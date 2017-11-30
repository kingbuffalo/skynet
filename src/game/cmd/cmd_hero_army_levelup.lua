local cmdM = {}

local dbHeroTbl = require("game.db.dbHeroTbl")
local addItemByLoc = require("game.cmd.addItemByLoc")

local army_max_level = require("game.config.army_max_level")
local army_level = require("game.config.army_level")
local hero = require("game.config.hero")
local enum = require("game.config.enum")
local allArmyWeaponCmpFalg = 30

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1

	local heroCfg = hero[heroId]
	if heroCfg == nil then return {err=3} end
	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=1} end
	if heroTbl.aweapon ~= allArmyWeaponCmpFalg then return {err=2} end

	local armyTy = heroCfg.army_type
	local armyLv = heroTbl.alv
	if armyLv >= army_max_level then return {err=4} end

	local army_levelCfg = army_level[armyTy][armyLv]
	if army_levelCfg == nil then return {err=5} end

	local err = addItemByLoc.removeNeedResCfg(pid,army_levelCfg.need_res,1)
	if err ~= 0 then return {err=err+enum.LOC_ERR_BEGIN} end

	heroTbl.aweapon = 0
	heroTbl.alv = heroTbl.alv + 1
	return {err=0}
end

return cmdM
