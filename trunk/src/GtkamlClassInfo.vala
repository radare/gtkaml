using GLib;

namespace Gtkaml {

	public class ClassInfo : GLib.Object  {
		public string name {get; set;}
		public Gee.Map<string,string> properties;
		public Gee.List<string> constructor_parameters;
		public Gee.List<string> signals;

	}
}
