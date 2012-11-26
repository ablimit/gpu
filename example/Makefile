DB2PATH=/home/db2inst2/sqllib
LIB=lib
EXTRA_LFLAG="-Wl,-rpath,$(DB2PATH)/$(LIB)"

example:example.o
        gcc -std=gnu99 -m64 -shared -o example.o $(EXTRA_LFLAG)  -L/lib64 -L/usr/local/lib -L$(DB2PATH)/$(LIB) -ldb2

example.o:example.c
	gcc -std=gnu99 -m64 -fpic -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I$(DB2PATH)/include -c example.c -D_REENTRANT


