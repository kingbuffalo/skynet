local cmdM = {}

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local dbBagTbl = require("game.db.dbBagTbl")
	local t = dbBagTbl.getBagTblT(cmdVO.pid)
	return {bagT=t}
end

return cmdM
