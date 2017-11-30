local M = {
	cmd_start = 1002,
	cmd_login = 1001,
	cmd_player_info = 1002,
	cmd_hero_list = 1003,
	cmd_add_hero_exp = 1004,
	cmd_add_hero_army_weapon = 1005,
	cmd_get_bag_list = 1006,
	cmd_open_gift = 1007,
	cmd_hero_star_up = 1008,
	cmd_buy_item = 1009,
	cmd_hero_army_levelup = 1010,
	cmd_get_citys = 1011,
	cmd_get_city_builds = 1012,
	cmd_build_levelup = 1013,
	cmd_build_set_hero = 1014,
	cmd_move_hero = 1015,
	cmd_hero_army_skill_levelup = 1016,
	cmd_end = 1016,

	cmd_map_star = 2001,
	cmd_army_move_pos = 2001,
	cmd_army_move_attack = 2002,
	cmd_to_battle = 2003,
	cmd_fight_npc = 2004,
	cmd_get_map_info = 2005,
	cmd_map_end = 2005,

	cmd_not_exist_single_service_star = 3000,
	cmd_timeIdx_inc = 3001,
	cmd_set_db = 3002,
	cmd_not_exist_single_service_end = 4000,
}

function M.getCmdFn(cmd)
	if M.__cmdMapFn== nil then
		local cmdMapFn= {}
		for k,v in pairs(M) do
			if type(v) == "number" then
				if k ~= "cmd_start" and k ~= "cmd_end"
					and k ~= "cmd_map_end" and k ~= "cmd_map_start"
					and k ~= "cmd_not_exist_single_service_star" 
					and k ~= "cmd_not_exist_single_service_end" then
					cmdMapFn[v] = k
				end
			end
		end
		M.__cmdMapFn=cmdMapFn
	end
	local ret = M.__cmdMapFn[cmd]
	return ret
end

function M.getStructName(cmd)
	if M.__cmdMapStr == nil then
		--通用的用大写
		--不通用的用小写
		local __cmdMapStr = {
			[M.cmd_login] = "login",
			[M.cmd_player_info] = "player_info",
			[M.cmd_hero_list] = "hero_list",
			[M.cmd_add_hero_exp] = "add_hero_exp",
			[M.cmd_get_bag_list] = "get_bag_list",
			[M.cmd_buy_item] = "buy_item",
			--[M.cmd_open_gift] = "open_gift",
			--[M.cmd_hero_star_up] = "hero_sta",
			--[M.cmd_buy_item] = "buy_i",
			--[M.cmd_hero_army_levelup] = "hero_army_",
			[M.cmd_get_citys] = "get_citys",
			[M.cmd_get_city_builds] = "get_city_builds",
			[M.cmd_build_levelup] = "build_levelup",
			[M.cmd_timeIdx_inc] = "BattleCommonCmd",
		}
		M.__cmdMapStr = __cmdMapStr
	end
	local ret = M.__cmdMapStr[cmd]
	if ret == nil then
		if M.cmd_map_star <= cmd  and cmd <= M.cmd_map_star then
			ret = "BattleCommonCmd"
		else
			ret = "ErrMsg"
		end
	end
	return ret
end

return M
