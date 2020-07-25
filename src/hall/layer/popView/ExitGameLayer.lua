local ExitGameLayer = class("ExitGameLayer", PopLayer)

function ExitGameLayer:ctor()
	self.super.ctor(self,PopType.small)

	self:initUI()
end

function ExitGameLayer:initUI()
	local title = ccui.ImageView:create("common/exitTitle.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)

	local info = FontConfig.createWithSystemFont("确定退出"..GameConfig.chineseGameName,28,cc.c3b(255,0,0))
	info:setPosition(self.size.width/2,self.size.height/2)
	self.bg:addChild(info)

	self:setName("exitGameLayer")
	self:updateSureBtnPos(0,-self.size.width*0.2)

	local sureBtn = ccui.Button:create("common/cancel.png","common/cancel-on.png")
	sureBtn:setPosition(self.size.width*0.5+self.size.width*0.2,self.sureBtn:getPositionY())
	self.bg:addChild(sureBtn)
	sureBtn:onClick(function(sender) self:onClickClose(sender) end)
end

function ExitGameLayer:onClickSure(sender)
	cc.Director:getInstance():endToLua()

	exitGame()
end

return ExitGameLayer
