-- a much simple OO implementation base on loop.simple

--local _check = require("oo_check")
--_check.openFlag()

--module("oo", package.seeall) --5.3不支持
local M = {}

local classList = {}  --类列表
local classBase = {}  --基类

-- default construnctor
function classBase:__init(ob)
end

-- isa operator
function classBase:isa(clz)
	local c = classof(self)
	while c and c ~= classBase do
		if c == clz then return true end
		c = superclassof(c)
	end
	return false
end

local function new(clz, ...)
	local obj = {}
	local mt = rawget(clz, "_mt_")
	if not mt then
		mt = {
			__index		= clz,
			__tostring	= clz.__tostring,
			__gc		= clz.__gc,
		}
		rawset(clz, "_mt_", mt)
	end
	
	setmetatable(obj, mt)
	obj:__init(...)

	--check
	--_check.checkObject(clz, obj)

	return obj
end

function M.class(super, name)
	local clz = {}
	if type(name) == "string" then
		local class_name = name..'__'
		if classList[class_name] ~= nil then
			print(">>>>>>>>>>>>>oo.class repeat,is hot upgate? class:", name)
			clz = classList[class_name]
			for k,v in pairs(clz) do
				clz[k] = nil
			end
		else
			classList[class_name] = clz
		end

		--check
		--_check.checkClass(clz, class_name)
	else
		error("Error:class name is error!")
	end

	super = super or classBase
	rawset(clz, "__super", super)
	setmetatable(clz, {__index = super, __call = new})
	return clz
end
function M.superclassof(clz)
	return rawget(clz, "__super")
end

function M.classof(ob)
	return getmetatable(ob).__index
end
function M.instanceof(ob, clz)
	return ((ob.isa and ob:isa(clz)) == true)
end

return M
