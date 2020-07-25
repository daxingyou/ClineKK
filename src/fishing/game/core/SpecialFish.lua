local SpecialFish = class("SpecialFish", require("fishing.game.core.Fish"))
local FishPath = require("fishing.game.core.FishPath"):getInstance();

function SpecialFish:ctor(fishtype)
	self.super.ctor(self,fishtype);

	self.bScale = 0.7;--底圈缩放倍数

	self:loadAnimate();

	self.checkGenerateCompete = performWithDelay(self, function() self:checkFish(); end, 0.2);
end

function SpecialFish:loadAnimate()
	-- if ccs.ArmatureDataManager:getInstance():getAnimationData("bigFishAnimation") == nil then
        -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("effect/fishAnimation/bigFishAnimation.ExportJson");
    -- end
    display.loadSpriteFrames("fishing/fishing/fish/fish_test1.plist", "fishing/fishing/fish/fish_test1.png");
	display.loadSpriteFrames("fishing/fishing/fish/fish_test2.plist", "fishing/fishing/fish/fish_test2.png");
	display.loadSpriteFrames("fishing/fishing/fish/fish_test3.plist", "fishing/fishing/fish/fish_test3.png");
	display.loadSpriteFrames("fishing/fishing/fish/fish_test4.plist", "fishing/fishing/fish/fish_test4.png");
end

function SpecialFish:initSpecialFish()
	--大三元
	if self._fishType == FishType.FISH_ZHENZHUBEI or self._fishType == FishType.FISH_XIAOFEIYU or self._fishType == FishType.FISH_ALILAN then
        self:createSanyuan();
    --大四喜
    elseif self._fishType == FishType.FISH_ZHADANFISH or self._fishType == FishType.FISH_NORMAL_TYPEMAX or self._fishType == FishType.FISH_WORLDBOSS then
    	self:createSixi();
    end

    for k,v in pairs(self.bossChildren) do
      v:setFlippedY(self:isFlippedY())
      v:setFlippedX(self:isFlippedX())
    end

    self.size = self.realSize;
    self:setFishBoundingBox();
end

function SpecialFish:updateFishFrame()
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

function SpecialFish:checkFish()
	if self._fishIsAnimate == true then
		if self.checkGenerateCompete then
			self:stopAction(self.checkGenerateCompete);
			self.checkGenerateCompete = nil;
		end
		self:initSpecialFish();
	end
end

function SpecialFish:createSanyuan()
	local rd = FishPath:fakeRandomS(self.path*self._fishType, 2,198)%80;--math.random(1,1000);

	if rd%2 == 0 then
		-- if self.animateSp then
		-- 	self.animateSp:setVisible(false);
		-- end
		
		if self.fishShadow then
			self.fishShadow:setVisible(false);
		end

		self.isLine = true;
		self:createLineSanyuan();
	else
		self.isLine = false;
		self:createRandSanyuan();
	end

	performWithDelay(self,function() self:createSpecFishShadow(rd%2 == 0); end,0.3)
end

--直线
function SpecialFish:createLineSanyuan()
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

    self:addPhysicsBody(cc.size(t.width*3,t.height));
    self:addFishWidget(cc.size(t.width*3,t.height));

    self.realSize = cc.size(t.width*3,t.height);
end

function SpecialFish:createRandSanyuan()
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

function SpecialFish:createSixi()
	local rd = FishPath:fakeRandomS(self.path*self._fishType, 12,398)%210;--math.random(1,1000);

	if rd%2 == 0 then
		-- if self.animateSp then
		-- 	self.animateSp:setVisible(false);
		-- end

		if self.fishShadow then
			self.fishShadow:setVisible(false);
		end

		self:updateFishFrame();		
		self.isLine = true;
		self:createLineSixi();
		-- local draw = cc.DrawNode:create()
  --     draw:setAnchorPoint(0,0)
  --     draw:setName("draw");
  --     self:addChild(draw, 1000)

      -- draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,0,0,1))
      -- draw:drawPoint((cc.p(0,0)), 20, cc.c4f(1,1,0,1))
	else
		self.isLine = false;
		-- local size = self:getContentSize();
		--  local draw = cc.DrawNode:create()
  --     draw:setAnchorPoint(0,0)
  --     draw:setName("draw");
  --     self:addChild(draw, 1000)

      -- draw:drawRect(cc.p(0,0), cc.p(size.width,size.height), cc.c4f(1,0,0,1))
      -- draw:drawPoint((cc.p(0,0)), 10, cc.c4f(1,1,0,1))
      -- draw:drawPoint((cc.p(size.width/2,size.height/2)), 10, cc.c4f(1,1,0,1))
      -- draw:drawPoint((cc.p(size.width,size.height)), 10, cc.c4f(1,1,0,1))
		self:createRandSixi();
	end

	performWithDelay(self,function() self:createSpecFishShadow(rd%2 == 0); end,0.3)
end

function SpecialFish:createLineSixi()
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

    self:addPhysicsBody(cc.size(t.width*4,t.height));
    self:addFishWidget(cc.size(t.width*4,t.height));
    self.effectNode:setPosition(x,y);

    self.realSize = cc.size(t.width*4,t.height);
end

function SpecialFish:createRandSixi()
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

return SpecialFish;