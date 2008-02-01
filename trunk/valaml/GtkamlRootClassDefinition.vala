using GLib;
using Vala;

public class Gtkaml.RootClassDefinition : Gtkaml.ClassDefinition {
	public Gee.Map<string,string> prefixes_namespaces {set;get;}
	
	public RootClassDefinition (SourceReference source_reference, string! identifier, string base_ns, Vala.Class! base_type, 
		DefinitionScope! definition_scope, Gtkaml.ClassDefinition parent_container = null)
	{
		this.source_reference = source_reference;
		this.base_ns = base_ns;
		this.identifier = identifier;
		this.base_type = base_type;
		this.definition_scope = definition_scope;
		this.parent_container = parent_container;
		this.attrs = new Gee.ArrayList<Gtkaml.Attribute> ();
		this.construct_method = null;
		this.children = new Gee.ArrayList<ClassDefinition> ();
	}
	
	 
}

