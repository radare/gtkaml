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
	
	public void generate (ClassDefinition! class_definition)
	{
		if (class_definition is RootClassDefinition) {
			root_class_definition = class_definition as RootClassDefinition;
			foreach (string prefix in root_class_definition.prefixes_namespaces.get_keys ()) {
				add_using (prefix_to_namespace (prefix));
			}
			generate_root_class_definition (null/*class:namespace*/, "Gigel" /*class:name*/, root_class_definition.ns, root_class_definition.base_type.name );
		} else {
			generate_declaration (class_definition);
			generate_constructor (class_definition);
		}
		foreach (ClassDefinition child in class_definition.container_children)
			generate (child);
	}
	
	private void generate_root_class_definition (string ns, string!name, string base_ns, string! base_name)
	{
		class_start += "public class ";
		if (ns!=null) class_start += ns + ".";
		class_start += name + " : ";
		if (base_ns!=null) class_start += base_ns + ".";
		class_start += base_name + "\n{\n";
		class_end += "}\n";
	}

	public void generate_declaration (ClassDefinition! class_definition)
	{
		switch (class_definition.enclosing_scope) {
			case DefinitionScope.PUBLIC:
				members_declarations += "\tpublic " + class_definition.full_name + " " + class_definition.name + ";\n";
				break;
			case DefinitionScope.PRIVATE:
				members_declarations += "\tprivate " + class_definition.full_name + " " + class_definition.name + ";\n";
				break;
			case DefinitionScope.CONSTRUCTOR:
				construct_body_locals += "\t\t" + class_definition.full_name + " " + class_definition.name + ";\n";
			break;
		}
	}	
		
	
	public void generate_constructor (ClassDefinition! class_definition)
	{
		string construct_name = class_definition.construct_method.name;
		construct_name = construct_name.substring (".new".len (), construct_name.len () - ".new".len ());
		constructors += "\t\t" + class_definition.name + " = new " + class_definition.full_name + construct_name + " (";
		int i = 0;
		for (; i < class_definition.construct_method.parameter_attributes.size - 1 ; i++) {
			Attribute attr = class_definition.construct_method.parameter_attributes.get (i);
			constructors += generate_method_parameter (attr) + ", ";
		}
		constructors += generate_method_parameter (class_definition.construct_method.parameter_attributes.get (i));
		constructors += ");\n";		
	}
	
	public string yield() {
		return using_directives + class_start + members_declarations + code +
		"\tconstruct {\n" + construct_body_locals + "\n" + constructors + "\n" + construct_body + "\t}\n" + class_end;
	}
	
	private string prefix_to_namespace (string prefix)
	{
		return root_class_definition.prefixes_namespaces.get ((prefix==null)?"":prefix);		
	}

	
	public void add_using (string ns)
	{
		using_directives+="using %s;\n".printf(ns);
	}
	
	public string generate_method_parameter (Attribute attr)
	{
		if (attr.target_type is Field) {
			return generate_literal((attr.target_type as Field).type_reference, attr);
		} else if (attr.target_type is Property) {
			return generate_literal((attr.target_type as Property).type_reference, attr);
		} else {		
			Report.error(null, "cannot give a parameter %s to a method".printf (attr.name));
			return null;
		}
	}
	
	public string generate_literal (DataType type, Attribute attr) {
		string literal;
		if (attr is ComplexAttribute) return (attr as ComplexAttribute).complex_type.name;
		
		string value = (attr as SimpleAttribute).value;
		if (type is UnresolvedType)
		{
			UnresolvedType utype = type as UnresolvedType;
			if (value.has_prefix ("{") && value.has_suffix ("}")) {
				literal = value.substring (1, value.len () - 2);
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
	
	public void set_identifier_signal (string identifier, string signal_name, Collection<FormalParameter> parameters, string body)
	{
		string[] parameter_names = new string[0];
		int i = 0;
		string parameters_joined = "";
		
		if (parameters.size > 0) {
			parameter_names.resize (parameters.size);
			
			foreach (FormalParameter p in parameters) {
				parameter_names[i] = p.name;
			}
			parameters_joined = string.joinv (",", parameter_names);
		}		
		
		
		construct_body += "\t\t%s.%s += (%s) => { %s; };".printf (identifier, signal_name, parameters_joined, body);
	}
	
	public void add_code (string value)
	{
		code += value + "\n";
	}

	private string construct_default_parameters (Class clazz)
	{
		foreach (Method m in clazz.get_methods ()) {
			if (m is CreationMethod) {
				var cm = m as CreationMethod;
				if (cm != null && cm.name == ".new") {
					string parameters = ""; bool last_comma = false;
					foreach (FormalParameter p in cm.get_parameters ()) {
						UnresolvedType utype = p.type_reference as UnresolvedType;
						
						if (utype.nullable) {
							parameters += "null, ";
							last_comma = true;
						} else if (utype.type_name == "string") {
							parameters += "null, ";
							last_comma = true;
						} else if (utype.type_name == "bool") {
							parameters += "false, ";
							last_comma = true;
						} else { //value type not boolean?
							parameters += "0, ";
							last_comma = true;
						}
					}
					if (last_comma)
						parameters = parameters.ndup (parameters.len () - 2);
					return parameters;
				}
			}
		}
		return "";
	}
	
}
