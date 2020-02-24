local cmdM = {}

local dbCityTbl = require("game.db.dbCityTbl")
function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local t = dbCityTbl.getCityTblT(pid)
	return {cityT=t}
end

function cmdM.close()
end

return cmdM
