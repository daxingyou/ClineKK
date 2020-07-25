

local MAXBANKER = 10;
local MAX_SCORE_BANKER = 5;
local BANKERFLEE = 2000000;
local REVENUE = 5;


local NAME_ID = 40015000;
local GAME_PLAYER = 30;	--游戏人数
-- local PLAY_COUNT = GAME_PLAYER;	--游戏人数
local MAX_NAME_INFO = 256;		--

-- MAX_COUNT = GAME_PLAYER;
-- PLAY_COUNT = GAME_PLAYER;




local GameMsg = {
	-- 游戏状态
	GS_FREE						=     25,									--等待开始
	GS_PLAYING                  =     26,									--各玩家进行打牌状态

	GS_PLACE_JETTON				=	  26,			--下注状态
	GS_GAME_END					=		27,			--结束状态

	-- 异常类消息
	ASS_NO_PLAYER                =   155,             --没有玩家进行游戏
	ASS_AGREE                    =   156,             --玩家是否同意的消息
	ASS_CFG_DESK_TIMEOUT         =   157,             --设置底注超时
	ASS_NOT_ENOUGH_MONEY         =   158,            --玩家金币不足的提示
	ASS_FORCE_QUIT_REQ           =   160,             --玩家强退请求
	ASS_QUIT_INFO                =   161,             --服务端向客户端报告那个玩家退出的消息


	ASS_HAVE_THING               =   182,             --有事请求离开
	ASS_LEFT_RESULT              =   183,             --同意用户离开
	ASS_HAVE_THING_OUTTIME       =   184,             --有事请求离开事件处理超时
	ASS_HAVE_THING_DOING         =   185,             --有事请求离开事件正在处理中
	ASS_OUT_SEQ                  =   186,             --outseq                    
	ASS_USER_CUT                 =   82,              --玩家断线了
	ASS_OUT_CARD_TIME            =   190,             --玩家超时,所剩时间


	--服务器命令结构
	SUB_S_GAME_FREE					=	99,	--游戏空闲
	

	SUB_S_GAME_PLAYING					=	26,	--抢红包中
	SUB_S_GAME_ENDING					=	27,	--游戏结束状态



	SUB_S_GAME_START				=	100,	--游戏开始
	SUB_C_PLANT_MINE 				=	101,	--申请埋雷
	SUB_C_OPEN_REDBAG				=	102,	--打开红包
	SUB_S_OPEN_REDBAG				=	103,	--打开红包 服务器返回
	SUB_S_GAME_END					=	102,	--游戏结束
	SUB_S_REDBAG_LIST 				=   104,    --红包列表
	SUB_S_GAME_FINISH				=	116,	--游戏完全结束

};




--空闲状态
GameMsg.GAME_SCENE_FREE				= 25
--下注状态
GameMsg.GAME_SCENE_PLAYING			= 26
--游戏结束
GameMsg.GAME_SCENE_END				= 27



GameMsg.CMD_S_AgreeState = {
	{"wCurrentUser","BYTE"},--当前玩家
	{"bAgree","BOOL"},--同意开始
}

-- 没有玩家在桌的通知
GameMsg.TNoPlayer = {
	{"bGameFinished","BOOL"},--桌子已散掉 bGameFinished = false;  桌子已散掉
}

-- 玩家强退的报告包,服务器给客户端的
GameMsg.TQuitInfo = {
	{"byUser","INT"},--退出的玩家
}

--断线数据结构
GameMsg.bCutStruct = {
	{"bDeskStation","BYTE"},
	{"bCut","BOOL"},
}

GameMsg.LeaveResultStruct = {
	{"bDeskStation","BYTE"},
	{"bArgeeLeave","INT"},
}


------------------------------------------------百人牛牛--------------------------------------------------------------------------------

function GameMsg.init()
	
end

--游戏状态 空闲
GameMsg.CMD_S_StatusFree = {
	{"IwanSafecode","LLONG"},
	{"cbGameStatus","BYTE"},		--游戏状态
	{"cbTimeLeave","BYTE"},		--剩余时间
	{"ucMaxRedBags","BYTE"},		--红包个数
	{"ucMaxRedScore","LLONG"},      --红包最大金额
	-- {"ucPlantMinesNum","BYTE"},	 --已申请玩家埋雷个数
	-- {"tagPlantMines","GameMsg.CMD_C_PLANT_MINE[100]"},		--红包列表
}



--游戏状态
GameMsg.CMD_S_StatusPlay = {
	{"IwanSafecode","LLONG"},
	{"cbGameStatus","BYTE"},		--游戏状态
	{"cbTimeLeave","BYTE"},		--剩余时间

	
	-- {"ucPlantMinesNum","BYTE"},	 --已申请玩家埋雷个数
	-- {"tagPlantMines","GameMsg.CMD_C_PLANT_MINE[100]"},		--红包列表

	{"curPlantMine","GameMsg.CMD_C_PLANT_MINE"},		--当前雷

	{"lBankerWinScore","LLONG"},		--庄家输赢金币

	{"cbUserStatus","BYTE"},		--玩家状态

	{"ucPeopoleCout","BYTE"},		--房间里实际人数
	{"ucMaxRedBags","BYTE"},		--红包个数
	
	{"tagRedBag","GameMsg.tagRedBag[10]"},		--每个红包状态数据 开启与否
	{"ucMaxRedScore","LLONG"},      --红包最大金额

	-- {"llEndBankerScore","LLONG"},		--庄家成绩
	-- {"llEndUserScore","LLONG"},		--玩家成绩
	-- {"lRevenue","LLONG"},		--游戏税收
};

--红包
GameMsg.tagRedBag = {
	{"llRedBagScore","LLONG"},		--红包金额
	{"ucChairID","BYTE"},		--位置 255 未开启
	{"bHitMine","BYTE"}			--是否中雷 1 中雷 0 没中 255 没打开
};



--游戏开始
GameMsg.CMD_S_GAMESTART = {
	{"llRedBagScore","LLONG"},		--红包总额
	{"ucMineIndex","BYTE"},		--本局雷号
	{"wBankerUser","BYTE"},		--埋雷玩家位置
	{"isVirtual","INT"},		--是否是机器人
	{"cbLeaveTime","BYTE"},		--剩余时间
	{"ucMaxRedBags","BYTE"},		--红包个数
	{"ucPeopoleCout","BYTE"}		--房间里实际人数
};



--打开红包
GameMsg.CMD_S_OPEN_REDBAG = {
	-- {"wOpenUser","WORD"},		--抢红包玩家
	-- {"bHitMine","BYTE"},		--抢红包玩家
	-- {"llRedBagScore","LLONG"},		--红包金额
	{"llRedBagScore","LLONG"},		--红包金额
	{"wOpenUser","BYTE"},		--位置 255 未开启
	{"bHitMine","BYTE"}			--是否中雷 1 中雷 0 没中 255 没打开
};



--申请埋雷
GameMsg.CMD_C_PLANT_MINE = {
	{"llRedBagScore","LLONG"},		--红包金额
	{"ucMinesIndex","BYTE"},		--雷号
	{"ucChairID","BYTE"},		--位置
	{"isVirtual","INT"}			--是否是机器人
};

--玩家埋雷
GameMsg.CMD_S_PLANT_MINE = {
	{"llRedBagScore","LLONG"},		--红包金额
	{"ucMinesIndex","BYTE"},		--雷号
	{"ucChairID","BYTE"},		--位置

	-- {"ucPlantMinesNum","BYTE"},	 --已申请玩家埋雷个数
	
	-- {"tagPlantMines","GameMsg.CMD_C_PLANT_MINE[100]"},		--红包列表
};


--玩家埋雷
GameMsg.CMD_S_REDBAG_LIST = {
	{"ucPlantMinesNum","BYTE"},	 --已申请玩家埋雷个数
	
	{"tagPlantMines","GameMsg.CMD_C_PLANT_MINE[30]"},		--红包列表
};


--游戏结束
GameMsg.CMD_S_GAME_END = {
	{"cbLeaveTime","BYTE"},		--剩余时间
	
	{"lBankerReturnScore","LLONG"},		--庄家返回金币
	{"lBankerWinScore","LLONG"},		--庄家输赢金币
	{"lBankerRevenue","LLONG"},		--游戏税收

	--玩家成绩
	{"ucUserChairs","BYTE[10]"},		--打开红包的玩家
	{"lUserWinScores","LLONG[10]"},		--玩家输赢金币
	{"lUserRevenues","LLONG[10]"},		--游戏税收
	{"lRegBagScores","LLONG[10]"},		--红包金额
	--{"lUserScore","LLONG"},		--玩家输赢金币
	{"nWinTime","INT"},									--//连胜局数
	
};












--申请列表
function GameMsg.formatCoin(lCoin,tagStr)
	if not lCoin then
		luaPrint("lCoin error:",lCoin);
		return "";
	end
	-- local str = math.ceil(lCoin/100);
 --    return tostring(str);
 	if not tagStr then
 		tagStr = "";
 	end

    local remainderNum = lCoin%100;
	local remainderString = "";

	if remainderNum == 0 then--保留2位小数
		remainderString = remainderString..".00";
	else
		if remainderNum%10 == 0 then
			remainderString = remainderString.."0";
		end
	end

	return tagStr..(lCoin/100)..remainderString;

end

function GameMsg.delayBtnEnable(btn,dt)
	btn:stopAllActions();
	if dt == nil then
		dt = 1.0
	end
	local actionCallback = cc.CallFunc:create(function (sender)
			btn:setTouchEnabled(true);
	end)

	btn:setTouchEnabled(false);
	local delayIt = cc.DelayTime:create(dt)
	local action = cc.Sequence:create(delayIt,actionCallback)
	btn:runAction(action);
end


return GameMsg;