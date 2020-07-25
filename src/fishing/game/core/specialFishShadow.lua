local specialFishShadow = class( "specialFishShadow", function() return display.newSprite(); end )
local FishManager = require("fishing.game.core.FishManager"):getInstance();
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

function specialFishShadow:ctor(fish, isLine)
  if tolua.isnull(fish) then
    self.isError = true;
    return;
  else
    self.isError = false;
  end
  
	self._activeFrameAnimation = activeFrameAnimation
	self._fish = fish
  self.isLine = isLine;
  self.bScale = 0.7;--底圈缩放倍数
  self.bossChildren = {}
  self.bossAnimate = {};

  self._fishType = self._fish._fishType
  self._activeFrameCount =  fish._activeFrameCount
  self._activeFrameDelay =  fish._activeFrameDelay
  self._fishScale = fish._fishScale
  self:loadAnimate()
	self:initGui()
end

function specialFishShadow:loadAnimate()
  -- if ccs.ArmatureDataManager:getInstance():getAnimationData("bigFishAnimation") == nil then
        -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("effect/fishAnimation/bigFishAnimation.ExportJson");
    -- end
    display.loadSpriteFrames("fishing/fishing/fish/fish_test1.plist", "fishing/fishing/fish/fish_test1.png");
    display.loadSpriteFrames("fishing/fishing/fish/fish_test2.plist", "fishing/fishing/fish/fish_test2.png");
    display.loadSpriteFrames("fishing/fishing/fish/fish_test3.plist", "fishing/fishing/fish/fish_test3.png");
    display.loadSpriteFrames("fishing/fishing/fish/fish_test4.plist", "fishing/fishing/fish/fish_test4.png");
end

function specialFishShadow:initGui()
    --从缓存找数据
  if not self.armatureObj then
    DataCacheManager:createFishAnimation(self,self._fishType)
  end
  self:setScale(self._fishScale);
  
  if self.isLine == true then
    if self.animateSp then
      self.animateSp:setVisible(false);
    end    
  end

  --大三元
  if self._fishType == FishType.FISH_ZHENZHUBEI or self._fishType == FishType.FISH_XIAOFEIYU or self._fishType == FishType.FISH_ALILAN then
    self:createSanyuan();
  --大四喜
  elseif self._fishType == FishType.FISH_ZHADANFISH or self._fishType == FishType.FISH_NORMAL_TYPEMAX or self._fishType == FishType.FISH_WORLDBOSS then
    self:createSixi();
  end

  if(self.armatureObj)then
    self.armatureObj:setColor(cc.c3b(10,10,10));
    self.armatureObj:setOpacity(128);
  else
    self:setColor(cc.c3b(10,10,10));
    self:setOpacity(128);
  end

  local children = self:getChildren();
  for k,v in pairs(children) do
    v:setColor(cc.c3b(10,10,10));
    v:setOpacity(128);
  end
end

function specialFishShadow:updateFishFrame()
    display.loadSpriteFrames("fishing/fishing/fish/fish_test1.plist", "fishing/fishing/fish/fish_test1.png");
    local size = self:getContentSize();
  -- local draw = cc.DrawNode:create()
 --      draw:setAnchorPoint(0,0)
 --      draw:setName("draw");
 --      self:addChild(draw, 1000)
 --      draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
 --      draw:drawPoint((cc.p(0,0)), 5, cc.c4f(1,0,0,1))
  if self.aimateSpeed then
    self:stopAction(self.aimateSpeed);
    self.aimateSpeed = nil;
  end

  local frames = {display.newSpriteFrame("touming.png")};
  local activeFrameAnimation = display.newAnimation(frames, 0.1);

  local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.Repeat:create(animate,999999);
    local aimateSpeed = cc.Speed:create(aimateAction, 1);
    self.aimateSpeed = aimateSpeed
    self:runAction(self.aimateSpeed);

    self:setContentSize(size);
end

function specialFishShadow:setFlipScreen(flipX,flipY)
  self:setFlippedX(flipX);
  self:setFlippedY(flipY);

  if self.animateSp then
    self.animateSp:setFlippedX(flipX);
    self.animateSp:setFlippedY(flipY);
  end

  if self.particle then
    self.particle:setFlippedX(flipX);
    self.particle:setFlippedY(flipY);
  end

  for k,v in pairs(self.bossChildren) do
    v:setFlippedY(flipY)
    v:setFlippedX(flipX)
  end
end

function specialFishShadow:createSanyuan()
  if self.isLine == true then
    self:createLineSanyuan();
  else
    self:createRandSanyuan();
  end
end

--直线
function specialFishShadow:createLineSanyuan()
  local size = self:getContentSize();
  local fileName = "fish_"..(self._fishType-20).."_%d.png";
  local t = cc.size(145,145);
  if self._fishType == 25 then
    t = cc.size(150,150);
  elseif self._fishType == 27 then
    t = cc.size(135,135);
  end

  local pos = {cc.p(size.width/2-t.width,size.height/2),cc.p(size.width/2,size.height/2),cc.p(size.width/2+t.width,size.height/2)}

  for k,v in pairs(pos) do
    local animate = display.newSprite();
    animate:setSpriteFrame(display.newSpriteFrame((self._fishType-25+1).."_1.png"));
    animate:setAnchorPoint(cc.p(0.5,0.5));
    animate:setPosition(v);
    self:addChild(animate);
    if self._fishType == 25 or self._fishType == 27 then
      animate:setScale(self.bScale);
    end
    animate:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    table.insert(self.bossAnimate,animate);

    local frames = display.newFrames(fileName, 1, self._activeFrameCount);
    local activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay);
    local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.RepeatForever:create(animate);

    local fish = display.newSprite();
    fish:setSpriteFrame(frames[1]);
    fish:setPosition(v);
    self:addChild(fish);
    fish:runAction(aimateAction);
    table.insert(self.bossChildren,fish);
  end

  self.realSize = cc.size(t.width*3,t.height);
end

function specialFishShadow:createRandSanyuan()
  local size = self:getContentSize();
  local fileName = "fish_"..(self._fishType-20).."_%d.png";

  local t = cc.size(145,145);
  if self._fishType == 25 then
    t = cc.size(150,150);
  elseif self._fishType == 27 then
    t = cc.size(135,135);
  end

  local pos = {cc.p(-size.width/2+30,size.height/2+t.height/2+10),cc.p(size.width+t.width/2,size.height/2),cc.p(-size.width/2+30,size.height/2-t.height/2-10)}

  for k,v in pairs(pos) do
    local animate = display.newSprite();
    animate:setSpriteFrame(display.newSpriteFrame((self._fishType-25+1).."_1.png"));
    animate:setAnchorPoint(cc.p(0.5,0.5));
    animate:setPosition(v);
    self:addChild(animate);
    if self._fishType == 25 or self._fishType == 27 then
      animate:setScale(self.bScale);
    end
    animate:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    table.insert(self.bossAnimate,animate);

    local frames = display.newFrames(fileName, 1, self._activeFrameCount);
    local activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay);
    local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.RepeatForever:create(animate);

    local fish = display.newSprite();
    fish:setSpriteFrame(frames[1]);
    fish:setPosition(v);
    self:addChild(fish);
    fish:runAction(aimateAction);
    table.insert(self.bossChildren,fish);
  end

  self.realSize = cc.size(t.width*2.5,t.height*2.2);

  if self._fishType == 27 then
      self.realSize.width = self.realSize.width + 100;
    end
end

function specialFishShadow:createSixi()
  if self.isLine == true then
    self:updateFishFrame();
    self:createLineSixi();
  else
    self:createRandSixi();
  end
end

function specialFishShadow:createLineSixi()
  local size = self:getContentSize();
  local fileName = "fish_"..(self._fishType-20).."_%d.png";
  local t = cc.size(145,145);
  if self._fishType == 28 then
    t = cc.size(150,150);
  elseif self._fishType == 30 then
    t = cc.size(135,135);
  end

  local x,y = 15,15;
  local pos = {cc.p(-t.width/2-t.width+x,y),
         cc.p(-t.width/2+x,y),
         cc.p(t.width/2+x,y),
         cc.p(t.width/2+t.width+x,y)}

  for k,v in pairs(pos) do
    local animate = display.newSprite();
    animate:setSpriteFrame(display.newSpriteFrame((self._fishType-28+1).."_1.png"));
    animate:setAnchorPoint(cc.p(0.5,0.5));
    animate:setPosition(v);
    self:addChild(animate);
    if self._fishType == 28 or self._fishType == 30 then
      animate:setScale(self.bScale);
    end
    animate:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    table.insert(self.bossAnimate,animate);

    local frames = display.newFrames(fileName, 1, self._activeFrameCount);
    local activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay);
    local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.RepeatForever:create(animate);

    local fish = display.newSprite();
    fish:setSpriteFrame(frames[1]);
    fish:setPosition(v);
    self:addChild(fish);
    fish:runAction(aimateAction);
    table.insert(self.bossChildren,fish);
    if self._fishType == 29 then
      -- fish:setPositionX(fish:getPositionX()+20);
    end
  end

  self.realSize = cc.size(t.width*4,t.height);
end

function specialFishShadow:createRandSixi()
  local size = self:getContentSize();
  local fileName = "fish_"..(self._fishType-20).."_%d.png";
  local t = cc.size(145,145);
  if self._fishType == 28 then
    t = cc.size(150,150);
  elseif self._fishType == 30 then
    t = cc.size(135,135);
  end

  local pos = {cc.p(-t.height/2,size.height/2),
           cc.p(size.width/2,size.height/2+t.height/2+50),
           cc.p(size.width/2,size.height/2-t.height/2-50),
           cc.p(size.width+t.height/2,size.height/2)}

  if self._fishType == 29 then
    pos = {cc.p(-t.height/2.5,size.height/2),
       cc.p(size.width/2,size.height/2+t.height/2+50),
       cc.p(size.width/2,size.height/2-t.height/2-50),
       cc.p(size.width+t.height/2.5,size.height/2)}
  end

  for k,v in pairs(pos) do
    local animate = display.newSprite();
    animate:setSpriteFrame(display.newSpriteFrame((self._fishType-28+1).."_1.png"));
    animate:setAnchorPoint(cc.p(0.5,0.5));
    animate:setPosition(v);
    self:addChild(animate);
    if self._fishType == 28 or self._fishType == 30 then
      animate:setScale(self.bScale);
    end
    animate:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    table.insert(self.bossAnimate,animate);

    local frames = display.newFrames(fileName, 1, self._activeFrameCount);
    local activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay);
    local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.RepeatForever:create(animate);

    local fish = display.newSprite();
    fish:setSpriteFrame(frames[1]);
    fish:setPosition(v);
    self:addChild(fish);
    fish:runAction(aimateAction);
    table.insert(self.bossChildren,fish);
    if self._fishType == 29 then
      -- fish:setPositionX(fish:getPositionX()+20);
    end
  end

  self.realSize = cc.size(t.width*3,t.height*2.7);

  if self._fishType == 29 or self._fishType == 30 then
    self.realSize.width = self.realSize.width + 100;
  end
end

function specialFishShadow:setFishShadowSpeed(aimateActionSpeed)
  if(self.shadowSpeed)then
    self.shadowSpeed:setSpeed(aimateActionSpeed);
  end

  if(self.armatureObj)then
    self.armatureObj:getAnimation():setSpeedScale(aimateActionSpeed);
  end
end

function specialFishShadow:isFishInScreen()
  local winSize = cc.Director:getInstance():getWinSize();
  local screenRect = cc.rect(0,0,winSize.width,winSize.height);

  local fishRect = self:getBoundingBox();
  local pos = cc.p(self:getPosition());

  if self.isLine ~= true and self._fishType ~= 27  and self._fishType < 27 then
    pos.x = pos.x + 20;
  end

  fishRect = cc.rect(pos.x-self.realSize.width/2,pos.y-self.realSize.height/2,self.realSize.width,self.realSize.height);
--   if FishManager:getGameLayer().fishLayer:getChildByName("drawfishs"..self._fishType) then
--     FishManager:getGameLayer().fishLayer:getChildByName("drawfishs"..self._fishType):removeFromParent();
--   end

--   if FishManager:getGameLayer().fishLayer:getChildByName("drawfishs"..self._fishType) == nil then
--       local draw = cc.DrawNode:create()
--       draw:setAnchorPoint(0.5,0.5)
--       draw:setName("drawfishs"..self._fishType);
--       FishManager:getGameLayer().fishLayer:addChild(draw, 1000)
--       draw:drawRect(cc.p(fishRect.x,fishRect.y), cc.p(fishRect.x+fishRect.width,fishRect.y+fishRect.height), cc.c4f(1,0,0,1))
--       local x,y = self:getPosition()
--       local size = self:getContentSize();
-- -- draw:drawRect(cc.p(x-size.width/2,y-size.height/2),cc.p(x+size.width/2,y+size.height/2),cc.c4f(1,0,0,1))
--       draw:drawRect(cc.p(screenRect.x+5,screenRect.y+5), cc.p(screenRect.width,screenRect.height), cc.c4f(1,0,0,1))
--       -- draw:drawPoint((cc.p(fishRect.x,fishRect.y)), 10, cc.c4f(1,1,0,1))
--   end

  if cc.rectIntersectsRect(screenRect, fishRect) then
    return true;
  end

  return false;
end

return specialFishShadow;
