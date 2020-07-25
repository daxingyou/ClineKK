
local ChipNodeManager = class("ChipNodeManager", function() return display.newSprite(); end);

function ChipNodeManager:ctor(tableLayer)
	self:init(tableLayer)
end

function ChipNodeManager:init(tableLayer)

	self.tableLayer = tableLayer
	self:initData();
	
end

function ChipNodeManager:initData()
	self.ChipNodeTable = {};

end

--创建筹码--创建类型，筹码类型，下注类型(下注的区域1-8)
function ChipNodeManager:ChipCreate(beginPos,endPos)

	display.loadSpriteFrames("shidianban/gold.plist", "shidianban/gold.png");
	local frames = display.newFrames("coin_gold_%d.png", 1, 15);
	if frames then
		self._activeFrameAnimation = display.newAnimation(frames, 0.05);
		local animate= cc.Animate:create(self._activeFrameAnimation);
	    self.aimateAction=cc.RepeatForever:create(animate);
	    
	end	
	self:setScale(0.5);
	if self.aimateAction then
		self:runAction(self.aimateAction);
	end 
	self:setPosition(beginPos);
	self.tableLayer.Node_goldMove:addChild(self,5);

	local goldMoveLength = cc.pGetDistance(beginPos,endPos);
	local goldSpeed = 800;

    self:runAction(cc.Sequence:create(cc.MoveTo:create(goldMoveLength/goldSpeed,endPos),cc.CallFunc:create(function ()
		self:removeFromParent();
	end)));
    
end


return ChipNodeManager;