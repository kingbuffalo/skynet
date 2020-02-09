local skynet = require "skynet"
local LatencySM = require "latencysm"

local LKcp = require "lkcp"
local LUtil = require "lutil"

local lsm = LatencySM.LatencySM.new(10, 60, 125)


local function udp_output(buf, info)
	if info ~= nil then
		skynet.error("xxxx  udp_output",info.id, info.a, info.b, info.c)
	else
		skynet.error("xxxx  udp_output")
	end
    if info.b then
        info.c(info.a)
    end
    lsm:send(info.id, buf)
end

skynet.start(function()
    local session = 0x11223344
    local info = {
        id = 0,
        a = 'aaa',
        b = false,
    }


    local kcp1 = LKcp.lkcp_create(session, function (buf)
        udp_output(buf, info)
    end)


    local info2 = {
        id = 1,
        a = 'aaaaaaaaaaaaa',
        b = true,
        c = function (a)
            print 'hahahah!!!'
        end,
    }

    local kcp2 = LKcp.lkcp_create(session, function (buf)
        udp_output(buf, info)
    end)

	kcp1:lkcp_wndsize(128, 128)
	kcp2:lkcp_wndsize(128, 128)

	kcp1:lkcp_nodelay(0, 10, 0, 0)
	kcp2:lkcp_nodelay(0, 10, 0, 0)

	local current = skynet.time() * 100
	local slap = current + 20
	local index = 0

	skynet.fork(function()
		skynet.error("fork")
		while 1 do
			kcp1:lkcp_update(current)
			kcp2:lkcp_update(current)

			skynet.sleep(10)
			current = skynet.time() * 100

			while current >= slap  do
				local s1 = LUtil.uint322netbytes(index)
				local s2 = LUtil.uint322netbytes(current)
				kcp1:lkcp_send(s1..s2)
				slap = slap + 20
				index = index + 1
			end

			while 1 do
				hrlen, hr = lsm:recv(1)
				if hrlen < 0 then
					break
				end
				--如果 p2收到udp，则作为下层协议输入到kcp2
				kcp2:lkcp_input(hr)
			end

			while 1 do
				hrlen, hr = lsm:recv(0)
				if hrlen < 0 then
					break
				end
				--如果 p1收到udp，则作为下层协议输入到kcp1
				kcp1:lkcp_input(hr)
			end

			--kcp2接收到任何包都返回回去
			while 1 do
				hrlen, hr = kcp2:lkcp_recv()
				if hrlen <= 0 then
					break
				end
				kcp2:lkcp_send(hr)
				--kcp2:lkcp_flush()
			end
		end
	end)


end)
