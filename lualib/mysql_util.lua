local M = {}
require "skynet.manager"
local skynet = require("skynet")
local level_log = require("level_log")
local service_name = "mysqld"

function M.initKeyFldArr(tbNameMapkeyFlds)
	local mysqld = skynet.queryservice(service_name)
	M._mysqldAddr = mysqld
	skynet.send(mysqld,"lua","initKeyFldArr",tbNameMapkeyFlds)
end

function M.sendInsertInc(tbName,luaTable)
	local mysqld = M._mysqldAddr
	skynet.send(mysqld,"lua","insertInc",tbName,luaTable)
end

function M.callInsertInc(tbName,luaTable)
	local mysqld = M._mysqldAddr
	return skynet.call(mysqld,"lua","insertInc",tbName,luaTable)
end

function M.sendInsertDuplicate(tbName,luaTable)
	local mysqld = M._mysqldAddr
	skynet.send(mysqld,"lua","insertDuplicate",tbName,luaTable)
end

function M.callInsertDuplicate(tbName,luaTable)
	local sn = service_name
	level_log.trace("callInsertDuplicate",sn)
	local utilfuncs= require("utilfunc/utilfuncs")
	utilfuncs.debugPrint(tbName,luaTable)
	local mysqld = M._mysqldAddr
	return skynet.call(mysqld,"lua","insertDuplicate",tbName,luaTable)
end

function M.sendUpdate(tbName,luaTable)
	local mysqld = M._mysqldAddr
	skynet.send(mysqld,"lua","update",tbName,luaTable)
end

function M.callUpdate(tbName,luaTable)
	local mysqld = M._mysqldAddr
	return skynet.call(mysqld,"lua","update",tbName,luaTable)
end

function M.sendInsert(tbName,luaTable)
	local sn = service_name
	local mysqld = M._mysqldAddr
	skynet.send(mysqld,"lua","insert",tbName,luaTable)
end

function M.closeDb()
	local mysqld = M._mysqldAddr
	skynet.send(mysqld,"lua","close")
end

function M.callInsert(tbName,luaTable)
	local mysqld = M._mysqldAddr
	return skynet.call(mysqld,"lua","insert",tbName,luaTable)
end

function M.callQueryStr(queryStr)
	local mysqld = M._mysqldAddr
	return skynet.call(mysqld,"lua","queryStr",queryStr)
end

function M.callQuery(tbName,selectTbl,whereTbl)
	local sn = service_name
	local mysqld = M._mysqldAddr
	return skynet.call(mysqld,"lua","query",tbName,selectTbl,whereTbl)
end

return M
