local M = {_name=nil,
	_requireAddr = nil,
}
local sharetable = require "skynet.sharetable"

function M.InitData(name,t)
	M._name = name
	local cfg_func = require("game/cfgmgr/cfg_func")
	return cfg_func.k1v(t,"ID")
end

function M.getItem(id)
	if M._requireAddr == nil then
		local skynet = require("skynet")
		M._requireAddr = skynet.self()
		--skynet.send(xxx,"lua","nameMapAddr",M._name,M._requireAddr)
	end
	local t = sharetable.query(M._name)
	return t[id]
end

return M
