local ChooseModeLayer = class("ChooseModeLayer", PopLayer)

function ChooseModeLayer:ctor()
	self.super.ctor(self,PopType.small)
	self:initUI()
end

function ChooseModeLayer:initUI()
	self:removeBtn(0)

	self:updateBg("common/bg.png")

	iphoneXFit(self.bg,1)

	self.size = self.bg:getContentSize()

	self:updateCloseBtnImage("newExtend/mode/fanhui.png","newExtend/mode/fanhui-on.png")
	self.closeBtn:setAnchorPoint(1,1)
	self.closeBtn:setPosition(self.size.width-(self.size.width-1280)/4,self.size.height)
	self.closeBtn:onTouchClick(function(sender) self:onClickClose(sender) end)
	self.closeBtn:setLocalZOrder(3)

	local title = ccui.ImageView:create("newExtend/mode/title.png")
	title:setAnchorPoint(cc.p(0.5,1));
	title:setPosition(self.size.width/2,self.size.height)
	self.bg:addChild(title)

	local btn = ccui.Button:create("newExtend/mode/tuiguangyuan.png","newExtend/mode/tuiguangyuan-on.png")
	btn:setPosition(self.size.width*0.2,self.size.height*0.5)
	btn:setTag(1)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	local btn = ccui.Button:create("newExtend/mode/hehuoren.png","newExtend/mode/hehuoren-on.png")
	btn:setPosition(self.size.width*0.5,self.size.height*0.5)
	btn:setTag(2)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)

	local btn = ccui.Button:create("newExtend/mode/kaitongvip.png","newExtend/mode/kaitongvip-on.png")
	btn:setPosition(self.size.width*0.8,self.size.height*0.5)
	btn:setTag(3)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
end

function ChooseModeLayer:onClickBtn(sender)
	local tag = sender:getTag()

	if tag == 1 then
		-- display.getRunningScene():addChild(require("layer.popView.newExtend.ExtendLayer"):create())
		display.getRunningScene():addChild(require("layer.popView.newExtend.Generalize.GeneralizeLayer"):create())
	elseif tag == 2 then
		local layer = require("layer.popView.newExtend.hehuoren.Partner"):create()
		display.getRunningScene():addChild(layer)
	elseif tag == 3 then
		-- display.getRunningScene():addChild(require("vip.OpenOrJoinLayer"):create())
		VipInfo:sendGetVipInfo()
	end
end

return ChooseModeLayer
