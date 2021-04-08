.PHONY : all win clean

all : linux
win : boylib.dll

# For Linux
linux:
	make boylib.so "DLLFLAGS = -shared -fPIC"
# For Mac OS
macosx:
	make boylib.so "DLLFLAGS = -bundle -undefined dynamic_lookup"

boylib.so : crc32.c lboy.c
	env gcc -O2 -Wall $(DLLFLAGS) -o $@ $^

boylib.dll : crc32.c lboy.c
	gcc -O2 -Wall --shared -o $@ $^ -I/home/cds/fun/skgamesvr/skynet/3rd/lua  -L/home/cds/fun/skgamesvr/skynet/3rd/lua

clean :
	rm -f boylib.so boylib.dll
