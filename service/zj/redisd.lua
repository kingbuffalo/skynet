local skynet = require "skynet"
local redis = require ("skynet.db.redis")
local tonumber = tonumber

local host,port,dbnumber,pwd = ...

skynet.start(function()
	local conf = { host=host, port=tonumber(port), db=tonumber(dbnumber),auth=pwd }
	local db = redis.connect(conf)
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = db[cmd]
		skynet.ret(skynet.pack(f(db,...)))
	end)
end)
