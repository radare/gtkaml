/* gtkamlmarkupscanner.vala
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
using Vala;
using Xml;

/** 
 * Wrapper for Xml document
 */
class Gtkaml.MarkupScanner {
	public string gtkaml_uri {get; protected set;}
	public Xml.Node* node;
	public SourceFile source_file {get; protected set;}
	Doc* whole_doc;

	public MarkupScanner (SourceFile source_file) throws ParseError {
		this.source_file = source_file;
		
		this.whole_doc = Xml.Parser.read_file (source_file.filename, null, ParserOption.NOWARNING);
		if (whole_doc == null) 
			throw new ParseError.SYNTAX("Error parsing %s".printf (source_file.filename));
		
		node = whole_doc->get_root_element ();
		
		parse_gtkaml_uri ();
	}
	
	public MarkupScanner.from_string (string source, SourceFile original_file) throws ParseError {
		this.source_file = original_file;
		
		this.whole_doc = Xml.Parser.read_doc (source, null, null, ParserOption.NOWARNING);
		if (whole_doc == null)
			throw new ParseError.SYNTAX("Error parsing %s".printf (source_file.filename));
			
		node = whole_doc->get_root_element ();
		
		parse_gtkaml_uri ();
	}

	~MarkupScanner () {
		if (whole_doc != null)
			delete whole_doc;
	}
	
	public SourceReference get_src () {
		SourceLocation begin, end;
		begin = end = SourceLocation (null, (int)node->get_line_no (), 0);
		return new SourceReference (source_file, begin, end);
	}


	void parse_gtkaml_uri () throws ParseError {
		for (Ns* ns = this.node->ns_def; ns != null; ns = ns->next) {
			if (ns->href.has_prefix ("http://gtkaml.org")) {
				this.gtkaml_uri = ns->href;
				return;
			}
		}
		throw new ParseError.SYNTAX ("No gtkaml prefix found.");
	}


}
