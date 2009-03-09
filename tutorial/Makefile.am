noinst_PROGRAMS = tutorial0

CLEANFILES = tutorial0.vala

## Example 0
tutorial0_GTKAMLSOURCES = \
	tutorial0.gtkaml main.vala

tutorial0_SOURCES = $(tutorial0_GTKAMLSOURCES)

tutorial0 : $(tutorial0_GTKAMLSOURCES)
	../src/gtkamlc $(VALAFLAGS) --implicitsdir ../data --pkg gtk+-2.0 $^

EXTRA_DIST = \
	$(tutorial0_GTKAMLSOURCES)
