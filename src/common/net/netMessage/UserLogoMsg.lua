-- 文件说明：本文件定义了与用户头像上传下载相关的消息和结构体
-- 整合平台时，需要在GameRoomLogonDT中包含本文件
-- 文件创建：Fred Huang 2008-03-17
-- 消息格式：MDM_		表示主消息
-- ASS_UL	表示与用户头像相关子消息
-- ASS_ULC	表示由客户端向服务器端发送的消息
-- ASS_ULS	表示由服务器端向客户端发送的消息
-- 结构格式：MSG_		表示是消息结构体
-- MSG_UL	与头像相关的消息结构
-- MSG_UL_C_ 由客户端发给服务器端的消息结构体
-- MSG_UL_S_ 由服务器端发给客户端的消息结构体

local UserLogoMsg = {}

-- //主消息
UserLogoMsg.MDM_GR_USER_LOGO			=	120						--//头像相关


-- //子消息
UserLogoMsg.ASS_ULC_UPLOAD				=	0x01					--//上传头像数据
UserLogoMsg.ASS_ULC_INFOREQUEST			=	0x02					--//请求头像文件消息
UserLogoMsg.ASS_ULC_DOWNREQUEST			=	0x03					--//请求下载头像文件
UserLogoMsg.ASS_ULC_DOWNRESULT			=	0x04					--//返回下载的结果，实际上用于分包下载时请求下一数据包

UserLogoMsg.ASS_ULS_UPLOADSUCCEED		=	0x11					--//上传上头像成功
UserLogoMsg.ASS_ULS_UPLOADFAILED		=	0x12					--//上传头像失败
UserLogoMsg.ASS_ULS_LOGOINFORMATION		=	0x13					--//用户头像文件信息
UserLogoMsg.ASS_ULS_DOWN				=	0x14					--//下载头像数据


UserLogoMsg.MAX_BLOCK_SIZE				=	512						--//每个消息中最大可带头像数据大小
-- /*
-- 结构：上传头像数据结构
-- 内容：文件名、文件大小、折包大小、折包数、折包序号、本次图片数据有效大小、图片数据
-- */
UserLogoMsg.MSG_UL_C_DOWNRESULT = {
	{"dwUserID","INT"},	--//用户ID
	{"dwUserSourceLogo","INT"},	--//原始的LOGOid号
	{"nFileSize","INT"},	--//文件大小，一般不超过20K，即20480Byte
	{"nBlockSize","INT"},	--//折包大小
	{"nBlockCount","INT"},	--//折包数
	{"nBlockIndex","INT"},	--//折包序号，从0-nPackageCount
	{"nPackageSize","INT"},	--//本此消息中所附带数据大小
	{"szData","CHARSTRING[512]"},--//图像数据
}

UserLogoMsg.MSG_UL_S_DOWN = {
	{"dwUserID","INT"},	--//用户ID
	{"dwUserSourceLogo","INT"},	--//原始的LOGOid号
	{"nFileSize","INT"},	--//文件大小，一般不超过20K，即20480Byte
	{"nBlockSize","INT"},	--//折包大小
	{"nBlockCount","INT"},	--//折包数
	{"nBlockIndex","INT"},	--//折包序号，从0-nPackageCount
	{"nPackageSize","INT"},	--//本此消息中所附带数据大小
	{"szData","CHARSTRING[512]"},--//图像数据
}

UserLogoMsg.MSG_UL_C_DOWNRESULT = {
	{"dwUserID","INT"},	--//上传或下载的用户ID
	{"nBlockCount","INT"},	--//上传或下载的数据块总数
	{"nBlockIndex","INT"},	--//上传或下载的数据块索引
	{"bNeedCheck","BOOL"},	
}

UserLogoMsg.MSG_UL_S_UPLOADRESULT = {
	{"dwUserID","INT"},	--//上传或下载的用户ID
	{"nBlockCount","INT"},	--//上传或下载的数据块总数
	{"nBlockIndex","INT"},	--//上传或下载的数据块索引
	{"bNeedCheck","BOOL"},	
}

-- //请求用户的头像数据//请求下载头像
UserLogoMsg.MSG_UL_C_INFORREQUEST = {
	{"dwUserID","INT"},	--//请求者的用户ID
	{"dwRequestUserID","INT"},	--////被请求者的用户ID
}

UserLogoMsg.MSG_UL_C_DOWNREQUEST = {
	{"dwUserID","INT"},	--//请求者的用户ID
	{"dwRequestUserID","INT"},	--////被请求者的用户ID
}
-- //返回的用户头像信息
UserLogoMsg.MSG_UL_S_INFORMATION = {
	{"dwUserID","INT"},	--//用户ID
	{"dwUserLogoID","INT"},	--//头像ID号，如果=0xFF，才表示有自定义头像，此处看起来多此一举，但为了规范和防止出错，特意加上
	{"szFileMD5","CHARSTRING[33]"},	--//头像文件的MD5值
}

return UserLogoMsg
