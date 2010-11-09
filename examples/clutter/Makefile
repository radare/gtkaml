all: full-example

full-example:full-example.gtkon
	../../src/gtkamlc --pkg gtk+-2.0 --pkg clutter-gtk-0.10 --pkg clutter-1.0 --pkg mx-1.0 --implicitsdir ../../data --save-temps $^

clean:
	rm -f full-example
