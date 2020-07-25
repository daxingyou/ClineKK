
--飞禽走兽

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local FqzsInfo = {}

function FqzsInfo:init()
	self:initData();

	self:registerCmdNotify();
end


function FqzsInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function FqzsInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_BEGIN},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_XIAZHU},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_PLAY_GAME},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SHOW_RESULT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_CONTINUE_END},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_XIAZHU_RESULT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_SHANG_ZHUANG},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_WU_ZHUANG},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_CHANGE_NT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_CHANGE_NT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_USER_CUT},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ERROR_CODE},--错误信息
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_ZHUANG_SCORE},--庄家坐庄期间输赢金币
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.ASS_XIAZHU_RESULT_EX},--续投
					}

	BindTool.register(self, "gameBeginInfo", {});--游戏开始
	BindTool.register(self, "gameBeginXiazhuInfo", {});--开始下注
	BindTool.register(self, "gamePlayGameInfo", {});--开始游戏转盘
	BindTool.register(self, "xiazhuResultInfo", {});--下注结果
	BindTool.register(self, "showResultInfo", {});--结算
	BindTool.register(self, "shangzhuangResultInfo", {});--上下庄结果
	BindTool.register(self, "changeZhuangInfo", {});--换庄
	BindTool.register(self, "wuZhuangInfo", {});--无庄
	BindTool.register(self, "userCutInfo", {});--断线
	BindTool.register(self, "ErrorCode", {});--错误信息
	BindTool.register(self, "ZhuangScore", {});--庄家坐庄期间输赢金币
	BindTool.register(self, "XiazhuResultXT", {});--续投


	
	
end

function FqzsInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function FqzsInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function FqzsInfo:unregisterCmdNotify(mainID,subID)
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

function FqzsInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.ASS_BEGIN then
			self:onReceiveGameBeginInfo(data);
		elseif subID == GameMsg.ASS_XIAZHU then
			self:onReceiveGameBeginXiazhuInfo(data);
		elseif subID == GameMsg.ASS_PLAY_GAME then
			self:onReceivePlayGameInfo(data);
		elseif subID == GameMsg.ASS_SHOW_RESULT then
			self:onReceiveShowKaijiangInfo(data);
		elseif subID == GameMsg.ASS_CONTINUE_END then
			self:onReceiveShowResultInfo(data);
		elseif subID == GameMsg.ASS_XIAZHU_RESULT then
			self:onReceiveXiazhuResultInfo(data);
		elseif subID == GameMsg.ASS_SHANG_ZHUANG then
			self:onReceiveShangzhuangResultInfo(data);
		elseif subID == GameMsg.ASS_CHANGE_NT then
			self:onReceiveChangaZhuangInfo(data);
		elseif subID == GameMsg.ASS_WU_ZHUANG then
			self:onReceiveWuZhuangInfo(data);
		elseif subID == GameMsg.ASS_USER_CUT then
			self:onReceiveUserCutInfo(data);
		elseif subID == GameMsg.ASS_ERROR_CODE then--错误信息
			self:ErrorCodeInfo(data);
		elseif subID == GameMsg.ASS_ZHUANG_SCORE then--庄家坐庄期间输赢金币
			self:ZhuangScoreMessage(data);
		elseif subID == GameMsg.ASS_XIAZHU_RESULT_EX then--续投
			self:XiazhuResultXTMessage(data);
		end
	end
end

--游戏开始
function FqzsInfo:onReceiveGameBeginInfo(data)
	local msg = convertToLua(data,GameMsg.GameBeginStruct);
	-- luaDump(msg,"游戏开始")
	self:setGameBeginInfo(msg);
end

--开始下注
function FqzsInfo:onReceiveGameBeginXiazhuInfo(data)
	local msg = convertToLua(data,GameMsg.GameNote);
	-- luaDump(msg,"开始下注")
	self:setGameBeginXiazhuInfo(msg);
end

--开始游戏转盘
function FqzsInfo:onReceivePlayGameInfo(data)
	local msg = convertToLua(data,GameMsg.GamePlay);
	-- luaDump(msg,"开始游戏转盘")
	self:setGamePlayGameInfo(msg);
end

--下注结果
function FqzsInfo:onReceiveXiazhuResultInfo(data)
	local msg = convertToLua(data,GameMsg.GameXiaZhuRsp);
	-- luaDump(msg,"下注结果")
	self:setXiazhuResultInfo(msg);
end

--开奖
function FqzsInfo:onReceiveShowKaijiangInfo(data)
	
end

--上下庄结果
function FqzsInfo:onReceiveShangzhuangResultInfo(data)
	local msg = convertToLua(data,GameMsg.tagShangZhuang);
	-- luaDump(msg,"上下庄结果")
	self:setShangzhuangResultInfo(msg);
end

--结算
function FqzsInfo:onReceiveShowResultInfo(data)
	local msg = convertToLua(data,GameMsg.GameEndStruct);
	-- luaDump(msg,"结算")
	self:setShowResultInfo(msg);
end

--换庄
function FqzsInfo:onReceiveChangaZhuangInfo(data)
	local msg = convertToLua(data,GameMsg.tagChangeZhuang);
	-- luaDump(msg,"换庄")
	self:setChangeZhuangInfo(msg);
end

function FqzsInfo:onReceiveWuZhuangInfo(data)
	self:setWuZhuangInfo(data);
end

--断线
function FqzsInfo:onReceiveUserCutInfo(data)
	local msg = convertToLua(data,GameMsg.bCutStruct);
	luaDump(msg,"断线")
	self:setUserCutInfo(data);
end

--错误信息
function FqzsInfo:ErrorCodeInfo(data)
	local msg = convertToLua(data,GameMsg.Rc_ErrorCode);
	luaDump(msg,"错误信息")
	self:setErrorCode(msg);
end

--庄家坐庄期间输赢金币
function FqzsInfo:ZhuangScoreMessage(object)
	local msg = convertToLua(object,GameMsg.BankGetMonry);
	self:setZhuangScore(msg);
end

function FqzsInfo:XiazhuResultXTMessage(object)
	local msg = convertToLua(object,GameMsg.Rc_Packet_XiaZhuResultEx);
	luaDump(msg,"续投rev")
	self:setXiazhuResultXT(msg);
end

--下注
function FqzsInfo:sendNote(type,num)
	local msg = {}
	msg.iType = type;
	msg.iNoteNum = num;
	luaDump(msg,"sendNote")
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_XIAZHU_RESULT, msg, GameMsg.GameXiaZhu);
end

--上下庄
function FqzsInfo:sendRspZhuang(isshang,bCancel)
	local msg = {}
	msg.bCancel = bCancel;
	msg.shang = isshang;
	msg.IsRobot = false;
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_SHANG_ZHUANG, msg, GameMsg.ShangZhuangRsp);
end

--续投
function FqzsInfo:sendXutou(data)
	local msg = {}
	msg.money = data;
	luaDump(msg,"续投")
    RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.ASS_XIAZHU_RESULT_EX, msg, GameMsg.Cr_Packet_XiaZhuEx);
end

return FqzsInfo;

