if isGameMode == true then
	if PlatformMsg then
		PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY = {
			{"iNameID","INT"},--//游戏ID
			{"nMinRoomKey","INT"},--//最少需要钻石数
		}
	end
end

local GamesInfoModule = class("GamesInfoModule")
local _gameInfoModule = nil;

function GamesInfoModule:getInstance()
	if _gameInfoModule == nil then
		_gameInfoModule = GamesInfoModule.new();
	end

	return _gameInfoModule;
end

function GamesInfoModule:ctor()
	self:initData();
end

function GamesInfoModule:initData()
	self._gameKinds = {};		--// 游戏类型列表
	self._gameNames = {};		--// 游戏名称列表
	self._gameList = {};		--游戏列表 新加的 为大厅模式
	self._selectedGame = nil; 	--// 当前选中的游戏
	self.isStart = nil;
	self.isEnd = false;
end

function GamesInfoModule:selectedGame()
	return self._selectedGame;
end

function GamesInfoModule:selectedGame(game)
	self._selectedGame = game;
end

function GamesInfoModule:getGameNameCount()
	return getTableLength(_gameNames);
end

-- 获取游戏信息
function GamesInfoModule:getGameNameByKindID(kindID)
	for k,v in pairs(self._gameNames) do
		if v.uKindID == kindID then
			return v;
		end
	end

	return nil;
end

-- 获取游戏信息
function GamesInfoModule:getGameNameByPos(pos)
	if pos >= getTableLength(sellf._gameNames) then
		return nil;
	end

	if next(self._gameNames) then
		return self._gameNames[pos];
	end

	return nil;
end

-- 添加游戏类型
function GamesInfoModule:addGameKind(kindInfo)
	if kindInfo ~= nil then
		local game = self:findGameKind(kindInfo.uKindID);
		if game ~= nil then
			for k,v in pairs(self._gameKinds) do
				if v.uKindID == kindInfo.uKindID then
					self._gameKinds[k] = kindInfo;
					break;
				end
			end
		else
			table.insert(self._gameKinds, kindInfo);
		end
	end
end

-- 添加游戏名称
function GamesInfoModule:addGameName(nameInfo)
	if nameInfo == nil then
		return;
	end

	self.isStart = true;

	local game = self:findGameName(nameInfo.uNameID);
	if game ~= nil then
		for k,v in pairs(self._gameNames) do
			if v.uNameID == nameInfo.uNameID then
				nameInfo.szType = self._gameNames[k].szType
				self._gameNames[k] = nameInfo;
				break;
			end
		end
	else
		nameInfo.szGameName = string.lower(nameInfo.szGameName)

		nameInfo.szType = ""

		if nameInfo.szGameName == "lkpy_0" or nameInfo.szGameName == "lkpy_4" or nameInfo.szGameName == "lkpy_1" or nameInfo.szGameName == "lkpy_5"or nameInfo.szGameName == "lkpy_2" or nameInfo.szGameName == "lkpy_6" then
			nameInfo.szType = nameInfo.szType..4
		end

		if nameInfo.szGameName == "dz_shuiguoji" or
			nameInfo.szGameName == "game_shz" or
			nameInfo.szGameName == "game_tgpd" or
			nameInfo.szGameName == "game_lhdb" or
			nameInfo.szGameName == "game_ppc" or
			nameInfo.szGameName == "game_slhb" or
			nameInfo.szGameName == "game_fqzs" then
			nameInfo.szType = nameInfo.szType..3
		end

		if nameInfo.szGameName == "game_30miao" or
			nameInfo.szGameName == "game_brps" or
			nameInfo.szGameName == "game_lhd" or
			nameInfo.szGameName == "game_hhdz" or
			nameInfo.szGameName == "game_yyy" or
			nameInfo.szGameName == "dz_ddz" or
			nameInfo.szGameName == "dz_szp" or
			nameInfo.szGameName == "dz_ernn" or
			nameInfo.szGameName == "dz_qzps" or
			nameInfo.szGameName == "dz_ssz" then
			nameInfo.szType = nameInfo.szType..2
		end

		-- if nameInfo.szGameName == "lkpy_0" or
		-- 	nameInfo.szGameName == "lkpy_4" or
		-- 	nameInfo.szGameName == "dz_szp" or
		-- 	nameInfo.szGameName == "dz_qzps" or
		-- 	nameInfo.szGameName == "game_lhd" or
		-- 	nameInfo.szGameName == "dz_ddz" or
		-- 	nameInfo.szGameName == "game_slhb" or
		-- 	-- nameInfo.szGameName == "game_shz" or
		-- 	nameInfo.szGameName == "game_brps" or
		-- 	nameInfo.szGameName == "game_lhdb" or
		-- 	nameInfo.szGameName == "game_ppc" then
		-- 	nameInfo.szType = nameInfo.szType..1
		-- end

		nameInfo.szType = nameInfo.szType..1

		table.insert(self._gameNames, nameInfo);
		if not GameCreator:findGame(nameInfo.uNameID) then
			local game = {
						nameInfo.uNameID, 
						GAMETYPE.MATHC_GAME,
						function(uNameId, bDeskIndex, bAutoCreate, bMaster) return TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);  end, 
						function(uNameId, bMySeatNo, roompwd, players) return ReplayLayer:create(uNameId, bMySeatNo, roompwd, players); end
					}
			GameCreator:addGame(game[1], game[2], game[3], nil, game[4]);
		end
	end

	self:addGameList(nameInfo);
end

-- 查找游戏数据
function GamesInfoModule:findGameName(gameID)
	for k,v in pairs(self._gameNames) do
		if v.uNameID == gameID then
			return v;
		end
	end

	return nil;
end

-- 查找游戏数据
function GamesInfoModule:findGameKind(kindID)
	--luaDump(self._gameKinds,"self._gameKinds")
	for k,v in pairs(self._gameKinds) do
		if v.uKindID == kindID then
			return v;
		end
	end

	return nil;
end

--游戏类别
function GamesInfoModule:addGameList(nameInfo)
	if nameInfo == nil then
		return;
	end

	local name = string.split(nameInfo.szGameName,"_")[1];
	name = string.lower(name);
	-- if name ~= string.lower("LKPY") then
		-- return;
	-- end

	local game, ret = self:findGame(name,nameInfo.uNameID);

	nameInfo.isSigleMode = 0;
	if nameInfo.uNameID == 40010000 or nameInfo.uNameID == 40010001 or nameInfo.uNameID == 40010002 then
		nameInfo.isSigleMode = 1;
	elseif nameInfo.uNameID == 40020000 then
		nameInfo.isSigleMode = 2;
	end

	if game ~= nil then
		for k,v in pairs(self._gameList) do
			if v[name] then
				for kk,vv in pairs(v[name]) do
					local gold = vv[kk].needMinGold;
					vv[kk] = nameInfo;
					vv[kk].needMinGold = gold;
					break;
				end
			end
		end
	else
		if ret == 0 then
			self._gameList[name] = {};
		end

		table.insert(self._gameList[name], nameInfo);

		if isGameMode then--  2018-06-30 11:48:39 游戏列表模式
			local msg = {};
			msg.iNameID = nameInfo.uNameID;
			PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY);
		end
	end

	-- luaDump(self._gameList,"self._gameList")
end

--值1 游戏信息 2 
function GamesInfoModule:findGame(listID, gameID)
	listID = string.lower(listID)
	if self._gameList[listID] == nil then
		return nil, 0;
	end

	for k,v in pairs(self._gameList) do
		if v[listID] then
			for kk,vv in pairs(v[listID]) do
				if vv.uNameID == gameID then
					return vv, 1;
				end
			end
		end
	end

	return nil, 2;
end

--0单人模式 ，1多人模式
function GamesInfoModule:findGameList(listID, mode)
	listID = string.lower(listID)
	mode = mode or 1;

	local temp = {};
	local i = 1;

	if self._gameList[listID] ~= nil then
		if listID == "lkpy" then
			for k,v in pairs(self._gameList[listID]) do
				if v.isSigleMode == mode then
					temp[i] = v
					i = i + 1
				end
			end
		else
			for k,v in pairs(self._gameList[listID]) do
				temp[i] = v
				i = i + 1
			end
		end
	end

	return temp;
end

function GamesInfoModule:isSigleMode(nameID)
	if type(nameID) ~= "number" or nameID <= 0 then
		return true;
	end


	for k,list in pairs(self._gameList) do
		for kk,game in pairs(list) do
			if game.uNameID == nameID then
				return (game.isSigleMode == 1);
			end
		end
	end

	return false;
end

function GamesInfoModule:getGameList()
	local temp = {};

	--第一次上来还没请求到游戏
	-- if next(self._gameList) == nil and self.copyGameList == nil then
	-- 	return temp;
	-- --后续刷新失败,用原数据
	-- elseif next(self._gameList) == nil and self.copyGameList ~= nil and type(self.copyGameList) == "table" and next(self.copyGameList) ~= nil then
	-- 	self._gameList = clone(self.copyGameList);
	-- 	self.copyGameList = nil;
	-- end

	if self.isEnd ~= true then
		if self.copyGameList ~= nil and type(self.copyGameList) == "table" and next(self.copyGameList) ~= nil then
			for k,v in pairs(self.copyGameList) do
				temp[k] = v;
			end
		end
	else
		for k,v in pairs(self._gameList) do
			temp[k] = v;
		end
	end

	return temp;
end

function GamesInfoModule:isGameListEmpty()
	if next(self._gameList) == nil then
		return true;
	end

	return false;
end

--更新金币场需要的钻石
function GamesInfoModule:updateGameListGold(nameID, minGold)
	for k,list in pairs(self._gameList) do
		for kk,game in pairs(list) do
			if game.uNameID == nameID then
				game.needMinGold = minGold;
				break;
			end
		end
	end
end

function GamesInfoModule:getGameListGold(nameID)
	for k,list in pairs(self._gameList) do
		for kk,game in pairs(list) do
			if game.uNameID == nameID then
				return game.needMinGold;
			end
		end
	end
end

-- 清空游戏数据
function GamesInfoModule:clear()
	self.isStart = nil;
	self.isEnd = false;
	if next(self._gameList) ~= nil then
		self.copyGameList = clone(self._gameList);
	end
	self._gameKinds = {};
	self._gameNames = {};
	self._gameList = {};--游戏列表 新加的 为大厅模式
	GameCreator:initData()
end

--遍历游戏数据
function GamesInfoModule:transform(func)
	for k,v in pairs(self._gameList) do
		if func then
			func(v, k);
		end
	end
end

-- 当前游戏是否是客户端匹配模式
function GamesInfoModule:isMatchMode(uNameId)
	if uNameId == nil then
		uNameId = GameCreator:getCurrentGameNameID()
	end

	if uNameId == 40023000 or uNameId == 40028000 or uNameId == 40021000 or uNameId == 40028010 or uNameId == 40022000 or uNameId == 40024000 then
		return true
	end

	return false
end

return GamesInfoModule
