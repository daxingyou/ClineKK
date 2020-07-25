local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "糖果派对",

    ASS_S_ROLL_RESULT = 62,        --滚动结果
    ASS_S_SMALLGAME_RESULT = 69,   --小游戏结果  

	ASS_S_UPDATE_POND = 66,		--奖池更新消息  

    ASS_C_START_ROLL = 82,        --启动游戏滚动
    ASS_C_SMALLGAME_INFO = 84,  --小游戏结果
    ASS_C_QUIT_WITH_SAVE   =  85,--保存进度退出游戏
}

--发送开始
GameMsg.Cr_Packet_StartGame = {
--	{"byDeskStation","BYTE"},--座位号
--	{"nDeposit","INT"},--单线金币数
--    {"nMublite","INT"},--倍数
    {"byDeskStation","BYTE"},--座位号
	{"nDeposit","INT"},--单线金币数
    {"nMublite","INT"},--倍数
};

GameMsg.smallGameInfo = {
    {"nPos","INT"},
	{"nReward","INT"}, --次数
    {"tbOtherReward","INT[4]"},
}

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

--转盘结果
GameMsg.Rc_Packet_GameResult = {
	{"iWinMoney","LLONG[7]"},--输赢分数
	{"iTypeImgInfo","GameMsg.ImgidInfo[7]"},--图形数据
    {"iRemoveTypeImgid","GameMsg.iRemoveTypeInfo[7]"},--消除图形队列数据   
    {"iPoolPoint","LLONG[4]"}, --奖池分数
    {"iRemoveNum","INT"},--消了几轮
    {"iLevel","INT"},
    {"iProgress","INT"},
    {"iSmallWinMoney","INT"}, --免费游戏倍数
    {"iFreeGame","INT"}, --免费游戏次数
    {"nWinPool","INT"},  --彩金糖果赢取分数
    {"nCaijinNum","INT"}, --彩金糖果的数量
    {"nSmallTotalWin","INT"}, --彩金糖果的数量
    {"nWinTime","INT"},                                 --//连胜局数
};



--断线重连数据包
GameMsg.tagChongLian = {
	{"bGameStation","BYTE"},--当前游戏状态
	{"iPoolPoint","LLONG[4]"}, -- 奖池
    {"iFreeGames","INT"}, --免费游戏次数
    {"scorePerline","INT"}, --下方每注分数
    {"linecount","INT"}, --下方注数
    {"nFreeGameBeilv","INT"}, --小游戏倍率
    {"level","INT"}, --关卡数
    {"progress","INT"}, --消除糖果数
};

--奖池更新
GameMsg.Cr_Packet_UpdatePool = {
	{"iPoolPoint","LLONG[4]"},--奖池分数
};

function GameMsg.init()

end

return GameMsg;
