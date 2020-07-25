local BossFish = class("BossFish", require("fishing.game.core.Fish"))
local FishPath = require("fishing.game.core.FishPath"):getInstance();
local FishManager = require("fishing.game.core.FishManager"):getInstance();

function BossFish:ctor(fishtype)
	self.super.ctor(self,fishtype);

	self.updateBoss = schedule(self, function() self:updateBossMusic(); end, 0.5);
end

function BossFish:updateBossMusic()
	if(self.m_isClear == true)then--出现在屏幕之后
		if(false ~= self:isFishInScreen())then
			self:startPlayMusic();
		else
			self:stopAction(self.updateBoss);
			self:stopAction(self.playSchedule);
			self.playSchedule = nil;
		end
	end
end

function BossFish:startPlayMusic()
	if self.playSchedule == nil then
		performWithDelay(self,function() self:playBossMusic(); end, 2);
		self.playSchedule = schedule(self,function() self:playBossMusic(); end, 15)
		local seq = nil;
		if self.pathid == "T" then
			-- performWithDelay(self,function() self:playWillDeadAnimate(); end, 30);
			seq = cc.Sequence:create(cc.DelayTime:create(30),cc.CallFunc:create(function() self:playWillDeadAnimate(); end));
		elseif self.pathid == "k" then
			-- performWithDelay(self,function() self:playWillDeadAnimate(); end, 20);
			seq = cc.Sequence:create(cc.DelayTime:create(20),cc.CallFunc:create(function() self:playWillDeadAnimate(); end));
		else
			-- performWithDelay(self,function() self:playWillDeadAnimate(); end, 30);
			seq = cc.Sequence:create(cc.DelayTime:create(20),cc.CallFunc:create(function() self:playWillDeadAnimate(); end));
		end

		local speed = cc.Speed:create(seq,1);
		self:runAction(speed);
		self.bossDeadSpeed = speed;
	end
end

function BossFish:playBossMusic()
	local rd = FishPath:fakeRandomS(math.ceil(os.time()/60), 2,463)%2;

	if rd == self.rd then
		rd = (rd + 1)%2;
	end

	self.rd = rd;

	local name = "sound/boss/boss"..self._fishType.."_"..(rd +1)..".mp3";
	audio.playSound(name, false);
end

function BossFish:playWillDeadAnimate()
	if self.bossDeadSpeed then
		self.bossDeadSpeed = nil;
	end
	
	FishManager:getGameLayer():showBossDeadWarning();
end

return BossFish;
