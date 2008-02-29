INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	 -Wall \
	 -g \
	 $(EXTRA_CFLAGS) \
	 $(GTK_CFLAGS)

BUILT_SOURCES = SimpleViewer2.stamp 
noinst_PROGRAMS = SimpleViewer2 

CLEANFILES = SimpleViewer2.h SimpleViewer2.c SimpleViewer2.vala test1.vala

## Example 0
SimpleViewer2_GTKAMLSOURCES = \
	SimpleViewer2.gtkaml

nodist_SimpleViewer2_SOURCES = \
	$(SimpleViewer2_GTKAMLSOURCES:.gtkaml=.c) \
	$(SimpleViewer2_GTKAMLSOURCES:.gtkaml=.h) \
	SimpleViewer2.stamp	

SimpleViewer2_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

SimpleViewer2.stamp : $(SimpleViewer2_GTKAMLSOURCES)
	../../src/gtkamlc $(VALAFLAGS) --implicitsdir ../../data --pkg gtk+-2.0 $^
	touch $@



EXTRA_DIST = \
	$(SimpleViewer2_GTKAMLSOURCES)
 