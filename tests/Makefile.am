INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	 -Wall \
	 -g \
	 $(EXTRA_CFLAGS) \
	 $(GTK_CFLAGS)

BUILT_SOURCES = test0.stamp test1.stamp test3.stamp test4.stamp test5.stamp
noinst_PROGRAMS = test0 test1 test3 test4 test5


CLEANFILES = test0.h test0.c test0.stamp test0.vala \
	test1.h test1.c test1.stamp test1.vala \
	test2.h test2.c test2.stamp test2.vala \
	test3.h test3.c test3.stamp test3.vala \
	test4.h test4.c test4.stamp test4.vala \
	test5.h test5.c test5.stamp test5.vala


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
	../src/gtkamlc -C $(VALAFLAGS) --implicitsdir $(top_srcdir)/data --pkg gtk+-2.0 $^
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
	../src/gtkamlc -C $(VALAFLAGS) --implicitsdir $(top_srcdir)/data --pkg gtk+-2.0 $^
	touch $@

## Segmentation fault test 3

test2_GTKAMLSOURCES = \
	test2.gtkaml

nodist_test2_SOURCES = \
	$(test1_GTKAMLSOURCES:.gtkaml=.c) \
	$(test1_GTKAMLSOURCES:.gtkaml=.h) \
	test2.stamp	

test2_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

test2.stamp : $(test2_GTKAMLSOURCES)
	../src/gtkamlc -C $(VALAFLAGS) --implicitsdir $(top_srcdir)/data --pkg gtk+-2.0 $^
	touch $@

## Example 3

test3_GTKAMLSOURCES = \
	test3.gtkaml

test3_VALASOURCES = \
	WindowController.vala 

nodist_test3_SOURCES = \
	$(test3_VALASOURCES:.vala=.c) \
	$(test3_VALASOURCES:.vala=.h) \
	$(test3_GTKAMLSOURCES:.gtkaml=.c) \
	$(test3_GTKAMLSOURCES:.gtkaml=.h) \
	test3.stamp

test3_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

test3.stamp : $(test3_VALASOURCES) $(test3_GTKAMLSOURCES)
	../src/gtkamlc -C $(VALAFLAGS) --implicitsdir $(top_srcdir)/data --pkg gtk+-2.0 $^
	touch $@

## Example 4 gtkon

test4_GTKONSOURCES = \
	test4.gtkon

nodist_test4_SOURCES = \
	$(test4_GTKONSOURCES:.gtkon=.c) \
	$(test4_GTKONSOURCES:.gtkon=.h) \
	test4.stamp

test4_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

test4.stamp : $(test4_GTKONSOURCES)
	../src/gtkamlc -C $(VALAFLAGS) --save-temps --implicitsdir $(top_srcdir)/data --pkg gtk+-2.0 $^
	touch $@

## Example 5 gtkon

test5_GTKONSOURCES = \
	test5.gtkon

nodist_test5_SOURCES = \
	$(test5_GTKONSOURCES:.gtkon=.c) \
	$(test5_GTKONSOURCES:.gtkon=.h) \
	test5.stamp

test5_LDADD = \
	$(GTK_LIBS) \
	$(EXTRA_LDFLAGS)

test5.stamp : $(test5_GTKONSOURCES)
	../src/gtkamlc -C $(VALAFLAGS) --save-temps --implicitsdir $(top_srcdir)/data --pkg gtk+-2.0 $^
	touch $@

EXTRA_DIST = \
	$(test0_GTKAMLSOURCES) \
	$(test1_GTKAMLSOURCES) \
	$(test2_GTKAMLSOURCES) \
	$(test3_GTKAMLSOURCES) \
	$(test3_VALASOURCES) \
	$(test4_GTKONSOURCES)

