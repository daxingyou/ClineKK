
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

	self.Pos ={cc.p(100,80),cc.p(80,360),cc.p(294,650),cc.p(1015,650),cc.p(1200,360)}
end

--创建筹码--创建类型，筹码类型，下注类型(下注的区域1-8)
function ChipNodeManager:ChipCreate(startnum,endnum,num)
	luaPrint("创建筹码",startnum,endnum,num)
	if startnum == nil or endnum == nil then
		return;
	end
	display.loadSpriteFrames("qiangzhuangniuniu/gold.plist", "qiangzhuangniuniu/gold.png");
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
	self:setPosition(self.Pos[startnum]);

	self.tableLayer.Node_gold:addChild(self,5);

    self:runAction(cc.Sequence:create(cc.MoveTo:create(1.1,self.Pos[endnum]),cc.CallFunc:create(function ()
		self:removeFromParent();
	end)));
    
end


return ChipNodeManager;