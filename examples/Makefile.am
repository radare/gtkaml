INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	 -Wall \
	 -g \
	 $(EXTRA_CFLAGS) \
	 $(GTK_CFLAGS)

BUILT_SOURCES = example0.stamp example1.stamp
bin_PROGRAMS = example0 example1

## Example 0

example0_GTKAMLSOURCES = \
	example0.gtkaml

example0_SOURCES = \
	$(example0_GTKAMLSOURCES:.gtkaml=.c) \
	$(example0_GTKAMLSOURCES:.gtkaml=.h) \
	example0.stamp	

example0_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

example0.stamp : $(example0_GTKAMLSOURCES)
	../src/gtkamlc $(VALAFLAGS) --pkg gtk+-2.0 $^
	touch $@

## Example 1

example1_GTKAMLSOURCES = \
	example1.gtkaml

example1_SOURCES = \
	$(example1_GTKAMLSOURCES:.gtkaml=.c) \
	$(example1_GTKAMLSOURCES:.gtkaml=.h) \
	example1.stamp	

example1_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

example1.stamp : $(example1_GTKAMLSOURCES)
	../src/gtkamlc $(VALAFLAGS) --pkg gtk+-2.0 $^
	touch $@

EXTRA_DIST = example0.stamp \
	example1.stamp \
	$(example0_GTKAMLSOURCES) \
	$(example1_GTKAMLSOURCES)
