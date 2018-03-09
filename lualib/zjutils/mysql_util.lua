local M = {}
require "skynet.manager"
local skynet = require("skynet")
local level_log = require("zjutils/level_log")
local service_name = "zj/mysqld"
local user_service_name = "zj/user_mysqld"

function M.initKeyFldArr(tbNameMapkeyFlds,mysqlCount)
	local mysqld = skynet.queryservice(service_name)
	skynet.send(mysqld,"lua","initKeyFldArr",tbNameMapkeyFlds)
	if mysqlCount > 1 then
		mysqld = skynet.queryservice(user_service_name)
		skynet.send(mysqld,"lua","initKeyFldArr",tbNameMapkeyFlds)
	end
end

function M.sendInsertInc(tbName,luaTable)
	local mysqld = skynet.queryservice(service_name)
	skynet.send(mysqld,"lua","insertInc",tbName,luaTable)
end

function M.callInsertInc(tbName,luaTable)
	local mysqld = skynet.queryservice(service_name)
	return skynet.call(mysqld,"lua","insertInc",tbName,luaTable)
end

function M.sendInsertDuplicate(tbName,luaTable)
	local mysqld = skynet.queryservice(service_name)
	skynet.send(mysqld,"lua","insertDuplicate",tbName,luaTable)
end

function M.callInsertDuplicate(tbName,luaTable,bUserSql)
	if bUserSql == nil then bUserSql = false end
	local sn = bUserSql and user_service_name or service_name
	level_log.trace("callInsertDuplicate",sn)
	local utilsFunc = require("zjutils/utilsFunc")
	utilsFunc.debugPrint(tbName,luaTable)
	local mysqld = skynet.queryservice(sn)
	return skynet.call(mysqld,"lua","insertDuplicate",tbName,luaTable)
end

function M.sendUpdate(tbName,luaTable)
	local mysqld = skynet.queryservice(service_name)
	skynet.send(mysqld,"lua","update",tbName,luaTable)
end

function M.callUpdate(tbName,luaTable)
	local mysqld = skynet.queryservice(service_name)
	return skynet.call(mysqld,"lua","update",tbName,luaTable)
end

function M.sendInsert(tbName,luaTable,bUserSql)
	if bUserSql == nil then bUserSql = false end
	local sn = bUserSql and user_service_name or service_name
	local mysqld = skynet.queryservice(sn)
	skynet.send(mysqld,"lua","insert",tbName,luaTable)
end

function M.closeDb()
	local mysqld = skynet.queryservice(service_name)
	skynet.send(mysqld,"lua","close")
	mysqld = skynet.queryservice(user_service_name)
	skynet.send(mysqld,"lua","close")
end

function M.callInsert(tbName,luaTable)
	local mysqld = skynet.queryservice(service_name)
	return skynet.call(mysqld,"lua","insert",tbName,luaTable)
end

function M.callQueryStr(queryStr)
	local mysqld = skynet.queryservice(service_name)
	return skynet.call(mysqld,"lua","queryStr",queryStr)
end

function M.callQuery(tbName,selectTbl,whereTbl,bUserSql)
	if bUserSql == nil then bUserSql = false end
	local sn = bUserSql and user_service_name or service_name
	local mysqld = skynet.queryservice(sn)
	return skynet.call(mysqld,"lua","query",tbName,selectTbl,whereTbl)
end

return M
