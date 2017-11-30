local skynet = require "skynet"

local M = {}
local SERVICENAME = "SSDB"

function M.sendExecute(...)
	skynet.send(SERVICENAME, "lua", ...)
end

function M.execute(...)
	return skynet.call(SERVICENAME, "lua", ...)
end

function M.close()
	skynet.send(SERVICENAME, "lua", "CLOSE")
end

return M

