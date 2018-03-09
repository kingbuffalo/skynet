#include <map>
#include <time.h>
#include <cstring>
#include <iostream>

extern "C"{
#include <lua.h>
#include <lauxlib.h>
#include <stdlib.h>
}

struct node{
	std::map<char,struct node*> m;
	bool bLeaf;
	char c;
};

//void printEmpty(int emptyCount){
	//for (int i = 0; i <emptyCount; i++) {
		//std::cout << ' ';
	//}
//}
//void __printNode(const struct node *n,int emptyCount){
	//for (auto it=n->m.begin(); it != n->m.end(); it++ ) {
		//printEmpty(emptyCount);
		//std::cout << emptyCount << "->" << it->second->c << std::endl;
		//__printNode(it->second, emptyCount+1);
	//}
//}
//void printNode(const struct node *n){
	//__printNode(n,1);
//}

extern "C" void addkeyword(struct node *rootNode,const char* szStr){
	int l = strlen(szStr);
	struct node *pn = rootNode;
	for (int i = 0; i <l; i++) {
		char c = szStr[i];
		struct node *n = pn->m[c];
		if ( n == NULL ){
			n = new struct node();
			n->c = c;
			n->bLeaf = false;
			pn->m[c] = n;
		}
		pn = n;
	}
	pn->bLeaf = true;
}

extern "C" void replace(struct node *rootNode, char* szStr){
	int l = strlen(szStr);
	int i=0;
	while ( i < l ){
		int x = i;
		int y = x;
		char c = szStr[i];
		struct node *n = rootNode;
		if ( n->m[c] ){
			while (n != NULL && n->m[c] != NULL ) {
				n = n->m[c];
				++ y;
				c = szStr[y];
			}
		}

		if ( n != NULL && n->bLeaf ){
			if ( y > x && y <= l ){
				for (int ii = x; ii <y; ++ii) {
					szStr[ii] = '*';
				}
				i = y-1;
			}
		}
		++ i;
	}
}

extern "C" int
lcreate(lua_State *L){
	struct node *ret = new struct node();
	lua_pushlightuserdata(L,ret);
	return 1;
}

extern "C" int
ldestory(lua_State *L){
	struct node *ret = (struct node *)lua_touserdata(L,1);
	delete ret;
	return 0;
}

extern "C" int
laddKeyWord(lua_State *L){
	struct node *n = (struct node*)lua_touserdata(L,1);
	if ( n == NULL) return 0;
	const char* szStr = lua_tostring(L,2);
	if ( szStr == NULL ) return 0;
	addkeyword(n,szStr);
	lua_pushinteger(L,1);
	return 1;
}


extern "C" int
lreplace(lua_State *L){
	struct node *n = (struct node*)lua_touserdata(L,1);
	if ( n == NULL) return 0;
	const char* szStr = lua_tostring(L,2);
	if ( szStr == NULL ) return 0;

	size_t strLen = strlen(szStr)+1;
	char *retStr = (char*)malloc(sizeof(char)*(strLen));
	retStr[strLen-1] = 0;
	strcpy(retStr,szStr);
	replace(n,retStr);

	lua_pushstring(L,retStr);
	free(retStr);
	return 1;
}

extern "C" int
luaopen_wordfilter(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "create", lcreate},
		{ "destory", ldestory},
		{ "addkeyword",laddKeyWord},
		{ "replace",lreplace},
		{ NULL,  NULL },
	};

	luaL_newlib(L,l);
	return 1;
}


//int main(){
	//struct node gn;
	//addkeyword(&gn, "伤的");
	//addkeyword(&gn, "酷");
	//addkeyword(&gn, "他酷");
	//addkeyword(&gn, "好");
	//addkeyword(&gn, "a");
	//addkeyword(&gn, "b");
	//addkeyword(&gn, "c");
	//addkeyword(&gn, "d");
	//addkeyword(&gn, "e");
	//addkeyword(&gn, "f");
	//addkeyword(&gn, "g");
	//addkeyword(&gn, "h");
	//addkeyword(&gn, "l");
	//addkeyword(&gn, "fuck");
	//addkeyword(&gn, "shit");
	//char szStr[] = "abcde";
	//char s[] = "然后他还用一种及其悲伤的表情一直表演fuck极其搞笑的段子，下楼梯撞倒天花板，
//烤面包烤糊了还烫了自fuck己的手。这位老兄酷爱shit喝茶，到了宇宙飞船上面还不忘了要
//杯茶喝，结果被好好恶心了一顿。";
	//char szStr1[] = "asdlfkje;lqwu asdkaf3q fuck axkfiasdfedwwqlfnmv a;lskdfwqe ckszaoifew a;klewk";


	//clock_t t;
	//t = clock();
	//for (int i = 0; i <10000; i++) {
		//replace(&gn,szStr1);
		//replace(&gn,s);
	//}
	//t =  clock()-t;
	//std::cout << s <<"\n"<< t << "\n" << (float)t / CLOCKS_PER_SEC <<std::endl;
	//return 0;
//}
