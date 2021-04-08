local M = {}
local skynet = require("skynet")
local protobuf = require "protobuf"

local service_name = "zj/redisd"
local redisd

local function callSetAndGetCmd(probufName,cmd,...)
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

local function callSetAndGetCmdBson(cmd,...)
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

local function callSetAndGetCmdJson(cmd,...)
	cmd = string.lower(cmd)
	local serpent = require("serpent")
	local level_log = require("zjutils/level_log")
	if cmd == "set" then
		local k,v = ...
		local str = serpent.strNumKeyDump(v)
		level_log.trace("redis set",k,str)
		return skynet.call(redisd,"lua",cmd,k,str)
	elseif cmd == "get" then
		local res = skynet.call(redisd,"lua",cmd,...)
		level_log.trace("redis get ",...)
		if res == nil then return nil end
		local ok,d = serpent.load(res)
		level_log.trace(ok and res)
		assert(ok==true,ok)
		return d
	end
	return nil
end

local function sendSetAndGetCmd(probufName,cmd,...)
	cmd = string.lower(cmd)
	if cmd == "set" then
		local k,v = ...
		local str = protobuf.encode(probufName,v)
		skynet.send(redisd,"lua",cmd,k,str)
		return true
	end
	return false
end

function M.callRedisBson(cmd,...)
	local ret = callSetAndGetCmdBson(redisd,cmd,...)
	if ret ~= nil then
		return ret
	end
	return skynet.call(redisd,"lua",cmd,...)
end

function M.callRedisJson(cmd,...)
	local ret = callSetAndGetCmdJson(redisd,cmd,...)
	if ret ~= nil then
		return ret
	end
	return skynet.call(redisd,"lua",cmd,...)
end

function M.callRedisProtoBuf(probufName,cmd,...)
	local ret = callSetAndGetCmd(redisd,probufName,cmd,...)
	if ret ~= nil then
		return ret
	end
	return skynet.call(redisd,"lua",cmd,...)
end

function M.init(addr)
	redisd = addr
end

function M.sendRedisProtoBuf(probufName,cmd,...)
	if not sendSetAndGetCmd(redisd,probufName,cmd,...) then
		skynet.send(redisd,"lua",cmd,...)
	end
end

return M
