/* GtkamlImplicitsResolver.vala
 * 
 * Copyright (C) 2008 Vlad Grecescu
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with main.c; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
 *
 * Author:
 *        Vlad Grecescu (b100dian@gmail.com)
 */

using GLib;
using Vala;

/** 
 * determines which constructors to use or which container add functions to use;
 * moves attributes from their ClassDefinition to the add or construct methods
 */
public class Gtkaml.ImplicitsResolver : GLib.Object 
{
	/** configuration file with some hints*/
	public ImplicitsStore implicits_store {get;construct;}
	private Vala.CodeContext context {get;set;}
	
	public ImplicitsResolver (construct Vala.CodeContext! context, construct ImplicitsStore! implicits_store) 
	{
	}
	
	public void resolve (ClassDefinition !class_definition)
	{
		//determine which constructor shall we use
		//references don't have to be constructed
		if (!(class_definition is ReferenceClassDefinition)) {
			determine_construct_method (class_definition);
		}
		//then determine the container add function, if applicable
		if (class_definition.parent_container != null)
			determine_add_method (class_definition);
		//References should have no other attributes than the 'attached' ones (woa.. i learned xaml)
		if (class_definition is ReferenceClassDefinition && class_definition.attrs.size != 0 && class_definition.parent_container != null) {
			Report.error (class_definition.source_reference, "No attributes other than the container add parameters are allowed on existing widgets which are not standalone");
			return;
		}
		
		//resolve the rest of the attr types
		resolve_complex_attributes (class_definition);
		determine_attribute_types (class_definition);
		foreach (ClassDefinition child in class_definition.children)
			resolve (child); 
	}

	public void resolve_complex_attributes (ClassDefinition! class_definition)
	{
		foreach (Attribute attr in class_definition.attrs) {
			if (attr is ComplexAttribute)
				resolve ( (attr as ComplexAttribute).complex_type );
		}
		if (class_definition.construct_method != null && class_definition.construct_method.parameter_attributes != null)
			foreach (Attribute attr in class_definition.construct_method.parameter_attributes) {
				if (attr is ComplexAttribute)
					resolve ( (attr as ComplexAttribute).complex_type );
			}
		bool first=true; //do not generate the first parameter of the container add child method
		if (class_definition.add_method != null && class_definition.add_method.parameter_attributes != null)
			foreach (Attribute attr in class_definition.add_method.parameter_attributes) {
				if (attr is ComplexAttribute && !first) {
					resolve ( (attr as ComplexAttribute).complex_type );
				}
				first = false;
			}						
	}		

	/**
	 * Determines which add method of parent container would be useful
	 */	
	private void determine_add_method (ClassDefinition! child_definition)
	{
		Gee.List<Vala.Method> adds = lookup_container_add_methods( child_definition.parent_container.base_ns, child_definition.parent_container.base_type );

		Vala.Method determined_add = null;
		Gtkaml.AddMethod new_method = new Gtkaml.AddMethod ();
		Gee.List<Gtkaml.Attribute> to_remove = new Gee.ArrayList<Gtkaml.Attribute> ();
	
		int i;
		
		//todo: move this one in the parser
		//pass one: see if we find an explicitly specified add method
		foreach (Vala.Method add in adds) {
			foreach (Gtkaml.Attribute attr in child_definition.attrs) {
				if ( attr is SimpleAttribute && attr.name == add.name && (attr as SimpleAttribute).value == "true") {
					determined_add = add;
					to_remove.add (attr);
					break;
				}
			}
		}
		
		ComplexAttribute first_parameter = new ComplexAttribute ( "widget", child_definition);
		MethodMatcher method_matcher = new MethodMatcher (implicits_store, child_definition.parent_container, "container add method", first_parameter);
		
		//pass two: the first who matches the most parameters + warning if there are more
		if (determined_add == null) {
			foreach (Vala.Method method in adds) {
				method_matcher.add_method (method);
			}
			determined_add = method_matcher.determine_matching_method ();
			if (determined_add == null) {
				return;
			}
		} else {
			method_matcher.add_method (determined_add);
			method_matcher.determine_matching_method ();
		}
		
		new_method.name = determined_add.name;
		new_method.parameter_attributes.add (first_parameter);
		//move the attributes from class definition to add method
		Gee.List<ImplicitsParameter> parameters = implicits_store.determine_parameter_names_and_default_values (child_definition.parent_container, determined_add);
		foreach (ImplicitsParameter parameter in parameters) {
			foreach (Gtkaml.Attribute attr in child_definition.attrs) {
				if (parameter.name == attr.name) {
					new_method.parameter_attributes.add (attr);
					to_remove.add (attr);
					break;
				}
			}
		}		
		
		if ( parameters.size  != new_method.parameter_attributes.size)
		{
			//stderr.printf ("failed because %d != %d", parameters.size, new_method.parameter_attributes.size + i);
			i = 0;
			if (first_parameter!=null) i = 1;//skip child
			string message = "";
			for (; i < parameters.size -1; i++)
				message += parameters.get (i).name + ", ";
			if (i < parameters.size)
				message += parameters.get (i).name;
			Report.error (child_definition.source_reference, "No matching %s found for %s: specify at least: %s\n".printf ("add method", child_definition.parent_container.base_full_name, message));
			return;
		} 
		
		//determine attr.target_types directly from method signature
		Gee.Collection<FormalParameter> add_parameters = determined_add.get_parameters ();
		i = 0;
		foreach (FormalParameter formal_parameter in add_parameters)
		{
			if (!formal_parameter.ellipsis) {
				var attr = new_method.parameter_attributes.get (i);
				attr.target_type = formal_parameter;
				i++;
			}
		}
		
		
		foreach (Gtkaml.Attribute attr in to_remove)
			child_definition.attrs.remove (attr);
		
		child_definition.add_method =  new_method;
	}

	private void determine_construct_method (ClassDefinition! class_definition)
	{
		Gee.List<Vala.Method> constructors = lookup_constructors (class_definition.base_type);
		Vala.Method determined_constructor = null;
		Gtkaml.ConstructMethod new_method = new Gtkaml.ConstructMethod ();
		Gee.List<Gtkaml.Attribute> to_remove = new Gee.ArrayList<Gtkaml.Attribute> ();
		
		//todo: move this one in the parser
		//pass one: see if we find an explicitly specified constructor
		foreach (Vala.Method constructor in constructors) {
			foreach (Gtkaml.Attribute attr in class_definition.attrs) {
				if ( attr is SimpleAttribute && ".new." + attr.name == constructor.name && (attr as SimpleAttribute).value == "true") {
					determined_constructor = constructor;
					to_remove.add (attr);
					break;
				}
			}
		}
		
		MethodMatcher method_matcher = new MethodMatcher (implicits_store, class_definition, "constructor");
		
		//pass two: the first who matches the most parameters + warning if there are more
		if (determined_constructor == null) {
			foreach (Vala.Method method in constructors) {
				method_matcher.add_method (method);
			}
			determined_constructor = method_matcher.determine_matching_method ();
			if (determined_constructor == null) {
				return;
			}
		} else {
			method_matcher.add_method (determined_constructor);
			method_matcher.determine_matching_method ();
		}
		
		new_method.name = determined_constructor.name;
		//move the attributes from class definition to construct method
		Gee.List<ImplicitsParameter> parameters = implicits_store.determine_parameter_names_and_default_values (class_definition, determined_constructor);
		foreach (ImplicitsParameter parameter in parameters) {
			foreach (Gtkaml.Attribute attr in class_definition.attrs) {
				if (parameter.name == attr.name) {
					new_method.parameter_attributes.add (attr);
					to_remove.add (attr);
					break;
				}
			}
		}		
		
		if ( parameters.size  != new_method.parameter_attributes.size )
		{
			string message = "";
			int i = 0;
			for (i = 0; i < parameters.size -1; i++) {
				message += parameters.get (i).name + ", ";
			}
			if (i < parameters.size)
				message += parameters.get (i).name;
			Report.error (class_definition.source_reference, "No matching %s found for %s: specify at least: %s\n".printf ("creation method", class_definition.base_full_name, message));
			return;
		}
		
		
		//determine attr.target_types directly from constructor signature
		Gee.Collection<FormalParameter> constructor_parameters = determined_constructor.get_parameters ();
		int i = 0;
		foreach (FormalParameter formal_parameter in constructor_parameters)
		{
			if (!formal_parameter.ellipsis) {
				var attr = new_method.parameter_attributes.get (i);
				//stderr.printf ("matching %s formal parameter against %s attribute\n", formal_parameter.name, attr.name);
				attr.target_type = formal_parameter;
				i++;
			}
		}

		
		foreach (Gtkaml.Attribute attr in to_remove)
			class_definition.attrs.remove (attr);
		
		class_definition.construct_method =  new_method;
	}
	
	public Gee.List<Vala.Method> lookup_container_add_methods (string! ns, Class! container_class)
	{
		Gee.List<Vala.Method> methods = new Gee.ArrayList<Vala.Method> ();
		//FIXME workaround to stop recursion at TypeInstance and Object
		if (null == ns) 
			return methods;

		var add_methods = implicits_store.get_adds (ns, container_class.name);
		if (add_methods.size != 0)
		{
			foreach (string add_method in add_methods) {
				foreach (Vala.Method method in container_class.get_methods ())
					if (method.name == add_method) {
						methods.add (method);
						//stderr.printf ("Found direct add method '%s'(%x), we now have %d\n", method.name, method, methods.size);
						break;
					}
			}
		}
		
		foreach (DataType dt in container_class.get_base_types ()) {
			if (dt is UnresolvedType) {
				string ns;
				if ((dt as UnresolvedType).unresolved_symbol.inner == null) {
					continue;
				}
				ns = (dt as UnresolvedType).unresolved_symbol.inner.name;
				Class c = lookup_class (ns, (dt as UnresolvedType).unresolved_symbol.name);
				if (c != null) {
					var otherMethods = lookup_container_add_methods (ns, c);
					foreach (Vala.Method method in otherMethods) {
						methods.add (method);
					  //stderr.printf ("Found inherited add method '%s.%s.%s'(%x), we now have %d\n", ns, c.name, method.name, method, methods.size);
					}
					break;
				}
			}
		}
		
		return methods; 
	}

	
	private void determine_attribute_types (ClassDefinition! class_definition)
	{
		foreach (Attribute attr in class_definition.attrs)
		{
			attr.target_type = member_lookup_inherited (class_definition.base_type, attr.name);
			if (attr.target_type == null) {
				Report.error (class_definition.source_reference, "Cannot find member %s of class %s\n".printf (attr.name, class_definition.base_full_name));
			}
		}
	}
	
	private Member member_lookup_inherited (Class! clazz, string! member) {
		Member result = clazz.scope.lookup (member) as Member;
		if (result != null)
			return result;
		
		foreach (DataType dt in clazz.get_base_types ()) {
			if (dt is UnresolvedType)
			{
				var name = (dt as UnresolvedType).unresolved_symbol.name;
				string ns;
				if ((dt as UnresolvedType).unresolved_symbol.inner != null)
					ns = (dt as UnresolvedType).unresolved_symbol.inner.name;
				else
					ns = null;
				var clazz = lookup_class (ns, name);
				if (clazz != null && ( null != (result = member_lookup_inherited (clazz, member) as Member)))
					return result;
			}
		}
		return null;
	}								

	private Class lookup_class (string! xmlNamespace, string! name)
	{
		foreach (Vala.Namespace ns in context.root.get_namespaces ()) {
			if ( (ns.name == null && xmlNamespace == null ) || ns.name == xmlNamespace) {
				Symbol s = ns.scope.lookup (name);
				if (s is Class) {
					return s as Class;
				}
			}
		}
		return null;
	}


	private Gee.List<Vala.Method> lookup_constructors (Class! clazz) {
		var constructors = new Gee.ArrayList<Vala.Method> ();
		foreach (Vala.Method m in clazz.get_methods ()) {
			//todo: if m is ConstructMethod ?
			if (m.name.has_prefix (".new")) {
				constructors.add (m);
			}
		}	
		return constructors;
	}
}
