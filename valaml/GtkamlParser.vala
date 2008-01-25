using GLib;
using Vala;


public class Gtkaml.Parser : Gtkaml.Dummy {


	private CodeContext context;
	private SourceFile current_source_file;
	
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
				if (vala_contents != null) { 
					string vala_filename = gtkaml_source_file.filename.ndup (gtkaml_source_file.filename.len () - ".gtkaml".len ()) + ".vala";
					FileUtils.set_contents (vala_filename, vala_contents);
					gtkaml_source_file.filename = vala_filename;
					base.visit_source_file (gtkaml_source_file);
				} 
			} catch (FileError e) {
				Report.error (null, e.message);
			}
		} else {
			Report.error (null, "%s not found".printf(gtkaml_source_file.filename));
		} 
	}
		
	private string call_sax_parser( CodeContext! context, SourceFile source_file )
	{
		SourceFile dummy_file = new SourceFile( context, source_file.filename );
		SAXParser parser = new SAXParser (context, dummy_file); 
		return parser.parse();
		
	}
	
	
}
