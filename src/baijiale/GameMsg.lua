local GameMsg = { 
	-- //文件名字定义
	GAMENAME                   	=     "百家乐",

	GS_FREE						= 25,
	GS_Play 					=26,
	GS_PLAYING					= 27,

	MAXBANKER					 = 10,
	SERVER_LEN					 = 32,
	MAXBANKER					 = 10,
	AREA_MAX					 = 8,						--//最大区域
	--//服务器命令结构

	SUB_S_GAME_FREE				 = 99 ,						--//游戏空闲
	SUB_S_GAME_START			 = 100,						--//游戏开始
	SUB_S_PLACE_JETTON			 = 101,						--//用户下注
	SUB_S_GAME_END				 = 102, 					--//游戏结束
	SUB_S_APPLY_BANKER			 = 103, 					--//申请庄家
	SUB_S_CHANGE_BANKER			 = 104,						--//切换庄家
	SUB_S_CHANGE_USER_SCORE		 = 105,						--//更新积分
	SUB_S_SEND_RECORD			 = 106,						--//游戏记录
	SUB_S_PLACE_JETTON_FAIL		 = 107,						--//下注失败
	SUB_S_CANCEL_BANKER			 = 108, 					--//取消申请
	SUB_S_AMDIN_COMMAND			 = 109,						--//管理员命令
	SUB_S_UPDATE_STORAGE         = 110, 					--//更新库存
	SUB_S_GET_BANKER             = 111, 					--//抢庄
	SUB_S_CANCEL_CANCEL			 = 112,						--//取消下庄
	SUB_S_CANCEL_SUCCESS		 = 113,						--//取消下庄成功
	SUB_S_CANCEL_BET			 = 114, 					--//有人离开，退下注
	SUB_S_BANKERWINSCORE   		 = 116,						--庄家赢钱
	SUB_S_CONTINUEFAIL      	 = 117,						--续投
	SUB_S_XIPAI					 = 118,						--重新洗牌	




	--//////////////////////////////////////////////////////////////////////////
	--//客户端命令结构
	SUB_C_PLACE_JETTON			= 101, 						--//用户下注
	SUB_C_APPLY_BANKER			= 102, 						--//申请庄家
	SUB_C_CANCEL_BANKER			= 103, 						--//取消申请
	SUB_C_AMDIN_COMMAND			= 104, 						--//管理员命令
	SUB_C_UPDATE_STORAGE        = 105, 						--//更新库存
	SUB_C_GET_BANKER            = 106, 						--//抢庄
	SUB_C_CANCEL_CANCEL			= 107,						--//取消下庄
	SUB_C_CONTINUEBET      		= 108,						-- 续投


}


-- --//申请庄家
-- GameMsg.CMD_S_GetBanker = 
-- {
-- 	{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"}, 				--//申请玩家
-- 	{"CMD_INVALID","BOOL"}, 							--//标记，避免破解
-- }

--//失败结构
GameMsg.CMD_S_CancelBet = 
{
	{"lUserPlaceScore","LLONG["..GameMsg.AREA_MAX.."]"},
	{"lTotalPlaceScore","LLONG["..GameMsg.AREA_MAX.."]"},
};

GameMsg.CMD_S_BankScore = 
{
	{"score","LLONG"},
};

--//切换庄家
GameMsg.CMD_S_ChangeBanker = 
{
	{"wBankerUser","WORD"},								--//当庄玩家
	{"lBankerScore","LLONG"},							--//庄家分数	
	{"ApplyCount","INT"},			 					--上庄人数	
	{"ApplyUsers","BYTE[10]"},							--上庄列表
}

--//游戏状态
GameMsg.CMD_S_StatusFree = 
{
	--//全局信息
	{"cbTimeLeave","BYTE"},								--//剩余时间

	--//玩家信息
	{"lPlayFreeSocre","LLONG"},							--//玩家自由金币

	--//庄家信息
	{"wBankerUser","WORD"},								--//当前庄家
	{"lBankerScore","LLONG"},							--//庄家分数
	{"lBankerWinScore","LLONG"},						--//庄家赢分
	{"wBankerTime","WORD"},								--//庄家局数

	--//是否系统坐庄
	{"bEnableSysBanker","BOOL"},						--//系统做庄

	--//控制信息
	{"lApplyBankerCondition","LLONG"},					--//申请条件
	{"lAreaLimitScore","LLONG"},						--//区域限制

	--//房间信息
	{"szGameRoomName","CHARSTRING["..GameMsg.SERVER_LEN.."]"},	--//房间名称
	{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"},				--//申请玩家
	{"lBetCondition","INT"},--//最小下注起步
	{"wCancleBanker","BOOL"},--bool							;
	{"ApplyCount","INT"},			 					--上庄人数	
	{"wApplyBanker","BOOL"},							--自己是否申请上庄	
	{"ApplyUsers","BYTE[10]"},							--上庄列表
}

--//游戏状态
GameMsg.CMD_S_StatusPlay = 
{
	--//全局信息
	{"cbTimeLeave","BYTE"},								--//剩余时间
	{"cbGameStatus","BYTE"},							--//游戏状态

	--//下注数
	{"lAllBet","LLONG["..GameMsg.AREA_MAX.."]"},						--//总下注
	{"lPlayBet","LLONG["..GameMsg.AREA_MAX.."]"},				--//玩家下注

	--//玩家积分
	{"lPlayBetScore","LLONG"},							--//玩家最大下注	
	{"lPlayFreeSocre","LLONG"},							--//玩家自由金币

	--//玩家输赢
	{"lPlayScore","LLONG["..GameMsg.AREA_MAX.."]"},				--//玩家输赢
	{"lPlayAllScore","LLONG"},							--//玩家成绩

	--//庄家信息
	{"wBankerUser","WORD"},								--//当前庄家
	{"lBankerScore","LLONG"},							--//庄家分数
	{"lBankerWinScore","LLONG"},						--//庄家赢分
	{"wBankerTime","WORD"},								--//庄家局数

	--//是否系统坐庄
	{"bEnableSysBanker","BOOL"},						--//系统做庄

	--//控制信息
	{"lApplyBankerCondition","LLONG"},					--//申请条件
	{"lAreaLimitScore","LLONG"},						--//区域限制

	--//扑克信息
	{"cbCardCount","BYTE[2]"},							--//扑克数目
	{"cbTableCardArray","BYTE[2][3]"},					--//桌面扑克

	--//房间信息
	{"szGameRoomName","CHARSTRING["..GameMsg.SERVER_LEN.."]"},	--//房间名称
	{"lBetCondition","INT"},--//最小下注起步
	{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"},				--//申请玩家
	{"wCancleBanker","BOOL"},--bool						--取消下庄
	{"ApplyCount","INT"},			 					--上庄人数	
	{"wApplyBanker","BOOL"},							--自己是否申请上庄
	{"ApplyUsers","BYTE[10]"},							--上庄列表	
}

--//游戏空闲
GameMsg.CMD_S_GameFree = 
{
	{"cbTimeLeave","BYTE"},								--//剩余时间
	 	
}

--//游戏开始
GameMsg.CMD_S_GameStart = 
{
	{"cbTimeLeave","BYTE"},								--//剩余时间

	{"wBankerUser","WORD"},								--//庄家位置
	{"lBankerScore","LLONG"},							--//庄家金币

	{"lPlayBetScore","LLONG"},							--//玩家最大下注	
	{"lPlayFreeSocre","LLONG"},							--//玩家自由金币

	--{"nChipRobotCount","INT"},							--//人数上限 (下注机器人)
	{"nListUserCount","LLONG"},                   		--//列表人数
	--{"nAndriodCount","BYTE"},							--//机器人列表人数
	{"nBankerTime","INT"},								--//做庄次数 

	 	
}

--//用户下注
GameMsg.CMD_S_PlaceBet = 
{
	{"wChairID","WORD"},								--//用户位置
	{"cbBetArea","BYTE"},								--//筹码区域
	{"lBetScore","LLONG"},								--//加注数目
	--{"cbAndroidUser","BYTE"},							--//机器标识
	--{"cbAndroidUserT","BYTE"},							--//机器标识
	 	
}

--//游戏结束
GameMsg.CMD_S_GameEnd = 
{
	--//下局信息
	{"cbTimeLeave","BYTE"},								--//剩余时间

	--//扑克信息
	{"cbCardCount","BYTE[2]"},							--//扑克数目
	{"cbTableCardArray","BYTE[2][3]"},					--//桌面扑克

	--//庄家信息
	{"lBankerScore","LLONG"},							--//庄家成绩
	{"lBankerTotallScore","LLONG"},						--//庄家成绩
	{"nBankerTime","INT"},								--//做庄次数

	--//玩家成绩
	{"lPlayScore","LLONG["..GameMsg.AREA_MAX.."]"},		--//玩家成绩
	{"lPlayAllScore","LLONG"},							--//玩家成绩

	--//全局信息
	{"lRevenue","LLONG"},								--//游戏税收
	{"lWinArea","BOOL["..GameMsg.AREA_MAX.."]"},		--区域结果				
	{"LOtherScore","LLONG"},							--其他玩家成绩
	{"UserWinScore","LLONG["..PLAY_COUNT.."]"},			--所有玩家成绩
	{"nWinTime","INT"},									--//连胜局数
}

--//用户下注
GameMsg.CMD_C_PlaceBet = 
{
	{"cbBetArea","BYTE"},								--//筹码区域
	{"lBetScore","LLONG"},								--//加注数目
	 	
}

--//记录信息
GameMsg.tagServerGameRecord = 
{
	{"cbKingWinner","BYTE"},--//天王赢家
	{"bPlayerTwoPair","BOOL"},--//对子标识
	{"bBankerTwoPair","BOOL"},--//对子标识
	{"cbPlayerCount","BYTE"},--//闲家点数
	{"cbBankerCount","BYTE"},--//庄家点数 	
}

--//失败结构
GameMsg.CMD_S_PlaceBetFail = 
{
	{"wPlaceUser","WORD"},	--//下注玩家
	{"lBetArea","BYTE"},	--//下注区域
	{"lPlaceScore","LLONG"},--//当前下注
	 	
}

--//取消申请
GameMsg.CMD_S_CancelBanker = 
{
	{"szCancelUser","WORD"}, 	     --//取消玩家
	{"wCancelUser","CHARSTRING[32]"},--//取消玩家
	{"ApplyCount","INT"},			 --上庄人数
	{"ApplyUsers","BYTE[10]"},							--上庄列表
};

GameMsg.CMD_S_ApplyBanker = 
{
	{"wApplyUser","WORD"},--//申请玩家
	{"ApplyCount","INT"},			 --上庄人数
	{"ApplyUsers","BYTE[10]"},							--上庄列表
}

GameMsg.CMD_C_ContinueBet = 
{
	{"cbBetArea1","BYTE"},								--//筹码区域
	{"lBetScore1","LLONG"},								--//加注数目
	{"cbBetArea2","BYTE"},								--//筹码区域
	{"lBetScore2","LLONG"},								--//加注数目
	{"cbBetArea3","BYTE"},								--//筹码区域
	{"lBetScore3","LLONG"},								--//加注数目
	{"cbBetArea4","BYTE"},								--//筹码区域
	{"lBetScore4","LLONG"},								--//加注数目
	{"cbBetArea5","BYTE"},								--//筹码区域
	{"lBetScore5","LLONG"},								--//加注数目
	{"cbBetArea6","BYTE"},								--//筹码区域
	{"lBetScore6","LLONG"},								--//加注数目
	{"cbBetArea7","BYTE"},								--//筹码区域
	{"lBetScore7","LLONG"},								--//加注数目
	{"cbBetArea8","BYTE"},								--//筹码区域
	{"lBetScore8","LLONG"},								--//加注数目
}

function GameMsg.init()

	-- --//申请庄家
	-- GameMsg.CMD_S_GetBanker = 
	-- {
	-- 	{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"}, 				--//申请玩家
	-- 	{"CMD_INVALID","BOOL"}, 									--//标记，避免破解
	-- }
	GameMsg.CMD_S_BankScore = 
	{
		{"score","LLONG"},
	};
	--//失败结构
	GameMsg.CMD_S_CancelBet = 
	{
		{"lUserPlaceScore","LLONG["..GameMsg.AREA_MAX.."]"},
		{"lTotalPlaceScore","LLONG["..GameMsg.AREA_MAX.."]"},
	};
	--//切换庄家
	GameMsg.CMD_S_ChangeBanker = 
	{
		{"wBankerUser","WORD"},								--//当庄玩家
		{"lBankerScore","LLONG"},							--//庄家分数
		{"ApplyCount","INT"},			 					--上庄人数	 	
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	}

	--//游戏状态
	GameMsg.CMD_S_StatusFree = 
	{
		--//全局信息
		{"cbTimeLeave","BYTE"},								--//剩余时间

		--//玩家信息
		{"lPlayFreeSocre","LLONG"},							--//玩家自由金币

		--//庄家信息
		{"wBankerUser","WORD"},								--//当前庄家
		{"lBankerScore","LLONG"},							--//庄家分数
		{"lBankerWinScore","LLONG"},						--//庄家赢分
		{"wBankerTime","WORD"},								--//庄家局数

		--//是否系统坐庄
		{"bEnableSysBanker","BOOL"},						--//系统做庄

		--//控制信息
		{"lApplyBankerCondition","LLONG"},					--//申请条件
		{"lAreaLimitScore","LLONG"},						--//区域限制

		--//房间信息
		{"szGameRoomName","CHARSTRING["..GameMsg.SERVER_LEN.."]"},	--//房间名称
		{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"},				--//申请玩家
		{"lBetCondition","INT"},--//最小下注起步
		{"wCancleBanker","BOOL"},--bool
		{"ApplyCount","INT"},			 					--上庄人数
		{"wApplyBanker","BOOL"},							--自己是否申请上庄
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	}

	--//游戏状态
	GameMsg.CMD_S_StatusPlay = 
	{
		--//全局信息
		{"cbTimeLeave","BYTE"},								--//剩余时间
		{"cbGameStatus","BYTE"},							--//游戏状态

		--//下注数
		{"lAllBet","LLONG["..GameMsg.AREA_MAX.."]"},						--//总下注
		{"lPlayBet","LLONG["..GameMsg.AREA_MAX.."]"},				--//玩家下注

		--//玩家积分
		{"lPlayBetScore","LLONG"},							--//玩家最大下注	
		{"lPlayFreeSocre","LLONG"},							--//玩家自由金币

		--//玩家输赢
		{"lPlayScore","LLONG["..GameMsg.AREA_MAX.."]"},				--//玩家输赢
		{"lPlayAllScore","LLONG"},							--//玩家成绩

		--//庄家信息
		{"wBankerUser","WORD"},								--//当前庄家
		{"lBankerScore","LLONG"},							--//庄家分数
		{"lBankerWinScore","LLONG"},						--//庄家赢分
		{"wBankerTime","WORD"},								--//庄家局数

		--//是否系统坐庄
		{"bEnableSysBanker","BOOL"},						--//系统做庄

		--//控制信息
		{"lApplyBankerCondition","LLONG"},					--//申请条件
		{"lAreaLimitScore","LLONG"},						--//区域限制

		--//扑克信息
		{"cbCardCount","BYTE[2]"},							--//扑克数目
		{"cbTableCardArray","BYTE[2][3]"},					--//桌面扑克

		--//房间信息
		{"szGameRoomName","CHARSTRING["..GameMsg.SERVER_LEN.."]"},	--//房间名称
		{"lBetCondition","INT"},--//最小下注起步
		{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"},				--//申请玩家
		{"wCancleBanker","BOOL"},--bool
		{"ApplyCount","INT"},			 					--上庄人数
		{"wApplyBanker","BOOL"},							--自己是否申请上庄	
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	}

	--//游戏空闲
	GameMsg.CMD_S_GameFree = 
	{
		{"cbTimeLeave","BYTE"},								--//剩余时间
		 	
	}

	--//游戏开始
	GameMsg.CMD_S_GameStart = 
	{
		{"cbTimeLeave","BYTE"},								--//剩余时间

		{"wBankerUser","WORD"},								--//庄家位置
		{"lBankerScore","LLONG"},							--//庄家金币

		{"lPlayBetScore","LLONG"},							--//玩家最大下注	
		{"lPlayFreeSocre","LLONG"},							--//玩家自由金币

		--{"nChipRobotCount","INT"},							--//人数上限 (下注机器人)
		{"nListUserCount","DOUBLE"},                   		--//列表人数
		--{"nAndriodCount","BYTE"},							--//机器人列表人数
		 	
	}

	--//用户下注
	GameMsg.CMD_S_PlaceBet = 
	{
		{"wChairID","WORD"},								--//用户位置
		{"cbBetArea","BYTE"},								--//筹码区域
		{"lBetScore","LLONG"},								--//加注数目
		--{"cbAndroidUser","BYTE"},							--//机器标识
		--{"cbAndroidUserT","BYTE"},							--//机器标识
		 	
	}

	--//游戏结束
	GameMsg.CMD_S_GameEnd = 
	{
		--//下局信息
		{"cbTimeLeave","BYTE"},								--//剩余时间

		--//扑克信息
		{"cbCardCount","BYTE[2]"},							--//扑克数目
		{"cbTableCardArray","BYTE[2][3]"},					--//桌面扑克

		--//庄家信息
		{"lBankerScore","LLONG"},							--//庄家成绩
		{"lBankerTotallScore","LLONG"},						--//庄家成绩
		{"nBankerTime","INT"},								--//做庄次数

		--//玩家成绩
		{"lPlayScore","LLONG["..GameMsg.AREA_MAX.."]"},				--//玩家成绩
		{"lPlayAllScore","LLONG"},							--//玩家成绩

		--//全局信息
		{"lRevenue","LLONG"},								--//游戏税收
		{"lWinArea","BOOL["..GameMsg.AREA_MAX.."]"},--区域结果	 
		{"LOtherScore","LLONG"},							--其他玩家成绩
		{"UserWinScore","LLONG["..PLAY_COUNT.."]"},			--所有玩家成绩
		{"nWinTime","INT"},									--//连胜局数
	
	}

	--//用户下注
	GameMsg.CMD_C_PlaceBet = 
	{
		{"cbBetArea","BYTE"},								--//筹码区域
		{"lBetScore","LLONG"},								--//加注数目
		 	
	}

	--//记录信息
	GameMsg.tagServerGameRecord = 
	{
		{"cbKingWinner","BYTE"},--//天王赢家
		{"bPlayerTwoPair","BOOL"},--//对子标识
		{"bBankerTwoPair","BOOL"},--//对子标识
		{"cbPlayerCount","BYTE"},--//闲家点数
		{"cbBankerCount","BYTE"},--//庄家点数 	
	}

	--//失败结构
	GameMsg.CMD_S_PlaceBetFail = 
	{
		{"wPlaceUser","WORD"},	--//下注玩家
		{"lBetArea","BYTE"},	--//下注区域
		{"lPlaceScore","LLONG"},--//当前下注
		 	
	}
	--//取消申请
	GameMsg.CMD_S_CancelBanker = 
	{
		{"szCancelUser","WORD"}, 	     --//取消玩家
		{"wCancelUser","CHARSTRING[32]"},--//取消玩家
		{"ApplyCount","INT"},			 --上庄人数
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};
	
	GameMsg.CMD_S_ApplyBanker = 
	{
		{"wApplyUser","WORD"},--//申请玩家
		{"ApplyCount","INT"},			 --上庄人数
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};

	GameMsg.CMD_C_ContinueBet = 
	{
		{"cbBetArea1","BYTE"},								--//筹码区域
		{"lBetScore1","LLONG"},								--//加注数目
		{"cbBetArea2","BYTE"},								--//筹码区域
		{"lBetScore2","LLONG"},								--//加注数目
		{"cbBetArea3","BYTE"},								--//筹码区域
		{"lBetScore3","LLONG"},								--//加注数目
		{"cbBetArea4","BYTE"},								--//筹码区域
		{"lBetScore4","LLONG"},								--//加注数目
		{"cbBetArea5","BYTE"},								--//筹码区域
		{"lBetScore5","LLONG"},								--//加注数目
		{"cbBetArea6","BYTE"},								--//筹码区域
		{"lBetScore6","LLONG"},								--//加注数目
		{"cbBetArea7","BYTE"},								--//筹码区域
		{"lBetScore7","LLONG"},								--//加注数目
		{"cbBetArea8","BYTE"},								--//筹码区域
		{"lBetScore8","LLONG"},								--//加注数目
	};

end

return GameMsg;