local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "水浒传",

    ASS_S_SHZ_ROLL_RESULT = 62,        --滚动结果
    ASS_S_SMALLGAME_RESULT = 72,   --小游戏结果    
    ASS_S_JIANGCHI_INFO_RESULT = 63, --彩金池结果

	ASS_S_UPDATE_POND = 66,		--奖池更新消息

    ASS_C_SHZ_START_ROLL = 82,        --启动游戏滚动
    ASS_C_SMALLGAME_RESULT = 92,  --小游戏结果
    ASS_C_JIANGCHI_INFO = 95 --查询奖池奖励
}

--发送开始
GameMsg.Cr_Packet_StartGame = {
	{"byDeskStation","BYTE"},--座位号
	{"nDeposit","INT"},--单线金币数
    {"nMublite","INT"},--倍数
};

GameMsg.smallGameInfo = {
    {"tbShowKind","INT[5][4]"},
    {"tbResultKind","INT[5]"},
	{"tbResultType","INT[5]"},
	{"nMaryCount","INT"},
}

--转盘结果
GameMsg.Rc_Packet_GameResult = {
	{"iWinMoney","LLONG"},--输赢分数
	{"iTypeImgid","INT[3][5]"},--图形数据
    {"tbSmallWin","GameMsg.smallGameInfo[27]"},
    {"nSmallCount","INT"},
    {"iSmallWinMoney","INT"},
    {"bWinPool","BOOL"},
    {"iPoolPoint","INT"},
    {"nWinTime","INT"},                                 --//连胜局数
};

--发送小游戏选择结果
GameMsg.Cr_Packet_SmallGameSelect = {
	{"nIndex1","INT"},--第几次
	{"nIndex2","INT"},--第几轮
};

--小游戏选择结果
GameMsg.Rc_Packet_SmallGameSelect = {
	{"nIndex1","INT"},--第几次
	{"nIndex2","INT"},--第几轮
};

--彩金池结果
GameMsg.Rc_Packet_CaiJinInfo = {
	{"strName","CHARSTRING[30]"},--昵称  
	{"nYaFen","INT"},--押分   
    {"nBeiShu","INT"},--倍数
    {"nMoney","INT"},--彩金池
    {"CreateDate","INT"},--时间
};

--断线重连数据包
GameMsg.tagChongLian = {
	{"bGameStation","BYTE"},--当前游戏状态
	{"i64UserMoney","LLONG"},
    
    {"iWinMoney","LLONG"},--输赢分数
	{"iTypeImgid","INT[3][5]"},--图形数据
    {"tbSmallWin","GameMsg.smallGameInfo[27]"},
    {"nSmallCount","INT"},
    {"iSmallWinMoney","INT"},
    {"bWinPool","BOOL"},
    {"iPoolPoint","INT"},

    {"nIndex1","INT"},--第几次
	{"nIndex2","INT"},--第几轮

    {"iCellMoney","INT"},
    {"nMublite","INT"},
    {"nCurrentSmallWin","INT"},
};

--奖池更新
GameMsg.Cr_Packet_UpdatePool = {
	{"iPoolPoint","INT"},--奖池分数
};

function GameMsg.init()

end

return GameMsg;
