local SettlementInfoNode = class("SettlementInfoNode",BaseNode)

function SettlementInfoNode:create(parent)
	return SettlementInfoNode.new(parent)
end

function SettlementInfoNode:ctor(parent)
	self.super.ctor(self)

	self.parent = parent
	self.isTixian = 0
	SettlementInfo:sendAcquire();

	self:bindEvent()

	self:initUI()
end

function SettlementInfoNode:bindEvent()
	self:pushEventInfo(SettlementInfo,"settlementCash",handler(self, self.receiveSettlementCash))
	self:pushEventInfo(SettlementInfo,"bindBank",handler(self, self.receiveBindBank))
	self:pushEventInfo(SettlementInfo,"Acquire",handler(self, self.receiveAcquire))--提现需要条件
end

function SettlementInfoNode:initUI()
	local size = self.parent:getContentSize()
	self.size = size

	local h = 80
	local y = size.height*0.85
	local x = size.width*0.45

	--结算金额
	local mobile = ccui.ImageView:create("settlement/jiesuanjiner.png")
	mobile:setAnchorPoint(1,0.5)
	mobile:setPosition(x,y)
	self:addChild(mobile)

	self.moneyTextEdit = createEditBox(mobile,"请输入结算金额",cc.EDITBOX_INPUT_MODE_NUMERIC,1)
	-- self.moneyTextEdit:setText(PlatformLogic.loginResult.szMobileNo)
	self.moneyTextEdit:onEditHandler(handler(self, self.onMoneyEditBoxHandler))

	--收款方式
	local typeImage = ccui.ImageView:create("settlement/shoukuanfangshi.png")
	typeImage:setAnchorPoint(1,0.5)
	typeImage:setPosition(x,y-h)
	self:addChild(typeImage)

	local image = ccui.ImageView:create("input/editBg.png")
	image:setAnchorPoint(0,0.5)
	image:setPosition(typeImage:getContentSize().width+20, typeImage:getContentSize().height/2)
	typeImage:addChild(image)

	local curimage = ccui.ImageView:create("settlement/1.png")
	curimage:setPosition(image:getContentSize().width*0.2, image:getContentSize().height/2)
	image:addChild(curimage)
	self.curTypeImage = curimage

	local label = FontConfig.createWithSystemFont("支付宝",26,cc.c3b(255,255,255))
	label:setAnchorPoint(0,0.5)
	label:setName("text")
	label:setPosition(curimage:getContentSize().width+20, curimage:getContentSize().height/2)
	curimage:addChild(label)

	local btn = ccui.ImageView:create("settlement/xiala.png")
	btn:setAnchorPoint(1,0.5)
	btn:setPosition(image:getContentSize().width,image:getContentSize().height/2)
	image:addChild(btn)
	self.xialaImage = btn

	--列表
	local btn = ccui.Widget:create()
	btn:setPosition(image:getContentSize().width/2, image:getContentSize().height/2)
	btn:setContentSize(image:getContentSize())
	btn:setTouchEnabled(true)
	btn:setTag(1)
	image:addChild(btn)
	btn:onClick(handler(self, self.onClickBtn))
	self.xialaBtn = btn

	--收款账号
	local image = ccui.ImageView:create("settlement/shoukuanzhanghao.png")
	image:setAnchorPoint(1,0.5)
	image:setPosition(x,y-h*2)
	self:addChild(image)

	local label = FontConfig.createWithSystemFont("",26,cc.c3b(255,0,0))
	label:setAnchorPoint(0,0.5)
	label:setPosition(image:getContentSize().width+20, image:getContentSize().height/2)
	image:addChild(label)
	self.shouKuanLabel = label

	--提现标准
	local image = ccui.ImageView:create("settlement/tixianbiaozhun.png")
	image:setAnchorPoint(1,0.5)
	image:setPosition(x,y-h*3)
	self:addChild(image) 

	--问号
	local helpButton = ccui.Button:create("settlement/shuoming.png","settlement/shuoming-on.png");
	helpButton:setPosition(-20,15);
	helpButton:setAnchorPoint(1,0.5)
	image:addChild(helpButton);
	helpButton:onClick(function(sender) self:helpButtonClick(sender) end);

	local label = FontConfig.createWithSystemFont("",26,cc.c3b(44,163,28))
	label:setAnchorPoint(0,0.5)
	label:setPosition(image:getContentSize().width+20, image:getContentSize().height/2)
	image:addChild(label)
	self.biaozhunLabel = label

	local sureBtn = ccui.Button:create("common/ok.png","common/ok-on.png")
	sureBtn:setPosition(size.width*0.6,size.height*0.15-15)
	self:addChild(sureBtn)
	sureBtn:setEnabled(false);
	sureBtn:onClick(function(sender) self:onClickSure(sender) end)
	self.sureBtn = sureBtn;

	local textStr = "提示：结算5分钟内到账，若未到账的玩家，请及时与客服取得联系！结算下限为\n"..(SettlementInfo:getConfigInfoByID(34)/100).."元，结算金额必须为"..(SettlementInfo:getConfigInfoByID(36)/100).."的整倍数，手续费为结算金额的"..(SettlementInfo:getConfigInfoByID(37)/10).."%"
	local label = FontConfig.createWithSystemFont(textStr,26,cc.c3b(255,255,255))
	label:setAnchorPoint(0,0.5)
	label:setPosition(40, -40)
	self:addChild(label)
	self.labelTip = label;

	--有效支持列表
	self.validList = {} --1支付宝,2银行卡,3微信
	table.insert(self.validList,(SettlementInfo:getConfigInfoByID(42) == 1 and self.isTixian == 1));	--支付宝
	table.insert(self.validList,SettlementInfo:getConfigInfoByID(43) == 1);	--银行卡
	table.insert(self.validList,false); --微信

	self.show_order = {2,1,3} --展示顺序 1.支付宝 2.银行卡 3.微信
	-- self.validList = {alipay = false,bank = true,wechat = false} 
	--没有有效渠道 隐藏
	self.xialaBtn:setVisible(false);
	self.curTypeImage:setVisible(false);
	self.xialaImage:setVisible(false);
	self.labelTip:setVisible(false);
	for key,v in ipairs(self.show_order) do
		local i = v
		if self.validList[i] then
			self:updateAccount(i)
			self:showDropDownListBox()
			self:onClicklistBoxBtn(self.dropDownListBoxBtn:getChildByTag(i));

			self.xialaBtn:setVisible(true);
			self.curTypeImage:setVisible(true);
			self.xialaImage:setVisible(true);
			self.labelTip:setVisible(true);
			break;
		end
	end
end

function SettlementInfoNode:helpButtonClick(sender)
	local prompt = GamePromptLayer:create();
    prompt:showPrompt("若未充值过，不计算提现所需流水，充值后开始计算提现流水。\n提现时需计算流水是否满足提现要求，如未满足则会提示缺少的流水值，满足后方可提现。");
    prompt.textPrompt:setFontSize(30);
end

function SettlementInfoNode:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then
		self:showDropDownListBox()
	end
end

function SettlementInfoNode:onClickSure(sender)
	if self.isClick then
		addScrollMessage("正在提交，请稍后操作")
		return
	end

	if self.cashType == nil then
		addScrollMessage("无法提现")
		return;
	end

	local money = self.moneyTextEdit:getText()

	if money == "" then
		money = 0
	end

	money = tonumber(money)

	if self.cashType == 1 then--支付宝
		if PlatformLogic.loginResult.Alipay == "" then
			addScrollMessage("未绑定支付宝账号")
			return
		end

		if money < SettlementInfo:getConfigInfoByID(34)/100 then
			addScrollMessage("当前接口提现不能小于"..(SettlementInfo:getConfigInfoByID(34)/100))
			return
		end

		if PlatformLogic.loginResult.i64Money < SettlementInfo:getConfigInfoByID(34) then
			addScrollMessage("账户余额不足，除提现金额外还需扣除手续费")
			return
		end

		-- if money % (SettlementInfo:getConfigInfoByID(36)/100) ~= 0 then
		-- 	addScrollMessage("结算必须为"..(SettlementInfo:getConfigInfoByID(36)/100).."的整倍数")
		-- 	return
		-- end
	elseif self.cashType == 2 then---银行卡
		if PlatformLogic.loginResult.BankNo == "" then
			addScrollMessage("未绑定银行卡")
			return
		end

		if money < SettlementInfo:getConfigInfoByID(35)/100 then
			addScrollMessage("当前接口提现不能小于"..(SettlementInfo:getConfigInfoByID(35)/100))
			return
		end

		if PlatformLogic.loginResult.i64Money < SettlementInfo:getConfigInfoByID(35) then
			addScrollMessage("账户余额不足，除提现金额外还需扣除手续费")
			return
		end

		-- if money % (SettlementInfo:getConfigInfoByID(36)/100) ~= 0 then
		-- 	addScrollMessage("结算必须为"..(SettlementInfo:getConfigInfoByID(36)/100).."的整倍数")
		-- 	return
		-- end
	elseif self.cashType == 3 then--微信
		addScrollMessage("微信暂不支持")
		return
	end

	self.isClick = true

	SettlementInfo:sendSettlementCashRequest(self.cashType,money)

	self.action = performWithDelay(self,function() self.isClick = true self.action = nil end,3)
end

function SettlementInfoNode:showDropDownListBox()
	if self.dropDownListBoxBtn == nil then
		local btn = ccui.Widget:create()
		btn:setAnchorPoint(cc.p(0.5,1))
		btn:setPosition(self.size.width*0.65+5,self.size.height*0.8-65)
		btn:setCascadeOpacityEnabled(true)
		btn:setTouchEnabled(true)
		btn:setSwallowTouches(true)
		self:addChild(btn)
		self.dropDownListBoxBtn = btn

		local width = 0
		local height = 0
		local x = 0
		local y = 0

		local text = {"支付宝","银行卡","微信  (暂不支持)"}
		for key,value in pairs (self.show_order) do
			local i = value
			if self.validList[i] then
				local btn = ccui.Button:create("settlement/xialakuang.png","settlement/xialakuang.png")
				if x == 0 then
					height = btn:getContentSize().height
					width = btn:getContentSize().width

					self.dropDownListBoxBtn:setContentSize(cc.size(width,height*3))
					self.dropDownListBoxBtn:setPositionY(self.dropDownListBoxBtn:getPositionY()-height)

					x = width/2
					y = height*3
				end

				btn:setPosition(x,y);
				btn:setAnchorPoint(0.5,1);
				btn:setTag(i)
				btn:setName(text[i])
				self.dropDownListBoxBtn:addChild(btn);
				btn:addClickEventListener(function(sender) self:onClicklistBoxBtn(sender) end)

				local curimage = ccui.ImageView:create("settlement/"..i..".png")
				curimage:setPosition(btn:getContentSize().width*0.15+12, btn:getContentSize().height/2)
				btn:addChild(curimage)

				local label = FontConfig.createWithSystemFont(text[i],26,cc.c3b(255,255,255))
				label:setAnchorPoint(0,0.5)
				label:setName("text")
				label:setPosition(curimage:getContentSize().width+20+12, curimage:getContentSize().height/2)
				curimage:addChild(label)

				y = y - height
			end
		end
		self.dropDownListBoxBtn:setScaleY(0)
	else
		if not self.dropDownListBoxBtn:isVisible() then
			self.dropDownListBoxBtn:setScaleY(0)
		end
		self.dropDownListBoxBtn:setVisible(not self.dropDownListBoxBtn:isVisible())
	end

	if self.xialaImage:getScaleY() == 1 then
		self.xialaImage:setScaleY(-1)
	else
		self.xialaImage:setScaleY(1)
	end

	if self.dropDownListBoxBtn:isVisible() then
		self.xialaBtn:setTouchEnabled(false)
		self.dropDownListBoxBtn:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1, 1, 1),cc.CallFunc:create(function() self.xialaBtn:setTouchEnabled(true) end)))
	end
end

function SettlementInfoNode:onClicklistBoxBtn(sender)
	self.curTypeImage:loadTexture("settlement/"..sender:getTag()..".png")
	self.curTypeImage:getChildByName("text"):setString(sender:getName())
	if self.xialaImage:getScaleY() == 1 then
		self.xialaImage:setScaleY(-1)
	else
		self.xialaImage:setScaleY(1)
	end
	self.dropDownListBoxBtn:setVisible(not self.dropDownListBoxBtn:isVisible())
	self:updateAccount(sender:getTag())

	if sender:getTag() == 3 then
		addScrollMessage("微信暂不支持")
	end
	local textStr = ""
	if sender:getTag() == 1 then
		textStr= "提示：结算5-10分钟内到账，若未到账的玩家，请及时与客服取得联系！结算下限为\n"..(SettlementInfo:getConfigInfoByID(34)/100).."元，结算上限为"..(SettlementInfo:getConfigInfoByID(74)/100).."元，结算金额必须为"..(SettlementInfo:getConfigInfoByID(36)/100).."的整倍数，手续费为结算金额的"..(SettlementInfo:getConfigInfoByID(37)/10).."%"
	elseif sender:getTag() == 2 then
		textStr= "提示：结算5-10分钟内到账，若未到账的玩家，请及时与客服取得联系！结算下限为\n"..(SettlementInfo:getConfigInfoByID(35)/100).."元，结算上限为"..(SettlementInfo:getConfigInfoByID(73)/100).."元，结算金额必须为"..(SettlementInfo:getConfigInfoByID(36)/100).."的整倍数，手续费为结算金额的"..(SettlementInfo:getConfigInfoByID(37)/10).."%"
	end
	self.labelTip:setString(textStr)
end

function SettlementInfoNode:updateAccount(tag)
	local label = self.shouKuanLabel
	if tag == 1 then
		if PlatformLogic.loginResult.Alipay == "" then
			label:setString("支付宝账号：未绑定")
		else
			label:setString("支付宝账号："..PlatformLogic.loginResult.Alipay)
		end
	elseif tag == 2 then
		if PlatformLogic.loginResult.BankNo == "" then
			label:setString("银行卡账号：未绑定")
		else
			label:setString("银行卡账号："..PlatformLogic.loginResult.BankNo)
		end
	elseif tag == 3 then
		label:setString("微信  (暂不支持)")
	elseif tag == 4 then
		label:setString("流水不足")
	end

	self.cashType = tag
end

function SettlementInfoNode:receiveSettlementCash(data)
	local data = data._usedata

	if data.ret == 0 then
		addScrollMessage("提现请求提交成功")
		dispatchEvent("refreshScoreBank")
		MailInfo:sendMailListInfoRequest()
	elseif data.ret == 1 then
		addScrollMessage("支付宝未绑定")
	elseif data.ret == 2 then
		addScrollMessage("银行卡未绑定")
	elseif data.ret == 3 then
		addScrollMessage("提现到支付宝低于最低金额")--至少"..(SettlementInfo:getConfigInfoByID(34)/100).."金币")
	elseif data.ret == 4 then
		addScrollMessage("提现到银行卡低于最低金额")--至少"..(SettlementInfo:getConfigInfoByID(35)/100).."金币")
	elseif data.ret == 5 then
		addScrollMessage("提现金币必须是"..(SettlementInfo:getConfigInfoByID(36)/100).."倍数")
	elseif data.ret == 6 then
		addScrollMessage("钱包金币不足")
	elseif data.ret == 7 then
		addScrollMessage("正在游戏中，请稍后再试")
	elseif data.ret == 9 then
		addScrollMessage("您有一笔兑换目前还在处理中，请处理完毕后在次提交")
	elseif data.ret == 15 then
		addScrollMessage("提现到银行卡高于最高金额")
	elseif data.ret == 16 then
		addScrollMessage("提现到支付宝高于最高金额")
	else
		addScrollMessage("提现请求提交失败")
	end

	self.isClick = nil

	if self.action then
		self:stopAction(self.action)
		self.action = nil
	end
end

function SettlementInfoNode:onMoneyEditBoxHandler(event)
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

function SettlementInfoNode:receiveBindBank(data)
	local data = data._usedata

	if self.cashType == data.bType then
		self:updateAccount(self.cashType)
	end
end

function SettlementInfoNode:receiveAcquire(data)
	local data = data._usedata
	luaDump(data,"条件");
	local score = data.lScore;

	if data.nTixian ~= nil then
		self.validList = {}
		self.isTixian = data.nTixian
		self.dropDownListBoxBtn = nil
		self:removeAllChildren()
		self:initUI()
	end

	if score <= 0 then
		self.biaozhunLabel:setString("可进行提现");
		self.biaozhunLabel:setColor(cc.c3b(44,163,28));
		self.sureBtn:setEnabled(true);
	else
		self.biaozhunLabel:setString("不可提现(还差"..goldConvert(score).."元有效投注)");
		self.biaozhunLabel:setColor(cc.c3b(255,0,0));
		self.sureBtn:setEnabled(false);
	end
end

return SettlementInfoNode
