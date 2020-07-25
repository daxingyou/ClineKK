local fishShadow = class( "fishShadow", function() return display.newSprite(); end )
local FishManager = require("jinchanbuyu.game.core.FishManager"):getInstance();
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();
local FishPath = require("jinchanbuyu.game.core.FishPath"):getInstance();

function fishShadow:ctor(fish)
  if tolua.isnull(fish) then
    self.isError = true;
    return;
  else
    self.isError = false;
  end

	self._activeFrameAnimation = activeFrameAnimation
	self._fish = fish

  self._fishType = self._fish._fishType
  self._activeFrameCount =  fish._activeFrameCount
  self._activeFrameDelay =  fish._activeFrameDelay
  self._fishScale = fish._fishScale
  self._fishKing = false;--鱼王
  self._fishCQZS = false
  self._fishHuaFei = fish._fishHuaFei;
  self.bossChildren = {}
  self.bossAnimate = {};

  self.animateSp = nil;

  if self._fishType >= FishType.FISH_FENGHUANG and self._fishType <= FishType.FISH_KIND_40 then
    self._fishKing = true;
  elseif self._fishType >= FishType.FISH_KIND_67 and self._fishType <= FishType.FISH_KIND_71 then
    self._fishCQZS = true;
  end

	self:initGui()
end

function fishShadow:initGui()
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test1.plist", "jinchanbuyu/fishing/fish/jcby_fish_test1.png");
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test2.plist", "jinchanbuyu/fishing/fish/jcby_fish_test2.png");
    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test3.plist", "jinchanbuyu/fishing/fish/jcby_fish_test3.png");
    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test4.plist", "jinchanbuyu/fishing/fish/jcby_fish_test4.png");

    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/boss.plist", "jinchanbuyu/fishing/fish/boss.png");
    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/boss1.plist", "jinchanbuyu/fishing/fish/boss1.png");
    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/boss2.plist", "jinchanbuyu/fishing/fish/boss2.png");
    --从缓存找数据
  if not self.armatureObj then
    DataCacheManager:createFishAnimation(self,self._fishType)
  end
  self:addThisEffect();
  self:setScale(self._fishScale);
  self:setCascadeColorEnabled(true);
  self:setCascadeOpacityEnabled(true);
  if(self.armatureObj)then
    self.armatureObj:setColor(cc.c3b(10,10,10));
    self.armatureObj:setOpacity(128);
  else
    self:setColor(cc.c3b(10,10,10));
    self:setOpacity(128);
  end
end

function fishShadow:addThisEffect()
    if(self.particle)then
      self.particle:setVisible(true);
    
      if(self._fishType == 18)then
        self.particle:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
      end
      return
    end

    self.particle = nil;

    if self._fishKing == true then
      local rd = FishPath:fakeRandomS(self._fish._fishType, 2,198)%80;
      if rd % 2 == 0 then
        self.particle = display.newSprite();
        self.particle:setSpriteFrame(display.newSpriteFrame("jcby_dish.png"));
      else
        self.particle = display.newSprite();
        self.particle:setSpriteFrame(display.newSpriteFrame("jcby_halo.png"));
      end
      self:addChild(self.particle,-1);
      self.particle:setPosition(self:getCenter());
      if self._fish._fishType == 39 then
        self.particle:setPositionX(self.particle:getPositionX()-10);
      end
      self.particle:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    elseif self._fishCQZS == true then
      -- self.particle = display.newSprite();
      -- self.particle:setSpriteFrame(display.newSpriteFrame("jcby_4_1.png"));
      self.particle = ccui.ImageView:create("fishing/cqzs.png");
      self:addChild(self.particle,-1);
      self.particle:setPosition(self:getCenter());
      self.particle:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    elseif self._fishHuaFei == true then
      -- local count = 30;
      -- local frames = display.newFrames("huafei_%d.png", 1, count);
      -- local activeFrameAnimation = display.newAnimation(frames, 0.1);

      -- self.particle = display.newSprite()
      -- self.particle:setSpriteFrame(frames[1]);
    
      -- -- 自身动画
      -- local animate= cc.Animate:create(activeFrameAnimation);
      -- local aimateAction=cc.Repeat:create(animate,999999);
      -- local aimateSpeed = cc.Speed:create(aimateAction, 1);
      -- self.particleaimateSpeed = aimateSpeed;
      -- self.particle:runAction(aimateSpeed);
      -- self:addChild(self.particle,10);
      -- self.particle:setPosition(self:getCenter());

      -- if self._flipY == true then
      --   self.particle:setRotation(-180);
      --   self.particle:setPositionY(self.particle:getPositionY()-self:getContentSize().height/2-20);
      -- else
      --   self.particle:setPositionY(self.particle:getPositionY()+self:getContentSize().height/2+20);
      --   self.particle:setPositionX(self.particle:getPositionX()+80);
      -- end
    end
end

function fishShadow:setFlipScreen(flipX,flipY)
  if self.particle then
    if self._fishHuaFei == true then
      local p = self:getCenter();
      if flipY == true then
        self.particle:setRotation(-180);
        self.particle:setPositionY(p.y-self:getContentSize().height/2-20);
        self.particle:setPositionX(p.x+60);
        if self._fishType == 59 then
            self.particle:setPositionY(self.particle:getPositionY()+100);
            self.particle:setPositionX(self.particle:getPositionX()+40);
          end
      else
        self.particle:setPositionY(p.y+self:getContentSize().height/2+20);
        self.particle:setPositionX(p.x+60);
        if self._fishType == 59 then
            self.particle:setPositionY(self.particle:getPositionY()-100);
            self.particle:setPositionX(self.particle:getPositionX()+40);
          end
      end
    end
  end

  self:setFlippedX(flipX);
  self:setFlippedY(flipY);
end

function fishShadow:getCenter()
  local center = cc.p(self:getContentSize().width/2,self:getContentSize().height/2);

  return center;
end

function fishShadow:setFishShadowSpeed(aimateActionSpeed)
  if(self.shadowSpeed)then
    self.shadowSpeed:setSpeed(aimateActionSpeed);
  end

  if(self.armatureObj)then
    self.armatureObj:getAnimation():setSpeedScale(aimateActionSpeed);
  end
end

function fishShadow:isFishInScreen()
  local winSize = cc.Director:getInstance():getWinSize();
  local screenRect = cc.rect(0,0,winSize.width,winSize.height);

  local fishRect = self:getBoundingBox();
  -- if isShowFishRect == true then
  --   if FishManager:getGameLayer().fishLayer:getChildByName(self._fish._fishID.."drawfishs"..self._fishType) then
  --     FishManager:getGameLayer().fishLayer:getChildByName(self._fish._fishID.."drawfishs"..self._fishType):removeFromParent();
  --   end

  --   if FishManager:getGameLayer().fishLayer:getChildByName(self._fish._fishID.."drawfishs"..self._fishType) == nil then
  --       local draw = cc.DrawNode:create()
  --       draw:setAnchorPoint(0.5,0.5)
  --       draw:setName(self._fish._fishID.."drawfishs"..self._fishType);
  --       FishManager:getGameLayer().fishLayer:addChild(draw, 1000)
  --       draw:drawRect(cc.p(fishRect.x,fishRect.y), cc.p(fishRect.x+fishRect.width,fishRect.y+fishRect.height), cc.c4f(1,0,0,1))
  --       local x,y = self:getPosition()
  --       local size = self:getContentSize();
  --       -- draw:drawRect(cc.p(x-size.width/2,y-size.height/2),cc.p(x+size.width/2,y+size.height/2),cc.c4f(1,0,0,1))
  --       draw:drawRect(cc.p(screenRect.x,screenRect.y), cc.p(screenRect.width,screenRect.height), cc.c4f(1,0,0,1))
  --       -- draw:drawPoint((cc.p(fishRect.x,fishRect.y)), 10, cc.c4f(1,1,0,1))
  --   end
  -- end

  if cc.rectIntersectsRect(screenRect, fishRect) then
    return true;
  end

  return false;
end

return fishShadow;
