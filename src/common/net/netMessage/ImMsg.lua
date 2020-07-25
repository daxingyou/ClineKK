-- /*
-- 文件说明：本文件定义了与IM相关的消息和结构体
-- 整合平台时，需要在GameRoomLogonDT中包含本文件
-- 文件创建：Fred Huang 2008-04-2
-- 消息格式：MDM_		表示主消息
-- ASS_IM	表示与IM相关子消息
-- ASS_IMC	表示由客户端向服务器端发送的消息
-- ASS_IMS	表示由服务器端向客户端发送的消息
-- 结构格式：MSG_		表示是消息结构体
-- MSG_IM	与头像相关的消息结构
-- MSG_IM_C_ 由客户端发给服务器端的消息结构体
-- MSG_IM_S_ 由服务器端发给客户端的消息结构体
-- */

local ImMsg = {}

-- //主消息
ImMsg.MDM_GP_IM						=		130						--//头像相关


-- //子消息
ImMsg.ASS_IMC_GETCOUNT				=		0x01					--//取得服务器上好友数，陌生人中的不取，需要将本地的数量发给服务器
ImMsg.ASS_IMC_GETUSERINFO			=		0x02					--//取得某个好友的详细资料
ImMsg.ASS_IMC_ADDREQUEST			=		0x03					--//请求加为好友，含有是否是第一次发出，这在对方需要确认时有用
ImMsg.ASS_IMC_ADDREQUESTRESPONSE	=		0x04					--//有人请求加为好友，返回是否同意
ImMsg.ASS_IMC_SEARCH				=		0x05					--//查询好友，分为在线与不在线（通过ID号或姓名），保留
ImMsg.ASS_IMC_MSG					=		0x0F					--//聊天消息
ImMsg.ASS_IMC_SETGROUP				=		0x06					--//设置好友组

ImMsg.ASS_IMS_GETCOUNT				=		0x11					--//返回好友数，不取黑名单
ImMsg.ASS_IMS_GETUSERINFO			=		0x12					--//返回好友的详细资料,最少要以下内容
-- //ID号，姓名，性别，是否在线
ImMsg.ASS_IMS_GETLIST				=		0x13					--//返回好友列表，包括：ID号，姓名，性别，是否在线
ImMsg.ASS_IMS_USERONLINE			=		0x14					--//上下线后，通知好友
ImMsg.ASS_IMS_GETONLINELIST			=		0x15					--//上线后，返回在线的好友，如果已取得完整列表，则不再返回此消息
ImMsg.ASS_IMS_ADDREQUEST			=		0x16					--//有人请求加为好友，需要请确认
ImMsg.ASS_IMS_ADDREQUESTRESPONSE	=		0x17					--//转发是否同意加为好友，如果是同意的，则服务器还要操作记录
ImMsg.ASS_IMS_USERNOTONLINE			=		0x1E					--//转发聊天消息失败，用户不在线
ImMsg.ASS_IMS_MSG					=		0x1F					--//转发聊天消息
ImMsg.ASS_IMS_SEARCH				=		0x24					--//查找好友
ImMsg.ASS_IMS_NOAC					=		0x23					--//转发聊天消息


ImMsg.ASS_SET_FRIENDTYPE			=		0x20					--///设置个人好友和聊天的接受类型


ImMsg.MAX_BLOCK_MSG_SIZE			=		512						--//每个消息的最大数量

ImMsg.IM_ADDRESPONSE_AGREE			=		0x0						--//同意加为好友
ImMsg.IM_ADDRESPONSE_REFUSE			=		0x1						--//拒绝加为好友
ImMsg.IM_ADDRESPONSE_IDENT			=		0x2						--//需要验证

ImMsg.IM_SEARCH_BY_ONLINE			=		0x0						--//查询在线用户
ImMsg.IM_SEARCH_BY_NAME				=		0x1						--//通过用户姓名查询
ImMsg.IM_SEARCH_BY_SEX				=		0x2						--//通过性别查询

-- //=======================数据结构定义=====================
-- /*
-- 结构：取得服务器上好友数/返回服务器上的好友数
-- 内容：用户的ID（防止错误，可以不要的），本地好友数

-- */
ImMsg.MY_CHARFORMATA = {
	{"cbSize","INT"},
	{"dwMask","INT"},
	{"dwEffects","INT"},
	{"yHeight","INT"},
	{"yOffset","INT"},
	{"crTextColor","INT"},
	{"bCharSet","CHAR"},
	{"bPitchAndFamily","CHAR"},
	{"szFaceName","CHARSTRING[32]"},
}

ImMsg.MY_CHARFORMATW = {
	{"cbSize","INT"},
	{"dwMask","INT"},
	{"dwEffects","INT"},
	{"yHeight","INT"},
	{"yOffset","INT"},
	{"crTextColor","INT"},
	{"bCharSet","CHAR"},
	{"bPitchAndFamily","CHAR"},
	{"szFaceName","CHARSTRING[32]"},
}

-- #if (_RICHEDIT_VER >= 0x0200)
-- #ifdef UNICODE
-- #define MY_CHARFORMAT MY_CHARFORMATW
-- #else
-- #define MY_CHARFORMAT MY_CHARFORMATA
-- #endif // UNICODE 
-- #else
-- #define MY_CHARFORMAT MY_CHARFORMATA
-- #endif // _RICHEDIT_VER >= 0x0200 

ImMsg.MSG_IM_C_SETGROUP = {
	{"dwUserID","INT"},--//用户ID
	{"dwRemoteUserID","INT"},--/好友的ID
	{"groupID","INT"},--//组ID
}

ImMsg.MSG_IM_C_COUNT = {
	{"dwUserID","INT"},--//用户ID
	{"dwUserCount","INT"},--//用户的好友数
	{"dwUserCountReturn","INT"},--//返回的用户好友数
}

ImMsg.MSG_IM_S_COUNT = {
	{"dwUserID","INT"},--//用户ID
	{"dwUserCount","INT"},--//用户的好友数
	{"dwUserCountReturn","INT"},--//返回的用户好友数
}

-- /*
-- 结构：请求取某个用户的资料
-- 内容：请求者的ID和被请求者的ID，以及用户名
-- */
ImMsg.MSG_IM_C_GETUSERINFO = {
	{"dwUserID","INT"},--//请求者ID
	{"dwRequestedUserID","INT"},--//被请求者ID
}

-- /*
-- 结构：用户的资料信息
-- 内容：用户的资料信息
-- 使用在以下消息中：
-- */
ImMsg.MSG_IM_S_GETUSERINFO = {
	{"dwUserID","INT"},--//用户ID
	{"dwRemoteID","INT"},--//发送接收者的ID
	{"sUserName","CHARSTRING[30]"},--//姓名
	{"nSex","BOOL"},--//性别
	{"nOnline","INT"},--//是否在线
	{"GroupID","INT"},--//分组ID，暂不使用
	{"dwLogoID","INT"},--
}

-- /*
-- 结构：请求加为好友
-- 内容：请求者的ID，被请求者的ID，如果对方需要验证，则发第二次请求，复用此结构体，因此，要包含是否是第一次发送，以及请求内容
-- 注	：现在只支持添加在线的用户
-- */
ImMsg.MSG_IM_C_ADDREQUEST = {
	{"dwUserID","INT"},--//请求者用户ID
	{"sUserName","CHAR"},--//请求者姓名  	//change by yjj 090323
	{"dwRequestedUserID","INT"},--//被请求用户ID
	{"sRequestedUserName","CHARSTRING[61]"},--//请求者姓名  	//change by yjj 090323
	{"nMsgLength","INT"},--//请求消息的长度
	{"cbSize","INT"},--//整个消息的长度
	{"sRequestNotes","CHARSTRING[128]"},--//请求的内容，实际长度与nMsgLength相关
}

ImMsg.MSG_IM_S_ADDREQUEST = {
	{"dwUserID","INT"},--//请求者用户ID
	{"sUserName","CHAR"},--//请求者姓名  	//change by yjj 090323
	{"dwRequestedUserID","INT"},--//被请求用户ID
	{"sRequestedUserName","CHARSTRING[61]"},--//请求者姓名  	//change by yjj 090323
	{"nMsgLength","INT"},--//请求消息的长度
	{"cbSize","INT"},--//整个消息的长度
	{"sRequestNotes","CHARSTRING[128]"},--//请求的内容，实际长度与nMsgLength相关
}

-- /*
-- 结构：是否同意加为好友
-- */
ImMsg.MSG_IM_C_ADDRESPONSE = {
	{"dwUserID","INT"},--//还是请求者的用户ID
	{"dwRequestedUserID","INT"},--//被请求者（即回应用户）的ID
	{"dwRefusedUserID","INT"},--//请求后被拒绝的用户id
	{"sRequestedUserName","CHARSTRING[61]"},--//被请求者（即回应用户）的姓名//change by yjj 090323
	{"sRequirUsrName","CHARSTRING[61]"},--//请求者的姓名  add by yjj 090323
	{"nResponse","INT"},--//回应方式：IDYES-同意,IDNO-不同意
	{"nSex","INT"},--//回应者的性别
}

ImMsg.MSG_IM_S_ADDRESPONSE = {
	{"dwUserID","INT"},--//还是请求者的用户ID
	{"dwRequestedUserID","INT"},--//被请求者（即回应用户）的ID
	{"dwRefusedUserID","INT"},--//请求后被拒绝的用户id
	{"sRequestedUserName","CHARSTRING[61]"},--//被请求者（即回应用户）的姓名//change by yjj 090323
	{"sRequirUsrName","CHARSTRING[61]"},--//请求者的姓名  add by yjj 090323
	{"nResponse","INT"},--//回应方式：IDYES-同意,IDNO-不同意
	{"nSex","INT"},--//回应者的性别
}

-- /*
-- 结构：查询用户
-- 内容：可以是查询在线用户，也可以是通过用户姓名查询
-- 注意：不能通过ID号查询，因为ID号对用户而言是不透明的
-- 返回结果是MSG_IM_S_GETUSERINFO
-- */
ImMsg.MSG_IM_C_SEARCHUSER = {
	{"dwUserID","INT"},--//请求查询的用户ID
	{"nSearchType","INT"},--//查询的方式，现只支持单项查询，不支持组合查询
	{"nSex","INT"},--//只有在nSearchType==IM_SEARCH_BY_SEX时有效
	{"sSearchName","CHARSTRING[30]"},--//只有在nSearchType==IM_SEZRCH_BY_NAME时有效
}

-- /*
-- 结构：返回用户列表，即多个用户信息
-- */
ImMsg.MSG_IM_S_USERLIST = {
	{"nListCount","INT"},--//此消息体中包含的用户列表数
	{"nBodyLength","INT"},--//此消息体中总共的数据长度
	{"sBody","CHARSTRING[512]"},--//消息体，多个MSG_IM_S_GETUSERINFO
}

-- /*
-- 结构：即时消息
-- 内容：要包括文字信息
-- */
ImMsg.MSG_IM_C_MSG = {
	{"dwUserID","INT"},--//用户的ID号
	{"szUserName","CHARSTRING[30]"},--//用户的姓名
	{"dwRemoteUserID","INT"},--//对方的ID号
	{"cf",""},--//消息格式
	{"szFontname","CHARSTRING[50]"},--//字体名称，CHARFORMAT中可能会不保留这个信息，因为它是一个指针
	{"szMsgLength","INT"},--//消息长度
	{"cbSize","INT"},--//消息长度
	{"szMsg","CHARSTRING[512]"},--//消息体
}
ImMsg.MSG_IM_S_MSG = {
	{"dwUserID",""},--//用户的ID号
	{"szUserName",""},--//用户的姓名
	{"dwRemoteUserID",""},--//对方的ID号
	{"cf",""},--//消息格式
	{"szFontname",""},--//字体名称，CHARFORMAT中可能会不保留这个信息，因为它是一个指针
	{"szMsgLength",""},--//消息长度
	{"cbSize",""},--//消息长度
	{"szMsg",""},--//消息体
}
-- typedef struct
-- {
-- 	int		dwUserID;						//用户的ID号
-- 	char		szUserName[30];					//用户的姓名
-- 	int		dwRemoteUserID;					//对方的ID号
--     MY_CHARFORMAT	cf;								//消息格式
-- 	char		szFontname[50];					//字体名称，CHARFORMAT中可能会不保留这个信息，因为它是一个指针
-- 	int		szMsgLength;					//消息长度
-- 	int			cbSize;							//消息长度
-- 	char		szMsg[MAX_BLOCK_MSG_SIZE];		//消息体
-- }MSG_IM_C_MSG, MSG_IM_S_MSG;
-- //查找用户
-- ImMsg.MY_CHARFORMATA = {
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- }
-- ImMsg.MY_CHARFORMATA = {
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- }
-- typedef struct
-- {
-- 	int dwUserID;
-- 	int dwRemoteID;
-- }MSG_IM_C_SEARCH, MSG_IM_S_SEARCH;
-- //查找用户
-- ImMsg.MY_CHARFORMATA = {
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- }
-- typedef struct
-- {
-- 	int dwRemoteID;
-- }MSG_IM_C_GETUSERINFO_BYID;

-- ImMsg.MY_CHARFORMATA = {
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- }
-- typedef struct
-- {
-- 	int dwUserID;
-- 	int dwRemoteID;
-- 	int	 nHeadType;
-- 	int  nVipLevel;
-- 	int  nDiamond;
-- 	int  nOnLineFlag;
-- 	int	 nSex;
-- 	int  nResult;
-- 	char sNickName[50];
-- }MSG_IM_C_SEARCH_RESULT;
-- ImMsg.MY_CHARFORMATA = {
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- 	{"",""},
-- }
-- typedef struct
-- {
-- 	int dwUserID;
-- 	int dwRemoteID;
-- 	int	 nResult;
-- }MSG_IM_C_DELETE_RESULT;
-- #endif

return ImMsg
