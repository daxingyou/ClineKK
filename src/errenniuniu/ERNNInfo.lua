--游戏内消息

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local ERNNInfo = {}

function ERNNInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function ERNNInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function ERNNInfo:initData()
	self.cmdList = {
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},-- 游戏开始
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_ADD_SCORE},--加注结果
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_CARD},--发牌消息
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},--游戏结束
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_OPEN_CARD},--用户摊牌
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CALL_BANKER},--用户叫庄
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_TRUST},--用户托管 
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_READY},--让谁准备
					 {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BEGIN},--播开始特效
				}


	self.isCompleteRequestMatchListInfo = false;
	self.tempMatchListInfo = {};
	BindTool.register(self, "BJLGameStart", {});--游戏开始
	BindTool.register(self, "BJLGameAddMoney", {});--加注结果
	BindTool.register(self, "BJLGameSendCard", {});--发牌消息
	BindTool.register(self, "BJLGameEnd", {});--游戏结束
	BindTool.register(self, "BJLGameLookCard", {});--用户摊牌
	BindTool.register(self, "GameBank", {});--用户叫庄
	BindTool.register(self, "BJLGameTrust", {});--用户托管
	BindTool.register(self, "BJLGameReady", {});--让谁准备
	BindTool.register(self, "BJLBegin", {});--播开始特效

	
end

function ERNNInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function ERNNInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function ERNNInfo:unregisterCmdNotify(mainID,subID)
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

function ERNNInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_START then -- 游戏开始
			self:onReceiveGameStart(data);
		elseif subID == GameMsg.SUB_S_ADD_SCORE then --加注结果
			self:onReceiveGameAddMoney(data);
		elseif subID == GameMsg.SUB_S_SEND_CARD then --发牌消息
			self:onReceiveGameSendCard(data);
		elseif subID == GameMsg.SUB_S_GAME_END then --游戏结束
			self:onReceiveGameEnd(data);
		elseif subID == GameMsg.SUB_S_OPEN_CARD then --用户摊牌
			self:onReceiveLookCard(data);
		elseif subID == GameMsg.SUB_S_CALL_BANKER then --用户叫庄
			self:onReceiveWantBank(data);
		elseif subID == GameMsg.SUB_S_TRUST then --用户托管
			self:onReceiveGameTrust(data);
		elseif subID == GameMsg.SUB_S_READY then --让谁准备
			self:onReceiveGameReady(data);
		elseif subID == GameMsg.SUB_S_BEGIN then--播开始特效
			self:onReceiveGameStartTeXiao(data);
		end
	end
end

--开始播特效
function ERNNInfo:onReceiveGameStartTeXiao(data)
	local msg = {}
	self:setBJLBegin(msg);
end

--游戏进入空闲状态，此时才可以上庄下庄请求
function ERNNInfo:onReceiveGameReady(data)
	local msg = convertToLua(data,GameMsg.CMD_S_READY)
	luaDump(msg,"让谁准备");
	self:setBJLGameReady(msg);
end

--游戏开始
function ERNNInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart)
	luaDump(msg,"游戏开始");
	self:setBJLGameStart(msg);
end

--用户下注
function ERNNInfo:onReceiveGameAddMoney(data)
	local msg = convertToLua(data,GameMsg.CMD_S_AddScore)
	luaDump(msg,"收到有用户下注消息");
	self:setBJLGameAddMoney(msg);
end

--发牌消息
function ERNNInfo:onReceiveGameSendCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SendCard)
	luaDump(msg,"发牌消息");
	self:setBJLGameSendCard(msg);
end

--游戏结束
function ERNNInfo:onReceiveGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd)
	luaDump(msg,"游戏结束");
	self:setBJLGameEnd(msg);
end

--用户摊牌
function ERNNInfo:onReceiveLookCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Open_Card)
	luaDump(msg,"用户摊牌");
	self:setBJLGameLookCard(msg);
end

--用户上庄
function ERNNInfo:onReceiveWantBank(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CallBanker)
	luaDump(msg,"用户上庄");
	self:setGameBank(msg);
end
--托管
function ERNNInfo:onReceiveGameTrust(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Trust)
	luaDump(msg,"托管");
	self:setBJLGameTrust(msg);
end



------------------------------------客户端消息-----------------------------------------------------------------
--游戏开始
function  ERNNInfo:sendStart()
	luaPrint("发送准备");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end
--叫庄
function ERNNInfo:sendWantBank(num)
	local msg = {};
	msg.bBanker = num;
	luaDump(msg,"发送叫庄请求");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_CALL_BANKER,msg,GameMsg.CMD_C_CallBanker);
end

--用户下注
function ERNNInfo:sendAddMoney(Score)
	local msg = {};
	
	msg.lScore = Score--*100;
	luaDump(msg,"sendAddMoney");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_ADD_SCORE,msg, GameMsg.CMD_C_AddScore);
end

--托管
function  ERNNInfo:sendTrust(num)
	local msg = {}
	msg.lBetIndex = num;
	luaDump(msg,"sendTrust托管");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_TRUST,msg, GameMsg.CMD_C_Trust);
end

--摊牌
function  ERNNInfo:sendOpen(num)
	local msg = {}
	msg.bOX = num;
	luaDump(msg,"sendOpen开牌");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_OPEN_CARD,msg, GameMsg.CMD_C_OxCard);
end


function numberToString2(value)
	-- luaPrint("numberToString2",value)
	-- if value == "" or value == nil then
	-- 	return value;
	-- end
	-- local bit = 100--比例
	-- local value = tonumber(value);

	-- local str = "";
	-- if value%100 == 0 then
	-- 	str = tostring(math.floor(value/bit))..".00";
	-- 	luaPrint("numberToString2str",str)
	-- else
	-- 	local yuvalue10 = value%100;
	-- 	local yuvalue1 = value%10;
	-- 	luaPrint("yuvalue1",yuvalue1);
	-- 	if yuvalue1 == 0 then
	-- 		str = tostring(math.floor(value/bit)+yuvalue10/100).."0";
	-- 	else
	-- 		str =tostring(math.floor(value/bit) + yuvalue10/100)
	-- 	end
	-- end
	-- luaPrint("str",str);
	return gameRealMoney(value);
end

function gameRealMoney(money)
	return string.format("%.2f", money/100);
end

--展示文字动画
function ShowAnimate(node,ft)
	if node == nil then
		return;
	end
	node:setVisible(true);
	node:runAction(cc.Sequence:create(cc.DelayTime:create(ft),cc.CallFunc:create(function ()
		-- body
		node:setVisible(false);
	end)));
end



return ERNNInfo;

