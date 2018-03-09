#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>

struct RandomSeq{
	unsigned int m_index;
	unsigned int m_intermediateOffset;
};

unsigned int permuteQPR(unsigned int x){
	static const unsigned int prime = 4294967291u;
	if (x >= prime)
		return x;  // The 5 integers out of range are mapped to themselves.
	unsigned int residue = ((unsigned long long) x * x) % prime;
	return (x <= prime / 2) ? residue : prime - residue;
}

struct RandomSeq* createRandomSeq(unsigned int seedBase,unsigned int seedOffset){
	struct RandomSeq *ret = malloc(sizeof(struct RandomSeq));
	ret->m_index = permuteQPR(permuteQPR(seedBase) + 0x682f0161);
	ret->m_intermediateOffset = permuteQPR(permuteQPR(seedOffset) + 0x46790905);
	return ret;
}

unsigned int next(struct RandomSeq* rs){
	return permuteQPR((permuteQPR(rs->m_index++) + rs->m_intermediateOffset) & 0x5bf03635);
}

void destoryRandomSeq(struct RandomSeq* rs){
	free(rs);
}

static int
lcreate(lua_State *L){
	int sb = luaL_checkinteger(L,1);
	int so = luaL_checkinteger(L,2);
	struct RandomSeq* ret = createRandomSeq(sb,so);
	lua_pushlightuserdata(L,ret);
	return 1;
}

static int
ldestory(lua_State *L){
	struct RandomSeq *rs = lua_touserdata(L,1);
	destoryRandomSeq(rs);
	rs = NULL;
	return 0;
}

static int
lnext(lua_State *L){
	struct RandomSeq *rs = lua_touserdata(L,1);
	unsigned int nextUint = next(rs);
	lua_pushinteger(L,nextUint);
	return 1;
}

LUAMOD_API int
luaopen_randseq(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "create", lcreate},
		{ "destory", ldestory},
		{ "nextInt", lnext},
		{ NULL,  NULL },
	};

	luaL_newlib(L,l);

	return 1;
}
