local GameMsg = { 
	-- //文件名字定义
	GAMENAME                   	=     "斗地主",

	-- //游戏状态
	GS_FREE						=	25,								--//等待开始
	GS_SENDCARD					=   26,								--//发牌
	GS_PLAYING                  =   27,								--//各玩家进行打牌状态
	GAME_SCENE_FREE				=	GS_FREE,					--//等待开始
	GAME_SCENE_CALL				=	GS_PLAYING,					--//叫分状态
	GAME_SCENE_ROBNT			=	GS_PLAYING,					--//叫地主状态
	GAME_SCENE_DOUBLE			=	28,--GS_PLAYING+1,					--//加倍状态
	GAME_SCENE_PLAY				=	29,--GS_PLAYING+1,					--//游戏进行

	--//服务器命令结构

	SUPER_PLAYER                =    10,              --//超级玩家
	INVALID_CHAIR				=	255,				--//无效椅子

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

	REVENUE 						=5,

	--//数目定义
	MAX_COUNT					=20,									--//最大数目
	FULL_COUNT					=54,									--//全牌数目

	--//逻辑数目
	NORMAL_COUNT				=17,									--//常规数目
	DISPATCH_COUNT				=51,									--//派发数目
	GOOD_CARD_COUTN				=38,									--//好牌数目

	--//数值掩码
	MASK_COLOR					=0xF0,								--//花色掩码
	MASK_VALUE					=0x0F,								--//数值掩码

	--//逻辑类型
	CT_ERROR					=0,									--//错误类型
	CT_SINGLE					=1,									--//单牌类型
	CT_DOUBLE					=2,									--//对牌类型
	CT_THREE					=3,									--//三条类型
	CT_SINGLE_LINE				=4,									--//单连类型
	CT_DOUBLE_LINE				=5,									--//对连类型
	CT_THREE_LINE				=6,									--//三连类型--飞机
	CT_THREE_TAKE_ONE			=7,									--//三带一单
	CT_THREE_TAKE_TWO			=8,									--//三带一对
	CT_FOUR_TAKE_ONE			=9,									--//四带两单
	CT_FOUR_TAKE_TWO			=10,									--//四带两对
	CT_BOMB_CARD				=11,									--//炸弹类型
	CT_MISSILE_CARD				=12,									--//火箭类型 

	--//命令定义
	SUB_S_GAME_START			=100,									--//游戏开始
	SUB_S_CALL_SCORE			=101,									--//用户叫分
	SUB_S_BANKER_INFO			=102,									--//庄家信息
	SUB_S_OUT_CARD				=103,									--//用户出牌
	SUB_S_PASS_CARD				=104,									--//用户放弃
	SUB_S_GAME_CONCLUDE			=105,									--//游戏结束
	SUB_S_TRUSTEE				=106,									--//用户托管
	SUB_S_DOUBLE				=107,									--//用户加倍
	SUB_S_NOCARD				=108,									--//用户要不起
	SUB_S_ROB_NT				=110,									--//叫地主
	SUB_S_SEND_CARD				=111,									--//发牌

	--//命令定义
	SUB_C_CALL_SCORE			=101,									--//用户叫分
	SUB_C_OUT_CARD				=102,									--//用户出牌
	SUB_C_PASS_CARD				=103,									--//用户放弃
	SUB_C_TRUSTEE				=104,									--//用户托管
	SUB_C_DOUBLE				=105,									--//用户加倍
	SUB_C_ROB_NT				=106,									--//用户叫地主
}


--//没有玩家在桌的通知
GameMsg.TNoPlayer=
{
    {"bGameFinished","BOOL"},								--//桌子已散掉
};

--//玩家强退的报告包，服务器给客户端的
GameMsg.TQuitInfo=
{
    {"byUser","BYTE"},								--//退出的玩家0未知类型1强退
};


--//断线数据结构
GameMsg.bCutStruct=
{
    {"bDeskStation","BYTE"},
    {"bCut","BOOL"},
};

GameMsg.HaveThingStruct=
{
	{"pos","BYTE"},
	{"szMessage","CHARSTRING[61]"},--//
    {"bAgreeLeft","INT["..PLAY_COUNT.."]"},
    {"nWaitTime","INT"},--等待同意时间
};

GameMsg.LeaveResultStruct=
{
	{"bDeskStation","BYTE"},
	{"bArgeeLeave","INT"},
};

--//积分信息
GameMsg.tagScoreInfo=
{
	{"lScore","LLONG"},--用户分数
	{"lGrade","LLONG"},--用户成绩
	{"lRevenue","LLONG"},--游戏税收
};
	
--//空闲状态
GameMsg.CMD_S_StatusFree=
{
	--//游戏属性
	{"lCellScore","INT"},--基础积分

	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
	{"bAgree","BOOL["..PLAY_COUNT.."]"},--//准备信息
};

--//发牌状态
GameMsg.CMD_S_StatusSend=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏信息
	{"lCellScore","INT"},--单元积分
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbScoreInfo","BYTE["..PLAY_COUNT.."]"},--叫分信息
	{"cbHandCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--手上扑克

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
};

--//叫分状态
GameMsg.CMD_S_StatusCall=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏信息
	{"lCellScore","INT"},--单元积分
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbScoreInfo","BYTE["..PLAY_COUNT.."]"},--叫分信息
	{"cbHandCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--手上扑克

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
};

--叫地主状态
GameMsg.CMD_S_StatusRobNT=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏信息
	{"lCellScore","INT"},--单元积分
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--抢地主倍数
	{"iRobNTStat","INT["..PLAY_COUNT.."]"},--叫地主信息
	{"cbHandCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--手上扑克

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
}

--//加倍状态
GameMsg.CMD_S_StatusDouble=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	{"lCellScore","INT"},--单元积分
	{"wBankerUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbScoreInfo","BYTE["..PLAY_COUNT.."]"},--叫分信息
	{"cbHandCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--手上扑克

	{"cbUserDouble","BYTE["..PLAY_COUNT.."]"},--玩家加倍

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
	{"cbBankerCard","BYTE[3]"},--//胜利玩家
};

--//游戏状态
GameMsg.CMD_S_StatusPlay=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏变量
	{"lCellScore","INT"},--单元积分
	{"cbBombCount","BYTE"},--炸弹次数
	{"wBankerUser","WORD"},--//庄家用户
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	
	--//出牌信息
	{"wTurnWiner","WORD"},--//胜利玩家
	{"cbTurnCardCount","BYTE"},--出牌数目
	{"cbTurnCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--出牌数据

	--//扑克信息
	{"cbBankerCard","BYTE[3]"},--//胜利玩家
	{"cbHandCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--手上扑克
	{"cbHandCardCount","BYTE["..PLAY_COUNT.."]"},--扑克数目

    --//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息

	{"cbUserDouble","BYTE["..PLAY_COUNT.."]"},--玩家加倍

	{"cbSecondTurnCardCount","BYTE["..PLAY_COUNT.."]"},--//出牌数目
	{"cbSecondTurnCardData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--出牌数据
	{"cbDistributing","BYTE[15]"},--//出牌数目	

};


--//游戏开始
GameMsg.CMD_S_GameStart=
{
	{"wStartUser","WORD"},--//开始玩家
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbValidCardData","BYTE"},--明牌扑克
	{"cbValidCardIndex","BYTE"},--明牌位置
	{"cbCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--扑克列表
};

--//发送扑克
GameMsg.CMD_S_SendCard=
{
	{"cbValidCardData","BYTE"},--明牌扑克
	{"cbValidCardIndex","BYTE"},--明牌位置
	{"cbCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--扑克列表
};

--//机器人扑克
GameMsg.CMD_S_AndroidCard=
{
	{"cbHandCard","BYTE["..PLAY_COUNT.."]["..GameMsg.NORMAL_COUNT.."]"},--手上扑克
	{"wCurrentUser","WORD"},--//当前玩家
};

--//作弊扑克
GameMsg.CMD_S_CheatCard=
{
	{"wCardUser","WORD["..PLAY_COUNT.."]"},--作弊玩家
	{"cbUserCount","BYTE"},--作弊数量
	{"cbCardData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--扑克列表
	{"cbCardCount","BYTE["..PLAY_COUNT.."]"},--扑克数量
};
--//用户叫分
GameMsg.CMD_S_CallScore=
{
	{"wCurrentUser","WORD"},--//当前玩家
	{"wCallScoreUser","WORD"},--//叫分玩家
	{"cbCurrentScore","BYTE"},--当前叫分
	{"cbUserCallScore","BYTE"},--上次叫分
};

--//庄家信息
GameMsg.CMD_S_BankerInfo=
{
	{"wBankerUser","WORD"},--//庄家用户
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbBankerCard","BYTE[3]"},--庄家扑克
};

--//用户出牌
GameMsg.CMD_S_OutCard=
{
	{"cbCardCount","BYTE"},--出牌数目
	{"wCurrentUser","WORD"},--当前玩家 
	{"wOutCardUser","WORD"},--出牌玩家
	{"cbCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--扑克列表
};

--//放弃出牌
GameMsg.CMD_S_PassCard=
{
	{"cbTurnOver","BYTE"},--一轮结束
	{"wCurrentUser","WORD"},--当前玩家 
	{"wPassCardUser","WORD"},--放弃玩家
};

--//游戏结束
GameMsg.CMD_S_GameConclude=
{
	--//积分变量
	{"lCellScore","INT"},--单元积分
	{"lGameScore","LLONG["..PLAY_COUNT.."]"},--游戏积分


	--//春天标志
	{"bChunTian","BYTE"},--春天标志
	{"bFanChunTian","BYTE"},--春天标志

	--//炸弹信息
	{"cbBombCount","BYTE"},--炸弹次数
	{"cbBombCount","BYTE["..PLAY_COUNT.."]"},--炸弹个数

	--//游戏信息
	{"cbBankerScore","BYTE"},--叫分数目
	{"cbCardCount","BYTE["..PLAY_COUNT.."]"},--扑克数目
	{"cbHandCardData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--扑克列表
	{"bHaveAction","BOOL"},	-- 本局是否有操作
};

GameMsg.CMD_S_TRUSTEE =
{
	{"wCurrentUser","WORD"},--当前玩家
	{"bTrustee","BOOL"},--是否托管
};

GameMsg.CMD_S_DOUBLE = 
{
	{"wCurrentUser","WORD"},--当前玩家
	{"bDouble","BOOL"},--是否加倍
	{"wBankUser","WORD"},--下个出牌玩家
};

GameMsg.CMD_S_NOCARD = 
{
	{"wCurrentUser","WORD"},--当前玩家
};




--//用户叫分
GameMsg.CMD_C_CallScore=
{
	{"cbCallScore","BYTE"},--叫分数目
};

--//用户出牌
GameMsg.CMD_C_OutCard =
{
	{"cbCardCount","BYTE"},--出牌数目
	{"cbCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--扑克数据
};

GameMsg.CMD_C_Double = 
{
	{"cbDouble","BOOL"},--是否加倍
};

GameMsg.CMD_S_RobNT = 
{
	{"wRobUser","WORD"},--叫地主玩家
	{"iRobStat","INT"},--叫地主状态
	{"wCurrentUser","WORD"},--当前玩家
	{"bFirstRob","BOOL"},--第一个叫地主
};

GameMsg.CMD_C_RobNT = 
{
	{"bRobNT","BOOL"},--叫地主
};



function  GameMsg.init()
	
GameMsg.HaveThingStruct=
{
	{"pos","BYTE"},
	{"szMessage","CHARSTRING[61]"},--//
    {"bAgreeLeft","INT["..PLAY_COUNT.."]"},
    {"nWaitTime","INT"},--等待同意时间
};

GameMsg.LeaveResultStruct=
{
	{"bDeskStation","BYTE"},
	{"bArgeeLeave","INT"},
};

--//积分信息
GameMsg.tagScoreInfo=
{
	{"lScore","LLONG"},--用户分数
	{"lGrade","LLONG"},--用户成绩
	{"lRevenue","LLONG"},--游戏税收
};
	
--//空闲状态
GameMsg.CMD_S_StatusFree=
{
	--//游戏属性
	{"lCellScore","INT"},--基础积分

	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
	{"bAgree","BOOL["..PLAY_COUNT.."]"},--//准备信息
};

--//发牌状态
GameMsg.CMD_S_StatusSend=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏信息
	{"lCellScore","INT"},--单元积分
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbScoreInfo","BYTE["..PLAY_COUNT.."]"},--叫分信息
	{"cbHandCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--手上扑克

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
};

--//叫分状态
GameMsg.CMD_S_StatusCall=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏信息
	{"lCellScore","INT"},--单元积分
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbScoreInfo","BYTE["..PLAY_COUNT.."]"},--叫分信息
	{"cbHandCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--手上扑克

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
};

--叫地主状态
GameMsg.CMD_S_StatusRobNT=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏信息
	{"lCellScore","INT"},--单元积分
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--抢地主倍数
	{"iRobNTStat","INT["..PLAY_COUNT.."]"},--叫地主信息
	{"cbHandCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--手上扑克

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
}

--//加倍状态
GameMsg.CMD_S_StatusDouble=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	{"lCellScore","INT"},--单元积分
	{"wBankerUser","WORD"},--//当前庄家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbScoreInfo","BYTE["..PLAY_COUNT.."]"},--叫分信息
	{"cbHandCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--手上扑克

	{"cbUserDouble","BYTE["..PLAY_COUNT.."]"},--玩家加倍

	--//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
	{"cbBankerCard","BYTE[3]"},--//胜利玩家
};

--//游戏状态
GameMsg.CMD_S_StatusPlay=
{
	--//时间信息
	{"cbTimeOutCard","BYTE"},--出牌时间
	{"cbTimeCallScore","BYTE"},--叫分时间
	{"cbTimeStartGame","BYTE"},--开始时间
	{"cbTimeHeadOutCard","BYTE"},--首出时间

	--//游戏变量
	{"lCellScore","INT"},--单元积分
	{"cbBombCount","BYTE"},--炸弹次数
	{"wBankerUser","WORD"},--//庄家用户
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	
	--//出牌信息
	{"wTurnWiner","WORD"},--//胜利玩家
	{"cbTurnCardCount","BYTE"},--出牌数目
	{"cbTurnCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--出牌数据

	--//扑克信息
	{"cbBankerCard","BYTE[3]"},--//胜利玩家
	{"cbHandCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--手上扑克
	{"cbHandCardCount","BYTE["..PLAY_COUNT.."]"},--扑克数目

    --//历史积分
	{"lTurnScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"lCollectScore","LLONG["..PLAY_COUNT.."]"},--积分信息
	{"cbTrustee","BOOL["..PLAY_COUNT.."]"},--//托管信息
	{"cbUserDouble","BYTE["..PLAY_COUNT.."]"},--玩家加倍

	{"cbSecondTurnCardCount","BYTE["..PLAY_COUNT.."]"},--//出牌数目
	{"cbSecondTurnCardData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--出牌数据
	{"cbDistributing","BYTE[15]"},--//出牌数目
};


--//游戏开始
GameMsg.CMD_S_GameStart=
{
	{"wStartUser","WORD"},--//开始玩家
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbValidCardData","BYTE"},--明牌扑克
	{"cbValidCardIndex","BYTE"},--明牌位置
	{"cbCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--扑克列表
};

--//发送扑克
GameMsg.CMD_S_SendCard=
{
	{"cbValidCardData","BYTE"},--明牌扑克
	{"cbValidCardIndex","BYTE"},--明牌位置
	{"cbCardData","BYTE["..GameMsg.NORMAL_COUNT.."]"},--扑克列表
};

--//机器人扑克
GameMsg.CMD_S_AndroidCard=
{
	{"cbHandCard","BYTE["..PLAY_COUNT.."]["..GameMsg.NORMAL_COUNT.."]"},--手上扑克
	{"wCurrentUser","WORD"},--//当前玩家
};

--//作弊扑克
GameMsg.CMD_S_CheatCard=
{
	{"wCardUser","WORD["..PLAY_COUNT.."]"},--作弊玩家
	{"cbUserCount","BYTE"},--作弊数量
	{"cbCardData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--扑克列表
	{"cbCardCount","BYTE["..PLAY_COUNT.."]"},--扑克数量
};
--//用户叫分
GameMsg.CMD_S_CallScore=
{
	{"wCurrentUser","WORD"},--//当前玩家
	{"wCallScoreUser","WORD"},--//叫分玩家
	{"cbCurrentScore","BYTE"},--当前叫分
	{"cbUserCallScore","BYTE"},--上次叫分
};

--//庄家信息
GameMsg.CMD_S_BankerInfo=
{
	{"wBankerUser","WORD"},--//庄家用户
	{"wCurrentUser","WORD"},--//当前玩家
	{"cbBankerScore","BYTE"},--庄家叫分
	{"cbBankerCard","BYTE[3]"},--庄家扑克
};

--//用户出牌
GameMsg.CMD_S_OutCard=
{
	{"cbCardCount","BYTE"},--出牌数目
	{"wCurrentUser","WORD"},--当前玩家 
	{"wOutCardUser","WORD"},--出牌玩家
	{"cbCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--扑克列表
};

--//放弃出牌
GameMsg.CMD_S_PassCard=
{
	{"cbTurnOver","BYTE"},--一轮结束
	{"wCurrentUser","WORD"},--当前玩家 
	{"wPassCardUser","WORD"},--放弃玩家
};

--//游戏结束
GameMsg.CMD_S_GameConclude=
{
	--//积分变量
	{"lCellScore","INT"},--单元积分
	{"lGameScore","LLONG["..PLAY_COUNT.."]"},--游戏积分


	--//春天标志
	{"bChunTian","BYTE"},--春天标志
	{"bFanChunTian","BYTE"},--春天标志

	--//炸弹信息
	{"cbBombCount","BYTE"},--炸弹次数
	{"cbBombCount","BYTE["..PLAY_COUNT.."]"},--炸弹个数

	--//游戏信息
	{"cbBankerScore","BYTE"},--叫分数目
	{"cbCardCount","BYTE["..PLAY_COUNT.."]"},--扑克数目
	{"cbHandCardData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"},--扑克列表
	{"bHaveAction","BOOL"},	-- 本局是否有操作
};

GameMsg.CMD_S_TRUSTEE =
{
	{"wCurrentUser","WORD"},--当前玩家
	{"bTrustee","BOOL"},--是否托管
};

GameMsg.CMD_S_DOUBLE = 
{
	{"wCurrentUser","WORD"},--当前玩家
	{"bDouble","BOOL"},--是否加倍
	{"wBankUser","WORD"},--下个出牌玩家
};

GameMsg.CMD_S_NOCARD = 
{
	{"wCurrentUser","WORD"},--当前玩家
};

--//用户叫分
GameMsg.CMD_C_CallScore=
{
	{"cbCallScore","BYTE"},--叫分数目
};

--//用户出牌
GameMsg.CMD_C_OutCard=
{
	{"cbCardCount","BYTE"},--出牌数目
	{"cbCardData","BYTE["..GameMsg.MAX_COUNT.."]"},--扑克数据
};


GameMsg.CMD_C_Double = 
{
	{"cbDouble","BOOL"},--是否加倍
};

GameMsg.CMD_S_RobNT = 
{
	{"wRobUser","WORD"},--叫地主玩家
	{"iRobStat","INT"},--叫地主状态
	{"wCurrentUser","WORD"},--当前玩家
	{"bFirstRob","BOOL"},--第一个叫地主
};

GameMsg.CMD_C_RobNT = 
{
	{"bRobNT","BOOL"},--叫地主
};

end




return GameMsg;