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
 
#ifndef _GTKAML_SAXPARSER_H
#define _GTKAML_SAXPARSER_H

#include <libxml/parser.h>
#include <glib.h>
#include <string.h>

typedef enum GtkamlSaxState { 
	GTKAML_CLASS_STATE = 0,         /* here we generate the class declaration */
	GTKAML_CONTAINER_STATE,  		/* then we can add things to the current container */
	GTKAML_NONCONTAINER_STATE,
	GTKAML_SCRIPT_STATE,			/* the CDATA is then pasted */
	GTKAML_ATTRIBUTE_STATE,  		/* the characters are then used as value */
} GtkamlSaxState;

typedef struct GtkamlSaxParserResult {
	GString * class_start;
	GString * members_declaration;
	GString * construct_body;
	GString * class_end;
	GString * code;
} GtkamlSaxParserResult;

typedef struct GtkamlState {
	GtkamlSaxState current_state;
	gchar * current_container;
} GtkamlState;

typedef struct GtkamlSaxParserUserData {
	GtkamlSaxParserResult parserResult;
	GList * state_stack;
	gchar * attribute_name;
	GHashTable * identifiers;
} GtkamlSaxParserUserData;

GString * gtkaml_parse_test( gchar * gtkaml, int size );
GString * gtkaml_parse_sax2_test( gchar * gtkaml, int size );

#endif /* _GTKAML_SAXPARSER_H */

 
