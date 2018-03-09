local skynet = require "skynet"
local socket = require("skynet.socket")
local socketchannel = require "skynet.socketchannel"
local utilsFunc = require("zjutils/utilsFunc")
local sproto = require("sproto")
local _ = socket

local function response(sock)
	return true,sock:readline("\r\n")
end

skynet.start(function()
	local gmcmd_struct = require("gmcmd_struct")
	local sp = sproto.parse(gmcmd_struct)

	local gameip = skynet.getenv("gameip")
	local gameport = skynet.getenv("gameport")
	gameport = tonumber(gameport)
	local channel = socketchannel.channel {
		host = gameip,
		port = gameport,
		nodelay = true,
	}
	channel:connect(true)

	local gm_handle = require("gm_handle")
	skynet.dispatch("lua",function(_,_,...)
		local sendT = ...
		local f = gm_handle[sendT.cmd]
		local retT
		if f ~= nil then
			retT = f(sendT)
			utilsFunc.infoPrint("http gm_handle ret",retT)
		end
		if (f ~= nil and retT.err == 0) or f == nil then
			local oldRetStr = nil
			if retT ~= nil then
				oldRetStr = retT.retStr
			end
			if f ~= nil then sendT = {cmd=sendT.cmd,p4=retT.retStr} end
			local msg = sp:pencode("GmCmd",sendT) .. "\r\n"
			local resp = channel:request(msg,response)
			retT = sp:pdecode("GmCmdR",resp)
			retT.retStr = oldRetStr
			utilsFunc.infoPrint("http final ret",retT)
		end
		skynet.ret(skynet.pack(retT))
	end)
end)
