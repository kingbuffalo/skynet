local skynet = require "skynet"

local cmdv = ...
cmdv = tonumber(cmdv)

skynet.start(function()
	local cmdconst = require("game.cmd.cmdconst")
	local cmdName = cmdconst.getCmdFn(cmdv)
	local cmd = require("game.cmd."..cmdName)
	cmd.init()

	skynet.dispatch("lua", function(_,_,funcName,...)
		local cmdvo,timeIdx = ...
		local msg = cmd[funcName](cmdvo,timeIdx)
		if msg ~= nil then
			skynet.ret(skynet.pack(msg))
		else
			skynet.ret(skynet.pack(nil,0))
		end
	end)
end)
