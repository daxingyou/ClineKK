--砸金蛋

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local DDZInfo = {}

function DDZInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function DDZInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function DDZInfo:initData()
	self.cmdList = {
					--//命令定义
					{RoomMsg.MDM_GM_GAME_NOTIFY,RoomMsg.ASS_GM_AGREE_GAME},-- //游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_CARD},-- //游戏发牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},-- //游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CALL_SCORE},-- //用户叫分
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BANKER_INFO},-- //庄家信息
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_OUT_CARD},-- //用户出牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PASS_CARD},-- //用户放弃
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_CONCLUDE},-- //游戏结束
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_TRUSTEE},-- //用户托管
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_DOUBLE},-- //用户加倍
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NOCARD},-- //用户要不起
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_ROB_NT},-- //用户叫地主

					}
	BindTool.register(self, "DDZGameReady", {});--游戏准备
	BindTool.register(self, "DDZGameStart", {});--游戏开始
	BindTool.register(self, "DDZCallScore", {});--用户叫分
	BindTool.register(self, "DDZBakerInfo", {});--庄家信息
	BindTool.register(self, "DDZOutCard", {});--用户出牌
	BindTool.register(self, "DDZPassCard", {});--用户放弃
	BindTool.register(self, "DDZGameEnd", {});--游戏结束
	BindTool.register(self, "DDZTrustee", {});--用户托管
	BindTool.register(self, "DDZDouble", {});--用户加倍
	BindTool.register(self, "DDZNoCard", {});--用户要不起
	BindTool.register(self, "DDZRobNt", {});--用户叫地主

	BindTool.register(self, "DDZSendCard", {});--游戏发牌
end

function DDZInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function DDZInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function DDZInfo:unregisterCmdNotify(mainID,subID)
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

function DDZInfo:onReceiveCmdResponse(mainID, subID, data)
	luaPrint("DDZInfo:onReceiveCmdResponse",mainID, subID)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_START then -- 游戏开始
			self:onReceiveGameStart(data);
		elseif subID == GameMsg.SUB_S_SEND_CARD then --游戏发牌
			self:onReceiveSendCard(data);
		elseif subID == GameMsg.SUB_S_CALL_SCORE then --用户叫分
			self:onReceiveCallScore(data);
		elseif subID == GameMsg.SUB_S_BANKER_INFO then --庄家信息
			self:onReceiveBankerInfo(data);
		elseif subID == GameMsg.SUB_S_OUT_CARD then --用户出牌
			self:onReceiveOutCard(data);
		elseif subID == GameMsg.SUB_S_PASS_CARD then --用户放弃
			self:onReceivePassCard(data);
		elseif subID == GameMsg.SUB_S_GAME_CONCLUDE then --游戏结束
			self:onReceiveGameEnd(data);
		elseif subID == RoomMsg.ASS_GM_AGREE_GAME then--游戏准备
			self:onGameReady(data);
		elseif subID == GameMsg.SUB_S_TRUSTEE then --用户托管
			self:onReceiveTrustee(data)
		elseif subID == GameMsg.SUB_S_DOUBLE then --用户加倍
			self:onReceiveDouble(data)
		elseif subID == GameMsg.SUB_S_NOCARD then --用户要不起
			self:onReceiveNoCard(data)
		elseif subID == GameMsg.SUB_S_ROB_NT then --用户叫地主
			self:onReceiveRobNt(data)
		end
	end
end
--游戏准备
function DDZInfo:onGameReady(data)
	local msg = convertToLua(object, RoomMsg.SG_GR_R_UserAgree);
	luaDump(msg,"准备消息")
	
	self:setGameReady(msg);
end
--游戏开始
function DDZInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart)
	luaDump(msg,"游戏开始");
	self:setDDZGameStart(msg);
end

--游戏发牌
function DDZInfo:onReceiveSendCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SendCard)
	luaDump(msg,"游戏发牌");
	self:setDDZSendCard(msg);
end

--用户叫分
function DDZInfo:onReceiveCallScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CallScore)
	luaDump(msg,"用户叫分");
	self:setDDZCallScore(msg);
end

--庄家信息
function DDZInfo:onReceiveBankerInfo(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BankerInfo)
	luaDump(msg,"庄家信息");
	self:setDDZBakerInfo(msg);
end

--用户出牌
function DDZInfo:onReceiveOutCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_OutCard)
	luaDump(msg,"用户出牌");
	self:setDDZOutCard(msg);
end

--用户放弃
function DDZInfo:onReceivePassCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PassCard)
	luaDump(msg,"用户放弃");
	self:setDDZPassCard(msg);
end

--游戏结束
function DDZInfo:onReceiveGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameConclude)
	luaDump(msg,"游戏结束");
	self:setDDZGameEnd(msg);
end

--用户托管
function DDZInfo:onReceiveTrustee(data)
	local msg = convertToLua(data,GameMsg.CMD_S_TRUSTEE)
	luaDump(msg,"用户托管");
	self:setDDZTrustee(msg);
end

--用户加倍
function DDZInfo:onReceiveDouble(data)
	local msg = convertToLua(data,GameMsg.CMD_S_DOUBLE)
	luaDump(msg,"用户加倍");
	self:setDDZDouble(msg);
end

--用户要不起
function DDZInfo:onReceiveNoCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_NOCARD)
	luaDump(msg,"用户要不起");
	self:setDDZNoCard(msg);
end

--用户叫地主
function DDZInfo:onReceiveRobNt(data)
	local msg = convertToLua(data,GameMsg.CMD_S_RobNT)
	luaDump(msg,"用户叫地主");
	self:setDDZRobNt(msg);
end

return DDZInfo;

