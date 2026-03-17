#ifndef GTKAML_VALACCODEGEN_H
#define GTKAML_VALACCODEGEN_H

#include <glib-object.h>
#include <vala.h>

G_BEGIN_DECLS

typedef struct _ValaCCodeCompiler ValaCCodeCompiler;
typedef struct _ValaGDBusServerModule ValaGDBusServerModule;
typedef struct _ValaGIRWriter ValaGIRWriter;

GType vala_ccode_compiler_get_type (void) G_GNUC_CONST;
ValaCCodeCompiler *vala_ccode_compiler_new (void);
void vala_ccode_compiler_compile (ValaCCodeCompiler *self, ValaCodeContext *context, const gchar *cc_command, gchar **cc_options, gint cc_options_length1);

GType vala_gd_bus_server_module_get_type (void) G_GNUC_CONST;
ValaGDBusServerModule *vala_gd_bus_server_module_new (void);

GType vala_gir_writer_get_type (void) G_GNUC_CONST;
ValaGIRWriter *vala_gir_writer_new (void);
void vala_gir_writer_write_file (ValaGIRWriter *self, ValaCodeContext *context, const gchar *directory, const gchar *gir, const gchar *gir_namespace, const gchar *gir_version, const gchar *library);

G_END_DECLS

#endif
