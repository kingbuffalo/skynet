local M = {}
local enum = require("game/config.enum")

local dbBagTbl = require("game.db.dbBagTbl")
--local dbHeroTbl = require("game.db.dbHeroTbl")
local dbUserPlayerTbl = require("game.db.dbUserPlayerTbl")

local item = require("game.config.item")
local gift = item.gift
local lottery = item.lottery
local lotteryWeightSum = item.lotteryWeightSum

function M.init()
	return gift,lottery,lotteryWeightSum
end

function M.addGift(pid,giftId,count)
	local giftCfg = gift[giftId]
	M.addOutResCfg(pid,giftCfg.out_res,count)
end

function M.addLottery(pid,lotteryId,count)
	local lotteryCfgArr = lottery[lotteryId]
	local sum = lotteryWeightSum[lotteryId]
	if sum == nil or lotteryCfgArr == nil then return end
	local randIdx = math.random(1,sum)
	local t = 0
	local lotteryCfg
	for _,v in ipairs(lotteryCfgArr) do
		t = t + v.weight
		if t >= randIdx then
			lotteryCfg = v
			break
		end
	end
	if lotteryCfg == nil then assert(false) end
	M.addOutResCfg(pid,lotteryCfg.out_res,count)
end

function M.addOutResCfgFunc(pid,cfg_out_res,countFunc,cityTbl)
	local playerInfo
	local bagTblArr = {}
	for _,v in ipairs(cfg_out_res) do
		local loc,id,co = v[1],v[2],v[3]
		co = countFunc(loc,id,co)
		if loc == enum.LOC_BAG then
			local bagTbl = dbBagTbl.getBagTbl(pid,id)
			if bagTbl == nil then
				bagTbl = dbBagTbl.newBagTbl(id,co)
			else
				bagTbl.count = bagTbl.count + co
			end
			bagTblArr[#bagTblArr+1] = bagTbl
		elseif loc == enum.LOC_BASE_RES then
			if playerInfo == nil then
				playerInfo = dbUserPlayerTbl.getPlayerInfo(pid)
			end
			playerInfo.baseRes[id] = playerInfo.baseRes[id] + co
		elseif loc == enum.LOC_GIFT then
			M.addGift(pid,id,co)
		elseif loc == enum.LOC_CITY then
			assert(cityTbl)
			cityTbl.res[id] = cityTbl.res[id] + co
		elseif loc == enum.LOC_LOTTERY then
			M.addLottery(pid,id,co)
		end
	end

	if playerInfo then
		dbUserPlayerTbl.setPlayerInfo(playerInfo)
	end
	for _,v in ipairs(bagTblArr) do
		dbBagTbl.setBagTbl(pid,v)
	end
end
function M.addOutResCfg(pid,cfg_out_res,count,cityTbl)
	local function onlyCountFunc(co) return co * count end
	M.addOutResCfgFunc(pid,cfg_out_res,onlyCountFunc,cityTbl)
end

function M.removeNeedResCfgFunc(pid,cfg_need_res,countFunc,cityTbl)
	local playerInfo
	local bagTblArr = {}
	for _,v in ipairs(cfg_need_res) do
		local loc,id,co = v[1],v[2],v[3]
		co = countFunc(loc,id,co)
		if loc == enum.LOC_BAG then
			local bagTbl = dbBagTbl.getBagTbl(pid,id)
			if bagTbl.count < co then
				return loc
			else
				bagTbl.count = bagTbl.count - co
				bagTblArr[#bagTblArr+1] = bagTbl
			end
		elseif loc == enum.LOC_CITY then
			assert(cityTbl)
			if cityTbl.res[id] < co then
				return loc
			else
				cityTbl.res[id] = cityTbl.res[id] - co
			end
		elseif loc == enum.LOC_BASE_RES then
			if playerInfo == nil then
				playerInfo = dbUserPlayerTbl.getPlayerInfo(pid)
			end
			if playerInfo.baseRes[id]< co then
				return loc
			else
				playerInfo.baseRes[id] = playerInfo.baseRes[id] - co
			end
		end
	end
	if playerInfo then
		dbUserPlayerTbl.setPlayerInfo(playerInfo)
	end
	for _,v in ipairs(bagTblArr) do
		dbBagTbl.setBagTbl(pid,v)
	end
	return 0,playerInfo
end

function M.removeNeedResCfg(pid,cfg_need_res,count,cityTbl)
	local function onlyCountFunc(co) return co * count end
	return M.removeNeedResCfgFunc(pid,cfg_need_res,onlyCountFunc,cityTbl)
end

return M
