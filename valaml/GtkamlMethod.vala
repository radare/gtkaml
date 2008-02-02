using GLib;
using Vala;

public abstract class Gtkaml.Method : GLib.Object {
	public string name {get;set;}
	public Gee.List<Gtkaml.Attribute> parameter_attributes{get;set;}
	construct
	{
		parameter_attributes = new Gee.ArrayList<Gtkaml.Attribute> ();
	}
}

public class Gtkaml.AddMethod : Gtkaml.Method 
{
}

public class Gtkaml.ConstructMethod : Gtkaml.Method 
{
}
