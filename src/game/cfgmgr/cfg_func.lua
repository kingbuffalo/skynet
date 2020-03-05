local M = {}

function M.k1v(arr,keyName)
	local ret = {}
	for _,v in ipairs(arr) do
		ret[v[keyName]] = v
	end
	return ret
end

return M
