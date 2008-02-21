using GLib;
using Gee;
using Vala;

public class Gtkaml.ImplicitsParameter : Object{
	public string name;
	public string default_value;
}

/** collects $(ns).implicits key files and provides key information from all of them*/
public class Gtkaml.ImplicitsStore : Object 
{
	private Gee.List<string> implicits_dirs = new ArrayList<string> (str_equal);
	private Map<string,Gee.List<weak KeyFile> > loaded_ns = new HashMap<string,Gee.List<weak KeyFile> > (str_hash, str_equal);
	
	construct {
		this.add_implicits_dir (Path.build_filename (Config.PACKAGE_DATADIR, "implicits"));
	}
	
	public ReadOnlyList<string> get_implicits_dirs ()
	{
		return new ReadOnlyList<string> (implicits_dirs);
	}
	
	public void add_implicits_dir (string! directory)
	{
		implicits_dirs.add (directory);
	}
	
	private Gee.List<weak KeyFile> get_ns (string! ns)
	{
		if (loaded_ns.contains (ns)) {
			return loaded_ns.get (ns);
		} else {
			var key_file_list = new Gee.ArrayList<weak KeyFile> ();
			foreach (string implicits_dir in this.implicits_dirs) {
				var file_name = Path.build_filename (implicits_dir, ns + ".implicits");
				if (FileUtils.test (file_name, FileTest.EXISTS)) {
					message ("Found %s.implicits in %s", ns, implicits_dir);
					KeyFile key_file = new KeyFile ();
					try {
						key_file.load_from_file (file_name, KeyFileFlags.NONE);
						key_file_list.add (key_file);
					} catch (Error e) {
						Report.warning (null, "Invalid implicits file %s".printf (file_name));
					}
				}
			}
			loaded_ns.set (ns, key_file_list);
			//even an empty list does it: so that we don't scan the directories again
			return key_file_list;
		}
	}
	
	public Gee.List<string> get_adds (string! ns, string! class_name)
	{
		Gee.List<string> adds = new Gee.ArrayList<string> ();
		foreach (weak KeyFile kf in get_ns (ns)) {
			if (kf.has_key (class_name, "adds")) {
				var kf_adds = kf.get_string_list (class_name, "adds");
				foreach (string add in kf_adds)
					adds.add (add);
			}
		}
		return adds;
	}

	public Gee.List<ImplicitsParameter> get_method_parameters (string! ns, string! class_name, string! method_name)
	{
		Gee.List<ImplicitsParameter> parameters = new Gee.ArrayList<ImplicitsParameter> ();
		foreach (weak KeyFile kf in get_ns (ns)) {
			if (kf.has_key (class_name, method_name)) {
				var kf_parameters = kf.get_string_list (class_name, method_name);
				foreach (string parameter in kf_parameters) {
					var implicits_parameter = new ImplicitsParameter ();
					implicits_parameter.name = parameter;
					parameters.add (implicits_parameter);
				}
				return parameters;
			}
		}
		return /*empty*/ parameters;
	}
}