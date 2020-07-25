local SettlementLayer = class("SettlementLayer",PopLayer)

function SettlementLayer:create(showType)
	return SettlementLayer.new(showType)
end

function SettlementLayer:ctor(showType)
	playEffect("hall/sound/tixian.mp3")
	self.super.ctor(self,PopType.middle)

	if showType == nil then
		showType = 0
	end
	self:setName("SettlementLayer")

	self.showType = showType

	self:initData()

	self:initUI()

	self:bindEvent()
end

function SettlementLayer:initData()
	self.bankBtns = {}
	self.bankNodes = {}
end

function SettlementLayer:bindEvent()
	self:pushEventInfo(SettlementInfo,"bindBank",handler(self, self.receiveBindBank))
end

function SettlementLayer:initUI()
	self.sureBtn:removeSelf()

	--有效支持列表
	self.validList = {} --1支付宝,2银行卡
	self.validList["bank"] = SettlementInfo:getConfigInfoByID(43) == 1;
	self.validList["alipay"] = SettlementInfo:getConfigInfoByID(42) == 1;
	luaDump(self.validList, "valid_tixian", 4)
	-- self.validList = {bank = true,alipay = false,wechat = false} --银行卡,支付宝,微信

	local title = ccui.ImageView:create("common/settlementTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	if self.showType == 1 then
		title:loadTexture("common/bangdingTitle.png")
	end

	local bg = ccui.ImageView:create("common/smallBg.png")
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.bg:addChild(bg)

	local size = bg:getContentSize()

	--cebian
	bg:setCascadeOpacityEnabled(false);
	bg:setOpacity(0);
	local cebianBg = ccui.ImageView:create("settlement/cebian.png")
	cebianBg:setPosition(cc.p(127,230))
	bg:addChild(cebianBg);
	cebianBg:setVisible(false);


	local x = 123
	local h = 120
	local y = 378
	local tag = 1

	--结算
	if self.showType ~= 1 then
		local btn = ccui.Button:create("settlement/jiesuan.png","settlement/jiesuan-on.png","settlement/jiesuan-dis.png")
		btn:setPosition(x,y)
		btn:setTag(tag)
		bg:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
		btn:setEnabled(false)
		table.insert(self.bankBtns,btn)
		tag = tag + 1
	else
		y = y + h
	end

	--支付宝
	local btn = ccui.Button:create("settlement/bangdingzhifubao.png","settlement/bangdingzhifubao-on.png","settlement/bangdingzhifubao-dis.png")
	btn:setPosition(x,y-h)
	btn:setTag(tag)
	bg:addChild(btn)
	btn:setVisible(self.validList.alipay);
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	table.insert(self.bankBtns,btn)

	if self.showType == 1 then
		btn:setEnabled(false)
	end

	tag = tag + 1

	--银行卡
	local btn = ccui.Button:create("settlement/bangdingyinhangka.png","settlement/bangdingyinhangka-on.png","settlement/bangdingyinhangka-dis.png")
	btn:setPosition(x,y-h*self:getValidBankBtnCount())
	btn:setTag(tag)
	bg:addChild(btn)
	btn:setVisible(self.validList.bank);
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	--提现记录
	local btn = ccui.Button:create("settlement/depositrecordbtn.png","settlement/depositrecordbtn.png","settlement/depositrecordbtn.png")
	btn:setPosition(900,495)
	bg:addChild(btn)
	btn:setScale(1.2)
	-- btn:setVisible(false);
	btn:onClick(function(sender) self:onClickDepositRecordBtn(sender) end)
	table.insert(self.bankBtns,btn)

	local info = ccui.ImageView:create("settlement/info1.png")
	info:setAnchorPoint(0,0.5)
	info:setPosition(120,75)
	self.bg:addChild(info)
	self.info = info
	self.info:setVisible(false)

	if self.showType ~= 1 then
		local node = require("layer.popView.SettlementInfoNode"):create(bg)
		bg:addChild(node)
		table.insert(self.bankNodes,node)
	else
		info:loadTexture("settlement/info2.png")
	end

	info.oldx = info:getPositionX()
	info.oldy = info:getPositionY()

	local node = require("layer.popView.BindBankNode"):create(bg,1)
	node:setVisible(self.showType == 1)
	bg:addChild(node)
	table.insert(self.bankNodes,node)

	local node = require("layer.popView.BindBankNode"):create(bg,2)
	node:hide()
	bg:addChild(node)
	table.insert(self.bankNodes,node)

end

function SettlementLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if self.showType ~= 1 and tag == 1 then
		SettlementInfo:sendAcquire();
	end

	self:selectBankOperation(tag)

	if self.info then
		if self.showType == 1 then
			tag = tag + 1
		end
		if tag ~= 1 then
			self.info:setVisible(true)
			self.info:loadTexture("settlement/info"..tag..".png");
			if tag == 2 then
				self.info:setPosition(self.info.oldx-70,self.info.oldy)
				self.info:setScale(0.8)
			else
				self.info:setPosition(self.info.oldx,self.info.oldy)
				self.info:setScale(1)
			end
		else
			self.info:setVisible(false)
		end
	end
end

function SettlementLayer:onClickDepositRecordBtn(sender)
	local GetCashRecordLayer = require("layer.popView.GetCashRecordLayer");
	local Layer = GetCashRecordLayer:create(1);
	Layer:ignoreAnchorPointForPosition(false);
	Layer:setAnchorPoint(cc.p(0.5,0.5));
	
	local size = display.getRunningScene():getContentSize();
	Layer:setPosition(size.width/2,size.height/2);
	display.getRunningScene():addChild(Layer,9999);
end

function SettlementLayer:selectBankOperation(tag)
	for k,v in pairs(self.bankBtns) do
		v:setEnabled(k~=tag)
	end

	for k,v in pairs(self.bankNodes) do
		if k == tag then
			v:show()
		else
			v:hide()
		end
	end
end

function SettlementLayer:receiveBindBank(data)
	local data = data._usedata

	if self.showType == 1 and data.ret == 0 then
		local str = "支付宝"

		if data.bType == 2 then
			str = "银行卡"
		end

		str = "绑定"..str.."成功！您可点击按钮前去充值。"

		local layer = GameMessageLayer:create("common/wenxintishi.png",str,"hall/quchongzhi")
		if PlatformLogic.loginResult.Alipay == "" or PlatformLogic.loginResult.BankNo == "" then
			layer = GameMessageLayer:create("common/wenxintishi.png",str,"hall/jixubangding","hall/quchongzhi")
			layer:setBtnClickCallBack(function() end,function() self:delayCloseLayer() showShop() end)
		else
			layer:setBtnClickCallBack(function() self:delayCloseLayer() showShop() end)
		end
		display.getRunningScene():addChild(layer,9999999)
	end
end

--获取显示的侧边导航按钮
function SettlementLayer:getValidBankBtnCount()
	local count = 0;
	for i,v in ipairs(self.bankBtns) do
		if v:isVisible() then
			count = count + 1;
		end
	end

	return count;
end

function SettlementLayer:onClickClose(sender)
	dispatchEvent("registerLayerUpCallBack");
	self:delayCloseLayer()
end

return SettlementLayer
