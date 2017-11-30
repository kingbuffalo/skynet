local mapInfoMgr = require("game.cmd.mapInfoMgr")
local enum = require("game.config.enum")
local map_neighbor_odd = require("game.config.map_neighbor_odd")
local map_neighbor_even = require("game.config.map_neighbor_even")

local function calcDef(aMOT,dMOT,army_skillCfg,army_skill_cfgCfg)
	assert(false,"此处并没有武将属性的加成")
	local _,_ = aMOT,army_skillCfg
	local attrEnum
	if army_skill_cfgCfg.atk_type == enum.ARMY_SKILL_ATK_TYPE_PHY then
		attrEnum = enum.ARMY_ATTR_PHY_DEF
	else
		attrEnum = enum.ARMY_ATTR_MAG_DEF
	end
	local def = dMOT.values[enum.ARMY_ATTR_MAP_MOIDX[attrEnum]]
	local cb = dMOT.values[enum.MOIDX_ARMY_BLEED]
	local mb = dMOT.values[enum.MOIDX_ARMY_MAX_BLEED]

	local gameUtils = require("game.db.gameUtils")
	def = gameUtils.getBleedEff(mb,cb,def)

	return def
end


local function calcHurt(atk,def)
	local hurt = (atk*atk)/(2*def)

	local rand = math.random(1,200)
	rand = (rand-100)/1000 + 1
	hurt = math.floor(hurt*rand)

	return hurt
end


local function spear_1(aMOT,dMOT,mapInfo,atk,army_skillCfg,army_skill_cfgCfg)
	local def = calcDef(aMOT,dMOT,army_skillCfg,army_skill_cfgCfg)
	local hurt = calcHurt(atk,def)
	local bleedLeft = dMOT.values[enum.MOIDX_ARMY_BLEED] - hurt
	if bleedLeft < 0 then bleedLeft = 0 end
	mapInfoMgr.setArmyBleed(mapInfo,dMOT,bleedLeft)
	if bleedLeft == 0 then
		dMOT.bVaild = false
		mapInfoMgr.removeMapObjectTbl(mapInfo,dMOT)
	else
		local _=1
		--可以增加反击
	end
end

local function getspear2Pos_help(ax,ay,dx,dy)
	local arr
	if (dx & 1) == 0 then
		arr = map_neighbor_even
	else
		arr = map_neighbor_odd
	end
	for i,v in ipairs(arr) do
		if dx+v[1] == ax and dy+v[2] == ay then
			return i,arr
		end
	end
	assert(false,"理论上不会有这个语句出现")
	return 1,arr
end
local function getspear2Pos(ax,ay,dx,dy)
	local idx,arr = getspear2Pos_help(ax,ay,dx,dy)
	idx = (idx+3)%6
	if idx == 0 then idx = 6 end
	local np = arr[idx]
	return dx+np[1],dx+np[2]
end

local function spear_2(aMOT,dMOT,mapInfo,atk,army_skillCfg,army_skill_cfgCfg)
	local def = calcDef(aMOT,dMOT,army_skillCfg,army_skill_cfgCfg)
	local hurt = calcHurt(atk,def)
	local bleedLeft = dMOT.values[enum.MOIDX_ARMY_BLEED] - hurt
	if bleedLeft < 0 then bleedLeft = 0 end
	mapInfoMgr.setArmyBleed(mapInfo,dMOT,bleedLeft)
	if bleedLeft == 0 then
		mapInfoMgr.removeMapObjectTbl(mapInfo,dMOT)
	else
		local dx = dMOT.values[enum.MOIDX_ALL_X]
		local dy = dMOT.values[enum.MOIDX_ALL_Y]

		local ax = aMOT.values[enum.MOIDX_ALL_X]
		local ay = aMOT.values[enum.MOIDX_ALL_Y]

		local ndx,ndy = getspear2Pos(ax,ay,dx,dy)
		if mapInfoMgr.bBlock(mapInfo,ndx,ndy) then
			mapInfoMgr.moveMapObjectTbl(mapInfo,dMOT,ndx,ndy)
		else
			local mot = mapInfoMgr.getMapObjectTbl(mapInfo,ndx,ndy)
			if mot.type == enum.MO_TYPE_ARMY or mot.type == enum.MO_TYPE_ENEMY then
				local _ = 1
			elseif mot.type == enum.MO_TYPE_TRAP then
				local _ = 1
				--TODO
			end
		end
	end
end

local t = {
	[enum.ARMY_SKILL_TYPE_SPEAR_1] = spear_1,
	[enum.ARMY_SKILL_TYPE_SPEAR_2] = spear_2,
}

return t
