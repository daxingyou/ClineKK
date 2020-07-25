--金币房
local CreateGoldRoomLayer = class("CreateGoldRoomLayer", BaseWindow)

function CreateGoldRoomLayer:create(gameName)
	return CreateGoldRoomLayer.new(gameName)
end

function CreateGoldRoomLayer:ctor(gameName)
	self.super.ctor(self, 0, true)

	self.gameName = gameName

	self:initData()

	self:initUI()

	self:bindEvent()

	self:setVisible(false);

	addSound();
end

function CreateGoldRoomLayer:initData()
	self.m_selectedNameID = 0
	self.m_selectedRoomID = 0
	self.layoutBtn = {}
end

function CreateGoldRoomLayer:initGameData()
	local gameList = GamesInfoModule:findGameList("game")

	self.gameList = gameList or {}
	-- luaDump(self.gameList)

	table.sort(self.gameList, function(a,b) return a.uNameID < b.uNameID end)
end

function CreateGoldRoomLayer:initUI()
	local winSize = cc.Director:getInstance():getWinSize()

	local bg = ccui.ImageView:create("game/roombg.png")
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

	local top = ccui.ImageView:create("hall/titleBg1.png")
	top:setAnchorPoint(0.5,1)
	top:setPosition(size.width/2,size.height)
	bg:addChild(top)
	self.topImage = top

	local title = ccui.ImageView:create("createRoom/title.png")
	title:setPosition(top:getContentSize().width/2,top:getContentSize().height/2+5)
	top:addChild(title)

	--退出
	local btn = ccui.Button:create("game/fanhui.png","game/fanhui-on.png")
	btn:setAnchorPoint(1,1)
	btn:setPosition(1419.5+(winSize.width-1280)/2, top:getContentSize().height)
	btn:setTag(2)
	top:addChild(btn)
	btn:onClick(handler(self, self.onClick))


	--规则
	local btn1 = ccui.Button:create("hall/guize.png","hall/guize-on.png")
	btn1:setPosition(199.5-(winSize.width-1280)/2, top:getContentSize().height/2+5)
	btn1:setTag(1)
	top:addChild(btn1)
	btn1:onClick(handler(self, self.onClick))
	-- local node = require("layer.popView.UserInfoNode"):create()
	-- node:setPosition(top:getContentSize().width*0.4,top:getContentSize().height*0.65)
	-- top:addChild(node)

	local node = require("layer.popView.BottomNode"):create()
	node:setPosition(size.width/2,0)
	self.bg:addChild(node)
	self.bottomNode = node

	local listView = ccui.ListView:create()
	listView:setAnchorPoint(cc.p(0,0))
	listView:setDirection(ccui.ScrollViewDir.horizontal)
	listView:setBounceEnabled(true)
	listView:setContentSize(cc.size(winSize.width,480))
	listView:setPosition((1559-winSize.width)/2,100)
	listView:setScrollBarEnabled(false)
	listView:setClippingEnabled(false)
	self.bg:addChild(listView)
	self.listView = listView

	local layoutWidth = (winSize.width - 380*4)/2;
	if layoutWidth<0 then
		layoutWidth = 0;
	end
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(layoutWidth, self.listView:getContentSize().height))
	self.listView:pushBackCustomItem(layout)
	for i=1,4 do -- 3 体验场
		local layout = self:createRoomGroup(i,5)
		self.listView:pushBackCustomItem(layout)
	end
end
function CreateGoldRoomLayer:createRoomGroup(groupId,num)
	if groupId > num then
		return;
	end
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(380,self.listView:getContentSize().height))

	local temp = {}
	local node = self:createItem(groupId);
	layout:addChild(node);
	node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2);
	table.insert(temp,node);
	table.insert(self.layoutBtn,temp)
	return layout
end
function CreateGoldRoomLayer:createItem(tag)
	luaPrint("createItem",tag);
	local radScore = {"50","50","500","500"}
	local ruchang = {"10.00","10.00","30.00","30.00"}

	local roomTag = tag;
	if roomTag > 2 then
		roomTag = roomTag-2;
	end

	local btn = ccui.Button:create("createRoom/"..(roomTag)..".png","createRoom/"..(roomTag).."-on.png")
	btn:setTag(tag)
	-- if tag >3 then
	-- 	btn:setTag(tag);
	-- end
	btn:onClick(handler(self, self.enterGame))
	local size = btn:getContentSize()
	if radScore[tag] then
		local add = "";
		-- if tag>2 then
		-- 	add = "add";
		-- end
		local str = "createRoom/"..add.."10.png"
		if tag%2 == 0 then
			str = "createRoom/"..add.."7.png"
		end
		local image = ccui.ImageView:create(str);
	btn:addChild(image)
		image:setPosition(btn:getContentSize().width*0.5,190);

		local text = ccui.Text:create("红包额度:10-"..radScore[tag].."元",FONT_PTY_TEXT,25);
	text:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2-100)
	text:setColor(cc.c3b(255,225,146));
	btn:addChild(text)

		local difen = FontConfig.createWithSystemFont(ruchang[tag].."入场",25)
		difen:setPosition(size.width/2,size.height/2-135)
		btn:addChild(difen)
		difen:setColor(cc.c3b(255,225,146));
	end
	return btn
end

function CreateGoldRoomLayer:onEnter()
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
			luaDump(self.roomList,"self.roomList")
			table.sort(self.roomList, function(a,b) return a.uRoomID < b.uRoomID; end);

			if #self.roomList == 0 then
				dispatchEvent("requestRoomList")
				return
			else
				-- self.difen:setText(goldConvert(RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.roomList[1].uRoomID),1))
				-- local image = ccui.ImageView:create("createRoom/gold.png")
				-- image:setPosition(-10,self.difen:getContentSize().height/2)
				-- image:setAnchorPoint(1,0.5)
				-- self.difen:addChild(image)

				-- local image = ccui.ImageView:create("createRoom/ruchang.png")
				-- image:setPosition(self.difen:getContentSize().width,self.difen:getContentSize().height/2)
				-- image:setAnchorPoint(0,0.5)
				-- self.difen:addChild(image)

				if self.touchLayer then
					self.touchLayer:removeSelf()
					self.touchLayer = nil
				end

				self:enterGame(3);
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

	self:pushGlobalEventInfo("roomLoginFail",handler(self, self.onRoomLoginFail))--断线重连刷新
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

function CreateGoldRoomLayer:enterGame(sender)
	local tag = sender

	if type(sender) ~= "number" then
		tag = sender:getTag()
	end

	if not self.roomList[tag] then
		-- addScrollMessage("该房间未开！")
		dispatchEvent("requestGameList")
		return
	end

	local mRoomId = {144,145,114,115};

	self.m_selectedRoomID = mRoomId[tag];

	local findFlag = false;
	for k,v in pairs(self.roomList) do
		if v.uRoomID == self.m_selectedRoomID then
			findFlag = true;
			break;
		end
	end

	if findFlag == false then
		--addScrollMessage(msg.."暂未开放!")
		dispatchEvent("requestGameList")
		return
	end

	GameCreator:setCurrentGame(self.m_selectedNameID)

	local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.m_selectedRoomID)

	if gold then
		globalUnit:setEnterGameID(self.m_selectedNameID.."_"..self.m_selectedRoomID)
		self:getMatchRoomMinRoomKey(gold,"最低需要"..goldConvert(gold).."金币以上！")

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
		showBuyTip(true)
		return
	end

	self:setBtnEnabled(true)

	if self.m_pMatchRoomCallBack then
		Hall.showTextState("正在加载房间信息",10,function() self:setBtnEnabled() end)
		self.m_pMatchRoomCallBack()
	else
		dispatchEvent("matchRoom",self.m_selectedRoomID)
		globalUnit.selectedRoomID = self.m_selectedRoomID;
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
		display.getRunningScene():addChild(require("saoleihongbao.HelpLayer"):create());
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

function CreateGoldRoomLayer:onRoomLoginFail()
	--判断是否有游戏界面 没有游戏界面则此界面退出
	local gameLayer = display.getRunningScene():getChildByName("gameLayer");
	if gameLayer == nil then
		Hall:exitGame()
	end
end

return CreateGoldRoomLayer
