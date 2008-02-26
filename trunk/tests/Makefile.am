INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	 -Wall \
	 -g \
	 $(EXTRA_CFLAGS) \
	 $(GTK_CFLAGS)

BUILT_SOURCES = test0.stamp test1.stamp
noinst_PROGRAMS = test0 test1


CLEANFILES = test0.h test0.c test1.h test1.c test0.vala test1.vala test0.stamp test1.stamp

## Example 0
test0_GTKAMLSOURCES = \
	test0.gtkaml

nodist_test0_SOURCES = \
	$(test0_GTKAMLSOURCES:.gtkaml=.c) \
	$(test0_GTKAMLSOURCES:.gtkaml=.h) \
	test0.stamp	
test0_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

test0.stamp : $(test0_GTKAMLSOURCES)
	../src/gtkamlc $(VALAFLAGS) --implicitsdir ../data --pkg gtk+-2.0 $^
	touch $@

## Example 1

test1_GTKAMLSOURCES = \
	test1.gtkaml

nodist_test1_SOURCES = \
	$(test1_GTKAMLSOURCES:.gtkaml=.c) \
	$(test1_GTKAMLSOURCES:.gtkaml=.h) \
	test1.stamp	

test1_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

test1.stamp : $(test1_GTKAMLSOURCES)
	../src/gtkamlc $(VALAFLAGS) --implicitsdir ../data --pkg gtk+-2.0 $^
	touch $@


EXTRA_DIST = \
	$(test0_GTKAMLSOURCES) \
	$(test1_GTKAMLSOURCES)
