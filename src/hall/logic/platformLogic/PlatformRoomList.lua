local PlatformRoomList = class("PlatformRoomList")

function PlatformRoomList:ctor(callback)
	self.callback = callback or nil;
end

function PlatformRoomList:start()
	self:bindEvent();
end

function PlatformRoomList:stop()
	self:unBindEvent();
end

function PlatformRoomList:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_RoomUserCount",function () self:I_P_M_RoomUserCount() end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_RoomList",function () self:I_P_M_RoomList() end);
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_SitError",function () self:I_R_M_SitError() end);
end

function PlatformRoomList:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end
    
    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function PlatformRoomList:requestRoomList()
	local gameNameID = GameCreator:getCurrentGameNameID();
	local gameKindID = GameCreator:getCurrentGameKindID();

	luaPrint("requestRoomList -------------------  %d ,   %d", gameNameID, gameKindID);

	if 0 == gameKindID or -1 == gameKindID then
		if self.callback then
			self.callback:onPlatformRoomListCallback(false, GBKToUtf8("游戏id或kindid错误"));				
		end
		return;
	end

	RoomInfoModule:clear();
	PlatformLogic:getRoomList(gameKindID, gameNameID);
end

function PlatformRoomList:requestRoomLogin()
	self:roomRequestLogin();
end

function PlatformRoomList:roomRequestLogin()
	local roomInfo = RoomLogic:getSelectedRoom();
	RoomLogic:connect(roomInfo.szServiceIP, roomInfo.uServicePort);
end

--// 房间列表
function PlatformRoomList:I_P_M_RoomList()
	if self.callback then
		self.callback:onPlatformRoomListCallback(true, GBKToUtf8("获取成功"));
	end
end

--// 房间人数
function PlatformRoomList:I_P_M_RoomUserCount(event)
	if event == nil then
		return;
	end
	
	local roomID = event.roomID;
	local count = event.peopleCount + event.virtualCount;

	if self.callback then
		self.callback:onPlatformRoomUserCountCallback(roomID, count);
	end
end

-- // 用户坐下
function PlatformRoomList:I_R_M_UserSit(event)
	local userSit = event.userSit or nil;
	local user = event.user or nil;
	if userSit == nil or user == nil then
		return;
	end

	if INVALID_DESKNO ~= userSit.bDeskIndex and INVALID_DESKSTATION ~= userSit.bDeskStation then
		if self.callback then
			self.callback:onRoomSitCallback(true, GBKToUtf8("坐下成功"), userSit.dwUserID, userSit.bDeskIndex, userSit.bDeskStation, userSit.bIsDeskOwner);
		end
			
		return;
	end
end

-- // 用户坐下失败
function PlatformRoomList:I_R_M_SitError(message)
	if self.callback then
		self.callback:onRoomSitCallback(false, message, INVALID_USER_ID, INVALID_DESKNO, INVALID_DESKSTATION,false);
	end
end

return PlatformRoomList
