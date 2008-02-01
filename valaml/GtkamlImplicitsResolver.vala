using GLib;
using Vala;

public class Gtkaml.ImplicitsResolver : GLib.Object 
{
	private KeyFile key_file;
	private string key_file_name {get;set;}
	private Vala.CodeContext context {get;set;}
	
	public ImplicitsResolver (construct Vala.CodeContext context, construct string! key_file_name) {}
	
	construct {
		try {
			key_file = new KeyFile ();
			key_file.load_from_file ("../data/implicits.ini", KeyFileFlags.NONE);
		} catch (KeyFileError error) {
			Report.error (null, error.message);
		}
	}
	
	public void resolve (ClassDefinition !class_definition)
	{
		//first determine which constructor shall we use
		determine_construct_method (class_definition);
		//then determine the .add function, if applyable
		//
		//resolve the attr types
		determine_attribute_types (class_definition);
		if (class_definition.construct_method == null) 
			return;
		foreach (ClassDefinition child in class_definition.container_children)
			resolve (child); 
	}

	public void determine_construct_method (ClassDefinition! class_definition)
	{
		Gee.List<Vala.Method> constructors = lookup_constructors (class_definition.base_type);
		Vala.Method determined_constructor = null;
		Gtkaml.ConstructMethod new_method = new Gtkaml.ConstructMethod ();
		Gee.List<Gtkaml.Attribute> to_remove = new Gee.ArrayList<Gtkaml.Attribute> ();
		//pass one: see if we find an explicitly specified constructor
		foreach (Vala.Method constructor in constructors) {
			foreach (Gtkaml.Attribute attr in class_definition.attrs) {
				if ( attr is SimpleAttribute && ".new." + attr.name == constructor.name && (attr as SimpleAttribute).value == "true") {
					determined_constructor = constructor;
					to_remove.add (attr);
					break;
				}
			}
		}
		
		//pass two: the first who matches the most parameters + warning if there are more
		if (determined_constructor == null) {
			determined_constructor = implicit_method_choice (class_definition, constructors, "constructor");
			if (determined_constructor == null) {
				Report.error (class_definition.source_reference, "No matching constructor for %s\n".printf (class_definition.full_name));
				return;
			}
		}
		
		new_method.name = determined_constructor.name;
		//move the attributes from class definition to construct method
		Gee.List<string> parameters = determine_method_parameter_names (class_definition, determined_constructor);
		
		foreach (string parameter in parameters) {
			foreach (Gtkaml.Attribute attr in class_definition.attrs) {
				if (parameter == attr.name) {
					new_method.parameter_attributes.add (attr);
					to_remove.add (attr);
					attr.target_type = member_lookup_inherited (class_definition.base_type, attr.name);
					break;
				}
			}
		}		
		
		if ( parameters.size  != new_method.parameter_attributes.size )
		{
			string message = "";
			int i = 0;
			for (i = 0; i < parameters.size -1; i++)
				message += parameters.get (i) + ",";
			message += parameters.get (i);
			Report.error (class_definition.source_reference, "No matching %s found for %s: specify at least: %s\n".printf ("Constructor", class_definition.full_name, message));
			return;
		}
		
		foreach (Gtkaml.Attribute attr in to_remove)
			class_definition.attrs.remove (attr);
		
		class_definition.construct_method =  new_method;
	}
	
	/**
	 * the methods that brought this class (ImplicitResolver) to the world
	 */
	public Vala.Method implicit_method_choice (ClassDefinition !class_definition, Gee.List<Vala.Method>! methods, string! wording )
	{
			int min_params = 999;
			Gee.List<string> min_param_names = null;
			int max_matches = 0;
			Vala.Method max_matches_method;
			int count_with_max_match = 0;
			foreach (Vala.Method method in methods) {
				var parameters = determine_method_parameter_names (class_definition, method);
				int current_matches = 0;
				foreach (string parameter in parameters) {
					foreach (Gtkaml.Attribute attr in class_definition.attrs) {
						if (parameter == attr.name) {
							current_matches ++;
							break;
						}
					}
				}
				//full match?
				if (current_matches == parameters.size ) {
					if (current_matches > max_matches) {
						max_matches = current_matches;
						max_matches_method = method;
						count_with_max_match = 1;
					} else if (current_matches == max_matches) {
						count_with_max_match ++;
					}
				}
				if (parameters.size < min_params) {
					min_params = parameters.size;
					min_param_names = parameters;
				}
			}
			
			if (max_matches_method == null){
				if (min_param_names == null) {
					Report.error(class_definition.source_reference, "The class %s doesn't have %ss\n".printf (class_definition.full_name, wording));
				} else {
					string message = "";
					int i = 0;
					for (; i < min_param_names.size -1; i++)
						message += min_param_names.get (i) + ",";
					message += min_param_names.get (i);
					Report.error (class_definition.source_reference, "No matching %s found for %s: specify at least: %s\n".printf (wording, class_definition.full_name, message));
				}
				return null;
			}
			
			if (count_with_max_match > 1) {
				Report.warning (class_definition.source_reference, "More than one %s matches your definition of %s\n".printf (wording, class_definition.full_name));
			}
					
			
			stderr.printf( "Determined the %s %s for %s\n", max_matches_method.name, wording, class_definition.name+"("+class_definition.full_name+")");							
			return max_matches_method;
	}	

	public Gee.List<string> determine_method_parameter_names (ClassDefinition! class_definition, Vala.Method! method)
	{
		var result = new Gee.ArrayList<string> (str_equal);
		string method_name= method.name;
		if (method.name.has_prefix (".new"))
			method_name = method.name.substring(1, method.name.len () - 1);
		if (key_file.has_key (class_definition.full_name, method_name))
		{
			stderr.printf ("Found %s in implicits\n", class_definition.full_name);
			string [] result_array = key_file.get_string_list (class_definition.full_name, method_name);
			for (int i = 0; i < result_array.length; i++)
				result.add (result_array [i]);
		} else {
			foreach (FormalParameter p in method.get_parameters ())
				result.add (p.name);
		}
		return result;
	}
	/**
	 * Determines which method of mine would be useful for a children attributes
	 */	
	public AddMethod determine_add_method (ClassDefinition container_definition, ref Gee.List<Attribute>child_attrs)
	{
		return null;
	}
	
	public void determine_attribute_types (ClassDefinition! class_definition)
	{
		foreach (Attribute attr in class_definition.attrs)
		{
			attr.target_type = member_lookup_inherited (class_definition.base_type, attr.name);
			if (attr.target_type == null) {
				Report.error (class_definition.source_reference, "Cannot find member %s of class %s\n".printf (attr.name, class_definition.full_name));
			}
		}
	}
	
	public Member member_lookup_inherited (Class clazz, string! member) {
		Member result = clazz.scope.lookup (member) as Member;
		if (result != null)
			return result;
		
		foreach (DataType dt in clazz.get_base_types ()) {
			if (dt is UnresolvedType)
			{
				var name = (dt as UnresolvedType).type_name;
				var ns = (dt as UnresolvedType).namespace_name;
				var clazz = lookup_class (ns, name);
				if (clazz != null && ( null != (result = member_lookup_inherited (clazz, member) as Member)))
					return result;
			}
		}
		return null;
	}								

	private Class lookup_class (string xmlNamespace, string name)
	{
		foreach (Vala.Namespace ns in context.root.get_namespaces ()) {
			if (ns.name == xmlNamespace) {
				Symbol s = ns.scope.lookup (name);
				if (s is Class) {
					return s as Class;
				}
			}
		}
		return null;
	}


	public Gee.List<Vala.Method> lookup_constructors (Class clazz) {
		var constructors = new Gee.ArrayList<Vala.Method> ();
		foreach (Vala.Method m in clazz.get_methods ()) {
			if (m.name.has_prefix (".new")) {
				constructors.add (m);
			}
		}	
		return constructors;
	}
}
