local BigFishCoinArmature = class( "BigFishCoinArmature", function() return display.newSprite("game/blank.png"); end )
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

function BigFishCoinArmature:ctor()
    self.score = 0
    self.multi = 0
    self.fishType = 0
    self.isCrit = nil
    self:initGui()
end

function BigFishCoinArmature:resetData()
    self.score = 0
    self.multi = 0
    self.fishType = 0
    self.isCrit = nil

    self:setScale(1);

    local paths = {};
    table.insert(paths,cc.DelayTime:create(0.3));
    table.insert(paths, cc.CallFunc:create(function() self:palyArmature(); end));
    table.insert(paths,cc.DelayTime:create(0.5));
    table.insert(paths, cc.CallFunc:create(function()  
            self.multiLabel:setVisible(true)
            self.scoreLabel:setVisible(true) 
            self.markIcon:setVisible(true)
            end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function BigFishCoinArmature:setData(score,multi,fishType,isCrit,isMe)
    score = score or 0
    self.multi = multi or 0
    fishType = fishType or 0

    self.score = goldConvert(score)
    self.fishType = fishType
    self.isCrit = isCrit
    self.isMe = isMe;
end

function BigFishCoinArmature:updateData()
    self:setScale(1)
end

function BigFishCoinArmature:addLinePathTo(endPos)
    self.endPos = endPos; 
end

function BigFishCoinArmature:initGui()
    self.armatureObj = createArmature("effect/zhuanfanle/eff_get_money0.png","effect/zhuanfanle/eff_get_money0.plist","effect/zhuanfanle/eff_get_money.ExportJson");
    self:addChild(self.armatureObj);

    --加个label
    local content = FontConfig.createWithBMFont("0","common/big_num.fnt");
    content:setAnchorPoint(0.5,0.5);
    content:setScale(0.5)
    content:setPosition(cc.p(0, 25))
    self:addChild(content)
    self.scoreLabel = content

    --加个label
    local content = FontConfig.createWithBMFont("0","common/beishu_fnt.fnt"); 
    content:setAnchorPoint(0.5,0.5);
    content:setPosition(cc.p(0, -50))
    self:addChild(content)
    self.multiLabel = content

    --延时播放动画
    local paths = {};
    table.insert(paths,cc.DelayTime:create(0.3));
    table.insert(paths, cc.CallFunc:create(function() self:palyArmature(); end));
    table.insert(paths,cc.DelayTime:create(0.5));
    table.insert(paths, cc.CallFunc:create(function()  
            self.multiLabel:setVisible(true)
            self.scoreLabel:setVisible(true) 
            self.markIcon:setVisible(true)
            end));

    local sequence = cc.Sequence:create(paths)
    sequence:retain()
    self.sequenceAction = sequence
end

function BigFishCoinArmature:createParticle()
    local particle = cc.ParticleSystemQuad:create("effect/zhuanfanle/lizi_baojinbi_big.plist")
    particle:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    self:addChild(particle)
    self.particle = particle
end

function BigFishCoinArmature:createTileText()
    if self.markIcon then
        self.markIcon:removeFromParent()
    end

    local markIconName;

    if not self.isCrit then
        -- if self.fishType == 19 or self.fishType == 20 or self.fishType == 21 or self.fishType == 24 then   --赚翻了            
            local num = math.random(1,5);
            if num == 1 then
                markIconName = "effect/zhuanfanle/zhuan_fan_le.png"
            elseif num == 2 then
                markIconName = "effect/zhuanfanle/diao_bao_le.png"
            elseif num == 3 then
                markIconName = "effect/zhuanfanle/tian_jiang_heng_cai.png"
            elseif num == 4 then
                markIconName = "effect/zhuanfanle/fu_jia_tian_xia.png"
            elseif num == 5 then
                markIconName = "effect/zhuanfanle/tai_bang_le.png"
            end
        -- end
    else
        markIconName = "effect/zhuanfanle/baoji.png"
    end

    local markIcon = display.newSprite(markIconName);
    markIcon:setPosition(0, 100)
    self:addChild(markIcon);

    self.markIcon = markIcon
end

function BigFishCoinArmature:playAction()
    self:createTileText()

    self.armatureObj:setVisible(false)
    self.markIcon:setVisible(false)
    self.multiLabel:setVisible(false)
    self.scoreLabel:setVisible(false)

    self:runAction(self.sequenceAction);
    self.sequenceAction:release()
end

function BigFishCoinArmature:palyArmature()
    self:createParticle()

    self.count = 1
    if self.multi >= 200 and self.multi <=500 then
        self.count = 2
    elseif self.multi >= 500 and self.multi <=1000 then
        self.count = 4
    elseif self.multi >= 1000 and self.multi <=2000 then
        self.count = 10
    elseif self.multi >= 2000 then
        self.count = 20
    end

    local dtime = 0
    if self.isMe then
        self.multiNum = 0;
        self.multiLabel:setString("+"..self.multiNum.."倍")
        self.updateMultiNum = schedule(self, function() self:updateMulti(); end, 0.02);
        dtime = (self.multi/self.count)*0.02;
    else
        self.multiLabel:setString("+"..self.multi.."倍")
    end
    self.scoreLabel:setString(FormatNumToString(self.score))
    self.armatureObj:getAnimation():playWithIndex(0); 
    self.armatureObj:setVisible(true)
    local paths = {};

    table.insert(paths,cc.DelayTime:create(1.3+dtime));

    local moveTo = cc.EaseExponentialIn:create(cc.MoveTo:create(1,  self.endPos));
    local saleTo = cc.EaseExponentialIn:create(cc.ScaleTo:create(1,0));
    local SpawnAction = cc.Spawn:create(moveTo,saleTo);
    table.insert(paths, SpawnAction);
    table.insert(paths, cc.CallFunc:create(function() self:nodeDead();end));

    self:runAction(cc.Sequence:create(paths));
end

function BigFishCoinArmature:updateMulti()

    self.multiNum = self.multiNum + self.count;

    if self.multiNum >= self.multi then
        self.multiLabel:setString(self.multi.."倍")
        if self.updateMultiNum then
            self:stopAction(self.updateMultiNum);
            self.updateMultiNum = nil;
        end
    else
        self.multiLabel:setString(self.multiNum.."倍")
    end

end

function BigFishCoinArmature:nodeDead()
    self.particle:removeFromParent()
    --缓存托管
    DataCacheManager:removeEffect(self);
end

function BigFishCoinArmature:deleteNode()
    self.sequenceAction:release()
    self:removeSelf()
end

return BigFishCoinArmature;
