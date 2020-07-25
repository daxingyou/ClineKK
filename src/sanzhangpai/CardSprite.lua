local CardSprite = class("CardSprite", function() return cc.Sprite:create() end);

function CardSprite:ctor()
	self.m_cardData = 0
	self.m_cardValue = 0
	self.m_cardColor = 0
end

--创建卡牌
function CardSprite:createCard( cbCardData )
	local card= CardSprite.new()
	luaPrint("sp:",cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("szp_0x%02X.png",cbCardData)));
    card:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("spz_0x%02X.png",cbCardData)));
    return card;
	
end

--设置卡牌数值
function CardSprite:setCardValue( cbCardData )
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("spz_0x%02X.png",cbCardData));
	if frame then
		self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("spz_0x%02X.png",cbCardData)));	
	end
end



--显示扑克背面
function CardSprite:showCardBack()
	-- self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("0x%02X.png",0)));
	self:setCardValue(0);
end


return CardSprite;