
local GameMsg = { 
	SUPER_PLAYER               	=     10,              	--//超级玩家
	INVALID_CHAIR			   	=     255,				--//无效椅子
-- //文件名字定义
	GAMENAME                   	=     "德州扑克",

-- //版本定义
	GAME_MAX_VER                =    1,               	--//现在最高版本
	GAME_LESS_VER               =    1,              	--//现在最低版本
	GAME_CHANGE_VER             =    0,               	--//修改版本

-- //游戏开发版本
	DEV_HEIGHT_VERSION          =    10,              	--//内部开发高版本号
	DEV_LOW_VERSION             =    1,               	--//内部开发低版本号

-- //数目定义
	MAX_HANDCOUNT				=     2,				--//最大数目
	MAX_CENTERCOUNT             =     5,				--//最大公共数目
-- -- //游戏信息
-- 	NAME_ID                     =    30002600,        	--//名字 ID
-- 	MAX_NAME_INFO               =    256,

-- //异常类消息
	
	--//游戏状态定义

		GS_FREE							=0,									--//等待开始
		GS_PLAY_GAME					=21,								--//
 		GS_WAIT_NEXT					=22,								--//

 		ASS_ROUND_BEGIN					=120,				--//回合开始
		ASS_BET							=125,             	--//玩家下注信息
		ASS_SENDCARD					=130,				--//发牌信息
		ASS_BETPOOL_UP					=134,				--//下注池更新
		ASS_BET_RESULT					=136,				--//下注结果
		ASS_COMPARE_CARD                =140,             	--//比牌信息

		ASS_AUTO_TOKEN              	=143,				--//托管 (让/弃，跟任何注)
		ASS_MING_CARD					=144,				--//弃牌后亮牌
		ASS_ALLIN_MING_CARD				=145,				--//所有玩家全下，翻开手牌


		ASS_TOKEN						=186,				--//令牌信息
		ASS_GAME_END					=191,				--//回合算分

		ASS_USER_CUT                    =82,              --//玩家断线了
		
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
 		ASS_OUT_CARD_TIME               =190,             --//玩家超时，所剩时间 

}
-- //动作类型
-- #define UD_VF_CALL					0x01  //可以跟注
-- #define UD_VF_ADD					0x02  //可以加注
-- #define UD_VF_FOLD					0x04  //可以弃牌
-- #define UD_VF_CHECK					0x08  //可以过牌
-- #define UD_VF_ALLIN					0x10  //可以全下

-- // 下注类型
-- enum emType
-- {
--     ET_UNKNOWN 		= 0,	//未知类型
--     ET_CALL			= 1,	//跟注
--     ET_ADDNOTE 		= 2,	//加注
--     ET_CHECK			= 3,	//过牌
--     ET_FOLD    		= 4,    //弃牌
--     ET_ALLIN			= 5,	//全下
--     ET_AUTO			= 6,    //自动下注

-- };

-- // 发牌类型
-- enum emTypeCard
-- {
--     UNKNOWN			= 0,	//未知类型
--     SEND_A_CAND		= 1,	//下发两张手牌
--     SEND_3_CAND		= 2,	//下发 3 张公共牌
--     SEND_4_5_CAND   	= 3,	//下发 4, 5 张牌
-- };

-- // 托管状态
-- enum emToken
-- {
-- 	TO_UNKNOWN					= 0,	// 未知类型
-- 	TO_CALLMANDATE				= 1,	// 跟注托管按钮
-- 	TO_CHECKMANDATE				= 2,    // 过牌托管按钮
-- 	TO_CALLANYMANDATE			= 3,    // 跟任何注按钮
-- 	TO_PASSABANDONMANDAT		= 4,    // 过牌/弃牌托管按钮
-- };

-- // 玩家状态
-- enum emUserState
-- {
-- 	STATE_NULL,			//无玩家0
-- 	STATE_PLAY,			//游戏中1
-- 	STATE_GIVE_UP,		//弃牌2
-- 	STATE_WATCH,		//观战3
-- };
-- //扑克出牌类型
-- #define UG_ERROR_KIND				    0				//错误
-- #define SH_OTHER					    	1				//散牌
-- #define SH_DOUBLE					    2				//对子
-- #define SH_TWO_DOUBLE				    3				//两对
-- #define SH_THREE					    	4				//三条
-- #define SH_SMALL_CONTINUE			    5				//最小顺子
-- #define SH_CONTINUE					    6				//顺子
-- #define SH_SAME_HUA					    7				//同花
-- #define SH_HU_LU					    	8				//葫芦
-- #define SH_TIE_ZHI					    9				//4条
-- #define SH_SMALL_SAME_HUA_CONTINUE	    11              //最小同花顺
-- #define SH_SAME_HUA_CONTINUE		    	10				//同花顺
-- #define SH_REGIUS_SAME_HUA_CONTINUE		12				//皇家同花顺

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

--//托管数据包
GameMsg.AutoToken = {
	{"autoType","INT"}, 		--//托管类型
	{"bAuto","BOOL"},			--//托管/取消托管
}

--//游戏状态
GameMsg.CMD_S_GameState =
{
	{"bGameStation", "BYTE"},     										--//游戏状态
	{"iThinkTime", "INT"},     											--//思考时间
	{"iCellNode", "INT"},     											--//小盲注
	{"byHandCard", "BYTE["..PLAY_COUNT.."][2]"}, 						--//玩家手上的扑克
	{"nHandCardNums", "INT"},     								 		--//玩家手上扑克数目	
	{"byCards", "BYTE[5]"}, 											--//桌面上公共牌
	{"nCardsCount", "INT"},      										--//桌面公共牌数	

	{"bAllin","BOOL["..PLAY_COUNT.."]"},								--//记录全下的玩家位置
	{"byTokenUser", "BYTE"}, 											--//得到令牌的用户
	{"byNTUser", "BYTE"}, 												--//庄家
	{"nCallMoney", "LLONG"}, 											--//跟注金币
	{"lTurnNode", "LLONG["..PLAY_COUNT.."]"}, 							--//跟注金币

	{"byVerbFlag", "BYTE"}, 											--//操作属性
	{"lUserMoney", "LLONG["..PLAY_COUNT.."]"}, 							--//玩家金币	
	{"nBetPools", "LLONG["..PLAY_COUNT.."]"}, 							--//下注边池金币	
	{"iUserState", "INT["..PLAY_COUNT.."]"},     						--//玩家状态
	{"iSTime", "INT"},     												--//玩家操作剩余时间
	{"iCardShape", "BYTE["..PLAY_COUNT.."]"},       					--//玩家最大类型
	{"bFollowAll","BOOL"},												--//跟任何
	{"bCheckOrfold","BOOL"},											--//让或弃
	{"bBigBlind", "BYTE"},       										--//大盲注位置
	{"bSmallBlind", "BYTE"},       										--//小盲注位置
	{"bMingCard","BOOL"},												--//弃牌后是否亮牌
};

--//下注数据包
GameMsg.CMD_C_Note =
{
	{"nType", "INT"},     		--//下注类型
	{"byUser", "BYTE"},     	--//下注的玩家
	{"nMoney", "LLONG"},     	--//注额
};

--//下注数据包
GameMsg.CMD_S_NoteResult =
{
	{"nType", "INT"},     			--//下注类型
	{"byUser", "BYTE"},     		--//下注的玩家
	{"nMoney", "LLONG"},     		--//注额
	{"lUserMoney", "LLONG"},     	--//玩家剩余金币
	{"lTurnNode", "LLONG"},     	--//一轮玩家所下的总注
};

--//比牌数据包
GameMsg.CMD_S_Compare =
{
	{"nCardKind", "BYTE["..PLAY_COUNT.."]"},     			--//玩家牌型
	{"bCards", "BYTE["..PLAY_COUNT.."][5]"},     			--//所有玩家组成的牌数据
	{"bCardsEx", "BYTE["..PLAY_COUNT.."][2]"},     			--//剩下2张没用的牌
	{"bHandCards", "BYTE["..PLAY_COUNT.."][2]"},     		--//玩家手牌
	{"nCardCount", "INT"},     								--//组合牌张数
	{"nHandCardCount", "INT["..PLAY_COUNT.."]"},     		--//玩家手牌张数
	{"bMaxStation", "BYTE"},     							--//最大牌型玩家
};

--//发牌数据包
GameMsg.CMD_S_SendCard =
{
	{"nTypeCard", "INT"},     							--//发牌类型
	{"iCardsNum", "INT"},     							--//发牌数量
	{"byCards", "BYTE["..PLAY_COUNT.."][2]"},     		--//牌数据
	{"byPublicCards", "BYTE[5]"},     					--//公共牌数据
	{"iUserState", "INT["..PLAY_COUNT.."]"},     		--//玩家状态
	{"iCardShape", "BYTE"},       						--//最大类型
};

--//令牌包
GameMsg.CMD_S_Notify =
{
	{"byUser", "BYTE"},     						--//所属玩家
	{"byVerbFlag", "BYTE"},     					--//允许动作标志
	{"bNewTurns","BOOL"},							--//是否为新的一轮开始
	{"nTurnNums", "INT"},     						--//当前游戏活动的圈数
	{"nCallMoney", "LLONG"},     					--//当前可以跟注的金币
	{"iUserState", "INT["..PLAY_COUNT.."]"},     	--//玩家状态
	{"bAllin","BOOL"},								--//是否全下

	{"lBotValueX", "LLONG"},     					--//机器人总盈利90%
	{"lBotValueY", "LLONG"},     					--//机器人总注+当前所需跟注
	{"bBot","BOOL["..PLAY_COUNT.."]"},				--//有效机器人位置
	{"bBotType", "INT["..PLAY_COUNT.."]"},     		--//机器人类型
	{"lUserNote","LLONG["..PLAY_COUNT.."]"},		--//机器人下注
	{"lUserMoney", "LLONG["..PLAY_COUNT.."]"},     	--//玩家当前可用金币
};

--//下注边池更新包
GameMsg.CMD_S_TBetPool =
{
	{"iBetPools", "LLONG["..PLAY_COUNT.."]"},     	--//下注边池
};

--//结算结构包
GameMsg.CMD_S_GameEnd =
{
	{"nBetPools", "LLONG["..PLAY_COUNT.."]"},     							--//所有下注池
	{"nUserBet", "LLONG["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},     			--//每个玩家下注数据
	{"bWinBetPools","BOOL["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},			--//赢的下注池
	{"nWinPoolsMoney", "LLONG["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},     	--//赢的下注池金币
	{"nScore", "LLONG["..PLAY_COUNT.."]"},     								--//输赢积分

	{"nSelfMoney", "LLONG["..PLAY_COUNT.."]"},     							--//自己的金币更新: 客户端获取的金币有可能还没有刷新, 所以在这里发下去
	{"bWin","BOOL["..PLAY_COUNT.."]"},										--//记录赢家
	{"byMingCard", "BYTE["..PLAY_COUNT.."][2]"},     						--//亮牌玩家手牌
	{"bAutoGiveUp","BOOL"},													--//本局无操作自动弃牌
	{"iUserState", "INT["..PLAY_COUNT.."]"},     							--//玩家状态
	{"nWinTime","INT"},									--//连胜局数
};

--/新的一回合消息包
GameMsg.CMD_S_GameStart =
{
	{"byNTUser", "BYTE"},     		--//庄家位置
	{"bSmallBlind", "BYTE"},     	--//小盲注位置
	{"bBigBlind", "BYTE"},     		--//大盲注位置
	{"iCellNode", "INT"},     		--//小盲注
	{"iGameRoundCount", "INT"},     --//局数
};

--//亮牌
GameMsg.CMD_S_MingCard =
{
	{"bMing", "BOOL"},      		--///亮牌/取消亮牌
};

--//allin亮牌
GameMsg.CMD_S_AllInMingCard =
{
	{"byHandCard", "BYTE["..PLAY_COUNT.."][2]"},     						--//亮牌玩家手牌      		
};


--//旁观
GameMsg.CMD_S_WatcherSit =
{
	{"wChairID", "WORD"},      		--//旁观用户
};


function GameMsg.init()
--//游戏状态
GameMsg.CMD_S_GameState =
{
	{"bGameStation", "BYTE"},     										--//游戏状态
	{"iThinkTime", "INT"},     											--//思考时间
	{"iCellNode", "INT"},     											--//小盲注
	{"byHandCard", "BYTE["..PLAY_COUNT.."][2]"}, 						--//玩家手上的扑克
	{"nHandCardNums", "INT"},     								 		--//玩家手上扑克数目	
	{"byCards", "BYTE[5]"}, 											--//桌面上公共牌
	{"nCardsCount", "INT"},      										--//桌面公共牌数	

	{"bAllin","BOOL["..PLAY_COUNT.."]"},								--//记录全下的玩家位置
	{"byTokenUser", "BYTE"}, 											--//得到令牌的用户
	{"byNTUser", "BYTE"}, 												--//庄家
	{"nCallMoney", "LLONG"}, 											--//跟注金币
	{"lTurnNode", "LLONG["..PLAY_COUNT.."]"}, 							--//跟注金币

	{"byVerbFlag", "BYTE"}, 											--//操作属性
	{"lUserMoney", "LLONG["..PLAY_COUNT.."]"}, 							--//玩家金币	
	{"nBetPools", "LLONG["..PLAY_COUNT.."]"}, 							--//下注边池金币	
	{"iUserState", "INT["..PLAY_COUNT.."]"},     						--//玩家状态
	{"iSTime", "INT"},     												--//玩家操作剩余时间
	{"iCardShape", "BYTE["..PLAY_COUNT.."]"},       					--//玩家最大类型
	{"bFollowAll","BOOL"},												--//跟任何
	{"bCheckOrfold","BOOL"},											--//让或弃
	{"bBigBlind", "BYTE"},       										--//大盲注位置
	{"bSmallBlind", "BYTE"},       										--//小盲注位置
	{"bMingCard","BOOL"},												--//弃牌后是否亮牌
};

--//比牌数据包
GameMsg.CMD_S_Compare =
{
	{"nCardKind", "BYTE["..PLAY_COUNT.."]"},     			--//玩家牌型
	{"bCards", "BYTE["..PLAY_COUNT.."][5]"},     			--//所有玩家组成的牌数据
	{"bCardsEx", "BYTE["..PLAY_COUNT.."][2]"},     			--//剩下2张没用的牌
	{"bHandCards", "BYTE["..PLAY_COUNT.."][2]"},     		--//玩家手牌
	{"nCardCount", "INT"},     								--//组合牌张数
	{"nHandCardCount", "INT["..PLAY_COUNT.."]"},     		--//玩家手牌张数
	{"bMaxStation", "BYTE"},     							--//最大牌型玩家
};

--//发牌数据包
GameMsg.CMD_S_SendCard =
{
	{"nTypeCard", "INT"},     							--//发牌类型
	{"iCardsNum", "INT"},     							--//发牌数量
	{"byCards", "BYTE["..PLAY_COUNT.."][2]"},     		--//牌数据
	{"byPublicCards", "BYTE[5]"},     					--//公共牌数据
	{"iUserState", "INT["..PLAY_COUNT.."]"},     		--//玩家状态
	{"iCardShape", "BYTE"},       						--//最大类型
};

--//下注边池更新包
GameMsg.CMD_S_TBetPool =
{
	{"iBetPools", "LLONG["..PLAY_COUNT.."]"},     	--//下注边池
};

--//令牌包
GameMsg.CMD_S_Notify =
{
	{"byUser", "BYTE"},     						--//所属玩家
	{"byVerbFlag", "BYTE"},     					--//允许动作标志
	{"bNewTurns","BOOL"},							--//是否为新的一轮开始
	{"nTurnNums", "INT"},     						--//当前游戏活动的圈数
	{"nCallMoney", "LLONG"},     					--//当前可以跟注的金币
	{"iUserState", "INT["..PLAY_COUNT.."]"},     	--//玩家状态
	{"bAllin","BOOL"},								--//是否全下

	{"lBotValueX", "LLONG"},     					--//机器人总盈利90%
	{"lBotValueY", "LLONG"},     					--//机器人总注+当前所需跟注
	{"bBot","BOOL["..PLAY_COUNT.."]"},				--//有效机器人位置
	{"bBotType", "INT["..PLAY_COUNT.."]"},     		--//机器人类型
	{"lUserNote","LLONG["..PLAY_COUNT.."]"},		--//机器人下注
	{"lUserMoney", "LLONG["..PLAY_COUNT.."]"},     	--//玩家当前可用金币
};

--//allin亮牌
GameMsg.CMD_S_AllInMingCard =
{
	{"byHandCard", "BYTE["..PLAY_COUNT.."][2]"},     						--//亮牌玩家手牌      		
};

--//结算结构包
GameMsg.CMD_S_GameEnd =
{
	{"nBetPools", "LLONG["..PLAY_COUNT.."]"},     							--//所有下注池
	{"nUserBet", "LLONG["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},     			--//每个玩家下注数据
	{"bWinBetPools","BOOL["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},			--//赢的下注池
	{"nWinPoolsMoney", "LLONG["..PLAY_COUNT.."]["..PLAY_COUNT.."]"},     	--//赢的下注池金币
	{"nScore", "LLONG["..PLAY_COUNT.."]"},     								--//输赢积分

	{"nSelfMoney", "LLONG["..PLAY_COUNT.."]"},     							--//自己的金币更新: 客户端获取的金币有可能还没有刷新, 所以在这里发下去
	{"bWin","BOOL["..PLAY_COUNT.."]"},										--//记录赢家
	{"byMingCard", "BYTE["..PLAY_COUNT.."][2]"},     						--//亮牌玩家手牌
	{"bAutoGiveUp","BOOL"},													--//本局无操作自动弃牌
	{"iUserState", "INT["..PLAY_COUNT.."]"},     							--//玩家状态
	{"nWinTime","INT"},									--//连胜局数
};

end

return GameMsg;
