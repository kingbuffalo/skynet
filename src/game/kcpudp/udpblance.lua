local skynet = require "skynet"
local socket = require "skynet.socket"
local LKcp = require "lkcp"
local protoT = require "game/sprotocfg/protoT"
local sprotoloader = require "sprotoloader"
local json = require "utils/json"
local fromMapPid = {}
local pidMapFrom = {}

local fromMapKcp = {}

local funcT = {}

function funcT.updatePidFrom(from,pid)
	fromMapPid[from] = pid
	pidMapFrom[pid] = from
end

function funcT.pushMsg(pid,sMsgType,tMsg)
	local from = pidMapFrom[pid]
	if from == nil then
		skynet.error("pid not found",pid)
	end
	local kcp = fromMapKcp[from]
	if kcp == nil then
		skynet.error("kcp not found",pid)
	end

	local protoId = protoT[sMsgType]
	if protoId == nil then assert(false,"sMsgType not found,sMsgType="..sMsgType) end
	local sp = sprotoloader.load(1)
	local msg = sp:encode(sMsgType,tMsg)
	local rb1 = (protoId>> 8 )& 0xff
	local rb2 = (protoId)& 0xff
	local retStr = string.char(rb1,rb2)
	retStr = retStr.. msg
	kcp:lkcp_send(retStr)
end

local function getKcp(from,host)
    local session = 1048
	local kcp = fromMapKcp[from]
	if kcp == nil then
		kcp = LKcp.lkcp_create(session, function (buf)
			socket.sendto(host, from, buf)
		end)
		kcp:lkcp_wndsize(128, 128)
		kcp:lkcp_nodelay(0, 10, 0, 0)
		fromMapKcp[from] = kcp
		skynet.fork(function()
			while 1 do
				skynet.sleep(1)
				local current = skynet.time() * 100
				kcp:lkcp_update(current)
			end
		end)
	end
	local pid = fromMapPid[from] or 0
	return kcp,pid
end


function funcT.recCmd(strData,from,host)
	local kcp,pid = getKcp(from,host)
	kcp:lkcp_input(strData)

	local hrlen, hr = kcp:lkcp_recv()
	if hrlen > 0 then
		local b1,b2 = string.byte(hr,1,2)
		local sprotoId = (b1 << 8) | b2
		local protostr = protoT[sprotoId]
		if protostr ~= nil then
			local sp = sprotoloader.load(1)
			local protoVO = sp:decode(protostr,string.sub(hr,3,#hr))
			local protoM = require("game/cmd/cmd_"..protostr)
			local errInt,retProtoName,retP = protoM.recCmd(protoVO,pid,from)
			local retProtoId = protoT[retProtoName]
			local msg
			if errInt == 0 then
				msg = sp:encode(retProtoName,retP)
			else
				retProtoId = 30001
				msg = sp:encode("ErrorR",{code=errInt})
			end
			local rb1 = (retProtoId >> 8 )& 0xff
			local rb2 = (retProtoId )& 0xff
			local retStr = string.char(rb1,rb2)
			retStr = retStr.. msg
			kcp:lkcp_send(retStr)
		end
	end
end

function funcT.recCmdJson(strData,from,host)
	local kcp,pid = getKcp(from,host)
	kcp:lkcp_input(strData)

	local hrlen, hr = kcp:lkcp_recv()
	if hrlen > 0 then
		local xxx = 0
		if xxx == 0 then
			skynet.error("rec",hr)
			local t = json.decode(hr)
			local protostr = t.cmd
			local serpent = require("serpent")
			skynet.error(serpent.dump(t))
			local protoM = require("game/cmd/cmd_"..protostr)
			local errInt,retProtoName,retP = protoM.recCmd(t,pid,from)
			if errInt == 0 then
				retP.cmd = retProtoName
			else
				retP.cmd = "ErrorR"
				retP.code = errInt
			end
			local sendStr = json.encode(retP)
			kcp:lkcp_send(sendStr)
			skynet.error("send",sendStr)
		else
			skynet.error("json.........",hr)
			local t = json.encode(hr)
			local sendStr = json.decode(t)
			kcp:lkcp_send(sendStr)
		end
	end
end


skynet.start(function()
	skynet.dispatch("lua",function(_,_,funcName,...)
		local f = assert(funcT[funcName],"func not found: "..funcName)
		skynet.retpack(f(...))
	end)
end)
