using GLib;
using Vala;

public class Gtkaml.RootClassDefinition : Gtkaml.ClassDefinition {
	public Gee.Map<string,string> prefixes_namespaces {set;get;}
	
	public RootClassDefinition (SourceReference source_reference, string! name, string ns, Vala.Class! base_type, 
		DefinitionScope! enclosing_scope, Gtkaml.ClassDefinition parent_container = null)
	{
		this.source_reference = source_reference;
		this.ns = ns;
		this.name = name;
		this.base_type = base_type;
		this.enclosing_scope = enclosing_scope;
		this.parent_container = parent_container;
		this.attrs = new Gee.ArrayList<Gtkaml.Attribute> ();
		this.construct_method = null;
		this.container_children = new Gee.ArrayList<ClassDefinition> ();

		//prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
	}
	
	 
}

