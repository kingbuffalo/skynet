local M = {}

local name = require("game.db.keyNameCfg")

local function getKey(pid)
	return "p"..pid.."_"..name.shop
end

function M.newShopTbl(shopId,times,timestamp)
	return {shopId=shopId, times=times,timestamp=timestamp}
end


function M.getShopTblT(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	local t = ssdbutils.execute("hgetalls",key)
	return t
end

function M.setShopTblT(pid,shopTblT)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	ssdbutils.sendExecute("hsetalls",key,shopTblT)
end

function M.getShopTblT(pid,shopId)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	local t = ssdbutils.execute("hgets",key,shopId)
	return t
end

function M.setShopTbl(pid,shopTbl)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getKey(pid)
	ssdbutils.sendExecute("hsets",key,shopTbl.shopId,shopTbl)
end

return M
