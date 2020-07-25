GAMETYPE = {
	UNKNOWN = 0,		--// 未知类型
	NORMAL = 1,		--// 常规游戏
	BR = 2,			--// 百人游戏
	SINGLE = 3,		--// 单人游戏
	MATHC_GAME = 4,		--// 匹配游戏
}

local ItemCreator = class("ItemCreator")

function ItemCreator:ctor(uNameId, uKindId, gameType, gameSelector, roomSelector, replySelector)
	self.gameType = gameType or GAMETYPE.UNKNOWN;
	self.uNameId = uNameId or 0;
	self.uKindId = uKindId or 0;
	self.gameSelector = gameSelector;
	self.roomSelector = roomSelector;
	self.replySelector = replySelector;
	self.priority = 0;
end

function ItemCreator:validGame()
	return (self.uNameId ~= 0 and self.gameType ~= GAMETYPE.UNKNOWN and self.gameSelector ~= nil);
end

function ItemCreator:valid()
	return (self.uNameId ~= 0 and self.uKindId ~= 0 and self.gameType ~= GAMETYPE.UNKNOWN and  self.gameSelector ~= nil);
end

local GameCreator = class("GameCreator")

local _gameCreator = nil;

function GameCreator:getInstance()
	if _gameCreator == nil then
		_gameCreator = GameCreator.new();
	end

	return _gameCreator;
end

function GameCreator:destroyInstance()
	_gameCreator = nil;
end

function GameCreator:ctor()
	self:initData();
end

function GameCreator:initData()
	self.INVALID_PRIORITY = 0xFF;
	self._creators = {}; --// 注册游戏列表
	-- // 优先级
	self._basePriority = 0;
	-- // 游戏游戏数量
	self._validCount = 0;
	self._validGames = {}; --// 有效游戏列表

	-- // 当前激活游戏
	self._currentCreator = nil;
end

function GameCreator:getRegistGameCount()
	-- local length = 0;
	-- for i,v in ipairs(table_name) do
	-- 	length = length + 1;
	-- end
	return getTableLength(self._creators);
end

	-- // 注册游戏
function GameCreator:addGame(uNameId, gameType, createGameSelector, createRoomSelector, replaySelector)
	local creator = ItemCreator.new(uNameId, 0, gameType, createGameSelector, createRoomSelector, replaySelector);
	self._basePriority = self._basePriority + 1;
	creator.priority = self._basePriority;
	-- luaDump(creator)
	if not creator:validGame() then
		luaPrint("注册游戏错误");
		return;
	end
	table.insert(self._creators, creator)
	self:setCurrentGame(creator.uNameId);

	-- luaDump(self._creators,"注册游戏成功")
end

-- // 设置注册游戏的类型id
function GameCreator:setGameKindId(uNameId, uKindId)
	luaPrint("uNameId -------- "..uNameId.."  , uKindId ------- "..uKindId)
	for k,v in pairs(self._creators) do
		if v.uNameId == uNameId then
			v.uKindId = uKindId;
			break;
		end
	end
end

-- // 获取有效的游戏列表
function GameCreator:getValidGamesByValue(validGames)
	validGames = {};

	validGames = self:getValidGames();

	return #validGames ~= 0;
end

function GameCreator:getValidGames()
	self._validGames = {};
	self._validCount = 0;
	GamesInfoModule:transform(function(nameInfo,index)
		local level = self:validGame(nameInfo.uNameID);

		if self.INVALID_PRIORITY ~= level then
			self._validGames[level] = nameInfo;
			self._validCount = self._validCount + 1;
		end
	end
	);

	for i=1, self._validCount do
		if self._validGames[i] == nil then
			for j = i + 1, #self._validGames do
				if self._validGames[j] ~= nil then
					self._validGames[i] = self._validGames[j];
					self._validGames[j] = nil;
					break;
				end
			end
		end
	end

	return self._validGames;
end

function GameCreator:findGame(uNameId)
	local creator = nil;
	-- luaDump(self._creators)
	for k,v in pairs(self._creators) do
		luaPrint("v.uNameId == "..v.uNameId.."   , uNameId = "..uNameId)
		if tonumber(v.uNameId) == tonumber(uNameId) then
			creator = v;
			break;
		end
	end

	return creator;
end

	-- // 获取游戏优先级
function GameCreator:getGamePriority(uNameId)
	local creator = self:findGame(uNameId);

	if creator ~= nil then
		return creator.priority;
	end

	return self.INVALID_PRIORITY;
end

-- // 设置当前选择的游戏ID
function GameCreator:setCurrentGame(uNameId)
	if tonumber(uNameId) <= 0 then
		return;
	end

	local creator = self:findGame(uNameId);
	self:setGameKindId(uNameId, 1)-- 临时
	if creator ~= nil then
		luaPrint("设置当前选择的游戏ID ---------- uNameId "..uNameId)
		self._currentCreator = creator;
	else
		luaPrint("设置当前选择的游戏ID 失败 uNameId "..uNameId)
		self._currentCreator = nil;
	end
end

-- // 当前游戏ID
function GameCreator:getCurrentGameNameID()
	if self._currentCreator then
		return self._currentCreator.uNameId;
	end

	return 0;
end

-- // 当前游戏类型
function GameCreator:getCurrentGameKindID()
	if self._currentCreator then
		return self._currentCreator.uKindId;
	end

	return -1;
end

-- // 获取游戏类型
function GameCreator:getCurrentGameType()
	if self._currentCreator then
		return self._currentCreator.gameType;
	end

	return GAMETYPE.UNKNOWN;
end

-- //获取是否有回放功能
function GameCreator:getReplay(uNameId)
	local creator = self:findGame(uNameId);

	if creator ~= nil then
		return creator.replySelector ~= nil;
	end

	return false;
end

-- // 启动游戏客户端
function GameCreator:startGameClient(uNameId, bDeskIndex, bAutoCreate, bMaster)
	self:setCurrentGame(uNameId);
	local creator = self._currentCreator;
	-- luaDump(self._currentCreator,"self._currentCreator")

	if creator ~= nil then
		if creator:valid() then
			Hall.closeTips()

			globalUnit.isEnterGame = true;

			RoomLogic:checkNet()

			if RoomLogic:getSelectedRoom().isTryPlay == true then
				globalUnit.isTryPlay = true
			else
				globalUnit.isTryPlay = false
			end

			if string.lower(string.split(GamesInfoModule:findGameName(uNameId).szGameName,"_")[1])  == string.lower("LKPY") then
				if GamesInfoModule:isSigleMode(uNameId) then
					PLAY_COUNT = 4;
					globalUnit:setIsEnterRoomMode(1)
				else
					PLAY_COUNT = 1;
					globalUnit:setIsEnterRoomMode(0)
					globalUnit.isTryPlay = false
				end
			else
				PLAY_COUNT = 180
			end

			luaPrint("启动游戏客户端 找到了PLAY_COUNT = "..PLAY_COUNT.." "..tostring(Hall:getCurGameName()))
			-- local game = creator.gameSelector(uNameId, bDeskIndex, bAutoCreate, bMaster);
			if Hall:getHallBackRoom(uNameId) then
				luaPrint("还在房间中，返回房间")
				Hall:selectedHallBackGame({uNameId, bDeskIndex, bAutoCreate, bMaster})
			else
				if Hall:getCurGameName() then
					Hall:selectedGame(Hall:getCurGameName(),{uNameId, bDeskIndex, bAutoCreate, bMaster})
				else
					if HallLayer and HallLayer:getInstance() and not HallLayer:getInstance():isVisible() then--回房间
						Hall:selectedBackGame({uNameId, bDeskIndex, bAutoCreate, bMaster})
					else
						Hall:selectedBackGame({uNameId, bDeskIndex, bAutoCreate, bMaster})
					end
				end
			end

			return true;
		end
	else
		luaPrint("启动游戏客户端 找不到 "..uNameId);
		luaDump(self._creators,"self._creators")
	end

	return false;
end

--启动加载页
function GameCreator:startLoading(callback)
	Hall.startLoading(callback);
end

-- // 启动游戏房间
function GameCreator:startGameRoom(uNameId, parent)
	local creator = self:findGame(uNameId);

	if creator ~= nil then
		local room = creator.roomSelector(parent);

		if room ~= nil then
			return true;
		end
	end

	return false;
end

-- //replay
function GameCreator:startGameReplay(uNameId, nWinUserIdx, bMySeatNo, nCurRnd, nMaxRound, iRule, roompwd, players, pData1, nLen1)
	local creator = self:findGame(uNameId);
	luaPrint("creator = self:findGame(uNameId)")
	if creator ~= nil then
		luaPrint("creator ~= nil");
		-- luaDump(creator)
		if creator:valid() then
			luaPrint("creator:valid() --------- "..uNameId)

			local game = creator.replySelector(uNameId, bMySeatNo, roompwd, players);

			if game ~= nil then
				game:setRound(nCurRnd, nMaxRound);
				game:setRule(iRule);
				game:setWinner(nWinUserIdx);
				game:setDataEx1(pData1, nLen1);
				local root = display.getRunningScene();
				root:addChild(game, 100000001, "gamereplay");
				return true;
			end
		end
	end

	return false;
end

-- // 校验游戏
function GameCreator:validGame(uNameId)
	local creator = self:findGame(uNameId);

	if creator ~= nil then
		return creator.priority;
	end

	return self.INVALID_PRIORITY;
end

return GameCreator
