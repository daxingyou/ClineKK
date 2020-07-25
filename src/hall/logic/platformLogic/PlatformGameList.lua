local PlatformGameList = class("PlatformGameList", require("logic.platformLogic.PlatformLogicBase"))

function PlatformGameList:ctor(callback)
	self.super.ctor(self,callback);
	self.callback = callback or nil;
end

function PlatformGameList:intData()
	self.callback = nil;
end

function PlatformGameList:start()
	self:stop();
	self:bindEvent();
end

function PlatformGameList:stop()
	self:unBindEvent();
end

function PlatformGameList:bindEvent()
    self.bindIds = {}
    self.super.bindEvent(self);

    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_GameList",function () self:I_P_M_GameList() end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_GameUserCount",function () self:I_P_M_GameUserCount() end);
end

function PlatformGameList:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end

    for _, bindid in pairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function PlatformGameList:requestGameList()
	return self:platformRequestGameList();
end

function PlatformGameList:I_P_M_GameList()
	if self.callback then
		GamesInfoModule.isStart = nil;
		GamesInfoModule.isEnd = true;
		GamesInfoModule.copyGameList = nil;
		LoadingLayer:removeLoading();
		self.callback:onPlatformGameListCallback(true, GBKToUtf8("获取游戏列表成功"));
	end
end

function PlatformGameList:platformRequestGameList()
	luaPrint("请求游戏列表")
	if GamesInfoModule:isGameListEmpty() == true then
		GamesInfoModule:clear();
		-- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求游戏列表,请稍后"), LOADING);
		local msg = {}
		msg.AgentID = channelID
		PlatformLogic:send(PlatformMsg.MDM_GP_LIST, PlatformMsg.ASS_GP_LIST_KIND,msg,PlatformMsg.MSG_GP_SR_GetAgentGameList);
	else
		if GamesInfoModule.isEnd == true then
			-- self.callback:onPlatformGameListCallback(true, GBKToUtf8("获取游戏列表成功"));
			return 1
		else
			GamesInfoModule:clear();
			local msg = {}
			msg.AgentID = channelID
			PlatformLogic:send(PlatformMsg.MDM_GP_LIST, PlatformMsg.ASS_GP_LIST_KIND,msg,PlatformMsg.MSG_GP_SR_GetAgentGameList);
		end
	end

	return true;
end

function PlatformGameList:I_P_M_GameUserCount(event)
	-- local count = event.uOnLineCount + event.uVirtualUser

	if self.callback then
		-- self.callback:onPlatformGameUserCountCallback(event.uID, count);
	end
end

return PlatformGameList
