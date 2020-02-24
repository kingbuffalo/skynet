local cmdM = {}

local dbBagTbl = require("game.db.dbBagTbl")
local dbHeroTbl = require("game.db.dbHeroTbl")

local hero = require("game.config.hero")
local hero_max_star = require("game.config.hero_max_star")
local hero_star = require("game.config.hero_star")
local enum = require("game.config.enum")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1
	local heroCfg = hero[heroId]
	if heroCfg == nil then return {err=1} end
	local starItemId = heroCfg.star_item_id
	local bagTbl = dbBagTbl.getBagTbl(pid,starItemId)
	if bagTbl == nil then return {err=2} end
	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	local toStar = 1
	if heroTbl == nil then
		toStar = heroCfg.gen_star
	else
		toStar = heroTbl.star + 1
		if toStar > hero_max_star then return {err=3} end
	end
	local hero_starCfg = hero_star[toStar]
	local needCount = hero_starCfg.count
	if bagTbl.count < needCount then return {err=4} end
	local addItemByLoc = require("game.cmd.addItemByLoc")
	local loc = addItemByLoc.removeNeedResCfg(pid,hero_starCfg.need_res,1)
	if loc ~= 0 then
		return {err=enum.LOC_ERR_BEGIN+loc}
	end
	bagTbl.count = bagTbl.count - needCount
	dbBagTbl.setBagTbl(pid,bagTbl)
	if heroTbl == nil then
		heroTbl = dbHeroTbl.newHeroTbl(heroId,toStar)
	else
		heroTbl.star = toStar
	end
	dbHeroTbl.setHeroTbl(pid,heroTbl)
	return {err=0}
end

return cmdM
