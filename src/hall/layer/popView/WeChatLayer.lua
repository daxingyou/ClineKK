local WeChatLayer = class("WeChatLayer",PopLayer)

function WeChatLayer:create(wechat)
	return WeChatLayer.new(wechat)
end

function WeChatLayer:ctor(wechat)
	self.super.ctor(self,PopType.small)

	self.wechat = wechat

	self:initUI()
end

function WeChatLayer:initUI()
	local title = ccui.ImageView:create("common/dailiTitle.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local wechatBg = ccui.ImageView:create("shop/weixinhaoBg.png")
	wechatBg:setPosition(self.size.width/2,self.size.height*0.65)
	self.bg:addChild(wechatBg)

	local label = FontConfig.createWithSystemFont(self.wechat,26,cc.c3b(65,97,120))
	label:setPosition(wechatBg:getContentSize().width*0.5+15, wechatBg:getContentSize().height/2)
	wechatBg:addChild(label)

	self:updateSureBtnImage("shop/fuzhidakai.png","shop/fuzhidakai-on.png")
	self:updateSureBtnPos(self.size.width*0.15)

	local line = ccui.ImageView:create("shop/line.png")
	line:setPosition(self.size.width/2,self.size.height*0.35-20)
	self.bg:addChild(line)

	local info = ccui.ImageView:create("shop/dailiInfo.png")
	info:setPosition(self.size.width/2,self.size.height*0.2+10)
	self.bg:addChild(info)
end

function WeChatLayer:onClickSure(sender)
	if copyToClipBoard(self.wechat) then
		addScrollMessage("微信号复制成功")
		openWeChat()
	end
end

return WeChatLayer
