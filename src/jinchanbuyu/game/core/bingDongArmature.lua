local bingDongArmature = class( "bingDongArmature", function() return display.newSprite("game/blank.png"); end )
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

function bingDongArmature:ctor()

    self:initGui()
end

function bingDongArmature:setData(...)

end

function bingDongArmature:resetData()
    self:setScale(1);

    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function bingDongArmature:updateData()
    self:setScale(1)
end

function bingDongArmature:initGui()
    self.armatureObj = createArmature("fishEffect/eff_bingdong0.png","fishEffect/eff_bingdong0.plist","fishEffect/eff_bingdong.ExportJson");
    self:addChild(self.armatureObj); 

        --延时播放动画
    local paths = {};
    table.insert(paths,cc.DelayTime:create(2));
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead(); end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function bingDongArmature:playAction()
    self.armatureObj:getAnimation():playWithIndex(0); 

    self:runAction(self.sequenceAction);
    self.sequenceAction:release()
end

function bingDongArmature:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function bingDongArmature:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return bingDongArmature;
