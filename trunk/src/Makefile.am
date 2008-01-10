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
	 $(GLIB_CFLAGS)

bin_PROGRAMS = gtkamlc

gtkamlc_SOURCES = \
	main.c   \
	gtkaml-saxparser.c   \
	gtkaml-saxparser.h   \
	gtkaml-codegenerator.c   \
	gtkaml-codegenerator.h

gtkamlc_LDADD = \
	$(LIBXML2_LIBS)\
	$(GLIB_LIBS)

