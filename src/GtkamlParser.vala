/* GtkamlParser.vala
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


public class Gtkaml.Parser : Gtkaml.Dummy {


	private CodeContext context;
	private SourceFile current_source_file;
	
	public void parse( CodeContext! context )
	{
		this.context = context;
		base.parse( context );
	}
	
	public override void visit_source_file (SourceFile! source_file) {
		if (source_file.filename.has_suffix (".vala") || source_file.filename.has_suffix (".vapi")) {
			base.visit_source_file (source_file);
		} else if (source_file.filename.has_suffix (".gtkaml")) {
			parse_gtkaml_file (source_file);
			/* resume_parsing () test
			 * does not work because we would have to be called from parser.y _before_ $end is encountered
			 * /
			SourceFile fragment1 = new SourceFile (context, "examples/fragment1.vala");
			string fragment2;
			ulong length;
			FileUtils.get_contents ("examples/fragment2.vala", out fragment2, out length);
			base.visit_source_file (fragment1);
			resume_parsing (fragment2, length);
			*/
		}
	}
	
	public virtual void parse_gtkaml_file (SourceFile! gtkaml_source_file) {
		if (FileUtils.test (gtkaml_source_file.filename, FileTest.EXISTS)) {
			try {
				string vala_contents = call_sax_parser( this.context, gtkaml_source_file );				
				if (vala_contents != null) { 
					string vala_filename = gtkaml_source_file.filename.ndup (gtkaml_source_file.filename.len () - ".gtkaml".len ()) + ".vala";
					FileUtils.set_contents (vala_filename, vala_contents);
					gtkaml_source_file.filename = vala_filename;
					base.visit_source_file (gtkaml_source_file);
				} 
			} catch (FileError e) {
				Report.error (null, e.message);
			}
		} else {
			Report.error (null, "%s not found".printf(gtkaml_source_file.filename));
		} 
	}
		
	private string call_sax_parser( CodeContext! context, SourceFile source_file )
	{
		SourceFile dummy_file = new SourceFile( context, source_file.filename );
		SAXParser parser = new SAXParser (context, dummy_file); 
		return parser.parse();
		
	}
	
	[Import]
	public void resume_parsing (string buffer, ulong length);
}
