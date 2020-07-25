local ClickEffect = class( "ClickEffect", function() return display.newSprite(); end )
local DataCacheManager = require("likuipiyu.game.core.DataCacheManager"):getInstance();

function ClickEffect:ctor()
	self:initGui()
end

function ClickEffect:updateData()
end

function ClickEffect:resetData()
    local sequence = cc.Sequence:create(
    cc.DelayTime:create(1.2),
    cc.CallFunc:create(function() self:nodeDead(); end)
    );
    sequence:retain()
    self.sequenceAction = sequence
end

function ClickEffect:initGui()
	local armatureObj = createArmature("effect/click_effect/eff_bowen0.png","effect/click_effect/eff_bowen0.plist","effect/click_effect/eff_bowen.ExportJson");
	armatureObj:setAnchorPoint(cc.p(0.5,0.5));
	self:addChild(armatureObj);
	self.armatureObj = armatureObj

	local sequence = cc.Sequence:create(
	cc.DelayTime:create(1.2),
	cc.CallFunc:create(function() self:nodeDead(); end)
	);
	sequence:retain()
	self.sequenceAction = sequence
end

function ClickEffect:playAction()
	self.armatureObj:getAnimation():playWithIndex(0); 

	self:runAction(self.sequenceAction)
	self.sequenceAction:release()
end

function ClickEffect:nodeDead()
	luaPrint("ClickEffect:nodeDead()")
	--缓存托管
	DataCacheManager:removeEffect(self);
end

function ClickEffect:deleteNode()
	self.sequenceAction:release()
	self:removeSelf()
end

return ClickEffect;
