local cmdM = {}

local enum = require("game.config.enum")

local dbHeroTbl = require("game.db.dbHeroTbl")
local dbCityTbl = require("game.db.dbCityTbl")
local dbBuildTbl = require("game.db.dbBuildTbl")
--local utilsFunc = require("utils.utilsFunc")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1
	local toCityId = cmdVO.p2

	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=1} end

	local cityId = heroTbl.cityId
	local cityTbl = dbCityTbl.getCityTbl(pid,cityId)
	if cityTbl == nil then return {err=2} end

	local heroInCityTbl = cityTbl.heroInCityTblT[heroId]
	if heroInCityTbl == nil then return {err=4} end
	if heroInCityTbl.status ~= enum.CITY_HERO_STATUS_FREE
		and heroInCityTbl.status ~= enum.CITY_HERO_STATUS_WORKING then
		return {err=5}
	end

	local toCityTbl = dbCityTbl.getCityTbl(pid,toCityId)
	if toCityTbl == nil then return {err=3} end

	if heroTbl.buildId ~= 0 then
		local buildTbl = dbBuildTbl.getBuildTbl(pid,cityId,heroTbl.buildId)
		dbBuildTbl.buildTblLeftHero(buildTbl)
		dbBuildTbl.setBuildTbl(pid,buildTbl)
		heroTbl.buildId = 0
		dbHeroTbl.setHeroTbl(pid,heroTbl)
	end
	heroInCityTbl.status = enum.CITY_HERO_STATUS_MOVE
	heroInCityTbl.values = heroInCityTbl.values or {}
	heroInCityTbl.values[1] = toCityId
	heroInCityTbl.values[2] = timeIdx
	dbCityTbl.setCityTbl(pid,cityTbl)

	return {err=0}
end

function cmdM.close()
end

return cmdM
