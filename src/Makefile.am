INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = -I$(top_srcdir) \
	-Wall \
	-g \
	$(LIBXML2_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(VALA_CFLAGS) \
	-DPACKAGE_DATADIR=\"$(pkgdatadir)\"

if VALA_LATEST
        GTKAML_COMPILER = GtkamlCompiler.vala
else
        GTKAML_COMPILER = GtkamlCompiler-0.10.vala
endif


bin_PROGRAMS = gtkamlc 

BUILT_SOURCES = gtkamlc.vala.stamp
CLEANFILES = gtkamlc.vala.stamp


gtkamlc_VALASOURCES = \
	GtkonParser.vala \
	$(GTKAML_COMPILER) \
	GtkamlCodeContext.vala \
	GtkamlSAXParser.vala \
	GtkamlParser.vala \
	GtkamlCodeGenerator.vala \
	GtkamlXmlNamespace.vala \
	GtkamlXmlAttribute.vala \
	GtkamlState.vala \
	GtkamlStateStack.vala \
	GtkamlClassDefinition.vala \
	GtkamlRootClassDefinition.vala \
	GtkamlReferenceClassDefinition.vala \
	GtkamlAttribute.vala \
	GtkamlSimpleAttribute.vala \
	GtkamlComplexAttribute.vala \
	GtkamlMethod.vala \
	GtkamlImplicitsResolver.vala \
	GtkamlImplicitsStore.vala \
	GtkamlMethodMatcher.vala

nodist_gtkamlc_SOURCES = \
	gtkamlc.vala.stamp \
	$(gtkamlc_VALASOURCES:.vala=.c) \
	gtkamlc.h \
	GtkamlSAXParser_start_parsing.c

gtkamlc.vala.stamp: $(gtkamlc_VALASOURCES)
	$(VALAC) -h gtkamlc.h -C $(VALAFLAGS) --vapidir=$(top_srcdir)/vapi --pkg config --pkg gio-2.0 --pkg libxml-2.0 --pkg $(VALA_PKG) $^ 
	touch $@

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(GIO_LIBS) \
	$(VALA_LIBS)

EXTRA_DIST = $(gtkamlc_VALASOURCES) GtkamlSAXParser_start_parsing.c
