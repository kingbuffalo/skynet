local M = {}

local name = require("game.db.keyNameCfg")

local function getBagKey(pid)
	return "p"..pid.."_"..name.bag
end

function M.newBagTbl(itemId,count)
	return { itemId=itemId,
		count = count }
end

function M.getBagTblT(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	local key =getBagKey(pid)
	local t = ssdbutils.execute("hgetalls",key)
	return t
end

function M.setBagTblT(pid,bagTblT)
	local ssdbutils = require("utils.db.ssdbutils")
	local key =getBagKey(pid)
	ssdbutils.sendExecute("hsetalls",key,bagTblT)
end

function M.getBagTbl(pid,itemId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key =getBagKey(pid)
	local t = ssdbutils.execute("hgets",key,itemId)
	return t
end

function M.setBagTbl(pid,bagTbl)
	local ssdbutils = require("utils.db.ssdbutils")
	local key=getBagKey(pid)
	local itemId = bagTbl.itemId
	ssdbutils.sendExecute("hsets",key,itemId,bagTbl)
end

return M
