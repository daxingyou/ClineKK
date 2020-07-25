local RoomDeal = require("net.room.RoomDeal"):getInstance();

local Common   = require("sanzhangpai.Common");

local SZPInfo = {}

function SZPInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function SZPInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function SZPInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()
	luaDump(self.cmdList, "self.cmdList----------", 6)
	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end
function SZPInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BEGIN_UPGRADE},		--游戏开始
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SEND_CARD},		--发牌信息
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_GAME_PLAY},		--开始游戏  开始下注
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_CONTINUE_END},		--游戏结束

					-- {RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_VREB_CHECK},		--用户处理

					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_NOTE},				--下注
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_NOTE_RESULT},		--下注结果
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_LOOK_CARD},			--看牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_MING_CARD},			--亮牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BIPAI_MAP_CARD},	--比牌亮牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BIPAI_RESULT},		--比牌结果
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_FINISH_COMPARE},		--全局比牌
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BIPAI_REQ},			--比牌申请
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_AUTO_FOLLOW},		--自动跟注
					
	}


	BindTool.register(self, "SZPBeginUpgrade", {});		--游戏开始
	BindTool.register(self, "SZPSendCard", {});			--发牌信息
	BindTool.register(self, "SZPGamePlay", {});			--开始游戏
	BindTool.register(self, "SZPContinueEnd", {});		--游戏结束
	
	BindTool.register(self, "SZPNote", {});				--下注
	BindTool.register(self, "SZPNoteResult", {});		--下注结果
	BindTool.register(self, "SZPLookCard", {});			--看牌
	BindTool.register(self, "SZPMingCard", {});			--亮牌
	BindTool.register(self, "SZPBipaiResult", {});		--比牌结果
	BindTool.register(self, "SZPFinishCompare", {});	--全局比牌
	BindTool.register(self, "SZPBipaiReq", {});			--比牌申请
	BindTool.register(self, "SZPOpponentCard", {});		--比牌亮牌
	BindTool.register(self, "SZPAutoFollow", {});		--自动跟注

	
	


end
--注销本表注册的所有事件
function SZPInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function SZPInfo:onReceiveCmdResponse(mainID, subID, data)
	luaPrint("SZPInfo:onReceiveCmdResponse-----",mainID,subID)
	luaPrint("subID,GameMsg.ASS_SEND_CARD,",subID,GameMsg.ASS_SEND_CARD)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.ASS_BEGIN_UPGRADE then -- 游戏开始
			self:onReceiveBeginUpgrade(data);

		elseif subID == GameMsg.ASS_SEND_CARD then 	--发牌信息
			luaPrint("subID == GameMsg.ASS_SEND_CARD")
			self:onReceiveSendCard(data);

		elseif subID == GameMsg.ASS_GAME_PLAY then 	--开始游戏
			self:onReceiveGamePlay(data);

		elseif subID == GameMsg.ASS_CONTINUE_END then 	--游戏结束
			self:onReceiveContinueEnd(data);

		elseif subID == GameMsg.ASS_NOTE then 	--通知下注
			self:onReceiveNote(data);

		elseif subID == GameMsg.ASS_NOTE_RESULT then 	--下注结果
			self:onReceiveNoteResult(data);

		elseif subID == GameMsg.ASS_LOOK_CARD then 	--看牌
			self:onReceiveLookCard(data);

		elseif subID == GameMsg.ASS_MING_CARD then 	--亮牌
			self:onReceiveMingCard(data);
		elseif subID == GameMsg.ASS_BIPAI_MAP_CARD then 	--比牌亮牌
			self:onReceiveOpponentCard(data);

		elseif subID == GameMsg.ASS_BIPAI_RESULT then 	--比牌结果
			self:onReceiveBipaiResult(data);

		elseif subID == GameMsg.ASS_FINISH_COMPARE then 	--全局比牌
			self:onReceiveFinishCompare(data);

		elseif subID == GameMsg.ASS_BIPAI_REQ then 		--比牌请求
			
			self:onReceiveBipaiReq(data);--SZPBipaiReq

		elseif subID == GameMsg.ASS_AUTO_FOLLOW then 		--自动下注
			self:onReceiveAutoFollow(data);			--
		end
	end
end




-- 游戏开始
function SZPInfo:onReceiveBeginUpgrade(data)
	local msg = convertToLua(data,GameMsg.BeginUpgradeStruct)
	luaDump(msg,"游戏开始_onReceiveBeginUpgrade");
	msg.id = Common.MSG_BEGIN_GAME;
	self:setSZPBeginUpgrade(msg);
end

-- 发牌信息
function SZPInfo:onReceiveSendCard(data)
	luaPrint("SZPInfo:onReceiveSendCard")
	local msg = convertToLua(data,GameMsg.SendCardStruct)
	luaDump(msg,"发牌信息_onReceiveSendCard");
	msg.id = Common.MSG_SEND_CARD;
	self:setSZPSendCard(msg);
end

-- 开始游戏下注
function SZPInfo:onReceiveGamePlay(data)
	local msg = convertToLua(data,GameMsg.BeginPlayStruct)
	luaDump(msg,"开始游戏_onReceiveGamePlay");
	msg.id = Common.MSG_BEGIN_BET;
	self:setSZPGamePlay(msg);
end

-- 1532596976
-- 游戏结束
function SZPInfo:onReceiveContinueEnd(data)
	local msg = convertToLua(data,GameMsg.GameEndStruct)
	luaDump(msg,"游戏结束_onReceiveContinueEnd");
	msg.id = Common.MSG_GAME_END;
	self:setSZPContinueEnd(msg);
end

-- 通知下注
function SZPInfo:onReceiveNote(data)
	luaPrint("SZPInfo:onReceiveNote")
	local msg = convertToLua(data,GameMsg.tagUserResult)
	luaDump(msg,"通知下注_onReceiveNote");
	msg.id = Common.MSG_TURN_BET;
	self:setSZPNote(msg);
end

-- 下注结果
function SZPInfo:onReceiveNoteResult(data)
	local msg = convertToLua(data,GameMsg.Rc_NoteResult)
	luaDump(msg,"下注结果_onReceiveNoteResult");
	msg.id = Common.MSG_PLAYER_BET;
	if msg.iVerbType == GameMsg.TYPE_NOTE then
		luaPrint("下注")
	elseif msg.iVerbType == GameMsg.TYPE_ADD then
		luaPrint("加注")
	elseif msg.iVerbType == GameMsg.TYPE_FOLLOW then
		luaPrint("跟注")
	elseif msg.iVerbType == GameMsg.TYPE_GIVE_UP then
		luaPrint("弃牌")
	end


	self:setSZPNoteResult(msg);
end


--看牌 onReceiveLookCard
function SZPInfo:onReceiveLookCard(data)
	local msg = convertToLua(data,GameMsg.Rc_LookCard)
	luaDump(msg,"看牌_onReceiveLookCard");
	msg.id = Common.MSG_CHECK_CARD;
	self:setSZPLookCard(msg);
end

--亮牌
function SZPInfo:onReceiveMingCard(data)
	luaPrint("SZPInfo:onReceiveMingCard")
	local msg = convertToLua(data,GameMsg.Rc_MingCard)
	luaDump(msg,"亮牌_onReceiveMingCard");
	msg.id = Common.MSG_EVEAL_CARD;
	self:setSZPMingCard(msg);
end


--比牌亮牌
function SZPInfo:onReceiveOpponentCard(data)
	luaPrint("SZPInfo:onReceiveOpponentCard")
	local msg = convertToLua(data,GameMsg.Rc_BiPaiMapCard)
	luaDump(msg,"比牌亮牌_onReceiveOpponentCard");
	msg.id = Common.MSG_OPPONENT_CARD;
	self:setSZPOpponentCard(msg);
end


--比牌结果
function SZPInfo:onReceiveBipaiResult(data)
	local msg = convertToLua(data,GameMsg.Rc_CompareResult)
	luaDump(msg,"比牌结果_onReceiveNoteResult");
	msg.id = Common.MSG_COMP_CARD;
	self:setSZPBipaiResult(msg);
end


--全局比牌
function SZPInfo:onReceiveFinishCompare(data)
	local msg = convertToLua(data,GameMsg.Rc_CompareFinish)
	luaDump(msg,"全局比牌_Rc_CompareFinish");
	msg.id = Common.MSG_ALL_COMPARE;
	self:setSZPFinishCompare(msg);
end


--比牌申请
function SZPInfo:onReceiveBipaiReq(data)
	local msg = convertToLua(data,GameMsg.Rc_CompareReq)
	luaDump(msg,"请求比牌消息_onReceiveBipaiReq");
	msg.id = Common.MSG_REQ_COMPARE;
	self:setSZPBipaiReq(msg);
	
end


--自动下注
function SZPInfo:onReceiveAutoFollow(data)
	local msg = convertToLua(data,GameMsg.AutoFollow)
	luaDump(msg,"自动跟注消息_onReceiveBipaiReq");
	msg.id = Common.MSG_AUTO_BET;
	self:setSZPAutoFollow(msg);


end

return SZPInfo;

