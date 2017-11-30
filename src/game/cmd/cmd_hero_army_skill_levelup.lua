local cmdM = {}

local dbHeroTbl = require("game.db.dbHeroTbl")
local addItemByLoc = require("game.cmd.addItemByLoc")

local army_skill = require("game.config.army_skill")
local army_skill_start = require("game.config.army_skill_start")
local army_cfg = require("game.config.army_cfg")
local hero = require("game.config.hero")
local enum = require("game.config.enum")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1
	local armySkillType = cmdVO.p2

	local heroCfg = hero[heroId]
	if heroCfg == nil then return {err=1} end
	local army_cfgCfg = army_cfg[heroCfg.army_type]
	if army_cfgCfg == nil then return {err=2} end
	local armySkillIdx = army_cfgCfg.skill_type[armySkillType]
	if  armySkillIdx == nil then return {err=3} end

	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=4} end
	local toLearnSkillId = heroTbl.askillIds[armySkillIdx]
	if toLearnSkillId == 0 then
		toLearnSkillId = army_skill_start[heroCfg.army_type]
	else
		local army_skillCfg = army_skill[toLearnSkillId]
		if army_skillCfg.next == 0 then return {err=5} end
		toLearnSkillId = army_skillCfg.next
	end
	local army_skillCfgToLearn = army_skill[toLearnSkillId]
	local loc = addItemByLoc.removeNeedResCfg(pid,army_skillCfgToLearn.need_res,1,nil)
	if loc ~= 0 then return {err=enum.LOC_ERR_BEGIN+loc} end
	heroTbl.askillIds[armySkillIdx] = toLearnSkillId
	return {err=0}
end

function cmdM.close()
end

return cmdM
