--所有的返回都会有一个{err=?} 0为正确 其它数值为错误
--详见 https://code.jh-it.cn/svn/zj-game-code-use/trunk/shisanshui/error_code.lua
--GM的错误是 991101 ~~ 1111
local M = {
	--gm:{cmd:1001,p1=0} p1为多少分之后 =0为立即生效
	cmd_create_room_restrict = 1001,
	--gm:{cmd:1002,p4="abcd"} p1关键字
	cmd_add_keyword = 1002,
	--gm:{cmd:1003,p4="user_id,user_id,user_id", p1为user_id用,连接起来的字符串
					--p2=minute p2为多少分钟数后
	cmd_kick_off = 1003,
	--gm:{cmd:1004,p1=0} p1为多少分之后 =0为立即生效
	cmd_login_restrict = 1004,

	--gm:{cmd:1005} 取消登陆限制和踢人
	cmd_cancel_restrict = 1005,

	--gm:{cmd:1006,p1=13} p1为user_id 当完成给玩家充值等操作
	--改完redis数据后需要更新玩家的money和gold的时候推送
	cmd_update_user_coin = 1006,

	--gm:{cmd:1007}
	--改完redis数据后需要更新玩家的money和gold的时候推送
	cmd_game_version = 1007,

	--gm:{cmd:1008,p1=room_id} p1为room_id =0为立即生效
	cmd_rm_room = 1008,

	-------------------email begin
	--gm:{cmd:1009}
	cmd_show_emails = 1009,

	--gm:{cmd:1010,p4=jsonObjStr}
	--jsonObj
	--    title
	--    content
	--    rewards
	--    	type = ?
	--    	value = ?
	--    	gold = ?
	cmd_add_emails = 1010,

	--gm:{cmd:1011,p1=email_id,p4=jsonObjStr}
	--jsonObj
	--    title
	--    content
	--    rewards
	--    	type = ?
	--    	value = ?
	--    	gold = ?
	cmd_alter_emails = 1011,

	--gm:{cmd:1012,p1=email_id}
	cmd_rm_emails = 1012,

	--gm:{cmd:1013,p1=email_id,p4=uid,uid,...}
	cmd_send_emails = 1013,

	--gm:{cmd:1014,p1=email_id}
	cmd_send_emails_toall = 1014,
	--------------------------------email end
	--gm:{cmd:1015,p4=str}
	cmd_send_horse_lamp= 1015,

	--gm:{cmd:1016,p1=begin_timestamp,p2=end_timestamp,p4=str}  begin && end == 0 : mean: forever
	cmd_send_announce = 1016,

	--gm:{cmd:1017}
	cmd_get_announce = 1017,

	--gm:{cmd:9999,p4="shutdown"} p1这个字符串是了防止误发送协议的shutdown校验
	--改完redis数据后需要更新玩家的money和gold的时候推送
	cmd_shut_down_game = 9999,
}
return M
