local zhuanlunEffect = class( "zhuanlunEffect", function() return display.newSprite(); end )
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

function zhuanlunEffect:ctor()
	self:setData(0)
	self:initGui()
end

function zhuanlunEffect:setData(score)
	score = score or 0
	self.score = goldConvert(score)
end

function zhuanlunEffect:updateData()
	-- self.score = score
	-- self:playAction()
end

function zhuanlunEffect:resetData()
	self:setData(0)
	self.armatureObj:setScale(1);
	self.scoreLabel:setScale(0.5);

	local sequence = cc.Sequence:create(
		cc.ScaleTo:create(0.5, 1.0),
		cc.CallFunc:create(function() self.scoreLabel:setVisible(true);end),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function() self:nodeDead();end)
	)
	sequence:retain()
	self.sequenceAction = sequence
end

function zhuanlunEffect:initGui()
	local armatureObj = createArmature("effect/zhuanpan/eff_zhuanpan0.png","effect/zhuanpan/eff_zhuanpan0.plist","effect/zhuanpan/eff_zhuanpan.ExportJson")
	armatureObj:setAnchorPoint(cc.p(0.5,0.5));
	self:addChild(armatureObj);
	armatureObj:setScale(3);
	self.armatureObj = armatureObj

	--加个label
	local scoreLabel = FontConfig.createWithBMFont("+"..FormatNumToString(self.score),"common/big_num.fnt");
	scoreLabel:setAnchorPoint(0.5,0.5);
	scoreLabel:setScale(0.5)
	scoreLabel:setPosition(cc.p(armatureObj:getContentSize().width/2 - 20, armatureObj:getContentSize().height/2-45))
	armatureObj:addChild(scoreLabel,100)
	self.scoreLabel = scoreLabel

	local sequence = cc.Sequence:create(
		cc.ScaleTo:create(0.5, 1.0),
		cc.CallFunc:create(function() self.scoreLabel:setVisible(true);end),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function() self:nodeDead();end)
	)
	sequence:retain()
	self.sequenceAction = sequence
end

function zhuanlunEffect:playAction()
	self.armatureObj:setScale(3);
	self.scoreLabel:setVisible(false)
	self.scoreLabel:setString("+"..FormatNumToString(self.score))

	self.armatureObj:getAnimation():playWithIndex(0); 

	self.armatureObj:runAction(self.sequenceAction)
	self.sequenceAction:release()
end

function zhuanlunEffect:nodeDead()
	--缓存托管
	DataCacheManager:removeEffect(self);
end

function zhuanlunEffect:deleteNode()
	self.sequenceAction:release()
	self:removeSelf()
end

return zhuanlunEffect;
