local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "连环夺宝",

    ASS_S_ROLL_RESULT = 62,        --滚动结果

	ASS_S_UPDATE_POND = 66,		--奖池更新消息

    ASS_C_START_ROLL = 82,        --启动游戏滚动
    ASS_C_SMALLGAME_INFO = 84,  --客户端发服务端 小游戏
    ASS_S_SMALLGAME_RESULT = 63,   --小游戏结果    
    ASS_C_QUIT_WITH_SAVE   =  85,--保存进度退出游戏

}

--发送开始
GameMsg.Cr_Packet_StartGame = {
    {"byDeskStation","BYTE"},--座位号
	{"scorePerLine","INT"},
    {"lineCount","INT"},
   
};


--发送小游戏
GameMsg.smallGameStart = {

   
};


GameMsg.smallGameInfo = {
	{"iWinMoney","INT"},--输赢分数
    {"nSamllGame","INT[5]"},
    {"nWinSamllIndex","INT"},
}

--转盘结果
GameMsg.Rc_Packet_GameResult = {
	{"iWinMoney","LLONG[7]"},--输赢分数
	{"iTypeImgInfo","GameMsg.ImgidInfo[7]"},--图形数据
    {"iRemoveTypeImgid","GameMsg.iRemoveTypeInfo[7]"},--消除图形队列数据   
    {"iRemoveNum","INT"},--消了几轮
    
    {"iLevel","INT"},
    {"iProgress","INT"},
    {"iJiangChiPoint","LLONG"},
    {"bWinPool","INT"},
    {"nTotalWin","INT"},
    {"nWinTime","INT"},                                 --//连胜局数
};




GameMsg.iRemoveTypeImgInfo = {
    {"iRemoveImg","BYTE[7][6]"},
}

GameMsg.iRemoveTypeInfo = {
    {"iRemoveTypeImgInfo","GameMsg.iRemoveTypeImgInfo[7]"},
	{"nRemoveNum","INT"}, --次数
}

GameMsg.ImgidInfo = {
    {"iTypeImgid","BYTE[7][6]"},
}


--断线重连数据包
GameMsg.tagChongLian = {
	{"bGameStation","BYTE"},--当前游戏状态
    {"iJiangChiPoint","LLONG"},
    {"scorePerLine","INT"},
    {"lineCount","INT"},
  
    {"level","INT"},
    {"progress","INT"},
    {"nTotalWinMoney","INT"},
};

--奖池更新
GameMsg.Cr_Packet_UpdatePool = {
	{"iPoolPoint","LLONG"},--奖池分数
};


function GameMsg.init()

end

return GameMsg;
