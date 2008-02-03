/* GtkamlRootClassDefinition.vala
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

public class Gtkaml.RootClassDefinition : Gtkaml.ClassDefinition {
	public Gee.Map<string,string> prefixes_namespaces {set;get;}
	public string target_name {get;set;}
	public string target_namespace {get;set;}
	
	public RootClassDefinition (SourceReference source_reference, string! identifier, string base_ns, Vala.Class! base_type, 
		DefinitionScope! definition_scope, Gtkaml.ClassDefinition parent_container = null)
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
	}
	
	 
}

