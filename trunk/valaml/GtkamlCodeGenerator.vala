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
	
	public void class_definition_start( string name, Class parent ) {
		class_start += "public class "+name+" : "+ parent.name;
	}
}
