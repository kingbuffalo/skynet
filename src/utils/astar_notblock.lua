--这个是当一个三国志11军队走法的A*寻路 没有任何阻挡的
local M = {}
local abs=math.abs

--AstartObj
--

function M.createMap(w,h)
end

function M.addBlock(x,y)
end

function M.setFieldType(x,y,ft)
end

function M.setFieldType(x,y,ft)
end

local function posHash(pos)
	return (pos.x << 10 )| pos.y
end

local function distance(p1,p2)
	local w = abs(p1.x-p2.x)
	local h = abs(p1.y-p2.y)
	if w > h then return w+w+h end
	return h+h+w
end
local function lowest_f(set)
	local lowest,bestNode = 9999999,nil
	for k,v in pairs(set) do
		local s = v.f
		--print(s,v.x,v.y)
		if s < lowest then
			lowest,bestNode = s,v
		end
	end
	--print("select",bestNode.x,bestNode.y)
	return bestNode
end

local function unwind_path(flat_path,map,current_node)
	local hk = posHash(current_node)
	if map[hk] then
		table.insert(flat_path,1,map[hk])
		return unwind_path(flat_path,map,map[hk])
	else
		return flat_path
	end
end

--奇减偶加
local function neighbor_nodes(node,w,h)
	local ret = {}
	local g=node.g+1
	if node.x > 0 then
		ret[#ret+1] = {x=node.x-1,y=node.y,g=g}
		if (node.x & 1) == 1 then
			if node.y > 0 then
				ret[#ret+1] = {x=node.x-1,y=node.y-1,g=g}
			end
		else
			if node.y < h then
				ret[#ret+1] = {x=node.x-1,y=node.y+1,g=g}
			end
		end
	end

	if node.y > 0 then
		ret[#ret+1] = {x=node.x,y=node.y-1,g=g}
	end
	if node.y < h then
		ret[#ret+1] = {x=node.x,y=node.y+1,g=g}
	end

	if node.x < w then
		ret[#ret+1] = {x=node.x+1,y=node.y,g=g}
		if (node.x & 1) == 1 then
			if node.y > 0 then
				ret[#ret+1] = {x=node.x+1,y=node.y-1,g=g}
			end
		else
			if node.y < h then
				ret[#ret+1] = {x=node.x+1,y=node.y+1,g=g}
			end
		end
	end

	--并将阻塞地去掉
	return ret
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

local tmp = 1
function M.astar(start,goal,w,h)
	local closedset = {}
	start.g = 0
	start.f = 0
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
		local currentPosHash = posHash(current)
		closedset[currentPosHash] = current

		local neighbors = neighbor_nodes(current,w,h)
		for i,v in ipairs(neighbors) do
			--print("neighbors",v.x,v.y)
			if not_in(closedset,v) then
				local tentative_g = current.g + 1
				local posKey = posHash(v)
				if not_in_openSet(openset,v) or tentative_g < v.g then
					came_from[posKey] = current
					v.g = tentative_g
					if v.h == nil then
						v.h = distance(v,goal)
					end
					v.f = v.g + v.h
					if not_in_openSet(openset,v) then
						openSetPush(openset,v)
						--print("addPos",v.x,v.y)
					end
				end
			end
		end
	end
	return {}
end

return M
