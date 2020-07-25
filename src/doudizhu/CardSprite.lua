local CardSprite = class("CardSprite", function() return cc.Sprite:create() end);
CardSprite.Left_Align=1;
CardSprite.Center_Align=2;
CardSprite.Right_Align=3;

-- {
--     0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,   --方块 2 - K
--     0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,   --梅花 2 - K
--     0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,   --红桃 2 - K
--     0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,   --黑桃 2 - K
--     0x4E,0x4F,
-- };

local CardTypeEnum = {
    MyCardHand = 0,--自己的手牌
    OutCard = 1,--打出的牌
    MasterCard = 2,--庄家的牌
}

CardSprite.CardType = CardTypeEnum.MyCardHand;

function CardSprite:create(cbCardData,cardType)
    if cardType == nil then
        cardType = CardTypeEnum.MyCardHand;
    end

    if cardType == CardTypeEnum.MyCardHand then
        local card = self:CreateMyCardHand(cbCardData);
        card.mCardType = cardType;
        return card
    elseif cardType == CardTypeEnum.OutCard then
        local card = self:CreateOutCard(cbCardData);
        card.mCardType = cardType;
        return card
    elseif cardType == CardTypeEnum.MasterCard then
        local card = self:CreateMasterCard(cbCardData);
        card.mCardType = cardType;
        return card
    end
end

--自己的手牌
function CardSprite:CreateMyCardHand(cbCardData)
    local card=CardSprite.new()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddz_card.plist");
    self.card = card;

    local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddz_0x%02X.png",cbCardData));

    if pFrame == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddz_card.plist");
        pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddz_0x%02X.png",cbCardData));
    end

    if pFrame then
        card:setSpriteFrame(pFrame);
        card.cbCard = cbCardData;
        card.bUp = false
        card.bSelect = false
    end
    return card;
end

--打出的牌
function CardSprite:CreateOutCard(cbCardData)
    local card=CardSprite.new()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzot.plist");
    self.card = card;

    local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzot_0x%02X.png",cbCardData));

    if pFrame == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzot.plist");
        pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzot_0x%02X.png",cbCardData));
    end

    if pFrame then
        card:setSpriteFrame(pFrame);
        card.cbCard = cbCardData;
        card.bUp = false
        card.bSelect = false
    end
    return card;
end

--庄家的牌
function CardSprite:CreateMasterCard(cbCardData)
    local card=CardSprite.new()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzdd.plist");
    self.card = card;

    local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzdd_0x%02X.png",cbCardData));

    if pFrame == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzdd.plist");
        pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzdd_0x%02X.png",cbCardData));
    end

    if pFrame then
        card:setSpriteFrame(pFrame);
        card.cbCard = cbCardData;
        card.bUp = false
        card.bSelect = false
    end
    return card;
end

--设置牌为灰色与否
function CardSprite:SetCardGray(isGray)
    if isGray == true then
        --设置为灰色
        self.card:setColor(cc.c3b(128,128,128));
    else 
        --设置为非灰色
        self.card:setColor(cc.c3b(255,255,255));
    end
end


function CardSprite:loadCard(cbCardData)
    if self.mCardType == CardTypeEnum.MyCardHand then
        self:LoadMyCardHand(cbCardData);
    elseif self.mCardType == CardTypeEnum.OutCard then
        self:LoadOutCard(cbCardData);
    elseif self.mCardType == CardTypeEnum.MasterCard then
        self:LoadMasterCard(cbCardData);
    end

end

--重新加载 自己的手牌 打出的牌 庄家的牌
function CardSprite:LoadMyCardHand(cbCardData)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddz_card.plist");

    local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddz_0x%02X.png",cbCardData));

    if pFrame == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddz_card.plist");
        pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddz_0x%02X.png",cbCardData));
    end

    if pFrame then
        self:setSpriteFrame(pFrame);
    end
end

function CardSprite:LoadOutCard(cbCardData)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzot.plist");

    local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzot_0x%02X.png",cbCardData));

    if pFrame == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzot.plist");
        pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzot_0x%02X.png",cbCardData));
    end

    if pFrame then
        self:setSpriteFrame(pFrame);
    end
end

function CardSprite:LoadMasterCard(cbCardData)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzdd.plist");

    local pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzdd_0x%02X.png",cbCardData));

    if pFrame == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/ddzdd.plist");
        pFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("ddzdd_0x%02X.png",cbCardData));
    end

    if pFrame then
        self:setSpriteFrame(pFrame);
    end
end


return CardSprite