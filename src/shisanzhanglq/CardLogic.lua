local CardLogic = class("CardLogic")

local POKER_MASK_LEFT = 0xf0
local POKER_MASK_RIGHT = 0x0f

local IS_A_SMALL = true 		--是否A2345 最小顺子
local IS_FLUSH_SAME = true		--同花是否一样大

local SORTARRAY = {1, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2}
local SORTARRAY1 = {10, 1, 9, 8, 7, 6, 5, 4, 3, 2}

function CardLogic:ctor()
	self.m_bSortCardStyle = 0
end

function CardLogic.Sort(collection, ascend)
	table.sort(collection, function(c1, c2)
		if ascend then
			return c1>c2
		else
			return c1<c2
		end
	end)
end

-- 牌面值十六进制排序
function CardLogic.SortPokers(pokers, isDesc)
	if isDesc==nil then isDesc=true end

	table.sort(pokers, function(p1, p2)
		local v1 = (math.floor(p1/16)==4) and 16 or (p1%16)
		local v2 = (math.floor(p2/16)==4) and 16 or (p2%16)
		if isDesc then
			return v1 > v2
			-- return bit._and(p1, POKER_MASK_RIGHT) > bit._and(p2, POKER_MASK_RIGHT)
		else
			return v1 > v2
			-- return bit._and(p1, POKER_MASK_RIGHT) < bit._and(p2, POKER_MASK_RIGHT)
		end
	end)
end

-- 逻辑值的排序
function CardLogic.SortPokersGDI(pokers, isDesc)
	table.sort(pokers, function(p1, p2)
		local v1 = CardLogic.DataToBBW(p1)
		local v2 = CardLogic.DataToBBW(p2)
		v1 = (math.floor(v1/16)==4) and 16 or (v1%16)
		v2 = (math.floor(v2/16)==4) and 16 or (v2%16)
		if isDesc then
			return v1 > v2
			-- return bit._and(v1, POKER_MASK_RIGHT) > bit._and(v2, POKER_MASK_RIGHT)
		else
			return v1 > v2
			-- return bit._and(v1, POKER_MASK_RIGHT) < bit._and(v2, POKER_MASK_RIGHT)
		end
	end)
end

function CardLogic.SortPokersByColor(pokers, isDesc)
	local colorCountTable = {}
	for i, card in ipairs(pokers) do
		local color = math.floor(card/16)%4
		colorCountTable[color] = colorCountTable[color] or 0
		colorCountTable[color] = colorCountTable[color] + 1
	end

	table.sort(pokers, function(p1, p2)
		local color1 = math.floor(p1/16)%4
		local color2 = math.floor(p2/16)%4
		if isDesc then
			if colorCountTable[color1]==colorCountTable[color2] then
				return color1 > color2
			else
				return colorCountTable[color1] > colorCountTable[color2]
			end
		else
			if colorCountTable[color1]==colorCountTable[color2] then
				return color1 < color2
			else
				return colorCountTable[color1] < colorCountTable[color2]
			end
		end
	end)
end

function CardLogic.SortPokersGDIByColor(pokers, isDesc)
	table.sort(pokers, function(p1, p2)
		local v1 = CardLogic.DataToBBW(p1)
		local v2 = CardLogic.DataToBBW(p2)

		if isDesc then
			return (math.floor(v1/16))%4 > (math.floor(v2/16))%4
		else
			return (math.floor(v1/16))%4 < (math.floor(v2/16))%4
		end
	end)
end

local function getCardList(value, ascend)
	local cda = {}
	for i=1, #value do
		local cd = CardData.new()
		cd.bIndex = value[i]
		cd.bColor = CardLogic.GetColor(cd.bIndex)
		cd.bValue = CardLogic.GetPointValue(cd.bIndex)
		table.insert(cda, cd)
	end

	CardLogic.Sort(cda, ascend)

	return cda
end

local function getCardList1(value, ascend)
	CardLogic.Sort(value, ascend)
	local cardsOfColor = {}  --花色列表
	local cardsOfValue = {}  --牌值列表
	local cardsKing = {}     --大小王表

	for i=1, 13 do
		cardsOfValue[i] = {}
	end
	for i=1, 4 do
		cardsOfColor[i] = {}
	end

	for i=1, #value do
		local cd = CardData.new()
		cd.bIndex = value[i]
		cd.bColor = CardLogic.GetColor(cd.bIndex)
		cd.bValue = CardLogic.GetPointValue(cd.bIndex)

		if cd.bColor~=5 then
			if cd.bColor>0 then
			table.insert(cardsOfValue[cd.bValue], cd)
			table.insert(cardsOfColor[cd.bColor], cd)
			end
		else
			table.insert(cardsKing, cd)
		end
	end
	-- luaDump(cardsOfColor, "color")
	-- luaDump(cardsOfValue, "value")


	return cardsOfColor, cardsOfValue, cardsKing
end

local function getCardList2(value)
	local cda = {}

	local cards = getCardList1(value)

	for i=1, PLAYCARTCOUNT do
		for j=1, MAXCOLOR do
			table.insert(cda, cards[i][j])
		end
	end

	for i=1, 1 do
		for j=1, MAXCOLOR do
			table.insert(cda, cards[i][j])
		end
	end

	return cda
end

-- 取最大值，不按花色
function CardLogic.MaxPoint(cardList)
	local temp = clone(cardList)
	local bMax = 0

	for i=1, #temp do
		local value = temp[i].bIndex%13

		if value == 0 then
			value = 13
		elseif value == 1 then
			bMax = 14
			break
		end

		if temp[i].bColor~=5 then
			bMax = math.max(value, bMax)
		end
	end

	return bMax
end

-- 取花色
function CardLogic.GetColor(_value)
	-- local bResult = math.floor((_value+12)/13)%4
	-- bResult = (bResult%4==0 and 4 or bResult%4)
	-- return bResult
	-- local bResult = math.ceil(_value/13)

	-- if bResult ~= 5 then
	-- 	if bResult < 5 then
	-- 		bResult = bResult % 5
	-- 	else
	-- 		bResult = (bResult + 1) % 5
	-- 	end
	-- end

	local bResult = math.floor((_value-1)/13)

	if bResult~=4 then
		bResult = bResult % 4
	end

	return bResult+1
end

-- 取牌的点数值
function CardLogic.GetPointValue(_value)
	local bResult = _value%13

	if bResult == 0 then
		bResult = 13
	end

	return bResult
end

function CardLogic.GetPaiXin(values)
	return CardLogic.GetCardsManager(values):GetPaiXin()
end

-- 蹲比较
function CardLogic.DunCompare(manager1, manager2, notFlush)
	local bResult

	local paiXin1 = manager1:GetPaiXin(notFlush)
	local paiXin2 = manager2:GetPaiXin(notFlush)

	if paiXin1.ePXE > paiXin2.ePXE then
		bResult = 1
	elseif paiXin1.ePXE < paiXin2.ePXE then
		bResult = 0xff
	else

		-- 同花时排除同花牌型再比较
		if not IS_FLUSH_SAME and paiXin1.ePXE==PaiXinEnum.FLUSH then
			return CardLogic.DunCompare(manager1, manager2, true)
		end

		-- 顺子、同花顺，A2345的大小
		if paiXin1.ePXE==PaiXinEnum.STRAIGHT or paiXin1.ePXE==PaiXinEnum.GRANDSTRAIGHT then
			-- 最小
			if IS_A_SMALL then
				paiXin1.bMax = (paiXin1.bMax == 1 and 14 or paiXin1.bMax)
				paiXin2.bMax = (paiXin2.bMax == 1 and 14 or paiXin2.bMax)
			-- 第2大
			else
				paiXin1.bMax = (paiXin1.bMax == 5 and 13.5 or (paiXin1.bMax == 1 and 14 or paiXin1.bMax))
				paiXin2.bMax = (paiXin2.bMax == 5 and 13.5 or (paiXin2.bMax == 1 and 14 or paiXin2.bMax))
			end
		else
			paiXin1.bMax = (paiXin1.bMax == 1 and 14 or paiXin1.bMax)
			paiXin2.bMax = (paiXin2.bMax == 1 and 14 or paiXin2.bMax)
		end

		if paiXin1.bMax > paiXin2.bMax then
			bResult = 1
		elseif paiXin1.bMax < paiXin2.bMax then
			bResult = 0xff
		else
			if paiXin1.ePXE==PaiXinEnum.TWOPAIRS or
			paiXin1.ePXE==PaiXinEnum.STRAIGHT or
			paiXin1.ePXE==PaiXinEnum.FLUSH or
			paiXin1.ePXE==PaiXinEnum.GRANDSTRAIGHT or
			paiXin1.ePXE==PaiXinEnum.SINGLE or
			paiXin1.ePXE==PaiXinEnum.PAIRS or
			paiXin1.ePXE==PaiXinEnum.FIVE then
				local cards1 = manager1:GetCardList()
				local cards2 = manager2:GetCardList()

				CardLogic.Sort(cards1, true)
				CardLogic.Sort(cards2, true)

				bResult = 1

				for i=1, math.min(#cards1, #cards2) do
					if cards1[i] ~= cards2[i] then
						bResult = (cards1[i]<cards2[i] and 0xff or 1)
						break
					end
				end
			end
		end
	end

	return bResult
end

-- 获取各种牌型牌组
-- @param 	values 		[table]  牌值数组
-- @param 	isHex 		[bool]   是否十六进制
function CardLogic.GetCardsManager(values, isHex)
	local temp = isHex and CardLogic.BBWToGDIList(values) or clone(values)
	
	local colorList, valueList, kingList = getCardList1(temp, true)
	local kingCount = #kingList
	-- 除单牌之外的牌型使用过的牌值
	local usedList = {}
	for k, v in pairs(temp) do
		usedList[v] = false
	end

	local Cards = {}

	function Cards:clear()
		self._pairs = nil
		self._tpairs = nil
		self._triples = nil
		self._fours = nil
		self._fives = nil
		self._flushs = nil
		self._fullhouses = nil
		self._flushstraighs = nil

		self._singles = nil
		self._dunCards = {}
	end

	local function SetUsedValue(cardDatas)
		for i1, v1 in ipairs(cardDatas) do
			if not v1.kingCount then
				for i2, v2 in ipairs(v1) do
					usedList[v2.bIndex] = true
				end
			end
			-- printTraceback(2)
			-- for k, v in pairs(usedList) do
			-- 	log(CardLogic.GetString(k), v)
			-- end
			-- luaPrint("")
		end

	end

	function Cards:GetValues()
		return clone(temp)
	end

	function Cards:GetCardList()
		return getCardList(temp, true)
	end

	function Cards:GetPaiXin(notFlush)
		local pxd = PaiXinData.new()

		local cardCount = #temp
		local bResult
		if cardCount == 2 then
			bResult = self:HavePairs()
			if bResult then
				pxd.ePXE = PaiXinEnum.PAIRS
			end
		elseif cardCount == 3 then
			bResult = self:HaveTriples()
			if bResult then
				pxd.ePXE = PaiXinEnum.TRIPLES
				pxd.bMax = bResult
			else
				bResult = self:HavePairs()
				if bResult then
					pxd.ePXE = PaiXinEnum.PAIRS
					pxd.bMax = bResult
				else
					pxd.ePXE = PaiXinEnum.SINGLE
					pxd.bMax = CardLogic.MaxPoint(self:GetCardList())
				end
			end
		elseif cardCount == 4 then
			bResult = self:HaveFour()
			if bResult then
				pxd.ePXE = PaiXinEnum.FOUR
				pxd.bMax = bResult
			else
				bResult = self:HaveTwoPairs()
				if bResult then
					pxd.ePXE = PaiXinEnum.TWOPAIRS
					pxd.bMax = bResult
				end
			end
		elseif cardCount == 5 then
			bResult = self:HaveFive()
			if bResult then
				pxd.ePXE = PaiXinEnum.FIVE
				pxd.bMax = bResult
			else
				bResult = self:HaveGrandStraight()
				if bResult then
					pxd.ePXE = PaiXinEnum.GRANDSTRAIGHT
					if bResult==1 then
						pxd.bMax = CardLogic.MaxPoint(self:GetCardList())
					else
						pxd.bMax = bResult
					end
				else
					bResult = self:HaveFour()
					if bResult then
						pxd.ePXE = PaiXinEnum.FOUR
						pxd.bMax = bResult
					elseif self:HaveFullHouse() then
						pxd.ePXE = PaiXinEnum.FULLHOUSE
						pxd.bMax = self:HaveTriples()
					elseif self:HaveFlush() and not notFlush then -- 排除同花
						pxd.ePXE = PaiXinEnum.FLUSH
						pxd.bMax = CardLogic.MaxPoint(self:GetCardList())
					else
						bResult = self:HaveStraight()
						if bResult then
							pxd.ePXE = PaiXinEnum.STRAIGHT
							if bResult == 1 then
								pxd.bMax = CardLogic.MaxPoint(self:GetCardList())
							else
								pxd.bMax = bResult
							end
						else
							bResult = self:HaveTriples()
							if bResult then
								pxd.ePXE = PaiXinEnum.TRIPLES
								pxd.bMax = bResult
							else
								bResult = self:HaveTPairs()
								if bResult then
									pxd.ePXE = PaiXinEnum.TWOPAIRS
									pxd.bMax = bResult
								else
									bResult = self:HavePairs()
									if bResult then
										pxd.ePXE = PaiXinEnum.PAIRS
										pxd.bMax = bResult
									else
										pxd.ePXE = PaiXinEnum.SINGLE
										pxd.bMax = CardLogic.MaxPoint(self:GetCardList())
									end
								end
							end
						end
					end
				end
			end
		end

		if pxd.bMax == 1 then
			pxd.bMax = 14
		end

		return pxd
	end

	function Cards:GetCardByColor(color)

	end

	-- 获取连续的牌
	-- @param  result   [table]   输出数组
	-- @param  cls      [class]   牌型的类
	-- @param  count    [number]  牌数量
	-- @param  sortRule [table]   降序规则

	function Cards:GetStraightCard(cls, count, sortRule)
		local result = {}
		-- result.cardDatas = {}

		--王牌
		local kList 
		local function GetStraight(t, count, index)

			-- 10 J Q K A
			if index== 14 then
				index = 1
			end

			if count==0 then
				local t_clone = clone(t)
				table.insert(result, t_clone)
				local value = t[#t].bValue
				result.maxPoint = math.max(result.maxPoint or 0, value==1 and 14 or value)
				return true
			end

			if #valueList[index]>0 then
				for i, v in pairs(valueList[index]) do
					local last = valueList[index][i-1]
					if not last or v.bIndex~=last.bIndex then
						table.insert(t, v)
						GetStraight(t, count-1, index+1)
						table.remove(t)
					end
				end
			else
				if #kList>0 then
					local kCard = clone(kList[#kList])
					table.insert(t, kList[#kList])
					table.remove(kList)
					GetStraight(t, count-1, index+1)
					table.remove(t)
					table.insert(kList, kCard)
				end
			end
		end

		-- 最大到A
		if not sortRule then
			for i=15-count, 1, -1 do
				local temp = {}
				kList = clone(kingList)
				GetStraight(temp, count, i)
			end
		else
			for i, v in ipairs(sortRule) do
				local temp = {}
				kList = clone(kingList)
				GetStraight(temp, count, v)
			end
		end

		return result
	end

	-- 获取某数量和牌值的组合
	--@param  result   [table]   输出数组，其中cardDatas包含所有牌的数据
	--@param  cls      [class]   牌型的类
	--@param  value    [number]  牌数值
	--@param  count    [number]  牌数量
	function Cards:GetCardByValueAndCount(result, cls, value, count)
		local list = {}

		for i=0, kingCount do
			if count>i then
				table.getCombination(valueList[value], list, count-i)

				-- 加入王牌
				for j=1, i do
					for k=1, #list do
						if #list[k]<count then
							table.insert(list[k], kingList[j])
							list[k].kingCount = (list[k].kingCount and (list[k].kingCount+1) or 1)
						end
					end
				end
			end
		end

		-- 最大值
		if #list>0 then
			if not result.maxPoint then
				result.maxPoint = (value==1 and 14 or value)
			end
		end

		for i2, v2 in pairs(list) do
			if #v2==count then
				-- 去重
				local found = false
				for i=#result, 1, -1 do
					local eq = true
					for j=1, count do
						if result[i][j].bIndex~=v2[j].bIndex then
							eq = false
							break
						end
					end

					if eq then
						found = true
						break
					end
				end

				if not found then
					local cardData = {}
					for j=1, count do
						table.insert(cardData, v2[j])
					end
					cardData.kingCount = v2.kingCount
					table.insert(result, cardData)
				end
			end
		end
	end

	-- 获取某数量的相同牌值组合
	--@param  result   		[table]   输出数组，其中cardDatas包含所有牌的数据
	--@param  cls      		[class]   牌型的类
	--@param  count    		[number]  牌数量
	function Cards:GetCardByCount(cls, count)--cls-cardType kc-kingCount count-card number
		local result = {}
		for i=1, 13  do
			local pointValue = SORTARRAY[i]-- card point value order from A to 2
			self:GetCardByValueAndCount(result, cls, pointValue, count)
		end
		table.sort(result, function(c1, c2) 
			if #valueList[c1[1].bValue] == #valueList[c2[1].bValue] then
				local v1 = (c1[1].bValue==1 and 14 or c1[1].bValue)
				local v2 = (c2[1].bValue==1 and 14 or c2[1].bValue)
				return v1 > v2
			else
				return #valueList[c1[1].bValue] < #valueList[c2[1].bValue]
			end
		end)

		return result
	end

	-- 获取排除指定牌的管理
	function Cards:GetOtherManager(removeCards)
		local otherValues = self:GetValues()
		for i, v in ipairs(removeCards) do
			table.removebyvalue(otherValues, v.bIndex, true)
		end

		return CardLogic.GetCardsManager(otherValues)
	end

	-- 排除王的管理
	function Cards:GetRemoveKingManager()
		if not self._removeKingManager then
			self._removeKingManager = self:GetOtherManager(kingList)
		end
		return self._removeKingManager
	end

	-- 获取适用蹲的牌组
	function Cards:GetDunCards(cardType)
		if not self._dunCards[cardType] then
			local getCardFunc = PaiXinT[cardType].getCardFunc

			local cardList, needSingle = getCardFunc(self)
			
			-- 需要插入其他牌型
			if needSingle then
				cardList = clone(cardList)
				for i, v in ipairs(cardList) do
					local tempManager = self:GetOtherManager(v)
					for i2, v2 in ipairs(tempManager:GetSingle(needSingle)) do
						table.insert(v, v2)
					end
				end
			end

			local result = {}
			for i1, v1 in ipairs(cardList) do
				local temp = {}
				table.insert(result, temp)
				for i2, v2 in ipairs(v1) do
					table.insert(temp, CardLogic.DataToBBW(v2.bIndex))
				end
			end

			self._dunCards[cardType] = result
		end

		return self._dunCards[cardType]
	end


	-- 单牌,即不和其他牌组成其他牌型的牌
	function Cards:GetSingle(num)
		if not self._singles then
			local result = {}

			self:GetPairs()
			self:GetTPairs()
			self:GetTriples()
			self:GetFour()
			self:GetFive()
			self:GetStraight()
			self:GetFlush()
			self:GetFullHouse()
			self:GetGrandStraight()

			for k, v in pairs(usedList) do
				if not v then
					local cd = CardData.new()
					cd.bIndex = k
					cd.bColor = CardLogic.GetColor(cd.bIndex)
					cd.bValue = CardLogic.GetPointValue(cd.bIndex)
					table.insert(result, cd)
				end
			end

			CardLogic.Sort(result)

			self._singles = result

			-- luaDump(self._singles)
		end

		local result = {}

		if num<=#self._singles then
			for i=1, num or 1 do
				table.insert(result, self._singles[i])
			end
		else
			log("not enough single!")
		end

		return result
	end

	function Cards:HavePairs()
		self:GetPairs()
		return #self._pairs>0 and self._pairs.maxPoint
	end
	-- 对子
	function Cards:GetPairs()
		if not self._pairs then
			self._pairs = self:GetCardByCount(PairsData, 2)

			SetUsedValue(self._pairs)
			-- luaDump(self._pairs)
		end
		return self._pairs
	end


	function Cards:HaveTPairs()
		self:GetTPairs()
		return #self._tpairs>0 and self._tpairs.maxPoint
	end
	-- 两对
	function Cards:GetTPairs()
		if not self._tpairs then

			-- 有王牌存在，只可能存在三条或铁枝，需要排除王牌再做计算
			if kingCount>0 then
				local manager = self:GetRemoveKingManager()
				self._tpairs = manager:GetTPairs()
			else
				local result = {}
				local pairs = self:GetPairs()

				result.maxPoint = pairs.maxPoint

				local list = {}
				for i=1, #pairs do
					for j=#pairs, 1, -1 do
						if i<j then
							table.insert(list, {pairs[i], pairs[j]})
						else
							break
						end
					end
				end

				-- 去重
				for i=#list, 1, -1 do
					if list[i][1][1].bValue==list[i][2][1].bValue then
						table.remove(list, i)
					end
				end

				for i, v in ipairs(list) do
					table.insert(result, {v[1][1], v[1][2], v[2][1], v[2][2]})
				end
				self._tpairs = result
			end

			SetUsedValue(self._tpairs)
			-- luaDump(result)
		end
		return self._tpairs
	end

	function Cards:HaveTriples()
		self:GetTriples()
		return #self._triples>0 and self._triples.maxPoint
	end
	function Cards:GetTriples()
		if not self._triples then
			self._triples = self:GetCardByCount(TriplesData, 3)
			SetUsedValue(self._triples)
		end
		return self._triples
	end

	function Cards:HaveFour()
		self:GetFour()
		return #self._fours>0 and self._fours.maxPoint
	end
	function Cards:GetFour()
		if not self._fours then
			self._fours = self:GetCardByCount(FourData, 4)
			SetUsedValue(self._fours)
		end
		-- luaDump(self._fours)
		return self._fours
	end

	function Cards:HaveFive()
		self:GetFive()
		return #self._fives>0 and self._fives.maxPoint
	end
	function Cards:GetFive()
		if not self._fives then
			self._fives = self:GetCardByCount(FiveData, 5)
			SetUsedValue(self._fives)
		end
		-- luaDump(self._fives)
		return self._fives
	end

	function Cards:HaveStraight()
		self:GetStraight()
		return #self._straights>0 and self._straights.maxPoint
	end
	function Cards:GetStraight()
		if not self._straights then
			self._straights = self:GetStraightCard(StaightData, 5)
			SetUsedValue(self._straights)
		end
		-- luaDump(self._straights)
		return self._straights
	end

	function Cards:HaveFlush()
		self:GetFlush()
		return #self._flushs>0 and self._flushs.maxPoint
	end
	function Cards:GetFlush()
		if not self._flushs then
			local list = {}
			for i, v in ipairs(colorList) do
				for j=0, kingCount do
					table.getCombination(v, list, 5-j)
				end
			end

			-- 按数量插入王牌
			for i=1, #list do
				local need = 5-#list[i]
				for k=1, need do
					table.insert(list[i], kingList[k])
				end
				list[i].kingCount = need
			end

			-- table.sort(list, function(v1, v2)
			-- 	return CardLogic.MaxPoint(v1) > CardLogic.MaxPoint(v2)
			-- end)

			local temp = clone(list)
			if #list>0 then
				list.maxPoint = CardLogic.MaxPoint(list[1])
			end

			self._flushs = list

			SetUsedValue(self._flushs)
			-- luaDump(self._flushs)
		end

		return self._flushs
	end

	function Cards:HaveFullHouse()
		self:GetFullHouse()
		return #self._fullhouses>0 and self._fullhouses.maxPoint
	end
	function Cards:GetFullHouse()
		if not self._fullhouses then

			if kingCount>0 then
				local manager = self:GetRemoveKingManager()
				-- 2张王牌以上不考虑葫芦
				-- if kingCount>1 then
				-- 	self._fullhouses = manager:GetFullHouse()
				-- -- 1张王牌只需考虑两对+1
				-- else
					local tpairs = manager:GetTPairs()

					local result = clone(tpairs)

					for i=1, #result do
						table.insert(result[i], kingList[1])
					end

					self._fullhouses = result
				-- end
			else
				local result = {}

				local trips = self:GetTriples()
				local pairs = self:GetPairs()

				local cardDatas1 = clone(trips)
				local cardDatas2 = clone(pairs)

				-- 对子先从两张取，再从三张取...
				table.sort(cardDatas2, function(c1, c2) 
					if #valueList[c1[1].bValue] == #valueList[c2[1].bValue] then
						local v1 = (c1[1].bValue==1 and 14 or c1[1].bValue)
						local v2 = (c2[1].bValue==1 and 14 or c2[1].bValue)
						return v1 < v2
					else
						return #valueList[c1[1].bValue] < #valueList[c2[1].bValue]
					end
				end)

				for i1, v1 in ipairs(trips) do
					for i2, v2 in ipairs(pairs) do
						if cardDatas1[i1][1].bValue~=cardDatas2[i2][1].bValue then
							-- table.insert(result, {v1, v2})
							table.insert(result, {cardDatas1[i1][1], cardDatas1[i1][2], cardDatas1[i1][3], cardDatas2[i2][1], cardDatas2[i2][2]})
						end
					end
				end
				
				-- local trips = self:GetTriples()
				-- for i, v in ipairs(trips.cardDatas) do
				-- 	local otherManager = self:GetOtherManager(v)
				-- 	local pairs = otherManger:GetPairs()
				-- end

				result.maxPoint = trips.maxPoint
				self._fullhouses = result

				SetUsedValue(self._fullhouses)
			end
			-- luaDump(result)
		end

		return self._fullhouses
	end

	function Cards:HaveGrandStraight()
		self:GetGrandStraight()
		return #self._flushstraighs>0 and self._flushstraighs.maxPoint
	end
	function Cards:GetGrandStraight(result)
		if not self._flushstraighs then
			local result = {}

			local list = self:GetFlush()
			for i, v in ipairs(list) do
				local cardDatas = list[i]
				
				local temp = {}
				for i=1, #cardDatas do
					table.insert(temp, cardDatas[i].bIndex)
				end

				local manager = CardLogic.GetCardsManager(temp)
				if manager:HaveStraight() then
					table.insert(result, cardDatas)
					result.maxPoint = math.max(result.maxPoint or 0, CardLogic.MaxPoint(cardDatas))
				end
			end

			-- local list = self:GetStraight()
			-- for i, v in ipairs(list) do
			-- 	local cardDatas = list.cardDatas[i]
			-- 	local eq = true
			-- 	for i1=1, #cardDatas-1 do
			-- 		if cardDatas[i1].bColor~=cardDatas[i1+1].bColor then
			-- 			eq = false
			-- 			break
			-- 		end
			-- 	end
			-- 	if eq then
			-- 		result.maxPoint = list.maxPoint
			-- 		table.insert(result, v)
			-- 		table.insert(result.cardDatas, cardDatas)
			-- 	end
			-- end
			self._flushstraighs = result

			SetUsedValue(self._flushstraighs)
		end
		return self._flushstraighs
	end

	Cards:clear()
	return Cards
end

function CardLogic.DataToBBWList(valueList)
	local result = {}

	table.walk(valueList, function(value, i)
		result[i] = CardLogic.DataToBBW(value)
	end)

	return result
end

function CardLogic.BBWToGDIList(valueList)
	local result = {}

	table.walk(valueList, function(value, i)
		result[i] = CardLogic.BBWToGDI(value)
	end)

	return result
end

-- server2client value
function CardLogic.DataToBBW(_value)

	-- if _value<=0 or _value>120 then
	-- 	return 0
	-- end

	local bResult
	local remainder = _value%13
	local consult = math.floor(_value/13)

	if consult==4 and remainder>0 then
		bResult = consult*16+remainder
	else
		if remainder==1 then
			bResult = consult*16+13
		elseif remainder==0 then
			bResult = (consult-1)*16+12
		else
			bResult = consult*16+remainder-1
		end
	end

	return bResult
end

-- client2server value
function CardLogic.BBWToGDI(_value)

	-- if _value<=0 or _value>120 then
	-- 	return 0
	-- end

	local bResult
	local remainder = _value%16
	local consult = math.floor(_value/16)

	if consult==4 then
		bResult = consult*13+remainder
	else
		bResult = consult*13+remainder+1
		if remainder==13 then
			bResult = bResult-13
		end		
	end

	return bResult
end

local colorT = {"黑桃","红桃","梅花","方片"}
local valueT = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
function CardLogic.GetString(_value, isBBW)
	if _value==0 then return "" end
	local color, value
	if isBBW then
		if math.floor(_value/16)~=4 then
			color = math.floor(_value/16)%4 + 1
			color = (color~=5 and color or 5)
			value = _value%16
		else
			return "王"
		end
	else
		if math.floor(_value/13)~=4 then
			color = math.floor(_value/13)%4
			value = _value%13
			color = (value==0 and color or color+1)
			color = (color~=5 and color or 5)
			value = (value==1 and 13 or (value==0 and 12 or value-1))
		else
			return "王"
		end
	end

	-- log(_value)
	-- log("color "..color, "value "..value)
	if color<=4 then
		return colorT[color]..valueT[value]
	else
		return "王"
	end
end

function CardLogic.GetValues(names)
	local res = {}
	for i, v in ipairs(names) do
		local t = string.split(v, '-')
		local color = t[1]
		local value = t[2]

		local i1 = table.indexof(colorT, color)
		local i2 = table.indexof(valueT, value)

		i1 = (i2==12 and i1 or i1-1) 
		i2 = (i2==13 and 1 or (i2==12 and 0 or i2+1))

		res[i] = i1*13+i2
	end

	-- luaDump(res)

	return res
end

function CardLogic.PrintCardsData(cardDatas)
	for i, v in ipairs(cardDatas) do
		for i1, v1 in ipairs(v) do
			log(CardLogic.GetString(v1.bIndex))
		end
		log()
	end
end

return CardLogic
