require "common"
local skynet = require "skynet"
local mysql = require "mysql"
local json = require "cjson"


function init(...)
	--print ("mysqld server start:", ...)
	local host, db_name, username, password = ...
	db = mysql.connect{	
		host=host,
		port=3306,
		database=db_name,
		user=username,
		password=password,
		max_packet_size = 1024 * 1024
	}
	if not db then
		logError("failed to connect mysql!", ...)
	end
-- You can return "queue" for queue service mode
	return "queue"
end

function exit(...)
	--print ("mysqld server exit:", ...)
end

function response.error()
	error "throw an error"
end

function accept.exec(sql)
	print("mysqld exex!", sql)
	local res =  db:query(sql)
	if res.err then
		skynet.error("errno:", res.errno, res.err)
	end
end

--[[
function response.query(sql)
	--print("mysqld query!", sql)
	local res = db:query(sql)
	--print_r(res)
	return res
end
]]

function response.query(tableName, seltb, wtbl)
	--print("mysqld query!", json.encode(tbl))
	local sql = "select "

	for k,v in pairs(seltb) do
		if #seltb > 1 and k < #seltb then
			sql = sql..v..", "
		else
			sql = sql..v.." "
		end
	end

	sql = sql.."from "..tableName.." "

	if wtbl then
		sql = sql.."where "

		for k,v in pairs(wtbl) do
			if #wtbl > 1 and k < #wtbl then
				if type(v[3]) == "string" then
					sql = sql..v[1].." "..v[2].." '"..v[3].."' && "
				else
					sql = sql..v[1].." "..v[2].." "..v[3].." && "
				end
			else
				if type(v[3]) == "string" then
					sql = sql..v[1].." "..v[2].." '"..v[3].."' "
				else
					sql = sql..v[1].." "..v[2].." "..v[3]
				end	
			end
		end
	end
	local res =  db:query(sql)
	if res.err then
		skynet.error("mysql query! errno:", res.errno, res.err, tableName, json.encode(tbl))
	end
	return res
end


--插入一数据到表，会自动拼字符串
--[=[	效率没下面的好
function accept.insert(tableName, tbl)
	print("mysqld insert!", json.encode(tbl))
	local sql = "insert into "..tableName.."("
	local s1, s2 = "", ""
	local first = true
	for k, v in pairs(tbl) do
		if type(k) == "string" then
			if first then
				first = false
			else
				s1 = s1 .. ","
				s2 = s2 .. ","
			end
			s1 = s1 .. k
			if type(v) == "string" then
				s2 = s2 .. "'"..v.."'"
			else
				s2 = s2 .. v
			end
		end
	end
	sql = sql .. s1 .. ") values(" .. s2 .. ")"
	print(sql)
	local res =  db:query(sql)
	if res.err then
		skynet.error("mysql insert! errno:", res.errno, res.err, tableName, json.encode(tbl))
	end
end
]=]

local tableCache = {}
local fieldCache = {}
--插入一数据到表，会自动拼字符串
function accept.insert(tableName, tbl)
	--print("mysqld insert!", json.encode(tbl))
	local preSql = tableCache[tableName]
	if preSql == nil then
		local field = {}
		local sql = "insert into "..tableName.."("
		local s1 = ""
		local first = true
		for k, v in pairs(tbl) do
			if type(k) == "string" then
				if first then
					first = false
				else
					s1 = s1 .. ","
				end
				s1 = s1 .. k
				table.insert(field, k)
			end
		end
		preSql = sql .. s1 .. ") values(" --.. s2 .. ")"
		tableCache[tableName] = preSql
		fieldCache[tableName] = field
	end
	local fed = fieldCache[tableName]
	local s2 = ""
	local first = true
	for _, k in ipairs(fed) do
		if first then
			first = false
		else
			s2 = s2 .. ","
		end
		local v = tbl[k]
		if v == nil then
			logError("mysql insert:", tableName, json.encode(tbl))
		end
		if type(v) == "string" then
			s2 = s2 .. "'"..v.."'"
		else
			s2 = s2 .. v
		end
	end
	local sql = preSql .. s2 ..")"
	--print(sql)
	local res =  db:query(sql)
	if res.err then
		logError("mysql insert! errno:", res.errno, res.err, tableName, json.encode(tbl))
	end
end

--更新数据到表，会自动拼字符串
function accept.update(tableName, tbl, wtbl)
	--print("mysqld update!", json.encode(tbl))
	local field = {}
	local sql = "update "..tableName.." set "
	local first = true
	for k, v in pairs(tbl) do
		if type(k) == "string" then
			if first then
				first = false
			else
				sql = sql..","
			end
			
			if type(v) == "string" then
				sql = sql..k.." = ".."'"..v.."'"
			else
				sql = sql..k.." = "..v
			end
		end
	end

	sql = sql.." where "

	first = true
	for k,v in pairs(wtbl) do
		if type(k) == "string" then
			if first then
				first = false
			else
				sql = sql.." && "
			end

			if type(v) == "string" then
				sql = sql..k.." = ".."'"..v.."'"
			else
				sql = sql..k.." = "..v
			end
		end
	end
	--print(sql)
	local res =  db:query(sql)
	if res.err then
		skynet.error("mysql update! errno:", res.errno, res.err, tableName, json.encode(tbl))
	end
end


--关闭服务器的时候调用
function response.stop()
	--print("mysqld stop!")
	while skynet.mqlen() > 0 do
		skynet.sleep(100)
	end
	return 0
end