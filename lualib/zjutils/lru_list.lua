local M = {}
local setmetatable = setmetatable

local function getLRUNode(self,intKey)
	local vo = self._idMapLRUNode[intKey]
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

local function getValue(self,intKey)
	local vo = getLRUNode(self,intKey)
	if vo ~= nil then return vo.value end
	return nil
end

local function rmValue(self,intKey)
	local vo = self._idMapLRUNode[intKey]
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
		self._idGenerator:recycleId(intKey)
		return vo.value
	end
	self._idMapLRUNode[intKey] = nil
	return nil
end

local function addValue(self,value,id)
	local room_db = require("db_oper/room_db")
	--if id == nil then id = self._idGenerator:getNextId() end
	if id == nil then
		id = self._idGenerator:getNextId()
		while room_db.bRoomExist(id) do
			id = self._idGenerator:getNextId()
		end
	end
	local vo = {value=value,intKey=id,timestamp=os.time()}
	if self._head == nil then
		self._head = vo
		self._tail = vo
	else
		self._head.prev = vo
		vo.next = self._head
		self._head = vo
	end
	self._len = self._len + 1
	self._idMapLRUNode[id] = vo
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

local function setRoomIdGenerator(self,idGenerator)
	self._idGenerator = idGenerator
end

local LRUList = { getValue=getValue,rmValue=rmValue,addValue=addValue,getLRUNode=getLRUNode,getLen=getLen,
	setRoomIdGenerator=setRoomIdGenerator,
rangeReverse=rangeReverse,range=range}
LRUList.__index = LRUList

function M.createLRUList()
	--head
	--tail
	--idMapLRUNode --intKey id  LRUNode:{intKey=intKey,value=value,timestamp=timestamp,next=nil,prev=nil}
	--incIntKeyId
	local roomId_generator = require("rooms.roomId_generator")
	local idGenerator = roomId_generator.createIdGenerator()
	local fll = {_idMapLRUNode={},_head=nil,_tail=nil,_len=1,_idGenerator=idGenerator}
	setmetatable(fll,LRUList)
	return fll
end

return M
