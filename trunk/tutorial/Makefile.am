#INCLUDES = \
#	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
#	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
#	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	 -Wall \
	 -g \
	 $(EXTRA_CFLAGS) \
	 $(GTK_CFLAGS)

#BUILT_SOURCES = test0.stamp test1.stamp
noinst_PROGRAMS = tutorial0


CLEANFILES = tutorial0.vala

## Example 0
tutorial0_GTKAMLSOURCES = \
	tutorial0.gtkaml main.vala

#tutorial0_LDADD = \
#	$(GTK_LIBS) \
#	$(EXTRA_LDFLAGS)

tutorial0 : $(tutorial0_GTKAMLSOURCES)
	../src/gtkamlc $(VALAFLAGS) --implicitsdir ../data --pkg gtk+-2.0 $^

EXTRA_DIST = \
	$(tutorial0_GTKAMLSOURCES)
