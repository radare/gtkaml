using GLib;
using Vala;
using Gee;

private enum Gtkaml.StateId {
	SAX_PARSER_INITIAL_STATE = 0, /* here we generate the class declaration, based on current tag, attributes and namespaces */
	SAX_PARSER_CONTAINER_STATE,   /* then we can add things to the current container, based on current tag and attributes */
	SAX_PARSER_ATTRIBUTE_STATE,   /* the characters are then used as value, string literal - we need the current instance.property */
}


public class Gtkaml.SAXParser : GLib.Object {
	/** the only reason this is public is to be accessible from the [Import]s */
	public pointer xmlCtxt;
	private CodeContext context {get;set;}
	private SourceFile source_file {get;set;}
	private ArrayList<State> states = new ArrayList<State>();
	
	/* this is the output */
	private string class_start;
	private string members_declarations;
	private string code;
	private string construct_body;
	private string class_end;
	
	/* this is the Flying Spaghetti Monster */
	

	
	public SAXParser( construct Vala.CodeContext context, construct Vala.SourceFile source_file) { }
	
	public void parse ()
	{
		string contents;
		ulong length;
		
		
		FileUtils.get_contents (source_file.filename, out contents, out length);
		start_parsing (contents, length);
		
	}
	
	[Import]
	public void start_parsing (string contents, ulong length);
	
	[Import]
	public void stop_parsing();

	[NoArrayLength]
	public void start_element (string localname, string prefix, 
	                         string URI, int nb_namespaces, string[] namespaces, 
	                         int nb_attributes, int nb_defaulted, string[] attributes)
	{
		//stdout.printf("Found element:%s\n", localname);
		/*var attrs = parse_attributes( attributes, nb_attributes );
		var nss = parse_namespaces( namespaces, nb_namespaces );
		foreach (Attribute attr in attrs) {
			stdout.printf ("%s:%s:%s:%s\n", attr.localname, attr.prefix, attr.URI, attr.value);
		}
		foreach (Namespace ns in nss) {
			stdout.printf ("%s:%s\n", ns.prefix, ns.URI);
		}*/
		State current_state = states.get(states.size-1);
		
	}
	
	public void end_element (string localname, string prefix, string URI)
	{
		//stdout.printf("End element:%s\n", localname );
	}
	
	public void cdata_block (string cdata, int len)
	{
		//stdout.printf("cdata:%s", cdata.ndup(len));
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
