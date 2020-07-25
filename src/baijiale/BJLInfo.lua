local RoomDeal = require("net.room.RoomDeal"):getInstance();

local BJLInfo = {}

function BJLInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function BJLInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function BJLInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},-- 游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON},--用户下注
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},--游戏结束
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_APPLY_BANKER},--申请庄家
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_BANKER},--切换庄家
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_USER_SCORE},--切换庄家
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON_FAIL},--下注失败
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_RECORD},--下注失败
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BANKER},--取消申请
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_AMDIN_COMMAND},--管理员
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_UPDATE_STORAGE},--更新库存
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GET_BANKER},--抢庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_FREE},--游戏进入空闲
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_CANCEL},--取消下庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_SUCCESS},--取消下庄成功
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BET},--退钱
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BANKERWINSCORE},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CONTINUEFAIL},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_XIPAI},
				}

	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START,self); -- 游戏开始
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON,self); --用户下注
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END,self); --游戏结束
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_APPLY_BANKER,self);--申请庄家
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_BANKER,self);--切换庄家
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_USER_SCORE,self);--更新积分
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_RECORD,self);--游戏记录
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON_FAIL,self);--下注失败
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BANKER,self);--取消申请
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_AMDIN_COMMAND,self);--管理员
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_UPDATE_STORAGE,self);--更新库存
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GET_BANKER,self);--抢庄
	-- RoomDeal:registerCmdReceiveNotify(RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_FREE,self);--游戏进入空闲


	self.isCompleteRequestMatchListInfo = false;
	self.tempMatchListInfo = {};
	BindTool.register(self, "BJLGameStart", {});--用户个人比赛信息
	BindTool.register(self, "BJLGameAddBank", {});--用户个人比赛信息
	BindTool.register(self, "BJLGameEnd", {});--用户个人比赛信息
	BindTool.register(self, "BJLGameApplyBank", {});--申请庄家
	BindTool.register(self, "BJLGameChangeBank", {});--切换庄家
	BindTool.register(self, "BJLGameStatusFree", {});--游戏进入空闲状态
	BindTool.register(self, "BJLGameCancelBank", {});--取消上庄
	BindTool.register(self, "BJLGameRecord", {});--游戏记录
	BindTool.register(self, "BJLGameAddMoneyFail", {});--下注失败
	BindTool.register(self, "BJLGameCancleBank", {});--取消下庄
	BindTool.register(self, "BJLGameCancleSuccess", {});--取消下庄成功
	BindTool.register(self, "BJLGameCancleBet", {});--退钱
	BindTool.register(self, "BJLGameBankScore", {});
	BindTool.register(self, "XuTouFail", {});--续投失败
	BindTool.register(self, "WashCard", {});--重新洗牌
end

function BJLInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function BJLInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function BJLInfo:unregisterCmdNotify(mainID,subID)
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

function BJLInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_START then -- 游戏开始
			self:onReceiveGameStart(data);
		elseif subID == GameMsg.SUB_S_PLACE_JETTON then --用户下注
			self:onReceiveGameAddBank(data);
		elseif subID == GameMsg.SUB_S_GAME_END then --游戏结束
			self:onReceiveGameEnd(data);
		elseif subID == GameMsg.SUB_S_APPLY_BANKER then --申请庄家
			self:onReceiveWaitBank(data);
		elseif subID == GameMsg.SUB_S_CHANGE_BANKER then --切换庄家
			self:onReceiveChangeBank(data);
		elseif subID == GameMsg.SUB_S_CHANGE_USER_SCORE then --更新积分
			--self:onReceiveUpdateScore(data);
		elseif subID == GameMsg.SUB_S_SEND_RECORD then --游戏记录
			self:onReceiveGameRecord(data);
		elseif subID == GameMsg.SUB_S_PLACE_JETTON_FAIL then --下注失败
			self:onReceiveAddMoneyFail(data);
		elseif subID == GameMsg.SUB_S_CANCEL_BANKER then --取消申请
			self:onReceiveCancle(data);
		elseif subID == GameMsg.SUB_S_AMDIN_COMMAND then --管理员

		elseif subID == GameMsg.SUB_S_UPDATE_STORAGE then --更新库存

		elseif subID == GameMsg.SUB_S_CANCEL_CANCEL then --//取消下庄
			self:onReceiveCancleDownBank()
		elseif subID == GameMsg.SUB_S_CANCEL_SUCCESS then --//取消下庄成功
			self:onReceiveCancleDownBankSuccess()
		elseif subID == GameMsg.SUB_S_GAME_FREE then --场景空闲消息
		 	self:onReceiveGameStatusFree(data);
		elseif subID == GameMsg.SUB_S_CANCEL_BET then --退钱
		 	self:onReceiveGameCancleBet(data);
		elseif subID == GameMsg.SUB_S_BANKERWINSCORE then
			self:onReceiveGameBankWinScore(data);
		elseif subID == GameMsg.SUB_S_CONTINUEFAIL then --续投失败
			self:onReceiveGameXuTouFail(data);
		elseif subID ==	GameMsg.SUB_S_XIPAI then -- 重新洗牌
			self:onReceiveWashCard(data);
		end
	end
end

function BJLInfo:onReceiveWashCard(data)
	self:setWashCard();
end

--续投失败
function BJLInfo:onReceiveGameXuTouFail()
	self:setXuTouFail();
end

--退钱
function BJLInfo:onReceiveGameBankWinScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_BankScore)
	luaDump(msg,"庄家赢钱");
	self:setBJLGameBankScore(msg);
end

--退钱
function BJLInfo:onReceiveGameCancleBet(data)
	luaPrint("退钱");
	local msg = convertToLua(data,GameMsg.CMD_S_CancelBet)
	luaDump(msg,"退钱");
	self:setBJLGameCancleBet(msg);
end

--//取消下庄
function BJLInfo:onReceiveCancleDownBank()
	luaPrint("取消下庄");
	self:setBJLGameCancleBank();
end

--//取消下庄成功
function BJLInfo:onReceiveCancleDownBankSuccess()
	luaPrint("取消下庄");
	self:setBJLGameCancleSuccess();
end

--游戏进入空闲状态，此时才可以上庄下庄请求
function BJLInfo:onReceiveGameStatusFree(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameFree)
	luaDump(msg,"游戏空闲");
	self:setBJLGameStatusFree(msg);
end
--游戏开始
function BJLInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart)
	luaDump(msg,"游戏开始");
	self:setBJLGameStart(msg);
end

--用户下注
function BJLInfo:onReceiveGameAddBank(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlaceBet)
	--luaDump(msg,"收到有用户下注消息");
	performWithDelay(display.getRunningScene(),function() self:setBJLGameAddBank(msg) end,0.1)
end

--游戏结束
function BJLInfo:onReceiveGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd)
	luaDump(msg,"游戏结束");
	self:setBJLGameEnd(msg);
end

function BJLInfo:onReceiveWaitBank(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ApplyBanker)
	luaDump(msg,"申请庄家");
	self:setBJLGameApplyBank(msg);

end

function BJLInfo:onReceiveChangeBank(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeBanker)
	luaDump(msg,"切换庄家");
	self:setBJLGameChangeBank(msg);
end
function BJLInfo:onReceiveUpdateScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeBanker)
	luaDump(msg,"更新积分");
	--self:setBJLGameEnd(msg);
end

function BJLInfo:onReceiveGameRecord(data)
	local size1 = data:getHead(1)-20
	local size2 = getObjSize(GameMsg.tagServerGameRecord)
	local num = size1/size2
	luaPrint("onReceiveGameRecord",size1,size2,num);
	local object = {};
	for i=1,num do
		local msg = convertToLua(data,GameMsg.tagServerGameRecord)
		table.insert(object,msg);
	end
	--luaDump(object,"游戏记录");
	self:setBJLGameRecord(object);
end

function BJLInfo:onReceiveAddMoneyFail(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlaceBetFail)
	luaDump(msg,"下注失败");
	self:setBJLGameAddMoneyFail(msg);
end

function BJLInfo:onReceiveCancle(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CancelBanker)
	luaDump(msg,"取消申请");
	self:setBJLGameCancelBank(msg);
end

--申请庄家
function BJLInfo:sendWaitBank()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_APPLY_BANKER);
end

--用户下注
function BJLInfo:sendAddMoney(realSeat,Area,Score)
	local msg = {};
	--msg.wChairID = realSeat;
	msg.cbBetArea = Area;
	
	local money = 0;
	if Score == 1 then
		money = 100
	elseif Score == 2 then
		money = 1000
	elseif Score == 3 then
		money = 5000
	elseif Score == 4 then
		money = 10000
	elseif Score == 5 then
		money = 50000
	elseif Score == 6 then
		money = 100000
	end

	msg.lBetScore = money--*100;
	--{"wChairID","WORD"},								--//用户位置
	--{"cbBetArea","BYTE"},								--//筹码区域
	--{"lBetScore","LLONG"},								--//加注数目
	--local size = getCSize("BYTE") + #pokers * getCSize("BYTE")
	luaDump(msg,"sendAddMoney");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_PLACE_JETTON,msg, GameMsg.CMD_C_PlaceBet);
end

--取消申请
function BJLInfo:sendCancleBanker()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_CANCEL_BANKER);
end

--取消下庄
function BJLInfo:sendCancleCancleBanker()
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_CANCEL_CANCEL);
end

--发送续投消息
function BJLInfo:sendXuTouMessage(data)
	local msg = {};
	for k=1,8 do
		msg["cbBetArea"..k] = k-1;
		msg["lBetScore"..k] = data[k];
	end
	luaDump(msg,"续投");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_CONTINUEBET,msg, GameMsg.CMD_C_ContinueBet);
end

-- --管理员命令
-- function BJLInfo:sendCancleBanker999()
-- 	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_AMDIN_COMMAND);
-- end


function numberToString2(value)
	--luaPrint("numberToString2",value)
	-- local bit = 100--比例
	-- local value = tonumber(value);

	-- local str = "";
	-- if value%100 == 0 then
	-- 	str = tostring(math.floor(value/bit))..".00";
	-- 	--luaPrint("numberToString2str",str)
	-- else
	-- 	local yuvalue10 = value%100;
	-- 	local yuvalue1 = value%10;
	-- 	--luaPrint("yuvalue1",yuvalue1);
	-- 	if yuvalue1 == 0 then
	-- 		str = tostring(math.floor(value/bit)).."."..tostring(yuvalue10/10).."0";
	-- 	else
	-- 		str =tostring(math.floor(value/bit) + yuvalue10/100)
	-- 	end
	-- end
	--luaPrint("str",str);
	return gameRealMoney(value);
end

function gameRealMoney(money)
	return string.format("%.2f", money/100);
end


--//获取牌点
function GetCardPip(cbCardData)

	--//计算牌点
	local cbCardValue=GetCardValue(cbCardData);
	local cbPipCount=0
	if cbCardValue>= 10 then
		cbPipCount = 0
	else
		cbPipCount = cbCardValue
	end

	return cbPipCount;
end

function GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end

--//获取牌点
function GetCardListPip(cbCardData,cbCardCount)
	--//变量定义
	local cbPipCount=0;
	--//获取牌点
	for i=1,cbCardCount do
		cbPipCount=(GetCardPip(cbCardData[i])+cbPipCount)%10;
	end
	return cbPipCount;
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



return BJLInfo;

