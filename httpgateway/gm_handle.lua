local gm_cmd_const = require("gm_cmd_const")
local mysql_util = require("zjutils/mysql_util")
local dkjson = require("dkjson")
local utilsFunc = require("zjutils/utilsFunc")

local tbName = "email_info"
local emailInfo_selectTbl = { "email_id", "title", "content", "rewards", "create_time" }
--local global_email_selectTbl = {"effect_time","email_id"}

local function getJsonObjErrCode(jsonObj)
	if jsonObj.title == nil then return 991001 end
	if jsonObj.content == nil then return 991002 end
	if jsonObj.rewards == nil then return 991003 end
	return 0
end

local function jsonDecode(jsonObjStr)
	local jsonObj = dkjson.decode(jsonObjStr)
	jsonObj.rewards = dkjson.encode(jsonObj.rewards)
	return jsonObj
end

local function show_emails(sendT)
	local ret = mysql_util.callQuery(tbName,emailInfo_selectTbl)
	if ret.errno ~= nil then
		return {err=991131,retStr=ret.err}
	end
	local str = dkjson.encode(ret)
	return {err=0,retStr=str}
end

local function alter_emails(sendT)
	local email_id = sendT.p1
	local jsonObjStr = sendT.p4

	local whereT = {{"email_id","=",email_id}}
	local ret = mysql_util.callQuery(tbName,emailInfo_selectTbl,whereT)
	if ret.errno ~= nil then
		return {err=991122,retStr=ret.err}
	end
	if utilsFunc.tableKeyCount(ret) == 0 then
		return {err=991121}
	end
	local jsonObj = jsonDecode(jsonObjStr)
	local err = getJsonObjErrCode(jsonObj)
	if err ~= 0 then return {err=err} end

	jsonObj.email_id = email_id
	local mysqlRet = mysql_util.callUpdate(tbName,jsonObj)
	if mysqlRet.errno ~= nil then
		return {err=991123,retStr=mysqlRet.err}
	end
	return {err=0}
end

local function add_emails(sendT)
	local jsonObjStr = sendT.p4
	local jsonObj = jsonDecode(jsonObjStr)
	local err = getJsonObjErrCode(jsonObj)
	if err ~= 0 then return {err=err} end
	local mysqlRet = mysql_util.callInsertInc(tbName,jsonObj)
	if mysqlRet.errno ~= nil then
		return {err=991151,retStr=mysqlRet.err}
	end
	return {err=0,retStr=mysqlRet.insert_id}
end

local function rm_emails(sendT)
	return {err=991141}
end

local function send_toall_email(sendT)
	local email_id = sendT.p1
	local whereT = {{"email_id","=",email_id}}
	local ret = mysql_util.callQuery(tbName,emailInfo_selectTbl,whereT)
	if ret.errno ~= nil then
		return {err=991171,retStr=ret.err}
	end
	if utilsFunc.tableKeyCount(ret) == 0 then
		return {err=991172}
	end

	local t = {email_id=email_id}
	local et = sendT.p2
	if et ~= nil and et ~= 0 then
		t.effect_time = os.time()
	end
	local mysqlRet = mysql_util.callInsert("global_emails",t)
	if mysqlRet.errno ~= nil then
		return {err=991173,retStr=mysqlRet.err}
	end
	return {err=0,retStr=mysqlRet.insert_id}
end

local function get_announce()
	local announce = require("announce")
	announce.clearCache()
	local str = dkjson.encode(announce.getAnnounce())
	return {err=0,retStr=str}
end

local M = {
	[gm_cmd_const.cmd_show_emails] = show_emails,
	[gm_cmd_const.cmd_add_emails] = add_emails,
	[gm_cmd_const.cmd_alter_emails] = alter_emails,
	[gm_cmd_const.cmd_rm_emails] = rm_emails,
	[gm_cmd_const.cmd_send_emails_toall] = send_toall_email,
	[gm_cmd_const.cmd_get_announce] = get_announce,
}


return M
