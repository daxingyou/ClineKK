--用户新加的属性

local RoomDeal = require("net.room.RoomDeal"):getInstance();

local UserExpandInfo = {}

function UserExpandInfo:init()
	self:initData();

	self:registerCmdNotify();
end

function UserExpandInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function UserExpandInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_GR_GET_USEREXPAND}
					}

	BindTool.register(self, "userExpandInfo", {});--用户新加属性值
end

function UserExpandInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function UserExpandInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function UserExpandInfo:unregisterCmdNotify(mainID,subID)
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

function UserExpandInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GR_LOGON then
		if subID == RoomMsg.ASS_GR_GET_USEREXPAND then
			self:onReceiveUserExpandInfo(data.data);
		end
	end
end

--请求扩展属性
function UserExpandInfo:sendUserExpandInfoRequest()
	if globalUnit.isEnterGame ~= true then
		return;
	end
	
	luaPrint("请求用户扩展信息")
	local msg = {}
	msg.dwUserID = PlatformLogic.loginResult.dwUserID;
	RoomLogic:send(RoomMsg.MDM_GR_LOGON, RoomMsg.ASS_GR_GET_USEREXPAND, msg, RoomMsg.MSG_GR_S_GetUserExpand);
end

--
function UserExpandInfo:onReceiveUserExpandInfo(data)
	luaDump(data,"onReceiveUserExpandInfo")

	self:setUserExpandInfo(data);
end

return UserExpandInfo;
