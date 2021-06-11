local skynet = require "skynet"
local socket = require "skynet.socket"
local socketchannel = require "skynet.socketchannel"
local serpent = require("serpent")

local table = table
local string = string
local assert = assert

local ssdb = {}
local command = {}
local meta = {
	__index = command,
	-- DO NOT close channel in __gc
}

---------- ssdb response
local redcmd = {}

redcmd[36] = function(fd, data) -- '$'
	local bytes = tonumber(data)
	if bytes < 0 then
		return true,nil
	end
	local firstline = fd:read(bytes+2)
	return true,string.sub(firstline,1,-3)
end

redcmd[43] = function(fd, data) -- '+'
	return true,data
end

redcmd[45] = function(fd, data) -- '-'
	return false,data
end

redcmd[58] = function(fd, data) -- ':'
	-- todo: return string later
	return true, tonumber(data)
end

local function read_response(fd)
	local result = fd:readline "\r\n"
	local firstchar = string.byte(result)
	local data = string.sub(result,2)
	local tret,strret = redcmd[firstchar](fd,data)
	return tret,strret
end

redcmd[42] = function(fd, data)	-- '*'
	local n = tonumber(data)
	if n < 0 then
		return true, nil
	end
	local bulk = {}
	local noerr = true
	for i = 1,n do
		local ok, v = read_response(fd)
		if not ok then
			noerr = false
		end
		bulk[i] = v
	end
	return noerr, bulk
end

-------------------

function command:disconnect()
	self[1]:close()
	setmetatable(self, nil)
end

-- msg could be any type of value
local function make_cache(f)
	return setmetatable({}, {
		__mode = "kv",
		__index = f,
	})
end

local header_cache = make_cache(function(t,k)
		local s = "\r\n$" .. k .. "\r\n"
		t[k] = s
		return s
	end)

local command_cache = make_cache(function(t,cmd)
		local s = "\r\n$"..#cmd.."\r\n"..cmd:upper()
		t[cmd] = s
		return s
	end)

local count_cache = make_cache(function(t,k)
		local s = "*" .. k
		t[k] = s
		return s
	end)

local function compose_message(cmd, msg)
	local t = type(msg)
	local lines = {}

	if t == "table" then
		lines[1] = count_cache[#msg+1]
		lines[2] = command_cache[cmd]
		local idx = 3
		for _,v in ipairs(msg) do
			v= tostring(v)
			lines[idx] = header_cache[#v]
			lines[idx+1] = v
			idx = idx + 2
		end
		lines[idx] = "\r\n"
	else
		msg = tostring(msg)
		lines[1] = "*2"
		lines[2] = command_cache[cmd]
		lines[3] = header_cache[#msg]
		lines[4] = msg
		lines[5] = "\r\n"
	end

	print("-----------------db oper--------------------- *****************")
	local utilsFunc = require "utils.utilsFunc"
	utilsFunc.printTable(lines)
	print("-----------------db oper--------------------- **************end")
	return lines
end

local function ssdb_login(auth, db)
	if auth == nil then return end
	return function(so)
		so:request(compose_message("AUTH", auth), read_response)
	end
end

function ssdb.connect(db_conf)
	local channel = socketchannel.channel {
		host = db_conf.host,
		port = db_conf.port or 6379,
		auth = ssdb_login(db_conf.auth),
		nodelay = true,
	}
	-- try connect first only once 表示没看懂 估计要去看看socket了
	channel:connect(true)
	return setmetatable( { channel }, meta )
end

setmetatable(command, { __index = function(t,k)
	local cmd = string.upper(k)
	local f = function (self, v, ...)
		print("ssdb,commnad:",cmd,v,...)
		if type(v) == "table" then
			return self[1]:request(compose_message(cmd, v), read_response)
		else
			return self[1]:request(compose_message(cmd, {v, ...}), read_response)
		end
	end
	t[k] = f
	return f
end})

local function read_boolean(so)
	local ok, result = read_response(so)
	return ok, result ~= 0
end

function command:hexists(key,key2)
	local fd = self[1]
	return fd:request(compose_message ("HEXISTS", key,key2), read_boolean)
end

function command:exists(key)
	local fd = self[1]
	return fd:request(compose_message ("EXISTS", key), read_boolean)
end

----------------------------serialize  merge oper --------------begin
function command:gets(key)
	local fd = self[1]
	local s = fd:request(compose_message ("get", key),read_response)
	if s == nil then return nil end
	local ok,t = serpent.load(s)
	assert(ok==true,ok)
	return t
end
function command:sets(key,t)
	local fd = self[1]
	local s = serpent.strNumKeyDump(t)
	--local s = serpent.dump(t)
	return fd:request(compose_message("set", {key,s}),read_response)
end

function command:hgets(key,key2)
	local fd = self[1]
	local s = fd:request(compose_message ("hget", {key,key2}),read_response)
	if s == nil then return nil end
	local ok,t = serpent.load(s)
	assert(ok==true,ok)
	return t
end
function command:hsets(key,key2,t)
	local fd = self[1]
	local s = serpent.strNumKeyDump(t)
	return fd:request(compose_message ("hset", {key,key2,s}),read_response)
end

function command:hsetalls(key,...)
	local args = {...}
	if #args == 1 then
		local t = args[1]
		local arr = {}
		for k,v in pairs(t) do
			arr[#arr+1] = k
			arr[#arr+1] = serpent.strNumKeyDump(v)
		end
		return self:multi_hset(key,table.unpack(arr))
	end
	return self:multi_hset(key,...)
end

function command:hgetalls(key)
	local fd = self[1]
	local t = fd:request(compose_message ("hgetall", key),read_response)
	local h = {}
	local ok
	for i = 1, #t, 2 do
		local k = t[i]
		k = tonumber(k) or k
		ok,h[k] = serpent.load(t[i+1])
		assert(ok==true,ok)
	end
	return h
end
----------------------------serialize  merge oper --------------end

function command:hsetall(key,...)
	local args = {...}
	if #args == 1 then
		local t = args[1]
		local arr = {}
		for k,v in pairs(t) do
			arr[#arr+1] = k
			arr[#arr+1] = v
		end
		return self:multi_hset(key,table.unpack(arr))
	end
	return self:multi_hset(key,...)
end

function command:hgetall(key)
	local fd = self[1]
	local t = fd:request(compose_message ("hgetall", key),read_response)
	local h = {}
	for i = 1, #t, 2 do
		local k = t[i]
		k = tonumber(k) or k
		h[k] = t[i+1]
	end
	return h
end

local function compose_table(lines, msg)
	local tinsert = table.insert
	tinsert(lines, count_cache[#msg])
	for _,v in ipairs(msg) do
		v = tostring(v)
		tinsert(lines,header_cache[#v])
		tinsert(lines,v)
	end
	tinsert(lines, "\r\n")
	return lines
end

function command:pipeline(ops,resp)
	assert(ops and #ops > 0, "pipeline is null")

	local fd = self[1]

	local cmds = {}
	for _, cmd in ipairs(ops) do
		compose_table(cmds, cmd)
	end

	if resp then
		return fd:request(cmds, function (fd)
			for i=1, #ops do
				local ok, out = read_response(fd)
				table.insert(resp, {ok = ok, out = out})
			end
			return true, resp
		end)
	else
		return fd:request(cmds, function (fd)
			local ok, out
			for i=1, #ops do
				ok, out = read_response(fd)
			end
			-- return last response
			return ok,out
		end)
	end
end

return ssdb
