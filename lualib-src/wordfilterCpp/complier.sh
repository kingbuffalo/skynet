g++ -O2 -o wordfilter.so -g -shared -rdynamic -fpic wordfilter.cpp -I ../../3rd/lua -L ../../3rd/lua/liblua.a -std=c++11
cp wordfilter.so ../../luaclib/
