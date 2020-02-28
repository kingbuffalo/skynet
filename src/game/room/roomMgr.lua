local skynet = require "skynet"
local pidMapRoomAddr = {}

local funcT = {}

function funcT.createRoom(ackIngInfo1,ackIngInfo2)
	local roomAddr = skynet.newservice("game/room/room")
	skynet.send(roomAddr,"lua","createRoom",ackIngInfo1,ackIngInfo2)
	for _,v in ackIngInfo1.arr do
		pidMapRoomAddr[v.pid] = roomAddr
	end
	for _,v in ackIngInfo2.arr do
		pidMapRoomAddr[v.pid] = roomAddr
	end
end

function funcT.bHasRoom(pid)
	return pidMapRoomAddr[pid] ~= nil
end


---------------------------------------------------------------------

skynet.start(function()
	skynet.dispatch("lua", function(_,_,funcName,...)
		local f = assert(funcT[funcName],"function not found " .. funcName)
		skynet.ret(skynet.pack(f(...)))
	end)
end)
