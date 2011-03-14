SUBDIRS = src data vapi tests 

gtkamldocdir = ${prefix}/doc/gtkaml

EXTRA_DIST = \
	README\
	COPYING\
	AUTHORS\
	INSTALL\
	debian/changelog \
	debian/compat \
	debian/control \
	debian/dirs \
	debian/docs \
	debian/files \
	debian/gtkaml.substvars \
	debian/rules \
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
	examples/blitzen/test.gtkon


# Copy all the spec files. Of cource, only one is actually used.
dist-hook:
	for specfile in *.spec; do \
		if test -f $$specfile; then \
			cp -p $$specfile $(distdir); \
		fi \
	done
