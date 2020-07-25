local PlatformLogin = class("PlatformLogin")
local RoomLogicBase = require("logic.roomLogic.RoomLogicBase");

local _roomList = nil;

function PlatformLogin:ctor(callback)
	self._callback = callback or nil;

	self:initData();
end

function PlatformLogin:start()
	PlatformRegister:getInstance():stop()
	self:stop()
	self:bindEvent();
end

function PlatformLogin:stop()
	self:unBindEvent();

	if _roomList then
		_roomList:stop();
		_roomList = nil;
	end
end

function PlatformLogin:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_Connect",function (event) self:I_P_M_Connect(event) end);
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_Login",function (event) self:I_P_M_Login(event) end);
end

function PlatformLogin:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
		return;
	end

	for _, bindid in pairs(self.bindIds) do
		Event:unRegisterListener(bindid)
	end
end

function PlatformLogin:initData()
	self._name = "";
	self._pwd = "";

	self.Word_Wrong_Name = GBKToUtf8("登录名字错误"); 
	self.Word_Wrong_Pass = GBKToUtf8("用户密码错误"); 
	self.Word_Logined = GBKToUtf8("帐号已经登录");
	self.Word_AccountError = GBKToUtf8("您的账号被禁用");
end

function PlatformLogin:requestLogin(name, pwd)
	if globalUnit.checkIpIsCanLogin == false then
		self._callback:onPlatformLoginCallback(false, GBKToUtf8("游戏已关闭，无法登陆"), name, pwd);
		return false
	end

	if isEmptyString(name) or isEmptyString(pwd) then
		if self._callback then
			self._callback:onPlatformLoginCallback(false, GBKToUtf8("名称或者密码为空"), name, pwd);
		end

		return false;
	end

	self._name = name;
	self._pwd  = pwd;
	
	self:platformLogin();

	return true;
end

function PlatformLogin:I_P_M_Connect(result)
	if not result then
		if self._callback then
			self._callback:onPlatformLoginCallback(false, GBKToUtf8("平台网络连接失败"), self._name, self._pwd);
		end
		
		return;
	end
	
	self:platformLogin();
end

function PlatformLogin:I_P_M_Login(event)
	local result = event.logined;
	local dwErrorCode = event.code;
	luaDump(event)
	
	if globalUnit.m_gameConnectState == STATE.STATE_OVER then--//普通状态
		if not result then
			local message = "登录错误";
			if dwErrorCode == PlatformMsg.ERR_GP_USER_NO_FIND then
				message = self.Word_Wrong_Name--..dwErrorCode;
				if self._name == cc.UserDefault:getInstance():getStringForKey("username", "") then
					cc.UserDefault:getInstance():setStringForKey("username", "");
					cc.UserDefault:getInstance():setStringForKey("password", "");
				end
			elseif dwErrorCode == PlatformMsg.ERR_GP_USER_PASS_ERROR then
				message = "密码错误，您还可以输入2次。";
				-- cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
			elseif dwErrorCode == 23 then
				message = "密码错误，您还可以输入1次。";
				-- cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
			elseif dwErrorCode == 24 then
				message = "密码错误，账号被暂时锁定，请3分钟后再做尝试。";
				-- cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
			elseif dwErrorCode == 25 then
				message = "由于您连续输入密码错误，账号被暂时锁定，请稍后再做尝试。";
				-- cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
			-- elseif dwErrorCode == PlatformMsg.ERR_GP_USER_PASS_ERROR then
			-- 	message = self.Word_Wrong_Pass--..dwErrorCode;
			-- 	cc.UserDefault:getInstance():setStringForKey("username", "");
			-- 	cc.UserDefault:getInstance():setStringForKey("password", "");
			elseif dwErrorCode == PlatformMsg.ERR_GP_USER_LOGON then
				message = self.Word_Logined--..dwErrorCode;
			elseif dwErrorCode == PlatformMsg.ERR_GP_USER_VALIDATA then
				cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
				message	= self.Word_AccountError--..dwErrorCode;
			elseif dwErrorCode == PlatformMsg.ERR_GP_VER_ERROR then
				message = PlatformMsg.ERR_GP_VER_ERROR--"版本过旧，请升级后在登录"
			elseif dwErrorCode == PlatformMsg.ERR_GP_USER_IP_LIMITED then
				message ="即日起游戏暂停服务，开启时间另行通知。感谢您的支持与厚爱！！！"
			end

			if self._callback then
				self._callback:onPlatformLoginCallback(false, message, self._name, self._pwd);
			end

			return;
		end

		if self._callback then
			luaPrint("登陆回调处理")
			if self._callback.onPlatformLoginCallback then
				self._callback:onPlatformLoginCallback(true, GBKToUtf8("登录成功"), self._name, self._pwd);
			else
				dispatchEvent("onPlatformLoginCallback",{true,GBKToUtf8("登录成功"),self._name, self._pwd})
			end
		end
	elseif globalUnit.m_gameConnectState == STATE.STATE_CONNECTING then -- //游戏重连中状态
		self:stop();

		if result then
			local roomInfo = {};
			roomInfo.uKindID = GAMETYPE.NORMAL;
			roomInfo.uNameID = PlatformLogic.loginResult.nNameID;
			roomInfo.uRoomID = PlatformLogic.loginResult.nRoomID;
			roomInfo.szServiceIP = PlatformLogic.loginResult.szIP;
			roomInfo.uServicePort = PlatformLogic.loginResult.nPort;

			GameCreator:setGameKindId(roomInfo.uNameID, roomInfo.uKindID);
			RoomInfoModule:addRoomInfo(GameCreator:getCurrentGameNameID())
			local roomInfo = RoomInfoModule:getByRoomID(roomInfo.uRoomID);

			if roomInfo then
				RoomLogic:setSelectedRoom(roomInfo);
			else
				roomInfo = {}
			end

			roomInfo.uKindID = GAMETYPE.NORMAL;
			roomInfo.uNameID = PlatformLogic.loginResult.nNameID;
			roomInfo.uRoomID = PlatformLogic.loginResult.nRoomID;
			roomInfo.szServiceIP = PlatformLogic.loginResult.szIP;
			roomInfo.uServicePort = PlatformLogic.loginResult.nPort;
			MailInfo:sendMailListInfoRequest()

			-- 非法房间信息直接返回不在登录
			if roomInfo.uNameID <= 0 or roomInfo.uRoomID <= 0 or roomInfo.uKindID <= 0 or roomInfo.uServicePort <= 0 then
				luaPrint("重连成功，但房间信息异常，可能房间已不存在!");
				RoomLogic:close()
				Hall:exitGame(nil,function() globalUnit.isEnterGame = false end,0)
				dispatchEvent("onPlatformLoginError");--通知VIP界面
				addScrollMessage("网络不太好哦，请检查网络")
				return;
			end

			luaPrint("重连成功，重新登录房间")

			-- 进入游戏
			if self._callback then
				luaPrint("重连  严重错误")
			end
			_roomList = RoomLogicBase.new(self._callback);
			_roomList:start();
			globalUnit.isDoudizhuBackRoom = true
			_roomList:requestLogin(PlatformLogic.loginResult.nRoomID);
		end
	elseif globalUnit.m_gameConnectState == STATE.PLATFORM_STATE_CONNECTING then--//平台重连中
		if not result then
			local message = "";
			if dwErrorCode == PlatformMsg.ERR_GP_USER_NO_FIND then
				message = self.Word_Wrong_Name--..dwErrorCode;
				cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
			elseif dwErrorCode == PlatformMsg.ERR_GP_USER_PASS_ERROR then
				message = self.Word_Wrong_Pass--..dwErrorCode;
				cc.UserDefault:getInstance():setStringForKey("username", "");
				cc.UserDefault:getInstance():setStringForKey("password", "");
			elseif dwErrorCode == PlatformMsg.ERR_GP_USER_LOGON then
				message = self.Word_Logined--..dwErrorCode;
			end

			if self._callback and not tolua.isnull(self._callback) then
				if self._callback.onPlatformLoginCallback then
					self._callback:onPlatformLoginCallback(false, message, self._name, self._pwd)
				end
			else
				dispatchEvent("onPlatformLoginCallback",{false,message,self._name, self._pwd})
			end

			return;
		else
			luaPrint("5555555555555----**********--")
			globalUnit.m_gameConnectState = STATE.STATE_OVER;
		end

		if self._callback and not tolua.isnull(self._callback) then
			if self._callback.onPlatformLoginCallback then
				self._callback:onPlatformLoginCallback(true, GBKToUtf8("登录成功"), self._name, self._pwd)
			end
		else
			dispatchEvent("onPlatformLoginCallback",{true,GBKToUtf8("登录成功"),self._name, self._pwd})
		end
	end
end

function PlatformLogin:platformLogin()
	if PlatformLogic:isConnect() then
		if not HallLayer:getInstance() then
			if isEmptyString(SocialUtils._wx_nickname) then
				LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("登录中,请稍后"), LOADING):removeTimer(10)
			else
				LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("微信登陆中,请稍后"), LOADING):removeTimer(10)
			end
		end

		if not PlatformLogic.isLogined then
			self:login(self._name, self._pwd, GameCreator:getCurrentGameNameID());
		else
			if self._callback then
				luaPrint("登陆回调处理1111")
				if self._callback.onPlatformLoginCallback then
					self._callback:onPlatformLoginCallback(true, GBKToUtf8("登录成功"), self._name, self._pwd);
				else
					dispatchEvent("onPlatformLoginCallback",{true,GBKToUtf8("登录成功"),self._name, self._pwd})
				end
			end
		end
	else
		PlatformLogic:connect();
	end
end

function PlatformLogin:login(name, pwd, uNameID)
	local msg = {};

	msg.uRoomVer = 4;
	msg.szName = name;
	msg.TML_SN = "EQ4gG6vEUL06ajaGn4EAuXDa662vaeeqL6UdoOQatxuujAlnqovO6VndvXT4Tv0l4a28XGoDxqde4El6XUAXLXe66lg2o6gQN4tlOgeAoV6gulE2jTNneUulE";
	msg.szMD5Pass = pwd--MD5_CTX:MD5String(pwd);
	msg.szMathineCode = onUnitedPlatformGetSerialNumber();
	msg.zCPUID = "612826255";
	msg.szHardID = "2222222";
	msg.szIDcardNo = "*";
	msg.szMobileVCode = "*";
	if device.platform ~= "windows" then
		msg.gsqPs = string.gsub("10"..localAppVersion,"%D","")--5471;
	else
		msg.gsqPs = 5471;
	end
	
	-- msg.iUserID = -1;
	msg.device_info = getJiGuangID(); --获取设备唯一标识
	if device.platform == "android" then
		msg.device_type = 0;
	elseif device.platform == "ios" then
		msg.device_type = 1;
	else
		msg.device_type = 2;
	end

	msg.uRoomVer = GameConfig:getServerVersion("hall")

	if msg.uRoomVer == nil then
		msg.uRoomVer = GameConfig:getLuaVersion("hall")
	end

	luaPrint("请求登陆  msg.szName  : "..msg.szName.."   msg.szMD5Pass : "..msg.szMD5Pass.." uNameID : "..uNameID)
	msg.AgentID = channelID
	msg.szIP = getIPAddress()
	-- luaDump(msg)
	PlatformLogic:send(PlatformMsg.MDM_GP_LOGON,PlatformMsg.ASS_GP_LOGON_BY_NAME,msg,PlatformMsg.MSG_GP_S_LogonByNameStruct)
end

return PlatformLogin;
