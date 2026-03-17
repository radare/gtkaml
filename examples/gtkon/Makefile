all: gtk-hello sync-sample search-dialog treeview-liststore-sample

VALA_API_VERSION := $(shell valac --api-version)
VALA_CODEGEN_LIBDIR := $(shell pkg-config --variable=pkglibdir libvala-$(VALA_API_VERSION))
GTKAMLC = env LD_LIBRARY_PATH="$(VALA_CODEGEN_LIBDIR):$$LD_LIBRARY_PATH" ../../src/gtkamlc --pkg gtk+-3.0 --vapidir ../../markuphints --save-temps

gtk-hello:gtk-hello.gtkaml
	$(GTKAMLC) $^

search-dialog:search-dialog.gtkaml
	$(GTKAMLC) $^

sync-sample:sync-sample.gtkaml
	$(GTKAMLC) $^

treeview-liststore-sample:treeview-liststore-sample.gtkaml
	$(GTKAMLC) $^

clean:
	rm -f gtk-hello search-dialog sync-sample treeview-liststore-sample
