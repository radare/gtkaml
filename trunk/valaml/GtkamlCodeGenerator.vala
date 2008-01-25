using GLib;
using Vala;

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
			} else if (utype.type_name == "boolean") {
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
	
	public void add_member (string identifier, string type_ns, string type, bool is_public)
	{
		members_declarations += (is_public?"\tpublic ":"\tprivate ");
		if (type_ns != null) 
			members_declarations += type_ns + ".";
		members_declarations += type + " " + identifier + ";\n";
	}
	
	public void construct_member (string identifier, string type_ns, string type)
	{
		construct_body += "\n\t\t" + identifier + " = new ";
		if (type_ns != null) 
			construct_body += type_ns + ".";
		construct_body += type + "();\n";
	}
}
