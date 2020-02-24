local cmdM = {}

local dbBagTbl = require("game.db.dbBagTbl")
local dbHeroTbl = require("game.db.dbHeroTbl")

local hero_level = require("game.config.hero_level")
local hero_max_level = require("game.config.hero_max_level")
local hero_add_exp = require("game.config.hero_add_exp")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1
	local itemId = cmdVO.p2
	local count = cmdVO.p3

	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=1} end

	local hero_add_expCfg = hero_add_exp[itemId]
	if hero_add_expCfg == nil then return {err=2} end

	local bagTbl = dbBagTbl.getBagTbl(pid,itemId)
	if bagTbl == nil then return {err=3} end
	if bagTbl.count < count then return {err=3} end

	local addExp = hero_add_expCfg.exp
	heroTbl.exp = heroTbl.exp + addExp
	if heroTbl.lv < hero_max_level and hero_level[heroTbl.lv].exp < heroTbl.exp then
		for i=heroTbl.lv+1,hero_max_level do
			if heroTbl.exp < hero_level[i].exp then
				heroTbl.lv = i
				break
			end
		end
	end
	bagTbl.count = bagTbl.count - count
	return {err=0,level=heroTbl.lv,exp=heroTbl.exp}
end

return cmdM
