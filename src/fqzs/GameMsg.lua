
local GameMsg = { 
	SUPER_PLAYER               	=     10,              	--//超级玩家
	INVALID_CHAIR			   	=     255,				--//无效椅子
-- //文件名字定义
	GAMENAME                   	=     "飞禽走兽",

-- //版本定义
	GAME_MAX_VER                =    1,               	--//现在最高版本
	GAME_LESS_VER               =    1,              	--//现在最低版本
	GAME_CHANGE_VER             =    0,               	--//修改版本

-- //游戏开发版本
	DEV_HEIGHT_VERSION          =    10,              	--//内部开发高版本号
	DEV_LOW_VERSION             =    1,               	--//内部开发低版本号

-- //数目定义
	MAX_COUNT					=     180,									--//最大数目

-- -- //游戏信息
-- 	NAME_ID                     =    30002600,        	--//名字 ID
-- 	MAX_NAME_INFO               =    256,

-- //异常类消息
	
	--//游戏状态定义
	GS_WAIT_SETGAME 	      =  0,			--//等待东家设置状态
	GS_XIAZHU	              =	20,			--//下注状态
	GS_XIAZHU_FINISH          = 21,
	GS_KAIJIANG               = 22,
	GS_GAME_FINISH            = 23,
	GS_WAIT_NEXT	          =	24,			--//等待下一盘开始 
	GS_PAUSE                  = 25,	        --//游戏暂停阶段
	ASS_BEGIN		          = 55,          
	ASS_XIAZHU                = 56,         --//下注 
	ASS_PLAY_GAME	          =	57,         --//	开始转盘
	ASS_SHOW_RESULT  		  = 58,         --// 显示转盘结果
	ASS_NEWTURN_START		  = 59,         -- //开始新一局       
	ASS_CONTINUE_END 	  	  =	60,
	--///服务器消息响应

	ASS_XIAZHU_RESULT    	  = 61,         --//  下注结果
	-- ASS_HANDOFF 			  = 62,         --//筹码切换
	ASS_XIAZHU_RESULT_EX      =62,      	--//续投

	ASS_SHANG_ZHUANG          = 70,          --/**< 上庄消息 */
	ASS_ZHUANG_MSG            = 71,          -- /**庄信息*/
	ASS_WU_ZHUANG             = 72,          --/**< 游戏无庄闲置消息消息*/
	ASS_CHANGE_NT			  = 73,			 --//换庄消息
	ASS_ERROR_CODE			  = 74,			 --//错误信息
	ASS_ZHUANG_SCORE		  = 75,			 --//庄家坐庄期间输赢金币

	ASS_USER_CUT              = 82,              --//玩家断线了

}

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

--/// 游戏开始消息结构
GameMsg.GameBeginStruct ={
	{"iBaseNote", "LLONG"},  			-- 底注
	{"iLimitNote", "LLONG"},  			--最大注数
	{"iMyMoney", "LLONG"},   			--自己金币
	{"iSingleNoteLimit", "LLONG"},  	--单个个人下注限额
	{"imultiplying", "INT[12]"},   		--倍率
	{"iTime", "INT"},  					--
	{"iNTStation", "BYTE"}, 			--//庄家位置
	{"iZhuangBaShu", "INT"},  			--//当前坐庄把数
};


--//游戏下注响应
GameMsg.GameXiaZhuRsp ={
	{"iType", "INT"},  					-- 类型0 ~ 14 ,走兽(0-猴子、1-狮子、2-熊猫、3-兔子)、飞禽(4-老鹰、5-孔雀、6-鸽子、7-燕子)、8-银鲨鱼、9-金鲨鱼，10-走兽*2，11-飞禽*2，12 - 续押，13 -	清空。
	{"iOwnAllCountNote", "INT"},  		--每个玩家自己下注总数（总押分）
	{"bDeskStation", "BYTE"},   		--玩家座位号
	{"iOwnNotes", "INT[12]"},  			--自己每个框下注数
	{"iNoteNum", "INT"},   		   		--单次下注值
	{"iUserMoney", "LLONG"},  			--
	{"iNotebyregion", "INT[12]"},  		-- 单个区域总的下注
	{"iOneAllNum", "INT[12]"},  		-- 单个区域总下注数，用来显示给玩家看
};

--下注
GameMsg.GameXiaZhu ={
	{"iType", "INT"}, 
	{"iNoteNum", "INT"},
};	

--续投
GameMsg.Cr_Packet_XiaZhuEx ={
	{"money", "LLONG[12]"},
};	

--续投
GameMsg.Rc_Packet_XiaZhuResultEx ={
	{"iOwnAllCountNote", "INT"}, 	--//每个玩家自己下注总数（总押分）
	{"bDeskStation", "BYTE"},		--//玩家座位号
	{"iOwnNotes", "INT[12]"},		--//自己每个框下注数
	{"money", "LLONG[12]"},
	{"iUserMoney", "LLONG"},
	{"iOneAllNum", "INT[12]"},		--//单个区域总下注数，用来显示给玩家看
};



--//游戏下注通知
GameMsg.GameNote ={
	{"bDeskStation", "BYTE"},  		--
	{"iTime", "INT"},   
};
	
--///发送开始转动消息
GameMsg.GamePlay ={
	{"iStarPos", "INT"},   		--开始位置
	{"iEndPos", "INT"},			--结束位置
	{"iWinnings", "INT"},		--彩金
	{"iEndAnimal", "INT"},
	{"iIsShedeng", "BOOL"},
	{"iTime", "INT"},
};
	
--///发送转动结果消息
GameMsg.GamePlayResult ={
	{"iEndPos", "INT"},   			--结束位置
	{"iEndDigree", "INT"},			--	
	{"iWinnings", "INT"},			--彩金
	{"iEndAnimal", "INT"},   		--	
	{"bIsShark", "INT"},			--射灯之前是金鲨还是银鲨（0 --都不是，1--金鲨 ，2-- 银鲨）
	{"imultiplying", "INT[12]"},
};

--//游戏结束统计数据包
	
--///发送结算结果消息
GameMsg.GameEndStruct ={
	{"iNowNTStation", "BYTE"},			--本局庄家
	{"iHistory", "INT[30]"},			--路子
	{"iOwnPoint", "LLONG"},  			--玩家得分
	{"iNTPoint", "LLONG"},  			--庄家得分
	{"iOtherPoint", "LLONG"},  			--闲家得分
	{"iOwnAllCountNote", "INT"},  		--玩家总下注
	{"i64Money", "LLONG"},  			--当前金币
	{"nWinTime","INT"},									--//连胜局数
};


--//游戏结束统计数据包
GameMsg.GameCutStruct ={
	{"iRoomBasePoint", "INT"}, 		--倍数
	{"iDeskBasePoint", "INT"},		--桌面倍数
	{"iHumanBasePoint", "INT"},		--人头倍数
	{"bDeskStation", "INT"},		--退出位置
	{"iChangeMoney", "INT[8]"},		--玩家金币
	{"iTurePoint", "INT[5]"},		--庄家得分
};

GameMsg.GameHandoff ={
	{"iNoteNum", "INT"},
};

--///上庄数据包
GameMsg.tagShangZhuang ={
	{"bCancel", "BOOL"},
	{"ntListNum", "BYTE"}, 			--庄家申请人数
	{"shang", "BOOL"}, 				--true为上庄，false 为下庄
	{"success", "INT"}, 			--0 失败 1 成功 2 加入上庄列表 3取消上庄 4
	{"station", "BYTE"}, 			--申请的位置
	{"iLimitmoney", "LLONG"}, 		--上庄最少金币数
	{"IsRobot", "BOOL"}, 
	{"iNTList","BYTE[10]"},             --上庄列表
};

GameMsg.tagChangeZhuang ={
	{"station", "BYTE"}, 			--//庄家
	{"ntListNum", "BYTE"},  		--//申请上庄人数
	{"nickName", "CHARSTRING[100]"},  	--//庄家昵称
	{"i64Money", "LLONG"},  		--//庄家金币
	{"iNTList","BYTE[10]"},             --上庄列表
}

GameMsg.ShangZhuangRsp ={
	{"bCancel", "BOOL"},
	{"shang", "BOOL"}, 				--true为上庄，false 为下庄
	{"IsRobot", "BOOL"}, 	
};

--错误信息
GameMsg.Rc_ErrorCode = {
	{"errorCode","INT"},--错误信息
};


-- //场景
GameMsg.GameStation ={
	{"bGameStation", "BYTE"}, 			--游戏状态
	{"iMyMoney", "LLONG"}, 	   			--自己金币
	{"iSingleNoteLimit", "LLONG"}, 	 	--单个个人下注限额
	{"imultiplying", "INT[12]"}, 		--倍率
	{"iTime", "INT"}, 	
	{"iHistory", "INT[30]"}, 	   		--路子
	{"iOwnNotes", "INT[12]"}, 			--区域下注
	{"iNowNTStation", "BYTE"}, 			--当前庄家
	{"zhuangStatus", "INT"}, 			--庄状态 0 非庄 1 在庄  2 在上庄列表 3 取消下庄  
	{"iNTListNum", "BYTE"},  			--上庄申请人数	
	{"ishangzhuangLimit", "LLONG"}, 	 	--上庄最少金币
	{"ixiazhuangLimit", "LLONG"}, 	 	--下庄最少金币
	{"iNTList","BYTE[10]"},             --上庄列表
	{"bEnableSysBanker","BOOL"},     --//系统坐庄
};

GameMsg.CMD_S_GameStatus = {
	{"gameStation", "GameMsg.GameStation"}, 
	{"iBaseNote", "LLONG"},     		--底注
	{"iLimitNote", "LLONG"}, 			--最大注数
	{"iMyMoney", "LLONG"},   			--自己金币
	{"iOneAllNum", "INT[12]"},  		--单个区域总下注数，用来显示给玩家看
};

--庄家坐庄期间输赢金币
GameMsg.BankGetMonry = {
	{"money","LLONG"},--庄家坐庄期间输赢金币
};

function GameMsg.init()

end

return GameMsg;
