local M = {}
local dbMapObjectTbl = require("game.db.dbMapObjectTbl")
local X_OFFSET = 16

--这个文件用来管理 mapInfo 和 dbMapObjectTbl
--我操，这代码，写的时候只有我跟上帝懂
--现在，只有上帝懂了

--[[
moId   army:10000000   move && attack && reattack   1kw
moId   enemy:20000   move && attack && reattack  读取cfg
moId   city:30000   reattack
moId   tower:40000  attack && reattack
moId   trap:50000  reattack
moId   fire:60000
moId   stone:70000
moId   growstone:80000

MapObject={
	moId,
	mapId,
	values,
	bVaild  -->不放在发送协议中的结构中去
}
TimeBuffTbl{
	endTimeIdx 0 : integer
	buffId 1 : integer
	value 2 : integer
	moId 3 : integer
}
key:pid
value:{
	mapObjectTbl : *MapObjectTbl(moId)
	mapId : integer
	timeIdx = 0,
	timeBuffTbl : *TimeBuffTbl(moId)
	xyMapMoId : integer
	saveMOTT : *MapObjectTbl(moId)
	enemyTblT : *enemyTbl(enmyId) 作废
} ]]

local enum = require("game.config.enum")

function M.createMapInfo(pid,mapId,timeIdx)
	local mtT = dbMapObjectTbl.getMapObjectTblT(pid,mapId)
	local t = {
		mapObjectTblT = mtT,
		timeIdx = timeIdx,
		mapId = mapId,
		saveMOTT = {},
		umotT = {}
	}
	return t
end

function M.getXYMapAntiLen(moType,mapInfo,w,h,len)
	local ret = {}
	local astar = require("utils.astar")
	for _,v in pairs(mapInfo.mapObjectTblT) do
		if v.values[enum.MOIDX_ALL_TYPE] ~= moType then
			local x=v.values[enum.MOIDX_ALL_X]
			local y=v.values[enum.MOIDX_ALL_Y]
			astar.setEnemyPos(x,y,w,h,len,ret)
		end
	end
	return ret
end

function M.saveChangeToDb(pid,mapInfo)
	local mapId = mapInfo.mapId
	dbMapObjectTbl.setMapObjectTblT(pid,mapId,mapInfo.saveMOTT)
	mapInfo.saveMOTT = {}
end

local function getUpdateMapObjectTbl(mapInfo,moId)
	local t = mapInfo.umotT[moId]
	if t == nil then
		t = {moId=moId,
			idxMapValue = {} }
		mapInfo.umotT[moId] = t
	end
	return t
end

local function changeValue(mapInfo,mot,idx,value)
	local moId = mot.moId
	local umot = getUpdateMapObjectTbl(mapInfo,moId)
	umot.idxMapValue[idx] = value
	mot.values[idx] = value
	if mapInfo.saveMOTT[mot.moId] == nil then
		mapInfo.saveMOTT[mot.moId] = mot
	end
end

local function addMapObjectToMapInfo(mapInfo,mapObjectTbl)
	local x = mapObjectTbl.values[enum.MOIDX_ALL_X]
	local y = mapObjectTbl.values[enum.MOIDX_ALL_X]
	local idx = ( x << X_OFFSET) | y
	mapInfo.xyMapMoId[idx] = mapObjectTbl
	mapInfo.mapObjectTblT[mapObjectTbl.moId] = mapObjectTbl
	mapInfo.saveMOTT[mapObjectTbl.moId] = mapObjectTbl

	local values = mapObjectTbl.values
	local moId = mapObjectTbl.moId
	local umot = getUpdateMapObjectTbl(mapInfo,moId)
	for k,v in pairs(values) do
		umot.idxMapValue[k] = v
	end
	mapInfo.saveMOTT[moId] = mapObjectTbl
end

function M.createArmy(mapInfo,heroId,fHeroId1,fHeroId2,coin,bleed,food,tx,ty,morale,heroTbl)
	local mapId = mapInfo.mapId
	local t = dbMapObjectTbl.createArmy(mapId,heroId,fHeroId1,fHeroId2,coin,bleed,food,tx,ty,morale,heroTbl)
	addMapObjectToMapInfo(mapInfo,t)
	return t
end

function M.createEnemyByCfg(mapInfo,npcCfg)
	local t = dbMapObjectTbl.createEnemyByCfg(npcCfg)
	addMapObjectToMapInfo(mapInfo,t)
	return t
end


function M.setArmyBleed(mapInfo,mapObjectTbl,bleed)
	changeValue(mapInfo,mapObjectTbl,enum.MOIDX_ARMY_BLEED,bleed)
end

function M.moveMapObjectTbl(mapInfo,mapObjectTbl,tx,ty)
	local x = mapObjectTbl.values[enum.MOIDX_ALL_X]
	local y = mapObjectTbl.values[enum.MOIDX_ALL_Y]

	changeValue(mapInfo,mapObjectTbl,enum.MOIDX_ALL_X,tx)
	changeValue(mapInfo,mapObjectTbl,enum.MOIDX_ALL_Y,ty)

	local idx = ( x << X_OFFSET ) | y
	mapInfo.xyMapMoId[idx] = nil
	idx = ( tx << X_OFFSET ) | ty
	mapInfo.xyMapMoId[idx] = mapObjectTbl
end

function M.getMapObjectTbl(mapInfo,x,y)
	local idx = ( x << X_OFFSET ) | y
	return mapInfo.xyMapMoId[idx]
end

function M.removeMapObjectTbl(mapInfo,mapObjectTbl)
	mapObjectTbl.bVaild = false
	local x = mapObjectTbl.values[enum.MOIDX_ALL_X]
	local y = mapObjectTbl.values[enum.MOIDX_ALL_Y]
	local idx = ( x << X_OFFSET ) | y
	mapInfo.xyMapMoId[idx] = nil
	mapInfo.mapObjectTblT[mapObjectTbl.moId] = nil
end

function M.bBlock(mapInfo,x,y)
	local idx = ( x << X_OFFSET ) | y
	return mapInfo.xyMapMoId[idx] ~= nil
end

return M
