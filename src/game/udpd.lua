local skynet = require "skynet"
local socket = require "skynet.socket"

--TODO
--1. balance done
--2. heart beat
--3. close while not respond
--4. session
--
--
local funcT = {}

function funcT.updatePidFrom(forwardAddr,from,pid)
	skynet.send(forwardAddr,"lua","updatePidFrom",from,pid)
end

function funcT.pushMsg(forwardAddr,pid,msg)
	skynet.send(forwardAddr,"lua","pushMsg",pid,msg)
end

skynet.start(function()
	local blanceCount = 8
	local blanceSvr = {}
	local udpSvr = "0.0.0.0"
	local hostMapBlance = {}
	local host
	for i=1,blanceCount,1 do
		blanceSvr[i] = skynet.newservice("game/udpblance")
	end

	skynet.dispatch("lua",function(_,_,funcName,from,...)
		local f = assert(funcT[funcName],"func not found: "..funcName)
		local svrIdx = hostMapBlance[from] or 0
		if svrIdx ~= 0 then
			skynet.retpack(f(blanceSvr[svrIdx],from,...))
		end
	end)

	local stepIdx = 1
	host = socket.udp(function(str, from)
		local svrIdx = hostMapBlance[from]
		if svrIdx == nil then
			svrIdx = stepIdx
			hostMapBlance[from] = svrIdx
			stepIdx = stepIdx + 1
			if stepIdx > blanceCount then
				stepIdx = 1
			end
		end
		skynet.send(blanceSvr[svrIdx],"lua","recCmd",str,from,host)
	end , udpSvr, 8765)	-- bind an address
end)
