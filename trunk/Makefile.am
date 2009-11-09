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
	examples/vala/Makefile \
	examples/vala/gtk-hello.gtkaml \
	examples/vala/search-dialog.gtkaml \
	examples/vala/sync-sample.gtkaml \
	examples/vala/treeview-liststore-sample.gtkaml

# Copy all the spec files. Of cource, only one is actually used.
dist-hook:
	for specfile in *.spec; do \
		if test -f $$specfile; then \
			cp -p $$specfile $(distdir); \
		fi \
	done
