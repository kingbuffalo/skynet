local cmdM = {}
local tonumber = tonumber
local utilsFunc = require("utils.utilsFunc")
local dbCityTbl = require("game.db.dbCityTbl")
local dbHeroTbl = require("game.db.dbHeroTbl")
local dbBuildTbl = require("game.db.dbBuildTbl")
local mapInfoMgr = require("game.cmd.mapInfoMgr")

local enum = require("game.config.enum")
local city = require("game.config.city")
local army_cfg = require("game.config.army_cfg")

local gameUtils = require("game.db.gameUtils")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx,mapInfo)
	local _=timeIdx
	local pid = cmdVO.pid
	local p4 = cmdVO.p4
	local tx,ty,heroId,fHeroId1,fHeroId2,coin,bleed,food
	local p4t = utilsFunc.string_split(p4,",")
	tx=tonumber(p4t[1])
	ty=tonumber(p4t[2])
	heroId=tonumber(p4t[3])
	fHeroId1=tonumber(p4t[4])
	fHeroId2=tonumber(p4t[5])
	coin=tonumber(p4t[6])
	bleed=tonumber(p4t[7])
	food=tonumber(p4t[8])
	local mapId = cmdVO.p1
	local skillId = cmdVO.p2
	local targetId = cmdVO.p3

	--check begin
	if mapId ~= enum.GLOBAL_MAP_ID then return {err=1} end  --地图不合理 目前只有一个地图所以这样判断
	local enemyMOT
	if skillId ~= 0 then
		enemyMOT = mapInfo.mapObjectTblT[targetId]
		if enemyMOT == nil then return {err=3} end
		if not enemyMOT.bVaild then return {err=3} end
		if enemyMOT.bleed == 0 then return {err=3} end
	end
	local heroTbl = dbHeroTbl.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=5} end
	local cityId = heroTbl.cityId
	local cityTbl = dbCityTbl.getCityTbl(pid,cityId)
	if cityTbl == nil then return {err=4} end
	local err,heroInCityTbl,fHeroInCityTbl1,fHeroInCityTbl2
	heroInCityTbl,err = dbCityTbl.errCodeVaildHero(cityTbl,heroId,6,7)
	if err ~=0 then return {err=err} end
	fHeroInCityTbl1,err = dbCityTbl.errCodeVaildHero(cityTbl,fHeroId1,8,9)
	if err ~=0 then return {err=err} end
	fHeroInCityTbl2,err = dbCityTbl.errCodeVaildHero(cityTbl,fHeroId2,10,11)
	if err ~=0 then return {err=err} end

	local cityCfg = city[cityTbl.cityId]
	local fx,fy = cityCfg.x,cityCfg.y

	--check can be reach or not
	local astar = require("utils.astar")
	local len = 10
	local w,h = enum.GLOBAL_MAP_W,enum.GLOBAL_MAP_H
	local xyMapAntiLen = mapInfoMgr.getXYMapAntiLen(enum.MO_TYPE_ARMY,mapInfo,w,h,len)
	local path = astar.astar({x=fx,y=fy},{x=tx,y=ty},w,h,len,xyMapAntiLen)
	if path == nil then return {err=5} end
	--check end

	local morale = cityTbl.res[enum.CITY_RES_MORALE]
	cityTbl.res[enum.CITY_RES_FOOD] = cityTbl.res[enum.CITY_RES_FOOD] - food
	cityTbl.res[enum.CITY_RES_COIN] = cityTbl.res[enum.CITY_RES_COIN] - coin
	cityTbl.res[enum.CITY_RES_SOLDIER] = cityTbl.res[enum.CITY_RES_SOLDIER] - bleed
	local armyMOT = mapInfoMgr.createArmy(mapInfo,heroId,fHeroId1,fHeroId2,coin,bleed,food,tx,ty,morale,heroTbl)

	heroInCityTbl.status = enum.CITY_HERO_STATUS_FIGHT
	local armyMoId = armyMOT.moId
	heroInCityTbl.values[1] = armyMoId
	if fHeroInCityTbl1 ~= nil then
		fHeroInCityTbl1.status = enum.CITY_HERO_STATUS_FIGHT
		fHeroInCityTbl1.values[1] = armyMoId
	end
	if fHeroInCityTbl2 ~= nil then
		fHeroInCityTbl2.status = enum.CITY_HERO_STATUS_FIGHT
		fHeroInCityTbl2.values[1] = armyMoId
	end

	if enemyMOT ~= nil then
		local armyType = heroTbl.armyType
		local army_cfgCfg = army_cfg[armyType]
		local atkRange = army_cfgCfg.atk_range
		if gameUtils.bCanAttack(tx,ty,enemyMOT.posX,enemyMOT.posY,atkRange) then
			gameUtils.doSkill(armyType,enemyMOT,mapInfo,skillId)
		end
	end

	-----------save db begin
	dbCityTbl.setCityTbl(pid,cityTbl)
	local buildId = heroTbl.buildId
	if buildId ~= 0 then
		local buildTbl = dbBuildTbl.getBuildTbl(pid,cityId,buildId)
		dbBuildTbl.buildTblLeftHero(buildTbl)
		dbBuildTbl.setBuildTbl(pid,buildTbl)
	end
	-----------save db end

	return {err=0}
end

function cmdM.close()
end

return cmdM
