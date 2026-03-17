/* gtkamlmarkuptemp.vala
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
 * Markup tag that has no g:private or g:public gtkaml attribute, therefore is local to the construct method
 */
public class Gtkaml.Ast.MarkupTemp : MarkupChildTag {
	private string temp_name;
	
	public override string me { get { return temp_name; } }
	
	public MarkupTemp (MarkupTag parent_tag, string tag_name, MarkupNamespace tag_namespace, SourceReference? source_reference = null)
	{
		base (parent_tag, tag_name, tag_namespace, source_reference);
		//FIXME: get_temp_name is weird
		temp_name = ("_" + tag_name + CodeNode.get_temp_name ()).replace (".", "_");
	}
	
	public override void generate_public_ast (CodeParserProvider parser) {
		//nothing public about local temps
	}
	
	public override void generate (MarkupResolver resolver) {
		generate_construct_local (resolver);
	}
	
	private void generate_construct_local(MarkupResolver resolver) {		
		var initializer = get_initializer (resolver);
		var local_variable = new LocalVariable (null, me,  initializer, source_reference);
		var local_declaration = new DeclarationStatement (local_variable, source_reference);
		
		markup_class.constructor.body.add_statement (local_declaration);
	}
}
