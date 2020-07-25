local GetRewardLayer = class("GetRewardLayer", BaseWindow)

function GetRewardLayer:create(callback,data)
	return GetRewardLayer.new(callback,data);
end

function GetRewardLayer:ctor(callback,data)
	self.super.ctor(self, true, true);

	self.callback = callback;
	self.data = clone(data);
	luaDump(self.data,"data")

	self:initUI()
end

function GetRewardLayer:onExit()
	self.super.onExit(self);
	if self.callback then
		self.callback();
	end
end

function GetRewardLayer:initUI()
	local size = cc.Director:getInstance():getWinSize();

	local skeleton_animation = createSkeletonAnimation("game/effect/gongxihuode","game/effect/gongxihuode.json", "game/effect/gongxihuode.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(size.width/2,size.height/2);	
		self:addChild(skeleton_animation);

		local name = {"gongxihuode","gongxihuode_jinbi","gongxihuode_quan"};
		local index = 0;
		if self.data.fish_score > 0 and self.data.iLotteries > 0 then
			index = 1;
		elseif self.data.iLotteries > 0 then
			index = 3;
		elseif self.data.fish_score > 0 then
			index = 2;
		end

		skeleton_animation:setAnimation(1,name[index], false);
	

		self.data.fish_score = goldConvert(self.data.fish_score)

		if index == 1 then
			local label = FontConfig.createWithCharMap(self.data.iLotteries,"game/rewardNum.png",20,25,"+",{{"万",":;"}});
			label:setPosition(cc.p(0.5,0.5));
			label:setPosition(size.width*0.4-20, size.height/2-20);
			self:addChild(label);

			local label = FontConfig.createWithCharMap(self.data.fish_score,"game/rewardNum.png",20,25,"+",{{"万",":;"}});
			label:setPosition(cc.p(0.5,0.5));
			label:setPosition(size.width*0.6+20, size.height/2-20);
			self:addChild(label);
		elseif index == 2 then
			local label = FontConfig.createWithCharMap(self.data.fish_score,"game/rewardNum.png",20,25,"+",{{"万",":;"}});
			label:setPosition(cc.p(0.5,0.5));
			label:setPosition(size.width*0.5, size.height/2-20);
			self:addChild(label);
		elseif index == 3 then
			local label = FontConfig.createWithCharMap(self.data.iLotteries,"game/rewardNum.png",20,25,"+",{{"万",":;"}});
			label:setPosition(cc.p(0.5,0.5));
			label:setPosition(size.width*0.5, size.height/2-20);
			self:addChild(label);
		end
	end

	self:delayCloseLayer(2);
end

return GetRewardLayer;
