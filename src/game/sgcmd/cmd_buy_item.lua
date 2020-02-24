local cmdM = {}

local shop = require("game.config.shop")
local enum = require("game.config.enum")
local dbShopTbl = require("game.db.dbShopTbl")
local addItemByLoc = require("game.cmd.addItemByLoc")
local DAY = 24 * 3600
local ceil = math.ceil

local function bSameDay(t1,t2)
	if t2 - t1 > DAY then return false end
	local d2 = os.date("%d",t2)
	local d1 = os.date("%d",t1)
	return d2 == d1
end

local function updateShopTbl(shopTbl,limitTy)
	local t1 = shopTbl.timestamp
	local ct = os.time()
	if limitTy == enum.SHOP_LIMIT_TYPE_DAY then
		if not bSameDay(ct,t1) then
			shopTbl.times = 0
			shopTbl.timestamp = ct
		end
		return
	end
	if limitTy == enum.SHOP_LIMIT_TYPE_WEEK then
		local w1 = os.date("%W",t1)
		local w2 = os.date("%W",ct)
		if w1 ~= w2 then
			shopTbl.times = 0
			shopTbl.timestamp = ct
		end
		return
	end
end


function cmdM.init()
end

function cmdM.recCmd(cmdVO,timeIdx)
	local pid = cmdVO.pid
	local shopId = cmdVO.p1
	local count = cmdVO.p2

	local shopCfg = shop[shopId]
	if shopCfg == nil then return {err=1} end

	local limitTy = shopCfg.limit[1]
	local shopTbl
	if limitTy ~= enum.SHOP_LIMIT_TYPE_NONE then
		shopTbl = dbShopTbl.getShopTblT(pid,shopId)
		if shopTbl == nil then
			local ti = os.time()
			shopTbl = dbShopTbl.newShopTbl(shopId,0,ti)
		else
			updateShopTbl(shopTbl,limitTy)
		end
		local limit_times = shopCfg.limit[2]
		if limit_times < shopTbl.times + count then return {err=2} end
	end

	local priceTy = shopCfg.price[1]
	local incPrice = 0
	if priceTy ~= enum.SHOP_PRICE_TYPE_STATIC then
		if shopTbl == nil then
			shopTbl = dbShopTbl.getShopTblT(pid,shopId)
		end
		for i=shopTbl.times+1,count do
			incPrice = incPrice + shopCfg.price[2] * i
		end
	end

	local function removeFunc(loc,id,co)
		local price = co*count + incPrice
		if shopCfg.discount ~= enum.TEN_THOUSAND then
			price = ceil(price*(shopCfg.discount/enum.TEN_THOUSAND))
		end
		return price
	end
	local err,playerInfo = addItemByLoc.removeNeedResCfgFunc(pid,shopCfg.need_res,removeFunc)
	if err ~= 0 then return {err=err+enum.LOC_ERR_BEGIN} end

	addItemByLoc.addOutResCfg(pid,shopCfg.out_res,count)
	if shopTbl ~= nil then
		shopTbl.times = shopTbl.times + count
		dbShopTbl.setShopTblT(pid,shopTbl)
	end
	local baseResEnum = shopCfg.need_res[1][2]
	local baseResValue = playerInfo.baseRes[baseResEnum]

	return {err=0,baseResEnum=baseResEnum,baseResValue=baseResValue}
end

return cmdM
