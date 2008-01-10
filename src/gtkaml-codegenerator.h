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
 

#ifndef GTKAML_CODEGENERATOR_H
#define GTKAML_CODEGENERATOR_H

#include <glib.h>
#include "gtkaml-saxparser.h"

GString * gtkaml_get_attribute( const gchar * attribute_name, int nb_attributes, const gchar ** attrs );

void gtkaml_generator_init( GtkamlSaxParserUserData * data );

void gtkaml_generate_class( GtkamlSaxParserUserData * data, gchar* name );

void gtkaml_generate_member( GtkamlSaxParserUserData * data, const gchar * name, int nb_attributes, const gchar ** attrs );

void gtkaml_generator_cleanup( GtkamlSaxParserResult parserResult );
#endif
