-----------------------------------db oper begin------------------------
--local name = require("game.db.keyNameCfg")
--local M = {}

--local function getKey(pid,mapId)
	--return "p"..pid.."_"..name.enemy.."_"..mapId
--end

--function M.newEnemyTbl(armyId,mapId,timeIdx,armyAttrT,heroAttrT,bleed,maxBleed,food,coin,morale,skillIds,heroId,fHeroId1,fHeroId2,posX,posY,targetArr)
	--local dbArmyTbl = require("sgame.db.dbArmyTbl")
	--return dbArmyTbl.newArmyTbl(armyId,mapId,timeIdx,armyAttrT,heroAttrT,bleed,maxBleed,food,coin,morale,skillIds,heroId,fHeroId1,fHeroId2,posX,posY,targetArr)
--end

--function M.createEnemyByCfg(npcCfg,timeIdx)
	--local armyId = npcCfg.enemy_id
	--local mapId = npcCfg.map_id
	--local _ = timeIdx
	--local armyAttrT = npcCfg.army_attr
	--local heroAttrT = npcCfg.hero_attr
	--local bleed = npcCfg.bleed
	--local maxBleed = npcCfg.max_bleed
	--local food = npcCfg.food
	--local coin = npcCfg.coin
	--local morale = npcCfg.morale
	--local skillIds = npcCfg.skill_ids
	--local heroId = npcCfg.hero_ids[1]
	--local fHeroId1 = npcCfg.hero_ids[2] or 0
	--local fHeroId2 = npcCfg.hero_ids[3] or 0
	--local posX = npcCfg.pos[1]
	--local posY = npcCfg.pos[2]
	--local target = npcCfg.target
	--local strategy = npcCfg.strategy
	--local t = M.newEnemyTbl(armyId,mapId,timeIdx,armyAttrT,heroAttrT,bleed,maxBleed,food,coin,morale,skillIds,heroId,fHeroId1,fHeroId2,posX,posY,target,strategy)
	--return t
--end

--function M.getEnemyTbl(pid,mapId,enemyId)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--local t = ssdbutils.execute("hgets",key,enemyId)
	--return t
--end

--function M.setEnemyTbl(pid,mapId,enemyTbl)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--return ssdbutils.sendExecute("hsets",key,enemyTbl.enemyId,enemyTbl)
--end

--function M.getEnemyTblT(pid,mapId)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--local t = ssdbutils.execute("hgetalls",key)
	--return t
--end

--function M.setEnemyTblT(pid,mapId,enemyTblT)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--return ssdbutils.sendExecute("hsetalls",key,enemyTblT)
--end
-----------------------------------db oper end------------------------
--return M
