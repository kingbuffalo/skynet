local M = {}
local lru_list = require("lru_list")

local function testAddRm()
	local rl = lru_list.createLRUList()
	for i=1,10 do
		local v = {}
		rl:addValue(1,v)
	end
	for i=1,10 do
		local v = rl:getValue(i)
		assert(v)
	end
	for i=1,10 do
		rl:rmValue(i)
	end

	--放入11~20的房间
	for i=1,10 do
		local v = {}
		rl:addValue(1,v)
	end

	for i=1,10 do
		local v = rl:getValue(i)
		assert(v==nil,i)
	end
	for i=11,20 do
		local v = rl:getValue(i)
		assert(v)
	end
	local idx = 10
	for v in rl:rangeReverse() do
		idx = idx + 1
		assert(v.roomId == idx)
	end

	for v in rl:range() do
		assert(v.roomId == idx)
		idx = idx - 1
	end

	for i=11,20 do
		local v = rl:rmValue(i)
		assert(v)
	end

	for i=1,10 do
		local v = rl:rmValue(i)
		assert(v==nil)
	end

end

function M.run()
	testAddRm()
	return "hhh"
end

return M
