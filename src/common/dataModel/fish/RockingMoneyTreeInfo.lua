--摇钱树

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local RockingMoneyTreeInfo = {}

function RockingMoneyTreeInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function RockingMoneyTreeInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function RockingMoneyTreeInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NEW_REWARD}
					}

	BindTool.register(self, "rockingMoneyTreeInfo", {});--摇钱树结果
end

function RockingMoneyTreeInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function RockingMoneyTreeInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function RockingMoneyTreeInfo:unregisterCmdNotify(mainID,subID)
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

function RockingMoneyTreeInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_NEW_REWARD then
			self:onReceiveRockingMoneyTreeInfo(data.data);
		end
	end
end

--摇一摇
function RockingMoneyTreeInfo:sendRockingMoneyTreeRequest()
	if globalUnit.isEnterGame ~= true then
		return;
	end

	self.isSend = true;

	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_YQS);
end

--摇一摇结果
function RockingMoneyTreeInfo:onReceiveRockingMoneyTreeInfo(data)
	if data.OperaType ~= 1 then
		return;
	end

	if self.isSend ~= true then
		return;
	end
	luaDump(data,"onReceiveRockingMoneyTreeInfo")

	self.isSend = nil;
	self:setRockingMoneyTreeInfo(data);
end

return RockingMoneyTreeInfo;
