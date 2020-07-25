-- Des: 封装layer的基类，提供所有的layer基础需求

local BaseLayer = class("BaseLayer", function() return display.newLayer() end)

--[[
@ isMaskLayer		[bool]	透明层
@ touchEnable		[bool]	是否触发touch事件(子类重写onTouchBegan,onTouchMoved,onTouchEnded函数)
@ isSwallow			[bool]	是否吞噬事件，toucheEnable为true时有效
@ isTouchClose		[bool]	是否触摸关闭layer
@ isActionEnter		[bool]	是否开启弹出效果
@ isPreventAddiction[bool]	是否开启防沉迷提示
]]
function BaseLayer:ctor(isMaskLayer, touchEnable, isSwallow, isTouchClose, isActionEnter, isPreventAddiction)
	if touchEnable == nil then--默认关闭
		touchEnable = false
	end

	if isSwallow == nil then--是否吞噬触摸
		isSwallow = true
	end

	self.isTouchClose = isTouchClose
	if isTouchClose == nil then
		self.isTouchClose = false
	end

	if isActionEnter == nil then--默认关闭
		isActionEnter = false
	end

	self.isActionEnter = isActionEnter

	self.isPreventAddiction = isPreventAddiction
	if isPreventAddiction == nil then
		self.isPreventAddiction = false
	end

	--注册layer触摸事件
	self:setLayerTouchEnabled(touchEnable, isSwallow)

	--注册节点事件
	self:setLayerNodeEvent()

	--创建蒙版透明层
	if isMaskLayer == true then
		self:initBackgroundLayer()
	end

	if self.isActionEnter == true then
		self:setScale(0)
	end

	self.bindCustomIds = {}
	self.eventList = {}

	self.globalBindCustomIds = {}
	self.globalEventList = {}
end

--触摸事件
function BaseLayer:setLayerTouchEnabled(enable, isSwallow)
	if enable == true then
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

		self:onTouch(touchCallback,0, isSwallow)
	else
		self:removeTouch()
	end
end

--节点事件
function BaseLayer:setLayerNodeEvent()
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
function BaseLayer:setTouchDelegate(node)
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
		widget:setPosition(node:getPosition())
		widget:setLocalZOrder(node:getLocalZOrder()-1)
		self.widget = widget
		self:addChild(widget)
	end
end

--透明层
function BaseLayer:initBackgroundLayer()
	-- 蒙板
	local winSize = cc.Director:getInstance():getWinSize()
	self.colorLayer = display.newLayer(cc.c4f(0, 0, 0, 255))
	self.colorLayer:setOpacity(100)
	self:addChild(self.colorLayer)
end

--修改透明度
function BaseLayer:updateLayerOpacity(opacity)
	if self.colorLayer then
		self.colorLayer:setOpacity(opacity)
	end
end

--显示透明层
function BaseLayer:showMaskLayer()
	if self.colorLayer then
		self.colorLayer:show()
	end
end

--隐藏透明层
function BaseLayer:hideMaskLayer()
	if self.colorLayer then
		self.colorLayer:hide()
	end
end

--加入事件信息
--target 触发事件的对象
--eventName 事件名
--func 处理函数
function BaseLayer:pushEventInfo(target,eventName,func)
	local item = {target,eventName,func}

	self.eventList[#self.eventList+1] = item
end

function BaseLayer:pushGlobalEventInfo(eventName,func)
	local item = {eventName,func}

	self.globalEventList[#self.globalEventList+1] = item
end

--节点系列事件处理
function BaseLayer:onEnter()
	-- luaPrint("BaseLayer:onEnter ...");

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

function BaseLayer:onEnterTransitionFinish()
	-- luaPrint("BaseLayer:onEnterTransitionFinish ...");
	iphoneXFit(self.bg)
	if self.isActionEnter == true then
		transition.scaleTo(self, {scale=1.0, time=0.5, easing="BACKOUT"})
	end
end

function BaseLayer:onExit()
	-- luaPrint("BaseLayer:onExit ...");
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("hall/fanhui.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("hall/fanhui-on.png")
	--注销事件
	for _, bindid in ipairs(self.bindCustomIds) do
		unbindEvent(bindid)
	end

	for _, bindid in ipairs(self.globalBindCustomIds) do
		unbindEvent(bindid)
	end
end

function BaseLayer:onExitTransitionStart()
	-- luaPrint("BaseLayer:onExitTransitionStart ...");
end

function BaseLayer:onCleanup()
	-- luaPrint("BaseLayer:onCleanup ...");
end

--触摸系列事件处理
function BaseLayer:onTouchBegan(touch, event)
	-- luaPrint("BaseLayer:touch began")
	return true;
end

function BaseLayer:onTouchMoved(touch, event)
	-- luaPrint("BaseLayer:touch move")
end

function BaseLayer:onTouchEnded(touch, event)
	-- luaPrint("BaseLayer:touch end")
end

function BaseLayer:onTouchCancelled(touch, event)
	-- luaPrint("BaseLayer:touch cancel")
end

--关闭layer
function BaseLayer:closeLayer()
	luaPrint("关闭layer ")
	if self.isActionEnter == true then
		transition.scaleTo(self, {scale=0,time=0.5,easing="BACKIN",onComplete= function() if self.closeCallback then self.closeCallback() end self:removeSelf() end})
	else
		if self.closeCallback then
			self.closeCallback()
		end

		self:removeSelf()
	end
end

--延时关闭layer
function BaseLayer:delayCloseLayer(dt,callback)
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

--防沉迷提示
function BaseLayer:preventAddictionGameTips()
	self.addictionTime = 0
	local func = function()
	 	self.addictionTime = self.addictionTime + 1
		local layer = GamePromptLayer:create():showPrompt("您已连续娱乐"..self.addictionTime.."小时，请休息后在娱乐！")

		self:addChild(layer)
	end

	schedule(self,func,60*60)
end

return BaseLayer
