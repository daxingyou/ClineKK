local SpecialFish = class("SpecialFish", require("jinchanbuyu.game.core.Fish"))
local FishPath = require("jinchanbuyu.game.core.FishPath"):getInstance();

function SpecialFish:ctor(fishtype)
	self.super.ctor(self,fishtype);

	self.bScale = 1.3;--底圈缩放倍数

	self:loadAnimate();

	self.checkGenerateCompete = performWithDelay(self, function() self:checkFish(); end, 0.2);
end

function SpecialFish:loadAnimate()
	-- if ccs.ArmatureDataManager:getInstance():getAnimationData("bigFishAnimation") == nil then
        -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("effect/fishAnimation/bigFishAnimation.ExportJson");
    -- end
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test1.plist", "jinchanbuyu/fishing/fish/jcby_fish_test1.png");
	display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test2.plist", "jinchanbuyu/fishing/fish/jcby_fish_test2.png");
	-- display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test3.plist", "jinchanbuyu/fishing/fish/jcby_fish_test3.png");
	-- display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test4.plist", "jinchanbuyu/fishing/fish/jcby_fish_test4.png");
end

function SpecialFish:initSpecialFish()
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

    for k,v in pairs(self.bossChildren) do
      v:setFlippedY(self:isFlippedY())
      v:setFlippedX(self:isFlippedX())
    end

    self.size = self.realSize;
    self:setFishBoundingBox();
    self:updateFishFrame()
end

function SpecialFish:updateFishFrame()
    display.loadSpriteFrames("jinchanbuyu/fishing/fish/jcby_fish_test1.plist", "jinchanbuyu/fishing/fish/jcby_fish_test1.png");
    local size = self:getContentSize();
  
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

function SpecialFish:checkFish()
	if self._fishIsAnimate == true then
		if self.checkGenerateCompete then
			self:stopAction(self.checkGenerateCompete);
			self.checkGenerateCompete = nil;
		end
		self:initSpecialFish();
	end
end

function SpecialFish:createEryuan()
	
	self:createRandEryuan();
	performWithDelay(self,function() self:createSpecFishShadow(); end,0.3)
end

function SpecialFish:createRandEryuan()
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


function SpecialFish:createSanyuan()
	self:createRandSanyuan();
	performWithDelay(self,function() self:createSpecFishShadow(); end,0.3)
end



function SpecialFish:createRandSanyuan()
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

function SpecialFish:createSixi()
	self:createRandSixi();
	performWithDelay(self,function() self:createSpecFishShadow(); end,0.3)
end

function SpecialFish:createRandSixi()
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

return SpecialFish;