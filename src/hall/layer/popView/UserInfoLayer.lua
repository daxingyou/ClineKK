local UserInfoLayer = class("UserInfoLayer",PopLayer)

function UserInfoLayer:ctor()
	self.super.ctor(self,PopType.middle)

	self:initData()

	self:initUI()

	self:bindEvent()
end

function UserInfoLayer:initData()
	self.checkBox = {}
	self.text = {}
end

function UserInfoLayer:bindEvent()
	self:pushGlobalEventInfo("ASS_GP_USERINFO_ACCEPT",handler(self, self.receiveUserinfoAccept))
	self:pushGlobalEventInfo("accountUpSuccess",handler(self, self.receiveAccountUp))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.receiveAccountUp))
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.onEnterForeground))
	self:pushGlobalEventInfo("ASS_GP_USERINFO_NOTACCEPT",handler(self, self.receiveUserinfoNoAccept))
end

function UserInfoLayer:initUI()
	local title = ccui.ImageView:create("common/userTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local bg = ccui.ImageView:create("common/smallBg.png")
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.bg:addChild(bg)

	local size = bg:getContentSize()

	--cebian
	bg:setCascadeOpacityEnabled(false);
	bg:setOpacity(0);
	local cebianBg = ccui.ImageView:create("mail/cebian.png")
	
	cebianBg:setPosition(cc.p(cebianBg:getContentSize().width*0.5,cebianBg:getContentSize().height/2+8.5))
	bg:addChild(cebianBg);
	cebianBg:setVisible(false);

	local x = self.size.width*0.1
	local h = 100

	local btn = ccui.ImageView:create("userCenter/userInfo.png")
	btn:setPosition(x,size.height*0.8)
	bg:addChild(btn)
	btn:setVisible(false);

	--头像
	local headBg = cc.Sprite:create("userCenter/headBg.png")
	headBg:setPosition(200,358)
	bg:addChild(headBg)

	local head = cc.Sprite:create("userCenter/head.png")
	head:setPosition(headBg:getContentSize().width/2,headBg:getContentSize().height/2)
	headBg:addChild(head)

	local node = cc.ClippingNode:create()
	node:setAlphaThreshold(0)
	local front = cc.Sprite:createWithSpriteFrame(head:getSpriteFrame())
	node:setStencil(front)
	node:setInverted(false)
	node:setAnchorPoint(0.5,0.5)
	node:setPosition(head:getContentSize().width/2,head:getContentSize().height/2)
	head:addChild(node)

	local head = cc.Sprite:create(getHeadPath(PlatformLogic.loginResult.bLogoID))
	node:addChild(head)
	self.head = head

	--ID
	local idText = FontConfig.createWithSystemFont("ID: "..PlatformLogic.loginResult.dwUserID,28,cc.c3b(255,249,217))
	idText:setPosition(450,370)
	bg:addChild(idText)

	--复制
	local btn = ccui.Button:create("userCenter/copy.png","userCenter/copy-on.png")
	btn:setTag(1)
	btn:setPosition(658,370)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	--昵称
	local node = cc.Node:create()
	node:setPosition(335,295)
	bg:addChild(node)

	node.epath = "userCenter/user_input.png"
	self.codeTextEdit, editBg = createEditBox(node,FormotGameNickName(PlatformLogic.loginResult.nickName,10),cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
	self.codeTextEdit:setTouchEnabled(false)
	self.codeTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
	self.codeTextEdit:setText(FormotGameNickName(PlatformLogic.loginResult.nickName,10))
	self.codeTextEdit:setMaxLength(11)

	local btn = ccui.Button:create("userCenter/update.png","userCenter/update-on.png")
	btn:setPosition(editBg:getContentSize().width,editBg:getContentSize().height/2)
	btn:setAnchorPoint(1,0.5)
	btn:setTag(2)
	editBg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	editBg = nil
	self.updateBtn = btn

	if globalUnit:getLoginType() ~= accountLogin then
		-- btn:hide()
	end

	--更换头像
	local btn = ccui.Button:create("userCenter/changeHead.png","userCenter/changeHead-on.png")
	btn:setTag(3)
	btn:setPosition(201,233)
	btn:setTouchEnabled(false)
	bg:addChild(btn)
	-- btn:onClick(function(sender) self:onClickBtn(sender) end)

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(185,240))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(201,233)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	btn:setTag(3)
	bg:addChild(btn)
	btn:onTouchClick(function(sender) self:onClickBtn(sender) end)

	--男
	local checkBox = ccui.CheckBox:create("common/gouxuankuang.png","common/gouxuankuang.png","common/gouxuan.png","common/gouxuankuang.png","common/gouxuankuang.png")
	checkBox:setPosition(785,377)
	checkBox:setTag(1)
	bg:addChild(checkBox)
	checkBox:onEvent(handler(self, self.onClickCheckBox))
	table.insert(self.checkBox,checkBox)

	local image = ccui.ImageView:create("userCenter/man.png")
	image:setPosition(861,376)
	bg:addChild(image)

	--女
	local checkBox = ccui.CheckBox:create("common/gouxuankuang.png","common/gouxuankuang.png","common/gouxuan.png","common/gouxuankuang.png","common/gouxuankuang.png")
	checkBox:setPosition(785,298)
	checkBox:setTag(2)
	bg:addChild(checkBox)
	checkBox:onEvent(handler(self, self.onClickCheckBox))
	table.insert(self.checkBox,checkBox)

	local image = ccui.ImageView:create("userCenter/woman.png")
	image:setPosition(860,298)
	bg:addChild(image)

	if PlatformLogic.loginResult.bBoy == true then
		self.checkBox[1]:setSelected(true)
	else
		self.checkBox[2]:setSelected(true)
		self.head:initWithFile(getHeadPath(PlatformLogic.loginResult.bLogoID))
	end

	--增加设置信息 --音效
	local y_v = 150;
	local path = "off"
	if getEffectIsPlay() then
		path = "on"
	end

	local Image_effect = ccui.ImageView:create("set/effect.png");
	bg:addChild(Image_effect);
	Image_effect:setPosition(cc.p(230,y_v));
	self.Button_effect = ccui.Button:create("set/"..path..".png","set/"..path.."-on.png","set/"..path.."-on.png");
	bg:addChild(self.Button_effect);
	self.Button_effect:setPosition(cc.p(230+140,y_v));
	self.Button_effect:setTag(101);

	--音乐
	local path = "off"
	if getMusicIsPlay() then
		path = "on"
	end
	local Image_music = ccui.ImageView:create("set/music.png");
	bg:addChild(Image_music);
	Image_music:setPosition(cc.p(588,y_v));
	self.Button_music = ccui.Button:create("set/"..path..".png","set/"..path.."-on.png","set/"..path.."-on.png");
	bg:addChild(self.Button_music);
	self.Button_music:setPosition(cc.p(588+140,y_v));
	self.Button_music:setTag(102);

	--切换账号
	self.Button_exchangeAccount = ccui.Button:create("set/changeAccount.png","set/changeAccount-on.png","set/changeAccount-on.png");
	bg:addChild(self.Button_exchangeAccount);
	self.Button_exchangeAccount:setPosition(cc.p(517,50));
	self.Button_exchangeAccount:setTag(103);

	self.Button_effect:onClick(handler(self, self.onClickBtn))
	self.Button_music:onClick(handler(self, self.onClickBtn))
	self.Button_exchangeAccount:onClick(handler(self, self.onClickBtn))

	local text = ""
	local Text_accountInfo = ccui.Text:create("",FONT_PTY_TEXT,20);
	Text_accountInfo:setTextColor(cc.c4b(231,201,158, 255)); 
	bg:addChild(Text_accountInfo);
	Text_accountInfo:setAnchorPoint(0,0.5);
	Text_accountInfo:setPosition(cc.p(420,-46));

	local Image_light = ccui.ImageView:create("userCenter/dengpao.png");
	bg:addChild(Image_light);
	Image_light:setPosition(cc.p(420 - Image_light:getContentSize().width,-46));

	if PlatformLogic.loginResult.IsCommonUser ~= 1 then
		if cc.UserDefault:getInstance():getIntegerForKey("wxlogin", 0) == 0 and isEmptyString(PlatformLogic.loginResult.weChat) then
			text = "您已处于游客登录状态"
		else
			text = "您已处于微信登录状态"
		end
	else
		text = "您已处于账号登录状态"
	end

	Text_accountInfo:setString(text)

	if showBindPhone(false) then
		self.sureBtn:setLocalZOrder(2)
		self:updateSureBtnPos(nil,100)
		self:updateSureBtnImage("login/accountUp1.png","login/accountUp1-on.png")

		self.sureBtn:setPosition(cc.p(800,155));
		self.Button_exchangeAccount:setPosition(cc.p(315,50));
	else
		self.sureBtn:removeSelf()
		self.sureBtn = nil
	end

	local btn = ccui.Button:create("gameUpdate/xiufu.png","gameUpdate/xiufu.png")
	btn:setTag(104)
	btn:setPosition(150,-46)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
end

function UserInfoLayer:onClickCheckBox(event)
	if self.isClick then
		return
	end
	self.isClick = true
	performWithDelay(self,function() self.isClick = nil end,2)

	local tag = event.target:getTag()

	for k,v in pairs(self.checkBox) do
		-- v:setTouchEnabled(v:getTag() ~= tag)
		v:setTouchEnabled(false)
		v:setSelected(v:getTag() == tag)
	end

	table.insert(self.text,
		{"头像修改成功",
		function() 
			self.head:initWithFile(getHeadPath(PlatformLogic.loginResult.bLogoID))
			for k,v in pairs(self.checkBox) do
				v:setTouchEnabled(not v:isSelected())
			end
		end})

	local msg = PlatformLogic.loginResult
	if tag == 1 then
		msg.bLogoID = 1
	else
		msg.bLogoID = 6
	end

	if event.id then
		msg.bLogoID = event.id
	end

	msg.bBoy = (tag == 1)

	PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_USERINFO_UPDATE_BASE, msg, PlatformMsg.MSG_GP_R_LogonResult)
end

function UserInfoLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then--复制ID
		if copyToClipBoard(PlatformLogic.loginResult.dwUserID) then
			addScrollMessage("账号ID复制成功")
		end

	elseif tag == 2 then--修改昵称
		self:sendNewNickName()
	elseif tag == 3 then--更改头像
		self:updateHeadImage()
	elseif tag == 101 then --音效
		setEffectIsPlay(not getEffectIsPlay())

		local path = "off"
		if getEffectIsPlay() then
			path = "on"
		end

		sender:loadTextures("set/"..path..".png","set/"..path.."-on.png")
	elseif tag == 102 then --音乐
		setMusicIsPlay(not getMusicIsPlay())

		local path = "off"
		if getMusicIsPlay() then
			path = "on"
			playMusic("sound/audio-login.mp3",true)
		end

		sender:loadTextures("set/"..path..".png","set/"..path.."-on.png")
	elseif tag == 103 then --切换账号
		local prompt = GamePromptLayer:create()
		prompt:showPrompt("确定退出当前账号吗?",true,true)
		prompt:setBtnClickCallBack(function()
			luaPrint("退出当前账号")
			Hall.exitHall()
		end)
	elseif tag == 104 then
		local len = 0
		for k,v in pairs(gameDownloadProgessTimer) do
			if v ~= nil and #v > 0 then 
				len = len + 1;
			end
		end

		if len > 0 then
			addScrollMessage("游戏正在下载中，请稍后")
			return
		end

		clearChildGameCacheResources()
		addScrollMessage("修复完成")

		local ret = true

		if GameConfig:getLuaVersion(gameName) >= 240 then
			if isRepairUpate ~= true then
				ret = false
			end
		end

		luaPrint("ret ",ret,NO_UPDATE,isCheckRestartDownload)

		if ret and NO_UPDATE == true and isCheckRestartDownload ~= true then
		else
			isAutoXiufu = true
			Hall:startDownload()
		end
	end
end

function UserInfoLayer:onEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		--todo
	elseif name == "ended" then
		self:sendNewNickName(true)
	elseif name == "return" then
	elseif name == "changed" then
		self.isForeground = nil
	end
end

function UserInfoLayer:sendNewNickName(flag)
	if self.isClick then
		return
	end

	self.isForeground = nil

	if not self.codeTextEdit:isTouchEnabled() and flag == nil then
		self.codeTextEdit:setTouchEnabled(true)
		self.codeTextEdit:touchDownAction(self.codeTextEdit,ccui.TouchEventType.ended)
		return
	end

	if flag ~= nil then
		self.codeTextEdit:setTouchEnabled(false)
	end

	local nickName = self.codeTextEdit:getText()

	if isEmptyString(nickName) then
		addScrollMessage("请输入您的昵称，不能为空")
		self.codeTextEdit:setText(FormotGameNickName(PlatformLogic.loginResult.nickName,10))
		return
	end

	if isEmoji(nickName) then
		addScrollMessage("请输入正确昵称")
		self.codeTextEdit:setText(FormotGameNickName(PlatformLogic.loginResult.nickName,10))
		return
	end

	if nickName == PlatformLogic.loginResult.nickName then
		addScrollMessage("昵称未变化")
		self.codeTextEdit:setText(FormotGameNickName(PlatformLogic.loginResult.nickName,10))
	else
		self.isClick = true
		local msg = clone(PlatformLogic.loginResult)
		msg.nickName = nickName
		self.nickName = nickName

		PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_USERINFO_UPDATE_BASE, msg, PlatformMsg.MSG_GP_R_LogonResult)
		table.insert(self.text,{"昵称修改成功"})
		performWithDelay(self,function() self.isClick = nil end,2)
	end
end

function UserInfoLayer:updateHeadImage()
	local func = function(id)
		local event = {}
		event.target = self.checkBox[1]
		event.id = id
		if id >= 6 then
			event.target = self.checkBox[2]
		end
		self:onClickCheckBox(event)
	end

	local layer = require("layer.popView.HeadLayer"):create()
	layer:setHeadCallback(func)
	display.getRunningScene():addChild(layer)
end

function UserInfoLayer:receiveUserinfoAccept()
	if not isEmptyTable(self.text) then
		addScrollMessage(self.text[1][1])
		if self.text[1][2] then
			self.text[1][2]()
		end

		if self.text[1][1] == "昵称修改成功" then
			PlatformLogic.loginResult.nickName = self.nickName
			dispatchEvent("refreshScoreBank")
		end

		table.remove(self.text,1)
	end

	self.isClick = nil
end

function UserInfoLayer:receiveUserinfoNoAccept()
	if not isEmptyTable(self.text) then

		if self.text[1][1] == "昵称修改成功" then
			table.remove(self.text,1)
		end
	end

	addScrollMessage("昵称修改失败(不能重复或包含非法字符)")
	self.codeTextEdit:setText(FormotGameNickName(PlatformLogic.loginResult.nickName,10))
end

function UserInfoLayer:onClickSure(sender)
	local layer = require("layer.popView.RegisterLayer"):create()
	display.getRunningScene():addChild(layer)
end

function UserInfoLayer:receiveAccountUp(data)
	if data then
		local data = data._usedata

		if data then
			self:stopActionByTag(5555)
			if self.isForeground ~= true then
				self.codeTextEdit:setText(FormotGameNickName(data.szNickName,10))
			else
				-- self.isForeground = nil
			end
		else
			self.updateBtn:show()

			if self.sureBtn then
				--重置切换账号位置
				self.Button_exchangeAccount:setPosition(cc.p(517,50));
				self.sureBtn:removeSelf()
				self.sureBtn = nil
			end
		end
	end
end

function UserInfoLayer:onEnterForeground()
	luaPrint("UserInfoLayer 从后台回来了---------------------------------------------")
	self.isForeground = true

	performWithDelay(self,function() self.isForeground = nil end,5):setTag(5555)
end

return UserInfoLayer
