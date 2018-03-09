--local skynet = require "skynet"
local level_log = require("zjutils/level_log")
local serpent = require ("serpent")

local PM = {
	__tableCache = {},
	__fieldCache = {},
	__keyMap1 = {},

	__tableCacheInc = {},
	__fieldCacheInc = {},
}

function PM.close(db)
	db:disconnect()
end

function PM.initKeyFldArr(db,tbNameMapKeyFlds)
	local skynet = require("skynet")
	skynet.error("initKeyFldArr")
	for k,v in pairs(tbNameMapKeyFlds) do
		local keyMap1 = {}
		for _,vv in ipairs(v) do
			keyMap1[vv] = 1
		end
		PM.__keyMap1[k] = keyMap1
	end
end

function PM.queryStr(db,queryStr)
	local res =  db:query(queryStr)
	if res.err then
		level_log.info("mysql queryStr! errno:", res.errno, res.err,queryStr)
	end
	local utilsFunc = require("zjutils/utilsFunc")
	utilsFunc.debugPrint(queryStr,"mysql queryStr result:", res)
	return res
end

function PM.insertInc(db,tableName,tbl)
	local utilsFunc = require("zjutils/utilsFunc")
	utilsFunc.debugPrint(tableName,tbl)
	local preSql = PM.__tableCacheInc[tableName]
	if preSql == nil then
		local field = {}
		local sql = "INSERT INTO "..tableName.."("
		local s1t = {}
		for k, v in pairs(tbl) do
			if type(k) == "string" then
				s1t[#s1t+1] = k
				table.insert(field, k)
			end
		end
		local s1 = table.concat(s1t,",")
		preSql = sql .. s1 .. ") VALUES(" --.. s2 .. ")"
		PM.__tableCacheInc[tableName] = preSql
		PM.__fieldCacheInc[tableName] = field
	end
	local fed = PM.__fieldCacheInc[tableName]
	local s2t = {}
	for _, k in ipairs(fed) do
		local v = tbl[k]
		if v == nil then
			level_log.info("mysql insert:", tableName, serpent.strNumKeyDump(tbl))
		end
		local vstr
		if type(v) == "string" then
			 vstr = "'"..v.."'"
		else
			vstr = v
		end
		if vstr ~= nil then
			s2t[#s2t+1] = vstr
		end
	end
	local s2 = table.concat(s2t,",")
	local sql = preSql .. s2 ..")"
	level_log.trace("mysql insert autoInc",sql)
	local res =  db:query(sql)
	if res.err then
		level_log.info("mysql insert! errno:", res.errno, res.err, tableName, serpent.strNumKeyDump(tbl))
	end
	return res
end

function PM.insertDuplicate(db,tableName,tbl)
	local preSql = PM.__tableCache[tableName]
	if preSql == nil then
		local field = {}
		local sql = "INSERT INTO "..tableName.."("
		local s1t = {}
		for k, v in pairs(tbl) do
			if type(k) == "string" then
				s1t[#s1t+1] = k
				table.insert(field, k)
			end
		end
		local s1 = table.concat(s1t,",")
		preSql = sql .. s1 .. ") VALUES(" --.. s2 .. ")"
		PM.__tableCache[tableName] = preSql
		PM.__fieldCache[tableName] = field
	end
	assert(PM.__keyMap1[tableName],"tableName="..tableName.." not found keyflds")
	local fed = PM.__fieldCache[tableName]
	local keyMap1 = PM.__keyMap1[tableName]
	local s2t = {}
	local s3T = {}
	for _, k in ipairs(fed) do
		local v = tbl[k]
		if v == nil and keyMap1[k] ~= nil then
			level_log.info("mysql insert:", tableName, serpent.strNumKeyDump(tbl))
		end
		local vstr
		if type(v) == "string" then
			 vstr = "'"..v.."'"
		else
			vstr = v
		end
		if vstr ~= nil then
			s2t[#s2t+1] = vstr
			if keyMap1[k] == nil then
				s3T[#s3T+1] = k .. "=" .. vstr
			end
		end
	end
	local s2 = table.concat(s2t,",")
	local s3 = table.concat(s3T,",")
	local sql = preSql .. s2 ..") ON DUPLICATE KEY UPDATE " .. s3
	level_log.trace("mysql insertDuplicate ",sql)
	local res =  db:query(sql)
	if res.err then
		level_log.info("mysql insert! errno:", res.errno, res.err, tableName, serpent.strNumKeyDump(tbl))
	end
	return res
end

function PM.insert(db,tableName, tbl)
	--这个函数在字符串连接上，还没有优化
	local preSql = PM.__tableCache[tableName]
	if preSql == nil then
		local field = {}
		local sql = "insert into "..tableName.."("
		local s1t = {}
		for k, v in pairs(tbl) do
			if type(k) == "string" then
				s1t[#s1t+1] = k
				table.insert(field, k)
			end
		end
		local s1 = table.concat(s1t,",")
		preSql = sql .. s1 .. ") values(" --.. s2 .. ")"
		PM.__tableCache[tableName] = preSql
		PM.__fieldCache[tableName] = field
	end
	local fed = PM.__fieldCache[tableName]
	local s2t = {}
	for _, k in ipairs(fed) do
		local v = tbl[k]
		if v == nil then
			level_log.info("mysql insert:", tableName, serpent.strNumKeyDump(tbl))
		end
		local vstr
		if type(v) == "string" then
			vstr = "'"..v.."'"
		else
			vstr = v
		end
		if vstr ~= nil then
			s2t[#s2t+1] = vstr
		end
	end
	local s2 = table.concat(s2t,",")
	local sql = preSql .. s2 ..")"
	level_log.trace("mysql insert:",sql)
	local res =  db:query(sql)
	if res.err then
		level_log.info("mysql insert! errno:", res.errno, res.err, tableName, serpent.strNumKeyDump(tbl))
	end
	return res
end

function PM.query(db,tableName,seltb,wtbl)
	local utilsFunc = require("zjutils/utilsFunc")
	utilsFunc.debugPrint(tableName,seltb,wtbl)
	local sqlT = {"SELECT"}
	for k,v in pairs(seltb) do
		if #seltb > 1 and k < #seltb then
			sqlT[#sqlT+1] = v..","
		else
			sqlT[#sqlT+1] = v
		end
	end
	sqlT[#sqlT+1] = "FROM "..tableName
	if wtbl then
		sqlT[#sqlT+1] = "WHERE"
		for k,v in pairs(wtbl) do
			if #wtbl > 1 and k < #wtbl then
				if type(v[3]) == "string" then
					sqlT[#sqlT+1] = v[1].." "..v[2].." '"..v[3].."' &&"
				else
					sqlT[#sqlT+1] = v[1].." "..v[2].." "..v[3].." &&"
				end
			else
				if type(v[3]) == "string" then
					sqlT[#sqlT+1] = v[1].." "..v[2].." '"..v[3].."'"
				else
					sqlT[#sqlT+1] = v[1].." "..v[2].." "..v[3]
				end
			end
		end
	end
	local sql = table.concat(sqlT," ")
	local res =  db:query(sql)
	if res.err then
		level_log.info("mysql query! errno:",
			res.errno, res.err, tableName, serpent.strNumKeyDump(seltb),serpent.strNumKeyDump(wtbl))
	end
	utilsFunc.debugPrint(sql,"query result",res)
	return res
end

function PM.update(db,tableName,tbl)
	local sql = "UPDATE "..tableName.." SET "
	local keyMap1 = PM.__keyMap1[tableName]
	local st = {}
	local wt = {}
	for k, v in pairs(tbl) do
		if type(k) == "string" then
			local vstr
			if type(v) == "string" then
				vstr = "'" .. v .. "'"
			else
				vstr = v
			end
			local s = k .. "=" .. vstr
			st[#st+1] = s
			if keyMap1[k] ~= nil then
				wt[#wt+1] = s
			end
		end
	end
	local sts = table.concat(st,",")
	assert(#wt > 0,serpent.dump(keyMap1)..",tbl="..serpent.dump(tbl))
	local wts = table.concat(wt," && ")
	sql = sql..sts .." WHERE " ..wts
	level_log.trace(sql)
	local res =  db:query(sql)
	if res.err then
		level_log.info("mysql update! errno:", res.errno, res.err, tableName,serpent.strNumKeyDump(tbl))
	end
	return res
end

return PM
