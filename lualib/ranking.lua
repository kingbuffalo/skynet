

Ranking = oo.class(nil, "Ranking")

function Ranking:__init(size)
	self:clear(size or 100)
end

function Ranking:clear(size)
	self._rankList = {}			--k:排名，v:{id, value, pos}
	self._idList = {}
	self._size = size or self._size
	self._count = 0
	self._minVal = 99999999999999
end

function Ranking:getMinVal()
	return self._minVal
end

function Ranking:isEmpty()
	return 0 == self.count
end

function Ranking:size()
	return self._count
end

function Ranking:getInfo( rank )
	return self._rankList[rank]
end

function Ranking:getIdInfo( id )
	return self._idList[id]
end

function Ranking:push(id, value)
	if self._idList[id] then
		self:pushOld(id, value)
	else
		self:pushNew(id, value)
	end
end

function Ranking:pushNew(id, value)
	local r = {id, value, 0}
	local pos
	if self._count < self._size then
		self._idList[id] = r
		pos = self:findPos(value)
		self._count = self._count + 1
	else
		if value <= self._minVal then
			return
		end
		pos = self:findPos(value)
		local tmp = self._rankList[self._count]
		self._rankList[self._count] = nil
		self._idList[tmp[1]] = nil
		self._idList[id] = r
	end
	r[3] = pos
	table.insert(self._rankList, pos, r)
	for i=pos+1, self._count do
		self._rankList[i][3] = i
	end
	self._minVal = self._rankList[self._count][2]
end

function Ranking:pushOld(id, value)
	local tmp = self._idList[id]
	if value <= tmp[2] then
		return
	end
	tmp[2] = value
	local oldPos = tmp[3]
	for i=oldPos, 1, -1 do
		local v = self._rankList[i-1]
		if v and tmp[2] > v[2] then
			self._rankList[i] = v
			v[3] = i
		else
			self._rankList[i] = tmp
			tmp[3] = i
			break
		end
	end
	if oldPos == self._count then
		self._minVal = self._rankList[self._count][2]
	end
end

function Ranking:findPos(value)
	if self._count == 0 then return 1 end
	local i, j = 1, self._count
	while i < j do
		local pos = math.floor((i + j) / 2)
		local v = self._rankList[pos][2]
		if v > value then
			i = pos + 1
		elseif v < value then
			j = pos - 1
		else
			return pos
		end
	end
	if self._rankList[i][2] >= value then
		return i + 1
	end
	return i
end


function Ranking:erase(id)

end

function Ranking:dbData()
	return self._rankList
end

function Ranking:initDbData(data)
	self._rankList = data
	self._count = #self._rankList
	if self._size < self._count then
		self._size = self._count
	end
	self._idList = {}
	for k,v in pairs(self._rankList) do
		self._idList[v[1]] = v
	end
	self._minVal = self._rankList[self._count][2]
end


function Ranking:test()
	local rank = Ranking(100)
	for i=1,1000 do
		local r = random(100, 10000)
		rank:push(i, r)
	end

	local tt = 100000000
	for k,v in pairs(rank._rankList) do
		print(k, v[3], v[1], v[2])
		assert(k == v[3])
		assert(tt >= v[2])
		tt = v[2]
	end
end

function Ranking:test2()
	local rank = Ranking(20)
	rank:push(101, 2)
	rank:push(102, 2)
	rank:push(101, 3)
	rank:push(102, 4)
	rank:push(103, 5)
	

	for k,v in pairs(rank._rankList) do
		print(k, v[3], v[1], v[2])
		assert(k == v[3])
	end
end

