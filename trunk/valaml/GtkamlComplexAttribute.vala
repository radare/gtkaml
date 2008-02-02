using GLib;
using Vala;

public class Gtkaml.ComplexAttribute : Gtkaml.Attribute {
	
	public ClassDefinition complex_type {get;set;}
	
	public ComplexAttribute (string! name, ClassDefinition! complex_type) {
		this.name = name;
		this.complex_type = complex_type;	
	}
	

	
}
