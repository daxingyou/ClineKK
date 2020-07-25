--全局变量统一存储
PLAY_COUNT = MAX_COUNT;--默认四人场
nickNameLen = 6 --昵称长度
local globalUnit = {}

function globalUnit:init()
	self.enterRoomID = ""--进入房间id
	self.selectedRoomID = 0;--选择房间id
	self.isFirstTimeInGame = true;--是否第一次进游戏

	self.isEnterGame = false;--是否进入游戏

	self.isRegisterEnterGame = false;--是否注册进入游戏

	self.m_connectCount = 0;--网络重连次数
	self.m_gameConnectState = 0;--网络状态

	self.m_userID = 0;
	self.m_account = "";
	self.m_password = "";
	self.tempPhone = "";

	self.m_reConnectMaxCount = 4;
	self.m_sNotieceMsg = "";--公告信息
	self.isOpenNoticyLayer = true;--是否需要打开公告
	self.nMinRoomKey = 0; --金币房最少金币数量

	self.webRoomid = 0;
	self.isGetSharedRoom = true;
	self.isCheckWebLogin = false;

	self.loginType = cc.UserDefault:getInstance():getIntegerForKey(LOGINTYPE_TEXT, guestLogin);--0游客登录 1 爱约吧登录 2 微信登录

	self.isShareAwardZuanshi = true;

	self.isFormalPackage = false;--是否是正式包 --只对iOS平台有效
	self:setIsFormalPackage(device.platform == "android");

	self.isRequestReliefMoney = true;--是否可以请求救济金
	self.isRequestReliefMoneyStatue = false;--请求救济金状态 true 正在请求

	self.isEnterRoomMode = cc.UserDefault:getInstance():getBoolForKey("fishmode", true); --0 单人模式 1 多人模式
	self.isGameMatchMode = false;
	self.enterGameMatchID = -1;
	self.iRoomIndex = 1;
	self.jiujinum = -1;  --今日救济次数
	self.isregisterSec = false;  --是否注册成功
	self.enterGameName = "lkpy";--进入游戏名字
	self.gameChannel = "";--游戏渠道
	self.isOpenYuekaLayer = true;--是否需要打开月卡
	self.isOpenfuliLayer = false;--是否需要打开福利
	self.isOpenfuliFirst = true;--是否需要打开福利
	self.isStopService = nil;--停服显示
	self.enterGameID = cc.UserDefault:getInstance():getStringForKey(ENTERROOMNAME, "");
	self.selectedCannon = -1;
	NOWPAOTAI = nil;

	self.playerLevelExperience = {
		300,600,900,1200,1500,1800,2100,2400,2700,3000,
		3300,3600,3900,4200,4500,4800,5100,5400,5700,6000,
		6300,6600,6900,7200,7500,7800,8100,8400,8700,9000,
		9300,9600,9900,10200,10500,10800,11100,11400,11700,12000,
		12300,12600,12900,13200,13500,13800,14100,14400,14700,15000,
		15300,15600,15900,16200,16500,16800,17100,17400,17700,18000,
		18300,18600,18900,19200,19500,19800,20100,20400,20700,21000,
		21300,21600,21900,22200,22500,22800,23100,23400,23700,24000,
		24300,24600,24900,25200,25500,25800,26100,26400,26700,27000,
		27300,27600,27900,28200,28500,28800,29100,29400,29700,30000
	};--升级需要经验

	BindTool.register(self, "updatePao", false);

	self.registerInfo = {}--注册信息
	self.registerInfo.dwUserID = 0
	self.registerInfo.code = ""
	self.registerInfo.phone = ""
	self.registerInfo.referee = 0
	self.registerInfo.name = ""

	self.bankPwd = nil--保险箱入密码

	self.isBackRoom = false--是否是返回房间
	self.isaccountQuit = nil

	self.fishRobotData = nil

	self.isSDKInit = false

	self.nowTingId = 0;
	self.VipRoomList = nil;

	self.isShowZJ = true;--控制战绩是否显示
	self.jsstring = ""
	self.jsstring1 = ""
	self.jsstring2 = ""

	self.mSaveUserLog = {}
	--本地邮件时间戳
	self.mail_time_stamp_local = 0;
	--服务端邮件时间戳
	self.mail_time_stamp_sever = 0;
	self.mail_info = nil;

	--选择的桌子
	self.mSelectDesk = 0;
	self.bIsSelectDesk = nil--百人进房间方式
end

function globalUnit:setEnterRoomID(id)
	self.enterRoomID = id
end

function globalUnit:getEnterRoomID()
	return self.enterRoomID
end

function globalUnit:setLoginType(login)
	self.loginType = login;

	cc.UserDefault:getInstance():setIntegerForKey(LOGINTYPE_TEXT, login);
	cc.UserDefault:getInstance():flush();
end

function globalUnit:getLoginType()
	return self.loginType;
end

function globalUnit:setIsShareAward(isShare)
	self.isShareAwardZuanshi = isShare;
end

function globalUnit:getIsShareAward()
	return self.isShareAwardZuanshi;
end

function globalUnit:setIsFormalPackage(isFormal)
	self.isFormalPackage = isFormal;

	if device.platform == "ios" then
		if isFormal ~= true then
			BAIDU_KEY = BAIDU_TKEY;
		else
			BAIDU_KEY = BAIDU_FKEY;
		end
	end
end

function globalUnit:getIsFormalPackage()
	return self.isFormalPackage;
end

function globalUnit:setIsRequestReliefMoney(isRequest)
	self.isRequestReliefMoney = isRequest;
end

function globalUnit:getIsRequestReliefMoney()
	return self.isRequestReliefMoney;
end

function globalUnit:setIsRequestReliefMoneyStatue(isRequest)
	self.isRequestReliefMoneyStatue = isRequest;
end

function globalUnit:getIsRequestReliefMoneyStatue()
	return self.isRequestReliefMoneyStatue;
end

function globalUnit:setIsEnterRoomMode(mode)
	mode = mode or 1;
	if mode == 1 then
		self.isEnterRoomMode = true;
	else
		self.isEnterRoomMode = false;
	end

	if mode == 2 then
		self.isGameMatchMode = true;
	else
		self.isGameMatchMode = false;
	end

	cc.UserDefault:getInstance():setBoolForKey("fishmode", self.isEnterRoomMode)
end

function globalUnit:getIsEnterRoomMode()
	return self.isEnterRoomMode;
end

function globalUnit:getGameMode()
	return self.isGameMatchMode;
end

function globalUnit:setEnterGameMatchID(id)
	self.enterGameMatchID = id;
end

function globalUnit:getEnterGameMatchID()
	return self.enterGameMatchID;
end

function globalUnit:setEnterGameName(name)
	self.enterGameName = name;
end

function globalUnit:getEnterGameName()
	if self.enterGameName == nil then
		return "lkpy";
	end

	return self.enterGameName;
end

function globalUnit:getLevelCount()
	self:setDefaultExperience();

	return #self.playerLevelExperience;
end

function globalUnit:getExperienceByLevel(lv)
	self:setDefaultExperience();

	if lv > #self.playerLevelExperience then
		luaPrint("获取等级所需经验值错误 lv  = "..tostring(lv).." #self.playerLevelExperience  = "..tostring(#self.playerLevelExperience));
	end

	return self.playerLevelExperience[lv] or 0;
end

function globalUnit:setDefaultExperience()
	if self.playerLevelExperience == nil or (type(self.playerLevelExperience) == "table" and next(self.playerLevelExperience) == nil) then
		self.playerLevelExperience = {
			300,600,900,1200,1500,1800,2100,2400,2700,3000,
			3300,3600,3900,4200,4500,4800,5100,5400,5700,6000,
			6300,6600,6900,7200,7500,7800,8100,8400,8700,9000,
			9300,9600,9900,10200,10500,10800,11100,11400,11700,12000,
			12300,12600,12900,13200,13500,13800,14100,14400,14700,15000,
			15300,15600,15900,16200,16500,16800,17100,17400,17700,18000,
			18300,18600,18900,19200,19500,19800,20100,20400,20700,21000,
			21300,21600,21900,22200,22500,22800,23100,23400,23700,24000,
			24300,24600,24900,25200,25500,25800,26100,26400,26700,27000,
			27300,27600,27900,28200,28500,28800,29100,29400,29700,30000
		};
	end
end

function globalUnit:setEnterGameID(id)
	if self.enterGameID == id then
		return;
	end

	self.enterGameID = id;

	cc.UserDefault:getInstance():setStringForKey(ENTERROOMNAME, id);
end

function globalUnit:getEnterGameID()
	return self.enterGameID;
end

function globalUnit:setSelectedCannon(cannonLv)
	self.selectedCannon = cannonLv;

	cc.UserDefault:getInstance():setIntegerForKey(NOWPAOTAI, cannonLv);

	self:setUpdatePao(true);
end

function globalUnit:getSelectedCannon()
	if self.selectedCannon == -1 then
		self.selectedCannon = cc.UserDefault:getInstance():getIntegerForKey(NOWPAOTAI, 1);
	end

	return self.selectedCannon;
end

function globalUnit:setBankPwd(pwd)
	self.bankPwd = pwd
end

function globalUnit:getBankPwd()
	return self.bankPwd
end

function globalUnit:setIsBackRoom(is)
    self.isBackRoom = is
end

function globalUnit:getIsBackRoom()
    return self.isBackRoom
end

return globalUnit
