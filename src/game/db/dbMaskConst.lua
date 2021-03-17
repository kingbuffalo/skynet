local M = {
	Mask = {
		PlayerTbl = 0x1,
	},
	AllBitLen = 1,
}


function M.getAllMask()
	if M._allMask == nil then
		M._allMask = 0
		for _,v in pairs(M.Mask) do
			M._allMask = M._allMask | v
		end
	end
	return M._allMask
end

local NewFunc = {
	[M.Mask.PlayerTbl] = function(pid)
		local dbPlayerTbl = require("game/src/dbPlayerTbl")
		dbPlayerTbl.NewPlayer(pid)
	end,
}

function M.CheckAndCreatTbl(currentMask,pid)
	local allMask = M.getAllMask()
	if allMask ~= currentMask then
		for i=0,M.AllBitLen-1, 1 do
			local mask = 1 << i
			if (mask & currentMask) ~= 0 then
				local f = assert(NewFunc[mask],"mask ="..(i+1) .. " not found")
				f(pid)
			end
		end
	end
	return allMask
end

return M
