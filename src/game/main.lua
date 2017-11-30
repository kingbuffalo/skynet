local skynet = require "skynet"

--以VO为结尾的，为数据结构
--以Tbl为结尾的，为存到数据库的数据结构
--以TblT为结尾的，为存到数据库的数据结构  以xx为key 对应 Tbl的table
--以TblArr为结尾的，为存到数据库的数据结构  Tbl的Array
--以Cfg为结尾的，为静态配置表的数据结构

--local max_client = 64
skynet.start(function()
	skynet.error("Server start")

	local port = skynet.getenv("port")
	skynet.uniqueservice("game/gated",port)
	skynet.uniqueservice("utils/db/ssdbd")
	skynet.newservice("debug_console",8000)

	--local configMgr = require("game.config.configMgr")
	--configMgr.init()
	--
	local tblcfg = require("game.tblcfg")
	tblcfg.genClassTag()

	skynet.exit()
end)
