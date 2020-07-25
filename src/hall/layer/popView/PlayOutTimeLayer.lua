local PlayOutTimeLayer = class("PlayOutTimeLayer", PopLayer)

function PlayOutTimeLayer:ctor()
	self.super.ctor(self,PopType.outType)

	self:initUI()

	self:bindEvent()
end

function PlayOutTimeLayer:bindEvent()
	self:pushGlobalEventInfo("closeOutTime",handler(self,self.closeLayer))
end

function PlayOutTimeLayer:initUI()
	local title = ccui.ImageView:create("common/wenxintishi.png")
	title:setPosition(self.size.width/2,self.size.height-40)
	self.bg:addChild(title)

	if globalUnit.isEnterGame == true then
		self:updateSureBtnImage("tryPlay/buy.png","tryPlay/buy-on.png")
		local image = ccui.ImageView:create("tryPlay/buyText.png")
		image:setPosition(self.sureBtn:getContentSize().width/2,self.sureBtn:getContentSize().height/2+5)
		image:setAnchorPoint(0,0.5)
		self.sureBtn:addChild(image)

		local tm = 10
		local text = FontConfig.createWithCharMap("%("..tm.."%)","tryPlay/buyNum.png",19,28,"0",{{"%(",":"},{"%)",";"}})
		text:setPosition(image:getContentSize().width,image:getContentSize().height/2)
		text:setAnchorPoint(0,0.5)
		image:addChild(text)
		text:setTag(tm)

		image:setPositionX(image:getPositionX() - image:getContentSize().width/2 - text:getContentSize().width/2)

		local fun = function() 
			local tag = text:getTag()

			tag = tag - 1

			if tag < 0 then
				text:stopAllActions()
				self:delayCloseLayer(0,function() Hall:exitGame(2,function() globalUnit.isEnterGame = false end,0) end)
			else
				text:setText("%("..tag.."%)")
				text:setTag(tag)
				image:setPositionX(self.sureBtn:getContentSize().width/2 - image:getContentSize().width/2 - text:getContentSize().width/2)
			end
		end

		schedule(text, fun, 1)
	else
		self:updateSureBtnImage("tryPlay/lijichongzhi.png","tryPlay/lijichongzhi-on.png")
	end

	local info = FontConfig.createWithSystemFont("亲，您当天免费体验游戏的时间已满，为了给其他玩家可以更好的轮番体验游戏，请您到正式游戏房间试试手气哦，祝您财源滚滚",26,cc.c3b(169,118,60))
	info:setPosition(self.size.width/2,self.size.height/2+40)
	info:setDimensions(400,0);

	info:setAlignment(cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.bg:addChild(info)

	GamePromptLayer:remove()
end

function PlayOutTimeLayer:onClickSure(sender)
	self:delayCloseLayer(0)
	GamePromptLayer:remove()
	if globalUnit.isEnterGame == true or display.getRunningScene():getChildByName("deskLayer") or display.getRunningScene():getChildByName("mGameLayer") then
		Hall:exitGame(2,function() globalUnit.isEnterGame = false end,0)
	else
		dispatchEvent("exitGameBackPlatform")
	end
	createShop()
end

function PlayOutTimeLayer:onClickClose()
	self:delayCloseLayer(0)
	GamePromptLayer:remove()
	if globalUnit.isEnterGame == true or display.getRunningScene():getChildByName("mGameLayer") then
		Hall:exitGame(2,function() globalUnit.isEnterGame = false end,0)
	else
		dispatchEvent("exitGameBackPlatform")
	end
end

return PlayOutTimeLayer

