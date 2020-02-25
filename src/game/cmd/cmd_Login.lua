local M = {}

function M.recCmd(protoVO,pid)
	local _ = pid
	local name = protoVO.name
	local passwd = protoVO.passwd
	local dbUserTbl = require("game/db/dbUserTbl")
	local userT = dbUserTbl.getUser(name)
	if userT == nil then
		local maxPid = dbUserTbl.getMaxPlayerId() + 1
		dbUserTbl.setMaxPlayerId(maxPid)
		userT = dbUserTbl.NewUser(maxPid,name,passwd)
	end

	return 0,20001,{pid=userT.pid}
end

return M
