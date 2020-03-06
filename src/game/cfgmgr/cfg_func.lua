local M = {}

function M.k1v(arr,keyName)
	local ret = {}
	for _,v in ipairs(arr) do
		ret[v[keyName]] = v
	end
	return ret
end

function M.thisServiceUseCfg(funcT)
	local skynet = require("skynet")
	local addr = skynet.queryservice("game/cfgmgr/cfgInit")
	skynet.send(addr,"lua","registUseCfgAddr",skynet.self())
	funcT.updateCfg = function(cfgName)
		local sharetable = require "skynet.sharetable"
		sharetable.update(cfgName)
	end
end

function M.onServiceExit()
	local skynet = require("skynet")
	local addr = skynet.queryservice("game/cfgmgr/cfgInit")
	skynet.send(addr,"lua","unRegistUseCfgAddr",skynet.self())
end

return M
