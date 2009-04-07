/* GtkamlSAXParser_start_parsing.c
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

#include <glib.h>
#include <glib-object.h>
#include "gtkamlc.h"
#include <libxml/parser.h>


void gtkaml_sax_parser_error (GtkamlSAXParser * self, char * message, ...)
{
	va_list args;
	gchar * output;
	
	int errNo = ((xmlParserCtxtPtr)self->xmlCtxt)->errNo;
	
	if (errNo == XML_ERR_DOCUMENT_EMPTY)
		return;
	
	va_start (args, message);
	g_vasprintf (&output, message, args);
	va_end (args);
	vala_report_error (gtkaml_sax_parser_create_source_reference (self), output);
	g_free (output);
	
	xmlStopParser (self->xmlCtxt);
}


void gtkaml_sax_parser_start_parsing (GtkamlSAXParser * self, const char* contents, gulong length)
{
	xmlSAXHandler *saxHandler;
		
	saxHandler = g_new0 (xmlSAXHandler, 1);
	saxHandler->startElementNs = (startElementNsSAX2Func)gtkaml_sax_parser_start_element;
	saxHandler->endElementNs = (endElementNsSAX2Func)gtkaml_sax_parser_end_element;
	saxHandler->cdataBlock = (cdataBlockSAXFunc)gtkaml_sax_parser_cdata_block;
	saxHandler->error = (errorSAXFunc)gtkaml_sax_parser_error;
	saxHandler->initialized = XML_SAX2_MAGIC;
	saxHandler->characters = (charactersSAXFunc)gtkaml_sax_parser_characters;
	
	self->xmlCtxt = xmlCreatePushParserCtxt (saxHandler, self, contents, 0, NULL);
	xmlParseChunk ((xmlParserCtxtPtr)self->xmlCtxt, contents, length, -1);
	//xmlSAXParseDoc ( saxHandler, contents, 0 );
	
	xmlSubstituteEntitiesDefault (1);
	xmlParseDocument ((xmlParserCtxtPtr)self->xmlCtxt);

	//xmlFreeParserCtxt ((xmlParserCtxtPtr)self->xmlCtxt);
	g_free (saxHandler);
}

void gtkaml_sax_parser_stop_parsing (GtkamlSAXParser * self)
{
	xmlStopParser(self->xmlCtxt);
}

int gtkaml_sax_parser_column_number (GtkamlSAXParser * self)
{
	return xmlSAX2GetColumnNumber (self->xmlCtxt);
}

int gtkaml_sax_parser_line_number (GtkamlSAXParser * self)
{
	return xmlSAX2GetLineNumber (self->xmlCtxt);
}
