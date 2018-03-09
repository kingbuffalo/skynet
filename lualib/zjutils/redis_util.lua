local M = {}
local skynet = require("skynet")
local protobuf = require "protobuf"

local service_name = "zj/redisd"

--local function cmpT(t1,t2)
	--if t1==t2 then return true end
	--for k,v in pairs(t1) do
		--local v2 = assert(t2[k])
		--local vt = type(v2)
		--if vt == "table" then
			--return cmpT(v,v2)
		--else
			--if v~=v2 then return false end
		--end
	--end
	--return true
--end

local function callSetAndGetCmd(redisd,probufName,cmd,...)
	cmd = string.lower(cmd)
	if cmd == "set" then
		local k,v = ...
		local str = protobuf.encode(probufName,v)
		return skynet.call(redisd,"lua",cmd,k,str)
	elseif cmd == "get" then
		local res = skynet.call(redisd,"lua",cmd,...)
		if res == nil then return nil end
		local d = protobuf.decode(probufName,res)
		return d
	end
	return nil
end

local function callSetAndGetCmdBson(redisd,probufName,cmd,...)
	cmd = string.lower(cmd)
	if cmd == "set" then
		local k,v = ...
		return skynet.call(redisd,"lua","bson_set",k,v)
	elseif cmd == "get" then
		local res = skynet.call(redisd,"lua","bson_get",...)
		if res == nil then return nil end
		return res
	end
	return nil
end

local _ = callSetAndGetCmdBson

local function callSetAndGetCmdJson(redisd,probufName,cmd,...)
	cmd = string.lower(cmd)

	return callSetAndGetCmdBson(redisd,probufName,cmd,...)
	--local serpent = require("serpent")
	--local level_log = require("zjutils/level_log")
	--if cmd == "set" then
		--local k,v = ...
		--local str = serpent.strNumKeyDump(v)
		--level_log.trace("redis set",k,str)
		--return skynet.call(redisd,"lua",cmd,k,str)
	--elseif cmd == "get" then
		--local res = skynet.call(redisd,"lua",cmd,...)
		--level_log.trace("redis get ",...)
		--if res == nil then return nil end
		--local ok,d = serpent.load(res)
		--level_log.trace(ok and res)
		--assert(ok==true,ok)
		--return d
	--end
	--return nil
end

local function sendSetAndGetCmd(redisd,probufName,cmd,...)
	cmd = string.lower(cmd)
	if cmd == "set" then
		local k,v = ...
		local str = protobuf.encode(probufName,v)
		skynet.send(redisd,"lua",cmd,k,str)
		return true
	end
	return false
end

function M.callRedisJson(probufName,cmd,...)
	local redisd = skynet.queryservice(service_name)
	local ret = callSetAndGetCmdJson(redisd,probufName,cmd,...)
	if ret ~= nil then
		return ret
	end
	return skynet.call(redisd,"lua",cmd,...)
end

function M.callRedis(probufName,cmd,...)
	local redisd = skynet.queryservice(service_name)
	local ret = callSetAndGetCmd(redisd,probufName,cmd,...)
	if ret ~= nil then
		return ret
	end
	return skynet.call(redisd,"lua",cmd,...)
end

function M.sendRedis(probufName,cmd,...)
	local redisd = skynet.queryservice(service_name)
	if not sendSetAndGetCmd(redisd,probufName,cmd,...) then
		skynet.send(redisd,"lua",cmd,...)
	end
end

return M
