gcc -O2 -o ikcp.o -c -g -shared -rdynamic -fpic ikcp.c
gcc -O2 -o lkcp.o -c -g -shared -rdynamic -fpic lkcp.c -I ../../3rd/lua -L ../../3rd/lua/liblua.a
gcc -O2 -o lutil.o -c -g -shared -rdynamic -fpic lutil.c -I ../../3rd/lua -L ../../3rd/lua/liblua.a
gcc -O2 -o lkcp.so -g -shared -rdynamic -fpic ikcp.o lkcp.o -I ../../3rd/lua -L ../../3rd/lua/liblua.a
gcc -O2 -o lutil.so -g -shared -rdynamic -fpic lutil.o ikcp.o -I ../../3rd/lua -L ../../3rd/lua/liblua.a
mv *.so ../../luaclib/

#gcc -O2 -o wordfilter.so -g -shared -rdynamic -fpic wordfilter.cpp -I ../../3rd/lua -L ../../3rd/lua/liblua.a
