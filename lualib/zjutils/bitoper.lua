--FOR lua5.1
local M =  {}
M._data32 = {}

local BIT_MAX = 32

if #M._data32 <= 0 then
	for i=1,BIT_MAX do
		M._data32[i]=2^(BIT_MAX-i)
	end
end

function M._b2d(arg)
    local nr=0
    for i=1,BIT_MAX do
        if arg[i] ==1 then
            nr=nr+M._data32[i]
        end
    end
    return  nr
end

function M._d2b(arg)
    arg = arg >= 0 and arg or (0xFFFFFFFF + arg + 1)
    local tr={}
    for i=1,BIT_MAX do
        if arg >= M._data32[i] then
            tr[i]=1
            arg=arg-M._data32[i]
        else
            tr[i]=0
        end
    end
    return tr
end

function  M.band(a,b)
    local op1=M._d2b(a)
    local op2=M._d2b(b)
    local r={}

    for i=1,BIT_MAX do
		r[i] = (op1[i]==1 and op2[i]==1) and 1 or 0
    end
    return  M._b2d(r)
end

function M.xor(a,b)
    local op1 = M._d2b(a)
    local op2 = M._d2b(b)
    local r={}
    for i = 1,BIT_MAX do
        if op1[i] == 0 then
            r[i] = op2[i]
        else
			r[i] = op2[i] == 0 and 1 or 0
        end
    end
    return M._b2d(r)
end

function M.rshift(a,n)
    local op1=M._d2b(a)
    n = n <= BIT_MAX and n or BIT_MAX
    n = n >= 0 and n or 0

    for i=BIT_MAX , n+1, -1 do
        op1[i] = op1[i-n]
    end
    for i=1, n do
        op1[i] = 0
    end

    return  M._b2d(op1)
end

function M.lshift(a,n)
    local op1 =M._d2b(a)
    n = n <= BIT_MAX and n or BIT_MAX
    n = n >= 0 and n or 0
    for i = 1, BIT_MAX - n do
        op1[i] = op1[i + n]
    end
    for i = BIT_MAX - n + 1, BIT_MAX do
        op1[i] = 0
    end
    return M._b2d(op1)
end

function M.bnot(a)
    local op1=M._d2b(a)
    local r={}

    for i=1,BIT_MAX do
		r[i] = op1[i] == 1 and 0 or 1
    end
    return M._b2d(r)
end

function M.bor(a,b)
    local op1=M._d2b(a)
    local op2=M._d2b(b)
    local r={}

    for i=1,BIT_MAX do
		r[i] = (op1[i]==1 or op2[i]==1) and 1 or 0
    end
    return M._b2d(r)
end

return M
