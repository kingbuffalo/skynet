local skynet = require "skynet"

local socket = require "skynet.socket"

--TODO 
--1. balance done
--2. heart beat
--3. close while not respond
--4. session

skynet.start(function()
	local blanceCount = 8
	local blanceSvr = {}
	local udpSvr = "0.0.0.0"
	local hostMapBlance = {}
	local host
	for i=1,blanceCount,1 do
		blanceSvr[i] = skynet.newservice("game/udpblance")
	end

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
		skynet.send(blanceSvr[svrIdx],"lua",strData,from,host)
	end , udpSvr, 8765)	-- bind an address
end)
