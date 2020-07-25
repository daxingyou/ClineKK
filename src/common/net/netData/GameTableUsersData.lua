local GameTableUsersData = class("GameTableUsersData")

function GameTableUsersData:ctor(deskNo)
	self._deskNo = deskNo;

	self:init();

	UserInfoModule:addObserver(self);

	self:update();
	-- luaDump(self._users,"初始化用户")
end

function GameTableUsersData:init()
	self._users = {};
end

function GameTableUsersData:update()
	self._users = clone(UserInfoModule:findDeskUsers(self._deskNo));
end

function GameTableUsersData:upateByDeskNo(deskNo)

end

--// 获取玩家信息
function GameTableUsersData:getUserByDeskStation(bDeskStation)
	-- luaPrint("bDeskStation --  "..bDeskStation)
	-- luaDump(self._users,"self._users");
	for k,v in pairs(self._users) do
		if v.bDeskStation == bDeskStation then
			return v;
		end
	end

	return nil;
end

--// 获取玩家信息
function GameTableUsersData:getUserByUserID(userID)
	for k,v in pairs(self._users) do
		if v.dwUserID == userID then
			return v;
		end
	end

	return nil;
end

--// 获取玩家信息
function GameTableUsersData:getUserByIndex(index)
	for k,v in pairs(self._users) do
		if k == index then
			return v;
		end
	end

	return nil;
end

function GameTableUsersData:getVeortsize()
	return table.nums(self._users);
end

--// 获取旁观玩家
function GameTableUsersData:findLooker()
	local users = {};

	for k,v in pairs(self._users) do
		if v.bUserState == USER_WATCH_GAME then
			table.insert(users, v);
		end
	end

	return users;
end

--// 获取坐桌玩家
function GameTableUsersData:findSitUsers()
	local users = {};

	for k,v in pairs(self._users) do
		if v.bUserState == USER_SITTING then
			table.insert(users, v);
		end
	end

	return users;
end

--// 获取正在游戏玩家
function GameTableUsersData:findGameUsers(users)
	local users = {};

	for k,v in pairs(self._users) do
		if v.bUserState == USER_PLAY_GAME then
			table.insert(users, v);
		end
	end

	return users;
end

function GameTableUsersData:clear(isRemove)
	self._users = {};

	if isRemove ~= nil then
		UserInfoModule:removeObserver(self);
	end
end

function GameTableUsersData:onchange(msg)
	-- luaPrint("GameTableUsersData:onchange "..self._deskNo)
	-- luaDump(msg)
	local msgType = msg.msgType;
	local user = msg.user;

	if msgType == IUserInfoChangedEvent.UNKNOW then
		luaPrint("未知用户信息更新事件 event : "..event.."  , msgType : "..msgType);
	elseif msgType == IUserInfoChangedEvent.ADD then
		luaPrint("msgType == IUserInfoChangedEvent.ADD self._deskNo "..self._deskNo.." ，user.bDeskNo "..user.bDeskNO.." , INVALID_DESKNO = "..INVALID_DESKNO)
		if INVALID_DESKNO ~= self._deskNo and self._deskNo == user.bDeskNO then
			table.insert(self._users, user);
			luaPrint("GameTableUsersData 添加用户了")
		end
	elseif msgType == IUserInfoChangedEvent.REMOVE then
		for k,v in pairs(self._users) do
			if v.dwUserID == user.dwUserID then-- and v.bDeskNo == user.bDeskNo then
				table.removebyvalue(self._users, user);
				break;
			end
		end
	elseif msgType == IUserInfoChangedEvent.UPDATE then
		local isFlag = false;
		local tempUser = nil;

		for k,v in pairs(self._users) do
			if v.dwUserID == user.dwUserID then-- and v.bDeskNo == user.bDeskNo then
				tempUser = v;
				isFlag = true;
				break;
			end
		end

		if user.bDeskNO == self._deskNo then
			if isFlag == false then
				table.insert(self._users, user);
			else
				for k,v in pairs(self._users) do
					if v.dwUserID == user.dwUserID then-- and v.bDeskNo == user.bDeskNo then
						self._users[k] = user;
						luaPrint("GameTableUsersData 修改用户了")
						break;
					end
				end
			end
		else
			if isFlag == true then
				if tempUser then
					table.removebyvalue(self._users, tempUser);
				end
			end
		end
	elseif msgType == IUserInfoChangedEvent.CLEAR then
		self._users = {};
	end

	-- luaDump(self._users,"onchange")
end

return GameTableUsersData;
