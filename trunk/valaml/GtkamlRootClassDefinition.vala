using GLib;
using Vala;

public class Gtkaml.RootClassDefinition : ClassDefinition {
	public Gee.Map<string,string> prefixes_namespaces {set;get;}
	
	public RootClassDefinition (SourceReference source_reference, string! name, string ns, Vala.Class! base_type, 
		DefinitionScope! enclosing_scope, ClassDefinition parent_container = null)
	{
		ClassDefinition (source_reference, name, ns, base_type, enclosing_scope, parent_container);
		prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
	}
	
	public void add_using (string prefix, string! ns)
	{
		prefixes_namespaces.set ((prefix==null)?"":prefix, ns);
	}
	 
}
