local RoomLogicBase = class("RoomLogicBase")
local roomLogic = require("net.room.RoomLogic")

function RoomLogicBase:ctor(callback)
	self._callback = callback or nil;
	self:init();
end

function RoomLogicBase:init()
	self:initData();
end

function RoomLogicBase:start()
	self:bindEvent();
end

function RoomLogicBase:stop()
	self:unBindEvent();
end

function RoomLogicBase:initData()
	self._roomID = 0;
end

function RoomLogicBase:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_GamePoint",function (event) self:I_R_M_GamePoint(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_ContestNotic",function (event) self:I_R_M_ContestNotic(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_RoomPassword",function (event) self:I_P_M_RoomPassword(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_Connect",function (event) self:I_R_M_Connect(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_RR_M_DisConnect",function (event) self:I_R_M_DisConnect(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_Login",function (event) self:I_R_M_Login(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_LoginFinish",function () self:I_R_M_LoginFinish() end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_MatchDeskFinish",function (event) self:I_R_M_MatchDeskFinish(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_SitError",function (event) self:I_R_M_SitError(event) end,"game");
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_RR_M_UserSit",function (event) self:I_R_M_UserSit(event) end,"game");

	BindTool.register(self, "loginRoom", false)
end

function RoomLogicBase:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
		return;
	end
	
	for _, bindid in pairs(self.bindIds) do
		Event:unRegisterListener(bindid)
	end
end

function RoomLogicBase:requestLogin(roomID)
	local roomInfo = RoomInfoModule:getByRoomID(roomID);
	if roomInfo == nil then
		if self._callback then
			self._callback:onRoomLoginCallback(false, GBKToUtf8("房间Id错误"..tostring(roomID)), self._roomID);
			luaDump(RoomInfoModule:getRoomInfo(),"roomList"..tostring(roomID))
			luaDump(RoomInfoModule._gameRoomList,"_gameRoomList"..tostring(roomID))
			performWithDelay(display.getRunningScene(),function() luaPrint("房间Id错误"..tostring(roomID))  luaPrint(c..d) end,0.2)
		end
	else
		if bit:_and(RoomLogic:getRoomRule(), GRR_CONTEST) or bit:_and(RoomLogic:getRoomRule(), GRR_TIMINGCONTEST) then

		else
			if PlatformLogic.loginResult.i64Money < roomInfo.iLessPoint then
				local buffer = "您的金币小于"..roomInfo.iLessPoint..", 不能进入房间, 请到商店充值。";
				self._callback:onRoomLoginCallback(false, GBKToUtf8(buffer), self._roomID);
				return;
			elseif roomInfo.iMaxPoint ~= 0 and PlatformLogic.loginResult.i64Money > roomInfo.iMaxPoint then
				local buffer = "您的金币大于"..roomInfo.iMaxPoint..", 不能进入房间,超过最大买入。";
				self._callback:onRoomLoginCallback(false, GBKToUtf8(buffer), self._roomID);
				return;
			end
		end

		self._roomID = roomID;

		-- // 连接房间服务器
		UserInfoModule:clear();
		
		if RoomLogic then
			-- RoomLogic:close();
		else
			RoomLogic = roomLogic:getInstance();
		end
		
		RoomLogic:setSelectedRoom(roomInfo);
		RoomLogic:setRoomRule(roomInfo.dwRoomRule);

		-- luaDump(roomInfo,"roomInfo");
		RoomLogic:close();
		-- RoomLogic:connect(roomInfo.szServiceIP,roomInfo.uServicePort)
		RoomLogic:connect(PlatformLogic.ip,PlatformLogic.centerMessage.m_iGameserverPort)
	end
end

function RoomLogicBase:requestSit(deskNo)
	local roomInfo = RoomLogic:getSelectedRoom();
	if roomInfo == nil then
		self._callback:onRoomSitCallback(false, GBKToUtf8("房间信息为空"), self._roomID, deskNo, INVALID_DESKSTATION,false);
		return;
	end

	local deskUsers = {};
	UserInfoModule:findDeskUsers(deskNo, deskUsers);

	local empty = {};
	
	for i=1,roomInfo.uDeskPeople do
		table.insert(empty, true);
	end

	-- // 查找坐下的用户座位号
	for k,user in pairs(deskUsers) do
		if USER_SITTING == user.bUserState			--// 坐下
			or USER_PLAY_GAME == user.bUserState		--// 游戏中
			or USER_CUT_GAME == user.bUserState		--// 断线
			or USER_ARGEE == user.bUserState	then		--// 同意游戏
			empty[user.bDeskStation] = false;
		end
	end

	local seatNo = INVALID_DESKSTATION;
	for k,v in pairs(empty) do
		if v then
			seatNo = i;
			break;
		end
	end

	if INVALID_DESKSTATION ~= seatNo then
		self:requestSit(deskNo, seatNo);
	else
		self._callback:onRoomSitCallback(false, GBKToUtf8("房间没有空座"), self._roomID, deskNo, seatNo,false);
	end
end

function RoomLogicBase:requestSit(deskNo, seatNo)
	local sendMsg = {};
	sendMsg.bDeskIndex = deskNo;
	sendMsg.bDeskStation = seatNo;
	sendMsg.szPassword = "";--GameLogic.getRoomPwd(enterRoom.iRoomID,enterRoom.iDeskID,enterRoom.szLockPass)

	if RoomLogic then
		RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION,RoomMsg.ASS_GR_USER_SIT,sendMsg,RoomMsg.MSG_GR_S_UserSit)
	end	
end

function RoomLogicBase:requestJoinQueue()
	if RoomLogic then
		RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION, RoomMsg.ASS_GR_JOIN_QUEUE);
	end	
end

function RoomLogicBase:requestQuitQueue()
	if RoomLogic then
		RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION, RoomMsg.ASS_GR_QUIT_QUEUE);
	end
end

function RoomLogicBase:requestRoomPasword(roomId, password)
	local sendMsg = {};
	sendMsg.uRoomID = roomId;
	sendMsg.szMD5PassWord = MD5_CTX:MD5String(password);

	if PlatformLogic then
		PlatformLogic:send(PlatformMsg.MDM_GP_LIST, PlatformMsg.ASS_GP_ROOM_PASSWORD, sendMsg, PlatformMsg.MSG_GP_SR_GetRoomStruct);
	end
end

function RoomLogicBase:requestMatchDesk()
	-- //用户ID
	local nUserID = PlatformLogic.loginResult.dwUserID;

	local msg = {};
	msg.dwUserID = PlatformLogic.loginResult.dwUserID;
	msg.iMatchType = globalUnit.mSelectDesk;

	local cf = {
		{"dwUserID","INT"},
		{"iMatchType","INT"}
	}

	if RoomLogic then
		RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf);
		globalUnit.mSelectDesk = 0;
	end
end

-- // 普通聊天
function RoomLogicBase:I_R_M_NormalTalk(object, objectSize)

end

-- // 用户坐下
function RoomLogicBase:I_R_M_UserSit(event)
	local userSit = event.data;
	local user = event.user;
	
	if userSit.dwUserID == PlatformLogic.loginResult.dwUserID and (userSit == nil or user == nil) then
		self._callback:onRoomSitCallback(false, GBKToUtf8("坐下失败"), self._roomID, INVALID_DESKNO, INVALID_DESKSTATION,false);
		RoomLogic:close();
		return;
	end

	-- // 断线重连进来
	if userSit.dwUserID == PlatformLogic.loginResult.dwUserID then
		if INVALID_DESKNO ~= userSit.bDeskIndex and INVALID_DESKSTATION ~= userSit.bDeskStation then
			dispatchEvent("changeMaster",{roomid = self._roomID, bDeskIndex = userSit.bDeskIndex, bDeskStation = userSit.bDeskStation, bIsDeskOwner = userSit.bIsDeskOwner})
			-- self._callback:onRoomSitCallback(true, GBKToUtf8("坐下成功"), self._roomID, userSit.bDeskIndex, userSit.bDeskStation,userSit.bIsDeskOwner);
		end
	end
end

-- // 用户坐下失败
function RoomLogicBase:I_R_M_SitError(message)
	self._callback:onRoomSitCallback(false, message, INVALID_USER_ID, INVALID_DESKNO, INVALID_DESKSTATION,false);
end

-- // 用户排队坐下
function RoomLogicBase:I_R_M_QueueUserSit(deskNo, users)
	if INVALID_DESKNO == deskNo then
		self._callback:onRoomQueueSitCallback(false, GBKToUtf8("座位号错误"), self._roomID, deskNo);
		return;
	end

	local find = false;
	for k,user in pairs(users) do
		if user.dwUserID == PlatformLogic.loginResult.dwUserID then
			find = true;
			break;
		end
	end

	if find then
		self._callback:onRoomQueueSitCallback(true, GBKToUtf8("成功进入游戏"), self._roomID, deskNo);
	else
		self._callback:onRoomQueueSitCallback(false, GBKToUtf8("未发现玩家"), self._roomID, deskNo);
	end
end

-- // 用户站起
function RoomLogicBase:I_R_M_UserUp(userUp, user)
	if INVALID_DESKNO == userUp.bDeskIndex then
		self._callback:onRoomSitUpCallback(false, GBKToUtf8("站起失败"), userUp.bDeskIndex, userUp.bDeskStation);
	else
		self._callback:onRoomSitUpCallback(true, GBKToUtf8("站起成功"), userUp.bDeskIndex, userUp.bDeskStation);
	end
end

-- // 用户断线
function RoomLogicBase:I_R_M_UserCut(dwUserID, bDeskNO, bDeskStation)

end

-- // 断开连接
function RoomLogicBase:I_R_M_DisConnect(itype)
	RoomLogic:close();
	local str = "网络连接失败";
	if itype == nil then
		itype = "未知";
	end
	luaPrint("网络断开连接 err=%d"..itype..",_roomID="..self._roomID);
	if self._callback then
		dispatchEvent("loginRoom")
		-- self:setLoginRoom(false);
		-- self._callback:onRoomDisConnect(GBKToUtf8(str));
	end	
end

-- // 网络连接
function RoomLogicBase:I_R_M_Connect(result)
	if not result then
		if self._callback then
			self._callback:onRoomLoginCallback(false, GBKToUtf8("网络连接失败"), self._roomID);
		end
	else
		local roomInfo = RoomLogic:getSelectedRoom();
		if roomInfo == nil then
			if self._callback then
				self._callback:onRoomLoginCallback(false, GBKToUtf8("房间信息为空"), self._roomID);
			end
		else
			RoomLogic:login(roomInfo.uNameID);
		end
	end
end

-- // 房间登录
function RoomLogicBase:I_R_M_Login(event)
	local success = event.success or false;
	local code = event.code or -1;
	local message = event.message or "";

	luaPrint("房间登陆成功处理")
	luaDump(event,"房间登陆成功处理")
	if not success then
		luaPrint("房间登录 error");
		if self._callback then
			self._callback:onRoomLoginCallback(false, message, self._roomID);
		end
	end
end

-- // 登录完成
function RoomLogicBase:I_R_M_LoginFinish()
	local info = RoomLogic.loginResult.pUserInfoStruct;

	local ret = true
luaDump(info,"I_R_M_LoginFinish")
	if INVALID_DESKNO ~= info.bDeskNO and INVALID_DESKSTATION ~= info.bDeskStation then
		local layer = display.getRunningScene():getChildByName("deskLayer")
		if layer and layer.isClickQuick ~= true then
			ret = false
		end
	else
		ret = false
	end

	if ret then
		luaPrint("坐下成功")
		if self._callback then
			luaPrint("回调坐下成功")
			self._callback:onRoomSitCallback(true, GBKToUtf8("坐下成功"), self._roomID, info.bDeskNO, info.bDeskStation,false);
		end
	else
		luaPrint("连接成功")
		if self._callback then
			self._callback:onRoomLoginCallback(true, GBKToUtf8("连接成功"), self._roomID);
		end
	end
end

-- // 用户进入
function RoomLogicBase:I_R_M_UserCome(user)
	self._callback:onRoomUserCome(user.dwUserID);
end

-- // 用户离开
function RoomLogicBase:I_R_M_UserLeft(user)
	self._callback:onRoomUserLeft(user.dwUserID);
end

-- // 结算消息
function RoomLogicBase:I_R_M_GamePoint(object, objectSize)

end

-- // 房间密码
function RoomLogicBase:I_P_M_RoomPassword(event)
	local ret = event.bRet;
	local roomId = event.uRoomID;
	if self._callback then
		self._callback:onPlatformRoomPassEnter(ret, roomId);
	end	
end

-- //匹配房间成功
function RoomLogicBase:I_R_M_MatchDeskFinish(event)
	local uDeskNO = event.code
	if RoomMsg.ERR_GR_FULL_DESK == uDeskNO then		  --  //桌子已满
		GamePromptLayer:create():showPrompt(GBKToUtf8("匹配人数过多，请稍后重试"));
		return;
	end

	if RoomMsg.ERR_GR_NO_ENOUGH_ROOM_KEY == uDeskNO then	--//玩家钻石数量不足以加入匹配场
		GamePromptLayer:create():showPrompt(GBKToUtf8("金币不足"));
		return;
	end

	if self._callback then
		self._callback:onMatchRoomSuccessful(uDeskNO);
	end
end

return RoomLogicBase
