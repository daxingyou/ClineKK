local ChouMa = class("ChouMa", function () return display.newNode(); end)

function ChouMa:create(score)
	return ChouMa.new(score);
end

function ChouMa:ctor(score)

	self:initData(score);
	self:initUI();
end

function ChouMa:initData(score)
	self.score = score
	self.resStr = self:getStr(self.score);--str;--资源路径
	self.isMe = false;
	self.area = 0;
end

function ChouMa:getStr(score)
	--local str = "baijiale/chouma/100.png";
	local bit = 100;
	--luaPrint("ChouMa:score",score);
	if score == 100 then
		str = "BJL_chou_1.png"--"baijiale/chouma/1.png"
	elseif score == 1000 then
		str = "BJL_chou_10.png"--"baijiale/chouma/10.png"
	elseif score == 5000 then
		str = "BJL_chou_50.png"--"baijiale/chouma/50.png"
	elseif score == 10000 then
		str = "BJL_chou_100.png"--"baijiale/chouma/100.png"
	elseif score == 50000 then
		str = "BJL_chou_500.png"--"baijiale/chouma/500.png"
	elseif score == 100000 then
		str = "BJL_chou_1000.png"--"baijiale/chouma/1000.png"
	else
		--return;
	end
	--luaPrint("ChouMa:getStr",str);
	return str;
end

function ChouMa:getScore()
	return self.score;
end

function ChouMa:initUI()
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    local pFrame = sharedSpriteFrameCache:getSpriteFrame(self.resStr);
    if pFrame == nil then
    	luaPrint("缓存被清除，创建筹码出现问题");
    	display.loadSpriteFrames("errenniuniu/errenniuniu.plist", "errenniuniu/errenniuniu.png");
    	pFrame = sharedSpriteFrameCache:getSpriteFrame(self.resStr);
    end 
	local sprite = cc.Sprite:createWithSpriteFrame(pFrame);--cc.Sprite:create(self.resStr);
	self:addChild(sprite);
end

function ChouMa:setIsMe(isMe)
	self.isMe = isMe;
end

function ChouMa:getIsMe()
	return self.isMe
end

function ChouMa:setArea(area)
	self.area = area;
end

function ChouMa:getArea()
	return self.area
end

return ChouMa;