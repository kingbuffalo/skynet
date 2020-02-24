local cmdM = {}

local npc = require("game.config.npc")
local mapInfoMgr = require("game.cmd.mapInfoMgr")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx,mapInfo)
	local _=timeIdx
	local mapId = cmdVO.p1
	local npcId = cmdVO.p2

	local npcCfgArr = npc[mapId]
	if npcCfgArr == nil then return {err=1} end
	npcCfgArr = npcCfgArr[npcId]
	if npcCfgArr == nil then return {err=2} end

	for _,v in ipairs(npcCfgArr) do
		mapInfoMgr.createEnemyByCfg(mapInfo,v)
	end
	return {err=0}
end

function cmdM.close()
end

return cmdM
