
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

	self.Pos ={cc.p(450,150),cc.p(80,360),cc.p(330,650),cc.p(950,650),cc.p(1200,360)}
end

--创建筹码--创建类型，筹码类型，下注类型(下注的区域1-8)
function ChipNodeManager:ChipCreate(endnum,num)
	luaPrint("创建筹码",endnum,num)
	if endnum == nil or endnum <1 or endnum>5 then
		return;
	end
	display.loadSpriteFrames("dezhoupuke/image/gold.plist", "dezhoupuke/image/gold.png");
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
	self:setPosition(cc.p(640,500));
	self.tableLayer.Panel_anim:addChild(self,5);

    self:runAction(cc.Sequence:create(cc.MoveTo:create(1.1,self.Pos[endnum]),cc.CallFunc:create(function ()
		self:removeFromParent();
	end)));
    
end


return ChipNodeManager;