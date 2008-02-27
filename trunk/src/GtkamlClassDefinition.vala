/* GtkamlClassDefinition.vala
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

public enum DefinitionScope {
	MAIN_CLASS = 0,
	PUBLIC,
	PRIVATE,
	CONSTRUCTOR
}

/** represents a gtkaml tag */
public class Gtkaml.ClassDefinition : GLib.Object {
	public Vala.SourceReference source_reference {get;set;}
	public string identifier {get;set;}
	public string base_full_name {
		get { 
			//BUG return (ns == null)? base_type.name : ns + "." + base_type.name;
			return (base_ns == null)? base_type.name : (base_ns + "." + base_type.name);
		} 
	}
	public string base_ns {get;set;}
	public Vala.Class base_type {get;set;}

	public Gee.List<Gtkaml.Attribute> attrs {get;set;}

	public weak ClassDefinition parent_container {get;set;}
	
	public Gee.List<ClassDefinition> children {get;set;}
	public DefinitionScope definition_scope {get;set;}
	public ConstructMethod construct_method {get;set;}
	public AddMethod add_method {get;set;}
	public string construct_code{get;set;}
	public string preconstruct_code{get;set;}

	public ClassDefinition (SourceReference! source_reference, string! identifier, string! base_ns, Vala.Class! base_type, 
		DefinitionScope! definition_scope, ClassDefinition parent_container = null)
	{
		this.source_reference = source_reference;
		this.base_ns = base_ns;
		this.identifier = identifier;
		this.base_type = base_type;
		this.definition_scope = definition_scope;
		this.parent_container = parent_container;
		this.attrs = new Gee.ArrayList<Gtkaml.Attribute> ();
		this.construct_method = null;
		this.children = new Gee.ArrayList<ClassDefinition> ();
		this.construct_code = null;
		this.preconstruct_code = null;
	}
	
	public void add_attribute (Gtkaml.Attribute attr) {
		attrs.add (attr);
	}

	public void add_child (ClassDefinition child)
	{
		children.add (child);
	}

	
}
