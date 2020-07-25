local smallArmature = class( "smallArmature", function() return display.newSprite("game/blank.png"); end )
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

function smallArmature:ctor()
    self:initGui()
end

function smallArmature:setData(...)

end

function smallArmature:resetData()
    self:setScale(1);

    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function smallArmature:updateData()
    self:setScale(1)
end

function smallArmature:initGui()
    self.armatureObj = createArmature("effect/dabaoza/eff_kill_dayu0.png","effect/dabaoza/eff_kill_dayu0.plist","effect/dabaoza/eff_kill_dayu.ExportJson");
    self:addChild(self.armatureObj); 

    --延时播放动画
    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function smallArmature:playAction()
    self.armatureObj:getAnimation():playWithIndex(0);

    self:runAction(self.sequenceAction);
    self.sequenceAction:release()
end

function smallArmature:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function smallArmature:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return smallArmature;
