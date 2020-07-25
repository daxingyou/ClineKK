local PlatformMsg = {
    --///常量定义
    MAX_PEOPLE                      =       180,             --//最大游戏人数 百家乐
    MAX_SEND_SIZE                   =       2044,            --//最大消息包
    MAX_TALK_LEN                    =       500,             --//最大聊天数据长度
    NORMAL_TALK_LEN                 =       200,             --//普通聊天数据长度

--//游戏通讯指令宏定义

--// 客户端到服务端心跳指令
    MDM_CONNECT                     =       88,
    ASS_NET_TEST_1                  =       1,
    ASS_CONNECT_SUCCESS             =       3,               --//连接成功
    ASS_NET_END                     =       4,               --//网络连接结束消息

--// 大厅主标识
    MDM_GP_CONNECT                  =       1,               --// 连接消息类型
    MDM_GP_LOGONUSERS               =       119,             --// 统计登录人数
    BROADCAST_MESSAGE_MAX           =       255,
    MDM_GP_GETCODE                  =       5,

--// 请求中心服务器
    MDM_GP_REQURE_GAME_PARA         =       102,

--// 快速登录主ID和，辅助ID标志
    MDM_GP_REGISTER                 =       99,               --// 快速登录
    ASS_GP_REGISTER                 =       0,               -- //
    ERR_REGISTER_ERROR              =       0,               --// 注册失败
    ERR_REGISTER_SUCCESS            =       1,               --// 注册成功
    ERR_REGISTER_NAME_EXIST         =       2,               --// 用户名存在

-- // 支付通知主ID和，辅助ID标志
    MDM_GP_NOTIFY_PAY               =       88,               --//
    ASS_GP_NOTIFY_PAY               =       1,                --//

--//游戏主标识
    MDM_GM_GAME_FRAME               =       150,               --//框架消息
    MDM_GM_MESSAGE                  =       151,               --//信息消息


-- //大厅辅助处理消息标志
    ASS_GP_NET_TEST                 =       1,               --//网络测试
    ASS_GP_CONNECT_SUCCESS          =       3,               --//连接成功

-- //大厅登陆
    MDM_GP_LOGON                    =       100,
    ASS_GP_LOGON_BY_NAME            =       1,               --//通过用户名字登陆
    ASS_GP_LOGON_BY_ACC             =       2,               --//通过用户ACC 登陆
    ASS_GP_LOGON_BY_MOBILE          =       3,               --//通过用户手机登陆
    ASS_GP_LOGON_REG                =       4,               --//用户注册
    ASS_GP_LOGON_SUCCESS            =       5,               --//登陆成功
    ASS_GP_LOGON_ERROR              =       6,               --//登陆失败
    ASS_GP_LOGON_ALLO_PART          =       7,               --//异地登陆
    ASS_GP_LOGON_LOCK_VALID         =       8,               --//锁机验证
    ASS_GP_LOGON_BY_SOFTWARE        =       10,
    ASS_GP_LOGON_MOBILE_VALID       =       11,              --//手机验证
    ASS_GP_LOGIN_SWITCH             =       12,              --//请求功能开关
    ASS_GP_CHECK_PHONE              =       13,              --//手机绑定短信验证
    ASS_GP_GET_DEVICE               =       14,              --//极光获取本机id
    
--角色系统
    MDM_GP_PLAYER                   =       150,             --//用户角色
    ASS_GP_ADD_PLAYER               =       14,              --//用户角色增加
    ASS_GP_SWITCH_PLAYER            =       15,              --//用户角色切换
    ASS_GP_TRANS_PLAYER             =       16,              --//用户角色转移
    ASS_GP_CHANGE_PNAME             =       17,              --//用户角色改名
    ASS_GP_STORE_SCORE              =       18,              --//用户角色存分
    ASS_GP_GET_SCORE                =       19,              --//用户角色取分
    ASS_GP_LOGON_PLAYER_LIST        =       20,              --//用户角色
    ASS_GP_GET_JIUJI                =       21,              --//用户救济金
    ASS_GP_JIUJI_TIP                =       22,              --//用户救济金提示
    ASS_GP_SET_BANKPASS             =       23,              --//设置银行密码
    ASS_GP_GET_BANKLOG              =       24,              --银行明细
    ASS_GP_GET_BANKREALTIME         =       25,              -- //获取实时利率
    ASS_GP_TRANSFER_SCORE           =       26,              --//保险柜转账
    ASS_GP_TRANSFER_INFO            =       27,              --//保险柜转账获取信息
--//邮件系统
    MDM_GP_MAIL                     =       151,             --///邮件系统
    ASS_GP_GET_MAILLIST             =       10,              --//获取邮件列表
    ASS_GP_GET_GOODS                =       11,              --///领取奖品
    ASS_GP_READ_MAIL                =       12,              --///读邮件
    ASS_GP_DELETE_MAIL              =       13,              --///删除邮件
    ASS_GP_GET_QUESTION             =       15,              --//获取问题列表
    ASS_GP_ADD_QUESTION             =       16,              --//增加问题列表

--//排行   
    MDM_RANK                        =       152,             --//排行
    ASS_GP_GET_RANKLIST             =       1,               --//获取排行
    ASS_GP_GET_BOSSRANKLIST         =       2,               --//获取boss排行
--//任务
    MDM_TASK                        =       153,                                 
    ASS_GP_GET_TASKLIST             =       1,                --//获取任务列表
    ASS_GP_UPDATE_TASK              =       2,                --//领取任务奖励
    ASS_GP_GET_TASKNAME             =       3,                --//获取任务名
--/vip月卡
    MDM_VIP                         =       154,              --//VIP
    ASS_GP_GET_VIP                  =       1,                --//获取任务列表
    ASS_GP_GET_YkScore              =       2,                --//领取月卡奖励
    ASS_GP_GET_FavCompain           =       3,                --//获取特惠活动
    ASS_GP_GET_NewUserRewardStateList=      4,                --//获取新手奖励列表
    ASS_GP_GET_NewUserReward        =       5,                --//获取新手奖励
    ASS_GP_GET_NewUserRewardList    =       6,                --//获取新手奖励列表
    ASS_GP_GET_VipList              =       7,                --//获取vip奖励列表
    ASS_GP_GET_UserVipReward        =       8,                --//获取vip奖励
    ASS_GP_GET_PaoTaiList           =       9,                 --//获取炮台列表
    ASS_GP_Get_UserPaoTai           =       10,                --//获取用户炮台
    ASS_GP_BUY_PaoTai               =       11,                --//购买炮台


--获取物品配置
    MDM_CONFIG                      =       155,              --//CONFIG
    ASS_GP_GET_CONFIG               =       1,                --//获取配置
    ASS_GP_GET_RAT                  =       3,                --//获取游戏税收比例
    ASS_GP_GET_CHARGE_URL           =       4,
    ASS_GP_GET_CHARGE_URLNEW        =       5,
--//用户充值相关    
    MDM_USERSCORE                   =       156,              --//用户充值相关
    ASS_GP_GET_SHOUCHONG            =       1,                --//获取首冲

--比赛场
    MDM_FISH_MATCH                  =       157,               --//捕鱼比赛
    ASS_GP_GET_FISH_MATCH_INFO      =       1,                 --//获取比赛列表
    ASS_GP_ENROLL_FISH_MATCH        =       2,                 --//报名比赛
    ASS_GP_GET_USER_MATCH_INFO      =       3,                 --//获取用户比赛信息
    ASS_GP_GET_FISH_MATCH_RANK      =       4,                 --//获取比赛排名
    ASS_GP_GET_FISH_MATCH_REWARD    =       5,                 --//获取比赛奖励列表

-- /// 错误代码
    ERR_GP_ERROR_UNKNOW             =       0,               --//未知错误
    ERR_GP_LOGON_SUCCESS            =       1,               --//登陆成功
    ERR_GP_USER_NO_FIND             =       2,               --//登陆名字错误
    ERR_GP_USER_PASS_ERROR          =       3,               --//用户密码错误
    ERR_GP_USER_VALIDATA            =       4,               --//用户帐号禁用
    ERR_GP_USER_IP_LIMITED          =       5,               --//登陆 IP 禁止
    ERR_GP_USER_EXIST               =       6,               --//用户已经存在
    ERR_GP_PASS_LIMITED             =       7,               --//密码禁止效验
    ERR_GP_IP_NO_ORDER              =       8,               --//不是指定地址 
    ERR_GP_LIST_PART                =       9,               --//部分游戏列表
    ERR_GP_LIST_FINISH              =       10,               --//全部游戏列表
    ERR_GP_USER_LOGON               =       11,               --//此帐号已经登录
    ERR_GP_USERNICK_EXIST           =       12,               --//此昵称已经存在
    ERR_GP_USER_BAD                 =       13,               --//未法字符
    ERR_GP_IP_FULL                  =       14,               --//IP已满
    ERR_GP_LOCK_SUCCESS             =       15,               --//锁定机器成功    
    ERR_GP_ACCOUNT_HAS_LOCK         =       16,               --//机器已经处于锁定状态    
    ERR_GP_UNLOCK_SUCCESS           =       17,               --//解除锁定成功 
    ERR_GP_NO_LOCK                  =       18,               --//机器根本就没有锁定，所以解锁失败 
    ERR_GP_CODE_DISMATCH            =       19,               --//机器码不匹配，解锁失败。
    ERR_GP_ACCOUNT_LOCKED           =       20,               --//本账号锁定了某台机器，登录失败
    ERR_GP_MATHINE_LOCKED           =       21,
    ERR_GP_VER_ERROR                =       22,

-- // 第三方认证返回的错误码
    ERR_GP_USER_NOT_EXIST           =       30,               --// 用户不存在
    ERR_GP_USER_OVERDATE            =       31,               --// 用户已过期

    EXP_GP_ALLO_PARTY               =       50,               --//本账号异地登陆

    MDM_GP_LIST                     =       101,              --// 游戏列表

-- ///通信辅助标识
    ASS_GP_LIST_KIND                =       1,               --//获取游戏类型列表
    ASS_GP_LIST_NAME                =       2,               --//获取游戏名字列表
    ASS_GP_LIST_ROOM                =       3,               --//获取游戏房间列表
    ASS_GP_LIST_COUNT               =       4,               --//获取游戏人数列表
    ASS_GP_ROOM_LIST_PEOCOUNT       =       5,               --//获取游戏人数列表
    ASS_GP_ROOM_PASSWORD            =       6,               --//发送房间密码,试图进入密码房间时发送此消息
    ASS_GP_GET_SELLGAMELIST         =       7,               --//获取游戏销售列表

    ASS_GP_CONTINUE_NEXT_ROUND      =       8,               --//继续下一轮游戏

-- //添加用户资料管理通讯协议
    MDM_GP_USERINFO                 =       115,
    ASS_GP_USERINFO_UPDATE_BASE     =       1,               --//用户更新基本信息
    ASS_GP_USERINFO_UPDATE_DETAIL   =       2,               --//用户更新详细信息
    ASS_GP_USERINFO_UPDATE_PWD      =       3,               --//用户修改密码
    ASS_GP_USERINFO_ACCEPT          =       5,               --//服务端已接受
    ASS_GP_USERINFO_NOTACCEPT       =       6,               --//服务端未能接受
    ASS_GP_USERINFO_NICKNAMEID      =       10,              --//根据玩家昵称找ID或ID找昵称
    ASS_GP_USERINFO_GET             =       11,              --//获取指定用户ID的个人资料]
    ASS_GP_FIND_PWD                 =       12,              --//找回密码
    ASS_GP_SETINVITECODE            =       13,              --//设置邀请码
    ASS_GP_SETUPDATELOGO            =       14,              --//设置logo

    ASS_GP_LOGONUSERS_COUNT         =       1,


    MDM_GP_SET_LOGO                 =       113,
    ASS_GP_SET_LOGO                 =       1,

    HC_USERINFO_NOTACCEPT           =       6,               --//个人资料修改失败
    HC_USERINFO_ACCEPT              =       5,               --//个人资料修改成功
    HC_USERINFO_REPEAT              =       2,               --//昵称已重复
    HC_USERINFO_BADNICK             =       3,               --//不允许的昵称

    ASS_GP_SHARE_WX_REWARD          =       15,              --//微信分享奖励

    MDM_GP_PROP                     =       140,
    ASS_PROP_BUY_NEW                =       0x0b,
    ASS_PROP_GETUSERPROP            =       0x01,
    ASS_PROP_BIG_BOARDCASE          =       0x07,              --//大喇叭消息
    ASS_PROP_BIG_BOARDCASE_BUYANDUSE =      0x14,              --大喇叭
    DTK_GP_PROP_BUY_ERROR           =       10,
    DTK_GP_PROP_BUY_NOMONEY         =       20,
    DTK_GP_PROP_BUY_SUCCEED         =       80,                --//购买成功
    DTK_GP_PROP_BUYANDUSE_SUCCEED   =       81,                --//即买即用成功
-- //pc端道具
    ASS_PROP_BUY                    =       0x03,              --//购买道具
    DTK_GP_PROP_BUY_ERROR           =       10,
    DTK_GP_PROP_BUY_NOMONEY         =       20,
    DTK_GP_PROP_BUY_SUCCEED         =       80,
    DTK_GP_PROP_BUYANDUSE_SUCCEED   =       81,

--//主ID=140，辅助ID=21
    MDM_GP_NET_PROP_BUY_LOG         =       140,
    ASS_GP_NET_PROP_BUY_LOG         =       21,

-- // 排行榜消息
    MDM_GP_PAIHANGBANG              =       133,

-- //金猪
    MDM_GP_GOLDENPIG                =       251,
    ASS_GP_GOLDENPIG_TUBI           =       1,                  --//金猪吐币
    ASS_GP_GOLDENPIG_GET            =       2,                  --//获取指定UserID的金猪重量
    ASS_GR_GOLDENPIG_TUBI           =       3,
    ASS_GR_GOLDENPIG_FEED           =       4,
--//宝箱
    MDM_GP_CHESTS                   =       250,
    ASS_GP_CHESTS_BUY               =       1,                  --//购买宝箱

-- //钻石
    MDM_GP_DIAMOND                  =       253,
    ASS_GP_DIAMOND_BUY              =       1,       --//买钻石

-- //礼物
    MDM_GP_GIFT                     =       252,
    ASS_GP_GIFT_BUY                 =       1,       --//礼物赠送
    ASS_GP_GIFT_NOTIFY              =       2,       --//礼物通知(收到礼物的人被通知)
    ASS_GP_GIFT_SELL                =       3,       --//礼物典当
    ASS_GP_GIFT_GET                 =       4,       --//获取指定UserID的礼物列表
    ASS_PROP_SMALL_BOARDCASE        =       8,       --//小喇叭 

-- // 签到消息
    MDM_GP_SIGN                     =       134,
    ASS_GP_SIGN_CHECK               =       1,
    ASS_GP_SIGN_DO                  =       2,

-- //在线奖励金币
    MDM_GP_ONLINE_AWARD             =       135,
    ASS_GP_ONLINE_AWARD_CHECK       =       1,
    ASS_GP_ONLINE_AWARD_DO          =       2,

    ASS_GP_GET_MONEY_BY_PAY_DO      =       2,
    ASS_GP_GET_MONEY_BY_PAY_CHECK   =       3,

    MDM_GP_DESK_LOCK_PASS           =       254,                                 --////桌子密码消息
    ASS_GP_DESK_LOCK_PASS           =       1,                                   --///询问桌子密码是否正确
    ERR_DESK_LOCK_PASS_ERROR        =       0,--//失败
    ERR_DESK_LOCK_PASS_SUCCESS      =       1,--//成功
    ERR_DESK_LOCK_NO_ENOUGH_ROOMKEY =       2,--//没有足够的钻石加入(AA制房间)

    ASS_GP_USE_ROOM_KEY             =       2,                                   --///使用钻石
    ERR_USE_ROOM_KEY_ERROR          =       0,--//失败
    ERR_USE_ROOM_KEY_SUCCESS        =       1,--//成功
    ERR_USE_ROOM_KEY_RECOME         =       2,--//重新回到已经在玩的房间
    ERR_USE_ROOM_KEY_EXISTS         =       3, --//已经登陆在数据库的其他的地方，无法创建房间

    ASS_GP_GET_ROOM_KEY_USE_INFO    =       3,                                   --///查询自己开启的桌子信息
    ERR_USE_ROOM_KEY_PART           =       0,--//失败
    ERR_USE_ROOM_KEY_FINISH         =       1,--//完成
    ASS_GP_GET_ROOM                 =       4,                                   --///查询自己先前所在的房间
    ASS_GP_DESK_LOCK_PASS_EX        =       5,                                   --///询问桌子密码是否正确(断线重回的询问)
    ERR_DESK_LOCK_PASS_ERROR        =       0,--//失败
    ERR_DESK_LOCK_PASS_SUCCESS      =       1,--//成功

    ASS_GP_GET_ROOM_CREATE_INFO     =       6,                               --///查询房间创建数据
    ERR_ROOM_CREATE_INFO_PART       =       0,
    ERR_ROOM_CREATE_INFO_FINISH     =       1,

    ASS_GP_MATCH_ROOM_INFO          =       7,                               --//开始匹配房间

    ASS_GET_MIN_ROOM_KEY_NUM        =       8,                               --//获取匹配房间需要最小钻石数

    ASS_CREATE_ROOM_FOR_OTHER       =       9,                               --//代开房
    ASS_DISMISS                     =       10,                              --//解散房间
    ASS_ROOM_LIST                   =       11,                              --//房间列表


    -- ///通信主标识
    MDM_GP_MESSAGE                  =       103,                            --///系统消息
    -- ///通信辅助标识
    ASS_GP_NEWS_SYSMSG              =       1,                               --///新闻和系统消息
    ASS_GP_DUDU                     =       2,                           --///小喇叭
    ASS_GP_TALK_MSG                 =       3,                              -- //聊天消息
    -- ///聊天结构
    ASS_GP_WORLD_HORN               =       4,                              -- //世界喇叭消息

    -- ///魅力兑换
    MDM_GP_CHARMEXCHANGE            =       109,
    ASS_GETLIST                     =       1,
    ASS_EXCHANGE                    =       2,
    ASS_GETHUAFEILIST               =       3,
    ASS_GETGOODLIST                 =       4,
    ASS_GETGOODLOG                  =       5,

    MZTW_USERINFO                   =       4,
    ASS_ZTW_SCORE                   =       1,
    ASS_ZTW_DJ_ENDGAME              =       2,                          --//通知电竞结束消息

    MDM_CASH                        =       159,                         --//提现
    ASS_GP_UPDATE_ALIPAY            =       1,                           --//绑定支付宝
    ASS_GP_GET_CASH                 =       3,                           --//提现
    ASS_GP_GET_AGENTWECHAT          =       2,                           --//获取代理微信
    ASS_GP_GET_CASH_LOG             =       4,                           --//提现记录
    ASS_GP_GET_CASH_ACQUIRE         =       5,                           --/获取提现需要条件


    MDM_GP_WEB_INFO                 =       160,                         --//网页消息
    ASS_GP_WEB_ADD_SCORE            =       1,                           --///充值
    ASS_GP_WEB_MAIL                 =       2,                           --///邮件
    ASS_GP_WEB_JIANYI               =       100,                         --建议
    ASS_GP_WEB_DUOBAO               =       7,                              --建议
    ASS_GP_LOAD_SYSTEM_LIST         =       6,                           --   ///重新加载配置列表
    ASS_GP_FORCEUSER                =       110,
    ASS_GP_REFRESHGAMELIST          =       111,

    MDM_GP_ACTIVITIES               =       162,                         --//活动
    ASS_GP_SIGNWEEK_OPEN            =       1,                           --///打开签到
    ASS_GP_SIGNWEEK_SIGNIN          =       2,                           --///签到
    ASS_GP_SIGNWEEK_RECORD          =       3,                           --签到记录
    ASS_GP_SIGNWEEK_CLOSE           =       4,                           --关闭签到
    ASS_GP_SIGNWEEK_RECORDToc       =       5,                           --签到总记录

        -- //幸运夺宝
    ASS_GP_LUCKAWARD_OPEN           =       10,                         --//打开夺宝
    ASS_GP_LUCKAWARD_WHEEL          =       11,                         --//转盘
    ASS_GP_LUCKAWARD_RECORD         =       12,                         --//转盘记录
    ASS_GP_LUCKAWARD_LUCKY          =       13,
    ASS_GP_LUCKAWARD_LEAVE          =       14,
    ASS_GP_LUCKAWARD_POINT          =       15,                         --转盘分数

    MDM_AGENCY                      =       158,                         --//代理系统
    ASS_GP_GET_TOTAL                =       1,                           --//获取总人数
    ASS_GP_GET_DETAIL               =       2,                           --//获取明细
    ASS_GP_GET_NEEDLEVEL            =       3,                           --//获取经验
    ASS_GP_GET_ACHIEVE              =       4,                           --//获取业绩
    ASS_GP_GET_REWARD               =       5,                           --//获取奖励
    ASS_GP_GET_PARTNERINFO          =       6,                           --//获取合伙人信息
    ASS_GP_GET_PARTNERSCORE         =       7,                           --//资金池转入余额宝
    ASS_GP_STORE_PARTNERSCORE       =       8,                           --//余额宝转入资金池
    ASS_GP_GET_PARTNERUSERINFO      =       9,                           --//获取合伙人玩家信息
    ASS_GP_GET_PARTNERUSERINFODETAIL=       10,                          --//获取合伙人玩家详细信息
    ASS_GP_OPEN_PARTNER             =       11,                          --//开启合伙人功能
    ASS_GP_UPDATE_PARTNERTIME       =       12,                          --//开启合伙人时间
    ASS_GP_GET_PROVISIONS           =       13,                          --//预提
    ASS_GP_UPDATE_PARTNERTIME_TEMP  =       14,                          --//更新时间 
    ASS_GP_GET_TOTAL_FORMODEB       =       15,                          --获取总人数
    ASS_GP_GET_DETAIL_FORMODEB      =       16,                          --//获取明细
    ASS_GP_GET_AGENCYREWARD_FORMODEB  =     17,                       --//提取奖励
    ASS_GP_GET_AGENCYREWARDLOG_FORMODEB =   18,                       --//提取奖励记录
    ASS_GP_GET_AGENCYREWARDRANK_FORMODEB =  19,                       --//奖励周排行
    ASS_GP_GET_AGENCYREWARD_LEVEL   =       20,

}

--礼券兑换物品记录
PlatformMsg.CMD_GetGoodLog =
{
    {"UserID","INT"}, 
};

--物品列表
PlatformMsg.CMD_GiftGoodList =
{
    {"id","INT"},
    {"GoodName","CHARSTRING[50]"},
    {"GoodPic","CHARSTRING[50]"},
    {"GoodPrice","INT"},
    {"GoodStock","INT"},
    {"GoodType","INT"},
};

--兑换记录
PlatformMsg.CMD_GiftGoodLog =
{
    {"id","INT"},
    {"GoodName","CHARSTRING[50]"},
    {"UserName","CHARSTRING[50]"},
    {"pAddress","CHARSTRING[150]"},
    {"Tel","CHARSTRING[50]"},
    {"Flag","INT"},
};

--兑换物品信息
PlatformMsg.CMD_ExChange =
{
    {"UserID","INT"},
    {"Num","INT"},
    {"WeiXin","CHARSTRING[50]"},
    {"Phone","CHARSTRING[20]"},
    {"pAddress","CHARSTRING[150]"},
    {"id","INT"},
    {"bType","BYTE"},--//兑换的类别
};

PlatformMsg.CMD_GetGoodList =
{
    {"GoodType","INT"},
};

--//首冲
PlatformMsg.MSG_GP_GET_SHOUCHONG =
{
    {"UserID","INT"}, 
};

--////获取首冲
PlatformMsg.MSG_GP_S_GET_SHOUCHONG =
{
    {"UserID","INT"}, 
    {"IsShouChong","INT"},
};

--//读配置
PlatformMsg.MSG_GP_GET_CONFIG =
{
    {"ID","INT"},
    {"AgentID","INT"}
};

--////获取配置
PlatformMsg.MSG_GP_S_GET_CONFIG =
{
    {"id","INT"},
    {"val","CHARSTRING[150]"},
};

--vip 月卡
PlatformMsg.MSG_P_GETVIP =
{
     {"UserID","INT"},              --///用户ID  
};

PlatformMsg.MSG_P_GETYKSCORE =
{
     {"UserID","INT"},              --///用户ID  
};

PlatformMsg.MSG_GP_S_GETYKSCORE =
{
    {"UserID","INT"},                       --///用户ID
    {"ret","INT"},                          
    {"score","LLONG"}, 
};

PlatformMsg.MSG_GP_S_GETVIP =
{
    {"UserID","INT"},                          
    {"VIPLevel","INT"},
    {"VIPTime","INT"},                          
    {"IsYueKa","INT"},
    {"YueKatime","INT"},                          
    {"IsGetYkScore","INT"},
    {"ChargeCount","LLONG"}, --充值金额
    {"IsGetVip","BYTE[20]"},
};

PlatformMsg.MSG_P_GETFAVCOM =
{
    {"UserID","INT"},                               --///用户ID
};

PlatformMsg.MSG_GP_S_GETFavCom =
{
    {"UserID","INT"}, 
    {"id","INT"}, 
    {"TimeLeft","INT"}, 
    {"IsGet","INT"}, 
    {"FavName","CHARSTRING[50]"},
    {"FavMessage","CHARSTRING[150]"},
    {"FavPic","CHARSTRING[50]"},
};

--日常任务
PlatformMsg.MSG_P_GETTASKLIST =
{
    {"UserID","INT"},              --///用户ID                           
};

PlatformMsg.MSG_P_UPDATETASKLIST =
{
    {"UserID","INT"},            --///用户ID
    {"TaskID","INT"},            --//任务id                           
};

PlatformMsg.MSG_GP_S_TASKLIST =
{
    {"UserID","INT"},                       --///用户ID
    {"Task","INT"},                         --//   任务状态
    {"TaskID","INT"},                       --///任务id
    {"TaskTitle","CHARSTRING[150]"},  
    {"TaskMax","INT"},            
    {"TaskScore","INT"},               
    {"CompleteCount","INT"}, 
};

PlatformMsg.MSG_GP_S_UPDATETASK =
{
    {"UserID","INT"},                       --///用户ID
    {"ret","INT"},                          
    {"score","LLONG"},                     
};

--大喇叭
PlatformMsg.UseBroadResult =
{
    {"UserID","INT"},
    {"CostScore","INT"},
    {"ret","INT"},
    {"szMessage","CHARSTRING[256]"},             --//;
};

PlatformMsg._TAG_BOARDCAST =  
{
    {"dwUserID","INT"},                          --//用户ID
    {"szMessage","CHARSTRING[256]"},             --//;
} ;

--公告消息
PlatformMsg.MZTW_Mess_World_Horn_struct = {
    {"UserName","CHARSTRING[50]"},
    {"data","CHARSTRING[200]"},
    {"messageType","INT"},
    {"VipLevel","INT"},
    {"IsYueKa","INT"},
    {"lScore","LLONG"},
    {"enddata","CHARSTRING[50]"},
    {"uNameId","INT"}
}
--绑定手机
PlatformMsg.MSG_GP_R_Check_Phone = {
    {"dwResult","INT"},
}

PlatformMsg.MSG_P_CHECK_PHONE = {
    {"UserID","INT"},
    {"dwResult","CHARSTRING[7]"},
}  

--获取用户角色信息
PlatformMsg.MSG_P_GET_PLAYERLIST =
{
    {"UserID","INT"},              --///用户ID
};

--角色信息
PlatformMsg.MSG_GP_S_PLAYERLIST =
{
    {"UserID","INT"},                      --//用户ID
    {"PlayerID","INT"},                    --//角色ID
    {"PlayerName","CHARSTRING[50]"},       --//角色昵称
    {"IsUse","BOOL"},                      --//是否正在使用
    {"Exper","INT"},                       --//角色经验
    {"PlayerLevel","INT"},                 --//角色等级
    {"Score","LLONG"},                     --//角色金币数量
    {"BossCount","INT"},                   --//击杀BOSS数量
    {"CreateDate","CHARSTRING[50]"},       --//创建时间
};

--获取余额宝信息
PlatformMsg.MSG_P_GET_BANKREALTIME = 
{
  {"UserID","INT"},                         --///用户ID
};

--余额宝信息
PlatformMsg.MSG_GP_S_BANKREALTIME = 
{
    {"UserID","INT"},
    {"LastGain","LLONG"},
    {"TotalGain","LLONG"},
    {"Rate","LLONG"},
    {"PerGain","LLONG"},
    {"UnSecondReach","LLONG"},--未产生收益金额
};

--余额宝转账
PlatformMsg.MSG_P_TRANSFER_SCORE = 
{
  {"UserID","INT"},         --///用户ID
  {"phone","CHARSTRING[16]"},          --//对方手机号
  {"Score","LLONG"},        --//分数
  {"MD5_BANKPASS","CHARSTRING[54]"},
  {"TargetUserID","INT"}, -- 对方id
};

--获取转账对方信息
PlatformMsg.MSG_P_TRANSFER_INFO = 
{
  {"Phone","CHARSTRING[16]"},  --//对方手机号
  {"TargetUserID","INT"},-- 对方id
};

--获得转账对方信息
PlatformMsg.MSG_GP_S_TRANSFERINFO = 
{
  {"UserID","INT"},
  {"NickName","CHARSTRING[50]"},--//类型
  {"LogoID","INT"}, 
  {"ret","INT"},
};

--添加/删除角色
PlatformMsg.MSG_P_ADD_PLAYER =
{
    {"UserID","INT"},                             --///用户ID
    {"PlayerName","CHARSTRING[50]"},              --//角色名  
    {"IsAdd","BOOL"},                             --//删除添加标志位
};

--返回结果
PlatformMsg.MSG_GP_S_PLAYERRESULT =
{
    {"bType","BYTE"},                            --////0:增加，1：删除，2：切换，3：转移，4：改名，5：领取
    {"ret","INT"},                                --//结果  
}; 

--切换角色
PlatformMsg.MSG_P_SWITCH_PLAYER =
{
    {"UserID","INT"},                             --///用户ID
    {"PlayerID","INT"},                           --//角色名ID  
};

--转移角色
PlatformMsg.MSG_P_TRANS_PLAYER =
{
    {"UserID","INT"},                             --///用户ID
    {"TargetUserID","INT"},                       --///目标ID
    {"PlayerID","INT"},                           --//角色名ID
};

PlatformMsg.MSG_GP_S_TRANSPLAYER =
{
    {"UserID","INT"},                             --///用户ID
    {"TargetUserID","INT"},                       --///目标ID
    {"PlayerID","INT"},                           --//角色名ID
    {"bType","BYTE"},                            --////0:增加，1：删除，2：切换，3：转移，4：改名，5：领取
    {"ret","INT"},                                --//结果  
};

--角色改名
PlatformMsg.MSG_P_CHANGE_PNAME =
{
    {"UserID","INT"},                             --///用户ID
    {"PlayerID","INT"},                           --//角色名ID  
    {"PlayerName","CHARSTRING[50]"},              --//角色名  
};

--用户角色存分
PlatformMsg.MSG_P_STORE_SCORE =
{
    {"UserID","INT"},                             --///用户ID
    {"PlayerID","INT"},                           --//角色名ID 
    {"Score","LLONG"},                            --//分数 
};

--用户角色取分
PlatformMsg.MSG_P_GET_SCORE =
{
    {"UserID","INT"},                             --//用户ID
    {"PlayerID","INT"},                           --//角色名ID 
    {"Score","LLONG"},                            --//分数  
    {"MD5_BANKPASS","CHARSTRING[54]"}
};

--用户角色存取分结果
PlatformMsg.MSG_GP_S_PLAYERSCORE =
{
    {"UserID","INT"},                             --//用户ID
    {"Score","LLONG"},                            --//分数  
    {"ret","INT"},                                --//存取分结果  
};

--救济金
PlatformMsg.MSG_P_GET_JIUJI =
{
    {"UserID","INT"},                             --//用户ID
};

--救济金返回结果
PlatformMsg.MSG_GP_S_JIUJI =
{
    {"UserID","INT"},                             --//用户ID
    {"JiuJiTimes","INT"},                             --//救济次数
    {"Score","LLONG"},                            --//分数 
    {"ret","INT"},                                --//结果 
};

--//邮件系统
PlatformMsg.MSG_P_GET_MAILLIST =
{
    {"UserID","INT"},                             --//用户ID
};

--邮件列表信息
PlatformMsg.MSG_GP_S_MAILLIST =
{
    {"UserID","INT"},                              --//用户ID
    {"MailID","INT"},                              --//用户邮件ID
    {"Title","CHARSTRING[100]"},                    --//标题  
    {"uMessage","CHARSTRING[250]"},                --//内容
    {"IsUse","BOOL"},                              --//是否已读  
    {"Goods","CHARSTRING[250]"},                               --
    {"CreateDate","INT"},               --//创建时间  
    {"OperateDate","INT"},              --//操作时间  
    {"MailType","INT"},              --///// 0 普通邮件 1 VIP邀请
};

--获取邮件物品
PlatformMsg.MSG_P_GET_GOODS =
{
    {"UserID","INT"},                              --//用户ID
    {"MailID","INT"},                              --//用户邮件ID
};

--获取邮件列表
PlatformMsg.MSG_P_GET_MAILLIST =
{
    {"UserID","INT"},                              --//用户ID
};

--读邮件
PlatformMsg.MSG_P_READ_MAIL =
{
    {"UserID","INT"},                              --//用户ID
    {"MailID","INT"},                              --//用户邮件ID
    {"readType","INT"}
};

--邮件处理结果
PlatformMsg.MSG_GP_S_MAILSRESULT =
{
    {"bType","BYTE"},                            --////0:增加，1：删除，2：切换，3：转移，4：改名，5：领取
    {"ret","INT"},                                --//结果 
    {"MailID","INT"},                              --//用户邮件ID
};

--删除邮件
PlatformMsg.MSG_P_DELETE_MAIL =
{
    {"UserID","INT"},                              --//用户ID
    {"MailID","INT"},                              --//用户邮件ID
};

--排行
PlatformMsg.MSG_GET_RANK_LIST =
{
    {"UserID","INT"},                             --//用户ID
    {"PlayerID","INT"},                           --//角色名ID 
    {"count","LLONG"},                            --//分数 
    {"playerName","CHARSTRING[50]"},              --//角色名 
};

--BOSS击杀排行
PlatformMsg.MSG_GET_BOSSRANK_LIST =
{
    {"UserID","INT"},                             --//用户ID
    {"PlayerID","INT"},                           --//角色名ID 
    {"count","INT"},                            --//BOSS击杀数量 
    {"playerName","CHARSTRING[50]"},              --//角色名 
};


PlatformMsg.MSG_S_ConnectSuccess = {    --连接成功消息
    {"bMaxVer","BYTE"},
    {"bLessVer","BYTE"},
    {"bReserve","BYTE[2]"},
    {"i64CheckCode","UINT"},
}

PlatformMsg.CenterServerMsg = {    
    {"m_is_haveZhuanZhang","INT"},
    {"m_strGameSerialNO","CHARSTRING[20]"},     --客户端当前版本系列号
    {"m_strMainserverIPAddr","CHARSTRING[40]"}, --主服务器IP地址
    {"m_iMainserverPort","INT"},                   --主服务器端口号         
    {"m_strWebRootADDR","CHARSTRING[128]"},
    {"m_strHomeADDR","CHARSTRING[128]"},
    {"m_strHelpADDR","CHARSTRING[128]"},
    {"m_strDownLoadSetupADDR","CHARSTRING[128]"},
    {"m_strDownLoadUpdatepADDR","CHARSTRING[128]"},
    {"m_strRallAddvtisFlashADDR","CHARSTRING[128]"},
    {"m_strRoomRollADDR","CHARSTRING[200]"},
    {"m_nHallInfoShowClass","INT"},
    {"m_nEncryptType","INT"},
    {"m_nFunction","UINT"},
    {"m_lNomalIDFrom","INT"},
    {"m_lNomalIDEnd","INT"},
    {"m_nIsUsingIMList","INT"},
    {"m_iGameserverPort","INT"}--                   //主服务器端口号 
}

PlatformMsg.MSG_GP_S_LogonByNameStruct = {
    {"uRoomVer","UINT"},            --大厅版本
    {"szName","CHARSTRING[64]"},          --登陆名字
    {"TML_SN","CHARSTRING[128]"},
    {"szMD5Pass","CHARSTRING[52]"},       --登陆密码
    {"szMathineCode","CHARSTRING[64]"},   --本机机器码 锁定机器
    {"szCPUID","CHARSTRING[24]"},         --CPU的ID
    {"szHardID","CHARSTRING[24]"},        --硬盘的ID
    {"szIDcardNo","CHARSTRING[64]"},      --证件号
    {"szMobileVCode","CHARSTRING[8]"},    --手机验证码
    {"gsqPs","INT"},
    {"iUserID","INT"},              --用户ID登录，如果ID>0用ID登录
    {"device_info","CHARSTRING[50]"},    --设备唯一标识
    {"device_type","INT"},               --设备类型  0  Android  1 iOS
    {"AgentID","INT"},
    {"szIP","CHARSTRING[20]"}
}

PlatformMsg.MSG_GP_GET_DEVICE = {
    {"UserID","INT"},
    {"device_info","CHARSTRING[50]"},    --设备唯一标识
    {"device_type","INT"},               --设备类型  0  Android  1 iOS
};

PlatformMsg.MSG_GP_R_LogonResult = {
    {"dwUserID","INT"},                 --用户 ID
    {"dwGamePower","INT"},              --游戏权限
    {"dwMasterPower","INT"},            --管理权限
    {"dwMobile","INT"},                 --手机号码
    {"dwAccID","INT"},                  --Acc 号码
    {"dwLastLogonIP","UINT"},           --上次登陆 IP
    {"dwNowLogonIP","UINT"},            --现在登陆 IP
    {"bLogoID","UINT"},                 --用户头像 
    {"bBoy","BOOL"},                    --性别
    {"szName","CHARSTRING[61]"},              --用户登录名
    {"weChat","CHARSTRING[128]"},             --数字签名
    {"szMD5Pass","CHARSTRING[50]"},           --用户密码
    {"nickName","CHARSTRING[100]"},           --用户昵称
    {"i64Money","LLONG"},               --用户金币
    {"i64Bank","LLONG"},                --用户财富
    {"iLotteries","DOUBLE"},                --奖券
    {"dwFascination","INT"},                --魅力
    {"dwDiamond","INT"},                --钻石
    {"iRoomKey","INT"},                --钻石数量
    --新用户资料
    {"szRealName","CHARSTRING[50]"},                --真实姓名
    {"szIDCardNo","CHARSTRING[36]"},                --证件号
    {"szMobileNo","CHARSTRING[50]"},                --移动电话
    {"szQQNum","CHARSTRING[20]"},                --QQ号码
    {"szAdrNation","CHARSTRING[50]"},                --玩家的国藉
    {"szAdrProvince","CHARSTRING[50]"},                --玩家所在的省份
    {"szAdrCity","CHARSTRING[50]"},                --玩家所在的城市
    {"szZipCode","CHARSTRING[10]"},                --邮政编码
    {"dwTimeIsMoney","INT"},                --上次登陆时长所换取的金币
    {"iVipTime","INT"},                     --
    {"iDoublePointTime","INT"},                --双倍积分时间
    {"iProtectTime","INT"},                --护身符时间，保留
    {"bLoginBulletin","BOOL"},                --是否有登录公告
    {"iLockMathine","INT"},                --当前帐号是否锁定了某台机器，1为锁定，0为未锁定
    {"iBindMobile","INT"},                     --当前帐号是否绑定手机号码，1为绑定，0为未绑定
    {"iAddFriendType","INT"},                --是否允许任何人加为好友
    {"szAgentCode","CHARSTRING[20]"},                --代理验证码
    {"nNameID","INT"},                --
    {"nRoomID","INT"},                     --
    {"nDeskIndex","INT"},                --
    {"szIP","CHARSTRING[50]"},                --
    {"nPort","INT"},                     --
    {"szPwd","CHARSTRING[60]"},                --
    {"VIPLevel","INT"},
    {"IsYueKa","INT"},
    {"YueKatime","INT"},
    {"IsGetYkScore","INT"},
    {"bSetBankPass","INT"},
    {"AgencyLevel","INT"},
    {"BankNo","CHARSTRING[20]"},
    {"Alipay","CHARSTRING[50]"},
    {"Exper","INT"},
    {"MachineCode","CHARSTRING[64]"},
    {"Ebat","CHARSTRING[100]"},
    {"AgentID","INT"},
    {"IsCommonUser","INT"},
    {"UserChouShui","INT"},
}

PlatformMsg.MSG_GP_C_USE_ROOM_KEYINFO = {
    {"iUserID","INT"},
}

PlatformMsg.MSG_GP_S_Room_CutNet_User_struct = {
    {"iuserid","INT"},
    -- {"inameid","INT"},
    -- {"iroomid","INT"},  --命名和MSG_GP_S_USE_ROOM_KEY统一
    -- {"ideskid","INT"},
    {"iNameID","INT"},
    {"iRoomID","INT"},
    {"iDeskID","INT"},
    {"szLockPass","CHARSTRING[61]"},
}

PlatformMsg.MSG_GP_C_DESK_LOCK_PASS = {
    {"nUserID","INT"},
    {"szLockPass","CHARSTRING[61]"},
}

PlatformMsg.MSG_GP_S_DESK_LOCK_PASS = {
    {"iNameID","INT"},                   --游戏ID
    {"iDeskID","INT"},                    --桌子ID
    {"uServicePort","INT"},             --大厅服务端口
    {"szServiceIP","CHARSTRING[25]"},   --服务器 IP 地址
    {"bAAFanKa","BOOL"},                --是否AA制钻石
}

PlatformMsg.MSG_CreateDeskCost_REQ = {
    {"iNameID","INT"}, 
}

PlatformMsg.MSG_CreateDeskCost_RES = {
    {"id","INT"},               --id
    {"iGameRound","INT"},       --游戏局数 
    {"iGameCost","INT"},        --钻石消耗
}

PlatformMsg.ItemCreatInfo = {  
    {"nCreateID","INT"},
    {"nRuleID","INT"},
    {"bAAFanKa","BOOL"},
}

PlatformMsg.MSG_GP_SR_GetRoomStruct = {
    {"uKindID","UINT"},
    {"uNameID","UINT"},
}

PlatformMsg.AssistantHead = {       --游戏列表辅助结构
    {"uSize","UINT"},           --数据大小
    {"bDataType","UINT"},          --类型标识
}

PlatformMsg.MSG_GP_C_USE_ROOM_KEY = {
    {"iNameID","INT"},
    {"iUserID","INT"},
    {"iRoomID","INT"},
    {"iGameRoundId","INT"},
    {"iGameRule","LLONG"},
    {"bAAFanKa","BOOL"},
}

PlatformMsg.MSG_GP_S_USE_ROOM_KEY = {
    {"iNameID","INT"},
    {"iRoomID","INT"},
    {"iDeskID","INT"},
    {"szLockPass","CHARSTRING[61]"},
}

PlatformMsg.MSG_GP_S_Register = {
    {"byFromPhone","BYTE"},
    {"byFastRegister","BYTE"},
    {"szHardID","CHARSTRING[64]"},
    {"szName","CHARSTRING[64]"},
    {"szPswd","CHARSTRING[64]"},
    {"LogonTimes","UINT"},
    {"dwUserID","INT"},
    {"UserCheckPhone","CHARSTRING[16]"},
    {"PhoneNum","CHARSTRING[16]"},
    {"AgencyID","INT"},
    {"answer","CHARSTRING[100]"},
    {"AgentID","INT"},
    {"szIP","CHARSTRING[20]"},
    {"qudao","CHARSTRING[50]"},
    {"jsstring","CHARSTRING[800]"},
    {"wxID","CHARSTRING[100]"},
    {"registerid","INT"}
}

PlatformMsg.MSG_GP_C_GET_USERINFO = {
    {"dwUserID","INT"}, --//用户ID
}

-- // 登陆服务器登陆信息
PlatformMsg.DL_GP_RoomListPeoCountStruct = {
    {"uID","UINT"}, --//房间ID
    {"uOnLineCount","UINT"},    --//在线人数
    {"uVirtualUser","INT"},     --//扩展机器人人数
}

-- // 进入密码房间返回信息
PlatformMsg.MSG_GP_S_C_CheckRoomPasswd = {
    {"bRet","BOOL"},    --// 成功与否
    {"uRoomID","UINT"}, --// 房间号
}

-- //匹配房间,最少需要钻石数
PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY = {
    {"iNameID","INT"},--//游戏ID
    {"iRoomID","INT"},
    {"nMinRoomKey","INT"},--//最少需要钻石数
}

-- //兑换列表
PlatformMsg.TCharmExchange_Item = {
    {"iID","INT"},
    {"iPoint","INT"},
    {"iPropID","INT"},
    {"iPropCount","INT"},
}


PlatformMsg.CMD_ExChangeRat = {
    {"RoomKeyToMoney","INT"},
    {"MoneyToHuaFei","INT"},
    {"iCharge","INT"},--//手续费
}

PlatformMsg.CMD_ExChangeResult = {
    {"bRet", "BOOL"},
}

PlatformMsg.CMD_GetHFList = {
    {"UserID", "INT"},
}

PlatformMsg.CMD_ListHF = {
    {"UserID", "INT"},
    {"Num", "INT"},
    {"state", "INT"},
    {"date", "CHARSTRING[50]"},
}

PlatformMsg.MSG_GP_S_GET_USERINFO = {
    {"dwUserID", "INT"},--//用户ID
    {"i64WalletMoney", "LLONG"},--//身上的钱
    {"i64BankMoney", "LLONG"},--//银行的钱
    {"dwFascination", "INT"},-- //魅力
    {"dwDiamond", "INT"},--//钻石
    {"szNickName", "CHARSTRING[61]"},--//昵称
    {"dwLogoID", "INT"},--//头像ID
    {"bBoy", "BOOL"},--//性别
    {"szSignDescr", "CHARSTRING[128]"},--//个性签名
    {"iRoomKey", "INT"},--//钻石数量
    {"iLotteries", "DOUBLE"}, --//礼券
}

PlatformMsg.MSG_PROP_C_GETSAVED = {
    {"dwUserID", "INT"},--//用户ID
}

--代开房
PlatformMsg.MSG_GP_C_GETROOMLIST = {
    {"UserID", "INT"},
}

PlatformMsg.MSG_GP_S_ROOMLIST = {
    {"iNameID", "INT"},--//游戏ID
    {"iRoomID", "INT"},-- //房间ID
    {"iDeskID", "INT"},--//桌子ID
    {"RoomRule", "INT"},--//游戏规则
    {"IAAFanKa", "BOOL"},--//aa制
    {"LeftRound", "INT"},--//局数
    {"GameRound","INT"}, --//总局数
    {"UserID", "INT"},--//用户id
    {"DiffTime","INT"},--           //剩余时间
    {"UserName", "CHARSTRING[61]"},--//用户名字
    {"szLockPass", "CHARSTRING[61]"},--//上锁密码
    {"UseTime", "CHARSTRING[50]"},--//是否被使用
    {"CreateTime","CHARSTRING[50]"},--//创建时间
}

PlatformMsg.MSG_GP_C_DISMISS = {
    {"iUserID","INT"},
    {"iNameID","INT"},--//游戏ID
    {"iRoomID","INT"},--//房间ID
    {"iDeskID","INT"},--//桌子ID
    {"szLockPass","CHARSTRING[61]"},--//上锁密码
}

PlatformMsg.MSG_SETLOGO_INFO = {
    {"dwUserIdx","INT"},
    {"bLogoIdx","INT"},
}

PlatformMsg.MSG_WX_SHARE_GET = 
{
    {"iUserRoomKey","INT"},
    {"leftShare","INT"},
}

--请求签到列表
PlatformMsg.MSG_P_GETNEWUSERREWARDLIST =
{
    {"UserID","INT"},
}

PlatformMsg.MSG_P_GETNEWUSERREWARD =
{
    {"UserID","INT"},
}

--签到结果
PlatformMsg.MSG_GP_S_NewReward =
{
    {"UserID","INT"},
    {"ret","INT"},
}

PlatformMsg.MSG_RewardGoods = {
    {"goodsID","INT"},
    {"goodsIcon","CHARSTRING[20]"},
    {"goodsCount","INT"},
}

PlatformMsg.MSG_SIGNINFO = {
    {"day","INT"},
    {"rewardInfo","PlatformMsg.MSG_RewardGoods[10]"}
}

PlatformMsg.MSG_SIGNLISTINFO = {
    {"signListInfo","PlatformMsg.MSG_SIGNINFO[7]"}
}
--签到信息
PlatformMsg.MSG_GP_S_NewRewardLIST =
{
    {"UserID","INT"},
    {"days","PlatformMsg.MSG_SIGNINFO[7]"},
}

PlatformMsg.MSG_GP_S_NewUserRewardStateList =
{
    {"UserID","INT"},
    {"days","INT[8]"},
}

--捕鱼比赛场
--//报名捕鱼比赛
PlatformMsg.MSG_GP_ENROLL_FISH_MATCH =
{
    {"UserID","INT"},
    {"MatchID","INT"},
};

--//获取玩家捕鱼比赛信息
PlatformMsg.MSG_GP_GET_USER_MATCH_INFO =
{
    {"UserID","INT"},
    {"MatchID","INT"},
};

--//获取比赛奖励列表
PlatformMsg.MSG_GP_GET_FISH_MATCH_REWARD =
{
   {"MatchID","INT"},
};

--//获取比赛排名
PlatformMsg.MSG_GP_GET_FISH_MATCH_RANK =
{
    {"MatchID","INT"},
};

--////获取比赛列表--数组
PlatformMsg.MSG_GP_S_GET_FISH_MATCH_INFO =
{
    {"MatchID","INT"},
    {"MatchName","CHARSTRING[25]"},
    {"MatchType","INT"},
    {"MatchStart","INT"},
    {"MatchEnd","INT"},
    {"MatchCost","INT"},
    {"RoomID","INT"},
    {"NowTime","INT"},
};

--////报名比赛
PlatformMsg.MSG_GP_S_ENROLL_FISH_MATCH =
{
    {"UserID","INT"},
    {"MatchID","INT"},
    {"ret","INT"},
};

--////获取用户比赛信息
PlatformMsg.MSG_GP_S_GET_USER_MATCH_INFO =
{
    {"UserID","INT"},
    {"MatchID","INT"},
    {"MatchScore","LLONG"},
    {"MatchRank","INT"},
    {"TotalNum","INT"},
    {"MatchCost","INT"},
    {"IsPlay","INT"},
    {"MatchFreeCount","INT"},
};

--////获取比赛排名--数组
PlatformMsg.MSG_GP_S_GET_FISH_MATCH_RANK =
{
    {"MatchID","INT"},
    {"UserID","INT"},
    {"PlayerName","CHARSTRING[25]"},
    {"MatchScore","LLONG"},
};

--////获取比赛奖励列表--数组
PlatformMsg.MSG_GP_S_GET_FISH_MATCH_REWARD =
{
    {"MatchType","INT"},
    {"MatchReward","INT"},
};

--VIP
PlatformMsg.MSG_P_GETUSERVIPREWARD =
{
    {"UserID","INT"},
    {"VipID","INT"},
};

PlatformMsg.MSG_GP_S_GET_VIP_LIST =
{
    {"VipID","INT"},
    {"NeedCharge","INT"},
    {"PaoTai","INT"},
    {"PresentScore","INT"},
    {"PropCard1","INT"},
    {"PropCard2","INT"},
    {"PropCard3","INT"},
};

PlatformMsg.MSG_GP_S_GET_VIP_REWARD =
{
    {"UserID","INT"},
    {"VipID","INT"},
    {"ret","INT"},
};

------------------炮台相关
PlatformMsg.MSG_P_GETUSERPAOTAI =
{
    {"UserID","INT"},
    {"PaoTaiID","INT"},
};

--购买炮台
PlatformMsg.MSG_P_BUYPAOTAI =
{
    {"UserID","INT"},
    {"PaoTaiID","INT"},
};

--////获取炮台列表(数组)
PlatformMsg.MSG_GP_S_GET_PAOTAILIST =
{
    {"ID","INT"},
    {"NeedMoney","INT"},
    {"NeedLevel","INT"},
};

--////获取用户炮台结果
PlatformMsg.MSG_GP_S_GET_USER_PAOTAI =
{
    {"UserID","INT"},
    {"PaoTaiID","INT"},
    {"HavePaoTai","INT"},
};

--////购买炮台结果
PlatformMsg.MSG_GP_S_BUY_PAOTAI =
{
    {"UserID","INT"},
    {"PaoTaiID","INT"},
    {"ret","INT"},
};

PlatformMsg.MSG_GP_S_ChPassword = {
    {"dwUserID","INT"},
    {"szHardID","CHARSTRING[24]"},
    {"UserCheckPhone","CHARSTRING[16]"},
    {"szMD5NewPass","CHARSTRING[80]"},
    {"PassType","INT"},
    {"PhoneNum","CHARSTRING[64]"},
    {"channel","INT"}
}

PlatformMsg.MSG_P_SET_BANKPASS = {
    {"UserID","INT"},
    {"MD5_BANKPASS","CHARSTRING[54]"},
    {"setType","INT"}
}

PlatformMsg.MSG_GP_SETBANKPASSRESULT = {
    {"ret","INT"}
}

PlatformMsg.MSG_P_GET_QUESTUONLIST =
{
    {"UserID","INT"}
}

PlatformMsg.MSG_P_ADD_QUESTUON =
{
    {"UserID","INT"},
    {"Question","CHARSTRING[250]"}
}

PlatformMsg.MSG_GP_S_ADDQUESTION =
{
    {"ret","INT"},
}

PlatformMsg.MSG_GP_S_QUESTIONLIST =
{
    {"UserID","INT"},
    {"QuestionID","INT"},
    {"Question","CHARSTRING[250]"},
    {"Answer","CHARSTRING[250]"},
    {"IsUse","INT"},
    {"CreateDate","INT"},
    {"OperateDate","INT"}
}

PlatformMsg.MSG_P_GET_BANKLOG =
{
    {"UserID","INT"}
}

PlatformMsg.MSG_GP_S_GETBANKLOG =
{
    {"UserID","INT"},
    {"OperatScore","LLONG"},
    {"NowScore","LLONG"},
    {"bType","CHARSTRING[50]"},
    {"ColletTime","INT"}
}

PlatformMsg.MZTW_Mess_UserInfo =
{
    {"UserID","INT"},
    {"i64WalletMoney","LLONG"},
}

PlatformMsg.MSG_GP_GET_TOTAL =
{
    {"UserID","INT"},
}

PlatformMsg.MSG_GP_GET_DETAIL =
{
    {"UserID","INT"},
    {"Day","INT"}
}

PlatformMsg.MSG_GP_S_GET_TOTAL =
{
    {"UserID","INT"},
    {"UpAgencyID","INT"},
    {"TeamCount","INT"},
    {"DirectCount","INT"},
    {"NewAdd","INT"},
    {"TodayActive","INT"},
    {"WeekDirectAchieve","LLONG"},
    {"WeekTeamAchieve","LLONG"},
    {"PredictReward","LLONG"},
    {"TotalReward","LLONG"},
    {"AgencyReward","LLONG"},
    {"UsedReward","LLONG"},
    {"ProvisionsScore","LLONG"},
    {"LeftProvisionsReward","LLONG"},
    {"TodayProvisionsScore","LLONG"},
}

PlatformMsg.MSG_GP_S_GET_DETAIL =
{
    {"UserID","INT"},
    {"NickName","CHARSTRING[50]"},
    {"TeamCount","INT"},
    {"DirectCount","INT"},
    {"TeamRevenue","LLONG"},
    {"DirectRevenue","LLONG"}
}

PlatformMsg.MSG_GET_NEED_LEVEL =
{
    {"levelid","INT"},
    {"needexper","LLONG"},
    {"Rat","INT"},
    {"LevelName","CHARSTRING[50]"},
}

PlatformMsg.MSG_GET_AGENCY_LEVEL =
{
    {"nUserID","INT"},
    {"nLevel","INT"}
}

PlatformMsg.MSG_GET_ACHIEVE =
{
    {"DirectAchieve","LLONG"},
    {"TeamAchieve","LLONG"},
    {"Id","INT"},
}

PlatformMsg.MSG_GET_REWARD =
{
    {"WeekDirectAchieve","LLONG"},
    {"WeekTeamAchieve","LLONG"},
    {"WeekRewrd","LLONG"},
    {"Flag","INT"},
    {"RewardDate","CHARSTRING[50]"},
}

PlatformMsg.MSG_GP_S_GET_CASH_LOG =
{
    {"UserID","INT"},
    {"bType","INT"},
    {"OrderNum","CHARSTRING[50]"},
    {"BankNo","CHARSTRING[50]"},
    {"lScore","LLONG"},
    {"Operate","INT"},
    {"CollectTime","INT"}
}

PlatformMsg.MSG_GP_GET_PROVISIONS =
{
    {"UserID","INT"},
    {"lScore","LLONG"},
}

 -- //绑定支付宝，银行卡
PlatformMsg.MSG_GP_UPDATE_ALIPAY = 
{
    {"UserID","INT"},
    {"RealName","CHARSTRING[50]"},--//真实姓名
    {"Alipay","CHARSTRING[50]"},--卡号
    {"bType","INT"},--//类型
    {"BankType","INT"},--
}

PlatformMsg.MSG_GP_GET_CASH_LOG =
{
    {"UserID","INT"},
    {"bType","INT"},--//类型
}


PlatformMsg.MSG_GP_GET_CASH =
{
    {"UserID","INT"},
    {"bType","INT"},--//类型
    {"lScore","LLONG"},--//类型
    {"ebetAddr","CHARSTRING[100]"}
}

PlatformMsg.MSG_GP_SETTLEMENT = 
{
    {"ret","INT"}
}

PlatformMsg.MSG_GP_S_GET_AGENTWECHAT =
{
    {"WeChat","CHARSTRING[50]"}
}

PlatformMsg.MSG_GP_WEB_INFO = {
    {"UserID","INT"},
    {"info","CHARSTRING[1000]"}
}

PlatformMsg.MSG_GP_SR_GetAgentGameList = {
    {"AgentID","INT"}
}

PlatformMsg.SignWeekOpen = {
    {"DayCount","INT"},--第几天
    {"SignState","INT[7]"},--  -1 不可签到 0 待签到 1 已签到
    {"SignRecord","PlatformMsg.SignRecordElem[4]"}--签到记录
}

PlatformMsg.SignRecordElem = {
    {"nickName","CHARSTRING[64]"},
    {"moneyGet","INT"}
}


PlatformMsg.SignWeekSignIn = {
    {"nickName","CHARSTRING[64]"},
    {"moneyGet","INT"}
}

PlatformMsg.LuckRecordElem = --//轮盘记录
{
    {"awardTime","INT"},
    {"nickName","CHARSTRING[50]"},
    {"wheelKind","INT"},
    {"awardLevel","INT"},
    {"awardMoney","INT"},
    {"iUserID","INT"},
    {"isRecordBig","INT"}--大小奖 大奖1
};

PlatformMsg.LuckAwardOpen = --//打开夺宝
{
    {"bigAward","PlatformMsg.LuckRecordElem[20]"},--//大奖记录
    {"smallAward","PlatformMsg.LuckRecordElem[4]"},--小奖记录
    {"selfAward","PlatformMsg.LuckRecordElem[20]"},--个人记录
    {"curPoint","INT"},--当前积分
    {"curNote","INT"}--今日有效下注
};

PlatformMsg.Cm_LuckAwardWheel = --//转动轮盘
{
    {"wheelKind","INT"},
};

PlatformMsg.LuckAwardWheel = --//通知轮盘结果
{
    {"awardLevel","INT"},
    {"awardMoney","INT"},
    {"curPoint","INT"}--当前积分
};

PlatformMsg.WheelInfo =--//轮盘信息
{
    {"kind","INT"},
    {"needPoint","INT"},
    {"isEnable","INT"},
    {"award","INT[7]"}
};

--合伙人-----------------------------
PlatformMsg.MSG_GP_GET_PARTNERINFO = 
{
  {"UserID","INT"},--//用户ID
};
PlatformMsg.MSG_GP_GET_PARTNERSCORE = 
{
  {"UserID","INT"},--//用户ID
  {"lScore","LLONG"},
};
PlatformMsg.MSG_GP_STORE_PARTNERSCORE = 
{
  {"UserID","INT"},--//用户ID
  {"lScore","LLONG"},
};
PlatformMsg.MSG_GP_GET_PARTNERUSERINFO = 
{
  {"UserID","INT"},--//用户ID.
  {"Day","INT"},
};

PlatformMsg.MSG_GP_GET_PARTNERUSERINFODETAIL = 
{
  {"UserID","INT"},--//用户ID
  {"DownUserID","INT"},--//用户ID
  {"Day","INT"},
};

PlatformMsg.MSG_GP_OPEN_PARTNER = 
{
  {"UserID","INT"},--//用户ID
  {"Rat","INT"},
  {"bType","INT"},
  {"PartnerMaxWin","LLONG"},
};

PlatformMsg.MSG_GP_UPDATE_PARTNERTIME = 
{
  {"UserID","INT"},--//用户ID
  {"StartTime1","INT"},
  {"EndTime1","INT"},
  {"StartTime2","INT"},
  {"EndTime2","INT"},
  {"StartTime3","INT"},
  {"EndTime3","INT"},
};

PlatformMsg.MSG_GP_S_GET_PARTNERINFO = 
{
    {"PartnerScore","LLONG"},
    {"PartnerIncome","LLONG"},
    {"PartnerRat","INT"},
    {"IsPartner","INT"},
    {"UserCount","INT"},
    {"StopTime","INT"},
    {"StartTime1","INT"},
    {"EndTime1","INT"},
    {"StartTime2","INT"},
    {"EndTime2","INT"},
    {"StartTime3","INT"},
    {"EndTime3","INT"},
    {"TempStartTime1","INT"},
    {"TempEndTime1","INT"},
    {"TempStartTime2","INT"},
    {"TempEndTime2","INT"},
    {"TempStartTime3","INT"},
    {"TempEndTime3","INT"},
    {"PartnerMaxWin","LLONG"},
};

PlatformMsg.MSG_GP_S_GET_PARTNERSCORE = 
{
  {"PartnerScore","LLONG"},
  {"BankScore","LLONG"},
  {"ret","INT"},
};
PlatformMsg.MSG_GP_S_STORE_PARTNERSCORE = 
{
  {"PartnerScore","LLONG"},
  {"BankScore","LLONG"},
  {"ret","INT"},
};
PlatformMsg.MSG_GP_S_OPEN_PARTNER = 
{
  {"ret","INT"},
  {"UserID","INT"},
};
PlatformMsg.MSG_GP_S_UPDATE_PARTNERTIME = 
{
  {"ret","INT"},
  {"UserID","INT"},
};
PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFO = 
{
  {"UserID","INT"},
  {"NickName","CHARSTRING[50]"},
  {"SumScore","LLONG"},
};
PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFODETAIL = 
{
  {"RoomID","INT"},
  {"CreateDate","INT"},
  {"Score","LLONG"},
  {"PartnerRat","INT"},
};

------------------------------------------
----------新推广模式-----------------------

--client to server
PlatformMsg.MSG_GP_GET_TOTALFORB = 
{
  {"UserID","INT"},--//用户ID
};
PlatformMsg.MSG_GP_GET_DETAILFORB = 
{
  {"UserID","INT"},--//用户ID
  {"Day","INT"},--//用户ID
};
PlatformMsg.MSG_GP_GET_AGENCYREWARDFORB = 
{
  {"UserID","INT"},--//用户ID
};
PlatformMsg.MSG_GP_GET_AGENCYREWARDLOGFORB = 
{
  {"UserID","INT"},--//用户ID
};

--server to client
PlatformMsg.MSG_GP_S_GET_TOTALFORB = 
{
  {"LastReward","LLONG"},
  {"DirectRevenue","LLONG"},
  {"TeamRevenue","LLONG"},
  {"TotalReward","LLONG"},
  {"AgencyReward","LLONG"},
  {"DirectCount","INT"},
  {"TeamCount","INT"},
};

PlatformMsg.MSG_GP_S_GET_DETAILFORB = 
{
  {"NickName","CHARSTRING[50]"},
  {"DirectRevenue","LLONG"},
  {"TeamRevenue","LLONG"},
};

PlatformMsg.MSG_GP_S_GET_AGENCYREWARDFORB = 
{
  {"ret","INT"},
};

PlatformMsg.MSG_GP_S_GET_AGENCYREWARDLOGFORB = 
{
  {"TradeScore","LLONG"},
  {"CreateDate","INT"},
};

PlatformMsg.MSG_GP_S_GET_AGENCYREWARDRANKFORB = 
{
  {"UserID","INT"},       
  {"NickName","CHARSTRING[50]"},
  {"Revenue","LLONG"},
};

PlatformMsg.MSG_GP_GET_RAT = 
{
  {"NameID","INT"},
  {"AgentID","INT"},
};

PlatformMsg.MSG_GP_S_GET_RAT = 
{
  {"AgentID","INT"},
  {"NameID","INT"},
  {"Rat","INT"},
};

------------------------------------------

return PlatformMsg