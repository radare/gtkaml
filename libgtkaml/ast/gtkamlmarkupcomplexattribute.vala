/* gtkamlmarkupcomplexattribute.vala
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
 * An attribute whose value is represented as another MarkupTag
 */
public class Gtkaml.Ast.MarkupComplexAttribute : MarkupAttribute {

	public MarkupTag value_tag;

	public MarkupComplexAttribute (string attribute_name, MarkupTag parent_tag, MarkupTag value_tag, SourceReference? source_reference = null) {
		base (attribute_name, parent_tag.me, source_reference);
		this.value_tag = value_tag;
	}

	public override Expression? get_expression (MarkupResolver resolver, MarkupTag markup_tag) {
		resolve (resolver, markup_tag);
		
		if (@signal != null) {
			Report.error (source_reference, "Signals cannot be defined as complex attributes");
			return null;
		} else {
			return new MemberAccess.simple (value_tag.me, source_reference);
		}
	}
}
