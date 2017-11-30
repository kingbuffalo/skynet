local skynet = require "skynet"
--local SERVICENAME = "mapcmdmgr"
local utilsFunc = require("utils.utilsFunc")

skynet.start(function()
	--local cmdconst = require("game.cmd.cmdconst")
	--for i=cmdconst.cmd_start,cmdconst.cmd_end do
		--cmds[i] = skynet.newservice("game/cmd/cmdservice",i)
	--end
	--local mapcmdmgr = skynet.newservice("game/cmd/mapcmdmgr")
	local g_mapserver = skynet.newservice("game/cmd/mapservice",1)
	local maps = {
		g_mapserver,
	}

	skynet.dispatch("lua", function(_,_,funcName,...)
		local cmdvo = ...
		local mapId = cmdvo.p1
		local s = maps[mapId]
		local msg
		if s ~= nil then
			msg = skynet.call(s,"lua",funcName,...)
			print("send cmd")
			utilsFunc.printTable(msg)
		end
		if msg ~= nil then
			skynet.ret(skynet.pack(msg))
		else
			local str = "cmd not found"
			skynet.ret(skynet.pack(str,#str))
		end
	end)
end)
