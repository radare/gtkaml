using GLib;
using Vala;

public enum Gtkaml.StateId {
	SAX_PARSER_INITIAL_STATE = 0, /* here we generate the class declaration, based on current tag, attributes and namespaces */
	SAX_PARSER_CONTAINER_STATE,   /* then we can add things to the current container, based on current tag and attributes */
	SAX_PARSER_ATTRIBUTE_STATE,   /* the characters are then used as value, string literal - we need the current instance.property */
}

public class Gtkaml.State : GLib.Object
{
	public StateId state_id {get;set;}
	public string parent_name {get;set;}
	public Vala.Class parent_type {get;set;}
	public ClassDefinition class_definition {get;set;}
	public State (construct StateId state_id, construct string parent_name, construct Class parent_type, construct ClassDefinition class_definition)
	{}
}
