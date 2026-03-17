/* gtkamlmarkupattribute.vala
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
 * Represents an attribute of a MarkupTag
 */
public class Gtkaml.Ast.MarkupAttribute {
	public DataType target_type { get; set; }
	public string attribute_name {get { return _attribute_name; }}
	public string? attribute_value {get; private set;}
	

	protected SourceReference? source_reference;
	protected string _attribute_name;
	protected Vala.Signal? @signal = null;

	public MarkupAttribute (string attribute_name, string? attribute_value, SourceReference? source_reference = null) {
		this._attribute_name = attribute_name;
		this.attribute_value = attribute_value;
		this.source_reference = source_reference;
	}

	public MarkupAttribute.with_type (string attribute_name, string? attribute_value, DataType target_type, SourceReference? source_reference = null) {
		this._attribute_name = attribute_name;
		this.attribute_value = attribute_value;
		this.target_type = target_type;
		this.source_reference = source_reference;
	}
	
	public virtual Expression? get_expression (MarkupResolver resolver, MarkupTag markup_tag) {
		resolve (resolver, markup_tag);
		
		string stripped_value = attribute_value.strip ();
		if (stripped_value.has_prefix ("{")) {
			if (stripped_value.has_suffix ("}")) {
				string code_source = stripped_value.substring (1, stripped_value.length - 2);
				if (@signal != null) {
					var stmts = resolver.code_parser.parse_statements (markup_tag.markup_class, markup_tag.me, attribute_name, code_source);
					var lambda = new LambdaExpression.with_statement_body(stmts, source_reference);

					lambda.add_parameter (new Vala.Parameter ("target", markup_tag.data_type, markup_tag.source_reference));
					foreach (var parameter in @signal.get_parameters ()) {
						lambda.add_parameter (parameter);
					}
		
					return lambda;
				} else {
					return resolver.code_parser.parse_expression (markup_tag.markup_class, markup_tag.me, attribute_name, code_source);
				}
			} else {
				Report.error (source_reference, "Unmatched closing brace in %'s value.".printf (attribute_name));
			}
		} else {
			if (@signal != null) {
				return resolver.code_parser.parse_expression (markup_tag.markup_class, markup_tag.me, attribute_name, stripped_value);
			} else {
				return generate_literal (stripped_value);
			}
		}
		return null;
	}

	public virtual Statement? get_assignment (MarkupResolver resolver, MarkupTag markup_tag) {
		resolve (resolver, markup_tag);

		Expression assignment;
		Expression? right_hand = get_expression (resolver, markup_tag);
		
		if (right_hand == null)
			return null;

		var parent_access = new MemberAccess.simple (markup_tag.me, source_reference);
		var attribute_access = new MemberAccess (parent_access, attribute_name, source_reference);
		
		if (@signal != null) {
			var connect_call = new MethodCall ( new MemberAccess (attribute_access, "connect", source_reference), source_reference);
			connect_call.add_argument (right_hand);
			assignment = connect_call;
		} else {
			assignment = new Assignment (attribute_access, right_hand, AssignmentOperator.SIMPLE, source_reference);
		}
		return new ExpressionStatement (assignment);
	}
	
	public virtual void resolve (MarkupResolver resolver, MarkupTag markup_tag) {
		if (target_type != null) return;
	
		assert (markup_tag.resolved_type is ObjectType || markup_tag.resolved_type is StructValueType);
		
		TypeSymbol type_symbol = null;
		if (markup_tag.resolved_type is ObjectType) {
			type_symbol = ((ObjectType)markup_tag.resolved_type).type_symbol;
		} else if (markup_tag.resolved_type is StructValueType) {
			type_symbol = ((StructValueType)markup_tag.resolved_type).type_symbol;
		}
		
		Symbol? resolved_attribute = resolver.search_symbol (type_symbol, attribute_name);
		
		if (resolved_attribute is Property) {
			target_type = ((Property)resolved_attribute).property_type.copy ();
		} else if (resolved_attribute is Field) {
			target_type = ((Field)resolved_attribute).variable_type.copy ();
		} else if (resolved_attribute is Vala.Signal) {
			@signal = (Vala.Signal)resolved_attribute;
		} else {
			//it's a parameter for add/create, not an actual property
		}
	}
	
	protected Expression? generate_literal (string stripped_value) {
		if (target_type == null) {
			Report.error (source_reference, "Unknown attribute `%s' on `%s'".printf (attribute_name, stripped_value));
			return null;
		}
		var type_symbol = target_type.type_symbol;
		var type_name = type_symbol != null ? type_symbol.get_full_name () : target_type.to_qualified_string ();

		if (type_name == "string") {
			return new StringLiteral ("\"" + attribute_value.replace ("\"", "\\\"") + "\"", source_reference);
		} else if (type_name == "bool") {
			//TODO: full boolean check 
			return new BooleanLiteral (attribute_value == "true", source_reference);
		} else if (target_type is IntegerType) {
			return new IntegerLiteral (attribute_value, source_reference);
		} else if (target_type is FloatingType) {
			return new RealLiteral (attribute_value, source_reference);
		} else if (target_type is ReferenceType && stripped_value == "null") {
			return new NullLiteral (source_reference);
		} else if (target_type is EnumValueType) {
			var enum_value = ((EnumValueType)target_type).get_member (attribute_value);
			
			if (enum_value == null) {
				 enum_value = ((EnumValueType)target_type).get_member (attribute_value.up ());
			}
			
			if (enum_value is Vala.EnumValue) {
				if (type_symbol == null) {
					Report.error (source_reference, "Error: enum type for '%s' could not be resolved\n".printf (attribute_name));
					return null;
				}
				var enum_access = new MemberAccess.simple (type_symbol.name, source_reference);
				return new MemberAccess (enum_access, enum_value.name, source_reference);
			} else {
				Report.error (source_reference, "Error: enum literal of '%s' not found: %s\n".printf (type_name, attribute_value));
				return null;
			}
		} else {
			Report.error (source_reference, "Error: attribute literal of '%s' type found\n".printf (type_name));
			return null;
		} 
	}
	
}
