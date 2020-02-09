local skynet = require "skynet"
local socket = require "skynet.socket"
local LKcp = require "lkcp"

skynet.start(function()
    local session = 1048
	local host
	local udpSvr = "0.0.0.0"
	local fromMapKcp = {}
	skynet.error(udpSvr)

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
			skynet.fork(function()
				while 1 do
					skynet.sleep(1)
					hrlen, hr = kcp:lkcp_recv()
					if hrlen > 0 then
						skynet.error("rec",hr)
						kcp:lkcp_send(hr)
					end
				end
			end)
		end
		return kcp
	end

	host = socket.udp(function(str, from)
		local kcp = getKcp(from,host)
		kcp:lkcp_input(str)
	end , udpSvr, 8765)	-- bind an address
end)
