local skynet = require "skynet"
local socket = require "skynet.socket"
local LKcp = require "lkcp"
local protoT = require "game/sprotocfg/protoT"
local sprotoloader = require "sprotoloader"
local hostMapPid = {}

--TODO 
--1. balance
--2. heart beat
--3. close while not respond
--4. session

skynet.start(function()

    local session = 1048
	local host
	local udpSvr = "0.0.0.0"
	local fromMapKcp = {}
	skynet.error(udpSvr)
	local sp = sprotoloader.load(1)

	local function getKcp(from,host)
		local kcp = fromMapKcp[from] 
		if kcp == nil then
			kcp = LKcp.lkcp_create(session, function (buf) 
				socket.sendto(host, from, buf)
			end)
			kcp:lkcp_wndsize(128, 128)
			kcp:lkcp_nodelay(0, 10, 0, 0)
			fromMapKcp[from] = kcp
			skynet.fork(function()
				while 1 do
					skynet.sleep(1)
					local current = skynet.time() * 100
					kcp:lkcp_update(current)
				end
			end)
		end
		local pid = hostMapPid[host] or 0
		return kcp,pid
	end

	host = socket.udp(function(str, from)
		local kcp,pid = getKcp(from,host)
		kcp:lkcp_input(str)

		hrlen, hr = kcp:lkcp_recv()
		if hrlen > 0 then
			local b1,b2 = string.byte(hr,1,2)
			local sprotoId = (b1 << 8) | b2
			local protostr = protoT[sprotoId]
			if protostr ~= nil then
				local protoVO = sp:decode(protostr,string.sub(hr,3,#hr))
				local protoM = require("game/xyycmd/cmd_"..protostr)
				local errInt,retProtoId,retP = protoM.recCmd(protoVO)
				local retProtoName = protoT[retProtoId]
				local msg
				if errInt == 0 then
					msg = sp:encode(retProtoName,retP)
				else
					retProtoId = 30001
					msg = sp:encode("ErrorR",{code=errInt})
				end
				local rb1 = (retProtoId >> 8 )& 0xff
				local rb2 = (retProtoId )& 0xff
				local retStr = string.char(rb1,rb2)
				retStr = retStr.. msg
				kcp:lkcp_send(retStr)


				skynet.error("xxxx--->",protostr,protoVO.name,protoVO.passwd)
			end
		end
	end , udpSvr, 8765)	-- bind an address
end)
