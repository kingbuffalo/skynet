local skynet = require "skynet"
local mysql = require ("skynet.db.mysql")
local level_log = require("level_log")

local host, port,db_name, username, password = ...

--因为db比较不一样
local function xpcall_ret(ok,...)
	if ok then return skynet.pack(...)  end
	return skynet.pack({errno=90003,err=90003,errmsg="lua func error",})
end

skynet.start(function()
	local function on_connect(db)
		db:query("set charset utf8mb4")
	end
	local db=mysql.connect({
		host=host,
		port=tonumber(port),
		database=db_name,
		user=username,
		password=password,
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})

	if not db then
		level_log.fatal( "failed to connect to mysql")
		skynet.abort()
	end

	local mysqlHandle = require("mysqlHandle")
	local utilfuncs = require("utilfunc/utilfuncs")
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = assert(mysqlHandle[cmd],"cmd not found in mysqld dispatch:"..cmd)
		skynet.ret(xpcall_ret(xpcall(f,utilfuncs.traceback,db,...)))
	end)
end)
