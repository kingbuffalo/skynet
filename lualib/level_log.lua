local M = {}
local serpent = require("serpent")

local LOG_LEVEL = {
	FATAL = 1,
	ERROR = 2,
	INFO = 3,
	TRACE = 4,
}

local LEVEL_TAG = {
	[LOG_LEVEL.FATAL]= "FATAL:",
	[LOG_LEVEL.ERROR] = "ERROR:",
	[LOG_LEVEL.INFO] = "INFO:",
	[LOG_LEVEL.TRACE] = "TRACE:",
}

local _level

local function log(level,...)
	if _level == nil then
		local skynet = require("skynet")
		_level = skynet.getenv("log_level") or LOG_LEVEL.INFO
		_level = tonumber(_level)
	end
	if level <= _level then
		local l = {...}
		local sarr = {}
		for _,v in ipairs(l) do
			local s = v
			if type(v) == "table" then
				s = serpent.dump(v)
			end
			sarr[#sarr+1] = tostring(s)
		end

		local skynet = require("skynet")
		skynet.error(LEVEL_TAG[level],table.concat(sarr,"\t"))
	end
end

function M.trace(...)
	log(LOG_LEVEL.TRACE,...)
end

function M.error(...)
	log(LOG_LEVEL.ERROR,...)
end

function M.fatal(...)
	log(LOG_LEVEL.FATAL,...)
end

function M.info(...)
	log(LOG_LEVEL.INFO,...)
end

return M
