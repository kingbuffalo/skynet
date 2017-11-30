--local utilsFunc = require("utils.utilsFunc")
local army_skill =  require("game.config.army_skill")
local army_skill_cfg = require("game.config.army_skill_cfg")
local enum = require("game.config.enum")


local M = {}

function M.getBleedEff(mb,cb,v)
	local ev = cb/mb
	local er = math.sqrt(ev)
	return er * mb * v
end

function M.bCanAttack(x,y,targetX,targetY,atkRange)
	local abs = math.abs
	return abs(targetX-x) <= atkRange and abs(targetY-y) <= atkRange
end

--function M.calcPhAtkPhDefHurt(phAtk,phDef)
	--local hurt = (phAtk*phAtk)/(2*phDef)

	--local rand = math.random(1,200)
	--rand = (rand-100)/1000 + 1
	--hurt = math.floor(hurt*rand)

	--return hurt
--end

--function M.calcDef(aMOT,dMOT,army_skillCfg,army_skill_cfgCfg)
	--local attrEnum
	--if army_skill_cfgCfg.atk_type == enum.ARMY_SKILL_ATK_TYPE_PHY then
		--attrEnum = enum.ARMY_ATTR_PHY_DEF
	--else
		--attrEnum = enum.ARMY_ATTR_MAG_DEF
	--end
	--local def = dMOT.values[enum.ARMY_ATTR_MAP_MOIDX[attrEnum]]
	--local cb = dMOT.values[enum.MOIDX_ARMY_BLEED]
	--local mb = dMOT.values[enum.MOIDX_ARMY_MAX_BLEED]
	--def = M.getBleedEff(mb,cb,def)

	--return def
--end

function M.calcAtk(aMOT,dMOT,army_skillCfg,army_skill_cfgCfg)
	assert(false,"此处并没有武将属性的加成")
	local heroAttr=notfound
	local _=dMOT
	local cb = aMOT.values[enum.MOIDX_ARMY_BLEED]
	local mb = aMOT.values[enum.MOIDX_ARMY_MAX_BLEED]
	local attrEnum
	if army_skill_cfgCfg.atk_type == enum.ARMY_SKILL_ATK_TYPE_PHY then
		attrEnum = enum.ARMY_ATTR_PHY_ATTACK
	else
		attrEnum = enum.ARMY_ATTR_MAG_ATTACK
	end
	local atk = aMOT.values[enum.ARMY_ATTR_MAP_MOIDX[attrEnum]]
	atk = M.getBleedEff(mb,cb,atk)
	atk = atk + army_skillCfg.attr[attrEnum]
	return atk
end

function M.doSkill(aMOT,dMOT,mapInfo,skillId)
	local army_skillCfg = army_skill[skillId]
	local armySkillType = army_skillCfg.type
	local army_skill_cfgCfg = army_skill_cfg[armySkillType]
	local atk = M.calcAtk(aMOT,dMOT,army_skillCfg,army_skill_cfgCfg)

	local armySkillTypeFunc = require("game.db.armySkillTypeFunc")
	local func = armySkillTypeFunc[armySkillType]
	if func ~= nil then
		func(aMOT,dMOT,mapInfo,atk,army_skillCfg,army_skill_cfgCfg)
	else
		assert(false)
	end
end

return M
