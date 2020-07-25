PLAY_COUNT = 5;
local MAX_CARD_COUNT = 3;
local INVALID_CHAIR = 255;


local GameMsg = {
		GS_WAIT_SETGAME = 0,	--等待东家设置状态
		GS_WAIT_ARGEE 	= 1,	--等待同意设置
		GS_SEND_CARD 	= 21,	--发牌状态
		GS_PLAY_GAME	= 22,	--游戏中状态
		GS_WAIT_NEXT	= 23,	--等待下一盘开始

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


		--游戏消息
		ASS_BEGIN_UPGRADE 			= 51,		--游戏开始
		ASS_SEND_CARD 				= 52,		--发牌信息
		ASS_GAME_PLAY 				= 59,		--开始游戏
		ASS_CONTINUE_END		 	= 65,		--游戏结束
		
		
		ASS_AUTO_FOLLOW				= 90,		--自动跟注
		ASS_NOTE 					= 91,		--通知下注
		ASS_NOTE_RESULT 			= 92,		--下注结果
		ASS_LOOK_CARD				= 93,		--看牌
		ASS_MING_CARD 				= 94,		--亮牌
		ASS_BIPAI_RESULT 			= 95,		--比牌结果
	 	ASS_BIPAI_REQ				= 96,		--比牌申请
	 	ASS_BIPAI_MAP_CARD			= 97,		--根据比牌关系看牌
		ASS_FINISH_COMPARE 			= 101,		--全局比牌


		ASS_VREB_CHECK 				= 179,		--用户处理发送数据
		

};


--游戏消息
GameMsg.EVT_DEAL_MSG = "EVT_DEAL_MSG";
--动画消息
GameMsg.EVT_VIEW_MSG = "EVT_VIEW_MSG";

GameMsg.ACTION_BEGIN = "ACTION_BEGIN";
GameMsg.ACTION_END = "ACTION_END";

--游戏房间等待
GameMsg.MSG_TABLE_WAIT = 101;
--游戏房间发牌
GameMsg.MSG_TABLE_SEND = 102;
--游戏进行中
GameMsg.MSG_TABLE_PLAYING = 103;




--按注类型
GameMsg.TYPE_GIVE_UP	= 0x00;		--放弃
GameMsg.TYPE_NOTE		= 0x01;		--下注
GameMsg.TYPE_ADD		= 0x02;		--加注
GameMsg.TYPE_FOLLOW		= 0x03;		--跟注
GameMsg.TYPE_MINGCARD	= 0x04;		--亮牌
GameMsg.TYPE_LOOKCARD	= 0x05;		--看牌
GameMsg.TYPE_NORMAL		= 0x06;		--正常状态

GameMsg.TYPE_COMPARE_REQ		= 0x08;		--比牌请求
GameMsg.TYPE_COMPARE_CARD		= 0x09;		--比牌操作
GameMsg.TYPE_NOTE_ALL			= 0x10;		--全下操作

--发送用户结果
GameMsg.tagUserResult = {
	{"bCountNotePeople","BYTE"},		--当前未放弃玩家数
	{"iNoteGroup","INT"},				--当前轮数
	
	{"iNowBigNoteStyle","BYTE"},		--当前最大下注类型
	{"iNowBigPeople","BYTE"},			--最大玩家
	{"iOutPeople","BYTE"},				--下注者

	{"iNowBigNote","LLONG"},				--当前最大下注
	{"iTotalNote","LLONG"},				--总下注
	{"iUserStation","INT["..PLAY_COUNT.."]"},		--玩家状态
	{"iFirstOutPeople","INT"},			--第一位置玩家

	{"iUserNote","LLONG["..PLAY_COUNT.."]"},			--用户本轮下注
	{"bIsFirstNote","BOOL"},	--第一次下注
	{"bForceCompare","BOOL"},	--是否强制比牌
	{"bForceFollow","BOOL"}, --最后一轮 最后一个玩家只能跟注
}





GameMsg.GameStationFree = {
	{"bGameStation","BYTE"},	--游戏状态
	-- {"iThinkTime","BYTE"},		--玩家操作时间
	-- {"iAllCardCount","BYTE"},	--扑克数目
	{"iGuoDi","INT"},			--锅底
	{"iLimtePerNote","LLONG"},	--  暗注上限，明注需要 * 2
	{"iUpGradePeople","BYTE"},			--庄家位置
	{"iBeenPlayGame","BYTE"},			--已经游戏的局数

}



GameMsg.GameStationBegin = {
	{"bGameStation","BYTE"},	--游戏状态
	{"iGuoDi","INT"},			--锅底
	{"iLimtePerNote","LLONG"},	--  暗注上限，明注需要 * 2
	--运行状态变量
	{"bNtPeople","BYTE"},			-- 庄家位置
	{"iUserStation","INT["..PLAY_COUNT.."]"},		--玩家状态
}



--游戏状态数据包	（ 游戏中状态 ）
GameMsg.GameStation_PLAYING = {
	--基础信息
	{"bGameStation","BYTE"},	--游戏状态
	{"iGuoDi","INT"},			--锅底
	{"iLimtePerNote","LLONG"},	--  暗注上限，明注需要 * 2
	{"iUpGradePeople","BYTE"},			--庄家位置
	{"iBeenPlayGame","BYTE"},			--已经游戏的局数


	{"iCurNote","LLONG"},			-- 上一位玩家下注值，已暗注计算

	--运行状态变量
	{"bNtPeople","BYTE"},			-- 庄家位置
	{"iOutCardPeople","BYTE"},				-- 现在出牌用户
	{"iFirstOutPeople","BYTE"},				-- 先出牌的用户
	{"iNowBigPeople","BYTE"},					--上次操作 的玩家
	{"iPerJuTotalNote","LLONG["..PLAY_COUNT.."]"},				-- 用户当前下注
	{"iMing","BOOL["..PLAY_COUNT.."]"},				--明牌状态
	
	{"bOpenLose","BOOL["..PLAY_COUNT.."]"},				--玩家比牌是否输了
	{"bIsGiveUp","BOOL["..PLAY_COUNT.."]"},				--玩家是否放弃
	
	{"bIsFirstNote","BOOL"},							--是否为第一次下注

	
	{"iTimeRest","UINT"},				--定时器实际剩下的时间，用于表示断线重连时剩余时间值


	--状态信息
	{"iNoteGroup","INT"},				--当前轮数
	{"iUserStation","INT["..PLAY_COUNT.."]"},		--玩家状态
	{"iUserNote","LLONG["..PLAY_COUNT.."]"},			--用户本轮下注
	{"iTotalNote","LLONG"},				--总下注
	--end
	{"iUserCardCount","BYTE["..PLAY_COUNT.."]"},		--用户手上的牌数
	{"iUserCard","BYTE["..PLAY_COUNT.."][3]"},		--用户手上的牌


	{"iNoteRecord","LLONG[105]"},				--总下注

	{"bForceCompare","BOOL"},	--是否强制比牌
	{"bAutoFollow","BOOL"},  --自动跟注
	{"bForceFollow","BOOL"}, --最后一轮 最后一个玩家只能跟注

	{"bCardShape","BYTE"},		--牌型
}




--游戏开始
GameMsg.BeginUpgradeStruct ={	
	{"bNtStation","BYTE"},					--庄家        
	{"iGuoDi","INT"},			--锅底
	{"iLimtePerNote","LLONG"},	--  暗注上限，明注需要 * 2
}

--发牌数据包
GameMsg.SendCardStruct ={
	{"bCard","BYTE["..PLAY_COUNT.."]["..MAX_CARD_COUNT.."]"},	--牌标号
	{"bCardCount","BYTE["..PLAY_COUNT.."]"},	--牌张数
}


--游戏开始数据包
GameMsg.BeginPlayStruct ={	
	{"iOutDeskStation","BYTE"},	--出牌的位置
	{"bNtPeople","BYTE"},		--庄家位置
	{"byUserData","BYTE["..PLAY_COUNT.."][2]"},	--确定玩家是否机器人和玩家的牌大小排名（只发给机器人）lym
}


--游戏结束统计数据包
GameMsg.GameEndStruct ={
	{"iUserState","INT["..PLAY_COUNT.."]"},	--四家状态(提前放弃,还是梭)
	{"iCardShape","BYTE["..PLAY_COUNT.."]"},	--四家状态(提前放弃,还是梭)

	{"iTurePoint","LLONG["..PLAY_COUNT.."]"},	--庄家得分
	
	{"iUpGradeStation","BYTE"},		--庄家位置
	-- {"bCard","BYTE["..PLAY_COUNT.."]["..MAX_CARD_COUNT.."]"},	--牌标号

	{"bAutoGiveUp","BOOL"},

	{"iHandCard","BYTE[3]"},  --玩家手牌
	{"nWinTime","INT"},									--//连胜局数
}





--看牌数据
GameMsg.Rc_LookCard ={
	{"bDeskStation","BYTE"},		--
	{"iUserCardCount","BYTE"},		--用户手上的牌数
	{"iUserCard","BYTE[3]"},		--用户手上的牌
	{"bForceCompare","BOOL"},		--是否强制比牌
	{"bCardShape","BYTE"},		--牌型
}


--比牌结果
GameMsg.Rc_CompareResult ={
	{"flag","BYTE"},	--0 正常  1 强制比牌	2 全局比牌
	{"iNt","BYTE"},	--比牌者
	{"iNoNt","BYTE"},	--比牌者
	{"iLoster","BYTE"},	--败者
	{"bWinner","BYTE"},	--胜利者，若比牌结束后，下一家马上达到下注上限，则此时客户端需要知道胜利者是谁

	{"iCurNote","LLONG"},	--当前玩家比牌下的下注数
	{"iNote","LLONG"},	 --当前有效注数
	{"bGameFinish","BOOL"},		--是否结束
	{"bRobot","BOOL["..PLAY_COUNT.."]"},		--是否机器人
};


--用户押注
GameMsg.Rc_NoteResult ={
	{"iVerbType","BYTE"},	--下注类型
	{"iOutPeople","BYTE"},	--下注者
	{"iCurNote","LLONG"},		--当前玩家下注数
	-- {"iNote","INT"},	 --当前有效注数
	-- {"bNextDeskStation","BYTE"},
};


--用户请求比牌
GameMsg.Rc_CompareReq ={
	{"bDeskStation","BYTE"},	--请求比牌玩家
};




--玩家动作
GameMsg.Cr_UserProcess ={
	{"iVrebType","BYTE"},	--所处理的按钮
	{"iNote","INT"},		--下注数
	-- {"bMing","BOOL"},		--看牌
	{"byComparedStation","BYTE"},	--被对比牌的玩家
};



--玩家亮牌
GameMsg.Rc_MingCard = {
	{"bDeskStation","BYTE"},
	{"iUserCard","BYTE[3]"},
	{"bCardShape","BYTE"},		--牌型
}


--比牌玩家亮牌
GameMsg.Rc_BiPaiMapCard = {
	{"iCards","BYTE["..PLAY_COUNT.."][3]"},
	{"bCardShapes","BYTE["..PLAY_COUNT.."]"},		--牌型
}



--全局比牌
GameMsg.Rc_CompareFinish ={
	{"bWin","BYTE["..PLAY_COUNT.."]"},		--255 无效位置 0 输 1 赢	
};



--自动跟注
GameMsg.AutoFollow ={
	{"bAutoFollow","BOOL"},  --自动跟注
}

function GameMsg.init()




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






return GameMsg;