
all:
	valac gtkml.vala --pkg gio-2.0
	rm -f test0.gtkaml
	./gtkml test0.gtkml
	cat test0.gtkaml
	gtkamlc --pkg gtk+-2.0 test0.gtkaml

clean:
	rm -f test0.gtkaml *.out gtkml test0 test0.vala
