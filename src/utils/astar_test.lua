local function posHash(pos)
	return (pos.x << 10 )| pos.y
end

local function main()
	local astar = require("astar")
	local bt = os.clock()
	local xyMapLen = {}
	local stepLen = 5000
	astar.setEnemyPos(1,2,1000,1000,stepLen,xyMapLen)

	local p = astar.astar({x=924,y=924},{x=0,y=0},1000,1000,stepLen,xyMapLen)
	print(os.clock()-bt)
	for k,v in pairs(p) do
		print(v.x,v.y)
	end
	print(#p)
end

main()
