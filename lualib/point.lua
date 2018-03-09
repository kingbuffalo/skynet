

local mt = {}
local point = {}

function point.new(x, y)
	local p = {
		x = x, 
		y = y
	}
	setmetatable(p, mt)
	return p
end

function point.init(p, x, y)
	p.x = x
	p.y = y
end

function point.getLength(p)
	return math.sqrt(p.x * p.x + p.y * p.y)
end

function point.getLengthSqr(q)
	return q.x * q.x + q.y * q.y
end

function point.add(a, b)
	local p = {}
	p.x = a.x + b.x
	p.y = a.y + b.y
	return p
end

function point.sub(a, b)
	local p = {}
	p.x = a.x - b.x
	p.y = a.y - b.y
	return p
end	

function point.div(a, s)
	local p = {}
	p.x = a.x / s
	p.y = a.y / s
	return p
end

function point.mul(a, s)
	local p = {}
	p.x = a.x * s
	p.y = a.y * s
	return p
end

function point.getDistance(a, b)
	local p = a - b
	return point.getLength(p)
end


function point.norm(p)
	local mag = point.getLength(p)
	if mag == 0 then
		return
	end
	p.x = p.x / mag
	p.y = p.y / mag
	return p
end


mt.__add = point.add
mt.__sub = point.sub
mt.__div = point.div
mt.__mul = point.mul

return point
