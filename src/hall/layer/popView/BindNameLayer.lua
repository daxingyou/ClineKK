local BindNameLayer = class("BindNameLayer", PopLayer)

function BindNameLayer:create()
	return BindNameLayer.new()
end

function BindNameLayer:ctor()
	self.super.ctor(self, PopType.small)

	self:bindEvent()

	self:initUI()
end

function BindNameLayer:bindEvent()
	self:pushGlobalEventInfo("ASS_GP_USERINFO_ACCEPT",handler(self, self.receiveUserinfoAccept))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_NOTACCEPT",handler(self, self.receiveUserinfoNoAccept))
end

function BindNameLayer:initUI()
	local title = ccui.ImageView:create("common/nameTitle.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local h = 90
	local y = self.size.height*0.6
	local x = self.size.width*0.32

	--手机号
	local name = ccui.ImageView:create("login/xingming.png")
	name:setAnchorPoint(1,0.5)
	name:setPosition(x,y)
	self.bg:addChild(name)

	self.nameTextEdit = createEditBox(name,"请输入真实姓名(最长20个字符)",cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
	self.nameTextEdit:setMaxLength(6)

	y = y - h
	local info = FontConfig.createWithSystemFont("(亲爱的玩家，为了您的资金安全，请先完成实名认证！)",26,cc.c3b(255,249,217))
	info:setLineBreakWithoutSpace(true)
	info:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	info:setPosition(self.size.width/2,y)
	self.bg:addChild(info)
end

function BindNameLayer:onClickSure(sender)
	local name = self.nameTextEdit:getText();

	if isEmptyString(name) then
		addScrollMessage("请输入您的真实姓名")
		return
	end

	if isEmoji(name) or not stringIsHaveChinese(name,1) then
		addScrollMessage("您输入的真实姓名包含非汉字如空格等")
		return
	end

	local msg = clone(PlatformLogic.loginResult)
	msg.szRealName = name
	self.name = name

	luaDump(msg,"修改昵称")
    PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_USERINFO_UPDATE_BASE, msg, PlatformMsg.MSG_GP_R_LogonResult)
end

function BindNameLayer:receiveUserinfoAccept()
	addScrollMessage("绑定成功")
	PlatformLogic.loginResult.szRealName = self.name
	createShop()
	self:delayCloseLayer()
end

function BindNameLayer:receiveUserinfoNoAccept()
	addScrollMessage("绑定失败")
end

return BindNameLayer
