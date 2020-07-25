local PrizeLayer = class("PrizeLayer",BaseWindow)

function PrizeLayer:create()
	return PrizeLayer.new();
end

function PrizeLayer:ctor()
	self.super.ctor(self, 0, true);

	self:bindEvent();

	self:initData();

	self:initUI()
end

function PrizeLayer:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = BindTool.bind(RedEnvelopesInfo, "redEnvelopesResultInfo", handler(self, self.receiveRedEnvelopesResultInfo))
	self.bindIds[#self.bindIds + 1] = BindTool.bind(RedEnvelopesInfo, "redEnvelopesInfo", handler(self, self.receiveRedEnvelopesInfo))
	self.bindIds[#self.bindIds + 1] = BindTool.bind(UserExpandInfo, "userExpandInfo", handler(self, self.receiveUserExpandInfo))--用户扩展属性
end

function PrizeLayer:initData()
	local r = 150;
	self.rotate = {0,36,72,108,144,180,216,252,288,324};
	local d = math.rad(36);
	local i = 0;
	local j = 7;
	local k = 17;

	self.posData = 
	{
		cc.p(0+j,r-i),
		cc.p(r*math.sin(d)-i+7,r*math.cos(d)-i-7),
		cc.p(r*math.cos(math.rad(18))-i+3,r*math.sin(math.rad(18))-i-8),
		cc.p(r*math.cos(math.rad(18))-i,-r*math.sin(math.rad(18))+i-8),
		cc.p(r*math.sin(d)-i-5,-r*math.cos(d)+i-8),
		cc.p(0-j,-r-3),
		cc.p(-r*math.sin(d)+i-j,-r*math.cos(d)+i),
		cc.p(-r*math.cos(math.rad(18))+i-j,-r*math.sin(math.rad(18))+i+5),
		cc.p(-r*math.cos(math.rad(18))+i,r*math.sin(math.rad(18))+i+5),
		cc.p(-r*math.sin(d)+i+5,r*math.cos(d)-i+5),
	}

	self.angle = 0;
	self.rate = 360/270;--转360的单位时间

	self.multBlink = {}

	self.multNum = {1,2,5,8,10};
	self.baifenNum = {50,200,150,100,75,50,200,150,100,75};
	self.baseReward = 0;

	UserExpandInfo:sendUserExpandInfoRequest();
end

function PrizeLayer:initUI()
	local size = cc.Director:getInstance():getWinSize();

	local bg = ccui.ImageView:create("game/zhuanpan/bg.png");
	bg:setPosition(size.width/2, size.height/2);
	bg:setTouchEnabled(true);
	self:addChild(bg);
	self.bg = bg;

	size = bg:getContentSize();

	local zhuanpan = ccui.ImageView:create("game/zhuanpan/zhuanpanBg.png");
	zhuanpan:setPosition(755, 340);
	zhuanpan:setTouchEnabled(true);
	bg:addChild(zhuanpan);
	self.zhuanpan = zhuanpan;
	size = zhuanpan:getContentSize();

	self:createGoodsUI();

	local compass = ccui.ImageView:create("game/zhuanpan/compass.png");
	compass:setPosition(zhuanpan:getPosition());
	compass:setTouchEnabled(true);
	compass:setLocalZOrder(10);
	self.bg:addChild(compass);
	compass:onTouchClick(function(sender) self:onClickStart(); end)

	self.startBtn = compass;

	local light = ccui.ImageView:create("game/zhuanpan/startLight.png");
	light:setPosition(compass:getContentSize().width/2, compass:getContentSize().height/2-15);
	compass:addChild(light);
	self.light = light;
	light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5,360)));

	local label = FontConfig.createWithCharMap(goldConvert(self.baseReward),"game/zhuanpan/lunpan.png",24,30,"+")
	label:setPosition(compass:getContentSize().width/2,compass:getContentSize().height/2-15);
	label:setAnchorPoint(cc.p(0.5,0.5));
	compass:addChild(label);
	self.basecLabel = label;

	local skeleton_animation = createSkeletonAnimation("buyuzhuanpan","game/effect/buyuzhuanpan.json", "game/effect/buyuzhuanpan.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition( bg:getContentSize().width/2, bg:getContentSize().height/2);
		skeleton_animation:setAnimation(1,"zhuanpan-dong", true);
		bg:addChild(skeleton_animation);
	end

	--基础奖励
	local label = FontConfig.createWithCharMap(goldConvert(self.baseReward),"game/zhuanpan/jisuan.png",33,42,"+")
	label:setPosition(cc.p(335,670));
	label:setAnchorPoint(cc.p(0.5,0.5));
	bg:addChild(label);
	self.baseLabel = label;

	--百分比
	local label = FontConfig.createWithCharMap(0,"game/zhuanpan/jisuan.png",33,42,"+")
	label:setPosition(cc.p(567,670));
	label:setAnchorPoint(cc.p(0.5,0.5));
	bg:addChild(label);
	self.percentLabel = label;

	--倍数
	local label = FontConfig.createWithCharMap(0,"game/zhuanpan/jisuan.png",33,42,"+")
	label:setPosition(cc.p(742,670));
	label:setAnchorPoint(cc.p(0.5,0.5));
	bg:addChild(label);
	self.multLabel = label;

	local label = FontConfig.createWithCharMap(0,"game/zhuanpan/jisuan.png",33,42,"+")
	label:setPosition(cc.p(960,670));
	label:setAnchorPoint(cc.p(0.5,0.5));
	bg:addChild(label);
	self.scoreLabel = label;

	local closeBtn = ccui.Button:create("common/guanbi.png","common/guanbi-on.png")
	closeBtn:setPosition(bg:getContentSize().width*0.95+10,bg:getContentSize().height*0.9);
	bg:addChild(closeBtn);
	closeBtn:onClick(function()self:delayCloseLayer();end);
	iphoneXFit(bg,4)
end

--奖品排列
function PrizeLayer:createGoodsUI()
	local size = self.zhuanpan:getContentSize();

	--百分比
	for k,v in pairs(self.baifenNum) do
		local iconLabel = FontConfig.createWithCharMap(v..":;","game/zhuanpan/gailv.png",23,29,"0")
		iconLabel:setPosition(size.width/2+self.posData[k].x,size.height/2+self.posData[k].y);
		iconLabel:setAnchorPoint(cc.p(0.5,0.5));
		iconLabel:setScale(0.9);
		self.zhuanpan:addChild(iconLabel);

		iconLabel:setRotation(self.rotate[k]);
	end

	--倍数
	local layout = ccui.Layout:create();
	layout:setAnchorPoint(0.5,1);
	layout:setPosition(315,510);
	layout:setContentSize(cc.size(160,370));
	layout:setClippingEnabled(true);
	self.bg:addChild(layout);
	self.multLayout = layout;
	local size = layout:getContentSize();
	local y = size.height;

	local background = ccui.ImageView:create("game/zhuanpan/beishu.png");
	background:setScale9Enabled(true);
	background:setAnchorPoint(0,1);
	background:setContentSize(size);
	background:setPosition(cc.p(0,size.height));
	layout:addChild(background);
	self.multNode = background;	

	for i=1,#self.multNum do
		local image = ccui.Button:create("game/zhuanpan/"..i..".png","game/zhuanpan/"..i..".png");
		image:setTag(i);
		image:setAnchorPoint(cc.p(0.5,1));
		image:setPosition(cc.p(size.width/2,y));
		self.multNode:addChild(image);

		y = y - image:getContentSize().height;
	end

	local rand = math.random(4,6);
	self.multRand = rand;
	local dis = 0;

	if rand > 0 then
		for i=1,rand do
			for j=1,#self.multNum do
				local image = ccui.Button:create("game/zhuanpan/"..j..".png","game/zhuanpan/"..j..".png");
				image:setTag(i*#self.multNum+j);
				image:setAnchorPoint(cc.p(0.5,1));
				image:setPosition(cc.p(size.width/2,y));
				self.multNode:addChild(image);

				y = y - image:getContentSize().height;

				if i == rand-1 then
					if self.multNum[j] == mult then
						dis = self.multNode:getChildByTag(3):getPositionY() - image:getPositionY();
					end
				end
			end
		end
	end
end

function PrizeLayer:setStartBtnStatus(touch)
	self.startBtn:setTouchEnabled(touch);

	if touch  == false then
		self.light:setVisible(false);
		self.startBtn:setHighlighted(true);
	else
		self.light:setVisible(true);
		self.startBtn:setHighlighted(false);
	end
end

function PrizeLayer:onClickStart()
	self:setStartBtnStatus(false);

	RedEnvelopesInfo:sendRedEnvelopesResultRequest();
	-- self:receiveRedEnvelopesResultInfo({_usedata={rat=2,multiple=10}})
end

function PrizeLayer:onExit()
	self.super.onExit(self);

	for _, bindid in ipairs(self.bindIds) do
		BindTool.unbind(bindid)
	end

	self:playPrizeResult();
end

function PrizeLayer:receiveRedEnvelopesResultInfo(data)
	local data = data._usedata;
	self.prizeResult = data;

	luaDump(data,"抽奖结果");

	--播放抽奖动画
	local index = data.rat;

	self.angle = 360-36*(index-1);

	if self.rate == nil then
		self.rate = 360/270;--转360的单位时间
	end
	local rand = math.random(2,5);
	local dt = rand*self.rate+self.angle/360*self.rate;
	local angle = 360*rand+self.angle;

	local seq = cc.Sequence:create(
			cc.EaseExponentialInOut:create(cc.RotateBy:create(dt, angle)),
			cc.CallFunc:create(function()
				self.percentLabel:setString(self.baifenNum[index]/100);
				local size = self.zhuanpan:getContentSize();

				local image = ccui.ImageView:create("game/zhuanpan/blinkLight.png");
				image:setAnchorPoint(cc.p(0.5,0));
				image:setPosition(cc.p(self.zhuanpan:getPositionX(),self.zhuanpan:getPositionY()+35));
				self.bg:addChild(image);
				image:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5))));

				self:playMultipleAction(data.multiple);
			end)
		)
	self.zhuanpan:runAction(seq);
end

function PrizeLayer:receiveRedEnvelopesInfo(data)
	local data = data._usedata;

	self.prizeEndRsult = data;
end

function PrizeLayer:receiveUserExpandInfo(data)
	local data = data._usedata;

	self.baseReward = data.BasicBonus;

	if self.basecLabel then
		self.basecLabel:setString(goldConvert(self.baseReward));
	end

	if self.baseLabel then
		self.baseLabel:setString(goldConvert(self.baseReward));
	end
end

function PrizeLayer:playMultipleAction(mult)
	local rand = self.multRand;
	local y = self.multNode:getChildByTag(#self.multNum):getPositionY()-self.multNode:getChildByTag(#self.multNum):getContentSize().height;
	local dis = 0;

	if rand > 0 then
		for j=1,#self.multNum do
			if self.multNum[j] == mult then
				dis = self.multNode:getChildByTag(3):getPositionY() - self.multNode:getChildByTag((rand-1)*#self.multNum+j):getPositionY();
			end
		end
	end

	local dt = dis/500;

	local seq = cc.Sequence:create(
			cc.EaseExponentialInOut:create(cc.MoveBy:create(dt, cc.p(0,dis))),
			cc.CallFunc:create(function() 
				self.multLabel:setString(self.prizeResult.multiple);
				self.scoreLabel:setString(goldConvert(self.baseReward*self.baifenNum[self.prizeResult.rat]/100*self.prizeResult.multiple));
				self:delayCloseLayer(0.5);
			end)
		)
	self.multNode:runAction(seq);
end

function PrizeLayer:playBlikAction()
	local seq = cc.Sequence:create(
		cc.FadeIn:create(0.2),
		cc.FadeOut:create(0.2),
		cc.CallFunc:create(function() self:playBlikAction(); end)
	)

	local index = self.curIndex%5 + 1;

	if self.curIndex+1 >= self.multIndex then
		seq = cc.Sequence:create(
		cc.FadeIn:create(0.2),
		cc.FadeOut:create(0.2),
		cc.FadeIn:create(0.2),
		cc.CallFunc:create(function() self:delayCloseLayer(0.5); end)
	)
	end
	
	self.multBlink[index]:runAction(cc.Sequence:create(seq));

	self.curIndex = self.curIndex + 1;
end

function PrizeLayer:playPrizeResult()
	if self.prizeEndRsult then
		luaDump(self.prizeEndRsult,"prizeEndRsult")
		UserExpandInfo:sendUserExpandInfoRequest();
		FishManager:getGameLayer():showSpecialRewardLayer({_usedata=self.prizeEndRsult,flag=1});
	end	
end

return PrizeLayer

