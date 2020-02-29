local skynet = require "skynet"

local M = {}

local _serverAddr

local function getAddr()
	if _serverAddr == nil then
		_serverAddr = skynet.queryservice("zj/cachedb")
	end
	return _serverAddr
end

function M.set(key,value,bForEver)
	skynet.send(getAddr(),"lua","set",key,value,bForEver)
end

function M.get(key)
	return skynet.call(getAddr(),"lua","get",key)
end

return M
