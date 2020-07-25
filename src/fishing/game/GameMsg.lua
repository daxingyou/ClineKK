local GameMsg = { 
	SUPER_PLAYER					=	10,			--//超级玩家
	INVALID_CHAIR					=	255,				--//无效椅子
-- //文件名字定义
	GAMENAME						=	"捕鱼",

-- //版本定义
	GAME_MAX_VER				=	1,					--//现在最高版本
	GAME_LESS_VER				=	1,				--//现在最低版本
	GAME_CHANGE_VER				=	0,					--//修改版本

-- //游戏开发版本
	DEV_HEIGHT_VERSION			=	10,				--//内部开发高版本号
	DEV_LOW_VERSION				=	1,					--//内部开发低版本号

-- //支持类型
	-- SUPPER_TYPE					 SUP_NORMAL_GAME|SUP_MATCH_GAME|SUP_MONEY_GAME

-- //数目定义
	MAX_COUNT					=	8,									--//最大数目
	FULL_COUNT					=	104,									--//全牌数目
-- //数值掩码
	MASK_COLOR					=	0xF0,									--//花色掩码
	MASK_VALUE					=	0x0F,									--//数值掩码

-- //游戏状态
	GS_FREE						=	25,									--//等待开始
	GS_PLAYING					=	27,									--//各玩家进行打牌状态
-- -- //游戏信息
-- 	NAME_ID					 =	30002600,			--//名字 ID
-- 	MAX_NAME_INFO				=	256,

-- //异常类消息
	ASS_NO_PLAYER					=	155,			--//没有玩家进行游戏
	ASS_AGREE						=	156,			--//玩家是否同意的消息
	ASS_CFG_DESK_TIMEOUT			=	157,			--//设置底注超时
	ASS_NOT_ENOUGH_MONEY			=	158,			--//玩家金币不足的提示
	ASS_FORCE_QUIT_REQ				=	160,			--//玩家强退请求
	ASS_QUIT_INFO					=	161,			--//服务端向客户端报告那个玩家退出的消息


	ASS_HAVE_THING					=	182,			--//有事请求离开
	ASS_LEFT_RESULT					=	183,			--//同意用户离开
	ASS_HAVE_THING_OUTTIME			=	184,			--//有事请求离开事件处理超时
	ASS_HAVE_THING_DOING			=	185,			--//有事请求离开事件正在处理中
	ASS_OUT_SEQ						=	186,			--//outseq					
	ASS_USER_CUT					=	82,			--//玩家断线了
	ASS_OUT_CARD_TIME				=	190,			--//玩家超时，所剩时间

	SUB_S_GPS							=	100,									--//经纬度
	SUB_S_GAME_CONFIG					=	101,									--//游戏配置 
	SUB_S_FISH_TRACE					=	102,									--//鱼的轨迹 
	SUB_S_EXCHANGE_FISHSCORE			=	103,									--//鱼分兑换 
	SUB_S_USER_FIRE						=	104,									--//用户发炮 
	SUB_S_CATCH_FISH					=	105,									--//用户碰撞鱼 
	SUB_S_BULLET_ION_TIMEOUT			=	106,									--//能量炮 
	SUB_S_LOCK_TIMEOUT					=	107,									--//锁定过期 
	SUB_S_CATCH_SWEEP_FISH				=	108,									--//炸弹鱼碰撞
	SUB_S_CATCH_SWEEP_FISH_RESULT		=	109,									--//炸弹鱼捕获结果 
	SUB_S_HIT_FISH_LK					=	110,									--//李逵碰撞 
	SUB_S_SWITCH_SCENE					=	111,									--//场景切换 
	SUB_S_STOCK_OPERATE_RESULT			=	112,									--//库存操作 
	SUB_S_SCENE_END						=	113,									--//特殊场景结束 
	SUB_S_SEND_BIRD_ANDROID				=	114,									--//机器人 
	SUB_S_MESSAGE						=	115,									--//发送消息
	SUB_S_SEND_RESULT					=	116,									--//发送成绩
	SUB_S_SEND_TIME						=	117,									--//同步时间
	SUB_S_SEND_ONLINEREWARD				=	118,									--//领取在线奖励
	SUB_S_SEND_SWITCH					=	119,									--//即将鱼潮
	SUB_S_SEND_NO_SCORE					=	121,									--//比赛结束，写分
	SUB_S_NEW_REWARD					=	122,									--//礼蛋,摇钱树，红包奖励
	SUB_S_HONGBAO_REWARD				=	123,									--//抽红包结果
	SUB_S_HUNDUN_REWARD					=	124,									--//混沌珠结果
	SUB_S_LOCK_FIRE						=	125,									--//锁定消息
	SUB_S_ANDROID						=	126,									--机器人通知消息
	SUB_S_HIT_FISH            			=	127,                  					--//子弹鱼碰撞消息


	SUB_C_EXCHANGE_FISHSCORE			=	110,										--//鱼分兑换
	SUB_C_USER_FIRE						=	111,										--//开火
	SUB_C_CATCH_FISH					=	112,										--//碰撞鱼
	SUB_C_CATCH_SWEEP_FISH				=	113,										--//炸弹鱼碰撞
	SUB_C_HIT_FISH_I					=	114,										--//李逵碰撞
	SUB_C_STOCK_OPERATE					=	115,										--//库存操作
	SUB_C_USER_FILTER					=	116,										--//特殊玩家配置
	SUB_C_ANDROID_STAND_UP				=	117,										--//机器人站立
	SUB_C_FISH20_CONFIG					=	118,										--//鱼配置
	SUB_C_ANDROID_BULLET_MUL			=	119,										--//机器人
	-- SUB_C_SEND_BIRD_ANDROID				=	120,										--//机器人
	SUB_C_SEND_RESULT					=	121,										--//发送成绩
	SUB_C_SEND_CONFIG					=	123,										--//领取配置
	SUB_C_SEND_TIME						=	124,										--//同步时间
	SUB_C_SEND_ONLINEREWARD				=	125,										--//领取在线奖励
	SUB_S_MATCH_END						=	120,
	SUB_C_SEND_NO_SCORE					=	126,										--//比赛结束，写分
	SUB_C_SEND_HUNDUN					=	127,									--//混沌碰撞
	SUB_C_LIDAN							=	128,										--//敲礼蛋
	SUB_C_YQS							=	129,										--//摇钱树
	SUB_C_HONGBAO						=	130,										--红包
	SUB_C_LOCK_FIRE						=	131,										--//锁定消息
	SUB_C_SEND_ANDROID_LEFT        		=	132,                    					--//让机器人离开消息

}

GameMsg.CMD_S_AgreeState = {
	{"wCurrentUser","BYTE"},--//当前玩家
	{"bAgree","BOOL"},--//同意开始
}

-- //没有玩家在桌的通知
GameMsg.TNoPlayer = {
	{"bGameFinished","BOOL"},--//桌子已散掉 bGameFinished = false;  //桌子已散掉
}

-- //玩家强退的报告包，服务器给客户端的
GameMsg.TQuitInfo = {
	{"byUser","INT"},--//退出的玩家
}

--//断线数据结构
GameMsg.bCutStruct = {
	{"bDeskStation","BYTE"},
	{"bCut","BOOL"},
}

GameMsg.LeaveResultStruct = {
	{"bDeskStation","BYTE"},
	{"bArgeeLeave","INT"},
}

--//百度定位
GameMsg.CMD_S_GPS = {
	{"wChairID","WORD"},				--//椅子id
	{"Latitude","DOUBLE"},			--//纬度
	{"Longitude","DOUBLE"},			--//经度
}

--捕鱼协议
GameMsg.FishTraceInfo = {
	{"fish_kind","INT"},
	{"fish_id","INT"},
	{"build_tick","INT"},
};

GameMsg.FPoint = {
	{"x","FLOAT"},
	{"y","FLOAT"},
};

GameMsg.FPointAngle = {
	{"x","FLOAT"},
	{"y","FLOAT"},
	{"angle","FLOAT"},
};

-- //鱼轨迹消息
GameMsg.CMD_S_FishTrace = {
	{"init_pos","GameMsg.FPoint[5]"},
	{"init_count", "INT"},
	{"fish_kind", "INT"},
	{"fish_id", "INT"},
	{"trace_type", "INT"},
	{"pathid", "INT"},
	{"chair_id","INT"},
};

-- //鱼分兑换消息
GameMsg.CMD_S_ExchangeFishScore = {
	{"chair_id","WORD"},
	{"swap_fish_score","LLONG"},
	{"exchange_fish_score","LLONG"},
};

-- //开火消息
GameMsg.CMD_S_UserFire = {
	{"bullet_kind", "INT"},
	{"bullet_id", "INT"},
	{"chair_id", "WORD"},
	{"android_chairid", "WORD"},
	{"bullet_mulriple", "INT"},
	{"lock_fishid", "INT"},
	{"fish_score","LLONG"},
	{"angle", "FLOAT"},
};

GameMsg.goodsInfo = {
	{"goodsID","INT"},
	{"goodsCount","DOUBLE"},
}

-- //碰撞消息
GameMsg.CMD_S_CatchFish = {
	{"chair_id","WORD"},
	{"fish_id","INT"},
	{"fish_kind","INT"},
	{"bullet_ion","BOOL"}, 
	{"fish_score","LLONG"},
	{"user_score","LLONG"},
	{"fish_mulriple","INT"},
	{"goodsInfoList","GameMsg.goodsInfo[20]"}
};

-- //能量炮
GameMsg.CMD_S_BulletIonTimeout = {
	{"chair_id", "WORD"},
};

-- //炸弹鱼碰撞
GameMsg.CMD_S_CatchSweepFish = {
	{"chair_id", "WORD"},
	{"fish_id","INT"},
	{"android_chairid", "WORD"},
};

-- //炸弹鱼捕获结果
GameMsg.CMD_S_CatchSweepFishResult = {
	{"chair_id", "WORD"},
	{"fish_id","INT"},
	{"fish_score","LLONG"},
	{"user_score","LLONG"},
	{"catch_fish_count","INT"},
	{"catch_fish_id","INT[50]"},
	{"fish_mulriple","INT"},
	{"fish_kind","INT"},
};

-- //李逵碰撞
GameMsg.CMD_S_HitFishLK = {
	{"chair_id", "WORD"},
	{"fish_id","INT"},
	{"fish_mulriple","INT"},
};

-- //切换场景
GameMsg.CMD_S_SwitchScene = {
	{"scene_kind","INT"},
	{"fish_count","INT"},
	{"fish_kind","INT[200]"},
	{"fish_id","INT[200]"},
};

-- //库存操作
GameMsg.CMD_S_StockOperateResult = {
	{"operate_code","BYTE"},
	{"stock_score","LLONG"},
};

GameMsg.CMD_S_SEND_BIRD_ANDROID = {
	{"ChairID","INT"},
};

-- //兑换鱼分
GameMsg.CMD_C_ExchangeFishScore = {
	{"increase","BOOL"},
};

-- //用户开火
GameMsg.CMD_C_UserFire = {
	{"chair_id","INT"},
	{"bullet_kind", "INT"},
	{"bullet_mulriple", "INT"},
	{"lock_fishid", "INT"},
	{"bullet_id", "INT"},
	{"angle", "FLOAT"},
};

-- //碰撞消息
GameMsg.CMD_C_CatchFish = {
	{"chair_id", "WORD"},
	{"fish_id","INT"},
	{"bullet_kind","INT"},
	{"bullet_id","INT"},
	{"bullet_mulriple","INT"},
};

-- //炸弹鱼碰撞
GameMsg.CMD_C_CatchSweepFish = {
	{"chair_id", "WORD"},
	{"fish_id","INT"},
	{"catch_fish_count","INT"},
	{"catch_fish_id","INT[50]"},
};

-- //李逵碰撞
GameMsg.CMD_C_HitFishLK = {
	{"fish_id","INT"},
};

-- //库存
GameMsg.CMD_C_StockOperate = {
	{"operate_code","BYTE"},--// 0查询 1 清除 2 增加 3 查询抽水	 
};

-- //特殊用户
GameMsg.CMD_C_UserFilter = {
	{"game_id","INT"},
	{"operate_code","BYTE"},--// 0 黑名单 1 白名单 2 清除
};

-- //特殊操作
GameMsg.CMD_C_Fish20Config = {
	{"game_id","INT"},
	{"catch_count","INT"},
	{"catch_probability","DOUBLE"},
};

-- //机器人
GameMsg.CMD_C_AndroidBulletMul = {
	{"chair_id", "WORD"},
	{"bullet_id", "INT"},
	{"bullet_mulriple", "INT"},
	{"bullet_kind", "INT"},
};

-- //机器人
GameMsg.CMD_C_SEND_BIRD_ANDROID = {
	{"FishPos", GameMsg.FPoint},
	{"ChairID", "INT"},
};

--砸金蛋
GameMsg.CMD_S_NewReward = {
	{"fish_score","LLONG"},
	{"UserFishscore","LLONG"},
	{"iLotteries","DOUBLE"},
	{"UserLotteries","DOUBLE"},
	{"OperaType","INT"}, --//0:l礼蛋，1：摇钱树，2：红包
}

GameMsg.CMD_S_HongBaoReward = {
	{"rat","INT"},
	{"multiple","INT"},
}

-- 锁定消息
GameMsg.CMD_C_LOCK_FIRE = {
	{"IsLockFire", "BOOL"},
};

-- 锁定消息
GameMsg.CMD_S_LOCK_FIRE = {
	{"IsLockFire", "BOOL"},
	{"chair_id", "WORD"},
};

GameMsg.CMD_S_Android = {
	{"chairID","INT"},
	{"robotChairID","BOOL["..PLAY_COUNT.."]"}
};

GameMsg.CMD_S_HitFish = {
	{"chair_id", "WORD"},
	{"fish_id","INT"},
};

GameMsg.CMD_S_FishTraces = {
	{"fish_kind", "INT"},
	{"fish_id", "INT"},
	{"pathid", "INT"}
};

-- //机器人离开
GameMsg.CMD_C_ANDROID_LEFT =
{
	{"chair_id", "INT"}
};

function GameMsg.init()
-- //场景
GameMsg.CMD_S_GameStatus = {
	{"fish_score","LLONG["..PLAY_COUNT.."]"},
	{"exchange_fish_score","LLONG["..PLAY_COUNT.."]"},
	-- {"fish_trace_info","FishTraceInfo[100]"},
	{"bulletid", "INT"},
	{"Now_tick","INT"},
	{"fish_trace_info","GameMsg.CMD_S_FishTraces[50]"},
};

-- //配置
GameMsg.CMD_S_GameConfig = {
	{"exchange_ratio_userscore","INT"},
	{"exchange_ratio_fishscore","INT"},
	{"exchange_count","INT"},
	{"min_bullet_multiple","INT"},
	{"max_bullet_multiple","INT"},
	{"bomb_range_width","INT"},
	{"bomb_range_height","INT"},
	{"fish_multiple","INT["..FishType.FISH_KIND_COUNT.."]"},
	{"fish_speed","INT["..FishType.FISH_KIND_COUNT.."]"},
	{"fish_bounding_box_width","INT["..FishType.FISH_KIND_COUNT.."]"},
	{"fish_bounding_box_height","INT["..FishType.FISH_KIND_COUNT.."]"},
	{"fish_hit_radius","INT["..FishType.FISH_KIND_COUNT.."]"},
	{"bullet_speed","INT["..BulletKind.BULLET_KIND_COUNT.."]"},
	{"net_radius","INT["..BulletKind.BULLET_KIND_COUNT.."]"},
	{"MatchScore","INT"},
	{"UserNowMatch","INT"},
	{"InitScore","INT"}
};

-- //游戏结束
GameMsg.CMD_S_GameEnd = {
	-- //游戏信息
	{"lGameScore","LLONG["..PLAY_COUNT.."][3]"},--//各墩分数
	{"lGameScoreGun","LLONG["..PLAY_COUNT.."]"},
	{"lWinScore", "LLONG["..PLAY_COUNT.."]"},--//玩家得失分
	-- //扑克信息
	{"bAllGun","BOOL["..PLAY_COUNT.."]"},--//扑克数目
	{"cbSpecType","BYTE["..PLAY_COUNT.."]"},
	{"cbHandCardData", "BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},	
	{"lCountGameScore", "LLONG["..PLAY_COUNT.."]"},--//玩家得失分
	{"bGameEnd", "BOOL"},
	{"m_bGunFire","INT[50]"}--//打枪列表
};

GameMsg.HaveThingStruct = {
	{"pos","BYTE"},
	{"szMessage","CHARSTRING[61]"},
	{"bAgreeLeft","INT["..PLAY_COUNT.."]"},
	{"nWaitTime","INT"},--//等待同意时间
};

-- 记录用户捕获的鱼成绩
GameMsg.UserResult = {
	{"m_lFishCount", "INT["..FishType.FISH_KIND_COUNT.."]"},
	{"m_lFishScore", "INT["..FishType.FISH_KIND_COUNT.."]"},
};

-- 在线奖励同步时间
GameMsg.UpdataTime = {
	{"times", "INT"},
};

-- 记录用户捕获的鱼成绩
GameMsg.CMD_S_OnlineTimeForReward = {
	{"fish_score", "LLONG"},
	{"score", "LLONG"},
};

GameMsg.CMD_S_Android = {
	{"chairID","INT"},
	{"robotChairID","BOOL["..PLAY_COUNT.."]"}
};

end

return GameMsg;
