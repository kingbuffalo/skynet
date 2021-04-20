#include "lua.h"
#include "lauxlib.h"
#include "crc32.h"

#include <stdio.h>
static int
lcrc32(lua_State *L) {
	size_t len=0;
	const char* buf = lua_tolstring(L,-1,&len);
	if ( buf == NULL ){
		return luaL_argerror(L, 1, "string is nil");
	}
	int ret = Crc32_ComputeBuf(buf,len);
	char retStr[5] = {0};
	retStr[3] = ret & 0xFF;
	retStr[2] = (ret >> 8)&0xFF;
	retStr[1] = (ret >> 16)&0xFF;
	retStr[0] = (ret >> 24)&0xFF;
	if (retStr[2] == 13 && retStr[3] == 10 ){
		retStr[3] = 9;
	}
	lua_pushstring(L,retStr);
	return 1;
}

LUAMOD_API int luaopen_boylib(lua_State *L) {
	luaL_Reg funcs[] = {
		{"crc32",lcrc32},
		{ NULL, NULL },
	};
	luaL_newlib(L,funcs);
	return 1;
}
