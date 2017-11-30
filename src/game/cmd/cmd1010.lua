
	--local item = require("game.config.item")
	--local npc = require("game.config.npc")
	--local map = require("game.config.map")
	--local hero = require("game.config.hero")
local map = require("game.config.map")
local global_map = require("game.config.global_map")
local city = require("game.config.city")
local playerMapCache = {} --key playerId  value:mapinfo
local createTbl = require("game.db.createTbl")
local ssdbhelper = require("game.db.ssdbhelper")

local cmdM = {}
local function bCanGoto(pid,fx,fy,tx,ty,speed)
	local mapInfo = {}
	return true
end

local function bCanSendOut(pid,cityId,heroId,x,y)
	local cityCfg = city[cityId]
	local fx,fy = cityCfg.x,cityCfg.y
	local speed
	if not bCanGoto(fx,fy,x,y,speed) then return false end
	return true
end

function cmdM.init()
end

function cmdM.recCmd(cmdVO)
	local pid = cmdVO.pid
	local heroId = cmdVO.p1
	local x,y = cmdVO.p2,cmdVO.p3
	local armyCount = tonumber(cmdVO.p4)
	local heroTbl = ssdbhelper.getHeroTbl(pid,heroId)
	if heroTbl == nil then return {err=err} end
	local armyId = heroTbl.armyId
	if armyId == 0 then return {err=err} end
	local city = heroTbl.cityId
	if not bCanSendOut(pid,cityId,heroId,x,y) then return {err=err} end
	local armyTbl = createTbl.createArmyByHeroTbl(heroTbl,armyCount,x,y)
	ssdbhelper.setArmyTbl(pid,armyTbl)
	return {err=0,armyId=armyTbl.armyId}
end

return cmdM
