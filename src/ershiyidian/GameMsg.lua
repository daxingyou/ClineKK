local GameMsg = { 

SUPER_PLAYER                    =10,                --//超级玩家
INVALID_CHAIR					=255,				--//无效椅子
--//文件名字定义
GAMENAME                        ="21点",
--//游戏状态
GS_FREE							=25,								--//等待开始
GS_PLAYING                      =26,								--//各玩家进行打牌状态
GAME_SCENE_FREE					=25,					        	--//等待开始
GAME_SCENE_ADD_SCORE			=26,					    		--//叫分状态
GAME_SCENE_INSURE				=26+1,					    		--//保险状态
GAME_SCENE_GET_CARD				=26+2,					   			--//加倍状态
GS_TH_QIANG						=26+3,								--抢庄状态
GS_TK_BEGIN						=30,								--特效
MAX_COUNT					    =11,								--//最大数目
FULL_COUNT					    =52,								--//扑克数目

--//游戏信息
GAME_PLAYER						=5,							     	--//游戏人数
NAME_ID                         =40026000,                  		--//名字 ID
PLAY_COUNT                      =5,               					--//游戏人数

-- //******************************************************************************************
-- //数据包处理辅助标识
-- //******************************************************************************************

--//异常类消息
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





--//////////////////////////////////////////////////////////////////////////////////


--//服务器命令结构
 SUB_S_GAME_START				=100,						--//游戏开始
 SUB_S_GAME_END					=101,						--//游戏结束
 SUB_S_SEND_CARD				=102,						--//发牌
 SUB_S_SPLIT_CARD				=103,						--//分牌
 SUB_S_STOP_CARD				=104,						--//停牌
 SUB_S_DOUBLE_SCORE				=105,						--//加倍
 SUB_S_INSURE					=106,						--//保险
 SUB_S_ADD_SCORE				=107,						--//下注
 SUB_S_GET_CARD					=108,						--//要牌
 SUB_S_BANKER_CARD				=109,						--//庄家的牌
 SUB_S_NO_ACTION				=110,						--//玩家未操作
 SUB_S_QIANG					=113,						--//玩家抢庄
 SUB_S_BEGIN					=112,						--//开始抢庄
 SUB_S_GIVE_UP_BANK			    =114,						--//放弃庄
 SUB_S_BANK_USER				=115,						--//通知庄家
 SUB_S_BEGIN_TX            		=116,						--特效


 --//////////////////////////////////////////////////////////////////////////
--//客户端命令结构

SUB_C_ADD_SCORE					=101,									--//用户加注
SUB_C_GET_CARD					=102,									--//要牌
SUB_C_DOUBLE_SCORE				=103,									--//加倍
SUB_C_INSURE					=104,									--//保险
SUB_C_SPLIT_CARD				=105,									--//分牌
SUB_C_STOP_CARD					=106,									--//放弃跟注
SUB_C_Continue					=107,			  						--//继续游戏
SUB_C_QIANG				        =108,									--//抢庄
SUB_C_GIVE_UP_BANK		        =109,									--//放弃庄
}


--//没有玩家在桌的通知
GameMsg.TNoPlayer = 
{
    {"bGameFinished","BOOL"}  --//桌子已散掉
};

--//玩家强退的报告包，服务器给客户端的
GameMsg.TQuitInfo = 
{
    -- enum emType
    -- {
    --     UNKNOWN     = 0,    //未知类型
    --     FORCE       = 1,    //强退
    -- } nType;
    {"nType","INT"},
    {"byUser","BYTE"},  --//退出的玩家
};


--//断线数据结构
GameMsg.bCutStruct = 
{
    {"bDeskStation","BYTE"},
    {"bCut","BOOL"}, 
};

GameMsg.HaveThingStruct = 
{
    {"pos","BYTE"}, 
    {"szMessage","CHARSTRING[61]"},
    {"bAgreeLeft","INT["..GameMsg.PLAY_COUNT.."]"},
	{"nWaitTime","INT"}, 				--//等待同意时间
};

GameMsg.LeaveResultStruct = 
{
    {"bDeskStation","BYTE"},
    {"bArgeeLeave","INT"},
};


--/////////////////////////////////////////////////////分界线
--//积分信息
GameMsg.tagScoreInfo = 
{
	{"lScore","LLONG"},										--//用户分数
	{"lGrade","LLONG"},										--//用户成绩
	{"lRevenue","LLONG"},									--//游戏税收
};




--//游戏状态
GameMsg.CMD_S_StatusFree = 
{
	{"lCellScore","LLONG"},									--//单元注数
	{"lMaxScore","LLONG"},									--//最大注数
	{"bGiveUp","BOOL"},							
	{"bShowGiveUp","BOOL"},							
};

--//抢庄状态
GameMsg.CMD_S_StatusQiang = 
{
	--//单元积分
	{"lCellScore","LLONG"},									--//单元注数
	{"lMaxScore","LLONG"},									--//最大注数
	{"bUserStatus","BOOL["..GameMsg.GAME_PLAYER.."]"},		--//用户状态
	{"bQiang","BYTE["..GameMsg.GAME_PLAYER.."]"},							
	{"iLeftTime","INT"},                             		--//剩余时间
};
--//游戏状态
GameMsg.CMD_S_StatusAddScore = 
{
	{"lCellScore","LLONG"},									--//单元注数
	{"lMaxScore","LLONG"},									--//最大注数
	{"wBankerChair","WORD"},								--庄家
	{"lTableScore","LLONG["..GameMsg.GAME_PLAYER.."]"},		--//桌面下注
	{"bUserStatus","BOOL["..GameMsg.GAME_PLAYER.."]"},		--//用户状态
	{"dwTimerLeftMS","WORD"},								--剩余秒数

};
--//保险状态
GameMsg.CMD_S_StatusInsure = 
{
	{"lCellScore","LLONG"},									--//单元注数
	{"lMaxScore","LLONG"},									--//最大注数
	{"bUserStatus","BOOL["..GameMsg.GAME_PLAYER.."]"},		--//用户状态
	
	{"cbCurrentUser","BYTE"},								
	{"wBankerChair","WORD"},								--庄家
	{"lTableScore","LLONG["..GameMsg.GAME_PLAYER.."]"},		--//桌面下注
	{"cbCardCount","BYTE["..2*GameMsg.GAME_PLAYER.."]"},	--//扑克数目
	{"cbHandCardData","BYTE["..2*GameMsg.GAME_PLAYER.."]["..GameMsg.MAX_COUNT.."]"},--//桌面扑克
	{"bInsureCard","BYTE["..2*GameMsg.GAME_PLAYER.."]"},							--//玩家下保险
	--{"cbBankerCardData","BYTE["..GameMsg.MAX_COUNT.."]"},						    --//庄家扑克
	--{"cbBankerCardCount","BYTE"},													--//庄家扑克数
	{"dwTimerLeftMS","WORD"},														--剩余秒数
};
--//游戏状态
GameMsg.CMD_S_StatusGetCard = 
{
	{"lCellScore","LLONG"},															--//单元注数
	{"lMaxScore","LLONG"},															--//最大注数
	{"bUserStatus","BOOL["..GameMsg.GAME_PLAYER.."]"},								--//用户状态

	{"lTableScore","LLONG["..GameMsg.GAME_PLAYER.."]"},								--//桌面下注

	--//扑克信息
	{"cbCardCount","BYTE["..2*GameMsg.GAME_PLAYER.."]"},							--//扑克数目
	{"cbHandCardData","BYTE["..2*GameMsg.GAME_PLAYER.."]["..GameMsg.MAX_COUNT.."]"},--//桌面扑克

	{"bStopCard","BYTE["..2*GameMsg.GAME_PLAYER.."]"},								--//玩家停牌
	{"bDoubleCard","BYTE["..2*GameMsg.GAME_PLAYER.."]"},							--//玩家加倍
	{"bInsureCard","BYTE["..2*GameMsg.GAME_PLAYER.."]"},							--//玩家下保险
	--{"cbBankerCardData","BYTE["..GameMsg.MAX_COUNT.."]"},							--//庄家扑克
	--{"cbBankerCardCount","BYTE"},													--//庄家扑克数
	{"cbCurrentUser","BYTE"},														--当前玩家
	{"wBankerChair","WORD"},														--庄家
	{"dwTimerLeftMS","WORD"},														--剩余秒数
};

--//游戏开始
GameMsg.CMD_S_GameStart = 
{
	--//下注信息
	{"lCellScore","LLONG"},													--//单元下注
	{"lMaxScore","LLONG"},													--//最大下注
	{"bUserStatus","BOOL["..GameMsg.GAME_PLAYER.."]"},						--//用户状态
	{"wBankerUser","WORD"},													--庄家
};

--//下注
GameMsg.CMD_S_AddScore = 
{
	{"wAddScoreUser","WORD"},												--//下注玩家
	{"lAddScore","LLONG"},													--//下注额
};

--//要牌
GameMsg.CMD_S_GetCard = 
{
	{"wGetCardUser","WORD"},												--//要牌玩家
	{"cbCardData","BYTE"},													--//牌数据
	
};

--//发牌
GameMsg.CMD_S_SendCard = 
{
	{"cbHandCardData","BYTE["..GameMsg.GAME_PLAYER.."][2]"},				--//发牌数据
	--{"cbBankerHandCardData","BYTE[2]"},										--//发牌数据
	{"cbCurrentUser","BYTE"}								
};

--//分牌
GameMsg.CMD_S_SplitCard = 
{
	{"wSplitUser","WORD"},													--//分牌玩家
	{"bInsured","BYTE"},													--//是否之前下了保险

	{"lAddScore","LLONG"},													--//加注额
	{"cbCardData","BYTE[2]"},												--//牌数据
};

--//停牌
GameMsg.CMD_S_StopCard = 				
{
	{"wStopCardUser","WORD"},												--//停牌玩家
	{"bTurnBanker","BYTE"},													--//是否轮到庄家
	{"cbCurrentUser","BYTE"},								
};

--//加倍
GameMsg.CMD_S_DoubleScore = 
{
	{"wDoubleScoreUser","WORD"},											--//加倍玩家

	{"cbCardData","BYTE"},													--//牌数据
	{"lAddScore","LLONG"},													--//加注额
};

--//保险
GameMsg.CMD_S_Insure = 
{
	{"wInsureUser","WORD"},													--//保险玩家
	{"IsInsure","BOOL"},								
	{"lInsureScore","LLONG"},												--//保险金
	{"IsComplete","BYTE"},	
	{"cbCurrentUser","BYTE"},																		
};

--//游戏结束
GameMsg.CMD_S_GameEnd = 
{
	{"lGameTax","LLONG["..GameMsg.GAME_PLAYER.."]"},						--//游戏税收
	{"lGameScore","LLONG["..GameMsg.GAME_PLAYER.."]"},						--//游戏得分
	--{"cbCardData","BYTE["..2*GameMsg.GAME_PLAYER.."]"},					--//用户扑克
	--{"lBankScore","LLONG"},													--//庄家得分
	{"bShowGiveUp","BOOL"},													--//是否显示弃庄
	{"nWinTime","INT"},									--//连胜局数															
};

GameMsg.CMD_S_BankerCard = 
{
	{"cbBankerHandCardData","BYTE[2]"}										--//发牌数据
};

--//抢庄
GameMsg.CMD_S_Qiang = 
{
	--//状态变量
	{"wChairID","WORD"},    --//当前玩家
	{"bQiang","BOOL"},	    --//抢庄							
							
};
--//放弃抢庄
GameMsg.CMD_S_GIVE_UP_BANK = 
{
	--//状态变量
	{"wChairID","WORD"},	--//当前玩家
	{"bGiveUp","BOOL"},		--//放弃庄
};
--//开始抢庄
GameMsg.CMD_S_BEGIN_BANK = 
{
	--//状态变量
	{"byUserStatus","BYTE["..GameMsg.GAME_PLAYER.."]"},	--//用户状态
};

--//通知庄家
GameMsg.CMD_S_Bank_USER = 
{
	--//状态变量
	{"wChairID","WORD"},    --//当前玩家					
};



--------------------------------客户端结构体---------------------------------------------

--//用户加注
GameMsg.CMD_C_AddScore = 
{
	{"lScore","LLONG"}		--//加注数目
};
--//用户保险
GameMsg.CMD_C_INSURE = 
{
	{"IsInsure","BOOL"}		--//保险
};

--//抢庄
GameMsg.CMD_C_Qiang = 
{
	{"bQiang","BOOL"},		--//抢庄
};
--//放弃庄
GameMsg.CMD_C_GIVE_UP_BANK = 
{
	{"bGiveUp","BOOL"},		--//放弃庄
};




function GameMsg.init()


end

return GameMsg;