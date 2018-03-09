require "common"
local skynet = require "skynet"
local mongo = require "mongo"

local mongo_ip = skynet.getenv("mongo_ip")
local mongo_user = skynet.getenv("mongo_user")
local mongo_passwd = skynet.getenv("mongo_passwd")
local mongo_db = skynet.getenv("mongo_db")
local db = nil
local dbCnt = 0


MongoHelper = oo.class(nil, "MongoHelper")

function MongoHelper:__init()
	--p("~~~~~~~~~~~~~~~~~~~~  MongoHelper:__init")
	if db == nil then
		db = mongo.client({
				host = mongo_ip,
				username = mongo_user,	 --username,
				password = mongo_passwd, --password
			})
	end
	dbCnt = dbCnt + 1
end

function MongoHelper:find(tableName, query, selector)
	return db[mongo_db][tableName]:find(query, selector)
end

function MongoHelper:findOne(tableName, query)
	return db[mongo_db][tableName]:findOne(query)
end

function MongoHelper:update(tableName, query, data)
	db[mongo_db][tableName]:update(query, data, true)
end

function MongoHelper:delete(tableName, query, single)
	db[mongo_db][tableName]:delete(query, single)
end

function MongoHelper:drop(tableName)
	db[mongo_db][tableName]:drop()
end

function MongoHelper:__gc()
	--p("~~~~~~~~~~~~~~~~~~~~  MongoHelper:__gc")
	dbCnt = dbCnt - 1
	if dbCnt <= 0 then
		db:disconnect()
		db = nil
		dbCnt = 0
		--p("~~~~~~~~~~~~~~~~~~~~  MongoHelper:disconnect")
	end
end

return tb