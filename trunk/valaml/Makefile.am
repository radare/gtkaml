INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	-Wall \
	-g \
	$(LIBXML2_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(VALA_CFLAGS)


bin_PROGRAMS = valamlc 

BUILT_SOURCES = valamlc.vala.stamp

valamlc_VALASOURCES = \
	GtkamlCompiler.vala \
	GtkamlSAXParser.vala \
	GtkamlParser.vala \
	GtkamlCodeGenerator.vala \
	GtkamlXmlNamespace.vala \
	GtkamlXmlAttribute.vala \
	GtkamlState.vala \
	GtkamlStateStack.vala \
	GtkamlClassDefinition.vala \
	GtkamlContainerDefinition.vala \
	GtkamlAttribute.vala \
	GtkamlSimpleAttribute.vala \
	GtkamlComplexAttribute.vala \
	GtkamlMethod.vala \
	GtkamlDummyParser.vala

valamlc_SOURCES = \
	valamlc.vala.stamp \
	$(valamlc_VALASOURCES:.vala=.c) \
	$(valamlc_VALASOURCES:.vala=.h) \
	GtkamlParser_resume_parsing.c \
	GtkamlSAXParser_start_parsing.c

valamlc.vala.stamp: $(valamlc_VALASOURCES)
	$(VALAC) $(VALAFLAGS) --pkg libxml-2.0 --pkg vala-1.0 $^ 
	sed 's/GTKAML_DUMMY/VALA_CODE_VISITOR/g' < GtkamlParser.c > GtkamlParser.c.ed
	mv -f GtkamlParser.c.ed GtkamlParser.c
	sed 's/\tGtkamlDummy/\tValaParser/g' < GtkamlParser.h > GtkamlParser.h.ed
	mv -f GtkamlParser.h.ed GtkamlParser.h
	touch $@

valamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(VALA_LIBS)
