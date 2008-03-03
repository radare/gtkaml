tutorial : tutorial.gtkaml
	gtkamlc --pkg gtk+-2.0 $^
	gcc `pkg-config --cflags gtk+-2.0` tutorial.c tutorial.h -o $@ `pkg-config --libs gtk+-2.0`

clean: 
	rm  tutorial.vala tutorial.c tutorial.h tutorial

