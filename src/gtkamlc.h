#ifndef GTKAMLC_H
#define GTKAMLC_H

#include <glib-object.h>
#include <vala.h>

G_BEGIN_DECLS

typedef struct _GtkamlSAXParser GtkamlSAXParser;

struct _GtkamlSAXParser {
	GObject parent_instance;
	gpointer priv;
	gpointer xmlCtxt;
};

ValaSourceReference *gtkaml_sax_parser_create_source_reference (GtkamlSAXParser *self);
void gtkaml_sax_parser_start_element (GtkamlSAXParser *self, const gchar *localname, const gchar *prefix, const gchar *uri, gint nb_namespaces, gchar **namespaces, gint nb_attributes, gint nb_defaulted, gchar **attributes);
void gtkaml_sax_parser_end_element (GtkamlSAXParser *self, const gchar *localname, const gchar *prefix, const gchar *uri);
void gtkaml_sax_parser_cdata_block (GtkamlSAXParser *self, const gchar *cdata, gint len);
void gtkaml_sax_parser_characters (GtkamlSAXParser *self, const gchar *data, gint len);

G_END_DECLS

#endif
