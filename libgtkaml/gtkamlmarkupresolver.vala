/* gtkamlmarkupresolver.vala
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
 * Gtkaml SymbolResolver
 */
public class Gtkaml.MarkupResolver : SymbolResolver, CodeParserProvider {

	public MarkupHintsStore markup_hints;
	public ValaParser code_parser {get; private set;}

	CodeContext context {get; set;}

	public new void resolve (CodeContext context) {
		markup_hints = new MarkupHintsStore (context);
		code_parser = new ValaParser (context);
		markup_hints.parse ();
		this.context = context;
		base.resolve (context);
	}
	
	/**
	 * executes before base.visit_class, triggers resolving and generating of tags
	 */
	public void visit_markup_class (MarkupClass mcl) {
		if (!mcl.markup_root.is_resolved) { //break cycles
			resolve_markup_tag (mcl.markup_root);
			generate_markup_tag (mcl.markup_root);
		}
	}
	
	/**
	 * looks up a memeber in the type hierarchy and returns its symbol
	 */
	public Symbol? search_symbol (TypeSymbol type, string sym_name)
	{
		Symbol? sym = type.scope.lookup (sym_name);
		if (sym == null) {
			Vala.List<DataType> base_types;
			if (type is Class) {
				base_types = ((Class)type).get_base_types();
			} else {
				return null;
			} 
			foreach (var base_type in base_types){
				if (base_type is ClassType) {
					sym = search_symbol (((ClassType)base_type).class_symbol, sym_name);
				} else if (base_type is InterfaceType) {
					sym = search_symbol (((InterfaceType)base_type).interface_symbol, sym_name);
				} else if (base_type is ObjectType) {
					sym = search_symbol (((ObjectType)base_type).type_symbol, sym_name);
				}
				if (sym != null) break;
			}
		}
		return sym;
	}
	
	/**
	 * processes tag hierarchy. Unresolved tags are removed after this step
	 */
	protected bool resolve_markup_tag (MarkupTag markup_tag) {
		//resolve first
		MarkupTag? resolved_tag = markup_tag.resolve (this);
		
		if (resolved_tag != null) {
			if (!resolved_tag.is_resolved) {
				Report.error (markup_tag.source_reference, "Unknown type %s".printf (markup_tag.tag_name));
				return false;
			}
			if (resolved_tag.resolved_type.type_symbol == null) {
				Report.error (markup_tag.source_reference, "Unknown type %s".printf (resolved_tag.tag_name));
				return false;
			}
			
			Vala.List<MarkupChildTag> to_remove = new Vala.ArrayList<MarkupChildTag> ();

			//recurse
			foreach (var child_tag in resolved_tag.get_child_tags ()) {
				if (false == resolve_markup_tag (child_tag)) {
					to_remove.add (child_tag);
				}
			}
		
			//remove 
			foreach (var remove in to_remove)
				resolved_tag.remove_child_tag (remove);
				
			//attributes last
			resolved_tag.resolve_attributes (this);
		}		
		return resolved_tag != null;
	}

	/**
	 * processes tag hierarchy, calling generate () on each, then recurses, then generate_attributes () 
	 */
	public void generate_markup_tag (MarkupTag markup_tag) {
		markup_tag.generate (this);
		markup_tag.generate_preconstruct (this);
		markup_tag.generate_attributes (this);
		foreach (MarkupTag child_tag in markup_tag.get_child_tags ())
			generate_markup_tag (child_tag);
		markup_tag.generate_construct (this);
	}
	
	/** 
	 * returns parameters of a Callable as a list of MarkupAttributes with name, type and default value if one exists as markup hints
	 */	
	public Vala.List<MarkupAttribute> get_default_parameters (string full_type_name, Callable m, SourceReference? source_reference = null) {
		var parameters = new Vala.ArrayList<MarkupAttribute> ();
		var hint = markup_hints.markup_hints.get (full_type_name);
		if (hint != null) {
			Vala.List <Pair<string, string?>> parameter_hints = hint.get_creation_method_parameters (m.name);
			if (parameter_hints == null) parameter_hints = hint.get_composition_method_parameters (m.name); //FIXME this if is disturbing
			#if DEBUGMARKUPHINTS
			stderr.printf ("Found %d parameter hints for %s#%s\n", parameter_hints.size, full_type_name, m.name);
			#endif
			if (parameter_hints != null && parameter_hints.size != 0) {
				if (parameter_hints.size != m.get_parameters ().size) {
					context.report.warn (source_reference, "Ignoring outdated markuphints for %s#%s".printf (full_type_name, m.name));
					parameter_hints = null;
				}
			}
			if (parameter_hints != null && parameter_hints.size != 0) {
				//actual merge. with two parralell foreaches
				int i = 0;
				foreach (var formal_parameter in m.get_parameters ()) {
					assert ( i < parameter_hints.size );
					var parameter = new MarkupAttribute.with_type ( parameter_hints.get (i).name, parameter_hints.get (i).value, formal_parameter.variable_type, source_reference );
					parameters.add (parameter);
					i++;
				}
				return parameters;
			}
		}
		foreach (var formal_parameter in m.get_parameters ()) {
			if (formal_parameter.ellipsis) {
				parameters.add (new MarkupAttribute.with_type ( "...", "null", new NullType (source_reference)));
				break;
			}
			var parameter = new MarkupAttribute.with_type ( formal_parameter.name, null, formal_parameter.variable_type );
			parameters.add (parameter);
		}
		#if DEBUGMARKUPHINTS
		stderr.printf ("Found %d formal parameters for %s#%s\n", parameters.size, full_type_name, m.name);
		#endif
		return parameters;
	}	

	/**
	 * returns the list of methods that can be used to add child tags for the current type, and its base types
	 */
	public Vala.List<Callable> get_composition_method_candidates (TypeSymbol parent_tag_symbol) {
		Vala.Set<string> visited = new HashSet<string> (GLib.str_hash, GLib.str_equal);
		return get_composition_methods_cached (parent_tag_symbol, visited);
	}
	
	protected Vala.List<Callable> get_composition_methods_cached (TypeSymbol parent_tag_symbol, Vala.Set<string> visited) {
		Vala.List<Callable> candidates = new Vala.ArrayList<Callable> ();
		#if DEBUGMARKUPHINTS
		stderr.printf ("Searching for composition method candidates for %s\n", parent_tag_symbol.get_full_name ());
		#endif
		var hint = markup_hints.markup_hints.get (parent_tag_symbol.get_full_name ());
		if (hint != null) {
			Vala.List<string> names = hint.get_composition_method_names ();
			foreach (var name in names) {
				Symbol? m = search_method_or_signal (parent_tag_symbol, name);
				if (m == null) {
					Report.error (null, "Invalid composition method hint: %s does not belong to %s".printf (name, parent_tag_symbol.get_full_name ()) );
				} else {
					#if DEBUGMARKUPHINTS
					stderr.printf (" FOUND!\n");
					#endif
					candidates.add (new Callable(m));
				}
			}
		}

		if (parent_tag_symbol is Class) {
			Class parent_class = (Class)parent_tag_symbol;
			if (parent_class.base_class != null && !visited.contains (parent_class.base_class.get_full_name ())) {
				foreach (var m in get_composition_methods_cached (parent_class.base_class, visited)) {
					candidates.add (m);
				}
			}
			foreach (var base_type in parent_class.get_base_types ()) {
				if (!visited.contains (base_type.to_qualified_string ())) {
					if (base_type.type_symbol == null) {
						continue;
					}
					foreach (var m in get_composition_methods_cached (base_type.type_symbol, visited)) {
						candidates.add (m);
					}
				}
			}
		} 
		visited.add (parent_tag_symbol.get_full_name ());
		return candidates;
	}
	
	/** 
	 * returns method or signal 
	 */
	protected Symbol? search_method_or_signal (TypeSymbol type, string name) {
		#if DEBUGMARKUPHINTS
		stderr.printf ("\rsearching %s in %s..", name, type.name);
		#endif
		if (type is Class) {
			Class class_type = (Class)type;
			foreach (var m in class_type.get_methods ())
				if (m.name == name) return m;
			foreach (var s in class_type.get_signals ())
				if (s.name == name) return s;
			if (class_type.base_class != null) {
				Symbol? m = search_method_or_signal (class_type.base_class, name);
				if (m != null) return m;
			}
			foreach (var base_type in class_type.get_base_types ()) {
				if (base_type.type_symbol == null) {
					continue;
				}
				Symbol? m = search_method_or_signal (base_type.type_symbol, name);
				if (m != null) return m;
			}
		} else
		if (type is Interface) {
			Interface interface_type = type as Interface;
			foreach (var m in interface_type.get_methods ())
				if (m.name == name) return m;
			foreach (var s in interface_type.get_signals ())
				if (s.name == name) return s;
		} else
			assert_not_reached ();
		return null;
	}
	
}
