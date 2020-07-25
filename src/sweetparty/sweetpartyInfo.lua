local RoomDeal = require("net.room.RoomDeal"):getInstance();

local sweetpartyInfo = {}

function sweetpartyInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function sweetpartyInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function sweetpartyInfo:initData()
	self.cmdList = {
		{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_S_ROLL_RESULT},--滚动结果
        {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_S_SMALLGAME_RESULT},--小游戏结果
		{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_S_UPDATE_POND},--奖池更新
	}

    BindTool.register(self, "RollResult", {});--滚动结果
	BindTool.register(self, "SmallGameResult", {});--小游戏结果
	BindTool.register(self, "UpdatePool", {});--奖池更新
end

function sweetpartyInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function sweetpartyInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function sweetpartyInfo:onReceiveCmdResponse(mainID, subID, object)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.ASS_S_ROLL_RESULT then--滚动结果
		    self:RollResultMessage(object);
		elseif subID == GameMsg.ASS_S_SMALLGAME_RESULT then--小游戏结果
			self:SmallGameResultMessage(object);
		elseif subID == GameMsg.ASS_S_UPDATE_POND then--奖池更新
			self:UpdatePoolMessage(object);
		end
	end
end

function sweetpartyInfo:RollResultMessage(object)
    luaDump(object,"object")  
	local msg = convertToLua(object,GameMsg.Rc_Packet_GameResult);
    
	self:setRollResult(msg);
end

function sweetpartyInfo:SmallGameResultMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_SmallGameSelect);
	self:setSmallGameResult(msg);
end

function sweetpartyInfo:UpdatePoolMessage(object)
	local msg = convertToLua(object,GameMsg.Cr_Packet_UpdatePool);
	luaDump(msg,"UpdatePool")
	self:setUpdatePool(msg);
end

return sweetpartyInfo;
