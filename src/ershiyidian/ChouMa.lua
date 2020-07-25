local ChouMa = class("ChouMa", function () return display.newNode(); end)
function ChouMa:create(lSeatNo,score)
	return ChouMa.new(lSeatNo,score);
end

function ChouMa:ctor(lSeatNo,score)

	self:initData(lSeatNo,score);
	self:initUI();
end

function ChouMa:initData(lSeatNo,score)
	self.lSeatNo = lSeatNo;--座位号，不同的座位号，筹码颜色不同
	self.score = score
	self.resStr = self:getStr(self.score);--str;--资源路径
	self.isMe = false;
	self.area = 0;
	self.LabelAtlas = nil;
end

function ChouMa:getStr(score)
	local bit = 100;
	local str = "";
	local TableLayer = require("ershiyidian.TableLayer");
	local tableLayer = TableLayer:getInstance();
	local temp = {};
	temp = tableLayer.scoreTable;
	--luaDump(temp,"getStr");
	if score == temp[1] then
		str = "21D_chouma3.png"
	elseif score == temp[2] then
		str = "21D_chouma2.png"
	elseif score == temp[3] then
		str = "21D_chouma5.png"
	elseif score == temp[4] then
		str = "21D_chouma4.png"
	elseif score == temp[5] then
		str = "21D_chouma1.png"
	else
		str = "21D_chouma3.png"
	end
	--luaPrint("ChouMa:getStr",str);
	--luaPrint("str",str,self.score);
	str = "21D_chouma3.png"
	return str;
end

function ChouMa:getScore()
	return self.score;
end

function ChouMa:getSeatNo()
	return self.lSeatNo;
end

function ChouMa:initUI()
	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    local pFrame = sharedSpriteFrameCache:getSpriteFrame(self.resStr);
    if pFrame == nil then
    	luaPrint("缓存被清除，创建筹码出现问题");
    	display.loadSpriteFrames("ershiyidian/ershiyidian.plist", "ershiyidian/ershiyidian.png");
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

--筹码上的数字
function ChouMa:setNum(num)
	luaPrint("setNum",num);
	
	-- if self.LabelAtlas then
	-- 	self.LabelAtlas:setString(numberToString2(num));
	-- else
	-- 	self.LabelAtlas = ccui.Text:create("",FONT_PTY_TEXT,20);
	-- 	self:addChild(self.LabelAtlas,1000);
	-- 	self.LabelAtlas:setString(numberToString2(num));
	-- 	self.LabelAtlas:setPosition(cc.p(0,5));
	-- end

	-- --筹码上的数字不要了
	-- if self.LabelAtlas then
	-- 	self.LabelAtlas:setVisible(false);
	-- end

end

--设置筹码数字可见性
function ChouMa:setNumVisible(visible)
	if self.LabelAtlas then
		self.LabelAtlas:setVisible(visible);
	end
end

return ChouMa;