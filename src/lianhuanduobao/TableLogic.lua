--游戏内消息
local TableLogic = class("TableLogic", require("logic.roomLogic.GameLogicBase"))

TableLogic.SWEET_TYPE = {
    INVALID = 0, --无效
    ORANGE = 1, --橙色糖果
    RED = 2, --红色糖果
    YELLOW = 3,  --黄色糖果
    GREEN = 4,  --绿色糖果
    PURPLE = 5,  --紫色糖果
    PASSSWEET = 6,  --过关糖果
};

TableLogic.SWEET_TYPE_MIN = 0;
TableLogic.SWEET_TYPE_MAX = 7;

TableLogic._bAutoStart = false;--是否勾选自动开始
TableLogic._nRollFreeTime = 0;--免费次数

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

--    --设置小游戏数据
--    if msg.nSmallCount > 0 then
--        self:setSmallGameData(msg.tbSmallWin,msg.nSmallCount,msg.iSmallWinMoney,msg.iCellMoney/100);
--    else
--        self:setSmallGameData(nil,0);
--    end

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

function TableLogic:setPoolPoint(nPointTable)
    self._nPoolPoint = nPointTable or 0;
    for i =1,4 do
        if self._nPoolPoint[i] < 0 then
            self._nPoolPoint[i] = 0;
        end
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
function TableLogic:sendStartRoll(scorePerLine,lineCount)
	luaPrint("发送开始",nDeposit)
	msg = {};
	msg.byDeskStation = 0;
	msg.scorePerLine = scorePerLine;
    msg.lineCount = 1;

	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_START_ROLL, msg, GameMsg.Cr_Packet_StartGame)
end


--发送小游戏
function TableLogic.sendSmallGame()
    luaPrint("发送小游戏")
	msg = {};
    luaDump(GameMsg.ASS_C_SMALLGAME_INFO,"子命令")
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_SMALLGAME_INFO,msg,GameMsg.smallGameStart)
end

--发送保存游戏退出请求
function TableLogic:sendGetCaiJinInfoRequest()
    luaPrint("保存游戏进度退出");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_C_QUIT_WITH_SAVE)
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

