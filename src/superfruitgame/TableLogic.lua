--游戏内消息
local TableLogic = class("TableLogic", require("logic.roomLogic.GameLogicBase"))

TableLogic.FRUIT_TYPE = {
    YINGTAO = 0,--樱桃
    PUTAO = 1,--葡萄
    LINGDANG = 2,--铃铛
    PINGGUO = 3,--苹果
    XIGUA = 4,--西瓜
    NINGMENG = 5,--柠檬
    LIZHI = 6,--荔枝
    CHENGZI = 7,--橙子
    SIYECAO = 8,--四叶草
    BAR = 9,--bar
    QIQIQI = 10,--777
};
TableLogic.FRUIT_TYPE_MIN = 0;
TableLogic.FRUIT_TYPE_MAX = 10;

TableLogic.FruitLineTable = {
    [1] = {2,2,2,2,2},
    [2] = {1,1,1,1,1},
    [3] = {3,3,3,3,3},
    [4] = {1,2,3,2,1},
    [5] = {3,2,1,2,3},
    [6] = {1,1,2,3,3},
    [7] = {3,3,2,1,1},
    [8] = {2,1,2,3,2},
    [9] = {2,3,2,1,2}
};

local FRUIT_LINE_AWARD = {
    [TableLogic.FRUIT_TYPE.YINGTAO] = {0,1,3,10,75},
    [TableLogic.FRUIT_TYPE.PUTAO] = {0,0,3,10,85},
    [TableLogic.FRUIT_TYPE.LINGDANG] = {0,0,15,40,250},
    [TableLogic.FRUIT_TYPE.PINGGUO] = {0,0,25,50,400},
    [TableLogic.FRUIT_TYPE.XIGUA] = {0,0,30,70,550},
    [TableLogic.FRUIT_TYPE.NINGMENG] = {0,0,35,80,650},
    [TableLogic.FRUIT_TYPE.LIZHI] = {0,0,45,100,800},
    [TableLogic.FRUIT_TYPE.CHENGZI] = {0,0,75,175,1250},
    [TableLogic.FRUIT_TYPE.SIYECAO] = {0,0,20,60,1000},
    [TableLogic.FRUIT_TYPE.BAR] = {0,0,25,50,400},
    [TableLogic.FRUIT_TYPE.QIQIQI] = {0,0,100,200,1750},
};

TableLogic._bAutoStart = false;--是否勾选自动开始
TableLogic._nRollFreeTime = 0;--免费次数
TableLogic._tbSmallGameData = nil;--小游戏数据
TableLogic._nSmallGamePoint = 0;--小游戏分数
TableLogic._nPoolPoint = 0;--奖池分数

local function checkObjSize(obj,objSize)
    if getObjSize(obj) == objSize then
        return true
    else
        luaPrint("the TableLogic receive size is error!!!",getObjSize(obj) .. " objSize:" .. objSize)
        return false
    end
end

function TableLogic:ctor(tableCallBack, deskNo, bAutoCreate, bMaster)
	self.super.ctor(self, tableCallBack, deskNo, bAutoCreate, bMaster, PLAY_COUNT);

	self:init();
end

function TableLogic:init()
    self._bAutoStart = false;
    self._nRollFreeTime = 0;
    self._tbSmallGameData = nil;
    self._nSmallGamePoint = 0;
    self._nPoolPoint = 0;
end

--玩家进入游戏调用
function TableLogic:enterGame()
    self:loadUsers();
	self:sendGameInfo();
end

--加载用户
function TableLogic:loadUsers()
	self._callback:setSelfUserInfo();
end

--玩家退出协议
function TableLogic:dealUserUpResp(userUp,user,bIsMe)
	if userUp == nil or user == nil then
		return;
	end
	
	self.super.dealUserUpResp(userUp, user);
	
	local viewseatNo = self:logicToViewSeatNo(userUp.bDeskStation);
	luaPrint("退出消息",viewseatNo,self:getMySeatNo());

	self._callback:removeUser(viewseatNo,bIsMe,userUp.bLock);
end

 --//玩家位置偏移量
function TableLogic:setSeatOffset(seatNo)
    self._seatOffset = -seatNo;
end

function TableLogic:dealGameInfoResp(gameInfo)
	-- self._callback:showDeskInfo(gameInfo);
end

-- //处理游戏消息
function TableLogic:dealGameMessage(messageHead, object, objectSize)

end

--处理游戏分数
function TableLogic:I_R_M_GamePoint(object, objectSize)
	
end

--//游戏状态,桌子超时
function TableLogic:dealGameRecycleDesk(object, objectSize)
	self._callback:dealGameRecycleDesk();
end

-- //处理游戏断线重连,，主要是断线重连来后处理的消息
function TableLogic:dealGameStationResp(object, objectSize)
	local msg = convertToLua(object,GameMsg.tagChongLian);
	luaDump(msg,"场景消息");

    --取消自动开始
    self:setAutoStartBool(false);
    --免费次数
    self:setRollFreeTime(msg.iFreeGame);
    --设置小游戏数据
    if msg.bSmallGame then
        self:setSmallGameData(msg.tbSmallWin,msg.iSmallWinMoney);
    else
        self:setSmallGameData(nil,0);
    end

	self._callback:ReConnectGame(msg);
end

function TableLogic:dealGameChangeMaster(object, objectSize)
  local msg = convertToLua(object, RoomMsg.MSG_Change_Owner);
  self.m_dwTableOwnerIdx = msg.dwUserID;
  self._callback:gameChangeMaster(msg);
end

--有玩家退出(强行退出)
function TableLogic:dealGamePlayerForceQuit(object, objectSize)

end

function TableLogic:dealLeftResult(object, objectSize)
	-- // 校验数据包大小
	if not checkObjSize(GameMsg.LeaveResultStruct, objectSize) then
		luaPrint("LeaveResultStruct size is error");
		return;
	end

	local msg = convertToLua(object, GameMsg.LeaveResultStruct);
	self._callback:gameLeftResult(msg.bDeskStation, msg.bArgeeLeave);
end

-- //处理玩家掉线协议
function TableLogic:dealUserCutMessageResp(userId, seatNo)
	
end

function TableLogic:dealUserCut(object, objectSize)
	-- // 校验数据包大小
	if not checkObjSize(GameMsg.bCutStruct, objectSize) then
		luaPrint("bCutStruct size is error");
		return;
	end

	local msg = convertToLua(object, GameMsg.bCutStruct);
	luaDump(msg,"断线头像处理")
	self._callback:gameUserCut(self:logicToViewSeatNo(msg.bDeskStation), msg.bCut);
end

function TableLogic:getUserHeadId(lSeatNo)
	local seatNo = self:viewToLogicSeatNo(lSeatNo);
	local userInfo = self._deskUserList:getUserByDeskStation(seatNo);

	if userInfo ~= nil then          
		return userInfo.bLogoID;
	end

	return INVALID_USER_ID;
end

function TableLogic:getUserUserId(lSeatNo)
	local seatNo = self:viewToLogicSeatNo(lSeatNo);
	local userInfo = self._deskUserList:getUserByDeskStation(seatNo);

	if userInfo ~= nil then
		return userInfo.dwUserID;
	end

	return INVALID_USER_ID;
end

function TableLogic:dealGameOutSeq(object, objectSize)
  
end

-- //恢复基本的UI，首次进入游戏和断线重连
function TableLogic:resurShowBaseUI(object)
	luaPrint("恢复基本的UI，首次进入游戏和断线重连")
	self:loadUsers();
end

-- //等待同意
function TableLogic:recurGameWaitSet(object)
	
end

-- //玩家同意准备消息
function TableLogic:dealUserAgreeResp(agree)

end

--恢复场景
function TableLogic:recurGamePlaying(object)
	
end

function TableLogic:sendForceQuit(source)
	if RoomLogic:isConnect() then
		self.super.sendForceQuit();
	end

	self._callback:leaveDesk(source);
end

function TableLogic:sendUserUp(source)
	if RoomLogic:isConnect() then
		self.super.sendUserUp();
	else
		self._callback:leaveDesk(source);
	end
end

function TableLogic:dealNetHeart()
	self._callback:gameNetHeart();
end

function TableLogic:getLightLineData(tbFruitData)
    local tbLightLineData = {};--点亮的数据
    local totalMultiples = 0;
    for lineIndex, tbLine in ipairs(self.FruitLineTable) do
        local fruitTable = {};
        for index, fruitNumber in ipairs(tbLine) do
            if tbFruitData[fruitNumber][index] then
                table.insert(fruitTable,tbFruitData[fruitNumber][index]);
            end
        end
        local fruitSameTable = self:getFruitSameData(fruitTable);
        local blight = false;--是否点亮
        local bLightSpecial = false;--是否点亮特殊类型
        local awardMultiples = 0;
        if fruitSameTable.sameNumber >= 2 and fruitSameTable.sameFruit == self.FRUIT_TYPE.YINGTAO then
            --樱桃，大于2即有奖励
            blight = true;
            awardMultiples = FRUIT_LINE_AWARD[fruitSameTable.sameFruit][fruitSameTable.sameNumber];
        elseif fruitSameTable.sameNumber >= 3 and fruitSameTable.sameFruit >= self.FRUIT_TYPE_MIN then
            --其他普通水果，大于3有奖励
            blight = true;
            awardMultiples = FRUIT_LINE_AWARD[fruitSameTable.sameFruit][fruitSameTable.sameNumber];
        end

        local sycNumber = fruitSameTable.sycTable.num;
        local barNumber = fruitSameTable.barTable.num;
        local qqqNumber = fruitSameTable.qqqTable.num;
        if sycNumber >= 3 then
            local tempMultiples = FRUIT_LINE_AWARD[self.FRUIT_TYPE.SIYECAO][sycNumber];
            if tempMultiples > awardMultiples then
                awardMultiples = tempMultiples;
                bLightSpecial = true;
            end
            blight = true;
        elseif barNumber >= 3 then
            local tempMultiples = FRUIT_LINE_AWARD[self.FRUIT_TYPE.BAR][barNumber];
            if tempMultiples > awardMultiples then
                awardMultiples = tempMultiples;
                bLightSpecial = true;
            end
            blight = true;
        elseif qqqNumber >= 3 then
            local tempMultiples = FRUIT_LINE_AWARD[self.FRUIT_TYPE.QIQIQI][qqqNumber];
            if tempMultiples > awardMultiples then
                awardMultiples = tempMultiples;
                bLightSpecial = true;
            end
            blight = true;
        end

        if blight then
            fruitSameTable.bLightSpecial = bLightSpecial;
            tbLightLineData[lineIndex] = fruitSameTable;
            totalMultiples = totalMultiples + awardMultiples;
        end
    end
    return tbLightLineData,totalMultiples;
end

function TableLogic:getFruitSameData(tbFruit)
    if table.nums(tbFruit) ~= 5 then
        return;
    end
    local sameFruit = self.FRUIT_TYPE_MIN-1;--需要相同的水果，特殊的类型不记录
    local sameNumber = 0;--普通水果相同数
    local barTable = {num=0,data={}};--bar特殊处理，需要连续
    local qqqTable = {num=0,data={}};--777特殊处理，需要连续
    local sycTable = {num=0,data={}};--四叶草特殊处理，需要连续

    --判断是否特殊类型
    local checkSpecial = function(nFruit)
        if nFruit == self.FRUIT_TYPE.SIYECAO or nFruit == self.FRUIT_TYPE.QIQIQI or nFruit == self.FRUIT_TYPE.BAR then
            return true;
        end
        return false;
    end

    for index, nFruit in ipairs(tbFruit) do
        --之前可组成连续的普通水果，包括连续的四叶草
        if sameNumber == index - 1 then
            if not checkSpecial(nFruit) then
                --之前出现过普通水果
                if sameFruit >= self.FRUIT_TYPE_MIN then
                    --则要之前的普通水果一样，才可以继续组成连续的普通水果
                    if sameFruit == nFruit then
                        sameNumber = sameNumber + 1;
                    end
                else
                    sameFruit = nFruit;
                    sameNumber = sameNumber + 1;
                end
            elseif nFruit == self.FRUIT_TYPE.SIYECAO then
                sameNumber = sameNumber + 1;
            end
        end
        if nFruit == self.FRUIT_TYPE.BAR and barTable.num == index - 1 then
            barTable.num = barTable.num + 1;
            barTable.data[index] = index;
        elseif nFruit == self.FRUIT_TYPE.QIQIQI and qqqTable.num == index - 1 then
            qqqTable.num = qqqTable.num + 1;
            qqqTable.data[index] = index;
        elseif nFruit == self.FRUIT_TYPE.SIYECAO and sycTable.num == index - 1 then
            sycTable.num = sycTable.num + 1;
            sycTable.data[index] = index;
        end
    end

    --如果最终没有出现连续的普通水果,则普通水果数清零，因为此情况表示为连续的四叶草
    if sameFruit < self.FRUIT_TYPE_MIN then
        sameNumber = 0;
    end

    local resultData = {};
    resultData.sameNumber = sameNumber;
    resultData.sameFruit = sameFruit;
    resultData.sycTable = sycTable;
    resultData.qqqTable = qqqTable;
    resultData.barTable = barTable;
    return resultData;
end

--function TableLogic:getLightLineData(tbFruitData)
--    local tbLightLineData = {};--点亮的数据
--    local maxMultiples = 0;
--    for lineIndex, tbLine in ipairs(self.FruitLineTable) do
--        local fruitTable = {};
--        for index, fruitNumber in ipairs(tbLine) do
--            if tbFruitData[fruitNumber][index] then
--                table.insert(fruitTable,tbFruitData[fruitNumber][index]);
--            end
--        end
--        local fruitSameTable = self:getFruitSameData(fruitTable);
--        local blight = false;--是否点亮
--        local bLightSpecial = false;--是否点亮特殊类型
--        local awardMultiples = 0;
--        if fruitSameTable.sameNumber >= 2 and fruitSameTable.sameFruit == self.FRUIT_TYPE.YINGTAO then
--            --樱桃，大于2即有奖励
--            blight = true;
--            awardMultiples = FRUIT_LINE_AWARD[fruitSameTable.sameFruit][fruitSameTable.sameNumber];
--        elseif fruitSameTable.sameNumber >= 3 and fruitSameTable.sameFruit >= self.FRUIT_TYPE_MIN then
--            --其他普通水果，大于3有奖励
--            blight = true;
--            awardMultiples = FRUIT_LINE_AWARD[fruitSameTable.sameFruit][fruitSameTable.sameNumber];
--        end

--        local sycNumber = fruitSameTable.sycTable.num;
--        local barNumber = fruitSameTable.barTable.num;
--        local qqqNumber = fruitSameTable.qqqTable.num;
--        if sycNumber >= 3 then
--            local tempMultiples = FRUIT_LINE_AWARD[self.FRUIT_TYPE.SIYECAO][sycNumber];
--            if tempMultiples > awardMultiples then
--                awardMultiples = tempMultiples;
--                bLightSpecial = true;
--            end
--            blight = true;
--        elseif barNumber >= 3 then
--            local tempMultiples = FRUIT_LINE_AWARD[self.FRUIT_TYPE.BAR][barNumber];
--            if tempMultiples > awardMultiples then
--                awardMultiples = tempMultiples;
--                bLightSpecial = true;
--            end
--            blight = true;
--        elseif qqqNumber >= 3 then
--            local tempMultiples = FRUIT_LINE_AWARD[self.FRUIT_TYPE.QIQIQI][qqqNumber];
--            if tempMultiples > awardMultiples then
--                awardMultiples = tempMultiples;
--                bLightSpecial = true;
--            end
--            blight = true;
--        end

--        if blight then
--            fruitSameTable.bLightSpecial = bLightSpecial;
--            tbLightLineData[lineIndex] = fruitSameTable;
--            if maxMultiples < awardMultiples then
--                maxMultiples = awardMultiples;
--            end
--        end
--    end
--    return tbLightLineData,maxMultiples;
--end

--function TableLogic:getFruitSameData(tbFruit)
--    if table.nums(tbFruit) ~= 5 then
--        return;
--    end
--    local lastFruit = self.FRUIT_TYPE_MIN-1;
--    local sameFruit = self.FRUIT_TYPE_MIN-1;--需要相同的水果，特殊的类型不记录
--    local sameNumber = 0;--普通水果相同数
--    local barTable = {num=0,data={}};--bar特殊处理，不需要连续
--    local qqqTable = {num=0,data={}};--777特殊处理，不需要连续
--    local sycTable = {num=0,data={}};--四叶草特殊处理，不需要连续

--    --判断是否特殊类型
--    local checkSpecial = function(nFruit)
--        if nFruit == self.FRUIT_TYPE.SIYECAO or nFruit == self.FRUIT_TYPE.QIQIQI or nFruit == self.FRUIT_TYPE.BAR then
--            return true;
--        end
--        return false;
--    end

--    for index, nFruit in ipairs(tbFruit) do
--        --之前可组成连续的普通水果，包括连续的四叶草
--        if sameNumber == index - 1 then
--            if not checkSpecial(nFruit) then
--                --之前出现过普通水果
--                if sameFruit >= self.FRUIT_TYPE_MIN then
--                    --则要之前的普通水果一样，才可以继续组成连续的普通水果
--                    if sameFruit == nFruit then
--                        sameNumber = sameNumber + 1;
--                    end
--                else
--                    sameFruit = nFruit;
--                    sameNumber = sameNumber + 1;
--                end
--            elseif nFruit == self.FRUIT_TYPE.SIYECAO then
--                sameNumber = sameNumber + 1;
--            end
--        end
--        lastFruit = nFruit;
--        if nFruit == self.FRUIT_TYPE.BAR then
--            barTable.num = barTable.num + 1;
--            barTable.data[index] = index;
--        elseif nFruit == self.FRUIT_TYPE.QIQIQI then
--            qqqTable.num = qqqTable.num + 1;
--            qqqTable.data[index] = index;
--        elseif nFruit == self.FRUIT_TYPE.SIYECAO then
--            sycTable.num = sycTable.num + 1;
--            sycTable.data[index] = index;
--        end
--    end

--    --如果最终没有出现连续的普通水果,则普通水果数清零，因为此情况表示为连续的四叶草
--    if sameFruit < self.FRUIT_TYPE_MIN then
--        sameNumber = 0;
--    end

--    local resultData = {};
--    resultData.sameNumber = sameNumber;
--    resultData.sameFruit = sameFruit;
--    resultData.sycTable = sycTable;
--    resultData.qqqTable = qqqTable;
--    resultData.barTable = barTable;
--    return resultData;
--end

function TableLogic:getAutoStartBool()
    return self._bAutoStart;
end

function TableLogic:setAutoStartBool(bAutoStart)
    self._bAutoStart = bAutoStart or false;
end

function TableLogic:getRollFreeTime()
    return self._nRollFreeTime;
end

function TableLogic:setRollFreeTime(nTime)
    self._nRollFreeTime = nTime or 0;
    if self._nRollFreeTime < 0 then
        self._nRollFreeTime = 0;
    end
end

function TableLogic:setSmallGameData(tbData,nPoint)
    self._tbSmallGameData = tbData;
    self._nSmallGamePoint = nPoint;
end

function TableLogic:getSmallGameDataByIndex(nIndex)
    if not self._tbSmallGameData then
        return nil;
    end
    return self._tbSmallGameData[nIndex];
end

function TableLogic:getSmallGamePoint()
    return self._nSmallGamePoint;
end

function TableLogic:setPoolPoint(nPoint)
    self._nPoolPoint = nPoint or 0;
    if self._nPoolPoint < 0 then
        self._nPoolPoint = 0;
    end
end

function TableLogic:updatePoolPointAfterSmallGame()
    self._nPoolPoint = self._nPoolPoint - self._nSmallGamePoint;
    if self._nPoolPoint < 0 then
        self._nPoolPoint = 0;
    end
end

function TableLogic:getPoolPoint(nPoint)
    return self._nPoolPoint;
end

--发送开始
function TableLogic:sendStartRoll(nDeposit)
	luaPrint("发送开始",nDeposit)
	msg = {};
	msg.byDeskStation = 0;
	msg.nDeposit = nDeposit;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_START_ROLL, msg, GameMsg.Cr_Packet_StartGame)
end

--发送小游戏选择
function TableLogic:sendSmallGameSelect(nStep,nPos)
    luaPrint("发送小游戏选择","nStep:",nStep,"nPos:",nPos)
	msg = {};
	msg.nStep = nStep;
	msg.nPos = nPos;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_SMALLGAME_INFO, msg, GameMsg.Cr_Packet_SmallGameSelect)
end

return TableLogic;


