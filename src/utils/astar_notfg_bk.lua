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

local function not_in(set,node)
	return set[posHash(node)] == nil
end

local function openSetPush(t,v)
end

local function openSetPop(t)
end


local tmp = 1
function M.astar(start,goal,w,h)
	local closedset = {}
	local openset = {}
	openset[posHash(start)] = start
	local came_from = {}

	local startPosKey = posHash(start)
	start.g = 0
	start.f = 0
	while next(openset) ~= nil do 
		local current = lowest_f(openset)
		if current.x == goal.x and current.y == goal.y then
			local path = unwind_path({},came_from,goal)
			table.insert(path,goal)
			return path
		end
		local currentPosHash = posHash(current)
		openset[currentPosHash] = nil
		closedset[currentPosHash] = current

		local neighbors = neighbor_nodes(current,w,h)
		for i,v in ipairs(neighbors) do
			--print("neighbors",v.x,v.y)
			if not_in(closedset,v) then
				local tentative_g = current.g + 1
				local posKey = posHash(v)
				if not_in(openset,v) or tentative_g < v.g then
					came_from[posKey] = current
					v.g = tentative_g
					if v.h == nil then
						v.h = distance(v,goal)
					end
					v.f = v.g + v.h
					if not_in(openset,v) then
						openset[posHash(v)] = v
						--print("addPos",v.x,v.y)
					end
				end
			end
		end
	end
	return nil
end

return M
