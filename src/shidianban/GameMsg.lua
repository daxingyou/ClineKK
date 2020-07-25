local GameMsg = {

SUPER_PLAYER                    = 10,                --//超级玩家
INVALID_CHAIR					= 255,				--//无效椅子

--//游戏状态
GS_FREE							= 25,								--//等待开始
GS_PLAYING                      = 26,								--//各玩家进行打牌状态
GS_TH_FREE						= 25,							--//等待开始
GS_TH_SCORE						= 26,						--//下注状态
GS_TH_PLAY						= 27,						--//游戏状态
GS_TH_QIANG						= 28,						--//抢庄状态
GS_TK_BEGIN						= 29,						--//开始状态

MAX_COUNT						= 5,									--//最大数目
FULL_COUNT						= 52,								--//扑克数目

--//游戏信息
GAME_PLAYER						= 5,									--//游戏人数
NAME_ID                         = 40027000,        					--//名字 ID
PLAY_COUNT                      = 5,               		--//游戏人数

--//牌型定义
CT_ERROR						= 0,									--//错误牌型
CT_WU_XIAO						= 110,								--//五小
CT_REN_WU_XIAO					= 120,								--//人五小
CT_TIAN_WANG					= 130,								--//天王


--//异常类消息
ASS_NO_PLAYER                   = 155,             					--//没有玩家进行游戏
ASS_AGREE                       = 156,             					--//玩家是否同意的消息
ASS_CFG_DESK_TIMEOUT            = 157,             					--//设置底注超时
ASS_NOT_ENOUGH_MONEY            = 158,             					--//玩家金币不足的提示
ASS_FORCE_QUIT_REQ              = 160,             					--//玩家强退请求
ASS_QUIT_INFO                   = 161,             					--//服务端向客户端报告那个玩家退出的消息

SUB_S_GAME_START				= 101,									--//游戏开始
SUB_S_GAME_END					= 102,									--//游戏结束
SUB_S_ADD_SCORE					= 103,									--//玩家操作命令
SUB_S_SEND_CARD					= 104,									--//发牌命令
SUB_S_GIVE_UP					= 106,									--//停牌命令
SUB_S_USER_LEFT					= 105,									--//玩家逃跑
SUB_S_GAME_PLAY					= 107,									--//游戏开始
SUB_S_BANKER_CARD				= 108,									--//庄家的牌
SUB_S_NO_ACTION					= 109,									--//玩家未操作
SUB_S_SCORE						= 110,									--//玩家下注
SUB_S_BAO						= 111,									--//玩家爆牌
SUB_S_QIANG						= 112,									--//玩家抢庄
SUB_S_BEGIN						= 113,									--//开始抢庄
SUB_S_GIVE_UP_BANK				= 114,									--//放弃庄
SUB_S_PLAY_BANK					= 115,									--//播放跑马灯
SUB_S_PLAYEFFECT				= 116,									--//玩家开始状态

--//客户端命令结构

SUB_C_ADD_SCORE					= 100,									--//加倍
SUB_C_GIVE_UP					= 102,									--//停牌
SUB_C_GIVE_CARD					= 103,									--//要牌
SUB_C_SCORE						= 104,									--//下注
SUB_C_Continue					= 105,									--//继续游戏
SUB_C_QIANG						= 106,									--//抢庄
SUB_C_GIVE_UP_BANK				= 107,									--//放弃庄

}

-------------抢庄---------------------

--抢庄状态
GameMsg.CMD_S_StatusQiang = 
{
		--//单元积分
	{"lCellScore","LLONG"},--单元积分

	{"bUserStatus","BOOL["..GameMsg.PLAY_COUNT.."]"},--用户状态

	{"bQiang","BYTE["..GameMsg.PLAY_COUNT.."]"},--玩家的抢庄状态

	{"iLeftTime","INT"},--剩余时间

};

--//抢庄
GameMsg.CMD_S_BEGIN_BANK =
{
	--//状态变量
	{"byUserStatus","BOOL["..GameMsg.PLAY_COUNT.."]"},--用户状态
};

--//抢庄
GameMsg.CMD_C_Qiang =
{
	{"bQiang","BOOL"},--抢庄
};
--//抢庄
GameMsg.CMD_S_Qiang =
{
	--//状态变量
	{"wChairID","WORD"},--当前玩家
	{"bQiang","BOOL"},--抢庄
};
--播放跑马灯
GameMsg.CMD_S_PlayBank =
{
	{"wBankerUser","WORD"},--庄家
};

--//放弃庄
GameMsg.CMD_C_GIVE_UP_BANK =
{
	{"bGiveUp","BOOL"},--放弃庄
};

--//放弃庄
GameMsg.CMD_S_GIVE_UP_BANK =
{
	--//状态变量
	{"wChairID","WORD"},--当前玩家
	{"bGiveUp","BOOL"},--放弃庄
};


-----------------------------------------

--//积分信息
GameMsg.tagScoreInfo = 
{
	{"lScore","LLONG"},--用户分数
	{"lGrade","LLONG"},--用户成绩
	{"lRevenue","LLONG"},--游戏税收
};


--//空闲状态
GameMsg.CMD_S_StatusFree =
{
	{"lCellScore","LLONG"},--单元积分
	{"bGiveUp","BOOL"},--显示是否放弃
	{"bShowGiveUp","BOOL"},--显示按钮

};

--//下注状态
GameMsg.CMD_S_StatusScore =
{
	--//单元积分
	{"lCellScore","LLONG"},--单元积分
	{"lMaxScore","LLONG"},--单元积分
	--//状态变量
	{"wBankerUser","WORD"},--庄家
	{"lTableScore","LLONG["..GameMsg.PLAY_COUNT.."]"},--底注
	{"bUserStatus","BOOL["..GameMsg.PLAY_COUNT.."]"},--用户状态
	{"iLeftTime","INT"},--剩余时间
};

--//游戏状态
GameMsg.CMD_S_StatusPlay = 
{
	--//单元积分
	{"lCellScore","LLONG"},--单元积分

	--//状态变量
	{"wCurrentUser","WORD"},--当前玩家
	{"wBankerUser","WORD"},--庄家
	{"byUserStatus","BOOL["..GameMsg.PLAY_COUNT.."]"},--用户状态


	--//下注变量
	{"lTableScore","LLONG["..GameMsg.PLAY_COUNT.."]"},--底注

	--//扑克变量
	{"cbCardCount","BYTE["..GameMsg.PLAY_COUNT.."]"},--扑克数目
	{"cbHandCardData","BYTE["..GameMsg.PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--桌面扑克
	{"iLeftTime","INT"},--剩余时间
};


-- //游戏开始
GameMsg.CMD_S_GameStart =
{
	-- //单元积分
	{"lCellScore","LLONG"},--单元积分
	{"lMaxScore","LLONG"},--单元积分

	-- //状态变量
	{"wBankerUser","WORD"},--庄家
	{"bUserStatus","BOOL["..GameMsg.PLAY_COUNT.."]"},--用户状态
	{"cbControlFlag","BYTE"},--机器人牌点控制
};

-- //游戏开始
GameMsg.CMD_S_GamePlay = 
{
	-- //状态变量
	{"wCurrentUser","WORD"},--当前玩家

	-- //扑克变量
	{"byCardData","BYTE["..GameMsg.PLAY_COUNT.."]"},--明牌

	-- //下注变量
	{"lTableScore","LLONG["..GameMsg.PLAY_COUNT.."]"},--底注
};

-- //玩家操作
GameMsg.CMD_S_AddScore =
{
	{"wAddScoreUser","WORD"},--操作玩家
	{"cbCardData","BYTE"},--玩家牌
};

-- //发送扑克
GameMsg.CMD_S_SendCard =
{
	-- //游戏信息
	{"wCurrentUser","WORD"},--当前玩家
	{"wSendCardUser","WORD"},--发牌玩家
	{"cbCardData","BYTE"},--用户扑克
	{"cbControlFlag","BYTE"},--机器人牌点控制
};

-- //游戏结束
GameMsg.CMD_S_GameEnd =
{
	{"byCardData","BYTE["..GameMsg.PLAY_COUNT.."]"},--底牌数据
	{"lGameScore","LLONG["..GameMsg.PLAY_COUNT.."]"},--玩家得分
	{"bShowGiveUp","BOOL"},--
	{"nWinTime","INT"},									--//连胜局数
};

-- //停牌
GameMsg.CMD_S_GiveUp =
{
	{"wGiveUpUser","WORD"},--停牌玩家
	{"wCurrentUser","WORD"},--当前玩家
};

-- //庄家的牌
GameMsg.CMD_S_BankerCard = 
{
	{"cbBankerHandCardData","BYTE"},--发牌数据
};

-- //下注
GameMsg.CMD_S_Score =
{
	-- //状态变量
	{"wChairID","WORD"},--当前玩家
	{"lScore","LLONG"},--下注数
};

-- //下注
GameMsg.CMD_C_Score =
{
	{"lScore","LLONG"},--下注数
};	

--//爆牌
GameMsg.CMD_S_Bao =
{
	--//状态变量
	{"wChairID","WORD"},--当前玩家
	{"byCardData","BYTE"},--底牌
};


return GameMsg;