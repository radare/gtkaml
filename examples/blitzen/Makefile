APPNAME=test
APPSDIR=/var/lib/blitzen/apps/
RESOURCEDIR=/var/lib/blitzen/resources
JSHELPER=$(RESOURCEDIR)/blitzenio.js
DEPLOYDIR=$(APPSDIR)/$(APPNAME)
SOURCES := test.vala main.vala 
OBJS := $(patsubst %.vala, %.vala.o, $(SOURCES))
.PHONY: all clean deploy install

VALA_API_VERSION := $(shell valac --api-version)
VALA_CODEGEN_LIBDIR := $(shell pkg-config --variable=pkglibdir libvala-$(VALA_API_VERSION))
GTKAMLC = env LD_LIBRARY_PATH="$(VALA_CODEGEN_LIBDIR):$$LD_LIBRARY_PATH" ../../src/gtkamlc --pkg=stk-1.0 --vapidir ../../markuphints
STK_AVAILABLE := $(shell pkg-config --exists stk-1.0 && echo yes)

all: gtkaml ${APPNAME}-app.so

gtkaml:
ifeq ($(STK_AVAILABLE),yes)
	$(GTKAMLC) test.gtkon
	rm -f test.vala.o ${APPNAME}-app.so
else
	@echo "Skipping blitzen example: stk-1.0 not available"
endif

${APPNAME}-app.so: $(OBJS)
ifeq ($(STK_AVAILABLE),yes)
	$(CC) $(OBJS) $(CFLAGS) -shared -fPIC -Wl,-soname,$@ -o $@
else
	@true
endif

$(OBJS):
ifeq ($(STK_AVAILABLE),yes)
	valac -g $(SOURCES) -c --pkg=stk-1.0 --Xcc=-fPIC
else
	@true
endif

deploy: ${APPNAME}-app.so
	if test ! -d "$(DEPLOYDIR)"; then mkdir "$(DEPLOYDIR)"; fi; 
	cp -f $< $(DEPLOYDIR) 
	ln -sf $(JSHELPER) $(DEPLOYDIR)
	@echo
	@echo To complete installation of the blitzen webapp append
	@echo this to the config file: /etc/blitzen/blitzen.conf
	@echo
	@cat blitzen.conf

install: deploy

clean:
	rm -f *.o *.so test.gtkaml test.vala
