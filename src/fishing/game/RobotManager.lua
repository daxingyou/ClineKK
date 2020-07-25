local RobotManager = class("RobotManager",BaseWindow)

local instance = nil

function RobotManager:getInstance()
	if instance == nil then
		instance = RobotManager.new()
	end

	return instance
end

function RobotManager:destroyInstance()
	instance:dctor()
end

function RobotManager:ctor()
	self.super.ctor(self)

	self:initData()

	self:bindEvent()
end

function RobotManager:dctor()
	self:removeSelf()
	releaseLuaRequire("fishing.game.RobotManager")
	instance = nil
end

function RobotManager:initData()
	self.robotList = {}--机器人列表
	self.gameLayer = nil
	self.isJianxie = {};				--是否间歇
	self.jianxieCount = {};			--间歇时间
	self.fishCount = 0;				--当前鱼数量
	self.fireRate = {1/3,1/3,1/3,1/3};	--机器人发炮频率
	self.fireCount = {0,0,0,0};		--机器人发炮次数
end

function RobotManager:bindEvent()
	self:pushGlobalEventInfo("addRobot",handler(self,self.addRobot))
	self:pushGlobalEventInfo("removeRobot",handler(self,self.removeRobot))
	self:pushGlobalEventInfo("refreshUserInfo", handler(self,self.refreshUserInfo))
end

function RobotManager:setGameLayer(gameLayer)
	self.gameLayer = gameLayer
end

--添加机器人
function RobotManager:addRobot(data)
	local data = data._usedata

	-- self:startFishSchedule();
	math.randomseed(tostring(os.time()):reverse():sub(1, 6)..os.time())
	local x = random(1,3);
	if x == self.lastX then
		x = x + 1;
	end
	self.lastX = x;
	performWithDelay(self.gameLayer, function()
		if self.robotList[data.lSeatNo] and not self.robotList[data.lSeatNo].isLeft then
			self:startFireSchedule(data.lSeatNo,1/3)
		end
	end , x);
	-- self:startFireSchedule(data.lSeatNo,1/3)
	luaDump(data,"addRobot")

	-- if self.robotList[data.lSeatNo] == nil then
		self.robotList[data.lSeatNo] = {}
		self.robotList[data.lSeatNo].lSeatNo = data.lSeatNo
		-- addScrollMessage("添加机器人 data.lSeatNo  = "..data.lSeatNo)
		if self.gameLayer.playerNodeInfo[data.lSeatNo] then
			self.gameLayer.playerNodeInfo[data.lSeatNo].isRobot = true
			self.gameLayer.playerNodeInfo[data.lSeatNo]:deleteUpdateFunction()
		end
	-- end
end

--移除机器人
function RobotManager:removeRobot(data)
	local data = data._usedata

	for k,v in pairs(self.robotList) do
		if v.lSeatNo == data.lSeatNo then
			-- addScrollMessage("移除机器人 data.lSeatNo  = "..data.lSeatNo)
			table.removebyvalue(self.robotList,v,true)
			self:stopFireSchedule(data.lSeatNo)
			self.fireCount[data.lSeatNo+1] = 0
			if self.gameLayer.playerNodeInfo[data.lSeatNo] then
					self.gameLayer.playerNodeInfo[data.lSeatNo].isLockFish = false;
					self.gameLayer.playerNodeInfo[data.lSeatNo]:setLockFish(nil);
				self.gameLayer.playerNodeInfo[data.lSeatNo]:hideAimLine();
			end
			break
		end
	end

	if table.nums(self.robotList) <= 0 then
		-- self:stopFishSchedule()
	end
end

--刷新机器人信息
function RobotManager:refreshUserInfo(data)
	local data = data._usedata

	if data.lSeatNo ~= nil then
		luaDump(self.robotList,"refreshUserInfo")
		if self.robotList[data.lSeatNo] then
			self.gameLayer.playerNodeInfo[data.lSeatNo].isRobot = true
			self.gameLayer.playerNodeInfo[data.lSeatNo]:deleteUpdateFunction()
		else
			self.gameLayer.playerNodeInfo[data.lSeatNo].isRobot = false
		end
		-- addScrollMessage("data.lSeatNo="..data.lSeatNo..tostring(self.gameLayer.playerNodeInfo[data.lSeatNo].isRobot))
	end
end

--启动发炮定时器
function RobotManager:startFireSchedule(lseatNo,dt)
	if dt ~= self.fireRate[lseatNo+1] then
		if self:getActionByTag(100+lseatNo) ~= nil then
			self:stopFireSchedule(lseatNo)
			self.fireRate[lseatNo+1] = dt;
		end
	end

	if self:getActionByTag(100+lseatNo) == nil then
		-- addScrollMessage("启动发炮定时器"..lseat)
		math.randomseed(tostring(os.time()):reverse():sub(1, 6)..os.time())
		schedule(self,function() self:fireToPonit(lseatNo) end,dt):setTag(100+lseatNo)
	end
end

--停止发炮定时器
function RobotManager:stopFireSchedule(lseatNo)
	-- addScrollMessage("停止发炮定时器"..lseat)
	self:stopActionByTag(100+lseatNo)
	local schedule = self:getActionByTag(100+lseatNo)
	schedule = nil;
	-- self.fireCount[lseatNo+1] = 0
end

--启动获取鱼定时器
function RobotManager:startFishSchedule()
	if self:getActionByTag(200) == nil then
		math.randomseed(tostring(os.time()):reverse():sub(1, 6)..os.time())
		schedule(self,function() self:getFishInfo(); end,0.2):setTag(200)
	end
end

--停止鱼定时器
function RobotManager:stopFishSchedule()
	self:stopActionByTag(200)
	local schedule = self:getActionByTag(200)
	schedule = nil;
end

--普通发炮函数
function RobotManager:fireToPonit(seatNo)
	if self.gameLayer.playerNodeInfo[seatNo] == nil then
		return;
	end
	math.randomseed(tostring(os.time()):reverse():sub(1, 6)..os.time())
	self.fireCount[seatNo+1] = self.fireCount[seatNo+1] +1;

	local xianzhi = 0;  --入场限制
	local shuyingzhi = 0;	--输赢计算量值
	if globalUnit.iRoomIndex == 1 then
		xianzhi = 30;
		shuyingzhi = 30;
	elseif globalUnit.iRoomIndex == 2 then
		xianzhi = 50;
		shuyingzhi = 50;
	elseif globalUnit.iRoomIndex == 3 then
		xianzhi = 100;
		shuyingzhi = 200;
	elseif globalUnit.iRoomIndex == 4 then
		xianzhi = 150;
		shuyingzhi = 500;
	else
		xianzhi = 150;
		shuyingzhi = 500;
	end


	local playerChushiMoney = self.gameLayer.playerNodeInfo[seatNo].chushiMoney/100; --之前的金币值
 --	if self.gameLayer.playerNodeInfo[seatNo].lastScore then
 --		playerChushiMoney = self.gameLayer.playerNodeInfo[seatNo].lastScore;
	-- end

	local playeyMoney = self.gameLayer.playerNodeInfo[seatNo].score/100; --当前金币

	-- self.gameLayer.playerNodeInfo[seatNo].lastScore = playeyMoney;

	local moneybeishu = playeyMoney/xianzhi;  --金币是入场限制的倍数
	local chazhi = playeyMoney - playerChushiMoney;		--差值
	--加减炮概率
	local addRate = 0;			--加炮
	local noActionRate = 0;		--不加减
	local multRate = 0;		--减炮
	--炮速概率
	local Pao2Rate = 0;		--2炮
	local Pao3Rate = 0;		--3炮
	local Pao4Rate = 0;		--4炮
	local Pao5Rate = 0;		--5炮
	--散弹概率
	local useSandanRate = 0;			--使用散弹
	local noUseSandanRate = 0;			--不使用散弹
	--锁定概率
	local useSuodingRate = 0;			--使用锁定
	local noUseSuodingRate = 0;			--不使用锁定
	--召唤卡概率
	local useZhaohuanRate = 0;			--使用召唤卡
	local noUseZhaohuanRate = 0;			--不使用召唤卡
	--狂暴卡概率
	local useKuangbaoRate = 0;			--使用狂暴卡
	local noUseKuangbaoRate = 0;			--不使用狂暴卡
	--冰冻卡概率
	local useBingdongRate = 0;			--使用冰冻卡
	local noUseBingdongRate = 0;			--不使用冰冻卡

	-- local BossFish,specialFish,bigFish,target = self:getFishInfo();
	if self.fireCount[seatNo+1] % 4 == 1 then
		self:getFishInfo();
	end
	local target = nil;
	local len = #self.target;
	if len>3 then
		target = self.target[seatNo+1]
	end
	if target == nil then
		for k,v in pairs(self.gameLayer.fishData) do
			if not v.isKilled and v.m_isClear and not v.isSuck and not v:isFishOutScreen() then
				target = v
				break;
			end
		end
	end
	--是否有boss
	local isHaveBoss = false;
	if self.BossFish then
		isHaveBoss = true;
		target = self.BossFish;
	end

	if moneybeishu >=1 and moneybeishu <= 5 then		--金币是入场限制的1-5倍
		--金币是入场限制的1-5倍：20%是，80%否。
		useSuodingRate = 20;
		noUseSuodingRate = 80;

		if self.gameLayer.isCreateMatrix or isHaveBoss then -- BOSS来临：45%加炮，40%不加减，15%减炮。
			addRate = 45;
			noActionRate = 40;
			multRate = 15;
			--BOSS来临：30%是，70%否。
			useSuodingRate = 30
			noUseSuodingRate = 70
		elseif chazhi >= shuyingzhi then 					--赢钱：20%加炮，72%不加减，8%减炮。
			addRate = 20;
			noActionRate = 72;
			multRate = 8;
		elseif chazhi < shuyingzhi and chazhi >(0-shuyingzhi) then 	--没怎么输赢: 15%加炮，75%不加减，10%减炮
			addRate = 15;
			noActionRate = 75;
			multRate = 10;
		else	 --输钱：15%加炮，60%不加减，25%减炮。
			addRate = 15;
			noActionRate = 60;
			multRate = 25;
		end
		--50%=2炮（每秒）   30%=3炮   15%=4炮   5%=5炮
		Pao2Rate = 50;
		Pao3Rate = 30;
		Pao4Rate = 15;
		Pao5Rate = 5;
		--散弹  --冰冻卡
		if self.bigfishcount > 5 then --大鱼数>5（大鱼指30倍及以上）：10%是，90%否。
			useSandanRate = 10;
			noUseSandanRate = 90;
			useBingdongRate = 5;
			noUseBingdongRate =95;
		else  --大鱼数≤5：5%是，95%否。
			useSandanRate = 5;
			noUseSandanRate = 95;
			useBingdongRate = 8;
			noUseBingdongRate =92;
		end

	elseif moneybeishu >5 and moneybeishu <= 15 then 	--金币是入场限制的5-15倍
		--金币是入场限制的5-15倍：30%是，70%否。
		useSuodingRate = 30;
		noUseSuodingRate = 70;

		if self.gameLayer.isCreateMatrix or isHaveBoss then -- BOSS来临：55%加炮，37%不加减，8%减炮。
			addRate = 55;
			noActionRate = 37;
			multRate = 8;
			--金币是入场限制的5-15倍BOSS来临：40%是，60%否。
			useSuodingRate = 40;
			noUseSuodingRate = 60;
		elseif chazhi >= shuyingzhi then					--赢钱：30%加炮，65%不加减，5%减炮。
			addRate = 30;
			noActionRate = 65;
			multRate = 5;
		elseif chazhi < shuyingzhi and chazhi >(0-shuyingzhi) then 	--没怎么输赢：20%加炮，72%不加减，8%减炮。
			addRate = 20;
			noActionRate = 72;
			multRate = 8;
		else	 --输钱：20%加炮，60%不加减，20%减炮。
			addRate = 20;
			noActionRate = 60;
			multRate = 20;
		end
		--金币是入场限制的5-15倍：30%=2炮   40%=3炮   20%=4炮   10%=5炮
		Pao2Rate = 30;
		Pao3Rate = 40;
		Pao4Rate = 20;
		Pao5Rate = 10;
		--散弹  --冰冻卡
		if self.bigfishcount > 5 then --大鱼数>5（大鱼指30倍及以上）：20%是，80%否。
			useSandanRate = 20;
			noUseSandanRate = 80;
			useBingdongRate = 10;
			noUseBingdongRate =90;
		else  --大鱼数≤5：10%是，90%否。
			useSandanRate = 10;
			noUseSandanRate = 90;
			useBingdongRate = 5;
			noUseBingdongRate =95;
		end
	elseif moneybeishu >15 and moneybeishu <= 30 then 	--金币是入场限制的15-30倍
		--金币是入场限制的15-30倍：40%是，60%否。
		useSuodingRate = 40;
		noUseSuodingRate = 60;

		if self.gameLayer.isCreateMatrix or isHaveBoss then -- BOSS来临：60%加炮，35%不加减，5%减炮。
			addRate = 60;
			noActionRate = 35;
			multRate = 5;
			--金币是入场限制的15-30倍BOSS来临：50%是，50%否。
			useSuodingRate = 50;
			noUseSuodingRate = 50;
		elseif chazhi >= shuyingzhi then					--赢钱: 35%加炮，62%不加减，3%减炮。
			addRate = 35;
			noActionRate = 62;
			multRate = 3;
		elseif chazhi < shuyingzhi and chazhi >(0-shuyingzhi) then 	--没怎么输赢：25%加炮，70%不加减，5%减炮。
			addRate = 25;
			noActionRate = 70;
			multRate = 5;
		else	 --输钱：25%加炮，60%不加减，15%减炮。
			addRate = 25;
			noActionRate = 60;
			multRate = 15;
		end
		--金币是入场限制的15-30倍：20%=2炮   30%=3炮   30%=4炮   20%=5炮
		Pao2Rate = 20;
		Pao3Rate = 30;
		Pao4Rate = 30;
		Pao5Rate = 20;
		--散弹  --冰冻卡
		if self.bigfishcount > 5 then
			--散弹 大鱼数>5：30%是，70%否。
			useSandanRate = 30;
			noUseSandanRate = 70;
			-- 冰冻卡  大鱼数>5：20%是，80%否。
			useBingdongRate = 20;
			noUseBingdongRate =80;
		else  
			--散弹 大鱼数≤5：15%是，85%否。
			useSandanRate = 15;
			noUseSandanRate = 85;
			--	冰冻卡 大鱼数≤5：8%是，92%否。
			useBingdongRate = 8;
			noUseBingdongRate =92;
		end
	elseif moneybeishu >30 then						--金币是入场限制的30倍以上
		--金币是入场限制的30倍以上: 50%是，50%否。
		useSuodingRate = 50;
		noUseSuodingRate = 50;

		if self.gameLayer.isCreateMatrix or isHaveBoss then -- BOSS来临：65%加炮，32%不加减，3%减炮。
			addRate = 65;
			noActionRate = 32;
			multRate = 3;
			--金币是入场限制的30倍以上， BOSS来临：60%是，40%否。
			useSuodingRate = 60;
			noUseSuodingRate = 40;
		elseif chazhi >= shuyingzhi then					--赢钱：40%加炮，59%不加减，1%减炮。
			addRate = 40;
			noActionRate = 59;
			multRate = 1;
		elseif chazhi < shuyingzhi and chazhi >(0-shuyingzhi) then 	--没怎么输赢：30%加炮，67%不加减，3%减炮。
			addRate = 30;
			noActionRate = 67;
			multRate = 3;
		else	 --输钱：40%加炮，50%不加减，10%减炮。
			addRate = 40;
			noActionRate = 50;
			multRate = 10;
		end
		--金币是入场限制的30倍以上：10%=2炮   20%=3炮   30%=4炮   40%=5炮
		Pao2Rate = 10;
		Pao3Rate = 20;
		Pao4Rate = 30;
		Pao5Rate = 40;
		--散弹  --冰冻卡
		if self.bigfishcount > 5 then
			--散弹 大鱼数>5：40%是，60%否。
			useSandanRate = 40;
			noUseSandanRate = 60;
			-- 冰冻卡  大鱼数>5：30%是，70%否。
			useBingdongRate = 30;
			noUseBingdongRate =70;
		else  
			--散弹 大鱼数≤5：20%是，80%否。
			useSandanRate = 20;
			noUseSandanRate = 80;
			--	冰冻卡 大鱼数≤5：10%是，90%否。
			useBingdongRate = 10;
			noUseBingdongRate =90;
		end
	end

	--召唤卡
	if self.bigfishcount < 6 then
		--大鱼数＜6：10%是，90%否。
		useZhaohuanRate = 10;
		noUseZhaohuanRate = 90;
	elseif self.bigfishcount < 5 then
		--大鱼数＜5：30%是，70%否。
		useZhaohuanRate = 30;
		noUseZhaohuanRate = 70;
	elseif self.bigfishcount < 4 then
		--大鱼数＜4：50%是，50%否。
		useZhaohuanRate = 50;
		noUseZhaohuanRate = 50;
	end

	--狂暴卡
	-- 锁定状态下（且锁定的鱼倍数高于100倍）：30%是，70%否
	-- 锁定状态下（且锁定的鱼倍数低于100倍）：20%是，80%否
	-- 非锁定状态下10是%，90%否
	local fish = self.gameLayer.playerNodeInfo[seatNo].lockFish;
	if fish then
		if fish._fishMult > 100 then
			useKuangbaoRate = 30;
			noUseKuangbaoRate = 70;
		else
			useKuangbaoRate = 20;
			noUseKuangbaoRate = 80;
		end
	else
		useKuangbaoRate = 10;
		noUseKuangbaoRate = 90;
	end

	if self.fishCount<= 10 then
		useSandanRate = 0;
		noUseSandanRate = 100;
		useBingdongRate = 0;
		noUseBingdongRate =100;
		useKuangbaoRate = 0;			--使用狂暴卡
		noUseKuangbaoRate = 100;
		useZhaohuanRate = 50;
		noUseZhaohuanRate = 50;
	end

	local suiji = {2,13,24,35}
	-- 加炮、减炮：10-15秒检测一次
	if self.fireCount[seatNo+1] % 46 == suiji[seatNo+1] then
		local bb = random(1,100);
		if bb <= addRate then
			local x = random(1,3); --加减炮次数
			for i=1,x do
				performWithDelay(self.gameLayer,function()
					if self.gameLayer.playerNodeInfo[seatNo] then
						self.gameLayer.playerNodeInfo[seatNo]:changePaoMultiple(true)
					end
				end,i)
			end
			-- self.gameLayer.playerNodeInfo[seatNo]:changePaoMultiple(true)
		elseif bb <= addRate + multRate then
			local x = random(1,3); --加减炮次数
			for i=1,x do
				performWithDelay(self.gameLayer,function()
					if self.gameLayer.playerNodeInfo[seatNo] then
						self.gameLayer.playerNodeInfo[seatNo]:changePaoMultiple(false)
					end
				end,i)
			end
			-- self.gameLayer.playerNodeInfo[seatNo]:changePaoMultiple(false)
		end
	end
	-- 炮速：2-5秒（随机）检测一次。
	local isKuangbao = self.gameLayer.playerNodeInfo[seatNo].cannon.isFastShoot;
	if isKuangbao then
		self:startFireSchedule(seatNo,1/6)
	elseif fish then
		self:startFireSchedule(seatNo,1/5)
	else
		suiji = {1,5,8,10}
		if self.fireCount[seatNo+1] % 12 == suiji[seatNo+1] then
			local bb = random(1,100);
			if bb <= Pao2Rate then
				self:startFireSchedule(seatNo,1/2)
			elseif bb <= Pao2Rate + Pao3Rate  then
				self:startFireSchedule(seatNo,1/3)
			elseif bb <= Pao2Rate + Pao3Rate + Pao4Rate then
				self:startFireSchedule(seatNo,1/4)
			elseif bb <= Pao2Rate + Pao3Rate + Pao4Rate + Pao5Rate then
				self:startFireSchedule(seatNo,1/5)
			end
		end

	end
	-- 散弹：10秒检测一次，鱼阵和BOSS来临时额外再检测一次。
	suiji = {2,11,24,31}
	if self.fireCount[seatNo+1] % 41 == suiji[seatNo+1] then
		local bb = random(1,100);
		if bb <= useSandanRate then
			if self.gameLayer.playerNodeInfo[seatNo].cannon.isMoreFastShoot == false then
				self.gameLayer.playerNodeInfo[seatNo].cannon:setMoreFastFire(true)
				self.gameLayer.playerNodeInfo[seatNo]:updateBullet(self.gameLayer.playerNodeInfo[seatNo].cur_zi_dan_cost)
			end
		else
			if self.gameLayer.playerNodeInfo[seatNo].cannon.isMoreFastShoot == true then
				self.gameLayer.playerNodeInfo[seatNo].cannon:setMoreFastFire(false)
				self.gameLayer.playerNodeInfo[seatNo]:updateBullet(self.gameLayer.playerNodeInfo[seatNo].cur_zi_dan_cost)
			end
		end
	elseif self.fishCount<= 10 then
		if self.gameLayer.playerNodeInfo[seatNo].cannon.isMoreFastShoot == true then
			self.gameLayer.playerNodeInfo[seatNo].cannon:setMoreFastFire(false)
			self.gameLayer.playerNodeInfo[seatNo]:updateBullet(self.gameLayer.playerNodeInfo[seatNo].cur_zi_dan_cost)
		end
	end

	-- 锁定：8秒检测一次
	suiji = {5,15,24,30}
	if self.fireCount[seatNo+1] % 33 == suiji[seatNo+1] then
		local bb = random(1,100);
		if bb <= useSuodingRate then
			if fish == nil then
				if self.BossFish ~= nil then
						fish = self.BossFish;
				elseif self.specialFish ~= nil then
						fish = self.specialFish;
				elseif self.bigFish ~= nil then
						fish = self.bigFish;
				end
			end
		elseif bb <= useSuodingRate + noUseSuodingRate then
			fish = nil;
			self.gameLayer.playerNodeInfo[seatNo].isLockFish = false;
		end
	end
	local money = self.gameLayer.playerNodeInfo[seatNo].score/100;
	local cost = self.gameLayer.playerNodeInfo[seatNo].cur_zi_dan_cost/100;
	if self.gameLayer.playerNodeInfo[seatNo].cannon.isMoreFastShoot == true then
		cost = cost*3;
	end
	local size = cc.size(220,80);
	local pos = cc.p(self.gameLayer.playerNodeInfo[seatNo]:getPositionX(),self.gameLayer.playerNodeInfo[seatNo]:getPositionY()+3);
	
	local size1 = cc.size(100,160);
	local pos1 = cc.p(self.gameLayer.playerNodeInfo[seatNo]:getPositionX(),self.gameLayer.playerNodeInfo[seatNo]:getPositionY()+35);
	if fish and not fish.isKilled and money >= cost and not fish:isFishOutScreen() and fish:isFishBelowPlayer(pos,size) == false and fish:isFishBelowPlayer(pos1,size1) == false then --锁定打鱼
		self.gameLayer.playerNodeInfo[seatNo]:setLockFish(fish);
		self.gameLayer.playerNodeInfo[seatNo]:showAimLine();
		self.gameLayer.playerNodeInfo[seatNo]:fireToPonit(fish:getFishPos())
		self.gameLayer.playerNodeInfo[seatNo].isLockFish = true;
	else
		if target and not tolua.isnull(target) and not target:isFishOutScreen() and target:isFishBelowPlayer(pos,size) == false and target:isFishBelowPlayer(pos1,size1) == false then
			if money >= cost  and self.gameLayer.playerNodeInfo[seatNo].isLockFish == true then

				self.gameLayer.playerNodeInfo[seatNo]:setLockFish(target);
				self.gameLayer.playerNodeInfo[seatNo]:showAimLine();
				self.gameLayer.playerNodeInfo[seatNo]:fireToPonit(target:getFishPos())
				-- addScrollMessage("wwwwwwwwwwwww")
				local time1 = random(1,3)
				performWithDelay(self.gameLayer.playerNodeInfo[seatNo],function()
					if self.gameLayer.playerNodeInfo[seatNo] and target and not tolua.isnull(target) then
						self.gameLayer.playerNodeInfo[seatNo].isLockFish = false;
						self.gameLayer.playerNodeInfo[seatNo]:setLockFish(nil);
						self.gameLayer.playerNodeInfo[seatNo]:hideAimLine();
						self.gameLayer.playerNodeInfo[seatNo]:fireToPonit(target:getFishPos())--普通发炮，目前一直不停的发
					end
				end,time1)
			else
				self.gameLayer.playerNodeInfo[seatNo]:setLockFish(nil);
				self.gameLayer.playerNodeInfo[seatNo]:hideAimLine();
				self.gameLayer.playerNodeInfo[seatNo]:fireToPonit(target:getFishPos())--普通发炮，目前一直不停的发
			end
		end
	end

	suiji = {45,55,65,75}
	-- 召唤卡：20秒检测一次。
	if self.fireCount[seatNo+1] % 80 == suiji[seatNo+1] then
		-- addScrollMessage("召唤卡：20秒检测一次".."bb="..bb.."-"..useZhaohuanRate)
		local bb = random(1,99);
		if bb <= useZhaohuanRate then
			if not self.gameLayer.isCreateMatrix then
				local userInfo = self.gameLayer.tableLogic:getUserBySeatNo(seatNo);
				if userInfo then
					self:sendRobotUseGoodsRequest(userInfo.dwUserID,GOODS_CALLFISH,-1)
				end
			end
		end
	end
	-- 狂暴卡：20秒检测一次，
	suiji = {25,52,78,89}
	if self.fireCount[seatNo+1] % 90 == suiji[seatNo+1] then
		local bb = random(1,98);
		-- addScrollMessage("狂暴卡：20秒检测一次".."bb="..bb.."-"..useKuangbaoRate)
		if bb <= useKuangbaoRate then
			local canUse = true;
			for i=1,4 do
				if self.gameLayer.playerNodeInfo[i] and self.gameLayer.playerNodeInfo[i].isUseKB == true then
					canUse = false;
				end
			end
			if canUse == true then
				local userInfo = self.gameLayer.tableLogic:getUserBySeatNo(seatNo);
				if userInfo  then
					self:sendRobotUseGoodsRequest(userInfo.dwUserID,GOODS_KUANGBAO,-1)
					self.gameLayer.playerNodeInfo[seatNo].isUseKB = true;
					performWithDelay(self.gameLayer,function()
						if self.gameLayer.playerNodeInfo[seatNo] then
							self.gameLayer.playerNodeInfo[seatNo].isUseKB = false;
						end
					end,15)
				end
			end
		end
	end
	-- 冰冻卡：30秒检测一次，
	suiji = {25,55,85,100}
	if self.fireCount[seatNo+1] % 120 == suiji[seatNo+1] then
		local bb = random(1,97);
		-- addScrollMessage("冰冻卡：30秒检测一次".."bb="..bb.."-"..useBingdongRate)
		if bb <= useBingdongRate then
			if not(self.gameLayer.isBingdongFish or self.gameLayer.isCreateMatrix) then
				local userInfo = self.gameLayer.tableLogic:getUserBySeatNo(seatNo);
				if userInfo then
					self:sendRobotUseGoodsRequest(userInfo.dwUserID,GOODS_BINGDONG,-1)
				end
			end
		end
	end
	--机器人5-10m  离开 先停止发炮，5s后离开
	local likaiTime = random(5+seatNo,10+seatNo);
	if self.fireCount[seatNo+1] >= likaiTime*60*4 or money < cost then
		-- addScrollMessage("left seatNo= "..seatNo)
		if self.robotList[seatNo] then
			self.robotList[seatNo].isLeft = true
		end
		performWithDelay(self.gameLayer,function()
				if self.robotList[seatNo] then
					self.robotList[seatNo].isLeft = nil;
				end
				self:sendRobotLeft(seatNo)
			end,5)
		self:stopFireSchedule(seatNo)
		self.fireCount[seatNo+1] = 0
		if self.gameLayer.playerNodeInfo[seatNo] then
			self.gameLayer.playerNodeInfo[seatNo].isLockFish = false;
			self.gameLayer.playerNodeInfo[seatNo]:setLockFish(nil); 
			self.gameLayer.playerNodeInfo[seatNo]:hideAimLine();
		end
	end
end


--获取一条锁定的鱼
function RobotManager:getFishInfo()
	local BossFish = nil			--一类 boss
	local specialFish = nil		--二类 特殊鱼
	local bigFish = nil			--三类  大鱼
	local specialFishTeam = {}			--二类 特殊鱼组
	local bigFishTeam = {}				--三类  大鱼组
	local target = nil
	local fishcount = 0;
	local bigfishcount = 0;
	self.target = {};
	for k,v in pairs(self.gameLayer.fishData) do
		if not v.isKilled and v.m_isClear and not v.isSuck and not v:isFishOutScreen() then
			-- 一类 boss
			if v.isBoss == true then
				BossFish = v;
				table.insert(self.target,v)
			end
			--黑洞鱼 红包鱼 摇钱树 金蛋 多宝鱼 全屏炸弹
			if v._fishType == 52 or v._fishType == 53 or v._fishType == 54 or v._fishType == 57 or v._fishType == 58 or v._fishType == 24 then
				table.insert(specialFishTeam,v)
			end
			--龙 企鹅 局部炸弹  冰冻鱼 金龟 金龙鱼 鲨鱼 银龙
			if v._fishType == 18 or v._fishType == 19 or v._fishType == 22 or v._fishType == 23  or v._fishType == 55 or v._fishType == 56 then
				table.insert(bigFishTeam,v)
			end

			if target == nil then
				target = v
			else
				if target._fishMult < v._fishMult then
					-- local ww = random(0,1)
					-- if ww == 0 then
						target = v
					-- end
					table.insert(self.target,v)
				end
			end
			if v._fishMult >= 30 then
				bigfishcount = bigfishcount+1;
			end
			fishcount = fishcount +1;
		end
	end
	self.fishCount = fishcount;
	self.bigfishcount = bigfishcount;

	math.randomseed(tostring(os.time()):reverse():sub(1, 5)..os.time())
	--鱼组中随机一条
	if #specialFishTeam > 0 then
		specialFish = specialFishTeam[random(1,#specialFishTeam)]
	end
	if #bigFishTeam > 0 then
		bigFish = bigFishTeam[random(1,#bigFishTeam)]
	end
	self.BossFish = BossFish;
	self.specialFish = specialFish;
	self.bigFish = bigFish;
	-- self.target = target
	for k,v in pairs(specialFishTeam) do
		table.insert(self.target,v)
	end
	for k,v in pairs(bigFishTeam) do
		table.insert(self.target,v)
	end
	table.insert(self.target,target)

	return BossFish,specialFish,bigFish,target;
end

--机器人物品使用
function RobotManager:sendRobotUseGoodsRequest(userID,goodsID, goodsCount)
	if globalUnit.isEnterGame ~= true then
		return;
	end

	local msg = {}
	msg.UserID = userID;
	msg.goodsID = goodsID;
	msg.goodsCount = goodsCount or 1;
	luaDump(msg)
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_UPDATE_GOODSINFO,msg,RoomMsg.CMD_C_GOODSINFO);
end

--机器人离开
function RobotManager:sendRobotLeft(chair_id)
	if globalUnit.isEnterGame ~= true then
		return;
	end

	local msg = {}
	msg.chair_id = chair_id;
	-- luaDump(msg)
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_SEND_ANDROID_LEFT,msg,GameMsg.CMD_C_ANDROID_LEFT);
end

return RobotManager
