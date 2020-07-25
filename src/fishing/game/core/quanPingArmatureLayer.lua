local quanPingArmatureLayer = class( "quanPingArmatureLayer", function() return cc.Layer:create(); end )

local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();
local FishManager = require("fishing.game.core.FishManager"):getInstance();

function quanPingArmatureLayer:ctor(startPos)

    local winSize = cc.Director:getInstance():getWinSize();
    self.startPos = startPos or cc.p(winSize.width/2,winSize.height/2)

    self:initData()
    self:initGui()
    self:playAction()
end

function quanPingArmatureLayer:initData()
    self.maxArmatureCount = 20
    self.armatureIntervalTime = 0.06
end

function quanPingArmatureLayer:initGui()
    
    self:createEffectNode(self.startPos,true)

    for i=1,self.maxArmatureCount do
        
        local randomPos = self:getRandomPos()

        local paths = {};
        table.insert(paths,cc.DelayTime:create(self.armatureIntervalTime * i));
        table.insert(paths, cc.CallFunc:create(function() self:createEffectNode(randomPos,false,0.5) end));
        self:runAction(cc.Sequence:create(paths))
    end

end

function quanPingArmatureLayer:createEffectNode(pos, isShowParticle,scaleTo)

    scaleTo = scaleTo or 1

    local armatureNode = nil
    armatureNode = DataCacheManager:createEffect(QUAN_PING_EFFECT)
    armatureNode:setScale(scaleTo)
    armatureNode:playAction()
    armatureNode:setPosition(pos);   
    armatureNode:setAnchorPoint(cc.p(0.5,0.5));   
    FishManager:getGameLayer():addChild(armatureNode);
    
    if isShowParticle then
        local particle = cc.ParticleSystemQuad:create("fishing/fishEffect/lizi_bz_quanping.plist")
        particle:setScale(scaleTo)
        particle:setPosition(armatureNode:getPosition())
        self:addChild(particle)
    end

end

function quanPingArmatureLayer:getRandomPos()

     local winSize = cc.Director:getInstance():getWinSize();

    local x = math.random(100,winSize.width - 100)
    local y = math.random(100,winSize.height - 100)
    -- prints("random x = "..x.."   y = "..y)
    return cc.p(x,y)
end

function quanPingArmatureLayer:playAction()
 
    local paths = {};
    table.insert(paths,cc.DelayTime:create((self.maxArmatureCount+1) * self.armatureIntervalTime +2));
    table.insert(paths, cc.CallFunc:create(function() self:deleteNode(); end));
    self:runAction(cc.Sequence:create(paths));

    self:playShakeAction()
end

function quanPingArmatureLayer:playShakeAction()
    
    if(FishManager:getGameLayer():getActionByTag(1002) ~= nil)then
        return
    end

    local sakeTime = 0.06;
    --震屏效果
    local paths = {};

    local shakeCount = (self.maxArmatureCount+1) * self.armatureIntervalTime  / sakeTime + 1

    local x = 0
    local y = 0

    for i=1,shakeCount do
        x = math.random(-15,15)
        y = math.random(-15,15)
        table.insert(paths,cc.MoveTo:create(sakeTime, cc.p(x, y)));
    end

    table.insert(paths,cc.MoveTo:create(sakeTime, cc.p(0, 0)));

    local skadeAction = cc.Sequence:create(paths);
    skadeAction:setTag(1002)

    FishManager:getInstance():getGameLayer():runAction(skadeAction);
end

function quanPingArmatureLayer:deleteNode()
    self:removeSelf()
end

return quanPingArmatureLayer;
