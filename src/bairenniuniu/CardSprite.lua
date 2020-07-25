local GameLogic = require("bairenniuniu.GameLogic")

local CardSprite = class("CardSprite", function() return cc.Sprite:create() end);

function CardSprite:ctor()
	self.m_cardData = 0
	self.m_cardValue = 0
	self.m_cardColor = 0
end

--创建卡牌
function CardSprite:createCard( cbCardData )
	local card= CardSprite.new()
	luaPrint("CardSprite:createCard_sp:",cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("brnn_0x%02X.png",cbCardData)));
    card:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("brnn_0x%02X.png",cbCardData)));
    card.m_cardData = cbCardData;
	card.m_cardValue = GameLogic.GetCardValue(cbCardData) --math.mod(cbCardData, 16)--bit:_and(cbCardData, 0x0F)
	card.m_cardColor = GameLogic.GetCardColor(cbCardData) --math.floor(cbCardData / 16)--bit:_rshift(bit:_and(cbCardData, 0xF0), 4)

	-- local m_spBack = cc.Sprite:create(string.format("0x%02X.png",0));
	-- self.m_spBack = m_spBack;
	-- self.m_spBack:setVisible(true);
	-- self:addChild(m_spBack);
    return card;
	
end

function CardSprite:addPlist()
	display.loadSpriteFrames("bairenniuniu/image/card.plist","bairenniuniu/image/card.png");
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("bairenniuniu/image/card.plist");
end

--设置卡牌数值
function CardSprite:setCardValue( cbCardData )
	self:addPlist();
	self.m_cardData = cbCardData;
	self.m_cardValue = GameLogic.GetCardValue(cbCardData) --math.mod(cbCardData, 16) --bit:_and(cbCardData, 0x0F)
	self.m_cardColor = GameLogic.GetCardColor(cbCardData) --math.floor(cbCardData / 16) --bit:_rshift(bit:_and(cbCardData, 0xF0), 4)
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("brnn_0x%02X.png",cbCardData));
	if frame then
		self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("brnn_0x%02X.png",cbCardData)));	
	end
	
	
end



--显示扑克背面
function CardSprite:showCardBack()
	self:addPlist();
	-- self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("0x%02X.png",0)));
	self:setCardValue(0);
end


return CardSprite;