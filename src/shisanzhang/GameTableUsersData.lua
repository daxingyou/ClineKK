local GameTableUsersData = class("GameTableUsersData")

function GameTableUsersData:ctor()

	self:update()
	-- luaDump(self._users,"初始化用户")
end

function GameTableUsersData:update()
	self._users = {}
end

--// 获取玩家信息
function GameTableUsersData:getUserByDeskStation(nRealSeat)
	for k,v in pairs(self._users) do
		if v.nRealSeat == nRealSeat-1 then
			return v
		end
	end
end

--// 获取玩家信息
function GameTableUsersData:getUserByUserID(nUserId1, nUserId2)
	for k,v in pairs(self._users) do
		if v.nUserId1 == nUserId1 and v.nUserId2 == nUserId2 then
			return v
		end
	end
end

--// 获取玩家信息
function GameTableUsersData:getUserByIndex(index)
	for k,v in pairs(self._users) do
		if k == index then
			return v
		end
	end
end

function GameTableUsersData:getVeortsize()
	return table.nums(self._users)
end

function GameTableUsersData:clear()
	self._users = {}
end

return GameTableUsersData
