using GLib;
using Vala;
using Gee;

public class Gtkaml.CodeGenerator : GLib.Object {
	/* this is the output */
	private string using_directives = new string();
	private string class_start = new string();
	private string members_declarations = new string();
	private string code = new string();
	private string construct_body = new string();
	private string class_end = new string();
	
	private CodeContext context {get;set;}
	private SourceFile source_code {get;set;}
	
	public CodeGenerator(construct CodeContext context, construct SourceFile source_code) {}
	
	public string yield() {
		return using_directives + class_start + members_declarations + code +
		"\tconstruct {\n" + construct_body + "\t}\n" + class_end;
	}
	
	public void add_using (string ns)
	{
		using_directives+="using %s;\n".printf(ns);
	}
	
	public void class_definition (string ns, string name, string parent_ns, string parent_name) {
		class_start += "public class ";
		if (ns!=null) class_start += ns + ".";
		class_start += name + " : ";
		if (parent_ns!=null) class_start += parent_ns + ".";
		class_start += parent_name + "\n{\n";
		class_end += "}\n";
	}
	
	/** 
	 * Generates the code identifier.property = value
	 * Also inspects the type to determine if value is string, boolean, int or {expression}
	 */
	public void set_identifier_property (string identifier, string property, DataType type, string value) {
		string source_value;
		if (type is UnresolvedType)
		{
			UnresolvedType utype = type as UnresolvedType;
			//stdout.printf("%s", utype.type_name); 
			if (value.has_prefix ("{") && value.has_suffix ("}")) {
				source_value = value.substring (1, value.len () - 2);
			} else if (utype.type_name == "string") {
				source_value = "\"" + value + "\"";
			} else if (utype.type_name == "bool") {
				if (value != "true" && value != "false") {
					Report.error (null, "'%s' is not a boolean literal".printf (value));
				}
				source_value = value;
			} else {
				source_value = value;
			}
			construct_body += "\t\t%s.%s = %s;\n".printf (identifier, property, source_value);
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
	
	public void add_member (string identifier, string type_ns, string type, bool is_public)
	{
		members_declarations += (is_public?"\tpublic ":"\tprivate ");
		if (type_ns != null) 
			members_declarations += type_ns + ".";
		members_declarations += type + " " + identifier + ";\n";
	}
	
	public void construct_member (string identifier, string type_ns, Class clazz)
	{
		construct_body += "\n\t\t" + identifier + " = new ";
		if (type_ns != null) 
			construct_body += type_ns + ".";
		construct_body += clazz.name + " (" + construct_default_parameters (clazz) + ");\n";
		
	}

	public void add_code (string value)
	{
		code += value + "\n";
	}

	public void add_to_parent (string identifier, string parent_name, Class parent_type)
	{
		construct_body += "\t\t%s.add (%s);\n".printf (parent_name, identifier);
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
							parameters += "null,";
							last_comma = true;
						} else if (utype.type_name == "string") {
							parameters += "null,";
							last_comma = true;
						} else if (utype.type_name == "bool") {
							parameters += "false,";
							last_comma = true;
						} else { //value type not boolean?
							parameters += "0,";
							last_comma = true;
						}
					}
					if (last_comma)
						parameters = parameters.ndup (parameters.len () - 1);
					return parameters;
				}
			}
		}
		return "";
	}
	
}