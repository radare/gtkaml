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

#include "gtkaml-codegenerator.h"

/** 
 * returns directly a strdup of the attribute's value or 0. caller has to release it
 */
GString * gtkaml_get_attribute( const gchar * attribute_name, int nb_attributes, const gchar ** attrs )
{
	guint walker = 0, i;
	for (i = 0; i < nb_attributes; ++i, walker += 5) {
		/** @todo to get rid of strcmp? */
		if ( 0 == strcmp( attrs[walker], attribute_name ) ) {
			return g_string_new( attrs[walker + 3] );
		}
	}
	return 0;
}

void gtkaml_generator_init( GtkamlSaxParserUserData * data )
{
	data->parserResult.class_start = g_string_new(0);
	data->parserResult.members_declaration = g_string_new(0);
	data->parserResult.construct_body = g_string_new("\tconstruct {\n");
	data->parserResult.class_end = g_string_new(0);
	data->parserResult.code = g_string_new(0);
}	

void gtkaml_generate_class( GtkamlSaxParserUserData * data, gchar* name )
{
	g_string_append_printf( data->parserResult.class_start, "public class Generated : %s {\n", name );
}

void gtkaml_generate_member( GtkamlSaxParserUserData * data, const gchar * name, int nb_attributes,  const gchar ** attrs )
{
	GtkamlState * state = g_list_last( data->state_stack)->data;
	GString* identifier = 0;
	guint * pidentifier_number = 0;

	if (! (identifier = gtkaml_get_attribute( "id", nb_attributes, attrs )) ) {
		/* generate the next identifier in list */
		if ( !( pidentifier_number = g_hash_table_lookup( data->identifiers, name ) ) ) {
			pidentifier_number = g_new0( guint, 1 );
			g_hash_table_insert( data->identifiers, g_strdup((gchar*)name), pidentifier_number );
		}
		identifier = g_string_new(0);
		g_string_append_printf( identifier, "_%s%d", name, *pidentifier_number );
		identifier->str[1] = g_ascii_tolower( identifier->str[1] );
		(*pidentifier_number)++;
	}
	g_string_append_printf( data->parserResult.members_declaration, "\tprivate %s %s;\n", (gchar*)name, identifier->str );  
	g_string_append_printf( data->parserResult.construct_body, "\t\t%s = new %s();\n", identifier->str, (gchar*)name );
	g_string_append_printf( data->parserResult.construct_body, "\t\t%s.add( %s );\n", 
						   state->current_container, identifier->str );
	g_string_free( identifier, TRUE );
}

void gtkaml_generator_cleanup( GtkamlSaxParserResult parserResult )
{
	g_string_free(parserResult.class_start, TRUE);
	g_string_free(parserResult.members_declaration, TRUE);
	g_string_free(parserResult.construct_body, TRUE);
	g_string_free(parserResult.class_end, TRUE);
	g_string_free(parserResult.code, TRUE);
}
