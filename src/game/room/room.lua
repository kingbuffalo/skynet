local skynet = require "skynet"
local udp_util =  require("game/kcpudp/udp_util")
--local cachedb_util = require("zj/cachedb_util")

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

	--for _,team in pairs(teamT) do
		--for _,v in team.arr do
			--local key = string.format("roomId_%d",v.pid)
			--cachedb_util.set(key,skynet.self())
		--end
	--end

end

function funcT.brocastCmd(sMsg,tMsg)
	for _,team in pairs(teamT) do
		for _,v in team.arr do
			udp_util.pushMsg(v.pid,sMsg,tMsg)
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
