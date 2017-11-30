local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

--local SERVICENAME = "cmdsmgr"

local timeIdxMgr = require("game.db.timeIdxMgr")

skynet.start(function()
	local cmds = {}

	local sp = sprotoloader.load(1)
	local utilsFunc = require("utils/utilsFunc")
	math.randomseed(os.time())

	local cmdconst = require("game.cmd.cmdconst")
	for i=cmdconst.cmd_start,cmdconst.cmd_end do
		cmds[i] = skynet.newservice("game/cmd/cmdservice",i)
	end
	local mapcmdmgr = skynet.newservice("game/cmd/mapcmdmgr")

	skynet.dispatch("lua", function(_,_,funcName,...)
		local cmdBinStr,addr = ...
		local cmdVO = sp:pdecode("Cmd",cmdBinStr)
		print("rec cmd")
		utilsFunc.printTable(cmdVO)

		local s = cmds[cmdVO.cmd]
		if cmdconst.cmd_map_star <= cmdVO.cmd  and cmdVO.cmd <= cmdconst.cmd_map_end then
			s = mapcmdmgr
		end
		local timeIdx = timeIdxMgr.getTimeIdx(cmdVO.pid)
		local msg
		local cmdLuaTable
		if cmdVO.cmd == cmdconst.cmd_set_db then
			local ipStr = string.sub(addr,1,8)
			if ipStr == "192.168." then
				local recCmd = require("game.cmd.cmd_set_db")
				recCmd.recCmd(cmdVO)
				cmdLuaTable={err=0}
			else
				cmdLuaTable={err=1}
			end
		elseif cmdVO.cmd == cmdconst.cmd_timeIdx_inc then
			local recCmd = require("game.cmd.cmd_timeIdx_inc")
			cmdLuaTable = recCmd.recCmd(cmdVO,timeIdx)
			if cmdLuaTable.err == 0 then
				cmdLuaTable = skynet.call(mapcmdmgr,"lua",funcName,cmdVO,timeIdx)
				timeIdxMgr.setTimeIdx(cmdVO.pid,timeIdx+1)
			end
		else
			assert(s~=nil,"service not found:"..cmdVO.cmd)
			cmdLuaTable = skynet.call(s,"lua",funcName,cmdVO,timeIdx)
		end
		print("send cmd")
		utilsFunc.printTable(cmdLuaTable)
		local cmdStrcutName = cmdconst.getStructName(cmdVO.cmd)
		msg= sp:pencode(cmdStrcutName,cmdLuaTable)
		if msg ~= nil then
			skynet.ret(skynet.pack(msg))
		else
			local str = "cmd not found"
			skynet.ret(skynet.pack(str,#str))
		end
	end)
end)
