local cmdM = {}

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local dbHeroTbl = require("game.db.dbHeroTbl")
	local t = dbHeroTbl.getHeroTblT(cmdVO.pid)
	return {heroInfoT=t}
end

return cmdM
