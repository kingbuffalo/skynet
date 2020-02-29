local M = {}
local string=string
local math=math

local e_range=1.7182

function M.getLnV(base,max,cv)
	local tw = max-base
	local w = cv-base
	local ev = w/tw * e_range
	local er = math.log(ev+1)
	return er * tw + base
end

function M.string_split(str,sep)
	local t = {}
	local p = string.format("([^%s]+)",sep)
	string.gsub(str,p,function(c)t[#t+1]=c end)
	return t
end

function M.getBleedEff(mb,cb,v)
	local ev = cb/mb
	local er = math.sqrt(ev)
	return er * mb * v
end

function M.getSqrtVPer(base,max,cv)
	local tw = max-base
	local w = cv-base
	local ev = w/tw
	local er = math.sqrt(ev)
	return er * tw + base
end

function M.getIntV(base,max,cv)
	return math.floor(M.getSqrtVPer(base,max,cv))
end

function M.indexOf(arr,value)
	for i, v in ipairs( arr ) do
		if v==value then return i end
	end
	return -1
end

--取打乱的数值数组
local randomCache = {}
function M.genRandomArry( size )
	for i=1, size do
		randomCache[i] = i
	end
	local r
	local random = math.random
	for i=2, size do
		r = random(1,i)
		randomCache[i], randomCache[r] = randomCache[r], randomCache[i]
	end
	randomCache[size + 1] = nil
	return randomCache
end

function M.getCallStack(name)
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

function M.printTable(t)
	local serpent = require("utils.serpent")
	print(serpent.block(t))
end

function M.printCallStack(name)
	local str = M.getCallStack(name)
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
function M.utf8len(str)
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
function M.utf8sub(str, startChar, numChars)
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
function M.utf82_ascii1_len(str)
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
function M.utf82_ascii1_sub(str, startChar, numChars)
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

--如果没有找到，则找到比cmpFunc最小的那个的位置数
function M.bSearch(arr,cmpFunc)
	local left = 1
	local right = #arr
	local mid = (left+right)//2
	while(left <= right) do
		mid = (left+right)//2
		local cmpRet = cmpFunc(arr[mid])
		if cmpRet == -1 then
			left = mid + 1
		elseif cmpRet == 1 then
			right = mid - 1
		else
			return mid
		end
	end
	return mid
end

function M.forEver(timeout,func,...)
	local function f(...)
		local skynet = require "skynet"
		skynet.timeout(timeout,f)
		func(...)
	end
	f(...)
end

return M
