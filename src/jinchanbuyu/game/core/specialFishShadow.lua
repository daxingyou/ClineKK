local specialFishShadow = class( "specialFishShadow", function() return display.newSprite(); end )
local FishManager = require("jinchanbuyu.game.core.FishManager"):getInstance();
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

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
  self.bScale = 1.3;--底圈缩放倍数
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
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test1.plist", "jinchanbuyu/fishing/fish/jcby_fish_test1.png");
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test2.plist", "jinchanbuyu/fishing/fish/jcby_fish_test2.png");
    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test3.plist", "jinchanbuyu/fishing/fish/jcby_fish_test3.png");
    -- display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test4.plist", "jinchanbuyu/fishing/fish/jcby_fish_test4.png");
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

  --一箭双雕
  if self._fishType == FishType.FISH_KIND_64  then
        self:createEryuan();
    --一石三鸟：是3种鱼的组合，组合：编号9+9+9
  elseif self._fishType == FishType.FISH_KIND_65 then
      self:createSanyuan();
    --金玉满堂：5种鱼的组合，组合：编号14+9+8+6+5,  （14长鱼排中间）
  elseif self._fishType == FishType.FISH_KIND_66 then
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
  self:updateFishFrame()
end

function specialFishShadow:updateFishFrame()
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test1.plist", "jinchanbuyu/fishing/fish/jcby_fish_test1.png");
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

  local frames = {display.newSpriteFrame("jcby_touming.png")};
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

function specialFishShadow:createEryuan()
  self:createRandEryuan();
end

function specialFishShadow:createRandEryuan()
  local size = self:getContentSize();
  local fileName = {"jcby_fish_9_%d.png","jcby_fish_6_%d.png"};
  local _activeFrameCount = {7,8}

    local t = cc.size(120,120);

    local pos = {cc.p(size.width/2-t.width/2,size.height/2),cc.p(size.width+t.width/2,size.height/2)}

    for k,v in pairs(pos) do
      local animate = display.newSprite();
      animate:setSpriteFrame(display.newSpriteFrame("jcby_1_1.png"));
      animate:setAnchorPoint(cc.p(0.5,0.5));
      animate:setPosition(v);
      self:addChild(animate);
      
      animate:setScale(self.bScale);
      
      animate:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
      table.insert(self.bossAnimate,animate);

      local frames = display.newFrames(fileName[k], 1, _activeFrameCount[k]);
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

    self.realSize = cc.size(t.width*2,t.height);
end

function specialFishShadow:createSanyuan()
    self:createRandSanyuan();
end

function specialFishShadow:createRandSanyuan()
  local size = self:getContentSize();
  local fileName = "jcby_fish_9_%d.png";

    local t = cc.size(120,120);

    local pos = {cc.p(-size.width/2+30,size.height/2+t.height/2+10),cc.p(size.width+t.width/2,size.height/2),cc.p(-size.width/2+30,size.height/2-t.height/2-10)}

    for k,v in pairs(pos) do
      local animate = display.newSprite();
      animate:setSpriteFrame(display.newSpriteFrame("jcby_2_1.png"));
      animate:setAnchorPoint(cc.p(0.5,0.5));
      animate:setPosition(v);
      self:addChild(animate);
      
      animate:setScale(self.bScale);
      
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
end

function specialFishShadow:createSixi()
    self:createRandSixi();
end

function specialFishShadow:createRandSixi()
  local size = self:getContentSize();
  local fileName = {"jcby_fish_14_%d.png","jcby_fish_9_%d.png","jcby_fish_8_%d.png","jcby_fish_6_%d.png","jcby_fish_5_%d.png"};
  local _activeFrameCount = {10,7,16,8,9}

    local t = cc.size(120,120);
    

    local pos = {cc.p(size.width/2,size.height/2),
          cc.p(size.width/2-t.width-60,size.height/2),
          cc.p(size.width/2,size.height/2+t.height+10),
          cc.p(size.width/2,size.height/2-t.height-10),
          cc.p(size.width/2+t.width+60,size.height/2)}


    for k,v in pairs(pos) do
      local animate = display.newSprite();
      animate:setSpriteFrame(display.newSpriteFrame("jcby_3_1.png"));
      animate:setAnchorPoint(cc.p(0.5,0.5));
      animate:setPosition(v);
      self:addChild(animate);
      
      animate:setScale(self.bScale);
      
      animate:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
      table.insert(self.bossAnimate,animate);

      local frames = display.newFrames(fileName[k], 1, _activeFrameCount[k]);
      local activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay);
      local animate= cc.Animate:create(activeFrameAnimation);
      local aimateAction=cc.RepeatForever:create(animate);

      local fish = display.newSprite();
      fish:setSpriteFrame(frames[1]);
      fish:setPosition(v);
      self:addChild(fish);
      fish:runAction(aimateAction);
      if k == 1 then
        fish:setScale(0.7)
      end
      table.insert(self.bossChildren,fish);
    end

    self.realSize = cc.size(t.width*3,t.height*2.7);
    
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
