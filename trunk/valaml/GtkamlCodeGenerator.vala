using GLib;
using Vala;
using Gee;

public class Gtkaml.CodeGenerator : GLib.Object {
	/* this is the output */
	private string using_directives = new string();
	private string class_start = new string();
	private string members_declarations = new string();
	private string code = new string();
	private string constructors = new string();
	private string construct_body_locals = new string();
	private string construct_body = new string();
	private string class_end = new string();
	
	private CodeContext context {get;set;}
	private RootClassDefinition root_class_definition {get;set;}
	
	
	public CodeGenerator (construct CodeContext context) {}
	
	public string yield() {
		return using_directives + "\n" +
		       class_start + "\n" +
		       members_declarations + "\n" +
		       code + "\n" +
		       "\tconstruct {\n" + 
		           construct_body_locals + "\n" + 
		           constructors + "\n" + 
		           construct_body + "\n" + 
		       "\t}\n" + 
		       class_end;
	}
	
	public void generate (ClassDefinition! class_definition)
	{
		if (class_definition is RootClassDefinition) {
			root_class_definition = class_definition as RootClassDefinition;
			foreach (string prefix in root_class_definition.prefixes_namespaces.get_keys ()) {
				write_using (prefix_to_namespace (prefix));
			}
			write_root_class_definition (null/*class:namespace*/, "Gigel" /*class:name*/, root_class_definition.base_ns, root_class_definition.base_type.name );
		} else {
			write_declaration (class_definition);
			write_constructor (class_definition);
		}
		write_setters (class_definition);
		if (class_definition.parent_container != null)
			write_add (class_definition);
		foreach (ClassDefinition child in class_definition.children)
			generate (child);
	}
	
	private void write_root_class_definition (string ns, string!name, string base_ns, string! base_name)
	{
		class_start += "public class ";
		if (ns!=null) class_start += ns + ".";
		class_start += name + " : ";
		if (base_ns!=null) class_start += base_ns + ".";
		class_start += base_name + "\n{\n";
		class_end += "}\n";
	}

	public void write_declaration (ClassDefinition! class_definition)
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
		
	
	public void write_constructor (ClassDefinition! class_definition)
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
	
	public void write_add (ClassDefinition! child_definition) {
		construct_body += "\t\t%s.%s (".printf (child_definition.parent_container.identifier, child_definition.add_method.name);
		int i = 0;
		for (; i < child_definition.add_method.parameter_attributes.size - 1 ; i++) {
			Attribute attr = child_definition.add_method.parameter_attributes.get (i);
			construct_body += generate_literal (attr) + ", ";
		}
		if (i < child_definition.add_method.parameter_attributes.size)
			construct_body += generate_literal (child_definition.add_method.parameter_attributes.get (i));
		construct_body += ");\n\n";		
			
	}
	
	public void write_setters (ClassDefinition! class_definition)
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
	
	private string prefix_to_namespace (string prefix)
	{
		return root_class_definition.prefixes_namespaces.get ((prefix==null)?"":prefix);		
	}

	
	public void write_using (string ns)
	{
		using_directives+="using %s;\n".printf(ns);
	}
	
	
	public string generate_literal (Attribute attr) {
		string literal;
		DataType type;
		
		if (attr is ComplexAttribute) return (attr as ComplexAttribute).complex_type.identifier;
		
		if (attr.target_type is Field) {
			type = (attr.target_type as Field).type_reference;
		} else if (attr.target_type is Property) {
			type = (attr.target_type as Property).type_reference;
		} else if (attr.target_type is FormalParameter) {
			type = (attr.target_type as FormalParameter).type_reference;
		} else {		
			Report.error(null, "Don't know what to do with %s to a method".printf (attr.name));
			return null;
		}
		
		string value = (attr as SimpleAttribute).value;
		if (type is UnresolvedType)
		{
			UnresolvedType utype = type as UnresolvedType;
			if (value.has_prefix ("{")) {
				if (value.has_suffix ("}")) {
					literal = value.substring (1, value.len () - 2);
				} else {
					Report.error( null, "Attribute %s not properly ended".printf (attr.name));
				}
			} else if (utype.type_name == "string") {
				literal = "\"" + value + "\"";
			} else if (utype.type_name == "bool") {
				if (value != "true" && value != "false") {
					Report.error (null, "'%s' is not a boolean literal".printf (value));
					return null;
				}
				literal = value;
			} else {
				literal = value;
			}
			return literal;
		} else { 
			Report.error (null, "Don't know what to do with %s\n type".printf (attr.target_type.name)); 
			return null;
		}
	}

	public void write_setter (ClassDefinition! class_definition, Attribute attr) 
	{
		construct_body += "\t\t%s.%s = %s;\n".printf (class_definition.identifier, attr.name, generate_literal (attr));
	}
	
	public void write_signal_setter (ClassDefinition! class_definition, Attribute signal_attr)
	{
		if (! (signal_attr is SimpleAttribute) ) {
			Report.error (class_definition.source_reference, "Cannot set the signal '%s' to this value.".printf (signal_attr.name));
			return;
		}
		var simple_attribute = signal_attr as SimpleAttribute;
		var the_signal = simple_attribute.target_type as Vala.Signal;
		string parameters_joined = "";
		string body = simple_attribute.value;
		
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
			parameter_names.resize (parameters.size);
			foreach (FormalParameter p in parameters) {
				parameter_names[i] = p.name;
			}
			parameters_joined += ", " + string.joinv (",", parameter_names);
			construct_body += "\t\t%s.%s += (%s) => { %s; };\n".printf (class_definition.identifier, signal_attr.name, parameters_joined, body);
		} else {
			construct_body += "\t\t%s.%s += %s => { %s; };\n".printf (class_definition.identifier, signal_attr.name, parameters_joined, body);
		}
		
	}
	
	public void add_code (string value)
	{
		code += value + "\n";
	}

	
}
