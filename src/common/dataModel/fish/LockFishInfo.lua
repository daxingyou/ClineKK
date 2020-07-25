--锁定鱼同步

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local LockFishInfo = {}

function LockFishInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function LockFishInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function LockFishInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GM_GAME_NOTIFY,GameMsg.SUB_S_LOCK_FIRE}
					}

	BindTool.register(self, "lockFishInfo", {});--锁定结果
end

function LockFishInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function LockFishInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function LockFishInfo:unregisterCmdNotify(mainID,subID)
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

function LockFishInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GM_GAME_NOTIFY then
		if subID == GameMsg.SUB_S_LOCK_FIRE then
			self:onReceiveLockFishInfo(data.data);
		end
	end
end

--锁定消息
function LockFishInfo:sendLockFishRequest(isLock)
	if globalUnit.isEnterGame ~= true then
		return;
	end

	local msg = {}
	msg.IsLockFire = isLock;
	RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_LOCK_FIRE,msg,GameMsg.CMD_C_LOCK_FIRE);
end

--锁定消息结果
function LockFishInfo:onReceiveLockFishInfo(data)

	luaDump(data,"onReceiveLockFishInfo")

	self:setLockFishInfo(data);
end

return LockFishInfo;

