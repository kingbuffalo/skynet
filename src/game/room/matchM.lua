local M = {}

local pidArr = {}
local ackIngPidMap1 = {}

function M.match(pid)
	if #pidArr <= 0 then
		pidArr[1] = pid
	else
		local matchPid = pidArr[1]
		table.remove(pidArr,1)
		ackIngPidMap1[matchPid] = pid
		ackIngPidMap1[pid] = matchPid
		skynet.timeout(100,function()
			--TODO send ack
		end)
	end
end

function M.matchAck(pid)
	local otherPid = ackIngPidMap1[pid]
	if otherPid == nil then return 1100201 end
	if ackIngPidMap1[otherPid] == nil then return 1100202 end
	if ackIngPidMap1[otherPid] == 0  then
		ackIngPidMap1[otherPid] = nil
		ackIngPidMap1[pid] = nil
		--TODO create room
		--skynet.send ... 这里要send,要不然容易出错
	else
		ackIngPidMap1[pid] = 0
	end
	return 0
end

return M
