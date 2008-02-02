using GLib;
using Vala;

public class Gtkaml.ComplexAttribute : Gtkaml.Attribute {
	
	public weak ClassDefinition complex_type {get;set;}
	
	public ComplexAttribute (string! name, string! identifier, ClassDefinition! complex_type) {
		this.name = name;
		this.complex_type = complex_type;	
	}
	

	
}
