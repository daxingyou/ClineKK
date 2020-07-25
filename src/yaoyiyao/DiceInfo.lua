local RoomDeal = require("net.room.RoomDeal"):getInstance();

local DiceInfo = {}

function DiceInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function DiceInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function DiceInfo:initData()
	self.cmdList = {
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_XIA_ZHU},--下注消息
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_GAME_ANIMATE},--动画消息
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SHOW_RESULT},--显示结算信息时间
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SHANG_ZHUANG},--上庄消息
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SB_BEGIN},--开始消息
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ERROR_CODE},--错误信息
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_WU_ZHUANG},--无庄等待
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_NOTE_BACK},--退还下注
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ZHUANG_SCORE},--庄家坐庄期间输赢金币
				{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_XIA_ZHU_EX},--续投
			}

	BindTool.register(self, "BankState", {});--上庄消息
	BindTool.register(self, "PutChip", {});--下注信息
	BindTool.register(self, "DiceGameStart", {});--游戏开始信息
	BindTool.register(self, "GameAnimate", {});--动画消息
	BindTool.register(self, "ResultMessage", {});--显示结算
	BindTool.register(self, "ErrorCode", {});--错误信息
	BindTool.register(self, "NoBankWait", {});--无庄等待
	BindTool.register(self, "NoteBack", {});--退还下注
	BindTool.register(self, "ZhuangScore", {});--庄家坐庄期间输赢金币
	BindTool.register(self, "XuTOU", {});--续投
end

function DiceInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function DiceInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function DiceInfo:onReceiveCmdResponse(mainID, subID, object)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.ASS_XIA_ZHU then--下注消息
			self:PutChipMessage(object);
		elseif subID == GameMsg.ASS_GAME_ANIMATE then--动画消息
			self:GameAnimateMessage(object);
		elseif subID == GameMsg.ASS_SHOW_RESULT then--显示结算信息时间
			self:ShowResultMessage(object);
		elseif subID == GameMsg.ASS_SHANG_ZHUANG then--上庄消息
			self:BankStateChange(object);
		elseif subID == GameMsg.ASS_SB_BEGIN then--开始消息
			self:DiceGameStartMessage(object);
		elseif subID == GameMsg.ASS_ERROR_CODE then--错误信息
			self:ErrorCodeInfo(object);
		elseif subID == GameMsg.ASS_WU_ZHUANG then--断线消息
			self:NoBankWaitInfo(object);
		elseif subID == GameMsg.ASS_NOTE_BACK then--退还下注
			self:NoteBackInfo(object);
		elseif subID == GameMsg.ASS_ZHUANG_SCORE then--庄家坐庄期间输赢金币
			self:ZhuangScoreMessage(object);
		elseif subID == GameMsg.ASS_XIA_ZHU_EX then--续投
			self:XuTouMessage(object);
		end
	end
end
--下注信息
function DiceInfo:PutChipMessage(object)

	local msg = convertToLua(object,GameMsg.Rc_Packet_XiaZhuResultss);
	self:setPutChip(msg);
end
--上庄消息
function DiceInfo:BankStateChange(object)
	local msg = convertToLua(object,GameMsg.tagShangZhuang);
	self:setBankState(msg);
end
--游戏开始
function DiceInfo:DiceGameStartMessage(object)
	local msg = convertToLua(object,GameMsg.tagBeginData);
	self:setDiceGameStart(msg);
end
--动画消息
function DiceInfo:GameAnimateMessage(object)
	local msg = convertToLua(object,GameMsg.SendSeziStruct);
	self:setGameAnimate(msg);
end
--显示结算
function DiceInfo:ShowResultMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_CompareResult);
	self:setResultMessage(msg);
end
--错误信息
function DiceInfo:ErrorCodeInfo(object)
	local msg = convertToLua(object,GameMsg.Rc_ErrorCode);
	self:setErrorCode(msg);
end
--玩家断线
function DiceInfo:NoBankWaitInfo(object)
	self:setNoBankWait(object);
end
--退还下注
function DiceInfo:NoteBackInfo(object)
	local msg = convertToLua(object,GameMsg.Rc_Note_Back);
	self:setNoteBack(msg);
end

--庄家坐庄期间输赢金币
function DiceInfo:ZhuangScoreMessage(object)
	local msg = convertToLua(object,GameMsg.BankGetMonry);
	self:setZhuangScore(msg);
end

--续投
function DiceInfo:XuTouMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_XiaZhuResultEx);
	self:setXuTOU(msg);
end

return DiceInfo;
