local cmdM = {}

local dbBuildTbl = require("game.db.dbBuildTbl")
local dbCityTbl = require("game.db.dbCityTbl")
local dbHeroTbl = require("game.db.dbHeroTbl")

local enum = require("game.config.enum")


function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local _ = timeIdx
	local pid = cmdVO.pid
	local cityId = cmdVO.p1
	local buildId = cmdVO.p2
	local heroId = cmdVO.p3

	local cityTbl = dbCityTbl.getCityTbl(pid,cityId)
	if cityTbl == nil then return {err=1} end
	local heroInCityTbl = cityTbl.heroInCityTblT[heroId]
	if heroInCityTbl == nil then return {err=2} end
	if heroInCityTbl.status ~= enum.CITY_HERO_STATUS_FREE
		and heroInCityTbl.status ~= enum.CITY_HERO_STATUS_WORKING then
		return {err=6}
	end
	local buildTbl = dbBuildTbl.getBuildTbl(pid,cityId,buildId)
	if buildTbl == nil then return {err=3} end
	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=4} end
	local oldBuildId = heroTbl.buildId
	if oldBuildId ~= 0 and buildId == oldBuildId then return {err=5} end

	if oldBuildId ~= 0 then
		local oldBuildTbl = dbBuildTbl.getBuildTbl(pid,cityId,oldBuildId)
		if oldBuildTbl ~= nil then
			dbBuildTbl.buildTblLeftHero(oldBuildTbl)
			dbBuildTbl.setBuildTbl(pid,oldBuildTbl)
		end
	end

	dbBuildTbl.buildTblSetHero(buildTbl,heroTbl)
	dbBuildTbl.setBuildTbl(pid,buildTbl)

	heroTbl.buildId = buildTbl.buildId
	dbHeroTbl.setHeroTbl(pid,heroTbl)
	heroInCityTbl.status = enum.CITY_HERO_STATUS_WORKING
	dbCityTbl.setCityTbl(pid,cityTbl)

	return {err=0}
end

function cmdM.close()
end

return cmdM
