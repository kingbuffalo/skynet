local gm_cmd_const = require("gm_cmd_const")

local function addKeyWord(sendT)
	local userIdArr = sendT.userIdArr
	local user_idCommaArr = table.concat(userIdArr,",")
	return {p4=user_idCommaArr}
end

local function sendEmails(sendT)
	local userIdArr = sendT.userIdArr
	local user_idCommaArr = table.concat(userIdArr,",")
	return {p1=sendT.email_id,p4=user_idCommaArr}
end

local function addEmails(sendT)
	local title = sendT.title
	local content = sendT.content
	local gold = sendT.gold or 0

	local e = {
		title = title,
		content = content,
		rewards = {
			gold = gold
		}
	}

	if sendT.type ~= nil then
		e.rewards.type = sendT.type
		e.rewards.value = sendT.value or 0
	end
	local dkjson = require("dkjson")
	local p4 = dkjson.encode(e)
	return {p1=sendT.email_id,p4=p4}
end

local function alterEmails(sendT)
	return addEmails(sendT)
end

local cmdMapParamToIdxFunc = {
	[gm_cmd_const.cmd_add_keyword] = addKeyWord,
	[gm_cmd_const.cmd_send_emails] = sendEmails,
	[gm_cmd_const.cmd_alter_emails] = alterEmails,
	[gm_cmd_const.cmd_add_emails] = addEmails,
}
local cmdMapParamMapIdx = {
	[gm_cmd_const.cmd_create_room_restrict] = { min = 1, },
	[gm_cmd_const.cmd_kick_off] = { min=1 },
	[gm_cmd_const.cmd_login_restrict] = { min=1 },
	[gm_cmd_const.cmd_cancel_restrict] = {},
	[gm_cmd_const.cmd_update_user_coin] = {user_id=1 },
	[gm_cmd_const.cmd_game_version] = {},
	[gm_cmd_const.cmd_rm_room] = {room_id=1},
	[gm_cmd_const.cmd_show_emails] = {},
	[gm_cmd_const.cmd_rm_emails] = {email_id=1},
	[gm_cmd_const.cmd_send_horse_lamp] = {horse_lamp=4},
	[gm_cmd_const.cmd_send_announce] = {begin_timestamp=1,end_timestamp=2,str=4},
	[gm_cmd_const.cmd_get_announce] = {},
	[gm_cmd_const.cmd_shut_down_game] = {},
}

local function wrap(sendT)
	local cmd=sendT.cmd
	local t = cmdMapParamMapIdx[cmd]
	if t ~= nil then
		for k,v in pairs(t) do
			local pkey = "p"..v
			sendT[pkey] = sendT[k]
		end
	else
		local f = cmdMapParamToIdxFunc[cmd]
		if f ~= nil then
			local st = f(sendT)
			st.cmd = sendT.cmd
			sendT = st
		end
	end
	return sendT
end

return wrap
