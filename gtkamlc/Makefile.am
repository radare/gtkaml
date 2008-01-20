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


bin_PROGRAMS = gtkamlc 

BUILT_SOURCES = gtkamlc.vala.stamp

gtkaml_VALASOURCES = \
	GtkamlCompiler.vala \
	GtkamlSAXParser.vala \
	GtkamlCodeGenerator.vala \
	GtkamlDummyParser.vala

gtkamlc_SOURCES = \
	gtkaml.vala.stamp \
	$(gtkaml_VALASOURCES:.vala=.c) \
	$(gtkaml_VALASOURCES:.vala=.h) \
	GtkamlSAXParser_startParsing.c

gtkamlc.vala.stamp: $(gtkaml_VALASOURCES)
	$(VALAC) $(VALACFLAGS) --pkg libxml-2.0 --pkg vala-1.0 $^ 
	sed -i 's/GTKAML_DUMMY/VALA_CODE_VISITOR/g' GtkamlSAXParser.c
	sed -i 's/\tGtkamlDummy/\tValaParser/g' GtkamlSAXParser.h
	touch $@

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(VALA_LIBS)
