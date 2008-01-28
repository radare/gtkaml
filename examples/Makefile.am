## File created by the gnome-build tools


INCLUDES = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

AM_CFLAGS = \
	 -Wall \
	 -g \
	 $(GTK_CFLAGS)

BUILT_SOURCES = example0.stamp

bin_PROGRAMS = example0

example0_GTKAMLSOURCES = \
	example0.gtkaml

example0_SOURCES = \
	example0.h \
	example0.c \
	example0.stamp	

example0_LDADD = \
	$(GTK_LIBS)

example0.stamp : $(example0_GTKAMLSOURCES)
	../valaml/valamlc $(VALAFLAGS) --pkg gtk+-2.0 $^
	touch $@


