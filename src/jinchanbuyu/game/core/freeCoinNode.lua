local freeCoinNode = class("freeCoinNode", BaseNode)

function freeCoinNode:ctor(showType,time,callBack)
	if time == 0 then
		time = 1
	end

	self.showType = showType
	self.time = time or 1;--倒计时时间

	self.timeText = nil;

	self.callBack = callBack;

	if self.time > 0 then
		self.status = 1;
	else
		self.status = 0;
	end

	self:createUI();
end

function freeCoinNode:cleanScheduler()
	luaPrint("倒计时页面  退出")
	if self.updateScheduler then
		self:stopAction(self.updateScheduler);
		self.updateScheduler = nil
	end
end

function freeCoinNode:createUI()
	if self.status == 1 then
		if self.showType == 1 then
			local coinBg = ccui.ImageView:create("hall/relief/chestClose.png");
			self:addChild(coinBg);

			local timeBg = ccui.ImageView:create("hall/relief/timerBg.png");
			timeBg:setPosition(coinBg:getContentSize().width/2,20);	   
			coinBg:addChild(timeBg);

			local timeText = ccui.Text:create(self:formatTime(),FONT_PTY_TEXT,20);
			timeText:setPosition(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2);
			timeBg:addChild(timeText);
			self.timeText = timeText;
		else
			local coinBg = ccui.ImageView:create("hall/relief/freeGoldBg.png");
			coinBg:setScale9Enabled(true);
			coinBg:setContentSize(300,80)
			self:addChild(coinBg);

			local chest = ccui.ImageView:create("hall/relief/chestClose.png");
			chest:setPosition(70,coinBg:getContentSize().height/2+15);
			coinBg:addChild(chest);

			local freeCoin = ccui.ImageView:create("hall/relief/freeGold.png");
			freeCoin:setPosition(chest:getContentSize().width/2,0);
			freeCoin:setAnchorPoint(0.5,0);
			chest:addChild(freeCoin);

			local timeText = ccui.Text:create(self:formatTime(),FONT_PTY_TEXT,20);
			timeText:setPosition(coinBg:getContentSize().width*0.7,coinBg:getContentSize().height/2);
			coinBg:addChild(timeText);
			self.timeText = timeText;
		end

		self:cleanScheduler()

		self.updateScheduler = schedule(self, function() self:startTimer(1.0) end, 1.0)
	else		
		if self.showType == 1 then
			local coinBg = ccui.ImageView:create("hall/relief/chestOpen.png");
			coinBg:setPositionY(coinBg:getPositionY()+10)
			coinBg:setTouchEnabled(true)
			self:addChild(coinBg);
			coinBg:addTouchEventListener(
				function (sender,eventType)
					if self.isClose == true then
						return;
					end

					if eventType == ccui.TouchEventType.began then
						sender:setScale(1.05);
					elseif eventType == ccui.TouchEventType.canceled then
						sender:setScale(1);
					elseif eventType == ccui.TouchEventType.ended then
						sender:setScale(1);
						performWithDelay(self, function() self:close(); end, 0.1);
						--发送领取命令
						self.callBack();
						self.isClose = true;
					end
			end
			)

			local timeBg = ccui.ImageView:create("hall/relief/timerBg.png");
			timeBg:setPosition(coinBg:getContentSize().width/2,20);	   
			coinBg:addChild(timeBg);

			local timeText = ccui.Text:create("点击可领取",FONT_PTY_TEXT,20);
			timeText:setPosition(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2);
			timeBg:addChild(timeText);

			local armatureObj =  createArmature("hall/eff_icon_tongyong0.png","hall/eff_icon_tongyong0.plist","hall/eff_icon_tongyong.ExportJson")
			armatureObj:getAnimation():playWithIndex(0);
			armatureObj:setPosition(coinBg:getContentSize().width/2,coinBg:getContentSize().height/2);
			coinBg:addChild(armatureObj);

			local em = cc.ParticleSystemQuad:create("hall/lizi_icon_tongyong.plist");
			em:setPosition(coinBg:getContentSize().width/2,coinBg:getContentSize().height/2);
			coinBg:addChild(em);
		else
			local light = ccui.ImageView:create("hall/relief/reliefLight.png");
			light:setScale9Enabled(true);
			light:setContentSize(320,90) 	
			self:addChild(light);
			light:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.8),cc.FadeIn:create(0.8))));

			local coinBg = ccui.ImageView:create("hall/relief/freeGoldBg.png");
			coinBg:setScale9Enabled(true);
			coinBg:setContentSize(300,80) 	
			self:addChild(coinBg);
			coinBg:setTouchEnabled(true)
			coinBg:addTouchEventListener(
				function (sender,eventType)
					if self.isClose == true then
						return;
					end

					if eventType == ccui.TouchEventType.began then
						sender:setScale(1.05);
					elseif eventType == ccui.TouchEventType.canceled then
						sender:setScale(1);
					elseif eventType == ccui.TouchEventType.ended then
						sender:setScale(1);
						--发送领取命令
						performWithDelay(self, function() self:close(); end, 0.1);
						self.callBack();
						self.isClose = true;
					end
			end
			)

			local chest = ccui.ImageView:create("hall/relief/chestOpen.png");
			chest:setPosition(70,coinBg:getContentSize().height/2+25);
			coinBg:addChild(chest);

			local freeCoin = ccui.ImageView:create("hall/relief/freeGold.png");
			freeCoin:setPosition(chest:getContentSize().width/2,2);
			freeCoin:setAnchorPoint(0.5,0);
			chest:addChild(freeCoin);

			local timeText = ccui.Text:create("点击可领取",FONT_PTY_TEXT,20);
			timeText:setPosition(coinBg:getContentSize().width*0.7,coinBg:getContentSize().height/2);
			coinBg:addChild(timeText);

			local armatureObj =  createArmature("hall/eff_icon_tongyong0.png","hall/eff_icon_tongyong0.plist","hall/eff_icon_tongyong.ExportJson")
			armatureObj:getAnimation():playWithIndex(0);
			armatureObj:setPosition(chest:getContentSize().width/2,chest:getContentSize().height/2);
			chest:addChild(armatureObj);

			local em = cc.ParticleSystemQuad:create("hall/lizi_icon_tongyong.plist");
			em:setPosition(chest:getContentSize().width/2,chest:getContentSize().height/2);
			chest:addChild(em);
		end
	end
end

function freeCoinNode:formatTime()
	local min = string.format("%d",self.time/60);
	local sec = string.format("%d",self.time%60);
	
	
	if string.len(min) < 2 then
		min = "0"..min;
	end

	if string.len(sec) < 2 then
		sec = "0"..sec;
	end

	if self.showType == 2 then
		return "领取免费金币\n倒计时"..min..":"..sec;
	end

	return  ""..min..":"..sec;
end

function freeCoinNode:startTimer(dt)
	self.time = self.time - dt;

	if self.timeText then
		self.timeText:setString(self:formatTime());	
	end

	if self.time <= 0 then
		self:stopAction(self.updateScheduler)

		self:changeUI();
	end
end

function freeCoinNode:changeUI()
	self:removeAllChildren();

	self.status=2

	self:createUI();
end


return freeCoinNode
