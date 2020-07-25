

local MAXBANKER = 10;
local MAX_SCORE_BANKER = 5;
local BANKERFLEE = 2000000;
local REVENUE = 5;


local NAME_ID = 40015000;
local GAME_PLAYER = 100;	--游戏人数
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
	SUB_S_GAME_START				=	100,	--游戏开始
	SUB_S_PLACE_JETTON 				=	101,	--用户下注
	SUB_S_GAME_END					=	102,	--游戏结束
	SUB_S_APPLY_BANKER				=	103,	--申请庄家
	SUB_S_CHANGE_BANKER				=	104,	--切换庄家
	SUB_S_CHANGE_USER_SCORE			=	105,	--更新积分
	SUB_S_SEND_RECORD				=	106,	--游戏记录
	SUB_S_PLACE_JETTON_FAIL			=	107,	--下注失败
	SUB_S_CANCEL_BANKER				=	108,	--取消申请
	SUB_S_MAX_JETTON				=	109,	--下注区域满
	SUB_S_GET_BANKER				=	110,	--获取庄家列表
	SUB_S_CANCEL_CANCEL				=	111,	--取消下庄 服务端消息

	SUB_S_CANCEL_SUCCESS			=	112,	--取消下庄成功
	SUB_S_CANCEL_BET				=	113,	--有人离开，退下注

	--客户端命令结构
	SUB_C_PLACE_JETTON				=	101,	--用户下注
	SUB_C_APPLY_BANKER				=	102,	--申请庄家
	SUB_C_CANCEL_BANKER				=	103,	--申请下庄 --取消申请上庄


	SUB_C_GET_BANKER				=	104,	--获取庄家列表
	SUB_C_CANCEL_CANCEL				=	105,	--取消下庄客户端

	ASS_ZHUANG_SCORE			= 115,		--//庄家坐庄期间输赢金币
	-- ASS_ZHUANG_SCORE			= 115,		--//庄家坐庄期间输赢金币

	SUB_C_CONTINUEBET 			= 106,	 --续投
	SUB_S_CONTINUEFAIL			= 116,	--续投失败

};


GameMsg.PLACE_JETTON_ID =  1001;



--天地玄黄
GameMsg.ID_TIAN_MARK = 0x01;
GameMsg.ID_DI_MARK = 0x02;
GameMsg.ID_XUAN_MARK = 0x04;
GameMsg.ID_HUANG_MARK = 0x08;
GameMsg.ID_QUAN_SHU = 0x10;





--空闲状态
GameMsg.GAME_SCENE_FREE				= 25
--下注状态
GameMsg.GAME_SCENE_JETTON			= 26
--游戏结束
GameMsg.GAME_SCENE_END				= 27

--发牌状态
GameMsg.GAME_SEND_CARD				= 10
--显示牌点
GameMsg.GAME_SHOW_POINT				= 11




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

--游戏状态 空闲
GameMsg.CMD_S_StatusFree = {
	{"IwanSafecode","LLONG"},
	{"cbTimeLeave","BYTE"},		--剩余时间
	{"lUserMaxScore","LLONG"},	--最大下注
	{"wBankerUser","WORD"},		--当前庄家
	{"cbBankerTime","WORD"},	--庄家局数
	{"lBankerWinScore","LLONG"}, --庄家成绩
	{"lBankerScore","LLONG"}, --庄家成绩
	{"bEnableSysBanker","BOOL"},	--系统做庄
	{"lApplyBankerCondition","LLONG"}, --申请条件
	{"lAreaLimitScore","LLONG"},		--区域限制
	{"wGetUser","WORD["..MAXBANKER.."]"},		--申请玩家
	{"lMultiple","INT"},				--几倍场
	{"lBetCondition","INT"},			--最小下注
	{"lCount","INT"},					--当日总局数
	{"lWinArea","INT[4]"},				--每个区域赢
	{"wCancleBanker","BOOL"},			--是否取消下庄
	{"ApplyCount","INT"},				--申请人数
	{"wApplyBanker","BOOL"},			--申请庄家
	{"ApplyUsers","BYTE[10]"},				--申请人数
}





--游戏状态
GameMsg.CMD_S_StatusPlay = {
	
	{"IwanSafecode","LLONG"},	--安全标志

	--全局下注
	{"lAllTianScore","LLONG"},	--天
	{"lAllDiScore","LLONG"},	--地
	{"lAllXuanScore","LLONG"},	--玄
	{"lAllHuangScore","LLONG"},	--黄

	--玩家自己下注
	{"lUserTianScore","LLONG"}, --天
	{"lUserDiScore","LLONG"},	--地
	{"lUserXuanScore","LLONG"},	--玄
	{"lUserHuangScore","LLONG"}, --黄

	--玩家积分
	{"lUserMaxScore","LLONG"}, 				--最大下注

	--控制信息
	{"lApplyBankerCondition","LLONG"}, 		--申请条件
	{"lAreaLimitScore","LLONG"}, 			--区域限制

	--扑克信息
	{"cbTableCardArray","BYTE[6][5]"},		--桌面扑克

	--庄家信息
	{"wBankerUser","WORD"},					--当前庄家
	{"cbBankerTime","WORD"},				--庄家局数
	{"lBankerWinScore","LLONG"},			--庄家赢分
	{"lBankerScore","LLONG"},				--庄家分数
	{"bEnableSysBanker","BOOL"},			--系统做庄

	--结束信息
	{"lEndBankerScore","LLONG"},				--庄家成绩
	{"lEndUserScore","LLONG"},					--玩家成绩
	{"lEndUserReturnScore","LLONG"},			--返回积分
	{"lEndRevenue","LLONG"},					--游戏税收

	--全局信息
	{"cbTimeLeave","BYTE"},						--剩余时间
	{"cbGameStatus","BYTE"},					--游戏状态
	{"wGetUser","WORD["..MAXBANKER.."]"},		--申请玩家
	{"lMultiple","INT"},				--几倍场 
	{"lBetCondition","INT"},			--最小下注

	{"lCount","INT"},					--当日总局数
	{"lWinArea","INT[4]"},				--每个区域赢
	{"wCancleBanker","BOOL"},			--是否取消下庄
	{"ApplyCount","INT"},				--申请人数
	{"wApplyBanker","BOOL"},			--申请庄家
	{"ApplyUsers","BYTE[10]"},				--申请人数

};
	--记录信息
	GameMsg.tagServerGameRecord ={
		{"cbWinner","BYTE"}
	};

function GameMsg.init()
	
end




--下注失败
GameMsg.CMD_S_PlaceJettonFail = {
	{"lJettonArea","BYTE"},		--下注区域
	{"lPlaceScore","LLONG"},		--当前下注
};


--更新积分
GameMsg.CMD_S_ChangeUserScore = {

	{"wChairID","WORD"},	--椅子号码
	{"lScore","LLONG"},		--玩家积分
	{"wCurrentBankerChairID","WORD"},		--当前庄家
	{"cbBankerTime","BYTE"},		--庄家局数
	{"lCurrentBankerScore","LLONG"},		--庄家分数
};

--申请庄家
GameMsg.CMD_S_ApplyBanker = {
	{"wApplyUser","WORD"},	--申请玩家
	{"ApplyCount","INT"},				--申请人数
	{"ApplyUsers","BYTE[10]"},				--申请人数
};


--取消申请
GameMsg.CMD_S_CancelBanker = {
	{"szCancelUser","WORD"},	--取消玩家
	{"wCancelUser","CHARSTRING[32]"}, --取消玩家名称
	{"ApplyCount","INT"},				--申请人数
	{"ApplyUsers","BYTE[10]"},				--申请人数
};


--切换庄家
GameMsg.CMD_S_ChangeBanker = 
{
	{"wBankerUser","WORD"},	--当庄玩家
	{"lBankerScore","LLONG"},	--庄家金币
	{"ApplyCount","INT"},				--申请人数
	{"BankerWinScore","LLONG"},
	{"ApplyUsers","BYTE[10]"},				--申请人数
};

--申请庄家
GameMsg.CMD_S_GetBanker = 
{
	{"wGetUser","WORD["..MAXBANKER.."]"},	--申请玩家
};


--游戏空闲
GameMsg.CMD_S_GameFree = 
{
	{"cbTimeLeave","BYTE"},	--剩余时间 
};


--游戏开始
GameMsg.CMD_S_GameStart = 
{
	{"wBankerUser","WORD"},	--庄家位置
	{"lBankerScore","LLONG"},	--庄家金币
	{"lUserMaxScore","LLONG"},	--我的金币
	{"cbTimeLeave","BYTE"},	--剩余时间 
	{"nBankerTime","INT"},	--做庄次数
};


--用户下注
GameMsg.CMD_S_PlaceJetton = 
{
	{"wChairID","WORD"},	--用户位置
	{"cbJettonArea","BYTE"},	--筹码区域
	{"lJettonScore","LLONG"},	--加注数目
};


--游戏结束
GameMsg.CMD_S_GameEnd = 
{
	--下局信息
	{"cbTimeLeave","BYTE"},	--剩余时间


	--扑克信息
	{"cbTableCardArray","BYTE[6][5]"},	--桌面扑克

	--庄家信息
	{"lBankerScore","LLONG"},	--庄家成绩
	{"lBankerTotallScore","LLONG"},	--庄家成绩
	{"nBankerTime","INT"},	--做庄次数

	--玩家成绩
	{"lUserScore","LLONG"},	--玩家成绩
	{"lUserReturnScore","LLONG"},	--返回积分

	--全局信息
	{"lRevenue","LLONG"},	--游戏税收
	

	--玩家下注信息
	{"lUserTianScore","LLONG"},	--天
	{"lUserDiScore","LLONG"},	--地
	{"lUserXuanScore","LLONG"},	--玄
	{"lUserHuangScore","LLONG"},	--黄


	{"lCount","INT"},					--当日总局数
	{"lWinArea","INT[4]"},				--每个区域赢

	{"LOtherScore","LLONG"}, --其他玩家得分
	{"UserWinScore","LLONG["..PLAY_COUNT.."]"},			--所有玩家成绩
 	{"nWinTime","INT"},									--//连胜局数

};


--下注已满
GameMsg.CMD_S_MaxJetton = 
{
	{"cbTimeLeave","BYTE"},	--剩余时间	 
};


--取消下庄
GameMsg.CMD_S_CANCEL_CANCEL ={
	-- {"wCancleBanker","BOOL"}
}


--取消下庄成功
GameMsg.CMD_S_CANCEL_SUCCESS ={
	-- {"wCancleBanker","BOOL"}
}


--庄家坐庄期间输赢金币
GameMsg.BankGetMonry = {
	{"money","LLONG"},--庄家坐庄期间输赢金币
};


--用户下注
GameMsg.CMD_C_PlaceJetton = 
{
	{"cbJettonArea","BYTE"},	--筹码区域
	{"lJettonScore","LLONG"},	--加注数目
};


--续投
GameMsg.CMD_C_ContinueBet = 
{
	{"PlaceBet","GameMsg.CMD_C_PlaceJetton[4]"},
};




--退注
GameMsg.CMD_S_CancelBet = {
	{"lUserPlaceScore","LLONG[4]"},
	{"lTotalPlaceScore","LLONG[4]"},
};



--获取空路单记录
function GameMsg.getEmptyGameRecord()
	return
	{
		bWinTianMen = false,		--天门胜利
		bWinDiMen = false,			--地门胜利
		bWinXuanMen = false,		--玄门胜利
		bWinHuangMen = false
	}
end

--申请列表
function GameMsg.getEmptyApplyInfo(  )
    return
    {
        --用户信息
        m_userItem = {},
        --是否当前庄家
        m_bCurrent = false,
        --编号
        m_llIdx = 0,
        --是否超级抢庄
        m_bRob = false
    }
end

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