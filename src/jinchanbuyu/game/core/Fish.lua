
local Fish = class("Fish", function() return display.newSprite();end)

local FishManager = require("jinchanbuyu.game.core.FishManager"):getInstance();
local FishPath = require("jinchanbuyu.game.core.FishPath"):getInstance();
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

function Fish:ctor(fishtype)
  self:setAnchorPoint(cc.p(0.5,0.5));
  self:setTag(FISH_TAG);

  self.isShowFishID = false;
  self.isShowFishMult = false;
  self.isShowPath = false;

  self._fishID = -1;
  self._fishType = getLocalType(fishtype);
  self._spec = SpecialAttr.SPEC_NONE;
  self._specSprite = nil;
  self._activeFrameDelay = 0.15;
  self._deadFrameDelay = 0.15;
  self._lastPostion = cc.p(-1,-1);
  self._fishIsAnimate = false;--鱼动画加载是否完成

  self._frozenTimer = -1;

  self._slowTimer = -1;

  self._fishKing = false;--鱼王
  self._fishHuaFei = false;--话费鱼
  self._fishCQZS = false;--出奇制胜

  if FishModule.m_gameFishConfig then
    self._fishMult = FishModule.m_gameFishConfig.fish_multiple[self._fishType] or 40;
  else
    self._fishMult = 40;
  end
  
  self:initFishType(self._fishType);
  self._activeFrameAnimation = nil;
  self.armatureObj = nil;
  self.animateSp = nil;

  self.effectNode = cc.Node:create();
  self.effectNode:setAnchorPoint(cc.p(0.5,0.5))
  self:addChild(self.effectNode,1); 

  self:updateData()
  self.winSize = cc.Director:getInstance():getWinSize();
end

function Fish:updateData()
  self:setScale(self._scale)
  self:setOpacity(255)
  self:setRotation(0)
  self:setCascadeColorEnabled(true);
  self:setCascadeOpacityEnabled(true);

  self.pathSpeed=nil;
  self.aimateSpeed=nil;
  self.bossDeadSpeed = nil;
  self._flipY=false;
  self.m_isClear = false;
  self.isKilled = false;
  self._isFrozen=false;
  self.updateFishScheduler = nil;
  self.bossChildren = {};
  self.bossAnimate = {};
  self._lastPostion = cc.p(-1,-1);
  self._fishID = -1;
  self._fishIsAnimate = false;
  self._frozenTimer = -1;
  self.isBoss = false
  self.isCanHit = nil;

  self._slowTimer = -1;
  self._fishKing = false;--鱼王
  self._fishHuaFei = false;--话费鱼
  self._fishCQZS = false;--出奇制胜
  if FishModule.m_gameFishConfig then
    self._fishMult = FishModule.m_gameFishConfig.fish_multiple[self._fishType] or 40;
  else
    self._fishMult = 40;
  end
  
  self:initFishType(self._fishType);
  self._activeFrameAnimation = nil;
  self.armatureObj = nil;
  self.animateSp = nil;

  self._fishPath = nil

  self:setFishSpeed(0,1)
  self:setScale(self._fishScale);

  if self._fishType >= FishType.FISH_FENGHUANG and self._fishType <= FishType.FISH_KIND_40 then
    self._fishKing = true;
  elseif self._fishType >= FishType.FISH_KIND_67 and self._fishType <= FishType.FISH_KIND_71 then
    self._fishCQZS = true;
  elseif self._fishType == FishType.FISH_LONGXIA then--金蟾
    -- self.isShowFishMult = true;
  elseif (self._fishType >= FishType.FISH_HUAFEI1 and self._fishType <= FishType.FISH_HUAFEI7) or self._fishType == FishType.FISH_HUAFEI8 then
    -- self._fishHuaFei = true;
  end

  self.isBoss = self:checkIsBoss()
  if self.isBoss then
    self.playSchedule = nil
    -- FishManager:getGameLayer():showBossWarning(self._fishType);
    -- if DataCacheManager._fishIsDatacache == true then
    --   self.updateBoss = schedule(self, function() self:updateBossMusic(); end, 0.5);
    -- end
  elseif self:checkIsSanyanSixi() then
    if DataCacheManager._fishIsDatacache == true then
      self.checkGenerateCompete = performWithDelay(self, function() self:checkFish(); end, 0.2);
    end
  end

  if self.skeleton_animation then
    self.skeleton_animation:removeSelf();
    self.skeleton_animation = nil;
  end

  if self.specDeath then
    self.specDeath:removeSelf();
    self.specDeath = nil;
  end

  self.localZorder = self._fishType;

  if self:checkIsBoss() then --BOSS
    self.localZorder = 100;
  elseif self._fishType == 52 or self._fishType == 53 or self._fishType == 54 or self._fishType == 57 or self._fishType == 58 then --金蛋，红包，摇钱树，黑洞鱼 多宝鱼
    self.localZorder = 99;
  elseif self._fishHuaFei then --话费鱼
    self.localZorder = 98;
  end

  self:setLocalZOrder(self.localZorder);
end

--恢复鱼的原始状态
function Fish:resetData(fishType)
  for k,v in pairs(self.bossChildren) do
    v:removeSelf();
  end
  self.bossChildren = {};

  for k,v in pairs(self.bossAnimate) do
    v:removeSelf();
  end
  self.bossAnimate = {};

  self._fishType = getLocalType(fishType);
  self:updateData();
  self:setFlipRotate(false);
  if self.curColor ~= self.originColor then
    self:setColor(self.originColor);
    self.curColor = self.originColor;
  end
end

function Fish:addPhysicsBody(size)
  if not isPhysics then
    return;
  end

  --add body
  local fishBody = nil;
  local fishBodyPlistName = "fish/"..self._fishType..".plist";

  if(size == nil and cc.FileUtils:getInstance():isFileExist(fishBodyPlistName))then
    if self._fishKing == true or 
      self._fishType == FishType.FISH_DAZHADAN or 
      self._fishType == FishType.FISH_FROZEN then
       fishBody = getFilePhysicsBody(fishBodyPlistName,self,"circle");
    else
       fishBody = getFilePhysicsBody(fishBodyPlistName,self);
    end
  else
    luaPrint(" 找不到碰撞配置文件   "..fishBodyPlistName)
    local boxSize = self:getContentSize();
    if self._fishType == FishType.FISH_MOGUIYU then
      boxSize.width = boxSize.width*2.5;
    end
    if size == nil then
      if self._fishType == FishType.FISH_BOSS2 then
        boxSize.height = boxSize.height*0.6;
      elseif self._fishType == FishType.FISH_ROCKMONEYTREE then
        -- boxSize.width = boxSize.width*2;
        boxSize.height = boxSize.height*1.5;
      elseif self._fishType == FishType.FISH_COLORFULFISH then
        boxSize.width = boxSize.width*1.5;
      elseif self._fishType == FishType.FISH_YINLONG then
        boxSize.width = boxSize.width*2;
      elseif self._fishType == FishType.FISH_GIFTEGGS then
        boxSize.height = boxSize.height*1.5;
      elseif self._fishType == FishType.FISH_REDENVELOPES then
        boxSize.height = boxSize.height*1.5;
        boxSize.width = boxSize.width*1.5;
      end
      fishBody = cc.PhysicsBody:createBox(cc.size(boxSize.width*0.5,boxSize.height*0.5))
    else
      fishBody = cc.PhysicsBody:createBox(size)
    end
  end

  fishBody:setCategoryBitmask(8);
  fishBody:setCollisionBitmask(20);
  fishBody:setContactTestBitmask(20);
  self:setPhysicsBody(fishBody);
  if self:checkIsSanyanSixi() then
    fishBody:setRotationOffset(self:getRotation());
  elseif self._fishType == FishType.FISH_ROCKMONEYTREE then
    -- fishBody:setPositionOffset(cc.p(0,50));
  end
  self.body = fishBody
end

function Fish:resetPhysicsBody(point)
  if not isPhysics then
    return;
  end

  fishBody = cc.PhysicsBody:create();

  fishBody:addShape(cc.PhysicsShapePolygon:create(point));

  fishBody:setCategoryBitmask(8);
  fishBody:setCollisionBitmask(20);
  fishBody:setContactTestBitmask(20);
  self:setPhysicsBody(fishBody);
  self.body = fishBody
end

function Fish:initFishType( fishtype ) 
    self = initFishType(self,fishtype);
end

function Fish:onEnter()

end

function Fish:onEnterTransitionFinish()

end

function Fish:onExit()
  if self.updateFishScheduler then
    self:stopAction(self.updateFishScheduler);
    self.updateFishScheduler = nil
  end
end

function Fish:generateFishPath(path, groupIndex, topFish,isSpec)
  if(groupIndex==nil)then
     groupIndex=0
  end

  self.path = self.path or path
  self.groupIndex = self.groupIndex or groupIndex
  self.topFish = self.topFish or topFish

  if self.path >= 20000 then
    FishPath:createCallFishPath(self, self.path, FishManager:getGameLayer().callFishTargetPos);
  else
    FishPath:createFishPath(self, self.path, self.groupIndex, self.topFish,isSpec);
  end
  
  local s = self.pathid;
  if s and self.isShowPath == true then
    if self.effectNode:getChildByName("pathid") then
      self.effectNode:getChildByName("pathid"):removeFromParent();
    end
    local fishIDText = FontConfig.createWithSystemFont(s, 26, cc.c3b(255,0,0))
    -- fishIDText:setPosition(cc.p(self:getContentSize().width/2 ,self:getContentSize().height/2));
    fishIDText:setPositionY(fishIDText:getPositionY()+50)
    fishIDText:setName("pathid")
    self.effectNode:addChild(fishIDText,3);
  end
end

function Fish:generateServerFishPath(pathType, points, dt)
  FishPath:createServerFishPath(self, pathType, points, dt);
end

function Fish:followFishPath(path, groupIndex, topFish)
  FishPath:createFollowPath(self, path, groupIndex, topFish);
end

function Fish:generateFrameAnimation()
  --从缓存找数据
  -- if not self.armatureObj then
    DataCacheManager:createFishAnimation(self,self._fishType)
  -- end

  self:correctPos()

  self:addPhysicsBody();
  self:addFishWidget();

  if self.isShowFishID then
    self:showFishID()
  end

  if self.isShowFishMult then
    self:showFishMult();
  end

  self.effectNode:setPosition(cc.p(self:getContentSize().width/2 + self.offsetPosx,self:getContentSize().height/2+self.offsetPosy))

  if self:checkIsSanyanSixi() then
    self._fishIsAnimate = true;
  end
end

function Fish:showFishID()
  if self.fishIDText then
    self.fishIDText:removeFromParent();
    self.fishIDText = nil;
  end

    --fishID
  if not self.fishIDText then
    -- local fishIDText = FontConfig.createWithSystemFont(self._fishType, 26, cc.c3b(255,0,0))
    local fishIDText = FontConfig.createWithSystemFont(self._fishID.."--"..tostring(self.isCanHit), 26, cc.c3b(255,255,0))
    -- fishIDText:setPosition(cc.p(self:getContentSize().width/2 ,self:getContentSize().height/2));
    self.effectNode:addChild(fishIDText,3);
    self.fishIDText = fishIDText
  end
end

function Fish:showFishMult()
  if self.fishMultText then
    self.fishMultText:removeFromParent();
    self.fishMultText = nil;
  end

  if not self.fishMultText then
    local fishMultText = FontConfig.createWithSystemFont(self._fishMult, 26, cc.c3b(255,0,0))
    fishMultText:setPositionY(self:getContentSize().height/2)
    self.effectNode:addChild(fishMultText,3);
    self.fishMultText = fishMultText
  end
end

function Fish:setFishMult(fishMult)
  if fishMult and self.fishMultText then
    self.fishMultText:setString(fishMult);
  end
end

function Fish:createShadow()
  if not self:checkIsSanyanSixi() then
    if self.fishShadow and not tolua.isnull(self.fishShadow) then
      self.fishShadow:removeFromParent();
      self.fishShadow = nil;
    end

    local fishShadow = require("jinchanbuyu.game.core.fishShadow").new(self);
    if fishShadow and not tolua.isnull(fishShadow) and fishShadow.isError == true then
      fishShadow:removeSelf();
      return nil;
    end

    FishManager:getGameLayer().fishLayer:addChild(fishShadow);
    fishShadow:setLocalZOrder(self.localZorder-1);
    self.fishShadow = fishShadow;

    return self.fishShadow 
  end
end

function Fish:createSpecFishShadow(isLine)
  if not self:checkIsSanyanSixi() then
    return;
  end

  if self.fishShadow and not tolua.isnull(self.fishShadow) then
    self.fishShadow:removeFromParent();
    self.fishShadow = nil;
  end

  local fishShadow = nil;
  if self:checkIsSanyanSixi() then
    fishShadow = require("jinchanbuyu.game.core.specialFishShadow").new(self,isLine);
  end

  if fishShadow and not tolua.isnull(fishShadow) and fishShadow.isError == true then
    fishShadow:removeSelf();
    return nil;
  end

  FishManager:getGameLayer().fishLayer:addChild(fishShadow);
  fishShadow:setLocalZOrder(self.localZorder-1);

  self.fishShadow = fishShadow;

  self.fishShadow:setVisible(true);
  self.fishShadow:setFlipScreen(self:isFlippedX(),self:isFlippedY());
  self:syncShadow(self:getPositionX(),self:getPositionY(),self:getRotation())

  return self.fishShadow
end

--大三元 大四喜，重新设置
function Fish:addFishWidget(size,x)
  self.touchEnabled = nil;

  if self.fishWidget and not tolua.isnull(self.fishWidget) then
    self.fishWidget:removeFromParent();
    self.fishWidget = nil;
    -- return;
  end

  if(not self.fishWidget or tolua.isnull(self.fishWidget))then
    --自动射击的时候锁定点击的鱼
    local fishWidget = ccui.Widget:create();
    fishWidget:setAnchorPoint(cc.p(0.5,0.5));
    fishWidget:setTouchEnabled(false);
    
    if size == nil then
      size = self:getContentSize();
      if self._fishType == 1 then
        size.height = size.height/2;
        size.width = size.width*0.8;
      elseif self._fishType == 4 then
        size.height = size.height/2;
        size.width = size.width*0.8;
      elseif self._fishType == 5 then
        size.height = size.height*0.6;
        size.width = size.width*0.8;
      elseif self._fishType == 7 then
        size.height = size.height/2;
        size.width = size.width*0.8;
      elseif self._fishType == 8 then
        size.height = size.height*0.8;
        size.width = size.width*0.8;
      elseif self._fishType == 9 then
        size.height = size.height*0.8;
        size.width = size.width*0.8;
      elseif self._fishType == 10 then
        size.height = size.height*0.6;
        size.width = size.width*0.7;
      elseif self._fishType == 11 then
        size.height = size.height*0.7;
      elseif self._fishType == 12 then
        size.height = size.height/2;
        size.width = size.width/2;
      elseif self._fishType == 13 then
        size.height = size.height/2;
        size.width = size.width*0.8;
      elseif self._fishType == 14 then
        size.height = size.height/2;
        size.width = size.width*0.9;
      elseif self._fishType == 15 then
        size.height = size.height/2;
        size.width = size.width*0.9;
      elseif self._fishType == 16 then
        size.height = size.height/2;
        size.width = size.width*0.7;
      elseif self._fishType == 17 then
        size.height = size.height*0.5;
        size.width = size.width*0.6;
      elseif self._fishType == 18 then
        size.height = size.height*0.4;
        size.width = size.width*0.8;
      elseif self._fishType == 19 then
        size.height = size.height*0.35;
        size.width = size.width*0.7;
      elseif self._fishType == 20 then
        size.height = size.height*0.65;
        size.width = size.width*0.7;
      elseif self._fishType == 21 then
        size.height = size.height*0.6;
        size.width = size.width*0.6;
      elseif self._fishType == 22 then
        size.height = size.height*0.5;
        size.width = size.width*0.7;
      elseif self._fishType == 23 then
        size.height = size.height*0.5;
        size.width = size.width*0.5;
      elseif self._fishType == 24 then
        size.height = size.height*0.5;
        size.width = size.width*0.5;
      elseif self._fishType == 25 then
        if self.isLine ~= true then
          size.height = size.height*3.5;
          size.width = size.width*2.5;
        end        
      elseif self._fishType == 26 then
        if self.isLine ~= true then
          size.height = size.height*4;
          size.width = size.width*3;
        end
      elseif self._fishType == 27 then
        if self.isLine ~= true then
          size.height = size.height*2;
          size.width = size.width*2.5;
        end
      elseif self._fishType == 28 then
        if self.isLine ~= true then
          size.height = size.height*1.4;
          size.width = size.width*2.2;
        end
      elseif self._fishType == 29 then
        if self.isLine ~= true then
          size.width = size.width*2;
        end
      elseif self._fishType == 30 then
        if self.isLine ~= true then
          size.height = size.height*1.4;
          size.width = size.width*3.5;
        end
      elseif self._fishType == 31 then
        size.height = size.height*1.2;
        size.width = size.width*1.2;
      elseif self._fishType == 32 then
        size.height = size.height*3;
        size.width = size.width*1.2;
      elseif self._fishType == 33 then
        size.height = size.height*2;
        size.width = size.width*1.2;
      elseif self._fishType == 36 then
        size.height = size.height*2;
        size.width = size.width*1.2;
      elseif self._fishType == 38 then
        -- size.height = size.height*0.9;
        size.width = size.width*0.7;
      elseif self._fishType == 40 then
        size.height = size.height*1.2;
        size.width = size.width*1.2;
      elseif self._fishType == 41 then
        size.height = size.height/3;
        size.width = size.width*0.8;
      elseif self._fishType == 42 then
        size.height = size.height*0.2;
        size.width = size.width*0.5;
      elseif self._fishType == 43 then
        size.height = size.height*0.2;
        size.width = size.width*0.8;
      elseif self._fishType == 44 then
        size.height = size.height*0.2;
        size.width = size.width*0.6;
      elseif self._fishType == 64 then
        size.height = size.height;
        size.width = size.width*2.6;
      elseif self._fishType == 65 then
        size.height = size.height*2.2;
        size.width = size.width*2.8;
      elseif self._fishType == 66 then
        size.height = size.height;
        size.width = size.width*3.8;
      elseif self._fishType == 67 then
        size.height = size.height*2;
        size.width = size.width*1.2;
      elseif self._fishType == 70 then
        size.height = size.height*2;
        size.width = size.width*1.2;
      elseif self._fishType == 71 then
        -- size.height = size.height*0.9;
        size.width = size.width*0.7;
      else

      end
      
      fishWidget:setContentSize(size);
    else
      fishWidget:setContentSize(size);
      if x then
        fishWidget:setPositionX(x);
      end
    end

    -- if fishWidget:getChildByName("draw") == nil then
    --   local draw = cc.DrawNode:create()
    --   draw:setAnchorPoint(0.5,0.5)
    --   draw:setName("draw");
    --   fishWidget:addChild(draw, 1000)
    --   draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
    --   draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))
    -- end
    
    self.effectNode:addChild(fishWidget);
    fishWidget:addTouchEventListener(
        function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
              if(FishManager:getGameLayer().my and not self.isKilled)then
                  -- luaPrint("锁定该鱼 /* //* /*/*/*/*/*/*/*/*/*/*");
                  if FishManager:getGameLayer().my.lockFish == self then
                      FishManager:getGameLayer().my:fireToPonit(self:getFishPos());
                  end
                  FishManager:getGameLayer().my:setLockFish(self)
              end
            end
        end
    )
    self.fishWidget = fishWidget

    if self.fishWidget2 then
      self.fishWidget2:removeFromParent();
      self.fishWidget2 = nil;
    end

    if self._fishType == 66   then
      size.height,size.width = size.width,size.height

      local fishWidget = ccui.Widget:create();
      fishWidget:setAnchorPoint(cc.p(0.5,0.5));
      fishWidget:setTouchEnabled(false);

      -- if fishWidget:getChildByName("draw") == nil then
      --   local draw = cc.DrawNode:create()
      --   draw:setAnchorPoint(0.5,0.5)
      --   draw:setName("draw");
      --   fishWidget:addChild(draw, 1000)
      --   draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
      --   draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))
      -- end

      fishWidget:setContentSize(size);
      self.effectNode:addChild(fishWidget);
      fishWidget:addTouchEventListener(
          function(sender,eventType)
              if eventType == ccui.TouchEventType.ended then
                if(FishManager:getGameLayer().my and not self.isKilled)then
                    -- luaPrint("锁定该鱼 /* //* /*/*/*/*/*/*/*/*/*/*");
                    if FishManager:getGameLayer().my.lockFish == self then
                        FishManager:getGameLayer().my:fireToPonit(self:getFishPos());
                    end
                    FishManager:getGameLayer().my:setLockFish(self)
                end
              end
          end
      )
      self.fishWidget2 = fishWidget
    end
  end
end

function Fish:setWidgetTouchEnable()
  if FishManager:getGameLayer().isAutoShoot ~= self.touchEnabled then
     self.fishWidget:setTouchEnabled(FishManager:getGameLayer().isAutoShoot)
     if self.fishWidget2 then
       self.fishWidget2:setTouchEnabled(FishManager:getGameLayer().isAutoShoot)
     end
     self.touchEnabled = FishManager:getGameLayer().isAutoShoot
  end
end

function Fish:updateWidgetPos()
  local size = self.fishWidget:getContentSize();

  if FLIP_FISH then
    if self._flipY == true then
      if self._fishType == 7 then
        self.fishWidget:setPositionX(self.fishWidget:getPositionX()-20);
      end
    else
      if self._fishType == 17 then
        self.fishWidget:setPositionY(self.fishWidget:getPositionY()+10);
      end
    end
  else
    if self._flipY == true then
      if self._fishType == 7 then
        self.fishWidget:setPositionX(self.fishWidget:getPositionX()-20);
      elseif self._fishType == 8 then
        -- self.fishWidget:setPositionX(self.fishWidget:getPositionX()-20);
        -- self.fishWidget:setPositionY(self.fishWidget:getPositionY()-20);
      elseif self._fishType == 9 then
        self.fishWidget:setPositionX(self.fishWidget:getPositionX()-20);
       end
    else
      if self._fishType == 9 then
        self.fishWidget:setPositionX(self.fishWidget:getPositionX()-20);
      elseif self._fishType == 17 then
        self.fishWidget:setPositionY(self.fishWidget:getPositionY()+10);
      end
    end 
  end
end

function Fish:getFishBoundingBox()
    local fishRect = self:getBoundingBox();
    -- local fishRect = self:getContentSize();
    -- if self._fishScale then
    --   fishRect.width = fishRect.width * self._fishScale;
    --   fishRect.height = fishRect.height * self._fishScale;
    --  end
    if self._fishKing or self._fishCQZS then
      if self.particle then
        local psize = self.particle:getContentSize();
        self.fishRect =cc.rect(fishRect.width/2-psize.width/2+10,fishRect.height/2-psize.height/2+10,psize.width*0.8,psize.height*0.8)
      else
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width,fishRect.height)
      end
    elseif self:checkIsSanyanSixi() then
        if self._fishType == 25 or self._fishType == 26 or self._fishType == 27 then
          if self.isLine then
            self.fishRect =cc.rect(fishRect.width/2-210,fishRect.height/2-80,420,150)
          else
            self.fishRect =cc.rect(fishRect.width/2-170,fishRect.height/2-80,380,150)
          end
        else
          if self.isLine then
            self.fishRect =cc.rect(fishRect.width/2-280,fishRect.height/2-80,560,150)
          else
            self.fishRect =cc.rect(fishRect.width/2-210,fishRect.height/2-80,420,150)
          end
        end
    elseif self._fishType == 41 then
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.35,fishRect.width*0.7,fishRect.height*0.3)
    elseif self._fishType == 42 then
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.4,fishRect.width*0.5,fishRect.height*0.2)
    elseif self._fishType == 43 then
      -- if self._flipY then
      --   self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.6,fishRect.width*0.8,fishRect.height*0.3)
      -- else
        self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.1,fishRect.width*0.8,fishRect.height*0.3)
      -- end
    elseif self._fishType == 44 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.35,fishRect.width*0.6,fishRect.height*0.3)
    elseif self._fishType == 4 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.5,fishRect.height*0.4)
    elseif self._fishType == 5 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width*0.6,fishRect.height*0.6)
    elseif self._fishType == 6 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 7 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 8 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 9 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.35,fishRect.width*0.5,fishRect.height*0.3)
    elseif self._fishType == 10 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.6)
    elseif self._fishType == 11 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.25,fishRect.width*0.7,fishRect.height*0.5)
    elseif self._fishType == 12 then
      self.fishRect =cc.rect(fishRect.width*0.4,fishRect.height*0.2,fishRect.width*0.5,fishRect.height*0.4)
    elseif self._fishType == 13 or self._fishType == 45 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.25,fishRect.width*0.6,fishRect.height*0.5)
    elseif self._fishType == 14 or self._fishType == 46 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.2,fishRect.width*0.8,fishRect.height*0.5)
    elseif self._fishType == 15 or self._fishType == 47 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.3,fishRect.width*0.8,fishRect.height*0.4)
    elseif self._fishType == 16 or self._fishType == 48 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 17 or self._fishType == 49 then
      -- if self._flipY then
      --   self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.2,fishRect.width*0.8,fishRect.height*0.4)
      -- else
        self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.4,fishRect.width*0.8,fishRect.height*0.4)
      -- end
    elseif self._fishType == 18 or self._fishType == 50 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.8,fishRect.height*0.4)
    elseif self._fishType == 19 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.35,fishRect.width*0.7,fishRect.height*0.3)
    elseif self._fishType == 20 or self._fishType == 51 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.2,fishRect.width*0.4,fishRect.height*0.7)
    elseif self._fishType == 22 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 23 then
      -- if self._flipY then
      --   self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.5,fishRect.width*0.5,fishRect.height*0.5)
      -- else
        self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.1,fishRect.width*0.5,fishRect.height*0.5)
      -- end
    elseif self._fishType == 24 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.25,fishRect.width*0.6,fishRect.height*0.5)
   elseif self._fishType == 52 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.1,fishRect.width*0.5,fishRect.height*0.5)
    elseif self._fishType == 55 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.3,fishRect.width*0.85,fishRect.height*0.4)
    elseif self._fishType == 56 or self._fishType == 59 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 57 then
      self.fishRect =cc.rect(fishRect.width*0.25,fishRect.height*0.25,fishRect.width*0.5,fishRect.height*0.5)
    elseif self._fishType == 58 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    else
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width*0.6,fishRect.height*0.6)
    end

    self.fishRect.x = self.fishRect.x + fishRect.x
    self.fishRect.y = self.fishRect.y + fishRect.y

    

    -- local draw = cc.DrawNode:create()
    -- draw:setAnchorPoint(0,0)
    -- draw:setName("draw");
    -- self:getParent():addChild(draw, 1000)
    -- draw:setLocalZOrder(1000)
    -- draw:drawRect(cc.p(self.fishRect.x,self.fishRect.y), cc.p(self.fishRect.x+self.fishRect.width,self.fishRect.y+self.fishRect.height), cc.c4f(1,1,0,1))
    -- draw:drawRect(cc.p(fishRect.x,fishRect.y), cc.p(fishRect.x+fishRect.width,fishRect.y+fishRect.height), cc.c4f(1,0,0,1)) 
    -- self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function() draw:removeFromParent() end)))
    -- luaDump(self.fishRect,"self.fishRect")

    return self.fishRect;
end

function Fish:addThisEffect()
    if(self.particle)then
      self.particle:setVisible(true);
    
      if(self._fishType == 18)then
        self.particle:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
      end
      return
    end
    
    self.particle = nil;

    if self._fishKing == true then
      self.particle = display.newSprite();
      self.particle:setSpriteFrame(self.fishShadow.particle:getSpriteFrame());      
      self:addChild(self.particle,-1);
      self.particle:setPosition(self:getCenter());
      if self._fishType == 38 then
        self.particle:setPositionX(self.particle:getPositionX()+self.offsetPosx);
        self.particle:setPositionY(self.particle:getPositionY()+self.offsetPosy);
      end
      self.particle:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    elseif self._fishCQZS == true then
      -- self.particle = display.newSprite();
      -- self.particle:setSpriteFrame("jcby_4_1.png");
      self.particle = ccui.ImageView:create("fishing/cqzs.png");      
      self:addChild(self.particle,-1);
      self.particle:setPosition(self:getCenter());
      self.particle:runAction(cc.RepeatForever:create(cc.RotateBy:create(4.0, 360)));
    elseif self._fishHuaFei == true then
      local count = 30;
      local frames = display.newFrames("huafei_%d.png", 1, count);
      local activeFrameAnimation = display.newAnimation(frames, 0.1);

      self.particle = display.newSprite()
      self.particle:setSpriteFrame(frames[1]);
    
      -- 自身动画
      local animate= cc.Animate:create(activeFrameAnimation);
      local aimateAction=cc.Repeat:create(animate,999999);
      local aimateSpeed = cc.Speed:create(aimateAction, 1);
      self.particleaimateSpeed = aimateSpeed;
      self.particle:runAction(aimateSpeed);
      self:addChild(self.particle,10);
      self.particle:setPosition(self:getCenter());

      self.particle:setPositionX(self.particle:getPositionX()+self.offsetPosx);
      self.particle:setPositionY(self.particle:getPositionY()+self.offsetPosy);

      if self._flipY == true then
        self.particle:setRotation(-180);
        self.particle:setPositionY(self.particle:getPositionY()-self:getContentSize().height/2-20);
        self.particle:setPositionX(self.particle:getPositionX()+60);

        if self._fishType == 59 then
          self.particle:setPositionY(self.particle:getPositionY()+100);
          self.particle:setPositionX(self.particle:getPositionX()+40);
        end
      else
        self.particle:setPositionY(self.particle:getPositionY()+self:getContentSize().height/2+20);
        self.particle:setPositionX(self.particle:getPositionX()+60);
        if self._fishType == 59 then
          self.particle:setPositionY(self.particle:getPositionY()-100);
          self.particle:setPositionX(self.particle:getPositionX()+40);
        end
      end
    end
end

function Fish:showFishDesc()
  
  local descTextFileName = ""
  if self._fishType == 18 then--美人鱼
    descTextFileName = "fish_desc_text_18.png"
  elseif self._fishType == 19 then--金蝙蝠
    descTextFileName = "fish_desc_text_19.png"
  elseif self._fishType == 20 then --机械
    descTextFileName = "fish_desc_text_20.png"
  elseif self._fishType == 21 then--金猪
    descTextFileName = "fish_desc_text_21.png"
  else
    descTextFileName = "fish_desc_text_21.png"
    -- return
  end

  local showDescBg = display.newSprite("game/fish_desc_text_bg.png")
  showDescBg:setAnchorPoint(0.5,0.5);
  -- showDescBg:setContentSize(cc.size(391, 147));
  showDescBg:setPosition(cc.p(self:getContentSize().width/2 ,self:getContentSize().height/2))
  self:addChild(showDescBg,15)

  self.showDesc = showDescBg

  local textImage = display.newSprite("game/"..descTextFileName)
  textImage:setAnchorPoint(0.5,0.5);
  textImage:setPosition(cc.p(showDescBg:getContentSize().width/2, showDescBg:getContentSize().height/2));
  showDescBg:addChild(textImage,16)

  showDescBg:setScale(0)

  self:performWithDelay(function()
        
    local Sequence = cc.Sequence:create(cc.ScaleTo:create(0.25,1),
                                        cc.DelayTime:create(3),
                                        cc.EaseSineIn:create(cc.ScaleTo:create(0.25,1.5,0)),
                                        cc.CallFunc:create(function()
                                           self.showDesc:removeFromParent(); 
                                           self.showDesc = nil 
                                        end)
      )

    showDescBg:runAction(Sequence)

  end,5)

end

function Fish:setSpec(spec)
    local pstr=nil;
    if(spec==SpecialAttr.SPEC_SANYUAN1)then
        pstr = "effect/39/dish.png";
    elseif(spec==SpecialAttr.SPEC_SANYUAN2)then
        pstr = "effect/39/dish.png";
        
    elseif(spec==SpecialAttr.SPEC_SANYUAN3)then
        pstr = "effect/39/dish.png";
        
    elseif(spec==SpecialAttr.SPEC_SIXI1)then
        pstr = "effect/39/halo.png";
        
    elseif(spec==SpecialAttr.SPEC_SIXI2)then
        pstr = "effect/39/halo.png";
        
    elseif(spec==SpecialAttr.SPEC_SIXI3)then
        pstr = "effect/39/halo.png";
    end
    
    if(pstr)then
        self._spec = spec;
        self._specSprite = cc.Sprite:create(pstr);
        self:addChild(self._specSprite,-1);
        local a = self:getContentSize();
        local b = self._specSprite:getContentSize();

        self._specSprite:setPosition(ccp(a.width/2,a.height/2));
        self._specSprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.0, 150)));
        local lbRepeate2 = cc.RepeatForever:create(cc.Sequence:create(updown2,updown2:reverse()))
        
    end
end

function Fish:goFish(fishElapsedTime)
    self._fishElapsedTime = fishElapsedTime
    if self.fishShadow then
      self.fishShadow:setVisible(true);
      self.fishShadow:setFlipScreen(self:isFlippedX(),self:isFlippedY());
      self:syncShadow(self:getPositionX(),self:getPositionY(),self:getRotation())
    end

    for k,v in pairs(self.bossChildren) do
      v:setFlippedY(self:isFlippedY())
      v:setFlippedX(self:isFlippedX())
    end
    
    self:addThisEffect();

    self:moveAction(fishElapsedTime);

    self._lastPostion=cc.p(self:getPositionX(),self:getPositionY());

    if not tolua.isnull(self) then
      self.updateFishScheduler = schedule(self, function() 
        if self and not tolua.isnull(self) then
          self:updateFish(1/50); 
        end
      end, 1/50);
    else
      self:fishDead();
    end
    self.originColor = self:getColor();
    self.curColor = self.originColor;
    self.size = self:getContentSize();
    self:setFishBoundingBox();
end

function Fish:moveAction(fishElapsedTime)
  local pathAction=nil;
    
    local callFunc = cc.CallFunc:create(function () 
      if isShowFishRect == true then
        Hall.showTips(self._fishType.." -------   "..self.pathid,2000)
      end
      self:fishDead(); end) ;
    
    if(self._fishPath ~= nil) then

        table.insert(self._fishPath,callFunc);
        pathAction = self._fishPath[1];
        for i=2,#self._fishPath do
          pathAction=cc.Sequence:create(pathAction,self._fishPath[i]);
        end
        
        table.remove(self._fishPath);

        local speedAction = cc.Speed:create(pathAction, 1);
        self:runAction(speedAction);
        self.pathSpeed = speedAction;

        if self.isCallFish == true then
          self:setFishSpeed(2,2);
        end
    else
        luaPrint("Fish:goFish()   mainAction = err ------------------- ");
    end
end

function Fish:fishDead()
  if self:checkIsBoss() then
    gameResumeMusic(self.isMatrix);
  end

  -- 隐藏阴影
  if self.fishShadow then
    self.fishShadow:setVisible(false);
    if(self.particle)then
      self.fishShadow.particle:setVisible(false);
      self.fishShadow.particle:removeSelf();
      self.fishShadow.particle = nil;
    end
    for k,v in pairs(self.fishShadow.bossChildren) do
      v:removeSelf();
    end
    self.fishShadow.bossChildren = {};

    for k,v in pairs(self.fishShadow.bossAnimate) do
      v:removeSelf();
    end
    self.fishShadow.bossAnimate = {};
  end

  if(self.particle)then
    self.particle:setVisible(false);
    self.particle:removeSelf();
    self.particle = nil;
  end
  -- self.effectNode:removeAllChildren()

  self:fishDeadRemoveData();

  -- self:stopAllActions();
  -- self:removeAllChildren();

  --缓存托管
  DataCacheManager:removeFish(self);
end

function Fish:isFishValid()
  return self:isFishAlive() and self:isFishInScreen();
end

function Fish:isFishAlive()
  if (self.isKilled)then
    return false;
  end

  return true;
end

function Fish:isFishInScreen(isCheckShadow)
  if (self.isKilled or self.isUse == false)then
    return false;
  end

  local screenRect = cc.rect(0,0,self.winSize.width,self.winSize.height);

  local fishRect = self:getBoundingBox();
  if self:checkIsSanyanSixi() and self.realSize then
    local pos = cc.p(self:getPosition());

    if self.isLine ~= true and self._fishType ~= 27  and self._fishType < 27 then
      pos.x = pos.x + 20;
    end

    fishRect = cc.rect(pos.x-self.realSize.width/2,pos.y-self.realSize.height/2,self.realSize.width,self.realSize.height);
  end

  -- if isShowFishRect == true then
  --   if FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfish"..self._fishType) then
  --     FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfish"..self._fishType):removeFromParent();
  --   end

  --   if FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfish"..self._fishType) == nil then
  --       local draw = cc.DrawNode:create()
  --       draw:setAnchorPoint(0.5,0.5)
  --       draw:setName(self._fishID.."drawfish"..self._fishType);
  --       FishManager:getGameLayer().fishLayer:addChild(draw, 1000)
  --       draw:drawRect(cc.p(fishRect.x,fishRect.y), cc.p(fishRect.x+fishRect.width,fishRect.y+fishRect.height), cc.c4f(1,1,0,1))
  --       local x,y = self:getPosition()
  --       local size = self:getContentSize();
  --       -- draw:drawRect(cc.p(x-size.width/2,y-size.height/2),cc.p(x+size.width/2,y+size.height/2),cc.c4f(1,0,0,1))
  --       -- draw:drawRect(cc.p(screenRect.x,screenRect.y), cc.p(screenRect.width,screenRect.height), cc.c4f(1,0,0,1))
  --       -- draw:drawPoint((cc.p(fishRect.x,fishRect.y)), 10, cc.c4f(1,1,0,1))
  --   end
  -- end

  if isCheckShadow == true then
    if  self.fishShadow then
      -- if isShowFishRect == true then
      --   self.fishShadow:isFishInScreen()
      -- end

      if cc.rectIntersectsRect(screenRect, fishRect) or self.fishShadow:isFishInScreen() then
        return true;
      end
    end    
  else    
    if cc.rectIntersectsRect(screenRect, fishRect) then
      return true;
    end
  end

  return false;
end

function Fish:isFishOutScreen()
  if (self.isKilled or self.isUse == false)then
    return true;
  end

  local winSize = cc.Director:getInstance():getWinSize();

  local pos = self:convertToWorldSpace(cc.p(self.effectNode:getPosition()))--self:getPosition()
  local x,y = pos.x,pos.y;

  if x < 0 or x > winSize.width or y < 0 or y > winSize.height then
    return true;
  end

  return false;
end

function Fish:isFishInFixRange(x, y, size)
  if (self.isKilled or self.isUse == false)then
    return false;
  end

  local screenRect = cc.rect(x-size.width/2,y-size.height/2,size.width,size.height);

  local x1,y1 = self:getPosition();
  if cc.rectContainsPoint(screenRect, cc.p(x1,y1)) then
    return true;
  end

  return false;
end

--是否被混沌珠吸住
function Fish:isSuckChaoticBeas(x,y,size)
  if (self.isKilled or self.isUse == false)then
    return false;
  end

  local screenRect = cc.rect(x-size.width/2,y-size.height/2,size.width,size.height);

  local x1,y1 = self:getPosition();
  if cc.rectContainsPoint(screenRect, cc.p(x1,y1)) then
    return true;
  end

  return false;
end

function Fish:isFishBelowPlayer(pos,size)
  local x,y = pos.x,pos.y;
  if (self.isKilled or self.isUse == false)then
    return false;
  end

  local screenRect = cc.rect(x-size.width/2,y-size.height/2,size.width,size.height);

  local x1,y1 = self:getPosition();
  if cc.rectContainsPoint(screenRect, cc.p(x1,y1)) then
    return true;
  end

  return false;
end

function Fish:getLightningSpotEffect()
 --圆点特效
  local armature = createArmature("effect/shandian/eff_dianji0.png","effect/shandian/eff_dianji0.plist","effect/shandian/eff_dianji.ExportJson")
  armature:getAnimation():playWithIndex(0);
  armature:setAnchorPoint(cc.p(0.5,0.5));

  return armature;
end

function Fish:getLightningLineEffect()
  --闪电
  local armature = createArmature("effect/shandian/eff_shandian0.png","effect/shandian/eff_shandian0.plist","effect/shandian/eff_shandian.ExportJson")
  armature:getAnimation():playWithIndex(0);
  armature:setAnchorPoint(cc.p(0.0,0.5));

  armature:setScaleY(0.5);

  return armature;
end

--闪电特效
function Fish:addFishLightningEffect(fishList,isMyFireAttackFish,seatID)

  local thisPos = cc.p(self:getFishPos());

  --线长度
  local lineEffectWidth = 630;

   local fishIsEffect = false;

   local attackFishList = {}

   for i, fish in pairs(fishList) do
      if fish then --and #attackFishList < 15)then
       
           --倍数小的鱼
           if((fish._fishType <= 10) and fish:isFishValid() and (fish._isFrozen == false))then
            
            table.insert(attackFishList,fish._fishID)

            fishIsEffect = true;
            --暂停鱼游动  3秒后恢复
            fish:frozen(4);

            local fishPos = fish:getFishPos();
            local spotEffect = self:getLightningSpotEffect();
            spotEffect:setScale(0.5);
            -- spotEffect:setPosition(cc.p(fish:getContentSize().width/2,fish:getContentSize().height/2));
            fish.effectNode:addChild(spotEffect);

            --删除鱼身上的动画
            local removeEffectFunc = cc.CallFunc:create(function () spotEffect:removeFromParent(); end) ;
            fish:runAction(cc.Sequence:create(cc.DelayTime:create(2.1),removeEffectFunc));

            --调整线条长度
            local angle =  math.atan((thisPos.x - fishPos.x)/(thisPos.y- fishPos.y)) / math.pi * 180;  
            angle = angle + 90 - self:getRotation();

            if FLIP_FISH then
                angle = angle + 180
            end

            if(thisPos.y- fishPos.y >= 0)then
                angle = angle + 180;
            end
            
            local lightningLineEffect = self:getLightningLineEffect();
            lightningLineEffect:setPosition(cc.p(self.effectNode:getContentSize().width/2,self.effectNode:getContentSize().height/2));
            lightningLineEffect:setRotation(angle + 180);
            self.effectNode:addChild(lightningLineEffect,-2); 

            local thisToFishDistance = cc.pGetDistance(thisPos,fishPos);

            local scaleToNum = thisToFishDistance/lineEffectWidth;

            --线条缩放
            lightningLineEffect:setScaleX(scaleToNum);

           end
       end
   end

   if(fishIsEffect)then
      --自身光特效
      local spotEffect = self:getLightningSpotEffect();
      self.effectNode:addChild(spotEffect,2);
      spotEffect:setPosition(cc.p(self.effectNode:getContentSize().width/2,self.effectNode:getContentSize().height/2));
   end

  if(#attackFishList > 0 and isMyFireAttackFish == true)then
      FishManager:getGameLayer():onCatchSmallBomFish(self,attackFishList,seatID);
  elseif FishManager:getGameLayer().players[seatID] and FishManager:getGameLayer().players[seatID].userInfo.isRobot then
      --机器人捕获
      -- self:performWithDelay(function()  RobotManager:catchSweepFish(seatID,self:getFishID(),attackFishList); end, 0.1)
  end

end

function Fish:fishDeadRemoveData()
  -- luaPrint("_fishType -------- "..self._fishType)
  self.isKilled = true;

  self.pathSpeed=nil;
  self.aimateSpeed=nil;

  if(self:getPhysicsBody())then
    self:getPhysicsBody():removeFromWorld();
  end

  if(self._parent.fishData and self._parent.fishData[self._fishID])then
    self._parent.fishData[self._fishID] = nil;
    self._parent.checkFishList[self._fishID]=nil;
  end

  if(self.updateFishScheduler)then
    self:stopAction(self.updateFishScheduler)
    self.updateFishScheduler = nil
  end
end

function Fish:setFishBoundingBox()
    -- local fishRect = self:getBoundingBox();
    local fishRect = self:getContentSize();
    -- if self._fishScale then
    --   fishRect.width = fishRect.width * self._fishScale;
    --   fishRect.height = fishRect.height * self._fishScale;
    --  end
    if self._fishKing or self._fishCQZS then
      if self.particle then
        local psize = self.particle:getContentSize();
        self.fishRect =cc.rect(fishRect.width/2-psize.width/2+10,fishRect.height/2-psize.height/2+10,psize.width*0.8,psize.height*0.8)
      else
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width,fishRect.height)
      end
    elseif self:checkIsSanyanSixi() then
        if self._fishType == 64  then
            self.fishRect =cc.rect(fishRect.width/2-130,fishRect.height/2-60,300,120)
        elseif self._fishType == 65  then
            self.fishRect =cc.rect(fishRect.width/2-170,fishRect.height/2-120,340,240)
        elseif self._fishType == 66  then
            self.fishRect =cc.rect(fishRect.width/2-210,fishRect.height/2-150,420,300)
        end
    elseif self._fishType == 41 then
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.35,fishRect.width*0.7,fishRect.height*0.3)
    elseif self._fishType == 42 then
        self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.4,fishRect.width*0.5,fishRect.height*0.2)
    elseif self._fishType == 43 then
      if self._flipY then
        self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.6,fishRect.width*0.8,fishRect.height*0.3)
      else
        self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.1,fishRect.width*0.8,fishRect.height*0.3)
      end
    elseif self._fishType == 44 then
     
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.35,fishRect.width*0.6,fishRect.height*0.3)
    elseif self._fishType == 1 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 4 then
      if self._flipY then
          self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.2,fishRect.width*0.5,fishRect.height*0.4)
      else
          self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.4,fishRect.width*0.5,fishRect.height*0.4)
      end
    elseif self._fishType == 5 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.25,fishRect.width*0.6,fishRect.height*0.5)
    elseif self._fishType == 6 then
      self.fishRect =cc.rect(fishRect.width*0.15,fishRect.height*0.2,fishRect.width*0.7,fishRect.height*0.6)
    elseif self._fishType == 7 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.3,fishRect.width*0.8,fishRect.height*0.4)
    elseif self._fishType == 8 then
      self.fishRect =cc.rect(fishRect.width*0.15,fishRect.height*0.3,fishRect.width*0.7,fishRect.height*0.4)
    elseif self._fishType == 9 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width*0.6,fishRect.height*0.6)
    elseif self._fishType == 10 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.2,fishRect.width*0.8,fishRect.height*0.6)
    elseif self._fishType == 11 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.25,fishRect.width*0.8,fishRect.height*0.5)
    elseif self._fishType == 12 then
      self.fishRect =cc.rect(fishRect.width*0.25,fishRect.height*0.3,fishRect.width*0.5,fishRect.height*0.4)
    elseif self._fishType == 13 or self._fishType == 45 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.25,fishRect.width*0.8,fishRect.height*0.5)
    elseif self._fishType == 14 or self._fishType == 46 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.2,fishRect.width*0.8,fishRect.height*0.5)
    elseif self._fishType == 15 or self._fishType == 47 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.3,fishRect.width*0.8,fishRect.height*0.4)
    elseif self._fishType == 16 or self._fishType == 48 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 17 or self._fishType == 49 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 18 or self._fishType == 50 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.8,fishRect.height*0.4)
    elseif self._fishType == 19 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.35,fishRect.width*0.7,fishRect.height*0.3)
    elseif self._fishType == 20 or self._fishType == 51 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.25,fishRect.width*0.6,fishRect.height*0.5)
    elseif self._fishType == 22 then
      self.fishRect =cc.rect(fishRect.width*0.15,fishRect.height*0.3,fishRect.width*0.7,fishRect.height*0.4)
    elseif self._fishType == 23 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width*0.6,fishRect.height*0.6)
   elseif self._fishType == 24 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 52 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.1,fishRect.width*0.5,fishRect.height*0.5)
    elseif self._fishType == 55 then
      self.fishRect =cc.rect(fishRect.width*0.1,fishRect.height*0.3,fishRect.width*0.85,fishRect.height*0.4)
    elseif self._fishType == 56 or self._fishType == 59 then
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    elseif self._fishType == 57 then
      self.fishRect =cc.rect(fishRect.width*0.25,fishRect.height*0.25,fishRect.width*0.5,fishRect.height*0.5)
    elseif self._fishType == 58 then
      self.fishRect =cc.rect(fishRect.width*0.3,fishRect.height*0.3,fishRect.width*0.6,fishRect.height*0.4)
    else
      self.fishRect =cc.rect(fishRect.width*0.2,fishRect.height*0.2,fishRect.width*0.6,fishRect.height*0.6)
    end

    

    -- local draw = cc.DrawNode:create()
    -- draw:setAnchorPoint(0,0)
    -- draw:setName("draw");
    -- self:addChild(draw, 1000)
    -- draw:setLocalZOrder(1000)
    -- draw:drawRect(cc.p(self.fishRect.x,self.fishRect.y), cc.p(self.fishRect.x+self.fishRect.width,self.fishRect.y+self.fishRect.height), cc.c4f(1,1,0,1))
    -- draw:drawRect(cc.p(fishRect.x,fishRect.y), cc.p(fishRect.x+fishRect.width,fishRect.y+fishRect.height), cc.c4f(1,0,0,1)) 
end

function Fish:killFish(isMyFireAttackFish,seatID,isPlay)
  if isMyFireAttackFish == nil then
    isMyFireAttackFish = false
  end

  if isPlay == nil then
    isPlay = true;
  end

  if(self.isKilled == true)then
    return
  end

  -- if isShowFishRect == true then
  --   if FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfish"..self._fishType) then
  --     FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfish"..self._fishType):removeFromParent();
  --   end

  --   if FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfishs"..self._fishType) then
  --     FishManager:getGameLayer().fishLayer:getChildByName(self._fishID.."drawfishs"..self._fishType):removeFromParent();
  --   end
  -- end

  --停止游动
  if self.pathSpeed then
    self:stopAction(self.pathSpeed);
    self.pathSpeed = nil
  end

  --加快鱼的动作
  if self._deadFrameCount <= 0 then
    self:setFishSpeed(0,5);
  end

  -- 隐藏阴影
  if self.fishShadow then
    self.fishShadow:setVisible(false);
    if self.fishShadow.particle then
      self.fishShadow.particle:removeSelf();
      self.fishShadow.particle = nil;
    end
    for k,v in pairs(self.fishShadow.bossChildren) do
      v:removeSelf();
    end
    self.fishShadow.bossChildren = {};

    for k,v in pairs(self.fishShadow.bossAnimate) do
      v:removeSelf();
    end
    self.fishShadow.bossAnimate = {};
  end

  --删除数据
  self:fishDeadRemoveData();

  self:setColor(self.originColor);
  self.curColor = self.originColor;

  --隐藏粒子效果
  if(self.particle)then
    self.particle:setVisible(false);
    self.particle:removeSelf();
    self.particle = nil;
  end

  local delayTimeDead = 1.5
  --死亡动画
  local armatureResult = nil;

  if isPlay == true then
    armatureResult = self:runSpecialDeath(isMyFireAttackFish,seatID);
  end  
    
  if(armatureResult)then
    delayTimeDead = 2.5
    -- self:runAction(cc.Sequence:create(
    --         cc.ScaleTo:create(0.1, 1.5)
    --     ))

    -- self:runAction(cc.Sequence:create(
    --             cc.DelayTime:create(1.3),
    --             cc.FadeOut:create(0.2)
    --         ))
  end

  --没有死亡动画
  local deadCallfunc = cc.CallFunc:create(function () self:fishDead(); end) ;
  local action = cc.DelayTime:create(delayTimeDead);
  self:runAction(cc.Sequence:create(action,cc.FadeOut:create(0.2),deadCallfunc));
  
  --检测任务
  if isMyFireAttackFish and isPlay == true then
    self:playDeadSound();
  end
end

function Fish:setFishID( fishID)
  self._fishID = fishID
end

function Fish:getFishID()
  if(self._fishID<0)then
    luaPrint("warning!  fishID <0  ")
  end
  return self._fishID;
end

function Fish:setFishSpeed(pathActionSpeed,aimateActionSpeed)
  self.curSpeed = pathActionSpeed;
  if self.pathSpeed and not tolua.isnull(self.pathSpeed) then
    self.pathSpeed:setSpeed(pathActionSpeed);
  end

  if self.bossDeadSpeed and not tolua.isnull(self.bossDeadSpeed) then
    self.bossDeadSpeed:setSpeed(pathActionSpeed);
  end

  if(self.aimateSpeed and not tolua.isnull(self.aimateSpeed))then
    self.aimateSpeed:setSpeed(aimateActionSpeed);
  end

  -- if(self.armatureObj)then
    -- self.armatureObj:getAnimation():setSpeedScale(aimateActionSpeed);
  -- end

  --阴影速度
  if(self.fishShadow)then
    -- self.fishShadow:setFishShadowSpeed(aimateActionSpeed)
  end
end

function Fish:updateFish(dt)
    if(self.isKilled == true)then
      luaPrint("Fish:updateFish(dt)   if(self.isKilled == true)then    意外");
      self:fishDead();
      return;
    end
    -- self:showFishID()
    local currentX,currentY=self:getPosition();

    if(currentX > 0 and currentX <= self.winSize.width  and currentY > 0 and  currentY <= self.winSize.height) then
        self.m_isClear = true;
        self._parent.checkFishList[self._fishID]=self;
    elseif(currentX < 0 or currentX > self.winSize.width  or currentY < 0 or  currentY > self.winSize.height) then
      if self.m_isClear == true then
        if(false == self:isFishInScreen(true))then
          self:fishDead();
          return;
        end
      else
        local ret = false;
        local dis = 20
        if currentX + self.size.width/2 < 0 then
          if currentX + self.size.width/2 < -dis then
            ret = true;
          end
        elseif currentX - self.size.width/2 > self.winSize.width then
          if currentX - self.size.width/2 - self.winSize.width > dis then
            ret = true;
          end
        elseif currentY + self.size.height/2 < 0 then
          if currentY + self.size.height/2 < -dis then
            ret = true;
          end
        elseif currentY - self.size.height/2 > self.winSize.height then
          if currentY - self.size.height/2 - self.winSize.height > dis then
            ret = true;
          end
        end

        if ret == true then
          return;
        end
      end
    end

    --冰冻    
    if(self._frozenTimer > 0)then
      self._frozenTimer = self._frozenTimer-dt;
      if(self._frozenTimer < 0)then
        self._frozenTimer = 0;
        self:resumeFrozen();
      end
    end

    --受攻击状态
    if self.inAttackTime then
      -- if self.armatureObj then
      --   self.armatureObj:setColor(cc.c3b(139, 0, 0));
      -- else
        self:setColor(cc.c3b(198, 88, 74));
      -- end
      self.curColor = cc.c3b(198, 88, 74);
      self.inAttackTime = self.inAttackTime - dt;
      if self.inAttackTime <= 0 then
        self.inAttackTime = nil;
      end
    else     
      -- if self.armatureObj then
      --   if self.armatureObj:getColor() ~= self.originColor then
      --     self.armatureObj:setColor(self.originColor);
      --   end
      -- else
        if self.curColor ~= self.originColor then
          self:setColor(self.originColor);
          self.curColor = self.originColor;
        end
      -- end
    end

    self:setWidgetTouchEnable()

    if self._frozenTimer > 0 then
      return
    end

    if(self._lastPostion.x~=currentX or self._lastPostion.y~=currentY)then
        local angle = math.atan2((currentY-self._lastPostion.y),(currentX-self._lastPostion.x));
        
        local rot = 0;
       
        rot=0 - (angle * 360)/(2*math.pi)
        
        local rotation = self:getRotation()

        if((rotation > 0 and rot < 0) or (rotation < 0 or rot > 0))then
          if self._fishType ~= FishType.FISH_GIFTEGGS and self._fishType ~= FishType.FISH_ROCKMONEYTREE and self._fishType ~= FishType.FISH_REDENVELOPES then
            self:setRotation(rot);
          else
            rot = rotation;
          end
        else
          rot = rotation - (rotation - rot) * 0.5;
          if self._fishType ~= FishType.FISH_GIFTEGGS and self._fishType ~= FishType.FISH_ROCKMONEYTREE and self._fishType ~= FishType.FISH_REDENVELOPES then
            self:setRotation(rot);
          else
            rot = rotation;
          end
        end

        self._lastPostion=cc.p(currentX,currentY);

        --同步阴影位置
        self:syncShadow(currentX,currentY,rot)
    end

-- if self:getChildByName("drawfish") then
-- self:getChildByName("drawfish"):removeSelf();
-- end
--     if self:getChildByName("drawfish") == nil then
--       local draw = cc.DrawNode:create()
--       draw:setAnchorPoint(0.5,0.5)
--       draw:setName("drawfish");
--       self:addChild(draw, 1000)
--       draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,1,0,1))
--       draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))
--     end
end

--同步阴影位置
function Fish:syncShadow(posX,posY,rotation)
  if(self.fishShadow and not tolua.isnull(self.fishShadow))then    
    if not self.fishShadow.rotation or self.fishShadow.rotation ~= rotation then
      self.fishShadow:setRotation(rotation)
      self.fishShadow.rotation = rotation
    end

    if(FLIP_FISH)then
      self.fishShadow:setPosition(cc.p(posX,posY+50));
    else
      self.fishShadow:setPosition(cc.p(posX,posY-50));
    end

    -- if self.particle then
    --   if self.fishShadow.particle then
    --     self.fishShadow.particle:setPosition(self.particle:getPosition());
    --   end
    -- end

    -- if self.fishShadow:isVisible() ~= self:isVisible() then
    --   self.fishShadow:setVisible(self:isVisible());
    -- end
  end
end

function Fish:setFlipRotate( flipY )
  if(flipY)then
    if self._fishType ~= FishType.FISH_GIFTEGGS and self._fishType ~= FishType.FISH_REDENVELOPES then
      if self._fishType == FishType.FISH_ROCKMONEYTREE then
        self:setFlippedY(false);
        self:setFlippedX(true);

        if self.particle then
          self.particle:setFlippedY(false)
          self.particle:setFlippedX(true)
        end
      else
          self:setFlippedY(true);
          self:setFlippedX(false);
          -- if self.animateSp then
          --   self.animateSp:setFlippedY(true)
          --   self.animateSp:setFlippedX(false)
          -- end

          if self.particle then
            self.particle:setFlippedY(true)
            self.particle:setFlippedX(false)
          end

          self._flipY=true;
          
          for k,v in pairs(self.bossChildren) do
            v:setFlippedY(true)
            v:setFlippedX(false)
          end   
      end
      self:correctPosFlip();
    end
  else
    self:setFlippedY(false);
    self:setFlippedX(false);
    
    -- if self.animateSp then
    --   self.animateSp:setFlippedY(false)
    --   self.animateSp:setFlippedX(false)
    -- end

    if self.particle then
      self.particle:setFlippedY(false)
      self.particle:setFlippedX(false)
    end

    for k,v in pairs(self.bossChildren) do
      v:setFlippedY(false)
      v:setFlippedX(false)
    end

    self._flipY=false;
  end

  self:updateWidgetPos();
end

function Fish:setFlipScreen( isflip )
  -- if self._fishType >= FishType.FISH_10 and self._fishType <= FishType.FISH_A then
  --   -- self:setFlippedY(isflip);
  -- end
end

function Fish:getCenter()
  local center = cc.p(self:getContentSize().width/2,self:getContentSize().height/2);

  return center;
end

--受到子弹攻击后
function Fish:setInAttack(bullet, isAttackSlow)
  local fishValid = self:isFishValid();
  if(fishValid and fishValid == true) and isAttackSlow == true then
    self.inAttackTime = 0.2;--0.2s
  end
  
  -- 增加大鱼被打中特效
  -- if self:checkIsBigFish() then
  --     local hitAni = self:getHitBigFishAnimation()
  --     if hitAni then
  --         hitAni:setPosition(self:getCenter())
  --         self:addChild(hitAni)
  --         hitAni:getAnimation():playWithIndex(0)
  --     end
  -- else
  --     self.inAttackTime = 2;--0.2s
  -- end

  -- if(bullet.bSetLockFishSlow and self.pathSpeed)then
  --   self._slowTimer=os.time()+3;
  --   self.pathSpeed:setSpeed(0.5);
  --   self.aimateSpeed:setSpeed(0.5);
  --   self.shadowSpeed:setSpeed(0.5);
  --   self:setColor(cc.c3b(120,120,225));
  --   self._isSlow=true;
  -- end

  -- self:playInAttackSound()
end

function Fish:frozen( delay )
  if(delay)then
    self._frozenTimer=delay;
  end

  self:setFishSpeed(0,1);
 
  self:setColor(cc.c3b(139, 0, 0));
  self.curColor = cc.c3b(139,0,0);
  self._isFrozen=true;
end

function Fish:resumeFrozen()  
  if(self._isFrozen ~= nil and self._isFrozen == false)then
    return;
  end

  --停止混沌珠效果
  if self.isSuck == true then
    self:stopActionByTag(2222);
  end

  if self.isCallFish == true then
    self:setFishSpeed(0.8,0.8);
  else
    self:setFishSpeed(1,1);
  end

  self:setColor(self.originColor);
  self.curColor = self.originColor;
  self._isFrozen=false;
  self._frozenTimer = 0;
end

function Fish:suck()
  local isMy = false;
  if FishManager:getGameLayer().chaoticCatchinfo and FishManager:getGameLayer().chaoticCatchinfo.chair_id==FishManager:getGameLayer().my:getSeatNo() then
    isMy = true;
  end

  self:setInAttack(nil,isMy);
  if self.isSuck then
    return;
  end

  self.isSuck = true;

  if self._isFrozen == true then
    return;
  end

  self:setFishSpeed(0.2,1);

  --减速动作
  local func = function()  
    local r = 0.02;
    local s = self.curSpeed-r;
    if s <= 0 then
      s = 0;
    end
    self:setFishSpeed(s,1);
    luaPrint(self._fishType.."  减速中 -------  "..s)
    if s <= 0 then
      self:stopActionByTag(2222);
    end
  end
  local action = schedule(self, func, 0.2)
  action:setTag(2222);
end

function Fish:resumeSuck()
  self.isSuck = false;

  if self._isFrozen == true then
    return;
  end

  self.inAttackTime = nil;
  self:stopActionByTag(2222);

  if self.isCallFish == true then
    self:setFishSpeed(0.8,0.8);
  else
    self:setFishSpeed(1,1);
  end
end

function Fish:runSpecialDeath(isMyFireAttackFish,seatID)
  local specDeath = nil

  if(self._fishType == FishType.FISH_ZHADAN)then--定屏
    specDeath = DataCacheManager:createEffect(BING_DONG_EFFECT)
    specDeath:playAction()
  -- elseif(self._fishType == FishType.FISH_ZHADAN)then--闪电鱼
  --   if(self._parent.fishData)then
  --     self:addFishLightningEffect(self._parent.fishData,isMyFireAttackFish,seatID);
  --   end
  elseif(self._fishType == FishType.FISH_DAZHADAN)then  --23 局部炸弹
    specDeath = DataCacheManager:createEffect(JUBU_EFFECT)
    specDeath:playAction()
  elseif(self._fishType == FishType.FISH_FROZEN)then  --24 全屏炸弹
    specDeath = DataCacheManager:createEffect(QUAN_PING_EFFECT)
    specDeath:playAction()
  end

  --大爆炸
  if(self._fishType >= 25 and self._fishType <= 30)then
    specDeath = DataCacheManager:createEffect(FISH_CATCH_BIG_EFFECT)
    specDeath:playAction()
  --小爆炸
  elseif(self._fishType >= 15 or self._fishType >= 20)then
    -- specDeath = DataCacheManager:createEffect(FISH_CATCH_SMALL_EFFECT)
    -- specDeath:playAction()
  elseif self:checkIsBoss() then
    -- specDeath = sp.SkeletonAnimation:create("effect/boss/bossdead.json", "effect/boss/bossdead.atlas");
    -- local name = {"guafuxiezisi","jinjiadujiaoshousi","dongfangjiaolongsi","shenniaohuofenghuangsi"};
    -- specDeath:setAnimation(self._fishType-40,name[self._fishType-40], false);
    -- specDeath:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function() specDeath:removeFromParent(); end)))
  end

  if self._deadFrameCount > 0 then
    local fileName = "jcby_fish_"..self._fishType.."_d%d.png"
    local frames = display.newFrames(fileName, 1, self._deadFrameCount);
    local activeFrameAnimation = display.newAnimation(frames, self._activeFrameDelay);
    self:setSpriteFrame(frames[1]);
    local animate= cc.Animate:create(activeFrameAnimation);
    local aimateAction=cc.Repeat:create(animate,999999);
    self:runAction(aimateAction);
  end

  local txname = {"siwangtexiaoyiji","siwangtexiaoerji","siwangtexiaosanji","siwangtexiaosiji"}
  local skeleton_animation = createSkeletonAnimation("siwangtexiao", "fishing/fishdead/siwangtexiao.json", "fishing/fishdead/siwangtexiao.atlas");
  if skeleton_animation then
    self:addChild(skeleton_animation);
    local fishsize = self:getContentSize();
    skeleton_animation:setPosition(cc.p(fishsize.width/2,fishsize.height/2));
  
    local index = 0;
    if self._fishMult <= 10 then
      index = 1;
    elseif self._fishMult <=30 then
      index = 2;
    elseif self._fishMult <=320 then
      index = 3;
    elseif self._fishMult <=500 then
      index = 4;
    end

    skeleton_animation:setAnimation(1,txname[index], false);
    performWithDelay(self,function() skeleton_animation:removeSelf() end,1)
  end
  -- self.skeleton_animation = skeleton_animation;
  self.specDeath = specDeath;
  if specDeath then
    specDeath:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2));   
    specDeath:setAnchorPoint(cc.p(0.5,0.5));
    self:addChild(specDeath);
    return true;
  end

  return false;
end

function Fish:quickGoOut()
  if(self.isKilled == true)then
    return;
  end

  if(self._isFrozen == true)then
    self:resumeFrozen();
  end

  self.isMatrix = true;

  if(self._isSlow)then
    self._isSlow=false;
    self._slowTimer=-1;
  end

  -- self:fishDeadRemoveData();

  -- self:generateFrameAnimation();
  --local animate= cc.Animate:create(self._activeFrameAnimation);
    
  local callFunc = cc.CallFunc:create(function () self:fishDead(); end) ;

  local winSize = cc.Director:getInstance():getWinSize();

  local self_x,self_y = self:getPosition();

  local end_Y=-20;
  if(self_y>winSize.height-self_y)then
    end_Y=winSize.height+20;
  end
  local end_X=self_x+math.random(0,800)-400;

  local result_X=(end_X-self_x)/3+self_x;
  local result_Y=(end_Y-self_y)/3+self_y;

  local bezier ={
        cc.p(result_X,result_Y),
        cc.p(result_X,result_Y),
        cc.p(end_X, end_Y)
    };

  local bezierTo = cc.BezierTo:create(0.8, bezier);
  local fadeOut =  cc.FadeOut:create(0.8);
  self.pathSpeed=cc.Sequence:create(cc.Spawn:create(fadeOut,bezierTo),callFunc);
  --fishaction = cc.Spawn:create(cc.Repeat:create(animate,100),getOutAction);
  --fishaction = cc.Spawn:create(getOutAction);
  self:runAction(self.pathSpeed);
  self.pathSpeed = nil;

end

function Fish:checkIsBigFish()
  if(self._fishType>=FishType.FISH_SHIBANYU 
    and self._fishType ~= FishType.FISH_ZHADAN
    and self._fishType ~= FishType.FISH_DAZHADAN
    and self._fishType ~= FishType.FISH_FROZEN)
  then
    return true
  end

  return false;
end

function Fish:checkIsSanyanSixi()
  local fishType = self._fishType;

  if fishType == FishType.FISH_KIND_64 or fishType == FishType.FISH_KIND_65 or fishType == FishType.FISH_KIND_66 then
    return true;
  end

  return false;
end

function Fish:checkIsBoss()
  if self._fishType == 21 then
    return true;
  end

  return false;
end

--是否可以炸弹鱼炸死
function Fish:checkIsBombKilled()
  -- if self._fishType > FishType.FISH_JIANYU then
  --   return false;
  -- end

  return true;
end

function Fish:checkIsLiQuan()
  -- if self._fishType == 25 or self._fishType == 26 then
  --   return true
  -- end

  return false;
end

function Fish:playInAttackSound()
    -- local time = 0
    -- if self._fishType == 5 then
    --     time = 1
    -- elseif self._fishType == 6 then
    --     time = 2
    -- elseif self._fishType == 7 then
    --     time = 2
    -- elseif self._fishType == 8 then
    --     time = 2
    -- elseif self._fishType == 10 then
    --     time = 4
    -- elseif self._fishType == 11 then
    --     time = 2
    -- elseif self._fishType == 12 then
    --     time = 3
    -- elseif self._fishType == 13 then
    --     time = 2
    -- elseif self._fishType == 14 then
    --     time = 4
    -- elseif self._fishType == 15 then
    --     time = 3
    -- elseif self._fishType == 17 then
    --     time = 3
    -- elseif self._fishType == 18 then
    --     time = 2
    -- elseif self._fishType == 19 then
    --     time = 4
    -- end

    -- local filePath = "sound/fish_hit_"..self._fishType..".mp3"
    -- if self._fishType >= 5 and self._fishType <= 19 and cc.FileUtils:getInstance():isFileExist(filePath) and 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
    --     if Is_Playing_Sound then
    --     else
    --         Is_Playing_Sound = true
    --         audio.playSound(filePath)
    --         self:performWithDelay(function() Is_Playing_Sound = false; end, time)
    --     end
    -- end
end

function Fish:playDeadSound()
    local soundType = self._fishType - 1

    if self._deadSoundCount > 0 then
       local filePath = "sound/fish"..soundType.."_"..math.random(1, self._deadSoundCount)..".mp3";
        luaPrint("播放音效  "..filePath)
        audio.playSound(filePath)
    elseif self:checkIsBoss() then
      -- local filePath = "sound/boss/boss"..(soundType+1).."_3.mp3";
      -- luaPrint("播放音效  "..filePath)
      -- audio.playSound(filePath)
    end
end

function Fish:getFishPos()
  local x,y = self.effectNode:getPosition()

  local worldPos = self:convertToWorldSpace(cc.p(x,y))
  return worldPos;
end

function Fish:correctSetPosition(offsetPosX,offsetPosY)
  offsetPosY = offsetPosY or 0;

  if(not self._flipY)then
    offsetPosX = offsetPosX*-1;
  end

  if self._flipY then
    offsetPosY = offsetPosY*-1;
  end
  --偏移量
  self.offsetPosx = offsetPosX;
  self.offsetPosy = offsetPosY;
end

--鱼位置矫正
function Fish:correctPos()
    if(self._fishType == 7)then
      self:correctSetPosition(-15)
    elseif(self._fishType == 8)then
      self:correctSetPosition(-10,10)
    elseif(self._fishType == 12)then
      self:correctSetPosition(-15)
    elseif(self._fishType == 16)then
      self:correctSetPosition(-20)
    elseif(self._fishType == 17)then
      self:correctSetPosition(0)
    -- elseif(self._fishType == 20)then
    --   self:correctSetPosition(-30)
    elseif self._fishType == 38 then
      self:correctSetPosition(-0,0);
    elseif self._fishType == 39 then
      self:correctSetPosition(-0,0);
    -- elseif self._fishType == 19 then
    --   self:correctSetPosition(-20,0);
    elseif self._fishType == 43 then
      self:correctSetPosition(0,-110);
    elseif self._fishType == 44 then
      self:correctSetPosition(-60,0);
    -- elseif self._fishType == 22 then
    --   self:correctSetPosition(-25,0);
    -- elseif self._fishType == 23 then
    --   self:correctSetPosition(-10,-35);
    -- elseif self._fishType == 24 then
    --   self:correctSetPosition(-30,0);
    elseif self._fishType == 53 then
      self:correctSetPosition(0,-20);
    elseif self._fishType == 56 then
      self:correctSetPosition(-50,0);
    else
      self.offsetPosx = 0;
      self.offsetPosy = 0;
    end
end

--翻转后的鱼位置矫正
function Fish:correctPosFlip()
  if self._flipY ~= true then
    return;
  end

  if self.offsetPosx ~= 0 and self.offsetPosy ~= 0 then
    self:correctSetPosition(-self.offsetPosx,self.offsetPosy);
  end
  
  if(self._fishType == 17)then
      self:correctSetPosition(0,10);
  elseif self._fishType == 43 then
    self:correctSetPosition(0,-220);
  elseif self._fishType == 44 then
    self:correctSetPosition(20,0);
  elseif self._fishType == 56 then
      self:correctSetPosition(10,0);
  -- elseif self._fishType == 23 then
  --   self:correctSetPosition(0,-70);
  end
  
  self:updateEffectPos();
end

function Fish:updateEffectPos()
  self.effectNode:setPositionX(self.effectNode:getPositionX()+self.offsetPosx);
  self.effectNode:setPositionY(self.effectNode:getPositionY()+self.offsetPosy);
  if self.fishIDText then
    self.fishIDText:setPositionY(0);
  end
  
  if self.fishWidget then
    self.fishWidget:setPositionY(self.fishWidget:getPositionY());
  end

  if self.body and (self._fishType == 17 or self._fishType == 8 or self._fishType == 15 or self._fishType == 43 or self._fishType == 21) then
    self.body:setRotationOffset(180);
  end

  if self.body and self:checkIsBoss() then
    if self._fishType == 44 then
      self.body:setPositionOffset(cc.p(0,30));
    end    
  end

  if self.fishMultText then
    self.fishMultText:setRotation(-180);
    self.fishMultText:setPositionY(-self:getContentSize().height/2)
  end
end

--鱼是否可以锁定
function Fish:isFishCanLock()  
  return true
end

return Fish