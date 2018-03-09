local skynet = require "skynet"
require "skynet.manager"
local io = require "io"

local fg_fnprefix
local everyDay = false
local function getFnPrefix()
	if fg_fnprefix == nil then
		if everyDay then
			local fnprefix = skynet.getenv("logpath")
			local tiTmp = os.time()
			local dateTmp = os.date("*t",tiTmp)
			local dateStrTmp = string.format("%4d-%02d-%02d",dateTmp.year,dateTmp.month,dateTmp.day)
			fg_fnprefix = fnprefix .. dateStrTmp
		else
			fg_fnprefix = skynet.getenv("logpath")
		end
	end
	return fg_fnprefix
end

local function getAllLog()
	local fnp = getFnPrefix()
	local allLog = assert(io.open(fnp ..".log","a"))
	return allLog
end

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg,...)
		local allLog = getAllLog()
		local ti = math.floor(skynet.time())
		local date = os.date("*t",ti)
		local tiStr = string.format("%02d:%02d:%02d",date.hour ,date.min,date.sec)
		local logStr = string.format("%08s [%x] %s\n", tiStr,address, msg)
		if allLog ~= nil then
			allLog:write(logStr)
			allLog:flush()
			allLog:close()
		end
	end
}

skynet.register_protocol {
	name = "SYSTEM",
	id = skynet.PTYPE_SYSTEM,
	unpack = function(...) return ... end,
	dispatch = function()
		print("SIGHUP")
	end
}

skynet.start(function()
	skynet.register ".logger"
end)
