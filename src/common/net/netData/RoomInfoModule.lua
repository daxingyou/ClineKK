local RoomInfoModule = class("RoomInfoModule");

local _roomInfoModule = nil;

function RoomInfoModule:getInstance()
	if _roomInfoModule == nil then
		_roomInfoModule = RoomInfoModule.new();
	end

	return _roomInfoModule;
end

function RoomInfoModule:ctor()
	self:initData();
end

function RoomInfoModule:initData()
	self._gameRoomList = {}--游戏房间列表
	self._roomList = {}; --// 当前房间列表
	self._onlineAllCount = 0;
	self.m_pRoomCreateCost = {};
	self.m_gold = {
		{uNameID = 40011000, uRoomID = 1, nMinRoomKey =5000},--百家乐
		-- {uNameID = 40011000, uRoomID = 49, nMinRoomKey = 0},

		{uNameID = 40012000, uRoomID = 2, nMinRoomKey = 5000},--奔驰宝马
		-- {uNameID = 40012000, uRoomID = 50, nMinRoomKey = 0},

		{uNameID = 40013000, uRoomID = 12, nMinRoomKey = 100},--骰宝
		-- {uNameID = 40013000, uRoomID = 51, nMinRoomKey = 0},

		{uNameID = 40014000, uRoomID = 13, nMinRoomKey = 5000},--飞禽走兽
		-- {uNameID = 40014000, uRoomID = 52, nMinRoomKey = 0},

		{uNameID = 40015000, uRoomID = 3, nMinRoomKey = 5000},--百人牛牛
		{uNameID = 40015000, uRoomID = 14, nMinRoomKey = 5000},
		-- {uNameID = 40015000, uRoomID = 48, nMinRoomKey = 0},

		{uNameID = 40016000, uRoomID = 46, nMinRoomKey = 5000},--红黑大战
		-- {uNameID = 40016000, uRoomID = 58, nMinRoomKey = 0},

		{uNameID = 40017000, uRoomID = 47, nMinRoomKey = 5000},--龙虎斗
		-- {uNameID = 40017000, uRoomID = 59, nMinRoomKey = 0},

		{uNameID = 40023000, uRoomID = 15, nMinRoomKey = 3000},--斗地主
		{uNameID = 40023000, uRoomID = 19, nMinRoomKey = 0},
		{uNameID = 40023000, uRoomID = 20, nMinRoomKey = 0},
		{uNameID = 40023000, uRoomID = 21, nMinRoomKey = 300},--不洗牌场
		{uNameID = 40023000, uRoomID = 22, nMinRoomKey = 5000},
		{uNameID = 40023000, uRoomID = 23, nMinRoomKey = 10000},
		{uNameID = 40023000, uRoomID = 24, nMinRoomKey = 48000},

		{uNameID = 40010000, uRoomID = 4, nMinRoomKey = 0},--捕鱼多人
		{uNameID = 40010000, uRoomID = 5, nMinRoomKey = 5000},
		{uNameID = 40010000, uRoomID = 6, nMinRoomKey = 10000},
		{uNameID = 40010000, uRoomID = 7, nMinRoomKey = 15000},
		{uNameID = 40010000, uRoomID = 53, nMinRoomKey = 0},

		{uNameID = 40010004, uRoomID = 8, nMinRoomKey = 0},--捕鱼单人
		{uNameID = 40010004, uRoomID = 9, nMinRoomKey = 5000},
		{uNameID = 40010004, uRoomID = 10, nMinRoomKey = 10000},
		{uNameID = 40010004, uRoomID = 11, nMinRoomKey = 15000},

		--百人拼十
		-- {uNameID = 40015000, uRoomID = 3, nMinRoomKey = 0},
		-- {uNameID = 40015000, uRoomID = 14, nMinRoomKey = 0},

		{uNameID = 40022000, uRoomID = 17, nMinRoomKey = 500},--抢庄拼十
		{uNameID = 40022000, uRoomID = 28, nMinRoomKey = 5000},
		{uNameID = 40022000, uRoomID = 29, nMinRoomKey = 50000},
		{uNameID = 40022000, uRoomID = 30, nMinRoomKey = 150000},

		{uNameID = 40021000, uRoomID = 16, nMinRoomKey = 5000},--二人拼十
		{uNameID = 40021000, uRoomID = 25, nMinRoomKey = 20000},
		{uNameID = 40021000, uRoomID = 26, nMinRoomKey = 100000},
		{uNameID = 40021000, uRoomID = 27, nMinRoomKey = 500000},

		{uNameID = 40024000, uRoomID = 18, nMinRoomKey = 3000},--三张牌
		{uNameID = 40024000, uRoomID = 31, nMinRoomKey = 3000},
		{uNameID = 40024000, uRoomID = 32, nMinRoomKey = 30000},
		{uNameID = 40024000, uRoomID = 33, nMinRoomKey = 100000},

		{uNameID = 40025000, uRoomID = 42, nMinRoomKey = 5000},--德州扑克
		{uNameID = 40025000, uRoomID = 43, nMinRoomKey = 20000},
		{uNameID = 40025000, uRoomID = 44, nMinRoomKey = 30000},
		{uNameID = 40025000, uRoomID = 45, nMinRoomKey = 100000},

		{uNameID = 40027000, uRoomID = 38, nMinRoomKey = 5000},--十点半
		{uNameID = 40027000, uRoomID = 39, nMinRoomKey = 25000},
		{uNameID = 40027000, uRoomID = 40, nMinRoomKey = 50000},
		{uNameID = 40027000, uRoomID = 41, nMinRoomKey = 100000},

		{uNameID = 40026000, uRoomID = 34, nMinRoomKey = 5000},--二十一点
		{uNameID = 40026000, uRoomID = 35, nMinRoomKey = 25000},
		{uNameID = 40026000, uRoomID = 36, nMinRoomKey = 50000},
		{uNameID = 40026000, uRoomID = 37, nMinRoomKey = 100000},

		{uNameID = 40028000, uRoomID = 109, nMinRoomKey = 3000},--十三张
		{uNameID = 40028000, uRoomID = 110, nMinRoomKey = 30000},
		{uNameID = 40028000, uRoomID = 111, nMinRoomKey = 60000}, 
		{uNameID = 40028000, uRoomID = 112, nMinRoomKey = 150000},

		{uNameID = 40028002, uRoomID = 127, nMinRoomKey = 10000},--十三张 6人
		{uNameID = 40028002, uRoomID = 128, nMinRoomKey = 25000},
		{uNameID = 40028002, uRoomID = 129, nMinRoomKey = 50000}, 
		{uNameID = 40028002, uRoomID = 130, nMinRoomKey = 100000},

		{uNameID = 40028001, uRoomID = 123, nMinRoomKey = 10000},--十三张 8人
		{uNameID = 40028001, uRoomID = 124, nMinRoomKey = 25000},
		{uNameID = 40028001, uRoomID = 125, nMinRoomKey = 50000}, 
		{uNameID = 40028001, uRoomID = 126, nMinRoomKey = 100000},

		{uNameID = 40028010, uRoomID = 131, nMinRoomKey = 5000},--乐清十三张
		{uNameID = 40028010, uRoomID = 132, nMinRoomKey = 25000},
		{uNameID = 40028010, uRoomID = 133, nMinRoomKey = 50000}, 
		{uNameID = 40028010, uRoomID = 134, nMinRoomKey = 100000},

		{uNameID = 40028012, uRoomID = 140, nMinRoomKey = 10000},--乐清十三张 6人
		{uNameID = 40028012, uRoomID = 141, nMinRoomKey = 25000},
		{uNameID = 40028012, uRoomID = 142, nMinRoomKey = 50000}, 
		{uNameID = 40028012, uRoomID = 143, nMinRoomKey = 100000},

		{uNameID = 40028011, uRoomID = 136, nMinRoomKey = 10000},--乐清十三张 8人
		{uNameID = 40028011, uRoomID = 137, nMinRoomKey = 25000},
		{uNameID = 40028011, uRoomID = 138, nMinRoomKey = 50000}, 
		{uNameID = 40028011, uRoomID = 139, nMinRoomKey = 100000},

		{uNameID = 40031000, uRoomID = 108, nMinRoomKey = 5000},

		{uNameID = 40018000, uRoomID = 114, nMinRoomKey = 3000},--扫雷红包
		{uNameID = 40018000, uRoomID = 115, nMinRoomKey = 3000},--扫雷红包
		{uNameID = 40018000, uRoomID = 144, nMinRoomKey = 1000},--扫雷红包
		{uNameID = 40018000, uRoomID = 145, nMinRoomKey = 1000},--扫雷红包

		--超级水果机
		{uNameID = 40050000, uRoomID = 118, nMinRoomKey = 100},
		{uNameID = 40050000, uRoomID = 119, nMinRoomKey = 10000},
		{uNameID = 40050000, uRoomID = 120, nMinRoomKey = 100000},

		--水浒传
		{uNameID = 40060000, uRoomID = 121, nMinRoomKey = 100},
		{uNameID = 40060000, uRoomID = 158, nMinRoomKey = 10000},
		{uNameID = 40060000, uRoomID = 159, nMinRoomKey = 100},

		--糖果派对
		{uNameID = 40061000, uRoomID = 146, nMinRoomKey = 100},
		{uNameID = 40061000, uRoomID = 160, nMinRoomKey = 10000},
		{uNameID = 40061000, uRoomID = 161, nMinRoomKey = 100000},

		--连环夺宝
		{uNameID = 40062000, uRoomID = 148, nMinRoomKey = 100},
		{uNameID = 40062000, uRoomID = 162, nMinRoomKey = 10000},
		{uNameID = 40062000, uRoomID = 163, nMinRoomKey = 100},

		--李逵劈鱼
		{uNameID = 40010001, uRoomID = 164, nMinRoomKey = 0},--捕鱼多人
		{uNameID = 40010001, uRoomID = 165, nMinRoomKey = 5000},
		{uNameID = 40010001, uRoomID = 166, nMinRoomKey = 10000},
		{uNameID = 40010001, uRoomID = 167, nMinRoomKey = 15000},

		{uNameID = 40010005, uRoomID = 168, nMinRoomKey = 0},--捕鱼单人
		{uNameID = 40010005, uRoomID = 169, nMinRoomKey = 5000},
		{uNameID = 40010005, uRoomID = 170, nMinRoomKey = 10000},
		{uNameID = 40010005, uRoomID = 171, nMinRoomKey = 15000},

		--金蟾捕鱼
		{uNameID = 40010002, uRoomID = 172, nMinRoomKey = 0},--捕鱼多人
		{uNameID = 40010002, uRoomID = 173, nMinRoomKey = 5000},
		{uNameID = 40010002, uRoomID = 174, nMinRoomKey = 10000},
		{uNameID = 40010002, uRoomID = 175, nMinRoomKey = 15000},

		{uNameID = 40010006, uRoomID = 176, nMinRoomKey = 0},--捕鱼单人
		{uNameID = 40010006, uRoomID = 177, nMinRoomKey = 5000},
		{uNameID = 40010006, uRoomID = 178, nMinRoomKey = 10000},
		{uNameID = 40010006, uRoomID = 179, nMinRoomKey = 15000},
	}
end

function RoomInfoModule:getOnlineAllCount()
	return self._onlineAllCount;
end

function RoomInfoModule:setOnlineAllCount(count)
	self._onlineAllCount = count;
end

function RoomInfoModule:getRoomCount()
	return getTableLength(self._roomList);
end

-- 获取房间个数（比赛房间合并）
function RoomInfoModule:getCountIncludeMatch()
	local roomCount = 0;
		-- local vecMatchRoom = {};
		-- for k,info in pairs(self.roomList) do
		-- 	if bit:_and(info.dwRoomRule,GRR_TIMINGCONTEST) == 0 and  bit:_and(info.dwRoomRule,GRR_CONTEST) == 0 then
		-- 		roomCount++;
		-- 	end
		-- end

		-- for (auto iter = _rooms->begin(); iter != _rooms->end(); ++iter)
		-- {
		-- 	ComRoomInfo* pInfo = (ComRoomInfo*)*iter;
		-- 	// 不是比赛
		-- 	if(((pInfo->dwRoomRule & GRR_TIMINGCONTEST) == 0) && ((pInfo->dwRoomRule & GRR_CONTEST) == 0))
		-- 	{
		-- 		roomCount++;
		-- 		continue;
		-- 	}
			
		-- 	if ((*iter)->dwRoomRule & GRR_TIMINGCONTEST)
		-- 	{
		-- 	roomCount++;
		-- 	continue;
		-- 	}
		-- 	auto it = vecMatchRoom.begin();
		-- 	for (; it != vecMatchRoom.end(); ++it)
		-- 	{
		-- 		if ((*iter)->iUpPeople == *it && (*iter)->dwRoomRule == *(++it))		break;
		-- 	}

		-- 	if (it == vecMatchRoom.end())	
		-- 	{
		-- 		vecMatchRoom.push_back((*iter)->iUpPeople);
		-- 		vecMatchRoom.push_back((*iter)->dwRoomRule);
		-- 		roomCount++;
		-- 	}
		-- }

		-- vecMatchRoom.clear();

		return roomCount;
end

-- 获取房间信息
function RoomInfoModule:getByRoomID(roomID)
	-- luaDump(self._roomList,"roomlist")

	for k,room in pairs(self._roomList) do
		if room.uRoomID == roomID then
			return room;
		end
	end

	return nil;
end

-- 获取房间信息
function RoomInfoModule:getRoom(postion)
	local postion = postion + 1;

	if postion < 1 or postion > getTableLength(self._roomList) then
		return;
	end

	for k,room in pairs(self._roomList) do
		if k == postion then
			return room;
		end
	end
end

-- 添加房间数据
function RoomInfoModule:addRoom(room)
	if room ~= nil and self._gameRoomList[room.uNameID] == nil then
		if string.find(room.szGameRoomName,"game") then
			room.nMinRoomKey = 0
		else
			room.nMinRoomKey = nil
		end
		room.isTryPlay = not self:isCashRoom(room.uNameID,room.uRoomID)
		table.insert(self._roomList, room);

		local msg = {};
		msg.iNameID = room.uNameID
		msg.iRoomID = room.uRoomID
		PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY);
	end
end

-- 删除房间数据
function RoomInfoModule:removeRoom(roomID)
	local room = nil;

	for k,v in pairs(self._roomList) do
		if v.uRoomID == roomID then
			room = v;
			break;
		end
	end

	if room ~= nil then
		table.removebyvalue(self._roomList, room);
		if next(self._roomList) == nil then
			self._roomList = {};
		end
	end
end

-- 更新房间数据
function RoomInfoModule:updateRoom(room)
	for k,v in pairs(self._roomList) do
		if v.uRoomID == room.uRoomID then
			self._roomList[k] = room;
			RoomInfoModule:updateRoomInfo(self._roomList[k])
			break;
		end
	end
end

-- 查找房间数据
function RoomInfoModule:findRoom(roomID)
	local room = nil;

	for k,v in pairs(self._roomList) do
		if v.uRoomID == roomID then
			room = v;
			break;
		end
	end

	return room;
end

-- 清空房间数据
function RoomInfoModule:clear()
	self._roomList = {};
end

-- 遍历房间数据
function RoomInfoModule:transform(func, condition)
	condition = condition or {};

	if next(condition) == nil then
		for k,room in pairs(self._roomList) do
			for key,value in pairs(func) do
				self._roomList[k][key] = value;
			end
		end
	else
		for k,room in pairs(self._roomList) do
			local flag = true;
			for kc,vc in pairs(condition) do
				if room[kc] ~= vc then
					flag = false;
					break;
				end
			end

			if flag == true then
				for key,value in pairs(func) do
					self._roomList[k][key] = value;
				end
			end
		end
	end	
end

-- //动态负载
function RoomInfoModule:randARoom(nameid)
	local roomid = 0;
	local mindeskusercount = 0;
	-- luaDump(self._roomList,"动态负载");
	for k,room in pairs(self._roomList) do
		if room ~= nil then
			if k == 1 then
				roomid = room.uRoomID;
				mindeskusercount = room.uUserDeskCount;
			else
				if room.uUserDeskCount and mindeskusercount > room.uUserDeskCount then
					roomid = room.uRoomID;
					mindeskusercount = room.uUserDeskCount;
				end
			end
		end
	end

	return roomid;
end

-- //钻石数据

-- //添加钻石数据
function RoomInfoModule:addRoomCreateCost(pData)
	if pData == nil then
		return;
	end

	if self.m_pRoomCreateCost[GameCreator:getCurrentGameNameID()] == nil then
		self.m_pRoomCreateCost[GameCreator:getCurrentGameNameID()] = {};
	end

	table.insert(self.m_pRoomCreateCost[GameCreator:getCurrentGameNameID()], pData);
	-- table.insert(self.m_pRoomCreateCost,pData);
end

-- //获取钻石消耗
function RoomInfoModule:getCreateRoomCost(id)
	-- luaDump(self.m_pRoomCreateCost)
	for k,v in pairs(self.m_pRoomCreateCost) do
		for k,vv in pairs(v) do
			if vv.id == id then
				return vv.iGameCost;
			end
		end
	end

	return -1;
end

function RoomInfoModule:getRoomCreateList()
	-- luaDump(self.m_pRoomCreateCost)
	luaPrint("GameCreator:getCurrentGameNameID() --RoomInfoModule----- "..GameCreator:getCurrentGameNameID())
	-- luaDump(self.m_pRoomCreateCost,"self.m_pRoomCreateCost")
	return self.m_pRoomCreateCost[GameCreator:getCurrentGameNameID()];
end

-- //清楚钻石创建数据
function RoomInfoModule:clearRoomCreateCostList()
	self.m_pRoomCreateCost = {};
end

function RoomInfoModule:updateMinNeedGold(msg)
	if self._gameRoomList then
		if self._gameRoomList[msg.iNameID] then
			for k,v in pairs(self._gameRoomList[msg.iNameID]) do
				if v.uRoomID == msg.iRoomID then
					v.nMinRoomKey = msg.nMinRoomKey
					break
				end
			end
		elseif msg.iNameID == self._roomList.uNameID and msg.iRoomID == self._roomList.uRoomID then
			self._roomList.nMinRoomKey = msg.nMinRoomKey
		end
	end
end

function RoomInfoModule:getRoomNeedGold(uNameId, iRoomID)
	-- if self._gameRoomList then
	-- 	if self._gameRoomList[uNameId] then
	-- 		for k,v in pairs(self._gameRoomList[uNameId]) do
	-- 			if v.uRoomID == iRoomID then
	-- 				return v.nMinRoomKey
	-- 			end
	-- 		end
	-- 	end
	-- end
	for k,v in pairs(self.m_gold) do
		if v.uNameID == uNameId and v.uRoomID == iRoomID then
			return v.nMinRoomKey
		end
	end

	return 0
end

function RoomInfoModule:addRoomInfo(uNameId)
	local ret = true

	for k,v in pairs(self._roomList) do
		if v.uNameID ~= uNameId then
			ret = false
			break
		end
	end

	if ret then
		-- self._roomList[#self._roomList].isTryPlay = true
		self._gameRoomList[uNameId] = self._roomList
	end
	-- luaDump(self._roomList,"addRoomInfo")
end

function RoomInfoModule:updateRoomInfo(room)
	if self._gameRoomList[room.uNameID] then
		for k,v in pairs(self._gameRoomList[room.uNameID]) do
			if v.uRoomID == room.uRoomID then
				v = room
				break
			end
		end
	end
end

--新增根据游戏nameId获得房间信息
function RoomInfoModule:getRoomInfoByNameID(uNameId)
	self._roomList = clone(self._gameRoomList[uNameId])

	if self._roomList == nil then
		self:clear()
	end

	-- luaDump(self._roomList,"getRoomInfoByNameID")

	return self._roomList
end

function RoomInfoModule:getRoomInfo()
	return self._roomList
end

function RoomInfoModule:isCashRoom(uNameId,iRoomID)
	for i,v in ipairs(self.m_gold) do
		if (v.uNameID == uNameId and v.uRoomID == iRoomID) or v.uNameID == 40010000 then
			return true
		end
	end

	return false
end

return RoomInfoModule;

