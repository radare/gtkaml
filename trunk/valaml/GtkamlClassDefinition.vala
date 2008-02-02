using GLib;
using Vala;

public enum DefinitionScope {
	MAIN_CLASS = 0,
	PUBLIC,
	PRIVATE,
	CONSTRUCTOR
}

/** represents a gtkaml tag */
public class Gtkaml.ClassDefinition : GLib.Object {
	public Vala.SourceReference source_reference {get;set;}
	public string identifier {get;set;}
	public string base_full_name {
		get { 
			//BUG return (ns == null)? base_type.name : ns + "." + base_type.name;
			return (base_ns == null)? base_type.name : (base_ns + "." + base_type.name);
		} 
	}
	public string base_ns {get;set;}
	public Vala.Class base_type {get;set;}

	public Gee.List<Gtkaml.Attribute> attrs {get;set;}

	private weak ClassDefinition _parent_container;
	public weak ClassDefinition parent_container {
		get { 
			return _parent_container;
		}
		set {
			//hmm reparent?
			if (value != null)
				value.add_child (this);
			_parent_container = value;
		}
	}
	
	public Gee.List<ClassDefinition> children {get;set;}
	public DefinitionScope definition_scope {get;set;}
	public ConstructMethod construct_method {get;set;}
	public AddMethod add_method {get;set;}

	public ClassDefinition (SourceReference source_reference, string! identifier, string base_ns, Vala.Class! base_type, 
		DefinitionScope! definition_scope, ClassDefinition parent_container = null)
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
	
	public void add_attribute (Gtkaml.Attribute attr) {
		attrs.add (attr);
	}

	public void add_child (ClassDefinition child)
	{
		children.add (child);
	}

	
}
