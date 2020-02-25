local skynet = require "skynet"
local pidMapRoomId = {}

local funcT = {}
---------------------------------------------------------------------

skynet.start(function()
	skynet.dispatch("lua", function(_,_,funcName,...)
		local f = assert(funcT[funcName],"function not found " .. funcName)
		skynet.ret(skynet.pack(f(...)))
	end)
end)
