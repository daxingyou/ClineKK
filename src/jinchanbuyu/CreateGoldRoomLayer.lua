--金币房
local CreateGoldRoomLayer = class("CreateGoldRoomLayer", BaseWindow)

local szGameName = {"lkpy_2","lkpy_6"}

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

	self.isRoomMode = 1-- 1 多人模式 0 单人模式
	-- if globalUnit:getIsEnterRoomMode() ~= true then
	-- 	self.isRoomMode = 0
	-- end

	self.layoutBtn = {}
	self.listNode = {}
	self.listViewBtn = {}
	globalUnit:setIsEnterRoomMode(self.isRoomMode)
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

	local title = ccui.ImageView:create("createRoom/buyuTitle.png")
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
	btn1:setTag(3)
	top:addChild(btn1)
	btn1:onClick(handler(self, self.onClick))
	-- local node = require("layer.popView.UserInfoNode"):create()
	-- node:setPosition(top:getContentSize().width*0.4,top:getContentSize().height*0.65)
	-- top:addChild(node)

	-- local node = require("layer.popView.BottomNode"):create()
	-- node:setPosition(size.width/2,0)
	-- self.bg:addChild(node)
	-- self.bottomNode = node

	-- local mask = ccui.ImageView:create("hall/duorenMask.png")
	-- mask:setPosition(size.width/2,size.height/2-20)
	-- mask:setName("mask")
	-- self.bg:addChild(mask)

	local ret = false

	if GamesInfoModule:findGameName(40010002) and GamesInfoModule:findGameName(40010006) then
		ret = true
		--模式按钮
		-- local modeBg = ccui.ImageView:create("createRoom/modeBg.png")
		-- modeBg:setPosition(modeBg:getContentSize().width/2+200,-22)
		-- modeBg:setAnchorPoint(0.5,0)
		-- modeBg:setScale(1.1)
		-- top:addChild(modeBg)

		local modeBtn = ccui.Button:create("createRoom/duorenmoshi.png","createRoom/duorenmoshi-on.png")
		modeBtn:setTag(self.isRoomMode)
		modeBtn:setPosition(size.width/2-450,15)
		modeBtn:setAnchorPoint(0.5,0)
		-- modeBtn:setScale(0.8*1/1.2)
		self.bg:addChild(modeBtn)
		modeBtn:onTouchClick(
			function(sender)
					if globalUnit.isEnterGame == true then
						return
					end
					self:onClickModeBtn(sender)
			end)
		self.modeBtn = modeBtn

		if self.isRoomMode == 0 then
			modeBtn:loadTextures("createRoom/danrenmoshi.png","createRoom/danrenmoshi-on.png")
			modeBtn:setPositionX(modeBtn:getPositionX()-8)
		end
	end

	if GamesInfoModule:findGameName(40010006) then
		if not ret then
			self.isRoomMode = 0
			globalUnit:setIsEnterRoomMode(self.isRoomMode)
		end
		--单人
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0,0))
		listView:setDirection(ccui.ScrollViewDir.horizontal)
		listView:setBounceEnabled(true)
		listView:setContentSize(cc.size(winSize.width,480))
		listView:setPosition((1559-winSize.width)/2,100)
		listView:setScrollBarEnabled(false)
		self.bg:addChild(listView)
		listView:setVisible(not ret)
		table.insert(self.listNode,listView)

		if checkIphoneX() then
			local layout = ccui.Layout:create()
			layout:setContentSize(cc.size((winSize.width - 380*4)/2-20, 355))
			listView:pushBackCustomItem(layout)
		end

		table.insert(self.layoutBtn,{})

		local name = {"xinshouyucun","yongzhehaiwan","shenhailieshou","haiyangshenhua"}
		for k,v in pairs(name) do
			local layout, btn = self:createItem(k,v)
			table.insert(self.layoutBtn[#self.layoutBtn],btn)
			btn:setTag(k)
			listView:pushBackCustomItem(layout)
		end

		if checkIphoneX() then
			local layout = ccui.Layout:create()
			layout:setContentSize(cc.size((winSize.width - 380*4)/2-20, 355))
			listView:pushBackCustomItem(layout)
		end
	end

	if GamesInfoModule:findGameName(40010002) then
		if not ret then
			self.isRoomMode = 1
			globalUnit:setIsEnterRoomMode(self.isRoomMode)
		end
		--多人
		local listView = ccui.ListView:create()
		listView:setAnchorPoint(cc.p(0,0))
		listView:setDirection(ccui.ScrollViewDir.horizontal)
		listView:setBounceEnabled(true)
		listView:setContentSize(cc.size(winSize.width,480))
		listView:setPosition((1559-winSize.width)/2,100)
		listView:setScrollBarEnabled(false)
		self.bg:addChild(listView)
		listView:setVisible(not ret)
		table.insert(self.listNode,listView)
		listView:onScroll(handler(self, self.onScrollEvent))

		if checkIphoneX() then
			local layout = ccui.Layout:create()
			layout:setContentSize(cc.size((winSize.width - 380*4)/2-20, 355))
			listView:pushBackCustomItem(layout)
		end

		table.insert(self.layoutBtn,{})

		local name = {"xinshouyucun","yongzhehaiwan","shenhailieshou","haiyangshenhua"}
		for k,v in pairs(name) do
			local layout, btn = self:createItem(k,v)
			table.insert(self.layoutBtn[#self.layoutBtn],btn)
			btn:setTag(k)
			-- if k == 1 then
			-- 	btn:setTag(#name)
			-- else
			-- 	btn:setTag(k-1)
			-- end
			listView:pushBackCustomItem(layout)
		end

		if checkIphoneX() then
			local layout = ccui.Layout:create()
			layout:setContentSize(cc.size((winSize.width - 380*4)/2-20, 355))
			listView:pushBackCustomItem(layout)
		end

		--左滑按钮呢
		local btn = ccui.Button:create("hall/left.png","hall/left-on.png")
		btn:setPosition(btn:getContentSize().width, size.height/2)
		btn:setTag(0)
		-- btn:setScale(-1)
		self.bg:addChild(btn)
		btn:onClick(handler(self, self.onClick))
		btn:hide()
		self.leftBtn = btn
		btn.mx = -15
		btn.mdt = 15/80

		if checkIphoneX() then
			btn:setPositionX(safeX+btn:getContentSize().width)
		end
		btn.px = btn:getPositionX()

		table.insert(self.listViewBtn,btn)

		--右滑按钮
		local btn = ccui.Button:create("hall/right.png","hall/right-on.png")
		btn:setPosition(size.width-btn:getContentSize().width, size.height/2)
		btn:setTag(1)
		self.bg:addChild(btn)
		btn:hide()
		btn:onClick(handler(self, self.onClick))
		self.rightBtn = btn
		btn.mx = 15
		btn.mdt = 15/80

		if checkIphoneX() then
			btn:setPositionX(winSize.width-safeX-btn:getContentSize().width)
		end
		btn.px = btn:getPositionX()
		btn:setOpacity(0)
		performWithDelay(self,function()
			btn:setPositionX(btn.px)
			btn:setOpacity(255)
		end,0.1)

		table.insert(self.listViewBtn,btn)
	end

	if #self.listNode > 1 then
		for k,v in pairs(self.listNode) do
			v:scrollToPercentHorizontal(0,0.05,false)
			v:setVisible(k == self.isRoomMode+1)
		end
	elseif #self.listNode == 1 then
		self.listNode[1]:scrollToPercentHorizontal(0,0.05,false)
		self.listNode[1]:setVisible(true)
	else
		performWithDelay(self, function() Hall:exitGame() end, 0.5)
		addScrollMessage("金蟾捕鱼暂未开放!")
		return
	end

	self:listViewSlider(0)

	local btn = ccui.Button:create("game/createRoomduizhan/kuaisukaishi.png","game/createRoomduizhan/kuaisukaishi-on.png")
	btn:setPosition(self.bg:getContentSize().width/2, 5)
	btn:setAnchorPoint(0.5,0)
	btn:setTag(4)
	self.bg:addChild(btn)
	btn:onClick(handler(self, self.onClick))
	self.bottomNode = btn
end

function CreateGoldRoomLayer:createItem(tag,name)
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(390, 365))

	-- if not checkIphoneX() then
	-- 	layout:setContentSize(cc.size(400, 355))
	-- end

	local size = layout:getContentSize()

	local btn = ccui.Widget:create()
	btn:setContentSize(cc.size(size.width-10,size.height))
	btn:setAnchorPoint(cc.p(0.5,0.5))
	btn:setPosition(size.width/2+15,size.height/2)
	btn:setCascadeOpacityEnabled(true)
	btn:setTouchEnabled(true)
	layout:addChild(btn)
	btn:onTouchClick(function(sender) self:enterGame(sender) end)

	-- local draw = cc.DrawNode:create()
	-- draw:setAnchorPoint(0.5,0.5)
	-- draw:setName("draw")
	-- btn:addChild(draw, 1000)
	-- draw:drawRect(cc.p(0,0), cc.p(btn:getContentSize().width,btn:getContentSize().height), cc.c4f(1,1,0,1))
	-- draw:drawPoint((cc.p(0,0)), 4, cc.c4f(1,0,0,1))

	local path = "createRoom/effect/"..name
	local skeleton_animation = createSkeletonAnimation(name,path..".json", path..".atlas")
	if skeleton_animation then
		skeleton_animation:setPosition(size.width/2, size.height*0.6)
		skeleton_animation:setAnimation(1,name, true)
		btn:addChild(skeleton_animation)

		-- if name == "shenhailieshou" then
		-- 	skeleton_animation:setPositionY(2)
		-- 	skeleton_animation:setPositionX(size.width/2-18+10)
		-- end

		-- if name == "yongzhehaiwan" then
		-- 	skeleton_animation:setPositionY(size.height*0.3+7)
		-- 	skeleton_animation:setPositionX(size.width/2+4+10)
		-- end

		-- if name == "xinshouyucun" then
		-- 	skeleton_animation:setPositionX(skeleton_animation:getPositionX()+10)
		-- 	skeleton_animation:setPositionY(skeleton_animation:getPositionY()-20)
		-- end

		-- if name == "haiyangshenhua" then
		-- 	skeleton_animation:setPositionX(size.width/2+3+10)
		-- 	skeleton_animation:setPositionY(skeleton_animation:getPositionY()-12)
		-- end

		-- if name == "tiyanchang" then
		-- 	skeleton_animation:setPositionX(size.width/2+3)
		-- 	skeleton_animation:setPositionY(skeleton_animation:getPositionY()+105)
		-- end
	end

	local info = ccui.ImageView:create("createRoom/"..tag..".png")
	info:setPosition(btn:getContentSize().width/2,-info:getContentSize().height/2+55)
	info:setAnchorPoint(0.5,0)
	btn:addChild(info)

	
	if name ~= "tiyanchang" then
		-- local gold = ccui.ImageView:create("game/createRoomduizhan/difen.png")
	 --    gold:setPosition(size.width*0.3,size.height*0.20+15)
	 --    btn:addChild(gold)

	    local Roomid = {172,173,174,175}--ruchangNum[k] --最小金币限制
	    -- local xianzhi = FontConfig.createWithCharMap(minRoomKey[tag], "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
	    -- xianzhi:setPosition(size.width*0.6,size.height*0.20)
	    -- btn:addChild(xianzhi)
	    local minRoomKey = RoomInfoModule:getRoomNeedGold(40010002,Roomid[tag])
	    local difen = FontConfig.createWithSystemFont(tostring(minRoomKey/100).."入场",26)
		difen:setPosition(size.width*0.5,size.height*0.20+15)
		-- difen:setAnchorPoint(0,0.5)
		btn:addChild(difen)
		difen:setColor(cc.c3b(255,225,146));
	else
		local image = ccui.ImageView:create("game/createRoomduizhan/free.png")
		image:setPosition(size.width*0.5,size.height*0.2)
		btn:addChild(image)
	end

	return layout,btn
end

function CreateGoldRoomLayer:initGameData()
	local gameList = GamesInfoModule:findGameList(self.gameName,self.isRoomMode)

	self.gameList = gameList or {}
	-- luaDump(self.gameList)
	local index = 1;
	if self.isRoomMode == 0 then
		index = 2;
	end
	if #self.gameList > 0 then
		for k,v in pairs(self.gameList) do
			if string.find(v.szGameName,szGameName[index]) then
				self.m_selectedNameID = v.uNameID
				self.index = k
				break
			end
		end
	end

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
		-- self.m_selectedNameID = self.gameList[1].uNameID

		-- //设置当前游戏
		GameCreator:setCurrentGame(self.m_selectedNameID)

		local roomList = RoomInfoModule:getRoomInfoByNameID(self.m_selectedNameID)

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

function CreateGoldRoomLayer:refreshGameList(data)
	LoadingLayer:removeLoading()

	if data == 1 then
		if GamesInfoModule:findGameName(40010002) or GamesInfoModule:findGameName(40010006) then
			self:initData()
			self:removeAllChildren()
			self:stopAllActions()
			self:initUI()
		else
			Hall:exitGame()
			return
		end
	end

	self:showFangjian()
end

function CreateGoldRoomLayer:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_GameList",function () self:refreshGameList(1) end);

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
	local id = string.split(globalUnit:getEnterGameID(),"_")[2]
	local oldID = 0

	for k,v in pairs(self.roomList) do
		if v.uRoomID == id then
			oldID = k
		end
	end

	if PlatformLogic.loginResult.i64Money >= 500000 then
		targetNodeID = 4
	elseif PlatformLogic.loginResult.i64Money >=100000 then
		targetNodeID = 3
	elseif PlatformLogic.loginResult.i64Money >=50000 then
		targetNodeID = 2
	elseif PlatformLogic.loginResult.i64Money >=10000 then
		targetNodeID = 1
	else
		targetNodeID = 1
	end

	if oldID > 0 and oldID < targetNodeID then
		targetNodeID = oldID
	end

	return  targetNodeID,self.rootOrginBtnList[targetNodeID]
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
		-- addScrollMessage("捕鱼暂未开放!")
		dispatchEvent("requestGameList")
		return
	end
	globalUnit:setIsEnterRoomMode(self.isRoomMode)
	local msg = ""

	if globalUnit.iRoomIndex == 1 then
		msg = "新手鱼村"
	elseif  globalUnit.iRoomIndex == 2 then
		msg = "勇者海湾"
	elseif  globalUnit.iRoomIndex == 3 then
		msg = "深海猎手"
	elseif  globalUnit.iRoomIndex == 4 then
		msg = "海洋神话"
	else
		msg = ""
	end

	if self.roomList[globalUnit.iRoomIndex] == nil then
		-- addScrollMessage(msg.."暂未开放!")
		dispatchEvent("requestRoomList")
		return
	end

	GameCreator:setCurrentGame(self.m_selectedNameID)

	self.m_selectedRoomID = self.roomList[globalUnit.iRoomIndex].uRoomID

	luaPrint("m_selectedRoomID == "..self.m_selectedRoomID)
	-- addScrollMessage(self.m_selectedNameID.."  "..self.m_selectedRoomID)

	local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.m_selectedRoomID)
	if gold then
		globalUnit:setEnterGameID(self.m_selectedNameID.."_"..self.m_selectedRoomID)
		self:getMatchRoomMinRoomKey(gold,msg.."最低需要"..goldConvert(gold).."金币以上！")
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
		Hall.showTextState("正在进入房间",10,function() self:setBtnEnabled() end)
		self.m_pMatchRoomCallBack()
	else
		dispatchEvent("matchRoom",self.m_selectedRoomID)
	end
end

function CreateGoldRoomLayer:loginRoom(event)
	local runningScene = display.getRunningScene()

	if runningScene:getChildByTag(1111111) then
		runningScene:removeChildByTag(1111111)
	end

	self:setBtnEnabled()
end

--多人单人模式选择
function CreateGoldRoomLayer:onClickModeBtn(sender)
	if sender:getTag() == 1 then--多人模式
		sender:loadTextures("createRoom/danrenmoshi.png","createRoom/danrenmoshi-on.png")
		sender:setTag(0)
		sender:setPositionX(sender:getPositionX()-8)
		self.isRoomMode = 0
		for k,v in pairs(self.listViewBtn) do
			v:hide()
		end
	else--单人模式
		sender:loadTextures("createRoom/duorenmoshi.png","createRoom/duorenmoshi-on.png")
		sender:setTag(1)
		sender:setPositionX(sender:getPositionX()+8)
		self.isRoomMode = 1
		if self.showTag ~= nil then
			-- for k,v in pairs(self.listViewBtn) do
			-- 	if k == self.showTag+1 then
			-- 		v:show()
			-- 	else
			-- 		v:hide()
			-- 	end
			-- end
		end
	end

	globalUnit:setIsEnterRoomMode(self.isRoomMode)

	for k,v in pairs(self.listNode) do
		v:setVisible(k == self.isRoomMode+1)
	end

	self:refreshGameList()
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

	if tag == 3 then
		display.getRunningScene():addChild(require("jinchanbuyu.popView.HelpLayer"):create());
	elseif tag == 2 then
		Hall:exitGame()
	elseif tag == 0 or tag == 1 then
		self:listViewSlider(tag)
	elseif tag == 4 then--快速开始
		self:quickStart()
	end
end

--左右箭头处理
function CreateGoldRoomLayer:listViewSlider(tag,flag)
	for k,v in pairs(self.listViewBtn) do
		v:stopAllActions()
		v:setPositionX(v.px)
		if v:getTag() == tag then
			v:hide()
		else
			self.showTag = v:getTag()
			local move = cc.MoveBy:create(v.mdt,cc.p(v.mx,0))
			local seq = cc.Sequence:create(move,move:reverse())
			local rep = cc.RepeatForever:create(seq)
			v:runAction(rep)
			if self.isRoomMode == 1 then
				-- v:show()
			end
		end
	end

	if flag == nil then
		if #self.listNode > 1 then
			self.listNode[2]:scrollToPercentHorizontal(tag*100,0.4,true)
		elseif #self.listNode == 1 then
			self.listNode[1]:scrollToPercentHorizontal(tag*100,0.4,true)
		end
	end
end

function CreateGoldRoomLayer:onScrollEvent(event)
	local ret = false

	if event.name == "BOUNCE_LEFT" or event.name == "SCROLL_TO_LEFT" then
		ret = true
	elseif event.name == "BOUNCE_RIGHT" or event.name == "SCROLL_TO_RIGHT" then
		ret = true
	end

	if ret then
		self:stopActionByTag(1111)
		self.event = event
		local func = function()
			if self.event then
				if self.event.name == "BOUNCE_LEFT" or self.event.name == "SCROLL_TO_LEFT" then
					self:listViewSlider(0,1)
					self.event = nil
				elseif self.event.name == "BOUNCE_RIGHT" or self.event.name == "SCROLL_TO_RIGHT" then
					self:listViewSlider(1,1)
					self.event = nil
				end
			end
		end

		performWithDelay(self,func,0.05):setTag(1111)	
	end
end

function CreateGoldRoomLayer:receiveExitCreateRoom(data)
	if data == nil then
		self:resetViewPos()

		self:playEffect()
	end
end

function CreateGoldRoomLayer:resetViewPos()
	local y = 130
	local x = {76+446,816+87,867-267,906-624,1800}

	self.topImage:setPositionY(self.topImage:getPositionY()+y+50)
	self.bottomNode:setPositionY(self.bottomNode:getPositionY()-y)

	if #self.listNode > 1 then
		for k,v in pairs(self.listNode) do
			v:scrollToPercentHorizontal(0,0.05,false)
			v:setVisible(k == self.isRoomMode+1)
		end

		for k,v in pairs(self.layoutBtn[self.isRoomMode+1]) do
			if x[k] then
				v:setPositionX(v:getPositionX()+x[k]+winSize.width/2)
			end
		end
	else
		self.listNode[1]:scrollToPercentHorizontal(0,0.05,false)
		self.listNode[1]:setVisible(true)

		for k,v in pairs(self.layoutBtn[1]) do
			if x[k] then
				v:setPositionX(v:getPositionX()+x[k]+winSize.width/2)
			end
		end
	end

	for k,v in pairs(self.listViewBtn) do
		v:hide()
	end

	self.isPlayEffect = false
end

function CreateGoldRoomLayer:playEffect()
	if self.isPlayEffect == true then
		return
	end

	self.isPlayEffect = true

	local y = 130
	local unit = 30
	local delay = {0,5,8,14,13}
	local pos1 = {-76-479,-816-152,241-867,612-906,-1800-50}
	local pos2 = {479-446,152-66,292-241,648-612,50+30}
	local pos3 = {0,66-87,267-292,624-648,-30}

	local dt1 = {6,6,8,10,9}
	local dt2 = {4,6,8,10,12}
	local dt3 = {0,9,11,16,12}

	local dt = -winSize.width/2*dt1[1]/pos1[1]

	local callback = cc.CallFunc:create(function() self:listViewSlider(0) end)

	local temp = self.layoutBtn[self.isRoomMode+1]

	if #self.layoutBtn == 1 then
		temp = self.layoutBtn[1]
	end

	local len = #temp

	for k,v in pairs(temp) do
		if delay[k] then
			local seq = cc.Sequence:create(
				cc.DelayTime:create(delay[k]/unit),
				cc.MoveBy:create((dt1[k]+dt)/unit,cc.p(pos1[k]-winSize.width/2,0)),
				cc.MoveBy:create(dt2[k]/unit,cc.p(pos2[k],0)),
				cc.MoveBy:create(dt3[k]/unit,cc.p(pos3[k],0))
			)

			if len <= 4 and k == len then
				seq = cc.Sequence:create(seq,callback)
			elseif len > 4  then
				if checkIphoneX() then
					if k == 5 then
						seq = cc.Sequence:create(seq,callback)
					end
				else
					if k == 4 then
						seq = cc.Sequence:create(seq,callback)
					end
				end
			end

			v:runAction(seq)
		end
	end

	local seq = cc.Sequence:create(
		cc.DelayTime:create(7/unit),
		cc.MoveBy:create(15/unit,cc.p(0,-y-20-50)),
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

function CreateGoldRoomLayer:quickStart()
	local tag = self:getRootIndex()

	self:enterGame(tag)
end

function CreateGoldRoomLayer:getRootIndex()
	local targetNodeID = 1

	for k,v in pairs(self.roomList) do
		if RoomInfoModule:isCashRoom(v.uNameID,v.uRoomID) then
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

return CreateGoldRoomLayer
