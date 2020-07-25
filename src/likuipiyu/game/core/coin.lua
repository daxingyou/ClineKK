local Coin = class( "Coin", function() return display.newSprite(); end )
local DataCacheManager = require("likuipiyu.game.core.DataCacheManager"):getInstance();

function Coin:ctor(isLiquan, coinTag)
	self:setDefaultData();
	self.isLiquan=isLiquan;
	self.coinTag = coinTag;

	self:initGui()
end

function Coin:resetData(isLiquan, coinTag)
	self:setDefaultData();
	self.aimateAction = nil;
	self.isLiquan=isLiquan;
	self.coinTag = coinTag;
	self:initGui()
end

function Coin:setDefaultData()
	self.filp = 1;
	self.paths = {};
end

function Coin:addLinePathTo(endPos,filp)
	self.endPos = endPos; 
	self.filp = filp;
end

function Coin:addAction(action)
	table.insert(self.paths, action);
end

function Coin:initGui()
	self:removeAllChildren();
	display.loadSpriteFrames("likuipiyu/fishing/scene/gold_lkpy.plist", "likuipiyu/fishing/scene/gold_lkpy.png")
	display.loadSpriteFrames("likuipiyu/fishing/scene/lkpy_other_gold.plist", "likuipiyu/fishing/scene/lkpy_other_gold.png")
	local frames = nil;
	if self.isLiquan == true then
	  -- frames = display.newFrames("ani_huafei_%d.png", 1, 12);
	  -- self:setScale(0.6)
	  	local goodsIcon = ccui.ImageView:create("game/quan.png");
		self:addChild(goodsIcon);
	else
		if self.coinTag == 1 then
			frames = display.newFrames("lkpy_goldf%d.png", 1, 5);
      	elseif self.coinTag == 2 then 
       		frames = display.newFrames("lkpy_other_goldf%d.png", 1, 5);
       	else
       		frames = display.newFrames("ani_chouma_%d.png", 1, 8);
		end
	end	

	if frames then
		self._activeFrameAnimation = display.newAnimation(frames, 0.1);
		local animate= cc.Animate:create(self._activeFrameAnimation);
	    self.aimateAction=cc.RepeatForever:create(animate);
	    self.aimateAction:retain()
	end	
end

function Coin:goCoin(delay)
	-- self:initGui()
	if self.aimateAction then
		self:runAction(self.aimateAction);
		self.aimateAction:release();
	end 	
 	
 	-- table.insert(self.paths, cc.DelayTime:create(delay/2));

	local jumpAction = cc.JumpBy:create(0.6,cc.p(0,0),80*self.filp, 2);--cc.p(self:getPositionX(),self:getPositionY())
	-- local jumpAction = cc.Shaky3D:create(2, cc.size(10,10), 10, false);
	table.insert(self.paths, jumpAction);

	table.insert(self.paths, cc.DelayTime:create(delay));

    local moveTo = cc.MoveTo:create(1.5, self.endPos);
	local easeAction = cc.EaseSineIn:create(moveTo);
	
    table.insert(self.paths, easeAction);

    local sequence = transition.sequence(
        {
            cc.Sequence:create(self.paths),
            cc.CallFunc:create(function() self:coinDead();end)
        }
    )
    self:runAction(sequence);
end

function Coin:deleteNode( )
	if self.aimateAction then
		self.aimateAction:release()
	end
	self:removeSelf()
end

function Coin:coinDead()
	--缓存托管
	DataCacheManager:removeCoin(self);
end

return Coin;
