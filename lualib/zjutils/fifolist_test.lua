local function main()
	local fifolist = require("fifolist")
	local ffl = fifolist.createFixedCapacityList(10)
	for i=1,95 do
		ffl:enQueue(i)
	end
	
	for i=1,10 do
		print(ffl._container[i])
	end
	print("--------------------------------")
	for v in ffl:range() do
		print(v)
	end
	print("--------------------------------")
	for i=1,11 do
		print(ffl:deQueue())
	end
	ffl:enQueue(2)
	ffl:enQueue(3)
	assert(ffl:deQueue()==2)
	assert(ffl:deQueue()==3)
	assert(ffl:bEmpty())

	local lnl = fifolist.createLinkedNodeList()
	for i=1,5 do
		lnl:enQueue(i)
	end
	print("--------------------linknode")
	for v in lnl:range() do
		print(v)
	end
	for i=1,7 do
		print(lnl:deQueue())
	end
	assert(lnl:bEmpty())
	for i=1,5 do
		lnl:enQueue(i)
	end
	for i=1,3 do
		lnl:deQueue()
	end
	for v in lnl:range() do
		print(v)
	end
end
main()
