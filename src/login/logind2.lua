local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local sprotoparser = require("sprotoparser")
local socket = require "skynet.socket"
local boylib = require("boylib")

local function readCrc32(crc32Str)
	local b = crc32Str
	local byte=string.byte
	local ret = byte(b,4) | byte(b,3)<<8 | byte(b,2)<<16 | byte(b,1)<<24
	return ret
end

local function accept(s, fd, addr)
	local msg,len = skynet.call(s, "lua",  fd, addr)
	return msg,len
end

local port=...
port = tonumber(port)

local function loginCmd(fd,addr,cmdBinStr)
	local sp = sprotoloader.load(1)
	local cmdvo = sp:pdecode("Cmd",cmdBinStr)
	print("rec cmd",fd,addr)
	local utilsFunc = require("utils/utilsFunc")
	utilsFunc.printTable(cmdvo)
	local cmd_login= require("game.cmd.cmd_login")
	local cmdLuaTable = cmd_login.recCmd(cmdvo)
	local cmdconst = require("game.cmd.cmdconst")
	local cmdStrcutName = cmdconst.getStructName(cmdvo.cmd)
	print("send cmd",cmdStrcutName,":")
	utilsFunc.printTable(cmdLuaTable)
	local msg = sp:pencode(cmdStrcutName,cmdLuaTable)
	return msg
end

skynet.start(function()
	skynet.error("logind2 server start")
	local cmd = require("game.cmd.cmdstruct")
	sprotoloader.save(sprotoparser.parse(cmd), 1)

	local instance = 8
	local host = "0.0.0.0"
	local port = port
	local slave = {}
	local balance = 1

	local id = socket.listen(host, port)
	socket.start(id , function(fd, addr)
		skynet.error(string.format("connect from %s (fd = %d)", addr, fd))
		socket.start(fd)
		socket.limit(fd,1024)
		local cmdBinStr = socket.readline(fd,"\r\n")
		local c_crc32 = socket.readline(fd,"\r\n")
		local s_crc32 = boylib.crc32(cmdBinStr)
		local c_crc32int = readCrc32(c_crc32)
		local s_crc32int = readCrc32(s_crc32)
		local msg,len= "unVaild data",14
		if c_crc32int == s_crc32int then
			msg = loginCmd(fd,add,cmdBinStr)
		end
		socket.write(fd,msg)
		--如果要增加较验，可以在下一行增加一个较验数
		--BTODO 有空再加
		socket.abandon(fd)	-- never raise error here
		socket.close_fd(fd)
	end)
end)

--skynet.start(function()
	--skynet.error("logind2 server start")
	--local cmd = require("game.cmd.cmdstruct")
	--sprotoloader.save(sprotoparser.parse(cmd), 1)

	--local instance = 8
	--local host = "0.0.0.0"
	--local port = port
	--local slave = {}
	--local balance = 1

	--for i=1,instance do
		--table.insert(slave, skynet.newservice("login/loginblanced"))
	--end

	--local id = socket.listen(host, port)
	--socket.start(id , function(fd, addr)
		--local s = slave[balance]
		--balance = balance + 1
		--if balance > #slave then balance = 1 end
		--local msg,len = skynet.call(s, "lua",  fd, addr)
		----local ok,err = pcall(accept,s, fd, addr)
		----if not ok then
			----if err ~= socket_error then
				----skynet.error(string.format("invalid client (fd = %d) error = %s", fd, err))
			----end
		----end
		--socket.close_fd(fd)
	--end)
--end)
