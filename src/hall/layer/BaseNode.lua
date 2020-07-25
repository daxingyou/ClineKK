local BaseNode = class("BaseNode", function() return display.newNode(); end)

function BaseNode:ctor()
	self.bindCustomIds = {}
	self.eventList = {}

	self.globalBindCustomIds = {}
	self.globalEventList = {}

	self:setNodeEventEnabled()
end

function BaseNode:setNodeEventEnabled(isEnabled)
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
end

--加入事件信息
--target 触发事件的对象
--eventName 事件名
--func 处理函数
function BaseNode:pushEventInfo(target,eventName,func)
	local item = {target,eventName,func}

	self.eventList[#self.eventList+1] = item
end

function BaseNode:pushGlobalEventInfo(eventName,func)
	local item = {eventName,func}

	self.globalEventList[#self.globalEventList+1] = item
end

--节点系列事件处理
function BaseNode:onEnter()
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

function BaseNode:onEnterTransitionFinish()
	if self.isActionEnter == true then
		transition.scaleTo(self, {scale=1.0, time=0.5, easing="BACKOUT"})
	end
end

function BaseNode:onExit()
	--注销事件
	for _, bindid in ipairs(self.bindCustomIds) do
		luaPrint(tostring(bindid))
		unbindEvent(bindid)
	end

	for _, bindid in ipairs(self.globalBindCustomIds) do
		unbindEvent(bindid)
	end
end

function BaseNode:onExitTransitionStart()
	-- luaPrint("BaseNode:onExitTransitionStart ...");
end

function BaseNode:onCleanup()
	-- luaPrint("BaseNode:onCleanup ...");
end

function BaseNode:close()
	self:removeSelf()
end

return BaseNode

