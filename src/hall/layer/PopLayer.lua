-- 弹出框基类 提供背景，关闭按钮确定按钮

local PopLayer = class("PopLayer", function() return display.newLayer() end)

--popType 目前根据背景大小 固定三种 0 最小  1 中型  2大框

PopType = {small = 0, middle = 1, big = 2, none = 3,outType = 4, moreBig = 5}

--isTouchClose 触摸背景区域外是否关闭
function PopLayer:ctor(popType,isTouchClose)
	self.isTouchClose = isTouchClose or false
	self.popType = popType or PopType.small

	--注册layer触摸事件
	self:setLayerTouchEnabled()

	--注册节点事件
	self:setLayerNodeEvent()

	self:initBackgroundLayer()

	self:initBg()

	self.bindCustomIds = {}
	self.eventList = {}

	self.globalBindCustomIds = {}
	self.globalEventList = {}
end

function PopLayer:initBg()
	self:setLocalZOrder(999)

	self:setScale(0)

	if self.popType == PopType.none then
		return
	end

	local bg = ccui.ImageView:create("common/commonBg"..self.popType..".png")
	bg:setPosition(getScreenCenter())
	self:addChild(bg)

	self:setTouchDelegate(bg)

	self.bg = bg

	self.size = bg:getContentSize()

	local closeBtn = ccui.Button:create("common/close.png","common/close-on.png")
	closeBtn:setPosition(self.size.width-48,self.size.height-40)
	bg:addChild(closeBtn)
	self.closeBtn = closeBtn
	closeBtn:onTouchClick(function(sender) self:onClickClose(sender) end,1)

	local sureBtn = ccui.Button:create("common/ok.png","common/ok-on.png")
	sureBtn:setPosition(self.size.width*0.5,self.size.height*0.25)
	bg:addChild(sureBtn)
	self.sureBtn = sureBtn
	sureBtn:onClick(function(sender) self:onClickSure(sender) end)
end

--需重写此函数
function PopLayer:onClickSure(sender)
	-- self:delayCloseLayer()
end

function PopLayer:onClickClose(sender)
	self:delayCloseLayer()
end

--bg换图
function PopLayer:updateBg(image)
	if self.bg then
		self.bg:loadTexture(image)
		self:setBgSize()
	end
end

function PopLayer:setBgSize(size)
	if self.bg then
		if size then
			self.bg:setContentSize(size)
		end

		self.size = self.bg:getContentSize()
		self:setTouchDelegate(self.bg)

		if self.closeBtn ~= nil then
			self.closeBtn:setPosition(self.size.width-6,self.size.height-59)
		end

		if self.sureBtn ~= nil then
			self.sureBtn:setPosition(self.size.width*0.5,self.size.height*0.15)
		end
	end
end

function PopLayer:updateSureBtnPos(y,x)
	if self.sureBtn ~= nil then
		if x then
			self.sureBtn:setPositionX(self.sureBtn:getPositionX() + x)
		end

		if y then
			self.sureBtn:setPositionY(self.sureBtn:getPositionY() + y)
		end
	end
end

function PopLayer:updateSureBtnImage(nImage,pImage)
	if self.sureBtn ~= nil then
		self.sureBtn:loadTextures(nImage,pImage)
	end
end

function PopLayer:updateCloseBtnImage(nImage,pImage)
	if self.closeBtn ~= nil then
		self.closeBtn:loadTextures(nImage,pImage)
	end
end

function PopLayer:updateCloseBtnPos(y,x)
	if self.closeBtn ~= nil then
		if x then
			self.closeBtn:setPositionX(self.closeBtn:getPositionX() + x)
		end

		if y then
			self.closeBtn:setPositionY(self.closeBtn:getPositionY() + y)
		end
	end
end

function PopLayer:removeBtn(iType)
	if iType == 0 then
		if self.sureBtn ~= nil then
			self.sureBtn:removeSelf()
			self.sureBtn = nil
		end
	elseif iType == 1 then
		if self.closeBtn ~= nil then
			self.closeBtn:removeSelf()
			self.closeBtn = nil
		end
	end
end

--触摸事件
function PopLayer:setLayerTouchEnabled()
	local function touchCallback(event)
		local eventType = event.name
		if eventType == "began" then
			if self.isTouchClose == true then
				self:delayCloseLayer()
			end
			return self:onTouchBegan({x = event.x, y = event.y}, event.name)
		elseif eventType == "moved" then
			self:onTouchMoved({x = event.x, y = event.y}, event.name)
		elseif eventType == "ended" then
			self:onTouchEnded({x = event.x, y = event.y}, event.name)
		elseif eventType == "cancel" then
			self:onTouchCancelled({x = event.x, y = event.y}, event.name)
		end
	end

	self:onTouch(touchCallback,0, true)
end

--节点事件
function PopLayer:setLayerNodeEvent()
	self:disableNodeEvents()

	local function onNodeEvent(eventName)
		if "enter" == eventName then
			self:onEnter()
		elseif "exit" == eventName then
			self:onExit()
		elseif "enterTransitionFinish" == eventName then
			self:onEnterTransitionFinish()
		elseif "exitTransitionStart" == eventName then
			self:onExitTransitionStart()
		elseif "cleanup" == eventName then
			self:onCleanup()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	luaPrint("注册 enter exit事件成功")
end

--触摸背景外区域关闭，设置背景触摸事件
function PopLayer:setTouchDelegate(node)
	if node and not tolua.isnull(node) and self.isTouchClose then
		if self.widget then
			self.widget:setContentSize(node:getContentSize())
			return
		end

		local widget = ccui.Widget:create()
		widget:setTouchEnabled(true)
		widget:setSwallowTouches(true)
		widget:setContentSize(node:getContentSize())
		widget:setAnchorPoint(cc.p(0.5,0.5))
		widget:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
		self.widget = widget
		node:addChild(widget)
	end
end

--透明层
function PopLayer:initBackgroundLayer()
	-- 蒙板
	local winSize = cc.Director:getInstance():getWinSize()
	self.colorLayer = display.newLayer(cc.c4f(0, 0, 0, 255))
	self.colorLayer:setOpacity(100)
	self:addChild(self.colorLayer)
end

--加入事件信息
--target 触发事件的对象
--eventName 事件名
--func 处理函数
function PopLayer:pushEventInfo(target,eventName,func)
	local item = {target,eventName,func}

	self.eventList[#self.eventList+1] = item
end

function PopLayer:pushGlobalEventInfo(eventName,func)
	local item = {eventName,func}

	self.globalEventList[#self.globalEventList+1] = item
end

--节点系列事件处理
function PopLayer:onEnter()
	--注册事件，有的话
	self.bindCustomIds = {}
	for k,v in pairs(self.eventList) do
		self.bindCustomIds[#self.bindCustomIds + 1] = bindEvent(v[1], v[2], v[3])
	end

	self.globalBindCustomIds = {}
	for k,v in pairs(self.globalEventList) do
		self.globalBindCustomIds[#self.globalBindCustomIds + 1] = bindGlobalEvent(v[1], v[2])
	end

	if self.isPreventAddiction then
		self:preventAddictionGameTips()
	end
end

function PopLayer:onEnterTransitionFinish()
	iphoneXFit(self.xBg,3)

	-- if self.popType ~= PopType.none then
		transition.scaleTo(self, {scale=1.0, time=0.3, easing="BACKOUT"})
	-- end
end

function PopLayer:onExit()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()

	--注销事件
	for _, bindid in ipairs(self.bindCustomIds) do
		unbindEvent(bindid)
	end

	for _, bindid in ipairs(self.globalBindCustomIds) do
		unbindEvent(bindid)
	end
end

function PopLayer:onExitTransitionStart()

end

function PopLayer:onCleanup()

end

--触摸系列事件处理
function PopLayer:onTouchBegan(touch, event)
	return true;
end

function PopLayer:onTouchMoved(touch, event)

end

function PopLayer:onTouchEnded(touch, event)

end

function PopLayer:onTouchCancelled(touch, event)

end

--关闭layer
function PopLayer:closeLayer()
	luaPrint("关闭layer ")
	-- if self.isActionEnter == true then
	-- if self.popType ~= PopType.none then
		transition.scaleTo(self, {scale=0,time=0.3,easing="BACKIN",onComplete= function() self:removeSelf() if self.closeCallback then self.closeCallback() end end})
	-- end
	-- else
	-- 	self:removeSelf()
	-- 	if self.closeCallback then
	-- 		self.closeCallback()
	-- 	end
	-- end
end

--延时关闭layer
function PopLayer:delayCloseLayer(dt,callback)
	if dt == nil then
		dt = 0.1
	end

	if self.isClose then
		return
	end

	self.isClose = true

	self.closeCallback = callback

	self:stopAllActions()

	if dt <= 0 then
		self:closeLayer()
	else
		performWithDelay(self, function() self:closeLayer() end, dt)
	end
end

return PopLayer
