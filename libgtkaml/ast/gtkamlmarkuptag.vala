/* gtkamlmarkuptag.vala
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
 * A tag that is a parent of others. Can be the root tag.
 * 
 * You have to implement:
 * 
 *  * generate_public_ast
 *  * (optionally) resolve
 *  * generate
 */ 
public abstract class Gtkaml.Ast.MarkupTag : Object {
	
	protected Vala.List<MarkupChildTag> child_tags = new Vala.ArrayList<MarkupChildTag> ();
	protected Vala.List<MarkupAttribute> markup_attributes = new Vala.ArrayList<MarkupAttribute> ();

	/**
	 * not-ignorable text nodes concatenated
	*/
	public string text {get; set;}

	/**
	 * the actual tag encountered
	 */	
	public string tag_name {get; set;}

	/**
	 * the Vala namespace
	 */
	public MarkupNamespace tag_namespace {get; set;}

	/**
	 * references the Vala class in which this tag was defined
	 */
	public weak MarkupClass markup_class {get; private set;}

	public SourceReference? source_reference {get; set;}
	
	/**
	 * the expression to be used (either 'this', or 'property name' or 'temporary variable name') when using the tag
	 */
	public abstract string me {get;}
	
	/**
	 * usually an Unresolved data type created from the tag name/namespace
	 */
	public DataType data_type {get ; set;}
	
	private DataTypeParent _data_type_parent;

	/**
	 * the determined data type - see resolve()
	 */
	public DataType resolved_type { 
		get {
			assert (!(_data_type_parent.data_type is UnresolvedType));
			return _data_type_parent.data_type;
		}
	}
	
	public bool is_resolved { 
		get {
			return !(_data_type_parent.data_type is UnresolvedType);
		}
	}

	public string construct_text;
	
	public string preconstruct_text;

	private string _full_name;

	/**
	 * shortcut for resolved_type.type_symbol.get_full_name () -> for debugging
	 */
	public string full_name {
		get {
			var type_symbol = resolved_type.type_symbol;
			return _full_name = type_symbol != null ? type_symbol.get_full_name () : resolved_type.to_qualified_string ();
		}
	}
	
	/**
	 * attributes explicitly found as creation parameters + default ones.
	 * All in the original order.
	 */
	public Vala.List<MarkupAttribute> creation_parameters = new Vala.ArrayList<MarkupAttribute> ();

	/**
	 * resolved creation method
	 */
	public CreationMethod creation_method;
	
	protected MarkupTag (MarkupClass markup_class, string tag_name, MarkupNamespace tag_namespace, SourceReference? source_reference = null) {
		this.markup_class = markup_class;
		this.tag_name = tag_name;
		this.tag_namespace = tag_namespace;
		this.source_reference = source_reference;
		this.construct_text = this.preconstruct_text = null;
		
		this.data_type = new UnresolvedType.from_symbol (new UnresolvedSymbol (tag_namespace, tag_name, source_reference));
		this.data_type.value_owned = true;
		
		this._data_type_parent = new DataTypeParent (data_type);
		this.creation_parameters = new Vala.ArrayList<MarkupAttribute> ();
	}

	/**
	 * Called when parsing.
	 * This only generates placeholder Vala AST so that the Parser can move on.
	 * e.g. the class itself, its public properties go here.
	 */
	public abstract void generate_public_ast (CodeParserProvider parser);

	/**
	 * Called when Gtkaml is resolving. 
	 * Here replacements in the Gtkaml AST can be made (e.g. MarkupUnresolvedTag -> MarkupTemp).
	 * Tags to remove must return 'null' here so that the SymbolResolver can remove them later
	 */
	public virtual MarkupTag? resolve (MarkupResolver resolver) {
		data_type.accept (resolver);
		var type_symbol = resolved_type.type_symbol;
		if (type_symbol != null) {
			type_symbol.accept (resolver);
		}
		return this;
	}
	
	/**
	 * Called when Gtkaml is resolving, after recursing over children
	 */
	public virtual void resolve_attributes (MarkupResolver resolver) {
		resolve_creation_method (resolver);
	}
	
	/** 
	 * Called after Gtkaml finished resolving, before Vala resolver kicks in.
	 * Final AST generation phase1 (all AST)
	 */
	public abstract void generate (MarkupResolver resolver);
	
	/**
	 * Called after Gtkaml finished resolving, before Vala resolver kicks in.
	 * Final AST generation phase2 (attributes)
	 */
	public virtual void generate_attributes (MarkupResolver resolver)	{

		foreach (var attribute in creation_parameters) {
			if (attribute is MarkupComplexAttribute) {
				resolver.generate_markup_tag (((MarkupComplexAttribute)attribute).value_tag);
			}
		}

		foreach (var attribute in markup_attributes) {
			if (attribute is MarkupComplexAttribute) {
				resolver.generate_markup_tag (((MarkupComplexAttribute)attribute).value_tag);
			}
			var assignment = attribute.get_assignment (resolver, this);
			if (assignment != null)
				markup_class.constructor.body.add_statement (assignment);
		}
	}

	public virtual void generate_preconstruct (MarkupResolver resolver)
	{
		if (preconstruct_text != null) {
			var stmts = resolver.code_parser.parse_statements (this.markup_class, this.me, "_preconstruct", strip_braces (preconstruct_text));
			if (stmts is Block) {
				foreach (var stmt in stmts.get_statements ()) {
					markup_class.constructor.body.add_statement (stmt);
				}
			}
		}
	}

	public virtual void generate_construct (MarkupResolver resolver)
	{
		if (construct_text != null) {
			var stmts = resolver.code_parser.parse_statements (this.markup_class, this.me, "_construct", strip_braces (construct_text));
			if (stmts is Block) {
				foreach (var stmt in stmts.get_statements ()) {
					markup_class.constructor.body.add_statement (stmt);
				}
			}
		}
	}

	
	/**
	 * picks up creation method parameters and determines the creation method, if applicable
	 */
	protected virtual void resolve_creation_method (MarkupResolver resolver) {
		var candidates = get_creation_method_candidates ();
		
		//go through each method, updating max&max_match_method if it matches and min&min_match_method otherwise
		//so that we know the best match method, if found, otherwise the minimum number of arguments to specify

		int min = 100; CreationMethod min_match_method = candidates.get (0);
		int max = -1; CreationMethod max_match_method = candidates.get (0);
		Vala.List<MarkupAttribute> matched_method_parameters = new Vala.ArrayList<MarkupAttribute> ();
		
		var i = 0;
		
		do {
			var current_candidate = candidates.get (i);
			var parameters = resolver.get_default_parameters (full_name, new Callable(current_candidate), source_reference);
			int matches = 0;

			foreach (var parameter in parameters) {
				if ( (null != get_attribute (parameter.attribute_name)) || parameter.attribute_value != null) {
					matches ++;
				}
			}
			
			if (matches < parameters.size) {  //does not match
				if (parameters.size < min) {
					min = parameters.size;
					min_match_method = current_candidate;
				}
			} else {
				assert (matches == parameters.size);
				if (parameters.size > max) {
					max = parameters.size;
					max_match_method = current_candidate;
					matched_method_parameters = parameters;
				}
			}

			i++;
		} while ( i < candidates.size );

		if (max_match_method.get_parameters ().size == max) { 
			this.creation_method = max_match_method;
			//save the CreationMethodParameters:
			foreach (var parameter in matched_method_parameters) {
				MarkupAttribute explicit_attribute = null;
				if (null != (explicit_attribute = get_attribute (parameter.attribute_name))) {
					//for the explicit ones, copy the data type from the default attribute
					explicit_attribute.target_type = parameter.target_type;
					this.creation_parameters.add (explicit_attribute);
					remove_attribute (explicit_attribute);
				} else {
					//for the default ones, include the default attribute
					this.creation_parameters.add (parameter);
				}
			}
		} else {
			var required = "";
			var parameters = min_match_method.get_parameters ();
			i = 0;
			for (; i < parameters.size - 1; i++ ) {
				required += "'" + parameters[i].name + "',";
			}
			required += "'" + parameters[i].name + "'";
			resolve_creation_method_failed (source_reference, "at least %s required for %s instantiation.".printf (required, full_name));
		}
		
	}

	/**
     * decides weather to halt on error or just issue an warning
     */
	protected virtual void resolve_creation_method_failed (SourceReference source_reference, string message) {
		Report.error (source_reference, message);
	}
	
	/**
	 * returns the list of possible creation methods
	 */
	protected virtual Vala.List<CreationMethod> get_creation_method_candidates () {
		#if DEBUGMARKUPHINTS
		stderr.printf ("Searching for creation method candidates for %s:\n", full_name);
		#endif
		Vala.List<CreationMethod> candidates = new Vala.ArrayList<CreationMethod> ();

		Vala.List<Method> methods = null;
		var type_symbol = resolved_type.type_symbol;
		if (type_symbol is Class) {
			methods = ((Class) type_symbol).get_methods ();
		} else if (type_symbol is Struct) {
			methods = ((Struct) type_symbol).get_methods ();
			var default_struct_creation = new CreationMethod (tag_name, ".new", source_reference);
			methods.add (default_struct_creation);
		}
			
		foreach (Method m in methods) {
			if (m is CreationMethod) { 
				candidates.add (m as CreationMethod);
				#if DEBUGMARKUPHINTS
				stderr.printf ("Found candidate '%s'\n", m.name );
				#endif
			}
		}

		assert (candidates.size > 0);
		return candidates;
	}
	
	public Vala.List<MarkupChildTag> get_child_tags () {
		return child_tags;
	}	
		
	public void add_child_tag (MarkupChildTag child_tag) {
		child_tags.add (child_tag);
		child_tag.parent_tag = this;
	}
	
	/**
	 * replaces a child tag and moves all its attributes and subtags to the new one
	 */
	public void replace_child_tag (MarkupChildTag old_child, MarkupChildTag new_child) {
		for (int i = 0; i < child_tags.size; i++) {
			if (child_tags[i] == old_child) {
				foreach (MarkupChildTag child_tag in child_tags[i].get_child_tags ())
					new_child.add_child_tag (child_tag);
				foreach (MarkupAttribute attribute in child_tags[i].get_markup_attributes ())
					new_child.add_markup_attribute (attribute);				
				child_tags[i] = new_child;
				return;
			}
		}
	}
	
	public void remove_child_tag (MarkupChildTag old_child) {
		child_tags.remove (old_child);
	}

	public Vala.List<MarkupAttribute> get_markup_attributes () {
		return markup_attributes;
	}
	
	public void add_markup_attribute (MarkupAttribute markup_attribute) {
		markup_attributes.add (markup_attribute);
	}

	public MarkupAttribute? get_attribute (string name) {
		foreach (var attribute in markup_attributes) {
			if (attribute.attribute_name == name) 
				return attribute;
		}
		return null;
	}
	
	public void remove_attribute (MarkupAttribute attribute) {
		markup_attributes.remove (attribute);
	}
	
	///Common AST techniques
	
	/** 
	 * returns ns.ns.ns.Class member access
	 */
	protected MemberAccess get_class_expression () {
		return new MemberAccess (namespace_access (tag_namespace), tag_name, source_reference);
	}
	
	private MemberAccess? namespace_access (UnresolvedSymbol? ns) {
		if (ns == null) return null;
		return new MemberAccess (namespace_access (ns.inner), ns.name, source_reference);
	}
	
	private string strip_braces (string code) {
		string stripped_value = code.strip ();
		if (stripped_value.has_prefix ("{")) {
			if (stripped_value.has_suffix ("}")) {
				return stripped_value.substring (1, stripped_value.length - 2);
			} else {
				Report.error (source_reference, "Unbalanced braces");
				return code;
			}
		} else {
			return code;
		}
	}

}
