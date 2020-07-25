--金币房
local CreateGoldRoomLayer = class("CreateGoldRoomLayer", BaseWindow)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

local szGameName = {"lkpy_2","lkpy_6"}

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

	self.isRoomMode = 1--多人模式
	-- if globalUnit:getIsEnterRoomMode() ~= true then
	-- 	self.isRoomMode = 0
	-- end

	self.layoutBtn = {}
	self.listNode = {}
	self.listViewBtn = {}
	globalUnit:setIsEnterRoomMode(self.isRoomMode)
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
	
	local duorenList = {};
	local danrenList = {};
	local isHaveDuo = false;
	local isHaveDan = false;
	for k,v in pairs(globalUnit.VipRoomList) do
		if k <= 4 then
			table.insert(duorenList,v)
		else
			table.insert(danrenList,v)
		end
	end

	for k,v in pairs(duorenList) do
		if v == 1 then
			isHaveDuo = true;
		end
	end

	for k,v in pairs(danrenList) do
		if v == 1 then
			isHaveDan = true;
		end
	end

	--是否开启游戏
	local gameList = GamesInfoModule._gameNames

	self.gameList = gameList or {}
	-- luaDump(self.gameList,"self.gameList")
	local x1 = 0
	local x2 = 0
	for k,v in pairs(self.gameList) do
        if "lkpy_2" == v.szGameName then
            x1 = 1
        end
        if "lkpy_6"== v.szGameName then
            x2 = 1
        end
    end

    if isHaveDuo and x1 == 1 then
    else
    	isHaveDuo = false;
    end

    if isHaveDan and x2 == 1 then
    else
    	isHaveDan = false;
    end

	if isHaveDuo and isHaveDan then
		local modeBtn = ccui.Button:create("newExtend/vip/typeset/danren.png","newExtend/vip/typeset/danren-on.png")
	    modeBtn:setTag(self.isRoomMode)
	    modeBtn:setPosition(winSize.width*0.5-200,winSize.height*0.16)
	    modeBtn:setAnchorPoint(0.5,0.5)
	    self:addChild(modeBtn)
	    modeBtn:onTouchClick(
	        function(sender)
	                self:onClickModeBtn(sender)
	        end)
	    self.modeBtn = modeBtn
	    -- self.modeBtn:setVisible(false)
	end

	self.NodeDuo = cc.Node:create();
	self.NodeDuo:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(self.NodeDuo);
	self.NodeDuo:setVisible(false) 

	self.NodeDan = cc.Node:create();
	self.NodeDan:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(self.NodeDan); 
	self.NodeDan:setVisible(true)

	if isHaveDuo and not isHaveDan then
		self.NodeDuo:setVisible(true)
		self.NodeDan:setVisible(false)
		self.isRoomMode = 1
	end
	
	self:createItem(self.NodeDuo,duorenList,1);

	self:createItem(self.NodeDan,danrenList,0);
	

    local guatiao = ccui.ImageView:create("newExtend/vip/common/di1.png")
    guatiao:setPosition(winSize.width*0.5+585,winSize.height*0.6)
    guatiao:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(guatiao)

    local Label_name = FontConfig.createWithSystemFont("金\n蟾\n捕\n鱼",26 ,cc.c3b(90, 44, 14));
    Label_name:setPosition(guatiao:getContentSize().width/2+10,guatiao:getContentSize().height/2-10)
    Label_name:setContentSize(cc.size(50,140))
    guatiao:addChild(Label_name)
end

function CreateGoldRoomLayer:createItem(parent,list,itype)
	-- local ruchangNum = {"30.00","50.00","100.00","150.00"}
	local GameNameID = VipRoomInfoModule:getuNameIDBysGameName("lkpy_2")
	local roomList_Roomid = VipRoomInfoModule:getRoomListBysGameName("lkpy_2")
	if itype == 1 then
		GameNameID = VipRoomInfoModule:getuNameIDBysGameName("lkpy_2")
	else
		GameNameID = VipRoomInfoModule:getuNameIDBysGameName("lkpy_6")
	end
	
	local teamCount = 0

	for k,room in pairs(list) do
        if  room == 1 then
        	teamCount = teamCount +1
        	local x = 0--105+winSize.width*0.5-300+(teamCount-1)*220;
        	local y = 0--winSize.height*0.5;
         	if teamCount > 3 then
    			y = winSize.height*0.40-30;
    			-- x = 105+winSize.width*0.5-((4+1)/2-teamCount+4)*230;--280*(teamCount-5);
    			x = 105+winSize.width*0.5-300+(teamCount-1-3)*280
    		else
    			x = 105+winSize.width*0.5-300+(teamCount-1)*280
    			-- x = 105+winSize.width*0.5-((4+1)/2-teamCount)*230;--280*(teamCount-1);
    			y = winSize.height*0.68-20;
    		end
         

            local typeset_dz = ccui.Button:create("newExtend/vip/typeset/"..k..".png","newExtend/vip/typeset/"..k.."-on.png")
            typeset_dz:setPosition(x,y)
            typeset_dz:setTag(k)
            typeset_dz:setName("fish")
            typeset_dz:onClick(handler(self, self.enterGame))
            parent:addChild(typeset_dz)
            -- typeset_dz:setScale(0.6)


            local size = typeset_dz:getContentSize();

      --       local dikuang = ccui.ImageView:create("newExtend/vip/typeset/dikuang.png")
		    -- dikuang:setPosition(size.width*0.5,size.height*0.22)
		    -- typeset_dz:addChild(dikuang)

            local name = {"xinshouyucun","yongzhehaiwan","shenhailieshou","haiyangshenhua"}
            
            local biaoti = ccui.ImageView:create("newExtend/vip/typeset/"..name[k]..".png")
            biaoti:setPosition(size.width/2,size.height*0.58)
            typeset_dz:addChild(biaoti)

            if itype == 0 then
            	name ="danren"
            else
            	name ="duoren"
            end
            local tip = ccui.ImageView:create("newExtend/vip/typeset/"..name..k..".png")
            tip:setPosition(size.width/2,size.height*0.80)
            typeset_dz:addChild(tip)

            local gold = ccui.ImageView:create("newExtend/vip/typeset/gold.png")
            gold:setPosition(size.width*0.35,size.height*0.18)
            typeset_dz:addChild(gold)

            -- local ruchang = ccui.ImageView:create("newExtend/vip/typeset/bei.png")
            -- ruchang:setPosition(size.width*0.75,size.height*0.22)
            -- typeset_dz:addChild(ruchang)

            local minRoomKey = RoomInfoModule:getRoomNeedGold(GameNameID,roomList_Roomid[k])--ruchangNum[k] --最小金币限制
            if itype == 0 then
            	minRoomKey = RoomInfoModule:getRoomNeedGold(GameNameID,roomList_Roomid[4+k])
            end
            -- local xianzhi = FontConfig.createWithCharMap(minRoomKey/100, "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
            -- xianzhi:setPosition(size.width*0.6,size.height*0.35)
            -- typeset_dz:addChild(xianzhi)
            local xianzhi = FontConfig.createWithSystemFont(tostring(minRoomKey/100),30)
            xianzhi:setPosition(size.width*0.56,size.height*0.18)
            xianzhi:setAnchorPoint(0.5,0.5)
            typeset_dz:addChild(xianzhi)

            -- name = {"0.01-0.1","0.1-1","1-10","10-55"}

            -- local difennum = name[k]
            -- local difen = FontConfig.createWithCharMap(difennum, "newExtend/vip/typeset/zitiao.png", 15, 22, "+");
            -- difen:setPosition(size.width*0.45,size.height*0.22)
            -- typeset_dz:addChild(difen)
            -- difen:setScale(1.2)
            local info = ccui.ImageView:create("createRoom/"..k..".png")
            info:setPosition(size.width*0.5,size.height*0.38)
            info:setScale(0.8)
            typeset_dz:addChild(info)
            
        end
    end
end

--多人单人模式选择
function CreateGoldRoomLayer:onClickModeBtn(sender)
    if sender:getTag() == 1 then--多人模式
        sender:loadTextures("newExtend/vip/typeset/danren.png","newExtend/vip/typeset/danren-on.png")
        sender:setTag(0)
        self.NodeDuo:setVisible(false)
		self.NodeDan:setVisible(true)
        self.isRoomMode = 0

    else--单人模式
        sender:loadTextures("newExtend/vip/typeset/duoren.png","newExtend/vip/typeset/duoren-on.png")
        sender:setTag(1)
        self.NodeDuo:setVisible(true)
		self.NodeDan:setVisible(false)
        self.isRoomMode = 1
        
    end
    globalUnit:setIsEnterRoomMode(self.isRoomMode)
    self:refreshGameList()
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
			dispatchEvent("onRoomLoginError",2)
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
	local tag = sender:getTag();
	globalUnit.iRoomIndex = tag;
	if globalUnit.iRoomIndex > 4 then
		globalUnit.iRoomIndex = globalUnit.iRoomIndex -4;
	end

	-- if GamesInfoModule:findGameName(self.m_selectedNameID) == nil then
	-- 	-- addScrollMessage("捕鱼暂未开放!")
	-- 	dispatchEvent("requestGameList")
	-- 	return
	-- end

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

	local roomid = {172,173,174,175}
	if self.isRoomMode == 1 then
		self.m_selectedNameID = 40010002;
	else
		self.m_selectedNameID = 40010006;
		roomid = {176,177,178,179}
	end

	globalUnit:setIsEnterRoomMode(self.isRoomMode)

	self.m_selectedRoomID = roomid[tag]

	-- if self.roomList[globalUnit.iRoomIndex] == nil then
	-- 	-- addScrollMessage(msg.."暂未开放!")
	-- 	dispatchEvent("requestRoomList")
	-- 	return
	-- end

	GameCreator:setCurrentGame(self.m_selectedNameID)

	-- self.m_selectedRoomID = self.roomList[globalUnit.iRoomIndex].uRoomID

	luaPrint("m_selectedRoomID == "..self.m_selectedRoomID)

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
		-- display.getRunningScene():addChild(require("popView.HelpLayer"):create());
		self:addChild(require("jinchanbuyu.popView.HelpLayer"):create());
	elseif tag == 2 then
		Hall:exitGame()
	elseif tag == 0 or tag == 1 then
		self:listViewSlider(tag)
	end
end



function CreateGoldRoomLayer:receiveExitCreateRoom(data)
	if data == nil then
		-- self:resetViewPos()

		-- self:playEffect()
	end
end



return CreateGoldRoomLayer
