require("min_heap")
--时间管理类
--时间用秒为单位
TimerMgr = oo.class(nil, "TimerMgr")

local _1_DAY_SEC = 86400
local _6_DAY_SEC = 86400 * 6
local _7_DAY_SEC = 86400 * 7

function TimerMgr:__init()
	self.heap = Min_heap()

	self.onNewDayList = {}
	self.onNewDayListId = 0

	self.onEveryDay = {}
	self.onEveryDayId = 0

	self.today = self:_getToday()
	self.tomorrow = self.today + _1_DAY_SEC;
	--服务开服时间
	self.startTime = self.today
	self.startDays = 0
end

--调用一次后就会删除
function TimerMgr:register1(hour, minute, second, timeout, obj, method, args)
	local timestamp = self.today + hour * 3600 + minute * 60 + second
	return self:register(timestamp, timeout, obj, method, args)
end

--调用一次后就会删除
function TimerMgr:register(timestamp, timeout, obj, method, args)
	local now = __NOW
	if timestamp < now then
		if timestamp + timeout < now then
			logError("error TimerMgr:register:", timestamp)
			--print(debug.traceback())
			return
		end
		timestamp = now + 1
	end
	-- if timestamp > self.tomorrow then
	-- 	print("error TimerMgr:register:", timestamp)
	-- 	print(debug.traceback())
	-- 	return
	-- end

	local value = {
		["obj"] = obj
		, ["method"] = method
		, ["args"] = args
	}
	log("TimerMgr:register:", timestamp)
	-- printCallStack("timerMgr")
	return self.heap:push(timestamp, value)
end

function TimerMgr:unregister(id)
	self.heap:erase(id)
end

--每天那个时间都调用一次
function TimerMgr:registEveryDay(hour, minute, timeout, obj, method, args)
	local value = {
		["obj"] = obj
		, ["method"] = method
		, ["args"] = args
		, ["hour"] = hour
		, ["minute"] = minute
		, ["timeout"] = timeout
	}
	
	self:register1(hour, minute, 0, timeout, obj, method, args)

	self.onEveryDayId = self.onEveryDayId + 1
	self.onEveryDay[self.onEveryDayId] = value
	return self.onEveryDayId
end

--第2天才生效
function TimerMgr:unregistEveryDay(id)
	self.onEveryDay[id] = nil
end

--这个函数只需要注册一次就会重复调用
function TimerMgr:registOnNewDay(obj, method, args)
	assert(obj and method)
	local value = {
		["obj"] = obj
		, ["method"] = method
		, ["args"] = args
	}
	self.onNewDayListId = self.onNewDayListId + 1
	self.onNewDayList[self.onNewDayListId] = value
	return self.onNewDayListId
end

function TimerMgr:unregistOnNewDay(id)
	self.onNewDayList[id] = nil
end

function TimerMgr:onTimer(now)
	--print("TimerMgr:onTimer:", now)
	while not self.heap:is_empty() do
		local o = self.heap:top()
		if o.key > now then
			break
		end
		
		self.heap:pop()
		
		local value = o.value
		local method = value.obj[value.method]
		if method then
			method(value.obj, value.args)
		end
	end

	if now > self.tomorrow then
		self:onNewDay()
	end
end

function TimerMgr:onNewDay()
	log("TimerMgr:onNewDay")
	local now = __NOW
	self.today = self:_getToday()
	self.tomorrow = self.today + _1_DAY_SEC;
	self.startDays = math.ceil((now - self.startTime) / _1_DAY_SEC)
	if self.startDays < 0 then self.startDays = 0 end
	--
	--self.heap:clear()
	for k, v in pairs(self.onEveryDay) do
		self:register1(v.hour, v.minute, 0, v.timeout, v.obj, v.method, v.args)
	end
	for k, v in pairs(self.onNewDayList) do
		local method = v.obj[v.method]
		if method then
			method(v.obj, v.args)
		end
	end
end

function TimerMgr:getToday()
	return self.today
end

function TimerMgr:getTomorrow()
	return self.tomorrow
end

function TimerMgr:_getToday()
	local today = os.date("*t", __NOW)
	today.hour = 0
	today.min = 0
	today.sec = 0
	return os.time(today), today
end

function TimerMgr:getDate(t_time)
	local date = os.date("*t", t_time)
	return date
end

--返回指定时间的时间戳
function TimerMgr:dateToTm(year, month, day, hour, min, sec)
	local d = os.date("*t", __NOW)
	d.year = year > 0 and year or d.year
	d.month = month > 0 and month or d.month
	d.day = day > 0 and day or d.day
	d.hour = hour >= 0 and hour or d.hour
	d.min = min
	d.sec = sec
	return os.time(d)
end

function TimerMgr:isToday(time)
	--print("is today", time, self.today, self.tomorrow)
	if time >= self.today and time <= self.tomorrow then
		return true
	end
	return false
end

--周日为第一天
function TimerMgr:isThisWeek(time)
	if time >= self.today and time <= self.tomorrow then
		return true
	end
	local today = os.date("*t")
	today.hour = 0
	today.min = 0
	today.sec = 0
	local sundayBegin = os.time(today) - ((today.wday -1) * _1_DAY_SEC)
	--print("isThisWeek:",sundayBegin, time)
	if time >= sundayBegin and time < sundayBegin + _7_DAY_SEC then
		return true
	end
	return false
end

--周一为第一天
function TimerMgr:isThisWeek2(time)
	if time >= self.today and time <= self.tomorrow then
		return true
	end
	local today = os.date("*t")
	today.hour = 0
	today.min = 0
	today.sec = 0
	local sundayBegin
	if today.wday == 1 then
		sundayBegin = os.time(today) - (_6_DAY_SEC)
	else
		sundayBegin = os.time(today) - ((today.wday -2) * _1_DAY_SEC)
	end
	--print("isThisWeek:",sundayBegin, time)
	if time >= sundayBegin and time < sundayBegin + _7_DAY_SEC then
		return true
	end
	return false
end

--清掉所有注册的定时器
function TimerMgr:clearAll()
	self.onNewDayList = {}
	self.onNewDayListId = 0

	self.onEveryDay = {}
	self.onEveryDayId = 0

	self.heap:clear()
end

--设置开服日期
function TimerMgr:setStartDate(year, month, day)
	self.startTime = self:dateToTm(year, month, day, 0, 0, 0)
	self.startDays = math.ceil((os.time() - self.startTime) / _1_DAY_SEC)
	if self.startDays < 0 then self.startDays = 0 end
end
--返回已经开服的天数
function TimerMgr:getStartDays()
	return self.startDays
end
--返回开服的时间
function TimerMgr:getStartTime()
	return self.startTime
end

--返回由参数时刻开始到现在的天数
function TimerMgr:getDaysFrom(time)
	local tm = os.date("*t", time)
	tm.hour = 0
	tm.min = 0
	tm.sec = 0
	local ds = os.time(tm)
	return ((__NOW - ds) // _1_DAY_SEC) + 1
end


if g_timerMgr == nil then
	g_timerMgr = TimerMgr()
end