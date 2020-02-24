local cmdM = {}

local gift = require("game.config.gift")

function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local giftId = cmdVO.p1
	if gift[giftId] == nil then return {err=1} end
	local count = cmdVO.p2
	local pid = cmdVO.pid
	local addItemByLoc = require("game.cmd.addItemByLoc")
	addItemByLoc.addGift(pid,giftId,count)
	return {err=0}
end

return cmdM
