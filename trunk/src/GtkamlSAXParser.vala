/* GtkamlSAXParser.vala
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
using GLib;
using Vala;
using Gee;



/** this is the Flying Spaghetti Monster */
public class Gtkaml.SAXParser : GLib.Object {
	/** the only reason this is public is to be accessible from the [Import]s */
	public pointer xmlCtxt;
	public CodeContext context {get;construct;}
	public weak SourceFile source_file {get;construct;}
	private StateStack states {get;set;}
	private Map<string,int> generated_identifiers_counter = new HashMap<string,int> (str_hash, str_equal);
	private Collection<string> used_identifiers = new ArrayList<string> (str_equal);
	/** prefix/vala.namespace pair */
	private Gee.Map<string,string> prefixes_namespaces {get;set;}

	private Gtkaml.RootClassDefinition root_class_definition {get;set;}	
	public string gtkaml_prefix="gtkaml";	
	
	public SAXParser( Vala.CodeContext! context, Vala.SourceFile! source_file) {
		this.context = context;
		this.source_file = source_file;
	}
	
	construct {
		states = new StateStack ();	
		prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
		root_class_definition = null;
	}
	
	public virtual RootClassDefinition parse ()
	{
		string contents;
		ulong length;
		
		try {
			FileUtils.get_contents ( this.source_file.filename, out contents, out length);
		} catch (FileError e) {
			Report.error (null, e.message);
			return null;
		}

		State initial_state = new State (StateId.SAX_PARSER_INITIAL_STATE, null);
		states.push (initial_state); 
		start_parsing (contents, length);
		return root_class_definition;
	}
	
	[Import]
	public void start_parsing (string contents, ulong length);
	
	[Import]
	public void stop_parsing();
	
	[Import]
	public int column_number();
	
	[Import]
	public int line_number();

	[NoArrayLength]
	public void start_element (string localname, string prefix, 
	                         string URI, int nb_namespaces, string[] namespaces, 
	                         int nb_attributes, int nb_defaulted, string[] attributes)
	{

		var attrs = parse_attributes( attributes, nb_attributes );
		State state = states.peek();
		var source_reference = create_source_reference ();
		switch (state.state_id) {
			case StateId.SAX_PARSER_INITIAL_STATE:
				{	
					
					//Frist Tag! - that means, add "using" directives first
					var nss = parse_namespaces (namespaces, nb_namespaces);
					foreach (XmlNamespace ns in nss) {
						if ( null == ns.prefix || null != ns.prefix && ns.prefix != gtkaml_prefix)
						{
							string[] uri_definition = ns.URI.split_set(":");	
							var namespace_reference = new Vala.NamespaceReference (uri_definition[0], source_reference);
							source_file.add_using_directive (namespace_reference);
							if (null == ns.prefix) {
								prefixes_namespaces.set ("", uri_definition[0]); 
							} else {
								prefixes_namespaces.set (ns.prefix, uri_definition[0]); 
							}
						}
					}
					
					Class clazz = lookup_class (prefix_to_namespace (prefix), localname);
					if (clazz == null) {
 						Report.error ( source_reference, "%s not a class".printf (localname));
						stop_parsing (); 
						return;
					}

					this.root_class_definition = get_root_definition (clazz, attrs, prefix);
															
					if (Report.get_errors() > 0)  {
						stop_parsing ();
						return;
					}

					states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, root_class_definition));
					break;
				}
			case StateId.SAX_PARSER_CONTAINER_STATE:	
				{
					
					Class clazz = lookup_class (prefix_to_namespace (prefix), localname);
					string fqan;
					
					if (clazz != null) { //this is a member/container child object
						ClassDefinition class_definition = get_child_for_container (clazz, state.class_definition, attrs, prefix);
						states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, class_definition));
					} else { //no class with this name found, assume it's an attribute
						ClassDefinition attribute_parent_class_definition = state.class_definition;
						if (prefix != null) 
							fqan = prefix + "." + localname;
						else 
							fqan = localname;
						states.push (new State (StateId.SAX_PARSER_ATTRIBUTE_STATE, attribute_parent_class_definition, null, fqan));
					}
					if (Report.get_errors() > 0)  {
						stop_parsing ();
						return;
					}
					break;
				}
			case StateId.SAX_PARSER_ATTRIBUTE_STATE:
				{
					//a tag found within an attribute state switches us to container_state
					
					if (state.attribute != null) { //this was created by non-discardable text nodes
						Report.error (source_reference, "Incorrect attribute definition for %s".printf (state.attribute_name));
						stop_parsing ();
						return;
					}
					
					Class clazz = lookup_class (prefix_to_namespace (prefix), localname);
					
					ClassDefinition attribute_value_definition;
					if (clazz != null) { //this is a member/container child object
						attribute_value_definition = get_child_for_container (clazz, null, attrs, prefix);
					} else {
						Report.error (source_reference, "No class %s found".printf (localname));
					}
					ComplexAttribute attr = new ComplexAttribute (strip_attribute_hyphens (state.attribute_name), attribute_value_definition);
					
					//add the attribute into the parent container
					state.class_definition.add_attribute (attr);		
					
					if (Report.get_errors() > 0)  {
						stop_parsing ();
						return;
					}
					states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, attribute_value_definition));
					break;
				}
			default:
				Report.error( source_reference, "Invalid Gtkaml SAX Parser state");
				stop_parsing(); 
				return;
		}
		
	}
	
	public void characters (string data, int len)
	{
		State state = states.peek ();
		string value = data.ndup (len);
		string stripped_value = value; stripped_value.strip ();
		
		if (stripped_value != "") {
			parse_attribute_content_as_text (state, value);
		}
	}
	
	public void end_element (string localname, string prefix, string URI)
	{
		states.pop();
	}
	
	public void cdata_block (string cdata, int len)
	{
		State state = states.peek ();
		if (state.state_id != StateId.SAX_PARSER_INITIAL_STATE){
			State previous_state = states.peek (1);
			if (previous_state.state_id == StateId.SAX_PARSER_INITIAL_STATE) {
				RootClassDefinition root_class = state.class_definition as RootClassDefinition;
				if (root_class.original_first_code_line < 0) {
					root_class.original_first_code_line = line_number ();
				}
				root_class.code.add (cdata.ndup (len));
			} else {
				parse_attribute_content_as_text (state, cdata.ndup (len));
			}
		} 
	}

	private void parse_attribute_content_as_text (State! state, string content)
	{
		if (state.state_id == StateId.SAX_PARSER_ATTRIBUTE_STATE) {
			if (state.attribute_name == gtkaml_prefix+".preconstruct") {
				if (state.class_definition.preconstruct_code != null) {
					Report.error (create_source_reference (), "A preconstruct attribute already exists for %s".printf (state.class_definition.identifier));
					stop_parsing ();
					return;
				}
				state.class_definition.preconstruct_code = content;
			} else if (state.attribute_name == gtkaml_prefix+".construct") {
				if (state.class_definition.construct_code != null) {
					Report.error (create_source_reference (), "A construct attribute already exists for %s".printf (state.class_definition.identifier));
					stop_parsing ();
					return;
				}
				state.class_definition.construct_code = content;
			} else {
				if (state.attribute == null) {
					state.attribute = new SimpleAttribute (strip_attribute_hyphens (state.attribute_name), content);
					state.class_definition.add_attribute (state.attribute);
				} else {
					if (state.attribute is SimpleAttribute) {
						(state.attribute as SimpleAttribute).value += "\n" + content;
					} else {
						Report.error (create_source_reference (), "Cannot mix a complex attribute definition with simple values like this: attribute %s".printf (state.attribute.name));
						stop_parsing ();
						return;
					}
				}
			}
		} else {
			Report.error (create_source_reference (), "Invalid non-whitespace text found");
			stop_parsing ();
			return;
		}
	}
	private string prefix_to_namespace (string prefix)
	{
		if (prefix==null)
			return prefixes_namespaces.get ("");		
		return prefixes_namespaces.get (prefix);		
	}
	
	public SourceReference create_source_reference () {
		return new SourceReference (source_file, line_number (), column_number (), line_number (), column_number ()); 
	}
	
	private Class lookup_class (string xmlNamespace, string name)
	{
		foreach (Vala.Namespace ns in context.root.get_namespaces ()) {
			if ( (ns.name == null && xmlNamespace == null ) || (ns.name != null && xmlNamespace != null && ns.name == xmlNamespace)) {
				Symbol s = ns.scope.lookup (name);
				if (s is Class) {
					return (s as Class);
				}
			}
		}
		return null;
	}

	private string strip_attribute_hyphens (string! attrname)
	{
		//see TDWTF, "The Hard Way"
		var tokens = attrname.split ("-");
		return string.joinv ("_", tokens);
	}

	public RootClassDefinition get_root_definition (Class clazz, Gee.List<XmlAttribute> attrs, string prefix)
	{
		RootClassDefinition root_class_definition = new Gtkaml.RootClassDefinition (create_source_reference (), "this", prefix_to_namespace (prefix),  clazz, DefinitionScope.MAIN_CLASS);
		root_class_definition.prefixes_namespaces = prefixes_namespaces;
		foreach (XmlAttribute attr in attrs) {
			if (attr.prefix != null)
			{ 
				if (attr.prefix == gtkaml_prefix) {
					switch (attr.localname) {
						case "public":
						case "name":
							if (root_class_definition.target_name != null) {
								Report.error (create_source_reference (), "A name for the class already exists ('%s')".printf (root_class_definition.target_name));
								stop_parsing ();
								return null;
							}
							root_class_definition.target_name = attr.value;
							break;
						case "namespace":
							root_class_definition.target_namespace = attr.value;
							break;
						case "private":
							Report.error (create_source_reference (), "'private' not allowed on root tag.");
							stop_parsing ();
							return null;
							break;
						case "construct":
							if (root_class_definition.construct_code != null) {
								Report.error (create_source_reference (), "A construct attribute already exists for the root class");
								stop_parsing ();
								return null;
							}
							root_class_definition.construct_code = attr.value;
							break;
						case "preconstruct":
							if (root_class_definition.preconstruct_code != null) {
								Report.error (create_source_reference (), "A preconstruct attribute already exists for the root class");
								stop_parsing ();
								return null;
							}
							root_class_definition.preconstruct_code = attr.value;
							break;
						case "implements":
							var implementsv = attr.value.split (",");
							for (int i = 0; implementsv[i]!=null; i++)
								implementsv[i].strip ();
							root_class_definition.implements = string.joinv (", ", implementsv);
							break;
						default:
							Report.warning (create_source_reference (), "Unknown gtkaml attribute '%s'.".printf (attr.localname));
							break;
					}
				} else  {
					Report.error (create_source_reference (), "'%s' is the only allowed prefix for attributes. Other attributes must be left unprefixed".printf (gtkaml_prefix));
					stop_parsing ();
					return null;
				}
			} else {
				var simple_attribute = new SimpleAttribute (strip_attribute_hyphens (attr.localname), attr.value);
				root_class_definition.add_attribute (simple_attribute);
			}
		}
		
		if (root_class_definition.target_name == null) {
			Report.error (create_source_reference (), "No class name specified: use %s:name for this".printf (gtkaml_prefix));
		}
		return root_class_definition;
	}
	
	public ClassDefinition get_child_for_container (Class clazz, ClassDefinition! container_definition, Gee.List<XmlAttribute> attrs, string prefix)
	{
		string identifier = null;
		DefinitionScope identifier_scope = DefinitionScope.CONSTRUCTOR;
		string reference = null;
		string construct_code = null;
		string preconstruct_code = null;
		ClassDefinition parent_container = container_definition;

		foreach (XmlAttribute attr in attrs) {
			if (attr.prefix!=null && attr.prefix==gtkaml_prefix) {
				if ((attr.localname=="public" || attr.localname=="private")) {
					if (identifier!=null) {
						Report.error (create_source_reference (), "Cannot have multiple identifier names:%s".printf(attr.localname));
						stop_parsing (); return null;
					}
					identifier = attr.value;
					if (attr.localname == "public") {
						identifier_scope = DefinitionScope.PUBLIC;
					} else {
						identifier_scope = DefinitionScope.PRIVATE;
					}
				} else if (attr.localname=="existing") {
					reference = attr.value;
				} else if (attr.localname=="construct") {
					construct_code = attr.value;
				} else if (attr.localname=="preconstruct") {
					preconstruct_code = attr.value;
				} else if (attr.localname=="standalone") {
					if (attr.value == "true") {
						parent_container = null;
					} else {
						Report.error (create_source_reference (), "Invalid 'standalone' value");
						stop_parsing ();
					}
				} else {
					Report.error (create_source_reference (), "Unkown gtkaml attribute '%s'".printf (attr.localname));
					stop_parsing ();
				}
			} else if (attr.prefix != null) {
				Report.error (create_source_reference (), "%s is the only allowed prefix for attributes. Other attributes must be left unprefixed".printf (gtkaml_prefix));
				stop_parsing ();
			}
		}
		
		if (identifier != null && reference != null) {
			Report.error (create_source_reference (), "Cannot specify both existing and a new identifier name");
			stop_parsing ();
		}
		
		ClassDefinition class_definition=null;
		if (reference == null) {
			int counter = 0;
			if (identifier == null) {
				//generate a name for the identifier
				identifier = clazz.name.down (clazz.name.len ());
				if (generated_identifiers_counter.contains (identifier)) {
					counter = generated_identifiers_counter.get (identifier);
				}
				identifier = "_%s%d".printf (identifier, counter);
				counter++;
				generated_identifiers_counter.set (clazz.name.down (clazz.name.len ()), counter);
			}

			class_definition = new ClassDefinition (create_source_reference (), identifier, prefix_to_namespace (prefix), clazz, identifier_scope, parent_container);
			class_definition.construct_code = construct_code;
			class_definition.preconstruct_code = preconstruct_code;
		} else {
			if (construct_code != null || preconstruct_code != null) {
				Report.error (create_source_reference (), "Cannot specify 'construct' or 'preconstruct' code for references");
				stop_parsing ();
			}
			class_definition = new ReferenceClassDefinition (create_source_reference (), reference, prefix_to_namespace (prefix), clazz, parent_container);
			/* now post-process the reference FIXME put this in code generator or something*/
			string reference_stripped = reference; 
			reference_stripped.strip ();
			if (reference_stripped.has_prefix ("{")) {
				if (reference_stripped.has_suffix ("}"))
				{
					class_definition.identifier = reference_stripped.substring (1, reference_stripped.len () -2 );
				} else {
					Report.error (create_source_reference (), "'existing' attribute not properly ended");
				}
			} else {
				class_definition.identifier = "(%s as %s)".printf (reference, class_definition.base_full_name);
			}
		}
		
		if (container_definition != null)
			container_definition.add_child (class_definition);
			
		foreach (XmlAttribute attr in attrs) {
			if (attr.prefix == null) {
				var simple_attribute = new SimpleAttribute (strip_attribute_hyphens (attr.localname), attr.value);
				class_definition.add_attribute (simple_attribute);
			}
		}
		return class_definition;
	}
	
	
	[NoArrayLength]
	private Gee.List<XmlAttribute> parse_attributes (string[] attributes, int nb_attributes)
	{	
		int walker = 0;
		string end;
		var attribute_list = new Gee.ArrayList<XmlAttribute> ();
		for (int i = 0; i < nb_attributes; i++)
		{
			var attr = new XmlAttribute ();
			attr.localname = attributes[walker];
			attr.prefix = attributes[walker+1];
			attr.URI = attributes[walker+2];
			attr.value = attributes[walker+3];
			end = attributes[walker+4];
			attr.value = attr.value.ndup (attr.value.len () - end.len () );
			attribute_list.add (attr);
			walker += 5;
		}
		return attribute_list;
	}
	
	[NoArrayLength]
	private Gee.List<XmlNamespace> parse_namespaces (string[] namespaces, int nb_namespaces)
	{
		int walker = 0;
		var namespace_list = new Gee.ArrayList<XmlNamespace> ();
		for (int i = 0; i < nb_namespaces; i++) 
		{
			var ns = new XmlNamespace ();
			ns.prefix = namespaces[walker];
			ns.URI = namespaces[walker+1];
			if (ns.URI != null && ns.URI.has_prefix ("http://gtkaml.org/")) {
				if (ns.prefix != null) {
					gtkaml_prefix = ns.prefix;
					string version = ns.URI.substring ("http://gtkaml.org/".len (), ns.URI.len () - "http://gtkaml.org/".len ());
					if (version > Config.PACKAGE_VERSION) {
						Report.warning (create_source_reference (), "Source file version (%s) newer than gtkaml compiler version (%s)".printf (version, Config.PACKAGE_VERSION));
					}
				} else {
					Report.error (create_source_reference (), "You cannot use the gtkaml namespace as default namespace");
				}
			}
			namespace_list.add (ns);
			walker += 2;
		}
		return namespace_list;
	}

}
