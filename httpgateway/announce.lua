local M = {
	_cfg=nil,
}

local function saveCfg(cfg)
	local f = io.open("./games/shisanshui/gm/announce.config","w")
	local serpent = require("serpent")
	local str = serpent.strNumKeyDump(cfg)
	f:write(str)
	f:flush()
	f:close()
end

function M.clearCache()
	M._cfg = nil
end

function M.getAnnounce()
	if M._cfg == nil then
		local f = io.open("./games/shisanshui/gm/announce.config","r")
		local allStr = f:read("*a")
		f:close()
		local serpent = require("serpent")
		local ok,obj = serpent.load(allStr)
		assert(ok==true,ok)
		M._cfg = obj
	end
	local ct = os.time()
	if M._cfg.announce.et ~= 0 then
		if M._cfg.announce.et < ct then
			M._cfg.announce.content = ""
			M._cfg.announce.et = 0
			saveCfg(M._cfg)
		end
	end
	return M._cfg
end


function M.setHorseLamp(str)
	M._cfg.horse_lamp = str
	saveCfg(M._cfg)
end

function M.setAnnounce(str,bt,et)
	if bt == nil then bt = os.time() end
	if et == nil then et = 0 end
	M._cfg.announce.bt = bt
	M._cfg.announce.et = et
	M._cfg.announce.content = str
	saveCfg(M._cfg)
end

return M
