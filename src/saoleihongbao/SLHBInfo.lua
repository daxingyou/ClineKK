local RoomDeal = require("net.room.RoomDeal"):getInstance();

local SLHBInfo = {}

function SLHBInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function SLHBInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function SLHBInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()
	luaDump(self.cmdList, "self.cmdList----------", 6)
	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end
function SLHBInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_FREE},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_C_PLANT_MINE},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_OPEN_REDBAG},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_FINISH},	
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_REDBAG_LIST},	
	}


	BindTool.register(self, "SLHBGameFree", {});--空闲
	BindTool.register(self, "SLHBGameStart", {});--游戏开始
	BindTool.register(self, "SLHBGamePlantMine", {});--申请埋雷
	BindTool.register(self, "SLHBOpenRedbag", {});--打开红包
	BindTool.register(self, "SLHBGameEnd", {});--游戏结束
	BindTool.register(self, "SLHBGameFinish", {});--游戏完结
	BindTool.register(self, "SLHBRedBagList", {});--游戏完结

end

--注销本表注册的所有事件
function SLHBInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function SLHBInfo:onReceiveCmdResponse(mainID, subID, data)
	luaPrint("SLHBInfo:onReceiveCmdResponse-----",mainID,subID)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_FREE then -- 游戏空闲
			self:onReceiveGameFree(data);
		elseif subID == GameMsg.SUB_S_GAME_START then --游戏开始
			self:onReceiveGameStart(data);
		elseif subID == GameMsg.SUB_C_PLANT_MINE then --申请埋雷
			self:onReceiveGamePlantMine(data);
		elseif subID == GameMsg.SUB_S_OPEN_REDBAG then --打开红包
			self:onReceiveOpenRegbag(data)
		elseif subID == GameMsg.SUB_S_GAME_END then --游戏结束
			self:onReceiveGameEnd(data)
		elseif subID == GameMsg.SUB_S_GAME_FINISH then --游戏完结
			self:onReceiveGameFinish(data)
		elseif subID == GameMsg.SUB_S_REDBAG_LIST then --红包列表
			self:onReceiveRedBagList(data)
		end
	end
end

--游戏空闲
function SLHBInfo:onReceiveGameFree(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameFree)
	luaDump(msg,"游戏空闲free");
	self:setSLHBGameFree(msg);
end

--游戏开始
function SLHBInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GAMESTART)
	luaDump(msg,"onReceiveGameStart");
	self:setSLHBGameStart(msg);
end

--申请埋雷
function SLHBInfo:onReceiveGamePlantMine(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PLANT_MINE)
	luaDump(msg,"申请埋雷");
	self:setSLHBGamePlantMine(msg);
end

--打开红包
function SLHBInfo:onReceiveOpenRegbag(data)
	luaPrint("onReceiveOpenRegbag_data:",data)
	local msg = convertToLua(data,GameMsg.CMD_S_OPEN_REDBAG)
	luaDump(msg,"打开红包");
	self:setSLHBOpenRedbag(msg);
end

--游戏结束
function SLHBInfo:onReceiveGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GAME_END)
	luaDump(msg,"游戏结束");
	self:setSLHBGameEnd(msg);
end

--游戏结算
function SLHBInfo:onReceiveGameFinish(data)
	--nil
	luaPrint("onReceiveGameFinish---------------116")
	self:setSLHBGameFinish(data);
end

function SLHBInfo:onReceiveRedBagList(data)
	local msg = convertToLua(data,GameMsg.CMD_S_REDBAG_LIST)
	luaDump(msg,"红包列表-----");
	self:setSLHBRedBagList(msg);
end


return SLHBInfo;

