local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

local PartnerInfo = {}

function PartnerInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function PartnerInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function PartnerInfo:initData()
	self.PartnerLog = {}; --合伙人明细
	self.PartnerDetailLog = {};--玩家明细
	self.extendDetailList = {}
	self.temp = {}
	self.cmdList = {
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_TOTAL},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_DETAIL},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_NEEDLEVEL},

					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERINFO},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERSCORE},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_STORE_PARTNERSCORE},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERUSERINFO},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERUSERINFODETAIL},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_OPEN_PARTNER},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_UPDATE_PARTNERTIME},
					{PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_UPDATE_PARTNERTIME_TEMP},

					}

	BindTool.register(self, "extendTotalCount", {})
	BindTool.register(self, "extendDetail", {})
	BindTool.register(self, "extendYesterdayDetail", {})
	BindTool.register(self, "needLevelExp", {})

	BindTool.register(self, "PartnerInfor", {})
	BindTool.register(self, "PartnerScore", {})
	BindTool.register(self, "AddPartnerScore", {})
	BindTool.register(self, "PartnerUserInfo", {})
	BindTool.register(self, "PartnerUserInfoDetail", {})
	BindTool.register(self, "OpenPartner", {})
	BindTool.register(self, "UpdatePartnerTime", {})
	BindTool.register(self, "UpdatePartnerTime_temp", {})

end

function PartnerInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function PartnerInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function PartnerInfo:unregisterCmdNotify(mainID,subID)
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

function PartnerInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_AGENCY then
		
		if subID == PlatformMsg.ASS_GP_GET_PARTNERINFO then--获取合伙人信息
			self:onReceiveGetPartnerInfo(data)
		elseif subID == PlatformMsg.ASS_GP_GET_PARTNERSCORE then--资金池转入余额宝
			self:onReceiveGetPartnerScore(data)
		elseif subID == PlatformMsg.ASS_GP_STORE_PARTNERSCORE then--余额宝转入资金池
			self:onReceiveGetAddPartnerScore(data)
		elseif subID == PlatformMsg.ASS_GP_GET_PARTNERUSERINFO then--获取合伙人玩家信息
			self:onReceiveGetPartnerUserInfo(data)
		elseif subID == PlatformMsg.ASS_GP_GET_PARTNERUSERINFODETAIL then--获取合伙人玩家详细信息
			self:onReceiveGetPartnerUserInfoDetail(data)
		elseif subID == PlatformMsg.ASS_GP_OPEN_PARTNER then--开启合伙人功能
			self:onReceiveOpenPartner(data)
		elseif subID == PlatformMsg.ASS_GP_UPDATE_PARTNERTIME then--开启合伙人时间
			self:onReceiveUpdatePartnerTime(data)
		elseif subID == PlatformMsg.ASS_GP_UPDATE_PARTNERTIME_TEMP then --半个小时到刷新时间
			self:onReceiveUpdatePartnerTime_temp(data);
		end
	end
end

function PartnerInfo:onReceiveGetPartnerInfo(data)
	luaPrint("获取合伙人信息");
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_PARTNERINFO)
	self:setPartnerInfor(msg)
end

function PartnerInfo:onReceiveGetPartnerScore(data)
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_PARTNERSCORE)
	self:setPartnerScore(msg)
end

function PartnerInfo:onReceiveGetAddPartnerScore(data)
	luaPrint("存钱");
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_STORE_PARTNERSCORE)
	self:setAddPartnerScore(msg)
end

function PartnerInfo:onReceiveGetPartnerUserInfo(data)
	local handCode = data:getHead(4);
    local size1 = data:getHead(1)-20
    local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFO)
    local num = size1/size2;
    
    for i = 1,num do
        local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFO);
        table.insert(self.PartnerLog,msg);
    end
    luaPrint("handCode",handCode);
    if handCode == 1 then
        self:setPartnerUserInfo(self.PartnerLog)
        self.PartnerLog = {};
    end
end

function PartnerInfo:onReceiveGetPartnerUserInfoDetail(data)
	local handCode = data:getHead(4);
    local size1 = data:getHead(1)-20
    local size2 = getObjSize(PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFODETAIL)
    local num = size1/size2;
    
    for i = 1,num do
        local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFODETAIL);
        table.insert(self.PartnerDetailLog,msg);
    end
    luaPrint("handCode",handCode);
    if handCode == 1 then
        self:setPartnerUserInfoDetail(self.PartnerDetailLog)
        self.PartnerDetailLog = {};
    end
 -- 	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_GET_PARTNERUSERINFODETAIL);
	-- self:setPartnerUserInfoDetail(msg)
end

function PartnerInfo:onReceiveOpenPartner(data)
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_OPEN_PARTNER)
	self:setOpenPartner(msg)
end

function PartnerInfo:onReceiveUpdatePartnerTime(data)
	local msg = convertToLua(data,PlatformMsg.MSG_GP_S_UPDATE_PARTNERTIME)
	self:setUpdatePartnerTime(msg)
end

function PartnerInfo:onReceiveUpdatePartnerTime_temp(data)
	self:setUpdatePartnerTime_temp(data)
end

----------------------------------------------------------------
--获取合伙人信息
function PartnerInfo:sendGetPartnerInfoRequest(Score)

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERINFO,msg,PlatformMsg.MSG_GP_GET_PARTNERINFO)
end

--资金池转入余额宝
function PartnerInfo:sendGetPartnerScoreRequest(Score)

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.lScore = Score;
	luaDump(msg,"取钱");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERSCORE,msg,PlatformMsg.MSG_GP_GET_PARTNERSCORE)
end

--余额宝转入资金池
function PartnerInfo:sendGetAddPartnerScoreRequest(Score)

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.lScore = Score;
	luaDump(msg,"存钱");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_STORE_PARTNERSCORE,msg,PlatformMsg.MSG_GP_STORE_PARTNERSCORE)
end

--获取合伙人玩家信息
function PartnerInfo:sendGetPartnerUserInfoRequest(Day)

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.Day = Day;
	luaDump(msg,"获取玩家信息");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERUSERINFO,msg,PlatformMsg.MSG_GP_GET_PARTNERUSERINFO)
end

--获取合伙人玩家详细信息
function PartnerInfo:sendGetPartnerUserInfoDetailRequest(DownUserID,Day)

	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.DownUserID = DownUserID;
	msg.Day = Day;
	luaDump(msg,"获取获取合伙信息");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_GET_PARTNERUSERINFODETAIL,msg,PlatformMsg.MSG_GP_GET_PARTNERUSERINFODETAIL)
end

--开启合伙人功能
function PartnerInfo:sendGetOpenPartnerRequest(Rat,MaxWin,bType)
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.Rat = Rat*10;
	msg.bType = bType;
	msg.PartnerMaxWin = MaxWin*100;
	luaDump(msg,"发送开启合伙人");
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_OPEN_PARTNER,msg,PlatformMsg.MSG_GP_OPEN_PARTNER)
end

--开启合伙人时间
function PartnerInfo:sendGetUpdatePartnerTimeRequest(StartTime1,EndTime1,StartTime2,EndTime2,StartTime3,EndTime3)
	
	local msg = {}
	msg.UserID = PlatformLogic.loginResult.dwUserID
	msg.StartTime1 = StartTime1;
	msg.EndTime1 = EndTime1;
	msg.StartTime2 = StartTime2;
	msg.EndTime2 = EndTime2;
	msg.StartTime3 = StartTime3;
	msg.EndTime3 = EndTime3;
	PlatformLogic:send(PlatformMsg.MDM_AGENCY,PlatformMsg.ASS_GP_UPDATE_PARTNERTIME,msg,PlatformMsg.MSG_GP_UPDATE_PARTNERTIME)
end

return PartnerInfo
