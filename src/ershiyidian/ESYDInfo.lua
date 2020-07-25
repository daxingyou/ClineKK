--游戏内消息


local RoomDeal = require("net.room.RoomDeal"):getInstance();

local ESYDInfo = {}

function ESYDInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function ESYDInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function ESYDInfo:initData()
	self.cmdList = {
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},-- 游戏开始
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},--游戏结束
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_CARD},--发牌消息
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SPLIT_CARD},--分牌
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_STOP_CARD},--停牌
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_DOUBLE_SCORE},--加倍
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_INSURE},--保险 
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_ADD_SCORE},--下注
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GET_CARD},--要牌
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BANKER_CARD},--庄家的牌
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NO_ACTION},--玩家未操作 
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_QIANG},--玩家抢庄
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BEGIN},--开始抢庄
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GIVE_UP_BANK},--放弃庄
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BANK_USER},--通知庄家
					  {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BEGIN_TX},--特效
				}


	self.isCompleteRequestMatchListInfo = false;
	self.tempMatchListInfo = {};
	BindTool.register(self, "GameStart", {});--游戏开始
	BindTool.register(self, "GameEnd", {});--游戏结束
	BindTool.register(self, "GameSendCard", {});--发牌消息
	BindTool.register(self, "GameBreakCard", {});--分牌
	BindTool.register(self, "GameStopCard", {});--停牌
	BindTool.register(self, "GameDoubleScore", {});--加倍
	BindTool.register(self, "GameInsurance", {});--保险
	BindTool.register(self, "GameAddScore", {});--下注
	BindTool.register(self, "GameGetCard", {});--要牌
	BindTool.register(self, "GameBankCard", {});--庄家的牌
	BindTool.register(self, "GameNoAction", {});--玩家未操作
	BindTool.register(self, "GameQiang", {});--玩家抢庄
	BindTool.register(self, "GameBegin", {});--开始抢庄
	BindTool.register(self, "GameGiveUp", {});--放弃庄
	BindTool.register(self, "GameBankUser", {});--通知庄家
	BindTool.register(self, "GameBeginTX", {});--特效
	
end

function ESYDInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function ESYDInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function ESYDInfo:unregisterCmdNotify(mainID,subID)
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

function ESYDInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_START then -- 游戏开始
			self:onReceiveGameStart(data);
		elseif subID == GameMsg.SUB_S_GAME_END then --游戏结束
			self:onReceiveGameEnd(data);
		elseif subID == GameMsg.SUB_S_SEND_CARD then --发牌消息
			self:onReceiveGameSendCard(data);
		elseif subID == GameMsg.SUB_S_SPLIT_CARD then --分牌
			self:onReceiveBreakCard(data);
		elseif subID == GameMsg.SUB_S_STOP_CARD then --停牌
			self:onReceiveStopCard(data);
		elseif subID == GameMsg.SUB_S_DOUBLE_SCORE then --加倍
			self:onReceiveDoubleScore(data);
		elseif subID == GameMsg.SUB_S_INSURE then --保险
			self:onReceiveGameInsurance(data);
		elseif subID == GameMsg.SUB_S_ADD_SCORE then --下注
			self:onReceiveGameAddScore(data);
		elseif subID == GameMsg.SUB_S_GET_CARD then --要牌
			self:onReceiveGameGetCard(data);
		elseif subID == GameMsg.SUB_S_BANKER_CARD then --庄家的牌
			self:onReceiveGameBankerCard(data);
		elseif subID ==	GameMsg.SUB_S_NO_ACTION then --玩家未操作
			self:onReceiveGameNoAction(data);
		elseif subID ==	GameMsg.SUB_S_QIANG then --玩家抢庄
			luaPrint("GameMsg.SUB_S_QIANG",GameMsg.SUB_S_QIANG);
			self:onReceiveGameQiang(data);
		elseif subID ==	GameMsg.SUB_S_BEGIN then --开始抢庄
			self:onReceiveGameBegin(data);
		elseif subID ==	GameMsg.SUB_S_GIVE_UP_BANK then --放弃庄
			self:onReceiveGameGiveUp(data);
		elseif subID ==	GameMsg.SUB_S_BANK_USER then --通知庄家
			self:onReceiveGameBankUser(data);
		elseif subID ==	GameMsg.SUB_S_BEGIN_TX then --特效
			self:onReceiveGameStartTeXiao(data);
		end
	end
end

--开始播特效
function ESYDInfo:onReceiveGameStartTeXiao(data)
	local msg = {}
	self:setGameBeginTX(msg);
end

--通知庄家
function ESYDInfo:onReceiveGameBankUser(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Bank_USER)
	luaDump(msg,"通知庄家");
	self:setGameBankUser(msg);
end

--放弃庄
function ESYDInfo:onReceiveGameGiveUp(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GIVE_UP_BANK)
	luaDump(msg,"放弃庄");
	self:setGameGiveUp(msg);
end

--开始抢庄
function ESYDInfo:onReceiveGameBegin(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BEGIN_BANK)
	luaDump(msg,"开始抢庄");
	self:setGameBegin(msg);
end

--玩家抢庄
function ESYDInfo:onReceiveGameQiang(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Qiang)
	luaDump(msg,"玩家抢庄");
	self:setGameQiang(msg);
end
--玩家未操作
function ESYDInfo:onReceiveGameNoAction(data)
	-- local msg = convertToLua(data,GameMsg.CMD_S_AddScore)
	-- luaDump(msg,"玩家未操作");
	self:setGameNoAction();
end
--玩家未操作
function ESYDInfo:onReceiveGameAddScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_AddScore)
	luaDump(msg,"下注");
	self:setGameAddScore(msg);
end
--要牌
function ESYDInfo:onReceiveGameGetCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GetCard)
	luaDump(msg,"要牌");
	self:setGameGetCard(msg);
end
--庄家的牌
function ESYDInfo:onReceiveGameBankerCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BankerCard)
	luaDump(msg,"庄家的牌");
	self:setGameBankCard(msg);
end

--游戏开始
function ESYDInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart)
	luaDump(msg,"游戏开始");
	self:setGameStart(msg);
end

--游戏结束
function ESYDInfo:onReceiveGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd)
	luaDump(msg,"游戏结束");
	self:setGameEnd(msg);
end

--发牌消息
function ESYDInfo:onReceiveGameSendCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SendCard)
	luaDump(msg,"发牌消息");
	self:setGameSendCard(msg);
end

--分牌
function ESYDInfo:onReceiveBreakCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_SplitCard)
	luaDump(msg,"分牌");
	self:setGameBreakCard(msg);
end

--停牌
function ESYDInfo:onReceiveStopCard(data)
	local msg = convertToLua(data,GameMsg.CMD_S_StopCard)
	luaDump(msg,"停牌");
	self:setGameStopCard(msg);
end

--加倍
function ESYDInfo:onReceiveDoubleScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_DoubleScore)
	luaDump(msg,"加倍");
	self:setGameDoubleScore(msg);
end
--保险
function ESYDInfo:onReceiveGameInsurance(data)
	local msg = convertToLua(data,GameMsg.CMD_S_Insure)
	luaDump(msg,"保险");
	self:setGameInsurance(msg);
end



------------------------------------客户端消息-----------------------------------------------------------------
--游戏开始
function  ESYDInfo:sendStart()
	luaPrint("发送准备");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, RoomMsg.ASS_GM_AGREE_GAME);
end

--用户加注
function ESYDInfo:sendAddMoney(Score)
	local msg = {};
	
	msg.lScore = Score--*100;
	luaDump(msg,"sendAddMoney");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_ADD_SCORE,msg, GameMsg.CMD_C_AddScore);
end

--要牌
function ESYDInfo:sendGetCard()
	luaPrint("要牌");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_GET_CARD);
end

--加倍
function ESYDInfo:sendDoubleScore()
	luaPrint("加倍");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_DOUBLE_SCORE);
end

--保险
function ESYDInfo:sendInsure(isTrue)
	luaPrint("保险");
	local msg = {};
	msg.IsInsure = isTrue;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_INSURE,msg, GameMsg.CMD_C_INSURE);
end

--分牌
function ESYDInfo:sendBreakCard()
	luaPrint("分牌");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_SPLIT_CARD);
end

--停牌
function ESYDInfo:sendStopCard()
	luaPrint("停牌");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_STOP_CARD);
end

--继续游戏
function ESYDInfo:sendjixuGame()
	luaPrint("继续游戏");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_Continue);
end

--抢庄
function ESYDInfo:sendQiang()
	luaPrint("抢庄");
	local msg = {};
	msg.bQiang = true;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_QIANG,msg, GameMsg.CMD_C_Qiang);
end

--不抢
function ESYDInfo:sendBuQiang()
	luaPrint("不抢");
	local msg = {};
	msg.bQiang = false;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_QIANG,msg, GameMsg.CMD_C_Qiang);
end

--弃庄
function ESYDInfo:giveUpBanker(isTrue)
	luaPrint("弃庄");
	local msg = {};
	msg.bGiveUp = isTrue;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_GIVE_UP_BANK,msg, GameMsg.CMD_C_GIVE_UP_BANK);
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

function GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end



return ESYDInfo;

