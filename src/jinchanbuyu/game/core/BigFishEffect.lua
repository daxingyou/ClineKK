-- local BigFishEffect = class( "BigFishEffect", function() return display.newSprite("game/blank.png"); end )
local BigFishEffect = class( "BigFishEffect", function() return display.newSprite(); end )
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

function BigFishEffect:ctor(itype)
    self.itype = itype
    self:setData(0)
    self:initGui()
end

function BigFishEffect:setData(score)
    score = score or 0
    self.score = goldConvert(score)
end

function BigFishEffect:updateData()
    -- self.score = score
    -- self:playAction()
end

function BigFishEffect:resetData()
    self:setData(0)
    self.armatureObj:setScale(1);
    -- self.scoreLabel:setScale(0.5);

    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.5, 1.0),
        cc.CallFunc:create(function() self.scoreLabel:setVisible(true);end),
        cc.DelayTime:create(2),
        cc.CallFunc:create(function() self:nodeDead();end)
    )
    sequence:retain()
    self.sequenceAction = sequence
end

function BigFishEffect:initGui()
    
    self.txname = {"xiao","zhong","da"}
    local armatureObj = createSkeletonAnimation("bigfishtexiao", "fishing/effect/bigfish/bosstexiao.json", "fishing/effect/bigfish/bosstexiao.atlas");
    if armatureObj then
        self:addChild(armatureObj,1);
        self.armatureObj = armatureObj

        self.armatureObj:setAnimation(1,self.txname[self.itype], false);
    end
    --加个label
    -- local scoreLabel = FontConfig.createWithBMFont("+"..FormatNumToString(self.score),"common/big_num.fnt");
    local scoreLabel = FontConfig.createWithCharMap("", "fishing/effect/bigfish/zitiao.png", 20, 29, "+")
    scoreLabel:setAnchorPoint(0.5,0.5);
    -- scoreLabel:setScale(0.5)
    scoreLabel:setPosition(cc.p(armatureObj:getContentSize().width/2, armatureObj:getContentSize().height/2-45))
    armatureObj:addChild(scoreLabel,100)
    self.scoreLabel = scoreLabel

    if self.itype == 3 then
        scoreLabel:setPositionY(scoreLabel:getPositionY()-30)

        local emitter1 = cc.ParticleSystemQuad:create("fishing/effect/bigfish/buyu_1.plist")
        emitter1:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存
        self:addChild(emitter1)
    end

    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.5, 1.0),
        cc.CallFunc:create(function() self.scoreLabel:setVisible(true);end),
        cc.DelayTime:create(2),
        cc.CallFunc:create(function() self:nodeDead();end)
    )
    sequence:retain()
    self.sequenceAction = sequence
end

function BigFishEffect:playAction()
    self.armatureObj:setScale(3);
    self.scoreLabel:setVisible(false)
    self.scoreLabel:setString("+"..FormatNumToString(self.score))

    -- self.armatureObj:getAnimation():playWithIndex(0); 
    self.armatureObj:setAnimation(1,self.txname[self.itype], false);

    self.armatureObj:runAction(self.sequenceAction)
    self.sequenceAction:release()
end

function BigFishEffect:nodeDead()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function BigFishEffect:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return BigFishEffect;

