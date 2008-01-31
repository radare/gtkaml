using GLib;
using Vala;

public enum DefinitionScope {
	MAIN_CLASS = 0,
	PUBLIC,
	PRIVATE,
	CONSTRUCTOR
}

public class Gtkaml.ClassDefinition : GLib.Object {
	public Vala.SourceReference source_reference {get;set;}
	public string name {get;set;}
	public string full_name {
		get { 
			//BUG return (ns == null)? base_type.name : ns + "." + base_type.name;
			return (ns == null)? base_type.name : (ns + "." + base_type.name);
		} 
	}
	public string ns {get;set;}
	public Vala.Class base_type {get;set;}

	public Gee.List<Gtkaml.Attribute> attrs {get;set;}

	private weak ClassDefinition _parent_container;
	public weak ClassDefinition parent_container {
		get { 
			return _parent_container;
		}
		set {
			if (value != null)
				value.add_child (this);
			_parent_container = value;
		}
	}
	
	public Gee.List<ClassDefinition> container_children {get;set;}
	public DefinitionScope enclosing_scope {get;set;}
	public ConstructMethod construct_method {get;set;}

	public ClassDefinition (SourceReference source_reference, string! name, string ns, Vala.Class! base_type, 
		DefinitionScope! enclosing_scope, ClassDefinition parent_container = null)
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
	}
	
	public void add_attribute (Gtkaml.Attribute attr) {
		attrs.add (attr);
	}

	public void add_child (ClassDefinition child)
	{
		container_children.add (child);
	}

	
}
