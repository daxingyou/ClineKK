--金币房
local CreateGoldRoomLayer = class("CreateGoldRoomLayer", BaseWindow)

function CreateGoldRoomLayer:create(gameName)
	return CreateGoldRoomLayer.new(gameName)
end

function CreateGoldRoomLayer:ctor(gameName)
	self.super.ctor(self, 0, true)

	self.gameName = gameName

	self:initData()

	--self:hide()
	-- self:initUI()

	self:bindEvent()

	addSound();
end

function CreateGoldRoomLayer:initData()
	self.m_selectedNameID = 0
	self.m_selectedRoomID = 0
end

function CreateGoldRoomLayer:initUI()
	local winSize = cc.Director:getInstance():getWinSize()

	local bg = ccui.ImageView:create("common/bg.png")
	bg:setPosition(winSize.width/2,winSize.height/2)
	self:addChild(bg)
	self.bg = bg

	local size = bg:getContentSize()

	self.touchLayer = display.newLayer()
	self.touchLayer:setTouchEnabled(true)
	self.touchLayer:setLocalZOrder(100)
	self:addChild(self.touchLayer)
	self.touchLayer:onTouch(function(event) 
							local eventType = event.name
							if eventType == "began" then
								return true
							end
				end,false, true)

	local top = ccui.ImageView:create("hall/topBg.png")
	top:setAnchorPoint(0.5,1)
	top:setPosition(size.width/2,size.height)
	bg:addChild(top)
	top:setLocalZOrder(20)
	self.topImage = top

	local titleBg = ccui.ImageView:create("hall/titleBg.png")
	titleBg:setAnchorPoint(0,1)
	titleBg:setPosition(0,top:getContentSize().height)
	top:addChild(titleBg)

	local title = ccui.ImageView:create("createRoom/title.png")
	title:setPosition(270,titleBg:getContentSize().height*0.62)
	titleBg:addChild(title)

	--规则
	local btn = ccui.Button:create("hall/guize.png","hall/guize-on.png")
	btn:setPosition(top:getContentSize().width*0.85-100, top:getContentSize().height/2+10)
	btn:setTag(1)
	top:addChild(btn)
	btn:onClick(handler(self, self.onClick))

	if checkIphoneX() then
		btn:setPositionX(btn:getPositionX() + 150)
	end

	--退出
	local btn = ccui.Button:create("hall/fanhui.png","hall/fanhui-on.png")
	btn:setPosition(top:getContentSize().width*0.85, top:getContentSize().height/2+10)
	btn:setTag(2)
	top:addChild(btn)
	btn:onClick(handler(self, self.onClick))

	if checkIphoneX() then
		btn:setPositionX(btn:getPositionX() + 150)
	end

	local node = require("layer.popView.UserInfoNode"):create()
	node:setPosition(top:getContentSize().width*0.35,top:getContentSize().height*0.65)
	top:addChild(node)

	local node = require("layer.popView.BottomNode"):create()
	node:setPosition(size.width/2,0)
	self.bg:addChild(node)
	self.bottomNode = node

	local mask = ccui.ImageView:create("hall/duorenMask.png")
	mask:setPosition(size.width/2,size.height/2)
	-- mask:setName("mask")
	self.bg:addChild(mask)
	self.mask = mask

	local btn = ccui.Button:create("createRoom/1.png","createRoom/1-on.png")
	btn:setPosition(mask:getContentSize().width*3/4-50,mask:getContentSize().height/2)
	btn:setTag(1)
	mask:addChild(btn)
	btn:setLocalZOrder(2)
	btn:onClick(handler(self,self.enterGame))

	-- local difen = FontConfig.createWithCharMap("","createRoom/num.png",14,19,"+")
	-- difen:setPosition(btn:getContentSize().width*0.5,65)
	-- btn:addChild(difen)
	-- self.difen = difen

	-- local btn = ccui.Button:create("createRoom/2.png","createRoom/2-on.png")
	-- btn:setPosition(mask:getContentSize().width/4+50,mask:getContentSize().height/2)
	-- btn:setTag(2)
	-- mask:addChild(btn)
	-- btn:setLocalZOrder(2)
	-- btn:onClick(handler(self,self.enterGame))
end

function CreateGoldRoomLayer:initGameData()
	local gameList = GamesInfoModule:findGameList("dz")

	self.gameList = gameList or {}
	-- luaDump(self.gameList)

	table.sort(self.gameList, function(a,b) return a.uNameID < b.uNameID end)
end

function CreateGoldRoomLayer:onEnter()
	--self:bindEvent()
	self.super.onEnter(self)
end

function CreateGoldRoomLayer:onEnterTransitionFinish()
	self:showFangjian()
	self.super.onEnterTransitionFinish(self)
	iphoneXFit(self.mask,4)
end

function CreateGoldRoomLayer:showFangjian()
	local VisibleCount = 0

	self:initGameData()

	VisibleCount = #self.gameList

	if VisibleCount == 0 then
		LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在请求游戏列表,请稍后"), LOADING):removeTimer()
		dispatchEvent("requestGameList")
	else
		local ret = false
		local index = 0
		for k,v in pairs(self.gameList) do
			if string.find(v.szGameName,self.gameName) then
				ret = true
				self.m_selectedNameID = v.uNameID
				index = k
				break
			end
		end

		if ret then
			-- //设置当前游戏
			GameCreator:setCurrentGame(self.m_selectedNameID);

			local roomList = RoomInfoModule:getRoomInfoByNameID(self.gameList[index].uNameID)

			self.roomList = roomList or {}
			-- luaDump(self.roomList,"self.roomList")
			table.sort(self.roomList, function(a,b) return a.uRoomID < b.uRoomID; end);

			if #self.roomList == 0 then
				dispatchEvent("requestRoomList")
				return
			else

				self:enterGame();

				if self.touchLayer then
					self.touchLayer:removeSelf()
					self.touchLayer = nil
				end
			end
		else
			luaPrint(self.gameName.." 在游戏列表中 名字异常！")
			addScrollMessage("进入游戏失败！")
			self:delayCloseLayer(0)
		end

	end
end

function CreateGoldRoomLayer:refreshGameList()
	LoadingLayer:removeLoading()
	self:showFangjian()
end

function CreateGoldRoomLayer:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_GameList",function () self:refreshGameList() end);

	self:pushGlobalEventInfo("requestGameListSuccess",handler(self, self.refreshGameList))
	self:pushGlobalEventInfo("I_P_M_RoomList",handler(self, self.refreshGameList))
	self:pushGlobalEventInfo("loginRoom",handler(self, self.loginRoom))
end

function CreateGoldRoomLayer:unBindEvent()
	if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
		return
	end
	
	for _, bindid in pairs(self.bindIds) do
		Event:unRegisterListener(bindid)
	end
end

function CreateGoldRoomLayer:onExit()
	self.super.onExit(self)

	self:unBindEvent()
end

function CreateGoldRoomLayer:enterGame()

	if not self.roomList[1] then
		addScrollMessage("该房间未开！")
		return
	end

	self.roomList[1].isTryPlay = false;

	self.m_selectedRoomID = self.roomList[1].uRoomID
	luaPrint("m_selectedNameID == "..self.m_selectedNameID)

	if GamesInfoModule:findGameName(self.m_selectedNameID) == nil then
		--addScrollMessage("奔驰宝马暂未开放!")
		dispatchEvent("requestRoomList")
		return
	end

	GameCreator:setCurrentGame(self.m_selectedNameID)

	local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.m_selectedRoomID)
	if gold then
		globalUnit:setEnterGameID(self.m_selectedNameID.."_"..self.m_selectedRoomID)
		self:getMatchRoomMinRoomKey(gold,"最低需要"..goldConvert(gold).."金币以上！")
		performWithDelay(self,function() Hall:exitGame(); end, 0.05)
		
	else
		local msg = {};
		msg.iNameID = self.m_selectedNameID
		msg.iRoomID = self.m_selectedRoomID
		PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY);
		self:delayCloseLayer(0)
	end
end

function CreateGoldRoomLayer:getMatchRoomMinRoomKey(data,msg)
	self.m_nMatchMinRoomKey = data
	globalUnit.nMinRoomKey = data

	self:showCreateRoomLayer(msg)
end

function CreateGoldRoomLayer:showCreateRoomLayer(msg)
	if PlatformLogic.loginResult.i64Money < self.m_nMatchMinRoomKey then
		addScrollMessage("抱歉，您的金币低于入场最低限制"..string.format("%.2f",goldConvert(globalUnit.nMinRoomKey)).."，不能进入该游戏房间！")
		showBuyTip()
		return
	end

	self:setBtnEnabled(true)

	if self.m_pMatchRoomCallBack then
		Hall.showTextState("正在加载房间信息",10,function() self:setBtnEnabled() end)
		self.m_pMatchRoomCallBack()
	else
		dispatchEvent("matchRoom",self.m_selectedRoomID)
	end
end

function CreateGoldRoomLayer:setBtnEnabled(flag)
	if flag then
		if self.touchLayer == nil then
			self.touchLayer = display.newLayer()
			self.touchLayer:setTouchEnabled(true)
			self.touchLayer:setLocalZOrder(100)
			self:addChild(self.touchLayer)
			self.touchLayer:onTouch(function(event) 
						local eventType = event.name
						if eventType == "began" then
							return true
						end
			end,false, true)
		end
	else
		if self.touchLayer ~= nil then
			self.touchLayer:removeSelf()
			self.touchLayer = nil
		end
	end
end

function CreateGoldRoomLayer:onClick(sender)
	local tag = sender:getTag()

	if tag == 1 then
		display.getRunningScene():addChild(require("GameRuleLayer"):create());
	elseif tag == 2 then
		Hall:exitGame()
	end
end

function CreateGoldRoomLayer:loginRoom(event)
	local runningScene = display.getRunningScene()

	if runningScene:getChildByTag(1111111) then
		runningScene:removeChildByTag(1111111)
	end

	self:setBtnEnabled()
end

return CreateGoldRoomLayer
