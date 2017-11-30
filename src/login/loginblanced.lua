local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local socket = require "skynet.socket"

local function assert_socket(service, v, fd)
	if v then
		return v
	else
		skynet.error(string.format("%s failed: socket (fd = %d) closed", service, fd))
		error(socket_error)
	end
end

local function auth_fd(fd, addr)
	skynet.error(string.format("connect from %s (fd = %d)", addr, fd))
	socket.start(fd)	-- may raise error here  --这个用来干嘛
	socket.limit(fd,1024)
	--local cmdBinStr = socket.readall(fd)
	local cmdBinStr = assert_socket("auth", socket.readline(fd,"\r\n"), fd)
	--如果要增加较验，可以在下一行增加一个较验数
	--BTODO 有空再加
	local reccmd = require("game.cmd.reccmd")
	--xpcall(reccmd,debug.traceback,fd,addr,cmdBinStr)
	reccmd(fd,addr,cmdBinStr)
	socket.abandon(fd)	-- never raise error here
	return status,err
end

skynet.start(function()
	skynet.error("loginbalanced start")
	--local cmd1001 = require("game.cmd.cmd1001")
	--cmd1001.init()
	skynet.dispatch("lua", function(_,_,...)
		auth_fd(...)
		return skynet.ret(skynet.pack(nil,0))
	end)
end)
