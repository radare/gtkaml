#include "GtkamlSAXParser.h"
#include <libxml/parser.h>

void gtkaml_sax_parser_error (GtkamlSAXParser * self, char * message, ...)
{
	va_list args;
	gchar * output;
	
	int errno = ((xmlParserCtxtPtr)self->xmlCtxt)->errNo;
	
	if (errno == XML_ERR_DOCUMENT_EMPTY)
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
	saxHandler->cdataBlock = (cdataBlockSAXFunc)gtkaml_sax_parser_cdata;
	saxHandler->initialized = XML_SAX2_MAGIC;
	
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
