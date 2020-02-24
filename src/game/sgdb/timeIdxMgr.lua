local M = {}

local pidMapTimeIdx = {}

local name = require("game.db.keyNameCfg")

local function getKey(pid)
	return "p"..pid.."_"..name.timeIdx
end

function M.getTimeIdx(pid)
	if pidMapTimeIdx[pid] == nil then
		local ssdbutils = require("utils.db.ssdbutils")
		local key = getKey(pid)
		local idx = ssdbutils.execute("get",key)
		pidMapTimeIdx[pid] = idx
	end
	return pidMapTimeIdx[pid]
end

function M.setTimeIdx(pid,timeIdx)
	pidMapTimeIdx[pid] = timeIdx
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	return ssdbutils.sendExecute("set",key,timeIdx)
end

return M
