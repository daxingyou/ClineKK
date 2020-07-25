
--德州扑克

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local DzpkInfo = {}

function DzpkInfo:init()
	self:initData();

	self:registerCmdNotify();
end


function DzpkInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function DzpkInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ROUND_BEGIN},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SENDCARD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BETPOOL_UP},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BET_RESULT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_COMPARE_CARD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_AUTO_TOKEN},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_TOKEN},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_GAME_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_MING_CARD},	
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ALLIN_MING_CARD},				

					-- {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_WATCHER_SIT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_USER_CUT},
					
					}

	BindTool.register(self, "gameStartInfo", {});		--游戏开始
	BindTool.register(self, "betRusultInfo", {});		--下注
	BindTool.register(self, "sendCardInfo", {});		--发牌
	BindTool.register(self, "gameEndInfo", {});			--结束
	BindTool.register(self, "betpoolupInfo", {});		--边池更新
	BindTool.register(self, "compareCardInfo", {});		--比牌
	BindTool.register(self, "autoTokenInfo", {});		--托管(让/弃，跟任何注)
	BindTool.register(self, "tokenInfo", {});			--令牌消息
	BindTool.register(self, "mingCardInfo", {});		--亮牌消息 
	BindTool.register(self, "allinMingCardInfo", {});	--allin亮牌消息 

	BindTool.register(self, "watcherSitInfo", {});  	--旁观
	BindTool.register(self, "userCutInfo", {});  		--断线
	
end 

function DzpkInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function DzpkInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function DzpkInfo:unregisterCmdNotify(mainID,subID)
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

function DzpkInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.ASS_ROUND_BEGIN then  			--开始游戏
			self:onReceiveGameStartInfo(data);
		elseif subID == GameMsg.ASS_BET_RESULT then     	--下注结果
			self:onReceiveBetRusultInfo(data);
		elseif subID == GameMsg.ASS_SENDCARD then        --发牌
			self:onReceiveSendCardInfo(data);
		elseif subID == GameMsg.ASS_GAME_END then 		--游戏结束
			self:onReceiveGameEndInfo(data);
		elseif subID == GameMsg.ASS_BETPOOL_UP then 		--边池更新
			self:onReceiveBetpoolupInfo(data);
		elseif subID == GameMsg.ASS_COMPARE_CARD then 		--比牌信息
			self:onReceiveCompareCardInfo(data);
		elseif subID == GameMsg.ASS_AUTO_TOKEN then 		--托管 
			self:onReceiveAutoTokenInfo(data);
		elseif subID == GameMsg.ASS_TOKEN then 				--令牌信息
			self:onReceiveTokenInfo(data);
		elseif subID == GameMsg.ASS_MING_CARD then 			--亮牌信息 
			self:onReceiveMingCardInfo(data);
		elseif subID == GameMsg.ASS_ALLIN_MING_CARD then 	--全下亮牌信息 
			self:onReceiveAllinMingCardInfo(data);

		elseif subID == GameMsg.SUB_S_WATCHER_SIT then 		--旁观
			self:onReceiveWatcherSitInfo(data);
		elseif subID == GameMsg.ASS_USER_CUT then 			--断线
			self:onReceiveUserCutInfo(data);
		end
	end
end

--游戏开始
function DzpkInfo:onReceiveGameStartInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart);
	-- luaDump(msg,"游戏开始")
	self:setGameStartInfo(msg);
end

--下注结果
function DzpkInfo:onReceiveBetRusultInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_NoteResult);
	-- luaDump(msg,"下注结果")
	self:setBetRusultInfo(msg);
end

--发牌
function DzpkInfo:onReceiveSendCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SendCard);
	-- luaDump(msg,"发牌")
	self:setSendCardInfo(msg);
end

--游戏结束
function DzpkInfo:onReceiveGameEndInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd);
	-- luaDump(msg,"游戏结束")
	self:setGameEndInfo(msg);
end

--边池更新
function DzpkInfo:onReceiveBetpoolupInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_TBetPool);
	-- luaDump(msg,"边池更新")
	self:setBetpoolupInfo(msg);
end

--比牌信息
function DzpkInfo:onReceiveCompareCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Compare);
	-- luaDump(msg,"比牌信息")
	self:setCompareCardInfo(msg);
end

--托管
function DzpkInfo:onReceiveAutoTokenInfo(data)
	local msg = convertToLua(data,GameMsg.AutoToken);
	-- luaDump(msg,"托管")
	self:setAutoTokenInfo(msg);
end

--令牌信息
function DzpkInfo:onReceiveTokenInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Notify);
	-- luaDump(msg,"令牌信息")
	self:setTokenInfo(msg);
end

--亮牌信息
function DzpkInfo:onReceiveMingCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_MingCard);
	luaDump(msg,"亮牌信息")
	self:setMingCardInfo(msg);
end

--allin亮牌信息
function DzpkInfo:onReceiveAllinMingCardInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_AllInMingCard);
	luaDump(msg,"亮牌信息")
	self:setAllinMingCardInfo(msg);
end

--旁观
function DzpkInfo:onReceiveWatcherSitInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_WatcherSit);
	-- luaDump(msg,"旁观")
	self:setWatcherSitInfo(msg);
end

--断线
function DzpkInfo:onReceiveUserCutInfo(data)
	local msg = convertToLua(data,GameMsg.bCutStruct);
	luaDump(msg,"断线")
	self:setUserCutInfo(msg);
end



----------------客户端主动发送消息-------------------------------

-- //发送玩家准备好消息
function DzpkInfo:sendMsgReady()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

--下注类型
function DzpkInfo:sendNodeType(itype,money)
	local msg = {}
	msg.nType = itype;
	msg.byUser = 255;
	msg.nMoney = money;
	luaDump(msg,"sendNodeType")
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_BET, msg, GameMsg.CMD_C_Note);
end

--托管类型
function DzpkInfo:sendAutoToken(itype,bAuto)
	local msg = {}
	msg.autoType = itype;
	msg.bAuto = bAuto;
	luaDump(msg,"sendAutoToken")
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_AUTO_TOKEN, msg, GameMsg.AutoToken);
end

--亮牌
function DzpkInfo:sendMingCard(bMing)
	local msg = {}
	msg.bMing = bMing;
	luaDump(msg,"sendMingCard")
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_MING_CARD, msg, GameMsg.CMD_S_MingCard);
end

return DzpkInfo;

