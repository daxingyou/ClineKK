local SetLayer = class("SetLayer",PopLayer)

function SetLayer:ctor()
	self.super.ctor(self)

	self:initUI()
end

function SetLayer:initUI()
	local uiTable = {
		Clip_head = "Clip_head",
		Button_effect = "Button_effect",
		Button_music = "Button_music",
		Button_exchangeAccount = "Button_exchangeAccount",
		Text_accountInfo = "Text_accountInfo",
		Text_nickName = "Text_nickName",
		Text_id = "Text_id"
	}
	loadNewCsb(self, "setLayer", uiTable)
	self.sureBtn:removeSelf()
	self.xBg = self.csbNode

	local title = ccui.ImageView:create("common/setTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local head = cc.Sprite:create(getHeadPath(PlatformLogic.loginResult.bLogoID))
	self.Clip_head:addChild(head)

	self.Button_effect:setTag(1)
	self.Button_music:setTag(2)
	self.Button_exchangeAccount:setTag(3)

	self.Button_effect:onClick(handler(self, self.onClickBtn))
	self.Button_music:onClick(handler(self, self.onClickBtn))
	self.Button_exchangeAccount:onClick(handler(self, self.onClickBtn))

	local path = "off"
	if getEffectIsPlay() then
		path = "on"
	end

	self.Button_effect:loadTextures("set/"..path..".png","set/"..path.."-on.png")

	local path = "off"
	if getMusicIsPlay() then
		path = "on"
	end

	self.Button_music:loadTextures("set/"..path..".png","set/"..path.."-on.png")

	if PlatformLogic.loginResult.IsCommonUser ~= 1 then
		self.Text_accountInfo:setString("您已处于游客登录状态")
	end

	self.Text_id:setString("ID: "..PlatformLogic.loginResult.dwUserID)
	self.Text_nickName:setString(PlatformLogic.loginResult.nickName)
end

function SetLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then
		setEffectIsPlay(not getEffectIsPlay())

		local path = "off"
		if getEffectIsPlay() then
			path = "on"
		end

		sender:loadTextures("set/"..path..".png","set/"..path.."-on.png")
	elseif tag == 2 then
		setMusicIsPlay(not getMusicIsPlay())

		local path = "off"
		if getMusicIsPlay() then
			path = "on"
			playMusic("sound/audio-login.mp3",true)
		end

		sender:loadTextures("set/"..path..".png","set/"..path.."-on.png")
	elseif tag == 3 then
		local prompt = GamePromptLayer:create()
		prompt:showPrompt("确定退出当前账号吗?",true,true)
		prompt:setBtnClickCallBack(function()
			luaPrint("退出当前账号")
			Hall.exitHall()
		end)
	end
end

return SetLayer
