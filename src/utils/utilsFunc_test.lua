
local utilsFunc = require("utilsFunc")

local arr = {0,1,2,3,4,5,6,200,1000}

local ret = utilsFunc.bSearch(arr,function(e)
	if e == 2 then return 0 end
	if e < 2 then return -1 end
	if e > 2 then return 1 end
end)
assert(3 == ret)

local arr = {0,2,3,4,5,6,200,1000}
local ret = utilsFunc.bSearch(arr,function(e)
	if e == 1 then return 0 end
	if e < 1 then return -1 end
	if e > 1 then return 1 end
end)
assert(1 == ret)

local arr = {}
local ret = utilsFunc.bSearch(arr,function(e)
	if e == 1 then return 0 end
	if e < 1 then return -1 end
	if e > 1 then return 1 end
end)

assert(0 == ret)
