local cmdM = {}

local dbBuildTbl = require("game.db.dbBuildTbl")
local dbCityTbl = require("game.db.dbCityTbl")
local addItemByLoc = require("game.cmd.addItemByLoc")
local dbUserPlayerTbl = require("game.db.dbUserPlayerTbl")

local build_level = require("game.config.build_level")
local build_max_level = require("game.config.build_max_level")
local enum = require("game.config.enum")


function cmdM.init()
end

local function getFreeWorkerIdx(pid,cityTbl)
	local playerTbl = dbUserPlayerTbl.getPlayerInfo(pid,true)
	local worker = playerTbl.worker
	local now = os.time()
	for i=1,worker do
		local ti = cityTbl.workerTimestamp[i]
		if ti < now  then return i end
	end
	return 0
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local cityId = cmdVO.p1
	local buildId = cmdVO.p2

	local cityTbl = dbCityTbl.getCityTbl(pid,cityId)
	if cityTbl == nil then return {err=1} end
	local fwIdx = getFreeWorkerIdx(pid,cityTbl)
	if fwIdx == 0 then return {err=2} end

	local bUpdate,buildTblT = dbCityTbl.updateCity(pid,cityTbl,timeIdx,nil)
	local buildTbl
	if buildTblT == nil then
		buildTbl = dbBuildTbl.getBuildTbl(pid,cityId,buildId)
	else
		buildTbl = buildTblT[buildId]
	end
	if buildTbl == nil then return {err=4} end

	local maxLv = build_max_level[buildId]
	if buildTbl.level >= maxLv then return {err=6} end

	local cfg = build_level[buildId]
	local toLv = buildTbl.level+1
	if cfg == nil then return {err=3} end
	cfg = cfg[toLv]
	if cfg == nil then return {err=5} end

	cityTbl.workerTimestamp[fwIdx] = os.time() + cfg.need_seconds

	local err = addItemByLoc.removeNeedResCfg(pid,cfg.need_res,1,cityTbl)
	if err ~= 0 then return {err=enum.LOC_ERR_BEGIN+err} end

	buildTbl.level = toLv
	dbCityTbl.setCityTbl(pid,cityTbl)
	dbBuildTbl.setBuildTbl(pid,buildTbl)

	return {err=0}
end

return cmdM
