local RockingMoneyTreeLayer = class("RockingMoneyTreeLayer",BaseWindow)

function RockingMoneyTreeLayer:create()
	return RockingMoneyTreeLayer.new();
end

function RockingMoneyTreeLayer:ctor()
	self.super.ctor(self, true, true);

	self:bindEvent();

	self:initData();

	self:initUI();
end

function RockingMoneyTreeLayer:initData()
	self.rockingResult = {}
	self.fishScore = 0;--摇到的金币和话费总数量
	self.fishHuaFei = 0;
	self.maxClickCount = 30;--最多摇一摇次数
	self.curClickCount = 0;
	self.rockingTime = 8;--游戏时长
end

function RockingMoneyTreeLayer:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = BindTool.bind(RockingMoneyTreeInfo, "rockingMoneyTreeInfo", handler(self, self.receiveRockingMoneyTreeInfo))--砸金蛋结果
end

function RockingMoneyTreeLayer:unBindEvent()	
	for _, bindid in ipairs(self.bindIds) do
		BindTool.unbind(bindid)
	end
end

function RockingMoneyTreeLayer:onExit()
	self.super.onExit(self);

	for _, bindid in ipairs(self.bindIds) do
		BindTool.unbind(bindid)
	end

	self:playRockingResult();
end

function RockingMoneyTreeLayer:initUI()
	local size = cc.Director:getInstance():getWinSize();
	local bg = ccui.ImageView:create("game/rockBg.png");
	bg:setPosition(cc.p(size.width/2,size.height/2));
	self:addChild(bg);

	local size = bg:getContentSize();

	local title = ccui.ImageView:create("game/rockTitle.png");
	title:setPosition(cc.p(size.width*0.47,size.height*0.9-10));
	bg:addChild(title);

	local infoBg = ccui.ImageView:create("game/rockInfoBg.png");
	infoBg:setAnchorPoint(cc.p(0,0.5));
	infoBg:setPosition(cc.p(10,size.height*0.7));
	bg:addChild(infoBg);

	local info = ccui.ImageView:create("game/rockInfo.png");
	info:setPosition(cc.p(infoBg:getContentSize().width/2,infoBg:getContentSize().height/2));
	infoBg:addChild(info);

	--创建摇钱树
	local btn = ccui.Widget:create();
	btn:setTouchEnabled(true);
	btn:setSwallowTouches(false);
	btn:setContentSize(cc.size(400,300));
	btn:setAnchorPoint(cc.p(0.5,0.5));
	btn:setPosition(cc.p(size.width/2,size.height/2));
	bg:addChild(btn);
	btn:onClick(function(sender)
		self:onClickRockingMoneyTree(sender);
	end);
	self.rockingBtn = btn;

	local skeleton_animation = createSkeletonAnimation("yaoqianshu","game/effect/yaoqianshu.json", "game/effect/yaoqianshu.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2);
		btn:addChild(skeleton_animation);
		skeleton_animation:setLocalZOrder(2);
		skeleton_animation:setAnimation(1,"buyao", false);
		self.rockingEffect = skeleton_animation;
	end

	local closeBtn = ccui.Button:create("common/guanbi.png","common/guanbi-on.png")
	closeBtn:setPosition(size.width*0.95,size.height*0.9);
	bg:addChild(closeBtn);
	closeBtn:onClick(function()self:delayCloseLayer();end);

	--摇到的金币和话费
	local y = 40;
	local infoBg = ccui.ImageView:create("game/infoBg.png");
	infoBg:setPosition(cc.p(size.width/2,y));
	bg:addChild(infoBg);

	local goldBg = ccui.ImageView:create("game/moneyBg.png");
	goldBg:setPosition(cc.p(infoBg:getContentSize().width*0.5,infoBg:getContentSize().height/2));
	infoBg:addChild(goldBg);

	local gold = ccui.ImageView:create("email/goods/goods0.png");
	gold:setPosition(cc.p(goldBg:getContentSize().width*0.1,goldBg:getContentSize().height/2));
	gold:setScale(0.7);
	goldBg:addChild(gold);

	local label = FontConfig.createWithCharMap("0","game/moneyNum.png",16,21,"+");
	label:setPosition(gold:getContentSize().width+20,gold:getContentSize().height/2);
	label:setAnchorPoint(cc.p(0,0.5));
	label:setScale(1/0.7);
	gold:addChild(label);
	self.goldLabel = label;

	-- local huafeiBg = ccui.ImageView:create("game/moneyBg.png");
	-- huafeiBg:setPosition(cc.p(infoBg:getContentSize().width*0.65,infoBg:getContentSize().height/2));
	-- infoBg:addChild(huafeiBg);

	-- local huafei = ccui.ImageView:create("email/goods/goods1.png");
	-- huafei:setPosition(cc.p(huafeiBg:getContentSize().width*0.1,huafeiBg:getContentSize().height/2));
	-- huafei:setScale(0.7);
	-- huafeiBg:addChild(huafei);

	-- local label = FontConfig.createWithCharMap("0<=","game/moneyNum.png",16,21,"+");
	-- label:setPosition(huafei:getContentSize().width+20,huafei:getContentSize().height/2);
	-- label:setAnchorPoint(cc.p(0,0.5));
	-- label:setScale(1/0.7);
	-- huafei:addChild(label);
	-- self.huafeiLabel = label;

	-- local label = FontConfig.createWithSystemFont("还剩"..(self.maxClickCount-self.curClickCount).."次机会",22,FontConfig.colorWhite);
	-- label:setPosition(size.width/2,y/2);
	-- bg:addChild(label);
	-- self.clickLabel = label;

	--结束倒计时
	local timeBg = ccui.ImageView:create("game/clock.png");
	timeBg:setPosition(cc.p(size.width*0.8,size.height*0.8));
	bg:addChild(timeBg);
	timeBg:setVisible(false);
	self.timeBg = timeBg;

	local timeText = FontConfig.createWithSystemFont(self.rockingTime,26,FontConfig.colorBlack);
	timeText:setPosition(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2);
	timeText:setTag(self.rockingTime);
	timeBg:addChild(timeText);
	self.timeText = timeText;

	local skeleton_animation = createSkeletonAnimation("shouzhi","game/effect/shouzhi.json", "game/effect/shouzhi.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2);
		btn:addChild(skeleton_animation,10);
		skeleton_animation:hide();
		self.fingerEffect = skeleton_animation;
	end
	iphoneXFit(bg,4)
end

function RockingMoneyTreeLayer:onClickRockingMoneyTree(sender)
	-- if self.curClickCount >= self.maxClickCount then
	-- 	Hall.showTips("您的机会已用完，期待下一次！");
	-- 	return;
	-- end

	self.clickPos = sender:convertToNodeSpace(cc.p(sender:getTouchEndPosition()));

	self:playFingerEffect();

	self:playRockingMoneyTreeEffect();

	RockingMoneyTreeInfo:sendRockingMoneyTreeRequest();
end

--摇一摇结束倒计时
function RockingMoneyTreeLayer:playRockingEndTimer()
	if self.isPlaying == true then
		return;
	end

	self.isPlaying = true;

	self.timeBg:setVisible(true);

	local func = function() 
		local tag = self.timeText:getTag()-1;

		self.timeText:setString(tag);
		self.timeText:setTag(tag);

		if tag == 3 then
			self:shakeClockIcon(tag);
		end

		if tag <= 0 then--结束
			self.rockingBtn:setTouchEnabled(false);
			self:delayCloseLayer(0.5);--0.5s后关闭页面
		end
	end

	schedule(self.timeBg,func,1);
end

function RockingMoneyTreeLayer:shakeClockIcon(actionTime)
	local time = 0.05

	local paths = {};
	local pos = cc.p(self.timeBg:getPosition())
	for i=1,actionTime / time  do

		local move = cc.MoveTo:create(time,cc.p(pos.x + math.random(-10,10),pos.y + math.random(-10,10)))
		local rotation = cc.RotateTo:create(time,math.random(-15,15))
		local spawn = cc.Spawn:create(move,rotation)
		table.insert(paths,spawn);
	end

	local move = cc.MoveTo:create(time,cc.p(pos.x,pos.y))
	local rotation = cc.RotateTo:create(time,0)
	local spawn = cc.Spawn:create(move,rotation)
	table.insert(paths,spawn);

	self.timeBg:runAction(cc.Sequence:create(paths))
end

--播放摇一摇动画
function RockingMoneyTreeLayer:playRockingMoneyTreeEffect()
	self.rockingEffect:clearTracks();
	self.rockingEffect:setAnimation(2,"yao", false);
end

function RockingMoneyTreeLayer:playFingerEffect()
	if self.clickPos then
		self:stopActionByTag(123);
		self.fingerEffect:setPosition(cc.p(self.clickPos.x+50,self.clickPos.y-40))
		self.clickPos = nil;
		self.fingerEffect:show();

		self.fingerEffect:clearTracks();
		self.fingerEffect:setAnimation(2,"an", false);

		performWithDelay(self,function() self.fingerEffect:hide(); end,0.7):setTag(123);
	end
end

function RockingMoneyTreeLayer:receiveRockingMoneyTreeInfo(data)
	local data = data._usedata;
	luaDump(data,"摇一摇结果");
	
	table.insert(self.rockingResult, data);

	self:playRockingDropEffect();

	self.curClickCount = self.curClickCount + 1;
	self.fishScore = self.fishScore + data.fish_score;
	self.fishHuaFei = self.fishHuaFei + data.iLotteries

	self:updateRockingMoneyTreeInfo();

	self:playRockingEndTimer();
end

--播放掉钱动画
function RockingMoneyTreeLayer:playRockingDropEffect()
	local skeleton_animation = createSkeletonAnimation("coin_hou","game/effect/coin_hou.json", "game/effect/coin_hou.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(self.rockingBtn:getContentSize().width/2,self.rockingBtn:getContentSize().height/2);
		self.rockingBtn:addChild(skeleton_animation);
		skeleton_animation:setLocalZOrder(1);
		skeleton_animation:setAnimation(1,"coin_hou", false);
		skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() skeleton_animation:removeSelf(); end)));
	end
	local skeleton_animation = createSkeletonAnimation("coin-qian","game/effect/coin-qian.json", "game/effect/coin-qian.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(self.rockingBtn:getContentSize().width/2,self.rockingBtn:getContentSize().height/2);
		self.rockingBtn:addChild(skeleton_animation);
		skeleton_animation:setLocalZOrder(2);
		skeleton_animation:setAnimation(1,"coin-qian", false);
		skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function() skeleton_animation:removeSelf(); end)));
	end
end

--更新摇一摇结果
function RockingMoneyTreeLayer:updateRockingMoneyTreeInfo()
	if self.goldLabel then
		self.goldLabel:setString(goldConvert(self.fishScore));
	end

	-- if self.huafeiLabel then
	-- 	self.huafeiLabel:setString(self.fishHuaFei.."<=");
	-- end

	-- if self.clickLabel then
	-- 	self.clickLabel:setString("还剩"..(self.maxClickCount-self.curClickCount).."次机会");
	-- end

	luaPrint("还剩"..(self.maxClickCount-self.curClickCount).."次机会")

	if self.curClickCount >= self.maxClickCount then
		-- self.rockingBtn:setTouchEnabled(false);
	end
end

function RockingMoneyTreeLayer:playRockingResult()
	local data = {fish_score=self.fishScore,iLotteries=self.fishHuaFei,UserLotteries=0};

	if #self.rockingResult > 0 then
		data.UserFishscore=self.rockingResult[#self.rockingResult].UserFishscore;
		FishManager:getGameLayer():showSpecialRewardLayer({_usedata=data,flag = 1});
	end
end

return RockingMoneyTreeLayer;
