local skynet = require "skynet"
local level_log = require("level_log")
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
--local table = table
local string = string

local HTTP_LIMIT = 65536
local mode,handlePath = ...
local handle

if mode == "agent" then

--skynet.error("agent:handlePath",handlePath)
handle = require(handlePath)
assert(handle.httpHandle)

local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		level_log.info(string.format("fd = %d, %s", id, err))
	end
end

skynet.start(function()
	local http_limit = skynet.getenv("http_limit") or HTTP_LIMIT
	http_limit = tonumber(http_limit)
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id),http_limit)
		if code then
			if code ~= 200 then
				response(id, code)
			else
				local path, query = urllib.parse(url)
				local q
				if query then
					q = urllib.parse_query(query)
				end
				local resStr = handle.httpHandle(path,q,body,url,method,header)
				response(id, code,resStr)
			end
		else
			if url == sockethelper.socket_error then
				level_log.info("socket closed")
			else
				level_log.info(url)
			end
		end
		socket.close(id)
	end)
end)

else

skynet.start(function()
	local agent = {}
	for i= 1, 20 do
		agent[i] = skynet.newservice("webd", "agent",handlePath )
	end
	local balance = 1
	local port = tonumber(mode)
	local http_ip_prefix = skynet.getenv("http_ip_prefix") or ""
	local listenId = socket.listen("0.0.0.0",port)
	level_log.info("Listen web port:"..port)
	socket.start(listenId, function(id, addr)
		local bUnVaild = false
		if #http_ip_prefix > 0 then
			bUnVaild = string.find(addr,http_ip_prefix) == nil
		end
		if not bUnVaild then
			level_log.info(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
			skynet.send(agent[balance], "lua", id)
			balance = balance + 1
			if balance > #agent then
				balance = 1
			end
		else
			httpd.write_response(sockethelper.writefunc(id),403,"403")
			socket.close(id)
		end
	end)
end)

end
