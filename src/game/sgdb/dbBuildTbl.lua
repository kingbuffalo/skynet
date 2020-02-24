local M = {}

local name = require("game.db.keyNameCfg")

local build_level = require("game.config.build_level")

local function getSqrtV(base,max,cv,v,vb)
	if cv > max then return v+vb end
	local tw = max-base
	local w = cv-base
	local ev = w/tw
	local er = math.sqrt(ev)
	return math.floor(er * v + vb)
end

function M.buildTblSetHero(buildTbl,heroTbl)
	local blCfg = build_level[buildTbl.buildId][buildTbl.level]
	local attrEnum = blCfg.hero_add_max[1]
	local dbHeroTbl = require("game.db.dbHeroTbl")
	local heroAttr = dbHeroTbl.getHeroBaseAttr(heroTbl,attrEnum)
	local attrMax = blCfg.hero_add_max[2]
	local mulMax = blCfg.hero_add_max[3]
	local v = getSqrtV(0,attrMax,heroAttr,mulMax,0)
	buildTbl.heroAttrMul = math.floor(v)
	buildTbl.heroId = heroTbl.heroId
end

function M.buildTblLeftHero(buildTbl)
	buildTbl.heroId = 0
	buildTbl.heroAttrMul = 0
end


local function getKey(pid,cityId)
	return "p"..pid.."_"..name.build.."_"..cityId
end

function M.newBuildTbl(cityId,buildId)
	return { buildId = buildId,
		cityId=cityId,
		heroId = 0, level = 1,
		heroAttrMul = 0,}
end

function M.getBuildTbl(pid,cityId,buildId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid,cityId)
	local t = ssdbutils.execute("hgets",key,buildId)
	return t
end

function M.setBuildTbl(pid,buildTbl)
	local ssdbutils = require("utils.db.ssdbutils")
	local cityId = buildTbl.cityId
	local key = getKey(pid,cityId)
	return ssdbutils.sendExecute("hsets",key,buildTbl.buildId,buildTbl)
end

function M.getBuildTblT(pid,cityId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid,cityId)
	local t = ssdbutils.execute("hgetalls",key)
	return t
end

function M.setBuildTblT(pid,cityId,buildTblT)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid,cityId)
	return ssdbutils.sendExecute("hsetalls",key,buildTblT)
end

return M
