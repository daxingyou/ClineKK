	--游戏内消息


local RoomDeal = require("net.room.RoomDeal"):getInstance();

local BRNNInfo = {}

function BRNNInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function BRNNInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function BRNNInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()
	luaDump(self.cmdList, "self.cmdList----------", 6)
	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end
function BRNNInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_FREE},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_START},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_APPLY_BANKER},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_BANKER},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CHANGE_USER_SCORE},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SEND_RECORD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_PLACE_JETTON_FAIL},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BANKER},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_MAX_JETTON},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GET_BANKER},

					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_SUCCESS},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_CANCEL},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CANCEL_BET},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ZHUANG_SCORE},--庄家坐庄期间输赢金币
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_CONTINUEFAIL},--续投失败

	}


	BindTool.register(self, "BRNNGameFree", {});--空闲
	BindTool.register(self, "BRNNGameStart", {});--游戏开始
	BindTool.register(self, "BRNNGamePlaceJetton", {});--用户下注
	BindTool.register(self, "BRNNGameEnd", {});--游戏结束
	BindTool.register(self, "BRNNApplyBanker", {});--申请庄家
	BindTool.register(self, "BRNNChangeBanker", {});--切换庄家
	BindTool.register(self, "BRNNChangeUserScore", {});--更新积分
	BindTool.register(self, "BRNNSendRecord", {});--消息记录
	BindTool.register(self, "BRNNPlaceJettonFail", {});--下注失败
	BindTool.register(self, "BRNNCancelBanker", {});--取消申请
	BindTool.register(self, "BRNNMaxJetton", {});--历史记录
	-- BindTool.register(self, "BRNNChangeSysBanker", {});--切换SYS庄家
	BindTool.register(self, "BRNNGetBanker", {});--获取庄家列表

	BindTool.register(self, "BRNNCancelQuit", {});--取消下庄
	BindTool.register(self, "BRNNCancelQuitSuc", {});--取消下庄成功
	BindTool.register(self, "BRNNCancelBet", {});--离开的筹码

	BindTool.register(self, "BRNNZhuangScore", {});--庄家坐庄期间输赢金币
	BindTool.register(self, "BRNNContinueFail", {});--续投失败
end
--注销本表注册的所有事件
function BRNNInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function BRNNInfo:onReceiveCmdResponse(mainID, subID, data)
	luaPrint("BRNNInfo:onReceiveCmdResponse-----",mainID,subID)
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
		elseif subID == GameMsg.SUB_S_MAX_JETTON then --下注区域满
			self:onReceiveMaxJetton(data)
		elseif subID == GameMsg.SUB_S_CHANGE_SYS_BANKER then --切换庄家
			self:onReceiveChangeSysBanker(data)
		elseif subID == GameMsg.SUB_S_GET_BANKER then --获取庄家列表
			self:onReceiveGetBanker(data)

		elseif subID == GameMsg.SUB_S_CANCEL_CANCEL then --取消下庄
			self:onReceiveCancelQuit(data);
		elseif subID == GameMsg.SUB_S_CANCEL_SUCCESS then --取消下庄成功
			self:onReceiveCancelQuitSuc(data);
		elseif subID == GameMsg.SUB_S_CANCEL_BET then --离开的筹码
			self:onReceiveCancelBet(data);
		elseif subID == GameMsg.ASS_ZHUANG_SCORE then --庄家坐庄期间输赢金币
			self:onReceiveZhuangScoreMessage(data);
		elseif subID == GameMsg.SUB_S_CONTINUEFAIL then --续投失败
			self:onReceiveContinueFailMessage(data);
		end
	end
end

--游戏空闲
function BRNNInfo:onReceiveGameFree(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameFree)
	-- luaDump(msg,"游戏空闲free");
	self:setBRNNGameFree(msg);
end

--游戏开始
function BRNNInfo:onReceiveGameStart(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameStart)
	-- luaDump(msg,"游戏开始start");
	self:setBRNNGameStart(msg);
end

--用户下注
function BRNNInfo:onReceiveGamePlaceJetton(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlaceJetton)
	-- luaDump(msg,"用户下注");
	performWithDelay(display.getRunningScene(),function() self:setBRNNGamePlaceJetton(msg) end,0.1)
end

--游戏结束
function BRNNInfo:onReceiveGameEnd(data)
	luaPrint("onReceiveGameEnd_data:",data)
	local msg = convertToLua(data,GameMsg.CMD_S_GameEnd)
	-- luaDump(msg,"游戏结束");
	self:setBRNNGameEnd(msg);
end

--申请庄家
function BRNNInfo:onReceiveApplyBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ApplyBanker)
	-- luaDump(msg,"申请庄家");
	self:setBRNNApplyBanker(msg);
end

--切换庄家
function BRNNInfo:onReceiveChangeBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeBanker)
	-- luaDump(msg,"切换庄家");
	self:setBRNNChangeBanker(msg);
end

--更新积分
function BRNNInfo:onReceiveChangeUserScore(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeUserScore)
	luaDump(msg,"onReceiveChangeUserScore_更新积分");
	self:setBRNNChangeUserScore(msg);
end

--游戏记录
function BRNNInfo:onReceiveSendRecord(data)
	-- local msg = convertToLua(data,GameMsg.tagServerGameRecord)
	-- luaDump(msg,"游戏记录");
	-- self:setBRNNSendRecord(msg);


	local size1 = data:getHead(1)-20
	local size2 = getObjSize(GameMsg.tagServerGameRecord)
	local num = size1/size2
	luaPrint("onReceiveSendRecord",size1,size2,num);
	local object = {};
	for i=1,num do
		local msg = convertToLua(data,GameMsg.tagServerGameRecord)
		table.insert(object,msg);
	end
	-- luaDump(object,"游戏记录");
	self:setBRNNSendRecord(object);


end

--下注失败
function BRNNInfo:onReceivePlaceJettonFail(data)
	local msg = convertToLua(data,GameMsg.CMD_S_PlaceJettonFail)
	luaDump(msg,"下注失败");
	self:setBRNNPlaceJettonFail(msg);
end

--取消申请
function BRNNInfo:onReceiveCancelBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_CancelBanker)
	luaDump(msg,"取消申请");
	self:setBRNNCancelBanker(msg);
end

--历史记录
function BRNNInfo:onReceiveScoreHistory(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ScoreHistory)
	luaDump(msg,"历史记录");
	self:setBRNNSendScoreHistory(msg);
end

--切换庄家
function BRNNInfo:onReceiveChangeSysBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_ChangeSysBanker)
	luaDump(msg,"切换SYS庄家");
	self:setBRNNChangeSysBanker(msg);
end

--获取庄家列表
function BRNNInfo:onReceiveGetBanker(data)
	local msg = convertToLua(data,GameMsg.CMD_S_GetBanker)
	luaDump(msg,"获取庄家列表");
	self:setBRNNGetBanker(msg);
end


--取消下庄
function BRNNInfo:onReceiveCancelQuit(data)
	-- local msg = convertToLua(data,GameMsg.CMD_S_GetBanker)
	-- luaDump(msg,"取消下庄");
	luaPrint("onReceiveCancelQuit 取消下庄")
	self:setBRNNCancelQuit({});
end


--取消下庄成功
function BRNNInfo:onReceiveCancelQuitSuc(data)
	-- local msg = convertToLua(data,GameMsg.CMD_S_GetBanker)
	-- luaDump(msg,"取消下庄成功");
	-- luaPrint("取消下庄成功");
	self:setBRNNCancelQuitSuc({});
end


--下注已满
function BRNNInfo:onReceiveMaxJetton( data )
	local msg = convertToLua(data,GameMsg.CMD_S_MaxJetton)
	-- luaPrint("下庄成功已满");
	-- luaDump(msg,"下庄成功已满");
	self:setBRNNMaxJetton(msg);
end


--离开的筹码
function BRNNInfo:onReceiveCancelBet( data )
	local msg = convertToLua(data,GameMsg.CMD_S_CancelBet)
	-- luaPrint("离开的筹码");
	-- luaDump(msg,"离开的筹码");
	self:setBRNNCancelBet(msg);
end

--庄家坐庄期间输赢金币
function BRNNInfo:onReceiveZhuangScoreMessage(data)
	local msg = convertToLua(data,GameMsg.BankGetMonry);
	luaDump(msg, "ZhuangScoreMessage________abc", 5)
	self:setBRNNZhuangScore(msg);
end

--续投失败
function BRNNInfo:onReceiveContinueFailMessage(data)
	luaPrint("onReceiveContinueFailMessage--------fail")
	self:setBRNNContinueFail();
end



return BRNNInfo;

