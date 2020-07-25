--// 维护所有的游戏用户数据
local UserInfoModule = class("UserInfoModule")

--用户变化事件类型
IUserInfoChangedEvent = {
	UNKNOW = 0,
	ADD = 1,
	REMOVE = 2,
	UPDATE = 3,
	CLEAR = 4,	
}

local _userInfoModule = nil;

function UserInfoModule:getInstance()
	if _userInfoModule == nil then
		_userInfoModule = UserInfoModule:new();
	end

	return _userInfoModule;
end

function UserInfoModule:ctor()
	self:initData();
end

function UserInfoModule:initData()
	--// 在线用户列表
	self._onlineUsers = {};

	--// 数据变换通知队列
	self._dataChangedQueue = {};
end

function UserInfoModule:addObserver(delegate)
	-- luaPrint("注册用户事件成功")
	table.insert(self._dataChangedQueue, delegate);
end

function UserInfoModule:removeObserver(delegate)
	table.removebyvalue(self._dataChangedQueue, delegate, true);
end

function UserInfoModule:getUsersCount()
	return getTableLength(self._onlineUsers);
end

--// 功能接口

--// 删除用户信息
function UserInfoModule:removeUser(userID)
	for k,v in pairs(self._onlineUsers) do
		if v.dwUserID == userID then
			self:onNotify(v,IUserInfoChangedEvent.REMOVE);
			table.removebyvalue(self._onlineUsers,v);
			v = nil;
			break;
		end
	end
end

--// 更新用户信息
function UserInfoModule:updateUser(user)
	local oldUser = self:findUserByID(user.dwUserID);

	if oldUser ~= nil then
		oldUser = user;
		self:onNotify(oldUser,IUserInfoChangedEvent.UPDATE);
	else
		self:addUser(user);
	end
end

--// 添加用户信息
function UserInfoModule:addUser(user)
	if user == nil then
		return;
	end

	local newUser = user;

	table.insert(self._onlineUsers, newUser);
	self:onNotify(newUser, IUserInfoChangedEvent.ADD);

	return newUser;
end

 --// 通过用户ID查找用户
function UserInfoModule:findUserByID(userID)
	local user = nil;

	for k,v in pairs(self._onlineUsers) do
		if v.dwUserID == userID then
			user = v;
			break;
		end
	end

	return user;
end

--// 通过桌号，座位号查找用户
function UserInfoModule:findUserByDesk(deskNo, station)
	local tempUsers = self:findDeskUsers(deskNo);

	local user = nil;

	for k,v in pairs(tempUsers) do
		if v.bDeskStation == station then
			user = v;
			break;
		end
	end

	return user;
end

--// 获取旁观玩家
function UserInfoModule:findLooker(deskNO)
	local users = {};

	for k,v in pairs(self._onlineUsers) do
		if v.bDeskNO == deskNO and v.bUserState == USER_WATCH_GAME then
			table.insert(users, v);
		end
	end

	return users;
end

--// 获取桌子玩家
function UserInfoModule:findDeskUsers(deskNO)
	local users = {};

	-- luaDump(self._onlineUsers,"_onlineUsers".." deskNo "..deskNO)
	for k,v in pairs(self._onlineUsers) do
		if v.bDeskNO == deskNO and v.bUserState ~= USER_WATCH_GAME then-- and v.bUserState ~= USER_LOOK_STATE then
			table.insert(users, v);
		end
	end

	return users;
end

--// 获取游戏玩家
function UserInfoModule:findGameUsers(deskNO)
	local users = {};

	for k,v in pairs(self._onlineUsers) do
		if v.bDeskNO == deskNO and (v.bUserState == USER_SITTING or v.bUserState == USER_PLAY_GAME or v.bUserState == USER_ARGEE) then
			user = v;
			table.insert(users, v);
		end
	end

	return users;
end

--// 遍历数据功能接口
--// 遍历用户数据
--// 遍历用户数据
--func  修改的值 condition 判断条件
function UserInfoModule:transform(func, condition)
	condition = condition or {};

	if next(condition) == nil then
		for k,user in pairs(self._onlineUsers) do
			for key,value in pairs(func) do
				self._onlineUsers[k][key] = value;
			end
		end
	else
		for k,user in pairs(self._onlineUsers) do
			local flag = true;
			for kc,vc in pairs(condition) do
				if user[kc] ~= vc then
					flag = false;
					break;
				end
			end

			if flag == true then
				for key,value in pairs(func) do
					self._onlineUsers[k][key] = value;
				end
			end
		end
	end
	
end

-- function UserInfoModule:transform(func)
-- 	if type(func ~= "table") then
-- 		luaPrint("更新用户信息 error param");
-- 	end

-- 	for k,user in pairs(self._onlineUsers) do
-- 		for key,value in pairs(func) do
-- 			self._onlineUsers[k][key] = value;
-- 		end
-- 	end
-- end

-- --// 遍历用户数据
-- function UserInfoModule:transformByDesk(bDeskNO, func)
-- 	for k,user in pairs(self._onlineUsers) do
-- 		if bDeskNo == user.bDeskNo then
-- 			for key,value in pairs(func) do
-- 				self._onlineUsers[k][key] = value;
-- 			end
-- 		end		
-- 	end
-- end

function UserInfoModule:transformByDeskStation(bDeskNO, bDeskStation, func)
	for k,user in pairs(self._onlineUsers) do
		if bDeskNo == user.bDeskNo  and bDeskStation == user.bDeskStation then
			for key,value in pairs(func) do
				self._onlineUsers[k][key] = value;
			end
		end		
	end
end

--// 清空数据
function UserInfoModule:clear()
	self._onlineUsers = {};

	self:onNotify(nil, IUserInfoChangedEvent.CLEAR);
end

function UserInfoModule:onNotify(user, command)
	luaPrint("UserInfoModule ------------ command "..command.." self._dataChangedQueue len "..getTableLength(self._dataChangedQueue));
	-- luaDump(user)
	for k,v in pairs(self._dataChangedQueue) do
		luaPrint("变更用户数据")
		v:onchange({msgType = command,user = user});
	end
end

return UserInfoModule;
