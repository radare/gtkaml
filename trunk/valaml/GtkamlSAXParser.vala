using GLib;
using Vala;
using Gee;



/** this is the Flying Spaghetti Monster */
public class Gtkaml.SAXParser : GLib.Object {
	/** the only reason this is public is to be accessible from the [Import]s */
	public pointer xmlCtxt;
	private CodeContext context {get;set;}
	private SourceFile source_file {get;set;}
	private StateStack states {get;set;}
	private Gtkaml.CodeGenerator code_generator {get;set;}	
	/** prefix/vala.namespace pair */
	private Gee.Map<string,string> prefixes_namespaces {get;set;}

	
	
	
	public SAXParser( construct Vala.CodeContext context, construct Vala.SourceFile source_file) {
		states = new StateStack ();	
		code_generator = new Gtkaml.CodeGenerator (context, source_file);
		prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
	}
	
	public void parse ()
	{
		string contents;
		ulong length;
		
		states.push (new State (StateId.SAX_PARSER_INITIAL_STATE, null, null));
		
		FileUtils.get_contents (source_file.filename, out contents, out length);
		
		start_parsing (contents, length);
		stdout.printf("====GENERATED CODE====\n%s\n====\n", code_generator.yield());
		
	}
	
	[Import]
	public void start_parsing (string contents, ulong length);
	
	[Import]
	public void stop_parsing();
	
	[Import]
	private int column_number();
	
	[Import]
	private int line_number();

	[NoArrayLength]
	public void start_element (string localname, string prefix, 
	                         string URI, int nb_namespaces, string[] namespaces, 
	                         int nb_attributes, int nb_defaulted, string[] attributes)
	{

		var attrs = parse_attributes( attributes, nb_attributes );
		State state = states.peek();
		var source_reference = create_source_reference ();
		switch (state.state_id) {
			case StateId.SAX_PARSER_INITIAL_STATE:
				{	//Frist Tag! - that means, add "using" directives first
					var nss = parse_namespaces (namespaces, nb_namespaces);
					foreach (Namespace ns in nss) {
						string[] uri_definition = ns.URI.split_set(":");	
						stdout.printf ("adding using directive:%s\n", uri_definition[0]);
						var namespace_reference = new Vala.NamespaceReference (uri_definition[0], source_reference);
						source_file.add_using_directive (namespace_reference);
						code_generator.use (uri_definition[0]);
						if (ns.prefix != null)
							prefixes_namespaces.set (ns.prefix, uri_definition[0]); 
					}
					//now generate the class definition
					Symbol c = lookup (prefix, localname);
					if (!(c is Class)) {
						Report.error (source_reference, "%s not a class".printf(localname));
						stop_parsing ();
					}
					Class clazz = c as Class;
					code_generator.class_definition (prefix_to_namespace(null), "Gigel",  prefix_to_namespace(prefix), c.name);
					//generate attributes definition
					var attrs = parse_attributes (attributes, nb_attributes);
					foreach (Attribute attr in attrs) {
						//Property?
						bool set = false;
						foreach (Property p in clazz.get_properties()) {
							if (p.name == attr.localname) {
								if ( p.type_reference is UnresolvedType ) stdout.printf("Unresolved");
								if ( p.type_reference is VoidType ) stdout.printf("Void");
								if ( p.type_reference is MethodType ) stdout.printf("Method");
								if ( p.type_reference is DelegateType ) stdout.printf("Delegate");
								if ( p.type_reference is PointerType ) stdout.printf("Pointer");
								if ( p.type_reference is InvalidType ) stdout.printf("Invalid");
								if ( p.type_reference is ValueType ) stdout.printf("Value");
								if ( p.type_reference is SignalType ) stdout.printf("Signal");
								if ( p.type_reference is ReferenceType ) stdout.printf("Reference");
								code_generator.set_identifier_property ("this", p.name, p.type_reference, attr.value);
								set = true;
								break;
							}
						}
						if (!set) {
							Report.error ( source_reference, "%s not found!\n".printf(attr.localname));
							stop_parsing ();
						}
						//Field
					}
					//push next state
				}
			default:
				stderr.printf("Invalid state\n");
				stop_parsing();
		}
		
	}
	
	public void end_element (string localname, string prefix, string URI)
	{
		//stdout.printf("End element:%s\n", localname );
	}
	
	public void cdata_block (string cdata, int len)
	{
		//stdout.printf("cdata:%s", cdata.ndup(len));
	}
	
	private string prefix_to_namespace (string prefix)
	{
		if (prefix == null)
			return null;
		return prefixes_namespaces.get (prefix);		
	}
	
	private SourceReference create_source_reference () {
		return new SourceReference (source_file, line_number (), column_number (), line_number (), column_number ()); 
	}
	
	private Symbol lookup (string xmlNamespace, string name)
	{
		foreach (Vala.Namespace ns in context.root.get_namespaces()) {
			if (ns.name == xmlNamespace) {
				Symbol s = ns.scope.lookup (name);
				if (s != null)
					return s;
			}
		}
	}
	
	[NoArrayLength]
	public Gee.List<Attribute> parse_attributes (string[] attributes, int nb_attributes)
	{	
		int walker = 0;
		string end;
		var attribute_list = new Gee.ArrayList<Attribute> ();
		for (int i = 0; i < nb_attributes; i++)
		{
			var attr = new Attribute ();
			attr.localname = attributes[walker];
			attr.prefix = attributes[walker+1];
			attr.URI = attributes[walker+2];
			attr.value = attributes[walker+3];
			end = attributes[walker+4];
			attr.value = attr.value.ndup (attr.value.len () - end.len () );
			attribute_list.add (attr);
			walker += 5;
		}
		return attribute_list;
	}
	
	[NoArrayLength]
	public Gee.List<Namespace> parse_namespaces (string[] namespaces, int nb_namespaces)
	{
		int walker = 0;
		var namespace_list = new Gee.ArrayList<Namespace> ();
		for (int i = 0; i < nb_namespaces; i++) 
		{
			var ns = new Namespace ();
			ns.prefix = namespaces[walker];
			ns.URI = namespaces[walker+1];
			namespace_list.add (ns);
			walker += 2;
		}
		return namespace_list;
	}

}
