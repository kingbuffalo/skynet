local M = {}

local name = require("game.db.keyNameCfg")
local enum = require("game.config.enum")

local function getPlayerInfoKey(pid)
	return "p"..pid.."_"..name.playerInfo
end
local function getUserInfoKey(uid)
	return name.gtbl_uidMapUserInfo.."_"..uid
end

function M.newPlayerInfo(pid,nickname)
	local t = { pid=pid,
		baseRes = {100000,100,0,24},
		exp = 0,
		worker = 2,
		timeIdxTimestamp = os.time(),
		nickname = nickname,
		level = 1, }
	return t
end

function M.newUserInfo(pid,uid,pwd)
	local t = { uid = uid, pwd=pwd, pid = pid, }
	return t
end

function M.getPlayerInfo(pid,bWhileUpdateSave)
	if bWhileUpdateSave == nil then bWhileUpdateSave = false end
	local key = getPlayerInfoKey(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	local t = ssdbutils.execute("gets",key)
	if t.baseRes[enum.BASE_RES_ROUND] < enum.ROUND_MAX then
		local ct = os.time()
		local pt = ct - t.timeIdxTimestamp
		if pt > enum.ROUND_SECOND then
			local addCount = pt // enum.ROUND_SECOND
			t.baseRes[enum.BASE_RES_ROUND]= t.baseRes[enum.BASE_RES_ROUND]+ addCount
			if t.baseRes[enum.BASE_RES_ROUND]> enum.ROUND_MAX then
				t.baseRes[enum.BASE_RES_ROUND]= enum.ROUND_MAX
			end
			t.timeIdxTimestamp = addCount*enum.ROUND_SECOND + t.timeIdxTimestamp

			if bWhileUpdateSave then
				M.setPlayerInfo(t)
			end
		end
	end
	return t
end

function M.setPlayerInfo(playerInfo)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getPlayerInfoKey(playerInfo.pid)
	ssdbutils.sendExecute("sets",key,playerInfo)
end

function M.getMaxPlayerId()
	local ssdbutils = require("utils.db.ssdbutils")
	local pid = ssdbutils.execute("get",name.gtbl_maxPlayerId)
	return tonumber(pid)
end

function M.setMaxPlayerId(pid)
	local ssdbutils = require("utils.db.ssdbutils")
	ssdbutils.sendExecute("set",name.gtbl_maxPlayerId,pid)
end

function M.getUserInfo(uid)
	local key = getUserInfoKey(uid)
	local ssdbutils = require("utils.db.ssdbutils")
	local t = ssdbutils.execute("gets",key)
	return t
end

function M.setUserInfo(userInfo)
	local ssdbutils = require("utils.db.ssdbutils")
	local key = getUserInfoKey(userInfo.uid)
	ssdbutils.sendExecute("sets",key,userInfo)
end

return M
