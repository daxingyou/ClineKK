--砸金蛋

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local GiftEggsInfo = {}

function GiftEggsInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function GiftEggsInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function GiftEggsInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_NEW_REWARD}
					}

	BindTool.register(self, "hitGiftEggsInfo", {});--砸金蛋结果
end

function GiftEggsInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function GiftEggsInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function GiftEggsInfo:unregisterCmdNotify(mainID,subID)
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

function GiftEggsInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_NEW_REWARD then
			self:onReceiveHitGiftEggsInfo(data.data);
		end
	end
end

--砸金蛋
function GiftEggsInfo:sendHitGiftEggsRequest()
	if globalUnit.isEnterGame ~= true then
		return;
	end

	self.isSend = true;

	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_LIDAN);
end

--砸金蛋结果
function GiftEggsInfo:onReceiveHitGiftEggsInfo(data)
	if data.OperaType ~= 0 then
		return;
	end

	if self.isSend ~= true then
		return;
	end
	luaDump(data,"onReceiveHitGiftEggsInfo")

	self.isSend = nil;
	self:setHitGiftEggsInfo(data);
end

return GiftEggsInfo;

