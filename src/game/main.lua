local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"

--以VO为结尾的，为数据结构
--以Tbl为结尾的，为存到数据库的数据结构
--以TblT为结尾的，为存到数据库的数据结构  以xx为key 对应 Tbl的table
--以TblArr为结尾的，为存到数据库的数据结构  Tbl的Array
--以Cfg为结尾的，为静态配置表的数据结构

--local max_client = 64
skynet.start(function()
	skynet.error("Server start")

	local f = io.open("/home/cds/coder/skynet/src/game/sprotocfg/c2s.lua","r")
	local str = f:read("*a")
	f:close()

	f = io.open("/home/cds/coder/skynet/src/game/sprotocfg/s2c.lua","r")
	local str2 = f:read("*a")
	f:close()

	str = str .. "\n" .. str2
	local proto = sprotoparser.parse(str)

	sprotoloader.save(proto, 1)


	--local port = skynet.getenv("port")
	--skynet.uniqueservice("game/gated",port)
	skynet.uniqueservice("game/udpd")
	skynet.uniqueservice("utils/db/ssdbd")
	skynet.uniqueservice("game/room/roomMgr")
	skynet.uniqueservice("zj/cachedb")
	skynet.newservice("debug_console",8000)
	--skynet.newservice("game/kcplibtest")

	--local configMgr = require("game.config.configMgr")
	--configMgr.init()
	--

	skynet.exit()
end)
