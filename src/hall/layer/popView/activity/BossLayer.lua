local BossLayer = class("BossLayer", PopLayer)

function BossLayer:create()
	return BossLayer.new();
end

function BossLayer:ctor()
	self.super.ctor(self, PopType.none)

	self:initUI();

	self:bindEvent();

end

function BossLayer:bindEvent()
	
end

function BossLayer:receiveConfigInfo(data)
	local data = data._usedata

	luaPrint("receiveConfigInfo",SettlementInfo:getConfigInfoByID(6));

	if data.id == 6 then
		if SettlementInfo:getConfigInfoByID(6) > 0 then
			self.score:setString(goldConvert(SettlementInfo:getConfigInfoByID(6))..":;");
		end
	else

	end
end

function BossLayer:initUI()
	luaPrint("BossLayer initUI",SettlementInfo:getConfigInfoByID(6));

	SettlementInfo:sendConfigInfoRequest(6)

	self.colorLayer:setOpacity(150)

	local winSize = cc.Director:getInstance():getWinSize();

	local sprite = ccui.ImageView:create("activity/boss.png")
	sprite:setPosition(winSize.width/2,winSize.height/2);
	self:addChild(sprite);

	local sureBtn = ccui.Button:create("activity/jiaru.png","activity/jiaru-on.png");
	sureBtn:setPosition(sprite:getContentSize().width/2,sprite:getContentSize().height/2-230);
	sprite:addChild(sureBtn);
	sureBtn:onClick(function(sender) self:onSure(sender) end)

	local closeBtn = ccui.Button:create("activity/guanbi.png","activity/guanbi-on.png")
	closeBtn:setPosition(900,500);
	sprite:addChild(closeBtn)
	closeBtn:onClick(handler(self, self.onClickClose))

end

function BossLayer:onSure(sender)
	local layer = require("layer.popView.newExtend.hehuoren.Partner"):create(true);
	if layer then
        display.getRunningScene():addChild(layer);
    end
    self:removeSelf();
end

function BossLayer:onClickClose(sender)
	--self:delayCloseLayer(0,function() if isShowAccountUpgrade == nil then showSign() end end)
	self:delayCloseLayer(0,function()  showNoticeLayer() end)
end

return BossLayer;