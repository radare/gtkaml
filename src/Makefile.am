AM_CPPFLAGS = \
	$(GLIB_CFLAGS) \
	$(GIO_CFLAGS) \
	$(VALA_CFLAGS) \
	$(LIBXML2_CFLAGS) \
	-I$(top_srcdir)/vapi \
	-I$(top_srcdir)/libgtkaml

bin_PROGRAMS = gtkamlc

BUILT_SOURCES = gtkamlc.stamp
CLEANFILES = gtkamlc.stamp

gtkamlc_VALASOURCES = gtkamlcompiler.vala

nodist_gtkamlc_SOURCES = \
	gtkamlc.stamp \
	$(gtkamlc_VALASOURCES:.vala=.c)

gtkamlc.stamp: $(gtkamlc_VALASOURCES)
	$(VALAC) -C $(VALAFLAGS) --vapidir $(top_srcdir)/vapi --vapidir ../libgtkaml --pkg valaccodegen --pkg gtkaml-1.0 --pkg libxml-2.0 --pkg libvala-$(VALA_VERSION) --pkg glib-2.0 --pkg gio-2.0 --pkg config $^
	touch $@

gtkamlc_LDADD = \
	$(top_srcdir)/libgtkaml/libgtkaml.la \
	-L$(VALA_CODEGEN_LIBDIR) \
	-lvalaccodegen \
	$(GLIB_LIBS) \
	$(GIO_LIBS) \
	$(VALA_LIBS) \
	$(LIBXML2_LIBS)

gtkamlc_LDFLAGS = \
	-Wl,-rpath,$(VALA_CODEGEN_LIBDIR)

EXTRA_DIST = $(gtkamlc_VALASOURCES)

install-exec-hook:
	cd $(DESTDIR)$(bindir) && $(LN_S) -f gtkamlc$(EXEEXT) gtkaml$(EXEEXT)
