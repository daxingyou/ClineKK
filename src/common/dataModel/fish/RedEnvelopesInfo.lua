--红包

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local RedEnvelopesInfo = {}

function RedEnvelopesInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function RedEnvelopesInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function RedEnvelopesInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NEW_REWARD},
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_HONGBAO_REWARD}
					}

	BindTool.register(self, "redEnvelopesResultInfo", {});--抽奖结果
	BindTool.register(self, "redEnvelopesInfo", {});
end

function RedEnvelopesInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function RedEnvelopesInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function RedEnvelopesInfo:unregisterCmdNotify(mainID,subID)
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

function RedEnvelopesInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_NEW_REWARD then
			self:onReceiveRedEnvelopesInfo(data.data);
		elseif subID == GameMsg.SUB_S_HONGBAO_REWARD then
			self:onReceiveRedEnvelopesResultInfo(data.data);
		end
	end
end

--抽奖
function RedEnvelopesInfo:sendRedEnvelopesResultRequest()
	if globalUnit.isEnterGame ~= true then
		return;
	end

	self.isSend = true;

	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_HONGBAO);
end

--抽奖结果
function RedEnvelopesInfo:onReceiveRedEnvelopesResultInfo(data)
	if self.isSend ~= true then
		return;
	end
	luaDump(data,"onReceiveRedEnvelopesResultInfo")

	-- self.isSend = nil;
	data.rat = data.rat + 1;
	self:setRedEnvelopesResultInfo(data);
end

function RedEnvelopesInfo:onReceiveRedEnvelopesInfo(data)
	if data.OperaType ~= 2 then
		return;
	end

	if self.isSend ~= true then
		return;
	end

	self.isSend = nil;
	self:setRedEnvelopesInfo(data);
end

return RedEnvelopesInfo;
