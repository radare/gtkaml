/* gtkamlmarkuproot.vala
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
 * The root tag of the tag hierarchy
 */
public class Gtkaml.Ast.MarkupRoot : MarkupTag {

	public MarkupRoot (MarkupClass markup_class, string tag_name, MarkupNamespace tag_namespace, SourceReference? source_reference = null) {
		base (markup_class, tag_name, tag_namespace, source_reference);
	}
	
	public override string me { get { return "this"; } }

	public override void generate_public_ast (CodeParserProvider parser) {
		markup_class.add_base_type (data_type.copy ());
		var ctor = new Constructor (markup_class.source_reference);
		ctor.body = new Block (markup_class.source_reference);
		markup_class.add_constructor (ctor);
		parse_class_members (parser, this.text);
	}

	public override void generate (MarkupResolver resolver) {
		generate_creation_method (resolver);
	}
	
	public override MarkupTag? resolve (MarkupResolver resolver) {
		foreach (var using_directive in markup_class.source_reference.using_directives) {
			using_directive.namespace_symbol.accept (resolver);
		}
		return base.resolve (resolver);
	}

	public override void generate_attributes (MarkupResolver resolver) {
		foreach (var parameter in creation_parameters) {
			if (parameter is MarkupComplexAttribute) {
				Report.error (source_reference, "Base class parameters cannot be defined as complex attributes: %s.%s".printf (full_name, parameter.attribute_name));
				break;
			}
			var assignment = parameter.get_assignment (resolver, this);
			if (assignment != null)
				markup_class.constructor.body.add_statement (assignment);
		}
		base.generate_attributes (resolver);
	}

	/**
	 * returns the list of possible creation methods, in root's case, only the default creation method
	 */
	protected override Vala.List<CreationMethod> get_creation_method_candidates () {
		var candidates = base.get_creation_method_candidates ();
		foreach (var candidate in candidates) {
			if (candidate.name == ".new") {
				candidates = new Vala.ArrayList<CreationMethod> ();
				candidates.add (candidate);
				break;//before foreach complains
			}
		}
		assert (candidates.size == 1);
		return candidates;
	}

	protected override void resolve_creation_method_failed (SourceReference source_reference, string message) {
		Report.warning (source_reference, message);
	}


	private void parse_class_members (CodeParserProvider parser, string source) {
		var temp_class = parser.code_parser.parse_members (markup_class, source);
		if (!(temp_class is Class)) return;
		
		Set<string> automatic_fields = new HashSet<string>(str_hash, str_equal);
		
		foreach (var x in temp_class.get_constants ()) { markup_class.add_constant (x); };
		
		foreach (var x in temp_class.get_properties ()) { 
			x.scope.remove ("this"); 
			markup_class.add_property (x); 
			automatic_fields.add("_" + x.name);
		};
		
		foreach (var x in temp_class.get_fields ()) { 
			if (!automatic_fields.contains (x.name)) {
				markup_class.add_field (x); 
			}
		};
		
		foreach (var x in temp_class.get_methods ()) {
			if (!(x is CreationMethod && ((CreationMethod)x).name == ".new"))  {
				markup_class.add_method (x);
			} else {
				if (x.body != null && x.body.get_statements ().size > 0) {
					//custom creation method
					x.name = null;
					markup_class.add_method (x);
				}
			}
		}
		foreach (var x in temp_class.get_signals ()) { markup_class.add_signal (x); };
		foreach (var x in temp_class.get_classes ()) { markup_class.add_class (x); };
		foreach (var x in temp_class.get_structs ()) { markup_class.add_struct (x); };
		foreach (var x in temp_class.get_enums ()) { markup_class.add_enum (x); };
		foreach (var x in temp_class.get_delegates ()) { markup_class.add_delegate (x); };
	}

	/**
	 * generate creation method with base () call
	 */
	private void generate_creation_method (MarkupResolver resolver) {
		
		if (markup_class.default_construction_method != null) {
			//already present
			return;
		}
		
		CreationMethod creation_method = new CreationMethod(markup_class.name, null, markup_class.source_reference);
		creation_method.access = SymbolAccessibility.PUBLIC;
		
		var block = new Block (markup_class.source_reference);

		// In this block, base() call should take place but it's not possible with current Gtk classes
		// I chose to init the params as fields and put them in construct {} but they may move here

		creation_method.body = block;
		
		markup_class.add_method (creation_method);
	}

}
