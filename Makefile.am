if ENABLE_TESTS
TESTS_DIRS = tests
endif

SUBDIRS = \
	libgtkaml \
	src \
	markuphints \
	$(TESTS_DIRS)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = gtkaml-1.0.pc

gtkamldocdir = ${prefix}/doc/gtkaml

dist_man_MANS = gtkamlc.1

EXTRA_DIST = \
	README \
	COPYING \
	AUTHORS \
	gtkaml-1.0.pc.in \
	autogen.sh \
	INSTALL \
	examples/SimpleViewer2/Makefile \
	examples/SimpleViewer2/SimpleViewer2.gtkaml \
	examples/gtkaml/Makefile \
	examples/gtkaml/gtk-hello.gtkaml \
	examples/gtkaml/search-dialog.gtkaml \
	examples/gtkaml/sync-sample.gtkaml \
	examples/gtkaml/treeview-liststore-sample.gtkaml \
	examples/gtkon/Makefile \
	examples/gtkon/gtk-hello.gtkon \
	examples/gtkon/search-dialog.gtkon \
	examples/gtkon/sync-sample.gtkon \
	examples/gtkon/treeview-liststore-sample.gtkon \
	examples/clutter/Makefile \
	examples/clutter/full-example.gtkon \
	examples/blitzen/Makefile \
	examples/blitzen/main.vala \
	examples/blitzen/test.gtkon \
	editors/vim/README \
	editors/vim/gtkaml.vim \
	editors/vim/gtkon.vim \
	editors/vim/vala.vim
