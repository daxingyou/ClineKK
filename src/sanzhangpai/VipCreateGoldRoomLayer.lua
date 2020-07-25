--金币房
local CreateGoldRoomLayer = class("CreateGoldRoomLayer", BaseWindow)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

function CreateGoldRoomLayer:create(gameName)
	return CreateGoldRoomLayer.new(gameName)
end

function CreateGoldRoomLayer:ctor(gameName)
	self.super.ctor(self, 0, false)

	self.gameName = gameName

	self:initData()

	self:initUI()

	self:bindEvent()
end

function CreateGoldRoomLayer:initData()
	self.m_selectedNameID = 0
	self.m_selectedRoomID = 0
	self.layoutBtn = {}
end

function CreateGoldRoomLayer:initUI()

	local vipLayer = display.getRunningScene():getChildByName("VipHallLayer")
	if  vipLayer then
		vipLayer.VIPGameListLayer:getChildByName("mask1"):setVisible(false)
		vipLayer:showShengqingBtn(false)
	end

	local winSize = cc.Director:getInstance():getWinSize()

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
	
	local difenNum = {"0.1","1","10","50"}
	local ruchangNum = {"30.00","50.00","300.00","600.00"}

	local GameNameID = VipRoomInfoModule:getuNameIDBysGameName(self.gameName)
	local roomList_Roomid = VipRoomInfoModule:getRoomListBysGameName(self.gameName)

	local zongNum = 0
	for k,room in pairs(globalUnit.VipRoomList) do
		if room == 1 then
			zongNum = zongNum + 1;
		end
	end
	self.roomBtn = {}
	local teamCount = 0
	for k,room in pairs(globalUnit.VipRoomList) do
            
        if  room == 1 then
        	teamCount = teamCount +1
        	local x = winSize.width*0.5-250+(teamCount-1)*235;
        	local y = winSize.height*0.16;
        	
        	if self.gameName == "dz_ddz" then
                if k>4 then
                    return;
                end
            end

            local typeset_dz = ccui.Button:create("newExtend/vip/changci/anniu.png","newExtend/vip/changci/anniu-on.png","newExtend/vip/changci/anniu-l.png")
            typeset_dz:setPosition(x,y)
            typeset_dz:setTag(k)
            typeset_dz:onClick(handler(self, self.enterGame))
            self:addChild(typeset_dz)
            table.insert(self.roomBtn,typeset_dz)

            local size = typeset_dz:getContentSize();

            local name = {"pingmin","xiaozi","laoban","fuhao"}
            if self.gameName == "dz_ddz" then
            	name = {"jindian","buxipai","buxipai","buxipai"}
            end

            local x = size.width*0.02
            local y = size.height*0.55

            local biaoti = ccui.ImageView:create("newExtend/vip/changci/"..name[k]..".png")
		    biaoti:setPosition(x,y)
		    biaoti:setAnchorPoint(0,0.5)
		    typeset_dz:addChild(biaoti)

		    x =  x + biaoti:getContentSize().width;

            local xie = ccui.ImageView:create("newExtend/vip/changci/xie.png")
		    xie:setPosition(x,y)
		    xie:setAnchorPoint(0,0.5)
		    typeset_dz:addChild(xie)

		    x =  x + xie:getContentSize().width;

		    local difennum = difenNum[k]
            local difen = FontConfig.createWithCharMap(difennum, "newExtend/vip/changci/zitiao.png", 15, 19, "+");
            difen:setPosition(x,y)
            difen:setAnchorPoint(0,0.5)
            typeset_dz:addChild(difen)

            x =  x + difen:getContentSize().width;

            local di = ccui.ImageView:create("newExtend/vip/changci/di.png")
		    di:setPosition(x,y)
		    di:setAnchorPoint(0,0.5)
		    typeset_dz:addChild(di)

		    x =  x + di:getContentSize().width;

		    local xie1 = ccui.ImageView:create("newExtend/vip/changci/xie.png")
		    xie1:setPosition(x,y)
		    xie1:setAnchorPoint(0,0.5)
		    typeset_dz:addChild(xie1)

		    x =  x + xie1:getContentSize().width;

		    local minRoomKey = RoomInfoModule:getRoomNeedGold(GameNameID,roomList_Roomid[k])--最小金币限制
            local xianzhi = FontConfig.createWithCharMap(minRoomKey/100, "newExtend/vip/changci/zitiao.png", 15, 19, "+");
            xianzhi:setPosition(x,y)
            xianzhi:setAnchorPoint(0,0.5)
            typeset_dz:addChild(xianzhi)

            x =  x + xianzhi:getContentSize().width;

		    local ruchang = ccui.ImageView:create("newExtend/vip/changci/ru.png")
		    ruchang:setPosition(x,y)
		    ruchang:setAnchorPoint(0,0.5)
		    typeset_dz:addChild(ruchang)


		    
        end
    end

    if zongNum > 1 then
		-- local btn = ccui.Button:create("newExtend/vip/viphall/kuaisukaishi.png","newExtend/vip/viphall/kuaisukaishi-on.png")
		-- btn:setPosition(105+winSize.width/2, 7)
		-- btn:setAnchorPoint(0.5,0)
		-- btn:setTag(3)
		-- self:addChild(btn)
		-- btn:onClick(handler(self, self.onClick))
		-- self.bottomNode = btn

		-- if checkIphoneX() then
		-- 	btn:setPositionX(btn:getPositionX() + 150)
		-- end
	end

	local guatiao = ccui.ImageView:create("newExtend/vip/common/di1.png")
    guatiao:setPosition(winSize.width*0.5+585,winSize.height*0.6)
    guatiao:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(guatiao)

    local Label_name = FontConfig.createWithSystemFont("扎\n金\n花",26 ,cc.c3b(90, 44, 14));
    Label_name:setPosition(guatiao:getContentSize().width/2+10,guatiao:getContentSize().height/2-10)
    Label_name:setContentSize(cc.size(50,140))
    guatiao:addChild(Label_name)

    performWithDelay(self,function()
        self:enterGame(self.roomBtn[1]:getTag())
    end,0.5)
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
	local targetNodeID = 0
	local VipRoomList = globalUnit.VipRoomList
	for k,v in pairs(self.roomList) do
		if k ~= #self.roomList and VipRoomList[k] == 1 then
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
	
	if targetNodeID == 0 then
		for k,v in pairs(VipRoomList) do
			if v == 1 then
				targetNodeID = k;
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
	for k,v in pairs(self.roomBtn) do
		v:setEnabled(true)
	end
	local layer1 = display.getRunningScene():getChildByName("deskLayer")
    if  layer1 then 
        RoomLogic:close();
        Hall:exitGame(3);
    end
	self.roomBtn[globalUnit.iRoomIndex]:setEnabled(false)
	if GamesInfoModule:findGameName(self.m_selectedNameID) == nil then
		-- addScrollMessage("暂未开放!")
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
		-- addScrollMessage(msg.."暂未开放!")
		dispatchEvent("requestGameList")
		return
	end

	GameCreator:setCurrentGame(self.m_selectedNameID)

	self.m_selectedRoomID = self.roomList[globalUnit.iRoomIndex].uRoomID

	luaPrint("m_selectedRoomID == "..self.m_selectedRoomID)

	local gold = RoomInfoModule:getRoomNeedGold(self.m_selectedNameID,self.m_selectedRoomID)
	if gold then
		self:getMatchRoomMinRoomKey(gold,"最低需要"..goldConvert(gold).."金币以上！")
	else
		local msg = {}
		msg.iNameID = self.m_selectedNameID
		msg.iRoomID = self.m_selectedRoomID
		PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY)
	end

	local vipLayer = display.getRunningScene():getChildByName("VipHallLayer")
	if  vipLayer then
		globalUnit.nowTingId = vipLayer.nowTingId;
	end
end

function CreateGoldRoomLayer:getMatchRoomMinRoomKey(data,msg)
	self.m_nMatchMinRoomKey = data
	globalUnit.nMinRoomKey = data

	self:showCreateRoomLayer(msg)
end

function CreateGoldRoomLayer:showCreateRoomLayer(msg)
	if PlatformLogic.loginResult.i64Money < self.m_nMatchMinRoomKey then
		-- GamePromptLayer:create():showPrompt(GBKToUtf8(msg))
		addScrollMessage("抱歉，您的金币低于入场最低限制"..string.format("%.2f",goldConvert(globalUnit.nMinRoomKey)).."，不能进入该游戏房间！")
		showBuyTip();
		return
	end

	self:setBtnEnabled(true)

	if self.m_pMatchRoomCallBack then
		Hall.showTextState("正在加载房间信息",10,function() self:setBtnEnabled() end)
		self.m_pMatchRoomCallBack()
	else
		dispatchEvent("matchRoom",self.m_selectedRoomID)--其他游戏调用此行代码
		globalUnit.selectedRoomID = self.m_selectedRoomID;
		-- Hall:selectedGame(Hall:getCurGameName())--斗地主特殊
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
		local PopUpLayer = require("sanzhangpai.PopUpLayer");
		self:addChild(PopUpLayer:create());
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

	self.topImage:setPositionY(self.topImage:getPositionY()+y)
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
