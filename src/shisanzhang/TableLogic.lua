local TableLogic = class("TableLogic", require("logic.roomLogic.GameLogicBase"))
local GameTableUsersData = require("shisanzhang.GameTableUsersData")
local CardLogic = require("shisanzhang.CardLogic")

local Audio = require("shisanzhang.Audio")

function TableLogic:ctor(tableUI, deskNo, bAutoCreate, bMaster)

	self.super.ctor(self, tableUI, deskNo, bAutoCreate, bMaster, PLAY_COUNT);

	--创建房间相关信息
	self._gameStatus 	= 0 	--游戏状态
	self._waitTime 		= 0	 	--等待时间

	--@RefType [app.views_shisanshui.GameTable.TableLayer#TableLayer]
	self._callback = tableUI

	self._userReady = Array(false, PLAY_COUNT) 		-- 玩家准备表

	self._iRoomBasePoint = 1					--房间倍数
	self._iArrangeCardTime = 60					--摆牌时间

	self._HCCardD = Array("table", PLAY_COUNT)			-- 手牌表 10进制
	self._HCCardH = Array("table", PLAY_COUNT)			-- 手牌表 16进制

	self._gsSendCard = {}  				-- 发牌数据

	self._canRecall = Array(false, 3)	-- 某蹲可重置

	self._handCardManager = false  -- 手牌的logic
	self._dunCardManager = {}	   -- 每蹲的logic

	self._selIndex = 1			-- 摆牌某牌型选中索引
	self._lastSelType = false   -- 上次选牌的牌型

	self._specCardTypeList = false     -- 每局比牌的特殊牌型列表

	self.isReadyTime = false      -- 准备是否倒计时开始游戏(多人场用)

	self._playerSitted = {}			--是否已坐下

	self._resultInfo = false		--小局结束
end

function TableLogic:viewToLogicSeatNo(vSeatNO)
	if vSeatNO == nil or vSeatNO < 0 or vSeatNO > PLAY_COUNT then
		luaPrint("viewToLogicSeatNo vSeatNO is error")
		return
	end

	local lSeatNo = math.fmod(vSeatNO - self._seatOffset + PLAY_COUNT, PLAY_COUNT)
	lSeatNo = lSeatNo==0 and PLAY_COUNT or lSeatNo
	return lSeatNo
end

function TableLogic:logicToViewSeatNo(lSeatNO)
    if lSeatNO == nil or lSeatNO < 0 or lSeatNO > PLAY_COUNT then
        luaPrint("logicToViewSeatNo lSeatNO is error")
        if lSeatNO ~= nil then
            luaPrint("logicToViewSeatNo lSeatNO is " .. lSeatNO)
        end
        return -1
    end
    -- luaPrint("lSeatNO "..lSeatNO.." ,self._seatOffset = "..self._seatOffset.." ,PLAY_COUNT = "..PLAY_COUNT)
    local vSeatNo = math.fmod(lSeatNO + self._seatOffset + PLAY_COUNT, PLAY_COUNT)
    vSeatNo = vSeatNo == 0 and PLAY_COUNT or vSeatNo
    -- luaPrint("vSeatNo "..vSeatNo)
    return vSeatNo
end

function TableLogic:getUserBySeatNo(lSeatNo)
    return self._deskUserList:getUserByDeskStation(lSeatNo - 1)
end

function TableLogic:getMySeatNo()
    return self._mySeatNo + 1
end


function TableLogic:enterGame()
	self:loadDesk()
	self:loadMySeat()
	self:loadUsers()

	self:sendBegin()
end

function TableLogic:loadDesk()
	self._gameStatus = GS_WAIT_NEXT
	
	-- self._callback:showDeskInfoGold()
end

function TableLogic:loadMySeat()
	if INVALID_DESKSTATION ~= self._mySeatNo and self._autoCreate then
		self:sendGameInfo();
	end
end

function TableLogic:loadUsers()
	self:loadDeskUsers()
	for i=1, PLAY_COUNT do
		self:onUserEnter(i)
	end
end

--判断满人
function TableLogic:checkIsAllSat()
	local isAllSat = true
	for i=1, PLAY_COUNT do
		if not self._existPlayer[i] then
			isAllSat = false
		end
	end
	return isAllSat
end

function TableLogic:getUserUserID(vSeatNo)
	local seatNo = self:viewToLogicSeatNo(vSeatNo)
	local userInfo = self:getUserBySeatNo(seatNo)

	if userInfo then
		return userInfo.dwUserID
	end
end

function TableLogic:getUserHeadUrl(vSeatNo)
	local seatNo = self:viewToLogicSeatNo(vSeatNo)
	local userInfo = self:getUserBySeatNo(seatNo)

	if userInfo then
		return userInfo.sHeadUrl
	end
end

function TableLogic:getUserMoney(vSeatNo)
	local seatNo = self:viewToLogicSeatNo(vSeatNo)
	local userInfo = self:getUserBySeatNo(seatNo)

	if userInfo then
		return userInfo.i64Money
	end
end

function TableLogic:clearDesk()
	self._callback:clearDesk()

	for i=1, PLAY_COUNT do
		local seatNo = self:logicToViewSeatNo(i)
		-- 移除计时器
		if not self.isReadyTime then
			self._callback:setWaitTime(false)
		end
		self._callback:showBiPaiFinish(seatNo, false)
	end
end

function TableLogic:playing()
	return  self._gameStatus == GS_PLAY_GAME
end

function TableLogic:waiting()
	return  self._gameStatus == GS_WAIT_NEXT or self._gameStatus == GS_WAIT_SETGAME or self._gameStatus == GS_WAIT_ARGEE
end

function TableLogic:showArrangeTime()
	self._callback:setArrangeCardTime(self._iArrangeCardTime-4, true)
end

function TableLogic:getMyCard()
	local myCard = clone(self._HCCardH[self:getMySeatNo()])
	CardLogic.Sort(myCard)

	return myCard
end

function TableLogic:autoOutCheck(cards)
	self._callback:setUpCardList(cards)
end

function TableLogic:callSingleUp(card)
	local upData = {}

	local mySeatNo = self:getMySeatNo()
	for i=1, #self._HCCardD[mySeatNo] do
		local hc = self._HCCardD[mySeatNo][i]
		local hcVal = CardLogic.DataToBBW(hc.bIndex)

		if hcVal == card then
			hc.bUp = true
			table.insert(upData, hc.bIndex)
			break
		end
	end
end

function TableLogic:callSingleDown(card)
	local downData = {}

	local mySeatNo = self:getMySeatNo()
	for i=1, #self._HCCardD[mySeatNo] do
		local hc = self._HCCardD[mySeatNo][i]
		local hcVal = CardLogic.DataToBBW(hc.bIndex)

		if hcVal == card then
			hc.bUp = false
			table.insert(downData, hc.bIndex)
			break
		end
	end
end

function TableLogic:canBtnRecallShow(num)
	return self._canRecall[num]
end

function TableLogic:canBtnSubmitCancelShow()
	if self._mySeatNo==INVALID_DESKSTATION then
		return
	end

	local canbipai = true
	local mySeatNo = self:getMySeatNo()

	for i=1, PLAYCARTCOUNT do
		local hc = self._HCCardD[mySeatNo][i]

		if hc.ePt == HandCard.Pos.HAND then
			canbipai = false
			break
		end
	end

	return canbipai
end

-- 获取按钮状态
function TableLogic:canBtnTipsShow(num)
	if self._mySeatNo==INVALID_DESKSTATION then
		return
	end

	local canbipai = true
	local mySeatNo = self:getMySeatNo()

	for i=1, PLAYCARTCOUNT do
		local hc = self._HCCardD[mySeatNo][i]

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

function TableLogic:callOnRecall(dunIdx)

	local allRecall = true
	local cards = {}

	local pos = CommonDunT[dunIdx].pos
	local mySeatNo = self:getMySeatNo()

	for i=1, #self._HCCardD[mySeatNo] do
		local hc = self._HCCardD[mySeatNo][i]

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
	self._callback:showUserArrangeCard(cards, false)

	-- 删除蹲显示
	self._callback:removeDunCards(dunIdx)
	self._dunCardManager[dunIdx] = nil
	self._handCardManager = CardLogic.GetCardsManager(cards, true)
	self._lastSelType = false
	self._canRecall[dunIdx] = false
	self._callback:setCtrlBtn()

end

function TableLogic:callOnRecallAll()
	self:callOnRecall(1)
	self:callOnRecall(2)
	self:callOnRecall(3)
end

function TableLogic:callOnDun(dunIdx, value)
	log(dunIdx, value)
	
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
		local hc = self._HCCardD[self:getMySeatNo()][i]

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
	self._callback:showUserDun(dunIdx, dunCards)
	self._callback:showUserArrangeCard(handCards, false)

	-- 计算当前蹲的牌型相关
	self._dunCardManager[dunIdx] = nil
	if #curListVal==count then
		self._dunCardManager[dunIdx] = CardLogic.GetCardsManager(curListVal)
		-- 蹲提示
		local paiXin = self._dunCardManager[dunIdx]:GetPaiXin()
		self._callback:showDunCardTips(dunIdx, paiXin.ePXE)
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
	self._callback:setCtrlBtn()

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
		self._callback:warningArrangeError(tipErr, dunIdx)
	end

	return isCardUp
end

-- 根据牌型点出牌
function TableLogic:callOnCardsByType(cardType)
	if self._handCardManager then
		local valueList = self._handCardManager:GetDunCards(cardType)

		-- 点击不同btn重置选择index
		if cardType~=self._lastSelType then
			self._selIndex = 1
			self._lastSelType = cardType
		end

		self._callback:setUpCardList(valueList[self._selIndex])
		self._selIndex = self._selIndex%(#valueList)+1
	end
end

-- 确认提交
function TableLogic:callOnConfirmSubmit()
	-- 检查是否蹲排位是否正确
	-- todo

	self:sendVersusCard()
end

function TableLogic:callOnConfirmSubmitSpec()
	if self._gsSendCard.isteshu==1 then
		shisanzhangInfo:sendTanpaiSpec()
	end
end

-- 发送比牌
function TableLogic:sendVersusCard()
	local bFirst, bMid, bLast = {}, {}, {}

	local i1, i2, i3 = 1, 1, 1
	local mySeatNo = self:getMySeatNo()
	for i=1, PLAYCARTCOUNT do
		local hc = self._HCCardD[mySeatNo][i]
		if hc.ePt==HandCard.Pos.HAND then
			log("还有手牌~！")
		elseif hc.ePt==HandCard.Pos.FIRST then
			bFirst[i1] = hc.bIndex
			i1 = i1 + 1
		elseif hc.ePt==HandCard.Pos.MID then
			bMid[i2] = hc.bIndex
			i2 = i2 + 1
		elseif hc.ePt==HandCard.Pos.LAST then
			bLast[i3] = hc.bIndex
			i3 = i3 + 1
		end
	end	

	local data = {
		tsbPRD = 0,
		bFirst = bFirst,
		bMid = bMid,
		bLast = bLast,
	}

	shisanzhangInfo:sendTanpai(data)
end



function TableLogic:getVSCardResult(dunIdx, isSpec, isEnd)
    local dunPos = {"bFirst", "bMid", "bLast"}
    local dunName = dunPos[dunIdx]
    local count = CommonDunT[dunIdx].count

    -- local scores = clone(self._gsbf.mPDateResult[dunIdx])
    -- for i=1, #scores do
    -- 	if isSpec then
    -- 		if self._gsbf.isteshu[i] then
    -- 			scores[i] = nil
    -- 		end
    -- 	end

    -- 	-- 没有比牌数据的玩家不参与排名
    -- 	if self._gsbf.bPlay[i][dunName][1]==0 then
    -- 		scores[i] = nil
    -- 	end
    -- end

    -- 获取蹲的manager
    local managerList = {}
    for i = 1, PLAY_COUNT do
        local dun = clone(self._gsbf.bPlay[i][dunName])
        managerList[#managerList + 1] = CardLogic.GetCardsManager(dun)
    end

    for i = 1, #managerList do
        if isSpec then
            if self._gsbf.isteshu[i] then
                managerList[i] = nil
            end
        end
        -- 没有比牌数据的玩家不参与排名
        if self._gsbf.bPlay[i][dunName][1] == 0 then
            managerList[i] = nil
        end
    end
    local rankList = TableUtil.getRankByPX(managerList, true)
    -- local rankList = TableUtil.getRankByScore(scores, true)
    for i = 1, PLAY_COUNT do
        -- 玩家存在比牌数据
        if self._gsbf.bPlay[i][dunName][1] ~= 0 then
            local cardType
            local dun = clone(self._gsbf.bPlay[i][dunName])
            local rank = isEnd and 1 or rankList[i]
            -- 确定牌型
            if isSpec and self._gsbf.isteshu[i] then
                cardType = -(self._gsbf.teshuType[i] + 1)
            else
                cardType = CardLogic.GetPaiXin(dun).ePXE
            end

            if not self._gsbf.isteshu[i] then
                local vSeatNo = self:logicToViewSeatNo(i)
                -- 获取牌值
                local cards = CardLogic.DataToBBWList(dun)

                self._callback:showVSCardResult(
                    dunIdx,
                    vSeatNo,
                    self._gsbf.mPDateResult[dunIdx][i],
                    cardType,
                    cards,
                    rank
                )
            end
        end
    end
end


-- 获取正在游戏的玩家数
function TableLogic:getUserCountInGame(isSpec)
    local count = 0

    if TableGlobal.isShowTogether() then
        return 1.5
    end

    for i = 1, PLAY_COUNT do
        if self._gsbf.bPlay[i].bFirst[1] ~= 0 then
            if isSpec then
                if not self._gsbf.isteshu[i] then
                    count = count + 1
                end
            else
                count = count + 1
            end
        end
    end
    return count
end


-- 调用显示结算界面
function TableLogic:callGameEndView()
    local playerPoint = clone(self._gsbf.bPoint)

    -- 座位有人的提前
    -- for i=1, #playerPoint do
    -- 	if not self._playerSitted[i] then
    -- 		playerPoint[i] = nil
    -- 	end
    -- end
    -- 清除没有比牌数据的玩家
    for i = 1, #playerPoint do
        if self._gsbf.bPlay[i].bFirst[1] == 0 then
            playerPoint[i] = nil
            if i== self:getMySeatNo() and globalUnit.nowTingId > 0 then
            	-- performWithDelay(self._callback, function() self._callback._btnStart:setVisible(true) end, 3)
        	end
        end
    end

    luaDump(playerPoint)
    local rankList = TableUtil.getRankByScore(playerPoint)
    luaDump(rankList)

    for i = 1, PLAY_COUNT do
        local first = clone(self._gsbf.bPlay[i].bFirst)
        local mid = clone(self._gsbf.bPlay[i].bMid)
        local last = clone(self._gsbf.bPlay[i].bLast)

        -- 非特殊牌需要排序
        if not self._gsbf.isteshu[i] then
            CardLogic.SortPokersGDI(first)
            CardLogic.SortPokersGDI(mid)
            CardLogic.SortPokersGDI(last)
        end

        local user = self._gsbf.users[i]

        if user then
            local rank = rankList[i]

            if rank then
                -- local score = playerPoint[i]
                local score = self._resultInfo.lGameScore[i]
                local point = self._gsbf.bPoint[i]
                -- local point = self._resultInfo.lGameScore[i]
				local totalPoint = self._gsbf.bTotalPoint[i]

                local vSeatNo = self:logicToViewSeatNo(i)
                local cards = {}

                for j = 1, PLAYCARTCOUNT do
                    if j > 8 then
                        cards[j] = CardLogic.DataToBBW(last[j - 8])
                    elseif j > 3 then
                        cards[j] = CardLogic.DataToBBW(mid[j - 3])
                    else
                        cards[j] = CardLogic.DataToBBW(first[j])
                    end
                end

                -- 特殊牌排序
                if self._gsbf.isteshu[i] then
                    if self._gsbf.teshuType[i] == 8 then
                        CardLogic.SortPokersByColor(cards)
                    else
                        CardLogic.SortPokers(cards)
                    end
                end

                self._callback:setGameResultInfo(
                    vSeatNo,
                    rank,
                    user,
                    score,
                    point,
                    totalPoint,
                    cards,
                    self._gsbf.isteshu[i] and self._gsbf.teshuType[i]
                )
            end
        end
    end
end


function TableLogic:getGunOrKoAll()
    local daqiang = 0

    for i = 1, PLAY_COUNT do
        for j = 1, PLAY_COUNT do
            if i ~= j then
                if self._gsbf.WinAll[i][j] then
                    daqiang = daqiang + 1
                end
            end
        end
    end

    if self._gsbf.isquanleida ~= 255 then
        daqiang = daqiang + 4
    end

    return daqiang
end


function TableLogic:callGunOrKoAll()
    local daqiang = 0
    for i = 1, PLAY_COUNT do
        for j = 1, PLAY_COUNT do
            if i ~= j then
                if self._gsbf.WinAll[i][j] then
                    self._callback:showdaqiang(i, j, daqiang)
                    daqiang = daqiang + 1
                end
            end
        end
    end

    if self._gsbf.isquanleida ~= 255 then
        self._callback:showquanleida(daqiang)
    end
end


-- 一局结束调用
function TableLogic:onGameEnd(data)
	self._resultInfo = data

	self._resultInfo.userinfo = {}
	self._resultInfo.bIsMe = {}
	for i=1, PLAY_COUNT do
		local userInfo = self:getUserBySeatNo(i)
		self._resultInfo.bIsMe[i] = (i==self:getMySeatNo())
		-- self._resultInfo.userinfo[i] = userInfo and userInfo.dwUserID
	end

	luaDump(self._resultInfo)
end

function TableLogic:dealGameEnd()

	if self._resultInfo then
		local hasMe = false
		local data = self._resultInfo
		for i = 1, PLAY_COUNT do
			if self._gsbf.bPlay[i].bFirst[1]>0 then
				if data.bIsMe[i] then
					hasMe = true
					if data.lGameScore[i] > 0 then
						self._callback:playResultEffect(1)
					elseif data.lGameScore[i] < 0 then
						self._callback:playResultEffect(2)
					else
						self._callback:playResultEffect(3)
					end
				end

				local vSeatNo = self:logicToViewSeatNo(i)

				local userInfo = self:getUserBySeatNo(i)
				-- local userid = userInfo and userInfo.dwUserID

				-- if userid and table.keyof(data.userinfo, userid) then
					if not self._callback.IsGameEndEnter[seatNo] then
						self._callback:setUserMoney(vSeatNo, data.i64Money[i])
					end
					self._callback:showScoreLabel(vSeatNo, data.lGameScore[i])
				-- end
			end
		end

		if not hasMe then
			self._callback:playResultEffect(4)
		end
	end

	self:callGameEndView()
end

function TableLogic:dealGameBuymoney(msg)
	luaDump(msg,"dealGameBuymoney");

	local realSeat = self:getlSeatNo(msg.UserID);
	local vSeatNo = self:logicToViewSeatNo(realSeat+1);
	
	self._callback:setUserMoney(vSeatNo, msg.score);

end

function TableLogic:showMoney()
	for i=1, PLAY_COUNT do
		local user = self:getUserBySeatNo(i)
		if user then
			self._callback:setUserMoney(self:logicToViewSeatNo(i), user.i64Money)
		end
	end
end

function TableLogic:isBoy(seatNo)
	local user = self:getUserBySeatNo(seatNo)
	return user and user.bBoy or 1
end

function TableLogic:resetData()
	self._iRoomBasePoint = 1				--房间倍数
	self._iArrangeCardTime = 60			 	--摆牌时间

	self._gsbf = false

	self._gsSendCard = {}

	self._HCCardD = Array("table", PLAY_COUNT)
	self._HCCardH = Array("table", PLAY_COUNT)

	self._canRecall = Array(false, 3)

	self._selIndex = 1
	self._lastSelType = false
end

function TableLogic:sendCutCard(isCut)
	RoomDataManager:SendCutCard(isCut)
end

function TableLogic:callSpecCard()
	for i=1, PLAY_COUNT do
		if self._gsbf.isteshu[i] then
			local user = self:getUserBySeatNo(i)
			local vSeatNo = self:logicToViewSeatNo(i)

			local cards = {}
			for j=1, PLAYCARTCOUNT do
				if j>8 then
					table.insert(cards, CardLogic.DataToBBW(self._gsbf.bPlay[i].bLast[j-8]))
				elseif j>3 then
					table.insert(cards, CardLogic.DataToBBW(self._gsbf.bPlay[i].bMid[j-3]))
				else
					table.insert(cards, CardLogic.DataToBBW(self._gsbf.bPlay[i].bFirst[j]))
				end
			end

			local cardType = -(self._gsbf.teshuType[i]+1)

			self._callback:showBiPaiFinish(vSeatNo, false)
			self._callback:showVSCardResult(0, vSeatNo, 0, cardType, cards, 1)
		end
	end
end

function TableLogic:getSpecCardEffect()

	local list = {}
	for i=1, PLAY_COUNT do
		if self._gsbf.teshuType[i]>0 then
			if self:isBoy(i) then
				table.insert(list, bit:_or(self._gsbf.teshuType[i], 0x80))
			else
				table.insert(list, self._gsbf.teshuType[i])
			end
		end
	end

	if #list > 0 then
		table.sort(list, function(c1, c2)
			return bit:_and(c1, 0x7f) > bit:_and(c2, 0x7f)
		end)
	end

	self._specCardTypeList = list

	return #list
end

function TableLogic:callSpecCardEffect()

	if not self._specCardTypeList then
		self:getSpecCardEffect()
	end

	self._callback:playSpecCardEffect(self._specCardTypeList)

end


function TableLogic:getAllUserInfos()
	local userinfos = {}
	for i=1, PLAY_COUNT do
		local user = self:getUserBySeatNo(i)
		if user then
			userinfos[i] = user
		end
	end	
	luaPrint("abelmou get all userinfos  length " .. #userinfos)
	return userinfos
end

-- 收到服务器下推信息
function TableLogic:onUserEnter(lSeatNo)
    local user = self:getUserBySeatNo(lSeatNo)
    if user then
        local vSeatNo = self:logicToViewSeatNo(lSeatNo)
        log("lSeatNo:" .. lSeatNo, "vSeatNo:" .. vSeatNo)
        luaDump(user, "user")
		if not self._playerSitted[lSeatNo] then 
			self._playerSitted[lSeatNo] = true;
			self._callback:addUser(vSeatNo, lSeatNo == self:getMySeatNo())
			self._callback:showPlayerInfo(vSeatNo, user, true)
		end
    else
        luaPrint(string.format("user%d is nil", lSeatNo))
    end
end

function TableLogic:onUserExit(lSeatNo, bIsMe,userUp)
	if self._playerSitted[lSeatNo] then
		self._playerSitted[lSeatNo] = false
		local vSeatNo = self:logicToViewSeatNo(lSeatNo)
		self._callback:removeUser(vSeatNo, bIsMe,userUp.bLock)
	end
end

function TableLogic:onUserReady(lSeatNo, isAgree)
	

	self._userReady[lSeatNo] = isAgree
	if GS_WAIT_NEXT == self._gameStatus then
		self._gameStatus = GS_WAIT_ARGEE
	end

	if isAgree then
		-- 如果已经不是准备阶段 不处理
		if self._gameStatus~=GS_WAIT_ARGEE then
			return
		end

		if lSeatNo == self:getMySeatNo() then
			self:clearDesk()
		end
	end

	local seatNo = self:logicToViewSeatNo(lSeatNo)
	self._callback:showUserState(seatNo, isAgree, "ready")
end

function TableLogic:onUserStatus(nUserId1,nUserId2,bOnline)
	for i=1, PLAY_COUNT do
		local user = self:getUserBySeatNo(i)

		if user and user.nUserId1==nUserId1 and user.nUserId2==nUserId2 then
			self._callback:gameUserCut(self:logicToViewSeatNo(i), user)
		end
	end
end

-- 一局开始定庄
function TableLogic:onBaStart()
    luaDump("开始定庄")
    self:clearDesk()
    RoomDataManager:ResetBaData()
    for i = 1, PLAY_COUNT do
        self._userReady[i] = false
        self._callback:showYaFenPanel(i, false)
        self._callback:setUserBanker(i, false)
        self._callback:showUserState(self:logicToViewSeatNo(i), false)
    end

    self._gameStatus = GS_PLAY_GAME -- 定义游戏状态
    self._callback:updateGameRemainCount() -- 更新场数
    self._callback:setWaitTime(false)
end


-- 发牌
function TableLogic:onFaPai(data)

	self._gsSendCard = data.bHand
	self._gsSendCard.isteshu = data.isteshu
	self._iArrangeCardTime = data.time or 60
	if globalUnit.nowTingId>0 then
		self._iArrangeCardTime = data.time or 70
	end
	self._callback:clearUI()
	self._bTanPaiFinished = false

	self._callback:showResultWidget(false)

	Audio.startFaPai()
	
    -- local test = CardLogic.GetValues({
    -- 	"黑桃-A","黑桃-Q","黑桃-7","黑桃-5","黑桃-4",
    -- 	"红桃-2","红桃-9","红桃-9","红桃-Q","红桃-Q",
    -- 	"方片-3","方片-2","方片-A"
    -- })
	local mySeatNo = self:getMySeatNo()
    for i=1, PLAY_COUNT do
		-- 隐藏准备标识
		self._callback:showUserState(self:logicToViewSeatNo(i), false)

		self._HCCardD[i] = {}
		self._HCCardH[i] = {}
		if self._gsSendCard[i][1]~=0 then
			for j=1, 13 do
				local hc = HandCard.new()
				hc.bIndex = self._gsSendCard[i][j]--test[j]--
				if hc.bIndex==255 then
					hc.bIndex = 0
				end
				hc.bValue = CardLogic.GetPointValue(hc.bIndex)
				table.insert(self._HCCardD[i], hc)
				table.insert(self._HCCardH[i], CardLogic.DataToBBW(hc.bIndex))
			end
		end

		-- 播放发牌动画
		if self._existPlayer[i] then
			local seatNo = self:logicToViewSeatNo(i)
			local cards = Array(0, 13)
			
			if not data.bOpen or data.bOpen[i]==0 then
				self._callback:showBiPaiFinish(seatNo, false)
				self._callback:showUserHandCardBack(seatNo, cards)

				if mySeatNo==i then
					CardLogic.Sort(self._HCCardD[i], true)
					self._handCardManager = CardLogic.GetCardsManager(self._HCCardH[mySeatNo], true)

					self._scene = SceneEnum.GS_PLAY_GAME
					self._callback:showGameStateTipWord(GTipEnum.GTip_Pls_Outcard, true)
				end
			else
				self._callback:showBiPaiFinish(seatNo, true)

				if mySeatNo==i then
					self._callback:setWaitTime(true, self._iArrangeCardTime)
				end
			end

		end

	end
end

-- 摆牌完成
function TableLogic:onBaiPaiFinish(data)
	for i=1, PLAY_COUNT do
		local seatNo = self:logicToViewSeatNo(i)
		local mySeat = self:getMySeatNo()

		if data.bBiPai[i] then
			self._callback:showBiPaiFinish(seatNo, true)
			self._callback:hideUserHandCard(seatNo)

			if mySeat==i and not self._bTanPaiFinished then
				self._bTanPaiFinished = true
				self._callback:setWaitTime(true, self._callback:getArrangeCardTime())
			end
		end
	end
end

-- 一局结束
function TableLogic:onBaEnd(data)
	self._gsbf = data

	-- 保存玩家备份给小结算
	self._gsbf.users = {}
	for i=1, PLAY_COUNT do
		local seatNo = self:logicToViewSeatNo(i)
		self._callback:showBiPaiFinish(seatNo, false)
		self._callback:hideUserHandCard(seatNo)

		self._gsbf.users[i] = clone(self:getUserBySeatNo(i))
	end
	self._bDunResult = Array(2, PLAY_COUNT, PLAY_COUNT, 3)

	local isSpecial = false
	for i=1, PLAY_COUNT do
		if self._gsbf.isteshu[i] then
			isSpecial = true
			break
		end
	end

	if isSpecial then
		self._callback:showGameStateTipWord(GTipEnum.GTip_Start_VScard_Spec, true)
	else
		self._callback:showGameStateTipWord(GTipEnum.GTip_Start_VScard, true)
	end

	self._gameStatus = GS_WAIT_NEXT

	self._callback:showGameResultView()
end

function TableLogic:onLeaveGame(resultCode)
	self._callback:gameLeftResult(resultCode)
end

function TableLogic:onReadyTime()
	log("time", g_nTime)

	self._callback:setWaitTime(false)
	if g_nTime~=0 then
		self._callback:setWaitTime(true, g_nTime)
	end

	self.isReadyTime = true
end

--//玩家坐下协议,父类方法
function TableLogic:dealUserSitResp(userSit, user)
	luaPrint("玩家坐下dealUserSitResp")
	if userSit == nil or user == nil then
        return;
    end
    if self._callback == nil then
		return;
	end
    local seatNo = self:logicToViewSeatNo(userSit.bDeskStation+1);
    local isMe = (user.dwUserID == PlatformLogic.loginResult.dwUserID);

    if isMe then
		self:loadDeskUsers();
		self._seatOffset = -userSit.bDeskStation
		luaPrint("自己//玩家坐下协议,父类方法")
		self:loadUsers();
		self:sendGameInfo();
    else
    	luaPrint("其他玩家坐下userSit.bDeskStation == "..userSit.bDeskStation)
		self:onUserEnter(userSit.bDeskStation+1)
        -- self._callback:setUserName(seatNo, user.nickName);
        -- self._callback:showUserMoney(seatNo, true);
    end

    -- luaPrint("游戏内坐下 设置房主")
    -- self._callback:setUserMaster(seatNo, userSit.dwUserID == self.m_dwTableOwnerIdx);
end

--玩家退出协议
function TableLogic:dealUserUpResp(userUp,user,bIsMe)
	luaPrint("玩家退出dealUserUpResp")
	if userUp == nil or user == nil then
		return;
	end
	if self._callback == nil then
		return;
	end
	self.super.dealUserUpResp(userUp, user);

	local seatNo = self:logicToViewSeatNo(userUp.bDeskStation);
	luaPrint("数据================"..seatNo);
	
	self:onUserExit(userUp.bDeskStation+1, bIsMe,userUp)
	-- self._callback:setUserName(seatNo," ");
	-- self._callback:showUserMoney(seatNo, false);
	-- self._callback:setUserMoney(seatNo, 0);
	
	-- self._callback:playerGetReady(seatNo, false);
	
end

-- //处理游戏断线重连,，主要是断线重连来后处理的消息
function TableLogic:dealGameStationResp(object, objectSize)
	luaPrint("处理游戏断线重连dealGameStationResp ="..self._gameStatus)
	self._callback.m_bGameStart = true;
	-- local msg = convertToLua(object,GameMsg.CMD_S_StatusFree);
	self._callback:showGameStatus(object,self._gameStatus)
	
end

------------  发送  ------------
function TableLogic:sendBegin()
	
	-- 移除计时器
	-- self._callback:setWaitTime(self:logicToViewSeatNo(self._mySeatNo), 0, false)
	-- RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY,RoomMsg.ASS_GM_AGREE_GAME);
end

function TableLogic:sendMatch()
	RoomDataManager:SendCoinRoomMatch(g_tableRoomInfo.nRoomType , true)
end

function TableLogic:sendForceQuit(source)
	if RoomLogic:isConnect() then
		self.super.sendForceQuit();
	end

	self._callback:leaveDeskDdz(source);
end

function TableLogic:sendUserUp(source)
	if RoomLogic:isConnect() then
		self.super.sendUserUp();
	end

	self._callback:leaveDeskDdz(source);
end

--多人场下-逻辑位置转视图位置--
function TableLogic:L2V(ViewNo)
    if self:IsMulPlayer() then
        assert(1 <= ViewNo and ViewNo <= 6, "ErrArg:" .. ViewNo)
        self.ViewMap = {}
        local nCount = 0
        for i = 1, 6 do
            local LogicNo = self:viewToLogicSeatNo(i)
            if self:getUserBySeatNo(LogicNo) then
                nCount = nCount + 1
                self.ViewMap[i] = nCount
            end
        end
        return self.ViewMap[ViewNo]
    else
        return ViewNo
    end
end

function TableLogic:getAllViewNo()
    local ViewNos = {}
    for i = 1, 6 do
        local LogicNo = self:viewToLogicSeatNo(i)
        if self:getUserBySeatNo(LogicNo) then
            table.insert(ViewNos, i)
        end
    end
    return ViewNos
end

function TableLogic:getPlayerCount()
    local nCount = 0
    for i = 1, 6 do
        if self:getUserBySeatNo(i) then
            nCount = nCount + 1
        end
    end
    return nCount
end

-- //玩家同意准备消息
function TableLogic:dealUserAgreeResp(agree)
	-- luaDump(agree,"agree")
	luaPrint("-- //玩家同意准备消息")
	if 1 == agree.bAgreeGame then
		local viewSeat = self:logicToViewSeatNo(agree.bDeskStation+1);
		self._callback:playerGetReady(viewSeat, true)
	end
end

-- //发送玩家准备好消息
function TableLogic:sendMsgReady()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

return TableLogic
