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
	return (pos[1] << 10 )| pos[2]
end

local function distance(p1,p2)
	local w = abs(p1[1]-p2[1])
	local h = abs(p1[2]-p2[2])
	if w > h then return w end
	return h
end
local function lowest_f(set,f)
	local lowest,bestNode = 9999999,nil
	for k,v in pairs(set) do
		local s = f[k]
		if s < lowest then
			lowest,bestNode = s,v
		end
	end
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
	if node[1] > 0 then
		ret[#ret+1] = {node[1]-1,node[2]}
		if (node[1] & 1) == 1 then
			if node[2] > 0 then
				ret[#ret+1] = {node[1]-1,node[2]-1}
			end
		else
			if node[2] < h then
				ret[#ret+1] = {node[1]-1,node[2]+1}
			end
		end
	end

	if node[2] > 0 then
		ret[#ret+1] = {node[1],node[2]-1}
	end
	if node[2] < h then
		ret[#ret+1] = {node[1],node[2]+1}
	end

	if node[1] < w then
		ret[#ret+1] = {node[1]+1,node[2]}
		if (node[1] & 1) == 1 then
			if node[2] > 0 then
				ret[#ret+1] = {node[1]+1,node[2]-1}
			end
		else
			if node[2] < h then
				ret[#ret+1] = {node[1]+1,node[2]+1}
			end
		end
	end

	--并将阻塞地去掉
	return ret
end

local function not_in(set,node)
	return set[posHash(node)] == nil
end

local tmp = 1
function M.astar(start,goal,w,h)
	local closedset = {}
	local openset = {}
	openset[posHash(start)] = start
	local came_from = {}

	local g,f = {},{}
	local startPosKey = posHash(start)
	g[startPosKey] = 0
	f[startPosKey] = g[startPosKey] + distance(start,goal)
	while next(openset) ~= nil do 
		local current = lowest_f(openset,f)
		if current[1] == goal[1] and current[2] == goal[2] then
			local path = unwind_path({},came_from,goal)
			table.insert(path,goal)
			return path
		end
		local currentPosHash = posHash(current)
		openset[currentPosHash] = nil
		closedset[currentPosHash] = current

		local neighbors = neighbor_nodes(current,w,h)
		for i,v in ipairs(neighbors) do
			if not_in(closedset,v) then
				local tentative_g = g[currentPosHash] + distance(current,v)
				local posKey = posHash(v)
				if not_in(openset,v) or tentative_g < g[posKey] then
					came_from[posKey] = current
					g[posKey] = tentative_g
					f[posKey] = g[posKey] + distance(v,goal)
					if not_in(openset,v) then
						openset[posHash(v)] = v
					end
				end
			end
		end
	end
	return nil
end

return M
