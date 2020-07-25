local quanPingArmature = class( "quanPingArmature", function() return display.newSprite("game/blank.png"); end )
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

function quanPingArmature:ctor(index)
    self.index = index;
    self:initGui()
end

function quanPingArmature:setData()

end

function quanPingArmature:resetData(effectType)
    if effectType == QUAN_PING_EFFECT then
        self.index = 2;
    else
        self.index = 1;
    end    

    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function quanPingArmature:updateData()
    self:setScale(1)
end

function quanPingArmature:initGui()
    self.armatureObj = createSkeletonAnimation("baozha", "fishing/effect/baozha/baozha.json", "fishing/effect/baozha/baozha.atlas");
    if self.armatureObj then
        self:addChild(self.armatureObj);
    end

    --延时播放动画
    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function quanPingArmature:playAction()
    local name = {"baozha_xiao","baozha_da"};
    if self.armatureObj then
        self.armatureObj:setAnimation(1,name[self.index], false);
    end

    self:runAction(self.sequenceAction);
    self.sequenceAction:release()
end

function quanPingArmature:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function quanPingArmature:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return quanPingArmature;
