local M = { DEBUG = true }
local serpent = require("serpent")
local skynet = require("skynet")
local level_log = require("level_log")
require("skynet.manager")

--local randseq = require("randseq")
local bson = require "bson"
local bson_encode =	bson.encode
local bson_decode =	bson.decodestr

function M.isArrayTable(t)
	if type(t) ~= "table" then return false end
	local n = #t
	for i,_ in pairs(t) do
		if type(i) ~= "number" then return false end
		if i > n then return false end
	end
	return true
end

--[[
function M.crc32(str)
	return randseq.crc32(str)
end
]]

function M.indexOf(arr,value)
	for i,v in ipairs(arr) do
		if v == value then return i end
	end
	return -1
end

function M.onShutDownService()
	local mysql_util = require("zjutils/mysql_util")
	mysql_util.closeDb()
	skynet.timeout(400,function()
		skynet.abort()
	end)
	--while skynet.mqlen() > 0 do
		--skynet.error("mqlen>0")
		--skynet.sleep(100)
	--end
end

function M.indexOfByKeyValue(arr,key,value)
	for i,v in ipairs(arr) do
		if v[key] == value then return i end
	end
	return -1
end

function M.indexOfByFunc(arr,func)
	for i,v in ipairs(arr) do
		if func(v) then return i end
	end
	return -1
end

function M.clearTable(t)
	for k,_ in pairs(t) do
		t[k] = nil
	end
end

function M.tableValueCount(t,val)
	local count = 0
	for k,v in pairs(t) do
		if v == val then
			count = count +1
		end
	end
	return count
end

function M.tableKeyCount(t)
	local count = 0
	for k,v in pairs(t) do
		count = count +1
	end
	return count
end


function M.getDebugPrint(...)
	if M.DEBUG then
		local l = {...}
		local sarr = {}
		for i,v in ipairs(l) do
			local s = v
			if type(v) == "table" then
				s = serpent.dump(v)
			end
			sarr[#sarr+1] = s
		end
		return table.concat(sarr,"\n")
	end
end

function M.infoPrint(...)
	if M.DEBUG then
		local l = {...}
		for i,v in ipairs(l) do
			local s = v
			if type(v) == "table" then
				s = serpent.dump(v)
			end
			level_log.info(s)
		end
	end
end

function M.debugPrint(...)
	if M.DEBUG then
		local l = {...}
		local sarr = {}
		for i,v in ipairs(l) do
			local s = v
			if type(v) == "table" then
				s = serpent.dump(v)
			end
			sarr[#sarr+1] = tostring(s)
		end
		level_log.trace(table.concat(sarr,"           \n"))
	end
end

function M.sqlTimestampToUnixTimestamp(sqltimestamp)
	local y,m,d,h,min,s = string.match(sqltimestamp,"(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)")
	local date = { year=tonumber(y), month=tonumber(m), day=tonumber(d),
		hour=tonumber(h), min=tonumber(min), sec=tonumber(s), }
	return os.time(date)
end

function M.timestampToSqlDATETIME(timestamp)
	return os.date("%Y-%m-%d %X",timestamp)
end

function M.timestampToSqlDATE(timestamp)
	return os.date("%Y-%m-%d",timestamp)
end

function M.timestampToSqlMonth(timestamp)
	return os.date("%Y%m",timestamp)
end

function M.getLogTime_DATATIME_DATE_MONTH(timestamp)
	return M.timestampToSqlDATETIME(timestamp),M.timestampToSqlDATE(timestamp),M.timestampToSqlMonth(timestamp)
end

function M.clone(t)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(t)
end

--key为intstr 且没有回引用的t
function M.intStrKeyClone(t,unCopyKeyMap1)
	if unCopyKeyMap1 == nil then unCopyKeyMap1 = {} end
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			if unCopyKeyMap1[key] == nil then
				new_table[key] = _copy(value)
			end
		end
		return new_table
	end
	return _copy(t)
end

function M.string_split(str,sep)
	local t = {}
	local p = string.format("([^%s]+)",sep)
	string.gsub(str,p,function(c)t[#t+1]= c end)
	return t
end

function M.strint_split(str,sep)
	local t = {}
	local p = string.format("([^%s]+)",sep)
	string.gsub(str,p,function(c)t[#t+1]=tonumber(c) or c end)
	return t
end

function M.printBit(v)
	local str = M.getBitStr(v)
	level_log.info(str)
end
function M.getBitStr(v)
	local str = {}
	for i=1,64 do
		local bit = 1 << (i-1)
		if v >= bit then
			if (v & bit) ~= 0 then
				str[#str+1] = 1
			else
				str[#str+1] = 0
			end
		end
	end
	local ret = {}
	local len = #str
	local strr = {}
	for i,vv in ipairs(str) do
		strr[#strr+1] = vv
		if i % 4 == 0 then
			strr[#strr+1] = ","
		end
	end
	local olen = len
	len = #strr
	for i,vv in ipairs(strr) do
		ret[len-i] = vv
	end
	local s = table.concat(ret,"")
	return "len="..(olen-1).." v="..s
end

function M.getCallStack(name)
	local strT = {name}
	local startLevel = 2
	local maxLevel = 100
	for level = startLevel, maxLevel do
		local info = debug.getinfo( level,"nSl" )
		if info == nil then break end
		if info.currentline > 0 then
			local ns = info.name or ""
			local ss = info.source or ""
			strT[#strT+1] = string.format("[line:%-4d] %-20s::%s", info.currentline, ns,ss )
		end
	end
	return table.concat(strT,"\n")
end


function M.bsonpack(t)
	return tostring(bson_encode(t))
end

function M.bsonunpack(str)
	return bson_decode(str)
end

local function emptyf()
end
function M.catchRequire(str)
	return xpcall(function() return require(str) end,emptyf)
end

function M.encodeURI(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])", function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end

function M.decodeURI(s)
	if(s) then
		s = string.gsub(s, '%%(%x%x)',function (hex) return string.char(tonumber(hex,16)) end )
	end
	return s
end

return M
