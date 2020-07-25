local ComStruct = {}

-- /// 房间规则设置
GRR_MEMBER_ROOM			=	0x00000001							--//会员房间
GRR_IP_LIMITED			=	0x00000002							--//地址限制
GRR_ENABLE_WATCH		=	0x00000004							--//允许旁观
GRR_UNENABLE_WATCH		=	0x00000008							--//不许旁观
GRR_AUTO_SIT_DESK		=	0x00000010							--//自动坐下，现在用于防作弊场使用
GRR_LIMIT_DESK			=	0x00000020							--//限制座位
GRR_LIMIT_SAME_IP		=	0x00000040							--//限制同IP
GRR_RECORD_GAME			=	0x00000080							--//记录游戏
GRR_STOP_TIME_CONTROL	=	0x00000100							--//停止时间控制
GRR_ALL_ON_DESK			=	0x00000200							--//是否所有人坐下才开始启动
GRR_FORBID_ROOM_TALK	=	0x00000400							--//禁止房间聊天
GRR_FORBID_GAME_TALK	=	0x00000800							--//禁止游戏聊天
GRR_MATCH_REG			=	0x00001000							--//比赛报名
GRR_EXPERCISE_ROOM		=	0x00002000							--//训练场
GRR_VIDEO_ROOM			=	0x00004000							--//视频房间

--/// 修改防作弊场可看见其他玩家姓名和头像问题！
GRR_NOTFUFENG			=	0x00008000							--//不允许负积分
GRR_NOTCHEAT			=	0x00010000							--//防作弊

--/// 台费场
GRR_ALL_NEED_TAX		=	0x00020000							--//收台费场,所有人都需缴纳一定数额台费
GRR_QUEUE_GAME			=	0x00040000							--//排队机

GRR_NOT_COST_POINT		=	0x00080000							--//金币场不扣积分

GRR_CONTEST				=	0x00100000							--//定时淘汰比赛场

GRR_TIMINGCONTEST		=	0x00800000							--//定时赛		--RoomRule == 8388608




--///用户状态定义
USER_NO_STATE		= 	0									--//没有状态，不可以访问
USER_LOOK_STATE		= 	1									--//进入了大厅没有坐下
USER_SITTING		= 	2									--//坐在游戏桌
USER_ARGEE			=	3									--//同意状态
USER_WATCH_GAME		= 	4									--//旁观游戏
USER_DESK_AGREE		=	5									--///大厅同意
USER_CUT_GAME		= 	20									--//断线状态		（游戏中状态）
USER_PLAY_GAME		= 	21									--//游戏进行中状态	（游戏中状态）

-- tagItemCreatInfo
-- {
-- 	int		iCreateID;
-- 	int		iRule;
-- 	bool	bAAFanKa;
-- } ItemCreatInfo;

--/// 游戏列表辅助结构
ComStruct.AssistantHead = {
	{"uSize","UINT"},	--//数据大小
	{"bDataType","UINT"},	--//类型标识
}
-- /// 游戏名称结构
ComStruct.ComNameInfo = {
	{"Head",ComStruct.AssistantHead},
	{"uKindID","UINT"},	--//游戏类型 ID 号码
	{"uNameID","UINT"},	--//游戏名称 ID 号码
	{"szGameName","CHARSTRING[61]"},	--//游戏名称
	{"szGameProcess","CHARSTRING[61]"},	--//游戏进程名
	{"m_uOnLineCount","UINT"},	--//在线人数
	{"uVer","UINT"},	--///版本
}

-- ///游戏类型de结构
ComStruct.ComKindInfo = {--///加入游戏类型AddTreeData
	{"Head",ComStruct.AssistantHead},
	{"uKindID","UINT"},	--//游戏类型 ID 号码
	{"szKindName","CHARSTRING[61]"},	--//游戏类型名字
	{"uParentKindID","UINT"},	--//父游戏类型ID号码
}

-- /// 游戏房间列表结构
ComStruct.ComRoomInfo = {
    {"Head",ComStruct.AssistantHead},
    {"uComType","UINT"},
    {"uKindID","UINT"},
    {"uNameID","UINT"},
    {"uRoomID","UINT"},
    {"uPeopleCount","UINT"},
    {"iUpPeople","UINT"},
    {"uDeskPeople","UINT"},
    {"uDeskCount","UINT"},
    {"uServicePort","UINT"},
    {"szServiceIP","CHARSTRING[25]"},
    {"szGameRoomName","CHARSTRING[61]"},
    {"uVirtualUser","INT"},
    {"uVirtualGameTime","INT"},
    {"uVer","UINT"},
    {"dwRoomRule","UINT"},
    {"bVIPRoom","BOOL"},
    --1.1版本新增字段
    {"iBasePoint","INT"},
    {"iLessPoint","UINT"},
    {"iMaxPoint","UINT"},
    {"uRoomTypeID","UINT"},
    {"uRoomTypeSecondID","UINT"},
    {"iContestID","INT"},
    {"i64TimeStart","LLONG"},
    {"i64TimeEnd","LLONG"},
    {"iLeaseID","INT"},
    {"i64LeaseTimeStart","LLONG"},
    {"i64LeaseTimeEnd","LLONG"},
    {"uBattleRoomID","UINT"},
    {"szBattleGameTable","CHARSTRING[31]"},
    {"bHasPassword","BOOL"},
    {"dwTax","UINT"},
    {"uUserDeskCount","UINT"}
}

-- /// 用户信息结构
-- typedef struct tagUserInfoStruct 
-- {
-- 	INT						    dwUserID;							//ID 号码
-- 	INT						    dwExperience;						//经验值
-- 	INT							dwAccID;							//ACC 号码
-- 	INT							dwPoint;							//分数
-- 	LLONG						i64Money;							//金币
-- 	LLONG						i64Bank;							//银行
-- 	UINT						uWinCount;							//胜利数目
-- 	UINT						uLostCount;							//输数目
-- 	UINT						uCutCount;							//强退数目
-- 	UINT						uMidCount;							//和局数目
-- 	CHAR						szName[61];							//登录名
-- 	CHAR						szClassName[61];					//游戏社团
-- 	UINT						bLogoID;							//头像 ID 号码

-- 	UINT						bDeskNO;							//游戏桌号
-- 	BYTE						bDeskStation;						//桌子位置
-- 	BYTE						bUserState;							//用户状态

-- 	BYTE						bMember;							//会员等级
-- 	BYTE						bGameMaster;						//管理等级
-- 	UINT						dwUserIP;							//登录IP地址
-- 	bool						bBoy;								//性别
-- 	CHAR						nickName[100];						//用户昵称
-- 	UINT						uDeskBasePoint;						//设置的桌子倍数
-- 	INT							dwFascination;						//魅力
-- 	INT							iVipTime;							//会员时间
-- 	INT							iDoublePointTime;					//双倍积分时间
-- 	INT							iProtectTime;						//护身符时间，保留
-- 	INT							isVirtual;							//是否是扩展机器人 
-- 	UINT						dwTax;								//房费   

-- 	///玩家信息结构调整   
-- 	CHAR                        szOccupation[61];                   //玩家职业
-- 	CHAR                        szPhoneNum[61];                     //玩家电话号码
-- 	CHAR                        szProvince[61];                     //玩家所在的省
-- 	CHAR                        szCity[61];                         //玩家所在的市
-- 	CHAR                        szZone[61];                         //玩家所在的地区
-- 	bool                        bHaveVideo;                         //是否具有摄像头
-- 	CHAR						szSignDescr[128];			        //个性签名

-- 	//玩家类型信息
-- 	//0 ,普通玩家
-- 	//1 ,电视比赛玩家
-- 	//2 ,VIP玩家
-- 	//3 ,电视比赛VIP玩家
-- 	INT							userType;

-- 	//作为扩展字段,为方便以后新加功能用
-- 	//此处为以后平台中的新加功能需要修改用户信息结构时，不用重新编译所有游戏
-- 	UINT                        userInfoEx1;		//扩展字段1，用于邮游钻石身份作用时间
-- 	UINT						userInfoEx2;		//扩展字段2，用于GM处理之禁言时效

-- 	INT							bTrader;			//用于判断是不是银商  

-- 	///比赛专用
-- 	INT							iMatchID;			//比赛ID，唯一的标识一场比赛
-- 	LLONG						i64ContestScore;	//比赛分数
-- 	INT							iContestCount;		//比赛次数
-- 	//bool						bIsKick;			//是否被淘汰
-- 	CHAR						timeLeft[8];		//
-- 	INT							iRankNum;			//排行名次
-- 	INT							iRemainPeople;		//比赛中还剩下的人数
-- 	INT							iAward;				//比赛获取的奖励
-- 	INT                         iAwardType;         //比赛获取的奖励类型

-- 	//添加个人钻石数量
-- 	int							iRoomKeyNum;	//个人钻石

-- }  UserInfoStruct;

-- // 自动赠送添加的结构体
-- typedef struct tagRECEIVEMONEY 
-- {
-- 	bool      bISOpen;
-- 	//bool      bISAuto;	
-- 	LLONG	  i64Money;
-- 	LLONG	  i64MinMoney;
-- 	INT		  iCount;
-- 	INT		  iTotal;
-- 	INT		  iTime;   
-- 	INT       iResultCode; 
-- 	INT       iLessPoint;
-- }  RECEIVEMONEY;

-- #pragma pack()

-- #endif	//_HN_ComStruct_H__

return ComStruct