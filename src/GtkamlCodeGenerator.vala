/* GtkamlCodeGenerator.vala
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
using Gee;

/**
 * Generates vala source from a given ClassDefinition root tag
 */
public class Gtkaml.CodeGenerator : GLib.Object {
	private string using_directives = new string();
	private string class_start = new string();
	private string members_declarations = new string();
	private string code = new string();
	private string construct_signals = new string ();
	private string constructors = new string();
	private string construct_body_locals = new string();
	private string construct_body = new string();
	private string class_end = new string();
	
	public CodeContext context {get;private set;}
	private RootClassDefinition root_class_definition {get;set;}
	
	
	public CodeGenerator (CodeContext context) {
		this.context = context;
	}
	
	/**
	 * returns a string that is the Vala source code
	 */
	public string yield() {
		string yielded = using_directives + "\n" +
		       class_start + "\n" +
		       members_declarations + "\n";

		for (int i = line_count(yielded) + 1; i < root_class_definition.original_first_code_line; i++) {
			yielded += "\n";
		} 

		yielded += code + "\n" +
		       construct_signals + "\n" +
		       "\tconstruct {\n" + 
		           construct_body_locals + "\n" + 
		           constructors + "\n" + 
		           construct_body + "\n" + 
		       "\t}\n" + 
		       class_end;
		return yielded;
	}
	
	/** 
	 * processes the root class definition and its children
	 */
	public void generate (ClassDefinition class_definition)
	{
		if (class_definition is RootClassDefinition) {
			root_class_definition = class_definition as RootClassDefinition;
			foreach (string prefix in root_class_definition.prefixes_namespaces.get_keys ()) {
				write_using (prefix_to_namespace (prefix));
			}
			write_root_class_definition (root_class_definition);
			write_preconstruct (root_class_definition);
			write_root_constructor_parameters (root_class_definition);
			write_complex_attributes (root_class_definition);
			write_setters (class_definition);
			generate_children (class_definition);
			write_construct (class_definition);
		} else if (class_definition is ReferenceClassDefinition) {
			generate_children (class_definition);
			write_add (class_definition);			
		} else {
			write_declaration (class_definition);
			write_complex_attributes (class_definition);//this must *really* go before the constructor
			write_constructor (class_definition);
			write_preconstruct (class_definition);
			write_setters (class_definition);
			generate_children (class_definition);
			write_construct (class_definition);
			write_add (class_definition);
		}
	}

	private int line_count (string s) {
		int count = 0;
		weak string current = s;
		while (current.get_char () != 0) {
			if (current.get_char () == '\n') { 
				count ++;
			}
			current = current.next_char ();
		}
		return count;
	}

	protected void generate_children (ClassDefinition class_definition)
	{
			foreach (ClassDefinition child in class_definition.children)
				generate (child);
	}

	protected void write_preconstruct (ClassDefinition class_definition)
	{
		if (class_definition.preconstruct_code != null) {
			write_construct_call (class_definition.identifier, class_definition.base_full_name, "preconstruct", class_definition.preconstruct_code);
		}
	}
	
	protected void write_construct (ClassDefinition class_definition)
	{
		if (class_definition.construct_code != null) {
			write_construct_call (class_definition.identifier, class_definition.base_full_name, "construct", class_definition.construct_code);
		}
	}

	protected void write_construct_call (string identifier, string identifier_type, string construct_type, string construct_code )
	{
		string construct_signal = identifier + "_" + construct_type;
		string real_construct_code = construct_code;
		real_construct_code.strip ();
		if (real_construct_code.has_prefix ("{"))
		{
			if (real_construct_code.has_suffix ("}")) {
				real_construct_code = real_construct_code.substring (1, real_construct_code.len () - 2);
			} else {
				Report.error (null, "%s for %s not properly ended".printf (construct_type, identifier));
			}
			
		}
		else 
			real_construct_code = " (thiz, target) => { %s; }".printf (construct_code);
		this.construct_signals += "\tprivate signal void %s (%s target);\n".printf (construct_signal, identifier_type);
		string to_append = "\t\t%s += %s;\n".printf (construct_signal, real_construct_code)
			+ "\t\t" + construct_signal + " (" + identifier + ");\n";
		if (construct_type == "preconstruct")
			this.constructors += to_append;
		else
			this.construct_body += to_append;
	}
		

	protected void write_complex_attributes (ClassDefinition class_definition)
	{	
		foreach (Attribute attr in class_definition.attrs) {
			if (attr is ComplexAttribute)
				generate ( (attr as ComplexAttribute).complex_type );
		}
		if (class_definition.construct_method != null && class_definition.construct_method.parameter_attributes != null)
			foreach (Attribute attr in class_definition.construct_method.parameter_attributes) {
				if (attr is ComplexAttribute)
					generate ( (attr as ComplexAttribute).complex_type );
			}
		bool first=true; //do not generate the first parameter of the container add child method
		if (class_definition.add_method != null && class_definition.add_method.parameter_attributes != null)
			foreach (Attribute attr in class_definition.add_method.parameter_attributes) {
				if (attr is ComplexAttribute && !first) {
					generate ( (attr as ComplexAttribute).complex_type );
				}
				first = false;
			}						
	}
	
	protected void write_root_class_definition (RootClassDefinition root_class_definition)
	{
		string ns = root_class_definition.target_namespace;
		string name = root_class_definition.target_name;
		string base_ns = root_class_definition.base_ns;
		string base_name = root_class_definition.base_type.name;
		
		class_start += "public class ";
		if (ns!=null) class_start += ns + ".";
		class_start += name + " : ";
		if (base_ns!=null) class_start += base_ns + ".";
		class_start += base_name;
		
		if (root_class_definition.implements != null)
		 	class_start += ", " + root_class_definition.implements;
		
		class_start += "\n{\n";
		class_end += "}\n";
		
		foreach (string code in root_class_definition.code) {
			add_code (code);
		}
	}

	protected void write_declaration (ClassDefinition class_definition)
	{
		switch (class_definition.definition_scope) {
			case DefinitionScope.PUBLIC:
				members_declarations += "\tpublic " + class_definition.base_full_name + " " + class_definition.identifier + ";\n";
				break;
			case DefinitionScope.PRIVATE:
				members_declarations += "\tprivate " + class_definition.base_full_name + " " + class_definition.identifier + ";\n";
				break;
			case DefinitionScope.CONSTRUCTOR:
				construct_body_locals += "\t\t" + class_definition.base_full_name + " " + class_definition.identifier + ";\n";
			break;
		}
	}	
		
	protected void write_root_constructor_parameters (RootClassDefinition class_definition)
	{
		foreach (Attribute attr in class_definition.construct_method.parameter_attributes)
		{
			write_setter (class_definition, attr);
		}
	}
	
	protected void write_constructor (ClassDefinition class_definition)
	{
		string construct_name = class_definition.construct_method.name;
		construct_name = construct_name.substring (".new".len (), construct_name.len () - ".new".len ());
		constructors += "\t\t" + class_definition.identifier + " = new " + class_definition.base_full_name + construct_name + " (";
		int i = 0;
		for (; i < class_definition.construct_method.parameter_attributes.size - 1 ; i++) {
			Attribute attr = class_definition.construct_method.parameter_attributes.get (i);
			constructors += generate_literal (attr) + ", ";
		}
		if (i < class_definition.construct_method.parameter_attributes.size)
			constructors += generate_literal (class_definition.construct_method.parameter_attributes.get (i));
		constructors += ");\n";		
	}
	
	protected void write_add (ClassDefinition child_definition) {
		if (child_definition.parent_container == null)
			return;
		construct_body += "\t\t%s.%s (".printf (child_definition.parent_container.identifier, child_definition.add_method.name);
		int i = 0;
		for (; i < child_definition.add_method.parameter_attributes.size - 1 ; i++) {
			Attribute attr = child_definition.add_method.parameter_attributes.get (i);
			construct_body += generate_literal (attr) + ", ";
		}
		if (i < child_definition.add_method.parameter_attributes.size)
			construct_body += generate_literal (child_definition.add_method.parameter_attributes.get (i));
		construct_body += ");\n";		
			
	}
	
	protected void write_setters (ClassDefinition class_definition)
	{
		foreach (Attribute attr in class_definition.attrs) 
		{
			if (attr.target_type is Field) {
				write_setter (class_definition, attr);
			} else if (attr.target_type is Property) {
				write_setter (class_definition, attr);
			} else if (attr.target_type is Vala.Signal) {
				write_signal_setter (class_definition, attr);
			} else {
				Report.error (class_definition.source_reference, "Unknown attribute type %s".printf (attr.name));
				return;
			}
		}
	}
	
	protected string prefix_to_namespace (string prefix)
	{
		return root_class_definition.prefixes_namespaces.get ((prefix==null)?"":prefix);		
	}

	
	protected void write_using (string ns)
	{
		using_directives+="using %s;\n".printf(ns);
	}
	
	
	protected string generate_literal (Attribute attr) {
		string literal;
		DataType type;
		
		if (attr is ComplexAttribute) {
			return (attr as ComplexAttribute).complex_type.identifier;
		}
		string value = (attr as SimpleAttribute).value;
		
		if (attr.target_type is Field) {
			type = (attr.target_type as Field).field_type;
		} else if (attr.target_type is Property) {
			type = (attr.target_type as Property).property_type;
		} else if (attr.target_type is FormalParameter) {
			type = (attr.target_type as FormalParameter).parameter_type;
		} else {		
			Report.error(null, "The attribute %s with value %s is not Field, Property or FormalParameter".printf (attr.name, value));
		}
		
		string stripped_value = value; stripped_value.strip ();

		if (stripped_value.has_prefix ("{")) {
			if (stripped_value.has_suffix ("}")) {
				literal = stripped_value.substring (1, stripped_value.len () - 2);
			} else {
				Report.error( null, "Attribute %s not properly ended".printf (attr.name));
			}
		} else if (type is UnresolvedType) {
			UnresolvedType utype = type as UnresolvedType;
			if (utype.unresolved_symbol.name == "string") {
				literal = "\"" + value.escape ("") + "\"";
			} else if (utype.unresolved_symbol.name == "bool") {
				if (stripped_value != "true" && stripped_value != "false") {
					Report.error (null, "'%s' is not a boolean literal".printf (value));
				}
				literal = stripped_value;
			} else {
				literal = stripped_value;
			}
		} else { 
			Report.error (null, "Don't know any literal of type '%s'\n".printf (attr.target_type.name)); 
			return stripped_value;
		}
		return literal;
	}

	protected void write_setter (ClassDefinition class_definition, Attribute attr) 
	{
		construct_body += "\t\t%s.%s = %s;\n".printf (class_definition.identifier, attr.name, generate_literal (attr));
	}
	
	protected void write_signal_setter (ClassDefinition class_definition, Attribute signal_attr)
	{
		if (! (signal_attr is SimpleAttribute) ) {
			Report.error (class_definition.source_reference, "Cannot set the signal '%s' to this value.".printf (signal_attr.name));
			return;
		}
		var simple_attribute = signal_attr as SimpleAttribute;
		var the_signal = simple_attribute.target_type as Vala.Signal;
		string parameters_joined = "";
		string body = simple_attribute.value;
		body.strip ();
		
		if ( body.has_prefix ("{") )
		{
			if ( body.has_suffix ("}") ) {
				parameters_joined = body.substring (1, body.len () - 2);
				construct_body += "\t\t%s.%s += %s;\n".printf (class_definition.identifier, signal_attr.name, parameters_joined);
				return;
			} else {
				Report.error (class_definition.source_reference, "Signal %s not properly ended".printf (signal_attr.name));
				return;
			}
		} 
		
		var parameters = the_signal.get_parameters ();
		string[] parameter_names = new string[0];
		int i = 0;
		
		parameters_joined = "target";
		if (parameters.size > 0) {
			parameter_names.resize (parameters.size+1);
			foreach (FormalParameter p in parameters) {
				parameter_names[i++] = p.name;
			}
			parameter_names[ parameters.size ] = null;
			parameters_joined += ", " + string.joinv (",", parameter_names);
			construct_body += "\t\t%s.%s += (%s) => { %s; };\n".printf (class_definition.identifier, signal_attr.name, parameters_joined, simple_attribute.value);
		} else {
			construct_body += "\t\t%s.%s += %s => { %s; };\n".printf (class_definition.identifier, signal_attr.name, parameters_joined, simple_attribute.value);
		}
		
	}
	
	protected void add_code (string value)
	{
		code += value + "\n";
	}

	
}
