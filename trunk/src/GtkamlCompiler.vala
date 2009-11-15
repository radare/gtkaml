/* valacompiler.vala
 * 
 * Copyright (C) 2006-2009  Jürg Billeter
 * Copyright (C) 1996-2002, 2004, 2005, 2006 Free Software Foundation, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 * Adapted for Gtkaml:
 *	Vlad Grecescu <b100dian@gmail.com>
 */

using GLib;
using Vala;

class Gtkaml.Compiler {
	static string basedir;
	static string directory;
	static bool version;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] sources;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] vapi_directories;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] gir_directories;
	static string vapi_filename;
	static string library;
	static string gir;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] packages;
	static string target_glib;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] implicits_directories; 

	static bool ccode_only;
	static string header_filename;
	static bool use_header;
	static string internal_header_filename;
	static string internal_vapi_filename;
	static string includedir;
	static bool compile_only;
	static string output;
	static bool debug;
	static bool thread;
	static bool disable_assert;
	static bool enable_checking;
	static bool deprecated;
	static bool experimental;
	static bool experimental_non_null;
	static bool disable_dbus_transformation;
	static bool disable_warnings;
	static string cc_command;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] cc_options;
	static string dump_tree;
	static bool save_temps;
	[CCode (array_length = false, array_null_terminated = true)]
	[NoArrayLength]
	static string[] defines;
	static bool quiet_mode;
	static bool verbose_mode;
	static string profile;
	static string entry_point;
	private Gtkaml.CodeContext context;

	const OptionEntry[] options = {
		{ "girdir", 0, 0, OptionArg.FILENAME_ARRAY, ref gir_directories, "Look for .gir files in DIRECTORY", "DIRECTORY..." },
		{ "vapidir", 0, 0, OptionArg.FILENAME_ARRAY, ref vapi_directories, "Look for package bindings in DIRECTORY", "DIRECTORY..." },
		{ "pkg", 0, 0, OptionArg.STRING_ARRAY, ref packages, "Include binding for PACKAGE", "PACKAGE..." },
		{ "vapi", 0, 0, OptionArg.FILENAME, ref vapi_filename, "Output VAPI file name", "FILE" },
		{ "library", 0, 0, OptionArg.STRING, ref library, "Library name", "NAME" },
		{ "gir", 0, 0, OptionArg.STRING, ref gir, "GObject-Introspection repository file name", "NAME-VERSION.gir" },
		{ "basedir", 'b', 0, OptionArg.FILENAME, ref basedir, "Base source directory", "DIRECTORY" },
		{ "directory", 'd', 0, OptionArg.FILENAME, ref directory, "Output directory", "DIRECTORY" },
		{ "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },
		{ "ccode", 'C', 0, OptionArg.NONE, ref ccode_only, "Output C code", null },
		{ "header", 'H', 0, OptionArg.FILENAME, ref header_filename, "Output C header file", "FILE" },
		{ "use-header", 0, 0, OptionArg.NONE, ref use_header, "Use C header file", null },
		{ "includedir", 0, 0, OptionArg.FILENAME, ref includedir, "Directory used to include the C header file", "DIRECTORY" },
		{ "internal-header", 'h', 0, OptionArg.FILENAME, ref internal_header_filename, "Output internal C header file", "FILE" },
		{ "internal-vapi", 0, 0, OptionArg.FILENAME, ref internal_vapi_filename, "Output vapi with internal api", "FILE" },
		{ "compile", 'c', 0, OptionArg.NONE, ref compile_only, "Compile but do not link", null },
		{ "output", 'o', 0, OptionArg.FILENAME, ref output, "Place output in file FILE", "FILE" },
		{ "debug", 'g', 0, OptionArg.NONE, ref debug, "Produce debug information", null },
		{ "thread", 0, 0, OptionArg.NONE, ref thread, "Enable multithreading support", null },
		{ "define", 'D', 0, OptionArg.STRING_ARRAY, ref defines, "Define SYMBOL", "SYMBOL..." },
		{ "main", 0, 0, OptionArg.STRING, ref entry_point, "Use SYMBOL as entry point", "SYMBOL..." },
		{ "disable-assert", 0, 0, OptionArg.NONE, ref disable_assert, "Disable assertions", null },
		{ "enable-checking", 0, 0, OptionArg.NONE, ref enable_checking, "Enable additional run-time checks", null },
		{ "enable-deprecated", 0, 0, OptionArg.NONE, ref deprecated, "Enable deprecated features", null },
		{ "enable-experimental", 0, 0, OptionArg.NONE, ref experimental, "Enable experimental features", null },
		{ "disable-warnings", 0, 0, OptionArg.NONE, ref disable_warnings, "Disable warnings", null },
		{ "enable-experimental-non-null", 0, 0, OptionArg.NONE, ref experimental_non_null, "Enable experimental enhancements for non-null types", null },
		{ "disable-dbus-transformation", 0, 0, OptionArg.NONE, ref disable_dbus_transformation, "Disable transformation of D-Bus member names", null },
		{ "cc", 0, 0, OptionArg.STRING, ref cc_command, "Use COMMAND as C compiler command", "COMMAND" },
		{ "Xcc", 'X', 0, OptionArg.STRING_ARRAY, ref cc_options, "Pass OPTION to the C compiler", "OPTION..." },
		{ "dump-tree", 0, 0, OptionArg.FILENAME, ref dump_tree, "Write code tree to FILE", "FILE" },
		{ "save-temps", 0, 0, OptionArg.NONE, ref save_temps, "Keep temporary files", null },
		{ "implicitsdir", 0, 0, OptionArg.FILENAME_ARRAY, ref implicits_directories, "Look for implicit add and creation methods and their parameters in DIRECTORY", "DIRECTORY..." },
		{ "profile", 0, 0, OptionArg.STRING, ref profile, "Use the given profile instead of the default", "PROFILE" },
		{ "quiet", 'q', 0, OptionArg.NONE, ref quiet_mode, "Do not print messages to the console", null },
		{ "verbose", 'v', 0, OptionArg.NONE, ref verbose_mode, "Print additional messages to the console", null },
		{ "target-glib", 0, 0, OptionArg.STRING, ref target_glib, "Target version of glib for code generation", "MAJOR.MINOR" },
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref sources, null, "FILE..." },
		{ null }
	};
	
	private int quit () {
		context.remove_generated_files ();

		if (context.report.get_errors () == 0 && context.report.get_warnings () == 0)
			return 0;

		if (context.report.get_errors () == 0) {
			if (!quiet_mode)
				stdout.printf ("Compilation succeeded - %d warning(s)\n",
					context.report.get_warnings ());
		} else {
			if (!quiet_mode)
				print ("Compilation failed: %d error(s), %d warning(s)\n",
					context.report.get_errors (), context.report.get_warnings ());
			return 1;
		}
		return 0;
	}

	private bool add_gir (CodeContext context, string gir) {
		var gir_path = context.get_gir_path (gir, gir_directories);

		if (gir_path == null)
			return false;

		context.add_source_file (new SourceFile (context, gir_path, true));

		return true;
	}
	
	private bool add_package (CodeContext context, string pkg) {
		// Ignore multiple occurences of the same package
		if (context.has_package (pkg))
			return true;

		var package_path = context.get_package_path (pkg, vapi_directories);

		if (package_path == null)
			return false;

		context.add_package (pkg);
		context.add_source_file (new SourceFile (context, package_path, true));
		
		var deps_filename = Path.build_filename (Path.get_dirname (package_path), "%s.deps".printf (pkg));
		if (FileUtils.test (deps_filename, FileTest.EXISTS)) {
			try {
				string deps_content;
				ulong deps_len;
				FileUtils.get_contents (deps_filename, out deps_content, out deps_len);
				foreach (string dep in deps_content.split ("\n")) {
					dep = dep.strip ();
					if (dep != "" && !add_package (context, dep))
						Report.error (null, "%s, dependency of %s, not found in specified Vala API directories".printf (dep, pkg));
				}
			} catch (FileError e) {
				Report.error (null, "Unable to read dependency file: %s".printf (e.message));
			}
		}
		return true;
	}

	private int run () {
		context = new Gtkaml.CodeContext ();
		Vala.CodeContext.push (context);

		// default to build executable
		if (!ccode_only && !compile_only && output == null) {
			// strip extension if there is one
			// else we use the default output file of the C compiler
			if (sources[0].rchr (-1, '.') != null) {
				long dot = sources[0].pointer_to_offset (sources[0].rchr (-1, '.'));
				output = Path.get_basename (sources[0].substring (0, dot));
			}
		}

		context.assert = !disable_assert;
		context.checking = enable_checking;
		context.deprecated = deprecated;
		context.experimental = experimental;
		context.experimental_non_null = experimental || experimental_non_null;
		context.dbus_transformation = !disable_dbus_transformation;
		context.report.enable_warnings = !disable_warnings;
		context.report.set_verbose_errors (!quiet_mode);
		context.verbose_mode = verbose_mode;
		context.ccode_only = ccode_only;
		context.compile_only = compile_only;
		context.header_filename = header_filename;
		context.use_header = use_header;
		context.internal_header_filename = internal_header_filename;
		context.includedir = includedir;
		context.output = output;

		if (basedir == null)
			context.basedir = realpath (".");
		else context.basedir = realpath (basedir);

		if (directory != null)
			context.directory = realpath (directory);
		else context.directory = context.basedir;

		context.debug = debug;
		context.thread = thread;
		context.save_temps = save_temps;
		if (profile == "posix") {
			context.profile = Profile.POSIX;
			context.add_define ("POSIX");
		} else if (profile == "gobject-2.0" || profile == "gobject" || profile == null) {
			// default profile
			context.profile = Profile.GOBJECT;
			context.add_define ("GOBJECT");
			context.add_define ("VALA_0_7_6_NEW_METHODS");
		} else {
			Report.error (null, "Unknown profile %s".printf (profile));
		}

		context.entry_point_name = entry_point;

		if (defines != null) {
			foreach (string define in defines) {
				context.add_define (define);
			}
		}

		if (context.profile == Profile.POSIX) {
			/* default package */
			if (!add_package (context, "posix"))
				Report.error (null, "posix not found in specified Vala API directories");
		} else if (context.profile == Profile.GOBJECT) {
			int glib_major = 2;
			int glib_minor = 12;
			if (target_glib != null && target_glib.scanf ("%d.%d", out glib_major, out glib_minor) != 2) {
				Report.error (null, "Invalid format for --target-glib");
			}

			context.target_glib_major = glib_major;
			context.target_glib_minor = glib_minor;
			if (context.target_glib_major != 2) {
				Report.error (null, "This version of valac only supports GLib 2");
			}

			/* default packages */
			if (!add_package (context, "glib-2.0"))
				Report.error (null, "glib-2.0 not found in specified Vala API directories");
			if (!add_package (context, "gobject-2.0"))
				Report.error (null, "gobject-2.0 not found in specified Vala API directories");
		}

		context.codegen = new CCodeGenerator ();

		if (packages != null) {
			foreach (string package in packages) {
				if (!add_package (context, package) && !add_gir (context, package))
					Report.error (null, "%s not found in specified Vala API directories or GObject-Introspection GIR directories".printf (package));
			}
			packages = null;
		}
		
		if (context.report.get_errors () > 0)
			return quit ();

		foreach (string source in sources) {
			if (FileUtils.test (source, FileTest.EXISTS)) {
				var rpath = realpath (source);
				if (source.has_suffix (".vala") || source.has_suffix (".gs")) {
					var source_file = new SourceFile (context, rpath);

					if (context.profile == Profile.POSIX) {
						// import the Posix namespace by default (namespace of backend-specific standard library)
						var ns_ref = new UsingDirective (new UnresolvedSymbol (null, "Posix", null));
						source_file.add_using_directive (ns_ref);
						context.root.add_using_directive (ns_ref);
					} else if (context.profile == Profile.GOBJECT) {
						// import the GLib namespace by default (namespace of backend-specific standard library)
						var ns_ref = new UsingDirective (new UnresolvedSymbol (null, "GLib", null));
						source_file.add_using_directive (ns_ref);
						context.root.add_using_directive (ns_ref);
					}

					context.add_source_file (source_file);
				} else if (source.has_suffix (".vapi") || source.has_suffix (".gir")) {
					context.add_source_file (new SourceFile (context, rpath, true));
                                } else if (source.has_suffix (".gtkaml")) {
                                        context.add_source_file (new SourceFile (context, rpath));
				} else if (source.has_suffix (".c")) {
					context.add_c_source_file (rpath);
				} else {
					Report.error (null, "%s is not a supported source file type. Only .vala, .vapi, .gs, and .c files are supported.".printf (source));
				}
			} else {
				Report.error (null, "%s not found".printf (source));
			}
		}
		sources = null;
		
		if (context.report.get_errors () > 0)
			return quit ();

		var parser = new Gtkaml.Parser ();
		parser.parse (context, implicits_directories);

		var genie_parser = new Genie.Parser ();
		genie_parser.parse (context);

		var gir_parser = new GirParser ();
		gir_parser.parse (context);

		if (gir_parser.get_package_names != null) {
			foreach (var pkg in gir_parser.get_package_names ()) {
				context.add_package (pkg);
			}
		}

		if (context.report.get_errors () > 0)
			return quit ();

		var resolver = new SymbolResolver ();
		resolver.resolve (context);

		if (context.report.get_errors () > 0)
			return quit ();

		var analyzer = new SemanticAnalyzer ();
		analyzer.analyze (context);

		if (!ccode_only && !compile_only && library == null) {
			// building program, require entry point
			if (context.entry_point == null) {
				Report.error (null, "program does not contain a static `main' method");
			}
		}

		if (dump_tree != null) {
			var code_writer = new CodeWriter (true);
			code_writer.write_file (context, dump_tree);
		}

		if (context.report.get_errors () > 0)
			return quit ();

		var flow_analyzer = new FlowAnalyzer ();
		flow_analyzer.analyze (context);

		if (context.report.get_errors () > 0)
			return quit ();

		context.codegen.emit (context);
		
		if (context.report.get_errors () > 0)
			return quit ();

		if (vapi_filename == null && library != null) {
			// keep backward compatibility with --library option
			vapi_filename = "%s.vapi".printf (library);
		}

		if (vapi_filename != null) {
			var interface_writer = new CodeWriter ();
			// put .vapi file in current directory unless -d has been explicitly specified
			if (directory != null && !Path.is_absolute (vapi_filename))
				vapi_filename = "%s%c%s".printf (context.directory, Path.DIR_SEPARATOR, vapi_filename);
			interface_writer.write_file (context, vapi_filename);
		}

		if (library != null) {
			if (gir != null) {
				if (context.profile == Profile.GOBJECT) {
					long gir_len = gir.len ();
					unowned string? last_hyphen = gir.rchr (gir_len, '-');

					if (last_hyphen == null || !gir.has_suffix (".gir")) {
						Report.error (null, "GIR file name `%s' is not well-formed, expected NAME-VERSION.gir".printf (gir));
					} else {
						long offset = gir.pointer_to_offset (last_hyphen);
						string gir_namespace = gir.substring (0, offset);
						string gir_version = gir.substring (offset + 1, gir_len - offset - 5);
						gir_version.canon ("0123456789.", '?');
						if (gir_namespace == "" || gir_version == "" || !gir_version[0].isdigit () || gir_version.contains ("?")) {
							Report.error (null, "GIR file name `%s' is not well-formed, expected NAME-VERSION.gir".printf (gir));
						} else {
							var gir_writer = new GIRWriter ();

							// put .gir file in current directory unless -d has been explicitly specified
							string gir_directory = ".";
							if (directory != null)
								gir_directory = context.directory;

							gir_writer.write_file (context, gir_directory, gir_namespace, gir_version, library);
						}
					}
				}
				gir = null;
			}
			library = null;
		}
		if (internal_vapi_filename != null) {
			if (internal_header_filename == null ||
			    header_filename == null) {
				Report.error (null, "--internal-vapi may only be used in combination with --header and --internal-header");
				return quit();
			}

			var interface_writer = new CodeWriter (false, true);
			interface_writer.set_cheader_override(header_filename, internal_header_filename);
			string vapi_filename = internal_vapi_filename;

			// put .vapi file in current directory unless -d has been explicitly specified
			if (directory != null && !Path.is_absolute (vapi_filename))
				vapi_filename = "%s%c%s".printf (context.directory, Path.DIR_SEPARATOR, vapi_filename);

			interface_writer.write_file (context, vapi_filename);

			internal_vapi_filename = null;
		}

		if (!ccode_only) {
			var ccompiler = new CCodeCompiler ();
			if (cc_command == null && Environment.get_variable ("CC") != null)
				cc_command = Environment.get_variable ("CC");
			if (cc_options == null)
				ccompiler.compile (context, cc_command, new string[] { });
			else ccompiler.compile (context, cc_command, cc_options);
		}

		return quit ();
	}

	private static bool ends_with_dir_separator (string s) {
		return Path.is_dir_separator (s.offset (s.len () - 1).get_char ());
	}

	/* ported from glibc */
	private static string realpath (string name) {
		string rpath;

		// start of path component
		weak string start;
		// end of path component
		weak string end;

		if (!Path.is_absolute (name)) {
			// relative path
			rpath = Environment.get_current_dir ();

			start = end = name;
		} else {
			// set start after root
			start = end = Path.skip_root (name);

			// extract root
			rpath = name.substring (0, name.pointer_to_offset (start));
		}

		long root_len = rpath.pointer_to_offset (Path.skip_root (rpath));

		for (; start.get_char () != 0; start = end) {
			// skip sequence of multiple path-separators
			while (Path.is_dir_separator (start.get_char ())) {
				start = start.next_char ();
			}

			// find end of path component
			long len = 0;
			for (end = start; end.get_char () != 0 && !Path.is_dir_separator (end.get_char ()); end = end.next_char ()) {
				len++;
			}

			if (len == 0)
				break;

			if (len == 1 && start.get_char () == '.') {
				// do nothing
			} else if (len == 2 && start.has_prefix ("..")) {
				// back up to previous component, ignore if at root already
				if (rpath.len () > root_len) {
					do {
						rpath = rpath.substring (0, rpath.len () - 1);
					} while (!ends_with_dir_separator (rpath));
				}
			} else {
				if (!ends_with_dir_separator (rpath)) {
					rpath += Path.DIR_SEPARATOR_S;
				}

				rpath += start.substring (0, len);
			}
		}

		if (rpath.len () > root_len && ends_with_dir_separator (rpath))
			rpath = rpath.substring (0, rpath.len () - 1);

		if (Path.DIR_SEPARATOR != '/') {
			// don't use backslashes internally,
			// to avoid problems in #include directives
			string[] components = rpath.split ("\\");
			rpath = string.joinv ("/", components);
		}

		return rpath;
	}

	static int main (string[] args) {
		try {
			var opt_context = new OptionContext ("- Vala Gtkaml Compiler");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse (ref args);
		} catch (OptionError e) {
			stdout.printf ("%s\n", e.message);
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return 1;
		}
		
		if (version) {
			stdout.printf ("Gtkaml %s (based on Vala 0.7.8)\n", Config.PACKAGE_VERSION);
			return 0;
		}
		
		if (sources == null) {
			stderr.printf ("No source file specified.\n");
			return 1;
		}
		
		var compiler = new Compiler ();
		return compiler.run ();
	}
}
