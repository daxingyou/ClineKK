local GameLogicBase = class("GameLogicBase")
local GameTableUsersData = require("net.netData.GameTableUsersData")

function GameLogicBase:ctor(tableCallBack, deskNo, bAutoCreate, bMaster, maxPlayerCount)
	self._callback = tableCallBack or nil;--消息回调处理对象
	self._deskNo = deskNo or INVALID_DESKNO;--桌子号
	self._autoCreate = bAutoCreate or false;--是否自动准备
	self._mySeatNo = INVALID_DESKSTATION;--自己的桌子号
	self._bSendLogic = false;--游戏信息是否获取
	self.m_dwTableOwnerIdx = bMaster;--房主ID
	self._maxPlayers = maxPlayerCount or -1;

	self:initData();

	self:start();

	self:loadDeskUsers();
end

function GameLogicBase:initData()
	self._existPlayer = {};--用户是否存在
	luaPrint("self._maxPlayers "..self._maxPlayers)
	for i=1,self._maxPlayers do
		table.insert(self._existPlayer,false);
	end

	self._deskUserList = GameTableUsersData.new(self._deskNo);

	--//创建房间相关信息
	self._nCostID		= 0;						 --//房卡消耗ID
	self._iGameRule		= 0;                         --//gamerule
	self._bAAFanKa		= 0;						 --//是否AA制房卡
	self._nCreatCost	= 0;						 --//创建房间消耗房卡
	self._seatOffset 	= 0;
	self._gameStatus 	= 0;						 --// 游戏状态
	self._waitTime	 	= 0;						 --// 等待时间
	self._watchOther 	= 0;						 --// 允许旁观
end

function GameLogicBase:clear()
	self:stop();

	if self._deskUserList then
		self._deskUserList:clear(true);
	end
end

function GameLogicBase:start()
	self:bindEvent();
end

function GameLogicBase:stop()
	self:unBindEvent();
end

function GameLogicBase:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserSit",function (event) self:I_R_M_UserSit(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GameInfo",function (event) self:I_R_M_GameInfo(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GameBegin",function (event) self:I_R_M_GameBegin(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GamePoint",function (event) self:I_R_M_GamePoint(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GameEnd",function (event) self:I_R_M_GameEnd(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserAgree",function (event) self:I_R_M_UserAgree(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserContest",function (event) self:I_R_M_UserContest(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_ContestNotic",function (event) self:I_R_M_ContestNotic(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_ContestOver",function (event) self:I_R_M_ContestOver(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_ContestKick",function (event) self:I_R_M_ContestKick(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_ContestWaitOver",function (event) self:I_R_M_ContestWaitOver(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GameStation",function (event) self:I_R_M_GameStation(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"onGameMessage",function (event) self:onGameMessage(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GameAllEnd",function (event) self:I_R_M_GameAllEnd(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_NormalTalk",function (event) self:I_R_M_NormalTalk(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserCut",function (event) self:I_R_M_UserCut(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserUp",function (event) self:I_R_M_UserUp(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_DisConnect",function (event) self:I_R_M_DisConnect(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_ContinueNextRound",function (event) self:I_R_M_ContinueNextRound(event) end,"game");
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_DisConnect",function (event) self:I_P_M_DisConnect(event) end);
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_Connect",function (event) self:I_P_M_Connect(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_VoiceTalk",function (event) self:I_R_M_VoiceTalk(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_RecycleDesk",function (event) self:I_R_M_RecycleDesk(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_USERINFO_GET_R",function (event) self:refreshUserInfo(event) end,"game");
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_heart",function (event) self:I_R_M_heart(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_RequestReliefMoney",function (event) self:I_R_M_RequestReliefMoney(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_RequestReliefMoneyResult",function (event) self:I_R_M_RequestReliefMoneyResult(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_SaveScore",function (event) self:I_R_M_SaveScore(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GetScore",function (event) self:I_R_M_GetScore(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserLevelUp",function (event) self:I_R_M_UserLevelUp(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserGetTaskList",function (event) self:I_R_M_UserGetTaskList(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserRewarldRes",function (event) self:I_R_M_UserRewarldRes(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_Taskcount",function (event) self:I_R_M_Taskcount(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_Buymoney",function (event) self:I_R_M_Buymoney(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_RetryMatch",function (event) self:I_R_M_RetryMatch(event) end,"game");
end

function GameLogicBase:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end
    
    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function GameLogicBase:getMySeatNo()
	return self._mySeatNo;
end

function GameLogicBase:getUserId(lSeatNo)
	if INVALID_DESKSTATION == lSeatNo then
		return INVALID_USER_ID;
	end

	if self._deskUserList == nil then
		return INVALID_USER_ID;
	end

	local userInfo = self._deskUserList:getUserByDeskStation(lSeatNo);
	if userInfo == nil then
		return INVALID_USER_ID;
	else
		return userInfo.dwUserID;
	end
end

function GameLogicBase:getlSeatNo(userid)
	return self._deskUserList:getUserByUserID(userid).bDeskStation;
end

function GameLogicBase:getOnlineUserCount()
	return self._deskUserList:getVeortsize();
end

function GameLogicBase:sendGameInfo()
	if self._bSendLogic == false then
		self._bSendLogic = true;
		luaPrint("sendGameInfo");

		local msg = {};
		msg.bEnableWatch = 0;

		RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GM_GAME_INFO,msg, RoomMsg.MSG_GM_S_ClientInfo);
	end
end

function GameLogicBase:sendUserSit(lSeatNo)
	if INVALID_DESKSTATION == lSeatNo then
		return;
	end

	local user = self._deskUserList:getUserByDeskStation(lSeatNo);
	if nullptr ~= userInfo then	
		local tmpSeatNo = lSeatNo;
		
		repeat
			tmpSeatNo = (tmpSeatNo + 1) % self._maxPlayers;
			if self._deskUserList:getUserByDeskStation(lSeatNo) == nil then
				break;
			end
		until (tmpSeatNo == lSeatNo)

		if tmpSeatNo == lSeatNo then
			luaPrint("no empty sit.");
			return;
		else
			lSeatNo = tmpSeatNo;
		end
	end

    local msg = {};
    msg.bDeskIndex = self._deskNo;
    msg.bDeskStation = lSeatNo;
    msg.szPassword = "";

    RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION,RoomMsg.ASS_GR_USER_SIT,sendMsg,RoomMsg.MSG_GR_S_UserSit);
    luaPrint("游戏内发送坐下成功")
end

function GameLogicBase:loadDeskUsers()
	luaPrint("GameLogicBase:loadDeskUsers()")
	for i=1,self._maxPlayers do
		local k = i - 1;
		-- luaDump(self._deskUserList,"self._deskUserList")
		local user = self._deskUserList:getUserByDeskStation(k);
		if user ~= nil then
			if user.dwUserID == PlatformLogic.loginResult.dwUserID then
				self._mySeatNo = user.bDeskStation;
				self._seatOffset = -self._mySeatNo;
			end

			if self._maxPlayers > 0 then
				-- luaPrint("set _existPlayer true")
				self._existPlayer[i] = true;
			end
		else
			-- luaPrint("GameLogicBase:loadDeskUsers() -------- user is nil");
		end
	end

	if self._maxPlayers == -1 then
		local user = self._deskUserList:getUserByUserID(PlatformLogic.loginResult.dwUserID);

		if use ~= nil then
			self._mySeatNo = user.bDeskStation;
		end
	end

	if self._callback and self._callback.updateGameSceneRotation and self._mySeatNo ~= INVALID_DESKSTATION then
		self._callback:updateGameSceneRotation(self._mySeatNo);
	end
end

function GameLogicBase:viewToLogicSeatNo(vSeatNO)
	if vSeatNO == nil or vSeatNO < 0 or vSeatNO >= self._maxPlayers then
		luaPrint("viewToLogicSeatNo vSeatNO is error");
		return;
	end

	return (vSeatNO - self._seatOffset + self._maxPlayers) % self._maxPlayers;
end

function GameLogicBase:logicToViewSeatNo(lSeatNO)
	if lSeatNO == nil or lSeatNO < 0 or lSeatNO >= self._maxPlayers then
		luaPrint("logicToViewSeatNo lSeatNO is error");
		if lSeatNO ~= nil then
			luaPrint("logicToViewSeatNo lSeatNO is "..lSeatNO);
		end
		return -1;
	end

	-- luaPrint("lSeatNO "..lSeatNO.." ,self._seatOffset = "..self._seatOffset.." ,self._maxPlayers = "..self._maxPlayers)
	return (lSeatNO + self._seatOffset + self._maxPlayers) % self._maxPlayers;
end

function GameLogicBase:getUserBySeatNo(lSeatNo)
	-- luaDump(self._deskUserList,"self._deskUserList getUserBySeatNo")
	return self._deskUserList:getUserByDeskStation(lSeatNo);
end

function GameLogicBase:I_R_M_DisConnect(itype)
	-- self._callback:onGameDisconnect();
end

function GameLogicBase:I_P_M_DisConnect()
	PlatformLogic:connect();
end

function GameLogicBase:I_P_M_Connect()
	PlatformLogic:stopListener();
end

function GameLogicBase:I_R_M_Connect(result)

end

--// 用户同意
function GameLogicBase:I_R_M_UserAgree(event)
	local agree = event.data;
	luaDump(agree,"agree");
	luaPrint("self._deskNo --- "..self._deskNo)
	if agree.bDeskNO ~= self._deskNo then 
		return;
	end
	luaPrint("dealUserAgreeResp----")
	self:dealUserAgreeResp(agree);
end

--// 游戏开始
function GameLogicBase:I_R_M_GameBegin(event)
	local bDeskNO = event.deskNo;

	if bDeskNO ~= self._deskNo then 
		return;
	end

	self:dealGameStartResp(bDeskNO);
end

--// 游戏结束
function GameLogicBase:I_R_M_GameEnd(bDeskNO)
	if bDeskNO ~= self._deskNo then 
		return;
	end

	self:dealGameEndResp(bDeskNO);

	self._deskUserList:clear();
end

--// 游戏信息
function GameLogicBase:I_R_M_GameInfo(event)
	local gameInfo = event.object;
	-- luaDump(event,"----")
	-- luaDump(gameInfo);
	-- luaPrint("event.szPwd ="..event.szPw)
	luaPrint("游戏信息获取完毕");

	self._gameStatus = gameInfo.bGameStation;
	self._waitTime   = gameInfo.bWaitTime;
	self._watchOther = gameInfo.bWatchOther;

	self._nCostID = gameInfo.nCostID;
	self._iGameRule = gameInfo.iGameRule;
	self._bAAFanKa = gameInfo.bAAFanKa;
	self._nCreatCost = gameInfo.iCost;

	globalUnit.nowTingId = gameInfo.iGuildId;
	self:dealGameInfoResp(gameInfo);
end

--// 游戏状态
function GameLogicBase:I_R_M_GameStation(event)
	local object = event.object;
	local objectSize = objectSize;

	self:dealGameStationResp(object, objectSize);
end

--// 游戏总结束消息
function GameLogicBase:I_R_M_GameAllEnd(event)

	local Desk_state= event.Desk_state;
	local object = event.object;
	local objectSize = event.objectSize;
	luaDump(object,"event.object====================")
	luaDump(objectSize,"event.objectSize====================")
	luaDump(Desk_state,"event.Desk_state====================")
	self:dealGameAllEnd(object, objectSize,Desk_state);
end

--// 桌子超时
function GameLogicBase:I_R_M_RecycleDesk(event)
	local messageHead = event.messageHead;
	local object = event.object;
	local objectSize = event.objectSize;

	self:dealGameRecycleDesk(object, objectSize)
end

--游戏信息
function GameLogicBase:onGameMessage(event)
	--luaDump(event,"游戏信息onGameMessage")
	local messageHead = event.messageHead;
	local object = event.object;
	local objectSize = event.objectSize;
	luaPrint("GameLogicBase:onGameMessage(messageHead, object, objectSize) ---------")
	self:dealGameMessage(messageHead, object, objectSize);
end

function GameLogicBase:dealGameMessage(messageHead, object, objectSize)

end
--// 结算消息
function GameLogicBase:I_R_M_GamePoint(object, objectSize)

end

--// 排队用户坐下
function GameLogicBase:I_R_M_QueueUserSit(deskNo, users)

end

--// 用户坐下
function GameLogicBase:I_R_M_UserSit(event)
	local userSit = event.data;
	local user = event.user;

	if userSit == nil then 
		return;
	end

	if user == nil then 
		return;
	end

	if userSit.bDeskIndex ~= self._deskNo then 
		return;
	end

	if userSit.bUserState ~= USER_WATCH_GAME then
		if self._maxPlayers > 0 then
			self._existPlayer[userSit.bDeskStation+1] = true;
		end

		if userSit.dwUserID == PlatformLogic.loginResult.dwUserID then
			self._deskNo = userSit.bDeskIndex;
			self._mySeatNo = userSit.bDeskStation;
		end

		if userSit ~= nil then
			if self.m_dwTableOwnerIdx == 0 then
				self.m_dwTableOwnerIdx = userSit.bIsDeskOwner;
			end
		end
		self:dealUserSitResp(userSit, user);
	end
end

--// 用户站起
function GameLogicBase:I_R_M_UserUp(event)
	local userUp = event.data;
	local user = event.user;
	--luaDump(userUp,"数据============");
	--luaDump(user,"数据22222============");
	if userUp.bDeskIndex ~= self._deskNo then
		return;
	end

	if userUp.bUserState ~= USER_WATCH_GAME then
		if self._maxPlayers > 0 then
			self._existPlayer[userUp.bDeskStation+1] = false;
		end
		bIsMe = false;
		if userUp.dwUserID == PlatformLogic.loginResult.dwUserID then
			self._deskNo = INVALID_DESKSTATION;
			-- self._mySeatNo = INVALID_DESKNO;
			bIsMe = true;
		end
		self:dealUserUpResp(userUp,user,bIsMe);
	end
end

--// 用户断线
function GameLogicBase:I_R_M_UserCut(event)
	local dwUserID = event.dwUserID;
	local bDeskNO = event.bDeskNO;
	local bDeskStation = event.bDeskStation;
	
	if bDeskNO ~= self._deskNo then 
		return;
	end

	self:dealUserCutMessageResp(dwUserID, bDeskStation);
end

--// 比赛初始化
function GameLogicBase:I_R_M_ContestInit(contestChange)

end

--//比赛信息广播
function GameLogicBase:I_R_M_ContestNotic(contestInfo)

end

--// 用户比赛信息
function GameLogicBase:I_R_M_UserContest(contestChange)

end

--// 比赛结束
function GameLogicBase:I_R_M_ContestOver(contestAward)

end

--// 比赛淘汰
function GameLogicBase:I_R_M_ContestKick()

end

--// 等待比赛结束
function GameLogicBase:I_R_M_ContestWaitOver()

end

--// 比赛奖励
function GameLogicBase:I_R_M_ContestAwards(awards)

end

--// 报名数量
function GameLogicBase:I_R_M_ContestPeople(contestPeople)

end

--// 个人参赛纪录
function GameLogicBase:I_R_M_ContestRecord(contestRecord)

end

--// 聊天消息
function GameLogicBase:I_R_M_NormalTalk(event)
	local messageHead = event.messageHead;
	local object = event.object;
	local objectSize = event.objectSize;
	self:dealNormalTalk(messageHead,object,objectSize)
end

function GameLogicBase:dealNormalTalk(messageHead,object,objectSize)

 end

--// 聊天消息
function GameLogicBase:I_R_M_VoiceTalk(event)
	local bAssistantID = event.bAssistantID;
	local object = event.object;
	local objectSize = event.objectSize;

	luaDump(event,"聊天消息");

	self:dealVoiceUserChatMessage(bAssistantID, object, objectSize);
end

--//继续下一局
function GameLogicBase:I_R_M_ContinueNextRound(event)
	local bAssist = event.bAssist;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealContinueNextRoundMessage(bAssist, object,objectSize)
end

--救济金请求
function GameLogicBase:I_R_M_RequestReliefMoney(event)
	local bAssist = event.bAssist;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealRequestReliefMoney(object,objectSize)
end

--救济金领取结果
function GameLogicBase:I_R_M_RequestReliefMoneyResult(event)
	local bAssist = event.bAssist;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealRequestReliefMoneyResult(object,objectSize)
end

--存分
function GameLogicBase:I_R_M_SaveScore(event)
	local bAssist = event.bAssist;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameSaveScore(object,objectSize)
end

--取分
function GameLogicBase:I_R_M_GetScore(event)
	local bAssist = event.bAssist;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameGetScore(object,objectSize)
end

--升级
function GameLogicBase:I_R_M_UserLevelUp(event)
	local bAssist = event.bAssist;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameUserLevelUp(object,objectSize)
end

--任务列表
function GameLogicBase:I_R_M_UserGetTaskList(event)
	local messageHead = event.messageHead;
	local code = messageHead.bHandleCode;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameGetTaskList(object,code)
end

--任务奖励
function GameLogicBase:I_R_M_UserRewarldRes(event)
	local messageHead = event.messageHead;
	local code = messageHead.bHandleCode;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameRewarldRes(object,code)
end

--完成任务数量
function GameLogicBase:I_R_M_Taskcount(event)
	local messageHead = event.messageHead;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameTaskcount(object)
end

--充值刷新
function GameLogicBase:I_R_M_Buymoney(event)
	local messageHead = event.messageHead;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameBuymoney(object)
end

function GameLogicBase:I_R_M_RetryMatch(event)
	local messageHead = event.messageHead;
	local object = event.object;
	local objectSize = event.objectSize
	self:dealGameRetryMatch(object)
end

--框架消息处理 begin
function GameLogicBase:dealUserAgreeResp(agree)
	luaPrint("dealUserAgreeResp");
end

function GameLogicBase:dealGameStartResp(bDeskNO)
	luaPrint("dealGameStartResp");
end

function GameLogicBase:dealGameEndResp(bDeskNO)
	luaPrint("dealGameEndResp");
end

function GameLogicBase:dealUserSitResp(userSit, user)
	luaPrint("GameLogicBase:dealUserSitResp");
end

function GameLogicBase:dealQueueUserSitMessage(deskNo,  users)
	luaPrint("dealQueueUserSitMessage");
end

function GameLogicBase:dealUserUpResp(userUp, user, bIsMe)
	luaPrint("dealUserUpResp");
end

function GameLogicBase:dealGameInfoResp(gameInfo)
	luaPrint("GameLogicBase:dealGameInfoResp")
end

function GameLogicBase:dealUserCutMessageResp(userId, seatNo)
	luaPrint("dealUserCutMessageResp");
end

function GameLogicBase:dealGamePointResp(object, objectSize)
	luaPrint("dealGamePointResp");
end

function GameLogicBase:dealUserChatMessage(normalTalk)
	luaPrint("dealUserChatMessage");
end

function GameLogicBase:dealVoiceUserChatMessage(bAssist, object, objetSize)
	luaPrint("dealUserChatMessage");
end

function GameLogicBase:dealContinueNextRoundMessage(bAssist, object, objetSize)
	luaPrint("dealContinueNextRoundMessage");
end

function GameLogicBase:dealGameRecycleDesk(object, objectSize)
	luaPrint("桌子超时..dealGameRecycleDesk");
end

function GameLogicBase:dealGameAllEnd(object, objectSize, game_state)
	luaPrint("dealGameAllEnd");
end

function GameLogicBase:I_R_M_heart(event)
	-- luaPrint("I_R_M_heart")
	self:dealNetHeart();
end

function GameLogicBase:dealNetHeart()
	luaPrint("dealNetHeart");
end

function GameLogicBase:dealRequestReliefMoney(object,objectSize)
	luaPrint("dealRequestReliefMoney");
end

function GameLogicBase:dealRequestReliefMoneyResult(object,objectSize)
	luaPrint("dealRequestReliefMoneyResult");
end

function GameLogicBase:dealGameSaveScore(object,objectSize)
	luaPrint("dealGameSaveScore");
end

function GameLogicBase:dealGameGetScore(object,objectSize)
	luaPrint("dealGameGetScore");
end

function GameLogicBase:dealGameUserLevelUp(object,objectSize)
	luaPrint("dealGameUserLevelUp");
end

function GameLogicBase:dealGameGetTaskList(object,code)
	luaPrint("dealGameGetTaskList");
end

function GameLogicBase:dealGameRewarldRes(object,code)
	luaPrint("dealGameRewarldRes");
end

function GameLogicBase:dealGameTaskcount(object,code)
	luaPrint("dealGameTaskcount");
end

function GameLogicBase:dealGameBuymoney(object,code)
	luaPrint("dealGameBuymoney");
end

function GameLogicBase:dealGameRetryMatch(object)
	luaPrint("dealGameRetryMatch");
end

--框架消息处理 end

function GameLogicBase:sendForceQuit()
	-- RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GM_FORCE_QUIT);
end

function GameLogicBase:sendAgreeGame()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

function GameLogicBase:sendUserUp()
	RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION, RoomMsg.ASS_GR_USER_UP);
end

function GameLogicBase:sendData(MainID, AssistantID, object, objectSize)
	RoomLogic:send(MainID, AssistantID, object, objectSize);
end

function GameLogicBase:sendNextRound()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_CONTINUE_NEXT_ROUND);
end

--//获取是否AA制房卡
function GameLogicBase:getAAFanKa()
	return self._bAAFanKa;
end

--////获取房卡花费
function GameLogicBase:getCreatCost()
	return self._nCreatCost;
end

function GameLogicBase:sendVoiceData(bAssist, object)
	-- luaPrint("发送语音到服务器");
	-- luaDump(object);
	RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, bAssist, object, RoomMsg.MSG_GR_GCloudVoice);
end

function GameLogicBase:refreshUserInfo(event)

end

return GameLogicBase;
