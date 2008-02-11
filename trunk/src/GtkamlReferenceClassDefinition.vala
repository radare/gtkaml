using GLib;
using Vala;

/** represents a tag with gtkaml:reference */
public class Gtkaml.ReferenceClassDefinition : Gtkaml.ClassDefinition 
{
	private int dummy {get;set;}
	
	public ReferenceClassDefinition (SourceReference! source_reference, string! reference, string! base_ns, Vala.Class! base_type, 
		ClassDefinition parent_container = null)
	{
		this.dummy=0;
		
		this.source_reference = source_reference;
		this.base_ns = base_ns;
		this.identifier = reference;
		this.base_type = base_type;
		this.definition_scope = 0;
		this.parent_container = parent_container;
		this.attrs = new Gee.ArrayList<Gtkaml.Attribute> ();
		this.construct_method = null;
		this.children = new Gee.ArrayList<ClassDefinition> ();
		this.construct_code = null;
		this.preconstruct_code = null;
	}
	
}
