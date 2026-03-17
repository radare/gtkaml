/* gtkamlmarkupreference.vala
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
 * Represents a tag with g:existing and therefore no creation method
 */
public class Gtkaml.Ast.MarkupReference : MarkupChildTag {

	protected string existing_name { get; private set; }

	public MarkupReference (MarkupTag parent_tag, string tag_name, MarkupNamespace tag_namespace, string existing_name, SourceReference? source_reference = null)
	{
		base (parent_tag, tag_name, tag_namespace, source_reference);
		this.existing_name = existing_name;
	}

	public override string me { get { return existing_name; }}

	public override void generate_public_ast (CodeParserProvider parser) {
		//No public AST that ain't there already for references
	}
	
	public override MarkupTag? resolve (MarkupResolver resolver) {
		data_type.accept (resolver);
		return this;
	}

	public override void resolve_attributes (MarkupResolver resolver) {
		//removed: resolve_creation_method (resolver);
		resolve_composition_method (resolver);
	}
	
	public override void generate (MarkupResolver resolver) {
		//removed: generate construct_..() for references
	}
}
