local TableLogic = require("lianhuanduobao.TableLogic");
local ZuanshiSprite = class("ZuanshiSprite",function()
    return cc.Sprite:create();
end);

local FRAME_PNG_NAME = {
    [TableLogic.SWEET_TYPE.ORANGE] = "zuanshiSprite_1",
    [TableLogic.SWEET_TYPE.RED] = "zuanshiSprite_2",
    [TableLogic.SWEET_TYPE.YELLOW] = "zuanshiSprite_3",
    [TableLogic.SWEET_TYPE.GREEN] = "zuanshiSprite_4",
    [TableLogic.SWEET_TYPE.PURPLE] = "zuanshiSprite_5",
    [TableLogic.SWEET_TYPE.PASSSWEET] = "zuanshiSprite_pass",
};



function ZuanshiSprite:create(shzType,stageNum,isAniaml)
    local sprite = ZuanshiSprite.new();
    sprite:init(shzType,stageNum,isAniaml);
    return sprite;
end

function ZuanshiSprite:init(shzType,stageNum,isAniaml)
    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("lianhuanduobao/zuanshiImage/zuanshi1.plist");

    self._shzType = shzType;
    self._stageNum = stageNum;
    self.isAniaml = isAniaml
    self:initData();
    self:initUI();
end

function ZuanshiSprite:initData()
    self._frameAnimate4 = nil;
    self._frameAnimate20 = nil;
    self._bEnable = true;
    self._bNeedShowEffect = false;

    if self.isAniaml then
       self:updateFrameNameOnAnimal()
    else
       self:updateFrameName();
    end
end

function ZuanshiSprite:updateFrameNameOnAnimal()
    if FRAME_PNG_NAME[self._shzType] then
        local strName = FRAME_PNG_NAME[self._shzType];
        if self._shzType == 1 or self._shzType == 2  or self._shzType == 3 or self._shzType == 4 or self._shzType == 5 then
            self._strNameNormal = strName.."_"..tostring(self._stageNum).."_" .. 0 ..".png"
            self:playFrameAnimateZuanshi()
        elseif self._shzType == 0 then
            return;
        else
           self._strNameNormal = strName.."_" .. 0 ..".png"
           self:playFrameAnimateZuanshiPass()
        end    
    end
end


function ZuanshiSprite:updateFrameName()
    if FRAME_PNG_NAME[self._shzType] then
        local strName = FRAME_PNG_NAME[self._shzType];
        if self._shzType == 1 or self._shzType == 2  or self._shzType == 3 or self._shzType == 4 or self._shzType == 5 then
            self._strNameNormal = strName.."_"..tostring(self._stageNum).."_" .. 0 ..".png"
        elseif self._shzType == 0 then
            return;
        else
           self._strNameNormal = strName.."_" .. 0 ..".png"
        end    
    end
end

function ZuanshiSprite:initUI()
    if self._strNameNormal then
       self:setSpriteFrame(self._strNameNormal);
    end
end

function ZuanshiSprite:updateSpriteFrameByType(shzType)
    self._shzType = shzType;
    self._bNeedShowEffect = false;
    self:updateFrameName();

    self:setSpriteEnable(self._bEnable);
end

function ZuanshiSprite:setSpriteEnable(bEnable)
    self._bEnable = bEnable;

    if bEnable and self._strNameNormal then
        self:setSpriteFrame(self._strNameNormal);
    end

--    if not bEnable and self._strNameGray then
--        self:setSpriteFrame(self._strNameGray);
--    end
end

--播放帧动画(钻石)
--typeIndex钻石类型
function ZuanshiSprite:playFrameAnimateZuanshi()
    self:stopAllFrameAnimate();
    --帧动画
    local frames = {};
    for i = 0, 5 do
        table.insert(frames,FRAME_PNG_NAME[self._shzType].."_"..tostring(self._stageNum).."_" .. i ..".png");
    end
    local animation= cc.Animation:create()
    for _, strFrame in pairs(frames) do
		local frameName = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFrame);
        if frameName then
    	    animation:addSpriteFrame(frameName)  
        end
    end
    animation:setDelayPerUnit( 0.1 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  

    local frameAnimate = cc.Animate:create(animation);
    self:runAction(cc.RepeatForever:create( frameAnimate));

    self._bNeedShowEffect = true;
end


--过关标识
function ZuanshiSprite:playFrameAnimateZuanshiPass()
    self:stopAllFrameAnimate();
    --帧动画
    local frames = {};
    for i = 0, 11 do
        table.insert(frames,FRAME_PNG_NAME[self._shzType].."_" .. i ..".png");
    end
    local animation= cc.Animation:create()
    for _, strFrame in pairs(frames) do
		local frameName = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFrame);
        if frameName then
    	    animation:addSpriteFrame(frameName)  
        end
    end
    animation:setDelayPerUnit( 0.1 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  

    local frameAnimate = cc.Animate:create(animation);
    self:runAction(cc.RepeatForever:create( frameAnimate));

    self._bNeedShowEffect = true;
end

function ZuanshiSprite:playFrameAnimateEffect(bNeedShowEffect)
    self:stopAllFrameAnimate();

    if bNeedShowEffect ~= nil then
        self._bNeedShowEffect = bNeedShowEffect;
    end

    if not self._bNeedShowEffect then
        return false;
    end

    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("lianhuanduobao/zuanshiImage/zuanshi1.plist");

    --帧动画
    local frames = {};
    for i = 0, 18 do
        local imgIndex = self._shzType+1;
        table.insert(frames,"result_"..imgIndex.."_3_"..i..".png");
    end
    local animation= cc.Animation:create()
    for _, strFrame in pairs(frames) do
		local frameName = cc.SpriteFrameCache:getInstance():getSpriteFrame(strFrame);
        if frameName then
    	    animation:addSpriteFrame(frameName)  
        end
    end
    animation:setDelayPerUnit( 0.08 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  

    local frameAnimate = cc.Animate:create(animation);
    self:runAction(cc.RepeatForever:create( frameAnimate));
    return true;
end

function ZuanshiSprite:stopAllFrameAnimate()
    self:stopAllActions();

    self:setSpriteEnable(true);
end

return ZuanshiSprite;
