local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

local ExtendInfo = {}

function ExtendInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function ExtendInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function ExtendInfo:initData()
	self.cmdList = {
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_TOTAL},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_DETAIL},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_NEEDLEVEL},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_ACHIEVE},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_REWARD},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PROVISIONS},
					{PlatformMsg.MDM_CASH,PlatformMsg.ASS_GP_GET_CASH},
					{PlatformMsg.MDM_CASH,PlatformMsg.ASS_GP_GET_CASH_LOG},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARD_LEVEL},
					}

	BindTool.register(self, "ExtendTotalCount", {})
	BindTool.register(self, "ExtendDetail", {})
	BindTool.register(self, "NeedLevelExp", {})
	BindTool.register(self, "ExtendAchieve", {})
	BindTool.register(self, "ExtendReward", {})
	BindTool.register(self, "ExtendProvisions", {})
	BindTool.register(self, "ReceiveGetCash", {})
	BindTool.register(self, "ReceiveGetCashLog", {})
	BindTool.register(self, "userAgencyLevel", {})

	self.saveExtendDetail = {};
	self.saveNeedLevel = {};
	self.saveAchieve = {};
	self.saveReward = {};
	self.saveCashLog = {};

	--保存更新时间戳
	self.mSaveDetailTime = 0;
	--保存更新的数据
	self.mSaveDetailData = nil;
end

function ExtendInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function ExtendInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

function ExtendInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_AGENCY then
		if subID == PlatformMsg.ASS_GP_GET_TOTAL then
			self:onReceiveExtendTotalCount(data)
		elseif subID == PlatformMsg.ASS_GP_GET_DETAIL then
			self:onReceiveExtendDetail(data)
		elseif subID == PlatformMsg.ASS_GP_GET_NEEDLEVEL then
			self:onReceiveGetNeedLevel(data)
		elseif subID == PlatformMsg.ASS_GP_GET_ACHIEVE then
			self:onReceiveAchieve(data)
		elseif subID == PlatformMsg.ASS_GP_GET_REWARD then
			self:onReceiveReward(data)
		elseif subID == PlatformMsg.ASS_GP_GET_PROVISIONS then
			self:onReceiveProvision(data)
		elseif subID == PlatformMsg.ASS_GP_GET_AGENCYREWARD_LEVEL then
			self:onReceiveUserAgencyLevel(data)
		end
	elseif mainID == PlatformMsg.MDM_CASH then
		if subID == PlatformMsg.ASS_GP_GET_CASH then
			self:onReceiveGetCash(data.data)
		elseif subID == PlatformMsg.ASS_GP_GET_CASH_LOG then
			self:onReceiveGetCashLog(data)
		end
	end
end

--代理人数
function ExtendInfo:sendExtendTotalCountRequest()
	local msg = {};

	msg.UserID = PlatformLogic.loginResult.dwUserID;

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_TOTAL,msg,PlatformMsg.MSG_GP_GET_TOTAL);
end

--我的玩家
function ExtendInfo:sendExtendDetailRequest()
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_DETAIL,msg,PlatformMsg.MSG_GP_GET_TOTAL);
end

--奖励配置
function ExtendInfo:sendGetNeedLevelRequest()
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_NEEDLEVEL);
end

--我的业绩
function ExtendInfo:sendExtendAchieveRequest()
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_ACHIEVE,msg,PlatformMsg.MSG_GP_GET_TOTAL);
end

--我的奖励
function ExtendInfo:sendExtendRewardRequest()
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_REWARD,msg,PlatformMsg.MSG_GP_GET_TOTAL);
end

--发送提现
function ExtendInfo:sendGetCash(iType,lScore)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.bType = iType;
	msg.lScore = lScore;

	luaDump(msg,"发送提现")

	PlatformLogic:send(PlatformMsg.MDM_CASH,PlatformMsg.ASS_GP_GET_CASH,msg,PlatformMsg.MSG_GP_GET_CASH);
end

--发送预提现
function ExtendInfo:sendGetProvisions(lScore)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.lScore = lScore;

	luaDump(msg,"发送预提现")

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PROVISIONS,msg,PlatformMsg.MSG_GP_GET_PROVISIONS);
end

function ExtendInfo:sendUserAgencyLevel()
	local msg = {}
	msg.nUserID = PlatformLogic.loginResult.dwUserID

	luaDump(msg)

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARD_LEVEL,msg,PlatformMsg.MSG_GET_AGENCY_LEVEL);
end

--发送提现记录
function ExtendInfo:sendGetCashLog(iType)
	local msg = {};
	msg.UserID = PlatformLogic.loginResult.dwUserID;
	msg.bType = iType;

	PlatformLogic:send(PlatformMsg.MDM_CASH,PlatformMsg.ASS_GP_GET_CASH_LOG,msg,PlatformMsg.MSG_GP_GET_CASH_LOG);
end

function ExtendInfo:onReceiveExtendTotalCount(data)
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_TOTAL);
	luaDump(msg,"获取总人数");
	self:setExtendTotalCount(msg);
end

function ExtendInfo:onReceiveExtendDetail(data)

	local handCode = data:getHead(4);

	local size1 = data:getHead(1)-20
	local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_DETAIL)
	local num = size1/size2;

	for i = 1,num do
		local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_DETAIL);
		table.insert(self.saveExtendDetail,msg);
	end
	

	if handCode == 1 then
		luaDump(self.saveExtendDetail,"获取明细");
		self:setExtendDetail(self.saveExtendDetail);
		self.saveExtendDetail = {};
	end
end

function ExtendInfo:onReceiveGetNeedLevel(data)
	local size1 = data:getHead(1)-20
	local size2 = getObjSize(PlatformMsg.MSG_GET_NEED_LEVEL)
	local num = size1/size2;

	for i = 1,num do
		local msg = convertToLua(data,PlatformMsg.MSG_GET_NEED_LEVEL);
		table.insert(self.saveNeedLevel,msg);
	end
	

	luaDump(self.saveNeedLevel,"获取经验");
	self:setNeedLevelExp(self.saveNeedLevel);
	self.saveNeedLevel = {};
end

function ExtendInfo:onReceiveAchieve(data)

	local handCode = data:getHead(4);

	local size1 = data:getHead(1)-20
	local size2 = getObjSize(PlatformMsg.MSG_GET_ACHIEVE)
	local num = size1/size2;

	for i = 1,num do
		local msg = convertToLua(data,PlatformMsg.MSG_GET_ACHIEVE);
		table.insert(self.saveAchieve,msg);
	end
	
	if handCode == 1 then
		luaDump(self.saveAchieve,"获取业绩");
		self:setExtendAchieve(self.saveAchieve);
		self.saveAchieve = {};
	end
end

function ExtendInfo:onReceiveReward(data)
	local handCode = data:getHead(4);

	local size1 = data:getHead(1)-20
	local size2 = getObjSize(PlatformMsg.MSG_GET_REWARD)
	local num = size1/size2;

	for i = 1,num do
		local msg = convertToLua(data,PlatformMsg.MSG_GET_REWARD);
		table.insert(self.saveReward,msg);
	end
	
	if handCode == 1 then
		luaDump(self.saveReward,"获取奖励");
		self:setExtendReward(self.saveReward);
		self.saveReward = {};
	end
end

--提现
function ExtendInfo:onReceiveGetCash(data)
	self:setReceiveGetCash(data);
end

--提现
function ExtendInfo:onReceiveProvision(data)
	local msg = convertToLua(data,PlatformMsg.MSG_GP_SETTLEMENT)
	self:setExtendProvisions(msg);
end

function ExtendInfo:onReceiveUserAgencyLevel(data)
	local msg = convertToLua(data,PlatformMsg.MSG_GET_AGENCY_LEVEL)
	self:setUserAgencyLevel(msg)
end

--提现记录
function ExtendInfo:onReceiveGetCashLog(data)
	local handCode = data:getHead(4);

	local size1 = data:getHead(1)-20
	local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_CASH_LOG)
	local num = size1/size2;

	for i = 1,num do
		local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_CASH_LOG);
		table.insert(self.saveCashLog,msg);
	end

	if handCode == 1 then
		luaDump(self.saveCashLog,"提现记录");
		self:setReceiveGetCashLog(self.saveCashLog);
		self.saveCashLog = {};
	end
end

return ExtendInfo
