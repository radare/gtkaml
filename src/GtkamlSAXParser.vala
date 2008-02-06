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
	private CodeContext context {get;set;}
	private SourceFile source_file {get;set;}
	private StateStack states {get;set;}
	private Map<string,int> generated_identifiers_counter = new HashMap<string,int> (str_hash, str_equal);
	private Collection<string> used_identifiers = new ArrayList<string> (str_equal);
	private Gtkaml.CodeGenerator code_generator {get;set;}	
	/** prefix/vala.namespace pair */
	private Gee.Map<string,string> prefixes_namespaces {get;set;}

	private Gtkaml.RootClassDefinition root_class_definition {get;set;}	
	public string gtkaml_prefix="gtkaml";
	
	
	public SAXParser( construct Vala.CodeContext context, construct Vala.SourceFile source_file) {
		
	}
	
	construct {
		states = new StateStack ();	
		prefixes_namespaces = new Gee.HashMap<string,string> (str_hash, str_equal, str_equal);
		root_class_definition = null;
		code_generator = new Gtkaml.CodeGenerator (context);
	}
	
	public virtual string parse ()
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

		if (Report.get_errors() != 0)
			return null;

		var implicitsResolver = new ImplicitsResolver (context, "key-file-name"); 
		implicitsResolver.resolve (root_class_definition);
		
		if (Report.get_errors() != 0)
			return null;

		
		code_generator.generate (root_class_definition);

		if (Report.get_errors() != 0)
			return null;
		
		return code_generator.yield ();
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
					
					if (clazz != null) { //this is a member/container child object
						ClassDefinition class_definition = get_child_for_container (clazz, state.class_definition, attrs, prefix);
						states.push (new State (StateId.SAX_PARSER_CONTAINER_STATE, class_definition));
					} else { //no class with this name found, assume it's an attribute
						ClassDefinition attribute_parent_class_definition = state.class_definition;
						states.push (new State (StateId.SAX_PARSER_ATTRIBUTE_STATE, attribute_parent_class_definition, null, localname));
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
					ComplexAttribute attr = new ComplexAttribute (state.attribute_name, attribute_value_definition);
					
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
			if (state.state_id == StateId.SAX_PARSER_ATTRIBUTE_STATE) {
				if (state.attribute == null) {
					state.attribute = new SimpleAttribute (state.attribute_name, value);
					state.class_definition.add_attribute (state.attribute);
				} else {
					if (state.attribute is SimpleAttribute) {
						(state.attribute as SimpleAttribute).value += "\n" + value;
					} else {
						Report.error (create_source_reference (), "Cannot mix a complex attribute definition with simple values like this: attribute %s".printf (state.attribute.name));
						stop_parsing ();
						return;
					}
				}
			}
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
				code_generator.add_code (cdata.ndup (len));
			} else {
				if (state.state_id == StateId.SAX_PARSER_ATTRIBUTE_STATE) {
					if (state.attribute == null) {
						state.attribute = new SimpleAttribute (state.attribute_name, cdata.ndup (len));
						state.class_definition.add_attribute (state.attribute);
					} else {
						if (state.attribute is SimpleAttribute) {
							(state.attribute as SimpleAttribute).value += "\n" + cdata.ndup (len);
						} else {
							Report.error (create_source_reference (), "Cannot mix a complex attribute definition with simple values like this: attribute %s".printf (state.attribute.name));
							stop_parsing ();
							return;
						}
					}
				}
			}
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

	public RootClassDefinition get_root_definition (Class clazz, Gee.List<XmlAttribute> attrs, string prefix)
	{
		RootClassDefinition root_class_definition = new Gtkaml.RootClassDefinition (create_source_reference (), "this", prefix_to_namespace (prefix),  clazz, DefinitionScope.MAIN_CLASS);
		root_class_definition.prefixes_namespaces = prefixes_namespaces;
		foreach (XmlAttribute attr in attrs) {
			if (attr.prefix != null)
			{ 
				if (attr.prefix == gtkaml_prefix) {
					switch (attr.localname) {
						case "name":
							root_class_definition.target_name = attr.value;
							break;
						case "namespace":
							root_class_definition.target_namespace = attr.value;
							break;
						case "public":
						case "private":
							Report.error (create_source_reference (), "public or private not allowed on root tag");
							break;
						default:
							Report.warning (create_source_reference (), "Unknown gtkaml attribute %s".printf (attr.localname));
							break;
					}
				}
			} else {
				var simple_attribute = new SimpleAttribute (attr.localname, attr.value);
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
				} if (attr.localname=="reference") {
					reference = attr.value;
				}
			}
		}
		
		if (identifier != null && reference != null) {
			Report.error (create_source_reference (), "Cannot specify both reference and a new identifier name");
			stop_parsing ();
			return null;
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

			class_definition = new ClassDefinition (create_source_reference (), identifier, prefix_to_namespace (prefix), clazz, identifier_scope, container_definition);
		} else {
			class_definition = new ReferenceClassDefinition (create_source_reference (), reference, prefix_to_namespace (prefix), clazz, container_definition);
		}

		foreach (XmlAttribute attr in attrs) {
			if (attr.prefix == null) {
				var simple_attribute = new SimpleAttribute (attr.localname, attr.value);
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
