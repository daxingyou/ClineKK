local GameMsg = { 
	-- //文件名字定义
	GAMENAME                   	=     "奔驰宝马",

	MAXBANKER					 = 10,
	SERVER_LEN					 = 10,
	AREA_MAX					 = 8,						--//最大区域
	
	--//历史记录
 	MAX_SCORE_HISTORY			 = 30,								--//历史个数

	--//异常类消息
	ASS_NO_PLAYER                   =155,--             //没有玩家进行游戏
	ASS_AGREE                       =156,--             //玩家是否同意的消息
	ASS_CFG_DESK_TIMEOUT            =157,--             //设置底注超时
	ASS_NOT_ENOUGH_MONEY            =158,--             //玩家金币不足的提示
	ASS_FORCE_QUIT_REQ              =160,--             //玩家强退请求
	ASS_QUIT_INFO                   =161,--             //服务端向客户端报告那个玩家退出的消息

	ASS_HAVE_THING                  =182,--             //有事请求离开
	ASS_LEFT_RESULT                 =183,--             //同意用户离开
	ASS_HAVE_THING_OUTTIME          =184,--             //有事请求离开事件处理超时
	ASS_HAVE_THING_DOING            =185,--             //有事请求离开事件正在处理中
	ASS_OUT_SEQ                     =186,--             //outseq                    
	ASS_USER_CUT                    =82 ,--            //玩家断线了
	ASS_OUT_CARD_TIME               =190,--				//玩家超时，所剩时间 

	-- //游戏状态
	GS_FREE						=     25,									--//等待开始
	GS_Play						=     26,									--//下注中
	GS_PLAYING                  =     27,									--//各玩家进行打牌状态

	--//服务器命令结构

	SUB_S_GAME_FREE				=99 ,--									//游戏空闲
	SUB_S_GAME_START			=100,-- 									//游戏开始
	SUB_S_PLACE_JETTON			=101,-- 									//用户下注
	SUB_S_GAME_END				=102,-- 									//游戏结束
	SUB_S_APPLY_BANKER			=103,-- 									//申请庄家
	SUB_S_CHANGE_BANKER			=104,-- 									//切换庄家
	SUB_S_CHANGE_USER_SCORE		=105,-- 									//更新积分
	SUB_S_SEND_RECORD			=106,-- 									//游戏记录
	SUB_S_PLACE_JETTON_FAIL		=107,-- 									//下注失败
	SUB_S_CANCEL_BANKER			=108,-- 									//取消申请
	SUB_S_SCORE_HISTORY			=109,-- 									//历史记录
	SUB_S_CHANGE_SYS_BANKER		=110,-- 									//切换庄家
	SUB_S_GET_BANKER            =111,-- 									//抢庄
	SUB_S_CANCEL_CANCEL			=112,-- 									//庄家下庄后反悔--取消下庄
	SUB_S_CANCEL_SUCCESS		=113,--									//庄家下庄
	SUB_S_CANCEL_BET			=114,--										//有人离开，退下注
	SUB_S_CONTINUEFAIL          =117,

	SUB_C_PLACE_JETTON			= 101,								--//用户下注
	SUB_C_APPLY_BANKER			= 102, 									--//申请庄家
	SUB_C_CANCEL_BANKER			= 103,									--//取消申请
	SUB_C_GET_BANKER            = 104,		
	SUB_C_CANCEL_CANCEL			= 105,									--//庄家下庄后反悔--取消下庄
	SUB_C_CONTINUEBET			= 106,										--//续投

	SUB_S_BANKERWINSCORE		= 116,								--庄家赢钱

}


	--//失败结构
	GameMsg.CMD_S_PlaceJettonFail =
	{
		{"lJettonArea","BYTE"},								--//下注区域
		{"lPlaceScore","LLONG"},							--//当前下注	 
	};

	--//更新积分
	GameMsg.CMD_S_ChangeUserScore =
	{
		{"wChairID","WORD"},--//椅子号码
		{"lScore","LLONG"},--//玩家积分
		--//庄家信息
		{"wCurrentBankerChairID","WORD"},--//当前庄家
		{"cbBankerTime","BYTE"},	--//庄家局数
		{"lCurrentBankerScore","LLONG"},--//庄家分数
	};
	--//申请庄家
	GameMsg.CMD_S_GetBanker =
	{
		{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"}, --//申请玩家
	};
	--//申请庄家
	GameMsg.CMD_S_ApplyBanker =
	{
		{"wApplyUser","WORD"},--//申请玩家
		{"ApplyCount","INT"},--/当庄玩家
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};

	--//取消申请
	GameMsg.CMD_S_CancelBanker =
	{
		{"szCancelUser","WORD"},--////取消玩家
		{"wCancelUser","CHARSTRING[32]"},--//取消玩家
		{"ApplyCount","INT"},--/当庄玩家
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};


	--//切换庄家
	GameMsg.CMD_S_ChangeBanker =
	{
		{"wBankerUser","WORD"},--/当庄玩家
		{"lBankerScore","LLONG"}, --//庄家金币
		{"ApplyCount","INT"},--/当庄玩家
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};

	--//切换庄家
	GameMsg.CMD_S_ChangeSysBanker =
	{
		{"bEnableSysBanker","BOOL"}, -- //系统做庄
		{"cbBankerTime","WORD"},--//庄家局数
	};

	--//游戏状态
	GameMsg.CMD_S_StatusFree =
	{
		{"IwanSafecode","LLONG"},
		--//全局信息
		{"cbTimeLeave","BYTE"},--//剩余时间

		{"lUserMaxScore","LLONG"},--//玩家金币

		--//庄家信息
		{"wBankerUser","WORD"},--//当前庄家
		{"cbBankerTime","WORD"},--//庄家局数
		{"lBankerWinScore","LLONG"},--//庄家成绩
		{"lBankerScore","LLONG"},--//庄家分数
		{"bEnableSysBanker","BOOL"},--//系统做庄
		{"cbLastResultIndex","BYTE"},--//上吧索引

		--//控制信息
		{"lApplyBankerCondition","LLONG"},--//申请条件
		{"lAreaLimitScore","LLONG"},--//区域限制
		{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"},--//申请玩家
		{"lBetCondition","INT"},--//最小下注
		{"wCancleBanker","BOOL"},--//庄家是否显示取消下庄
		{"ApplyCount","INT"},--/当庄玩家
		{"wApplyBanker","BOOL"},--//是否申请上庄
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};

	--//游戏状态
	GameMsg.CMD_S_StatusPlay=
	{
		{"IwanSafecode","LLONG"},--//安全标志
		--//全体下注
		{"lALLBigBCScore","LLONG"},--		//自己买大奔驰总数
		{"lALLSmallBCScore","LLONG"},--		//小奔驰
		{"lALLBigBMScore","LLONG"},--		//大宝马
		{"lALLSmallBMScore","LLONG"},--		//小宝马
		{"lALLBigADScore","LLONG"},--		//大奥迪
		{"lALLSmallADScore","LLONG"},--		//小奥迪
		{"lALLBigDZScore","LLONG"},--		//大大众
		{"lALLSmallDZScore","LLONG"},--		//小大众
		
		--//个人下注
		{"lUserBigBCScore","LLONG"},--		//自己买大奔驰总数
		{"lUserSmallBCScore","LLONG"},--		//小奔驰
		{"lUserBigBMScore","LLONG"},--		//大宝马
		{"lUserSmallBMScore","LLONG"},--		//小宝马
		{"lUserBigADScore","LLONG"},--		//大奥迪
		{"lUserSmallADScore","LLONG"},--		//小奥迪
		{"lUserBigDZScore","LLONG"},--		//大大众
		{"lUserSmallDZScore","LLONG"},--		//小大众

		--//玩家积分
		{"lUserMaxScore","LLONG"},--		//最大下注		

		--//控制信息
		{"lApplyBankerCondition","LLONG"},--		//申请条件
		{"lAreaLimitScore","LLONG"},--		//区域限制

		--//索引信息
		{"cbMoveEndIndex","BYTE"},--//移动减速索引
		{"cbResultIndex","BYTE"},--//结果索引
		{"cbEndIndex","BYTE"},--//停止索引
		{"cbLastResultIndex","BYTE"},--//上吧索引

		--//庄家信息
		{"wBankerUser","WORD"},--//当前庄家
		{"cbBankerTime","WORD"},--//庄家局数
		{"lBankerWinScore","LLONG"},--//庄家成绩
		{"lBankerScore","LLONG"},--//庄家分数
		{"bEnableSysBanker","BOOL"},--//系统做庄

		--//结束信息
		{"lEndBankerScore","LLONG"},--		//庄家成绩
		{"lEndUserScore","LLONG"},--	//玩家成绩
		{"lEndUserReturnScore","LLONG"},--		//返回积分
		{"lEndRevenue","LLONG"},--	//游戏税收

		--//全局信息
		{"cbTimeLeave","BYTE"},--//剩余时间
		{"cbGameStatus","BYTE"},--//游戏状态

		--//玩家状态
		{"cbUserStatus","BYTE"},--//用户状态
		{"wGetUser","WORD["..GameMsg.MAXBANKER.."]"}, 				--//申请玩家

		{"lBetCondition","INT"},--//最小下注
		{"wCancleBanker","BOOL"},--//庄家是否显示取消下庄
		{"ApplyCount","INT"},--/当庄玩家
		{"wApplyBanker","BOOL"},--//是否申请上庄
		{"ApplyUsers","BYTE[10]"},							--上庄列表
	};

	--//游戏空闲
	GameMsg.CMD_S_GameFree = 
	{
		{"cbTimeLeave","BYTE"},								--//剩余时间
		 	
	};

	--//游戏开始
	GameMsg.CMD_S_GameStart = 
	{
		{"wBankerUser","WORD"},--//庄家位置	
		{"lBankerScore","LLONG"},--//庄家金币	
		{"lUserMaxScore","LLONG"},--//我的金币		
		{"cbTimeLeave","BYTE"},								--//剩余时间	
		{"nBankerTime","INT"},								--//做庄次数		
	};

	--//用户下注
	GameMsg.CMD_S_PlaceJetton = 
	{
		{"wChairID","WORD"},--//用户位置	
		{"cbJettonArea","BYTE"},	--//筹码区域
		{"iJettonScore","LLONG"},--//加注数目		
	};


	--//游戏结束
	GameMsg.CMD_S_GameEnd = 
	{
		{"cbTimeLeave","BYTE"},								--//剩余时间

		--//索引信息
		{"cbMoveEndIndex","BYTE"},--//移动减速索引
		{"cbResultIndex","BYTE"},--//结果索引
		{"cbEndIndex","BYTE"},--//停止索引
		{"cbLastResultIndex","BYTE"},--//上吧索引

		--//庄家信息
		{"lBankerScore","LLONG"},--//庄家金币	
		{"lBankerTotallScore","LLONG"},--//庄家总成绩
		{"nBankerTime","INT"},								--//做庄次数

		--//玩家成绩
		{"lUserScore","LLONG"},--//玩家成绩	
		{"lUserReturnScore","LLONG"},--//返回积分

		--//全局信息
		{"lRevenue","LLONG"},--//游戏税收

		--//玩家下注信息
		{"lUserBigBCScore","LLONG"},--		//自己买大奔驰总数
		{"lUserSmallBCScore","LLONG"},--		//小奔驰
		{"lUserBigBMScore","LLONG"},--		//大宝马
		{"lUserSmallBMScore","LLONG"},--		//小宝马
		{"lUserBigADScore","LLONG"},--		//大奥迪
		{"lUserSmallADScore","LLONG"},--		//小奥迪
		{"lUserBigDZScore","LLONG"},--		//大大众
		{"lUserSmallDZScore","LLONG"},--		//小大众

		{"LOtherScore","LLONG"},--//其他玩家成绩	
		
		{"nWinTime","INT"},									--//连胜局数
	};

	--////有人离开，退下注
	GameMsg.CMD_S_CancelBet =
	{
		{"lUserPlaceScore","LLONG[8]"},	--//
		{"lTotalPlaceScore","LLONG[8]"},	--//
	};

	--//游戏结束
	GameMsg.CMD_S_ScoreHistory =
	{
		{"cbScoreHistroy","BYTE["..GameMsg.MAX_SCORE_HISTORY.."]"},	--//历史信息
	};

	--//用户下注
	GameMsg.CMD_C_PlaceJetton =
	{
		{"cbJettonArea","BYTE"}, -- //筹码区域
		{"iJettonScore","LLONG"}, --//加注数目
	};

	--庄家坐庄期间输赢金币
	GameMsg.BankGetMonry = {
		{"money","LLONG"},--庄家坐庄期间输赢金币
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

function  GameMsg.init()
	
end




return GameMsg;