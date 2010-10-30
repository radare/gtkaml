/* GtkamlImplicitsStore.vala
 * 
 * Copyright (C) 2008 Vlad Grecescu
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with main.c; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
 *
 * Author:
 *        Vlad Grecescu (b100dian@gmail.com)
 */

using GLib;
using Vala;

/** a method parameter as it came from an .implicits file, with its default value */
public class Gtkaml.ImplicitsParameter : Object {
	public string name;
	public string default_value;
}

/**
 * GObject-ification of KeyFile
 */
private class Gtkaml.KeyFileWrapper : Object {
	public KeyFile key_file;

	construct {
		this.key_file = new KeyFile ();
	}
	
	public bool has_key (string group, string key) {
		try {
			return key_file.has_key (group, key);
		} catch (GLib.KeyFileError e) {
			return false;
		}
	}

	public string[] get_string_list (string group, string key) {
		try {
			return key_file.get_string_list (group, key);
		} catch (Error e) {
			return new string[0];
		}
	}
}

/** 
 * collects $(ns).implicits key files and provides key information from all of them
 */
public class Gtkaml.ImplicitsStore : Object {
	private Vala.List<string> implicits_dirs = new ArrayList<string> (str_equal);
	private Vala.Map<string, Vala.List<KeyFileWrapper>> loaded_ns = new HashMap<string, Vala.List<KeyFileWrapper>> (str_hash, str_equal);
		
	public Vala.List<string> get_implicits_dirs () {
		return implicits_dirs;
	}
	
	public void add_implicits_dir (string directory) {
		implicits_dirs.add (directory);
	}
	
	private Vala.List<KeyFileWrapper> get_ns (string ns) {
		if (loaded_ns.contains (ns)) {
			return loaded_ns.get (ns);
		} else {
			var key_file_list = new Vala.ArrayList<KeyFileWrapper> ();
			foreach (string implicits_dir in this.implicits_dirs) {
				var file_name = Path.build_filename (implicits_dir, ns + ".implicits");
				if (FileUtils.test (file_name, FileTest.EXISTS)) {
					var key_file_wrapper = new KeyFileWrapper ();
					try {
						key_file_wrapper.key_file.load_from_file (file_name, KeyFileFlags.NONE);
						key_file_list.add (key_file_wrapper);
					} catch (Error e) {
						Report.warning (null, "Invalid implicits file %s".printf (file_name));
					}
				}
			}
			//even an empty list does it: so that we don't scan the directories again
			loaded_ns.set (ns, key_file_list);
			return key_file_list;
		}
	}
	
	public Vala.List<string> get_adds (string ns, string class_name) {
		Vala.List<string> adds = new Vala.ArrayList<string> ();
		var kf_ns = get_ns (ns);
		foreach (KeyFileWrapper kfw in kf_ns) {
			if (kfw.has_key (class_name, "adds")) {
				var kf_adds = kfw.get_string_list (class_name, "adds");
				foreach (string add in kf_adds) {
					//stderr.printf ("store contains %s\n", add);
					adds.add (add);
				}
			}
		}
		return adds;
	}

	public Vala.List<ImplicitsParameter> get_method_parameters (string ns, string class_name, string method_name) {
		Vala.List<ImplicitsParameter> parameters = new Vala.ArrayList<ImplicitsParameter> ();
		foreach (KeyFileWrapper kfw in get_ns (ns)) {
			if (kfw.has_key (class_name, method_name)) {
				var kf_parameters = kfw.get_string_list (class_name, method_name);
				foreach (string parameter in kf_parameters) {
					var implicits_parameter = new ImplicitsParameter ();
					var name_value = parameter.split ("=");
					implicits_parameter.name = name_value[0];
					implicits_parameter.default_value = name_value[1];//either null or not
					parameters.add (implicits_parameter);
				}
				return parameters;
			}
		}
		return /*empty*/ parameters;
	}
	
	public Vala.List<ImplicitsParameter> determine_parameter_names_and_default_values(ClassDefinition class_definition, Vala.Method method) {
		var ns = method.parent_symbol.parent_symbol.get_full_name ();
		var clazz = method.parent_symbol.name;
		//stderr.printf ("determine_parameter_names_and_default_values %s %s of %s.%s\n", class_definition.base_full_name, method.name, ns, clazz);
		var result = new Vala.ArrayList<ImplicitsParameter> ();

		string method_name = method.name;
		if (method is CreationMethod) {
			if (method.name != ".new")
				method_name = "new." + method.name;
			else method_name = "new";
		} else method_name = "add." + method.name;

		var result_array = this.get_method_parameters (ns, clazz, method_name);
		if (result_array.size != 0) {
			//stderr.printf ("found in implicits: %s|%s\n", clazz, method_name);
			foreach (ImplicitsParameter result_item in result_array) {
				if (result_item.default_value != null) {
					//stderr.printf ("default value for %s=<%s>\n", result_item.name, result_item.default_value);
				}
				result.add (result_item);
			}
		} else {
			//stderr.printf ("NOT found in implicits: %s|%s\n", clazz, method_name);
			foreach (var p in method.get_parameters ()) {
				if (!p.ellipsis) { //hack for add_with_parameters (widget, ...)
					var new_implicits_parameter = new ImplicitsParameter ();
					new_implicits_parameter.name = p.name;
					new_implicits_parameter.default_value = null; //here we can go for "zero"es and "false"s
					result.add (new_implicits_parameter);
				}
			}
		}
		return result;
	}
}
