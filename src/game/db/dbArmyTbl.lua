--local name = require("game.db.keyNameCfg")

--local M = {}

--function M.createTimeBuffTbl(buffId,endTimeIdx,effAttrValue)
	--return {buffId=buffId,
			--effAttrValue=effAttrValue,
			--endTimeIdx=endTimeIdx,}
--end

--function M.newArmyTbl(armyId,mapId,timeIdx,armyAttrT,heroAttrT,bleed,maxBleed,food,coin,morale,skillIds,heroId,fHeroId1,fHeroId2,posX,posY,targetArr,strategy)
	--return { heroId = heroId,
			--flowerHeroIdArr = {fHeroId1,fHeroId2},
			--food = food,
			--coin = coin,
			--skillIds = skillIds,
			--maxBleed = maxBleed,
			--morale = morale,
			--bleed = bleed,
			--armyId = armyId,
			--mapId = mapId,
			--targetArr = targetArr,
			--strategy = strategy,
			--heroAttrT = heroAttrT,
			--armyAttrT = armyAttrT,
			--actionMask = 0,
			--timeIdx = timeIdx,
			--timeBuffTblT = {},
			--bitBuffMask = 0,
			--posX = posX, posY = posY, }
--end

--local function getKey(pid,mapId)
	--return "p"..pid.."_"..name.army.."_"..mapId
--end

--function M.getArmyTbl(pid,mapId,armyId)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--local t = ssdbutils.execute("hgets",key,armyId)
	--return t
--end

--function M.setArmyTbl(pid,armyTbl)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local mapId = armyTbl.mapId
	--local key = getKey(pid,mapId)
	--return ssdbutils.sendExecute("hsets",key,armyTbl.armyId,armyTbl)
--end

--function M.getArmyTblT(pid,mapId)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--local t = ssdbutils.execute("hgetalls",key)
	--return t
--end

--function M.setArmyTblT(pid,mapId,armyTblT)
	--local ssdbutils = require("utils.db.ssdbutils")
	--local key = getKey(pid,mapId)
	--return ssdbutils.sendExecute("hsetalls",key,armyTblT)
--end
--return M
