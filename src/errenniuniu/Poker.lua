local Poker = class("Poker", function () return display.newNode(); end)

function Poker:ctor(pokerPath, pokerValue,type)
	self:initData();

	self.pokerPath = pokerPath or "";
	self.pokerValue = pokerValue or -1;
	self.type = type;

	self:initUI();
end

function Poker:initData()
	self.m_originColor = nil;
	self.pokerPath = "";
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
	if self.pokerPath == "" or self.pokerPath == nil then
		luaPrint("pokerPath is nil error !")
		local str = gameName.."\\"..os.date("%Y%m%d").."\\";
        if PlatformLogic.loginResult then
            str = str..PlatformLogic.loginResult.nickName.."牌路径为空"..os.date("%Y%m%d%H%M%S").."id"..PlatformLogic.loginResult.dwUserID..".txt";
        end
        HttpUtils:requestHttpFile(function() end, "http://120.76.43.8:8009/Public/XmlHttpUser.aspx?type=AddTxt", "self.pokerValue ="..self.pokerValue, str, 10);
		return;
	end

	--luaPrint("self.pokerPath = "..self.pokerPath.." self.pokerValue "..self.pokerValue)
	if self.type == nil then
		local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
	    local pFrame = sharedSpriteFrameCache:getSpriteFrame(self.pokerPath);
	    
	    if pFrame == nil then
	    	display.loadSpriteFrames("errenniuniu/card.plist", "errenniuniu/card.png");
	    	pFrame = sharedSpriteFrameCache:getSpriteFrame(self.pokerPath);
	    	local str = gameName.."\\"..os.date("%Y%m%d").."\\";
	        if PlatformLogic.loginResult then
	            str = str..PlatformLogic.loginResult.nickName.."牌缓存异常"..os.date("%Y%m%d%H%M%S").."id"..PlatformLogic.loginResult.dwUserID..".txt";
	        end
	        --HttpUtils:requestHttpFile(function() end, "http://120.76.43.8:8009/Public/XmlHttpUser.aspx?type=AddTxt", "self.pokerPath ="..self.pokerPath, str, 10);
	    end

	    if pFrame == nil then
	    	local str = gameName.."\\"..os.date("%Y%m%d").."\\";
	        if PlatformLogic.loginResult then
	            str = str..PlatformLogic.loginResult.nickName.."牌二次缓存异常"..os.date("%Y%m%d%H%M%S").."id"..PlatformLogic.loginResult.dwUserID..".txt";
	        end
	        --HttpUtils:requestHttpFile(function() end, "http://120.76.43.8:8009/Public/XmlHttpUser.aspx?type=AddTxt", "self.pokerPath ="..self.pokerPath, str, 10);
	    end

	    self.pokerNode = cc.Sprite:createWithSpriteFrame(pFrame);

	   	if self.pokerNode == nil then
	   		self.pokerNode = cc.Sprite:createWithSpriteFrame(pFrame);
	   		local str = gameName.."\\"..os.date("%Y%m%d").."\\";
	        if PlatformLogic.loginResult then
	            str = str..PlatformLogic.loginResult.nickName.."牌二次创建异常"..os.date("%Y%m%d%H%M%S").."id"..PlatformLogic.loginResult.dwUserID..".txt";
	        end
	        --HttpUtils:requestHttpFile(function() end, "http://120.76.43.8:8009/Public/XmlHttpUser.aspx?type=AddTxt", "self.pokerPath ="..self.pokerPath, str, 10);
	   	end
	end

	if self.type then
		self.pokerNode = cc.Sprite:create(self.pokerPath);
	end
    if self.pokerNode then
    	-- luaPrint("创建了poker "..self.pokerPath)
    	self:setContentSize(cc.size(self.pokerNode:getContentSize().width, self.pokerNode:getContentSize().height));
    	self.pokerNode:setAnchorPoint(cc.p(0,0));
    	self:addChild(self.pokerNode);
    	self.m_originColor = self.pokerNode:getColor();
    end
end

--刷新牌面
function Poker:updataCard(pokerPath,pokerValue)
	if pokerValue == nil then
		return ;
	end
	self.pokerPath = pokerPath or "";
	self.pokerValue = pokerValue or -1;
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    local pFrame = sharedSpriteFrameCache:getSpriteFrame(self.pokerPath);
    if pFrame == nil then
    	display.loadSpriteFrames("errenniuniu/card.plist", "errenniuniu/card.png");
    end
    if pFrame then
    	luaPrint("updataCard");
    	self.pokerNode:setSpriteFrame(pFrame); 
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
	-- luaPrint("self.pokerValue  ===== "..self.pokerValue)

	if self:isWuShiK() then
		self:setPokerHighlighted(false);
	end
end

function Poker:getPokerValue()
	return self.pokerValue;
end

function Poker:isWuShiK()
	local isFlag = false;

	local value = self.pokerValue % 16;

	if value == 5 or value == 10 or value == 13 then
		isFlag = true;
	end
	isFlag = false;
	return isFlag;
end

function Poker:WuShiK()

	if self.pokerValue % 16 == 5 or self.pokerValue % 16 == 10 or self.pokerValue % 16 == 13 then
		return true;
	else
		return false;
	end
	
end

function Poker:setPokerHighlighted(isHighLighted)
	if isHighLighted == nil then
		isHighLighted = true;
	end

	if self:isWuShiK() then
		isHighLighted = false;
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

--滑动选择 方向保存
function Poker:setMoveDir(dir)
	self.moveDir = dir;
end

function Poker:getMoveDir()
	return self.moveDir;
end

function Poker:setOriginPos(pos)
	self.pokerOriginPos = pos;
end

function Poker:setIsUp(is)
	self.pokerIsUp = is;
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
