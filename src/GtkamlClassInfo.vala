using GLib;

namespace Gtkaml {

	public class ClassInfo {
		public string name {get; set;}
		private Gee.Map<string,string> properties;
		public Gee.List<string> constructor_parameters;
		private Gee.List<string> signals;

		construct {
			properties = new Gee.HashMap<string,string>();
			constructor_parameters = new Gee.ArrayList<string>();
		}

		public void add_property( string property_name, string property_type ) {
			properties.set( property_name, property_type );
		}
	}
}
