local skynet = require "skynet"
local sharetable = require "skynet.sharetable"

local funcT = {}
local tAddrMap1 = {}

function funcT.registUseCfgAddr(addr)
	if addr ~= skynet.self() then
		tAddrMap1[addr] = 1
	end
end

function funcT.unRegistUseCfgAddr(addr)
	tAddrMap1[addr] = nil
end

function funcT.updateCfg(cfgName)
	local t = require("game/cfg/"..cfgName)
	local mgr = require("game/cfgmgr/"..cfgName.."_mgr")
	t = mgr.InitData(cfgName,t)
	sharetable.loadtable(cfgName,t)

	for addr,_ in pairs(tAddrMap1) do
		skynet.send(addr,"lua","updateCfg",cfgName)
	end
end


skynet.start(function()
	local tblArr = {
		"cfg_item"
	}
	for _,v in ipairs(tblArr) do
		local t = require("game/cfg/"..v)
		local mgr = require("game/cfgmgr/"..v.."_mgr")
		t = mgr.InitData(v,t)
		sharetable.loadtable(v,t)
	end

	skynet.dispatch("lua", function(_,_,funcName,...)
		local f = assert(funcT[funcName],"function not found " .. funcName)
		skynet.ret(skynet.pack(f(...)))
	end)
end)
