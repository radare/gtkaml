/* GtkamlState.vala
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

public enum Gtkaml.StateId {
	SAX_PARSER_INITIAL_STATE = 0, /* here we generate the class declaration, based on current tag, attributes and namespaces */
	SAX_PARSER_CONTAINER_STATE,   /* then we can add things to the current container, based on current tag and attributes */
	SAX_PARSER_ATTRIBUTE_STATE,   /* the characters are then used as value, string literal - we need the current instance.property */
}

public class Gtkaml.State : GLib.Object {
	public StateId state_id {get;set;}
	public Gtkaml.ClassDefinition class_definition {get;set;}
	public Gtkaml.Attribute attribute {get;set;}
	public string attribute_name{get;set;}
	
	public State (StateId state_id, Gtkaml.ClassDefinition? class_definition,
		Gtkaml.Attribute? attribute = null, string? attribute_name = null)
	{
		this.state_id = state_id;
		this.class_definition = class_definition;
		this.attribute = attribute;
		this.attribute_name = attribute_name;
	}
}
