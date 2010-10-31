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
	examples/vala2gtkaml/Makefile \
	examples/vala2gtkaml/gtk-hello.gtkaml \
	examples/vala2gtkaml/search-dialog.gtkaml \
	examples/vala2gtkaml/sync-sample.gtkaml \
	examples/vala2gtkaml/treeview-liststore-sample.gtkaml \
	examples/vala2gtkon/Makefile \
	examples/vala2gtkon/gtk-hello.gtkaml \
	examples/vala2gtkon/search-dialog.gtkaml \
	examples/vala2gtkon/sync-sample.gtkaml \
	examples/vala2gtkon/treeview-liststore-sample.gtkaml


# Copy all the spec files. Of cource, only one is actually used.
dist-hook:
	for specfile in *.spec; do \
		if test -f $$specfile; then \
			cp -p $$specfile $(distdir); \
		fi \
	done
