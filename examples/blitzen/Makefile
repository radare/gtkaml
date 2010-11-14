APPNAME=test
APPSDIR=/var/lib/blitzen/apps/
RESOURCEDIR=/var/lib/blitzen/resources
JSHELPER=$(RESOURCEDIR)/blitzenio.js
DEPLOYDIR=$(APPSDIR)/$(APPNAME)
SOURCES := test.vala main.vala 
OBJS := $(patsubst %.vala, %.vala.o, $(SOURCES))
.PHONY: all clean deploy install

all: gtkaml ${APPNAME}-app.so

gtkaml:
	gtkamlc -V --pkg=stk test.gtkon 
	rm -f test.vala.o ${APPNAME}-app.so

${APPNAME}-app.so: $(OBJS)
	$(CC) $(OBJS) $(CFLAGS) -shared -fPIC -Wl,-soname,$@ -o $@

$(OBJS):
	valac -g $(SOURCES) -c --pkg=stk --Xcc=-fPIC

deploy: ${APPNAME}-app.so
	if test ! -d "$(DEPLOYDIR)"; then mkdir "$(DEPLOYDIR)"; fi; 
	cp -f $< $(DEPLOYDIR) 
	ln -sf $(JSHELPER) $(DEPLOYDIR)

install: deploy

clean:
	rm -f *.o *.so test.gtkaml test.vala
