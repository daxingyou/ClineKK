local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "超级水果机",

    ASS_S_ROLL_RESULT = 62,        --滚动结果
    ASS_S_SMALLGAME_RESULT = 63,   --小游戏结果

	ASS_S_UPDATE_POND = 66,		--奖池更新消息

    ASS_C_START_ROLL = 82,        --启动游戏滚动
    ASS_C_SMALLGAME_INFO = 84,  --小游戏结果
}

--发送开始
GameMsg.Cr_Packet_StartGame = {
	{"byDeskStation","BYTE"},--座位号
	{"nDeposit","INT"},--单线金币数
};

GameMsg.smallGameInfo = {
	{"nPos","INT"},
	{"nReward","INT"},
    {"tbOtherReward","INT[4]"},
}

--转盘结果
GameMsg.Rc_Packet_GameResult = {
	{"iWinMoney","LLONG"},--输赢分数
	{"iTypeImgid","INT[3][5]"},--图形数据
    {"tbSmallWin","GameMsg.smallGameInfo[4]"},
    {"iSmallWinMoney","INT"},
    {"bSmallGame","BOOL"},
    {"iFreeGame","INT"},
    {"bWinPool","BOOL"},
    {"iPoolPoint","INT"},
    {"nWinTime","INT"},                                 --//连胜局数
};

--发送小游戏选择结果
GameMsg.Cr_Packet_SmallGameSelect = {
	{"nStep","INT"},--第几关
	{"nPos","INT"},--第几个位置
};

--小游戏选择结果
GameMsg.Rc_Packet_SmallGameSelect = {
	{"nStep","INT"},--第几关
	{"nPos","INT"},--第几个位置
};

--断线重连数据包
GameMsg.tagChongLian = {
	{"bGameStation","BYTE"},--当前游戏状态
	{"iPoolPoint","INT"},
    
    {"bSmallGame","BOOL"},
    {"iSmallWinMoney","INT"},
    {"iFreeGame","INT"},
    {"iCellMoney","INT"},
    {"tbSmallWin","GameMsg.smallGameInfo[4]"},
};

--奖池更新
GameMsg.Cr_Packet_UpdatePool = {
	{"iPoolPoint","INT"},--奖池分数
};

function GameMsg.init()

end

return GameMsg;
