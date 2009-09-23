SUBDIRS = src \
	data \
	vapi \
	tests 

gtkamldocdir = ${prefix}/doc/gtkaml

EXTRA_DIST = \
	README\
	COPYING\
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS \
  debian/changelog \
	debian/compat \
	debian/control \
	debian/dirs \
	debian/docs \
	debian/files \
	debian/gtkaml.substvars \
	debian/rules


# Copy all the spec files. Of cource, only one is actually used.
dist-hook:
	for specfile in *.spec; do \
		if test -f $$specfile; then \
			cp -p $$specfile $(distdir); \
		fi \
	done


