local PlatformLogicBase = class("PlatformLogicBase")

function PlatformLogicBase:ctor(callback)
	self._callback = callback or nil;
end

-- function PlatformLogicBase:start()
-- 	self:bindEvent();
-- end

-- function PlatformLogicBase:stop()
-- 	self:unBindEvent();
-- end

function PlatformLogicBase:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_DisConnect",function () self:I_P_M_DisConnect() end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_RoomList",function () self:I_P_M_RoomList() end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_NewsSys",function () self:I_P_M_NewsSys() end);
end

-- function PlatformLogicBase:unBindEvent()
-- 	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
--         return;
--     end
    
--     for _, bindid in pairs(self.bindIds) do
--         Event:unRegisterListener(bindid)
--     end
-- end

function PlatformLogicBase:I_P_M_DisConnect()
	PlatformLogic:close();
	if self._callback then
		self._callback:onPlatformDisConnectCallback(GBKToUtf8("网络断开连接"));
	end
end

function PlatformLogicBase:I_P_M_RoomList()
	local nNameID = GameCreator:getCurrentGameNameID();
	-- //匹配房
	if self._callback then
		if tonumber(nNameID) > 40000000 then
			self._callback:onPlatformMatchRoomGameCallBack(nNameID);
		else
			self._callback:onPlatformGameRoomListCallback(true, GBKToUtf8("获取成功"));
		end
	end
end

function PlatformLogicBase:I_P_M_NewsSys(event)
	if self._callback then
		self._callback:onPlatformNewsCallback(event.szMessage);
	end
end

return PlatformLogicBase
