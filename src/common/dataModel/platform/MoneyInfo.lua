local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

local MoneyInfo = {}

function MoneyInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function MoneyInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function MoneyInfo:initData()
	self.cmdList = {
					{PlatformMsg.MDM_GP_PLAYER, PlatformMsg.ASS_GP_JIUJI_TIP},
					{PlatformMsg.MDM_GP_PLAYER, PlatformMsg.ASS_GP_GET_JIUJI}
					}

	BindTool.register(self, "moneyInfo", {})
	BindTool.register(self, "getMoney", {})

	self.AllJiuJiTimes = 0;
	self.JiuJiTimes = 0;
	self.jiujiNeed = 0;
	self.jiujiScore = 0;
end

function MoneyInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function MoneyInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function MoneyInfo:unregisterCmdNotify(mainID,subID)
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
end

function MoneyInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_GP_PLAYER then
		if subID == PlatformMsg.ASS_GP_JIUJI_TIP then
			self:onReceiveMoney(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_JIUJI then
			self:onReceiveGetMoney(data.data)
		end
	end
end

--请求救济金信息
function MoneyInfo:sendMoneyInfoRequest()
	self.tempMailList = {}
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER, PlatformMsg.ASS_GP_JIUJI_TIP, msg, PlatformMsg.MSG_P_GET_JIUJI)
end

--领取救济金
function MoneyInfo:sendGetMoneyRequest()
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER, PlatformMsg.ASS_GP_GET_JIUJI, msg, PlatformMsg.MSG_P_GET_JIUJI)
end

function MoneyInfo:onReceiveMoney(data)
	luaDump(data,"救济金信息")

	self:setMoneyInfo(data)
end

function MoneyInfo:onReceiveGetMoney(data)
	luaDump(data,"领取救济金")

	self:setGetMoney(data)
end

return MoneyInfo

