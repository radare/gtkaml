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
public class Gtkaml.ImplicitsResolver : GLib.Object {
	/** configuration file with some hints*/
	public ImplicitsStore implicits_store {get;construct;}
	public Vala.CodeContext context {get;construct;}
	
	public ImplicitsResolver (Vala.CodeContext context, ImplicitsStore implicits_store) {
		base (context: context, implicits_store: implicits_store);
	}
	
	public void resolve (ClassDefinition class_definition) {
		//determine which constructor shall we use
		//references don't have to be constructed
		if (!(class_definition is ReferenceClassDefinition))
			determine_construct_method (class_definition);

		//then determine the container add function, if applicable
		if (class_definition.parent_container != null)
			determine_add_method (class_definition);

		//resolve the rest of the attr types
		resolve_complex_attributes (class_definition);
		determine_attribute_types (class_definition);
		foreach (ClassDefinition child in class_definition.children)
			resolve (child); 
	}

	public void resolve_complex_attributes (ClassDefinition class_definition) {
		foreach (Attribute attr in class_definition.attrs) {
			if (attr is ComplexAttribute)
				resolve ( (attr as ComplexAttribute).complex_type );
		}
		if (class_definition.construct_method != null &&
			class_definition.construct_method.parameter_attributes != null)
		{
			foreach (Attribute attr in class_definition.construct_method.parameter_attributes) {
				if (attr is ComplexAttribute)
					resolve ( (attr as ComplexAttribute).complex_type );
			}
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
	private void determine_add_method (ClassDefinition child_definition) {
		Vala.List<Vala.Method> adds = new Vala.ArrayList<Vala.Method> ();
		lookup_container_add_methods (child_definition.parent_container.base_ns,
			child_definition.parent_container.base_type, adds );

		Vala.Method determined_add = null;
		Gtkaml.AddMethod new_method = new Gtkaml.AddMethod ();
		Vala.List<Gtkaml.Attribute> to_remove = new Vala.ArrayList<Gtkaml.Attribute> ();
	
		//pass one: see if we find an explicitly specified add method
		foreach (Vala.Method add in adds) {
			foreach (Gtkaml.Attribute attr in child_definition.attrs) {
				if (attr is SimpleAttribute && attr.name == add.name
					&& (attr as SimpleAttribute).value == "true")
				{
					determined_add = add;
					to_remove.add (attr);
					break;
				}
			}
		}
		
		ComplexAttribute first_parameter = new ComplexAttribute ("widget", child_definition);
		MethodMatcher method_matcher = new MethodMatcher (implicits_store, child_definition.parent_container, "container add method", first_parameter);
		
		//pass two: the first who matches the most parameters + warning if there are more
		if (determined_add == null) {
			foreach (Vala.Method method in adds) {
				method_matcher.add_method (method);
			}
			determined_add = method_matcher.determine_matching_method ();
			if (determined_add == null)
				return;
		} else {
			method_matcher.add_method (determined_add);
			if (null == method_matcher.determine_matching_method ())
				return;
		}
		
		method_matcher.set_method_parameters (new_method, determined_add);
		
		foreach (Gtkaml.Attribute attr in to_remove)
			child_definition.attrs.remove (attr);
		
		child_definition.add_method =  new_method;
	}

	private void determine_construct_method (ClassDefinition class_definition) {
		Vala.List<Vala.Method> constructors = lookup_constructors (class_definition.base_type);
		Vala.Method determined_constructor = null;
		Gtkaml.ConstructMethod new_method = new Gtkaml.ConstructMethod ();
		Vala.List<Gtkaml.Attribute> to_remove = new Vala.ArrayList<Gtkaml.Attribute> ();
		
		//pass one: see if we find an explicitly specified constructor
		foreach (Vala.Method constructor in constructors) {
			foreach (Gtkaml.Attribute attr in class_definition.attrs) {
				if (attr is SimpleAttribute && attr.name == constructor.name &&
					(attr as SimpleAttribute).value == "true")
				{
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
			if (determined_constructor == null)
				return;
		} else {
			method_matcher.add_method (determined_constructor);
			if (null == method_matcher.determine_matching_method ())
				return;
		}
		
		method_matcher.set_method_parameters (new_method, determined_constructor);
		
		foreach (Gtkaml.Attribute attr in to_remove)
			class_definition.attrs.remove (attr);
		
		class_definition.construct_method =  new_method;
	}

	private void lookup_container_add_methods_for_class (string ns,
		TypeSymbol container_class_implicits_entry, string? ns2,
		TypeSymbol? container_class_holding_methods,
		Vala.List<Vala.Method> methods)
	{
		if (ns2 == null)
			return;
			
		Vala.List<DataType> base_types;
		if (container_class_holding_methods is Class?)
			base_types = (container_class_holding_methods as Class).get_base_types ();
		else if (container_class_holding_methods is Interface?)
			base_types = (container_class_holding_methods as Interface).get_prerequisites ();
			else base_types = new Vala.ArrayList<DataType> ();

		//recurse over base classes - ugly ugly ugly!
		foreach (DataType dt in base_types) {
			if (dt is UnresolvedType) {
				string utns = get_unresolved_type_ns (dt as UnresolvedType);
				if (utns == null)
					continue;
				TypeSymbol c = lookup_class (utns,
					(dt as UnresolvedType).unresolved_symbol.name);
				if (c != null)
					lookup_container_add_methods_for_class (ns,
						container_class_implicits_entry, utns, c, methods);
			}
		}
			
		var add_methods = implicits_store.get_adds (ns, container_class_implicits_entry.name);
		if (add_methods.size != 0) {
			foreach (string add_method in add_methods) {
				Vala.List<Vala.Method> class_methods = new ArrayList<Vala.Method> ();
				if (container_class_holding_methods is Struct)
					class_methods = ((Struct)container_class_holding_methods).get_methods ();
				if (container_class_holding_methods is ObjectTypeSymbol)
					class_methods = ((ObjectTypeSymbol)container_class_holding_methods).get_methods ();
				foreach (Vala.Method method in class_methods)
					if (method.name == add_method) {
						methods.add (method);
						//stderr.printf ("Found direct add method '%s.%s' for %s, we now have %d\n", container_class_holding_methods.name, method.name, container_class_implicits_entry.name, methods.size);
						break;
					}
			}
		}
	}
	
	public void lookup_container_add_methods (string? ns, TypeSymbol? container_class, Vala.List<Vala.Method> methods) {
		//FIXME workaround to stop recursion at TypeInstance and Object
		if (null == ns) 
			return;

		//first recurse over class hierarchy
		lookup_container_add_methods_for_class (ns, container_class, ns, container_class, methods);

		//then recurse over implicits definitions
		if (container_class is Class)
		foreach (DataType dt in ((Class)container_class).get_base_types ()) {
			if (dt is UnresolvedType) {
				string utns = get_unresolved_type_ns (dt as UnresolvedType);
				if (utns == null) continue;
				TypeSymbol c = lookup_class (utns, (dt as UnresolvedType).unresolved_symbol.name) as Class;
				if (c != null) {
					//over inherited implicits definitions
					lookup_container_add_methods (utns, c, methods);
					break;
				}
			}
		}
	}

	private string? get_unresolved_type_ns (UnresolvedType? dt) {
		if (dt.unresolved_symbol.inner == null)
			return null;
		return dt.unresolved_symbol.inner.name; 
	}
	
	private void determine_attribute_types (ClassDefinition class_definition) {
		foreach (Attribute attr in class_definition.attrs) {
			attr.target_type = member_lookup_inherited (class_definition.base_type, attr.name);
			if (attr.target_type == null)
				Report.error (class_definition.source_reference,
					"Cannot find member %s of class %s\n".printf (attr.name,
					class_definition.base_full_name));
		}
	}
	
	private Symbol? member_lookup_inherited (TypeSymbol clazz, string member) {
		Symbol result = clazz.scope.lookup (member) as Symbol;
		if (result != null)
			return result;

		/* recurse over base types */
		if (clazz is Class)
		foreach (DataType dt in ((Class)clazz).get_base_types ()) {
			if (dt is UnresolvedType) {
				var name = (dt as UnresolvedType).unresolved_symbol.name;
				string ns;
				if ((dt as UnresolvedType).unresolved_symbol.inner != null)
					ns = (dt as UnresolvedType).unresolved_symbol.inner.name;
				else
					ns = null;
				var otherclazz = lookup_class (ns, name);
				if (otherclazz != null && ( null != (result = member_lookup_inherited (otherclazz, member) as Symbol)))
					return result;
			}
		}
		return null;
	}

	private ObjectTypeSymbol? lookup_class (string? xmlNamespace, string name) {
		foreach (Vala.Namespace ns in context.root.get_namespaces ()) {
			if ((ns.name == null && xmlNamespace == null ) || ns.name == xmlNamespace) {
				Symbol s = ns.scope.lookup (name);
				if (s is ObjectTypeSymbol)
					return s as ObjectTypeSymbol;
			}
		}
		return null;
	}

	private Vala.List<Vala.Method> lookup_constructors (TypeSymbol clazz) {
		var constructors = new Vala.ArrayList<Vala.Method> ();

		if (clazz is Class)
		foreach (Vala.Method m in ((Class)clazz).get_methods ()) {
			if (m is CreationMethod) {
				constructors.add (m);
			}
		}

		if (clazz is Struct) {
			bool no_default_constructor = true;
			foreach (Vala.Method m in ((Struct)clazz).get_methods ()) {
				if (m is CreationMethod) {
					constructors.add (m);
					if (m.name == ".new")
						no_default_constructor = false;
				}
			}

			if (no_default_constructor) {
				Vala.Method m = new Vala.CreationMethod (clazz.name, ".new");
				m.owner = clazz.scope;
				constructors.add (m);
			}
		}
		return constructors;
	}
}
