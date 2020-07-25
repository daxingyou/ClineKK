local MailContentLayer = class("MailContentLayer", PopLayer)

function MailContentLayer:create(data)
	return MailContentLayer.new(data)
end

function MailContentLayer:ctor(data)
	self.super.ctor(self,PopType.small)

	self.data = data

	self:initUI()
end

function MailContentLayer:initUI()
	local title = ccui.ImageView:create("common/xiangqing.png")
	title:setPosition(self.size.width/2,self.size.height-90)
	self.bg:addChild(title)
	luaDump(self.data,"MailContentLayer")
	local text = FontConfig.createWithSystemFont(timeConvert(self.data.CreateDate),26,cc.c3b(231,201,158))
	text:setPosition(self.size.width*0.1,self.size.height*0.75)
	text:setAnchorPoint(0,1)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.bg:addChild(text)

	local text = FontConfig.createWithSystemFont(self.data.uMessage,26,cc.c3b(231,201,158))
	text:setPosition(self.size.width*0.1,self.size.height*0.65)
	text:setAnchorPoint(0,1)
	text:setDimensions(600,0)
	text:setLineBreakWithoutSpace(true)
	text:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.bg:addChild(text)

	if self.data.MailType == 1 then --0 普通邮件 1 VIP邀请
		self.sureBtn:loadTextures("mail/tongyi.png","mail/tongyi-on.png")
		self.sureBtn:onClick(function ()
			luaPrint("同意");
			VipInfo:sendGuildCommendAgree(0,self.data.MailID)
			self:delayCloseLayer(0)
			MailInfo:sendMailListInfoRequest()
		end);
		if self.data.OperateDate ~= 0 then 
			self.sureBtn:loadTextures("mail/yitongyi.png","mail/yitongyi.png","mail/yitongyi.png")
			self.sureBtn:setEnabled(false)
		end
	end
end

function MailContentLayer:onClickSure(sender)
	self:delayCloseLayer()
end

return MailContentLayer
