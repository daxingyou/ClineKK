local bigArmature = class( "bigArmature", function() return display.newSprite("game/blank.png"); end )
local DataCacheManager = require("likuipiyu.game.core.DataCacheManager"):getInstance();

function bigArmature:ctor()
    self:initGui()
end

function bigArmature:setData(...)

end

function bigArmature:resetData()
    self:setScale(1);

    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function bigArmature:updateData()
    self:setScale(1);
end

function bigArmature:initGui()
    self.armatureObj = createArmature("effect/xiaobaoza/eff_kill_dabaozha0.png","effect/xiaobaoza/eff_kill_dabaozha0.plist","effect/xiaobaoza/eff_kill_dabaozha.ExportJson");
    self:addChild(self.armatureObj); 

    --延时播放动画
    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function bigArmature:playAction()
    self.armatureObj:getAnimation():playWithIndex(0);

    self:runAction(self.sequenceAction);
    self.sequenceAction:release()
end

function bigArmature:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function bigArmature:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return bigArmature;
