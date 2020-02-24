local M = {}

function M.recCmd(protoVO)
	local name = protoVO.name
	local passwd = protoVO.passwd
	local dbUserTbl = require("game/db/dbUserTbl")
	local userT = dbUserTbl.getUser(name)
	if userT == nil then
		local pid = dbUserTbl.getMaxPlayerId() + 1
		dbUserTbl.setMaxPlayerId(pid)
		userT = dbUserTbl.NewUser(pid,name,passwd)
	end

	return 0,20001,{pid=userT.pid}
end

return M
