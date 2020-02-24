local sprotoloader = require "sprotoloader"
local socket = require "skynet.socket"
--local skynet = require("skynet")

--local function assert_socket(service, v, fd)
	--if v then
		--return v
	--else
		--skynet.error(string.format("%s failed: socket (fd = %d) closed", service, fd))
		----error(socket_error)
	--end
--end

--local function write(service, fd, text)
	--assert_socket(service, socket.write(fd, text), fd)
--end

local function reccmd(fd,addr,cmdBinStr)
	local sp = sprotoloader.load(1)
	local cmdvo = sp:pdecode("Cmd",cmdBinStr)
	print("rec cmd",fd,addr)
	local utilsFunc = require("utils/utilsFunc")
	utilsFunc.printTable(cmdvo)
	local everyCmdRec = require("game.cmd.cmd"..cmdvo.cmd)
	local cmdLuaTable = everyCmdRec.recCmd(cmdvo)
	local cmdconst = require("game.cmd.cmdconst")
	local cmdStrcutName = cmdconst.getStructName(cmdvo.cmd)
	print("send cmd",cmdStrcutName,":")
	utilsFunc.printTable(cmdLuaTable)
	local msg = sp:pencode(cmdStrcutName,cmdLuaTable)
	--write("send cmd:"..cmdvo.cmd,fd, msg.."\n")
	socket.write(fd,msg)
	return 0
end

return reccmd
