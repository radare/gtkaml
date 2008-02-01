using GLib;
using Vala;
using Gee;



/* this is the Flying Spaghetti Monster */
public class Gtkaml.SAXParser : GLib.Object {
	/** the only reason this is public is to be accessible from the [Import]s */
	public pointer xmlCtxt;
	private CodeContext context {get;set;}
	private SourceFile source_file {get;set;}
	private StateStack states {get;set;}
	private Map<string,int> generated_identifiers_counter = new HashMap<string,int> (str_hash, str_equal);
	private Collection<string> used_identifiers = new ArrayList<string> (str_equal);
	private Gtkaml.CodeGenerator code_generator {get;set;}	
	/** prefix/vala.namespace pair */
	private Gee.Map<string,string> prefixes_namespaces {get;set;}

	private Gtkaml.RootClassDefinition root_class_definition {get;set;}	
	public string gtkaml_prefix;
	
	
	public SAXParser( construct Vala.CodeContext context, construct Vala.SourceFile source_file) {
		
	}
	
	construct {
		states = new StateStack ();	
		prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
		root_class_definition = null;
		code_generator = new Gtkaml.CodeGenerator (context);
	}
	
	public virtual string parse ()
	{
		string contents;
		ulong length;
		
		try {
			FileUtils.get_contents ( this.source_file.filename, out contents, out length);
		} catch (FileError e) {
			Report.error (null, e.message);
			return null;
		}

		State initial_state = new State (StateId.SAX_PARSER_INITIAL_STATE, null);
		states.push (initial_state); 
		start_parsing (contents, length);

		if (Report.get_errors() != 0)
			return null;

		var implicitsResolver = new ImplicitsResolver (context, "key-file-name"); 
		implicitsResolver.resolve (root_class_definition);
		
		if (Report.get_errors() != 0)
			return null;

		
		code_generator.generate (root_class_definition);

		if (Report.get_errors() != 0)
			return null;
		stderr.printf ("===GENERATED CODE==\n%s\n===\n", code_generator.yield ());

		return code_generator.yield ();
	}
	
	[Import]
	public void start_parsing (string contents, ulong length);
	
	[Import]
	public void stop_parsing();
	
	[Import]
	public int column_number();
	
	[Import]
	public int line_number();

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
				{	
					
					//Frist Tag! - that means, add "using" directives first
					var nss = parse_namespaces (namespaces, nb_namespaces);
					foreach (XmlNamespace ns in nss) {
						if ( ns.prefix == null || ns.prefix != null && ns.prefix != gtkaml_prefix)
						{
							string[] uri_definition = ns.URI.split_set(":");	
							var namespace_reference = new Vala.NamespaceReference (uri_definition[0], source_reference);
							source_file.add_using_directive (namespace_reference);
							if (ns.prefix==null) {
								prefixes_namespaces.set ("", uri_definition[0]); 
							} else {
								prefixes_namespaces.set (ns.prefix, uri_definition[0]); 
							}
						}
					}
					
					//now generate the class definition
					Class clazz = lookup_class (prefix, localname);
					if (clazz == null) {
 						Report.error ( source_reference, "%s not a class".printf (localname));
						stop_parsing (); 
						return;
					}
					
					this.root_class_definition = new Gtkaml.RootClassDefinition (source_reference, "this", prefix_to_namespace (prefix),  clazz, DefinitionScope.MAIN_CLASS);
					this.root_class_definition.prefixes_namespaces = prefixes_namespaces;
					foreach (XmlAttribute attr in attrs) {
						var simple_attribute = new SimpleAttribute (attr.localname, attr.value);
						root_class_definition.add_attribute (simple_attribute);
					}
					
					//push next state
					states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, root_class_definition));
					break;
				}
			case StateId.SAX_PARSER_CONTAINER_STATE:	
				{
					//get a name for the identifier
					string identifier = null;
					DefinitionScope identifier_scope = DefinitionScope.CONSTRUCTOR;
					
					int counter = 0;
					
					Class clazz = lookup_class (prefix, localname);
					
					foreach (XmlAttribute attr in attrs) {
						if (attr.prefix!=null && attr.prefix==gtkaml_prefix && (attr.localname=="public" || attr.localname=="private")) {
							if (identifier!=null) {
								Report.error (source_reference, "Cannot have multiple identifier names:%s".printf(attr.localname));
								stop_parsing (); return;
							}
							identifier = attr.value;
							if (attr.localname == "public") {
								identifier_scope = DefinitionScope.PUBLIC;
							} else {
								identifier_scope = DefinitionScope.PRIVATE;
							}
						}
					}
					
					if (identifier == null) {
						//generate a name for the identifier
						identifier = clazz.name.down (clazz.name.len ());
						if (generated_identifiers_counter.contains (identifier)) {
							counter = generated_identifiers_counter.get (identifier);
						}
						identifier = "_%s%d".printf (identifier, counter);
						counter++;
						generated_identifiers_counter.set (clazz.name.down (clazz.name.len ()), counter);
					}

					ClassDefinition class_definition = new ClassDefinition (source_reference, identifier, prefix_to_namespace (prefix), clazz, identifier_scope, state.class_definition);
					foreach (XmlAttribute attr in attrs) {
						if (attr.prefix == null) {
							var simple_attribute = new SimpleAttribute (attr.localname, attr.value);
							class_definition.add_attribute (simple_attribute);
						}
					}
					

					
					//push next state
					states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, class_definition));
					break;
				}
			default:
				stderr.printf("Invalid state\n");
				stop_parsing(); return;
		}
		
	}
	
	public void end_element (string localname, string prefix, string URI)
	{
		states.pop();
	}
	
	public void cdata_block (string cdata, int len)
	{
		State state = states.peek ();
		if (state.state_id != StateId.SAX_PARSER_INITIAL_STATE){
			State previous_state = states.peek (1);
			if (state.state_id != StateId.SAX_PARSER_INITIAL_STATE) {
				code_generator.add_code (cdata.ndup (len));
			}
		}

	}

	private string prefix_to_namespace (string prefix)
	{
		if (prefix==null)
			return prefixes_namespaces.get ("");		
		return prefixes_namespaces.get (prefix);		
	}
	
	public SourceReference create_source_reference () {
		return new SourceReference (source_file, line_number (), column_number (), line_number (), column_number ()); 
	}
	
	private Class lookup_class (string xmlNamespace, string name)
	{
		foreach (Vala.Namespace ns in context.root.get_namespaces ()) {
			if (ns.name == xmlNamespace) {
				Symbol s = ns.scope.lookup (name);
				if (s is Class) {
					return (s as Class);
				}
			}
		}
		return null;
	}
	
	
	[NoArrayLength]
	private Gee.List<XmlAttribute> parse_attributes (string[] attributes, int nb_attributes)
	{	
		int walker = 0;
		string end;
		var attribute_list = new Gee.ArrayList<XmlAttribute> ();
		for (int i = 0; i < nb_attributes; i++)
		{
			var attr = new XmlAttribute ();
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
	private Gee.List<XmlNamespace> parse_namespaces (string[] namespaces, int nb_namespaces)
	{
		int walker = 0;
		var namespace_list = new Gee.ArrayList<XmlNamespace> ();
		for (int i = 0; i < nb_namespaces; i++) 
		{
			var ns = new XmlNamespace ();
			ns.prefix = namespaces[walker];
			ns.URI = namespaces[walker+1];
			if (ns.URI != null && ns.URI.has_prefix ("http://gtkaml.org/")) {
				gtkaml_prefix = ns.prefix;
			}
			namespace_list.add (ns);
			walker += 2;
		}
		return namespace_list;
	}

}
