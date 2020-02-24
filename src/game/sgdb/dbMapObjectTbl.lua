local M = {}

local enum = require("game.config.enum")

local function createArmy_help(moId,heroId,mapId,x,y,type,skillIds,
		fHeroId1,fHeroId2,
		coin,food,bleed,morale,heroAttr,armyAttr,maxBleed)
	local t = M.newMapObjectTbl(moId,mapId,x,y,type)
	for i=1,enum.ARMY_SKILL_NUM do
		local key = "MOIDX_ARMY_SKILL"..i
		local idx = enum[key]
		t.values[idx] = skillIds[i] or 0
	end
	t.values[enum.MOIDX_ARMY_HERO_ID] = heroId
	t.values[enum.MOIDX_ARMY_FHERO1_ID] = fHeroId1
	t.values[enum.MOIDX_ARMY_FHERO2_ID] = fHeroId2
	t.values[enum.MOIDX_ARMY_COIN] = coin
	t.values[enum.MOIDX_ARMY_FOOD] = food
	t.values[enum.MOIDX_ARMY_BLEED] = bleed
	t.values[enum.MOIDX_ARMY_MORALE] = morale

	for k,v in pairs(heroAttr) do
		local idx = enum.HERO_ATTR_MAP_MOIDX[k]
		t.values[idx] = v
	end
	for k,v in pairs(armyAttr) do
		local idx = enum.ARMY_ATTR_MAP_MOIDX[k]
		t.values[idx] = v
	end
	t.values[enum.MOIDX_ARMY_MAX_BLEED] = maxBleed
	return t
end

function M.createArmy(mapId,heroId,fHeroId1,fHeroId2,coin,bleed,food,tx,ty,morale,heroTbl)
	local dbHeroTbl = require("game.db.dbHeroTbl")
	local heroAttr,armyAttr,maxBleed = dbHeroTbl.getFightInfo(heroTbl)
	local t = createArmy_help(heroId,heroId,mapId,tx,ty,enum.MO_TYPE_ARMY,heroTbl.askillIds,
		fHeroId1,fHeroId2,
		coin,food,bleed,morale,heroAttr,armyAttr,maxBleed)
	return t
end

function M.createEnemyByCfg(npcCfg)
	local x,y = npcCfg.pos[1] ,npcCfg.pos[2]
	local hids = npcCfg.hero_ids
	local t = createArmy_help(npcCfg.enemy_id,hids[1],npcCfg.map_id,x,y,enum.MO_TYPE_ENEMY,npcCfg.skill_ids,
		hids[2] or 0,hids[3] or 0,
		npcCfg.coin,npcCfg.food,npcCfg.bleed,
		npcCfg.morale,npcCfg.hero_attr,npcCfg.army_attr,npcCfg.max_bleed)
	return t
end



---------------------------------db oper begin------------------------
local name = require("game.db.keyNameCfg")

local function getKey(pid,mapId)
	return "p"..pid.."_"..name.mapObject.."_"..mapId
end

function M.newMapObjectTbl(moId,mapId,x,y,type)
	return { moId=moId,
		mapId=mapId,
		bVaild=true,
		values={ [enum.MOIDX_ALL_X] = x,
			[enum.MOIDX_ALL_TYPE] = type,
			[enum.MOIDX_ALL_Y] = y, } }
end

function M.getMapObjectTbl(pid,mapId,moId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid,mapId)
	local t = ssdbutils.execute("hgets",key,moId)
	return t
end

function M.setMapObjectTbl(pid,mapId,mapObjectTbl)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid,mapId)
	if not mapObjectTbl.bVaild then
		mapObjectTbl={moId=mapObjectTbl.moId,bVaild=false}
	end
	return ssdbutils.sendExecute("hsets",key,mapObjectTbl.moId,mapObjectTbl)
end

function M.getMapObjectTblT(pid,mapId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid,mapId)
	local t = ssdbutils.execute("hgetalls",key)
	for k,v in pairs(t) do
		if not v.bVaild then
			t[k] = nil
		end
	end
	return t
end

function M.setMapObjectTblT(pid,mapId,mapObjectTblT)
	local ssdbutils = require("utils.db.ssdbutils")
	for k,v in pairs(mapObjectTblT) do
		if not v.bVaild then
			mapObjectTblT[k] = {moId=v.moId,bVaild=false}
		end
	end
	local key = getKey(pid,mapId)
	return ssdbutils.sendExecute("hsetalls",key,mapObjectTblT)
end
---------------------------------db oper end------------------------
return M
