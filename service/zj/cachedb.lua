local skynet = require "skynet"
local utilsFunc = require("utils/utilsFunc")
local lru_list = require("zjutils/lru_list")
local CACHE_TIME = 2*60*60

local funcT = {}
local lrulist
local forEver = {}

function funcT.set(key,value,bForEver)
	if bForEver == nil then bForEver = false end
	if bForEver then
		lrulist:addValue(value,key)
	else
		forEver[key] = value
	end
end

function funcT.get(key)
	local ret = lrulist:getValue(key)
	if ret == nil then
		return forEver[key]
	end
	return ret.value
end

function funcT.rmValue(key)
	local ret = lrulist:rmValue(key)
	if ret == nil then
		forEver[key] = nil
	end
end

local function checkLru()
	for lruNode in lrulist:rangeReverse() do
		local timestamp = lruNode.timestamp
		local key = lruNode.key
		local current = skynet.time()
		if current-timestamp > CACHE_TIME then
			lrulist:rmValue(key)
		else
			break
		end
	end
end

skynet.start(function()

	lrulist = lru_list.createLRUList()
	skynet.dispatch("lua", function(_,_,funcName,...)
		local f = assert(funcT[funcName],"function not found " .. funcName)
		skynet.ret(skynet.pack(f(...)))
	end)
	utilsFunc.forEver(1000,checkLru)
end)
