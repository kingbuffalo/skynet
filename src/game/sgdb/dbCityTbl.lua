local M = {}


local name = require("game.db.keyNameCfg")
local build_level = require("game.config.build_level")
local enum = require("game.config.enum")

local function getKey(pid)
	return "p"..pid.."_"..name.city
end

local function calcBuildGain(pid,cityTbl,timeIdx,buildTblT)
	local dbBuildTbl = require("game.db.dbBuildTbl")
	if buildTblT == nil then
		local cityId = cityTbl.cityId
		buildTblT = dbBuildTbl.getBuildTblT(pid,cityId)
	end
	local passTime = timeIdx-cityTbl.timeIdx
	local additembyloc = require("game.cmd.additembyloc")
	for _,v in pairs(buildTblT) do
		local cfg = build_level[v.buildId][v.level]
		local function outFunc(loc,id,co)
			local _,_ = loc,id
			local ret = co*passTime
			if buildTblT.heroAttrMul ~= 0 then
				ret = ret + ret*(buildTblT.heroAttrMul/enum.TEN_THOUSAND)
			end
			return math.floor(ret)
		end
		additembyloc.addOutResCfgFunc(pid,cfg.out_res,outFunc,cityTbl)
	end
	return buildTblT
end

local function moveHero(pid,cityTbl,timeIdx)
	local cityIdMap_toCityTbl = {}
	for k,v in pairs(cityTbl.heroInCityTblT) do
		if v.status == enum.CITY_HERO_STATUS_MOVE then
			local vt = v.values[2]
			if vt <= timeIdx then
				local toCityId = v.values[1]
				local toCityTbl = M.getCityTbl(pid,toCityId)
				v.status = enum.CITY_HERO_STATUS_FREE
				toCityTbl.heroInCityTblT[k] = v
				cityIdMap_toCityTbl[toCityId] = toCityTbl
				cityTbl.heroInCityTblT[k] = nil
			end
		end
	end
	for _,v in pairs(cityIdMap_toCityTbl) do
		M.setCityTbl(pid,v)
	end
end

function M.errCodeVaildHero(cityTbl,heroId,notInThisCityErrCode,busyErrCode)
	if heroId == 0 then return nil,0 end
	local heroInCityTbl = cityTbl.heroInCityTblT[heroId]
	if heroInCityTbl == nil then return nil,notInThisCityErrCode end
	if heroInCityTbl.status ~= enum.CITY_HERO_STATUS_FREE
		and heroInCityTbl.status ~= enum.CITY_HERO_STATUS_WORKING then
		return nil,busyErrCode
	end
	return heroInCityTbl,0
end

function M.newHeroInCityTbl(heroId)
	return { heroId=heroId,
		status = enum.CITY_HERO_STATUS_FREE,
		values = {} }
end

function M.createMoveHero(heroId,cityId,timeIdx)
	return {heroId=heroId,cityId=cityId,timeIdx=timeIdx}
end

function M.updateCity(pid,cityTbl,timeIdx,buildTblT)
	if cityTbl.timeIdx == timeIdx then return false,nil end

	buildTblT = calcBuildGain(pid,cityTbl,timeIdx,buildTblT)

	moveHero(pid,cityTbl,timeIdx)

	cityTbl.timeIdx = timeIdx

	return true,buildTblT
end

function M.newCityTbl(cityId,bleed,coin,food,timeIdx)
	local t = { cityId = cityId,
		level = 1,
		bleed = bleed,
		mayor = 0,
		res = {0,0,0,0,
					0,0,0,0,
					0,0,0,0, },
		status = 0,
		timeIdx = timeIdx,
		workerTimestamp = {0,0,0,0,0},
		heroInCityTblT = {}, }

	t.res[enum.CITY_RES_COIN] = coin
	t.res[enum.CITY_RES_FOOD] = food
	return t
end

function M.getCityTbl(pid,cityId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	local t = ssdbutils.execute("hgets",key,cityId)
	return t
end

function M.setCityTbl(pid,cityTbl)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	return ssdbutils.sendExecute("hsets",key,cityTbl.cityId,cityTbl)
end

function M.getCityTblT(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	local t = ssdbutils.execute("hgetalls",key)
	return t
end

function M.setCityTblT(pid,cityTblT)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	return ssdbutils.sendExecute("hsetalls",key,cityTblT)
end

return M
