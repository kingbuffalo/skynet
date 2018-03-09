require "skynet.manager"
local skynet = require "skynet"

local httpHandle,gateToGameHandle = ...

skynet.start(function()
	skynet.error("zj bootstrap")

	local http_port = skynet.getenv("http_port")

	local redis_host = skynet.getenv("redis_host")
	local redis_prot = skynet.getenv("redis_prot")
	local redis_db = skynet.getenv("redis_db")
	local redis_pwd = skynet.getenv("redis_pwd")

	local mysql_host = skynet.getenv("mysql_host")
	local mysql_port = skynet.getenv("mysql_port")
	local mysql_name = skynet.getenv("mysql_name")
	local mysql_username = skynet.getenv("mysql_username")
	local mysql_password = skynet.getenv("mysql_password")

	local user_mysql_host = skynet.getenv("user_mysql_host")
	local user_mysql_port = skynet.getenv("user_mysql_port")
	local user_mysql_name = skynet.getenv("user_mysql_name")
	local user_mysql_username = skynet.getenv("user_mysql_username")
	local user_mysql_password = skynet.getenv("user_mysql_password")

	skynet.uniqueservice("zj/webd",http_port,httpHandle)
	skynet.uniqueservice("zj/mysqld",mysql_host,mysql_port,mysql_name,
		mysql_username,mysql_password)
	skynet.uniqueservice("zj/redisd",redis_host,redis_prot,redis_db,redis_pwd)
	skynet.uniqueservice("zj/user_mysqld",user_mysql_host,user_mysql_port,
		user_mysql_name,user_mysql_username,user_mysql_password)

	skynet.newservice("zj/gateToGamed",gateToGameHandle)

	local debug_console_port = skynet.getenv("debug_console_port")
	skynet.uniqueservice("debug_console",debug_console_port)

	skynet.exit()
end)
