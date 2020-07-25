local PlatformDeal = require("net.platform.PlatformDeal"):getInstance()

local LuckyInfo = {}

function LuckyInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function LuckyInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function LuckyInfo:initData()
	self.tempList = {}
	self.cmdList = {
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_OPEN},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_WHEEL},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_RECORD},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_LUCKY},
					{PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_POINT}
					}

	BindTool.register(self, "luckyOpenInfo", {})
	BindTool.register(self, "luckyWheelResult", {})
	BindTool.register(self, "luckyOtherResult", {})
	BindTool.register(self, "luckyListInfo", {})
	BindTool.register(self, "luckyPointInfo", {})
end

function LuckyInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		PlatformDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function LuckyInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		PlatformDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function LuckyInfo:unregisterCmdNotify(mainID,subID)
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

function LuckyInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == PlatformMsg.MDM_GP_ACTIVITIES then
		if subID == PlatformMsg.ASS_GP_LUCKAWARD_OPEN then
			self:onReceiveLuckyOpen(data.data)
		elseif subID == PlatformMsg.ASS_GP_LUCKAWARD_WHEEL then
			self:onReceiveLuckyWheel(data.data)
		elseif subID == PlatformMsg.ASS_GP_LUCKAWARD_RECORD then
			self:onReceiveRecord(data.data)
		elseif subID == PlatformMsg.ASS_GP_LUCKAWARD_LUCKY then
			self:onReceiveLucky(data.data)
		elseif subID == PlatformMsg.ASS_GP_LUCKAWARD_POINT then
			self:onReceiveLuckyPoint(data.data)
		end
	end
end

--请求夺宝记录
function LuckyInfo:sendLuckyOpenRequest()
	PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES, PlatformMsg.ASS_GP_LUCKAWARD_OPEN)
end

--请求轮盘信息
function LuckyInfo:sendLuckyWheelRequest()
	if #self.luckyListInfo > 0 then
		self:setLuckyListInfo(self.luckyListInfo)
	else
		PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_LUCKY)	
	end
end

-- 请求抽奖
function LuckyInfo:sendLuckyResultRequest(kind)
	local msg = {}
	msg.wheelKind = kind
	luaDump(msg,"请求抽奖")
	PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_WHEEL,msg,PlatformMsg.Cm_LuckAwardWheel)
end

-- 离开
function LuckyInfo:sendLeaveLuckyRequest()
	PlatformLogic:send(PlatformMsg.MDM_GP_ACTIVITIES,PlatformMsg.ASS_GP_LUCKAWARD_LEAVE)
end

--夺宝记录
function LuckyInfo:onReceiveLuckyOpen(data)
	luaDump(data,"轮盘结果")

	table.sort(data.bigAward,function(a,b) return a.awardTime > b.awardTime end)
	table.sort(data.selfAward,function(a,b) return a.awardTime > b.awardTime end)
	table.sort(data.smallAward,function(a,b) return a.awardTime < b.awardTime end)

	self:setLuckyOpenInfo(data)
end

--分数
function LuckyInfo:onReceiveLuckyPoint(data)
	luaDump(data,"分数")

	self:setLuckyPointInfo(data)
end

function LuckyInfo:onReceiveLucky(data)
	luaDump(data,"幸运夺宝")

	if data[2] == 0 then
		if data[1].isEnable == 1 then
			table.insert(self.tempList,data[1])
		end
	else
		self:setLuckyListInfo(clone(self.tempList))
		self.tempList = {}
	end
end

--轮盘结果
function LuckyInfo:onReceiveLuckyWheel(data)
	luaDump(data,"轮盘结果")
	self:setLuckyWheelResult(data)

	if data[2] == 0 then
		self.luckyPointInfo.curPoint = data[1].curPoint
		self:setLuckyPointInfo(self.luckyPointInfo)
	end
end

function LuckyInfo:onReceiveRecord(data)
	luaDump(data,"他人结果")

	if self.luckyOpenInfo then
		if self.luckyOpenInfo.bigAward then
			if data.isRecordBig == 1 then--大奖塞入大奖数组
				table.insert(self.luckyOpenInfo.bigAward,1,data);
				if #self.luckyOpenInfo.bigAward > 20 then
					table.removebyvalue(self.luckyOpenInfo.bigAward,self.luckyOpenInfo.bigAward[#self.luckyOpenInfo.bigAward])
				end
			end

			if data.iUserID == PlatformLogic.loginResult.dwUserID then--id是自己则塞入自己
				table.insert(self.luckyOpenInfo.selfAward,1,data);
				if #self.luckyOpenInfo.selfAward > 20 then
					table.removebyvalue(self.luckyOpenInfo.selfAward,self.luckyOpenInfo.selfAward[#self.luckyOpenInfo.selfAward])
				end
			end

			table.insert(self.luckyOpenInfo.smallAward,data);
			if #self.luckyOpenInfo.smallAward > 4 then
				table.removebyvalue(self.luckyOpenInfo.smallAward,self.luckyOpenInfo.smallAward[#self.luckyOpenInfo.smallAward])
			end

			self:setLuckyOpenInfo(self.luckyOpenInfo)
		end
	end

	self:setLuckyOtherResult(data)
end

return LuckyInfo
