local M = {}

local skynet = require("skynet")

local udpdAddr

local function getUdpdAddr()
	if udpdAddr == nil then
		udpdAddr = skynet.queryservice("game/kcpudp/udpd")
	end
	return udpdAddr
end

function M.pushMsg(pid,sMsg,tMsg)
	skynet.send(getUdpdAddr(),"lua","pushMsg","",pid,sMsg,tMsg)
end

function M.updatePidFrom(from,pid)
	skynet.send(getUdpdAddr(),"lua","updatePidFrom",from,pid)
end

return M
