ALL = test4

EXTRA_DIST = $(ALL:=.gtkaml)

all: $(ALL)

test4: test4.gtkaml
	$(top_srcdir)/src/gtkamlc $(VALAFLAGS) --pkg gtk+-3.0 $@.gtkaml --dump-tree $@.vala --vapidir ../../markuphints

clean:
	rm -f $(ALL) $(ALL:=.vala)
