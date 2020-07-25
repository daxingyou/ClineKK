--房间类

local GameRoom = class("GameRoom")
local RoomLogicBase = require("logic.roomLogic.RoomLogicBase");

local enter_game_desk_outtime_timer = 30.0;
local update_game_room_people_timer = 2.0;
local connect_room_text		= "连接房间......";
local login_room_text			= "登陆房间......";
local request_room_info_text	= "获取房间数据......";
local allocation_table_please_wait_text = "正在配桌，请稍后......";
local enterGame_please_wait_text = "正在进入游戏，请稍后......";

local FK_SET_TAG = 1000;
local MM_SET_TAG = 1001;
local TS_SET_TAG = 1002;

local _gameRoom = nil;

function GameRoom:getInstance()
	if _gameRoom == nil then
		_gameRoom = GameRoom.new();
	end

	return _gameRoom;
end

function GameRoom:ctor()
	self:initData();
end

function GameRoom:initData()
	self.RoomNameID = 0;
	self.RoomID = 0;
	self._roomID = 0;
	self._fastEnterMatch = false;
	self._overdueTime = false;					--//获得的开赛时间是否过期
	self._isTouch = true;
	self.onEnterDeskCallBack = nil;
	self.onMatchDeskCallBack = nil;
	self.onCloseCallBack = nil;

	self.roomLogicBase = RoomLogicBase.new(self);
end

function GameRoom:setOnCloseCallBack(func)
	self.onCloseCallBack = func;
end

function GameRoom:setOnEnterDeskCallBack(func)
	self.onEnterDeskCallBack = func;
end

function GameRoom:setOnMatchDeskCallBack(func)
	self.onMatchDeskCallBack = func;
end

function GameRoom:setCancelCallback(func)
	self.CancelCallback = func
end

function GameRoom:setRoomID(roomid)
	self._roomID = roomid;
end

function GameRoom:clear()
	self.RoomNameID = 0;
	self.RoomID = 0;
	self._roomID = 0;
	self._fastEnterMatch = false;
	self._overdueTime = false;					--//获得的开赛时间是否过期
	self._isTouch = true;

	if self.roomLogicBase then
		self.roomLogicBase:stop();
	end
	
	self.roomLogicBase = nil;

	_gameRoom = nil;
end

--//登陆房间回调
function GameRoom:onRoomLoginCallback(success, message, roomID)
	local success = success or false;
	local message = message or "";
	local roomID = roomID or 0;

	if success then
		luaPrint("the user enters a room complete message!");
		
		local roomInfo = nil;
		if self._fastEnterMatch then
			self._fastEnterMatch = false;
			roomInfo = RoomInfoModule:getByRoomID(getTimeMatchRoomID());
		else
			roomInfo = RoomInfoModule:getByRoomID(self._roomID);
		end

		if roomInfo then
			RoomLogic:setSelectedRoom(roomInfo);
			RoomLogic:setRoomRule(roomInfo.dwRoomRule);
		end

		if not bit:_and(RoomLogic:getRoomRule(), GRR_CONTEST) or not bit:_and(RoomLogic:getRoomRule(), GRR_TIMINGCONTEST) then --	// 定时淘汰比赛场
			luaPrint("定时淘汰比赛场");
			self.roomLogicBase:stop();

			if self._overdueTime then
				self._isTouch = true;
				self._overdueTime = false;
				GamePromptLayer:create():showPrompt("定时赛已过期");
				RoomLogic:close();
				return;
			end
			
			LoadingLayer:removeLoading();
			-- GameMatch::createMatch(_isRecom);
		elseif  not bit:_and(RoomLogic:getRoomRule(), GRR_QUEUE_GAME) then		--// 排队机
			luaPrint("排队机");
			local loading = LoadingLayer:createLoading(FontConfig.gFontConfig_22, allocation_table_please_wait_text, LOADING);
			-- Button* cancel = (Button*)loading->getChildByTag(4444);
			-- if (nullptr!=cancel){
			-- 	cancel->addTouchEventListener(CC_CALLBACK_2(GameRoom::cancelCallback, this));
			-- }
			-- // 进入排队游戏
			self.roomLogicBase:requestJoinQueue();
		else												--// 金币场不扣积分
			luaPrint("金币场不扣积分 getCurrentGameType "..GameCreator:getCurrentGameType())
			if GameCreator:getCurrentGameType() == GAMETYPE.NORMAL then
				self._isTouch = true;

				if self.onEnterDeskCallBack ~= nil then
					luaPrint("self.onEnterDeskCallBack --------")
					self:onEnterDeskCallBack(RoomLogic:getSelectedRoom());
				end

				self:clear();

				LoadingLayer:removeLoading();
			elseif GameCreator:getCurrentGameType() == GAMETYPE.BR then
				LoadingLayer:createLoading(FontConfig.gFontConfig_22, enterGame_please_wait_text, LOADING);
				self.roomLogicBase:requestSit(0, 0);
			elseif GameCreator:getCurrentGameType() == GAMETYPE.SINGLE then
				LoadingLayer:createLoading(FontConfiggFontConfig_22, enterGame_please_wait_text, LOADING);
				for i=1,roomInfo.uDeskCount do
					local k = i - 1;

					local deskUsers = UserInfoModule:findGameUsers(k);
					-- // 是否锁桌
					local value = bit:_and(RoomLogic.deskStation.bVirtualDesk[math.floor(k/8)], bit:_lshift(1, (k % 8)));

					if next(deskUsers) == nil and value == 0 then
						self.roomLogicBase:requestSit(k, 0);
						break;
					end
				end
			-- //匹配场
			elseif GameCreator:getCurrentGameType() == GAMETYPE.MATHC_GAME then
				if GamesInfoModule:isMatchMode() then-- or GameCreator:getCurrentGameNameID() == 40021000 then
					-- LoadingLayer:createLoading(FontConfig.gFontConfig_22, "正在加载房间信息...", LOADING)
				else
					LoadingLayer:createLoading(FontConfig.gFontConfig_22, "正在加载房间信息,请稍后", LOADING):removeTimer(10,function() RoomLogic:close(); dispatchEvent("loginRoom") end);
				end

				globalUnit.isNoTipBack = false

				-- //开始匹配房间(实际上是在找到桌子坐下去)
				if GamesInfoModule:isMatchMode() then
					self.roomLogicBase:stop()
					LoadingLayer:removeLoading()
					if display.getRunningScene():getChildByName("deskLayer") or display.getRunningScene():getChildByName("mGameLayer") then
						luaPrint("display.getRunningScene():getChildByName(deskLaye) ==================== have ")
						dispatchEvent("roomLoginSuccess")
					else
						globalUnit.isStartMatch = true
						luaPrint("display.getRunningScene():getChildByName(deskLaye)------------------------ no have ")
						Hall:selectedGame(Hall:getCurGameName())
						globalUnit.isStartMatch = false
					end
				else
					local uNameId = GameCreator:getCurrentGameNameID()

					if globalUnit.gameName ~= nil and (uNameId == 40023000 or uNameId == 40028000 or uNameId == 40021000
					or uNameId == 40011000 or uNameId == 40012000 or uNameId == 40013000 or uNameId == 40028010
					or uNameId == 40014000 or uNameId == 40015000 or uNameId == 40016000
					or uNameId == 40017000) then
						if globalUnit.bIsSelectDesk == true then
							if not RoomInfoModule:isCashRoom(uNameId,globalUnit.selectedRoomID) then
								self.roomLogicBase:requestMatchDesk()
							else
								LoadingLayer:removeLoading()
								dispatchEvent("loginRoom")
							end
						else
							self.roomLogicBase:requestMatchDesk()
						end
					else
						local name = Hall:getCurGameName();
						local isDuizhan = false
						if name == "qiangzhuangniuniu" or name == "doudizhu" or name == "sanzhangpai" or name == "errenniuniu"
						or name == "ershiyidian" or name == "shidianban" or name == "dezhoupuke" or name == "shisanzhang" or name == "shisanzhanglq" then
							isDuizhan = true
						end
						if globalUnit.nowTingId > 0 and globalUnit.VipRoomList and isDuizhan then
							local layer = display.getRunningScene():getChildByName("deskLayer")
							if not layer then 
								Hall:selectedGame(Hall:getCurGameName())
							else
								self.roomLogicBase:stop()
								LoadingLayer:removeLoading()
								dispatchEvent("roomLoginSuccess")
							end
						else
							self.roomLogicBase:requestMatchDesk()
						end
					end
				end
			end
		end
	else
		Hall.closeTips();
		self._isTouch = true;
		self.roomLogicBase:stop();
		Hall:setHallBackRoom(nil)
		if display.getRunningScene():getChildByName("deskLayer") then
			dispatchEvent("exitGameBackPlatform")
		end
		RoomLogic:close()

		dispatchEvent("loginRoom")

		local layer = GamePromptLayer:create()
		layer:setBtnClickCallBack(function()
			if Hall:isHaveGameLayer() then
				RoomLogic:close()
				Hall:exitGame(nil,function() globalUnit.isEnterGame = false end,0)
			end
		end)
		layer:showPrompt(message);
	end
end

function GameRoom:onRoomSitCallback(success, message, roomID, deskNo, seatNo, bMaster)
	LoadingLayer:removeLoading();
	self._isTouch = true;

	if success then
		if self.roomLogicBase then
			self.roomLogicBase:stop();
		end

		if INVALID_DESKNO ~= deskNo and INVALID_DESKSTATION ~= seatNo then
			-- // 启动游戏
			luaPrint("启动游戏 RoomLogic:getSelectedRoom().uNameID ： "..RoomLogic:getSelectedRoom().uNameID.." ,deskNo = "..deskNo.." bMaster = "..tostring(bMaster));
			local ret = GameCreator:startGameClient(RoomLogic:getSelectedRoom().uNameID, deskNo, true, bMaster);
			if not ret then
				GamePromptLayer:create():showPrompt("游戏启动失败。");
			end
		end
	else
		dispatchEvent("loginRoom")
		local prompt = GamePromptLayer:create();
		prompt:showPrompt(message);
		prompt:setBtnClickCallBack(function() 
			if GameCreator:getCurrentGameType() == GAMETYPE.SINGLE or GameCreator:getCurrentGameType() == GAMETYPE.BR then
				RoomLogic:close();
				self.roomLogicBase:stop();
				Hall:setHallBackRoom(nil)
			end
		 end);
	end
end

function GameRoom:onRoomQueueSitCallback(success, message, roomID, deskNo)
	LoadingLayer:removeLoading(self);
	self.roomLogicBase:stop();
	self._isTouch = true;

	if success then
		if INVALID_DESKNO ~= deskNo then
			-- // 启动游戏
			local ret = GameCreator:startGameClient(RoomLogic:getSelectedRoom().uNameID, deskNo, true, false);
			if not ret then
				GamePromptLayer:create():showPrompt("游戏启动失败。");
			end
		end
	else
		GamePromptLayer:create():showPrompt(message);
	end
end

function GameRoom:onRoomDisConnect(message)
	LoadingLayer:removeLoading();
	local prompt = GamePromptLayer:create();
	prompt:showPrompt(message);
	prompt:setBtnClickCallBack(function() 
		-- 回到登陆页
		Hall.startGame();
	end);
end

-- //匹配房间成功请求坐下
function GameRoom:onMatchRoomSuccessful(uDeskNO)
	if RoomMsg.ERR_GR_FULL_DESK == uDeskNO then          --  //桌子已满
		return;
	end

	self.roomLogicBase:stop();

	if self.onMatchDeskCallBack ~= nil then
		self._isTouch = true;
		self.onMatchDeskCallBack(RoomLogic:getSelectedRoom(), uDeskNO);
	end
end

-- // 房间密码
function GameRoom:onPlatformRoomPassEnter(success, roomId)
	if success then
		self.roomLogicBase:start();
		self.roomLogicBase:requestLogin(roomId);
	else
		GamePromptLayer:create():showPrompt("房间密码错误");
	end
end

function GameRoom:getTimeMatchRoomID()
	for i=1,10 do
		local k = i -1;
		if cc.UserDefault:getInstance():getIntegerForKey("MARK_"..k) == 3 then
			local roomID = cc.UserDefault:getInstance():getIntegerForKey("RoomID_"..K);
			self._fastEnterMatch = true;
			return roomID;
		end
	end
	return 255;
end

return GameRoom;
