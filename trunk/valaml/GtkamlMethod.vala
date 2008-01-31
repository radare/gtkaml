using GLib;
using Vala;

public class Gtkaml.Method : GLib.Object {
	public string name {get;set;}
	public Gee.List<Attribute> parameter_attributes{get;set;}
	public Method()
	{
		parameter_attributes = new Gee.ArrayList<Attribute> ();
	}
}

public class Gtkaml.AddMethod : Gtkaml.Method {
}

public class Gtkaml.ConstructMethod : Gtkaml.Method 
{
}
