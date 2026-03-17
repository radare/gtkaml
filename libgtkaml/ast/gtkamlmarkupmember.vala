/* gtkamlmarkupmember.vala
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
 * Represents a tag with g:private or g:public which will be declared as an instance member
 */
public class Gtkaml.Ast.MarkupMember : MarkupChildTag {

	protected string member_name { get; private set; }
	protected SymbolAccessibility access {get; private set;}
	protected PropertySpec? property_spec {get; private set;}

	public MarkupMember (MarkupTag parent_tag, string tag_name, MarkupNamespace tag_namespace, string member_name, SymbolAccessibility access, PropertySpec? property_spec, SourceReference? source_reference = null)
	{
		base (parent_tag, tag_name, tag_namespace, source_reference);
		this.member_name = member_name;
		this.access = access;
		this.property_spec = property_spec;
	}

	public override string me { get { return member_name; }}

	public override void generate_public_ast (CodeParserProvider parser) {
		generate_property ();
	}
	
	public override void generate (MarkupResolver resolver) {
		generate_construct_member (resolver);
	}
	
	private void generate_property () {
		var variable_type = data_type.copy ();
		variable_type.value_owned = false;
		PropertyAccessor getter = new PropertyAccessor (true, false, false, variable_type, null, source_reference);

		if (property_spec != null && property_spec.getter_accessibility != null)
			getter.access = property_spec.getter_accessibility;
		
		variable_type = data_type.copy ();
		variable_type.value_owned = false;
		PropertyAccessor setter = new PropertyAccessor (false, true, false, variable_type, null, source_reference);

		if (property_spec != null && property_spec.setter_accessibility != null)
			setter.access = property_spec.setter_accessibility;
		
		variable_type = data_type.copy ();
		variable_type.value_owned = true;
		Property p = new Property (member_name, variable_type, getter, setter, source_reference);
		p.access = access;

		markup_class.add_property (p);
	}
	
	private void generate_construct_member (MarkupResolver resolver) {
		var initializer = get_initializer (resolver);
		var assignment = new Assignment (new MemberAccess.simple (me, source_reference), initializer, AssignmentOperator.SIMPLE, source_reference);
		
		markup_class.constructor.body.add_statement (new ExpressionStatement (assignment, source_reference));
	}
}
