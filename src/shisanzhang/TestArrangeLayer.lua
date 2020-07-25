local TestArrangeLayer = class("TestLayer", BaseWindow)

require("shisanzhang.CommonFunc")
require("shisanzhang.CommonUI")
require("shisanzhang.TableStructs")
require("shisanzhang.TableGlobal")
require("shisanzhang.TableConfig")
require("shisanzhang.TableUtil")
local CardLogic = require "shisanzhang.CardLogic"
local CardListBoard = require("shisanzhang.CardListBoard")
local PokerCard = require("shisanzhang.PokerCard")

cc.FileUtils:getInstance():addSearchPath("res/shisanzhang")

function TestArrangeLayer:ctor(values)
    self:setCard(values)
    
    self._dunCards = Array("table", 3)              -- 摆牌蹲显示
    self._canRecall = Array(false, 3)
    self._dunCardManager = Array(false, 3)
    self:init()

end

function TestArrangeLayer:init()
    local uiTable = {
		{"_btnRecallD1", "btn_cancel1"},
		{"_btnRecallD2", "btn_cancel2"},
		{"_btnRecallD3", "btn_cancel3"},
		{"_btnRecallAll", "btn_allcancell"},
		{"_btnConfirmCard", "btn_confirm"},

		{"_btnPairs", "btn_tip_1"},
		{"_btnTwoPairs", "btn_tip_2"},
		{"_btnTriples", "btn_tip_3"},
		{"_btnStraight", "btn_tip_4"},
		{"_btnFlush", "btn_tip_5"},
		{"_btnFullHouse", "btn_tip_6"},
		{"_btnFour", "btn_tip_7"},
		{"_btnGrandStraight", "btn_tip_8"},
		-- {"_btnFive", "btn_tip_9"},
		{"_btnSpecial", "btn_tip_10"},

		{"_dun1", "dun1_left"},
		{"_dun2", "dun2_left"},
		{"_dun3", "dun3_left"},
		{"_touch_1", "touch_1dun"},
		{"_touch_2", "touch_2dun"},
		{"_touch_3", "touch_3dun"},
		{"_imgCombinationTips1", "Img_cbn_tips_1"},
		{"_imgCombinationTips2", "Img_cbn_tips_2"},
		{"_imgCombinationTips3", "Img_cbn_tips_3"},

		{"_lbTimerArrange", "clock_num"},
	}

	self._arrangeWidget = UILoader:load("shisanzhang/ArrangeCard.json", self, uiTable):addTo(self)
	self._arrangeWidget:setAnchorPoint(display.CENTER)
	self._arrangeWidget:move(display.cx, display.height+self._arrangeWidget:getContentSize().height)
	self._arrangeWidget:runAction(cc.MoveTo:create(0.6, display.center))

	self._btnRecallD1:onClick(function(sender) self:arrangeMenuCallback(sender, 1) end)
	self._btnRecallD2:onClick(function(sender) self:arrangeMenuCallback(sender, 2) end)
	self._btnRecallD3:onClick(function(sender) self:arrangeMenuCallback(sender, 3) end)
	self._btnRecallAll:onClick(function(sender) self:arrangeMenuCallback(sender) end)
	self._btnConfirmCard:onClick(function(sender) self:arrangeMenuCallback(sender) end)

	self._btnPairs:onClick(function(sender) self:arrangeMenuCallback(sender, 1) end)
	self._btnTwoPairs:onClick(function(sender) self:arrangeMenuCallback(sender, 2) end)
	self._btnTriples:onClick(function(sender) self:arrangeMenuCallback(sender, 3) end)
	self._btnStraight:onClick(function(sender) self:arrangeMenuCallback(sender, 4) end)
	self._btnFlush:onClick(function(sender) self:arrangeMenuCallback(sender, 5) end)
	self._btnFullHouse:onClick(function(sender) self:arrangeMenuCallback(sender, 6) end)
	self._btnFour:onClick(function(sender) self:arrangeMenuCallback(sender, 7) end)
	self._btnGrandStraight:onClick(function(sender) self:arrangeMenuCallback(sender, 8) end)
	-- self._btnFive:onClick(function(sender) self:arrangeMenuCallback(sender, 9) end)
	self._btnSpecial:onClick(function(sender) self:arrangeMenuCallback(sender) end)

	self._touch_1:onClick(function(sender) self:arrangeImageCallback(sender, 1) end)
	self._touch_2:onClick(function(sender) self:arrangeImageCallback(sender, 2) end)
	self._touch_3:onClick(function(sender) self:arrangeImageCallback(sender, 3) end)

	self:setCtrlBtn()

	-- 摆牌列表
	self:addArrangeCardList()
	self:showUserArrangeCard(self:getMyCard(), false)
end

function TestArrangeLayer:setCard(values)
    self._HCCardD = {}
    self._HCCardH = {}

    for i=1, 13 do
        local hc = HandCard.new()
        hc.bIndex = values[i]
        hc.bValue = CardLogic.GetPointValue(hc.bIndex)
        table.insert(self._HCCardD, hc)
        table.insert(self._HCCardH, CardLogic.DataToBBW(hc.bIndex))
    end

    self._handCardManager = CardLogic.GetCardsManager(values)
end

-- 摆牌界面btn回调
function TestArrangeLayer:arrangeMenuCallback(sender, index)
	local name = sender:getName()

	if name=="btn_cancel1" or name=="btn_cancel2" or name=="btn_cancel3" then

	elseif name=="btn_allcancell" then
	elseif name=="btn_confirm" then

	elseif name=="btn_tip_1"
	or name=="btn_tip_2"
	or name=="btn_tip_3"
	or name=="btn_tip_4"
	or name=="btn_tip_5"
	or name=="btn_tip_6"
	or name=="btn_tip_7"
	or name=="btn_tip_8"
	or name=="btn_tip_9" then
		self:callOnCardsByType(index)
	elseif name=="btn_tip_10" then
	end
end

-- 根据牌型点出牌
function TestArrangeLayer:callOnCardsByType(cardType)
	if self._handCardManager then
		local valueList = self._handCardManager:GetDunCards(cardType)

		-- 点击不同btn重置选择index
		if cardType~=self._lastSelType then
			self._selIndex = 1
			self._lastSelType = cardType
		end

		self:setUpCardList(valueList[self._selIndex])
		self._selIndex = self._selIndex%(#valueList)+1
	end
end

-- 摆牌蹲位点击回调
function TestArrangeLayer:arrangeImageCallback(sender, dunIdx)
	local pos = sender:getTouchEndPosition()

	local count = CommonDunT[dunIdx].count
	local gap = CommonDunT[dunIdx].gap

	local index = math.floor((pos.x-sender:getPositionX()+sender:getContentSize().width/2)/gap)+1
	local card = self._dunCards[dunIdx][index]
	if not card then
		card = self._dunCards[dunIdx][index-1]
	end
	local value = card and CardLogic.BBWToGDI(card:getCardValue())
	local isCardUp = self:callOnDun(dunIdx, value)

	-- 两蹲摆满时自动上蹲
	local fullCount = 0
	local noFullIdx

	if isCardUp then
		-- 计算满蹲的个数
		for i=1, 3 do
			if self._dunCards[i].isFull then
				fullCount = fullCount + 1
			else
				noFullIdx = i
			end
		end
		if fullCount==2 then
			self:callOnDun(noFullIdx, 0)
		end
	end
end

function TestArrangeLayer:callOnDun(dunIdx, value)
	
	local dunCards = {}
	local handCards = {}
	local hands = {}
	local upCards = {}

	local first = {}
	local mid = {}
	local last = {}

	local firstVal = {}
	local midVal = {}
	local lastVal = {}

	local dunT = {
		{list=first, listVal = firstVal},
		{list=mid, listVal = midVal},
		{list=last, listVal = lastVal},
	}

	local pos = CommonDunT[dunIdx].pos
	local count = CommonDunT[dunIdx].count
	local curList = dunT[dunIdx].list
	local curListVal = dunT[dunIdx].listVal

	local needRecall = false
	local cardIdx
	
	local isCardUp --是否点击上牌  做返回结果

	for i=1, PLAYCARTCOUNT do
		local hc = self._HCCardD[i]

		if hc.ePt==HandCard.Pos.FIRST then
			table.insert(firstVal, hc.bIndex)
			table.insert(first, hc)
		elseif hc.ePt==HandCard.Pos.MID then
			table.insert(midVal, hc.bIndex)
			table.insert(mid, hc)
		elseif hc.ePt==HandCard.Pos.LAST then
			table.insert(lastVal, hc.bIndex)
			table.insert(last, hc)
		elseif hc.ePt==HandCard.Pos.HAND then
			table.insert(handCards, CardLogic.DataToBBW(hc.bIndex))
			table.insert(hands, hc)

			-- 全部点上
			if value==0 then
				hc.bUp = true
			end
		end

		if hc.ePt==pos then
			table.insert(dunCards, CardLogic.DataToBBW(hc.bIndex))
			-- 获取点击位置索引
			if hc.bIndex==value then
				cardIdx = #curList
			end
		end

		if hc.bUp then
			table.insert(upCards, hc)
		end

	end

	-- 点出的牌多余蹲位上限
	-- if #upCards>count then
	-- 	return
	-- end

	-- 有点出的牌
	if #upCards>0 then
		isCardUp = true
		-- 点出的牌放入first中，直到满
		for i, hc in ipairs(upCards) do
			upCards[i].bUp = false
			if #curListVal<count then
				hc.ePt = pos
				table.insert(dunCards, CardLogic.DataToBBW(hc.bIndex))
				table.insert(curListVal, hc.bIndex)
				table.removebyvalue(hands, hc)
				table.removebyvalue(handCards, CardLogic.DataToBBW(hc.bIndex))
			end
		end

	-- 没点出的牌就下落所点击的牌
	else
		local hc = curList[cardIdx]
		isCardUp = false
		if hc then
			hc.ePt = HandCard.Pos.HAND
			table.insert(hands, hc)
			table.insert(handCards, CardLogic.DataToBBW(hc.bIndex))
			table.removebyvalue(curList, hc)
			table.removebyvalue(curListVal, hc.bIndex)
			table.removebyvalue(dunCards, CardLogic.DataToBBW(hc.bIndex))
		end
	end

	CardLogic.SortPokers(dunCards, true)
	CardLogic.SortPokers(handCards, true)

	-- 蹲显示和手牌显示
	self:showUserDun(dunIdx, dunCards)
	self:showUserArrangeCard(handCards, false)

	-- 计算当前蹲的牌型相关
	self._dunCardManager[dunIdx] = nil
	if #curListVal==count then
		self._dunCardManager[dunIdx] = CardLogic.GetCardsManager(curListVal)
		-- 蹲提示
		local paiXin = self._dunCardManager[dunIdx]:GetPaiXin()
		self:showDunCardTips(dunIdx, paiXin.ePXE)
	end

	-- 全满判断是否需要重置
	if #firstVal==FIRSTDUNCOUNT and #midVal==OTHERDUNCOUNT and #lastVal==OTHERDUNCOUNT then
		if CardLogic.DunCompare(self._dunCardManager[3], self._dunCardManager[2])==0xff then
			needRecall = true
		elseif CardLogic.DunCompare(self._dunCardManager[2], self._dunCardManager[1])==0xff then
			needRecall = true
		end
	end

	-- 重新计算牌型相关和提示
	self._handCardManager = CardLogic.GetCardsManager(handCards, true)
	self._lastSelType = false
	self._canRecall[dunIdx] = (#dunCards>=count)
    self:setCtrlBtn()

	-- 错误提示信息
	local tipErr = 0
	if #midVal==OTHERDUNCOUNT and #lastVal==OTHERDUNCOUNT and CardLogic.DunCompare(self._dunCardManager[3], self._dunCardManager[2])==0xff then
		tipErr = 1
	elseif #firstVal==FIRSTDUNCOUNT and #midVal==OTHERDUNCOUNT and CardLogic.DunCompare(self._dunCardManager[2], self._dunCardManager[1])==0xff then
		tipErr = 2
	elseif #firstVal==FIRSTDUNCOUNT and #lastVal==OTHERDUNCOUNT and CardLogic.DunCompare(self._dunCardManager[3], self._dunCardManager[1])==0xff then
		tipErr = 3
	end

	if needRecall then
		self:callOnRecall(dunIdx)
	end

	if tipErr then
		self:warningArrangeError(tipErr, dunIdx)
	end

	return isCardUp
end

-- 蹲之间比较大小错误提示
function TestArrangeLayer:warningArrangeError(errCode, dunIdx)
	if errCode==0 then
		return
	end

	-- 具体顿显示信息
	local sp = cc.Sprite:create(string.format("arrenge_res/errTip%d.png", errCode))
			:move(display.cx, display.cy+100)
			:addTo(self, ErrTipZorder)
			:runAction(cc.Sequence:create(
				cc.DelayTime:create(2),
				cc.FadeOut:create(1.5),
				cc.RemoveSelf:create()
			))

	-- 玩家操作  撤回
	self:callOnRecall(dunIdx)
end

function TestArrangeLayer:callOnRecall(dunIdx)

	local allRecall = true
	local cards = {}

	local pos = CommonDunT[dunIdx].pos

	for i=1, #self._HCCardD do
		local hc = self._HCCardD[i]

		if hc.bValue ~= EXCEPTIONCARD then
			if hc.bUp then
				hc.bUp = false
			end
			if hc.ePt == pos then
				hc.ePt = HandCard.Pos.HAND
			end

			if hc.ePt == HandCard.Pos.HAND then
				table.insert(cards, CardLogic.DataToBBW(hc.bIndex))
			end
		end
	end


	CardLogic.Sort(cards)
	self:showUserArrangeCard(cards, false)

	-- 删除蹲显示
	self:removeDunCards(dunIdx)
	self._dunCardManager[dunIdx] = nil
	self._handCardManager = CardLogic.GetCardsManager(cards, true)
	self._lastSelType = false
	self._canRecall[dunIdx] = false
	self:setCtrlBtn()
end

-- 移除蹲牌
function TestArrangeLayer:removeDunCards(dunIdx)
	local dun = self._dunCards[dunIdx]
	for i=1, CommonDunT[dunIdx].count do
		if dun[i] then
			dun[i]:removeFromParent(true)
			dun[i] = nil
		end
	end
	dun.isFull = false
	self["_imgCombinationTips"..dunIdx]:hide()
end

-- 设置蹲位牌型提示
function TestArrangeLayer:showDunCardTips(dunIdx, cardType)
	local img_tips = self["_imgCombinationTips"..dunIdx]
	local texture = PaiXinT[cardType].texture
	texture = type(texture)=="table" and texture[2] or texture
	img_tips:show()
	img_tips:loadTexture(texture)
end

function TestArrangeLayer:showUserDun(dunIdx, values)
	self:removeDunCards(dunIdx)
	local touchDun = self["_touch_"..dunIdx]
	for i=1, #values do
		local cardPos = UILoader:seekNodeByName(touchDun, "card_bg_"..i)
		self._dunCards[dunIdx][i] = PokerCard:create(values[i])
		self._dunCards[dunIdx][i]:setPosition(cardPos:getPosition())
		self._dunCards[dunIdx][i]:setScale(cardPos:getScale())
		touchDun:addChild(self._dunCards[dunIdx][i])
	end

	-- 该蹲是否占满
	self._dunCards[dunIdx].isFull = (#values==CommonDunT[dunIdx].count)

end

-- 显示摆牌界面手牌
function TestArrangeLayer:showUserArrangeCard(values, isUp)
	if not self._arrangeCardList then
		self:addArrangeCardList()
	end

	if not isUp then
		self._arrangeCardList:clear()
	end

	self._arrangeCardList:addCardAllOnce(values, isUp)
end

-- 添加摆牌列表
function TestArrangeLayer:addArrangeCardList()
	local ptr = UILoader:seekNodeByName(self._arrangeWidget, "card_pos")

	if ptr then
		self._arrangeCardList = CardListBoard:create(true, false, 0)
		self._arrangeCardList:setPosition(ptr:getPosition())
		self._arrangeCardList:setAnchorPoint(ptr:getAnchorPoint())
		self._arrangeCardList:setCallFunction(handler(self, self.autoOutCallFunction))
		self._arrangeCardList:setCallFunctionUp(handler(self, self.autoUpCallFunction))
		self._arrangeCardList:setCallFunctionDown(handler(self, self.autoDownCallFunction))
		ptr:getParent():addChild(self._arrangeCardList, ptr:getLocalZOrder())
	end
end

-- 重置
function TestArrangeLayer:autoOutCallFunction(board)
	if not board then return end

	local outCards = board:getTouchedCards()
	self:autoOutCheck(outCards)
end

-- 上牌
function TestArrangeLayer:autoUpCallFunction(board, card)
	if not board then return end

	self:callSingleUp(card)
end

-- 下牌
function TestArrangeLayer:autoDownCallFunction(board, card)
	if not board then return end

	self:callSingleDown(card)
end

function TestArrangeLayer:autoOutCheck(cards)
	self:setUpCardList(cards)
end

-- 设置点上的牌
function TestArrangeLayer:setUpCardList(upCards)
	if self._arrangeCardList then
		self._arrangeCardList:upCards(upCards)
	end
end

function TestArrangeLayer:callSingleUp(card)
	local upData = {}

	for i=1, #self._HCCardD do
		local hc = self._HCCardD[i]
		local hcVal = CardLogic.DataToBBW(hc.bIndex)

		if hcVal == card then
			hc.bUp = true
			table.insert(upData, hc.bIndex)
			break
		end
	end
end

function TestArrangeLayer:callSingleDown(card)
	local downData = {}

	for i=1, #self._HCCardD do
		local hc = self._HCCardD[i]
		local hcVal = CardLogic.DataToBBW(hc.bIndex)

		if hcVal == card then
			hc.bUp = false
			table.insert(downData, hc.bIndex)
			break
		end
	end
end

function TestArrangeLayer:canBtnRecallShow(num)
	return self._canRecall[num]
end

-- 获取按钮状态
function TestArrangeLayer:canBtnTipsShow(num)
	local canbipai = true

	for i=1, PLAYCARTCOUNT do
		local hc = self._HCCardD[i]

		if hc.ePt == HandCard.Pos.HAND then
            canbipai = false
			break
		end
	end

	if canbipai then
		return false
	end

    if self._handCardManager then
		return PaiXinT[num].checkFunc(self._handCardManager)~=false
	end
end


-- 设置按钮显隐状态
function TestArrangeLayer:setCtrlBtn()
	local bShowBtn = true
	local btnState = {}

	btnState[6] = self:canBtnTipsShow(1)
	btnState[7] = self:canBtnTipsShow(2)
	btnState[8] = self:canBtnTipsShow(3)
	btnState[9] = self:canBtnTipsShow(4)
	btnState[10] = self:canBtnTipsShow(5)
	btnState[11] = self:canBtnTipsShow(6)
	btnState[12] = self:canBtnTipsShow(7)
	btnState[13] = self:canBtnTipsShow(8)
	btnState[14] = self:canBtnTipsShow(9)

	self._btnRecallD1:setVisible(btnState[1])
	self._btnRecallD2:setVisible(btnState[2])
	self._btnRecallD3:setVisible(btnState[3])
	self._btnRecallAll:setVisible(btnState[4])
	self._btnConfirmCard:setVisible(btnState[5])

	if btnState[4] and btnState[5] then
		bShowBtn = false
	end

	self._btnPairs:setVisible(bShowBtn)
	self._btnPairs:setEnabled(btnState[6])
	self._btnTwoPairs:setVisible(bShowBtn)
	self._btnTwoPairs:setEnabled(btnState[7])
	self._btnTriples:setVisible(bShowBtn)
	self._btnTriples:setEnabled(btnState[8])
	self._btnStraight:setVisible(bShowBtn)
	self._btnStraight:setEnabled(btnState[9])
	self._btnFlush:setVisible(bShowBtn)
	self._btnFlush:setEnabled(btnState[10])
	self._btnFullHouse:setVisible(bShowBtn)
	self._btnFullHouse:setEnabled(btnState[11])
	self._btnFour:setVisible(bShowBtn)
	self._btnFour:setEnabled(btnState[12])
	self._btnGrandStraight:setVisible(bShowBtn)
	self._btnGrandStraight:setEnabled(btnState[13])
	-- self._btnFive:setVisible(bShowBtn)
    -- self._btnFive:setEnabled(btnState[14])
end

function TestArrangeLayer:getMyCard()
	local myCard = clone(self._HCCardH)
	CardLogic.Sort(myCard)

	return myCard
end

return TestArrangeLayer