/* gtkamlmarkupclass.vala
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

using Gtkaml.Ast;
/**
 * Represents a Class as declared by a Gtkaml root node. 
 * This is mainly used to identify that after parsing, a Gtkaml markup resolver needs to be used on this specific class
 */
public class Gtkaml.MarkupClass : Class {

	public MarkupTag markup_root {get; set;}

	public MarkupClass (string tag_name, MarkupNamespace tag_namespace, string class_name, SourceReference? source_reference = null)
	{
		base (class_name, source_reference);
		this.markup_root = new MarkupRoot (this, tag_name, tag_namespace, source_reference);
	}
	
	public override void accept_children (CodeVisitor visitor) {
		if (visitor is MarkupResolver) {
			((MarkupResolver)visitor).visit_markup_class (this);
		}
		base.accept_children (visitor);
	}	
	
}

