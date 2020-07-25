
--抢庄拼十

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local QznnInfo = {}

function QznnInfo:init()
	self:initData();

	self:registerCmdNotify();
end


function QznnInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function QznnInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_ADD_SCORE},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_CARD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_OPEN_CARD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CALL_BANKER},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BEGIN_CALL},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_WATCHER_SIT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_USER_CUT},
					
					}

	BindTool.register(self, "gameStartInfo", {});		--游戏开始
	BindTool.register(self, "addScoreInfo", {});		--下注
	BindTool.register(self, "sendCardInfo", {});		--发牌
	BindTool.register(self, "gameEndInfo", {});			--结束
	BindTool.register(self, "openCardInfo", {});		--摊牌
	BindTool.register(self, "callBankerInfo", {});		--叫庄 
	BindTool.register(self, "beginCallInfo", {});		--开始叫庄 
	BindTool.register(self, "watcherSitInfo", {});  	--旁观
	BindTool.register(self, "userCutInfo", {});  		--断线
	
end 

function QznnInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function QznnInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function QznnInfo:unregisterCmdNotify(mainID,subID)
	local isHave = false

	for k,v in pairs(self.cmdList) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		RoomDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end
end

function QznnInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_START then  			--开始游戏
			self:onReceiveGameStartInfo(data);
		elseif subID == GameMsg.SUB_S_ADD_SCORE then     	--下注
			self:onReceiveAddScoreInfo(data);
		elseif subID == GameMsg.SUB_S_SEND_CARD then        --发牌
			self:onReceiveSendCardInfo(data);
		elseif subID == GameMsg.SUB_S_GAME_END then 		--游戏结束
			self:onReceiveGameEndInfo(data);
		elseif subID == GameMsg.SUB_S_OPEN_CARD then 		--摊牌
			self:onReceiveOpenCardInfo(data);
		elseif subID == GameMsg.SUB_S_CALL_BANKER then 		--叫庄
			self:onReceiveCallBankerInfo(data);
		elseif subID == GameMsg.SUB_S_BEGIN_CALL then 		--开始叫庄
			self:onReceiveBeginCallInfo(data);
		elseif subID == GameMsg.SUB_S_WATCHER_SIT then 		--旁观
			self:onReceiveWatcherSitInfo(data);
		elseif subID == GameMsg.ASS_USER_CUT then 			--断线
			self:onReceiveUserCutInfo(data);
		end
	end
end

--游戏开始
function QznnInfo:onReceiveGameStartInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart);
	luaDump(msg,"游戏开始")
	self:setGameStartInfo(msg);
end

--下注
function QznnInfo:onReceiveAddScoreInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_AddScore);
	luaDump(msg,"下注")
	self:setAddScoreInfo(msg);
end

--发牌
function QznnInfo:onReceiveSendCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SendCard);
	luaDump(msg,"发牌")
	self:setSendCardInfo(msg);
end


--游戏结束
function QznnInfo:onReceiveGameEndInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd);
	luaDump(msg,"游戏结束")
	self:setGameEndInfo(msg);
end


--摊牌
function QznnInfo:onReceiveOpenCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Open_Card);
	luaDump(msg,"摊牌")
	self:setOpenCardInfo(msg);
end

--叫庄
function QznnInfo:onReceiveCallBankerInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CallBanker);
	luaDump(msg,"叫庄")
	self:setCallBankerInfo(msg);
end

--开始叫庄
function QznnInfo:onReceiveBeginCallInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BeginData);
	luaDump(msg,"开始叫庄")
	self:setBeginCallInfo(msg);
end

--旁观
function QznnInfo:onReceiveWatcherSitInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_WatcherSit);
	luaDump(msg,"旁观")
	self:setWatcherSitInfo(msg);
end

--断线
function QznnInfo:onReceiveUserCutInfo(data)
	local msg = convertToLua(data,GameMsg.bCutStruct);
	luaDump(msg,"断线")
	self:setUserCutInfo(msg);
end



-----------------------------------------------

-- //发送玩家准备好消息
function QznnInfo:sendMsgReady()
	-- RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

--是否抢庄
function QznnInfo:sendQiangzhuang(type)
	local msg = {}
	msg.bBanker = type;
	luaDump(msg,"sendNote")
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_CALL_BANKER, msg, GameMsg.CMD_C_CallBanker);
end

--闲家倍数
function QznnInfo:sendXianBeishu(num)
	local msg = {}
	msg.lScore = num;
	
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_ADD_SCORE, msg, GameMsg.CMD_C_AddScore);
end

--摊牌
function QznnInfo:sendTanpai(num)
	local msg = {}
	msg.bOX = num;
	
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_OPEN_CARD, msg, GameMsg.CMD_C_OxCard);
end


return QznnInfo;

