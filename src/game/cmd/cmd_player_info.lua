local cmdM = {}

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local dbUserPlayerTbl = require("game.db.dbUserPlayerTbl")
	local t = dbUserPlayerTbl.getPlayerInfo(cmdVO.pid,true)
	return t
end

return cmdM
