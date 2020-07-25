
-- 十三张

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local shisanzhanglqInfo = {}

function shisanzhanglqInfo:init()
	self:initData();

	self:registerCmdNotify();
end


function shisanzhanglqInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function shisanzhanglqInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_CARD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BIBAI_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_OPEN_CARD},
					
					}

	BindTool.register(self, "sendCardInfo", {});		--发牌
	BindTool.register(self, "gameResultInfo", {});  	--比牌结果
	BindTool.register(self, "gameEndInfo", {});			--结束
	BindTool.register(self, "openCardInfo", {});		--摊牌
	
end 

function shisanzhanglqInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function shisanzhanglqInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function shisanzhanglqInfo:unregisterCmdNotify(mainID,subID)
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

function shisanzhanglqInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		luaPrint("recv~~~~~~~~~", mainID, subID)
		printTrackback()
		if subID == GameMsg.SUB_S_SEND_CARD then        --发牌
			self:onReceiveSendCardInfo(data);
		elseif subID == GameMsg.SUB_S_GAME_END then 		--游戏结束
			self:onReceiveGameEndInfo(data);
		elseif subID == GameMsg.SUB_S_BIBAI_END then 		-- 比牌结果
			self:onReceiveGameResultInfo(data);
		elseif subID == GameMsg.SUB_S_OPEN_CARD then 		--摊牌
			self:onReceiveOpenCardInfo(data);
		elseif subID == GameMsg.ASS_USER_CUT then 			--断线
			self:onReceiveUserCutInfo(data);
		end
	end
end

--游戏开始
function shisanzhanglqInfo:onReceiveGameStartInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart);
	luaDump(msg,"游戏开始")
	self:setGameStartInfo(msg);
end

--发牌
function shisanzhanglqInfo:onReceiveSendCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_FaPai);
	luaDump(msg,"发牌")
	self:setSendCardInfo(msg);
end

-- 比牌结果
function shisanzhanglqInfo:onReceiveGameResultInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BiPai);
	luaDump(msg,"比牌结果")
	self:setGameResultInfo(msg);
end

--游戏结束
function shisanzhanglqInfo:onReceiveGameEndInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd);
	luaDump(msg,"游戏结束")
	self:setGameEndInfo(msg);
end


--摊牌
function shisanzhanglqInfo:onReceiveOpenCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Open_Card);
	luaDump(msg,"摊牌")
	self:setOpenCardInfo(msg);
end

-----------------------------------------------

-- //发送玩家准备好消息
function shisanzhanglqInfo:sendMsgReady()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end


--摊牌
function shisanzhanglqInfo:sendTanpai(data)
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_OPEN_CARD, data, GameMsg.DMC_S_Open_Card);
end

-- 特殊牌摊牌
function shisanzhanglqInfo:sendTanpaiSpec()
	local data = {
		tsbPRD = 1,
		bFirst = {},
		bMid = {},
		bLast = {},
	}
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_OPEN_CARD, data, GameMsg.DMC_S_Open_Card);
end

return shisanzhanglqInfo;

