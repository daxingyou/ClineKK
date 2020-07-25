local CardListBoard = class("CardListBoard", BaseWindow)
local Audio = require("shisanzhanglq.Audio")
Factory(CardListBoard)

local PokerCard = require("shisanzhanglq.PokerCard")

local UP_OFFSET  = 30
local UP_OFFSET =              30.0
local Self_Card_Min_Interval = 72.0       --两张牌间最小间隔
local Self_Card_Max_Interval = 72.0       --两张牌间最大间隔
local Other_Card_Interval =    30.0

local Name_Up    = "up"
local Name_Down  = "down"

local Tag_Untouched  = 0
local Tag_Touched    = 1

local Zorder_Card_Began = 1

local send_card_time = 0.1

function CardListBoard:ctor(isMySelf, isBack, seatNo)
	self._isMySelf = nil
	self._isBack = nil
	self._seatNo = nil
	self._callfunc = nil
	self._callfuncUp = nil
	self._callfuncDown = nil
	self._maValue = nil

	self._undoList = {}
	self._cards = {}
	self._cardsBack = {}

	self:init(isMySelf, isBack, seatNo)
end

function CardListBoard:init(isMySelf, isBack, seatNo)
	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(display.CENTER)
	self:setContentSize(cc.size(0, 0))

	self._isMySelf = isMySelf
	self._isBack = isBack
	self._seatNo = seatNo

	if self._isMySelf then
		self:setLayerTouchEnabled(true, false, true)
	end
end

function CardListBoard:onTouchBegan(event)
	self:removeTouchedTag()
	local pos = self:convertToNodeSpace(cc.p(event.x, event.y))
	self:touchCheck(pos)

	local rect = cc.rect(0, 0, self:getContentSize().width, self:getContentSize().height + 35)

	if cc.rectContainsPoint(rect, pos) then
		return true
	else
		self:downCards()
		return false
	end

end

function CardListBoard:onTouchMoved(event)
	local pos = self:convertToNodeSpace(cc.p(event.x, event.y))
	self:touchCheck(pos)
end

function CardListBoard:onTouchEnded(event)
	-- local pos = self:convertToNodeSpace(cc.p(event.x, event.y))
	-- self:touchCheck(pos)

	table.walk(self._cards, function(card)
		card:removeTouchedLayer()
	end)

	local upCards = self:getUpCards()
	luaDump(upCards)

	if #upCards==0 then
		if self._callfunc then
			self:_callfunc()
		end
	else
		self:changeUpDown()
	end
end

function CardListBoard:addCardOneByOne(values)
	if #values==0 then return end

	-- self:unschedule(self.scheduleRun)
	-- self._undoList = {}
	-- self:removeCardAllOnce(values)
	self._undoList = values
	self:schedule(self.scheduleRun, send_card_time)
end

function CardListBoard:addCardBack(values)
	if values then
		-- self:unschedule(self.scheduleRun)
		-- self._undoList = {}
		-- self:removeCardAllOnce(values)
		self._undoList = values
		self:schedule(self.scheduleRun, send_card_time)
	else
		local card = PokerCard:create(0)
		if card then
			card:setScale(1.5)
			card:setPositionY(0)
			card:setName(Name_Up)
			card:setTag(Tag_Untouched)
			self:addChild(card, 10)
			table.insert(self._cardsBack, card)
		end
	end
end

function CardListBoard:resizeCardListBack(isAction)
	if #self._cardsBack>0 then
		self:setAnchorPoint(cc.p(0, 0))
		self:setPosition(cc.p(0, 0))
		-- 默认52张牌 牌间距设定为17.67f
		local carddis = 17.67
		-- 多一色 情况多13张牌  间距调整为14.08f
		if #self._cardsBack>52 then
			carddis = 14.08
		end

		table.walk(self._cardsBack, function(card, i)
			local index = i-1
			card:setPosition(1500, card:getPositionY()+164)
			card:setAnchorPoint(cc.p(0, 0))
			card:setScale(0.8)

			if isAction then
				card:runAction(cc.Sequence:create(cc.DelayTime:create(0.02*index), cc.MoveTo:create(0.02, cc.p(carddis*index + 188, card:getPositionY() + 164))))
			else
				card:setPosition(carddis*index + 188, card:getPositionY() + 164)
			end
			card:setLocalZOrder(Zorder_Card_Began + index)
		end)
	end
end

function CardListBoard:sendBackCard(num, isAction)
	self._cardsBack = {}
	for i=1,num do
		self:addCardBack()
	end

	self:resizeCardListBack(isAction)
end

-- 切牌结束动画
function CardListBoard:removeBackCardQie(num)
	table.walk(self._cardsBack, function(card, i)
		if i < num/2 then
			card:setLocalZOrder(333+i)
			card:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.MoveTo:create(0.2, cc.p(640, 480))))
		else
			card:runAction(cc.MoveTo:create(0.2, cc.p(640, 480)))
		end

		card:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.MoveTo:create(0.2, cc.p(640, 350))))
		card:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.RemoveSelf:create(true)))
	end)
end

function CardListBoard:reorderCard()
	table.sort(self._cards, function(left, right)
		local lCard = left:getCardValue()
		local rCard = right:getCardValue()

		local lColor = math.floor(lCard/16)--bit._and(lCard, 0xf0)
		local rColor = math.floor(rCard/16)--bit._and(rCard, 0xf0)
		local lValue = lCard%16--bit._and(lCard, 0x0f)
		local rValue = rCard%16--bit._and(rCard, 0x0f)
		-- 大小王的排序
		if lColor==4 and lValue>0 then
			lValue = 20 + lValue
		end
		if rColor==4 and rValue>0 then
			rValue = 20 + rValue
		end

		return (rValue < lValue or (rValue==lValue and rColor < lColor))
 	end)
end

function CardListBoard:resizeCardList()

	if #self._cards>0 then
		local card = self._cards[1]
		local size = card:getContentSize()
		local cardSize = cc.size(size.width*card:getScale(), size.height*card:getScale())
		local cardInterval = Other_Card_Interval

		if not self._isBack then
			local maxLength = cardSize.width + (20-1)*Self_Card_Min_Interval
			cardInterval = maxLength/(#self._cards)
			cardInterval = math.min(cardInterval, Self_Card_Max_Interval)
		end

		local width = cardSize.width+(#self._cards-1)*cardInterval
		local height = cardSize.height
		self:setContentSize(cc.size(width, height))

		table.walk(self._cards, function(card, i)
			card:setAnchorPoint(cc.p(0, 0))
			card:setPosition(cardInterval*(i-1), card:getPositionY())
			card:setLocalZOrder(Zorder_Card_Began+i-1)
		end)

		if not self._isMySelf then
			self:downCards()
		end
	end

end

function CardListBoard:addCardAllOnce(values, isUp)
	table.walk(values or {}, function(value)
		self:addCard(value, isUp)
	end)

	self:reorderCard()
	self:resizeCardList()
end

function CardListBoard:scheduleRun(dt)
	if #self._undoList==0 then
		self:unschedule(self.scheduleRun)
	else
		if self._isMySelf then
			Audio.playDispathCard()
		end
		self:addCard(self._undoList[1], false)
		-- self:reorderCard()
		self:resizeCardList()
		table.remove(self._undoList, 1)
	end
end

function CardListBoard:setCallFunction(callback)
	self._callfunc = callback
end

function CardListBoard:setCallFunctionUp(callback)
	self._callfuncUp = callback
end

function CardListBoard:setCallFunctionDown(callback)
	self._callfuncDown = callback
end

function CardListBoard:setMaValue(value)
	self._maValue = value
end

function CardListBoard:clear()
	self:unschedule(self.scheduleRun)
	self._undoList = {}

	table.walk(self._cards, function(card)
		if not tolua.isnull(card) then
			card:removeFromParent()
		end
	end)
	self._cards = {}
end

function CardListBoard:setBackCard()
	table.walk(self._cards, function(card)
		card:setCardValue(0)
	end)
end

function CardListBoard:addCard(value, isUp)
	local card = PokerCard:create(value, self._maValue)
	card:setScale((self._isMySelf and not self._isBack) and 1.1 or 0.6)
	card:setPositionY(isUp and UP_OFFSET or 0)
	card:setName(isUp and Name_Up or Name_Down)
	card:setTag(Tag_Untouched)
	self:addChild(card)
	table.insert(self._cards, card)
end

function CardListBoard:removeCard(value)
	local index = table.indexof(self._cards, value)

	if index then
		local card = self._cards[index]
		card:removeFromParent()
		table.remove(self._cards, index)
	end
end

function CardListBoard:removeCardAllOnce(values)
	if #values>0 then
		table.walk(values, function(value)
			self:removeCard(value)
		end)

		self:resizeCardList()
		Audio.playDispathCard()
	end
end

function CardListBoard:downCards()
	local duration = self._isMySelf and 0.1 or 2.0

	table.walk(self._cards, function(card)
		self:downCard(card, duration)
		card:setTag(Tag_Untouched)

	end)
end

function CardListBoard:downCard(card, delay)
	if card:getName()==Name_Up then
		card:setName(Name_Down)
		card:stopAllActions()
		card:runAction(cc.Sequence:create(
			cc.DelayTime:create(delay),
			cc.MoveTo:create(0.2, cc.p(card:getPositionX(), 0))
		))

		if self._callfuncDown then
			self:_callfuncDown(card:getCardValue())
		end
	end
end

function CardListBoard:upCards(cards)
	cards = clone(cards)
	table.walk(self._cards, function(card, i)
		local found = false
		local index = table.indexof(cards, card:getCardValue())
		if index then
			found = true
			table.remove(cards, index)
		end

		if found then
			self:upCard(card)
		else
			self:downCard(card, 0)
		end

		card:setTag(Tag_Untouched)
	end)
end

function CardListBoard:upCard(card)
	if card:getName()==Name_Down then
		card:setName(Name_Up)
		card:stopAllActions()
		card:runAction(cc.Sequence:create(
			-- cc.DelayTime:create(0.1),
			cc.MoveTo:create(0.1, cc.p(card:getPositionX(), UP_OFFSET))
		))

		if self._callfuncUp then
			self:_callfuncUp(card:getCardValue())
		end
	end
end

function CardListBoard:getUpCards()
	local upCards = {}
	table.walk(self._cards, function(card)
		if card:getName()==Name_Up then
			table.insert(upCards, card:getCardValue())
		end
	end)

	return upCards
end

function CardListBoard:getTouchedCards()
	local outCards = {}
	table.walk(self._cards, function(card)
		if card:getTag()==Tag_Touched then
			table.insert(outCards, card:getCardValue())
		end
	end)

	return outCards
end

function CardListBoard:changeUpDown()
	table.walk(self._cards, function(card)
		if card:getTag()~=Tag_Untouched then
			if card:getName()==Name_Up then
				self:downCard(card, 0)
			else
				self:upCard(card)
			end
		end
	end)
end

function CardListBoard:removeTouchedTag()
	table.walk(self._cards, function(card)
		if not tolua.isnull(card) then
			card:setTag(Tag_Untouched)
		end
	end)
end

function CardListBoard:touchCheck(pos)
	for i=(#self._cards), 1, -1 do
		local card = self._cards[i]
		local rect = card:getBoundingBox()
		local preRect = self._cards[i+1] and self._cards[i+1]:getBoundingBox()
		if preRect then
			rect = cc.rect(rect.x,rect.y,preRect.x-rect.x,rect.height)
		end
		if cc.rectContainsPoint(rect, pos) and card:getTag()==Tag_Untouched then
			card:setTag(Tag_Touched)
			card:addTouchedLayer()
			return true
		end
	end
end

return CardListBoard
