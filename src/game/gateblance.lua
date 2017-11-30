local skynet = require "skynet"
--local sprotoloader = require "sprotoloader"
local socket = require "skynet.socket"


local function formatcmd(fd, addr)
	-- set socket buffer limit (8K)
	-- If the attacker send large package, close the socket
	local _ = addr
	socket.limit(fd,2048)
	skynet.error("formatcmd")
	local cmdBinStr = socket.readline(fd)
	--如果要增加较验，可以在下一行增加一个较验数
	--还有，不允许一个用户在同一时间内请求多条协议
	--BTODO 有空再加
	local ret = skynet.call(cmdsmgr,"lua",cmdBinStr)
	socket.write(fd,ret.."\n")

	
	--skynet.ret(skynet.call(cmdsmgr,"lua",fd,addr,cmdBinStr))
	--local reccmd = require("game.cmd.reccmd")
	--xpcall(reccmd,debug.traceback,fd,addr,cmdBinStr)
	--return true
end

skynet.start(function()
	skynet.error("gateblance start")
	skynet.dispatch("lua", function(_,_,...)
		local fd,addr = ...
		skynet.error(string.format("connect from %s (fd = %d)", addr, fd))
		socket.start(fd)	-- may raise error here  --这个用来干嘛
		--local status,err = pcall(formatcmd, fd, addr)
		formatcmd(fd,addr)
		socket.abandon(fd)	-- never raise error here
		return status
	end)
end)
