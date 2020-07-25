--游戏内消息
local TableLogic = class("TableLogic", require("logic.roomLogic.GameLogicBase"))

TableLogic.SHZ_TYPE = {
    SHUIHUZHUAN = 0,--水浒传
    ZHONGYITANG = 1,--忠义堂
    TITIANXINGDAO = 2,--替天行道
    SONG = 3,--宋江
    LIN = 4,--林冲
    LU = 5,--鲁智深
    DAO = 6,--刀
    QIANG = 7,--枪
    FU = 8,--斧
    EXIT = 9,--退出
};
TableLogic.SHZ_TYPE_MIN = 0;
TableLogic.SHZ_TYPE_MAX = 8;

TableLogic.FruitLineTable = {
    [1] = {2,2,2,2,2},   
    [2] = {1,1,1,1,1},
    [3] = {3,3,3,3,3},
    [4] = {1,2,3,2,1},
    [5] = {3,2,1,2,3},
    [6] = {1,1,2,1,1},
    [7] = {3,3,2,3,3},    
    [8] = {2,3,3,3,2},
    [9] = {2,1,1,1,2},
};

local SHZ_LINE_AWARD = {
    [TableLogic.SHZ_TYPE.SHUIHUZHUAN] = {0,0,0,0,2000},
    [TableLogic.SHZ_TYPE.ZHONGYITANG] = {0,0,50,200,1000},
    [TableLogic.SHZ_TYPE.TITIANXINGDAO] = {0,0,20,80,400},
    [TableLogic.SHZ_TYPE.SONG] = {0,0,15,40,200},
    [TableLogic.SHZ_TYPE.LIN] = {0,0,10,30,160},
    [TableLogic.SHZ_TYPE.LU] = {0,0,7,20,100},
    [TableLogic.SHZ_TYPE.DAO] = {0,0,5,15,60},
    [TableLogic.SHZ_TYPE.QIANG] = {0,0,3,10,40},
    [TableLogic.SHZ_TYPE.FU] = {0,0,2,5,20},
};

TableLogic._bAutoStart = false;--是否勾选自动开始
TableLogic._nRollFreeTime = 0;--免费次数
TableLogic._tbSmallGameData = nil;--小游戏数据
TableLogic._nSmallCountTotal = 0;--小游戏总次数
TableLogic._nSmallGamePoint = 0;--小游戏分数
TableLogic._nSmallGameBet = 0;--小游戏压分

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
    self._nSmallCountTotal = 0;
    self._nSmallGameBet = 0;
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

    --设置小游戏数据
    if msg.nSmallCount > 0 then
        self:setSmallGameData(msg.tbSmallWin,msg.nSmallCount,msg.iSmallWinMoney,msg.iCellMoney/100);
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
    local mostShzBigThanThreeLine = 0;--水浒传数量大于3的数量最大的一条线
    local shzBigThanThreeNumber = 0;--mostShzBigThanThreeLine该条线上水浒传的个数
    local mostShzLineAward = 0;

    local tbSoundSpecial = {nSoundIndex = 999};

    local tbLightLineData = {};--点亮的数据
    local totalMultiples = 0;
    for lineIndex, tbLine in ipairs(self.FruitLineTable) do
        local fruitTable = {};
        for index, fruitNumber in ipairs(tbLine) do
            if tbFruitData[fruitNumber][index] then
                table.insert(fruitTable,tbFruitData[fruitNumber][index]);
            end
        end
        
        local fruitSameTable = self:getSameDataSingleLine(fruitTable);

        local shzSameNumber = fruitSameTable.shzNumber;--该条线水浒传连续数量

        if shzSameNumber >= 3 and shzSameNumber > shzBigThanThreeNumber then
            mostShzBigThanThreeLine = lineIndex;
            shzBigThanThreeNumber = shzSameNumber;  
        end

        local awardLeft = 0; --倍数
        local awardRight = 0; --倍数
        local blight = false;--是否点亮
        if fruitSameTable.sameNumberLeft >= 3 and fruitSameTable.sameFruitLeft >= 0 then
            blight = true
            awardLeft = SHZ_LINE_AWARD[fruitSameTable.sameFruitLeft][fruitSameTable.sameNumberLeft];
            if fruitSameTable.sameFruitLeft < tbSoundSpecial.nSoundIndex then
                tbSoundSpecial.nSoundIndex = fruitSameTable.sameFruitLeft;
            end
            if mostShzBigThanThreeLine == lineIndex then
                mostShzLineAward = awardLeft;
            end
        end

        if fruitSameTable.sameNumberRight >= 3 and fruitSameTable.sameFruitRight >= 0 then
            blight = true
            awardRight = SHZ_LINE_AWARD[fruitSameTable.sameFruitRight][fruitSameTable.sameNumberRight];
            if fruitSameTable.sameFruitRight < tbSoundSpecial.nSoundIndex then
                tbSoundSpecial.nSoundIndex = fruitSameTable.sameFruitRight;
            end
            if mostShzBigThanThreeLine == lineIndex then
                mostShzLineAward = mostShzLineAward + awardRight;
            end
        end

        if blight then
            tbLightLineData[lineIndex] = fruitSameTable;
            totalMultiples = totalMultiples + awardLeft + awardRight;
        end
    end

    if mostShzBigThanThreeLine > 0 and shzBigThanThreeNumber < 5 then
        totalMultiples = totalMultiples - mostShzLineAward;
    end

    local AllSameawardMultiples = self:getAllSameAwardMultiple(tbFruitData); --检查有无全屏倍数
    totalMultiples = totalMultiples + AllSameawardMultiples;

    return tbLightLineData,totalMultiples,mostShzBigThanThreeLine,tbSoundSpecial,AllSameawardMultiples;
end

function TableLogic:getTotalMultiples()
    
end

function TableLogic:getSameDataSingleLine(fruitTable)
    local tbFruitLeft = {};
    local tbFruitRight = {};
    for i = 1, 5 do
        tbFruitLeft[i] = fruitTable[i];
        tbFruitRight[6-i] = fruitTable[i];
    end

    local resultDataLeft = self:getFruitSameData(tbFruitLeft);
    local resultDataRight = self:getFruitSameData(tbFruitRight);

    local resultData = {};
    resultData.shzNumber = 0;
    resultData.bShzLeft = true;
    if resultDataLeft.shzNumber >= 3 then
        resultData.shzNumber = resultDataLeft.shzNumber;
    elseif resultDataRight.shzNumber >= 3 then
        resultData.shzNumber = resultDataRight.shzNumber;
        resultData.bShzLeft = false;
    end
    resultData.sameNumberLeft = resultDataLeft.sameNumber;
    resultData.sameNumberRight = resultDataRight.sameNumber;
    if resultData.sameNumberLeft >= 5 then
        resultData.sameNumberRight = 0;--如果5个一样，则只算一次
    end
    resultData.sameFruitLeft = resultDataLeft.sameFruit;
    resultData.sameFruitRight = resultDataRight.sameFruit;
    return resultData;
end

function TableLogic:getFruitSameData(tbFruit)
    if table.nums(tbFruit) ~= 5 then
        return;
    end

    local sameFruit = -1;--需要相同的水果，特殊的类型不记录
    local sameNumber = 0;--普通水果相同数
    local shzNumber = 0;--水浒传连续数量

    for index, nFruit in ipairs(tbFruit) do
        --之前是连续的水浒传
        if shzNumber == index - 1 and nFruit == self.SHZ_TYPE.SHUIHUZHUAN then
            shzNumber = shzNumber + 1;
        end

        --之前可组成连续的图形，包括连续的水浒传
        if sameNumber == index - 1 then
            if nFruit == self.SHZ_TYPE.SHUIHUZHUAN then
                sameNumber = sameNumber + 1;
            else
                --之前出现过普通水果
                if sameFruit >= 0 then
                    --则要之前的普通水果一样，才可以继续组成连续的普通水果
                    if sameFruit == nFruit then
                        sameNumber = sameNumber + 1;
                    end
                else
                    sameFruit = nFruit;
                    sameNumber = sameNumber + 1;
                end
            end
        end
    end
   
    --如果最终没有出现连续的普通图形,则普通图形数清零，因为此情况表示为连续的水浒传
    if sameFruit < 0 then
        sameNumber = 0;
    end

    local resultData = {};
    resultData.sameNumber = sameNumber;
    resultData.sameFruit = sameFruit;
    resultData.shzNumber = shzNumber;
    
    return resultData;
end

local SHZ_ALLSAME_AWARD_SINGLE = {
    [TableLogic.SHZ_TYPE.SHUIHUZHUAN] = 5000,
    [TableLogic.SHZ_TYPE.ZHONGYITANG] = 2500,
    [TableLogic.SHZ_TYPE.TITIANXINGDAO] = 1000,
    [TableLogic.SHZ_TYPE.SONG] = 500,
    [TableLogic.SHZ_TYPE.LIN] = 400,
    [TableLogic.SHZ_TYPE.LU] = 250,
    [TableLogic.SHZ_TYPE.DAO] = 150,
    [TableLogic.SHZ_TYPE.QIANG] = 100,
    [TableLogic.SHZ_TYPE.FU] = 50,
};
function TableLogic:getAllSameAwardMultiple(tbFruitData)
    local getTotalType = function(shzType)
        if shzType == self.SHZ_TYPE.FU or shzType == self.SHZ_TYPE.QIANG or shzType == self.SHZ_TYPE.DAO then
            return 1;
        end
        if shzType == self.SHZ_TYPE.LU or shzType == self.SHZ_TYPE.LIN or shzType == self.SHZ_TYPE.SONG then
            return 2;
        end
        return 3;
    end

    local totalType = 0;--大类别，全人物或者全武器使用
    local singleType = -1;
    local bSingle = true;--在大类一致的情况下，小类是否一致

    for i = 1, 3 do
        for j = 1, 5 do
            local shzType = tbFruitData[i][j];
            if singleType < 0 then
                --第一次记录类别
                singleType = shzType;
            end

            local tempTotalType = getTotalType(shzType)
            if totalType == 0 then
                --第一次记录类别
                totalType = tempTotalType;
            end

            --大类不一样，直接返回
            if totalType ~= tempTotalType then
                return 0;
            end

            --大类一致，3特殊处理
            if tempTotalType == 3 then
                --大类为3，必须要一模一样才行
                if singleType ~= shzType then
                    return 0;
                end
            else
                if singleType ~= shzType then
                    bSingle = false;
                end
            end
        end
    end

    local totalMultiple = 0;
    if totalType == 1 then
        totalMultiple = 15;
    elseif totalType == 2 then
        totalMultiple = 50;
    end

    if bSingle then
        if SHZ_ALLSAME_AWARD_SINGLE[singleType] > totalMultiple then
            totalMultiple = SHZ_ALLSAME_AWARD_SINGLE[singleType];
        end
    end
    return totalMultiple;
end

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

function TableLogic:setSmallGameData(tbData,nSmallCount,nPoint,nBetPoint,nBeiShu)
    self._tbSmallGameData = tbData;
    self._nSmallCountTotal = nSmallCount;
    self._nSmallGamePoint = nPoint;
    self._nSmallGameBet = nBetPoint;
    self._nSmallGameBeiShu = nBeiShu;
end

function TableLogic:getSmallGameData()
    return self._tbSmallGameData;
end

function TableLogic:getSmallGameDataByIndex(nIndex)
    if not self._tbSmallGameData then
        return nil;
    end
    return self._tbSmallGameData[nIndex];
end

function TableLogic:getSmallGamePoint()
    return self._nSmallGamePoint*self._nSmallGameBeiShu;
end

function TableLogic:getSmallGameBet()
    return self._nSmallGameBet;
end

function TableLogic:getSmallCountTotal()
    return self._nSmallCountTotal;
end

function TableLogic:setPoolPoint(nPoint)
    self._nPoolPoint = nPoint or 0;
    if self._nPoolPoint < 0 then
        self._nPoolPoint = 0;
    end
end

function TableLogic:updatePoolPointAfterSmallGame()
    luaPrint("self._nPoolPoint",self._nPoolPoint);
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
	luaPrint("发送开始",nDeposit,nMublite)
	msg = {};
	msg.byDeskStation = 0;
	msg.nDeposit = nDeposit/9;
    msg.nMublite = 1;
    luaDump(msg,"发送开始")
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_SHZ_START_ROLL, msg, GameMsg.Cr_Packet_StartGame)
end

--发送小游戏选择
function TableLogic.sendSmallGameSelect(nIndex1,nIndex2)
    luaPrint("发送小游戏选择","nIndex1:",nIndex1,"nIndex2:",nIndex2)
	msg = {};
	msg.nIndex1 = nIndex1;
	msg.nIndex2 = nIndex2;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_SMALLGAME_RESULT, msg, GameMsg.Cr_Packet_SmallGameSelect)
end

--发送请求彩金池数据
function TableLogic:sendGetCaiJinInfoRequest()
    luaPrint("请求彩金池数据");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_JIANGCHI_INFO)
end

--判断小游戏是否结束
function TableLogic:checkSmallGameOver(nGameIndex,nTurnIndex)
    if not self._tbSmallGameData[nGameIndex] then
        return true;
    end
    local tbData = self._tbSmallGameData[nGameIndex];
    local nResultType = tbData.tbResultType[nTurnIndex];
    --最后一次，并且为退出
    if self._nSmallCountTotal == nGameIndex and nResultType == self.SHZ_TYPE.EXIT then
        return true;
    end
    return false;
end

return TableLogic;


