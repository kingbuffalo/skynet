local error_code = {
	--公用
	[90001] = "你的货币不足",
	[90002] = "你的货币不足",
	--GuestLogin
	[1001] = "登陆已经超时",
	[1002] = "此用户不存在",
	[1003] = "没有金币信息",
	[1004] = "目前不允许登陆",
	[1005] = "token值不匹配",

	--创建房间
	[1011] = "你还没有登陆过游戏",
	[1012] = "你的钻石不够",
	[1013] = "你在别的房间",
	[1014] = "现在不允许创建房间",
	[1015] = "回合类型不对",
	[1016] = "房间时间类型不对",

	[1021] = "你还没有登陆过游戏",
	[1022] = "你不在房间内",

	--
	--进入房间
	[1031] = "你还没有登陆过游戏",
	[1032] = "你已经有房间了",
	[1033] = "此房间不存在",
	[1034] = "此房间已经满人了",
	[1035] = "你的钻石不够",
	[1036] = "房间已经完了,马上就要关闭了",
	[1037] = "你的掉线前的记录没有找到",

	--离开房间
	[1041] = "你还没有登陆过游戏",
	[1042] = "你还没有加入房间",
	[1043] = "此房间不存在",
	[1044] = "你还没有加入此房间",
	[1045] = "开始玩游戏之后就不能再退出了",
	[1046] = "此房间不存在你的信息",
	[1047] = "此房间只有你一个人了",
	[1048] = "已经玩游戏了就不能退出房间",
	[1049] = "房主不能离开房间",

	--准备游戏
	[1051] = "你的状态不对",
	[1052] = "你的钻石不够",

	--出牌
	[1061] = "你还没有登陆过游戏",
	[1062] = "你还没有加入房间",
	[1063] = "你还没有开始游戏",
	[1064] = "房间为非游戏状态",
	[1065] = "你手上并没有牌",
	[1066] = "你手上的牌并不存在",

	--aaa
	[1071] = "你还没有登陆过游戏",
	[1072] = "需要重新登陆",
	[1073] = "你还没有加入房间",
	[1074] = "房间不存在",
	[1075] = "游戏还没开始，你可以随时离开",
	[1076] = "你已经加入了房间",
	[1077] = "你申请解散太频繁了，请稍候再申请",

	[1081] = "房间不存在",

	[1091] = "房间不存在",
	[1092] = "你已经在游戏中了，请申请解散",
	[1093] = "房间已经在游戏中了，请申请解散",


	[1121] = "content没有内容",
	[1122] = "OpType Not Found",
	[1123] = "OpType is Empty",

	[1131] = "没有这个房间",
	[1132] = "没有这个回合的数据",

	[1141] = "你不能查看此记录",
	[1142] = "此记录不存在",

	[1151] = "你不能查看此记录",
	[1152] = "此记录不存在",
	[1153] = "不存在此回合数",

	[1161] = "用户数据没有",

	[1171] = "你没有这个Email",
	[1172] = "这个Email不存在",

	[1181] = "你没有这个Email",
	[1182] = "这个Email不存在",



	----------99xxx is gm error
	[991001] = "title 不能为空 ",
	[991002] = "content 不能为空",
	[991003] = "rewards 不能为空",

	[991101] = "没有此GM命令",
	[991102] = "玩家没有此GM命令",
	[991103] = "房间没有此GM命令",
	[991104] = "没有这个房间",

	[991111] = "关键字过滤未初始化",

	[991121] = "没有这个Email",
	[991122] = "mysql query error",
	[991123] = "mysql update error",


	[991131] = "mysql query error",

	--但又为什么有这个指令？-->我并不是因为忘记而没做这个功能，
	--而是因为不建议存在这个指令而不做这个功能",
	[991141] = "此功能不建议存在",

	[991151] = "mysql 增加邮件错误",

	[991161] = "user_id为空",
	[991162] = "email为空",
	[991163] = "此email没有在数据库中找到",

	[991171] = "没有这个Email table",
	[991172] = "没有这个Email",
	[991173] = "mysql update error",
	[991174] = "global email not found",
	[991175] = "email info not found",

	[991181] = "horse lamp str is empty",

	[991191] = "announce str is empty",



	--[90001] = "OpType没有",
	--[90002] = "UserId不能为空",

	--[1001] = "五霸不能出现在头墩",
	--[1002] = "五霸不能没有王",


	----进入房间(包括创建房间)
	--[2001] = "你已经在一个房间了",
	--[2002] = "你已经在这个房间了",
	--[2003] = "此房间不存在",
	--[2004] = "这个房间已经到达最大人数",
	--[2005] = "房间类型不对",

	----开始牌局
	--[2011] = "局数类型不对",
	--[2012] = "你不是房管",
	--[2013] = "庄家id出错",
	--[2014] = "最起码要2个人才能玩",
	--[2015] = "房间状态类型不对",

	----出牌
	--[2031] = "你已经出过了",
	--[2032] = "你未参加游戏",
	--[2033] = "你出错牌了",

	--
}
return error_code