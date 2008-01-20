/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
 */

#include "gtkaml-saxparser.h"
#include "gtkaml-codegenerator.h"



/** 
 * @defgroup statestack manages the stack of states 
 * @{
 */
void gtkaml_state_push( GList ** state_stack,  gchar * current_identifier, ValaClass* base_class , GtkamlSaxState current_state )
{
	GtkamlState * new_state = g_new0(GtkamlState, 1);
	new_state->current_state = current_state;
	new_state->current_identifier = current_identifier;
	new_state->current_base_class = base_class;
	*state_stack = g_list_append( *state_stack, new_state );
}

void gtkaml_state_pop( GList ** state_stack )
{
	GtkamlState * popped_state = g_list_last( *state_stack )->data;
	*state_stack = g_list_remove( *state_stack, popped_state );
	g_object_unref(popped_state->current_base_class);
	g_free(popped_state->current_identifier);
	g_free(popped_state);
}


/** 
 * @}
 *
 * @defgroup saxcallbacks libxml2 sax callbacks
 * @{ 
 */
void gtkamlStartDocument ( GtkamlSaxParserUserData * data  )
{
	gtkaml_generator_init( data );
	gtkaml_state_push( &data->state_stack, 0, 0, GTKAML_CLASS_STATE );
	data->attribute_name = 0;
	data->identifiers = g_hash_table_new_full( g_str_hash, g_str_equal, (GDestroyNotify)g_free, (GDestroyNotify)g_free );
}


void gtkamlCdataBlock ( GtkamlSaxParserUserData * data , const xmlChar * cdata, int len )
{
	GtkamlState * state = g_list_last( data->state_stack )->data;
	GtkamlState * previous_state;
	switch (state->current_state) {
		case GTKAML_CONTAINER_STATE:
			/* vala code is contained in CDATA sections in the root container */
			previous_state = g_list_previous( g_list_last( data->state_stack ) )->data;
			if (previous_state->current_state == GTKAML_CLASS_STATE)
			{
				g_string_append( data->parserResult.code, "\n" );
				g_string_append_len( data->parserResult.code, (gchar*)cdata, len );
				g_string_append( data->parserResult.code, "\n" );
			}
			break;
		default:
			break;
	}
}

void gtkamlEndDocument ( GtkamlSaxParserUserData * data  )
{
	g_string_append( data->parserResult.construct_body, "\t}\n" );
	g_string_append( data->parserResult.class_end, "}\n" );
	g_hash_table_remove_all( data->identifiers );
	g_hash_table_destroy( data->identifiers );
	gtkaml_state_pop( &data->state_stack );
	g_list_free( data->state_stack );
}

void gtkamlStartElement ( GtkamlSaxParserUserData * data , const xmlChar *name, const xmlChar * prefix, 
                               const xmlChar * URI, 
                               int nb_namespaces, 
                               const xmlChar ** namespaces, 
                               int nb_attributes, 
                               int nb_defaulted, 
                               const xmlChar ** attrs )
{
	GtkamlState * state = g_list_last(data->state_stack)->data;
	ValaClass * base_class;
	
	switch (state->current_state) {
		/* NB: each case has to push a meaningful state */
		case GTKAML_CLASS_STATE: 
			//inspect packages
			vala_code_context_add_package(data->vala_context, "gtk+-2.0");
			//begin the class definition
			base_class = gtkaml_generator_new_class( data, g_strdup("Generated"), (gchar*)name );
			if (!base_class) {
				g_message("Class not found: %s", name);
				xmlStopParser((void*)data);
			}
			gtkaml_state_push( &data->state_stack, g_strdup("this"), base_class , GTKAML_CONTAINER_STATE );
			break;
		case GTKAML_CONTAINER_STATE:
			if ( g_ascii_isupper( (gchar)name[0] ) ) {
				gtkaml_generator_new_member( data, (gchar*)name, nb_attributes, (const gchar **) attrs );
				gtkaml_state_push( &data->state_stack, 0, 0, GTKAML_NONCONTAINER_STATE );
			} else {
				//else state push ( GTKAML_ATTRIBUTE_STATE )
				//fallback for characters() to determine attribute name
			}
			break;
		default:
			g_error("gtkaml parser in invalid state: startElement and %d", state->current_state);
			xmlStopParser((void*)data);
			break;
	}
	
}

void gtkamlEndElement ( GtkamlSaxParserUserData * data, const xmlChar *name, const xmlChar * prefix, 
                             const xmlChar * URI )
{
	gtkaml_state_pop( &data->state_stack );
}
/** @} */

static xmlSAXHandler gtkamlSaxParser = {
	0, //internalSubsetSAXFunc internalSubset;
    0, //isStandaloneSAXFunc isStandalone;
    0, //hasInternalSubsetSAXFunc hasInternalSubset;
    0, //hasExternalSubsetSAXFunc hasExternalSubset;
    0, //resolveEntitySAXFunc resolveEntity;
    0, //getEntitySAXFunc getEntity;
    0, //entityDeclSAXFunc entityDecl;
    0, //notationDeclSAXFunc notationDecl;
    0, //attributeDeclSAXFunc attributeDecl;
    0, //elementDeclSAXFunc elementDecl;
    0, //unparsedEntityDeclSAXFunc unparsedEntityDecl;
    0, //setDocumentLocatorSAXFunc setDocumentLocator;
    (startDocumentSAXFunc)gtkamlStartDocument, //startDocumentSAXFunc startDocument;
    (endDocumentSAXFunc)gtkamlEndDocument, //endDocumentSAXFunc endDocument;
    0, //(startElementSAXFunc)gtkamlStartElement, //startElementSAXFunc startElement;
    0, //(endElementSAXFunc)gtkamlEndElement, //endElementSAXFunc endElement;
    0, //referenceSAXFunc reference;
    0, //charactersSAXFunc characters;
    0, //ignorableWhitespaceSAXFunc ignorableWhitespace;
    0, //processingInstructionSAXFunc processingInstruction;
    0, //commentSAXFunc comment;
    0, //warningSAXFunc warning;
    0, //errorSAXFunc error;
    0, //fatalErrorSAXFunc fatalError;
	//SAX2?
    0, //getParameterEntitySAXFunc	getParameterEntity
    (cdataBlockSAXFunc)gtkamlCdataBlock, //cdataBlockSAXFunc	cdataBlock
    0, //externalSubsetSAXFunc	externalSubset
    0, //unsigned int	initialized	: The following fields are extensions ava
    0, //void *	_private
    (startElementNsSAX2Func)gtkamlStartElement, //startElementNsSAX2Func	startElementNs
    (endElementNsSAX2Func)gtkamlEndElement, //endElementNsSAX2Func	endElementNs
    0, //xmlStructuredErrorFunc	serror	
};

GString * gtkaml_parse_test( gchar * gtkaml, int size )
{
	GtkamlSaxParserUserData * user_data = g_new0( GtkamlSaxParserUserData, 1 );
	GString * vala = g_string_new("");
	int result = xmlSAXUserParseMemory( &gtkamlSaxParser, user_data, gtkaml, size );
	if ( result  ) {
		g_error( xmlLastError.message );
		return 0;
	}
	g_string_append(vala, user_data->parserResult.class_start->str );
	g_string_append(vala, user_data->parserResult.members_declaration->str );
	g_string_append(vala, user_data->parserResult.code->str );
	g_string_append(vala, user_data->parserResult.construct_body->str );
	g_string_append(vala, user_data->parserResult.class_end->str );
	
	gtkaml_generator_cleanup( user_data->parserResult );
	g_free( user_data );
	xmlCleanupParser();
	return vala;
}

GString * gtkaml_parser_sax2_test( gchar * gtkaml, gulong size, ValaCodeContext* vala_context )
{
	GtkamlSaxParserUserData * user_data = g_new0( GtkamlSaxParserUserData, 1 );
	
	GString * vala = g_string_new("");

	user_data->vala_context = vala_context;
	
	LIBXML_TEST_VERSION;
	//xmlSAXVersion( &gtkamlSaxParser, 2 );
	gtkamlSaxParser.initialized = XML_SAX2_MAGIC;
		
	xmlSubstituteEntitiesDefault(1);
	
	int result = xmlSAXUserParseMemory( &gtkamlSaxParser, user_data, gtkaml, size );
	if ( result  ) {
		g_error( xmlLastError.message );
		return 0;
	}
	g_string_append(vala, user_data->parserResult.class_start->str );
	g_string_append(vala, user_data->parserResult.members_declaration->str );
	g_string_append(vala, user_data->parserResult.code->str );
	g_string_append(vala, user_data->parserResult.construct_body->str );
	g_string_append(vala, user_data->parserResult.class_end->str );
	
	gtkaml_generator_cleanup( user_data->parserResult );
	g_free( user_data );
	xmlCleanupParser();
	return vala;
}
