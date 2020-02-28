local M = {
	TEAM_TYPE_WOLF = 1,
	TEAM_TYPE_SHEEP = 2,
	MATCH_COUNT = {
		[1] = 3,
		[2] = 3,
	},
	MATCH_ACK_TIME = 10,
	[1100201] = "你没有匹配",
	[1100202] = "你的对手已经在战斗中",


}

function M.getOppoType(teamType)
	if teamType == M.TEAM_TYPE_WOLF then return M.TEAM_TYPE_SHEEP end
	return M.TEAM_TYPE_WOLF
end

return M
