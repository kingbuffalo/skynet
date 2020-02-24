local skynet = require "skynet"

skynet.start(function()
	local m = require("game/room/matchM")
	skynet.dispatch("lua", function(_,_,cmd,...)
		local f = assert(m[cmd],"function not found " .. cmd)
		skynet.ret(skynet.pack(f(...)))
	end)
end)
