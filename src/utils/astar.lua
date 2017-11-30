--目前满足增加block
--满足周围只能走一步
--[[
--算法简述:
--A* 是   在起点将 around的点放到一个集合中去。
--然后现从这个集合中   找一个预测  最小的点当作起点
--如此反复。
--]]
local M = {}
local abs=math.abs

function M.createMap(w,h)
end

function M.addBlock(x,y)
end

function M.setFieldType(x,y,ft)
end

function M.setFieldType(x,y,ft)
end

local function posHashXY(x,y)
	return (x << 10 )| y
end
local function posHash(pos)
	return (pos.x << 10 )| pos.y
end

local function distance(p1,p2)
	local w = abs(p1.x-p2.x)
	local h = abs(p1.y-p2.y)
	if w > h then return w+h+w end
	return h+h+w
end

local function unwind_path(flat_path,map,current_node)
	local hk = posHash(current_node)
	while map[hk] ~= nil do
		table.insert(flat_path,1,map[hk])
		hk = posHash(map[hk])
	end
	return flat_path
end

local function getAnti(xyMapAntiLen,pos)
	if xyMapAntiLen[posHash(pos)] == nil then return 1 end
	return xyMapAntiLen[posHash(pos)]
end

local function range_neighbor(x,y)
	local idx = 0
	return function()
		idx = idx + 1
		if idx == 1 then return x-1,y end
		if idx == 2 then
			if (x & 1) == 1 then return x-1,y-1
			else return x-1,y+1 end
		end
		if idx == 6 then
			if (x & 1) == 1 then return x+1,y-1
			else return x+1,y+1 end
		end
		if idx == 3 then return x,y-1 end
		if idx == 4 then return x,y+1 end
		if idx == 5 then return x+1,y-1 end
		return nil,nil
	end
end

local function push(self,value)
	local ln = {value=value,next=nil}
	if self._head == nil then
		self._head = ln
		self._tail = ln
	else
		local node = self._head
		local prevNode = self._head
		if value.f < node.value.f then
			ln.next = self._head
			self._head = ln
			return
		end
		node = node.next
		while node ~= nil do
			if value.f < node.value.f then
				ln.next = node
				prevNode.next = ln
				return
			end
			prevNode = node
			node = node.next
		end
		self._tail.next = ln
		self._tail = ln
	end
end

local function pop(self)
	if self._head == nil then return end
	local ret = self._head.value
	self._head = self._head.next
	return ret
end


local function not_in(set,node)
	return set[posHash(node)] == nil
end

local function createOpenset()
	return {list={},len=0}
end
local function openSetPush(t,v)
	--print("in",v.x,v.y,v.f)
	t[posHash(v)] = v
	push(t.list,v)
	t.len = t.len + 1
end

local function openSetPop(t)
	local v = pop(t.list)
	if t.len > 0 then
		t.len = t.len - 1
	end
	t[posHash(v)] = nil
	--print("out",v.x,v.y,v.f)
	return v
end

local function not_in_openSet(t,v)
	return t[posHash(v)] == nil
end

function M.reset(xyMapAntiLen)
	for k,v in pairs(xyMapAntiLen) do
		xyMapAntiLen[posHashXY(x,y)] = 1
	end
end

function M.setEnemyPos(x,y,w,h,len,xyMapAntiLen)
	abc = 11
end

function M.setEnemyPos(x,y,w,h,len,xyMapAntiLen)
	xyMapAntiLen[posHashXY(x,y)] = 999999
	for nx,ny in range_neighbor(x,y) do
		if nx >= 0 and nx <= w and ny >= 0 and ny <= h then
			local hk = posHashXY(nx,ny)
			xyMapAntiLen[hk] = len-1
		end
	end
end

function M.astar(start,goal,w,h,len,xyMapAntiLen)
	local closedset = {}
	start.g = 0
	start.f = 0
	local antiLen = - getAnti(xyMapAntiLen,start)
	local openset = createOpenset()
	openSetPush(openset,start)
	local came_from = {}

	local startPosKey = posHash(start)
	while openset.len > 0 do 
		local current = openSetPop(openset)
		if current.x == goal.x and current.y == goal.y then
			local path = unwind_path({},came_from,goal)
			table.insert(path,goal)
			return path
		end
		antiLen = antiLen + getAnti(xyMapAntiLen,current)
		if antiLen > len then
			print("antiLen",antiLen)
			return nil
		end
		local currentPosHash = posHash(current)
		closedset[currentPosHash] = current

		for nx,ny in range_neighbor(current.x,current.y) do
			if (getAnti(xyMapAntiLen,current) > 0 )
				and (nx >= 0 and nx <= w and ny >= 0 and ny <= h) then
				local v = {x=nx,y=ny,g=current.g+1}
				if not_in(closedset,v) then
					local tentative_g = current.g + 1
					local posKey = posHash(v)
					if not_in_openSet(openset,v) or tentative_g < v.g then
						came_from[posKey] = current
						v.g = tentative_g
						if v.h == nil then
							v.h = distance(v,goal) + getAnti(xyMapAntiLen,v)
						end
						v.f = v.g + v.h
						if not_in_openSet(openset,v) then
							openSetPush(openset,v)
						end
					end
				end
			end
		end
	end
	return nil
end

function M.astar_plant_field(start,goal,w,h,len,xyMapAntiLen)
	local closedset = {}
	start.g = 0
	start.f = 0
	local antiLen = - getAnti(xyMapAntiLen,start)
	local openset = createOpenset()
	openSetPush(openset,start)
	local came_from = {}

	local startPosKey = posHash(start)
	while openset.len > 0 do 
		local current = openSetPop(openset)
		if current.x == goal.x and current.y == goal.y then
			local path = unwind_path({},came_from,goal)
			table.insert(path,goal)
			return path
		end
		antiLen = antiLen + getAnti(xyMapAntiLen,current)
		if antiLen > len then
			print("antiLen",antiLen)
			return {}
		end
		local currentPosHash = posHash(current)
		closedset[currentPosHash] = current

		for nx,ny in range_neighbor(current.x,current.y) do
			if (getAnti(xyMapAntiLen,current) > 0 )
				and (nx >= 0 and nx <= w and ny >= 0 and ny <= h) then
				local v = {x=nx,y=ny,g=current.g+1}
				if not_in(closedset,v) then
					local tentative_g = current.g + 1
					local posKey = posHash(v)
					if not_in_openSet(openset,v) or tentative_g < v.g then
						came_from[posKey] = current
						v.g = tentative_g
						if v.h == nil then
							v.h = distance(v,goal) + getAnti(xyMapAntiLen,v)
						end
						v.f = v.g + v.h
						if not_in_openSet(openset,v) then
							openSetPush(openset,v)
						end
					end
				end
			end
		end
	end
	return {}
end

return M
