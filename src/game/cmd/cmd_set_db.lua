local M = {}

function M.recCmd(cmdVO)
	local utilsFunc = require("utils.utilsFunc")
	local t = utilsFunc.string_split(cmdVO.p4,'#')
	if #t == 4 then
		local cmd = t[1]
		local key = t[2]
		local key2 = t[3]
		local valueStr = t[4]
		local ssdbutils = require("utils.db.ssdbutils")
		ssdbutils.sendExecute(cmd,key,key2,valueStr)
	elseif #t == 2 then
		local cmd = t[1]
		local key = t[2]
		local ssdbutils = require("utils.db.ssdbutils")
		ssdbutils.sendExecute(cmd,key)
	end
end

return M
