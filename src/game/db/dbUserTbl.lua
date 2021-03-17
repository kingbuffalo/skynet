local M = {}

local ssdbutils = require("utils.db.ssdbutils")
local name = require("game.db.keyNameCfg")

local function getUserInfoKey(uid)
	return name.gtbl_uidMapUserInfo.."_"..uid
end

function M.NewUser(pid,uid,pwd)
	local t = { uid = uid, pwd=pwd, pid = pid,
		tblCreateMask = 0,
	}
	local dbMaskConst = require("game/db/dbMaskConst")
	t.tblCreateMask = dbMaskConst.CheckAndCreatTbl(0,pid)
	M.setUser(t)
	return t
end

function M.getUser(uid)
	local key = getUserInfoKey(uid)
	local t = ssdbutils.execute("gets",key)
	return t
end

function M.setUser(userInfo)
	local key = getUserInfoKey(userInfo.uid)
	ssdbutils.sendExecute("sets",key,userInfo)
end

function M.setMaxPlayerId(pid)
	ssdbutils.sendExecute("set",name.gtbl_maxPlayerId,pid)
end

function M.getMaxPlayerId()
	local pid = ssdbutils.execute("get",name.gtbl_maxPlayerId)
	return tonumber(pid) or 0
end


return M
