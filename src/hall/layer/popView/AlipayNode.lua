local AlipayNode = class("AlipayNode", BaseNode)

function AlipayNode:create(parent,bType)
	return AlipayNode.new(parent,bType)
end

function AlipayNode:ctor(parent,bType)
	self.super.ctor(self)

	self.parent = parent
	self.bType = bType

	self:initData()

	self:bindEvent()

	self:initUI()
end

function AlipayNode:initData()
end

function AlipayNode:bindEvent()
	-- self:pushEventInfo(SettlementInfo,"weChat",handler(self, self.receiveWeChat))
	self:pushGlobalEventInfo("pasteString",handler(self, self.paste))
	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.onEnterBackground))
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.onEnterForeground))
end

function AlipayNode:initUI()
	local size = self.parent:getContentSize()
	self.size = size

	if self.bType == 4 then
		local url = GameConfig:getWebPay()..PlatformLogic.loginResult.dwUserID
		if device.platform ~= "windows" then
			local webView = ccexp.WebView:create()
			webView:setContentSize(cc.size(1200,535))
			webView:setPosition(self.size.width*0.58+8,self.size.height/2-10)
			webView:setScalesPageToFit(true)
			webView:setScaleX(0.82)
			webView:loadURL(url)
			self:addChild(webView)
			self.webView = webView
			self.webView:hide()
		end
	else
		local icon = ccui.ImageView:create("shop/zhifubao.png")
		icon:setPosition(self.size.width*0.6-13,size.height*0.75)
		self:addChild(icon)

		if self.bType == 2 then
			icon:loadTexture("shop/wechat.png")
		end

		local label = FontConfig.createWithSystemFont("ID:"..PlatformLogic.loginResult.dwUserID,28,cc.c3b(65,97,120))
		label:setPosition(self.size.width*0.6-13,size.height*0.65-10)
		self:addChild(label)

		local node = cc.Node:create()
		node:setPosition(self.size.width*0.4,self.size.height*0.55)
		self:addChild(node)

		self.moneyEditText = createEditBox(node,"请输入金额",cc.EDITBOX_INPUT_MODE_NUMERIC,1)
		self.moneyEditText:onEditHandler(handler(self, self.onMoneyEditBoxHandler))
		
		local btn = ccui.Button:create("shop/qingchu.png","shop/qingchu-on.png")
		btn:setPosition(size.width*0.8,self.size.height*0.55)
		btn:setTag(1)
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)

		self:createMoneyBtn()

		local btn = ccui.Button:create("shop/chongzhitijiao.png","shop/chongzhitijiao-on.png")
		btn:setPosition(size.width*0.6-13,self.size.height*0.15+15)
		btn:setTag(2)
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)

		local info = ccui.ImageView:create("shop/info.png")
		info:setAnchorPoint(0,0.5)
		info:setPosition(30,40)
		self:addChild(info)
	end
end

function AlipayNode:createMoneyBtn()
	local money = {"50.00","100.00","500.00","1000.00","5000.00"}

	local x = 0
	local w = 0
	local y = 0

	for i=1,#money do
		local btn = ccui.Button:create("shop/anniu.png","shop/anniu-on.png")

		if w == 0 then
			w = btn:getContentSize().width
			x = self.size.width*0.25
			y = self.size.height*0.45-10
		end

		btn:setAnchorPoint(0,0.5)
		btn:setPosition(x,y)
		btn:setTag(i)
		btn:setName(money[i])
		self:addChild(btn)
		btn:onClick(function(sender) self:onClickMoneyBtn(sender) end)

		local label = FontConfig.createWithCharMap(money[i],"shop/buyNum.png",19,33,"+")
		label:setPosition(btn:getContentSize().width*0.5, btn:getContentSize().height/2+5)
		btn:addChild(label)

		x = x + w + 10

		if i % 4 == 0 then
			x = self.size.width*0.25
			y = y - btn:getContentSize().height - 15
		end
	end
end

function AlipayNode:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then--清除
		self.moneyEditText:setText("")
	elseif tag == 2 then--充值
		local money = self.moneyEditText:getText()

		if money == nil or money == "" then
			addScrollMessage("请输入充值金额，最低50元")
			return
		end

		money = tonumber(self.moneyEditText:getText())

		if money < 50 then
			addScrollMessage("最低充值金额50元，请重输")
			return
		end

		local pName = "buy"..money.."gold"

		local url = "http://"..GameConfig.payUrl.."/zhifu/index.php"

		if self.bType == 3 then
			url = "http://"..GameConfig.payUrl.."/suie/index.php"
		end
		local str = "userId="..PlatformLogic.loginResult.dwUserID.."&payMoney="..money.."&payType=21&productName="..pName.."&token="..MD5_CTX:MD5String(PlatformLogic.loginResult.szMobileNo)
		openWeb(url.."?"..str)
	end
end

function buyCallback(result, response)
	luaPrint("result ",result)
	luaPrint("response ",response)
end

function AlipayNode:onClickMoneyBtn(sender)
	local money = tonumber(sender:getName())

	if self.moneyEditText:getText() ~= "" then
		money = money + tonumber(self.moneyEditText:getText())
	end

	self.moneyEditText:setText(money)
end

function AlipayNode:onMoneyEditBoxHandler(event)
	local name = event.name

	if name == "began" then
		--todo
	elseif name == "ended" then
		checkNumber(event.target:getText(),event.target)
	elseif name == "return" then
		checkNumber(event.target:getText(),event.target)
	elseif name == "changed" then
		checkNumber(event.target:getText(),event.target)
	end
end

function AlipayNode:refreshWeb(iType)
	if self.bType == 4 then
		if iType == 1 then
			if self.webView == nil and device.platform ~= "windows" then
				local url = GameConfig:getWebPay()..PlatformLogic.loginResult.dwUserID
				local webView = ccexp.WebView:create()
				webView:setContentSize(cc.size(1200,535))
				webView:setPosition(self.size.width*0.58+8,self.size.height/2-10)
				webView:setScalesPageToFit(true)
				webView:setScaleX(0.82)
				webView:loadURL(url)
				self:addChild(webView)
				self.webView = webView
			else
				if self.webView then
					self.webView:show()
				end
			end
			self:onEnterForeground()
		elseif iType == 2 then
			if self.webView then
				self.webView:hide()
				self:onEnterBackground()
			end
		end
	end
end

function AlipayNode:checkBuy()
	pasteFromClipBoard()
end

function AlipayNode:paste(data)
	if self.bType == 4 then
		local data = data._usedata

		if isEmptyString(data) then
			return
		end

		local qianzhui = "coqppayhttp"
		local len = string.len(qianzhui)

		local s = string.sub(data,1,len)

		if s == qianzhui then
			self:stopAllActions()
			s = string.sub(data,len+1, string.len(data))
			if string.len(s) > 0 then
				copyToClipBoard("123")
				openWeb(s)
			end
		end
	end
end

function AlipayNode:onEnterBackground()
	self:stopAllActions()
end

function AlipayNode:onEnterForeground()
	if self.bType == 4 then
		self:onEnterBackground()
		if self.webView then
			-- self.webView:reload()
		end
		schedule(self,handler(self, self.checkBuy),0.3)
	end
end

return AlipayNode
