local skynet = require "skynet"
local level_log = require("zjutils/level_log")
local mysql = require ("skynet.db.mysql")
--TODO
--this file can be remove

local host, port,db_name, username, password = ...

local function traceback(...)
	level_log.error(...)
end
local function xpcall_ret(ok,...)
	if ok then return skynet.pack(...)  end
	return skynet.pack({errno=90003,err=90003,errmsg="lua func error",})
end

skynet.start(function()
	local function on_connect(db)
		db:query("set charset utf8");
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
		level_log.info("failed to connect")
	end

	local mysqlHandle = require("zjutils/mysqlHandle")
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = assert(mysqlHandle[cmd],"cmd not found in mysqld dispatch:"..cmd)
		--skynet.ret(skynet.pack(f(db,...)))
		skynet.ret(xpcall_ret(xpcall(f,traceback,db,...)))
	end)
end)
