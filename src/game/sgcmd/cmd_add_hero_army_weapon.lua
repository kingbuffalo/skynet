local cmdM = {}

local hero = require("game.config.hero")
local army_weapon = require("game.config.army_weapon")
local addItemByLoc = require("game.cmd.addItemByLoc")
local dbHeroTbl = require("game.db.dbHeroTbl")
local enum = require("game.config.enum")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1
	local armyWeaponIdx = cmdVO.p2

	if armyWeaponIdx < 0 or armyWeaponIdx > 4 then return {err=2} end

	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=1} end

	local heroCfg = hero[heroId]
	if heroCfg == nil then return {err=3} end

	local army_type = heroCfg.army_type
	local key = "need_res"..armyWeaponIdx
	local army_weaponCfg = army_weapon[army_type][heroTbl.alv]
	if army_weaponCfg == nil then return {err=4} end

	local err = addItemByLoc.removeNeedResCfg(pid,army_weaponCfg[key],1)
	if err ~= 0 then return {err=enum.LOC_ERR_BEGIN+err} end
	heroTbl.aweapon = heroTbl.aweapon | 1 << armyWeaponIdx

	return {err=0}
end

return cmdM
