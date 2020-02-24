local cmdM = {}

local enum = require("game.config.enum")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local dbUserPlayerTbl = require("game.db.dbUserPlayerTbl")
	local playerTbl = dbUserPlayerTbl.getPlayerInfo(cmdVO.pid)
	if playerTbl.baseRes[enum.BASE_RES_ROUND]<= 0 then return {err=1} end
	playerTbl.baseRes[enum.BASE_RES_ROUND] = playerTbl.baseRes[enum.BASE_RES_ROUND] - 1
	dbUserPlayerTbl.setPlayerInfo(playerTbl)
	return {err=0}
end

function cmdM.close()
end

return cmdM
