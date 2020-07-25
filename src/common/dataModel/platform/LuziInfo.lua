
-- 路子

local RoomDeal = require("net.room.RoomDeal"):getInstance()

local LuziInfo = {}

function LuziInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function LuziInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function LuziInfo:initData()
	self.temp = {}

	self.cmdListR = {
					{RoomMsg.MZTW_ROOMINFO,RoomMsg.ASS_ZTW_GAMERECORED},
					{RoomMsg.MZTW_ROOMINFO,RoomMsg.ASS_ZTW_CHANGEGAMESTATION}
					}

	BindTool.register(self, "gameRecord", {})
	BindTool.register(self, "changeGameStation", {})
end

function LuziInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdListR) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function LuziInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdListR) then
		return
	end

	for k,v in pairs(self.cmdListR) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function LuziInfo:unregisterCmdNotify(mainID,subID)
	local isHave = false

	for k,v in pairs(self.cmdListR) do
		if v[1] == mainID and v[2] == subID then
			isHave = true
			break
		end
	end

	if isHave then
		RoomDeal:unregisterCmdReceiveNotify(mainID,subID,self)
	end
end

function LuziInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MZTW_ROOMINFO then
		if subID == RoomMsg.ASS_ZTW_GAMERECORED then
			self:onReceiveGameRecord(data)
		elseif subID == RoomMsg.ASS_ZTW_CHANGEGAMESTATION then
			self:onReceiveChangeGameStation(data)
		end
	end
end


function LuziInfo:onReceiveGameRecord(data)
	local msg = convertToLua(data,RoomMsg.MSG_GP_S_GET_ROOMINFO);
	luaDump(msg,"onReceiveGameRecord")
	self:setGameRecord(msg)
end

function LuziInfo:onReceiveChangeGameStation(data)
	local msg = convertToLua(data,RoomMsg.MSG_GP_S_BASIC_ROOMINFO);
	luaDump(msg,"onReceiveChangeGameStation")
	self:setChangeGameStation(msg)
end

return LuziInfo
