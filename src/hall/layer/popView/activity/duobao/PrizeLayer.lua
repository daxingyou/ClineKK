local PrizeLayer = class("PrizeLayer",BaseWindow)

function PrizeLayer:create(layer)
	return PrizeLayer.new(layer);
end

function PrizeLayer:ctor(layer)
	self.super.ctor(self, false, false);

	self.parentLayer = layer

	self:bindEvent();

	self:initData();

	self:initUI()
	-- LuckyInfo:sendLuckyOpenRequest()
end

function PrizeLayer:bindEvent()
	self:pushEventInfo(LuckyInfo,"luckyWheelResult",handler(self, self.receiveLuckyWheelResult))
	self:pushEventInfo(LuckyInfo,"luckyPointInfo",handler(self, self.receiveLuckyPointInfo))
	self:pushGlobalEventInfo("changePrize",handler(self, self.changePrize))
end

function PrizeLayer:initData()
	local len = 12
	local r = 230;
	local ro = 360/len

	self.rotate = {}

	self.posData = {}
	self.posDataImage = {}
	local r1 = r - 60

	for i=1,len do
		table.insert(self.rotate,ro*(i-1))
		table.insert(self.posData,cc.p(r*math.sin(math.rad(self.rotate[i])),r*math.cos(math.rad(self.rotate[i]))))
		table.insert(self.posDataImage,cc.p(r1*math.sin(math.rad(self.rotate[i])),r1*math.cos(math.rad(self.rotate[i]))))
	end

	self.angle = 0;
	self.rate = 360/270;--转360的单位时间

	self.baifenNum = {
						{1,5,4,6,4,7,2,7,5,7,3,6},
						{6,7,2,3,4,7,1,5,4,7,5,6},
						{7,5,4,6,4,7,2,3,5,7,1,6},
					};

	self.goodsIcon = {}
	self.index = 0
end

function PrizeLayer:initUI()
	self.goodsIcon = {}
	self.selectTag = self.parentLayer.iTag
	self.index = 0
	self.light = nil
	local size = cc.Director:getInstance():getWinSize();

	local pNode = cc.Node:create();
	pNode:setPosition((size.width-1280)/2,0);
	self:addChild(pNode);
	self.pNode = pNode;

	local zhuanpan = ccui.ImageView:create("activity/duobao/zhuanpan/zhuanpan"..self.selectTag..".png");
	zhuanpan:setPosition(800,360);
	pNode:addChild(zhuanpan,10);
	self.zhuanpan = zhuanpan;

	-- local zhuanpanBg = ccui.ImageView:create("activity/duobao/zhuanpan/zhuanpanBg.png");
	-- zhuanpanBg:setAnchorPoint(0.5,0);
	-- zhuanpanBg:setPosition(zhuanpan:getPositionX(),0);
	-- pNode:addChild(zhuanpanBg);

	self:createGoodsUI();

	local name = {"baiyin","huangjin","zuanshi"}

	local skeleton_animation = createSkeletonAnimation("baolilunpan","activity/duobao/zhuanpan/baolilunpan.json","activity/duobao/zhuanpan/baolilunpan.atlas");
	if skeleton_animation then
		pNode:addChild(skeleton_animation,20);
		skeleton_animation:setAnimation(0,name[LuckyInfo.luckyListInfo[self.selectTag].kind],true);
		skeleton_animation:setPosition(zhuanpan:getPositionX(),zhuanpan:getPositionY());
	end

	local compass = ccui.Button:create("activity/duobao/zhuanpan/compass"..self.selectTag..".png","activity/duobao/zhuanpan/compass"..self.selectTag.."-on.png");
	compass:setPosition(zhuanpan:getPositionX(),zhuanpan:getPositionY()+20);
	compass:setTouchEnabled(true);
	compass:setLocalZOrder(30);
	pNode:addChild(compass);
	compass:onClick(function(sender) self:onClickStart(); end)

	self.startBtn = compass;

	local compass = ccui.Button:create("activity/duobao/zhuanpan/help.png");
	compass:setPosition((size.width-1280)/4+1200,25);
	pNode:addChild(compass,30);
	compass:onTouchClick(function(sender) self:onclick(); end)

	local iconLabel = FontConfig.createWithCharMap(goldConvert(LuckyInfo.luckyPointInfo.curPoint),"activity/duobao/zhuanpan/jifenNum.png",13,19,"+")
	iconLabel:setPosition(compass:getPositionX()-compass:getContentSize().width-5,compass:getPositionY());
	iconLabel:setAnchorPoint(cc.p(1,0.5));
	iconLabel:setAlignment(cc.TEXT_ALIGNMENT_LEFT,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	pNode:addChild(iconLabel,30);
	self.pointLabel = iconLabel

	local iconLabel1 = FontConfig.createWithSystemFont("当前积分:")
	iconLabel1:setPosition(iconLabel:getPositionX()-iconLabel:getContentSize().width-5,compass:getPositionY());
	iconLabel1:setAnchorPoint(cc.p(1,0.5));
	pNode:addChild(iconLabel1,30);
	self.iconLabel1 = iconLabel1
end

function PrizeLayer:onExit()
	self.super.onExit(self)
	-- LuckyInfo:sendLuckyOpenRequest()
	dispatchEvent("refreshScoreBank")
end

--奖品排列
function PrizeLayer:createGoodsUI()
	local size = self.zhuanpan:getContentSize();

	--百分比
	if #LuckyInfo.luckyListInfo <= 0 then
		return
	end

	local len = #LuckyInfo.luckyListInfo[self.selectTag].award
	for k,v in pairs(self.baifenNum[LuckyInfo.luckyListInfo[self.selectTag].kind]) do
		local iconLabel = FontConfig.createWithCharMap(goldConvert(LuckyInfo.luckyListInfo[self.selectTag].award[v]),"activity/duobao/zhuanpan/num.png",16,20,"0")
		iconLabel:setPosition(size.width/2+self.posData[k].x,size.height/2+self.posData[k].y);
		iconLabel:setAnchorPoint(cc.p(0.5,0.5));
		self.zhuanpan:addChild(iconLabel);
		iconLabel:setRotation(self.rotate[k]);
		iconLabel:setTag(k)

		if self.goodsIcon[v] == nil then
			self.goodsIcon[v] = {}
		end

		table.insert(self.goodsIcon[v],iconLabel)

		local image = ccui.ImageView:create("activity/duobao/zhuanpan/"..(len-v+1)..".png")
		image:setPosition(size.width/2+self.posDataImage[k].x,size.height/2+self.posDataImage[k].y);
		image:setAnchorPoint(cc.p(0.5,0.5));
		self.zhuanpan:addChild(image);
		image:setRotation(self.rotate[k]);
	end
end

function PrizeLayer:setStartBtnStatus(touch)
	self.startBtn:setTouchEnabled(touch);

	if touch  == false then
		self.startBtn:setHighlighted(true);
	else
		self.startBtn:setHighlighted(false);
	end
end

function PrizeLayer:onClickStart()
	if #LuckyInfo.luckyListInfo <= 0 then
		return
	end

	self:setStartBtnStatus(false);

	if self.light then
		self.light:removeSelf()
		self.light = nil
	end

	if self.touchLayer == nil then
		self.touchLayer = display.newLayer()
		self.touchLayer:setTouchEnabled(true)
		self.touchLayer:setLocalZOrder(100)
		self:getParent():addChild(self.touchLayer)
		self.touchLayer:onTouch(function(event) 
					local eventType = event.name
					if eventType == "began" then
						return true
					end
		end,false, true)

		performWithDelay(self,function() 
			if self.touchLayer then
				self.touchLayer:removeSelf()
				self.touchLayer = nil
			end
			self:setStartBtnStatus(true)
		end,
		5):setTag(100)
	end

	LuckyInfo:sendLuckyResultRequest(LuckyInfo.luckyListInfo[self.selectTag].kind)
end

function PrizeLayer:onclick(sender)
	self:addChild(require("layer.popView.activity.duobao.HelpLayer"):create())
end

function PrizeLayer:receiveLuckyWheelResult(data)
	local data = data._usedata
	self.prizeResult = data[1]
	self:stopActionByTag(100)

	if data[2] == 1 then
		addScrollMessage("您的积分不足")
		if self.touchLayer then
			self.touchLayer:removeSelf()
			self.touchLayer = nil
		end
		self:setStartBtnStatus(true)
		return
	end

	luaDump(data[1],"抽奖结果");

	--播放抽奖动画
	local index = data[1].awardLevel

	if self.goodsIcon[index] == nil then
		addScrollMessage("轮盘结果异常")
		if self.touchLayer then
			self.touchLayer:removeSelf()
			self.touchLayer = nil
		end
		self:setStartBtnStatus(true)
		return
	end

	index = self.goodsIcon[index][math.random(1,#self.goodsIcon[index])]:getTag()-1

	if index > self.index  then
		self.angle = 360-(360/12)*(math.abs(index-self.index))
	else
		self.angle = (360/12)*(math.abs(index-self.index))
	end
	
	self.index = index

	if self.rate == nil then
		self.rate = 360/240;--转360的单位时间
	end
	local rand = math.random(2,5);
	local dt = rand*self.rate+self.angle/360*self.rate;
	local angle = 360*rand+self.angle;

	local temp = self.zhuanpan:getRotation()
	local seq = cc.Sequence:create(
			cc.EaseExponentialInOut:create(cc.RotateBy:create(dt, angle)),
			cc.CallFunc:create(function()
				local size = self.zhuanpan:getContentSize();
				self.zhuanpan:setRotation(angle+temp)
				local image = ccui.ImageView:create("activity/duobao/zhuanpan/blinkLight.png");
				image:setAnchorPoint(cc.p(0.5,0));
				image:setPosition(cc.p(self.zhuanpan:getPositionX(),self.zhuanpan:getPositionY()-10));
				self.pNode:addChild(image,20);
				image:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5))));
				self.light = image

				-- LuckyInfo:sendLuckyOpenRequest()
				dispatchEvent("refreshScoreBank")
				self:playPrizeResult()
			end)
		)
	self.zhuanpan:runAction(seq);
end

function PrizeLayer:playPrizeResult()
	if self.touchLayer then
		-- return
	end

	local skeleton_animation = createSkeletonAnimation("gongxihuode","activity/SignIn/gongxihuode.json","activity/SignIn/gongxihuode.atlas");
	if skeleton_animation then
		self.touchLayer:addChild(skeleton_animation);
		skeleton_animation:setAnimation(0,"gongxihuode",true);
		skeleton_animation:setPosition(winSize.width/2,winSize.height/2);
		self.touchLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
			local image = ccui.ImageView:create("activity/duobao/zhuanpan/"..(8-self.prizeResult.awardLevel).."d.png")
			image:setPosition(winSize.width/2,winSize.height/2)
			self.touchLayer:addChild(image)

			local iconLabel = FontConfig.createWithCharMap(goldConvert(self.prizeResult.awardMoney),"activity/SignIn/hdnum.png", 42, 68, '+')
			iconLabel:setPosition(winSize.width/2,winSize.height/2-140)
			self.touchLayer:addChild(iconLabel)

			end),cc.DelayTime:create(3),cc.CallFunc:create(function()
				self.touchLayer:removeSelf()
				self.touchLayer = nil
				self:setStartBtnStatus(true)
		end)));
	end
end

function PrizeLayer:receiveLuckyPointInfo(data)
	local data = data._usedata
	self.pointLabel:setString(goldConvert(data.curPoint))
	self.iconLabel1:setPositionX(self.pointLabel:getPositionX()-self.pointLabel:getContentSize().width-5);
end

function PrizeLayer:changePrize()
	if self.selectTag == self.parentLayer.iTag then
		return
	end

	self:removeAllChildren()

	self:initUI()
end

return PrizeLayer

