local RoomDeal = require("net.room.RoomDeal"):getInstance();

local HhdzInfo = {}

function HhdzInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function HhdzInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function HhdzInfo:initData()
	self.cmdList = {
		--//S-C
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_ERROR},--错误信息
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_GAME_BEGIN},--游戏开始
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NOTE_RESULT},--下注结果
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_OPEN_CARD},--开牌结算
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_SHANG_ZHUANG},--上庄
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_WU_ZHUANG},--无庄等待
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_NOTE_BACK},--退还下注
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ZHUANG_SCORE},--庄家坐庄期间输赢金币
			{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NOTE_RESULT_EX},--续投
	}

	BindTool.register(self, "ErrorCode", {});--错误信息
	BindTool.register(self, "GameBegin", {});--游戏开始
	BindTool.register(self, "NoteResult", {});--下注结果
	BindTool.register(self, "OpenCard", {});--开牌结算
	BindTool.register(self, "ShangZhuang", {});--上庄
	BindTool.register(self, "WuZhuang", {});--无庄等待
	BindTool.register(self, "NoteBack", {});--退还下注
	BindTool.register(self, "ZhuangScore", {});--庄家坐庄期间输赢金币
	BindTool.register(self, "XuTOU", {});--续投
end

function HhdzInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function HhdzInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function HhdzInfo:onReceiveCmdResponse(mainID, subID, object)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_ERROR then--错误信息
			self:ErrorCodeInfo(object);
		elseif subID == GameMsg.SUB_S_GAME_BEGIN then--游戏开始
			self:GameStartMessage(object);
		elseif subID == GameMsg.SUB_S_NOTE_RESULT then--下注结果
			self:ShowResultMessage(object);
		elseif subID == GameMsg.SUB_S_OPEN_CARD then--开牌结算
			self:OpenCardMessage(object);
		elseif subID == GameMsg.SUB_S_SHANG_ZHUANG then--上庄消息
			self:BankStateChange(object);
		elseif subID == GameMsg.SUB_S_WU_ZHUANG then--无庄等待
			self:WuZhuangWaitMessage(object);
		elseif subID == GameMsg.ASS_NOTE_BACK then--退还下注
			self:NoteBackInfo(object);
		elseif subID == GameMsg.ASS_ZHUANG_SCORE then--庄家坐庄期间输赢金币
			self:ZhuangScoreMessage(object);
		elseif subID == GameMsg.SUB_S_NOTE_RESULT_EX then--续投
			self:XuTouMessage(object);
		end
	end
end

--错误信息
function HhdzInfo:ErrorCodeInfo(object)
	local msg = convertToLua(object,GameMsg.Rc_ErrorCode);
	self:setErrorCode(msg);
end

--游戏开始
function HhdzInfo:GameStartMessage(object)
	local msg = convertToLua(object,GameMsg.tagBeginData);
	self:setGameBegin(msg);
end

--下注结果
function HhdzInfo:ShowResultMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_XiaZhuResultss);
	performWithDelay(display.getRunningScene(),function() self:setNoteResult(msg) end,0.1)
end

--开牌结算
function HhdzInfo:OpenCardMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_OpenCard);
	self:setOpenCard(msg);
end

--上庄消息
function HhdzInfo:BankStateChange(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_SXZhuang);
	self:setShangZhuang(msg);
end

--无庄等待
function HhdzInfo:WuZhuangWaitMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_Wait);
	self:setWuZhuang(msg);
end

--退还下注
function HhdzInfo:NoteBackInfo(object)
	local msg = convertToLua(object,GameMsg.Rc_Note_Back);
	self:setNoteBack(msg);
end

--庄家坐庄期间输赢金币
function HhdzInfo:ZhuangScoreMessage(object)
	local msg = convertToLua(object,GameMsg.BankGetMonry);
	self:setZhuangScore(msg);
end

--续投
function HhdzInfo:XuTouMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_XiaZhuResultEx);
	self:setXuTOU(msg);
end

return HhdzInfo;
