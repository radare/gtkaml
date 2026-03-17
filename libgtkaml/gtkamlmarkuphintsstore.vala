/* gtkamlmarkuphintsstore.vala
 *
 * Copyright (C) 2011 Vlad Grecescu
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

/**
 * stores a map between *.markuphints symbols like [Gtk.Window] and their markup hints
 */
public class Gtkaml.MarkupHintsStore {
	public Vala.Map<string, MarkupHint> markup_hints;
	public CodeContext context;

	public MarkupHintsStore (CodeContext context) {
		this.context = context;
		markup_hints = new Vala.HashMap<string, MarkupHint> (str_hash, str_equal);
	}

	public void parse () {
		foreach (var pkg in context.get_packages ()) {
			var filename = context.get_markuphints_path (pkg);
			if (filename != null) {
				#if DEBUGMARKUPHINTS
				stderr.printf ("checking if '%s' file exists.. ", filename);
				#endif
				if (FileUtils.test (filename, FileTest.EXISTS))  {
					#if DEBUGMARKUPHINTS
					stderr.printf ("yes\n");
					#endif
					parse_package (filename);
				} else {
					#if DEBUGMARKUPHINTS
					stderr.printf ("no\n");
					#endif
				}
			}
		}
	}
	
	void parse_package (string package_filename) {
		KeyFile key_file = new KeyFile ();
		try {
			key_file.load_from_file (package_filename, KeyFileFlags.NONE);		
		
			foreach (var symbol_fullname in key_file.get_groups ()) {
				var hints = parse_symbol (ref key_file, symbol_fullname);
				markup_hints.set (symbol_fullname, hints);
			}
		} catch {
			context.report.warn (null, "There was an error parsing %s as markuphints file".printf (package_filename));
		}
	}
	
	MarkupHint parse_symbol (ref KeyFile key_file, string symbol_fullname) throws KeyFileError {
		#if DEBUGMARKUPHINTS
		stderr.printf ("parsing hint group '%s'\n", symbol_fullname);
		#endif
		
		var symbol_hint = new MarkupHint (symbol_fullname);

		string [] keys = key_file.get_keys (symbol_fullname); //the group comes from get_groups ()

		string hint_method_name;		
		foreach (string key in keys) {
			#if DEBUGMARKUPHINTS
			stderr.printf ("definition is '%s' and is interpreted as ", key);
			#endif
			
			if (key.has_prefix ("new")) { //creation parameters
				
				if (key.has_prefix ("new.")) 
					hint_method_name = key.substring (4);
				else
					hint_method_name = ".new";

				#if DEBUGMARKUPHINTS
				stderr.printf ("creation method '%s' with the following parameters:\n", hint_method_name);
				#endif
				
				symbol_hint.add_creation_method (hint_method_name);
				
				foreach (var parameter in key_file.get_string_list (symbol_fullname, key)) {
					string parameter_name = parameter.split ("=",2)[0];
					string parameter_value = parameter.split ("=",2)[1];
					#if DEBUGMARKUPHINTS
					stderr.printf ("\t'%s'='%s'\n", parameter_name, parameter_value);
					#endif
					symbol_hint.add_creation_method_parameter (hint_method_name, parameter_name, parameter_value);
				}
					
			} else if (key.has_prefix ("add")) { //composition method
			
				if (key == "adds") { //composition method listing
					#if DEBUGMARKUPHINTS
					stderr.printf ("composition method list contains:\n");
					#endif
					foreach (string add in key_file.get_string_list (symbol_fullname, key)) {
						#if DEBUGMARKUPHINTS
						stderr.printf ("\t'%s'\n", add);
						#endif
						symbol_hint.add_composition_method (add);
					}
				
				} else if (key[3] == '.') { //composition method parameters
					hint_method_name = key.substring (4);
					#if DEBUGMARKUPHINTS
					stderr.printf ("add method '%s' with the following parameters:\n", hint_method_name);
					#endif
					foreach (var parameter in key_file.get_string_list (symbol_fullname, key)) {
						string parameter_name = parameter.split ("=",2)[0];
						string parameter_value = parameter.split ("=",2)[1];
						#if DEBUGMARKUPHINTS
						stderr.printf ("\t'%s'='%s'\n", parameter_name, parameter_value);
						#endif
						if (!symbol_hint.add_composition_method_parameter (hint_method_name, parameter_name, parameter_value))
							context.report.warn (null, "Composition method %s not listed in [%s]'s composition methods ".printf (hint_method_name, symbol_fullname)); 
					}	
				} else {
					context.report.warn (null, "Unknown '%s' key in [%s] section".printf (key, symbol_fullname));
				}
			} else {
				context.report.warn (null, "Unknown '%s' key in [%s] section".printf (key, symbol_fullname));
			}
		}
		
		return symbol_hint;
	}
	

}
