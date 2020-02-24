local M = {}
local ssdbutils = require("utils.db.ssdbutils")
local name = require("game.db.keyNameCfg")

local function getPlayerInfoKey(pid)
	return "p"..pid.."_"..name.playerInfo
end

function M.setPlayerInfo(playerInfo)
	local key = getPlayerInfoKey(playerInfo.pid)
	ssdbutils.sendExecute("sets",key,playerInfo)
end

function M.getPlayerInfo(pid)
	local key = getPlayerInfoKey(pid)
	local t = ssdbutils.execute("gets",key)
	return t
end

function M.NewPlayer(pid)
	local t = { pid=pid,
		baseRes = {100000,100,0,24},
		exp = 0,
		nickname = "player"..pid,
		level = 1, }
	M.setPlayerInfo(t)
	return t
end

return M
