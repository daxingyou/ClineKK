local BankPasswordLayer = class("BankPasswordLayer", PopLayer)

function BankPasswordLayer:ctor()
	self.super.ctor(self,PopType.small)

	self:initUI()

	self:bindEvent()
end

function BankPasswordLayer:initUI()
	local title = ccui.ImageView:create("common/bankTitle.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local h = 100
	local y = self.size.height*0.65
	local x = self.size.width*0.3

	local pwd = ccui.ImageView:create("login/pwdInfo.png")
	pwd:setAnchorPoint(1,0.5)
	pwd:setPosition(x,y)
	self.bg:addChild(pwd)

	self.pwdTextEdit = createEditBox(pwd,"请输入6-20位密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	--确定密码
	local againPwd = ccui.ImageView:create("hall/querenmima.png")
	againPwd:setAnchorPoint(1,0.5)
	againPwd:setPosition(x,y-h)
	self.bg:addChild(againPwd)

	self.againPwdTextEdit = createEditBox(againPwd,"请再输入一次密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	local info = ccui.ImageView:create("hall/bankpwdInfo.png")
	info:setPosition(self.size.width/2,40)
	self.bg:addChild(info)
end

function BankPasswordLayer:bindEvent()
	self:pushEventInfo(BankInfo,"bankPassword",handler(self,self.receiveSetPassword))
end

function BankPasswordLayer:onClickSure(sender)
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

	local newPwd = MD5_CTX:MD5String(pwd)

	if newPwd == PlatformLogic.loginResult.szMD5Pass then
		addScrollMessage("保险箱密码不能与登录密码一致")
		return
	end

	self.newPwd = newPwd

	BankInfo:sendSetBankPasswordRequest(newPwd)
end

function BankPasswordLayer:receiveSetPassword(data)
	local data = data._usedata

	if data.ret == 0 then
		luaPrint("设置保险柜密码成功")
		globalUnit:setBankPwd(self.newPwd)
		PlatformLogic.loginResult.bSetBankPass = 1
		addScrollMessage("设置保险柜密码成功")
		local layer = require("layer.popView.BankLayer"):create()
		if layer then
			display.getRunningScene():addChild(layer)
		end
		self:delayCloseLayer()
	else
		luaPrint("设置保险柜密码失败")
		addScrollMessage("设置保险柜密码失败")
	end
end

return BankPasswordLayer
