

local Poker = class("Poker", function () return display.newNode(); end)

function Poker:ctor(pokerValue)
	self:initData();

	self.pokerValue = pokerValue or -1;

	self:initUI();
end

function Poker:initData()
	self.m_originColor = nil;
	self.pokerValue = -1;
	self.pokerNode = nil;
	self.target = nil;
	self.isSelected = false;

	self.index = -1;--牌索引
	self.moveDir = -1;--滑动选中方向 0 左滑 1 右滑
	self.isChangePosY = -1;
	self.pokerOriginPos = nil;--原始位置
	self.pokerIsUp = false;--是否弹起

	self.group = 0; --理牌组

end

function Poker:setTarget(target)
	self.target = target;
end

function Poker:initUI()
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");

	local pathvalue = string.format("dzpk_0x%02X.png", self.pokerValue);

	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    local pFrame = sharedSpriteFrameCache:getSpriteFrame(pathvalue);
    
    -- self.pokerNode = cc.Sprite:createWithSpriteFrame(pFrame);
    self.pokerNode = ccui.ImageView:create();
    self.pokerNode:loadTexture(pathvalue,UI_TEX_TYPE_PLIST);

    if self.pokerNode then
    	-- luaPrint("创建了poker ")
    	self:setContentSize(cc.size(self.pokerNode:getContentSize().width, self.pokerNode:getContentSize().height));
    	-- self.pokerNode:setAnchorPoint(cc.p(0,0));
    	self:addChild(self.pokerNode);
    	self.m_originColor = self.pokerNode:getColor();
    end
end

--刷新牌面
function Poker:updataCard(pokerValue)
	if pokerValue == nil then
		return ;
	end
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	self.pokerValue = pokerValue or -1;
	local pathvalue = string.format("dzpk_0x%02X.png", self.pokerValue);
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    local pFrame = sharedSpriteFrameCache:getSpriteFrame(pathvalue);
    if pFrame then
    	luaPrint("updataCard");
    	-- self.pokerNode:setSpriteFrame(pFrame); 
    	self.pokerNode:loadTexture(pathvalue,UI_TEX_TYPE_PLIST);
    end
    
end

function Poker:setAutoScale(scale)
	self:setScale(scale);
	local size = self:getContentSize();
	self:setContentSize(cc.size(size.width * scale, size.height * scale));
end

function Poker:setAutoRotate(rotate)
	self:setRotation(rotate);
end

function Poker:onTouchEvent(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		luaPrint("Poker:onTouchEvent begin -----")
	elseif eventType == ccui.TouchEventType.ended then
		luaPrint("Poker:onTouchEvent ended -----")
		if self.target ~= nil then
			self.isSelected = not self.isSelected;
			--self.target:touchPokerDeal(self);
		end
	end
end

function Poker:setPokerValue(value)
	self.pokerValue = value;
end

function Poker:getPokerValue()
	return self.pokerValue%16;
end


function Poker:setPokerHighlighted(isHighLighted)
	if isHighLighted == nil then
		isHighLighted = true;
	end

	if isHighLighted == true then
		self:setColorOrgin();
	else
		self:setPokerGray();
	end
end

--灰色
function Poker:setPokerGray()
	if self.pokerNode then
		self.pokerNode:setColor(FontConfig.colorGray);
	else
		luaPrint("Poker:setPokerGray() error")
	end
end

--绿色
function Poker:setPokerGreen()
	if self.pokerNode then
		self.pokerNode:setColor(cc.c3b(193, 255, 193));
	else
		luaPrint("Poker:setPokerGreen() error")
	end
end

--红色
function Poker:setPokerRed()
	if self.pokerNode then
		self.pokerNode:setColor(cc.c3b(255, 228, 225));
	else
		luaPrint("Poker:setPokerRed() error")
	end
end

--高亮
function Poker:setColorOrgin()
	if self.pokerNode then
		self.pokerNode:setColor(self.m_originColor);
	end
end

function Poker:getIsSelected()
	return self.isSelected;
end

function Poker:setIsSelected(selected)
	self.isSelected = selected;
end

function Poker:setIndex(index)
	self.index = index;
end

function Poker:getIndex()
	return self.index;
end

function Poker:setNewPosX(x)
	if x ~= nil then
		self:setPositionX(self:getPositionX() + x);
	end
end

function Poker:setNewPosY(y)
	if y == nil then
		return;
	end

	if self.isChangePosY == 0 and y > 0 then
		return;
	end

	if self.isChangePosY == 1 and y < 0 then
		return;
	end

	self:setPositionY(self:getPositionY() + y);

	if y > 0 then
		self.isChangePosY = 0;--up
	elseif y < 0 then
		self.isChangePosY = 1;--down
	end
end


function Poker:setOriginPos(pos)
	self.pokerOriginPos = pos;
end

function Poker:setIsUp(isup)
	self.pokerIsUp = isup;
end

function Poker:getIsUp()
	return self.pokerIsUp;
end

function Poker:setGroup(group)
	self.group = group;
end

function Poker:getGroup()
	return self.group;
end


return Poker
