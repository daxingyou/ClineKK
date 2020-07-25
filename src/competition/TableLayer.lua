local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("competition.TableLogic");
local MainLayer = require("competition.MainLayer");

--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene();

	scene:addChild(layer);

	layer.runScene = scene;

	return scene;
end
--创建类
function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
	Event:clearEventListener();
	
	local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster);

	globalUnit.isFirstTimeInGame = false;

	return layer;
end
--静态函数
function TableLayer:getInstance()
	return _instance;
end
--构造函数
function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
	self.super.ctor(self, 0, true);
	PLAY_COUNT = 180;
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;
	CompetInfo:init();

	self:initData();

	_instance = self;
	
end
--进入
function TableLayer:onEnter()
	self:bindEvent();--绑定消息
	self:initUI();
	self.super.onEnter(self);
end

local ccuiButton = ccui.Button;
ccuiButton.newOnClick = function(self,callback,dt)
    local buttonAnchor = cc.p(self:getAnchorPoint());
    local buttonSize = self:getContentSize();
    local buttonPos = cc.p(self:getPosition());

    --设置锚点到中间
    self:setAnchorPoint(0.5,0.5);

    --设置位置
    local pX = buttonPos.x - (buttonAnchor.x - 0.5)*buttonSize.width;
    local pY = buttonPos.y - (buttonAnchor.y - 0.5)*buttonSize.height;

    self:setPosition(pX,pY);

    self:onClick(callback,dt);
end


--绑定消息
function TableLayer:bindEvent()
	self:pushEventInfo(CompetInfo, "EcList", handler(self, self.onEcList))--
	self:pushEventInfo(CompetInfo, "EcBet", handler(self, self.onEcBet))--
	self:pushEventInfo(CompetInfo, "EcResult", handler(self, self.onEcResult))--
	self:pushEventInfo(CompetInfo, "SpecialEcList", handler(self, self.onSpecialEcList))--
	self:pushEventInfo(CompetInfo, "ClassEcList", handler(self, self.onClassEcList))--
	self:pushEventInfo(CompetInfo, "GametypeEcList", handler(self, self.onGametypeEcList))--
	self:pushEventInfo(CompetInfo, "EventEcList", handler(self, self.onEventEcList))--
	self:pushEventInfo(CompetInfo, "RealtimeInfo", handler(self, self.onRealtimeInfo))--
    self:pushGlobalEventInfo("MZTW_Mess_UserInfo",handler(self, self.MZTW_Mess_UserInfo))


	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
end
-----------------------------------------------框架消息-----------------------------------------------
--广播消息
function TableLayer:gameWorldMessage(event)
    local msg = event.data;
    local msgType = event.messageType;

    if msgType == 0 then
        Hall:showScrollMessage(event,MESSAGE_ROLL);
    elseif msgType == 1 then
        Hall:showFishMessage(event)
    elseif msgType == 3 then--停服更新
        Hall:showFishMessage(event);
    end

end
function TableLayer:updateGameSceneRotation(lSeatNo)

end


--添加用户
function TableLayer:addUser(deskStation, bMe)
    -- if bMe then
    -- 	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:viewToLogicSeatNo(deskStation));
    -- 	self.playerMoney = userInfo.i64Money;
    -- end

end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
   
end

function TableLayer:isValidSeat(seatNo)
    return seatNo < PLAY_COUNT and seatNo >= 0;
end
function TableLayer:setUserName(seatNo, name)
    if not self:isValidSeat(seatNo) then 
        return;
    end

    seatNo = seatNo + 1;

    -- self.playerNodeInfo[seatNo]:setUserName(name);
end
--设置玩家分数显示隐藏
function TableLayer:showUserMoney(seatNo, visible)
    --luaPrint("设置玩家分数显示隐藏 ------------ seatNo "..seatNo)
    if not self:isValidSeat(seatNo) then
        return;
    end
    
    --luaPrint("设置玩家分数显示隐藏")
    seatNo = seatNo + 1;

    -- self.playerNodeInfo[seatNo]:showUserMoney(visible);
end

function TableLayer:leaveDesk(source)
    if not self._bLeaveDesk then
		globalUnit.isEnterGame = false;

		if self.contactListener then
			local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
			eventDispathcher:removeEventListener(self.contactListener);
			self.contactListener = nil;
		end

		self.tableLogic:stop();

		self:stopAllActions();

		performWithDelay(display.getRunningScene(),function() RoomLogic:close() end, 0.5)
		
		self._bLeaveDesk = true;
		_instance = nil;
	end
end

function TableLayer:setUserMaster(seatNo, bMaster)
 
end
--设置玩家分数
function TableLayer:setUserMoney(seatNo, money)
    if not self:isValidSeat(seatNo) then
        return;
    end

    seatNo = seatNo + 1;--lua索引从1开始

    -- self.playerNodeInfo[seatNo]:setUserMoney(money);
end
 -- //服务器收到玩家已经准备好了
function TableLayer:playerGetReady(byStation, bAgree, isRecur)
    -- //准备好图片
    -- self.readyImage["Image_ready"..(byStation+1)]:setVisible(bAgree);  
end
-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
    self:clearDesk();

    -- FishModule:clearData();
end
 -- //清理桌面
function TableLayer:clearDesk()
    for i=1,PLAY_COUNT do
        -- //准备好图片
        -- self.readyImage["Image_ready"..i]:setVisible(false);
    end
    -- self.m_bGameStart = false;

    -- //默认不留在桌子上
    self._bLeaveDesk = false;
end

function TableLayer:gameUserCut(seatNo, bCut)
    if globalUnit.m_gameConnectState ~= STATE.STATE_OVER then--//重连中状态
        -- //请求游戏状态信息 ,刷新桌子数据
        local msg = {};
        msg.bEnableWatch = 0;

        RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GM_GAME_INFO,msg, RoomMsg.MSG_GM_S_ClientInfo);
    end

    local root = cc.Director:getInstance():getRunningScene()

    local node = root:getChildByTag(1421);
    if node then
        node:delayCloseLayer(0);
    end
end

function TableLayer:onUserCutMessageResp()
    -- body
end

--进入后台
function TableLayer:refreshEnterBack(data)
	luaPrint("进入后台-----------refreshEnterBack")
	if device.platform == "windows" then
		return;
	end

end

--后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if device.platform == "windows" then
		return;
	end
	if RoomLogic:isConnect() then



	else
		-- self.gameStart = false;
		-- self:BackCallBack();
	end
end
-------------------------------------------------------------------------------------
--初始化数据
function TableLayer:initData()	
	self.m_iHeartCount = 0;--心跳计数
	self.m_maxHeartCount = 3;--最大心跳计数
	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

	self.GametypeEcList = {};--全部赛事信息表
	self.GameSpecialEcList = {};--赛事情报表
	self.GameBetList = {};--下注的表
    self.GameEcList = {};--全部游戏列表

	self.saveDate = {};
	--塞入年月日的数据
	self.saveDate[1] = os.date("%Y");
	self.saveDate[2] = os.date("%m");
	self.saveDate[3] = os.date("%d");

end
--初始化界面
function TableLayer:initUI()
	local layer = MainLayer:create(self,true);
	self:addChild(layer);

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();
	RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_LIST);

	--发送下注历史
	local msg = {};
    msg.lUserID = PlatformLogic.loginResult.dwUserID;

    RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_RESULT,msg,GameMsg.MSG_GP_RC_RESULT);

    --创建加载图片
    local winSize = cc.Director:getInstance():getWinSize();
    local loadSp = ccui.ImageView:create("zhuye/jiazai.png");
    loadSp:setPosition(winSize.width/2,winSize.height/2);
    loadSp:setName("loadSp");
    self:addChild(loadSp,200);

end
--返回大厅
function TableLayer:ExitGame()
	local func = function()
        self.tableLogic:sendUserUp();
        self.tableLogic:sendForceQuit();  
    end

    Hall:exitGame(false,func);

end


--游戏列表消息 2.1
function TableLayer:onEcList(data)
    local msg = data._usedata;
    ----luaDump(msg,"游戏列表消息--------------")

    local layer = self:getChildByName("MainLayer");
    if layer then
    	layer:ClearMatchLlist();
    end

    for k,v in pairs(msg.info) do
        self.GameEcList[v.event_id] = v;

        local eventMsg = {};
        eventMsg.EventID = v.event_id;

        luaPrint("游戏的eventid",v.event_id)

        RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_SPECIAL_EC_LIST,eventMsg,GameMsg.MSG_GP_GET_SPECIAL_EC_LIST);
        RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_GAMETYPE_EC_LIST,eventMsg,GameMsg.MSG_GP_GET_SPECIAL_EC_LIST);
    end

    local layer = self:getChildByName("MainLayer");
    if layer then
        layer:UpdateSearchList();
    end

end

--获取游戏 用于游戏选择
function TableLayer:GetAllEcList()
    local ecList = {};
    --塞入全部赛事
    ecList = {};
    ecList[1] = {};
    ecList[1].event_id = 0;
    ecList[1].eventName = "全部赛事";

    for k,v in pairs(self.GameEcList) do
        table.insert(ecList,v);
    end

    -- ----luaDump(ecList,"获取游戏 用于游戏选择")

    return ecList;

end

--下注
function TableLayer:onEcBet(data)
    local msg = data._usedata;
    ----luaDump(msg,"游戏下注消息--------------")
    if msg.lRet == 0 and msg.UserID == PlatformLogic.loginResult.dwUserID then
    	PlatformLogic.loginResult.i64Money = PlatformLogic.loginResult.i64Money - msg.lScore;
    	CompetInfo:setUserMoneyUpdate();
        addScrollMessage("下注成功");
    elseif msg.lRet == 5 and msg.UserID == PlatformLogic.loginResult.dwUserID then
        addScrollMessage("赛事非下注状态");
    else
        addScrollMessage("下注失败");
    end

    --发送下注历史
	local msg = {};
    msg.lUserID = PlatformLogic.loginResult.dwUserID;

    RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_RESULT,msg,GameMsg.MSG_GP_RC_RESULT);
end

--获取战绩
function TableLayer:onEcResult(data)
    local msg = data._usedata;
    table.sort(msg,function(a,b)
        return a.lTime>b.lTime;
    end);
    self.GameBetList = msg;
    dispatchEvent("onEcResult");
end

--赛事列表消息 4.1
function TableLayer:onSpecialEcList(data)
    local msg = data._usedata;
    ----luaDump(msg.info,"赛事列表消息--------------")

    self.GameSpecialEcList[msg.EventID] = msg;
end

--获取赛事分类
function TableLayer:onClassEcList(data)
    local msg = data._usedata;
    ----luaDump(msg,"赛事分类消息--------------")
end

--赛事专题下的比赛列表 4.3
function TableLayer:onGametypeEcList(data)
    local msg = data._usedata;
    -- ----luaDump(msg.info,"比赛列表消息--------------");

    local timeSplit = function(timeStr)
        local beginTime = string.split(timeStr," ");
        local timeSplit = string.split(beginTime[1],"-");
        local timeSplit1 = string.split(beginTime[2],":");


        return {timeSplit[1],timeSplit[2],timeSplit[3],timeSplit1[1],timeSplit1[2]};
    end



    if #msg.info>1 then
        for i = 1,#msg.info-1 do
            for j = i+1,#msg.info do

                local timeTable1 = timeSplit(msg.info[i].begin_time);
                local timeTable2 = timeSplit(msg.info[j].begin_time);

                local flag = false;
                for k=1,#timeTable1 do
                    if tonumber(timeTable1[k])<tonumber(timeTable2[k]) then
                        flag = false;
                        break;
                    elseif tonumber(timeTable1[k])>tonumber(timeTable2[k]) then
                        flag = true;
                        break;
                    end
                end

                if flag then
                    local temp = msg.info[i];
                    msg.info[i] = msg.info[j];
                    msg.info[j] = temp;
                end

            end
        end
    end


    self.GametypeEcList[msg.EventID] = msg;

    local count = 1;

    for k,v in pairs(self.GametypeEcList[msg.EventID].info) do

        v.player = json.decode(v.player);

        v.teamInfo = json.decode(v.teamInfo);

        v.guess = {};

        local eventMsg = {};
        eventMsg.EventID = v.event_id;
        eventMsg.GameID = v.game_id;

        --self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*count),cc.CallFunc:create(function()
           RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_REALTIME_INFO,eventMsg,GameMsg.MSG_GP_GET_GAMETYPE_EC_LIST);
        --end)));

        count = count+1;

    end

end

function TableLayer:UpdateMainLayer()
	local layer = self:getChildByName("MainLayer");
    if layer then
    	layer:InitMatchList();
    end
end

--
function TableLayer:onEventEcList(data)
    local msg = data._usedata;
    ----luaDump(msg,"onEventEcList--------------")
end

--比赛动态信息 9.1
function TableLayer:onRealtimeInfo(data)
    local msg = data._usedata;
    -- ----luaDump(msg.info,"onRealtimeInfo--------------")

    local msgCopy = clone(msg.info);
    local guessTable = {};

    if #msgCopy>1 then
        for i = 1,#msgCopy-1 do
            for j = i+1,#msgCopy do
                if tonumber(msgCopy[i].bet_id) > tonumber(msgCopy[j].bet_id) then
                    local temp = msgCopy[i];
                    msgCopy[i] = msgCopy[j];
                    msgCopy[j] = temp;
                end
            end
        end
    end

    --设置是否遍历标志
    for k,v in pairs(msgCopy) do
        v.flag = false;
    end

    if #msgCopy > 0 then
        while true do
            local guessData = {};

            local msgCopyData = nil;

            --取没有遍历过的为第一个
            for k,v in pairs(msgCopy) do
                if v.flag == false then
                    msgCopyData = v;
                    break;
                end
            end

            if msgCopyData == nil then
                break;
            end

            if msgCopyData then
                guessData.begin_time = msgCopyData.begin_time;
                guessData.bet_id = msgCopyData.bet_id;
                guessData.bet_title = msgCopyData.bet_title;
                guessData.eventid = msgCopyData.eventid;
                guessData.game_status = msgCopyData.game_status;
                guessData.gameid = msgCopyData.gameid;
                guessData.items = {}

                for k,v in pairs(msgCopy) do
                    if msgCopyData.bet_id == v.bet_id and v.flag == false then
                        table.insert(guessData.items,v);
                        v.flag = true;
                    end
                end

                table.insert(guessTable,guessData);
            end

        end
    end


    --判断是否可以下注
    local zhuStatus = false;
    for k,v in pairs(guessTable) do
        for k1,v1 in pairs(v.items) do
            if tonumber(v1.items_odds_status) == 1 and tonumber(v1.isDelete) == 0 then
                zhuStatus = true;
                break;
            end
        end

        if zhuStatus == true then
            break;
        end
    end

    if self.GametypeEcList[msg.EventID] == nil then
        return;
    end

    for k,v in pairs(self.GametypeEcList[msg.EventID].info) do
    	if tonumber(v.game_id) == tonumber(msg.GameID) then
    		v.guess = guessTable;
            -- v.game_status = guessTable.game_status;
            v.zhuStatus = zhuStatus;
    		self:UpdateMainLayer(v);
    	end
    end

    -- ----luaDump(self.GametypeEcList[msg.EventID],"比赛动态信息")

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        local loadSp = self:getChildByName("loadSp");
        if loadSp then
            loadSp:removeFromParent();
        end
    end)))

    dispatchEvent("onRealtimeInfo");

end

function TableLayer:MZTW_Mess_UserInfo()
    local msg = {};
    msg.lUserID = PlatformLogic.loginResult.dwUserID;

    RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_RESULT,msg,GameMsg.MSG_GP_RC_RESULT);
end

return TableLayer;