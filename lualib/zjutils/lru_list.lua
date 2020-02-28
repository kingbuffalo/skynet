local M = {}
local setmetatable = setmetatable
local keyInc = 1

local function getLRUNode(self,key)
	local vo = self._idMapLRUNode[key]
	if vo ~= nil then
		vo.timestamp = os.time()
		if self._head ~= self._tail then
			if self._head ~= vo then
				vo.prev.next = vo.next
				if self._tail == vo then
					self._tail = vo.prev
					self._tail.next = nil
				else
					vo.next.prev = vo.prev
				end
				vo.next = self._head
				self._head.prev = vo
				self._head = vo
				self._head.prev = nil
			end
		end
	end
	return vo
end

local function getValue(self,key)
	local vo = getLRUNode(self,key)
	if vo ~= nil then return vo.value end
	return nil
end

local function rmValue(self,key)
	local vo = self._idMapLRUNode[key]
	self._idMapLRUNode[key] = nil
	if vo ~= nil then
		if self._head == self._tail then
			self._head = nil
			self._tail = nil
		else
			if self._head == vo then
				self._head = vo.next
				self._head.prev = nil
			else
				vo.prev.next = vo.next
				if self._tail == vo then
					self._tail = vo.prev
					self._tail.next = nil
				else
					vo.next.prev = vo.prev
				end
			end
		end
		self._len = self._len - 1
		return vo.value
	end
	return nil
end

local function addValue(self,value,key)
	if key == nil then key = keyInc;keyInc=keyInc+1 end
	local vo = {value=value,key=key,timestamp=os.time()}
	if self._head == nil then
		self._head = vo
		self._tail = vo
	else
		self._head.prev = vo
		vo.next = self._head
		self._head = vo
	end
	self._len = self._len + 1
	self._idMapLRUNode[key] = vo
	return vo
end

local function rangeReverse(self)
	local vo = self._tail
	return function ()
		local ret = vo
		if vo ~= nil then vo = vo.prev end
		return ret
	end
end

local function range(self)
	local vo = self._head
	return function ()
		local ret = vo
		if vo ~= nil then vo = vo.next end
		return ret
	end
end

local function getLen(self)
	return self._len
end

local LRUList = { getValue=getValue,
	rmValue=rmValue,
	addValue=addValue,
	getLRUNode=getLRUNode,
	getLen=getLen,
	rangeReverse=rangeReverse,
	range=range}

LRUList.__index = LRUList

function M.createLRUList()
	--head
	--tail
	--idMapLRUNode --key id  LRUNode:{key=key,value=value,timestamp=timestamp,next=nil,prev=nil}
	--incIntKeyId
	local fll = {_idMapLRUNode={},_head=nil,_tail=nil,_len=0}
	setmetatable(fll,LRUList)
	return fll
end

return M
