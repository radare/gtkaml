all: full-example

VALA_API_VERSION := $(shell valac --api-version)
VALA_CODEGEN_LIBDIR := $(shell pkg-config --variable=pkglibdir libvala-$(VALA_API_VERSION))
GTKAMLC = env LD_LIBRARY_PATH="$(VALA_CODEGEN_LIBDIR):$$LD_LIBRARY_PATH" ../../src/gtkamlc --pkg gtk+-3.0 --pkg clutter-gtk-1.0 --pkg clutter-1.0 --pkg mx-1.0 --vapidir ../../markuphints --save-temps

ifeq ($(shell pkg-config --exists gtk+-3.0 clutter-gtk-1.0 clutter-1.0 mx-1.0 && echo yes),yes)
BUILD_FULL_EXAMPLE = $(GTKAMLC) $^
else
BUILD_FULL_EXAMPLE = @echo "Skipping full-example: gtk+-3.0 clutter-gtk-1.0 clutter-1.0 mx-1.0 not available"
endif

full-example:full-example.gtkon
	$(BUILD_FULL_EXAMPLE)

clean:
	rm -f full-example
