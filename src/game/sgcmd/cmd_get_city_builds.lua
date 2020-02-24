local cmdM = {}

local dbBuildTbl = require("game.db.dbBuildTbl")
local dbCityTbl = require("game.db.dbCityTbl")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local cityId = cmdVO.p1

	local t = dbBuildTbl.getBuildTblT(pid,cityId)
	local cityTbl = dbCityTbl.getCityTblT(pid)
	if dbCityTbl.updateCity(pid,cityTbl,timeIdx,t) then
		dbCityTbl.setCityTbl(pid,cityTbl)
	end
	return {buildT=t}
end

function cmdM.close()
end

return cmdM
