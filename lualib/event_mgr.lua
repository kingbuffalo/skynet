
local table = table
--事件管理类
--事件类型参考 enum_ser.lua 的 EVENT
EventMgr = oo.class(nil, "EventMgr")


function EventMgr:__init()
	self._eventList = {}		--观察者列表 key:event value:{key:obj, value:func}
end

--触发事件，由对应的事件调用
function EventMgr:trigger(event, args)
	local obsList = self._eventList[event]
	if obsList == nil then return end
	--local funcList = {}
	for k,v in ipairs(obsList) do
		v(args)
	end
end

--监听事件 func:填函数的字符串
function EventMgr:observe(event, obj, func)
	assert(type(obj[func]) == "function")
	local obsList = self._eventList[event]
	if obsList == nil then
		obsList = {}
		self._eventList[event] = obsList
	end
	
	if obsList[obj] == nil then
		local f = function( args )
			obj[func](obj, args)
		end
		obsList[obj] = f
		table.insert(obsList, f)
	end
end

--取消监听事件 
function EventMgr:cancel(event, obj)
	local obsList = self._eventList[event]
	local f = obsList and obsList[obj]
	if f then
		for i,v in ipairs(obsList) do
			if f == v then
				obsList[obj] = nil
				table.remove(obsList, i)
				break
			end
		end
	end 
end


if g_eventMgr == nil then
	g_eventMgr = EventMgr()
end