INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = -I$(top_srcdir) \
	-Wall \
	-g \
	$(LIBXML2_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(VALA_CFLAGS) \
	-DPACKAGE_DATADIR=\"$(pkgdatadir)\"


bin_PROGRAMS = gtkamlc 

BUILT_SOURCES = gtkamlc.vala.stamp
CLEANFILES = gtkamlc.vala.stamp

gtkamlc_VALASOURCES = \
	GtkamlCompiler.vala \
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

gtkamlc_SOURCES = \
	gtkamlc.vala.stamp \
	$(gtkamlc_VALASOURCES:.vala=.c) \
	$(gtkamlc_VALASOURCES:.vala=.h) \
	GtkamlSAXParser_start_parsing.c

gtkamlc.vala.stamp: $(gtkamlc_VALASOURCES)
	$(VALAC) -C $(VALAFLAGS) --vapidir=../vapi --pkg config --pkg libxml-2.0 --pkg vala-1.0 $^ 
	touch $@

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(VALA_LIBS)

EXTRA_DIST = $(gtkamlc_VALASOURCES)
