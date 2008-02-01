using GLib;
using Vala;

public abstract class Gtkaml.Attribute : GLib.Object {
	public string name {get;set;}
	public Symbol target_type {get;set;}
}
