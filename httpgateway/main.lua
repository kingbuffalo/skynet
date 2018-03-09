local skynet = require "skynet"

skynet.start(function()
	skynet.error("main start")

	local http_port = skynet.getenv("http_port")
	local httpHandle = "httpHandle"
	skynet.uniqueservice("zj/webd",http_port,httpHandle)

	local mysql_host = skynet.getenv("mysql_host")
	local mysql_port = skynet.getenv("mysql_port")
	local mysql_name = skynet.getenv("mysql_name")
	local mysql_username = skynet.getenv("mysql_username")
	local mysql_password = skynet.getenv("mysql_password")
	skynet.uniqueservice("zj/mysqld",mysql_host,mysql_port,mysql_name,
		mysql_username,mysql_password)

	--还有一个转发的service
	skynet.uniqueservice("httpToGm")

	local mysql_util = require("zjutils.mysql_util")
	local tbNameMapkeyFlds = {
		email_info = {"email_id"},
	}
	mysql_util.initKeyFldArr(tbNameMapkeyFlds,1)


	skynet.exit()
end)
