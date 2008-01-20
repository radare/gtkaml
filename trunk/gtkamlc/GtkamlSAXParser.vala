using GLib;
using Vala;


public class Gtkaml.SAXParser : Gtkaml.Dummy {


	private CodeContext context;
	private SourceFile current_source_file;
	public pointer xmlCtxt;
	
	public void parse( CodeContext! context )
	{
		this.context = context;
		base.parse( context );
	}
	
	public override void visit_source_file (SourceFile! source_file) {
		if (source_file.filename.has_suffix (".vala") || source_file.filename.has_suffix (".vapi")) {
			base.visit_source_file (source_file);
		} else if (source_file.filename.has_suffix (".gtkaml")) {
			parse_gtkaml_file (source_file);
		}
	}
	
	public virtual void parse_gtkaml_file (SourceFile! gtkaml_source_file) {
		if (FileUtils.test (gtkaml_source_file.filename, FileTest.EXISTS)) {
			try {
				string vala_contents = call_sax_parser( this.context, gtkaml_source_file );				
				string vala_filename = gtkaml_source_file.filename.ndup (gtkaml_source_file.filename.len () - ".gtkaml".len ()) + ".vala";
				if (false) FileUtils.set_contents (vala_filename, vala_contents);
				gtkaml_source_file.filename = vala_filename;
				base.visit_source_file (gtkaml_source_file);
			} catch (FileError e) {
				Report.error (null, e.message);
			}
		} else {
			Report.error (null, "%s not found".printf(gtkaml_source_file.filename));
		} 
	}
		
	private string call_sax_parser( CodeContext! context, SourceFile source_file )
	{
		string contents;
		ulong length;
		
		
		FileUtils.get_contents (source_file.filename, out contents, out length);
		
		this.current_source_file = source_file;
		this.start_parsing( contents, length );
		/*SourceFile dummy_file = new SourceFile( context, source_file.filename );
		
		NamespaceReference ns_ref = new NamespaceReference("Gtk", new SourceReference(source_file));
		
		dummy_file.add_using_directive(ns_ref);
		
		foreach (Namespace ns in context.root.get_namespaces()) {
			stdout.printf("%s\n", ns.name );
			if (ns.name == "Gtk")
			{
				Class s = ns.scope.lookup("Label") as Class;
				if (s != null) {
					foreach (Property p in s.get_properties()) {
						stdout.printf("=>%s\n", p.name);
					}
				}
			}
		}*/
		
		return contents;
	}
	
	public class Attribute : GLib.Object {
		public string localname;
		public string prefix;
		public string URI;
		public string value;
	}
	
	public class Namespace : GLib.Object {
		public string prefix;
		public string URI;
	}
	
	[Import]
	public void start_parsing( string contents, ulong length );
	
	[Import]
	public void stop_parsing();
	
	[NoArrayLength]
	public void start_element (string localname, string prefix, 
	                         string URI, int nb_namespaces, string[] namespaces, 
	                         int nb_attributes, int nb_defaulted, string[] attributes)
	{
		//stdout.printf("Found element:%s\n", localname);
		var attrs = parse_attributes( attributes, nb_attributes );
		var nss = parse_namespaces( namespaces, nb_namespaces );
		foreach (Attribute attr in attrs) {
			stdout.printf ("%s:%s:%s:%s\n", attr.localname, attr.prefix, attr.URI, attr.value);
		}
		foreach (Namespace ns in nss) {
			stdout.printf ("%s:%s\n", ns.prefix, ns.URI);
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
