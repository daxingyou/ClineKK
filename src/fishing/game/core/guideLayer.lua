GuideTypeMobileBind = 1	--手机绑定
GuideTypeFastStart = 2	--快速开始
GuideTypeLockSkill = 3	--锁定技能
GuideTypeCatchFishTask = 4	--捕鱼任务
GuideTypeCannonUnlock = 5	--炮倍解锁

local GuideLayer = class("GuideLayer", function () return cc.Node:create(); end)

function GuideLayer:ctor(guideType)
	self.guideType = guideType;

	self:initData()
	if self.isGuideShow then
		self:createUI()
	end
end

function GuideLayer:initData()
	self.allDirection  = {top=1,bottom=2,left=3,right=4,no=5};
	self.allTextImage = {"","","skillTips","taskTips","unlockTips"}
	self.pos = nil;
	self.movePos = nil;
	self.isFlip = false;
	self.isGuideShow = true

	if self.guideType == GuideTypeMobileBind then
		self.direction = self.allDirection.right;
	elseif self.guideType == GuideTypeFastStart then
		self.direction = self.allDirection.no;
		self.movePos = cc.p(0,-20);
		self:isShow()
	elseif self.guideType == GuideTypeLockSkill then
		self.direction = self.allDirection.top;
		self.pos = cc.p(0,50);
		self.movePos = cc.p(0,-20);
		self:isShow()
	elseif self.guideType == GuideTypeCatchFishTask then
		self.direction = self.allDirection.bottom;
		self.pos = cc.p(0,-50);
		self.movePos = cc.p(0,20);
		self.isFlip = true;
		self:isShow()
	elseif self.guideType == GuideTypeCannonUnlock then
		self.direction = self.allDirection.top;
		self.pos = cc.p(0,50);
		self.movePos = cc.p(0,-20);
	end

	--显示状态
	self:setVisible(self.isGuideShow)
end

function GuideLayer:isShow()
	local isGuide = cc.UserDefault:getInstance():getStringForKey("test"..self.guideType.."_isguide","")  
	if string.len(isGuide) == 0 then
		self.isGuideShow = true
	else
		self.isGuideShow = false
	end
end

function GuideLayer:hideGuide()
	self:removeAllChildren()
	cc.UserDefault:getInstance():setStringForKey("test"..self.guideType.."_isguide", "true")  
end

function GuideLayer:createUI()
	if self.guideType == GuideTypeMobileBind then
		self:createMobileBindLayer();
	else
		self:createGuideLayer();
	end

	if self.guideType == GuideTypeCatchFishTask or self.guideType == GuideTypeCannonUnlock then--self.isShow then
		self:playAction()
	end
end

function GuideLayer:createMobileBindLayer()
	local bg = ccui.ImageView:create("guide/bindBg.png");
	bg:setAnchorPoint(0,1);
	bg:setPosition(-30, 40);
	self:addChild(bg);

	local text  = ccui.Text:create("绑定手机可获得奖励哦",FONT_PTY_TEXT,20);
	text:setPosition(bg:getContentSize().width/2+2, bg:getContentSize().height/2-5);
	text:setAnchorPoint(0.5,0.5);
	text:enableOutline(cc.c4b(0,45,75,255),2);
	bg:addChild(text);
end

function GuideLayer:createGuideLayer()
	luaPrint("创建引导")
	--箭头
	local arrow = ccui.ImageView:create("hall/guide/arrow.png");
	self:addChild(arrow);

	if self.isFlip == true then
		arrow:setFlippedY(true);
	end

	if self.movePos ~= nil then
		local move = cc.MoveBy:create(0.3, self.movePos);
		arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(move,move:reverse())));
	end

	--文字
	if self.allTextImage[self.guideType] ~= "" then
		local text = ccui.ImageView:create("hall/guide/"..self.allTextImage[self.guideType]..".png");
		text:setPosition(self.pos);
		self:addChild(text);
	end
end

function GuideLayer:playAction()
	--延时播放动画
    local actionTalbe = {};
    table.insert(actionTalbe,cc.DelayTime:create(5));
    table.insert(actionTalbe, cc.CallFunc:create(function() self:setVisible(false); end));

    self:runAction(cc.Sequence:create(actionTalbe))
end

return GuideLayer;
