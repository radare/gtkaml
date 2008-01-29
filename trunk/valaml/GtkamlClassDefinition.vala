using GLib;
using Vala;

public enum DefinitionScope {
	SCOPE_CLASS_PUBLIC = 0,
	SCOPE_CLASS_PRIVATE,
	SCOPE_CONSTRUCTOR
}

public class Gtkaml.ClassDefinition : GLib.Object {
	
	public string name {get;set;}
	public Vala.DataType data_type {get;set;}

	private Gee.List<Gtkaml.Attribute> attrs {get;set;}

	public weak ContainerDefinition parent_container {get;set;}
	public DefinitionScope enclosing_scope {get;set;}

	public ConstructMethod construct_method {get;set;}

	public ClassDefinition( string! name, Vala.DataType! data_type, 
		DefinitionScope! enclosing_scope, ContainerDefinition parent_container = null)
	{
		this.name = name;
		this.data_type = data_type;
		this.enclosing_scope = enclosing_scope;
		this.parent_container = parent_container;
		this.attrs = new Gee.ArrayList<Gtkaml.Attribute> ();
		this.construct_method = null;
	}
	
	public void add_attribute (Gtkaml.Attribute attr) {
		attrs.add (attr);
	}

	public void determine_construct_method (ref Gee.List<Gtkaml.Attribute>attrs)
	{
		return;
	}
	
	
}
