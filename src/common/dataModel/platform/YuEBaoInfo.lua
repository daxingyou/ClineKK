
-- 余额宝

local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()
local RoomDeal = require("net.room.RoomDeal"):getInstance()

local YuEBaoInfo = {}

function YuEBaoInfo:init()
	self:initData()

	self:registerCmdNotify()
end

--获取余额宝功能是否打开
function YuEBaoInfo:isOpenTransfer()
	return SettlementInfo:getConfigInfoByID(serverConfig.zhuanZhang) == 1
end

function YuEBaoInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function YuEBaoInfo:initData()
	self.temp = {}
	self.cmdList = {
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_SET_BANKPASS},
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_SCORE},
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_STORE_SCORE},
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_BANKLOG},
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_BANKREALTIME},
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_TRANSFER_INFO},
					{PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_TRANSFER_SCORE},
					}

	self.cmdListR = {
					{RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_GET_SCORE},
					{RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_STORE_SCORE}
					}

	BindTool.register(self, "bankPassword", false)
	BindTool.register(self, "getBankScore", {})
	BindTool.register(self, "storeBankScore", {})
	BindTool.register(self, "bankLog", {})
	BindTool.register(self, "YuEBao", {})
	BindTool.register(self, "UserInfo", {})
	BindTool.register(self, "TransferScore", {})
end

function YuEBaoInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end

	for k,v in pairs(self.cmdListR) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function YuEBaoInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end

	if isEmptyTable(self.cmdListR) then
		return
	end

	for k,v in pairs(self.cmdListR) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function YuEBaoInfo:unregisterCmdNotify(mainID,subID)
	local isHave = false

	for k,v in pairs(self.cmdList) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		PlatformDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end

	isHave = false

	for k,v in pairs(self.cmdListR) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		RoomDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end
end

function YuEBaoInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_GP_PLAYER then
		if subID == PlatformMsg.ASS_GP_SET_BANKPASS then
			self:onReceiveSetBankPassword(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_SCORE then
			self:onReceiveGetBankScore(data.data)
		elseif subID == PlatformMsg.ASS_GP_STORE_SCORE then
			self:onReceiveStoreBankScore(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_BANKLOG then
			self:onReceiveBankLog(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_BANKREALTIME then
			self:onReceiveYuEBao(data.data)
		elseif subID == PlatformMsg.ASS_GP_TRANSFER_INFO then
			self:onReceiveUserInfo(data.data);
		elseif subID == PlatformMsg.ASS_GP_TRANSFER_SCORE then
			self:onReceiveTransferScore(data.data);
		end
	elseif mainID == RoomMsg.MDM_GM_GAME_FRAME then
		if subID == RoomMsg.ASS_GET_SCORE then
			self:onReceiveGetBankScore(data.data)
		elseif subID == RoomMsg.ASS_STORE_SCORE then
			self:onReceiveStoreBankScore(data.data)
		end
	end
end

--设置密码
function YuEBaoInfo:sendSetBankPasswordRequest(pwd)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.MD5_BANKPASS = pwd
	msg.setType = 0
	luaDump(msg,"发送设置密码");
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_SET_BANKPASS,msg,PlatformMsg.MSG_P_SET_BANKPASS)
end

--校验密码
function YuEBaoInfo:sendCheckBankPasswordRequest(pwd)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.MD5_BANKPASS = pwd
	msg.setType = 1

	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_SET_BANKPASS,msg,PlatformMsg.MSG_P_SET_BANKPASS)
end

--取
function YuEBaoInfo:sendGetBankScoreRequest(money,pwd)
	local msg = {}

	if globalUnit.isEnterGame == true then
		msg.Score = money
		if pwd == nil then
			msg.MD5_BANKPASS = globalUnit:getBankPwd()
		else
			msg.MD5_BANKPASS = pwd
		end
		RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_GET_SCORE,msg,RoomMsg.CMD_C_GET_SCORE) --角色取分
	else
		msg.UserID = PlatformLogic.loginResult.dwUserID
		msg.Score = money
		msg.MD5_BANKPASS = globalUnit:getBankPwd()
		PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_SCORE,msg,PlatformMsg.MSG_P_GET_SCORE)
	end

	luaDump(msg,"qu")
end

--存
function YuEBaoInfo:sendStoreBankScoreRequest(money)
	local msg = {}

	if globalUnit.isEnterGame == true then
		msg.Score = money
		RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME,RoomMsg.ASS_STORE_SCORE,msg,RoomMsg.CMD_C_STORE_SCORE) --角色存分
	else
		msg.UserID = PlatformLogic.loginResult.dwUserID
		msg.Score = money
		PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_STORE_SCORE,msg,PlatformMsg.MSG_P_STORE_SCORE)
	end

	luaDump(msg,"cun")
end 

--银行明细
function YuEBaoInfo:sendBankLogRequest()
	self.temp = {}

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_BANKLOG,msg,PlatformMsg.MSG_P_GET_BANKLOG)
end

function YuEBaoInfo:onReceiveSetBankPassword(data)
	luaDump(data,"设置保险柜密码")
	self:setBankPassword(data)
end

function YuEBaoInfo:onReceiveGetBankScore(data)
	luaDump(data,"取钱结果")

	self:setGetBankScore(data)
	-- if data.ret == 0 then
	-- 	YuEBaoInfo:sendBankLogRequest()
	-- end
end

function YuEBaoInfo:onReceiveStoreBankScore(data)
	luaDump(data,"存钱结果")

	self:setStoreBankScore(data)
	-- if data.ret == 0 then
	-- 	YuEBaoInfo:sendBankLogRequest()
	-- end
end

function YuEBaoInfo:onReceiveBankLog(data)
	--luaDump(data,"余额宝明细")

	-- table.sort(data,function(a,b) return a.ColletTime < b.ColletTime end)
	self:setBankLog(data)
end

--获取余额宝信息
function YuEBaoInfo:sendYuEBaoRequest()
	self.temp = {}

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_BANKREALTIME,msg,PlatformMsg.MSG_P_GET_BANKREALTIME)
end
--余额宝信息
function YuEBaoInfo:onReceiveYuEBao(data)
	self:setYuEBao(data)
end

--对方信息
function YuEBaoInfo:onReceiveUserInfo(data)
	self:setUserInfo(data)
end

--转账返回
function YuEBaoInfo:onReceiveTransferScore(data)
	self:setTransferScore(data)
end

--余额宝转账
function YuEBaoInfo:onTransferMoney(phone,Score,pwd)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.phone = phone;
	msg.Score = Score;
	msg.MD5_BANKPASS = pwd;
	msg.TargetUserID = phone;
	luaDump(msg,"onTransferMoney");
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_TRANSFER_SCORE,msg,PlatformMsg.MSG_P_TRANSFER_SCORE)
end

--获取余额宝转账对方信息
function YuEBaoInfo:onRequestUserInfo(UserID)
	local msg = {};
	msg.TargetUserID = UserID;
	msg.Phone = "";
	luaDump(msg,"onRequestUserInfo");
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_TRANSFER_INFO,msg,PlatformMsg.MSG_P_TRANSFER_INFO)
end

return YuEBaoInfo
