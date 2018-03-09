local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local sprotoparser = require("sprotoparser")
local socket = require "skynet.socket"
local boylib = require("boylib")

--local function accept(s, fd, addr)
	----未必有这么多变量返回
	--local msg,len = skynet.call(s, "lua",  fd, addr)
	--print("gate",msg,len)
	--return msg,len
--end

local port = ...
port = tonumber(port)

local function readCrc32(crc32Str)
	local b = crc32Str
	local byte=string.byte
	local ret = byte(b,4) | byte(b,3)<<8 | byte(b,2)<<16 | byte(b,1)<<24
	return ret
end

skynet.start(function()
	skynet.error("game gate server start")
	local cmd = require("game.cmd.cmdstruct")
	sprotoloader.save(sprotoparser.parse(cmd), 1)

	--local instance = 8
	local host = "0.0.0.0"
	--local port = port
	--local slave = {}
	--local balance = 1
	local cmdsmgr = skynet.newservice("game/cmd/cmdsmgr")
	--skynet.send(cmdsmgr,"lua","INIT_SERVICE")

	--for i=1,instance do
		--table.insert(slave, skynet.newservice("game/gateblance"))
	--end
	local function logfunc()
		local str = os.date() .. "-----------------------"
		skynet.error(str)
		skynet.timeout(30*100,logfunc)
	end
	skynet.timeout(30*100,logfunc)

	local id = socket.listen(host, port)
	socket.start(id , function(fd, addr)
		--local s = slave[balance]
		--balance = balance + 1
		--if balance > #slave then balance = 1 end
		--local ok,err = pcall(accept,s, fd, addr)
		--if not ok then
			--if err ~= socket_error then
				--skynet.error(string.format("invalid client (fd = %d) error = %s", fd, err))
			--end
		--end
		socket.start(fd)	-- may raise error here
		socket.limit(fd,2048)
		local cmdBinStr = socket.readline(fd,"\r\n")
		local c_crc32 = socket.readline(fd,"\r\n")
		local s_crc32 = boylib.crc32(cmdBinStr)
		local c_crc32int = readCrc32(c_crc32)
		local s_crc32int = readCrc32(s_crc32)
		local msg = "unValid data"
		if c_crc32int == s_crc32int then
			msg = skynet.call(cmdsmgr, "lua","recCmd", cmdBinStr,addr)
		end
		--if len > 2048 then assert(false,">2048") end
		socket.write(fd,msg)
		socket.abandon(fd)	-- never raise error here
		socket.close(fd)
	end)
end)
