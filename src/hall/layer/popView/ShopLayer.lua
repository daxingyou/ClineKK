local ShopLayer = class("ShopLayer",PopLayer)

function ShopLayer:ctor()
	self.super.ctor(self)

	self:initData()

	self:initUI()
end

function ShopLayer:initData()
	self.bankBtns = {}
	self.bankNodes = {}
end

function ShopLayer:initUI()
	self.sureBtn:removeSelf()
	self:setName("shopLayer")

	local title = ccui.ImageView:create("common/shopTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local bg = self.bg

	-- local bg = ccui.ImageView:create("common/smallBg.png")
	-- bg:setAnchorPoint(cc.p(0.5,0.5))
	-- bg:setPosition(cc.p(self.size.width/2,self.size.height/2))
	-- self.bg:addChild(bg)

	local size = bg:getContentSize()

	local x = self.size.width*0.1-5
	local h = 100
	local y = self.size.height/2

	--代理充值
	local btn = ccui.Button:create("shop/dailichongzhi.png","shop/dailichongzhi-on.png")
	btn:setPosition(self.size.width/2-btn:getContentSize().width*0.6,y)
	btn:setTag(1)
	bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	-- btn:setEnabled(false)
	table.insert(self.bankBtns,btn)

	-- if not showAccountUpgrade(false) then
		--支付宝
		local btn = ccui.Button:create("shop/zaixianchongzhi.png","shop/zaixianchongzhi-on.png")
		btn:setPosition(self.size.width/2+btn:getContentSize().width*0.6-15,y)
		btn:setTag(2)
		bg:addChild(btn)
		btn:onClick(function(sender) self:onClickBtn(sender) end)
		table.insert(self.bankBtns,btn)

		-- local btn = ccui.Button:create("shop/zhifubaochongzhi2.png","shop/zhifubaochongzhi2-on.png","shop/zhifubaochongzhi2-dis.png")
		-- btn:setPosition(x,size.height*0.8-h*2)
		-- btn:setTag(3)
		-- bg:addChild(btn)
		-- btn:onClick(function(sender) self:onClickBtn(sender) end)
		-- table.insert(self.bankBtns,btn)

		--微信
		-- local btn = ccui.Button:create("shop/weixinchongzhi.png","shop/weixinchongzhi-on.png","shop/weixinchongzhi-dis.png")
		-- btn:setPosition(x,size.height*0.8-h*2)
		-- btn:setTag(3)
		-- bg:addChild(btn)
		-- btn:onClick(function(sender) self:onClickBtn(sender) end)
		-- table.insert(self.bankBtns,btn)
	-- end

	-- local node = require("layer.popView.ShopWeChatNode"):create(bg,self)
	-- bg:addChild(node)
	-- node:setPositionX(-10)
	-- table.insert(self.bankNodes,node)

	-- if not showAccountUpgrade(false) then
		-- local node = require("layer.popView.AlipayNode"):create(bg,3)
		-- node:hide()
		-- bg:addChild(node)
		-- table.insert(self.bankNodes,node)

		-- local node = require("layer.popView.AlipayNode"):create(bg,4)
		-- node:hide()
		-- bg:addChild(node)
		-- table.insert(self.bankNodes,node)

		-- local node = require("layer.popView.BindBankNode"):create(bg,2)
		-- node:hide()
		-- bg:addChild(node)
		-- table.insert(self.bankNodes,node)
	-- end

	local info = ccui.ImageView:create("shop/newInfo.png")
	info:setAnchorPoint(0,0.5)
	info:setPosition(30,40)
	bg:addChild(info)
end

function ShopLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then
		self:addChild(require("layer.popView.ShopWeChatNode"):create(self,self))
	elseif tag == 2 then
		openWeb(GameConfig:getWebPay()..PlatformLogic.loginResult.dwUserID)
	end

	-- self:selectBankOperation(tag)
end

function ShopLayer:selectBankOperation(tag)
	for k,v in pairs(self.bankBtns) do
		v:setEnabled(k~=tag)
	end

	for k,v in pairs(self.bankNodes) do
		if k == tag then
			v:show()
			if k == 1 then
				v:refreshWeChat()
			elseif k == 2 then
				v:refreshWeb(1)
			end
		else
			v:hide()
			if k == 2 then
				v:refreshWeb(2)
			end
		end
	end
end

return ShopLayer
