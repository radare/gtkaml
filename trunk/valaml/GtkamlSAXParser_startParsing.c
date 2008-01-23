#include "GtkamlSAXParser.h"
#include <libxml/parser.h>


void gtkaml_sax_parser_start_parsing( GtkamlSAXParser * self, const char* contents, gulong length )
{
	xmlSAXHandler *saxHandler;
	xmlParserCtxtPtr ctxt = (xmlParserCtxtPtr)self->xmlCtxt;
	
	saxHandler = g_new0 (xmlSAXHandler, 1);
	saxHandler->startElementNs = (startElementNsSAX2Func)gtkaml_sax_parser_start_element;
	saxHandler->endElementNs = (endElementNsSAX2Func)gtkaml_sax_parser_end_element;
	saxHandler->cdataBlock = (cdataBlockSAXFunc)gtkaml_sax_parser_cdata_block;
	saxHandler->initialized = XML_SAX2_MAGIC;
	
	ctxt = xmlCreatePushParserCtxt( saxHandler, self, contents, length, NULL );
	
	xmlSubstituteEntitiesDefault(1);
	xmlParseDocument (ctxt);

	xmlFreeParserCtxt (ctxt);
	g_free (saxHandler);
}

void gtkaml_sax_parser_stop_parsing( GtkamlSAXParser * self )
{
	xmlStopParser(self->xmlCtxt);
}
