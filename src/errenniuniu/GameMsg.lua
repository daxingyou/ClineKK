local GameMsg = { 

--//文件名字定义
GAMENAME                        ="对战牛牛",

SUPER_PLAYER                    =10,              --//超级玩家
INVALID_CHAIR					=255,			 --//无效椅子

--//版本定义
GAME_MAX_VER                    =1,               --//现在最高版本
GAME_LESS_VER                   =1,               --//现在最低版本
GAME_CHANGE_VER                 =0,               --//修改版本

--//游戏开发版本
DEV_HEIGHT_VERSION              =10,              --//内部开发高版本号
DEV_LOW_VERSION                 =1 ,              --//内部开发低版本号

--//支持类型
--SUPPER_TYPE                     =SUP_NORMAL_GAME|SUP_MATCH_GAME|SUP_MONEY_GAME

--//游戏状态
GS_FREE							=25,								--//等待开始
GS_PLAYING                      =26,								--//各玩家进行打牌状态
GS_TK_BEGIN 					=29,								--开始场景消息(只为了播特效)


--//游戏信息
GAME_PLAYER						=2,							--//游戏人数
NAME_ID                         =40021000,        --//名字 ID
PLAY_COUNT                      =2,--GameMsg.GAME_PLAYER,               --//游戏人数
--GET_SERVER_INI_NAME(str)        =sprintf(str,"%s%d_s.ini",CINIFile::GetAppPath(),NAME_ID);
MAX_NAME_INFO                   =256,

--//******************************************************************************************
--//数据包处理辅助标识
--//******************************************************************************************



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

REVENUE						    =5,
MAXCOUNT						=5,									--//扑克数目

--//结束原因
GER_NO_PLAYER					=0x10,								--//没有玩家

--//游戏状态
GS_TK_FREE					=25,								--//等待开始
GS_TK_CALL					=26,								--//叫庄状态
GS_TK_SCORE					=26+1,								--//下注状态
GS_TK_PLAYING				=26+2,								--//游戏进行



--//////////////////////////////////////////////////////////////////////////
--//服务器命令结构

SUB_S_GAME_START				=100,									--//游戏开始
SUB_S_ADD_SCORE					=101,									--//加注结果
SUB_S_SEND_CARD					=103,									--//发牌消息
SUB_S_GAME_END					=104,									--//游戏结束
SUB_S_OPEN_CARD					=105,									--//用户摊牌
SUB_S_CALL_BANKER				=106,									--//用户叫庄
SUB_S_TRUST						=107,									--//用户托管
SUB_S_READY						=108,									--//让用户准备
SUB_S_BEGIN            			=109,									--开始播开始游戏特效


--//////////////////////////////////////////////////////////////////////////
--//客户端命令结构
SUB_C_CALL_BANKER				=101,									--//用户叫庄
SUB_C_ADD_SCORE					=102,									--//用户加注
SUB_C_OPEN_CARD					=103,									--//用户摊牌
SUB_C_TRUST						=104,									--//用户托管

}

GameMsg.CMD_S_READY = 
{
	{"wCurrentUser","WORD"},
};

--//没有玩家在桌的通知
GameMsg.TNoPlayer = 
{
    {"bGameFinished","BOOL"},  --//桌子已散掉

};

--//玩家强退的报告包，服务器给客户端的
GameMsg.TQuitInfo = 
{
    {"byUser","BYTE"} -- //退出的玩家 0未知类型 1强退
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
	{"nWaitTime","INT"},  --//等待同意时间
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
	{"lScore","LLONG"},   						--//用户分数
	{"lGrade","LLONG"},							--//用户成绩
	{"lRevenue","LLONG"},						--//游戏税收
};





--//游戏状态
GameMsg.CMD_S_StatusFree = 
{
	{"wMaxPlayer","WORD"},                                   
	{"lCellScore","LLONG"}, 								--//基础积分
	{"lUserTotalWin","LLONG"}, 								
	{"lUserLastWin","LLONG"},                                
	{"lUserTrust","BOOL["..GameMsg.GAME_PLAYER.."]"}, 									
	{"lUserTrustScore","BYTE["..GameMsg.GAME_PLAYER.."]"},
	{"bFirst","BYTE"},									
	{"bLast","BYTE"},									
 	{"bAgree","BOOL["..GameMsg.GAME_PLAYER.."]"},					
};

--//游戏状态
GameMsg.CMD_S_StatusCall = 
{
	{"wMaxPlayer","WORD"},                    
	{"wCallBanker","WORD"}, 					--//叫庄用户
	{"lUserTotalWin","LLONG"}, 
	{"lUserLastWin","LLONG"}, 
	{"lUserTrust","BOOL["..GameMsg.GAME_PLAYER.."]"}, 
	{"lUserTrustScore","BYTE["..GameMsg.GAME_PLAYER.."]"},
	{"bFirst","BYTE"},									
	{"bLast","BYTE"},
};

--游戏状态
GameMsg.CMD_S_StatusScore = 
{
	{"wMaxPlayer","WORD"},                                    
	--//下注信息
	{"lTurnMaxScore","LLONG"},							--	//最大下注
	--//LONG								lTurnLessScore;	//最小下注
	{"lTableScore","LLONG["..GameMsg.GAME_PLAYER.."]"},		--		//下注数目
	{"wBankerUser","WORD"},				--//庄家用户
	{"lUserTotalWin","LLONG"},								
	{"lUserLastWin","LLONG"},                                
	{"lUserTrust","BOOL["..GameMsg.GAME_PLAYER.."]"},									
	{"lUserTrustScore","BYTE["..GameMsg.GAME_PLAYER.."]"},
	{"bFirst","BYTE"},									
	{"bLast","BYTE"},
	
};

--//游戏状态
GameMsg.CMD_S_StatusPlay = 
{
	{"wMaxPlayer","WORD"},                                    
	--//状态信息
	{"lTurnMaxScore","LLONG"},												--//最大下注
	--//LONG								lTurnLessScore;					--//最小下注
	{"lTableScore","LLONG["..GameMsg.GAME_PLAYER.."]"},							    --//下注数目
	{"wBankerUser","WORD"},													--//庄家用户

	--//扑克信息
	{"cbHandCardData","BYTE["..GameMsg.GAME_PLAYER.."]["..GameMsg.MAXCOUNT.."]"},			--//桌面扑克
	{"bOxCard","BYTE["..GameMsg.GAME_PLAYER.."]"},														--//牛牛数据
	{"lUserTotalWin","LLONG"},							
	{"lUserLastWin","LLONG"},                            
	{"lUserTrust","BOOL["..GameMsg.GAME_PLAYER.."]"},								
	{"lUserTrustScore","BYTE["..GameMsg.GAME_PLAYER.."]"},	
	{"bFirst","BYTE"},									
	{"bLast","BYTE"},							
	
};

--//用户叫庄
GameMsg.CMD_S_CallBanker = 
{
	{"wCallBanker","WORD"},													--//叫庄用户
	
};

--//游戏开始
GameMsg.CMD_S_GameStart = 
{
	--//下注信息
	{"lTurnMaxScore","LLONG"},													--//最大下注
	{"wBankerUser","WORD"},														--//庄家用户
	
};

--//用户下注
GameMsg.CMD_S_AddScore = 
{
	{"wAddScoreUser","WORD"},									--//加注用户
	{"lAddScoreCount","LLONG"},									--//加注数目
	
};

--//游戏结束
GameMsg.CMD_S_GameEnd = 
{
	{"lGameTax","LLONG["..GameMsg.GAME_PLAYER.."]"},	--//游戏税收
	{"lGameScore","LLONG["..GameMsg.GAME_PLAYER.."]"},	--//游戏得分
	{"cbCardData","BYTE["..GameMsg.GAME_PLAYER.."]["..GameMsg.MAXCOUNT.."]"},	--//用户扑克
	{"bHaveAction","BOOL"},	-- 本局是否有操作
	
};

--//发牌数据包
GameMsg.CMD_S_SendCard = 
{
	{"cbCardData","BYTE["..GameMsg.MAXCOUNT.."]"},--//用户扑克
	
};

--//用户退出
GameMsg.CMD_S_PlayerExit = 
{
	{"wPlayerID","WORD"},							--//退出用户
	
};

--//用户摊牌
GameMsg.CMD_S_Open_Card = 
{
	{"wPlayerID","WORD"},										--//摊牌用户
	{"bOpen","BYTE"},											--//摊牌标志
	
};

GameMsg.CMD_S_Trust = 
{
	{"wPlayerID","WORD"},							--//用户id
	{"bTrust","BOOL"},								

};

---------------------------------------------------------------------------
--客户端命令结构
--//用户叫庄
GameMsg.CMD_C_CallBanker = 
{
	{"bBanker","BYTE"},								--//做庄标志
	
};

--//用户加注
GameMsg.CMD_C_AddScore = 
{
	{"lScore","LLONG"},							--//加注数目
	
};

--//用户摊牌
GameMsg.CMD_C_OxCard = 
{
	{"bOX","BYTE"},							--//牛牛标志
	
};

GameMsg.CMD_C_Trust = 
{
	{"lBetIndex","BYTE"},				    --//托管下注标记
};






function GameMsg.init()

	

end

return GameMsg;