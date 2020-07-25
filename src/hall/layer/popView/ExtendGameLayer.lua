local ExtendGameLayer = class("ExtendGameLayer",BaseWindow)

function ExtendGameLayer:ctor()
	self.super.ctor(self,true,true,true,true,true)

	self:initUI()
end

function ExtendGameLayer:initUI()
	self:setLocalZOrder(999)
	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0.5,0.5))
	listView:setDirection(ccui.ScrollViewDir.horizontal)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(1055, winSize.height*0.6))
	listView:setPosition(winSize.width*0.5,winSize.height*0.5)
	listView:setScrollBarEnabled(false)
	self:addChild(listView)
	self.listView = listView

	for i=1,5 do
		local layout = self:createItem(i)
		self.listView:pushBackCustomItem(layout)
	end

	self:setTouchDelegate(self.listView)

	local label = FontConfig.createWithSystemFont("点击可选择",28,cc.c3b(255,0,0))
	label:setPosition(winSize.width*0.5,winSize.height*0.2)
	self:addChild(label)
end

function ExtendGameLayer:createItem(tag)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(240, 400))

	local size = layout:getContentSize()

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw");
	-- layout:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

	local big = ccui.ImageView:create("extend/big"..tag..".png")
	big:setPosition(size.width/2,size.height/2)
	big:setScale(0.35)
	layout:addChild(big)

	local path = cc.FileUtils:getInstance():getWritablePath()..PlatformLogic.loginResult.dwUserID..".png"
	if cc.FileUtils:getInstance():isFileExist(path) then
		local qr = ccui.ImageView:create(path)
		qr:setPosition(big:getContentSize().width/2,qr:getContentSize().width/2+80)
		big:addChild(qr)
	end

	local btn = ccui.Widget:create()
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2,size.height/2)
	btn:setContentSize(size)
	btn:setTouchEnabled(true)
	layout:addChild(btn)
	btn:setTag(tag)
	btn:onClick(handler(self, self.onClick))

	return layout
end

function ExtendGameLayer:onClick(sender)
	local tag = sender:getTag()
	cc.UserDefault:getInstance():setIntegerForKey("saveExtend", tag)
	dispatchEvent("saveExtend",tag)

	self:delayCloseLayer()
end

return ExtendGameLayer
