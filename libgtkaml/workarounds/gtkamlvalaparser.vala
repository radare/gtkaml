/* gtkamlvalaparser.vala
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
 * Vala.Parser wrapper.
 * Parses different kinds of code islands: class members, expressions as values of properties, statements as values of signals
 */
public class Gtkaml.ValaParser {
	
	protected Gtkaml.CodeContext real_context;
	protected Vala.List<SourceFile> temp_source_files = new Vala.ArrayList<SourceFile> ();
	
	public ValaParser (CodeContext real_context) {
		this.real_context = real_context;
	}

	/**
	 * parses CDATA code containing class members. <br/>
	 * TODO use Vala.Parser.parse_declarations in the future
	 */
	public Class? parse_members (MarkupClass markup_class, string members_source) {
		string class_name = markup_class.name;
		var temp_source = "public class %s { %s }".printf (class_name, members_source);
		
		var temp_ns = parse (markup_class.source_reference.file, temp_source, class_name + "-members");
		
		while (temp_ns.get_namespaces ().size > 0)
			temp_ns = temp_ns.get_namespaces ()[0];
		
		if (temp_ns is Namespace && temp_ns.get_classes ().size == 1) {
			return temp_ns.get_classes ().get (0);
		} else {
			Report.error (markup_class.source_reference, "There was an error parsing the code section: members");
			return null;
		}
	}
	
	/**
	 * parses an attribute value that is coded as an expression.<br />
	 * TODO use Vala.Parser.parse_expression in the future
	 */
	public Expression? parse_expression (MarkupClass markup_class, string target, string target_member, string expression_source) {
		string class_name = markup_class.name;
		var temp_source = "VoidFunc voidFunc = ()=> %s;".printf (expression_source);
		
		var temp_ns = parse (markup_class.source_reference.file, temp_source, class_name + "_" + target + "_" + target_member + "_expression");
		if (temp_ns is Namespace && temp_ns.get_fields ().size == 1 && temp_ns.get_fields ().get (0).initializer is LambdaExpression) {
			var temp_lambda = (LambdaExpression)temp_ns.get_fields ().get (0).initializer;
			return temp_lambda.expression_body;
		} else {
			Report.error (markup_class.source_reference, "There was an error parsing the code section: expression");
			return null;
		}
	}
	
	/**
	 * parses a signal value that is coded as an expression.<br />
	 * TODO use Vala.Parser.parse_block in the future
	 */
	public Block? parse_statements (MarkupClass markup_class, string target, string target_member, string statements_source) {
		string class_name = markup_class.name;
		var temp_source = "VoidFunc voidFunc = ()=> {%s;};".printf (statements_source);
		
		var temp_ns = parse (markup_class.source_reference.file, temp_source, class_name + "_" + target + "_" + target_member + "_expression");
		if (temp_ns is Namespace && temp_ns.get_fields ().size == 1 && temp_ns.get_fields ().get (0).initializer is LambdaExpression) {
			var temp_lambda = (LambdaExpression)temp_ns.get_fields ().get (0).initializer;
			return temp_lambda.statement_body;
		} else {
			Report.error (markup_class.source_reference, "There was an error parsing the code section: statements");
			return null;
		}
	}
	
	/**
	 * parses the getter/setter declaration
	 * TODO use Vala.Parser.parse_property_declaration in the future
	 * TODO this is not used, as we don't seem to need body on getters and setters, a simple 
	 * MarkupParser.parse_markup_subtag_propertyspec is used now
	 */
	public Property? parse_property_declaration (MarkupClass markup_class, string target, string target_member, string declaration)
	{
		string class_name = markup_class.name;
		var temp_source = "public class %s { %s { %s }}".printf (class_name, target_member, declaration);
		
		var temp_ns = parse (markup_class.source_reference.file, temp_source, class_name + "-members");
		
		while (temp_ns.get_namespaces ().size > 0)
			temp_ns = temp_ns.get_namespaces ()[0];
		
		if (temp_ns is Namespace && temp_ns.get_classes ().size == 1 && temp_ns.get_classes ().get (0).get_properties().size == 1) {
			return temp_ns.get_classes ().get (0).get_properties ().get (0);
		} else {
			Report.error (markup_class.source_reference, "There was an error parsing the code section: property declaration");
			return null;
		}
	}

	/**
	 * Makes a copy of the real context for Vala parser's use
	 * 
	 */
	protected CodeContext copy_context (Gtkaml.CodeContext source) {
		var ctx = new CodeContext ();
		foreach (string define in source.defines) {
			ctx.add_define (define);
		}
		
		return ctx;
	}

	/**
	 * parses a vala source string temporary stored in .gtkaml/what.vala
	 * returns the root namespace
	 */
	private Namespace? parse(SourceFile original_source, string source, string temp_filename) {
		var ctx = copy_context (real_context);
		var filename = real_context.directory + "/.gtkaml/" + temp_filename + ".vala";
		
		try {
			DirUtils.create_with_parents (real_context.directory + "/.gtkaml", 488 /*0750*/);
			FileUtils.set_contents (filename, source);
			var temp_source_file = new SourceFile (ctx, SourceFileType.SOURCE, filename, source);

			//TODO: use source_reference.using_directives instead of original_source's..?
			foreach (var using_directive in original_source.current_using_directives) {
				temp_source_file.add_using_directive (using_directive);
			}
			
			temp_source_files.add (temp_source_file);
			ctx.add_source_file (temp_source_file);
		
			var parser = new Vala.Parser ();
			parser.parse (ctx);
			return ctx.root;
		} catch {
			Report.error (null, "There was an error writing temporary '%s'".printf (filename));
			return null;
		}
	}

	

}
