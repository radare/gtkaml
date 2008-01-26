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

	
	
	
	public SAXParser( construct Vala.CodeContext context, construct Vala.SourceFile source_file) {
		states = new StateStack ();	
		code_generator = new Gtkaml.CodeGenerator (context, source_file);
		prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
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
		State initial_state = new State (StateId.SAX_PARSER_INITIAL_STATE, null, null);
		states.push (initial_state); 
		
		start_parsing (contents, length);

		string result = code_generator.yield();

		if (Report.get_errors() != 0)
			return null;

		return result;
	}
	
	[Import]
	public void start_parsing (string contents, ulong length);
	
	[Import]
	public void stop_parsing();
	
	[Import]
	public int column_number();
	
	[Import]
	public int line_number();

	public void cdata (string value, int len )
	{
		State state = states.peek ();
		if (state.state_id != StateId.SAX_PARSER_INITIAL_STATE){
			State previous_state = states.peek (1);
			if (state.state_id != StateId.SAX_PARSER_INITIAL_STATE) {
				code_generator.add_code (value.ndup (len));
			}
		}
	}

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
						if ( ns.prefix == null || ns.prefix != null && ns.prefix != "gtkaml")
						{
							string[] uri_definition = ns.URI.split_set(":");	
							var namespace_reference = new Vala.NamespaceReference (uri_definition[0], source_reference);
							source_file.add_using_directive (namespace_reference);
							code_generator.add_using (uri_definition[0]);
							if (ns.prefix != null)
								prefixes_namespaces.set (ns.prefix, uri_definition[0]); 
						}
					}
					//now generate the class definition
					Class clazz = lookup_class (prefix, localname);
					if (clazz == null) {
 						Report.error ( create_source_reference (), "%s not a class".printf (localname));
						stop_parsing (); 
						return;
					}
					code_generator.class_definition (prefix_to_namespace(null), "Gigel",  prefix_to_namespace(prefix), clazz.name);

					//generate attributes definition
					var attrs = parse_attributes (attributes, nb_attributes);
					set_members (attrs, "this", clazz);
					
					//push next state
					states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, "this", clazz));
					break;
				}
			case StateId.SAX_PARSER_CONTAINER_STATE:	
				{
					//get a name for the identifier
					string identifier = null;
					bool public_identifier = false;
					int counter = 0;
					
					Class clazz = lookup_class (prefix, localname);
					
					var attrs = parse_attributes (attributes, nb_attributes);
					foreach (Attribute attr in attrs) {
						if (attr.prefix!=null && attr.prefix=="gtkaml" && (attr.localname=="public" || attr.localname=="private")) {
							if (identifier!=null) {
								Report.error (source_reference, "Cannot have multiple identifier names:%s".printf(attr.localname));
								stop_parsing (); return;
							}
							identifier = attr.value;
							public_identifier = (attr.localname=="public");
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

					//generate member definition
					code_generator.add_member (identifier, prefix_to_namespace(prefix), clazz.name, public_identifier);
					
					//generate constructor
					code_generator.construct_member (identifier, prefix_to_namespace(prefix), clazz);
					
					set_members (attrs, identifier, clazz);
					//push next state
					states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, identifier, clazz));
					break;
				}
			default:
				stderr.printf("Invalid state\n");
				stop_parsing(); return;
		}
		
	}
	
	public void end_element (string localname, string prefix, string URI)
	{
		//stdout.printf("End element:%s\n", localname );
		states.pop();
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
	
	public SourceReference create_source_reference () {
		return new SourceReference (source_file, line_number (), column_number (), line_number (), column_number ()); 
	}
	
	private Class lookup_class (string xmlNamespace, string name)
	{
		foreach (Vala.Namespace ns in context.root.get_namespaces()) {
			if (ns.name == xmlNamespace) {
				Symbol s = ns.scope.lookup (name);
				if (s is Class) {
					return s as Class;
				}
			}
		}
		return null;
	}
	

	
	private void set_members (Gee.List<Attribute> attrs, string identifier, Class clazz) {
		
		foreach (Attribute attr in attrs) {
			if (attr.prefix == null)
			{
				Symbol m = SemanticAnalyzer.symbol_lookup_inherited(clazz, attr.localname);
				if (m == null) {
					Report.error ( create_source_reference (), "%s not found!\n".printf(attr.localname));
					stop_parsing ();
				} else if (m is Property) {
					Property p = m as Property;
					code_generator.set_identifier_property (identifier, p.name, p.type_reference, attr.value);
				} else if (m is Field) {
					Field f = m as Field;
					code_generator.set_identifier_property (identifier, f.name, f.type_reference, attr.value);
				}
			}					
		}
	}		
		
	[NoArrayLength]
	private Gee.List<Attribute> parse_attributes (string[] attributes, int nb_attributes)
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
	private Gee.List<Namespace> parse_namespaces (string[] namespaces, int nb_namespaces)
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
