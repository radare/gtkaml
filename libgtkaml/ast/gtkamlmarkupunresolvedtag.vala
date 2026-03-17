/* gtkamlmarkupunresolvedtag.vala
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
 * Any markup tag encountered in XML that is not the root, nor has g:public/g:private identifier.
 * Can later morph into a complex attribute or into a temp
 */
public class Gtkaml.Ast.MarkupUnresolvedTag : MarkupChildTag {

	public override string me { get { assert_not_reached(); } }
	
	public MarkupUnresolvedTag (MarkupTag parent_tag, string tag_name, MarkupNamespace tag_namespace, SourceReference? source_reference = null)
	{
		base (parent_tag, tag_name, tag_namespace, source_reference);
	}	
	
	public override void generate_public_ast (CodeParserProvider parser) {
		//No public AST for unkown stuff
	}
	
	public override MarkupTag? resolve (MarkupResolver resolver) {
		//try to silently resolve as a type
		resolve_silently (resolver);

		if (!tag_namespace.explicit_prefix && markup_attributes.size == 0)  { //candidate for attribute
			if (resolved_type.type_symbol == null) {
				//resolve failed => is an attribute
				switch (child_tags.size) {
					case 0:
						parent_tag.add_markup_attribute (new MarkupAttribute (tag_name, text, source_reference));
						return null;
					case 1:
						var complex_attribute = mutate_into_complex_attribute (child_tags[0], resolver);
						parent_tag.add_markup_attribute (complex_attribute);
						return null;
					default:
						Report.error (source_reference, "Don't know how to handle `%s's children".printf (tag_name));
						return null;
				}
			}
		}
		var markup_temp = new MarkupTemp (parent_tag, tag_name, tag_namespace, source_reference);
		markup_temp.resolve (resolver);
		parent_tag.replace_child_tag (this, markup_temp);
		return markup_temp;
	}
	
	public override void generate (MarkupResolver resolver) {
		assert_not_reached ();//unresolved tags are replaced with temporary variables or complex attributes at resolve () time
	}
	
	private MarkupComplexAttribute mutate_into_complex_attribute (MarkupChildTag child_tag, MarkupResolver resolver)
	{
		var resolved_child = child_tag.resolve (resolver) as MarkupChildTag;

		resolved_child.standalone = true;
		resolved_child.resolve_attributes (resolver);
		
		return new MarkupComplexAttribute (tag_name, parent_tag, resolved_child, source_reference);
	}		
	
	private void resolve_silently (MarkupResolver resolver) {
		if (! (data_type is UnresolvedType))
			return;

		//this prevents reporting another error
		((UnresolvedType)data_type).unresolved_symbol.error = true;

		data_type.accept (resolver);

		((UnresolvedType)data_type).unresolved_symbol.error = false;
	}
}
