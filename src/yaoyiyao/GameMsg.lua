local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "摇一摇",
	NOTE_TYPE_COUNT 			=		52,


	GS_WAIT_SETGAME				=	0,				--等待东家设置状态
	GS_WAIT_AGREE				=	1,				--等待同意设置
	GS_XIAZHU_TIME				=	21,				--下注状态
	GS_PLAY_GAME				=	22,				--开牌状态
	GS_WAIT_NEXT				=	23,				--等待下一盘开始



	ASS_SUPER_SETTING           =	150,             	--由客户端发送消息控制本局输赢
	ASS_SUPER_STATE             =   151,             	--通知客户端是否为超级状态

	--消息ID
	ASS_CUT_END				  	=	103,		 		--用户强行离开
	ASS_SAFE_END			  	=	104,		 		--用户安全结束

	ASS_TRUSTEE               	=	110,        		--托管
	ASS_HAVE_THING            	=	120,        		--有事要走消息
	ASS_USER_AGREE_LEAVE      	=	121,        		--有事要走消息答复结果

	ASS_XIA_ZHU               	=	130,        		--下注消息
	ASS_GAME_ANIMATE          	=	131,        		--动画消息
	ASS_SHOW_RESULT           	=	133,        		--显示结算信息时间
	ASS_DENG_DAI              	=	134,        		--等待消息
	ASS_SHANG_ZHUANG          	=	135,        		--上庄消息
	ASS_SB_BEGIN              	=	136,        		--百家乐开始消息
	ASS_WU_ZHUANG             	=	137,       			--游戏无庄闲置消息消息
	ASS_ZHUANG_MSG            	=	138,         		--庄信息
	ASS_ERROR_CODE			  	=	139,				--错误信息
	ASS_NOTE_BACK				=	155,				--退还下注


	ASS_XIA_ZHU_FULL			=	153,				--下注已满消息 add xyh 2011-12-12
	ASS_CHANGE_NT				=	154,				--换庄消息 add xyh 2011-12-12

	ASS_USER_CUT                 =   82,              --//玩家断线了

	ASS_ZHUANG_SCORE			=	140,				--庄家坐庄期间输赢金币
	ASS_XIA_ZHU_EX				=	141,				--续投

}

--游戏开始信息
GameMsg.tagBeginData = {
	{"iNTListCount","INT"},--庄家列表的位置
	{"m_iResultInfo","SHORT[30][4]"},--最近72把的信息
	{"m_iBaSHu","INT"},--本局（30把一局）进行的把数
	{"m_iZhuangBaShu","INT"},--庄家进行了几把
	{"m_iNowNtStation","BYTE"},--当前庄家的位置
	{"m_iGameCount","INT"},--当前已经进行了几把

	{"m_iXiaZhuTime","INT"},--下注时间
	{"m_iAnimateTime","INT"},--动画时间
	{"m_iKaiPaiTime","INT"},--开牌时间
	{"m_iFreeTime","INT"},--空闲时间

	{"bPlayerInList","BOOL"},--是否有非机器人玩家在庄家列表中
	{"m_iShangZhuangLimit","LLONG"},--上庄需要的最少金币
	{"m_iNTdata","LLONG[4]"},--庄家的位置,总分（当前金币数），成绩(赢的总金币)，局数（坐庄的局数）
	{"iNTList","GameMsg.SZUserInfo[10]"},
};
--下注
GameMsg.Cr_Packet_XiaZhu = {
	{"m_bNoteByRobot","BOOL"},--是否是机器人下注
	{"money","INT"},--金额
	{"type","INT"},--下注区域0-7
	{"moneytype","INT"},--筹码类型：1：百，2：千，3：万，4：十万，5：百万，6：五百万
};
--下注结果
GameMsg.Rc_Packet_XiaZhuResultss = {
	{"m_bNoteByRobot","BOOL"},--是否是机器人下注
	{"station","BYTE"},--位置
	{"money","INT"},--金额
	{"type","INT"},--下注小区域
	{"moneytype","INT"},--筹码类型：1：百，2：千，3：万，4：十万，5：百万，6：五百万
	{"m_iZhongZhu","LLONG"},--本把当前总注额
	{"m_iQuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--本把每个区域下的注额
	{"m_iNoteByRobot","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--机器人下注
	{"xyPoint","INT[2]"},--区域xy
};
--发送上庄
GameMsg.Cr_ShangZhuang = {
	{"bCancel","BOOL"},--上下庄取消
	{"shang","BOOL"},--true为上庄，false 为下庄
	{"bIsRobot","BOOL"},--是否为机器人
};
--上庄数据包
GameMsg.tagShangZhuang = {
	{"iNTListCount","INT"},--庄家列表
	{"shang","BOOL"},--true为上庄，false 为下庄
	{"success","INT"},--是否失败 0上下庄失败 1金币不足 2成为庄操作 3加入申请列表的操作
	{"station","BYTE"},--申请的位置

	{"iLimitmoney","LLONG"},--上庄最少金币数
	{"bCancel","BOOL"},--取消操作

	{"bIsRobot","BOOL"},--是否为机器人
	{"iNTList","GameMsg.SZUserInfo[10]"},
};
--上庄列表信息
GameMsg.tagZhuangMsg = {
	{"iNowNtStation","BYTE"},--当前的庄家
	{"iNTListCount","INT"},--庄家列表
	{"iNTList","GameMsg.SZUserInfo[10]"},
};
--发送骰子数据包
GameMsg.SendSeziStruct = {
	{"one","BYTE"},--1点的数目
	{"two","BYTE"},--2点的数目
	{"three","BYTE"},--3点的数目
	{"four","BYTE"},--4点的数目
	{"five","BYTE"},--5点的数目
	{"six","BYTE"},--6点的数目
};
--断线重连数据包
GameMsg.tagChongLian = {
	{"bNoDisplyRobotNote","BOOL"},--是否不显示机器人下的注
	{"bIsVipDouble","BOOL"},--是否为机器人双倍下注房间

	{"iNTListCount","INT"},--庄家列表
	{"ZhuangStatus","INT"},--玩家庄状态
	{"iResultInfo","SHORT[30][4]"},--最近30局的信息
	{"iWinner","INT"},--赢家1 庄，2闲，3和，本赢方
	{"iKaiPai","INT"},--本把开牌区域：1庄，2庄天王，3庄对子，4闲，5闲天王，6闲对子，和，同点和
	{"iBaSHu","INT"},--本局（30把一局）进行的把数
	{"iZhuangBaShu","INT"},--庄家进行了几把
	{"iNowNtStation","BYTE"},--当前庄家的位置
	{"itempNtStation","BYTE"},--临时庄家
	{"iGameCount","INT"},--当前已经进行了几把
	{"iSYTime","INT"},--剩余时间
	{"iCurMessage","INT"},--当前要处理的消息

	{"iXiaZhuTime","INT"},--下注时间
	{"iAnimateTime","INT"},--动画时间
	{"iKaiPaiTime","INT"},--开牌时间
	{"iFreeTime","INT"},--空闲时间
	{"iSendInterval","INT"},--发牌间隔时间

	{"i64ShangZhuangLimit","LLONG"},--上庄需要的最少金币
	{"iXiaZhuangLimit","LLONG"},--下庄限制
	{"i64ZhongZhu","LLONG"},--本把当前总注额
	{"i64QuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--本把每个区域下的注额
	{"i64myZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--自己下的注
	{"iNTdata","LLONG[4]"},--庄家的位置,总分（当前金币数），成绩(赢的总金币)，局数（坐庄的局数）
	{"i64ZhuangFen","LLONG"},--庄家的得分
	{"i64XianFen","LLONG"},--闲家的得分
	{"i64UserFen","LLONG"},--当前玩家的得分
	{"i64MaxNote","LLONG"},--最大下注
	{"i64GameMaxNote","LLONG"},--游戏的最大下注
	{"i64NoteByRobot","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},--机器人下的注

	{"iSaiZiRecord","GameMsg.SendSeziStruct"},--记录五个方位的值
	{"iNTList","GameMsg.SZUserInfo[10]"},
	{"bEnableSysBanker","BOOL"},--系统坐庄
};
--无庄等待
GameMsg.Rc_Packet_Wait = {
	{"iNTListCount","INT"},--庄家列表
	{"m_iZhuangBaShu","INT"},--庄家进行了几把
	{"m_iNtWin","LLONG"},--当前庄家赢的金币
	{"iNTList","GameMsg.SZUserInfo[10]"},
};
--摇骰子结果
GameMsg.Rc_Packet_CompareResult = {
	{"iNTListCount","INT"},--庄家列表
	{"iResultInfo","SHORT[30][4]"},--游戏信息--1把数2各点数3点数和4大小
	{"iWinQuYu","INT["..GameMsg.NOTE_TYPE_COUNT.."]"},--游戏的赢钱区域
	{"iUserScore","LLONG"},--玩家本局得分
	{"iNTScore","LLONG"},--庄家得分
	{"iOtherScore","LLONG"},--闲家得分,排除庄家和自己
	{"iUserReturnTotle","LLONG"},--玩家总下注
	{"iUserTotalNote","LLONG"},--玩家输赢金币

	{"iSaiZiRecord","GameMsg.SendSeziStruct"},--记录五个方位的值
	{"nWinTime","INT"},									--//连胜局数
	{"iNTList","GameMsg.SZUserInfo[10]"},
};
--庄家信息
GameMsg.SZUserInfo = {
	{"station","BYTE"},--庄家位置
	{"i64Money","LLONG"},--庄家金币
};

--错误信息
GameMsg.Rc_ErrorCode = {
	{"errorCode","INT"},--错误信息
};
--//断线数据结构
GameMsg.bCutStruct = {
	{"bDeskStation","BYTE"},
	{"bCut","BOOL"},
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
	{"m_iZhongZhu","LLONG"},
	{"iQuYuZhu","LLONG["..GameMsg.NOTE_TYPE_COUNT.."]"},
};

function GameMsg.init()

end

return GameMsg;
