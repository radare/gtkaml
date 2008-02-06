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
	GtkamlDummyParser.vala

gtkamlc_SOURCES = \
	gtkamlc.vala.stamp \
	$(gtkamlc_VALASOURCES:.vala=.c) \
	$(gtkamlc_VALASOURCES:.vala=.h) \
	GtkamlParser_resume_parsing.c \
	GtkamlSAXParser_start_parsing.c

gtkamlc.vala.stamp: $(gtkamlc_VALASOURCES)
	$(VALAC) $(VALAFLAGS) --vapidir=../vapi --pkg config --pkg libxml-2.0 --pkg vala-1.0 $^ 
	sed 's/GTKAML_DUMMY/VALA_CODE_VISITOR/g' < GtkamlParser.c > GtkamlParser.c.ed
	mv -f GtkamlParser.c.ed GtkamlParser.c
	sed 's/\tGtkamlDummy/\tValaParser/g' < GtkamlParser.h > GtkamlParser.h.ed
	mv -f GtkamlParser.h.ed GtkamlParser.h
	touch $@

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(VALA_LIBS)

EXTRA_DIST = $(gtkamlc_VALASOURCES)
