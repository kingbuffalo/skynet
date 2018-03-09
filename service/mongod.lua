require "common"
local skynet = require "skynet"
local mongo = require "mongo"
local json = require "cjson"
local DEBUG 
local bson_encode 


local db, db_name
function init(...)
	DEBUG = skynet.getenv("DEBUG")
	if DEBUG then
		local bson = require "bson"
		bson_encode = bson.encode
	end
	--print ("mongod server start:", ...)
	local host, username, password
	host, db_name, username, password = ...
	db = mongo.client({
			host = host,
			username = username, --,
			password = password, --
		})
	--这里最好检测一下是否连接成功
	if db == nil then
		logError("mongod failed to connect")
	end
-- You can return "queue" for queue service mode
--	return "queue"
end

function exit(...)
	--print ("mongod server exit:", ...)
	
end

function response.error()
	error "throw an error"
end

function accept.insert(tableName, tbl)
	--print("mongod insert!", json.encode(tbl))
	if DEBUG then
		local ok = pcall(bson_encode, tbl)
		if not ok then
			logError("mongo insert:", json.encode(tbl))
		end
	end
	local ret = db[db_name][tableName]:safe_insert(tbl)
	if ret == nil or ret.n ~= 1 then
		skynet.error("mongod insert! errno:", json.encode(ret), json.encode(tbl))
	end
end

--upsert:如果查找不到记录是否生成新的记录, 默认是
--multi:是否更新多条，默认一条
function accept.update(tableName, selector, tbl, upsert, multi)
	if DEBUG then
		local ok = pcall(bson_encode, tbl)
		if not ok then
			logError("mongo update:", json.encode(selector), json.encode(tbl))
		end
	end
	--print("mongod update!", json.encode(tbl))
	if upsert == nil then upsert = true end
	db[db_name][tableName]:update(selector, tbl, upsert, multi)
end

--查询到多条的情况
--sort: {_id = -1} -1表示倒序，默认增序
--skip: 2  表示跳过两个
--limit: 2 表示只显示两个
function response.find(tableName, tbl, sort, skip, limit)
	--print("mongod find!", tableName, json.encode(tbl))
	local ret = db[db_name][tableName]:find(tbl)
	if sort then
		ret = ret:sort(sort)
	end
	if skip then
		ret = ret:skip(skip)
	end
	if limit then
		ret = ret:limit(limit)
	end
	local r = {}
	while ret:hasNext() do
		local item = ret:next()
		table.insert(r, item)
	end
	return r
end

--查找到一条就返回，一般情况下用findOne
function response.findOne(tableName, tbl, selector)
	--print("mongod findOne!", tableName, json.encode(tbl))
	return db[db_name][tableName]:findOne(tbl, selector)
end

--一次查到多条表的记录，需要查询条件一致
function response.findMulti(tableNameList, tbl)
	--print("mongod findOne!", tableName, json.encode(tbl))
	local r = {}
	for k, tableName in ipairs(tableNameList) do
		r[k] = db[db_name][tableName]:findOne(tbl)
	end
	--p(r)
	return r
end

--当single==1表示删除一条（如果有多条记录）
function accept.delete(tableName, tbl, single)
	--print("mongod delete!", json.encode(tbl), single)
	db[db_name][tableName]:delete(tbl, single)
end

--创建索引 tab:索引值的表 options:选项表
function accept.ensureIndex(tableName, tbl, options)
	--print("mongod ensureIndex!", tableName, json.encode(tbl))
	db[db_name][tableName]:ensureIndex(tbl, options)
end

--关闭服务器的时候调用
function response.stop()
	--print("mongod stop!")
	while skynet.mqlen() > 0 do
		skynet.sleep(100)
	end
	return 0
end