local ShopWeChatNode = class("ShopWeChatNode", PopLayer)

function ShopWeChatNode:create(parent,layer)
	return ShopWeChatNode.new(parent,layer)
end

function ShopWeChatNode:ctor(parent,layer)
	self.super.ctor(self,PopType.middle)

	self.parent = parent
	self.shopLayer = layer

	self:bindEvent()

	self:initUI()
end

function ShopWeChatNode:bindEvent()
	self:pushEventInfo(SettlementInfo,"weChat",handler(self, self.receiveWeChat))
end

function ShopWeChatNode:initUI()
	self:removeBtn(0)
	-- local size = self.parent:getContentSize()
	-- self.size = size
	local size = self.size

	local title = ccui.ImageView:create("common/wechatTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local btn = ccui.Button:create("shop/jubaoyoujiang.png","shop/jubaoyoujiang-on.png")
	btn:setPosition(size.width*0.2,150)
	btn:setTag(1)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	local btn = ccui.Button:create("shop/shuaxin.png","shop/shuaxin-on.png")
	btn:setPosition(size.width*0.45,150)
	btn:setTag(2)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	local image = ccui.ImageView:create("shop/idkuang.png")
	image:setPosition(size.width*0.75,150)
	self.bg:addChild(image)

	local label = FontConfig.createWithSystemFont("我的ID\n"..PlatformLogic.loginResult.dwUserID,26,cc.c3b(22,48,132))
	label:setAnchorPoint(0,0.5)
	label:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setPosition(image:getContentSize().width*0.1, image:getContentSize().height/2)
	image:addChild(label)

	local btn = ccui.Button:create("shop/fuzhi.png","shop/fuzhi-on.png")
	btn:setAnchorPoint(1,0.5)
	btn:setPosition(image:getContentSize().width*0.95, image:getContentSize().height/2)
	btn:setTag(3)
	image:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	local info = ccui.ImageView:create("shop/wechatInfo.png")
	info:setAnchorPoint(0,0.5)
	info:setPosition(30,50)
	self.bg:addChild(info)

	self:refreshWeChat()
end

function ShopWeChatNode:refreshWeChat()
	SettlementInfo:sendWeChatRequest()

	LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求配置,请稍后"), LOADING):removeTimer()
end

function ShopWeChatNode:receiveWeChat(data)
	local data = data._usedata

	local ret = false
	local count = 0
	local temp = {}

	for k,v in pairs(data) do
		if not isEmptyString(v.WeChat) then
			ret = true
			count = count + 1
			table.insert(temp,v)
		end
	end

	if not ret then
		LoadingLayer:removeLoading()
		return
	end

	if self.listView == nil then
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0.5,0.5))
		listView:setDirection(ccui.ScrollViewDir.vertical)
		listView:setBounceEnabled(true)
		listView:setContentSize(cc.size(self.size.width*0.9, self.size.height*0.5))
		listView:setPosition(self.size.width*0.5,self.size.height*0.58)
		self.bg:addChild(listView)
		self.listView = listView
	else
		self.listView:removeAllChildren()
	end

	local count = math.ceil(count/2)

	for i=0, count-1 do
		local layout = self:createItem(i,temp)
		self.listView:pushBackCustomItem(layout)
	end

	LoadingLayer:removeLoading()
end

function ShopWeChatNode:createItem(groupId,data)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(self.listView:getContentSize().width, 110))

	local size = layout:getContentSize()

	local tag = groupId * 2 +1

	if tag <= #data then
		local btn = self:createWechat(tag,data)
		btn:setPosition(size.width/2-5-btn:getContentSize().width/2,size.height/2)
		layout:addChild(btn)
	end

	tag = tag  +1

	if tag <= #data then
		local btn = self:createWechat(tag,data)
		btn:setPosition(size.width/2+5+btn:getContentSize().width/2,size.height/2)
		layout:addChild(btn)
	end

	return layout
end

function ShopWeChatNode:createWechat(tag,data)
	local btn = ccui.Button:create("shop/wechatkuang.png","shop/wechatkuang.png")
	btn:setTag(tag)
	btn:setName(data[tag].WeChat)
	btn:onClick(function(sender) self:onClickWeChat(sender) end)

	local size = btn:getContentSize()

	local icon = ccui.ImageView:create("shop/weixinicon.png")
	icon:setPosition(size.width*0.1,size.height/2)
	btn:addChild(icon)

	local label = FontConfig.createWithSystemFont("代理充值",26,cc.c3b(255,0,0))
	label:setAnchorPoint(0,0.5)
	label:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setPosition(size.width*0.2, size.height/2+15)
	btn:addChild(label)

	local label = FontConfig.createWithSystemFont(data[tag].WeChat,26,cc.c3b(73,39,39))
	label:setAnchorPoint(0,0.5)
	label:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setPosition(size.width*0.2, size.height/2-15)
	btn:addChild(label)

	local image = ccui.ImageView:create("shop/chongzhi.png")
	image:setPosition(size.width*0.75,size.height/2)
	btn:addChild(image)

	return btn
end

function ShopWeChatNode:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then--举报有奖
		self.shopLayer:addChild(require("layer.popView.ReportLayer"):create())
	elseif tag == 2 then--刷新
		self:refreshWeChat()
	elseif tag == 3 then--复制
		if copyToClipBoard(PlatformLogic.loginResult.dwUserID) then
			addScrollMessage("账号ID复制成功")
		end
	end
end

function ShopWeChatNode:onClickWeChat(sender)
	self.shopLayer:addChild(require("layer.popView.WeChatLayer"):create(sender:getName()))
end

return ShopWeChatNode
