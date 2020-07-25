local BindBankNode = class("BindBankNode", BaseNode)

function BindBankNode:create(parent,bType)
	return BindBankNode.new(parent,bType)
end

function BindBankNode:ctor(parent,bType)
	self.super.ctor(self)

	self.bType = bType
	self.parent = parent

	self:initData()

	self:bindEvent()

	self:initUI()
end

function BindBankNode:initData()
	self.bankNode = {}
	self.defaultBank = 1
end

function BindBankNode:bindEvent()
	self:pushEventInfo(SettlementInfo,"bindBank",handler(self, self.receiveBindBank))
end

function BindBankNode:initUI()
	local size = self.parent:getContentSize()
	self.size = size

	local flag = false
	if self.bType == 1 then--支付宝
		if PlatformLogic.loginResult.Alipay == "" then
			local h = 85
			local y = size.height*0.8
			local x = size.width*0.45

			--账号
			local mobile = ccui.ImageView:create("settlement/zhifubaozhanghao.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y)
			self:addChild(mobile)

			self.accountTextEdit = createEditBox(mobile,"请输入支付宝账号",cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
			self.accountTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
			self.isInit = true
			performWithDelay(self,function() self.isInit = nil end,0.5):setTag(5555)

			--姓名
			local mobile = ccui.ImageView:create("settlement/zhenshixingming.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y-h)
			self:addChild(mobile)

			self.nameTextEdit = createEditBox(mobile,"请输入真实姓名",cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
			self.nameTextEdit:setMaxLength(20)
		else
			local h = 90
			local y = size.height*0.7
			local x = size.width*0.5

			--账号
			local mobile = ccui.ImageView:create("settlement/zhifubaozhanghao.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y)
			self:addChild(mobile)

			local label = FontConfig.createWithSystemFont(PlatformLogic.loginResult.Alipay,26,cc.c3b(231,201,158))
			label:setAnchorPoint(0,0.5)
			label:setPosition(mobile:getContentSize().width+20, mobile:getContentSize().height/2)
			mobile:addChild(label)

			--姓名
			local mobile = ccui.ImageView:create("settlement/zhenshixingming.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y-h)
			self:addChild(mobile)

			local label = FontConfig.createWithSystemFont(PlatformLogic.loginResult.szRealName,26,cc.c3b(231,201,158))
			label:setAnchorPoint(0,0.5)
			label:setPosition(mobile:getContentSize().width+20, mobile:getContentSize().height/2)
			mobile:addChild(label)
			flag = true
		end
	elseif self.bType == 2 then--银行卡
		if PlatformLogic.loginResult.BankNo == "" then
			local h = 67
			local y = size.height*0.9-5
			local x = size.width*0.45

			--账号
			local mobile = ccui.ImageView:create("settlement/yinhangkahao.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y)
			self:addChild(mobile)

			self.accountTextEdit = createEditBox(mobile,"请输入银行卡号",cc.EDITBOX_INPUT_MODE_NUMERIC,1)
			self.accountTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
			-- self.isInit = true
			-- performWithDelay(self,function() self.isInit = nil end,0.5):setTag(5555)

			--姓名
			local mobile = ccui.ImageView:create("settlement/zhenshixingming.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y-h)
			self:addChild(mobile)

			self.nameTextEdit = createEditBox(mobile,"请输入真实姓名",cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
			self.nameTextEdit:setMaxLength(20)
			--银行列表
			local x = 0
			local y = 0

			for i=1,16 do
				local btn = ccui.Button:create("settlement/b"..i..".png","settlement/b"..i..".png")
				btn:setAnchorPoint(0,0.5)
				btn:setTag(i)

				if x == 0 then
					x = size.width*0.25+20
				end

				if y == 0 then
					y = size.height*0.65-20
				end

				btn:setPosition(x,y)
				self:addChild(btn)
				btn:onClick(function(sender) self:onClickSure(sender) end)

				x = x + btn:getContentSize().width

				if i % 4 == 0 then
					x = 0
					y = y - btn:getContentSize().height - 2
				end

				local image = ccui.ImageView:create("settlement/xuanzhongkuang.png")
				image:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
				image:setTag(1)
				-- image:setVisible(self.defaultBank == i)
				btn:addChild(image)

				table.insert(self.bankNode,btn)
			end
			self:onClickSure(self.bankNode[1])
		else
			local h = 90
			local y = size.height*0.7
			local x = size.width*0.5

			--账号
			local mobile = ccui.ImageView:create("settlement/yinhangkahao.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y)
			self:addChild(mobile)

			local label = FontConfig.createWithSystemFont(PlatformLogic.loginResult.BankNo,26,cc.c3b(231,201,158))
			label:setAnchorPoint(0,0.5)
			label:setPosition(mobile:getContentSize().width+20, mobile:getContentSize().height/2)
			mobile:addChild(label)

			--姓名
			local mobile = ccui.ImageView:create("settlement/zhenshixingming.png")
			mobile:setAnchorPoint(1,0.5)
			mobile:setPosition(x,y-h)
			self:addChild(mobile)

			local label = FontConfig.createWithSystemFont(PlatformLogic.loginResult.szRealName,26,cc.c3b(231,201,158))
			label:setAnchorPoint(0,0.5)
			label:setPosition(mobile:getContentSize().width+20, mobile:getContentSize().height/2)
			mobile:addChild(label)

			flag = true
		end
	end

	if flag == false then
		local sureBtn = ccui.Button:create("settlement/querenbangding.png","settlement/querenbangding-on.png")
		sureBtn:setPosition(size.width*0.6,size.height*0.15-15)
		self:addChild(sureBtn)
		sureBtn:setTag(0)
		sureBtn:onClick(function(sender) self:onClickSure(sender) end)
	end
end

function BindBankNode:onClickSure(sender)
	local tag = sender:getTag()

	if tag == 0 then--绑定
		if self.isClick then
			addScrollMessage("正在绑定，请稍后操作")
			return
		end

		local account = self.accountTextEdit:getText()
		local name = self.nameTextEdit:getText()
		if self.bType == 1 then
			if isEmptyString(account) then
				addScrollMessage("请输入您的支付宝账号")
				return
			end

			if stringIsHaveChinese(account) == true then
				addScrollMessage("请输入正确支付宝账号")
				return
			end

			local ret = checkEmail(account)
			local ret1 = checkPhoneNum(account)

			if not ret and not ret1 then
				addScrollMessage("请输入格式正确的支付宝账号")
				return
			end

			if isEmptyString(name) then
				addScrollMessage("请输入您的真实姓名")
				return
			end

			if isEmoji(name) or not stringIsHaveChinese(name,1) then
				addScrollMessage("您输入的真实姓名包含非汉字如空格等")
				return
			end
		elseif self.bType == 2 then
			if isEmptyString(account) then
				addScrollMessage("请输入您的银行卡号")
				return
			end

			if not checkNumber(account) then
				addScrollMessage("请输入正确银行卡号")
				return
			end

			if isEmptyString(name) then
				addScrollMessage("请输入您的真实姓名")
				return
			end

			if isEmoji(name) or not stringIsHaveChinese(name,1) then
				addScrollMessage("您输入的真实姓名包含非汉字如空格等")
				return
			end
		end

		self.isClick = true

		SettlementInfo:sendBindBankRequest(name,account,self.bType,self.defaultBank)

		self.action = performWithDelay(self,function() self.isClick = nil self.action = nil end,3)
	else
		for k,v in pairs(self.bankNode) do
			if tag == v:getTag() then
				v:setTouchEnabled(false)
				v:getChildByTag(1):show()
				self.defaultBank = tag
			else
				v:setTouchEnabled(true)
				v:getChildByTag(1):hide()
			end
		end
	end
end

function BindBankNode:receiveBindBank(data)
	if not self:isVisible() then
		return
	end

	local data = data._usedata

	if data.ret == 0 then
		addScrollMessage("绑定成功")
		self:removeAllChildren()
		self:initUI()
	elseif data.ret == 3 then
		addScrollMessage("绑定失败，对应姓名需与之前绑定姓名一致")
	elseif data.ret == 2 then
		addScrollMessage("绑定失败,银行卡被占用")
	elseif data.ret == 1 then
		addScrollMessage("绑定失败,支付宝被占用")
	else
		addScrollMessage("绑定失败")
	end

	self.isClick = nil

	if self.action then
		self:stopAction(self.action)
		self.action = nil
	end
end

function BindBankNode:onEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		-- self.isInit = nil
		-- self:stopActionByTag(5555)
	elseif name == "ended" then
		-- numberVerify(event.target)
	elseif name == "return" then
		-- numberVerify(event.target)
	elseif name == "changed" then
		-- if self.isInit ~= true then
			-- self:numberVerify(event.target)
		-- end
	end
end

function BindBankNode:numberVerify(sender)
	if self.bType == 1 then
		local text = sender:getText()
		if stringIsHaveChinese(text) == true then
			addScrollMessage("请输入正确支付宝账号")
			return
		end

		if not isEmptyString(text) then
			if #text < 8 then
				return
			end
		end

		local ret = checkEmail(text)
		local ret1 = checkPhoneNum(text)

		if not ret and not ret1 then
			addScrollMessage("请输入格式正确的支付宝账号")
		end
	else
		local rt = checkNumber(text)

		if rt == false then
			addScrollMessage("请输入正确银行卡号")
		end
	end
end

return BindBankNode
