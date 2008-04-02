using GLib;

namespace Gtkaml {

	public class MethodMatcher:Object {
		/** the minimum number of parameters */ 
		public int min_params = 999; /* use MAX_INT? */
		/** the least you would need to call that minimal method */
		public Gee.List<ImplicitsParameter> min_param_names = null;
		/** the number of maximum matched parameters */
		public int max_matches = -1;
		/** the method most matched */
		public Vala.Method max_matches_method = null;
		/** the number of matched defaulted parameters */
		public int max_matches_defaulted = 0;
		/** the default parameters for the max matches method */
		public Gee.List<ImplicitsParameter> max_matches_method_defaulted_parameters = null;
		/** if there are more methods that match for the same parameters, this is > 1 */
		public int count_with_max_match = 0;
		
	}

}
