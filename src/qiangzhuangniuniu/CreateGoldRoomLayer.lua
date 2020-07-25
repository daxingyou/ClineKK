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

	addSound();
end

function CreateGoldRoomLayer:initData()
	self.m_selectedNameID = 0
	self.m_selectedRoomID = 0
	self.layoutBtn = {}
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

	local title = ccui.ImageView:create("createRoom/qiangzhuangpinshi.png")
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

	for i=2,5 do -- 3
		local layout = self:createRoomGroup(i,5)
		self.listView:pushBackCustomItem(layout)
	end

	-- if checkIphoneX() then
	-- 	local layout = ccui.Layout:create()
	-- 	layout:setContentSize(cc.size((winSize.width - 360*4)/2, self.listView:getContentSize().height))
	-- 	self.listView:pushBackCustomItem(layout)
	-- end

	local btn = ccui.Button:create("game/createRoomduizhan/kuaisukaishi.png","game/createRoomduizhan/kuaisukaishi-on.png")
	btn:setPosition(self.bg:getContentSize().width/2, 15)
	btn:setAnchorPoint(0.5,0)
	btn:setTag(3)
	self.bg:addChild(btn)
	btn:onClick(handler(self, self.onClick))
	self.bottomNode = btn

	--self:receiveExitCreateRoom()
end

function CreateGoldRoomLayer:createRoomGroup(groupId,num)
	if groupId > num then
		return;
	end
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(380,self.listView:getContentSize().height))

	local temp = {}

	-- if groupId < num then
	-- 	local node = self:createItem(groupId)
	-- 	node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height*0.75)
	-- 	layout:addChild(node)
	-- 	table.insert(temp,node)
	-- end

	-- if groupId+3 <= num then
	-- 	local node = self:createItem(groupId+3)
	-- 	node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height*0.25)
	-- 	layout:addChild(node)
	-- 	table.insert(temp,node)
	-- end

	local node = self:createItem(groupId);
	layout:addChild(node);
	node:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2);
	table.insert(temp,node);

	table.insert(self.layoutBtn,temp)

	return layout
end

function CreateGoldRoomLayer:createItem(tag)
	local difenNum = {nil,"0.10","1.00","10.00","50.00"}
	local ruchang = {nil,"5.00","50.00","500.00","1500.00"}

	local btn = ccui.Button:create("game/createRoomduizhan/"..(tag-1)..".png","game/createRoomduizhan/"..(tag-1).."-on.png")
	btn:setTag(tag-1)
	btn:onClick(handler(self, self.enterGame))

	local size = btn:getContentSize()

	if difenNum[tag] then
		local difen = FontConfig.createWithCharMap(difenNum[tag].."底分","game/createRoomduizhan/zitiao1.png",20,24,"+",{{"底分",":;<"}})
		difen:setPosition(size.width/2+10,size.height/2-135)
		btn:addChild(difen)

		local difen = FontConfig.createWithSystemFont(ruchang[tag].."入场",25)
		difen:setPosition(size.width/2,size.height/2-100)
		btn:addChild(difen)
		difen:setColor(cc.c3b(255,225,146));
	else
		btn:setTag(#difenNum)
		-- local image = ccui.ImageView:create("game/createRoomduizhan/tiyanchang.png")
		-- image:setPosition(size.width*0.5,size.height*0.6)
		-- btn:addChild(image)

		local image = ccui.ImageView:create("game/createRoomduizhan/free.png")
		image:setPosition(size.width*0.5,size.height*0.2+70)
		btn:addChild(image)
	end

	return btn
end

function CreateGoldRoomLayer:initGameData()
	local gameList = GamesInfoModule:findGameList("dz")

	self.gameList = gameList or {}
	-- luaDump(self.gameList)

	table.sort(self.gameList, function(a,b) return a.uNameID < b.uNameID end)
end

function CreateGoldRoomLayer:onEnter()
	self.super.onEnter(self)
end

function CreateGoldRoomLayer:onEnterTransitionFinish()
	self:showFangjian()
	self.super.onEnterTransitionFinish(self)

	-- self:receiveExitCreateRoom()
end

function CreateGoldRoomLayer:showFangjian()
	local VisibleCount = 0

	self:initGameData()

	VisibleCount = #self.gameList

	if VisibleCount == 0 then
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
			table.sort(self.roomList, function(a,b) return a.uRoomID < b.uRoomID end)

			if #self.roomList == 0 then
				dispatchEvent("requestRoomList")
			else
				if self.touchLayer then
					self.touchLayer:removeSelf()
					self.touchLayer = nil
				end
			end
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
		return;
	end

	for _, bindid in pairs(self.bindIds) do
		Event:unRegisterListener(bindid)
	end
end

function CreateGoldRoomLayer:onExit()
	self.super.onExit(self)

	self:unBindEvent()
end

function CreateGoldRoomLayer:getRootIndex()
	local targetNodeID = 1

	for k,v in pairs(self.roomList) do
		if k ~= #self.roomList then
			local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,v.uRoomID)
			if gold then
				if gold <= PlatformLogic.loginResult.i64Money then
					targetNodeID = k
				else
					break
				end
			end
		end
	end

	return  targetNodeID
end

function CreateGoldRoomLayer:setMatchRoomCallBack(func)
	self.m_pMatchRoomCallBack = func
end

function CreateGoldRoomLayer:setCloseCreateRoomCallBack(func)
	self.m_pCloseCallBack = func
end

function CreateGoldRoomLayer:enterGame(sender)
	if type(sender) == "number" then
		globalUnit.iRoomIndex = sender
	else
		globalUnit.iRoomIndex = sender:getTag()
	end	

	if GamesInfoModule:findGameName(self.m_selectedNameID) == nil then
		--addScrollMessage("游戏暂未开放!")
		dispatchEvent("requestGameList")
		return
	end

	local msg = ""
	if globalUnit.iRoomIndex == 1 then
		msg = "平民场"
	elseif globalUnit.iRoomIndex == 2 then
		msg = "小资场"
	elseif globalUnit.iRoomIndex == 3 then
		msg = "老板场"
	elseif globalUnit.iRoomIndex == 4 then
		msg = "富豪场"
	end

	if self.roomList[globalUnit.iRoomIndex] == nil then
		--addScrollMessage(msg.."暂未开放!")
		dispatchEvent("requestGameList")
		return
	end

	self.m_selectedRoomID = self.roomList[globalUnit.iRoomIndex].uRoomID

	luaPrint("m_selectedRoomID == ",self.m_selectedRoomID,globalUnit.iRoomIndex)
	GameCreator:setCurrentGame(self.m_selectedNameID)

	local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.m_selectedRoomID)
	if gold then
		self:getMatchRoomMinRoomKey(gold,"最低需要"..goldConvert(gold).."金币以上！")
	else
		local msg = {}
		msg.iNameID = self.m_selectedNameID
		msg.iRoomID = self.m_selectedRoomID
		PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY)
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
		dispatchEvent("matchRoom",self.m_selectedRoomID)--其他游戏调用此行代码
		globalUnit.selectedRoomID = self.m_selectedRoomID;
	end
end

function CreateGoldRoomLayer:loginRoom(event)
	local runningScene = display.getRunningScene()

	if runningScene:getChildByTag(1111111) then
		runningScene:removeChildByTag(1111111)
	end

	self:setBtnEnabled()
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
		-- addScrollMessage("正在开发")
		local layer = require("qiangzhuangniuniu.HelpLayer"):create();
    	self:getParent():addChild(layer,gameZorder);
	elseif tag == 2 then
		Hall:exitGame()
	elseif tag == 3 then--快速开始
		self:quickStart()
	end
end

function CreateGoldRoomLayer:quickStart()
	local tag = self:getRootIndex()

	self:enterGame(tag)
end

function CreateGoldRoomLayer:receiveExitCreateRoom(data)
	if data == nil then
		self:resetViewPos()

		self:playEffect()
	end
end

function CreateGoldRoomLayer:resetViewPos()
	local y = 130;
	local x = {76+446,816+87,867-267,906-624}

	-- self.topImage:setPositionY(self.topImage:getPositionY()+y)
	self.bottomNode:setPositionY(self.bottomNode:getPositionY()-y)

	for k,v in pairs(self.layoutBtn) do
		if v[1] then
			v[1]:setPositionX(v[1]:getPositionX()+x[k]+winSize.width/2)
		end
		
		if v[2] then
			v[2]:setPositionX(v[2]:getPositionX()+x[k]+winSize.width/2)
		end
	end

	self.isPlayEffect = false
end

function CreateGoldRoomLayer:playEffect()
	if self.isPlayEffect == true then
		return;
	end

	self.isPlayEffect = true

	local y = 130
	local unit = 30
	local delay = {0,5,8,14}
	local pos1 = {-76-479,-816-152,241-867,612-906}
	local pos2 = {479-446,152-66,292-241,648-612}
	local pos3 = {0,66-87,267-292,624-648}

	local dt1 = {6,6,8,10}
	local dt2 = {4,6,8,10}
	local dt3 = {0,9,11,16}

	local dt = -winSize.width/2*dt1[1]/pos1[1]

	for k,v in pairs(self.layoutBtn) do
		local seq = cc.Sequence:create(
			cc.DelayTime:create(delay[k]/unit),
			cc.MoveBy:create((dt1[k]+dt)/unit,cc.p(pos1[k]-winSize.width/2,0)),
			cc.MoveBy:create(dt2[k]/unit,cc.p(pos2[k],0)),
			cc.MoveBy:create(dt3[k]/unit,cc.p(pos3[k],0))
		)

		if v[1] then
			v[1]:runAction(seq)
		end

		if v[2] then
			v[2]:runAction(seq:clone())
		end
	end

	local seq = cc.Sequence:create(
		cc.DelayTime:create(7/unit),
		cc.MoveBy:create(15/unit,cc.p(0,-y-20)),
		cc.MoveBy:create(3/unit,cc.p(0,20))
	)
	self.topImage:runAction(seq)

	local seq = cc.Sequence:create(
		cc.DelayTime:create(7/unit),
		cc.MoveBy:create(15/unit,cc.p(0,y+20)),
		cc.MoveBy:create(3/unit,cc.p(0,-20))
	)
	self.bottomNode:runAction(seq)
end

return CreateGoldRoomLayer
