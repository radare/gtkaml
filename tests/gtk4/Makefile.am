ALL = smoke

EXTRA_DIST = $(ALL:=.gtkaml)

all: $(ALL)

smoke: smoke.gtkaml
	$(top_srcdir)/src/gtkamlc $(VALAFLAGS) --pkg gtk4 $@.gtkaml --dump-tree $@.vala --vapidir ../../markuphints

clean:
	rm -f $(ALL) $(ALL:=.vala)
