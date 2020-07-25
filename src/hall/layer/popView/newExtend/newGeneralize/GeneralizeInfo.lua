local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

local GeneralizeInfo = {}

function GeneralizeInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function GeneralizeInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function GeneralizeInfo:initData()
	-- self.temp = {}
	self.cmdList = {
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_TOTAL_FORMODEB},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_DETAIL_FORMODEB},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARD_FORMODEB},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARDLOG_FORMODEB},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARDRANK_FORMODEB},
					
					}

	BindTool.register(self, "NewGeneralizeTotal", {})
	BindTool.register(self, "NewGeneralizeDetail", {})
	BindTool.register(self, "NewGeneralizeReward", {})
	BindTool.register(self, "NewGeneralizeRewardLog", {})
	BindTool.register(self, "NewGeneralizeRewardRank", {})
	

end

function GeneralizeInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function GeneralizeInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function GeneralizeInfo:unregisterCmdNotify(mainID,subID)
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

function GeneralizeInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_AGENCY then
		
		if subID == PlatformMsg.ASS_GP_GET_TOTAL_FORMODEB then --获取总人数
			self:onReceiveGetTotal(data)
		elseif subID == PlatformMsg.ASS_GP_GET_DETAIL_FORMODEB then--获取明细
			self:onReceiveGetDetail(data)
		elseif subID == PlatformMsg.ASS_GP_GET_AGENCYREWARD_FORMODEB then--提取奖励
			self:onReceiveGetAgencyReward(data)
		elseif subID == PlatformMsg.ASS_GP_GET_AGENCYREWARDLOG_FORMODEB then--提取奖励记录
			self:onReceiveGetAgencyRewardLog(data)
		elseif subID == PlatformMsg.ASS_GP_GET_AGENCYREWARDRANK_FORMODEB then--奖励周排行
			self:onReceiveGetAgencyRewardRank(data)
		
		end
	end
end

--获取总人数
function GeneralizeInfo:onReceiveGetTotal(data)
	
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_TOTALFORB)
	luaDump(msg,"获取总人数");
	self:setNewGeneralizeTotal(msg)
end

--获取明细
function GeneralizeInfo:onReceiveGetDetail(data)
	self.detailLog = {};
	local handCode = data:getHead(4);
    local size1 = data:getHead(1)-20
    local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_DETAILFORB)
    local num = size1/size2;
    
    for i = 1,num do
        local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_DETAILFORB);
        table.insert(self.detailLog,msg);
    end
    luaPrint("handCode",handCode);
    if handCode == 1 then
        self:setNewGeneralizeDetail(self.detailLog)
        luaDump(self.detailLog,"获取明细");
        self.detailLog = {};
    end
end

function GeneralizeInfo:onReceiveGetAgencyReward(data)
	luaPrint("提取奖励");
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_AGENCYREWARDFORB)
	luaDump(msg)
	self:setNewGeneralizeReward(msg)
end

function GeneralizeInfo:onReceiveGetAgencyRewardLog(data)
	self.rewardLog = {};
	local handCode = data:getHead(4);
    local size1 = data:getHead(1)-20
    local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_AGENCYREWARDLOGFORB)
    local num = size1/size2;
    
    for i = 1,num do
        local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_AGENCYREWARDLOGFORB);
        table.insert(self.rewardLog,msg);
    end
    luaPrint("handCode",handCode);
    if handCode == 1 then
        self:setNewGeneralizeRewardLog(self.rewardLog)
        luaDump(self.rewardLog,"提取奖励记录")
        self.rewardLog = {};
    end
end

function GeneralizeInfo:onReceiveGetAgencyRewardRank(data)
	self.rankLog = {}
	local handCode = data:getHead(4);
    local size1 = data:getHead(1)-20
    local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_AGENCYREWARDRANKFORB)
    local num = size1/size2;
    
    for i = 1,num do
        local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_AGENCYREWARDRANKFORB);
        table.insert(self.rankLog,msg);
    end
    luaPrint("handCode",handCode);
    if handCode == 1 then
        self:setNewGeneralizeRewardRank(self.rankLog)
        luaDump(self.rankLog,"奖励周排行");
        self.rankLog = {};
    end
 
end

----------------------------------------------------------------
--获取总人数
function GeneralizeInfo:sendGetNewGeneralizeTotalRequest()

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_TOTAL_FORMODEB,msg,PlatformMsg.MSG_GP_GET_TOTALFORB)
end

--获取明细
function GeneralizeInfo:sendGetNewGeneralizeDetailRequest(day)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.Day = day;
	luaDump(msg,"获取明细");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_DETAIL_FORMODEB,msg,PlatformMsg.MSG_GP_GET_DETAILFORB)
end

--提取奖励
function GeneralizeInfo:sendGetNewGeneralizeRewardRequest()

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	luaDump(msg,"提取奖励");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARD_FORMODEB,msg,PlatformMsg.MSG_GP_GET_AGENCYREWARDFORB)
end

--提取奖励记录
function GeneralizeInfo:sendGetNewGeneralizeRewardLogRequest()

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	luaDump(msg,"获取玩家信息");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARDLOG_FORMODEB,msg,PlatformMsg.MSG_GP_GET_AGENCYREWARDLOGFORB)
end

--奖励周排行
function GeneralizeInfo:sendGetNewGeneralizeRewardBankRequest()

	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_AGENCYREWARDRANK_FORMODEB)
end


return GeneralizeInfo
