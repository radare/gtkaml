## Process this file with automake to produce Makefile.in

## Created by Anjuta

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

BUILT_SOURCES = gtkaml.vala.stamp

gtkaml_VALASOURCES = \
	GtkamlCompiler.vala \
	GtkamlParser.vala

gtkamlc_SOURCES = \
	gtkaml.vala.stamp \
	$(gtkaml_VALASOURCES:.vala=.c) \
	$(gtkaml_VALASOURCES:.vala=.h) \
	gtkaml-saxparser.c   \
	gtkaml-saxparser.h   \
	gtkaml-codegenerator.c   \
	gtkaml-codegenerator.h 

gtkaml.vala.stamp: $(gtkaml_VALASOURCES)
	$(VALAC) $(VALACFLAGS) --pkg vala-1.0 $^ 
	touch $@

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS) \
	$(VALA_LIBS)

EXTRA_DIST = \
	gtkaml.in 
