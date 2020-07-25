local GameMsg = { 
-- //文件名字定义
	GAMENAME                   	=     "电竞",

	ASS_GP_EC_LIST                  =       1,                           --//获取电竞列表
    ASS_GP_EC_BET                   =       2,                           --//下注
    ASS_GP_EC_RESULT                =       3,                           --//获取战绩
    ASS_GP_SPECIAL_EC_LIST          =       4,                           --//获取所有的电竞列表
    ASS_GP_CLASS_EC_LIST            =       5,                           --//获取赛事分类
    ASS_GP_GAMETYPE_EC_LIST         =       6,                           --//赛事专题下的比赛列表
    ASS_GP_EVENT_EC_LIST            =       7,                           --//获取某项目下比赛列表
    ASS_GP_REALTIME_INFO            =       8,                           --//比赛动态信息

    MAX_EC_BYTE                     =       950,                        --//数据的字节

}


--------------------------------电竞--------------------------------------
GameMsg.MSG_GP_EC_LIST =
{
    {"info1","CHARSTRING["..GameMsg.MAX_EC_BYTE.."]"}, 
    {"info2","CHARSTRING["..GameMsg.MAX_EC_BYTE.."]"}, 
    {"info3","CHARSTRING["..GameMsg.MAX_EC_BYTE.."]"}, 
    {"info4","CHARSTRING["..GameMsg.MAX_EC_BYTE.."]"},
    {"EventID","INT"},
    {"GameID","INT"}, 
    {"uSize","INT"},
    {"IsFirst","INT"},
};

GameMsg.MSG_GP_GET_SPECIAL_EC_LIST =
{
    {"EventID","INT"},
};

GameMsg.MSG_GP_GET_GAMETYPE_EC_LIST =
{
    {"EventID","INT"},
    {"GameID","INT"}, 
};

GameMsg.MSG_GP_EC_BET =
{
    {"EventID","INT"},
    {"MatchID","INT"},
    {"BetID","INT"},
    {"BetNumID","INT"},
    {"UserID","INT"},
    {"lScore","LLONG"},
};

GameMsg.MSG_GP_EC_BET_RESULT =
{
    {"lRet","INT"},
    {"EventID","INT"},
    {"MatchID","INT"},
    {"BetID","INT"},
    {"UserID","INT"},
    {"lScore","LLONG"},
    {"Rat","INT"},
};

GameMsg.MSG_GP_RC_RESULT = 
{
    {"lUserID","INT"},
}

GameMsg.MSG_GP_EC_RESULT =
{
    {"lEventID","INT"},
    {"lMatchID","INT"},
    {"lBetID","INT"},
    {"lBetNumID","INT"},
    {"lUserID","INT"},
    {"lBetScore","LLONG"},
    {"lBetRat","INT"},
    {"lMatchState","INT"},
    {"lWinScore","LLONG"},
    {"lTime","INT"},
    {"lEndTime","INT"},
};


function GameMsg.init()

end

return GameMsg;
