--[[
0x00 // Back image                               1-13
0x01-0x0D,   // ♠  2 3 4 5 6 7 8 9 10 J Q K A  2-13, 1
0x11-0x1D,   // ♥  2 3 4 5 6 7 8 9 10 J Q K A  15-26, 14
0x21-0x2D,   // ♣  2 3 4 5 6 7 8 9 10 J Q K A  28-39, 27
0x31-0x3D,   // ♦  2 3 4 5 6 7 8 9 10 J Q K A  41-52, 40
0x41,0x42    // small king, big king
]]--
local PokerCard = class("PokerCard", function()
	return cc.Sprite:create()
end)
Factory(PokerCard)

local Audio = require("shisanzhang.Audio")
local CardLogic = require("shisanzhang.CardLogic")

local Tag_Color_Layer = 100

function PokerCard:ctor(cardValue,maValue,bHistory)
	self._value = nil
	if not cc.SpriteFrameCache:getInstance():getSpriteFrame("shisanzhang/cards/cards.plist") then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("shisanzhang/cards/cards.plist")
	end

	self:init(cardValue,maValue,bHistory)
end

function PokerCard:init(cardValue,maValue,bHistory)
	-- if not (
	-- 	(cardValue >= 0x00 and cardValue <= 0x0D) or
	-- 	(cardValue >= 0x11 and cardValue <= 0x1D) or
	-- 	(cardValue >= 0x21 and cardValue <= 0x2D) or
	-- 	(cardValue >= 0x31 and cardValue <= 0x3D) or
	-- 	(cardValue >= 0x41 and cardValue <= 0x42) or
	-- 	(cardValue >= 0x51 and cardValue <= 0x5D) or
	-- 	(cardValue >= 0x61 and cardValue <= 0x6D)
	-- ) then assert(false, string.format("cardValue error! value is %d - %02X", cardValue, cardValue)) end

	self:initWithCardValue(cardValue)

	--判定马牌
	if bHistory and maValue and maValue > 0 then
		maValue = CardLogic.DataToBBW(maValue)
		if cardValue == maValue then
				local maFlag = cc.Sprite:create("cards/matag.png")
							:align(cc.p(0, 0.5), 4, 82)
							:addTo(self)			
		end
	else
		if TableGlobal.iMaValue then
			if TableGlobal.iMaValue==cardValue then
				local maFlag = cc.Sprite:create("cards/matag.png")
							:align(cc.p(0, 0.5), 4, 82)
							:addTo(self)
			end
		end
	end
	
end

function PokerCard:initWithCardValue(cardValue)
	if self:initWithSpriteFrameName(self:getCardTextureFileName(cardValue)) then
		self._value = cardValue
		-- debugUI(self, self:toString().."\n"..CardLogic.BBWToGDI(cardValue).."\n"..cardValue, {0.3, 0.5})
	end
end

function PokerCard:setCardValue(cardValue)
	if cardValue < 0x00 or cardValue > 0x3D then
		if cardValue~=0x4E and cardValue~=0x4F then
			return
		end
	end

	self._value = cardValue

	self:setSpriteFrame(self:getCardTextureFileName(cardValue))
end

function PokerCard:getCardValue()
	return self._value
end

function PokerCard:addTouchedLayer()
	if not self:getChildByTag(Tag_Color_Layer) then
		local mark = cc.Sprite:create("shui13_res/card_mark.png")
				:align(cc.p(0, 0), 0, 5)
				:addTo(self, 0, Tag_Color_Layer)
		Audio.playDispathCard()
	end
end

function PokerCard:removeTouchedLayer()
	local node = self:getChildByTag(Tag_Color_Layer)
	if node and not tolua.isnull(node) then
		node:removeFromParent()
	end
end

function PokerCard:getCardTextureFileName(cardValue)
	luaPrint(string.format("0x%02X.png", cardValue))
	return string.format("0x%02X.png", cardValue)
end

function PokerCard:setGray(isGray)
	setGray(self, isGray)
end

function PokerCard:toString()
	return CardLogic.GetString(self._value, true)
end

return PokerCard
