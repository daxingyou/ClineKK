
local VipMsg = { 

	MDM_GP_GUILD                    =  	190,									--///公会消息

	ASS_GP_CREATE_GUILD_REQ			=	1,										--//查询VIP配置
	ASS_GP_CREATE_REQ_MEMBER		=	2,										--//普通成员界面查询VIP配置
	ASS_GP_CREATE_GUILD				=	3,										--//创建公会

	HC_GP_GUILD_CREATE_SUCC      	=	0,  									--///创建成功
   	HC_GP_GUILD_CREATE_NUMERR    	=	1,  									--///只能创建一个
   	HC_GP_GUILD_CREATE_NAMEERR    	=	2,  									--///名字已被占用

	ASS_GP_DELETE_GUILD				=	4,										--//删除公会
	ASS_GP_CHANGE_RULE				=	5,										--//修改公会
	ASS_GP_APPLY_JOIN_REQ			=	6,										--//查询公会
	ASS_GP_APPLY_JOIN				=	7,										--//申请加入公会
	ASS_GP_QUIT_JOIN				=	8,										--//退出公会
	ASS_GP_AGREE_JOIN				=	9,										--//通过申请
	ASS_GP_REJECT_JOIN				=	10,										--//拒绝申请
	ASS_GP_GET_GUILD_LIST			=	11,										--//VIP厅列表
	 HC_GP_GUILD_OWNER				=	1,
	 HC_GP_GUILD_MEMBER				=	2,
	 HC_GP_GUILD_LIST_FINISH		=	0,

	
	ASS_GP_GET_GUILD_USER			=	12,										--//厅成员
	ASS_GP_KICK_GUILD_USER			=	13,										--//踢出公会
	ASS_GP_MEMBER_USERLIST      	=	14,                    					--//成员功能（厅详情）
	ASS_GP_GET_CALLTIME        		=	15,                    					--//一键召集时间
	ASS_GP_GET_GUILD_MESSAGE		=	16,										--//获取消息列表
	ASS_GP_READ_GUILD_MESSAGE		=	17,										--//读消息
	
	ASS_GP_GUILD_SETTOP             =	18,                    --//置顶
 	ASS_GP_GUILD_RECORD_REQ      	=	19,                    --//我的战绩
 	ASS_GP_CHANGE_USERNOTE      	=	20,                    --//修改备注
 	ASS_GP_GUILD_ONEKEYCALL      	=	21,                    --//一键召集

 	ASS_GP_GUILD_TAXDETAIL          =	22,                  	--//税收详情
	ASS_GP_GUILD_MEMBERDETAIL       =	23,                  	--//成员详情
	ASS_GP_GUILD_CHANGERULE_REQ    	=	24,                    	--//修改规则查询
	ASS_GP_GUILD_DELETE_NOTIFY    	=	25,                    	--//解散VIP厅
 	ASS_GP_GUILD_CHANGE_NOTIFY    	=	26,                    	--//修改规则
 	ASS_GP_GUILD_KICK_NOTIFY    	= 	27,                    	--//踢出公会

 	-----股东
 	ASS_GP_GUILD_HOLDER_REQ      	=	28,                    --//股东查询
	ASS_GP_GUILD_HOLDER_SET      	=	29,                   --//股东设置
	ASS_GP_GUILD_COMMEND_TIME    	=	30,                    --//推荐冷却时间
	ASS_GP_GUILD_COMMEND_REQ    	=	31,                    --//推荐查询
	ASS_GP_GUILD_COMMEND      		=	32,                    --//推荐
	ASS_GP_GUILD_COMMEND_AGREE    	=	33,                    --//同意推荐
	ASS_GP_GUILD_COMMEND_DETAIL    	=	34,                    --///推荐成员详情(厅主)
	ASS_GP_GUILD_COMMEND_DETAIL_HOLDER    = 	35,                    --//推荐成员详情(股东)
	ASS_GP_GUILD_SENDMONEY_REQ    	=	36,                    --//绑定送金查询
 	
 	---房间消息
 	ASS_GR_GUILD_DESKINFO      		=	31,                  	--///公会对战桌子信息
 	ASS_GR_GUILD_DESKINFO_UPDATE  	=	32,                  	--///公会对战桌子更新

}

--///////////////////////////////公会消息
--//公会请求
VipMsg.MSG_GP_CREATE_GUILD_REQ =
{
	{"UserID", "INT"},				--//用户ID
};

--//创建公会
VipMsg.MSG_GP_CREATE_GUILD =
{
	{"UserID", "INT"},							--用户ID
	{"GuildName", "CHARSTRING[50]"},			--公会名字
	{"GameStates", "CHARSTRING[50]"},			--游戏
	{"RoomStates", "CHARSTRING[200]"},			--房间
	{"iTaxRate", "INT"},						--税收比例
};

--//删除公会
VipMsg.MSG_GP_DELETE_GUILD =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID	
};

--//修改公会规则
VipMsg.MSG_GP_CHANGE_RULE =
{
	{"UserID", "INT"},						
	{"GuildID", "INT"},						
	{"GuildName", "CHARSTRING[50]"},
	{"GameStates", "CHARSTRING[50]"},			--游戏						
	{"RoomStates", "CHARSTRING[200]"},						
	{"iTaxRate", "INT"},
};

--//查询公会
VipMsg.MSG_GP_APPLY_JOIN_REQ =
{
	{"GuildID", "INT"},						--公会ID
};

--//申请加入公会
VipMsg.MSG_GP_APPLY_JOIN =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
};

--//退出公会
VipMsg.MSG_GP_QUIT_JOIN =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
};
	
--//通过申请
VipMsg.MSG_GP_AGREE_JOIN =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
	{"AgreeType", "INT"},					--/同意类型（0 同意 1 全部同意）
	{"AgreeUserID", "INT"},					--通过者的userid
};

--//拒绝申请
VipMsg.MSG_GP_REJECT_JOIN =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
	{"RejectType", "INT"},					--/同意类型（0 同意 1 全部同意）
	{"RejectUserID", "INT"},				--通过者的userid
};

--//获取公会列表
VipMsg.MSG_GP_GET_GUILD_LIST =
{
	{"UserID", "INT"},						--用户ID
};

--//获取公会成员列表
VipMsg.MSG_GP_GET_GUILD_USER =
{
	{"GuildID", "INT"},						--公会ID
};

--//踢出公会
VipMsg.MSG_GP_KICK_GUILD_USER =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
	{"KickUserID", "INT"},					--踢掉的userid
};

--//获取桌子列表
VipMsg.MSG_GP_GET_GUILD_ROOM =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
};

--//导入其他公会成员
VipMsg.MSG_GP_IMPORT_USER =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
	{"FromGuildID", "INT"},					--目标公会
};

--//邀请公会成员
VipMsg.MSG_GP_INVITE_USER =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
	{"TargetUserID", "INT"},				--对方用户
};

--//获取消息
VipMsg.MSG_GP_GET_GUILD_MESSAGE =
{
	{"UserID", "INT"},						--用户ID
	{"GuildID", "INT"},						--公会ID
};

--//读消息
VipMsg.MSG_GP_READ_GUILD_MESSAGE =
{
	{"UserID", "INT"},						--用户ID
	{"MessageID", "INT"},					--消息ID
	{"GuildID", "INT"},						--公会ID
};

--/修改成员备注
VipMsg.MSG_GP_CHANGE_USERNOTE =
{
	{"GuildID", "INT"},						--公会ID
	{"TargetUserID", "INT"},				--备注人ID
	{"NoteName", "CHARSTRING[50]"},			--//备注姓名
	{"NotePhone", "CHARSTRING[20]"},		--//备注手机号
};

--///公会房间匹配
VipMsg.MSG_GR_S_RoomMatchGuild =
{
	{"iUserId", "INT"},						--ID
	{"iGuildId", "INT"},					--公会ID
};

-- //税收详情
VipMsg.MSG_GP_GUILD_TAXDETAIL  =
{
	{"GuildID", "INT"},					--公会ID
	{"iDayIndex", "INT"},				--近7日记录
};

-- //成员详情
VipMsg.MSG_GP_GUILD_MEMBERDETAIL  =
{
	{"GuildID", "INT"},					--公会ID
	{"iDayIndex", "INT"},				--近7日记录
};

-- //战绩查询
VipMsg.MSG_GP_GUILD_RECORDREQ =
{
	{"GuildID", "INT"},
	{"UserID", "INT"},
	{"iDayIndex", "INT"},
};

-- //置顶
VipMsg.MSG_GP_GUILD_SETTOP = 
{
	{"GuildID", "INT"},					--公会ID
	{"UserID", "INT"},					--ID
};

-- //一键召集时间
VipMsg.MSG_GP_S_GET_CALLTIME =
{
	{"iLeftTime", "INT"},  --//剩余秒数
};

-- //一键召集
VipMsg.MSG_GP_GUILD_ONEKEYCALL =
{
	{"UserID", "INT"},  --//玩家id
	{"GuildID", "INT"},  --//厅id
};

--//股东查询
VipMsg.MSG_GP_GUILD_HOLDER_REQ =
{
	{"GuildID", "INT"},
	{"UserID", "INT"},
};

--//股东设置
VipMsg.MSG_GP_GUILD_HOLDER_SET =
{
	{"opType", "BYTE"},  --///0 设置 1 撤销
	{"GuildID", "INT"},
	{"UserID", "INT"},
	{"Rate", "INT"},    --//推荐占成
};

-- //推荐冷却时间查询
VipMsg.MSG_GP_GUILD_COMMEND_TIME = 
{
 	{"GuildID", "INT"},
	{"UserID", "INT"},
};

--//推荐查询
VipMsg.MSG_GP_GUILD_COMMEND_REQ =
{
	{"GuildID", "INT"},
	{"UserID", "INT"},
	{"TargetUserID", "INT"},
};

--//推荐
VipMsg.MSG_GP_GUILD_COMMEND =
{
	{"GuildID", "INT"},
	{"UserID", "INT"},
	{"TargetUserID", "INT"},
};

--//同意推荐
VipMsg.MSG_GP_GUILD_COMMEND_AGREE =
{
	{"OpType", "INT"},  --/// 0 同意 1 拒绝
	{"UserID", "INT"},
	{"MailID", "INT"},
};

--//股东查询
VipMsg.MSG_GP_S_GUILD_HOLDER_REQ =
{
	{"GuildID", "INT"},
	{"iMemberType", "INT"},  ----//成员类型 0 普通成员 2 股东
	{"iNeedCount", "INT"},
	{"iCommendCount", "INT"},
	{"iCommendRate", "INT"},
};

--//股东设置
VipMsg.MSG_GP_S_GUILD_HOLDER_SET =
{
	{"GuildID", "INT"},
	{"opType", "INT"},
};

--//推荐冷却时间
VipMsg.MSG_GP_S_GUILD_COMMEND_TIME =
{
	{"iLeftTime", "INT"},
	{"CommendRate", "INT"},
};

-- //推荐查询
VipMsg.MSG_GP_S_GUILD_COMMEND_REQ =
{
	{"UserID", "INT"},
	{"LogoID", "INT"},
	{"NickName", "CHARSTRING[50]"},
};

-- //推荐
VipMsg.MSG_GP_S_GUILD_COMMEND_AGREE =
{
	{"OpType", "INT"},
	{"GuildID", "INT"},
	{"GuildName", "CHARSTRING[50]"},
};

--//推荐成员详情
VipMsg.MSG_GP_GUILD_COMMEND_DETAIL =
{
	{"GuildID", "INT"},
	{"UserID", "INT"},
	{"DayIndex", "INT"},
};

-- //推荐成员详情
VipMsg.MSG_GP_S_GUILD_COMMEND_DETAIL =
{
	{"UserID", "INT"},
	{"NickName", "CHARSTRING[50]"},
	{"CommendUserID", "INT"},
	{"CommendNickName", "CHARSTRING[50]"},
	{"lTaxProduce", "LLONG"},
	{"lTaxGet", "LLONG"},
	{"iLogoID", "INT"},
};

--//赠送金币查询
VipMsg.MSG_GP_S_GUILD_SENDMONEY_REQ =
{
	{"lSendMoney", "LLONG"}, --0 不显示
};

--//////////////////////////////////////////////////////////
--//公会税率
VipMsg.MSG_GP_S_CREATE_GUILD_REQ =
{
	{"iCountNow", "INT"}, 		--//当前推广人数
	{"iCountNeed", "INT"}, 		--//需要推广人数
	{"iRateBase", "INT"}, 		--//平台固定收取
	{"iRateMin", "INT"},		--//最低税率
	{"iRateMax", "INT"},		--//最高税率
};

--//创建公会
VipMsg.MSG_GP_S_CREATE_GUILD =
{
	{"iOwnerId", "INT"},				--//厅主id
	{"GuildName", "CHARSTRING[50]"},	--//厅名称
	{"iGuildId", "INT"},				--//厅id
	{"GameStates", "CHARSTRING[50]"},	--//游戏
	{"RoomStates", "CHARSTRING[200]"},	--//房间
	{"iTaxRate", "INT"},				--//税收比例
};

--//修改公会规则
VipMsg.MSG_GP_S_CHANGE_RULE =
{
	{"GuildID", "INT"},
	{"GuildName", "CHARSTRING[50]"},
	{"RoomStates", "CHARSTRING[200]"},
	{"iTaxRate", "INT"},
};

--//查询公会
VipMsg.MSG_GP_S_APPLY_JOIN_REQ =
{
	{"GuildID", "INT"},					--//厅id
	{"GuildName", "CHARSTRING[50]"},	--//厅名
	{"OwnerID", "INT"},					--//厅主id
	{"OwnerName", "CHARSTRING[50]"},	--//厅主昵称
};

--//申请加入公会
VipMsg.MSG_GP_S_APPLY_JOIN =
{
	{"GuildID", "INT"},					--//厅id
	{"GuildName", "CHARSTRING[50]"},	--//厅名
	{"OwnerId", "INT"},					--//厅主id
};

--//退出公会
VipMsg.MSG_GP_S_QUIT_JOIN =
{
	{"GuildID", "INT"},					--//厅id
	{"GuildName", "CHARSTRING[50]"},	--//厅名
	{"OwnerId", "INT"}, 				--//厅主id
};

--//通过申请
VipMsg.MSG_GP_S_AGREE_JOIN =
{
	{"GuildID", "INT"},					--//公会id
	{"UserID", "INT"},					--//用户ID
	{"UserName", "CHARSTRING[50]"},		--//用户名字
	{"IsPass", "INT"},					--
};

--//拒绝申请
VipMsg.MSG_GP_S_REJECT_JOIN =
{
	{"GuildID", "INT"},					--//公会id
	{"UserID", "INT"},					--//用户ID
	{"UserName", "CHARSTRING[50]"},		--	//用户名字
	{"IsPass", "INT"},					--
};

--//获取公会列表
VipMsg.MSG_GP_S_GET_GUILD_LIST =
{
	{"OwnerID", "INT"},					--//厅主ID
	{"GuildID", "INT"},					--//公会ID	
	{"GuildName", "CHARSTRING[50]"},	--//公会名称
	{"MemberCount", "INT"},				--//成员数
	{"GameStates", "CHARSTRING[50]"},	--游戏
	{"RoomStates", "CHARSTRING[200]"},	--
	{"iTaxRate", "INT"},	
};

--//公会成员
VipMsg.MSG_GP_S_GET_GUILD_USER =
{
	{"UserID", "INT"},					--//玩家id
	{"NickName", "CHARSTRING[50]"},		--//玩家昵称
	{"iApplyTime", "INT"},				--//申请时间
	{"iPassTime", "INT"},				--//入厅时间
	{"IsPass", "INT"},					--//入厅状态
	{"WalletMoney", "LLONG"},			--//金币
	{"NoteName", "CHARSTRING[50]"},		--//备注姓名
	{"NotePhone", "CHARSTRING[20]"},	--//备注手机号
	{"iLogoID", "INT"},
	{"MemberType", "INT"},     --//0 普通成员 2 股东
};

--//税收详情
VipMsg.MSG_GP_S_TAXDETAIL =
{
	{"iGameId", "INT"},
	{"iPlayCount", "INT"},
	{"lTaxProduce", "LLONG"},
	{"lTaxGet", "LLONG"},
};

--//成员详情
VipMsg.MSG_GP_S_MEMBERDETAIL =
{
	{"UserID", "INT"},
	{"NickName", "CHARSTRING[50]"},
	{"iPlayCount", "INT"},
	{"lTaxProduce", "LLONG"},
	{"lTaxGet", "LLONG"},
	{"iLogoID", "INT"},
};

-- //战绩查询
VipMsg.MSG_GP_S_GUILD_RECORDREQ =
{
	{"UserID", "INT"},	
	{"NickName", "CHARSTRING[50]"},	
	{"iCreateDate", "INT"},	
	{"iRoomId", "INT"},	
	{"iChangeScore", "LLONG"},
};

--//踢出公会
VipMsg.MSG_GP_S_KICK_GUILD_USER =
{
	{"GuildID", "INT"},					--//公会id
	{"UserID", "INT"},					--//用户ID
	{"UserName", "CHARSTRING[50]"},		--//用户名字
	{"IsPass", "INT"},
};

--//获取桌子列表
VipMsg.MSG_GP_S_GET_GUILD_ROOM =
{
	{"ret", "INT"},			--//结果
};

--//导入其他公会成员
VipMsg.MSG_GP_S_IMPORT_USER =
{
	{"ret", "INT"},			--//结果
};

--//邀请公会成员
VipMsg.MSG_GP_S_INVITE_USER =
{
	{"ret", "INT"},						--//结果
	{"UserID", "INT"},					--//发起邀请
	{"TargetUserID", "INT"},			--//接受邀请
};

--//获取公会消息列表
VipMsg.MSG_GP_S_GET_GUILD_MESSAGE =
{
	{"ret", "INT"},				--//结果
	{"UserID", "INT"},
	{"GuildID", "INT"},
	{"Title", "CHARSTRING[100]"},
	{"uMessage", "CHARSTRING[250]"},
	{"CreateDate", "CHARSTRING[50]"},
};

--//读消息
VipMsg.MSG_GP_S_READ_GUILD_MESSAGE =
{
	{"ret", "INT"},				--//结果
};

-- //一键召集
VipMsg.MSG_GP_S_GUILD_ONEKEYCALL =
{
	{"iLeftTime", "INT"},
};

--//公会税率
VipMsg.MSG_GP_S_CHANGE_RULE_REQ =
{
	{"iRateBase", "INT"}, 		--//平台固定收取
	{"iRateMin", "INT"},		--//最低税率
	{"iRateMax", "INT"},		--//最高税率
};

-- //广播解散
VipMsg.MSG_GP_S_GUILD_DELETE_NOTIFY =
{
  {"GuildID", "INT"},      --//厅id
};

-- //广播修改
VipMsg.MSG_GP_S_GUILD_CHANGE_NOTIFY =
{
  {"GuildID", "INT"},      --//厅id
};

VipMsg.DeskUser =
{
 	{"iUserId", "INT"},
 	{"iLogoId", "INT"},
 	{"nickName", "CHARSTRING[100]"},
};

VipMsg.GuildDesk =
{
  	{"iDeskNo", "INT"}, 	--///桌子下标
	{"iDeskIndex", "INT"}, 	--///实际桌子索引
	{"iDeskUser", "VipMsg.DeskUser[8]"},
	{"eState", "INT"},
};

--///请求桌子信息
VipMsg.MSG_GR_C_GuildDeskReq = 
{
	{"iGuildId", "INT"},
};

-- ///更新桌子信息
VipMsg.MSG_GR_GuildDeskUpdate =
{
	{"iDeskIndex", "INT"},
	{"updateType", "INT"},
	{"bDeskStation", "BYTE"},
	{"deskUser", "VipMsg.DeskUser"},
	{"eState", "INT"},
};

-- ///公会桌子更新类型
-- enum eUpdateType 
-- {
--   UpdateType_null = 0, ///空
--   UpdateType_sit = 1, ///玩家坐下
--   UpdateType_left = 2, ///玩家离开
--   UpdateType_begin = 3, ///游戏开始
--   UpdateType_end = 4, ///游戏结束
-- };

return VipMsg;
