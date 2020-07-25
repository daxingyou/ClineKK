--游戏内消息
local TableLogic = class("TableLogic", require("logic.roomLogic.GameLogicBase"))

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
	self._playerSitted = {};--是否已坐下

	for i=1,PLAY_COUNT do
		table.insert(self._playerSitted, false);
	end
end

--玩家进入游戏调用
function TableLogic:enterGame()
	if INVALID_DESKSTATION == self._mySeatNo and not self._autoCreate then
    luaPrint("玩家进入游戏调用 self._mySeatNo "..self._mySeatNo)
		for i=1,PLAY_COUNT do
			local k = i -1;
			if not self._existPlayer[i] then
				--发送坐下命令
				self:sendUserSit(self:logicToViewSeatNo(k));
				break;
			end
		end
	else
		luaPrint("TableLogic:enterGame() --------- self._mySeatNo ="..self._mySeatNo.." self._autoCreate = "..tostring(self._autoCreate));
		self:loadUsers();

		if INVALID_DESKSTATION ~= self._mySeatNo and self._autoCreate then
			self:sendGameInfo();
		end
	end
end

--加载用户
function TableLogic:loadUsers()
	luaPrint("loadUsers---");
	-- local seatNo = INVALID_DESKNO;
	-- self:loadDeskUsers();
	-- --加载玩家信息
	self._callback:showPlayerInfo();
	local seatNo = INVALID_DESKNO;
	self:loadDeskUsers();
	for i=1,PLAY_COUNT do
    	local k = i -1;

    	local user = self._deskUserList:getUserByDeskStation(k);

	    if self._existPlayer[i] == true and user ~= nil then
	  		--luaPrint("TableLogic:loadUsers() ------------ self.m_dwTableOwnerIdx "..self.m_dwTableOwnerIdx.." ,user.dwUserID = "..user.dwUserID)
			self._playerSitted[i] = true;
			seatNo = self:logicToViewSeatNo(k);
			self._callback:addUser(seatNo, k == self._mySeatNo);
			--self._callback:setUserName(seatNo, user.nickName);
			--self._callback:showUserMoney(seatNo, true);
			--self._callback:setUserMaster(seatNo, self.m_dwTableOwnerIdx == user.dwUserID);
			--//断线用户显示断线图标
			-- if USER_CUT_GAME == user.bUserState then
			-- 	self._callback:gameUserCut(self:logicToViewSeatNo(user.bDeskStation), true);
			-- end
		else
			self._playerSitted[i] = false;
			seatNo = self:logicToViewSeatNo(k);
			--self._callback:setUserName(seatNo," ");
			--self._callback:showUserMoney(seatNo, true);
			--self._callback:setUserMoney(seatNo, " ");
			--self._callback:playerGetReady(seatNo, false);
		end
	end
end

--//玩家坐下协议,父类方法
function TableLogic:dealUserSitResp(userSit, user)
	luaPrint("坐下消息");
	if userSit == nil or user == nil then
        return;
    end

    local seatNo = self:logicToViewSeatNo(userSit.bDeskStation);
    local isMe = (user.dwUserID == PlatformLogic.loginResult.dwUserID);

    if isMe then
		self:loadDeskUsers();
		self:setSeatOffset(userSit.bDeskStation);
		luaPrint("自己//玩家坐下协议,父类方法")
		self:loadUsers();
		self:sendGameInfo();
    else
    	luaPrint("其他玩家坐下userSit.bDeskStation == "..userSit.bDeskStation)
        if self._playerSitted[userSit.bDeskStation+1] then 
        	return;
        end

        self._playerSitted[userSit.bDeskStation+1] = true;
        self._callback:addUser(seatNo, userSit.bDeskStation == self._mySeatNo);
        --self._callback:setUserName(seatNo, user.nickName);
        --self._callback:showUserMoney(seatNo, true);
    end

    luaPrint("游戏内坐下 设置房主")
    --self._callback:setUserMaster(seatNo, userSit.dwUserID == self.m_dwTableOwnerIdx);
end

--玩家退出协议
function TableLogic:dealUserUpResp(userUp,user,bIsMe)
	if userUp == nil or user == nil then
		return;
	end
	
	self.super.dealUserUpResp(userUp, user);
	
	if not self._playerSitted[userUp.bDeskStation+1] then
		return;
	end
	self._playerSitted[userUp.bDeskStation+1]=false;
	local seatNo = self:logicToViewSeatNo(userUp.bDeskStation);
	luaPrint("数据================"..seatNo);
	--self._callback:setUserName(seatNo," ");
	--self._callback:showUserMoney(seatNo, false);
	--self._callback:setUserMoney(seatNo, 0);
	self._callback:removeUser(seatNo, bIsMe,userUp.bLock);
	--self._callback:playerGetReady(seatNo, false);
end

 --//玩家位置偏移量
function TableLogic:setSeatOffset(seatNo)
    self._seatOffset = -seatNo;
end

function TableLogic:dealGameInfoResp(gameInfo)
	-- self._callback:showDeskInfo(gameInfo);
end

-- //发送玩家准备好消息
function TableLogic:sendMsgReady()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

-- //处理游戏消息
function TableLogic:dealGameMessage(messageHead, object, objectSize)
  --   if messageHead == nil or object == nil then
		-- luaPrint("messageHead is nil or object is nil");
		-- return;
  --   end

  --   local bAssistantID = messageHead.bAssistantID;

  --   if bAssistantID ~= 110 and bAssistantID ~= 102 then
  --   	luaPrint("TableLogic:dealGameMessage messageHead.bMainID = "..messageHead.bMainID.."  bAssistantID = "..bAssistantID)
  --   end    

  --   -- //游戏消息
  --   if RoomMsg.MDM_GM_GAME_NOTIFY ~= messageHead.bMainID then
		-- return;
  --   end

  --   if bAssistantID == RoomMsg.ASS_GM_AGREE_GAME then--//有玩家同意游戏
		-- luaPrint("ASS_GM_AGREE_GAME");
		-- self:dealGamePlayerAgree(object, objectSize);
  --   elseif bAssistantID == GameMsg.ASS_HAVE_THING then--有事请求离开
		-- luaPrint("dealHaveOut");
		-- self:dealHaveThing(object, objectSize);
  --   elseif bAssistantID == GameMsg.ASS_LEFT_RESULT then--（服务器回复数据告诉我是否可以离开）
		-- luaPrint("dealLeftResult");
		-- self:dealLeftResult(object, objectSize);
  --   elseif bAssistantID == GameMsg.ASS_USER_CUT then
		-- luaPrint("dealUserCut");
		-- self:dealUserCut(object, objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_GPS then--游戏定位
		-- luaPrint("SUB_S_GPS");
		-- self:dealGameBaiDuResult(object, objectSize);
  --   elseif bAssistantID == RoomMsg.ASS_GR_CHANGE_OWNER then--变更房主
		-- luaPrint("ASS_GR_CHANGE_OWNER")
		-- self:dealGameChangeMaster(object, objectSize);
  --   elseif bAssistantID == RoomMsg.ASS_GR_USERINFO_GET then
  --   	self:refreshUserInfo(object, objectSize)
  --   --捕鱼协议
  --   elseif bAssistantID == GameMsg.SUB_S_GAME_CONFIG then--游戏配置
  --   	luaPrint("SUB_S_GAME_CONFIG");
  --   	self:dealGameConfig(object, objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_FISH_TRACE then--出鱼
  --   	-- luaPrint("SUB_S_FISH_TRACE")
  --   	self:dealGameNewFish(object, objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_EXCHANGE_FISHSCORE then--鱼分兑换
  --   	luaPrint("SUB_S_EXCHANGE_FISHSCORE")
  --   	self:dealGameFishScore(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_USER_FIRE then--用户发炮
  --   	-- luaPrint("SUB_S_USER_FIRE")
  --   	self:dealGameUserFire(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_CATCH_FISH then--用户碰撞鱼
  --   	-- luaPrint("SUB_S_CATCH_FISH")
  --   	self:dealGameCatchFish(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_BULLET_ION_TIMEOUT then--能量炮
  --   	luaPrint("SUB_S_BULLET_ION_TIMEOUT")
  --   	self:dealGameEnergyCannon(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_LOCK_TIMEOUT then--锁定过期
  --   	luaPrint("SUB_S_LOCK_TIMEOUT")
  --   	self:dealGameLockFish(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_CATCH_SWEEP_FISH then--炸弹鱼碰撞
  --   	luaPrint("SUB_S_CATCH_SWEEP_FISH")
  --   	self:dealGameCatchSweepFish(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_CATCH_SWEEP_FISH_RESULT then--炸弹鱼捕获结果
  --   	luaPrint("SUB_S_CATCH_SWEEP_FISH_RESULT")
  --   	self:dealGameCatchSweepFishResult(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_HIT_FISH_LK then--李逵碰撞
  --   	-- luaPrint("SUB_S_HIT_FISH_LK")
  --   	self:dealGameHitFishLk(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SWITCH_SCENE then--鱼阵
  --   	luaPrint("SUB_S_SWITCH_SCENE")
  --   	self:dealGameSwichScene(object, objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_STOCK_OPERATE_RESULT then--库存操作
  --   	luaPrint("SUB_S_STOCK_OPERATE_RESULT")
  --   	self:dealGameStockOperate(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SCENE_END then--特殊场景结束
  --   	luaPrint("SUB_S_SCENE_END")
  --   	self:dealGameSceneEnd(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SEND_BIRD_ANDROID then--机器人
  --   	luaPrint("SUB_S_SEND_BIRD_ANDROID")
  --   	self:dealGameRoot(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_MESSAGE then--发送消息
  --   	luaPrint("SUB_S_MESSAGE")
  --   	self:dealGameGameMessage(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SEND_RESULT then--结算消息
  --   	luaPrint("SUB_S_SEND_RESULT")
  --   	self:dealGameResultMessage(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SEND_TIME then--同步时间
  --   	luaPrint("SUB_S_SEND_TIME")
  --   	self:dealGameUpdataTimeRes(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SEND_ONLINEREWARD then--领取在线奖励
  --   	luaPrint("SUB_S_SEND_ONLINEREWARD")
  --   	self:dealGameRewarldOnlineRes(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SEND_SWITCH then
  --   	luaPrint("SUB_S_SEND_SWITCH");
  --   	self:dealGameStartSwitch(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_MATCH_END then
  --   	luaPrint("SUB_S_MATCH_END");
  --   	self:dealGameMatchEnd(object,objectSize);
  --   elseif bAssistantID == GameMsg.SUB_S_SEND_NO_SCORE then
  --   	luaPrint("SUB_S_SEND_NO_SCORE");
  --   	self:dealGameMatchWriteScore(object,objectSize);
  --   end
end

--//游戏状态,桌子超时
function TableLogic:dealGameRecycleDesk(object, objectSize)
	self._callback:dealGameRecycleDesk();
end

-- //处理游戏断线重连,，主要是断线重连来后处理的消息
function TableLogic:dealGameStationResp(object, objectSize)
	self._callback:showGameBegin();
	luaPrint("dealGameStationResp",self._gameStatus,GameMsg.GS_FREE,GameMsg.GS_PLAYING);
	--luaDump(self._deskUserList,"玩家信息1");
	if self._gameStatus == GameMsg.GS_FREE then--//空闲状态
    	local msg = convertToLua(object,GameMsg.CMD_S_StatusFree);
    	luaDump(msg,"场景消息CMD_S_StatusFree");
    	self:gameStationFree(msg);--空闲状态
	else --游戏状态
		local msg = convertToLua(object,GameMsg.CMD_S_StatusPlay);
		luaDump(msg,"场景消息CMD_S_StatusPlay");
		self:gameStationPlaying(msg);----游戏状态
		if self._gameStatus == GameMsg.GS_PLAYING then
			self._callback:judgeGame(msg);
		end
	end

end

--空闲状态
function TableLogic:gameStationFree(msg)
	self._callback:dealGameStationFree(msg);
end

--游戏状态
function TableLogic:gameStationPlaying(msg)
	self._callback:dealGameStationPlaying(msg);

end

function TableLogic:dealGameStartResp(bDeskNO)

end

--//游戏开始
function TableLogic:dealGameBeginResp(object, objectSize)
	self._callback:showGameBegin();

	self._callback:SYnum();
	self:setCurrentStation(GameMsg.GS_PLAYING);

	for i=1,PLAY_COUNT do
		local byView = self:logicToViewSeatNo(i-1);  
		self._callback:playerGetReady(byView, false, 0);
	end

	self._callback:updateReady();

	self._callback.m_bGameStart = true;

	if self.isSceneMessage == true then
		--游戏页面展示 切牌
		local msg = convertToLua(object, GameMsg.CMD_S_GameStart);
		self._callback:gameUserQiePaiDeal(msg);
	end
end

function TableLogic:dealGameActResult(object, objectSize)
	self:setCurrentStation(GameMsg.GS_FREE);
	local msg = convertToLua(object, GameMsg.CMD_S_GameEnd);

	self._callback:saveSouce(msg);
end

--服务器报告游戏结束
function TableLogic:dealGameAllEnd(object, objectSize, game_state)
	local msg = convertToLua(object, RoomMsg.Game_StatisticsMessage);
	self._callback:gameAllEnde(msg,objectSize, game_state);  
end

-- //语音聊天消息
function TableLogic:dealVoiceUserChatMessage(bAssist, object, objetSize)
	if nil == object or objetSize < 0 then
		luaPrint("dealVoiceUserChatMessage   error");
		return;
	end

	if bAssist == RoomMsg.ASS_VOICE_CHAT_MSG_FINISH then
		self._callback:receiveVoiceChagMsg(object, objetSize, true);
	elseif bAssist == RoomMsg.ASS_VOICE_CHAT_MSG then
		self._callback:receiveVoiceChagMsg(object, objetSize, false);
	end
end

--百度定位
function TableLogic:dealGameBaiDuResult(object, objectSize)
	local msg = convertToLua(object, GameMsg.CMD_S_GPS);
	luaPrint("TableLogic:dealGameBaiDuResult")
	self._callback:gameBaiduLocation(msg);
end

function TableLogic:dealGameChangeMaster(object, objectSize)
  local msg = convertToLua(object, RoomMsg.MSG_Change_Owner);
  self.m_dwTableOwnerIdx = msg.dwUserID;
  self._callback:gameChangeMaster(msg);
end

--有玩家退出(强行退出)
function TableLogic:dealGamePlayerForceQuit(object, objectSize)

end

--有事请求离开
function TableLogic:dealHaveThing(object, objectSize)
  -- // 校验数据包大小
	if not checkObjSize(GameMsg.HaveThingStruct, objectSize) then
		luaPrint("HaveThingStruct size is error");
		return;
	end

	luaPrint("--有事请求离开 ");
	local msg = convertToLua(object, GameMsg.HaveThingStruct);
	self._callback:showHaveThing(msg);
end

--（服务器回复数据告诉我是否可以离开）
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
	local byView = self:logicToViewSeatNo(seatNo);
	--self._callback:onUserCutMessageResp(userId, byView);
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
  self._resultSave = object;

  self._resultSaveLen = objectSize;
end

-- //恢复基本的UI，首次进入游戏和断线重连
function TableLogic:resurShowBaseUI(object)
	luaPrint("恢复基本的UI，首次进入游戏和断线重连")
	self:loadUsers();
end

-- //等待同意
function TableLogic:recurGameWaitSet(object)
	local gsBase = convertToLua(object,GameMsg.CMD_S_StatusFree)

	-- luaDump(gsBase,"gsBase");
	self:setCurrentStation(GameMsg.GS_FREE);

	self._callback:initSceneBtn(gsBase);

	if gsBase.m_LastGameInfo.bGameEnd == true then
		self._callback.recurFreeData = gsBase;
		--重置按钮状态
		for i=1, PLAY_COUNT do
			local byView = self:logicToViewSeatNo(i-1);
			self._callback:recurPlayerGetReady(byView, gsBase.bReply[i]);
		end

		self._callback:delayPlayCompareCardAnimation(gsBase.m_LastGameInfo, true);

		if gsBase.bReply[self._mySeatNo] == false then
			self._callback:showWaitNextRoundPromt();
		end

		-- self._callback:saveSouce(gsBase.m_LastGameInfo, self._resultSave, self._resultSaveLen);    
		self._resultSave = nil;
		self._resultSaveLen = 0;
	else
		for i=1, PLAY_COUNT do
			local byView = self:logicToViewSeatNo(i-1);
			-- //玩家准备
			luaPrint("等待同意 ------ byView "..byView.." , gsBase.bAgree[i] "..tostring(gsBase.bAgree[i]))
			self._callback:playerGetReady(byView, gsBase.bAgree[i]);
			end

			self._callback:gameStartShowReady(PokerCommonDefine.Poker_Seat_Mark.Poker_South, gsBase.bAgree[self:viewToLogicSeatNo(PokerCommonDefine.Poker_Seat_Mark.Poker_South) + 1]);

		if self:getTableOwnerId() == PlatformLogic.loginResult.dwUserID then
			if gsBase.bAgentRoom ~= true then
				self:sendMsgReady();
			end
		end
	end

	self._callback:updateGameInfoFree(gsBase);
end

-- //玩家同意准备消息
function TableLogic:dealUserAgreeResp(agree)
	-- luaDump(agree,"agree")
	luaPrint("-- //玩家同意准备消息")
	if 1 == agree.bAgreeGame then
		local seatNo = self:logicToViewSeatNo(agree.bDeskStation);
		self._callback:playerGetReady(seatNo, true);
		self._callback:gameStartShowReady(seatNo, true);
	end
end

--恢复场景
function TableLogic:recurGamePlaying(object)
	self:setCurrentStation(GameMsg.GS_PLAYING);

	for i=1,PLAY_COUNT do
		local byView = self:logicToViewSeatNo(i-1);  
		self._callback:playerGetReady(byView, false);
	end

	self._callback.Button_ready:setVisible(false);

	luaPrint("PLAY_COUNT =---恢复场景------=   "..PLAY_COUNT);

	local msg = convertToLua(object,GameMsg.CMD_S_StatusPlay)

	self._callback:initSceneBtn(msg);

	-- luaDump(msg,"恢复场景recurGamePlaying")

	PokerModule.m_curUser = msg.wCurrentUser;

	PokerModule.m_byHandCard[self._mySeatNo] = msg.cbHandCardData;

	PokerModule.m_recurGameData = msg;

	self._callback:updateGameInfo();

	-- //房间解散结果处理
	if msg.bArgeeLeave ~= -1 then
		self._callback:gameRecurLeftResult(0, msg.bArgeeLeave);
	end
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

function TableLogic:playing()
	return self._gameStatus == GameMsg.GS_PLAYING;
end

function TableLogic:getTableOwnerId()
	return self.m_dwTableOwnerIdx;
end

-- //设置当前游戏状态
function TableLogic:setCurrentStation(byGameStation)
	PokerModule.m_byGameStation = byGameStation;
	self._gameStatus = byGameStation;
end

--发送聊天消息
function TableLogic:sendChatMsg(nIndex,msg,userInfo)
    -- {"crColor","UINT"},         --字体颜色
    -- {"iLength","WORD"},         --信息长度
    -- {"dwSendID","INT"},         --用户 ID
    -- {"dwTargetID","INT"},       --目标 ID
    -- {"nDefaultIndex","INT"},    --=0，输入的内容，>0，选择的内容
    -- {"szMessage","CHARSTRING[501]"},  --聊天内容
    --doby
    -- local userInfo = self:getUserBySeatNo(self:getMySeatNo());
    local data = {}
    data.crColor = 1
    data.dwTargetID = userInfo.dwUserID
    data.dwSendID = userInfo.dwUserID
    data.iLength = string.len(msg)
    data.nDefaultIndex = nIndex
    data.szMessage = msg
    -- luaDump(data)
    RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_GM_NORMAL_TALK,data,RoomMsg.MSG_GR_RS_NormalTalk)
end

--// 聊天消息
function TableLogic:dealNormalTalk(messageHead,msg,objectSize)
	luaPrint("有人发聊天消息了，到游戏里面了")
	self._callback:showUserChatMsg(msg.nDefaultIndex, msg.szMessage,msg)
end

function TableLogic:refreshUserInfo(object, objectSize)
  local msg = convertToLua(object, RoomMsg.MSG_GR_USERINFO);
  self._callback:refreshUserInfo(msg);
end

function TableLogic:dealNetHeart()
	self._callback:gameNetHeart();
end

function TableLogic:gameChangeMaster(msg)
	local deskNo = msg.bDeskIndex;
	if deskNo ~= self._deskNo then
		return;
	end

	self.m_dwTableOwnerIdx = msg.bIsDeskOwner;
end


--服务端 start
--游戏配置
function TableLogic:dealGameConfig(object, objectSize)
	local msg = convertToLua(object, GameMsg.CMD_S_GameConfig);

	-- luaDump(msg,"游戏配置");
	FishModule.m_gameFishConfig = msg;
	--刷新玩家炮倍
	self._callback:refreshFortMultip(msg);

	if FishModule.m_gameSceneData ~= nil then
		self._callback.m_bGameStart = true;
	end
end


--服务端 end

--客户端命令 start
-- 鱼分兑换
function TableLogic:sendFishScoreExchange(isAdd)
	local msg = {};
	msg.increase = isAdd;

	-- RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_EXCHANGE_FISHSCORE, msg, GameMsg.CMD_C_ExchangeFishScore);
end


--// 结算消息
function TableLogic:I_R_M_GamePoint(msg)
	--luaDump(msg,"I_R_M_GamePoint");
	self._callback:flushOtherMsg(msg);
end

function TableLogic:dealGameBuymoney(msg)
	luaDump(msg,"dealGameBuymoney");
	if msg.UserID == PlatformLogic.loginResult.dwUserID then
		self._callback:Baoxian(msg);
	end
end


--客户端命令 end

return TableLogic;


