local BankPasswordTip = class("BankPasswordTip", PopLayer)

function BankPasswordTip:ctor()
	self.super.ctor(self,PopType.small)

	self:initUI()

	self:bindEvent()
end

function BankPasswordTip:initUI()
	local title = ccui.ImageView:create("common/wenxintishi.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)


	local info = ccui.ImageView:create("hall/banktipInfo.png")
	info:setPosition(self.size.width/2-20,self.size.height*0.7)
	self.bg:addChild(info)

	local h = 100
	local y = self.size.height*0.55
	local x = self.size.width*0.3

	local pwd = ccui.ImageView:create("hall/bankPwd.png")
	pwd:setAnchorPoint(1,0.5)
	pwd:setPosition(x,y)
	self.bg:addChild(pwd)

	self.pwdTextEdit = createEditBox(pwd,"输入保险箱密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

	--忘记密码
	local forgetPwdBtn = ccui.Button:create("login/forget.png","login/forget-on.png")
	forgetPwdBtn:setPosition(self.size.width*0.85,self.sureBtn:getPositionY())
	self.bg:addChild(forgetPwdBtn)
	forgetPwdBtn:onClick(function(sender) self:onClickForgetPwd() end)
end

function BankPasswordTip:bindEvent()
	self:pushEventInfo(BankInfo,"bankPassword",handler(self,self.receiveSetPassword))
	self:pushGlobalEventInfo("updatePwd",handler(self, self.receiveUpdatePwd))
end

function BankPasswordTip:onClickSure(sender)
	local pwd = self.pwdTextEdit:getText()

	if isEmptyString(pwd) then
		luaPrint("密码为空")
		addScrollMessage("密码为空")
		return
	end

	local newPwd = MD5_CTX:MD5String(pwd)

	self.newPwd = newPwd

	BankInfo:sendCheckBankPasswordRequest(newPwd)
end

function BankPasswordTip:receiveSetPassword(data)
	local data = data._usedata

	if data.ret == 0 then
		luaPrint("设置保险柜密码成功")
		addScrollMessage("保险柜密码校验成功")
		globalUnit:setBankPwd(self.newPwd)
		local layer = require("layer.popView.BankLayer"):create()
		if layer then
			display.getRunningScene():addChild(layer)
		end
		self:delayCloseLayer()
	else
		luaPrint("设置保险柜密码失败")
		addScrollMessage("保险柜密码校验失败")
	end
end

function BankPasswordTip:receiveUpdatePwd(data)
	local data = data._usedata

	if data == 0 then
		local layer = require("layer.popView.BankLayer"):create()
		if layer then
			display.getRunningScene():addChild(layer)
		end
		self:delayCloseLayer()
	end
end

function BankPasswordTip:onClickForgetPwd(sender)
	if globalUnit:getLoginType() ~= accountLogin then
		addScrollMessage("请升级到正式账号")
		return
	end

	local layer = require("layer.popView.ForgetPwdLayer"):create(1)

	display.getRunningScene():addChild(layer)

	-- addScrollMessage("请联系游戏客服");
end

return BankPasswordTip
