local M = {}
local randseq = require("randseq")
local INT_MAX = 0x7fffffff

local sequd

function M.rand(n,m)
	local bReal = false
	if n == nil then
		n,m = 0,INT_MAX
		bReal = true
	end
	if sequd == nil then
		local random = math.random
		local sb,so = random(1,0xffff),random(1,0xffffff)
		sequd = randseq.create(sb,so)
	end
	local v = randseq.nextInt(sequd) & INT_MAX
	if bReal then
		return v / INT_MAX
	else
		return n + v % (m-n)
	end
end

return M
