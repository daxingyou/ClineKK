local TableLogic = require("lianhuanduobao.TableLogic");
local ZuanshiSprite = require("lianhuanduobao.ZuanshiSprite");

local SweetSprite = class("SweetSprite",function()
    return cc.Node:create();
end);

REMOVE_TIME = 0.5;

local SWEET_PNG_NAME = {
    [TableLogic.SWEET_TYPE.ORANGE] = "zuanshiSprite_1",
    [TableLogic.SWEET_TYPE.RED] = "zuanshiSprite_2",
    [TableLogic.SWEET_TYPE.YELLOW] = "zuanshiSprite_3",
    [TableLogic.SWEET_TYPE.GREEN] = "zuanshiSprite_4",
    [TableLogic.SWEET_TYPE.PURPLE] = "zuanshiSprite_5",
    [TableLogic.SWEET_TYPE.PASSSWEET] = "zuanshiSprite_pass",

};



SweetSprite._sweetType = 0;
SweetSprite._nRemoveSequence = 0; --爆炸的顺序

function SweetSprite:create(sweetType,stageNum,isAction)
    local spriteNode = SweetSprite.new();
    spriteNode:init(sweetType,stageNum,isAction);
    return spriteNode;
end

function SweetSprite:init(sweetType,stageNum,isAction)
    local spriteFrame = cc.SpriteFrameCache:getInstance();
    spriteFrame:addSpriteFrames("lianhuanduobao/zuanshiImage/zuanshi1.plist");

    self._sweetType = sweetType;
    self._stageNum = stageNum;
    self.isAction = isAction
    self:initUI();
end

function SweetSprite:initUI()
    local strName = ""
    local sprite = ZuanshiSprite:create(self._sweetType,self._stageNum,self.isAction)
    self._sprite = sprite;
    self:addChild(sprite)

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
    local fxAni = createSkeletonAnimation("xiaoshia","lianhuanduobao/effects/xiaoshitexiao.json","lianhuanduobao/effects/xiaoshitexiao.atlas");
	if fxAni then
        self._sprite:setVisible(false);
		fxAni:setAnimation(1,"xiaoshia", false);       
        if sweetType == 3 then
            --fxAni:setScale(0.9);
        elseif sweetType == 4 then
            --fxAni:setScale(0.8);
        elseif sweetType == 5 then
            --fxAni:setScale(0.6);
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