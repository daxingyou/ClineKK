local GameDesk = class("GameDesk")
local GameDeskLogic = require("logic.roomLogic.RoomDeskLogic");

function GameDesk:ctor(roomInfo)
	self:initData(roomInfo);
end

function GameDesk:initData(roomInfo)
	self.onCloseCallBack = nil;
	self._roomInfo = roomInfo;

	-- // 桌子列表所有数据
	self._allDeskInfo = {};

	self._deskLogic = GameDeskLogic.new(self);
	self._deskLogic:start();
end

function GameDesk:clear()
	self._deskLogic:stop();
end

function GameDesk:createDesk(roomInfo)
	local desk = GameDesk.new(roomInfo);

	return desk;
end

function GameDesk:getRoomDeskLogic()
	return self._deskLogic;
end

function GameDesk:onRoomSitCallback(success, message, roomID, deskNo, seatNo, bMaster)
	luaPrint("启动游戏 GameDesk -------- bMaster "..tostring(bMaster));
	LoadingLayer:removeLoading();
	if success then
		self:clear()

		local roomInfo = RoomLogic:getSelectedRoom();
		if roomInfo == nil then
			GamePromptLayer:create():showPrompt(GBKToUtf8("查找房间失败。"));
			return;
		end
		
		local bRet = GameCreator:startGameClient(roomInfo.uNameID, deskNo, true, bMaster);
		if not bRet then
			GamePromptLayer:create():showPrompt(GBKToUtf8("游戏启动失败。"));
		end
	else
		dispatchEvent("loginRoom")
		dispatchEvent("I_R_M_SitError")
		GamePromptLayer:create():showPrompt(message);
	end
end

function GameDesk:onRoomDeskLock(deskNo)

end

function GameDesk:onRoomDeskUnLock(deskNo)

end

function GameDesk:onRoomDeskUserCountChanged()

end

return GameDesk;
