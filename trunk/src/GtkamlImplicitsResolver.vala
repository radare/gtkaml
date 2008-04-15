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
	
	public ImplicitsResolver (Vala.CodeContext context, ImplicitsStore implicits_store) 
	{
		this.context = context;
		this.implicits_store = implicits_store;
	}
	
	public void resolve (ClassDefinition class_definition)
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
		}
		
		//resolve the rest of the attr types
		resolve_complex_attributes (class_definition);
		determine_attribute_types (class_definition);
		foreach (ClassDefinition child in class_definition.children)
			resolve (child); 
	}

	public void resolve_complex_attributes (ClassDefinition class_definition)
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
	private void determine_add_method (ClassDefinition child_definition)
	{
		Gee.List<Vala.Method> adds = new Gee.ArrayList<Vala.Method> ();
		lookup_container_add_methods( child_definition.parent_container.base_ns, child_definition.parent_container.base_type, adds );

		Vala.Method determined_add = null;
		Gtkaml.AddMethod new_method = new Gtkaml.AddMethod ();
		Gee.List<Gtkaml.Attribute> to_remove = new Gee.ArrayList<Gtkaml.Attribute> ();
	
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
			if (null == method_matcher.determine_matching_method ())
			{
				return;
			}
		}
		
		method_matcher.set_method_parameters (new_method, determined_add);
		
		foreach (Gtkaml.Attribute attr in to_remove)
			child_definition.attrs.remove (attr);
		
		child_definition.add_method =  new_method;
	}

	private void determine_construct_method (ClassDefinition class_definition)
	{
		Gee.List<Vala.Method> constructors = lookup_constructors (class_definition.base_type);
		Vala.Method determined_constructor = null;
		Gtkaml.ConstructMethod new_method = new Gtkaml.ConstructMethod ();
		Gee.List<Gtkaml.Attribute> to_remove = new Gee.ArrayList<Gtkaml.Attribute> ();
		
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
			if (null == method_matcher.determine_matching_method ())
			{
				return;
			}
		}
		
		method_matcher.set_method_parameters (new_method, determined_constructor);
		
		foreach (Gtkaml.Attribute attr in to_remove)
			class_definition.attrs.remove (attr);
		
		class_definition.construct_method =  new_method;
	}
	
	private void lookup_container_add_methods_for_class (string ns, Class container_class_implicits_entry, string? ns2, Class? container_class_holding_methods, Gee.List<Vala.Method> methods)
	{
		if (ns2 == null)
			return;

		//recurse over base classes - ugly ugly ugly!
		foreach (DataType dt in container_class_holding_methods.get_base_types ()) {
			if (dt is UnresolvedType) {
				string utns = get_unresolved_type_ns (dt as UnresolvedType);
				if (utns == null) continue;
				Class c = lookup_class (utns, (dt as UnresolvedType).unresolved_symbol.name);
				if (c != null) {
					lookup_container_add_methods_for_class (ns, container_class_implicits_entry, utns, c, methods);
				}
			}
		}
			
		var add_methods = implicits_store.get_adds (ns, container_class_implicits_entry.name);
		if (add_methods.size != 0)
		{
			foreach (string add_method in add_methods) {
				foreach (Vala.Method method in container_class_holding_methods.get_methods ())
					if (method.name == add_method) {
						methods.add (method);
						//stderr.printf ("Found direct add method '%s.%s' for %s(%x), we now have %d\n", container_class_holding_methods.name, container_class_implicits_entry.name, method.name, methods.size);
						break;
					}
			}
		}

	}
	
	public void lookup_container_add_methods (string? ns, Class? container_class, Gee.List<Vala.Method> methods)
	{
		//FIXME workaround to stop recursion at TypeInstance and Object
		if (null == ns) 
			return;

		lookup_container_add_methods_for_class (ns, container_class, ns, container_class, methods);
		
		foreach (DataType dt in container_class.get_base_types ()) {
			if (dt is UnresolvedType) {
				string utns = get_unresolved_type_ns (dt as UnresolvedType);
				if (utns == null) continue;
				Class c = lookup_class (utns, (dt as UnresolvedType).unresolved_symbol.name);
				if (c != null) {
					//over inherited implicits definitions
					lookup_container_add_methods (utns, c, methods);
					break;
				}
			}
		}
	}

	private string? get_unresolved_type_ns (UnresolvedType? dt)
	{
		if (dt.unresolved_symbol.inner == null) {
			return null;
		}
		return dt.unresolved_symbol.inner.name; 
	}
	
	private void determine_attribute_types (ClassDefinition class_definition)
	{
		foreach (Attribute attr in class_definition.attrs)
		{
			attr.target_type = member_lookup_inherited (class_definition.base_type, attr.name);
			if (attr.target_type == null) {
				Report.error (class_definition.source_reference, "Cannot find member %s of class %s\n".printf (attr.name, class_definition.base_full_name));
			}
		}
	}
	
	private Member? member_lookup_inherited (Class clazz, string member) {
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

	private Class? lookup_class (string xmlNamespace, string name)
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


	private Gee.List<Vala.Method> lookup_constructors (Class clazz) {
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
