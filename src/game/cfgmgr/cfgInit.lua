local skynet = require "skynet"
local sharetable = require "skynet.sharetable"

--local funcT = {}
--local nameMapAddrT = {}

--function funcT.nameMapAddr(name,addr)
	--local arr = nameMapAddrT[name] or {}
	--arr[addr] = 1
	--nameMapAddrT[name] = arr
--end

skynet.start(function()
	local tblArr = {
		"cfg_item"
	}
	for _,v in ipairs(tblArr) do
		local t = require("src/game/cfg/"..v)
		local mgr = require("src/game/cfg/"..v.."_mgr")
		t = mgr.InitData(v,t)
		sharetable.loadtable(v,t)
	end

	--skynet.dispatch("lua", function(_,_,funcName,...)
		--local f = assert(funcT[funcName],"function not found " .. funcName)
		--skynet.ret(skynet.pack(f(...)))
	--end)
end)
