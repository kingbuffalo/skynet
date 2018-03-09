--常用的库
util = require "util"
oo = require "oo"
local math = math
local c = require "skynet.core"
local bson = require "bson"
local base_print = print
local skynet = require("skynet")
local DEBUG = skynet.getenv("DEBUG")
print=function(...)
	if DEBUG then
		log(...)
	else
		base_print(...)
	end
end

--全局函数

local function pr(obj)
	if obj == nil then
		return "nil    "
	elseif type(obj) == "table" then
		print_r(obj)
	else
		return tostring(obj) .."    "
	end
end
function p(...)
	local t = table.pack(...)
	local str = ""
	for i=1, t.n do
		local t = pr(t[i])
		if t then
			str = str..t
		end
	end
	print(str)
end

function print_r(obj)
	print( util.table_dump( obj ) )
	--util.tablePrint(obj)
end

function print_for( obj )
	for k, v in pairs(obj) do
		print("---->", k, v)
	end
end

function logl(...)
	local table = {...}
	print_r(table)
end

function dump_string(s)
	local b = false
	local str = ""
	for i=1,#s do
		if b then
			str = str .. ","
		else
			b = true
		end
		local c = string.byte(s, i)
		str = str .. c
	end
	print(str)
end

math.randomseed(os.time())
function random(min, max)
	return math.random(min, max)
end

--日志输出
function logImp( ... )
	local t = {...}
	for i=1,#t do
		t[i] = tostring(t[i])
	end
	return c.error(table.concat(t, " "))
end

function log( ... )
	if _roleId then
		logImp(_roleId, ...)
	else
		logImp(...)
	end
end

function logError( ... )
	if _roleId then
		logImp(_roleId, "error", ...)
	else
		logImp("error", ...)
	end
end

function logWarning( ... )
	if _roleId then
		logImp(_roleId, "warning", ...)
	else
		logImp("warning", ...)
	end
end

--只复制值
function simpleCopy( object )
	local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        --return setmetatable(new_table, getmetatable(object))
        return new_table
    end
    return _copy(object)
end

--此函数会复制所有的属性，包括函数(此函数需要谨慎使用)
function deepCopy(object)  
	local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
        --return new_table
    end
    return _copy(object)	
end


--enum.OBJ_ITEM大类物品对象
function getItemType( code )
	--return math.floor(code / 10000000)
	return code // 10000000
end

--enum.BAG_TYPE背包类型
function getBagTypeBySlot(slot)
	return math.floor(slot / 10000)
end

function positiveInt(...)
	local numList = {...}
	for _, val in ipairs(numList) do
		if "number" ~= type(val) or 0 >= val then
			return false
		else
			--正数,跳过继续检查下一个
		end
	end
	return true
end

--当dataType为 1 时，rewardListo为数组[[code,size,id],[code,size,id]...]
--当dataType为 2 时，是 {code=size, code2=size2}
--当dataType为 3 时，是 {{code=xx,num=xx,id=id},{code=xx,num=xx,id=id}..}
function getExtractCodeNumFunc(dataType )
	if dataType == 1 then
		return function( k, v ) return v[1], v[2],v[3] end
	elseif dataType == 2 then
		return function( k, v ) return k, v end
	elseif dataType == 3 then
		return function( k, v ) return v.code,v.num,v.id end
	else
		return nil
	end
end

function indexOf(arr,value)
	for i, v in ipairs( arr ) do
		if v==value then return i end
	end
	return -1
end

--生成uuid
function genUUID()
	local _, uuid = bson.type(bson.objectid())
	return uuid
end

local randomCache = {}
--取打乱的数值数组
function genRandomArry( size )
	for i=1, size do
		randomCache[i] = i
	end
	local r
	for i=2, size do
		r = random(1,i)
		randomCache[i], randomCache[r] = randomCache[r], randomCache[i]
	end
	randomCache[size + 1] = nil
	return randomCache
end

--合并奖励
function mergeReward(des, src, dataType)
	local fun = getExtractCodeNumFunc(dataType)
	for k,v in pairs(src) do
		local code, num = fun(k, v)
		if des[code] == nil then
			des[code] = num
		else
			des[code] = des[code] + num
		end
	end
end

function calDirection(srcX, srcY, dstX, dstY)
	local vecX = dstX - srcX
	local vecY = dstY - srcY
	local length = math.sqrt(vecX * vecX + vecY * vecY)
	local dir = math.deg(math.asin(vecX / length))
	if dir > 0 then
		if vecY < 0 then
			dir = 180 - dir
		end
	else
		if vecY < 0 then
			dir = 180 - dir
		else
			dir = 360 + dir
		end
	end
	return dir
end

--xxx_config 的配置要用这个require
function requireConfig( name )
	local r = require(name)
	package.loaded[name] = nil
	return r
end

function getCallStack(name)
	local strT = {name}
	local startLevel = 2
	local maxLevel = 100
	for level = startLevel, maxLevel do
		local info = debug.getinfo( level, "nSl" ) 
		if info == nil then break end
		if info.currentline > 0 then
			strT[#strT+1] = string.format("[ line : %-4d ]  %-20s :: %s", info.currentline, info.name or "", info.source or "" )  
		end
	end
	return table.concat(strT,"\n")
end

function printCallStack(name)
	local str = getCallStack(name)
	print(str)
end

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
	if not char then return 0,0 end
	if char >= 252 then return 6,2 end
	if char >= 248 then return 5,2 end
	if char >= 240 then return 4,2 end
	if char >= 225 then return 3,2 end
	if char >= 192 then return 2,2 end
	return 1,1
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- -- 例如utf8len("1你好") => 3
function utf8len(str)
	local len = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + chsize(char)
		len = len +1
	end
	return len
end

-- 截取utf8 字符串
-- str:utf8要截取的字符串
-- startChar:startChar开始字符下标,从1开始
-- numChars:numChars要截取的字符长度
function utf8sub(str, startChar, numChars)
	local startIndex = 1
	while startChar > 1 do
		local char = string.byte(str, startIndex)
		startIndex = startIndex + chsize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex

	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + chsize(char)
		numChars = numChars -1
	end
	return str:sub(startIndex, currentIndex - 1)
end

--认为utf8字符长度为2
--ascii字符长度为1
--字符串长度
function utf82_ascii1_len(str)
	local len = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		local size,clen = chsize(char)
		currentIndex = currentIndex + size
		len = len + clen
	end
	return len
end

--认为utf8字符长度为2
--ascii字符长度为1
--字符串长度
function utf82_ascii1_sub(str, startChar, numChars)
	local startIndex = 1
	while startChar > 1 do
		local char = string.byte(str, startIndex)
		startIndex = startIndex + chsize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex

	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		local size,len = chsize(char)
		currentIndex = currentIndex + size
		numChars = numChars - len
	end
	return str:sub(startIndex, currentIndex - 1)
end

