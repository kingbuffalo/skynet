local skynet = require "skynet"

skynet.start(function()
	skynet.error("Server start")
	local port = skynet.getenv("port")

	skynet.newservice("login/logind2",port)
	skynet.uniqueservice("utils/db/ssdbd")
	skynet.newservice("debug_console",8000)
--	local gate = skynet.newservice("login/gated", loginserver)
--	skynet.call(gate, "lua", "open" , {
--		port = 8888,
--		maxclient = 64,
--		servername = "sample",
--	})

	skynet.exit()
end)
