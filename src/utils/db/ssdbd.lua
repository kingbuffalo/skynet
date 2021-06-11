local skynet = require "skynet"
require ("skynet.manager")
local ssdb = require "skynet.db.ssdb"

local db

local host,port,auth = ...
port = tonumber(port)

local SERVICENAME = "SSDB"

skynet.start(function()
	local conf = { host = host, port =port, auth = auth }
	db = ssdb.connect(conf)
	skynet.register(SERVICENAME)
	skynet.dispatch("lua", function (_, _, cmd, ...)
		if cmd == "CLOSE" then
			--不知道应该怎么退出，是写在gc那里吗？
			db:disconnect()
		else
			local f = db[cmd]
			local msg = f(db,...)
			if type(msg) == "number" then
				msg = tostring(msg)
			end
			if msg ~= nil then
				skynet.ret(skynet.pack(msg,#msg))
			else
				skynet.ret(skynet.pack(nil,0))
			end
		end
	end)
end)

