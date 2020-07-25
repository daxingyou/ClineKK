local ForgetPwdLayer = class("ForgetPwdLayer", PopLayer)

function ForgetPwdLayer:create(forgetType)
	return ForgetPwdLayer.new(forgetType)
end

function ForgetPwdLayer:ctor(forgetType)
	self.super.ctor(self,PopType.small)

	self.forgetType = forgetType or 0--默认登陆密码

	self:initUI()

	self:bindEvent()
end

function ForgetPwdLayer:initUI()
	self:updateSureBtnPos(-22)
	local title = ccui.ImageView:create("common/forgetTitle.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local h = 80
	local y = self.size.height*0.73
	local x = self.size.width*0.3

	--手机号
	local mobile = ccui.ImageView:create("login/mobile.png")
	mobile:setAnchorPoint(1,0.5)
	mobile:setPosition(x,y)
	self.bg:addChild(mobile)

	self.phoneTextEdit = createEditBox(mobile,"请输入手机号",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1)
	-- self.phoneTextEdit:setText(PlatformLogic.loginResult.szMobileNo)
	-- self.phoneTextEdit:setTouchEnabled(false)

	--验证码
	local mobileCode = ccui.ImageView:create("login/mobileCode.png")
	mobileCode:setAnchorPoint(1,0.5)
	mobileCode:setPosition(x,y-h)
	self.bg:addChild(mobileCode)

	self.codeTextEdit, editBg = createEditBox(mobileCode,"请输入验证码",cc.EDITBOX_INPUT_MODE_PHONENUMBER,1,cc.size(300,70))

	--获取验证码
	self.codeBtn = createPhoneCodeBtn(editBg,handler(self, self.sendPhoneCode))
	editBg = nil

	--输入密码
	local pwd = ccui.ImageView:create("login/pwd.png")
	pwd:setAnchorPoint(1,0.5)
	pwd:setPosition(x,y-h*2)
	self.bg:addChild(pwd)

	self.pwdTextEdit = createEditBox(pwd,"请输入6-20位密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	--确定密码
	local againPwd = ccui.ImageView:create("login/againPwd.png")
	againPwd:setAnchorPoint(1,0.5)
	againPwd:setPosition(x,y-h*3)
	self.bg:addChild(againPwd)

	self.againPwdTextEdit = createEditBox(againPwd,"请再次输入密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	if self.forgetType == 1 then
		local info = FontConfig.createWithSystemFont("提示:1.使用余额宝请先设置余额宝密码2.余额宝密码不能与登录密码一样",22,cc.c3b(174,186,226))
		info:setPosition(self.size.width/2,80)
		self.bg:addChild(info)
	end
end

function ForgetPwdLayer:bindEvent()
	self:pushGlobalEventInfo("updatePwd",handler(self, self.receiveUpdatePwd))
	self:pushGlobalEventInfo("getCodeSuccess",handler(self, self.receiveGetCodeSuccess))
	self:pushGlobalEventInfo("onPlatformRegistCallback",handler(self, self.onReceivePlatformRegistCallback))
end

function ForgetPwdLayer:onClickSure(sender)
	local phone = self.phone

	if isEmptyString(phone) then
		phone = self.phoneTextEdit:getText()
	end

	if isEmptyString(phone) then
		luaPrint("手机号为空")
		addScrollMessage("手机号为空")
		return
	end

	if #phone > 11 then
		luaPrint("您输入的手机号有误，请重输")
		addScrollMessage("您输入的手机号有误，请重输")
		return
	end

	local code = self.codeTextEdit:getText()

	if isEmptyString(code) then
		luaPrint("验证码为空")
		addScrollMessage("验证码为空")
		return
	end

	local pwd = self.pwdTextEdit:getText()

	if isEmptyString(pwd) then
		luaPrint("密码为空")
		addScrollMessage("密码为空")
		return
	end

	local ret,msg = verifyNumberAndEnglish(pwd)
	if not ret then
		luaPrint("您输入的密码包含非法字符")
		addScrollMessage(msg)
		return
	end

	if #pwd < 6 then
		luaPrint("您输入的密码小于6位，请重输")
		addScrollMessage("您输入的密码小于6位，请重输")
		return
	end

	if #pwd > 20 then
		luaPrint("您输入的密码大于20位，请重输")
		addScrollMessage("您输入的密码大于20位，请重输")
		return
	end

	local againPwd = self.againPwdTextEdit:getText()

	if isEmptyString(againPwd) then
		luaPrint("确认密码为空")
		addScrollMessage("确认密码为空")
		return
	end

	if pwd ~= againPwd then
		luaPrint("两次密码不一致")
		addScrollMessage("两次密码不一致")
		return
	end

	local ret,msg = verifyNumberAndEnglish(againPwd)
	if not ret then
		addScrollMessage(msg)
		return
	end

	local msg = {}
	msg.PhoneNum = phone
	msg.UserCheckPhone = code
	msg.szMD5NewPass = MD5_CTX:MD5String(pwd)
	msg.PassType = self.forgetType
	if self.forgetType == 1 then
		msg.dwUserID = PlatformLogic.loginResult.dwUserID
	end
	msg.channel = channelID

	self:sendUpdatePwd(msg)
end

--发送手机验证码
function ForgetPwdLayer:sendPhoneCode(sender)
	luaPrint("发送手机验证码")
	if self.forgetType == 1 and globalUnit:getLoginType() ~= accountLogin then
		addScrollMessage("请升级到正式账号")
		return false
	end

	local phone = self.phoneTextEdit:getText()

	if isEmptyString(phone) then
		luaPrint("手机号为空")
		addScrollMessage("手机号为空")
		return false
	end

	if not checkPhoneNum(phone) then
		addScrollMessage("请输入正确的手机号")
		return false
	end

	sender:setTouchEnabled(false)

	self.phone = phone

	local url = GameConfig:getVerificationCodeUrl()
	local str = "userid="..(PlatformLogic.loginResult.dwUserID or 0).."&phone="..phone.."&type=2"
	local rd,code,pcode = createCheckCode()
	
	if self.forgetType == 1 then
		str = "userid="..(PlatformLogic.loginResult.dwUserID or 0).."&phone="..phone.."&type=3"
	end

	str = str.."&rd="..rd.."&code="..code.."&pcode="..pcode.."&AgentID="..channelID

	HttpUtils:requestHttp(url, function(result, response) getCodeCallback(result, response); end, "POST", str);

	return true
end

function ForgetPwdLayer:receiveUpdatePwd(data)
	local data = data._usedata

	LoadingLayer:removeLoading()

	if data == 0 then
		luaPrint("修改成功")
		if self.forgetType == 1 then
			globalUnit:setBankPwd(self.msg.szMD5NewPass)
		end
		addScrollMessage("修改密码成功")
		self:delayCloseLayer()
	elseif data == 1 then
		addScrollMessage("用户不存在")
	elseif data == 2 then
		addScrollMessage("验证码过期")
	elseif data == 3 then
		addScrollMessage("验证码无效")
	elseif data == 4 then
		addScrollMessage("修改密码失败")
	elseif data == 5 then
		addScrollMessage("账号密码不能与保险箱密码一致")
	elseif data == 6 then
		addScrollMessage("手机号不匹配")
	else
		luaPrint("修改失败")
		addScrollMessage("修改密码失败")
	end
end

function ForgetPwdLayer:receiveGetCodeSuccess(data)
	local data = data._usedata
	if data == false then
		self.codeBtn:setTouchEnabled(true)
		return
	end

	local sender = self.codeBtn
	sender:removeAllChildren()

	sender:setEnabled(false)
	sender:loadTextures("input/getNo.png","input/getNo-on.png","input/getNo-dis.png")
	local tm = 60;
	local text = FontConfig.createWithCharMap(tm.."s","input/inputNum.png",20,29,"0",{{"s",":"}})
	text:setPosition(sender:getContentSize().width/2,sender:getContentSize().height/2)
	sender:addChild(text)
	text:setTag(tm)

	local fun = function() 
		local tag = text:getTag()

		tag = tag - 1

		if tag < 0 then
			text:removeSelf()
			sender:setEnabled(true)
			sender:loadTextures("input/get.png","input/get-on.png","input/get-dis.png")
			sender:setTouchEnabled(true)
		else
			text:setText(tag.."s",{{"s",":"}})
			text:setTag(tag)
		end
	end

	schedule(text, fun, 1)
end

function ForgetPwdLayer:sendUpdatePwd(msg)
	PlatformLogic:close()
	self.msg = msg
	if PlatformLogic:isConnect() then
		self:onPlatformRegistCallback(true)
	else
		PlatformRegister:getInstance().type = 5
		PlatformRegister:getInstance():start()
		PlatformRegister:getInstance():requestRegist("", "", onlyString, false)
	end

	LoadingLayer:createLoading(FontConfig.gFontConfig_30, "正在修改密码,请稍后", LOADING):removeTimer(10)
end

function ForgetPwdLayer:onReceivePlatformRegistCallback(data)
	local data = data._usedata

	self:onPlatformRegistCallback(data[1],data[2],data[3],data[4],data[5],data[6])
end

function ForgetPwdLayer:onPlatformRegistCallback(success, fastRegist, message, name, pwd, loginTimes)
	PlatformRegister:getInstance():stop()

	luaDump(self.msg,"连接完毕")
	if success then
		PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO,PlatformMsg.ASS_GP_USERINFO_UPDATE_PWD,self.msg,PlatformMsg.MSG_GP_S_ChPassword)
	else
		performWithDelay(self,function() LoadingLayer:removeLoading() end,0.1)
		GamePromptLayer:create():showPrompt(message)
	end
end

function ForgetPwdLayer:onExit()
	PlatformRegister:getInstance():stop()
	self.super.onExit(self)
end

return ForgetPwdLayer
