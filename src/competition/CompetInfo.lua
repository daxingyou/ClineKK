local RoomDeal = require("net.room.RoomDeal"):getInstance();

local CompetInfo = {}

function CompetInfo:init()
	self:initData()

	self:registerCmdNotify()
end

function CompetInfo:clear()
	self:clearAllRegisterCmdNotify()
end

function CompetInfo:initData()
	self.cmdList = {
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_LIST},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_BET},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_RESULT},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_SPECIAL_EC_LIST},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_CLASS_EC_LIST},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_GAMETYPE_EC_LIST},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EVENT_EC_LIST},
					{RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_REALTIME_INFO},
					}

	BindTool.register(self, "EcList", {})
	BindTool.register(self, "EcBet", {})
	BindTool.register(self, "EcResult", {})
	BindTool.register(self, "SpecialEcList", {})
	BindTool.register(self, "ClassEcList", {})
	BindTool.register(self, "GametypeEcList", {})
	BindTool.register(self, "EventEcList", {})
	BindTool.register(self, "RealtimeInfo", {})

	self.EcList = {};
	self.EcBet = {};
	self.EcResult = {};
	self.SpecialEcList = {};
	self.ClassEcList = {};
	self.GametypeEcList = {};
	self.EventEcList = {};
	self.RealtimeInfo = {};
	--更新用户金币信息
	BindTool.register(self, "UserMoneyUpdate", {})

	self.MsgList = {};
end

function CompetInfo:registerCmdNotify()
	self:clearAllRegisterCmdNotify()

	for k,v in pairs(self.cmdList) do
		RoomDeal:registerCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销本表注册的所有事件
function CompetInfo:clearAllRegisterCmdNotify()
	if isEmptyTable(self.cmdList) then
		return
	end

	for k,v in pairs(self.cmdList) do
		RoomDeal:unregisterCmdReceiveNotify(v[1],v[2],self)
	end
end

--注销单个事件
function CompetInfo:unregisterCmdNotify(mainID,subID)
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

function CompetInfo:onReceiveCmdResponse(mainID, subID, data)
	if mainID == RoomMsg.MDM_GP_EC_INFO then
		if subID == GameMsg.ASS_GP_EC_LIST then
			-- self:onEcList(data);
			self:DealMsgList("EcList",data);
		elseif subID == GameMsg.ASS_GP_EC_BET then
			self:onEcBet(data);
		elseif subID == GameMsg.ASS_GP_EC_RESULT then
			self:onEcResult(data);
		elseif subID == GameMsg.ASS_GP_SPECIAL_EC_LIST then
			-- self:onSpecialEcList(data);
			self:DealMsgList("SpecialEcList",data);
		elseif subID == GameMsg.ASS_GP_CLASS_EC_LIST then
			-- self:onClassEcList(data);
			self:DealMsgList("ClassEcList",data);
		elseif subID == GameMsg.ASS_GP_GAMETYPE_EC_LIST then
			-- self:onGametypeEcList(data);
			self:DealMsgList("GametypeEcList",data);
		elseif subID == GameMsg.ASS_GP_EVENT_EC_LIST then
			-- self:onEventEcList(data);
			self:DealMsgList("EventEcList",data);
		elseif subID == GameMsg.ASS_GP_REALTIME_INFO then
			-- self:onRealtimeInfo(data);
			self:DealMsgList("RealtimeInfo",data);
		end
	end
end

function CompetInfo:onEcList(data)
	self:DealCompetInfoMsg("EcList",data);
end

function CompetInfo:onEcBet(data)
	local msg = convertToLua(data,GameMsg.MSG_GP_EC_BET_RESULT);

	self:setEcBet(msg);
end

function CompetInfo:onEcResult(data)

	local size1 = data:getHead(1)-20
	local size2 = getObjSize(GameMsg.MSG_GP_EC_RESULT)
	local num = size1/size2
	for i=1,num do
		local msg = convertToLua(data,GameMsg.MSG_GP_EC_RESULT)
		table.insert(self.EcResult,msg);
	end

	local handCode = data:getHead(4);

	-- --luaDump(self.EcResult,"下注历史");

	if handCode == 1 then
		self:setEcResult(self.EcResult);
		self.EcResult = {};
	end
end

--消息处理
function CompetInfo:DealMsgList(msgName,data)
	table.insert(self.MsgList,{data = data,msgName = msgName});

	if #self.MsgList > 1 then
		return;
	end

	self:DealCompetInfoMsg(self.MsgList[1]);
end

function CompetInfo:onSpecialEcList(data)
	self:DealCompetInfoMsg("SpecialEcList",data);
end

function CompetInfo:onClassEcList(data)
	self:DealCompetInfoMsg("ClassEcList",data);
end

function CompetInfo:onGametypeEcList(data)
	self:DealCompetInfoMsg("GametypeEcList",data);
end

function CompetInfo:onEventEcList(data)
	self:DealCompetInfoMsg("EventEcList",data);
end

function CompetInfo:onRealtimeInfo(data)
	self:DealCompetInfoMsg("RealtimeInfo",data);
end

-- local count = 0;

function CompetInfo:DealCompetInfoMsg(data)
	-- local socket = require "socket"
	-- local start_time = socket.gettime()*1000
	-- luaPrint("start_time:",start_time)

	local msg = convertToLua(data.data,GameMsg.MSG_GP_EC_LIST);
	local msgName = data.msgName;

	msg.info = msg.info1..msg.info2..msg.info3..msg.info4;

	local handCode = data.data:getHead(4);

	-- luaPrint("handCode",handCode);

	-- count = count+1;
	-- luaPrint("包的个数---------------",count);

	if handCode == 0 then
		if msg.IsFirst == 1 then
			self[msgName] = {};
			self[msgName].info = msg.info;
			self[msgName].uSize = msg.uSize;
			self[msgName].IsFirst = msg.IsFirst;
			self[msgName].EventID = msg.EventID;
			self[msgName].GameID = msg.GameID;
		else
			self[msgName].info = self[msgName].info..msg.info;
			self[msgName].uSize = self[msgName].uSize + msg.uSize;
			self[msgName].IsFirst = msg.IsFirst;
			self[msgName].EventID = msg.EventID;
			self[msgName].GameID = msg.GameID;
		end
	else
		if table.nums(self[msgName]) == 0 then
			self[msgName].info = "";
			self[msgName].uSize = 0;
			self[msgName].IsFirst = 0;
			self[msgName].EventID = 0;
			self[msgName].GameID = 0;
		end

		self[msgName].info = self[msgName].info..msg.info;
		self[msgName].uSize = self[msgName].uSize + msg.uSize;
		self[msgName].IsFirst = msg.IsFirst;
		self[msgName].EventID = msg.EventID;
		self[msgName].GameID = msg.GameID;

		-- luaPrint("字符长度-------------",self[msgName].uSize);

		-- self[msgName].info = string.gsub(self[msgName].info,"\\u00a0","");

		-- local end_time= socket.gettime()*1000
		-- luaPrint("string.gsub end_time:",end_time)
		-- local use_time2 = (end_time - start_time )
		-- luaPrint("string.gsub used time: "..use_time2 .."ms \n")

		-- local utf8Info = unicode_to_utf8(self[msgName].info);

		-- local end_time= socket.gettime()*1000
		-- luaPrint("unicode_to_utf8 end_time:",end_time)
		-- local use_time1 = (end_time - start_time )
		-- luaPrint("unicode_to_utf8 used time: "..use_time1 .."ms \n")
		-- luaPrint("UTF8数据---------",self[msgName].info);

    	self[msgName].info = json.decode(self[msgName].info);

    	-- luaDump(self[msgName].info,"数据解析");

		-- local end_time= socket.gettime()*1000
		-- luaPrint("end_time json:",end_time)
		-- local use_time = (end_time - start_time )
		-- luaPrint("used time json: "..use_time .."ms \n")

    	local str = "return function(x) CompetInfo:set"..msgName.."(x) end";

		local func = loadstring(str)();
		func(self[msgName]);
		self[msgName] = {};
	end

	table.remove(self.MsgList,1);
	if #self.MsgList>0 then
		self:DealCompetInfoMsg(self.MsgList[1]);
	end

end


return CompetInfo
