local M = {}

local name = require("game.db.keyNameCfg")
local hero_star_attr = require("game.config.hero_star_attr")
local hero_level_attr = require("game.config.hero_level_attr")
local hero_level = require("game.config.hero_level")
local army_weapon = require("game.config.army_weapon")
local army_level = require("game.config.army_level")
local hero = require("game.config.hero")
local enum = require("game.config.enum")


local function getHeroKey(pid)
	return "p"..pid.."_"..name.hero
end

function M.newHeroTbl(heroId,star)
	local t = { heroId=heroId,
		armyType = 1,
		lv = 1,
		exp = 0,
		star = star,
		alv = 1,
		askillIds = {0,0,0,0},
		aweapon = 0,
		buildId = 0,
		cityId = 0,
		armyId = 0, }

	local heroCfg = hero[heroId]
	t.armyType = heroCfg.army_type
	return t
end

function M.getFightInfo(heroTbl)
	local heroAttr = {}
	local armyAttr = {}
	local hero_level_attrCfg = hero_level_attr[heroTbl.heroId][heroTbl.lv]
	for k,v in pairs(hero_level_attrCfg.attr) do
		heroAttr[k] = v
	end
	local hero_star_attrCfg = hero_star_attr[heroTbl.heroId][heroTbl.star]
	for k,v in pairs(hero_star_attrCfg.attr) do
		heroAttr[k] = (heroAttr[k] or 0 ) + v
	end

	local armyLv = heroTbl.alv
	local armyType = heroTbl.armyType
	local army_levelCfg = army_level[armyType][armyLv]
	for k,v in pairs(army_levelCfg.attr) do
		armyAttr[k] = v
	end

	local armyWeapon = heroTbl.aweapon
	local army_weaponCfg = army_weapon[armyType][armyLv]
	for i=1,enum.ARMY_SKILL_NUM do
		if (armyWeapon & (1 << i) ~= 0 ) then
			local cfgKey = "attr" .. i
			local attr = army_weaponCfg[cfgKey]
			for k,v in pairs(attr) do
				armyAttr[k] = (armyAttr[k] or 0 ) + v
			end
		end
	end
	local hero_levelCfg = hero_level[heroTbl.lv]
	local maxBleed = hero_levelCfg.max_bleed
	return heroAttr,armyAttr,maxBleed
end

function M.getHeroTbl(pid,heroId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getHeroKey(pid)
	local t = ssdbutils.execute("hgets",key,heroId)
	return t
end

function M.setHeroTbl(pid,heroTbl)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getHeroKey(pid)
	return ssdbutils.sendExecute("hsets",key,heroTbl.heroId,heroTbl)
end

function M.getHeroTblT(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getHeroKey(pid)
	local t = ssdbutils.execute("hgetalls",key)
	return t
end

function M.setHeroTblT(pid,heroTblT)
	local key = getHeroKey(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	ssdbutils.sendExecute("hsetalls",key,heroTblT)
end

--只算基本的，可能战斗中的会不一样
function M.getHeroBaseAttr(heroTbl,attr)
	local id,lv = heroTbl.heroId,heroTbl.lv
	local lvcfg = hero_level_attr[id][lv]
	local star = heroTbl.star
	local starCfg = hero_star_attr[id][star]
	local lvAttr = lvcfg[attr] or 0
	local starAttr = starCfg[attr] or 0
	return lvAttr+starAttr
end

return M
