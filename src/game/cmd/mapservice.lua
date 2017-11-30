local skynet = require "skynet"
local cmdconst = require("game.cmd.cmdconst")
local mapInfoMgr = require("game.cmd.mapInfoMgr")
local enum = require("game.config.enum")
local INT_BITS = 32

local mapId = ...
mapId = tonumber(mapId)

local mapInfoT={}

local function getMapInfo(pid,timeIdx)
	local t = mapInfoT[pid]
	if t == nil then
		t = mapInfoMgr.createMapInfo(pid,mapId,timeIdx)
	end
	mapInfoT[pid] = t
	return t
end

local function setMapInfo(pid,mapInfo)
	mapInfoMgr.saveChangeToDb(pid,mapInfo)
	mapInfoT[pid] = mapInfo
	local moIdMapIdxMapValues = mapInfo.umotT
	mapInfo.umotT = {}

	local ret = {}
	for k,v in pairs(moIdMapIdxMapValues) do
		local umt = {
			moId=k,
			idxMasks = {0},
			values = {},
		}
		for i=1,enum.MOIDX_MAX do
			if v.idxMapValue[i] ~= nil then
				umt.values[#umt.values+1] = 1
				local idxMasksIdx = i//INT_BITS + 1
				local mask = umt.idxMasks[idxMasksIdx]
				mask = mask | 1 << ( i-INT_BITS*(idxMasksIdx-1) -1 )
				umt.idxMasks[idxMasksIdx] = mask
			end
		end
		ret[k] = umt
	end
	return ret
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_,funcName,...)
		local cmdVO,timeIdx= ...
		local pid = cmdVO.pid
		local cmdName = cmdconst.getStructName(cmdVO.cmd)
		local mapInfo = getMapInfo(cmdVO.pid)
		if cmdVO.cmd == cmdconst.cmd_timeIdx_inc then
			assert(false,"还没做")
			skynet.ret(skynet.pack(nil,0))
		else
			local cmd = require("game.cmd.cmd_"..cmdName)
			local msg = cmd[funcName](cmdVO,timeIdx,mapInfo)
			msg.updateMapObjectTblT = setMapInfo(pid,mapInfo)
			if msg ~= nil then
				skynet.ret(skynet.pack(msg))
			else
				skynet.ret(skynet.pack(nil,0))
			end
		end
	end)
end)
