/* GtkamlParser.vala
 * 
 * Copyright (C) 2008-2011 Vlad Grecescu
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
 * Contributors:
 *        pancake (pancake@nopcode.org)
 */

using GLib;
using Vala;

/**
 * gtkaml entry point
 */
public class Gtkaml.Parser : Vala.Parser {
	private CodeContext context;
	
	private ImplicitsStore implicits_store = new ImplicitsStore ();
	
	public Parser () {
		base ();
	}

	public new void parse (CodeContext context, string[]? implicits_directories = null) {
		if (implicits_directories != null)
			foreach (string? implicits_dirs in implicits_directories)
				implicits_store.add_implicits_dir (implicits_dirs);
		foreach (var datadir in Environment.get_system_data_dirs ()) {
			var filename = Path.build_filename (datadir, "gtkaml", "implicits");
			if (FileUtils.test (filename, FileTest.EXISTS)) {  
				implicits_store.add_implicits_dir (filename);
			}
		}
		this.context = context;
		base.parse( context );
	}

	public override void visit_source_file (SourceFile source_file) {
		if (source_file.filename.has_suffix (".vala") || source_file.filename.has_suffix (".vapi")) {
			base.visit_source_file (source_file);
		} else if (source_file.filename.has_suffix (".gtkon")) {
			parse_gtkon_file (source_file);
		} else if (source_file.filename.has_suffix (".gtkaml")) {
			parse_gtkaml_file (source_file);
		}
	}

public bool use_genie;
	public void parse_gtkon_file (SourceFile gtkon_source_file) {
		var gtkaml_filename = gtkon_source_file.filename.replace (".gtkon", ".gtkaml");
		var gp = new GtkonParser ();
		gp.use_genie (use_genie);
		gp.parse_file (gtkon_source_file.filename);
		if (FileUtils.test (gtkaml_filename, FileTest.EXISTS))
			FileUtils.unlink (gtkaml_filename);
		gp.to_file (gtkaml_filename);
		gtkon_source_file.filename = gtkaml_filename;
		context.generated_files.add (gtkaml_filename);
		parse_gtkaml_file (gtkon_source_file);
	}

	public virtual void parse_gtkaml_file (SourceFile gtkaml_source_file) {
		if (FileUtils.test (gtkaml_source_file.filename, FileTest.EXISTS)) {
			try {
				#if VALA_0_12
				SourceFile dummy_file = new SourceFile (context, SourceFileType.FAST, gtkaml_source_file.filename );
				#else
				SourceFile dummy_file = new SourceFile (context, gtkaml_source_file.filename );
				#endif

				var sax_parser = new SAXParser (context, dummy_file); 
				RootClassDefinition root_class_definition = sax_parser.parse();

				if (root_class_definition != null) {
					var implicitsResolver = new ImplicitsResolver (context, implicits_store); 
					implicitsResolver.resolve (root_class_definition);
					
					Gtkaml.CodeGenerator code_generator = new CodeGenerator (context);	
					code_generator.generate (root_class_definition);
					
					string vala_contents =  code_generator.yield ();
					if (vala_contents != null) { 
						string vala_filename = gtkaml_source_file.filename.substring (0, 
							gtkaml_source_file.filename.length - ".gtkaml".length) + ".vala";
						FileUtils.set_contents (vala_filename, vala_contents);
						context.generated_files.add (vala_filename);
						gtkaml_source_file.filename = vala_filename;
						base.visit_source_file (gtkaml_source_file);
					}
				}
			} catch (FileError e) {
				Report.error (null, e.message);
			}
		} else Report.error (null, "%s not found".printf(gtkaml_source_file.filename));
	}
}
