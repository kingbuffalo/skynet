local skynet = require "skynet"
local harbor = require("skynet.harbor")
local AGENT_MAX = 20

local mode,handlePath = ...

if mode == "agent" then

local handle = require(handlePath)

skynet.start(function()
	skynet.dispatch("lua", function (_,_,cmd,...)
		local f = assert(handle[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)
end)

else

skynet.start(function()
	local name = skynet.getenv("gs_node_name")
	harbor.globalname(name)
	local agent = {}
	for i=1,AGENT_MAX do
		agent[i] = skynet.newservice("zj/gateToGamed","agent",mode)
	end
	local balance = 1
	skynet.dispatch("lua", function(session, address, ...)
		skynet.send(agent[balance],"lua",...)
		balance = balance + 1
		if balance > AGENT_MAX then
			balance = 1
		end
	end)
end)

end
