local skynet = require "skynet"

local udpd

local funcT = {}
local teamT = {}

function funcT.createRoom(ackIngInfo1,ackIngInfo2)
	teamT[ackIngInfo1.teamType] = ackIngInfo1.arr
	teamT[ackIngInfo2.teamType] = ackIngInfo2.arr
	local tMatchP = {
		team1 = ackIngInfo1.arr,
		team2 = ackIngInfo2.arr
	}
	funcT.brocastCmd("MatchP",tMatchP)
end

function funcT.brocastCmd(sMsg,tMsg)
	if udpd == nil then
		udpd = skynet.queryservice("game/udpd")
	end

	for _,team in pairs(teamT) do
		for _,v in team.arr do
			skynet.send(udpd,"lua","pushMsg",v.pid,sMsg,tMsg)
		end
	end
end

---------------------------------------------------------------------

skynet.start(function()
	skynet.dispatch("lua", function(_,_,funcName,...)
		local f = assert(funcT[funcName],"function not found " .. funcName)
		skynet.ret(skynet.pack(f(...)))
	end)
end)
