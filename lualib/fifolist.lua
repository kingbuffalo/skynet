local M = {}
local setmetatable = setmetatable

----------------  FixedCapacityList  begin --------------------------------------------------
--FixedCapacityList 主要使用于存储最近的n条数据 利用Queue先进先出(fifo)的特性，
--将旧的数据挤掉
--- A FixedCapacityList  注意：headIdx指向的认为是无效值(故而capacity=capacity+1)
-- 各成员都不希望被外部修改
-- @type FixedCapacityList
-- @field #number capacity
-- @field #number _headIdx
-- @field #number _tailIdx
-- @field #number _container

local function enQueue(self,value)
  if self:bFull() then
      self._headIdx = ( self._headIdx + 1 ) % self.capacity
  end
  self._tailIdx = ( self._tailIdx + 1 ) % self.capacity
  self._container[self._tailIdx] = value
end

local function deQueue(self)
	if self:bEmpty() then return end
    self._headIdx = ( self._headIdx + 1 ) % self.capacity
    return self._container[self._headIdx]
end

local function front(self)
    if self:bEmpty() then return end
    return self._container[(self._headIdx+1)%self.capacity]
end

local function tail(self)
    if self:bEmpty() then return end
    return self._container[self._tailIdx]
end

local function bFull(self)
	return (self._tailIdx+1)%self.capacity == self._headIdx
end

local function bEmpty(self)
	return self._headIdx == self._tailIdx
end

local function getLen(self)
	local head = self._headIdx
	if head < self._tailIdx then
		head = head + self.capacity
	end
	return head - self._tailIdx
end

local function range(self)
	local idx = self._headIdx
	return function()
		idx = idx + 1
		if idx < 0 then return nil end
		if idx >= self.capacity then idx = 0 end
		local ret = self._container[idx]
		if idx == self._tailIdx then idx = -100 end
		return ret
	end
end

local fixedCapacityList = { enQueue=enQueue,deQueue=deQueue,front=front,tail=tail,
	range=range,bEmpty=bEmpty,bFull=bFull,getLen=getLen}
fixedCapacityList.__index = fixedCapacityList

---
-- @param capacity
-- @return #FixedCapacityList
function M.createFixedCapacityList(capacity)
  local fll = {capacity=capacity+1,_headIdx=0,_tailIdx=0,_container={}}
  setmetatable(fll,fixedCapacityList)
  return fll
end
----------------  FixedCapacityList  end--------------------------------------------------

----------------  LinkedNodeList begin --------------------------------------------------
-- 一般性 先进先出队列
--- A LinkedNode
-- @type LinkedNode
-- @field #table value
-- @field #LinkedNode next
--- A LinkedNodeList
-- @type LinkedNodeList
-- @field #LinkedNode _head
-- @field #LinkedNode _tail
local function lenQueue(self,value)
	local ln = {value=value,next=nil}
	if self._head == nil then
		self._head = ln
		self._tail = ln
	else
		self._tail.next = ln
		self._tail = ln
	end
end

local function ldeQueue(self)
	if self._head == nil then return end
	local ret = self._head.value
	self._head = self._head.next
	return ret
end

local function lfront(self)
	if self._head == nil then return end
	return self._head.value
end

local function ltail(self)
	if self._head == nil then return end
    return self._tail.value
end

local function lbEmpty(self)
	return self._head == nil
end

local function lrange(self)
	local iterNode = self._head
	return function()
		if iterNode == nil then return nil end
		local ret = iterNode.value
		iterNode = iterNode.next
		return ret
	end
end

local linkedNodeList = { enQueue=lenQueue,deQueue=ldeQueue,front=lfront,
tail=ltail,range=lrange,bEmpty=lbEmpty}
linkedNodeList.__index = linkedNodeList

---
-- @return #LinkedNodeList
function M.createLinkedNodeList()
  local lnl = {}
  setmetatable(lnl,linkedNodeList)
  return lnl
end
----------------  LinkedNodeList end --------------------------------------------------

return M
