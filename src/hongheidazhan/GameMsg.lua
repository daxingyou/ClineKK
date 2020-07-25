local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "红黑大战",
	MAX_CARD_COUNT 			=		52,
	CARD_COUNT 				= 		3,


	--游戏状态
	GS_FREE = 0,
	GS_NOTE = 21,
	GS_OPEN_CARD = 22,
	GS_WAIT_NEXT = 23,

	NOTE_TYPE_COUNT = 3,

	MAX_RESULT_RECORD = 100,
	CARD_COUNT = 3,

	--//S-C
	SUB_S_ERROR					= 100,		--//错误信息
	SUB_S_GAME_BEGIN			= 101,		--//游戏开始
	SUB_S_NOTE_RESULT			= 102,		--//下注结果
	SUB_S_OPEN_CARD				= 104,		--//开牌结算
	SUB_S_SHANG_ZHUANG			= 105,		--//上庄
	SUB_S_WU_ZHUANG				= 106,		--//无庄等待
	ASS_NOTE_BACK				= 107,		--退注

	--//C-S
	SUB_C_NOTE					= 201,		--//下注
	SUB_C_SHANG_ZHUANG			= 202,		--//上庄

	ASS_ZHUANG_SCORE			= 108,		--//庄家坐庄期间输赢金币

	SUB_C_NOTE_EX				= 203,		--//续投
	SUB_S_NOTE_RESULT_EX		= 109,		--//续投结果

}

--庄家信息
GameMsg.SZUserInfo = {
	{"station","BYTE"},--庄家位置
	{"i64Money","LLONG"},--庄家金币
};


--游戏开始信息
GameMsg.tagBeginData = {
	{"iNTListCount","INT"},--庄家列表的位置
	{"m_iZhuangBaShu","INT"},--庄家进行了几把
	{"m_iNowNtStation","BYTE"},--当前庄家的位置
	{"iNTList","GameMsg.SZUserInfo[10]"},
};
--下注
GameMsg.Cr_Packet_XiaZhu = {
	{"type","INT"},--下注区域0-3
	{"money","INT"},--金额
	{"moneytype","INT"},--筹码类型：1：百，2：千，3：万，4：十万，5：百万，6：五百万
};
--下注结果
GameMsg.Rc_Packet_XiaZhuResultss = {
	{"station","BYTE"},--位置
	{"money","INT"},--金额
	{"type","INT"},--下注区域
	{"moneytype","INT"},--筹码类型：1：百，2：千，3：万，4：十万，5：百万，6：五百万
	{"m_iQuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--本把每个区域下的注额
	
};

--错误信息
GameMsg.Rc_ErrorCode = {
	{"errorCode","INT"},--错误信息
};

--发送上庄
GameMsg.Cr_Packet_SXZhuang = {
	{"bCancel","BOOL"},--上下庄取消
	{"shang","BOOL"},--true为上庄，false 为下庄
	{"bIsRobot","BOOL"},--是否为机器人
};

--上庄数据包
GameMsg.Rc_Packet_SXZhuang = {
	{"iNTListCount","INT"},--庄家列表
	{"shang","BOOL"},--true为上庄，false 为下庄
	{"success","INT"},--是否失败 0上下庄失败 1金币不足 2成为庄操作 3加入申请列表的操作
	{"station","BYTE"},--申请的位置

	{"iLimitmoney","LLONG"},--上庄最少金币数
	{"bCancel","BOOL"},--取消操作

	{"bIsRobot","BOOL"},--是否为机器人
	{"iZhuangStatus","INT"},--自己的按钮状态
	{"iNTList","GameMsg.SZUserInfo[10]"},
};


--比牌结果
GameMsg.Rc_OpenCard = {
	{"iWinner","BYTE"},--获胜玩家
	{"iRBCard","BYTE[2]["..GameMsg.CARD_COUNT.."]"},
	{"iCardShape","BYTE[2]"},--牌型
	{"iWinQuYu","BOOL["..GameMsg.NOTE_TYPE_COUNT.."]"},--游戏的赢钱区域
	{"iUserScore","LLONG"},--玩家本局得分
	{"iNTScore","LLONG"},--庄家得分
	{"iOtherScore","LLONG"},--闲家得分,排除庄家和自己
	{"iUserReturnTotle","LLONG"},--玩家赢钱区域所下的注
	{"iUserTotalNote","LLONG"},--玩家总下注
	{"nWinTime","INT"},									--//连胜局数
};

--断线重连数据包
GameMsg.tagChongLian = {
	{"bGameStation","BYTE"},--当前游戏状态
	{"iNTListCount","INT"},--庄家列表
	{"ZhuangStatus","INT"},--玩家庄状态
	{"iShangZhuangLimit","LLONG"},--上庄限制
	{"iXiaZhuangLimit","LLONG"},--下庄限制
	{"iZhuangBaShu","INT"},--庄家进行了几把
	{"iNowNtStation","BYTE"},--当前庄家的位置

	{"iTotalNote","LLONG"},--本把当前总注额
	{"i64QuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--本把每个区域下的注额
	{"i64myZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--自己下的注

	{"i64ZhuangFen","LLONG"},--庄家的得分
	{"i64XianFen","LLONG"},--闲家的得分
	{"i64UserFen","LLONG"},--当前玩家的得分

	{"ResultInfo","GameMsg.ResultInfo["..GameMsg.MAX_RESULT_RECORD.."]"},
	{"iSYTime","INT"},--剩余时间
	{"iNTList","GameMsg.SZUserInfo[10]"},
};

--无庄等待
GameMsg.Rc_Packet_Wait = {
	{"iNTListCount","INT"},--庄家列表
	{"m_iZhuangBaShu","INT"},--庄家进行了几把
	{"m_iNtWin","LLONG"},--当前庄家赢的金币
	{"iNTList","GameMsg.SZUserInfo[10]"},
};

--路子信息
GameMsg.ResultInfo = {
	{"iWinner","BYTE"},--红赢还是黑赢
	{"iCardShape","BYTE"},--牌型
	
};

--退还下注
GameMsg.Rc_Note_Back = {
	{"bDeskStation","BYTE"},
	{"iUserXiaZhuData","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},
	{"m_iQuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--本把每个区域下的注额
};

--庄家坐庄期间输赢金币
GameMsg.BankGetMonry = {
	{"money","LLONG"},--庄家坐庄期间输赢金币
};

--续投
GameMsg.Cr_Packet_XiaZhuEx = {
	{"money","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},
};

--续投
GameMsg.Rc_Packet_XiaZhuResultEx = {
	{"station","BYTE"},
	{"money","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},
	{"iQuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},
};

function GameMsg.init()

end

return GameMsg;
