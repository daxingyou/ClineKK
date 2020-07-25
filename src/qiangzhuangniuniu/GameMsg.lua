
local GameMsg = { 
	SUPER_PLAYER               	=     10,              	--//超级玩家
	INVALID_CHAIR			   	=     255,				--//无效椅子
-- //文件名字定义
	GAMENAME                   	=     "抢庄牛牛",

-- //版本定义
	GAME_MAX_VER                =    1,               	--//现在最高版本
	GAME_LESS_VER               =    1,              	--//现在最低版本
	GAME_CHANGE_VER             =    0,               	--//修改版本

-- //游戏开发版本
	DEV_HEIGHT_VERSION          =    10,              	--//内部开发高版本号
	DEV_LOW_VERSION             =    1,               	--//内部开发低版本号

-- //数目定义
	MAX_COUNT					=     5,									--//最大数目
	USER_HAND_CARD              =     5,
-- -- //游戏信息
-- 	NAME_ID                     =    30002600,        	--//名字 ID
-- 	MAX_NAME_INFO               =    256,

-- //异常类消息
	
	--//游戏状态定义

		GS_FREE						=25,							--//等待开始
 		GS_PLAYING                  =26,							--//各玩家进行打牌状态

		GS_TK_FREE					=25,								--//等待开始
 		GS_TK_CALL					=26	,							--//叫庄状态
 		GS_TK_SCORE					=27,							--//下注状态
 		GS_TK_PLAYING				=28,							--//游戏进行

		SUB_S_GAME_START			=100,									--//闲开始下注
 		SUB_S_ADD_SCORE				=101,									--//加注结果
 		SUB_S_SEND_CARD				=103,									--//发牌消息
 		SUB_S_GAME_END				=104,									--//游戏结束
 		SUB_S_OPEN_CARD				=105,									--//用户摊牌
 		SUB_S_CALL_BANKER			=106,									--//用户叫庄
 		SUB_S_BEGIN_CALL			=107,									--//开始叫庄
 		SUB_S_WATCHER_SIT			=108,  									--//旁观

		SUB_C_CALL_BANKER			=101,									--//用户叫庄
		SUB_C_ADD_SCORE				=102,									--//用户加注
		SUB_C_OPEN_CARD				=103,									--//用户摊牌

		ASS_NO_PLAYER                   =155,             --//没有玩家进行游戏
		ASS_AGREE                       =156,             --//玩家是否同意的消息
 		ASS_CFG_DESK_TIMEOUT            =157,             --//设置底注超时
 		ASS_NOT_ENOUGH_MONEY            =158,             --//玩家金币不足的提示
 		ASS_FORCE_QUIT_REQ              =160,             --//玩家强退请求
  		ASS_QUIT_INFO                   =161,             --//服务端向客户端报告那个玩家退出的消息


 		ASS_HAVE_THING                  =182,             --//有事请求离开
 		ASS_LEFT_RESULT                 =183,             --//同意用户离开
 		ASS_HAVE_THING_OUTTIME          =184,             --//有事请求离开事件处理超时
 		ASS_HAVE_THING_DOING            =185,             --//有事请求离开事件正在处理中
 		ASS_OUT_SEQ                     =186,             --//outseq                    
		ASS_USER_CUT                    =82,              --//玩家断线了
 		ASS_OUT_CARD_TIME               =190,             --//玩家超时，所剩时间 

}

--//没有玩家在桌的通知
GameMsg.TNoPlayer =
{
	{"bGameFinished","BOOL"}, 		--//桌子已散掉
};
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

--//游戏状态
GameMsg.CMD_S_StatusFree =
{
	{"wMaxPlayer", "WORD"}, 
	{"lUserTotalWin", "LLONG"}, 
	{"lUserLastWin", "LLONG"}, 
	{"bCellScore", "INT"}, 
	{"bWatcher","BOOL[5]"},
};

--//游戏状态
GameMsg.CMD_S_StatusCall =
{
	{"wMaxPlayer", "WORD"},
	{"wCallBanker", "WORD"},    --//叫庄用户
	{"lUserTotalWin", "LLONG"},
	{"lUserLastWin", "LLONG"},
	{"bCellScore", "INT"},
	{"bCallBank", "BYTE[5]"}, 			--叫庄分
	{"bCallStatus", "BYTE[5]"}, 		--叫庄状态
	{"iTime","UINT"},
	{"bWatcher","BOOL[5]"},
};

--//游戏状态
GameMsg.CMD_S_StatusScore =
{
	{"wMaxPlayer", "WORD"},
	{"lTurnMaxScore", "LLONG"},     	--//最大下注
	-- {"lTurnLessScore", "LONG"}, 		--//最小下注
	{"lTableScore", "LLONG[5]"},   	--//下注数目
	{"wBankerUser", "WORD"},        	--//庄家用户
	{"lUserTotalWin", "LLONG"},
	{"lUserLastWin", "LLONG"},
	{"bCellScore", "INT"},
	{"bCallBank", "BYTE"}, 			--叫庄分
	{"iTime","UINT"},
	{"bWatcher","BOOL[5]"},
};

--//游戏状态
GameMsg.CMD_S_StatusPlay =
{
	{"wMaxPlayer", "WORD"},
	{"lTurnMaxScore", "LLONG"},         --//最大下注
	-- {"lTableScore", "LONG"},
	{"lTableScore", "LLONG[5]"},        --//下注数目
	{"wBankerUser", "WORD"},               --//庄家用户
	{"cbHandCardData", "BYTE[5][5]"},            --//桌面扑克
	{"bOxCard", "BYTE[5]"},                   --//牛牛数据  255 未摊牌
	{"lUserTotalWin", "LLONG"},
	{"lUserLastWin", "LLONG"},
	{"bCellScore", "INT"},
	{"bCallBank", "BYTE"}, 			--叫庄分
	{"iTime","UINT"},
	{"bWatcher","BOOL[5]"},
};

--//用户叫庄
GameMsg.CMD_S_CallBanker =
{
	{"wCallBanker", "WORD"},      --//叫庄用户
	{"bBankRat", "BYTE"}, 
};

--//游戏开始
GameMsg.CMD_S_GameStart =
{
	{"lTurnMaxScore", "LLONG"},      --//最大下注
	{"wBankerUser", "WORD"},      --//叫庄用户
};

--//用户下注
GameMsg.CMD_S_AddScore =
{
	{"wAddScoreUser", "WORD"},      		--//加注用户
	{"lAddScoreCount", "LLONG"},      	--//加注数目
};

--//游戏结束
GameMsg.CMD_S_GameEnd =
{
	{"lGameTax", "LLONG[5]"},      		--//游戏税收
	{"lGameScore", "LLONG[5]"},      	--//游戏得分
	{"i64Money", "LLONG[5]"},      		--//玩家金币
	{"bAutoGiveUp","BOOL"},				-- //是否没有任何操作自动弃牌
	{"nWinTime","INT"},									--//连胜局数
};

--//发牌数据包
GameMsg.CMD_S_SendCard =
{
	{"cbCardData", "BYTE[5]"},      	--//用户扑克
};

--//用户退出
GameMsg.CMD_S_PlayerExit =
{
	{"wPlayerID", "WORD"},      		--//退出用户
	
};

--//用户摊牌
GameMsg.CMD_S_Open_Card =
{
	{"wPlayerID", "WORD"},      		--//摊牌用户
	{"bOpen", "BYTE"},      		    --//摊牌标志
	{"cbCardData", "BYTE[5]"},      	--//用户扑克
};

GameMsg.CMD_S_BeginData =
{
	{"iBasePoint", "INT"},      --//底分	
};

--//旁观
GameMsg.CMD_S_WatcherSit =
{
	{"wChairID", "WORD"},      		--//旁观用户
};

-------客户端-------------------------------------

--//用户叫庄
GameMsg.CMD_C_CallBanker =
{
	{"bBanker", "BYTE"},      		    --//做庄标志
};

--//用户加注
GameMsg.CMD_C_AddScore =
{
	{"lScore", "LLONG"},      	--//加注数目
	
};

--//用户摊牌
GameMsg.CMD_C_OxCard =
{
	{"bOX", "BYTE"},      		    --//牛牛标志
};

GameMsg.CMD_C_Trust =
{
	{"lBetIndex", "BYTE"},      		    --//托管下注标记
};

function GameMsg.init()

end

return GameMsg;
