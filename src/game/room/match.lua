local skynet = require "skynet"
local errorcode = require("game/sprotocfg/errorcode")
local utilsFunc = require("utils/utilsFunc")
local lru_list = require("lru_list")

local udpd

local funcT = {}

local teamArr = {
	[errorcode.TEAM_TYPE_WOLF] = {}, --array element = {pid=,score=}
	[errorcode.TEAM_TYPE_SHEEP] = {}, --array element = {pid=,score=}
}
local ackIngMapPidArr = {}
local ackIngLruList = lru_list.createLRUList()

local function pushMatch(pid)
	if udpd == nil then
		udpd = skynet.queryservice("game/udpd")
	end
	local msgT = {}
	skynet.send(udpd,"lua","pushMsg",pid,"MatchAckP",msgT)
end

local function getAckArr1Arr2(arr,matchCount,oppoArr,oppoMatchCount)
--TODO 这里可以再做优化，引用积分来计算给谁匹配
	local arr1 = {}
	local arr2 = {}
	for i=1,matchCount,1 do
		arr1[i] = arr[1]
		table.remove(arr,1)
	end

	for i=1,oppoMatchCount,1 do
		arr2[i] = oppoArr[1]
		table.remove(oppoArr,1)
	end
	return arr1,arr2
end

local function match(tPidScore,teamType)
	local arr = assert(teamArr[teamType],"not found teamType="..teamType)
	local idx = utilsFunc.bSearch(arr,function(e)
		if e < tPidScore.score then return -1 end
		if e > tPidScore.score then return 1 end
		return 0
	end)
	table.insert(arr,idx+1,tPidScore)
	local matchCount = errorcode.MATCH_COUNT[teamType]
	if #arr >= matchCount then
		local oppoType = errorcode.getOppoType(teamType)
		local oppoArr = teamArr[oppoType]
		local oppoMatchCount = errorcode.MATCH_COUNT[oppoType]
		if #oppoArr >= oppoMatchCount then
			local arr1,arr2 = getAckArr1Arr2(arr,matchCount,oppoArr,oppoMatchCount)
			local ackIngInfo1 = {ack=0,ackPidMap1={},arr=arr1,max=matchCount,teamType=teamType}
			local ackIngInfo2 = {ack=0,ackPidMap1={},arr=arr2,max=oppoMatchCount,teamType=oppoType}
			ackIngInfo2.oppoInfo = ackIngInfo1
			ackIngInfo1.oppoInfo = ackIngInfo2
			for _,v in ipairs(arr1) do
				ackIngMapPidArr[v.pid] = ackIngInfo1
				pushMatch(v.pid)
			end
			for _,v in ipairs(arr2) do
				ackIngMapPidArr[v.pid] = ackIngInfo2
				pushMatch(v.pid)
			end
			local ackIng = {ackIngInfo1,ackIngInfo2}
			ackIngLruList:addValue(ackIng)
		end
	end
end

function funcT.match(pid,score,teamType)
	match({pid=pid,score=score},teamType)
end

function funcT.clientRespondMatchAck(pid)
	local ackIngInfo = ackIngMapPidArr[pid]
	if ackIngInfo == nil then return 1100201 end
	ackIngInfo.ack = ackIngInfo.ack + 1
	if ackIngInfo.ack >= ackIngInfo.max then
		if ackIngInfo.oppoInfo.ack >= ackIngInfo.oppoInfo.max then
			local _ = 1
			--TODO
			--create room
		end
	end
	return 0
end


-----------------------------------------------------------------------
local function checkOutofLineAck()
	for lruNode in ackIngLruList:rangeReverse() do
		local ackIng = lruNode.value
		local timestamp = lruNode.timestamp
		local key = lruNode.key
		local current = skynet.time()
		if current-timestamp > errorcode.MATCH_ACK_TIME then
			for idx = 1,2,1 do
				for _,v in ipairs(ackIng[idx].arr) do
					local pid = v.pid
					if ackIng.ackPidMap1[pid] ~= nil then
						match(v,ackIng[idx].teamType)
					end
				end
			end
			ackIngLruList:rmValue(key)
		else
			break
		end
	end
end
-----------------------------------------------------------------------

skynet.start(function()
	utilsFunc.forEver(100,checkOutofLineAck)
	skynet.dispatch("lua", function(_,_,funcName,...)
		local f = assert(funcT[funcName],"function not found " .. funcName)
		skynet.ret(skynet.pack(f(...)))
	end)
end)
