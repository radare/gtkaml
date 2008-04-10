/* GtkamlMethodMatcher.vala
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

using Vala;
using GLib;

namespace Gtkaml {
	
	public class MethodMatcher : Object {
		
		public ClassDefinition class_owning_method {get; construct;}
		public string wording {get; construct;}
		public ComplexAttribute? first_parameter {get; construct;}		
		public ImplicitsStore implicits_store {get;construct;}

		private ClassDefinition class_owning_parameters; 
		
		/**
		 * @first_parameter is used to discern between add methods (first_parameter=child widget) and creation methods (first_parameter=null)
		 * @wording contains a display name for the type of method
		 */
		public MethodMatcher (construct ImplicitsStore! implicits_store, construct ClassDefinition! class_owning_method, 
			construct string! wording, construct ComplexAttribute? first_parameter = null)
		{
		}
		
		construct {
			if (first_parameter == null) {
				this.class_owning_parameters = class_owning_method;
			} else {
				this.class_owning_parameters = first_parameter.complex_type;
			}
		}
		
		private Gee.List<Vala.Method> methods = new Gee.ArrayList<Vala.Method> ();
		
		public void add_method (Vala.Method method) 
		{
			methods.add (method);
		}
		
		/** the minimum number of parameters */ 
		private int min_params = 999; /* use MAX_INT? */
		/** the least you would need to call that minimal method */
		private Gee.List<ImplicitsParameter> min_param_names = null;
		/** the number of maximum matched parameters */
		private int max_matches = -1;
		/** the method most matched */
		private Vala.Method max_matches_method = null;
		/** the number of matched defaulted parameters */
		private int max_matches_defaulted = 0;
		/** the default parameters for the max matches method */
		private Gee.List<ImplicitsParameter> max_matches_method_defaulted_parameters = null;
		/** if there are more methods that match for the same parameters, this is > 1 */
		private int count_with_max_match = 0;
		
		public Vala.Method? determine_matching_method ()
		{
			Gee.List<ImplicitsParameter> defaulted_parameters;

			//stderr.printf ("===%d candidates\n", methods.size);
			foreach (Vala.Method method in methods) {
				//stderr.printf ("CANDIDATE %s\n", method.name);
				var parameters = implicits_store.determine_parameter_names_and_default_values (class_owning_method, method);
				int current_matches = 0;
				int current_matches_defaulted = 0;
				Gee.List<ImplicitsParameter> current_defaulted_parameters = new Gee.ArrayList<ImplicitsParameter> ();
				 
				foreach (ImplicitsParameter parameter in parameters) {
					//stderr.printf ("searching for %s =>", parameter.name); 
					int flag_current_matches_modified = current_matches;
					foreach (Gtkaml.Attribute attr in this.class_owning_parameters.attrs) {
						if (parameter.name == attr.name) {
							current_matches ++;
							//stderr.printf (" .. explicit\n");
							break;
						}
					}
					if (flag_current_matches_modified == current_matches) {
						if (parameter.default_value != null) {
							current_matches_defaulted++;
							current_defaulted_parameters.add (parameter);
							//stderr.printf (" .. default %s\n", parameter.name);
						} else {
							//stderr.printf (" .. not found\n");
						}
					}
				}
				if (first_parameter != null) //child widget
				{
					current_matches++;
				} 
				
				//full match?
				if (current_matches + current_matches_defaulted == parameters.size ) {
					if (current_matches > max_matches) {
						//stderr.printf ("local maximum is %s with %d matches and %d defaulted\n", method.name, current_matches, current_matches_defaulted);
						max_matches = current_matches;
						max_matches_defaulted = current_matches_defaulted;
						max_matches_method = method;
						max_matches_method_defaulted_parameters = current_defaulted_parameters;
						count_with_max_match = 1;
					} else if (current_matches == max_matches) {
						if (max_matches_defaulted > current_matches_defaulted) {
							//stderr.printf ("found method with less defaulted parameters\n");
							max_matches = current_matches;
							max_matches_defaulted = current_matches_defaulted;
							max_matches_method = method;
							max_matches_method_defaulted_parameters = current_defaulted_parameters;
							count_with_max_match = 1;
						} else if (max_matches_defaulted > current_matches_defaulted) {
							count_with_max_match ++;
						} else {
							//stderr.printf ("found method with more defaulted parameters, discarding\n");
						}
					}
				} else {
					//stderr.printf ("discarded because %d != %d\n", current_matches, parameters.size);
				}
				if (parameters.size < min_params) {
					min_params = parameters.size;
					min_param_names = parameters;
				}
			}
			
			if (max_matches_method == null){
				if (min_param_names == null) {
					Report.error(class_owning_method.source_reference, "The class %s doesn't have %ss\n".printf (class_owning_method.base_full_name, wording));
				} else {
					string message = "";
					int i = 0;
					if (first_parameter!=null) i = 1;
					for (; i < min_param_names.size - 1; i++) {
						message += min_param_names.get (i).name + ", ";
					}
					if (i < min_param_names.size )
						message += min_param_names.get (i).name;
					Report.error (this.class_owning_parameters.source_reference, "NO matching %s found for %s: specify at least: %s\n".printf (wording, class_owning_method.base_full_name, message));
				} 
				return null;
			}
			
			if (count_with_max_match > 1) {
				//Report.warning (class_owning_method.source_reference, "More than one %s matches your definition of %s(%s)\n".printf (wording, class_owning_method.identifier, class_owning_method.base_full_name));
			}
			
			foreach (ImplicitsParameter parameter in max_matches_method_defaulted_parameters) {
				//stderr.printf ("found default value for %s.%s.%s being <%s>\n", class_owning_method.base_full_name, max_matches_method.name, parameter.name, parameter.default_value);
				if (first_parameter != null) {
					first_parameter.complex_type.add_attribute (new SimpleAttribute (parameter.name, parameter.default_value));
				} else {
					class_owning_method.add_attribute (new SimpleAttribute (parameter.name, parameter.default_value));
				}
			}
			//stderr.printf ("selected '%s'\n", max_matches_method.name);			
			return max_matches_method;
		}

		public void set_method_parameters (Gtkaml.Method new_method, Vala.Method determined_method) 
		{
			Gee.List<Gtkaml.Attribute> to_remove = new Gee.ArrayList<Gtkaml.Attribute> ();
			
			new_method.name = determined_method.name;
			if (first_parameter != null) {
				new_method.parameter_attributes.add (first_parameter);
			}

			//move the attributes from class definition to add method
			Gee.List<ImplicitsParameter> parameters = implicits_store.determine_parameter_names_and_default_values (this.class_owning_method, determined_method);
			foreach (ImplicitsParameter parameter in parameters) {
				foreach (Gtkaml.Attribute attr in this.class_owning_parameters.attrs) {
					if (parameter.name == attr.name) {
						new_method.parameter_attributes.add (attr);
						to_remove.add (attr);
						break;
					}
				}
			}		
			
			int i;
			if ( parameters.size  != new_method.parameter_attributes.size)
			{
				//stderr.printf ("failed because %d != %d", parameters.size, new_method.parameter_attributes.size + i);
				i = 0;
				if (first_parameter != null) i = 1;//skip child
				string message = "";
				for (; i < parameters.size -1; i++)
					message += parameters.get (i).name + ", ";
				if (i < parameters.size)
					message += parameters.get (i).name;
				Report.error (this.class_owning_parameters.source_reference, "No matching %s found for %s: specify at least: %s\n".printf (wording, class_owning_parameters.base_full_name, message));
				return;
			} 
			
			//determine attr.target_types directly from method signature
			Gee.Collection<FormalParameter> method_parameters = determined_method.get_parameters ();
			i = 0;
			foreach (FormalParameter formal_parameter in method_parameters)
			{
				if (!formal_parameter.ellipsis) {
					var attr = new_method.parameter_attributes.get (i);
					attr.target_type = formal_parameter;
					i++;
				}
			}

			foreach (Gtkaml.Attribute attr in to_remove)
				class_owning_parameters.attrs.remove (attr);
			
		}
		
	}

}
