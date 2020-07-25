local TableLogic = require("sweetparty.TableLogic");
local SweetSprite = class("SweetSprite",function()
    return cc.Node:create();
end);

REMOVE_TIME = 0.5;

local SWEET_PNG_NAME = {
    [TableLogic.SWEET_TYPE.ORANGE] = "SweetSprite_orange",
    [TableLogic.SWEET_TYPE.RED] = "SweetSprite_red",
    [TableLogic.SWEET_TYPE.YELLOW] = "SweetSprite_yellow",
    [TableLogic.SWEET_TYPE.GREEN] = "SweetSprite_green",
    [TableLogic.SWEET_TYPE.PURPLE] = "SweetSprite_purple",
    [TableLogic.SWEET_TYPE.PASSSWEET] = "SweetSprite_passsweet",
    [TableLogic.SWEET_TYPE.FREESWEET] = "SweetSprite_freesweet",
    [TableLogic.SWEET_TYPE.WINNINGSSWEET] = "SweetSprite_winningssweet",
};

SweetSprite._sweetType = 0;
SweetSprite._nRemoveSequence = 0; --爆炸的顺序

function SweetSprite:create(sweetType,stageNum)
    local spriteNode = SweetSprite.new();
    spriteNode:init(sweetType,stageNum);
    return spriteNode;
end

function SweetSprite:init(sweetType,stageNum)
    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("sweetparty/SweetSprite.plist"); 

    self._sweetType = sweetType;
    self._stageNum = stageNum;
--    self:initData();
    self:initUI();
end

function SweetSprite:initUI()
    local strName = ""
    if self._sweetType == 6 or self._sweetType == 1 or self._sweetType == 2 
        or self._sweetType == 3 or self._sweetType == 4 or self._sweetType == 5 then
        strName = SWEET_PNG_NAME[self._sweetType].."_"..tostring(self._stageNum)..".png";
    elseif self._sweetType == 0 then
        return;
    else
        strName = SWEET_PNG_NAME[self._sweetType]..".png";
    end
    local sprite = cc.Sprite:createWithSpriteFrameName(strName)
    
    self._sprite = sprite;
    self:addChild(sprite);
--    sprite:setPosition(cc.p(0,0));
--    self:setSpriteFrame(strName);
    self._nodeAnimation = cc.Node:create();
    self._nodeAnimation:setPosition(cc.p(0,0));
    self:addChild(self._nodeAnimation,20);
end

function SweetSprite:setSweetType(sweettype)
   self._sweetType = sweettype;  
end

function SweetSprite:getSweetType()
   local sweetType = self._sweetType;
   return sweetType;
end


function SweetSprite:setRemoveSequence(RemoveSign)
    self._nRemoveSequence = RemoveSign;
end

function SweetSprite:getRemoveSequence()
    return self._nRemoveSequence;
end

function SweetSprite:RemoveSweet(RemoveType)
   local sweetType = RemoveType;
   if sweetType>5 then
        sweetType =5;
   end
   --显示特效
    local fxAni = createSkeletonAnimation("fx"..tostring(sweetType),"sweetparty/effects/xiaochutexiao.json","sweetparty/effects/xiaochutexiao.atlas");
	if fxAni then
        self._sprite:setVisible(false);
		fxAni:setAnimation(1,"fx"..tostring(sweetType), false);       
        if sweetType == 3 then
            fxAni:setScale(0.8);
        elseif sweetType == 4 then
            fxAni:setScale(0.7);
        elseif sweetType == 5 then
            fxAni:setScale(0.6);
        end

        fxAni:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
--        self:setVisible(false);
        self._nodeAnimation:addChild(fxAni);
        self:runAction(cc.Sequence:create(cc.DelayTime:create(REMOVE_TIME),cc.CallFunc:create(function() self:removeFromParent() end)))
	end 
end

function SweetSprite:AllSweetFadeOut()
end

function SweetSprite:RemoveSprite()
    self:removeFromParent();
end


return SweetSprite;