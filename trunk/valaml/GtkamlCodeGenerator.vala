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
		return using_directives + class_start + members_declarations + code + construct_body + class_end;
	}
	
	public void use (string ns)
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
	
	public void set_identifier_property (string identifier, string property, DataType type, string value) {
		string source_value;
		if (type is UnresolvedType)
		{
			UnresolvedType utype = type as UnresolvedType;
			stdout.printf("%s", utype.type_name);
			if ((utype as UnresolvedType).type_name == "string")
				source_value = "\"" + value + "\"";
			else
				source_value = value;
			code += "\t%s.%s = %s;\n".printf (identifier, property, source_value);
		}
	}
}
