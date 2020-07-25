
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

		luaPrint("self._mySeatNo="..self._mySeatNo)
		if INVALID_DESKSTATION ~= self._mySeatNo and self._autoCreate then
			self:sendGameInfo();
		end
	end
end

--加载用户
function TableLogic:loadUsers()
	local seatNo = INVALID_DESKNO;
	self:loadDeskUsers();
	for i=1,PLAY_COUNT do
    	local k = i -1;

    	local user = self._deskUserList:getUserByDeskStation(k);

	    if self._existPlayer[i] == true and user ~= nil then
	  		luaPrint("TableLogic:loadUsers() ------------ self.m_dwTableOwnerIdx "..self.m_dwTableOwnerIdx.." ,user.dwUserID = "..user.dwUserID)
			self._playerSitted[i] = true;
			seatNo = self:logicToViewSeatNo(k);
			self._callback:addUser(seatNo, k == self._mySeatNo);
			-- self._callback:setUserName(seatNo, user.nickName);
			-- self._callback:showUserMoney(seatNo, true);
			-- self._callback:setUserMaster(seatNo, self.m_dwTableOwnerIdx == user.dwUserID);
			-- --//断线用户显示断线图标
			if USER_CUT_GAME == user.bUserState then
				self._callback:gameUserCut(self:logicToViewSeatNo(user.bDeskStation), true);
			end
		else
			self._playerSitted[i] = false;
			-- seatNo = self:logicToViewSeatNo(k);
			-- self._callback:setUserName(seatNo," ");
			-- self._callback:showUserMoney(seatNo, true);
			-- self._callback:setUserMoney(seatNo, " ");
			-- self._callback:playerGetReady(seatNo, false);
		end
	end
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
	
	if not self._playerSitted[userUp.bDeskStation+1] then
		return;
	end
	self._playerSitted[userUp.bDeskStation+1]=false;
	local seatNo = self:logicToViewSeatNo(userUp.bDeskStation);
	luaPrint("数据================"..seatNo);
	self._callback:removeUser(seatNo, bIsMe,userUp.bLock);
	-- self._callback:setUserName(seatNo," ");
	-- self._callback:showUserMoney(seatNo, false);
	-- self._callback:setUserMoney(seatNo, 0);
	
	-- self._callback:playerGetReady(seatNo, false);
	
end

--//玩家位置偏移量
function TableLogic:setSeatOffset(seatNo)
    self._seatOffset = -seatNo;
end

-- //处理游戏消息
function TableLogic:dealGameMessage(messageHead, object, objectSize)
   
end

-- //处理游戏断线重连,，主要是断线重连来后处理的消息
function TableLogic:dealGameStationResp(object, objectSize)
	luaPrint("处理游戏断线重连dealGameStationResp ="..self._gameStatus)
	self._callback.m_bGameStart = true;
	-- local msg = convertToLua(object,GameMsg.CMD_S_GameStatus);
	self._callback:showGameStatus(object,self._gameStatus)
	
end
-- //处理玩家掉线协议
function TableLogic:dealUserCutMessageResp(userId, seatNo)
	local byView = self:logicToViewSeatNo(seatNo);
	self._callback:onUserCutMessageResp(userId, byView);
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

function TableLogic:sendForceQuit(source)
	if RoomLogic:isConnect() then
		self.super.sendForceQuit();
	end

	--self._callback:leaveDesk(source);
end

function TableLogic:sendUserUp(source)
	if RoomLogic:isConnect() then
		self.super.sendUserUp();
	else
		--self._callback:leaveDesk(source);
	end
end

function TableLogic:dealNetHeart()
	self._callback:gameNetHeart();
end


function TableLogic:dealGamePointResp(object, objectSize)
	self._callback:gamePoint();
end

function TableLogic:dealUserAgreeResp(data)
	if self._callback == nil then
		return;
	end
	self._callback:gameUserAgree(data);
end

function TableLogic:dealGameInfoResp(gameInfo)
  self._callback:showDeskInfo(gameInfo);
end

--充值刷新
function TableLogic:dealGameBuymoney(msg)
	-- self._callback:gameBuymoney(object);
	luaDump(msg,"dealGameBuymoney");

	local realSeat = self:getlSeatNo(msg.UserID);
	local vSeatNo = self:logicToViewSeatNo(realSeat);
	
	self._callback:setUserMoney(msg.score,vSeatNo+1);
end

-- //发送玩家准备好消息
function TableLogic:sendMsgReady()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

return TableLogic;


