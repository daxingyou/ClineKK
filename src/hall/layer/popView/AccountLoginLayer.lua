local AccountLoginLayer = class("AccountLoginLayer", PopLayer)

function AccountLoginLayer:ctor()
	self.super.ctor(self,PopType.small)

	self:initUI()
end

function AccountLoginLayer:setLoginCallback(callback)
	self.callback = callback
end

function AccountLoginLayer:initUI()
	self:updateSureBtnImage("login/accountLogin.png","login/accountLogin-on.png")

	local title = ccui.ImageView:create("common/loginTitle.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local h = 100
	local y = self.size.height*0.65
	local x = self.size.width*0.3

	--手机号
	local account = ccui.ImageView:create("login/name.png")
	account:setAnchorPoint(1,0.5)
	account:setPosition(x,y)
	self.bg:addChild(account)

	local userName = cc.UserDefault:getInstance():getStringForKey(USERNAME_TEXT, "")
	self.accountTextEdit = createEditBox(account,"请输入您的手机号",cc.EDITBOX_INPUT_MODE_SINGLELINE)
	if globalUnit:getLoginType() == accountLogin then
		self.accountTextEdit:setText(userName)
	end

	--验证码
	local pwd = ccui.ImageView:create("login/pwdInfo.png")
	pwd:setAnchorPoint(1,0.5)
	pwd:setPosition(x,y-h)
	self.bg:addChild(pwd)

	self.pwdTextEdit = createEditBox(pwd,"请输入您的密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	if device.platform == "windows" then
		self.pwdTextEdit:setText("123456a")
	end

	--忘记密码
	local forgetPwdBtn = ccui.Button:create("login/forget.png","login/forget-on.png")
	forgetPwdBtn:setPosition(self.size.width*0.75+30,self.sureBtn:getPositionY())
	self.bg:addChild(forgetPwdBtn)
	forgetPwdBtn:onClick(function(sender) self:onClickForgetPwd() end)

	local reigsterBtn = ccui.Button:create("login/zhuce.png","login/zhuce-on.png")
	reigsterBtn:setPosition(self.size.width*0.25-30,self.sureBtn:getPositionY())
	self.bg:addChild(reigsterBtn)
	reigsterBtn:onClick(function(sender) self:registerEventCallback() end)
end

function AccountLoginLayer:onClickSure(sender)
	local userName = self.accountTextEdit:getText()

	if isEmptyString(userName) then
		luaPrint("请输入您的手机号")
		addScrollMessage("请输入您的手机号")
		return
	end

	local s = string.gsub(userName,"[%w]","")

	if not isEmptyString(s) then
		addScrollMessage("手机号只能包含字母和数字")
		return
	end

	local pwd = self.pwdTextEdit:getText()

	if isEmptyString(pwd) then
		luaPrint("请输入您的密码")
		addScrollMessage("请输入您的密码")
		return
	end

	if self.callback then
		self.callback(userName,pwd)
	else
		dispatchEvent("accountLogin",{userName,pwd})
	end
end

function AccountLoginLayer:onClickForgetPwd(sender)
	local layer = require("layer.popView.ForgetPwdLayer"):create()

	display.getRunningScene():addChild(layer)
	-- addScrollMessage("请联系登录页面的客服");
end

function AccountLoginLayer:registerEventCallback(sender)
   dispatchEvent("registerCallback")
end

return AccountLoginLayer


