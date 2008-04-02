using Vala;
using GLib;

namespace Gtkaml {
	
	/**
	 * @first_parameter is used to discern between add methods (first_parameter=child widget) and creation methods (first_parameter=null)
	 * @wording contains a display name for the type of method
	 */
	public class MethodMatcher:Object {
		
		public ClassDefinition class_definition {get; construct;}
		public string wording {get; construct;}
		public ComplexAttribute first_parameter {get; construct;}		
		public ImplicitsStore implicits_store {get;construct;}
		
		public MethodMatcher (construct ImplicitsStore! implicits_store, construct ClassDefinition! class_definition, 
			construct string! wording, construct ComplexAttribute! first_parameter = null)
		{
		}
		
		private Gee.List<Vala.Method> methods = new Gee.ArrayList<Vala.Method> ();
		
		public void addMethod (Vala.Method method) 
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
		
		public Vala.Method determine_matching_method ()
		{
			ClassDefinition parameter_class = class_definition;
			Gee.List<ImplicitsParameter> defaulted_parameters;

			if (first_parameter != null)
				parameter_class = first_parameter.complex_type;

			//stderr.printf ("===%d candidates\n", methods.size);
			foreach (Vala.Method method in methods) {
				//stderr.printf ("CANDIDATE %s\n", method.name);
				var parameters = implicits_store.determine_parameter_names_and_default_values (class_definition, method);
				int current_matches = 0;
				int current_matches_defaulted = 0;
				Gee.List<ImplicitsParameter> current_defaulted_parameters = new Gee.ArrayList<ImplicitsParameter> ();
				 
				foreach (ImplicitsParameter parameter in parameters) {
					//stderr.printf ("searching for %s =>", parameter.name); 
					int flag_current_matches_modified = current_matches;
					foreach (Gtkaml.Attribute attr in parameter_class.attrs) {
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
					Report.error(class_definition.source_reference, "The class %s doesn't have %ss\n".printf (class_definition.base_full_name, wording));
				} else {
					string message = "";
					int i = 0;
					if (first_parameter!=null) i = 1;
					for (; i < min_param_names.size - 1; i++) {
						message += min_param_names.get (i).name + ", ";
					}
					if (i < min_param_names.size )
						message += min_param_names.get (i).name;
					Report.error (parameter_class.source_reference, "NO matching %s found for %s: specify at least: %s\n".printf (wording, class_definition.base_full_name, message));
				} 
				return null;
			}
			
			if (count_with_max_match > 1) {
				//Report.warning (class_definition.source_reference, "More than one %s matches your definition of %s(%s)\n".printf (wording, class_definition.identifier, class_definition.base_full_name));
			}
			
			foreach (ImplicitsParameter parameter in max_matches_method_defaulted_parameters) {
				//stderr.printf ("found default value for %s.%s.%s being <%s>\n", class_definition.base_full_name, max_matches_method.name, parameter.name, parameter.default_value);
				if (first_parameter != null) {
					first_parameter.complex_type.add_attribute (new SimpleAttribute (parameter.name, parameter.default_value));
				} else {
					class_definition.add_attribute (new SimpleAttribute (parameter.name, parameter.default_value));
				}
			}
			//stderr.printf ("selected '%s'\n", max_matches_method.name);			
			return max_matches_method;
		}
		
	}

}
