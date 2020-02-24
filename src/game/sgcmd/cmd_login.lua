local cmdM = {}
--local skynet = require("skynet")

local dbUserPlayerTbl = require("game.db.dbUserPlayerTbl")

function cmdM.init()
	if cmdM.__maxPid == nil then
		cmdM.__maxPid = dbUserPlayerTbl.getMaxPlayerId() or 1
		cmdM.__gameip = "192.168.0.197"
		cmdM.__gameport = 7759
	end
end

local function createNewPlayer(uid,pwd,nickname)
	local pid = cmdM.__maxPid + 1
	cmdM.__maxPid = pid
	dbUserPlayerTbl.setMaxPlayerId(pid)
	local userInfo = dbUserPlayerTbl.newUserInfo(pid,uid,pwd)
	dbUserPlayerTbl.setUserInfo(userInfo)
	local t = dbUserPlayerTbl.newPlayerInfo(pid,nickname)
	dbUserPlayerTbl.setPlayerInfo(t)
	return userInfo
end

function cmdM.recCmd(cmdvo,timeIdx)
	cmdM.init()
	local uid = cmdvo.p4
	local pwd_nickname = cmdvo.p5
	local pwd,nickname = string.match(pwd_nickname,"(%w+)_(%w+)")
	local userInfo = dbUserPlayerTbl.getUserInfo(uid)
	if userInfo == nil then
		userInfo = createNewPlayer(uid,pwd,nickname)
	end
	return {err=0,pid=userInfo.pid,ip=cmdM.__gameip,port=cmdM.__gameport}
end

return cmdM
