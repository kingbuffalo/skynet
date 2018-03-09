
--保留关键定: id(默认，可以通过加载文件时传入，空格分格多个关键字), is_array, _data

--数组用 id 可以转为数值则为索引, 如果有重复的child.tag 则自动转为数组
--如果有 is_array 字段则属性数据为数组，顺序重左到右为1.2.3.4...  否则就是一个table, 属性值为键值
--is_array 必须放在tag 后的第一们位置
--<test>xxx</test>  xxx的值用test._data 来取，如果xxx是数字则自动转为数值，
--自动把可以转为数值的值转为数值，如果不想转则用str_ 开头  

local lom = require("lom")
local xmlFileName = ""

local function parse_field(k, v)
	if 1 == string.find(k, "str_", 1) then
		return string.sub(k, 5), v
	end
	return k, tonumber(v) or v
end

local function parse_node(tree, key_world)
	--print("tree.tag", TablePrint(tree))
	--
	local tag_list = {}
	local tag_array = {}
	local tag_table = {}
	for _, node in pairs(tree) do
		if node.tag ~= nil then
			--print("node.tag", node.tag)
			local k, v, a_id = parse_node(node, key_world)
			if a_id ~= nil then
				if tag_table[k] == nil then
					tag_table[k] = {}
				end
				if tag_table[k][a_id] ~= nil then
					print("error double attr _id:", xmlFileName, k, a_id)
				end
				tag_table[k][a_id] = v
			else
				if tag_list[k] ~= nil then
					if tag_array[k] == nil then
						tag_array[k] = {}
						table.insert(tag_array[k], tag_list[k])
					end
					table.insert(tag_array[k], v)
				end
				tag_list[k] = v
			end
		end
	end
	--
	local tag = {}
	local is_array = tree.attr["is_array"] ~= nil
	local array_id = nil
	if key_world then
		local key = tree.attr[1]
		array_id = key_world[key] and tonumber(tree.attr[key]) or nil
	else
		array_id = tonumber(tree.attr["id"])
	end
	if is_array then
		if "is_array" ~= tree.attr[1] then
			print("error is_array must is first position")
		else
			-- attr
			for k, v in ipairs(tree.attr) do
				--print("attr", type(k), count, k, v, tree.attr[v])
				if type(k) == "number" and k > 1 then
					local r1, r2 = parse_field(v, tree.attr[v])
					tag[k-1] = r2
				end
			end
		end
	else
		for k, v in pairs(tree.attr) do
			--print("attr", type(k), count, k, v, tree.attr[v])
			if type(k) == "string" then
				if "is_array" ~= k then
					local r1, r2 = parse_field(k, v)
					tag[r1] = r2
				end
			end
		end
	end
	--<>data 的内容<>
	if tree[1] ~= nil and next(tag_array) == nil and next(tag_table) == nil then
		--print("_data", type(tree[1]), tree[1], print(engine.json.encode(tree[1])))
		local r1, r2 = parse_field("", tree[1])
		tag._data = r2
	end

	for k, v in pairs(tag_list) do
		if tag[k] ~= nil then
			print("error double attr list:", k)
		else
			tag[k] = v
		end
	end
	for k, v in pairs(tag_array) do
		tag[k] = v
	end
	for k, v in pairs(tag_table) do
		if tag[k] == nil then
			tag[k] = {}
		else
			print("error double attr list:", k)
		end
		for a_id, entry in pairs(v) do
			tag[k][a_id] = entry
		end
	end

	return tree.tag, tag, array_id
	
end

-- XML数据结构解析
local function handleXmlTree(xml_tree, key_world)
	if not xml_tree then
		debug_print("handleXmlTree tree is nil return")
		return 
	end

	local k, v, a_id = parse_node(xml_tree, key_world)
	return v
end

local tbl = {}
-- 从XML文件中读取数据
function tbl.handleXmlFile(str_file, key_world)
	xmlFileName = str_file
	if key_world ~= nil then
		t = {}
		for w in string.gmatch(key_world,"%a+") do 
			t[w] = 1
		end
		key_world = t
		--tbl.tablePrint(t)
	end
	local file_handle = io.open(str_file)
	if not file_handle then
		print("error no xml file:", str_file)
		return 
	end
	local file_data = file_handle:read("*a")
	file_handle:close()
	
	local xml_tree,err = lom.parse(file_data)
	if err then
		print("error format xml:", str_file)
		return 
	end
	return handleXmlTree(xml_tree, key_world)
end

function tbl.tablePrint(value,fmt,tabnum)
	local num = tabnum or 1
	local fmt = fmt or '\t'
	if type(value) =="table" then
		local left = fmt .. '{'
		local right = fmt .. '}' ..','
		local newfmt = fmt .. '\t'
		if num<= 1 then
			left = '{'
			right = '}'
			newfmt = fmt
		end

		print (left)
		for k,v in pairs(value) do
			if type(v) == "table" then
				print(newfmt..k.. " = ")
				tbl.tablePrint(v,newfmt,num+1)
			else
				if type(k) == "string" then
					print(newfmt..'"'..k..'"'.." = " .. v .. ',')
				else
					print(newfmt..k.." = " .. v .. ',')
				end
			end
		end
		print(right)
	end
end

return tbl
--使用测试例子
--local config = handleXmlFile("../config/xml/faction/sample1.xml")
--local config = handleXmlFile("../config/xml/faction/sample2.xml")
--local config = handleXmlFile("../config/xml/faction/sample3.xml")
--print(engine.json.encode(config))
--print(TablePrint(config))
