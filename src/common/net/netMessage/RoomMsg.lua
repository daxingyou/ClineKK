local RoomMsg = {
    MAX_TALK_LEN                    =          500,                      --//最大聊天数据长度


--/// 通信标识定义
    MDM_CONNECT                     =           88,                      --心跳
    ASS_NET_TEST_1                  =           1,
--//连接消息
    MDM_GR_CONNECT                  =           1,                       --//连接消息类型
    ASS_GR_CONNECT_SUCCESS          =           3,
    MDM_GP_GETCODE                  =           5,
    MDM_GP_GETROOMINFO              =           24,                       --//房间桌子情况

--//登录游戏房间的相关定义

    MDM_GR_LOGON                    =           100,                     --//登陆游戏房间

    MDM_GR_QUEUE_MSG                =           114,                     --///排队消息

--//登录返回结果
    ASS_GR_LOGON_SUCCESS            =           2,                       --//登陆成功
    ASS_GR_LOGON_ERROR              =           3,                       --//登陆失败
    ASS_GR_SEND_FINISH              =           4,                       --//登陆完成
    ASS_GR_LOGON_BY_ID              =           5,                       --//通过用户ID登陆
    ASS_GR_GET_USEREXPAND           =           6,                       --///获取用户扩展信息

    ASS_GR_IS_VIPROOM               =           16,                      --//是否VIP房间
    ASS_GR_VIP_PW                   =           17,                      --//VIP房间需要密码
    ASS_GR_VIP_NO_PW                =           18,                      --//VIP房间不需要密码(第一个进入不需要密码)
    ASS_GR_NO_VIP                   =           19,                      --//不是VIP房间
    ASS_GR_VIPROOM_PW               =           20,                      --//VIP房间密码
    ASS_GR_VIPROOM_PW_RIGHT         =           21,                      --//VIP房间密码正确

--//匹配房间
    ASS_BEGIN_MATCH_ROOM            =           22,                      --//匹配房间
    ASS_END_MATCH_ROOM              =           23,                      --//取消匹配
    ERR_GR_FULL_DESK                =           100000,                  --//桌子已经满了
    ERR_GR_NO_ENOUGH_ROOM_KEY       =           255,                     --//玩家钻石不足
    ERR_GR_IN_ROOM                  =           254,                     --//玩家正在游戏中
    ERR_GR_GUILD_MATCHERR           =           253,                     --//公会房间匹配错误

--//服务端主动推送
--//用户列表主ID
    MDM_GR_USER_LIST                =           101,                     --//登录成功后返回个人信息以及该房间玩家信息
--//用户列表辅助ID
    ASS_GR_ONLINE_USER              =           1,                       --//在线用户
    ASS_GR_NETCUT_USER              =           2,                       --//断线用户
    ASS_GR_DESK_STATION             =           3,                       --//桌子状态


--//客户端发送

--//玩家动作
    MDM_GR_USER_ACTION              =           102,                     --//用户动作，玩家坐桌，起身，断线等都是以该值为主标志
--//玩家动作辅助ID
    ASS_GR_USER_UP                  =           1,                       --//用户起来
    ASS_GR_USER_SIT                 =           2,                       --//用户坐下
    ASS_GR_WATCH_UP                 =           3,                       --//旁观起来
    ASS_GR_WATCH_SIT                =           4,                       --//旁观坐下

    ASS_GR_USER_COME                =           5,                       --//用户进入
    ASS_GR_USER_LEFT                =           6,                       --//用户离开

    ASS_GR_USER_CUT                 =           7,                       --//用户断线
    ASS_GR_SIT_ERROR                =           8,                       --//坐下错误
    ASS_GR_SET_TABLE_BASEPOINT      =           9,                       --//改变桌子倍数

    ASS_GR_USER_HIT_BEGIN           =           10,                      --//用户同意开始

    ASS_GR_JOIN_QUEUE               =           11,                      --//加入排队机
    ASS_GR_QUIT_QUEUE               =           12,                      --//退出排队机
    ASS_GR_QUEUE_USER_SIT           =           13,                      --//排队用户坐下
    ASS_GR_LEASE_TIMEOVER           =           14,                      --//排队用户坐下
    ASS_GR_CONTEST_APPLY            =           24,                      --//比赛场报名
    ASS_GR_CONTEST_CANCEL           =           16,                      --//比赛场退赛
    ASS_GR_EXPERCISE_OUTTIME        =           27,                      --//练习场超时

--//玩家动作部分操作结果：（专用于比赛房间）
    ERR_GR_APPLY_SUCCEEDED          =           1,                       --//参赛或退赛成功
    ERR_GR_APPLY_ALREADYSIGN        =           2,                       --//已经报名
    ERR_GR_APPLY_BEGIN              =           3,                       --//比赛已经开始
    ERR_GR_APPLY_NOTENOUPH_MONEY    =           4,                       --//由于钱包金币不够，导致报名失败


--//房间信息
    MDM_GR_ROOM                     =           103,
--//房间信息辅助ID
    ASS_GR_NORMAL_TALK              =           1,                   --//普通聊天
    ASS_GR_HIGH_TALK                =           2,                   --//高级聊天
    ASS_GR_USER_AGREE               =           3,                   --//用户同意
    ASS_GR_GAME_BEGIN               =           4,                   --//游戏开始
    ASS_GR_GAME_END                 =           5,                   --//游戏结束
    ASS_GR_USER_POINT               =           6,                   --//用户经验值
    ASS_GR_SHORT_MSG                =           7,                   --//聊短信息
    ASS_GR_ROOM_SET                 =           8,                   --//房间设置
    ASS_GR_INVITEUSER               =           9,                   --//邀请用户
    ASS_GR_INSTANT_UPDATE           =           10,                  --//即时更新分数金币
    ASS_GR_UPDATE_CHARM             =           11,                  --//即时更新魅力
    ASS_GR_ROOM_PASSWORD_SET        =           12,                  --//房间设置
    ASS_GR_ROOM_QUEUE_READY         =           13,                  --//排队机准备
    ASS_GR_GET_NICKNAME_ONID        =           14,                  --//根据ID获取昵称
    ASS_GR_OWNER_T_ONE_LEFT_ROOM    =           15,                  --//房主踢玩家离开房间
    ASS_GR_GET_NICKNAME_ONID_INGAME =           16,                  --//根据ID获取昵称 游戏中
    ASS_GR_USER_CONTEST             =           17,                  --//用户比赛信息，发送NET_ROOM_CONTEST_CHANGE_RESULT，排名有更改
    ASS_GR_AVATAR_LOGO_CHANGE       =           18,                  --//用户形象更改信息
    ASS_GR_CAHNGE_ROOM              =           19,                  --//比赛开始，未报名用户切换房间
    ASS_GR_CONTEST_GAMEOVER         =           20,                  --//比赛结束
    ASS_GR_CONTEST_KICK             =           21,                  --//用户被淘汰
    ASS_GR_CONTEST_WAIT_GAMEOVER    =           22,                  --//比赛结束，但是有用户还在打最后一局，通知已打完的用户等待排名
    ASS_GR_INIT_CONTEST             =           23,                  --//比赛开始，初始化比赛信息，发送NET_ROOM_CONTEST_CHANGE_RESULT，初始化排名信息
    ASS_GR_CONTEST_PEOPLE           =           24,                  --//获取报名数量，登陆完成后服务端主动发送NET_ROOM_CONTEST_PEOPLE_RESULT
    ASS_GR_CONTEST_RECORD           =           25,                  --//个人参赛纪录，登陆完成后服务端主动发送NET_ROOM_CONTEST_RECORD_RESULT
    ASS_GR_CONTEST_AWARDS           =           26,                  --//比赛奖励，一连串的NET_ROOM_CONTEST_AWARD_RESULT
    ASS_GR_CONTEST_GETINFO          =           27,                  --//获取比赛信息（服务端返回24,25,26三个消息包）


--//框架消息
    MDM_GM_GAME_FRAME               =           150,                     --//框架消息
--//框架消息辅助ID
    ASS_GM_GAME_INFO                =           1,                       --//游戏信息
    ASS_GM_GAME_STATION             =           2,                       --//游戏状态
    ASS_GM_FORCE_QUIT               =           3,                       --//强行退出
    ASS_GM_NORMAL_TALK              =           4,                       --//普通聊天
    ASS_GM_HIGH_TALK                =           5,                       --//高级聊天
    ASS_GM_WATCH_SET                =           6,                       --//旁观设置  
    ASS_GM_CLEAN_USER               =           9,                       --//比赛场清理用户信息
    ASS_GM_USE_KICK_PROP            =           7,                       --//使用踢人卡
    ASS_GM_USE_ANTI_KICK_PROP       =           8,                       --//使用防踢卡
    ASS_GM_SET_VIDEOADDR            =           10,                      --//设置视频服务器地址
    ASS_GM_STATISTICS               =           11,                      --//总局通知
    ASS_GM_DESKLOCKPASS_UNUSE       =           12,                      --///桌子密码已经超时，请桌子上所有的玩家离开此桌子
    ASS_GM_DESKLOCKPASS_TIMEOUT     =           13,                      --///桌子已经超过五分钟未开始了，清场重置
    CODE_GM_STATISTICS_PART         =           1,                       --//一部分数据
    CODE_GM_STATISTICS_FINISH       =           2,                       --//最后的数据

    ASS_VOICE_CHAT_MSG              =           15,                      --//主意传输
    ASS_VOICE_CHAT_MSG_FINISH       =           16,                      --//语音传输完成

    ASS_CONTINUE_NEXT_ROUND         =           17,                      --//继续下一轮消息
    ASS_RETRY_MATCH                 =           31,                      --//玩家重新报名

    ASS_GR_USERSCORELOG             =           33,                      --//获取用户日志
    ASS_GR_NEWUSERSCORELOG          =           34,                      --//新的用户日志      


--//通知消息
    MDM_GM_GAME_NOTIFY              =           180,                     --//游戏消息
    ASS_GM_AGREE_GAME               =           1,                       --//同意游戏
    ASS_GR_CHANGE_OWNER             =           3,                       --//切换房主
    ASS_GR_USERINFO_GET             =           4,                       --//获取用户信息

--///错误代码
    ERR_GR_ERROR_UNKNOW             =           0,                       --//未知错误
    ERR_GR_LOGON_SUCCESS            =           1,                       --//登陆成功
    ERR_GR_USER_NO_FIND             =           2,                       --//用户不存在
    ERR_GR_USER_PASS_ERROR          =           3,                       --//用户密码错误
    ERR_GR_USER_VALIDATA            =           4,                       --//用户帐号禁用
    ERR_GR_USER_IP_LIMITED          =           5,                       --//登陆 IP 禁止
    ERR_GR_IP_NO_ORDER              =           6,                       --//不是指定地址
    ERR_GR_ONLY_MEMBER              =           7,                       --//会员游戏房间
    ERR_GR_IN_OTHER_ROOM            =           8,                       --//正在其他房间
    ERR_GR_ACCOUNTS_IN_USE          =           9,                       --//帐号正在使用
    ERR_GR_PEOPLE_FULL              =           10,                      --//人数已经满
    ERR_GR_LIST_PART                =           11,                      --//部分用户列表
    ERR_GR_LIST_FINISH              =           12,                      --//全部用户列表
    ERR_GR_STOP_LOGON               =           13,                      --//暂停登陆服务
    ERR_GR_GAME_END                 =           20,                      --游戏结束，房间已结束

    ERR_GR_CONTEST_NOSIGNUP         =           14,
    ERR_GR_CONTEST_TIMEOUT          =           15,
    ERR_GR_CONTEST_KICK             =           16,
    ERR_GR_CONTEST_NOTSTRAT         =           17,
    ERR_GR_CONTEST_OVER             =           18,
    ERR_GR_CONTEST_BEGUN            =           19,

    ERR_GR_GUILDERR                 =           21,                     --VIP厅ID错误
    ERR_GR_GUILD_ROOMERR            =           22,                     --///公会房间错误

    ERR_GR_MATCH_LOGON              =           160,                     --//游戏房间
    ERR_GR_TIME_OVER                =           161,                     --//时间到期

--///不在混战场活动时间内
    ERR_GR_BATTLEROOM_OUTTIME       =           162,

--///用户坐下错误码
    ERR_GR_SIT_SUCCESS              =           50,                      --//成功坐下
    ERR_GR_BEGIN_GAME               =           51,                      --//游戏已经开始
    ERR_GR_ALREAD_USER              =           52,                      --//已经有人存在
    ERR_GR_PASS_ERROR               =           53,                      --//密码错误
    ERR_GR_IP_SAME                  =           54,                      --//IP 相同
    ERR_GR_CUT_HIGH                 =           55,                      --//断线率太高
    ERR_GR_POINT_LOW                =           56,                      --//经验值太低
    ERR_GR_POINT_HIGH               =           57,                      --//经验值太高
    ERR_GR_NO_FRIEND                =           58,                      --//不受欢迎
    ERR_GR_POINT_LIMIT              =           59,                      --//经验值不够
    ERR_GR_CAN_NOT_LEFT             =           60,                      --//不能离开
    ERR_GR_NOT_FIX_STATION          =           61,                      --//不是这位置
    ERR_GR_MATCH_FINISH             =           62,                      --//比赛结束
    ERR_GR_MONEY_LIMIT              =           63,                      --//金币太低
    ERR_GR_MATCH_WAIT               =           64,                      --//比赛场排队提示
    ERR_GR_IP_SAME_3                =           65,                      --//IP前3 相同
    ERR_GR_IP_SAME_4                =           66,                      --//IP前4 相同
    ERR_GR_UNENABLE_WATCH           =           67,                      --//不允许旁观
    ERR_GR_DESK_FULL                =           68,                      --// 百家乐 桌子座位满了，无法分配座位给玩家 
    ERR_GR_WAIT_DESK_RECYLE         =           69,                      --///桌子还没有回收，暂时不能用

--//封桌
    MDM_GR_MANAGE                   =           115,
    ASS_GR_ALONE_DESK               =           15,                      --//封桌
    ASS_GR_DEALONE_DESK             =           16,                      --//解封

    --银行存取分
    ASS_STORE_SCORE                 =           18,                      --//游戏存分
    ASS_GET_SCORE                   =           19,                      --//游戏取分
    --救济金
    ASS_JIUJI_RESULT                =           20,                      --//发送救济金结果
    ASS_JIUJI_TIPS                  =           21,                      --//发送救济金提示
    ASS_LEVEL_UP                    =           22,                      --//发送升级提示
    ASS_GET_TASKLIST                =           23,                      --//获取任务列表
    ASS_UPDATE_TASK                 =           24,                      --//获取任务奖励
    ASS_SEND_COMPLETETASK           =           26,                      --//获取完成任务数量
    ASS_SEND_BUYMONEY               =           27,                      --//获取购买成功
    ASS_GET_GOODSINFO               =           28,                      --//获取物品信息
    ASS_UPDATE_GOODSINFO            =           29,                      --//更新物品信息
    ASS_SYN_GOODSINFO               =           30,                      --
    ASS_BUY_PaoTai                  =           32,                      --//玩家购买炮台
    ASS_ROOM_GUILD_CHANGE           =           33,                      --//公会修改
    HC_ROOM_GUILD_DELETE            =   1,  --///解散
    HC_ROOM_GUILD_TAXRATE           =   2,  --///税率修改
    HC_ROOM_GUILD_CLOSEROOM         =   3,  --///关闭房间
    HC_ROOM_GUILD_KICK              =   4,  --///被踢出厅
--系统消息
    MDM_GR_MESSAGE                  =           151,
    ASS_GR_SYSTEM_MESSAGE           =           1,                       --///系统消息

    MDM_GP_EC_INFO                  =       161,                         --//客户端电竞消息

    --//房间信息
    MZTW_ROOMINFO                   =           5,                       --//通知房间信息id
    ASS_ZTW_GAMERECORED             =           1,                      --//通知游戏记录
    ASS_ZTW_NEWGAMERECORED          =           2,                      --//通知新游戏记录
    ASS_ZTW_CHANGEGAMESTATION       =           3,                      --//修改游戏状态

}

--///获取用户扩展信息
RoomMsg.MSG_GR_S_GetUserExpand =
{
    {"dwUserID","INT"},                           --///用户 ID
};

--//用户基本信息扩展
RoomMsg.UserInfoExpand =
{
    {"UserID","INT"}, 
    {"iLotteries","DOUBLE"}, --//礼券
    {"ExpPlus","INT"},
    {"IonPlus","INT"},
    {"FallCardPlus","INT"},
    {"HongBaoCount","INT"},
    {"BasicBonus","INT"},
};


--//物品变化结果
RoomMsg.CMD_S_UPDATE_GOODSINFO =
{ 
    {"ret","INT"},
    {"code","INT"},  
    {"UserID","INT"}, 
    {"goodsID","INT"}, 
    {"goodsCount","INT"},
};

--//获取物品列表
RoomMsg.CMD_C_GET_GOODSINFO =
{
    {"UserID","INT"}, 
};

--//使用物品
RoomMsg.CMD_C_GOODSINFO =
{
    {"UserID","INT"}, 
    {"goodsID","INT"}, 
    {"goodsCount","INT"}, 
};

--//操作物品同步
RoomMsg.CMD_S_SYN_GOODSINFO = {
    {"code","INT"},
    {"UserID","INT"}, 
    {"goodsID","INT"}, 
    {"goodsCount","INT"},
}

--房间充值刷新
RoomMsg.BuyMoney =
{
    {"UserID","INT"},            --///用户ID
    {"score","LLONG"},
    {"OperatScore","LLONG"}
};

--//获取任务列表
RoomMsg.CMD_GET_TASKCount =
{
    {"Taskcount","INT"},            --///用户ID
};

--//获取任务列表
RoomMsg.CMD_C_GET_TASKLIST =
{
    {"UserID","INT"},            --///用户ID
};


RoomMsg.CMD_C_UPDATETASKLIST =
{
    {"UserID","INT"},            --///用户ID
    {"TaskID","INT"},            --//任务id  
};

RoomMsg.TaskList =
{
    {"UserID","INT"},                       --///用户ID
    {"Task","INT"},                         --//   任务状态
    {"TaskID","INT"},                       --///任务id
    {"TaskTitle","CHARSTRING[150]"},  
    {"TaskMax","INT"},            
    {"TaskScore","INT"},               
    {"CompleteCount","INT"}, 
};

RoomMsg.UpdateTask =
{
    {"UserID","INT"},                       --///用户ID
    {"ret","INT"},                          
    {"Score","LLONG"},
};

RoomMsg.UserLevelUp = { --升级
    {"UserID","INT"},
    {"PlayerLevel","INT"},
};

RoomMsg.MSG_S_ConnectSuccess = {    --连接成功消息
    {"bMaxVer","BYTE"},
    {"bLessVer","BYTE"},
    {"bReserve","BYTE[2]"},
    {"i64CheckCode","UINT"},
}

RoomMsg.MSG_GR_S_RoomLogon = {
    {"uNameID","UINT"},
    {"dwUserID","INT"},
    {"uRoomVer","UINT"},
    {"uGameVer","UINT"},
    {"szMD5Pass","CHARSTRING[50]"},
    {"isReturn","BOOL"},
    {"iGuildId","INT"},  --//Vip厅id
    {"szIP","CHARSTRING[20]"},
    {"iMatchId","INT"},  --//比赛id
    {"szCityInfo","CHARSTRING[50]"}
}

RoomMsg.MSG_GR_GRM_UpData = {       --房间管理类窗口数据更新
    --奖池
    {"bAIWinAndLostAutoCtrl","BOOL"},
    {"iAIWantWinMoney","LLONG[3]"},
    {"iAIWinLuckyAt","INT[4]"},
    {"iReSetAIHaveWinMoney","LLONG"},
    {"iAIHaveWinMoney","LLONG"},
    --输赢控制
    {"bWinProbCtrl","BOOL"},
    {"dwUserID_win","INT[20]"},
    {"iProb_win","INT[20]"},
    {"dwUserID_los","INT[20]"},
    {"iProb_los","INT[20]"},
}

RoomMsg.UserInfoStruct = {
    {"dwUserID","INT"},
    {"dwExperience","INT"},
    {"dwAccID","INT"},
    {"dwPoint","INT"},
    {"i64Money","LLONG"},
    {"i64Bank","LLONG"},
    {"uWinCount","UINT"},
    {"uLostCount","UINT"},
    {"uCutCount","UINT"},
    {"uMidCount","UINT"},
    {"szName","CHARSTRING[61]"},
    -- {"szClassName","CHARSTRING[61]"},    
    {"bLogoID","UINT"},
    {"bDeskNO","UINT"},
    {"bDeskStation","BYTE"},
    {"bUserState","BYTE"},
    {"bMember","BYTE"},
    {"bGameMaster","BYTE"},
    {"dwUserIP","UINT"},
    {"bBoy","BOOL"},
    {"nickName","CHARSTRING[100]"}, 
    {"uDeskBasePoint","UINT"},
    {"dwFascination","INT"},
    {"iVipTime","INT"},
    {"iDoublePointTime","INT"},
    {"iProtectTime","INT"},
    {"isVirtual","INT"},
    {"dwTax","UINT"},
    -- {"szOccupation","CHARSTRING[61]"},
    -- {"szPhoneNum","CHARSTRING[61]"},
    -- {"szProvince","CHARSTRING[61]"},
    -- {"szCity","CHARSTRING[61]"},
    -- {"szZone","CHARSTRING[61]"},
    -- {"bHaveVideo","BOOL"},
    -- {"szSignDescr","CHARSTRING[128]"},
    {"userType","INT"},
    {"userInfoEx1","UINT"},
    {"userInfoEx2","UINT"},
    {"bTrader","INT"},
    {"iMatchID","INT"},
    {"i64ContestScore","LLONG"},
    {"iContestCount","INT"},
    -- {"timeLeft","CHARSTRING[8]"},
    {"iRankNum","INT"},
    {"iRemainPeople","INT"},
    {"iAward","INT"},
    {"iAwardType","INT"},
    {"iRoomKeyNum","INT"},
    {"PlayerID","INT"},
    {"JiuJiTimes","INT"},
    {"TotalScore","LLONG"},
    {"PlayerLevel","INT"},
    {"Exper","INT"},
    {"KuoZhan", "LLONG"},
    {"VIPLevel","INT"},
    {"IsYueKa","INT"},
    {"YueKatime","INT"},
    {"UserChouShui","INT"},
}

RoomMsg.RECEIVEMONEY = {
    {"bISOpen","BOOL"},
    {"i64Money","LLONG"},
    {"i64MinMoney","LLONG"},
    {"iCount","INT"},
    {"iTotal","INT"},
    {"iTime","INT"},
    {"iResultCode","INT"},
    {"iLessPoint","INT"},
}

RoomMsg.MSG_GR_R_LogonResult = {
    {"dwGamePower","INT"},
    {"dwMasterPower","INT"},
    {"dwRoomRule","INT"},
    {"uLessPoint","UINT"},
    {"uMaxPoint","UINT"},
    {"pUserInfoStruct",RoomMsg.UserInfoStruct},
    {"strRecMoney",RoomMsg.RECEIVEMONEY},
    {"nVirtualUser","INT"},
    {"nPresentCoinNum","INT"},
    {"iContestID","INT"},--比赛场ID
    {"iLowCount","INT"},--比赛场总共所需人数
    {"i64Chip","LLONG"},
    {"i64TimeStart","LLONG"},
    {"i64TimeEnd","LLONG"},
    {"i64LowChip","LLONG"},
    {"iTimeout","INT"},--比赛场玩法
    {"iBasePoint","INT"},--比赛场报名人数
    {"bGRMUser","BOOL"},
    {"bGRMRoom","BOOL"},
    {"GRM_Updata",RoomMsg.MSG_GR_GRM_UpData},
    {"itime","UINT"},
    {"inumber","UINT"},
    {"iSignupCntReal","INT"},
}

-- ///游戏桌子状态
RoomMsg.MSG_GR_DeskStation = {
    {"bDeskStation","BYTE[100]"},   --//桌子状态
    {"bDeskLock","BYTE[100]"},      --//锁定状态
    {"iBasePoint","INT[100]"},      --//桌子倍数
    {"bVirtualDesk","BYTE[100]"},   --//虚拟状态
}

-- ///用户离开房间
RoomMsg.MSG_GR_R_UserLeft = {
    {"dwUserID","INT"},                           --//用户 ID
}

-- ///用户进入房间
RoomMsg.MSG_GR_R_UserCome = {
    {"pUserInfoStruct",RoomMsg.UserInfoStruct}
}

-- ///修改用户经验值
RoomMsg.MSG_GR_S_RefalshMoney = {
    {"dwUserID","INT"},                           --//用户 ID
    {"i64Money","LLONG"},                           --//用户金币
}

-- ///用户经验值
RoomMsg.MSG_GR_R_UserPoint = {
    {"dwUserID","INT"},                     --//用户 ID
    {"dwPoint","LLONG"},                    --//用户经验值
    {"dwMoney","LLONG"},                    --//用户金币
    {"dwSend","LLONG"},                     --//赠送
    {"bWinCount","BYTE"},                   --//胜局
    {"bLostCount","BYTE"},                  --//输局
    {"bMidCount","BYTE"},                   --//平局
    {"bCutCount","BYTE"},                   --//逃局
    {"strAutoSendMoney",RoomMsg.RECEIVEMONEY},    --//添加自动赠送
}

-- // 自动赠送添加的结构体
RoomMsg.RECEIVEMONEY = {
    {"bISOpen","BOOL"},
    -- {"bISAuto",""},
    {"i64Money","LLONG"},
    {"i64MinMoney","LLONG"},
    {"iCount","INT"},
    {"iTotal","INT"},
    {"iTime","INT"},
    {"iResultCode","INT"},
    {"iLessPoint","INT"},
}

-- ///用户同意结构
RoomMsg.MSG_GR_R_UserAgree = {
    {"bDeskNO","UINT"},         --//游戏桌号
    {"bDeskStation","BYTE"},    --//位置号码
    {"bAgreeGame","BYTE"},      --//同意标志
}

RoomMsg.MSG_GR_S_UserSit = {   --用户坐下
    {"bDeskIndex","UINT"},
    {"bDeskStation","BYTE"},
    {"szPassword","CHARSTRING[61]"},
}

-- ///用户分数
RoomMsg.MSG_GR_R_InstantUpdate = {
    {"dwUserID","INT"},     --//用户 ID
    {"dwPoint","INT"},      --//用户分数
    {"dwMoney","INT"},      --//用户金币
}

-- //比赛开始
-- //Out:   给比赛用发送初始化信息
-- //ASS_GR_INIT_CONTEST

RoomMsg.MSG_GR_ContestChange = {
    {"dwUserID","INT"},             --// 用户 ID
    {"iContestCount","INT"},        --// 比赛局数
    {"i64ContestScore","LLONG"},    --// 比赛分数
    {"iRankNum","INT"},             --// 比赛排名
    {"iRemainPeople","INT"},        --// 比赛中还剩多少人
    {"szAward","CHARSTRING[30]"},   --// 比赛获取的奖励
    {"bIsKick","BOOL"},             --///是否被淘汰
}

-- //广播
RoomMsg.MSG_GR_I_ContestInfo = {
    {"iContestBegin","INT"},   --//0-比赛还未开始, 1-比赛开始
    {"iContestNum","INT"},     --//已报名人数
}

RoomMsg.MSG_GR_ContestAward = {
    {"dwUserID","INT"},
    {"iAward","INT"},
    {"iAwardType","INT"},
}

-- // 房间中显示报名人数
RoomMsg.NET_ROOM_CONTEST_PEOPLE_RESULT = {
    {"bSignedCount","BYTE"},    --// 已报名数量
    {"bNeedCount","BYTE"},      --// 还需多少人报名才开始
    {"bContestBegin","BYTE"},   --// 比赛是否开始
}

-- // 参赛纪录，用于房间中显示个人记录
RoomMsg.NET_ROOM_CONTEST_RECORD_RESULT = {
    {"iChanpionTimes","INT"},   --// 夺冠次数
    {"iContestTimes","INT"},    --// 参赛次数
    {"bBestRank","BYTE"},       --// 最佳排名
}

RoomMsg.MSG_GR_R_UserSit = {
    {"dwUserID","INT"},
    {"bLock","BYTE"},
    {"bDeskIndex","UINT"},
    {"bDeskStation","BYTE"},
    {"bUserState","BYTE"},
    {"bIsDeskOwner","INT"},
    {"pUserInfoStruct",RoomMsg.UserInfoStruct},
}

RoomMsg.MSG_GM_S_ClientInfo = {
    {"bEnableWatch","BYTE"},  --允许旁观
}

RoomMsg.MSG_GM_S_GameInfo = {
    {"bGameStation","BYTE"},    --游戏状态
    {"bWatchOther","BYTE"},      --允许旁观
    {"bWaitTime","BYTE"},        --等待时间
    {"bReserve","BYTE"},         --保留字段
    {"iGameRoundCount","UINT"},  --游戏局数
    {"iGameRoundMax","UINT"},    --游戏最大局数

    {"nCostID","INT"},              --房卡消耗ID
    {"iGameRule","LLONG"}, 
    {"bAAFanKa","BOOL"},
    {"iCost","INT"},              --房卡消耗ID

    {"i64UseDeskLockPassTime","LLONG"},    --桌子的开始使用时间
    {"iGameStatisticsPoint","INT[180]"},    --每个人开始的总分数
    {"szPwd","CHARSTRING[61]"},              --服务器密码
    {"iGuildId","INT"},              --公会ID
    {"szMessage","CHARSTRING[1000]"},         --系统消息
}

RoomMsg.TDeskCfg = {   --有关桌面配置
    {"dz",{   --底注相关
        {"iLoseTop","INT"},
        {"iEscapePunish","INT"},
    }},    --时间相关
    {"Time",{
        {"byWaitAgree","BYTE"},  --等待同意的时间
        {"byOutCard","BYTE"},    --出牌思考时间
        {"byAct","BYTE"},        --动作思考时间，如碰杠胡
        {"byNextRound","BYTE"},  --下一回合等待时间，是结算框上显示
    }},
    {"Rule",{
        {"nLeastQuan","INT"},
    }},
    {"bShowUserInfo","BOOL"},   --是否显示玩家和身份，多用于比赛场
    {"bNetcutAuto","BOOL"},    --是否断线后直接托管
    {"bBoy","BOOL[4]"},         --各玩家的性别，用于解决早期平台版本游戏不能获取玩家性别的问题
    {"bLogMode","BOOL"},        --是否启动日志模式
    {"szLogID","CHARSTRING[32]"},    --日志ID
    {"iDiHua","INT"},           --绍兴麻将独有 底花
}

RoomMsg.TGSBase = {   --游戏状态包
    {"byGSID","BYTE"},      --当前状态ID
    {"byUser","BYTE"},      --状态所属玩家
    {"bWatchUser","BOOL"},    --byUser是否旁观玩家
    {"bBoy","BOOL[4]"},      --获取各玩家的性别，为解决早期游戏客户端不能获取玩家性别的问题
    {"iEvPassTime","INT"},     --当前事件已消耗的时间

    {"tagDeskCfg",RoomMsg.TDeskCfg},

    {"direct","BYTE"},          --当前游戏的圈风
    {"directUser","BYTE[4]"},   --各玩家坐的方位
    {"nQuan","INT"},            --当前圈数
    {"byNTUser","BYTE"},   --庄家位置
    {"nLiangZhuangNum","INT"},      --连庄次数
    {"byJinCard","BYTE"},   --当前的金牌
    {"iLeftMoney","INT[4]"},            --各玩家余下的金币数量
    {"byNTUser","BYTE[4][2][18]"},   --各玩家门前的牌城状态
    {"iWallLeftNums","INT"},            --牌城的中剩余牌的张数
    {"byHandCards","BYTE[17]"},   --自己的手牌
    {"iHandNums","INT[4]"},            --各玩家的手牌数量
    {"byHuaCards","BYTE[4][24]"},          --各玩家的花牌表
    {"iHuaNums","INT[4]"},            --各玩家花牌表长度
    {"bNoticeContinueNext","BOOL"},            --是否提示继续下一轮
}

RoomMsg.TFetchHands = {
    {"byCards","BYTE[17]"},
    {"","INT"},
}

RoomMsg.MSG_GR_RS_NormalTalk = {
    {"crColor","UINT"},         --字体颜色
    {"iLength","WORD"},         --信息长度
    {"dwSendID","INT"},         --用户 ID
    {"dwTargetID","INT"},       --目标 ID
    {"nDefaultIndex","INT"},    --=0，输入的内容，>0，选择的内容
    {"szMessage","CHARSTRING[501]"},  --聊天内容
}

RoomMsg.Game_StatisticsOther = {
    {"iReserveData","INT[10]"},
}

RoomMsg.Game_StatisticsMessage = {
    --//总局数据节点(一个玩家的数据)
    {"dwUserID","INT"},
    {"taiZhuID","INT"},
    {"dwPoint","LLONG"},
    {"dwMoney","LLONG"},
    {"dwSend","LLONG"},
    {"bWinCount","BYTE"},
    {"bLostCount","BYTE"},
    {"bMidCount","BYTE"},
    {"bCutCount","BYTE"},
    {"bMaxLzCount","BYTE"},
    {"data",RoomMsg.Game_StatisticsOther},
}

--//语音结构
RoomMsg.MSG_GR_GCloudVoice = {
    {"bDestion","BYTE"},    --玩家
    {"bTimeLength","BYTE"}, --语音时间
    {"szFileID","CHARSTRING[250]"},--语音包下载ID
}

--//继续下一轮，发送结构体
RoomMsg.MSG_GR_R_Continue_Next_Round = {
    {"byDeskStation","BYTE"},   --发起者坐位号
    {"nTableOwnerID","INT"},    --新房主的ID
}

RoomMsg.MSG_GR_R_UserUp = {
    {"dwUserID","INT"},--//用户 ID
    {"bLock","BYTE"},--//是否密码
    {"bDeskIndex","UINT"},--//桌子索引
    {"bDeskStation","BYTE"},--//桌子位置
    {"bUserState","BYTE"},--//用户状态
    {"bIsDeskOwner","BOOL"},--//台主离开
}

-- ///用户断线
RoomMsg.MSG_GR_R_UserCut = {
    {"dwUserID","INT"},--//用户 ID
    {"bDeskNO","UINT"},--//游戏桌号
    {"bDeskStation","BYTE"},--//位置号码
}

RoomMsg.MSG_Change_Owner = {
    {"dwUserID","INT"},--//用户 ID
}


RoomMsg.MSG_GR_USERINFO = {
    {"UserID","INT"},--//用户id
    {"RoomKey","LLONG"},--//房卡
    {"WalletMoney","LLONG"},--//金币
}

RoomMsg.MSG_GR_C_GET_USERINFO = {
    {"dwUserID", "INT"},--//用户ID
}

-- //存分
RoomMsg.CMD_C_STORE_SCORE = {
    {"Score", "LLONG"}
}

-- //取分
RoomMsg.CMD_C_GET_SCORE = {
    {"Score", "LLONG"},
    {"MD5_BANKPASS","CHARSTRING[54]"}
}

--存取分结果
RoomMsg.StoreResultStruct = {
    {"UserID", "INT"},
    {"Score", "LLONG"},
    {"OperatScore", "LLONG"},
    {"ret", "INT"}
}

--救济金
RoomMsg.JiujiResultStruct = {
    {"UserID", "INT"},
    {"JiuJiTimes", "INT"},
    {"Score", "LLONG"},
    {"OperatScore", "LLONG"},
    {"ret", "INT"},
}

RoomMsg.JiuJiTips = {
    {"JiuJiTimes","INT"},
    {"ret","INT"}
}

RoomMsg.RetryMatch = {
    {"ret","INT"}
}

RoomMsg.BUY_PAOTAI =
{
    {"UserID","INT"},
    {"PaoTaiID","INT"},
    {"ret","INT"},
    {"Score","LLONG"}
};

RoomMsg.MSG_GA_S_Message = {
    {"bFontSize","BYTE"},--///字体大小
    {"bCloseFace","BYTE"},--///关闭界面
    {"bShowStation","BYTE"},--///显示位置
    {"szMessage","CHARSTRING[1000]"},--///消息内容
}

RoomMsg.MSG_GP_S_BASIC_ROOMINFO = {
    {"NameID","INT"},
    {"RoomID","INT"},
    {"OnlineUser","INT"},
    {"RoomMinScore","LLONG"},
    {"GameStation","INT"},
    {"LeftTime","INT"},
    {"ChangeTime","INT"},
    {"NowTime","INT"},
    {"DeskID","INT"},
    {"DeskState","INT"},
}

RoomMsg.MSG_GP_S_GET_ROOMINFO = {
    {"BasicRoomInfo",RoomMsg.MSG_GP_S_BASIC_ROOMINFO},
    {"RecordCount","INT"},
    {"pData","CHARSTRING[1000]"},
}

RoomMsg.MSG_GR_C_USERSCORELOG = {
    {"UserID","INT"},
}

RoomMsg.MSG_GP_USERSCORE_LOG = {
    {"CreateDate","INT"},
    {"lScore","LLONG"},
    {"Detail1","CHARSTRING[1000]"},
    {"Detail2","CHARSTRING[1000]"},
    {"Detail3","CHARSTRING[1000]"},
}

return RoomMsg