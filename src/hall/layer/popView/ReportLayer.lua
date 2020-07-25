local ReportLayer = class("ReportLayer",PopLayer)

function ReportLayer:ctor()
	self.super.ctor(self,PopType.small)

	self.wechat = "b3496843"

	self:initUI()
end

function ReportLayer:initUI()
	local title = ccui.ImageView:create("common/reportTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local wechatBg = ccui.ImageView:create("shop/reportInfo.png")
	wechatBg:setAnchorPoint(0,0.5)
	wechatBg:setPosition(self.size.width*0.1,self.size.height*0.75)
	self.bg:addChild(wechatBg)

	local wechatBg = ccui.ImageView:create("shop/jiangli.png")
	wechatBg:setAnchorPoint(0,0.5)
	wechatBg:setPosition(self.size.width*0.1,self.size.height*0.6)
	self.bg:addChild(wechatBg)

	local label = FontConfig.createWithSystemFont(3000,26,cc.c3b(175,19,19))
	label:setAnchorPoint(0,0.5)
	label:setPosition(wechatBg:getContentSize().width+15, wechatBg:getContentSize().height/2)
	wechatBg:addChild(label)

	self:updateSureBtnImage("shop/fuzhidakai.png","shop/fuzhidakai-on.png")
	self:updateSureBtnPos(-20,self.size.width*0.25)

	local info = ccui.ImageView:create("shop/weixinicon.png")
	info:setPosition(self.size.width*0.1,self.sureBtn:getPositionY())
	self.bg:addChild(info)

	local label = FontConfig.createWithSystemFont(self.wechat,26,cc.c3b(65,97,120))
	label:setAnchorPoint(0,0.5)
	label:setPosition(info:getContentSize().width+15, info:getContentSize().height/2)
	info:addChild(label)
end

function ReportLayer:onClickSure(sender)
	if copyToClipBoard(self.wechat) then
		addScrollMessage("微信号复制成功")
		openWeChat()
	end
end

return ReportLayer

