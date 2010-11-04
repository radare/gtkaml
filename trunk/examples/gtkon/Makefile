all: gtk-hello sync-sample search-dialog treeview-liststore-sample

gtk-hello:gtk-hello.gtkon
	../../src/gtkamlc --pkg gtk+-2.0 --implicitsdir ../../data --save-temps $^

search-dialog:search-dialog.gtkon
	../../src/gtkamlc --pkg gtk+-2.0 --implicitsdir ../../data --save-temps $^

sync-sample:sync-sample.gtkon
	../../src/gtkamlc --pkg gtk+-2.0 --implicitsdir ../../data --save-temps $^

treeview-liststore-sample:treeview-liststore-sample.gtkon
	../../src/gtkamlc --pkg gtk+-2.0 --implicitsdir ../../data --save-temps $^

clean:
	rm -f gtk-hello search-dialog sync-sample treeview-liststore-sample
