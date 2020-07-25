local RoomDeskLogic = class("RoomDeskLogic")

function RoomDeskLogic:ctor(callback)
	self.callback = callback or nil;
end

function RoomDeskLogic:initData()
	self._roomID = 0;
end

function RoomDeskLogic:start()
	self:bindEvent();
end

function RoomDeskLogic:stop()
	self:unBindEvent();
end

function RoomDeskLogic:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_UserSit",function (event) self:I_R_M_UserSit(event) end,"game");
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_R_M_SitError",function (event) self:I_R_M_SitError(event) end,"game");    
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_RoomList",function (event) self:I_P_M_RoomList(event) end);
end

function RoomDeskLogic:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end

    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function RoomDeskLogic:requestSit(deskNo, password)
	password = password or "";

	local roomInfo = RoomLogic:getSelectedRoom();
	if roomInfo == nil then
		if self.callback then
			self.callback:onRoomSitCallback(false, GBKToUtf8("房间信息为空"), self._roomID, deskNo, INVALID_DESKSTATION,false);
			return;
		end
	end

		-- local deskUsers = UserInfoModule:findDeskUsers(deskNo);

		-- std::vector<bool> empty(pRoomInfo->uDeskPeople, true);

	-- // 服务器请求位置
	luaPrint("桌子请求位置 -- password "..password)
	self:requestSitBySeatNo(deskNo, INVALID_DESKSTATION, password);
end

function RoomDeskLogic:requestSitBySeatNo(deskNo, seatNo, password)
	luaPrint("password -------------- "..password)
	local data = {};
	data.bDeskIndex   = deskNo;
	data.bDeskStation = seatNo;
	data.szPassword = password;

	RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION, RoomMsg.ASS_GR_USER_SIT, data ,RoomMsg.MSG_GR_S_UserSit);
end

-- // 用户坐下
function RoomDeskLogic:I_R_M_UserSit(event)
	local userSit = event.data;
	local user = event.user;

	if userSit == nil or user == nil then
		return;
	end

	luaPrint("桌子坐下成功")
	-- // 断线重连进来
	if userSit.dwUserID == PlatformLogic.loginResult.dwUserID then
		if INVALID_DESKNO ~= userSit.bDeskIndex and INVALID_DESKSTATION ~= userSit.bDeskStation then
			self.callback:onRoomSitCallback(true, GBKToUtf8("坐下成功"), self._roomID, userSit.bDeskIndex, userSit.bDeskStation, userSit.bIsDeskOwner);
		end
	else
		self.callback:onRoomDeskUserCountChanged();
	end
end

-- // 用户坐下失败
function RoomDeskLogic:I_R_M_SitError(message)
	luaPrint("桌子坐下失败 message "..message);
	self.callback:onRoomSitCallback(false, message, self._roomID, INVALID_DESKNO, INVALID_DESKSTATION,false);
end

-- // 用户站起
function RoomDeskLogic:I_R_M_UserUp(event)
	local userUp = event.userUp;
	local uesr = event.user;

	self.callback:onRoomDeskUserCountChanged();
end

-- // 锁桌
function RoomDeskLogic:I_R_M_LockDesk(deskNo)
	self.callback:onRoomDeskLock(deskNo);
end

-- // 取消锁桌
function RoomDeskLogic:I_R_M_UnLockDesk(deskNo)
	self.callback:onRoomDeskUnLock(deskNo);
end

-- // 用户进入
function RoomDeskLogic:I_R_M_UserCome(user)
	self.callback:onRoomUserCome(user.dwUserID);
end

-- // 用户离开
function RoomDeskLogic:I_R_M_UserLeft(user)
	self.callback:onRoomUserLeft(user.dwUserID);
end

return RoomDeskLogic
