local M = { }
local dkjson = require("dkjson")
local skynet = require("skynet")

function M.httpHandle(path,q,body,url,method,header)
	local utilsFunc = require("zjutils/utilsFunc")
	utilsFunc.debugPrint(path,q,body,url,method,header)
	local arr = utilsFunc.string_split(body,"&")
	local bodyT = {}
	for i,v in ipairs(arr) do
		local keyValueArr = utilsFunc.string_split(v,"=")
		local kk,vv = keyValueArr[1],keyValueArr[2]
		vv = tonumber(vv) or vv
		bodyT[kk] = vv
	end

	local str = utilsFunc.decodeURI(bodyT.parameter)
	utilsFunc.debugPrint(str)
	--local t = dkjson.decode(bodyT.paramter)
	local t = dkjson.decode(str)
	local addr = skynet.queryservice("httpToGm")
	local data = skynet.call(addr,"lua",t)
	local ret = {
		__status = 200,
		__message = "",
		data = data,
		auth = bodyT.auth,
	}

	return dkjson.encode(ret)
end

return M
