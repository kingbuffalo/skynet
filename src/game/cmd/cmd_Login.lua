local M = {}

function M.recCmd(protoVO,pidUslessParam,from)
	local _ = pidUslessParam
	local name = protoVO.name
	local passwd = protoVO.passwd
	local dbUserTbl = require("game/db/dbUserTbl")
	local userT = dbUserTbl.getUser(name)
	if userT == nil then
		local maxPid = dbUserTbl.getMaxPlayerId() + 1
		dbUserTbl.setMaxPlayerId(maxPid)
		userT = dbUserTbl.NewUser(maxPid,name,passwd)
	end

	local udp_util = require("game/kcpudp/udp_util")
	udp_util.updatePidFrom(from,userT.pid)

	return 0,"LoginR",{pid=userT.pid}
end

return M
