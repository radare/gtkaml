using GLib;
using Vala;

public class Gtkaml.SimpleAttribute : Gtkaml.Attribute {

	public string value {get;set;}

	public SimpleAttribute (string! name, string! value)
	{
		this.name = name;
		this.value = value;
	}	
	
}
