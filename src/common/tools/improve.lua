local ccuiButton = ccui.Button

ccuiButton.onTouchClick = function(self,callback,isPlay,dt)
	-- self:setPressedActionEnabled(true);
	self:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			if sender.isclick == true then
				return false
			end

			if sender.scale == nil then
				sender.scale = sender:getScale()
			end
			sender.dt = dt or 0.5

			sender:setScale(sender.scale + 0.05)

			if isPlay == nil then
				Click()
			elseif isPlay == 1 then
				audio.playSound(GAME_SOUND_CLOSE)
			end
			return true
		elseif eventType == ccui.TouchEventType.ended then
			if sender.isclick == true then
				return false
			end

			sender.isclick = true

			performWithDelay(sender,function() sender.isclick = nil end,sender.dt)
			callback(sender)
			sender:setScale(sender.scale)
		elseif eventType == ccui.TouchEventType.canceled then
			if sender.isclick == true then
				return false
			end
			sender:setScale(sender.scale)
			performWithDelay(sender,function() sender.isclick = nil end,sender.dt)
		end
	end)
end

ccuiButton.onClick = function(self,callback,dt)
	self:onTouchClick(callback,nil,dt)
	-- self:setPressedActionEnabled(true);
	-- self:addClickEventListener(function(sender)
	-- 		if self[tostring(sender)] == true then
	-- 			return
	-- 		end

	-- 		self[tostring(sender)] = true
	-- 		Click()
	-- 		callback(sender)
	-- 		performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5);
	-- end)
end

local ccuiImageView = ccui.ImageView

ccuiImageView.onTouchClick = function(self,callback)
	self:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			if self[tostring(sender)] == true then
				return;
			end

			Click()
			self:setScale(0.9)
		elseif eventType == ccui.TouchEventType.ended then
			if self[tostring(sender)] == true then
				return;
			end
			self[tostring(sender)] = true
			callback(sender)
			performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5)
			self:setScale(1)
		elseif eventType == ccui.TouchEventType.canceled then
			if self[tostring(sender)] == true then
				return;
			end
			performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5)
			self:setScale(1)
		end
	end)
end

ccuiImageView.onClick = function(self,callback)
	self:addClickEventListener(function(sender)
			if self[tostring(sender)] == true then
				return
			end

			self[tostring(sender)] = true
			Click()
			callback(sender)
			performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5)
	end)
end

local ccuiWidget = ccui.Widget

ccuiWidget.onTouchClick = function(self,callback)
	self:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			if self[tostring(sender)] == true then
				return
			end

			Click()
		elseif eventType == ccui.TouchEventType.ended then
			if self[tostring(sender)] == true then
				return
			end
			self[tostring(sender)] = true
			callback(sender)
			performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5);
		elseif eventType == ccui.TouchEventType.canceled then
			if self[tostring(sender)] == true then
				return
			end
			performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5);
		end
	end)
end

ccuiWidget.onClick = function(self,callback)
	self:addClickEventListener(function(sender)
			if self[tostring(sender)] == true then
				return
			end

			self[tostring(sender)] = true
			Click()
			callback(sender)
			performWithDelay(sender,function() self[tostring(sender)] = nil end,0.5);
	end)
end

function Click()
	audio.playSound(GAME_SOUND_BUTTON)
end

local spriteButton = cc.Sprite

spriteButton.onClick = function(self,callback)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		 if event.name == "began" then
			self:setScale(1.05)
			Click()
		elseif event.name == "moved" then
			self:setScale(1.0)
			callback()
		elseif event.name == "ended" then
			self:setScale(1.0)
		end  
		return true
	end)
end

ccui.Helper.seekNodeByName = function (self,node,name)
	if not node then
		return nil
	end

	if node:getName() == name then
		return node
	end

	local children = node:getChildren()
	for i,node in ipairs(children) do
		if node then
			local child = ccui.Helper:seekNodeByName(node,name)

			if child ~= nil then
				return child
			end
		end
	end

	return nil
end
