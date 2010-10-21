
all:
	valac gtkon.vala --pkg gio-2.0
	rm -f test0.gtkaml
	./gtkon test0.gtkon
	cat test0.gtkaml
	gtkamlc --pkg gtk+-2.0 test0.gtkaml

clean:
	rm -f test0.gtkaml *.out gtkon test0 test0.vala
