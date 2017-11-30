root = "./"
luaservice = root.."service/?.lua;".. root.."src/?.lua;"
	--.. root.. "src/login/?.lua"
lualoader = root .. "lualib/loader.lua"
lua_path = root.."lualib/?.lua;"..root.."lualib/?/init.lua;"..root.."src/?.lua;"
lua_cpath = root .. "luaclib/?.so"
snax = root.."src/?.lua;"

-- preload = "./examples/preload.lua"	-- run preload.lua before every lua service run
thread = 8
logger = nil
logpath = "."
harbor = 0
port=7759
--address = "127.0.0.1:2526"
--master = "127.0.0.1:2013"
start = "game/main"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap
--standalone = "0.0.0.0:2013"
-- snax_interface_g = "snax_g"
cpath = root.."cservice/?.so"
-- daemon = "./skynet.pid"
