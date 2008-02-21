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
	GtkamlImplicitsStore.vala \
	GtkamlDummyParser.vala

gtkamlc_SOURCES = \
	gtkamlc.vala.stamp \
	$(gtkamlc_VALASOURCES:.vala=.c) \
	$(gtkamlc_VALASOURCES:.vala=.h) \
	GtkamlSAXParser_start_parsing.c

gtkamlc.vala.stamp: $(gtkamlc_VALASOURCES)
	$(VALAC) $(VALAFLAGS) --vapidir=../vapi --pkg config --pkg libxml-2.0 --pkg vala-1.0 $^ 
	sed -e 's/GTKAML_DUMMY_CLASS (klass)/VALA_CODE_VISITOR_CLASS (klass)/g' \
		-e 's/GTKAML_DUMMY_CLASS (gtkaml_parser_parent_class)/VALA_CODE_VISITOR_CLASS (gtkaml_parser_parent_class)/g' \
		-e 's/GTKAML_DUMMY/VALA_PARSER/g' \
		-e 's/GTKAML_TYPE_DUMMY/VALA_TYPE_PARSER/g' \
		-e 's/GtkamlDummy/ValaParser/g' < GtkamlParser.c > GtkamlParser.c.ed
	mv -f GtkamlParser.c.ed GtkamlParser.c
	sed -e 's/GtkamlDummy /ValaParser /g' -e 's/GtkamlDummyClass/ValaParserClass/g'< GtkamlParser.h > GtkamlParser.h.ed
	mv -f GtkamlParser.h.ed GtkamlParser.h
	touch $@

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(VALA_LIBS)

EXTRA_DIST = $(gtkamlc_VALASOURCES)
