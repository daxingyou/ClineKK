local PlatformRegister = class("PlatformRegister")

--注册
local REGIST_FAILE = 0;  --注册失败
local REGIST_SUCCESS = 1; --注册成功
local REGIST_SAME_NAME = 2; --用户名已经存在
local REGIST_FAILE_TUIJINREN = 3 --推荐人ID错误

local PlatformRegisterInstance = nil

function PlatformRegister:getInstance()
	if PlatformRegisterInstance == nil then
		PlatformRegisterInstance = PlatformRegister.new()
	end

	return PlatformRegisterInstance
end

function PlatformRegister:ctor(callback)
	self._callback = callback or nil;
	self.type = 0

	self:initData();
end

function PlatformRegister:start()
	self:stop()
	self:bindEvent();
end

function PlatformRegister:stop()
	self:unBindEvent();
end

function PlatformRegister:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_Connect",function (event) self:I_P_M_Connect(event) end);
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_Regist",function (event) self:I_P_M_Regist(event) end);
end

function PlatformRegister:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
		return;
	end

	for _, bindid in pairs(self.bindIds) do
		Event:unRegisterListener(bindid)
	end

	self.bindIds = nil
end

function PlatformRegister:initData()
	self._fastRegist = false;
	self._name = "";
	self._pwd = "";
	self._unionId = "";
end

function PlatformRegister:requestRegist(name, pwd, unionid, fastRegist)
	if globalUnit.checkIpIsCanLogin == false then
		dispatchEvent("onPlatformRegistCallback",{false, fastRegist, GBKToUtf8("游戏已关闭，无法登陆"), name, pwd, 0})
		return false
	end

	if not fastRegist and self.type ~= 5 and self.type ~= 3 then
		if isEmptyString(name) or isEmptyString(pwd) then
			dispatchEvent("onPlatformRegistCallback",{false, fastRegist, GBKToUtf8("名称或密码为空"), name, pwd, 0})
			return false;
		end
	end

	if unionid == "00000000-0000-0000-0000-000000000000" then
		cc.UserDefault:getInstance():setStringForKey("iosimei","")
		dispatchEvent("onPlatformRegistCallback",{false, fastRegist, GBKToUtf8("机器码获取错误"), name, pwd, 0})
		return false
	end

	-- name = globalUnit.gameChannel..name;--昵称加上渠道后缀

	self._fastRegist = fastRegist;
	self._name = name;
	self._pwd = pwd;
	self._unionId = unionid;

	self:platformRegist();

	return true;
end

-- // 平台连接
function PlatformRegister:I_P_M_Connect(result)
	luaPrint("PlatformRegister ----------")
	if not result then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("平台网络连接失败"), self._name, self._pwd, 0})
		return;
	end
	
	if self.type == 5 then
		dispatchEvent("onPlatformRegistCallback",{true})
	else
		self:platformRegist();
	end
end

-- // 平台注册
function PlatformRegister:I_P_M_Regist(event)
	local registerStruct = event.data;
	local ErrorCode = event.code;
	luaPrint("平台注册 ---")
	self._name = registerStruct.szName;
	self._pwd = registerStruct.szPswd;

	luaDump(event,"event");
	if ErrorCode == REGIST_FAILE then
		if self.type == 2 then
			dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("账号升级失败"), self._name, self._pwd, registerStruct.LogonTimes})
		elseif self.type == 3 then
			dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("绑定手机号失败"), self._name, self._pwd, registerStruct.LogonTimes})
		else
			dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("注册失败"), self._name, self._pwd, registerStruct.LogonTimes})
		end
	elseif ErrorCode == REGIST_SUCCESS then
		globalUnit.isregisterSec = true;
		dispatchEvent("onPlatformRegistCallback",{true, self._fastRegist, GBKToUtf8("注册成功"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == REGIST_SAME_NAME then
		dispatchEvent("onPlatformRegistCallback",{true, self._fastRegist, GBKToUtf8("用户名已存在"),self. _name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == REGIST_FAILE_TUIJINREN then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("推荐人ID填写错误"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 4 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("推荐人ID是非正式账号，不能作为推荐人"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 5 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("该手机号已经注册，不能重复注册"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 6 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("验证码错误"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 7 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("验证码无效"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 8 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("已经绑定过手机"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 9 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("机器码校验错误"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 10 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("未获取验证码"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 11 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("登录密码不能与保险箱密码一致"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 13 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("答案错误"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 15 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("账号已存在"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 16 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("您的手机已注册过账号，不能再注册新号"), self._name, self._pwd, registerStruct.LogonTimes})
	elseif ErrorCode == 18 then
		dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("您已升级为正式账号，请使用用户名密码登录"), self._name, self._pwd, registerStruct.LogonTimes})
	else
		if self.type == 2 then
			dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("账号升级失败"..ErrorCode), self._name, self._pwd, registerStruct.LogonTimes})
		elseif self.type == 3 then
			dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("绑定手机号失败"), self._name, self._pwd, registerStruct.LogonTimes})
		else
			dispatchEvent("onPlatformRegistCallback",{false, self._fastRegist, GBKToUtf8("注册失败"..ErrorCode), self._name, self._pwd, registerStruct.LogonTimes})
		end
	end
end

function PlatformRegister:platformRegist()
	if PlatformLogic:isConnect() then
		if self._fastRegist then
			self:regist(0, GameCreator:getCurrentGameNameID(), self._unionId, self._name);
		else
			if self.type == 0 then
				self:regist(0, GameCreator:getCurrentGameNameID(), self._unionId, self._name, self._pwd);
			else
				self:regist(1, GameCreator:getCurrentGameNameID(), self._unionId, self._name, self._pwd);
			end
		end
	else
		PlatformLogic:connect();
	end
end

function PlatformRegister:regist(byFastRegister, uNameID, usn, name, password)
	local func = function()
		name = name or "";
		password = password or "";

		local msg = {};

		msg.byFromPhone = 1;
		msg.byFastRegister = byFastRegister;
		msg.szHardID = usn;
		msg.szName = name;
		msg.szPswd = password;
		msg.LogonTimes = 0;

		if not self._fastRegist and self.type == 0 then
			-- msg.szHardID = globalUnit.registerInfo.phone
		end

		if PlatformLogic and PlatformLogic.loginResult and PlatformLogic.loginResult.dwUserID then
			msg.dwUserID = PlatformLogic.loginResult.dwUserID
		else
			msg.dwUserID = 0
		end

		msg.UserCheckPhone = globalUnit.registerInfo.code
		msg.PhoneNum = globalUnit.registerInfo.phone
		msg.AgencyID = globalUnit.registerInfo.referee
		msg.answer = globalUnit.registerInfo.answer
		msg.AgentID = channelID
		msg.szIP = getIPAddress()
		msg.qudao = getConfig("channel")
		msg.jsstring = globalUnit.jsstring
		msg.wxID = globalUnit.registerInfo.wxID
		msg.registerid = globalUnit.registerInfo.registerid

		if self.type == 0 and isEmptyString(msg.jsstring) and device.platform ~= "windows" and isEmptyString(SocialUtils._wx_nickname) and not isEmptyString(GameConfig.AliyunUrl) then
			addScrollMessage("校验失败，请重试")
			globalUnit.jsstring1 = ""
			globalUnit.jsstring2 = ""
			dispatchEvent("checkFangShuaFailed")
			return
		end

		luaPrint("开始注册")
		luaDump(msg,"开始注册")
		PlatformLogic:send(PlatformMsg.MDM_GP_REGISTER,PlatformMsg.ASS_GP_REGISTER,msg,PlatformMsg.MSG_GP_S_Register)
		if self.type == 0 and device.platform ~= "windows" and isEmptyString(SocialUtils._wx_nickname) and not isEmptyString(GameConfig.AliyunUrl) then
			uploadInfo("aliyun",gameName.."人机key ="..tostring(msg.jsstring).."结束 usn="..tostring(usn).."device.platform="..device.platform.."ip="..tostring(msg.szIP).."luaV="..GameConfig:getLuaVersion(gameName).."appV="..gVersion)
		end

		if not HallLayer:getInstance() then
			LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("注册中,请稍后"), LOADING):removeTimer(10)
		end
	end

	if isEmptyString(globalUnit.gameChannel) then
		getOpenInstall(func)
	else
		func()
	end
end

return PlatformRegister
