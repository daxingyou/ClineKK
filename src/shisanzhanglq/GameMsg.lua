
local GameMsg = {
	GAMENAME            =  "十三张",
	ASS_GM_AGREE_GAME 	=  1,			-- 开始
	ASS_USER_CUT		=  82,			-- 玩家掉线

	-- 服务器命令结构
	SUB_S_SEND_CARD		=  103,			-- 发牌消息
	SUB_S_GAME_END		=  104,			-- 游戏结束
	SUB_S_OPEN_CARD		=  105,			-- 用户摊牌
	SUB_S_BIBAI_END		=  106,			-- 比牌数据

	-- 客户端命令结构
	SUB_C_OPEN_CARD		=  103,			-- 用户摊牌




	GS_TK_FREE			=  25,	-- 等待开始
	GS_TK_GAME			=  26,	-- 游戏中
}

-- 游戏状态
GameMsg.CMD_S_StatusFree =
{
	{"wMaxPlayer", "WORD"}, 
	{"lUserTotalWin", "LLONG"}, 
	{"lUserLastWin", "LLONG"}, 
	{"bCellScore", "INT"}, 
	{"bWatcher","BOOL["..PLAY_COUNT.."]"},
	{"nBasePoint", "INT"}, 				-- 底分
	{"nMoneyLimit", "INT"}, 			-- 最少金币
	{"bAgree", "BOOL["..PLAY_COUNT.."]"}, 
}

-- 游戏状态   基本是发牌后发的消息
GameMsg.CMD_S_StatusPlay = {
	{"wMaxPlayer", "WORD"},				-- 用户
	{"cbHandCardData", "BYTE["..PLAY_COUNT.."][13]"},	-- 桌面扑克
	{"bOxCard", "BYTE"},				-- 特殊牌
	{"bOpen", "BYTE["..PLAY_COUNT.."]"},				-- 是否摆牌
	{"lUserTotalWin", "LLONG"},			-- 
	{"lUserLastWin", "LLONG"},			-- 
	{"iSYTime", "INT"},					-- 摊牌剩余时间
	{"bWatcher", "BOOL["..PLAY_COUNT.."]"},			-- 
	{"nBasePoint", "INT"}, 				-- 底分
	{"nMoneyLimit", "INT"}, 			-- 最少金币
}

--//游戏结束
GameMsg.CMD_S_GameEnd =
{
	{"lGameTax", "LLONG["..PLAY_COUNT.."]"},      		--//游戏税收
	{"lGameScore", "LLONG["..PLAY_COUNT.."]"},      	--//游戏得分
	{"i64Money", "LLONG["..PLAY_COUNT.."]"},      		--//玩家金币
	{"bAutoGiveUp", "BOOL"},
	{"nWinTime","INT"},									--//连胜局数
};

-- 摊牌结构
GameMsg.OpenCard = {
	{"bFirst", "BYTE[3]"},
	{"bMid", "BYTE[5]"},
	{"bLast", "BYTE[5]"},
}

-- 比牌结果
GameMsg.CMD_S_BiPai = {
	{"bPlay", "GameMsg.OpenCard["..PLAY_COUNT.."]"},		-- 玩家数组
	{"bPRD", "INT["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},			-- 2维结果数据
	{"tsbPRD", "INT["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},
	{"bPoint", "LLONG["..PLAY_COUNT.."]"},			-- 当局玩家输赢积分用户积分
	{"mPDateResult", "INT[4]["..PLAY_COUNT.."]"},	-- 0 第一蹲  1 第二蹲 2 第三蹲  3 特殊牌
	{"iTax_Bingo", "INT[8]"},		-- 公点
	{"bAction", "BYTE["..PLAY_COUNT.."]"},				-- 用户状态 0,不切牌,1,切牌
	{"bGun", "INT["..PLAY_COUNT.."]"},
	{"bTotalPoint", "INT["..PLAY_COUNT.."]"},		-- 总分
	{"isteshu", "BOOL["..PLAY_COUNT.."]"},
	{"teshuType", "BYTE["..PLAY_COUNT.."]"},
	{"isquanleida", "BYTE"},
	{"WinAll", "BOOL["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},		-- 打枪情况
}

-- 发牌数据包
GameMsg.CMD_S_FaPai = {
	{"isteshu", "BYTE"},			-- 特殊牌
	{"bHand", "BYTE["..PLAY_COUNT.."][13]"},		-- 用户扑克
}

-- 用户摊牌
GameMsg.CMD_S_Open_Card = {
	{"bBiPai", "BOOL["..PLAY_COUNT.."]"},			-- 是否比牌
	{"isteshu", "BOOL["..PLAY_COUNT.."]"},			-- 是否特殊
}

-- 摆牌
GameMsg.DMC_S_Open_Card = {
	{"tsbPRD", "BYTE"},
	{"bFirst", "BYTE[3]"},
	{"bMid", "BYTE[5]"},
	{"bLast", "BYTE[5]"},
}


return GameMsg;
