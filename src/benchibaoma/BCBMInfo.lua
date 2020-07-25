--砸金蛋

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local BCBMInfo = {}

function BCBMInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function BCBMInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function BCBMInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_FREE},-- //游戏空闲
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},-- //游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON},-- //用户下注
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},-- //游戏结束
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_APPLY_BANKER},-- //申请庄家
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_BANKER},-- //切换庄家
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_USER_SCORE},-- //更新积分
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_RECORD},-- //游戏记录

					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON_FAIL},-- //下注失败
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BANKER},-- //取消申请
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SCORE_HISTORY},-- //历史记录
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_SYS_BANKER},-- //切换庄家
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GET_BANKER},-- //抢庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_CANCEL},--//庄家下庄后反悔--取消下庄
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_SUCCESS},--//庄家下庄按钮点击返回
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BET},--//有人离开退注
					
					--{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_USER_CUT},-- //断线重连
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_BANKERWINSCORE},--庄家坐庄期间输赢金币
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CONTINUEFAIL},
					}

	BindTool.register(self, "BCBMGameFree", {});--空闲
	BindTool.register(self, "BCBMGameStart", {});--游戏开始
	BindTool.register(self, "BCBMGamePlaceJetton", {});--用户下注
	BindTool.register(self, "BCBMGameEnd", {});--游戏结束
	BindTool.register(self, "BCBMApplyBanker", {});--申请庄家
	BindTool.register(self, "BCBMChangeBanker", {});--切换庄家
	BindTool.register(self, "BCBMChangeUserScore", {});--更新积分
	BindTool.register(self, "BCBMSndRecord", {});--游戏记录

	BindTool.register(self, "BCBMPlaceJettonFail", {});--下注失败
	BindTool.register(self, "BCBMCancelBanker", {});--取消申请
	BindTool.register(self, "BCBMSendScoreHistory", {});--历史记录
	BindTool.register(self, "BCBMChangeSysBanker", {});--切换SYS庄家
	BindTool.register(self, "BCBMGetBanker", {});--抢庄
	BindTool.register(self, "BCBMCancelCancel", {});--//庄家下庄后反悔--取消下庄
	BindTool.register(self, "BCBMCancelSuccess", {});--//庄家下庄按钮点击返回
	BindTool.register(self, "BCBMCancelBet", {});--//有人离开退注
	--BindTool.register(self, "BCBMUSERCUT", {});--断线重连
	BindTool.register(self, "ZhuangScore", {});--庄家坐庄期间输赢金币
	BindTool.register(self, "XuTouFail", {});--续投失败

end

function BCBMInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function BCBMInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function BCBMInfo:unregisterCmdNotify(mainID,subID)
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

function BCBMInfo:onReceiveCmdResponse(mainID, subID, data)
	luaPrint("BCBMInfo:onReceiveCmdResponse",mainID, subID)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_GAME_FREE then -- 游戏空闲
			self:onReceiveGameFree(data);
		elseif subID == GameMsg.SUB_S_GAME_START then --游戏开始
			self:onReceiveGameStart(data);
		elseif subID == GameMsg.SUB_S_PLACE_JETTON then --用户下注
			self:onReceiveGamePlaceJetton(data);
		elseif subID == GameMsg.SUB_S_GAME_END then --游戏结束
			self:onReceiveGameEnd(data)
		elseif subID == GameMsg.SUB_S_APPLY_BANKER then --申请庄家
			self:onReceiveApplyBanker(data)
		elseif subID == GameMsg.SUB_S_CHANGE_BANKER then --切换庄家
			self:onReceiveChangeBanker(data)
		elseif subID == GameMsg.SUB_S_CHANGE_USER_SCORE then --更新积分
			self:onReceiveChangeUserScore(data)
		elseif subID == GameMsg.SUB_S_SEND_RECORD then --游戏记录
			self:onReceiveSendRecord(data)
		elseif subID == GameMsg.SUB_S_PLACE_JETTON_FAIL then --下注失败
			self:onReceivePlaceJettonFail(data)
		elseif subID == GameMsg.SUB_S_CANCEL_BANKER then --取消申请
			self:onReceiveCancelBanker(data)
		elseif subID == GameMsg.SUB_S_SCORE_HISTORY then --历史记录
			self:onReceiveScoreHistory(data)
		elseif subID == GameMsg.SUB_S_CHANGE_SYS_BANKER then --切换庄家
			self:onReceiveChangeSysBanker(data)
		elseif subID == GameMsg.SUB_S_GET_BANKER then --抢庄
			self:onReceiveGetBanker(data)
		elseif subID == GameMsg.SUB_S_CANCEL_CANCEL then --庄家下庄后反悔--取消下庄
			self:onReceiveCancelCancel(data)
		elseif subID == GameMsg.SUB_S_CANCEL_SUCCESS then --庄家下庄按钮点击返回
			self:onReceiveCancelSuccess(data)
		elseif subID == GameMsg.SUB_S_CANCEL_BET then --有人离开，退下注
			luaPrint("有人离开，退下注1")
			self:onReceiveCancelBet(data)
		-- elseif subID == GameMsg.ASS_USER_CUT then --断线重连
		-- 	self:onReceiveUserCut(data)
		elseif subID == GameMsg.SUB_S_BANKERWINSCORE then--庄家坐庄期间输赢金币
			self:ZhuangScoreMessage(data);
		elseif subID == GameMsg.SUB_S_CONTINUEFAIL then --续投失败
			self:onReceiveGameXuTouFail(data);
		end
	end
end

--续投失败
function BCBMInfo:onReceiveGameXuTouFail()
	self:setXuTouFail();
end

--游戏空闲
function BCBMInfo:onReceiveGameFree(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameFree)
	--luaDump(msg,"游戏空闲free");
	self:setBCBMGameFree(msg);
end

--游戏开始
function BCBMInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart)
	---luaDump(msg,"游戏开始start");
	self:setBCBMGameStart(msg);
end

--用户下注
function BCBMInfo:onReceiveGamePlaceJetton(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlaceJetton)
	--luaDump(msg,"用户下注");
	performWithDelay(display.getRunningScene(),function() self:setBCBMGamePlaceJetton(msg) end,0.1)
end

--游戏结束
function BCBMInfo:onReceiveGameEnd(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd)
	--luaDump(msg,"游戏结束");
	self:setBCBMGameEnd(msg);
end

--申请庄家
function BCBMInfo:onReceiveApplyBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ApplyBanker)
	--luaDump(msg,"申请庄家");
	self:setBCBMApplyBanker(msg);
end

--切换庄家
function BCBMInfo:onReceiveChangeBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeBanker)
	--luaDump(msg,"切换庄家");
	self:setBCBMChangeBanker(msg);
end

--更新积分
function BCBMInfo:onReceiveChangeUserScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeUserScore)
	--luaDump(msg,"更新积分");
	self:setBCBMChangeUserScore(msg);
end

--游戏记录
function BCBMInfo:onReceiveSendRecord(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeBanker)
	--luaDump(msg,"游戏记录");
	self:setBCBMSendRecord(msg);
end

--下注失败
function BCBMInfo:onReceivePlaceJettonFail(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlaceJettonFail)
	--luaDump(msg,"下注失败");
	self:setBCBMPlaceJettonFail(msg);
end

--取消申请
function BCBMInfo:onReceiveCancelBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CancelBanker)
	--luaDump(msg,"取消申请");
	self:setBCBMCancelBanker(msg);
end

--历史记录
function BCBMInfo:onReceiveScoreHistory(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ScoreHistory)
	--luaDump(msg,"历史记录");
	self:setBCBMSendScoreHistory(msg);
end

--切换庄家
function BCBMInfo:onReceiveChangeSysBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeSysBanker)
	luaDump(msg,"切换SYS庄家");
	self:setBCBMChangeSysBanker(msg);
end

--抢庄
function BCBMInfo:onReceiveGetBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GetBanker)
	--luaDump(msg,"抢庄");
	self:setBCBMGetBanker(msg);
end

function BCBMInfo:onReceiveCancelCancel( ... )
	self:setBCBMCancelCancel();
end

function BCBMInfo:onReceiveCancelSuccess( ... )
	self:setBCBMCancelSuccess();
end
--退注
function BCBMInfo:onReceiveCancelBet(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CancelBet)
	--luaDump(msg,"退注");
	self:setBCBMCancelBet(msg);
end

--断线重连
function BCBMInfo:onReceiveUserCut(data)
	-- local msg = convertToLua(data,GameMsg.CMD_S_GetBanker)
	-- luaDump(msg,"断线重连");
	--self:setBCBMUserCut();
end

--庄家坐庄期间输赢金币
function BCBMInfo:ZhuangScoreMessage(object)
	local msg = convertToLua(object,GameMsg.BankGetMonry);
	self:setZhuangScore(msg);
end

--发送续投消息
function BCBMInfo:sendXuTouMessage(data)
	local msg = {};
	for k=1,8 do
		msg["cbBetArea"..k] = k;
		msg["lBetScore"..k] = data[k];
	end
	luaDump(msg,"续投");
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_CONTINUEBET,msg, GameMsg.CMD_C_ContinueBet);
end

return BCBMInfo;

