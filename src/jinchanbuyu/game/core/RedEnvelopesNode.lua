local RedEnvelopesNode = class("RedEnvelopesNode", BaseNode)

function RedEnvelopesNode:create()
	return RedEnvelopesNode.new();
end

function RedEnvelopesNode:ctor()
	self.super.ctor(self)

	self:bindEvent();

	self:initData();

	self:initUI();
end

function RedEnvelopesNode:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = BindTool.bind(UserExpandInfo, "userExpandInfo", handler(self, self.receiveUserExpandInfo))--用户扩展属性
end

function RedEnvelopesNode:onExit()
	self.super.onExit(self);

	for _, bindid in ipairs(self.bindIds) do
		BindTool.unbind(bindid)
	end
end

function RedEnvelopesNode:initData()
	self.redImage = {};
	self.orginColor = nil;
end

function RedEnvelopesNode:initUI()
	local bg = ccui.ImageView:create("game/bg.png");
	bg:setScale9Enabled(true)
	-- bg:setContentSize(cc.size(300, 110));
	bg:setAnchorPoint(cc.p(0.5,1));
	bg:setPosition(cc.p(0,0));
	self:addChild(bg);
	self.bg = bg;

	local size = bg:getContentSize();
	self.moveY = 0;

	local node = cc.Node:create();
	node:setPosition(size.width/2,size.height);
	bg:addChild(node);
	self.baseNode = node;
	self.oldX = size.width/2;

	local baseImage = ccui.ImageView:create("game/baseScore.png");
	baseImage:setAnchorPoint(cc.p(0,0.5));
	baseImage:setPosition(0,-baseImage:getContentSize().height/2-5);
	node:addChild(baseImage);

	local label = FontConfig.createWithCharMap(goldConvert(UserExpandInfo.userExpandInfo.BasicBonus),"game/baseNum.png",15,20,"0");
	label:setPosition(baseImage:getContentSize().width+5,baseImage:getContentSize().height/2);
	label:setAnchorPoint(cc.p(0,0.5));
	baseImage:addChild(label);
	self.baseScoreLabel = label;
	self.baseWidth = baseImage:getContentSize().width;

	local len = baseImage:getContentSize().width + label:getContentSize().width + 5;
	node:setPositionX(node:getPositionX() - len/2);

	--创建红包
	local x = 0;
	local y = size.height-baseImage:getContentSize().height-12;
	local dis = 10;
	local y1 = y;

	for i=1,3 do
		local image = ccui.ImageView:create("game/hongbao.png");

		if x == 0 then
			x = size.width/2 - image:getContentSize().width - dis;
			y1 = y1 - image:getContentSize().height;
			self.moveY = baseImage:getContentSize().height+12+image:getContentSize().height+5;
		end

		image:setAnchorPoint(cc.p(0.5,1));
		image:setPosition(cc.p(x,y));
		bg:addChild(image);
		self.orginColor = image:getColor();

		if i > UserExpandInfo.userExpandInfo.HongBaoCount then
			image:setColor(cc.c3b(125,125,125));
		end

		x = x + image:getContentSize().width + dis;

		table.insert(self.redImage, image);
	end

	--抽奖按钮
	local btn = ccui.Widget:create();
	btn:setContentSize(cc.size(170,68));
	btn:setPosition(size.width*0.5,y);
	btn:setAnchorPoint(cc.p(0.5,1));
	bg:addChild(btn);
	btn:onClick(function(sender)self:onCLickPrize(sender);end);
	self.prizeBtn = btn;
	self.prizeBtn:setTouchEnabled(UserExpandInfo.userExpandInfo.HongBaoCount >= #self.redImage);

	local btn = ccui.Widget:create();
	btn:setTouchEnabled(true);
	btn:setContentSize(cc.size(45,40));
	btn:setPosition(size.width/2,y1-20);
	btn:setAnchorPoint(cc.p(0.5,0.5));
	bg:addChild(btn);
	btn:setTag(0);
	btn:setLocalZOrder(3);
	btn:onClick(function(sender)self:onClickTip(sender);end);

	local image = ccui.ImageView:create("game/redTip.png");
	image:setPosition(btn:getContentSize().width/2,image:getContentSize().height/2);
	-- image:setAnchorPoint(cc.p(0.5,0));
	btn:addChild(image);
	image:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,10)),cc.MoveBy:create(0.5,cc.p(0,-10)))));
	self.tipBtn = btn;
	self.tipImage = image;

	self:showPrizeEffect(UserExpandInfo.userExpandInfo.HongBaoCount >= #self.redImage);
end

function RedEnvelopesNode:receiveUserExpandInfo(data)
	local data = data._usedata;

	self:updateUI();
end

function RedEnvelopesNode:updateUI()
	for k,v in pairs(self.redImage) do
		if k > UserExpandInfo.userExpandInfo.HongBaoCount then
			v:setColor(cc.c3b(125,125,125));
		else
			v:setColor(self.orginColor);
		end
	end

	self.prizeBtn:setTouchEnabled(UserExpandInfo.userExpandInfo.HongBaoCount >= #self.redImage);
	self.baseScoreLabel:setString(goldConvert(UserExpandInfo.userExpandInfo.BasicBonus));
	local len = self.baseWidth + self.baseScoreLabel:getContentSize().width+5;
	self.baseNode:setPositionX(self.oldX - len/2);

	if UserExpandInfo.userExpandInfo.HongBaoCount == #self.redImage then
		if self.tipBtn:isTouchEnabled() then
			if self.tipBtn:getTag() == 1 then
				self:onClickTip(self.tipBtn);
			end			
		else
			if self.tipBtn:getTag() == 1 then
				performWithDelay(self,function() self:onClickTip(self.tipBtn); end,0.5);
			end
		end
	end

	self:showPrizeEffect(UserExpandInfo.userExpandInfo.HongBaoCount >= #self.redImage);
end

function RedEnvelopesNode:showPrizeEffect(isShow)
	if self.playPrizeEffect == nil and isShow == true then
		local skeleton_animation = createSkeletonAnimation("hongbaojiqi","game/effect/hongbaojiqi.json", "game/effect/hongbaojiqi.atlas");
		if skeleton_animation then
			skeleton_animation:setAnchorPoint(cc.p(0.5,0.5));
			skeleton_animation:setPosition(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2-57);
			skeleton_animation:setAnimation(1,"hongbaojiqi", true);
			self.bg:addChild(skeleton_animation);

			self.playPrizeEffect = skeleton_animation;
		end
	end

	if isShow ~= true and self.playPrizeEffect then
		self.playPrizeEffect:removeSelf();
		self.playPrizeEffect = nil;
	end
end

--获得红包碎片时，播放飞入动画
function RedEnvelopesNode:playGetRedEnvelopesAction(goodsInfo,startPos)
	UserExpandInfo.userExpandInfo.HongBaoCount = UserExpandInfo.userExpandInfo.HongBaoCount + goodsInfo.goodsCount;

	local lp = self.bg:convertToNodeSpace(startPos);

	local node = ccui.ImageView:create("game/hongbao.png");
	node:setAnchorPoint(cc.p(0.5,1));
	node:setPosition(cc.p(lp.x,lp.y+node:getContentSize().height/2));
	self.bg:addChild(node);

	local endPos = cc.p(self.redImage[UserExpandInfo.userExpandInfo.HongBaoCount]:getPosition());

	local moveTo = cc.MoveTo:create(1.5, endPos);
	local easeAction = cc.EaseSineIn:create(moveTo);
	local seq = cc.Sequence:create(easeAction, cc.CallFunc:create(function() node:removeSelf(); UserExpandInfo:sendUserExpandInfoRequest(); self:updateUI(); end));

	node:runAction(seq);
end

function RedEnvelopesNode:onCLickPrize(sender)
	FishManager:getGameLayer():showPrizeLayer();
end

function RedEnvelopesNode:onClickTip(sender)
	local tag = sender:getTag();

	sender:setTouchEnabled(false);

	local y = self.moveY;
	local x = -1;
	if tag == 0 then--缩进去
		sender:setTag(1);
	elseif tag == 1 then--伸出来
		y = -self.moveY;
		sender:setTag(0);
		x = 1;
	end	
	
	self:runAction(cc.Sequence:create(
		cc.MoveBy:create(0.5,cc.p(0,y)),
		cc.CallFunc:create(function() self.tipImage:setScaleY(x); self.tipBtn:setTouchEnabled(true); end)
	));
end

return RedEnvelopesNode;
