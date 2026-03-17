/* gtkamlmarkuphint.vala
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
 * Contains parameters for creation and composition methods of a given Class/Interface, 
 * along with their default values if present
 */
public class Gtkaml.MarkupHint {
	/**
	 * the full symbol name of the target hinted symbol
	 */
	public string target;
	
	private static string ADD = "add-"; //composition methods
	private static string NEW = "new-"; //creation methods
	
	/* maps for directly navigating to a given creation/composition method*/
	private Vala.Map<string, Vala.List<Pair<string,string?>>> hint_map;
	
	/* lists for preserving .markuphints file order */
	private Vala.List<Pair<string, Vala.List<Pair<string, string?>>>> hint_list;
	
	public MarkupHint (string target) {
		this.target = target;
		this.hint_map = new Vala.HashMap<string, Vala.List<Pair<string,string?>>> (str_hash, str_equal);
		this.hint_list = new Vala.ArrayList<Pair<string, Vala.List<Pair<string, string?>>>> ();
	}
	
	public Vala.List<string> get_composition_method_names ()	{
		Vala.List<string> methods = new Vala.ArrayList<string> ();
		foreach (var method_pair in hint_list) {
			if (method_pair.name.has_prefix (MarkupHint.ADD)) {
				methods.add (method_pair.name.substring (MarkupHint.ADD.length));
			}
		} 
		return methods;
	}
	
	public Vala.List<Pair<string, string?>> get_creation_method_parameters (string name) {
		return hint_map.get (MarkupHint.NEW + name);
	}

	public Vala.List<Pair<string, string?>> get_composition_method_parameters (string name) {
		return hint_map.get (MarkupHint.ADD + name);
	}
	
	/* adding a creation or an composition method */
	
	private void add_hint (string hint_name, string type) {
		var full_hint_name = type + hint_name;
		if (!hint_map.contains (full_hint_name)) {
			var parameters_list = new Vala.ArrayList<Pair<string, string?>> ();
			hint_map.set (full_hint_name, parameters_list);
			hint_list.add (new Pair<string, Vala.List<Pair<string, string?>>> (full_hint_name, parameters_list));
		}
	}
	
	public void add_creation_method (string creation_method_name) {
		add_hint (creation_method_name, MarkupHint.NEW);
	}
	
	public void add_composition_method (string composition_method_name) {
		add_hint (composition_method_name, MarkupHint.ADD);
	}
	
	/* adding parameters to creation or composition method */
	
	private bool add_hint_parameter (string hint_method_name, string type, string parameter, string? default_value) {
		var hint_full_name = type + hint_method_name;
		var parameters = hint_map.get (hint_full_name);
		
		if (parameters == null) {
			return false;
		}	
		
		parameters.add (new Pair<string, string?> (parameter, default_value));
		return true;
	}
		
	public bool add_creation_method_parameter (string creation_method_name, string parameter, string? default_value) {
		return add_hint_parameter (creation_method_name, NEW, parameter, default_value);
	}
	
	public bool add_composition_method_parameter (string composition_method_name, string parameter, string? default_value) {
		return add_hint_parameter (composition_method_name, ADD, parameter, default_value);
	}
}

public class Gtkaml.Pair<K,V> {
	public K name;
	public V value;
	public Pair (owned K name, owned V value) {
		this.name = (owned)name;
		this.value = (owned)value;
	}
}
