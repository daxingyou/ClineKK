local HallLayer = class("HallLayer", BaseWindow)
local PlatformGameList = require("logic.platformLogic.PlatformGameList")
local PlatformRoomList = require("logic.platformLogic.PlatformRoomList")
local GameRoom = require("layer.GameRoom")
local GameDesk = require("layer.GameDesk")
local GameRelineLayer = require("layer.GameRelineLayer")
local BottomNode = require("layer.popView.BottomNode")
local UserInfoNode = require("layer.popView.UserInfoNode")

local SPRITE_BACK_ROOM_OFF = "platform/back.png";
local SPRITE_BACK_ROOM_ON = "platform/back.png";
local SPRITE_ADD_ROOM_OFF = "platform/jiaru.png";
local SPRITE_ADD_ROOM_ON = "platform/jiaru.png";

local BACK_ROOM_TAG = 100;
local CREATE_ROOM_TAG = 101;

--开房类型
RoomType = 
{
    NormalRoom = 0,--正常房间
    JinBiRoom = 1,--金币房
    DaiKaiRoom = 2,--代开房
}

layerZorder = 110;
gameZorder = 1100

local _hallLayer = nil;

function HallLayer:getInstance()
    return _hallLayer;
end

function HallLayer:create(createType,roomid)
    return HallLayer.new(createType,roomid)
end

function HallLayer:scene()
    local layer = HallLayer:create();

    local scene = display.newScene();
    scene:addChild(layer);

    return scene;
end

function HallLayer:returnPlatformDirectMatch()
    local layer = HallLayer:create();

    local scene = display.newScene();
    scene:addChild(layer);
    
    layer:matchGameEvent();
    
    return scene;
end

function HallLayer:returnPlatform()
    globalUnit.isCheckWebLogin = true;

    local layer = HallLayer:create();

    local scene = display.newScene();
    scene:addChild(layer);

    return scene;
end

function HallLayer:ctor(createType,roomid)
    playEffect("hall/sound/welcome.mp3")
    self.super.ctor(self, 0);
    if createType == nil then
        Event:clearEventListener(1);
    end

    self.createType = createType;
    self.loginRoomid = roomid;--比赛场回房间时赋值
    self:initData();

    self:bindEvent();

    _hallLayer = self;
end

function HallLayer:initData()
    self.roomid = {};

    -- //房间信息
    self.m_desk_lock_pass = {};
    --AA制提示
    self.m_PromptLayer = nil;
    self.m_bIsClickBackRoom = false;

    self.iDeskID = 0;

    self._gameListLogic = PlatformGameList.new(self);
    self._roomListLogic = PlatformRoomList.new(self);

    --房间列表层
    self.gameRoomLayer = nil;

    self.gameDeskLayer = nil;
    self.room_Key_Data = {};
    self.room_Key_Data.iNameID = 0;
    self.room_Key_Data.iRoomID = 0;
    self.room_Key_Data.iDeskID = 0;
    self.room_Key_Data.szLockPass = "";
    for i=1,61 do
        self.room_Key_Data.szLockPass = self.room_Key_Data.szLockPass.."0";
    end

    self.Go_game = true;--输入密码直接进入

    --规则
    self.m_nSelectCreateID = 0;
    self.m_nGameRuleID = 0;
    self.m_bAAFanKa = false;

    self.addRoomLayer = nil;
    self.m_bIsClickBackRoom = false;

    self.curRoomMode = RoomType.NormalRoom;   --0正常开房  1 金币房 2 代开房

    HeadManager:setPostUrl(GameConfig:getHeadUpLoadUrl());
    HeadManager:setRequestUrl(GameConfig:getHeadDownloadUrl());

    self.m_iHeartCount = 0;
    self.m_maxHeartCount = 3;

    if NOWPAOTAI == nil then
        -- NOWPAOTAI = "nowpaotai"..PlatformLogic.loginResult.dwUserID;

        -- globalUnit:setSelectedCannon(globalUnit:getSelectedCannon());
    end

    --游戏下载进度条对象
    gameDownloadProgessTimer = {}
    self.updateBtn = {}
end

function HallLayer:bindEvent()
    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_ROOM",function (event) self:searchRoom(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_DESK_LOCK_PASS",function (event) self:gameNotify(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_USE_ROOM_KEY",function (event) self:FKGameNotify(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GETLIST",function (event) self:exchangeList(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_USERINFO_GET",function (event) self:refreshUserInfo(event) end);
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_USERINFO_ACCEPT",function (event) self:setUserName(event) end);
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"I_P_M_Heart",function (event) self:I_P_M_Heart(event) end);
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_LOGON_PLAYER_LIST",function (event) self:GetRoleList(event) end);--用户角色列表
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_MAILLIST",function (event) self:GetMailList(event) end);--用户邮件列表
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_JIUJI",function (event) self:getJiujiResult(event) end);--用户邮件列表
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_JIUJI_TIP",function (event) self:getIsJiujiResult(event) end);--用户邮件列表
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_TRANS_PLAYER",function (event) self:TransRole(event) end);--用户角色转移   
    self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_WorldMessage",function (event) self:showWorldMessage(event) end);--用户角色转移   
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_SCORE",function (event) self:getExchangeResult(event) end);--取
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_STORE_SCORE",function (event) self:saveExchangeResult(event) end);--存
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_Laba",function (event) self:showLabaResult(event) end);--喇叭
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_UPDATE_TASK",function (event) self:RecTaskRes(event) end);--获取任务奖励
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_TASKLIST",function (event) self:GetTaskList(event) end);--获取任务列表
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_VIP",function (event) self:GetVipresult(event) end);--获取领取结果
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_FavCompain",function (event) self:GetTehuiList(event) end);--获取特惠列表
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_BindPhone",function (event) self:GetCheckPhoneresult(event) end);    
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_CONFIG",function (event) self:getGoodSConfig(event) end);    
    -- self.bindIds[#self.bindIds + 1] = Event:registerListener(self,"ASS_GP_GET_SHOUCHONG",function (event) self:getChongzhiResult(event) end);

    -- self:pushEventInfo(SignInfo, "signStateInfo", handler(self, self.receiveSignStateInfo));
    -- self:pushEventInfo(VipInfo, "userVipInfo", handler(self, self.receiveUserVipInfo));
    self:pushEventInfo(MoneyInfo, "moneyInfo", handler(self, self.receiveMoneyInfo))
    self:pushEventInfo(MoneyInfo, "getMoney", handler(self, self.receiveGetMoney))

    -- self:pushGlobalEventInfo("exitCreateRoom",handler(self, self.receiveExitCreateRoom))
    self:pushGlobalEventInfo("platformHeart",handler(self, self.I_P_M_Heart))
    self:pushGlobalEventInfo("matchRoom",handler(self, self.matchGameEvent))
    self:pushGlobalEventInfo("requestGameList",handler(self, self.requestGameRoomTimerCallBack))
    self:pushGlobalEventInfo("enterGameAndStopCheckNet",handler(self, self.stopCheckNet))
    self:pushGlobalEventInfo("startCheckNet",handler(self, self.startCheckNet))
    self:pushGlobalEventInfo("requestRoomList",handler(self, self.requestRoomList))
    self:pushGlobalEventInfo("registerAccount", handler(self, self.registerAccount))
    self:pushGlobalEventInfo("removeUpdateNotify",handler(self, self.removeUpdateNotify))
    self:pushGlobalEventInfo("downloadGame",handler(self, self.syncDownState))
    self:pushGlobalEventInfo("refreshScoreBank",handler(self, self.getInforData))--银行存取
    self:pushGlobalEventInfo("notifySameGameUpdate",handler(self,self.syncSameGameUpdate))
    self:pushGlobalEventInfo("selectDesk", handler(self, self.selectDesk))
    self:pushGlobalEventInfo("downFileFail", handler(self, self.downFileFail))
    self:pushGlobalEventInfo("unzipFileFail", handler(self, self.unzipFileFail))
    self:pushGlobalEventInfo("I_R_M_MatchDeskFinish", handler(self,self.matchDesk))
    self:pushGlobalEventInfo("accountQuit", handler(self,self.accountQuit))
    self:pushGlobalEventInfo("pushMessage", handler(self,self.pushScorllMessage))
    self:pushGlobalEventInfo("playOutTime", handler(self, self.playOutTime))--试玩场超时
    self:pushGlobalEventInfo("webScore",handler(self, self.webRefreshScore))
    self:pushGlobalEventInfo("reDownload",handler(self, self.reDownload))--下载失败重新下载
    self:pushEventInfo(SettlementInfo,"weChat",handler(self, self.receiveWeChat))
    self:pushGlobalEventInfo("bindPhone", handler(self, self.bindPhone))
    self:pushEventInfo(SettlementInfo,"configInfo",handler(self, self.receiveConfigInfo))
    -- self:pushEventInfo(LuckyInfo,"luckyOpenInfo",handler(self, self.receiveLuckyOpenInfo))
    self:pushEventInfo(VipInfo,"noGuildInfo",handler(self, self.receiveNoGuildInfo))
    self:pushEventInfo(VipInfo,"haveGuildInfo",handler(self, self.receiveHaveGuildInfo))
    self:pushEventInfo(VipInfo,"guildCommendAgree",handler(self, self.receiveGuildCommendAgree))
    self:pushGlobalEventInfo("onPlatformRegistCallback",handler(self, self.onReceivePlatformRegistCallback))
    self:pushEventInfo(VipInfo,"guildSendMoneyReq",handler(self, self.receiveGuildSendMoneyReq))
    self:pushGlobalEventInfo("forceUser",handler(self, self.forceUser))
    self:pushGlobalEventInfo("refreshGameList", handler(self, self.refreshGameList))
end

function HallLayer:unBindEvent()
    if self.bindIds == nil or (type(self.bindIds) == "table" and next(self.bindIds) == nil) then
        return;
    end

    for _, bindid in ipairs(self.bindIds) do
        Event:unRegisterListener(bindid)
    end
end

function HallLayer:onExit()
    self.super.onExit(self);
    self:unBindEvent();

    local eventDispatcher =self:getEventDispatcher()
    eventDispatcher:removeEventListener(self.keyListener)

    if self.newtip and not tolua.isnull(self.newtip) then
        self.newtip:release();
    end

    for k,v in pairs(self.updateBtn) do
        local data = {_usedata = {v[2],v[1]}}
        self:removeUpdateNotify(data)
    end

    PlatformRegister:getInstance():stop()

    self._gameListLogic:stop();
    self._roomListLogic:stop();

    self._gameListLogic = nil
    self._roomListLogic = nil

    if self.gameRoomLayer then
        self.gameRoomLayer:clear();
        self.gameRoomLayer = nil;
    end

    if self.gameDeskLayer then
        self.gameDeskLayer:clear();
        self.gameDeskLayer = nil;
    end

    _hallLayer = nil;
end

function HallLayer:onEnterTransitionFinish()
    self:initUI()
    requestNotice()

    self:requestGameRoomTimerCallBack()

    performWithDelay(self,function() self:playScrollMessage() createExtendQr() initShop() if globalUnit.isRestartDown == true then Hall:restartDownload() end end, 0.1)

    if self.createType == nil then
        self.Image_headBg:setPositionX(self.Image_headBg:getPositionX()-(winSize.width-1280)/2)

        self.Button_shantui:setPositionX(self.Button_shantui:getPositionX()+(winSize.width-1280)/2);
        self.Button_sign:setPositionX(self.Button_shantui:getPositionX() - 90)

        if device.platform == "android" then
            self.Button_sign:setPositionX(self.Button_shantui:getPositionX());  
        end

        self.Button_copy:setPositionX(self.Button_sign:getPositionX() - 90)
        self.Button_jiujijin:setPositionX(self.Button_copy:getPositionX() - 90)

        MailInfo:sendMailListInfoRequest()
        MailInfo:sendQuestionListRequest()
        SettlementInfo:sendConfigInfoRequest(6)
        SettlementInfo:sendConfigInfoRequest(serverConfig.xingYunDuoBao)

        clearCache(nil,true,true)
        SettlementInfo:sendConfigInfoRequest(serverConfig.total)
        SettlementInfo:sendPayConfigInfoRequest()
    end
    self.Button_jiujijin.oldx = self.Button_jiujijin:getPositionX()
    self.Button_sign.oldx = self.Button_sign:getPositionX()
    self.Button_copy.oldx = self.Button_copy:getPositionX()
    self:onHallKeypad()
end

function HallLayer:initUI()
    logInfo = ""
    local uiTable = {
        Image_bg = "Image_bg",
        Text_name = "Text_name",
        Clip_head = "Clip_head",
        Button_ddz = "Button_ddz",
        Button_by = "Button_by",
        Button_dr = "Button_dr",
        Button_dz = "Button_dz",
        Button_copy = "Button_copy",
        Button_jiujijin = "Button_jiujijin",
        Image_top = "Image_top",
        -- Text_net = "Text_net",
        Image_headBg = "Image_headBg",
        Button_notice = "Button_notice"
    }
    loadNewCsb(self,"hallLayer",uiTable)
    -- self.Text_net:setString("www.78196.com")
    self.Button_ddz:hide()
    self.Button_by:hide()
    self.Button_dr:hide()
    self.Button_dz:hide()
    self.Button_copy:hide()
    self.Button_jiujijin:hide()

    -- self.Button_copy:setPositionX(self.Button_copy:getPositionX() + 100)
    -- self.Button_jiujijin:setPositionX(self.Button_jiujijin:getPositionX() + 100)

    local btn = ccui.Button:create("hall/qiandao.png","hall/qiandao-on.png")
    btn:setPosition(self.Button_copy:getPositionX()+70,self.Button_copy:getPositionY())
    btn:setName("Button_sign")
    self.Button_jiujijin:getParent():addChild(btn)
    self.Button_sign = btn

    local btn = ccui.Button:create("hall/yufangshantui.png","hall/yufangshantui-on.png")
    btn:setPosition(self.Button_sign:getPositionX()+70,self.Button_copy:getPositionY())
    btn:setName("Button_shantui")
    self.Button_jiujijin:getParent():addChild(btn)
    self.Button_shantui = btn

    if device.platform == "android" then
        self.Button_shantui:setVisible(false);
        self.Button_sign:setPositionX(self.Button_shantui:getPositionX());
    end

    self.Text_name:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen))

    self.Text_name:setFontSize(24);

    local text = FontConfig.createWithSystemFont(string.format("ID:%d",PlatformLogic.loginResult.dwUserID),20,cc.c3b(255,255,255),cc.size(200,24),"",cc.TEXT_ALIGNMENT_LEFT)
    text:setAnchorPoint(cc.p(0,0.5));
    self.Text_name:getParent():addChild(text);
    text:setPosition(cc.p(self.Text_name:getPositionX(),self.Text_name:getPositionY() - 34))

    -- if PlatformLogic.loginResult.IsYueKa == 1 then
    --     self.Text_name:setColor(cc.c3b(255,0,0))
    -- end
    -- self.Text_id:setString("ID: "..PlatformLogic.loginResult.dwUserID)
    local head = cc.Sprite:create(getHeadPath())
    head:setName("head");
    self.Clip_head:addChild(head)
    head:setScale(0.5)

    local headbg = cc.Sprite:create("hall/hall/touxiang-bg2.png")
    headbg:setPosition(self.Clip_head:getPosition())
    self.Clip_head:getParent():addChild(headbg,2)

    local winSize = cc.Director:getInstance():getWinSize();
    local x = 621
    local y = 142;

    self.Button_jiujijin:onClick(handler(self, self.onClickBtn))
    self.Button_copy:onClick(handler(self, self.onClickBtn))
    self.Button_sign:onClick(handler(self, self.onClickBtn))
    self.Button_shantui:onClick(handler(self, self.onClickBtn))

    local headBtn = ccui.Widget:create();
    headBtn:setName("headBtn");
    headBtn:setTouchEnabled(true);
    headBtn:setContentSize(cc.size(100,100));
    headBtn:setAnchorPoint(cc.p(0.5,0.5));
    headBtn:setPosition(self.Clip_head:getPosition());
    self.Clip_head:getParent():addChild(headBtn);
    headBtn:addClickEventListener(function(sender) self:onClickBtn(sender); end);

    -- local name = getHeadPath(PlatformLogic.loginResult.bLogoID);
    -- name = name.."LogonResult.bLogoID___"..PlatformLogic.loginResult.bLogoID..Name_Local_Head_Pic;
    -- luaPrint("name==========", name);

    -- if PlatformLogic.loginResult.bLogoID >= 45 then
    --     local fullpath = cc.FileUtils:getInstance():getWritablePath();
    --     name = cc.FileUtils:getInstance():getWritablePath().."headupload.png";
    --     if not cc.FileUtils:getInstance():isFileExist(name) then
    --         name = Name_Local_Head_Pic;
    --     end
    -- end
    -- self.Clip_head:getChildByName("head"):initWithFile(Name_Local_Head_Pic);

    -- if cc.FileUtils:getInstance():isFileExist(name) then
    --     self.Clip_head:getChildByName("head"):initWithFile(name);
    -- end

    if globalUnit.isRegisterEnterGame == true then
        --注册 
        -- if globalUnit.isregisterSec == true then
            -- reyunSetRegisterWithAccountID(PlatformLogic.loginResult.dwUserID)
        --     globalUnit.isregisterSec = false;
        -- end
        if self.createType == nil then
            globalUnit.isRegisterEnterGame = false
        end
        -- getGameChannel();

        -- if globalUnit.gameChannel == "" then
        --     getGameChannel();
        -- end
        -- luaPrint("globalUnit.gameChannel  ==== "..tostring(globalUnit.gameChannel))
        local msg = PlatformLogic.loginResult;
        msg.szIP = getIPAddress()
        if not isEmptyString(SocialUtils._wx_nickname) and msg.nickName == "YK"..PlatformLogic.loginResult.dwUserID then  --globalUnit:getLoginType() == wxLogin then
            globalUnit:setLoginType(wxLogin)
            msg.nickName = SocialUtils._wx_nickname..PlatformLogic.loginResult.dwUserID
            PlatformLogic.loginResult.bBoy = (SocialUtils._wx_sex == 1)
            msg.bBoy = PlatformLogic.loginResult.bBoy
            local path,id = getHeadPath(255,msg.bBoy,true)
            PlatformLogic.loginResult.bLogoID = id

            self.Clip_head:getChildByName("head"):initWithFile(path)
        end
        luaDump(msg,"修改昵称")
        PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_USERINFO_UPDATE_BASE, msg, PlatformMsg.MSG_GP_R_LogonResult);
    end

    self:refreshHead();

    --游戏中退回房间才检测是否在某个房间
    if not globalUnit.isFirstTimeInGame then
        -- luaPrint("游戏中退回房间才检测是否在某个房间")
        -- local msg = {};
        -- msg.iUserID = PlatformLogic.loginResult.dwUserID;
        -- PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_GET_ROOM, msg, PlatformMsg.MSG_GP_C_USE_ROOM_KEYINFO);
    end
    
    self:getInforData();

    --跑马灯
    self:showNotice();

    if self.createType == nil then
        self:initMusic();
        --添加后台回调
        self:startCheckNet()
    end

    self:initGameBtn()

    self:appleViewOff()

    local node = BottomNode:create()
    node:setPosition(winSize.width/2,0)
    self.csbNode:addChild(node,2)
    -- node:hide()
    self.bottomNode = node

    local node = UserInfoNode:create()
    node:setPosition(self.Image_top:getContentSize().width*0.39,self.Image_top:getContentSize().height*0.55)
    self.Image_top:addChild(node)
    -- self.Image_top:hide()
end

function HallLayer:showGameListView()
    if not self.csbNode:getChildByName("GameListLayer") then
        local layer = require("layer.popView.GameListLayer"):create()
        layer:setName("GameListLayer")
        self.csbNode:addChild(layer)

        -- self:receiveExitCreateRoom()
    else        
        local func = function()
            local cName,game = Hall:getCurrentGameName()

            if game and game.pushLayer[1] then
               if game.pushLayer[1]:getName() ~= "gameLayer" then
                    game.pushLayer[1]:bindEvent()
               end
            end
        end

        performWithDelay(self,func,0.1)

        dispatchEvent("refreshVIPGameList");--通知VIP界面
    end 
end

function HallLayer:onHallKeypad()
    local function onrelease(code, event)
        if code == cc.KeyCode.KEY_BACK then
            luaPrint("你点击了返回键")
            self:exitGame()
        elseif code == cc.KeyCode.KEY_HOME then
            luaPrint("你点击了HOME键")
            self:exitGame()
        end
    end

    local listener = cc.EventListenerKeyboard:create()

    listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_PRESSED)

    --lua中得回调，分清谁绑定，监听谁，事件类型是什么
    local eventDispatcher =self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
    self.keyListener = listener
end

function HallLayer:exitGame()
    if display.getRunningScene():getChildByName("exitGameLayer") then
        display.getRunningScene():getChildByName("exitGameLayer"):delayCloseLayer(0)
    else
        display.getRunningScene():addChild(require("layer.popView.ExitGameLayer"):create(),100000)
    end
end

--btn点击事件添加
function HallLayer:initGameBtn()
    self.Button_ddz:onClick(handler(self,self.onClickDdz))--斗地主
    self.Button_by:onClick(handler(self,self.onClickBy))--捕鱼
    self.Button_dr:onClick(handler(self,self.onClickDr))--多人
    self.Button_dz:onClick(handler(self,self.onClickDz))--对战

    -- table.insert(self.updateBtn,{self.Button_ddz,"bairenniuniu"})
    -- table.insert(self.updateBtn,{self.Button_by,"fishing"})
end

--播放大厅进入特效
function HallLayer:playPlatformEnterEffect()
    if self.isPlayEffect == true then
        return;
    end

    self.isPlayEffect = true

    self.Image_top:show()
    self.bottomNode:show()

    if self.touchLayer == nil then
        self.touchLayer = display.newLayer();
        self.touchLayer:setTouchEnabled(true);
        self.touchLayer:setLocalZOrder(100);
        self:addChild(self.touchLayer)
        self.touchLayer:onTouch(function(event) 
                                local eventType = event.name; 
                                if eventType == "began" then
                                    return true
                                end
                    end,false, true);
    end

    local dx = 865
    local bx = 1205
    local jx = 1765
    local x = 1540
    local y = 130
    local unit = 30

    local seq = cc.Sequence:create(
        cc.MoveBy:create(10/unit,cc.p(-dx-375,0)),
        cc.MoveBy:create(5/unit,cc.p(75,0)),
        cc.MoveBy:create(5/unit,cc.p(-30,0))
    )
    self.Button_ddz:runAction(seq)

    local seq = cc.Sequence:create(
        cc.DelayTime:create(5/unit),
        cc.MoveBy:create(10/unit,cc.p(-bx-25,0)),
        cc.MoveBy:create(5/unit,cc.p(68,0)),
        cc.MoveBy:create(5/unit,cc.p(-28,0))
    )
    self.Button_by:runAction(seq)

    local seq = cc.Sequence:create(
        cc.DelayTime:create(10/unit),
        cc.MoveBy:create(10/unit,cc.p(-x+325,0)),
        cc.MoveBy:create(5/unit,cc.p(68,0)),
        cc.MoveBy:create(5/unit,cc.p(-48,0))
    )
    self.Button_dr:runAction(seq)

    self.Button_dz:runAction(seq:clone())

    -- local seq = cc.Sequence:create(
    --     cc.DelayTime:create(13/unit),
    --     cc.MoveBy:create(10/unit,cc.p(-jx+540,0)),
    --     cc.MoveBy:create(5/unit,cc.p(66,0)),
    --     cc.MoveBy:create(5/unit,cc.p(-33,0))
    -- )
    -- self.Button_jiujijin:runAction(seq)

    local seq = cc.Sequence:create(
        cc.DelayTime:create(7/unit),
        cc.MoveBy:create(15/unit,cc.p(0,-y-20)),
        cc.MoveBy:create(3/unit,cc.p(0,20))
    )
    self.Image_top:runAction(seq)

    local seq = cc.Sequence:create(
        cc.DelayTime:create(7/unit),
        cc.MoveBy:create(15/unit,cc.p(0,y+20)),
        cc.MoveBy:create(3/unit,cc.p(0,-20)),
        cc.CallFunc:create(function() self:playScrollMessage() end)
    )
    self.bottomNode:runAction(seq)
end

--动画播放完毕后，播放缓存喇叭消息
function HallLayer:playScrollMessage()
    try({
            function() 
                if self.createType == nil and isShowAccountUpgrade == nil then
                    self.isShowTip = true
                    showAccountUpgrade()
                    --showAdvertising();

                    local url = GameConfig.serverVersionInfo.appUrl
                    if url == nil then
                        url = "http://www.h29.com"
                    end
                    SettlementInfo:sendConfigInfoRequest(8)
                    SettlementInfo:sendConfigInfoRequest(serverConfig.qianDao)
                    self.url = url
                    self:stopActionByTag(123)
                    self:showNotice()
                    -- self:onClickBtn(self.Button_notice)
                    -- showSign()
                    performWithDelay(self,function() Hall:showScrollMessage("官网地址："..url) end, 0.2)
                end

                onlineRemind()
            end,
            catch=function(error)
                print("playScrollMessage error ",error)
            end
        })

    if self.touchLayer then
        self.touchLayer:removeFromParent();
        self.touchLayer = nil;
    end
end

--重播动画前，设置按钮位置
function HallLayer:resetPlatformViewPos()
    local dx = 865+330
    local bx = 1205-15
    local jx = 1765-573
    local x = 1540-345
    local y = 130

    self.Button_ddz:setPositionX(self.Button_ddz:getPositionX()+dx)
    self.Button_by:setPositionX(self.Button_by:getPositionX()+bx)
    self.Button_dr:setPositionX(self.Button_dr:getPositionX()+x)
    self.Button_dz:setPositionX(self.Button_dz:getPositionX()+x)
    -- self.Button_jiujijin:setPositionX(self.Button_jiujijin:getPositionX()+jx)

    self.Image_top:setPositionY(self.Image_top:getPositionY()+y)
    self.bottomNode:setPositionY(self.bottomNode:getPositionY()-y)

    self.isPlayEffect = false
end

function HallLayer:pushScorllMessage(data)
    local data = data._usedata

    if globalUnit.isEnterGame ~= true or data ~= nil then
        if self.url then
            Hall:showScrollMessage("官网地址："..self.url)
        end
    end
end

--保险箱
function HallLayer:onClickBank()
    if roleData ~= nil then 
        local runningScene = display.getRunningScene();
        local layer = BankLayer:create(roleData);
        layer:setName("banklayer");
        layer:setCallBack(function(type,value) self:sendExchangeGold(type,value); end)
        runningScene:addChild(layer);
    end
end

--更新福利气泡
function HallLayer:updatafuliTip()
    -- local realname = PlatformLogic.loginResult.szRealName;
    -- local phonenum = PlatformLogic.loginResult.szMobileNo;
    -- if realname ~= "" and phonenum ~= "" then
    --     if self.newtip then
    --         self.newtip:removeFromParent();
    --         self.newtip:release();
    --     end 
    -- end
end

--更新月卡红点
function HallLayer:updataYuekaTip()
    -- local myueka = PlatformLogic.loginResult.IsYueKa;
    -- local mscore = PlatformLogic.loginResult.IsGetYkScore;
    -- if myueka == 1 and mscore == 1 then
    --     if self.yuekaTipbg then
    --         self.yuekaTipbg:removeFromParent();
    --     end
    -- end
end

function HallLayer:sendIsJiuji()
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER, PlatformMsg.ASS_GP_JIUJI_TIP, msg, PlatformMsg.MSG_P_GET_JIUJI);
end

function HallLayer:sendRequestReliefMoneyResult()
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER, PlatformMsg.ASS_GP_GET_JIUJI, msg, PlatformMsg.MSG_P_GET_JIUJI);
end

function HallLayer:refreshHead()
    luaPrint("刷新头像")
    if gHeadPath ~= "" and cc.FileUtils:getInstance():isFileExist(gHeadPath) and self.Clip_head then
        local head = self.Clip_head:getChildByName("head")
        if head then
            head:initWithFile(gHeadPath);
        end
        
        gHeadPath = "";

        local msg = {};
        msg.dwUserIdx = PlatformLogic.loginResult.dwUserID;
        msg.bLogoIdx = PlatformLogic.loginResult.bLogoID;
        PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_SETUPDATELOGO, msg, PlatformMsg.MSG_SETLOGO_INFO);
        PlatformLogic.loginResult.bLogoID = PlatformLogic.loginResult.bLogoID + 256;

        self:postHttpHead();
    end
end

function HallLayer:appleViewOff()
    -- if device.platform == "ios" then
    --     if appleView == 1 then
    --         self.Button_exit:setVisible(false);
    --         self:playPlatformEnterEffect();
    --     else
    --         self:addEffect();
    --     end
    -- else
    --     self:addEffect();
    -- end
    if self.touchLayer == nil then
        self.touchLayer = display.newLayer();
        self.touchLayer:setTouchEnabled(true);
        self.touchLayer:setLocalZOrder(100);
        self:addChild(self.touchLayer)
        self.touchLayer:onTouch(function(event) 
                                local eventType = event.name; 
                                if eventType == "began" then
                                    return true
                                end
                    end,false, true);
    end
end

--跑马灯
function HallLayer:showNotice()
    Hall:clearShowScrollMessage()
    Hall:clearNewScrollMessage()
end

function HallLayer:showWorldMessage(event)
    local msg = event.data;

    if self.isShowMessage ~= true then
        if self.cacheMessage == nil then
            self.cacheMessage = {};
        end

        table.insert(self.cacheMessage,msg);
        -- return;
    end

    if msg.messageType == 2 then
        local name = Hall:getGameNameByNameID(msg.uNameId)

        local ret = false

        for k,v in pairs(GamesInfoModule._gameNames) do
            if v.uNameID == msg.uNameId then
                ret = true
                break
            end
        end

        if not ret and msg.uNameId > 0 then
            return
        end

        if LoginLayer:getInstance() and globalUnit.isEnterGame ~= true then
            return
        end
    end

    if msg.messageType == 0 then
        Hall:showScrollMessage(msg.data);
    elseif msg.messageType == 1 then
        Hall:showFishMessage(msg)
    elseif msg.messageType == 2 then
        Hall:showScrollMessage(msg,MESSAGE_ROLL)
    elseif msg.messageType == 3 then --提现
        Hall:showScrollMessage(msg,MESSAGE_ROLL)
    elseif msg.messageType == 1000 then --喇叭
        addScrollMessage(msg.data)
    end
end

function onEnterBackground()
    luaPrint("进入后台了---------------------------------------------")
    cc.UserDefault:getInstance():setBoolForKey("bEnterBackground", false)
end

function onEnterForeground()
    luaPrint("从后台回来了---------------------------------------------")

    cc.UserDefault:getInstance():setBoolForKey("bEnterBackground", true)

    if HallLayer:getInstance() and device.platform ~= "windows" then
        HallLayer:getInstance():toCallUpdateRoomkey()
        if PlatformLogic:isConnect() then
            MailInfo:sendMailListInfoRequest()
        end
    end

    if globalUnit.isTryPlay == true and device.platform ~= "windows" then
        -- RoomLogic:close()
    end
end

function HallLayer:receiveUserVipInfo(data)
    -- local data = data._usedata;
    -- local loginResult = PlatformLogic.loginResult;
    -- loginResult.IsYueKa = data.IsYueKa;
    -- loginResult.YueKatime = data.YueKatime;
    -- loginResult.VIPLevel = data.VIPLevel;
    -- if data.IsYueKa == 1 then
    --     local layer = self:getChildByName("YuekaLayer");
    --     if layer then
    --         layer:refreshYuekaLayer();
    --     end
    --     if PlatformLogic.loginResult.IsYueKa == 1 then
    --         self.Text_name:setColor(cc.c3b(255,0,0))
    --     end
    -- end
    -- local flag = false;
    -- if  data.VIPLevel > 0 then
    --     for i=1,data.VIPLevel do
    --         if data.IsGetVip[i] == 0 then
    --             flag = true;
    --         end
    --     end

    --     if flag == true then
    --         if self.VipTipbg  and not tolua.isnull(self.VipTipbg) then
    --             self.VipTipbg:setVisible(true);
    --         else
    --             self.VipTipbg = ccui.ImageView:create("common/mailtip.png")
    --             self.VipTipbg:setPosition(cc.p(70,65));
    --             if self.Button_vip then
    --                 self.Button_vip:addChild(self.VipTipbg);
    --             end
    --         end
    --     else
    --         if self.VipTipbg and not tolua.isnull(self.VipTipbg) then
    --             self.VipTipbg:setVisible(false);
    --         end
    --     end
    -- end
end

function HallLayer:postHttpHead()
     -- //上传图像
    -- //存储图片
    local storePath = cc.FileUtils:getInstance():getWritablePath().."headupload.png";
    HeadManager:postHttp(storePath, function(result, response)
        if result == true then
            luaPrint("上传头像成功");
        else
            luaPrint("上传头像失败");
        end
      end);    
end

function HallLayer:initGCloudVoice()
    if device.platform ~= "windows" then
        -- //腾讯语音
        local openIDS;
        openIDS = globalUnit.m_userID; --//玩家唯一标识
        openIDS = openIDS..os.time();
        onUnitedPlatformInitGCloudSDK(GameConfig.GCLOUD_GAME_ID, GameConfig.GCLOUD_GAME_KEY, openIDS);
    end
end

function HallLayer:initMusic()
    local userDefault = cc.UserDefault:getInstance();

    audio.isPlaySound = userDefault:getBoolForKey(CLOSE_SOUND_TEXT, true);

    --effect
    local volume = userDefault:getIntegerForKey(SOUND_VALUE_TEXT, 100);

    if audio.isPlaySound ~= true then
        volume = 0;       
    end

    audio.setSoundsVolume(volume/100);

    --music
    volume = userDefault:getIntegerForKey(MUSIC_VALUE_TEXT, 100);
    if self.createType == nil then
        playMusic("sound/audio-login.mp3",true)
    end
    
    audio.setMusicVolume(volume/100);
    
    if volume <= 0 then
        audio.pauseMusic();
    end
end

--按钮特效添加
function HallLayer:addEffect()
    local winSize = cc.Director:getInstance():getWinSize();

    -- local skeleton_animation = createSkeletonAnimation("beijing","platform/effect/beijing.json", "platform/effect/beijing.atlas");
    -- skeleton_animation:setPosition(winSize.width/2,winSize.height/2);
   
    -- skeleton_animation:setAnimation(1,"beijing", true);
    -- skeleton_animation:setLocalZOrder(0)
    -- self.Image_bg:addChild(skeleton_animation);
    
    -- skeleton_animation = createSkeletonAnimation("ding","platform/effect/ding.json", "platform/effect/ding.atlas");
    -- skeleton_animation:setPosition(winSize.width/2,winSize.height-80)
    -- skeleton_animation:setAnimation(1,"ding", true);
    -- skeleton_animation:setLocalZOrder(100)
    -- self.Image_biaoti:addChild(skeleton_animation);

    -- local emitter1 = cc.ParticleSystemQuad:create("platform/buyu/qipao/qipao.plist")  
    -- emitter1:setAutoRemoveOnFinish(true);    --设置播放完毕之后自动释放内存   
    -- emitter1:setPosition(cc.p(winSize.width/2,winSize.height/2));
    -- emitter1:setLocalZOrder(10);
    -- self:addChild(emitter1,102);

    -- local size = self.Button_yueka:getContentSize();

    -- local btns = {self.Button_yueka,self.Button_share,self.Button_paotai,self.Button_role,self.Button_mail,self.Button_task,self.Button_bank};
    -- addSkeletonAnimation("tubiaotexiao", "platform/effect/tubiaotexiao.json", "platform/effect/tubiaotexiao.atlas");

    -- for k,v in pairs(btns) do
    --     skeleton_animation = createSkeletonAnimation("tubiaotexiao", "platform/effect/tubiaotexiao.json", "platform/effect/tubiaotexiao.atlas");
    --     skeleton_animation:setPosition(size.width/2,size.height*0.75)
    --     skeleton_animation:setAnimation(1,"tubiaotexiao", true);
    --     skeleton_animation:setLocalZOrder(100)
    --     v:addChild(skeleton_animation);
    -- end
end

function HallLayer:onClickCreateRoom()
    cc.UserDefault:getInstance():setIntegerForKey(USERDEFAULT_CHOOSE_GAME, 1);
    
    local layer = NewCreateRoomLayer:create();

    if layer then
        self.curRoomMode = RoomType.NormalRoom;
        layer:setCreateRoomCallBack(function(param) self:createGameEvent(param); end);
        layer:setMatchRoomCallBack(function() self:matchGameEvent(); end);
        layer:setTag(2017);

        self.view:addChild(layer);
    end
end

--代开房
function HallLayer:onClickOpenRoom()
    cc.UserDefault:getInstance():setIntegerForKey(USERDEFAULT_CHOOSE_GAME, 1);
    local layer = OpenRoomLayer:create();

    if layer then
        self.curRoomMode = RoomType.DaiKaiRoom;
        layer:setCreateRoomCallBack(function(param) self:createGameEvent(param); end);
        layer:setMatchRoomCallBack(function() self:matchGameEvent(); end);
        layer:setTag(2017);

        self.view:addChild(layer);
    end
end

--请求任务列表
function HallLayer:sendTaskReq()
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
   
    -- PlatformLogic:send(PlatformMsg.MDM_TASK,PlatformMsg.ASS_GP_GET_TASKLIST,msg,PlatformMsg.MSG_P_GETTASKLIST)--获取邮件列表   
end

--一键领取
function HallLayer:onClickReceiveAll()
    -- self.TaskList = {};

    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- msg.TaskID = 0;
    -- PlatformLogic:send(PlatformMsg.MDM_TASK,PlatformMsg.ASS_GP_UPDATE_TASK,msg,PlatformMsg.MSG_P_UPDATETASKLIST)  
end

function HallLayer:onClickReceive(taskid)
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- msg.TaskID = taskid;
   
    -- PlatformLogic:send(PlatformMsg.MDM_TASK,PlatformMsg.ASS_GP_UPDATE_TASK,msg,PlatformMsg.MSG_P_UPDATETASKLIST)  
end

--领取结果
function HallLayer:RecTaskRes(event)
    -- local data = event.data;
    -- local code = event.code;
    -- self.TaskList = {};

    -- if data.ret == 0 then
    --     if data.score > 0 then
    --         GamePromptLayer:create():showPrompt(GBKToUtf8("领取成功,奖励已发放！"));
    --         self:sendTaskReq();
    --         self:refreshUserGold();
    --     else
    --         GamePromptLayer:create():showPrompt(GBKToUtf8("领取失败"));  
    --     end
    -- else
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("领取失败"));  
    -- end
end

function HallLayer:GetTaskList(event)
    -- if self.TaskList == nil then
    --     self.TaskList = {};
    -- end
    -- local code = event.code;
    -- local data = event.data;
    -- if code == 0 then
    --     table.insert(self.TaskList, data);
    -- elseif code == 1 then
    --     local layer = self:getChildByName("TaskLayer")
    --     if layer then
    --         layer:updateTastLlist(self.TaskList);
    --     end
	
    --     local count = 0
    --     for i,v in ipairs(self.TaskList) do
    --         if v.Task ==1 then
    --             count = count +1;
    --         end
    --     end

    --     if self.Tasknewbg then
    --         self.Tasknewbg:setVisible(count ~= 0)
    --     end
	
    --     if count == 0 then
    --         count = "";
    --     end

    --     if self.TaskAtlnum then
    --         self.TaskAtlnum:setString(count);
    --     end

    --     self.TaskList = {};
    -- else
    --     luaPrint(event, "GetTaskList error");
    -- end
end

function HallLayer:onClickBtn(sender)
    local name = sender:getName();

    local layer = nil;

    if name == "Button_help" then
        layer = HelpLayer:create();
    elseif name == "Button_set" then
        layer = SetLayer:create();
        layer:setScale(1.1)
    elseif name == "Button_exit" then
        layer = ExitLayer:create();
        layer:setScale(1.1)
    elseif name == "Button_role" then
        layer = OpenRoleLayer:create();
        layer:setName("OpenRoleLayer");
    elseif name == "Button_honePage" then
        self:onClickHomePage();
    elseif name == "Button_notice" then
        layer = require("layer.popView.NoticeLayer"):create()
    elseif name == "Button_share" then
        layer = ActivityLayer:create();
        layer:setName("ActivityLayer");
    elseif name == "Button_mail" then
        layer = MailLayer:create();
        layer:setScale(1.1)
    elseif name == "Button_kefu" then
        self:onClickKefu();
    elseif name == "headBtn" then
        layer = require("layer.popView.UserInfoLayer"):create()
    elseif name == "Button_laba" then
        layer = WorldMsgLayer:create();
        layer:setCallBack(function(worldmsg) self:sendLabaMessage(worldmsg); end)
        layer:setName("WorldMsgLayer")
    elseif name == "Button_yueka" then
        layer = YuekaLayer:create();
        layer:setName("YuekaLayer")
    elseif name == "Button_task" then
        layer = TaskLayer:create();
        self:sendTaskReq()
        layer:setRecAllCallBack(function() self:onClickReceiveAll(); end)
        layer:setRecCallBack(function(taskid) self:onClickReceive(taskid); end)
        layer:setName("TaskLayer")
    elseif name == "Button_xinshoulibao" then
        layer = SignLayer:create()
    elseif name == "Button_more" then
        self:sliderHideBtns();
    elseif name == "Button_shop" or name == "Button_huafei" then
        self:onClickShop();
    elseif name == "shouchonglibao" then
        layer = ShouchongLayer:create();
        layer:setName("ShouchongLayer");
    elseif name == "match" then
        layer = MatchLayer:create();
    elseif name == "Button_vip" then
        layer = VipLayer:create(); 
        layer:setName("VipLayer");
    elseif name == "Button_paotai" then
        if roleData ~= nil then
            layer = PaotaiLayer:create(roleData.Score);
            layer:setName("PaotaiLayer");
        end
    elseif name == "Button_jiujijin" then
        --layer = require("layer.popView.NoticeLayer"):create()
        self:dealMoney()
    elseif name == "Button_copy" then
        -- if copyToClipBoard(GameConfig.serverVersionInfo.androidUrl) then
        --     addScrollMessage("网址复制成功")
        -- end
        layer = require("layer.popView.activity.duobao.LuckyLayer"):create()
    elseif name == "Button_sign" then
        showSign(1)
    elseif name == "Button_shantui" then
        openWeb(SettlementInfo:getConfigInfoByID(serverConfig.diaoqianUrl))
    end

    if layer then
        display.getRunningScene():addChild(layer);
    end
end

function HallLayer:onClickFk()

end

function HallLayer:onClickKefu()

end

function HallLayer:onClickHomePage()

end

--金币房
function HallLayer:onClickGoldRoom(gameName)
    local layer = CreateGoldRoomLayer:create(gameName);

    if layer then
        self.curRoomMode = RoomType.JinBiRoom;
        layer:setMatchRoomCallBack(function() self:matchGameEvent(); end);
        layer:setTag(2017);
        layer:setLocalZOrder(layerZorder);

        self:addChild(layer);
    end
end

function HallLayer:onClickAddRoom(sender)
    local tag = sender:getTag();

    if tag == CREATE_ROOM_TAG then
        self.addRoomLayer = JoinRoomLayer:create();
        self.view:addChild(self.addRoomLayer);
        self.addRoomLayer:setJoinRoomCallback(function(roomID) self:joinRoomByID(roomID); end)
    elseif tag == BACK_ROOM_TAG then
        -- //查询玩家是否在游戏中
        self.m_bIsClickBackRoom = true;
        local msg = {};
        -- msg.iUserID = PlatformLogic.loginResult.dwUserID;
        -- PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_GET_ROOM, msg, PlatformMsg.MSG_GP_C_USE_ROOM_KEYINFO);
    end
end

function HallLayer:changeToAddRoom()
    if self.Button_joinRoom then
        self.Button_joinRoom:loadTextures(SPRITE_ADD_ROOM_OFF, SPRITE_ADD_ROOM_ON);
        self.Button_joinRoom:setTag(CREATE_ROOM_TAG);
        self.Button_joinRoom:setTouchEnabled(true);
    end
end

function HallLayer:changeToBackRoom()
    if self.Button_joinRoom then
        self.Button_joinRoom:loadTextures(SPRITE_BACK_ROOM_OFF, SPRITE_BACK_ROOM_ON);
        self.Button_joinRoom:setTag(BACK_ROOM_TAG);
        self.Button_joinRoom:setTouchEnabled(true);
    end
end

function HallLayer:stopCheckNet()
    -- if self.updateForCheck then
    --     self:stopAction(self.updateForCheck);
    --     self.updateForCheck = nil;
    -- end
end

function HallLayer:startCheckNet()
    if self.updateForCheck then
        self:stopAction(self.updateForCheck);
        self.updateForCheck = nil;
    end

    globalUnit.m_connectCount = 0

    -- dispatchEvent("requestGameList")
    -- MailInfo:sendMailListInfoRequest()

    self.updateForCheck = schedule(self, function() self:updateForCheckOnline(); end, 4)
end

function HallLayer:updateForCheckOnline()
    if globalUnit.isEnterGame == true and display.getRunningScene():getChildByTag(1421) then
        return
    end

    if globalUnit.isaccountQuit then
        return
    end

     -- //其次检测大厅
    if not PlatformLogic:isConnect() and globalUnit.m_connectCount > globalUnit.m_reConnectMaxCount then
        if self.updateForCheck then
            self:stopAction(self.updateForCheck);
            self.updateForCheck = nil;
        end

       local prompt = GamePromptLayer:create();
        prompt:showPrompt(GBKToUtf8("网络断开连接"));
        prompt:setBtnClickCallBack(
            function ()
                Hall.startGame();
            end
        );
    elseif not PlatformLogic:isConnect() then
        if globalUnit.m_gameConnectState ~= STATE.PLATFORM_STATE_CONNECTING then
            self:onPlatformDisConnectCallback("",function() onEnterForeground(); self:startCheckNet() end);
        else
            local node = display.getRunningScene():getChildByTag(1421);
            if node == nil then
                self:onPlatformDisConnectCallback("",function() onEnterForeground(); self:startCheckNet() end);
            end
        end
    elseif PlatformLogic:isConnect() then
        luaPrint("platfrom send self.m_iHeartCount = "..self.m_iHeartCount)
        if self.m_iHeartCount > self.m_maxHeartCount then
            self.m_iHeartCount = 0;
            uploadInfo("netheartDisConnect","心跳收到断网状态 ="..logInfo)
            self:onPlatformDisConnectCallback("",function() onEnterForeground(); self:startCheckNet() end);
            -- performWithDelay(display.getRunningScene(),function() luaPrint("大厅心跳断线事件")  luaPrint(a..b) end,1)
        else
            PlatformLogic:sendHeart();
            self:checkGameList();
            self.m_iHeartCount = self.m_iHeartCount + 1;
        end
    end
end

function HallLayer:I_P_M_Heart()
    luaPrint("platfrom rece self.m_iHeartCount = "..self.m_iHeartCount)
    if self.m_iHeartCount > 0 then
        self.m_iHeartCount = self.m_iHeartCount - 1;
    else
        self.m_iHeartCount = 0;
    end
end

function HallLayer:onPlatformDisConnectCallback(message,callback)
    if globalUnit.isEnterGame == true then
        return
    end

    if globalUnit.isaccountQuit == true then
        return
    end

    -- //断线直接重连，每秒1次，10次后回到登陆界面
    local node = display.getRunningScene():getChildByTag(1421);
    if node then
        return;
    end

    if self.updateForCheck then
        self:stopAction(self.updateForCheck);
        self.updateForCheck = nil;
    end

    if callback == nil then
        callback = function() onEnterForeground(); self:startCheckNet() end;
    end

    local prompt = GameRelineLayer:create(callback);
    prompt:setTag(1421);
    display.getRunningScene():addChild(prompt, gameZorder+1000);
    prompt:sureRelinePlatform();
end

function HallLayer:createGameEvent(param)
    local iCreateID = param.nCreateId;
    local iRule = param.nRuleId;
    local bAAFanKa = param.bAAFanKa;
    -- luaDump(param)

    if iCreateID == 0 then
        local layer = GamePromptLayer:create();
        layer:showPrompt(GBKToUtf8("没有局数选择，无法创建房间"));
        layer:setBtnClickCallBack(function() 
            local layer = self.view:getChildByTag(2017);

            if layer then
                layer:delayCloseLayer();
            end
         end)
        return;
    end

    local iCost = RoomInfoModule:getCreateRoomCost(iCreateID);

    if iCost <= -1 then
        luaPrint("error --------- iCreateID = "..iCreateID.." , iCost = "..iCost);
        local layer = GamePromptLayer:create();
        layer:showPrompt(GBKToUtf8("局数选择错误，无法创建房间"));
        layer:setBtnClickCallBack(function() 
            local layer = self.view:getChildByTag(2017);

            if layer then
                layer:delayCloseLayer();
            end
         end)
        return;
    end

    local LogonResult = PlatformLogic.loginResult;

    local playerCount = 0;
    local nameId = GameCreator:getCurrentGameNameID();
    nameId = tonumber(nameId);

    if nameId == GAME_ERREN_ID then
        playerCount = 2
    elseif nameId == GAME_SANREN_ID then
        playerCount = 3
    elseif nameId == GAME_SIREN_ID then
        playerCount = 4
    elseif nameId == GAME_WUREN_ID then
        playerCount = 5
    elseif nameId == GAME_LIUREN_ID then
        playerCount = 6;
    elseif nameId == GAME_CHUJI_ID or nameId == GAME_ZHONGJI_ID or nameId == GAME_GAOJI_ID then
        playerCount = 6;
    end

    local roomKey = 0;

    if bAAFanKa == true then
        roomKey = tonumber(LogonResult.iRoomKey) * playerCount;
    else
        roomKey = tonumber(LogonResult.iRoomKey);
    end

    luaPrint("roomKey = "..roomKey.." ,iCost = "..iCost.." LogonResult.iRoomKey = "..LogonResult.iRoomKey.." playerCount = "..playerCount)

    if roomKey < iCost then
        GamePromptLayer:create():showPrompt(GBKToUtf8("钻石数量不足！"));
        return;
    end

    local layer = self.view:getChildByTag(2017);

    if layer and self.curRoomMode ~= RoomType.DaiKaiRoom then
        layer:delayCloseLayer();
    end

    -- //设置规则
    self.m_nSelectCreateID = iCreateID;
    self.m_nGameRuleID = iRule;
    self.m_bAAFanKa = bAAFanKa;

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在创建房间,请稍后"), LOADING):removeTimer();
    -- //获取游戏列表
    RoomLogic:close();
    self._roomListLogic:stop();
    self._gameListLogic:start();
    self._roomListLogic:requestRoomList();
end

function HallLayer:selectDesk(data)
    local deskNo = data._usedata

    if self.gameDeskLayer then
        self.gameDeskLayer:clear();
        self.gameDeskLayer = nil;
    end

    -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在进入游戏,请稍后"), LOADING):removeTimer(10,function() 
    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在加载房间信息,请稍后"), LOADING):removeTimer(10,function() 
        if globalUnit.nowTingId > 0 then
            dispatchEvent("onRoomLoginError",1);--通知VIP界面
        end

        local nameId = GameCreator:getCurrentGameNameID()

        local a,b = Hall:getGameName(Hall:getGameNameByNameID(nameId))

        if a ~= nil and globalUnit.gameName ~= nil and (nameId == 40011000 or nameId == 40016000 or nameId == 40017000 or nameId == 40015000 or nameId == 40024000 or nameId == 40018000) then
            Hall:exitGame()
            addScrollMessage("房间信息加载失败，请重新加载")
        else
            addScrollMessage("进入游戏失败，请重新进入")
        end
    end);

    UserInfoModule:clear()

    self.gameDeskLayer = GameDesk:createDesk(RoomLogic:getSelectedRoom());
    -- //请求坐下
    local data = {};
    data.bDeskIndex = deskNo;
    data.bDeskStation = INVALID_DESKSTATION;
    luaDump(data,"请求坐下")
    RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION, RoomMsg.ASS_GR_USER_SIT, data, RoomMsg.MSG_GR_S_UserSit);--服务器主动坐下
end

function HallLayer:matchDesk(data)
    local deskNo = data._usedata

    if (GameCreator:getCurrentGameNameID() == 40021000 and display.getRunningScene():getChildByName("deskLayer")) or
        GamesInfoModule:isMatchMode() then
        if self.gameDeskLayer then
            self.gameDeskLayer:clear()
            self.gameDeskLayer = nil
        end

        self.gameDeskLayer = GameDesk:createDesk(RoomLogic:getSelectedRoom())
    end
end

--子游戏内请求房间列表
function HallLayer:requestRoomList()
    luaPrint("HallLayer:requestRoomList()")
    self._gameListLogic:stop();
    self._roomListLogic:stop();
    self._roomListLogic:requestRoomList();
end

function HallLayer:matchGameEvent(roomid)
    local func = function()
        RoomLogic:close()
        dispatchEvent("loginRoom")
        local a,b = Hall:getGameName(Hall:getGameNameByNameID(GameCreator:getCurrentGameNameID()))

        if a ~= nil and globalUnit.gameName ~= nil then
            Hall:exitGame()
        end

        if globalUnit.nowTingId > 0 then
            dispatchEvent("onRoomLoginError",1);--通知VIP界面
        end

        addScrollMessage("房间信息加载失败，请重新加载")
    end

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在加载房间信息,请稍后"), LOADING):removeTimer(10,func);

    local ret = true

    if type(roomid) == "number" then
        self.matchRoomID = roomid
    elseif type(roomid) == "userdata" then
        if type(roomid._usedata) == "number" then
            self.matchRoomID = roomid._usedata
            globalUnit.isTryPlay = not RoomInfoModule:isCashRoom(GameCreator:getCurrentGameNameID(),self.matchRoomID)
        elseif globalUnit.isEnterGame == true and type(roomid._usedata) == "table" then
            self.matchRoomID = roomid._usedata[1]
            if GamesInfoModule:isMatchMode() then
                LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在加载房间信息,请稍后"), LOADING):removeTimer(10,function() dispatchEvent("loginRoom") end)
            end
        elseif type(roomid._usedata) == "table" and roomid._usedata[2] == true then
            self.matchRoomID = roomid._usedata[1]
            globalUnit.isTryPlay = not RoomInfoModule:isCashRoom(GameCreator:getCurrentGameNameID(),self.matchRoomID)
            --LoadingLayer:removeLoading()
        else
            self.matchRoomID = roomid._usedata[1]
            ret = false
            local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),self.matchRoomID)

            -- if globalUnit.isTryPlay ~= true then
            if RoomInfoModule:isCashRoom(GameCreator:getCurrentGameNameID(),self.matchRoomID) then
                if gold == nil or gold <= 0 then
                    local msg = {}
                    msg.iNameID = GameCreator:getCurrentGameNameID()
                    msg.iRoomID = self.matchRoomID
                    PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GET_MIN_ROOM_KEY_NUM, msg, PlatformMsg.MSG_GP_MATCH_ROOM_MIN_ROOM_KEY)
                    return
                else
                    if PlatformLogic.loginResult.i64Money < gold then
                        if roomid._usedata[2] ~= 2 then--二人牛牛回大厅时，钱不够，无需弹
                            addScrollMessage("抱歉，您的金币低于入场最低限制"..string.format("%.2f",goldConvert(globalUnit.nMinRoomKey)).."，不能进入该游戏房间！")
                            showBuyTip()
                        end
                        return
                    end
                end

                if GamesInfoModule:isMatchMode() then
                    if globalUnit:getIsBackRoom() == true then
                        globalUnit.isDoudizhuBackRoom = false
                    end
                end
            end

            if GamesInfoModule:isMatchMode() then
                LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在加载房间信息,请稍后"), LOADING):removeTimer(10,function() dispatchEvent("loginRoom") end)
            end
        end
    end

    if ret then
        self.bMatchSearch = true
        luaPrint("匹配房间时检测是否在某个房间")
        local msg = {};
        msg.iUserID = PlatformLogic.loginResult.dwUserID
        PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_GET_ROOM, msg, PlatformMsg.MSG_GP_C_USE_ROOM_KEYINFO)
    else
        luaPrint("开始请求匹配---------- "..tostring(self.matchRoomID))

        RoomLogic:close();
        self._roomListLogic:stop();
        self._gameListLogic:start();
        self._roomListLogic:requestRoomList();
    end
end

function HallLayer:searchRoom(event)
    if self.m_bIsClickBackRoom == true or self.bMatchSearch == true then
        self:getRoomIDCallbackForEnter(event);
    else
        self:searchRoomCallback(event);
    end
end

function HallLayer:searchRoomCallback(event)
    local data = event.data;
    local handCode = event.code;
    if handCode == 0 then
        self.roomid = {};
        table.insert(self.roomid, math.floor(data.iRoomID / 10));
        table.insert(self.roomid, data.iRoomID % 10);
        table.insert(self.roomid, math.floor(data.iDeskID / 100));
        table.insert(self.roomid, math.floor((data.iDeskID % 100) / 10));
        table.insert(self.roomid, data.iDeskID % 10);
        table.insert(self.roomid, tonumber(data.szLockPass));

        if data.iRoomID ~= -1 then
            -- //从游戏中出来，若已在游戏中，按钮变成返回游戏。若登录进入，则直接进入游戏
            if globalUnit.isFirstTimeInGame == true then
                -- //直接通過密碼進入房間
                self:enterGameRoom();
            elseif globalUnit.isFirstTimeInGame == false then
                self:changeToBackRoom();
            end
        else
            -- //未在游戏中，按钮变成加入游戏
            self:changeToAddRoom();
        end
    else
        -- //按钮变成加入游戏
        self:changeToAddRoom();
    end
end

-- //点击返回房间，先查询玩家是否在房间中
function HallLayer:getRoomIDCallbackForEnter(event)
    local data = event.data;
    local handCode = event.code;

    self.m_bIsClickBackRoom = false;
    luaDump(event,"getRoomIDCallbackForEnter")
    if handCode == 0 then
        if not GamesInfoModule:findGameName(data.iNameID) then
            addScrollMessage("请等待上局游戏结束")
            LoadingLayer:removeLoading()
            dispatchEvent("loginRoom")
            return
        end

        if self.bMatchSearch == true then
            self.bMatchSearch = false

            self.roomid = {};
            table.insert(self.roomid, math.floor(data.iRoomID / 10));
            table.insert(self.roomid, data.iRoomID % 10);
            table.insert(self.roomid, math.floor(data.iDeskID / 100));
            table.insert(self.roomid, math.floor((data.iDeskID % 100) / 10));
            table.insert(self.roomid, data.iDeskID % 10);
            table.insert(self.roomid, tonumber(data.szLockPass));

            local layer = display.getRunningScene():getChildByName("deskLayer")
            local name = Hall:getCurGameName();
            local isDuizhan = false
            if name == "qiangzhuangniuniu" or name == "doudizhu" or name == "sanzhangpai" or name == "errenniuniu"
             or name == "ershiyidian" or name == "shidianban" or name == "dezhoupuke" or name == "shisanzhang" or name == "shisanzhanglq" then
                isDuizhan = true
            end 
            if isDuizhan and layer then
                if event.data.iDeskID == -1 and layer.isQuick == true then--二人牛牛快速开始 走匹配
                    layer.isQuick = nil 
                    local msg = {};
                    msg.dwUserID = PlatformLogic.loginResult.dwUserID
                    local cf = {
                     {"dwUserID","INT"},
                     {"iMatchType","INT"}
                    }
                    RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf)
                    return
                end
                if event.data.iDeskID == -1 then
                    dispatchEvent("selectDesk",layer.selectDeskNo)
                    layer.selectDeskNo = nil
                else
                    -- luaPrint("开始请求匹配-----22222----- "..tostring(self.matchRoomID))

                    -- RoomLogic:close();
                    -- self._roomListLogic:stop();
                    -- self._gameListLogic:start();
                    -- self._roomListLogic:requestRoomList();

                    -- RoomLogic:close()
                    layer.selectDeskNo = nil
                    globalUnit.isDoudizhuBackRoom = true
                    Hall.lastGame.step = 2
                    layer.isQuick = nil
                    self:enterGameRoom()
                end
            else
                if GamesInfoModule:isMatchMode(data.iNameID) and globalUnit.nowTingId == 0 then
                    if display.getRunningScene():getChildByName("mGameLayer") then
                        if RoomLogic:isConnect() then
                            local msg = {};
                            msg.dwUserID = PlatformLogic.loginResult.dwUserID
                            local cf = {
                             {"dwUserID","INT"},
                             {"iMatchType","INT"}
                            }
                            RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf)
                        else
                            luaPrint("开始请求匹配-----222226666----- "..tostring(self.matchRoomID))

                            RoomLogic:close();
                            self._roomListLogic:stop();
                            self._gameListLogic:start();
                            self._roomListLogic:requestRoomList();
                        end
                    else
                        local prompt = GamePromptLayer:create()
                        prompt:showPrompt("您还在其它游戏中，是否立刻返回该游戏?",true)
                        prompt:setAutoClose(4)
                        prompt:setBtnClickCallBack(function()
                            globalUnit:setIsBackRoom(true)
                            Hall:setHallBackRoom(data.iNameID)
                            GameCreator:setCurrentGame(data.iNameID)
                            self:enterGameRoom()
                        end,function()
                            dispatchEvent("roomLoginFail");
                        end)
                    end
                else
                    if data.iNameID ~= 40010000 and data.iNameID ~= 40010004 then --捕鱼不提示
                        if globalUnit.isNoTipBack ~= true then
                            local prompt = GamePromptLayer:create()
                            prompt:showPrompt("您还在其它游戏中，是否立刻返回该游戏?",true)
                            prompt:setAutoClose(4)
                            prompt:setBtnClickCallBack(function()
                                globalUnit:setIsBackRoom(true)
                                Hall:setHallBackRoom(data.iNameID)
                                GameCreator:setCurrentGame(data.iNameID)
                                self:enterGameRoom()
                            end,function()
                                dispatchEvent("roomLoginFail");
                            end)
                        else
                            globalUnit.isNoTipBack = false
                            globalUnit:setIsBackRoom(true)
                            Hall:setHallBackRoom(data.iNameID)
                            GameCreator:setCurrentGame(data.iNameID)
                            self:enterGameRoom()
                        end
                    end
                end
            end
            dispatchEvent("loginRoom")
        else
            globalUnit:setIsBackRoom(false)
            if GamesInfoModule:isMatchMode() then
                if globalUnit.isEnterGame == true then
                    local msg = {};
                    msg.dwUserID = PlatformLogic.loginResult.dwUserID
                    local cf = {
                     {"dwUserID","INT"},
                     {"iMatchType","INT"}
                    }
                    RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf)
                else
                    Hall:selectedGame(Hall:getCurGameName())--斗地主特殊
                end
            else
                self:enterGameRoom()
            end
        end
    else
        globalUnit.isNoTipBack = false
        globalUnit:setIsBackRoom(false)
        -- //避免特殊情况，点击返回按钮后，状态恢复为加入房间
        if self.bMatchSearch == true then
            -- if GameCreator:getCurrentGameNameID() == 40023000 then
            --     if globalUnit.isEnterGame == true then
            --         local msg = {};
            --         msg.dwUserID = PlatformLogic.loginResult.dwUserID
            --         local cf = {
            --          {"dwUserID","INT"}
            --         }
            --         RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf)
            --     else
            --         Hall:selectedGame(Hall:getCurGameName())--斗地主特殊
            --     end
            -- else
                self.bMatchSearch = false

                 local a,b = Hall:getGameName(self.gameName)
                if globalUnit.gameName ~= nil and a ~= nil and Hall.lastGame == nil then
                    Hall:selectedGame(self.gameName)
                else
                    local layer = display.getRunningScene():getChildByName("deskLayer")
                    local name = Hall:getCurGameName();
                    local isDuizhan = false
                    if name == "qiangzhuangniuniu" or name == "doudizhu" or name == "sanzhangpai" or name == "errenniuniu"
                     or name == "ershiyidian" or name == "shidianban" or name == "dezhoupuke" or name == "shisanzhang" or name == "shisanzhanglq" then
                        isDuizhan = true
                    end
                    if isDuizhan and layer then
                        luaPrint("二人牛牛快速开始匹配 layer.isQuick = "..tostring(layer.isQuick))
                        if layer.isQuick == true then
                            layer.isQuick = nil
                            local msg = {};
                            msg.dwUserID = PlatformLogic.loginResult.dwUserID
                            local cf = {
                             {"dwUserID","INT"},
                             {"iMatchType","INT"}
                            }
                            RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf)
                            return
                        end
                    elseif display.getRunningScene():getChildByName("mGameLayer") and RoomLogic:isConnect() then
                        local msg = {};
                        msg.dwUserID = PlatformLogic.loginResult.dwUserID
                        local cf = {
                         {"dwUserID","INT"},
                         {"iMatchType","INT"}
                        }
                        RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_BEGIN_MATCH_ROOM, msg, cf)
                        return
                    end

                    luaPrint("开始请求匹配-----111111----- "..tostring(self.matchRoomID))

                    RoomLogic:close();
                    self._roomListLogic:stop();
                    self._gameListLogic:start();
                    self._roomListLogic:requestRoomList();
                end
                
            -- end
        else
            self:changeToAddRoom();
        end
    end
end

function HallLayer:requestGameRoomTimerCallBack()
    local ret = self._gameListLogic:requestGameList()
    if ret == false then
        if self.Image_bg:getChildByName("gameList") then
            return
        end
    elseif ret == 1 then
        -- dispatchEvent("requestGameListSuccess")
        if self.createType == nil then
            self:showGameListView()
        else
            self:onPlatformGameListCallback(true,"获取游戏列表成功")
        end
    elseif ret == true then
        self._gameListLogic:start()
    end
end

function HallLayer:onPlatformGameListCallback(success, message)
    self:showGameListView();

    if success then
        luaPrint("游戏列表获取成功");
        if GameCreator:getRegistGameCount() >= 1 then
            if self.createType == nil then
                if self.updateCheckGameList then
                    self:stopAction(self.updateCheckGameList);
                    self.updateCheckGameList = nil;
                end
            else
                -- MatchInfo:sendMatchListInfoRequest();
                if self.createType == nil or self.loginRoomid == nil then
                    return;
                end

                local roomid = {};

                table.insert(roomid, math.floor(self.loginRoomid.iRoomID / 10));
                table.insert(roomid, self.loginRoomid.iRoomID % 10);
                table.insert(roomid, math.floor(self.loginRoomid.iDeskID / 100));
                table.insert(roomid, math.floor((self.loginRoomid.iDeskID % 100) / 10));
                table.insert(roomid, self.loginRoomid.iDeskID % 10);
                table.insert(roomid, tonumber(self.loginRoomid.szLockPass));
                self.loginRoomid = nil

                self:enterGameRoomByPwd(roomid);
            end
        else
            self._gameListLogic:stop();
            self._roomListLogic:start();
            self._roomListLogic:requestRoomList();
        end
    else
        GamePromptLayer:create():showPrompt(message);
    end
end

function HallLayer:receiveMatchListInfo(data)
    -- if self.createType == nil then
    --     return;
    -- end

    -- local data = data._usedata;

    -- self.matchListInfo = data;

    -- local roomid = {};

    -- table.insert(roomid, math.floor(self.loginRoomid.iRoomID / 10));
    -- table.insert(roomid, self.loginRoomid.iRoomID % 10);
    -- table.insert(roomid, math.floor(self.loginRoomid.iDeskID / 100));
    -- table.insert(roomid, math.floor((self.loginRoomid.iDeskID % 100) / 10));
    -- table.insert(roomid, self.loginRoomid.iDeskID % 10);
    -- table.insert(roomid, tonumber(self.loginRoomid.szLockPass));

    -- local matchID = -1;
    -- for i,v in ipairs(data) do
    --     if v.RoomID == self.loginRoomid.iRoomID then
    --         matchID = v.MatchID;
    --         break;
    --     end
    -- end

    -- if matchID ~= -1 then
    --     globalUnit:setIsEnterRoomMode(2);
    --     GameCreator:setCurrentGame(40020000);
    --     globalUnit:setEnterGameMatchID(matchID);
    --     self:enterGameRoomByPwd(roomid);
    -- else
    --     Hall.enterPlatform();
    -- end
end

function HallLayer:receiveExitCreateRoom(data)
    if data then
        data = data._usedata
    end

    if data == nil then
        if not isHaveGameListLayer() and self.createType == nil and not LoginLayer:getInstance()  then
            -- self:resetPlatformViewPos()
            -- self:playPlatformEnterEffect()
        end
    elseif data == 1 then
        performWithDelay(self,function() 
        self:resetPlatformViewPos()
        self:playPlatformEnterEffect() 
        end,0.05)
    end
end

function HallLayer:onPlatformGameUserCountCallback(Id, count)

end

-- //进行匹配房间
function HallLayer:onPlatformMatchRoomGameCallBack(nNameID)
    -- //显示匹配状态界面
    if self.gameRoomLayer then
        self.gameRoomLayer:clear();
        self.gameRoomLayer = nil;
    end

    self.gameRoomLayer = GameRoom.new();
    self.gameRoomLayer:setCancelCallback(function()
        self:CancleMatchGame();
        end)
    self.gameRoomLayer:setOnCloseCallBack(function() 
        self._roomListLogic:stop();
        self:requestGameRoomTimerCallBack();

    end);
    self.gameRoomLayer:setOnMatchDeskCallBack(function(roomInfo, uDeskNo)
        if self.gameDeskLayer then
            self.gameDeskLayer:clear();
            self.gameDeskLayer = nil;
        end

        self.gameDeskLayer = GameDesk:createDesk(RoomLogic:getSelectedRoom());
        -- //请求坐下
        local data = {};
        data.bDeskIndex = uDeskNo;
        data.bDeskStation = INVALID_DESKSTATION;
        --RoomLogic:send(RoomMsg.MDM_GR_USER_ACTION, RoomMsg.ASS_GR_USER_SIT, data, RoomMsg.MSG_GR_S_UserSit);--服务器主动坐下
    end)
    
    self.gameRoomLayer.roomLogicBase:start();

    -- //随机选择一个房间登陆(这里客户端进行了适配)
    luaPrint("匹配 ---------- nNameID "..nNameID);
    local nRoomID = 0;

    if self.matchRoomID then
        nRoomID = self.matchRoomID;
    else
        nRoomID = RoomInfoModule:randARoom(nNameID);
    end

    self.gameRoomLayer.roomLogicBase:requestLogin(nRoomID);
    self.gameRoomLayer:setRoomID(nRoomID);
end

-- //游戏内
function HallLayer:onPlatformGameRoomListCallback(success, message)
    luaPrint("游戏内 onPlatformGameRoomListCallback")
    if success then
        -- //动态适配
        if RoomInfoModule:getRoomCount() == 0 then
            GamePromptLayer:create():showPrompt(GBKToUtf8("房间暂未开启，无法创建房间"));
            LoadingLayer:removeLoading();
            return;
        end

        local Room_key = {};
        Room_key.iNameID = GameCreator:getCurrentGameNameID();
        Room_key.iUserID = PlatformLogic.loginResult.dwUserID;
        Room_key.iRoomID = RoomInfoModule:randARoom(Room_key.iNameID);
        Room_key.iGameRoundId = self.m_nSelectCreateID;
        Room_key.iGameRule = self.m_nGameRuleID;
        Room_key.bAAFanKa = self.m_bAAFanKa;         --//是否AA制钻石
        if self.curRoomMode == RoomType.NormalRoom then
            PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_USE_ROOM_KEY, Room_key, PlatformMsg.MSG_GP_C_USE_ROOM_KEY);
        elseif self.curRoomMode == RoomType.DaiKaiRoom then--代开房
            luaPrint("创建代开房   PlatformMsg.ASS_CREATE_ROOM_FOR_OTHER")
            PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_CREATE_ROOM_FOR_OTHER, Room_key, PlatformMsg.MSG_GP_C_USE_ROOM_KEY);
        end
    else
        LoadingLayer:removeLoading();
        GamePromptLayer:create():showPrompt(message);
    end
end

function HallLayer:onPlatformRoomListCallback(success, message)
    luaPrint("房间列表获取回调")
    if success then
        self:createRoomListLayer();
    else
        luaPrint(message)
        LoadingLayer:removeLoading();
        GamePromptLayer:create():showPrompt(message);
    end
end

-- //创建房间列表层
function HallLayer:createRoomListLayer()
    luaPrint("创建房间列表层")
    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在加载房间信息中,请稍后"), LOADING):removeTimer(10);
    if self.gameRoomLayer then
        self.gameRoomLayer:clear();
        self.gameRoomLayer = nil;
    end

    self.gameRoomLayer = GameRoom.new();
    self.gameRoomLayer:setOnCloseCallBack(function() 
        self._roomListLogic:stop();
        self:requestGameRoomTimerCallBack();
    end);
    self.gameRoomLayer:setOnEnterDeskCallBack(function(roomInfo) 
        if self.Go_game == true then
            if self.gameDeskLayer then
                self.gameDeskLayer:clear();
                self.gameDeskLayer = nil;
            end

            self.gameDeskLayer = GameDesk:createDesk(RoomLogic:getSelectedRoom());
            self.gameDeskLayer.onCloseCallBack = function() end;
            local _deskLogic = self.gameDeskLayer:getRoomDeskLogic();

            local pwd = "";
            if self.room_Key_Data.szLockPass then
                -- pwd = self.room_Key_Data.szLockPass
            end
            luaPrint("pwd -------- "..pwd)
            if next(self.roomid) ~= nil then
                for k,v in pairs(self.roomid) do 
                    if k > 5 then
                        pwd = pwd..v;
                        luaPrint("pwd *******  "..pwd)
                    end
                end
            end
            luaPrint("pwd ~~~~~~~~~~ "..pwd)
            luaPrint("请求桌子坐下")
            -- luaDump(pwd)
            _deskLogic:requestSit(self.iDeskID, pwd);
        else
            self:createDeskListLayer(roomInfo);
        end
    end);

    self.gameRoomLayer.roomLogicBase:start();
    local roomid = 0;
    if self.room_Key_Data.iRoomID then
        roomid = self.room_Key_Data.iRoomID;
    end

    luaDump(self.roomid);

    local len = getTableLength(self.roomid);
    if len <= 6 and len > 0 then
        roomid = self.roomid[1] * 10 + self.roomid[2];
    end
    luaPrint("请求房间登陆 roomID "..roomid)
    
    globalUnit.selectedRoomID = roomid
    self.gameRoomLayer.roomLogicBase:requestLogin(roomid);
    self.gameRoomLayer:setRoomID(roomid);
end

function HallLayer:cancleMatchGame()
    --增加取消匹配游戏功能
    LoadingLayer:removeLoading()
    local prompt =  GamePromptLayer:create()
    prompt:showPrompt("匹配中，请稍后！")
    prompt:setBtnVisible(false,true)
    prompt:setBtnCanclePos()

    local spriteFrame = cc.SpriteFrameCache:getInstance()
    spriteFrame:addSpriteFrames( "platform/pipei/loading_saizi.plist" )  
    local spriteTest = cc.Sprite:createWithSpriteFrameName("MjLoading1.png")  
    --spriteTest:setAnchorPoint( 0.5, 0.5 )  
    spriteTest:setPosition( cc.p(640, 360 ) )  
    prompt:addChild( spriteTest )  
      
    local animation = cc.Animation:create()  
    for i=1, 8 do  
        local blinkFrame = spriteFrame:getSpriteFrame( string.format( "MjLoading%d.png", i ) )  
        animation:addSpriteFrame( blinkFrame )  
    end  
    animation:setDelayPerUnit( 0.1 )--设置每帧的播放间隔  
    animation:setRestoreOriginalFrame( true )--设置播放完成后是否回归最初状态  
    local action = cc.Animate:create(animation)  
    spriteTest:runAction( cc.RepeatForever:create( action ) )


    prompt:setBtnClickCallBack(function() luaPrint("确认") end,function() 
        RoomLogic:close();
        LoadingLayer:removeLoading()
    end);

end

function HallLayer:enterGameRoomByPwd(roomid)
    self.roomid = {};
    --生成房间密码
    local pwd = "";
    for k,v in pairs(roomid) do
        pwd = pwd..v;
        table.insert(self.roomid, v);
    end

    local msg = {};
    msg.nUserID = PlatformLogic.loginResult.dwUserID;
    msg.szLockPass = pwd;

    PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS,PlatformMsg.ASS_GP_DESK_LOCK_PASS,msg,PlatformMsg.MSG_GP_C_DESK_LOCK_PASS)

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, ("正在加入房间,请稍后"), LOADING):removeTimer(15,
        function() 
            if HallLayer:getInstance() and HallLayer:getInstance():isVisible() ~= true then
               HallLayer:getInstance():delayCloseLayer();
            end
        end
        );
end

function HallLayer:gameNotify(event)
    local data = event.data;
    local handCode = event.code;
    luaDump(event)
    luaPrint("gameNotify  ----- "..handCode)
    if handCode == PlatformMsg.ERR_DESK_LOCK_PASS_ERROR then
        -- if self.addRoomLayer ~= nil then
        --     self.addRoomLayer:onClickReset();
        --     self.roomid = {};
        --     cc.Device:vibrate(1);

        --     GamePromptLayer:create():showPrompt(GBKToUtf8("房间号不存在！"));
        --     LoadingLayer:removeLoading(self);
        -- else
        --     LoadingLayer:removeLoading(self);
        --     if globalUnit.isCheckWebLogin == true then
        --         GamePromptLayer:create():showPrompt(GBKToUtf8("房间已解散，不能加入！"));
        --     else
        --         GamePromptLayer:create():showPrompt(GBKToUtf8("您正在房间中，不能创建房间！"));
        --     end
        -- end
        GamePromptLayer:create():showPrompt(GBKToUtf8("游戏已结束，请重新开始！"));
        return false;
    elseif handCode == PlatformMsg.ERR_DESK_LOCK_NO_ENOUGH_ROOMKEY then
        GamePromptLayer:create():showPrompt(GBKToUtf8("您的金币不足，不能加入房间！"));
        return false;
    end

    self.m_desk_lock_pass = data;
    if self.m_desk_lock_pass.bAAFanKa and self.m_bFirstEnterRoom then --//AA制钻石房间
        luaPrint("AA制房卡提示");
        self.m_bFirstEnterRoom = false;
        self:initConfirmEnterRoomNotice();
        return true;
    else
        -- globalUnit:setIsBackRoom(true)
        self:onEnterGameRoom();
    end

    return true;
end

function HallLayer:FKGameNotify(event)
    local data = event.data;
    local code = event.code;

    if code == PlatformMsg.ERR_USE_ROOM_KEY_ERROR then
        LoadingLayer:removeLoading();
        GamePromptLayer:create():showPrompt(GBKToUtf8("创建失败！"));   --//一般是钻石数量不足
    elseif code == PlatformMsg.ERR_USE_ROOM_KEY_RECOME then
        self:getRoomIDCallback(socketMessage);
    else
        self.room_Key_Data.iDeskID = data.iDeskID;
        self.room_Key_Data.iNameID = data.iNameID;
        self.room_Key_Data.iRoomID = data.iRoomID;
        self.room_Key_Data.szLockPass = data.szLockPass;--//存储数据
        local str = self.room_Key_Data.iRoomID..self.room_Key_Data.iDeskID..self.room_Key_Data.szLockPass;
        
        local info = RoomInfoModule:findRoom(data.iRoomID);

        self.Go_game = true;

        if info then            
            local roomID = "";
		    for k,v in pairs(self.roomid) do
		        roomID = roomID..v;
		    end
		    globalUnit:setEnterRoomID(roomID)

            self.iDeskID = data.iDeskID;
            luaPrint("data.iNameID = "..data.iNameID)
            GameCreator:setCurrentGame(data.iNameID);
            self:onPlatformRoomListCallback(true, GBKToUtf8("获取成功"));
        else
            self:enterRoomFSCallBack(str);
        end
    end
end

function HallLayer:enterRoomFSCallBack(lockPass)
    -- //增加用户ID号，在AA制钻石的房间检测是否拥有足够的钻石进入
    local msg = {};
    msg.nUserID = PlatformLogic.loginResult.dwUserID;
    msg.szLockPass = lockPass;
    PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_DESK_LOCK_PASS, msg, PlatformMsg.MSG_GP_C_DESK_LOCK_PASS);
end

-- //初始化确认加入房间提示框
function HallLayer:initConfirmEnterRoomNotice()
    self.m_PromptLayer = GamePromptLayer:create();
    if self.m_PromptLayer then
        self.m_PromptLayer:setLocalZOrder(2000);

        self.m_PromptLayer:showPrompt(GBKToUtf8("该房间是AA制钻石，是否确认加入？"), true, true);

        self.m_PromptLayer:setBtnClickCallBack(function() self:confirmEnterRoom(); end, function() self:cancelEnterRoom(); end);
    end
end

-- //确认加入游戏
function HallLayer:confirmEnterRoom()
    self.m_PromptLayer = nil;
    self.Go_game = true;

    self:onEnterGameRoom();
end

-- //取消加入游戏
function HallLayer:cancelEnterRoom()   
    self.roomid = {}
    if self.addRoomLayer then
        self.addRoomLayer:removeSelf();
        self.addRoomLayer = nil;
    end    
    LoadingLayer:removeLoading();
    self.m_PromptLayer = nil;
end

-- //加入游戏
function HallLayer:onEnterGameRoom()
    -- //判断移除界面
    if self.addRoomLayer ~= nil then
        self.addRoomLayer:removeSelf();
        self.addRoomLayer = nil;
        LoadingLayer:removeLoading(self);
    end

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("房间加入中,请稍后"), LOADING);

    local roomID = "";
    for k,v in pairs(self.roomid) do
        roomID = roomID..v;
    end
    globalUnit:setEnterRoomID(roomID)

    self.iDeskID = self.m_desk_lock_pass.iDeskID;
    luaPrint("self.m_desk_lock_pass.iNameID = "..self.m_desk_lock_pass.iNameID)
    GameCreator:setCurrentGame(self.m_desk_lock_pass.iNameID);

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, ("正在加入房间,请稍后"), LOADING):removeTimer(15,
        function() 
            if HallLayer:getInstance() and HallLayer:getInstance():isVisible() ~= true then
               HallLayer:getInstance():delayCloseLayer();
            end
        end
        );

    self._gameListLogic:stop();
    self._roomListLogic:start();
    self._roomListLogic:requestRoomList();
end

function HallLayer:setRoomID(roomid)
    self.roomid = roomid;
end

function HallLayer:enterGameRoom()
    --生成房间密码
    local pwd = "";
    for k,v in pairs(self.roomid) do
        pwd = pwd..v;
    end

    local msg = {};
    msg.nUserID = PlatformLogic.loginResult.dwUserID;
    msg.szLockPass = pwd;

    luaDump(msg,"enterGameRoom")

    PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS,PlatformMsg.ASS_GP_DESK_LOCK_PASS,msg,PlatformMsg.MSG_GP_C_DESK_LOCK_PASS)

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, ("正在加入房间,请稍后"), LOADING):removeTimer(15,
        function()
            if HallLayer:getInstance() and HallLayer:getInstance():isVisible() ~= true then
               HallLayer:getInstance():delayCloseLayer();
            end
        end
        );
end

function HallLayer:joinRoomByID(roomID)
    self.m_bFirstEnterRoom = true;
    
    self.roomid = roomID;

    self:enterGameRoom();
end

function HallLayer:onClickShop()
    PlatformLogic:send(PlatformMsg.MDM_GP_CHARMEXCHANGE,PlatformMsg.ASS_GETLIST)
end

function HallLayer:exchangeList(event)
    -- luaDump(event)

    local layer = ShopLayer:create(event.data);
    layer:setName("ShopLayer")
    self:addChild(layer,100);
end

function HallLayer:getInforData()
    -- if globalUnit.isEnterGame ~= true then
        if PlatformLogic:isConnect() then
            local  msg = {};
            msg.dwUserID = PlatformLogic.loginResult.dwUserID;

            PlatformLogic:send(PlatformMsg.MDM_GP_USERINFO, PlatformMsg.ASS_GP_USERINFO_GET, msg, PlatformMsg.MSG_PROP_C_GETSAVED);
        end
    -- end
end

function HallLayer:refreshUserInfo(event)
    if event.data == nil then
        return;
    end

    luaDump(event,"刷新钻石大厅")
    PlatformLogic.loginResult.i64Bank = event.data.i64BankMoney;
    PlatformLogic.loginResult.i64Money = event.data.i64WalletMoney;
    PlatformLogic.loginResult.iLotteries = event.data.iLotteries;
    PlatformLogic.loginResult.nickName = event.data.szNickName

    --邮件服务器时间戳
    globalUnit.mail_time_stamp_sever = event.data.dwFascination
    if globalUnit.mail_time_stamp_local ~= globalUnit.mail_time_stamp_sever then
        MailInfo:sendMailListInfoRequest()
    end
    -- local layer = self:getChildByName("ShopLayer")
    -- if layer then
    --     layer:refreshUserQuan(PlatformLogic.loginResult.iLotteries);
    -- end

    self:setNumGold();
    -- self:refreshUserGold();
    self:setUserName()
end

function HallLayer:setNumGold()
    -- self.Text_gold:setText(FormatNumToString(goldConvert(PlatformLogic.loginResult.i64Money)));    
    -- self.Text_baoxiangui:setText(FormatNumToString(goldConvert(PlatformLogic.loginResult.i64Bank)))
    -- self.Text_huafei:setText(string.format("%.2f", PlatformLogic.loginResult.iLotteries))
end

function HallLayer:refreshUserMail()--请求邮件列表
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- PlatformLogic:send(PlatformMsg.MDM_GP_MAIL, PlatformMsg.ASS_GP_GET_MAILLIST, msg, PlatformMsg.MSG_P_GET_MAILLIST);
end

function HallLayer:refreshUserGold()----请求角色列表 刷新金币
     --请求角色列表
    -- local msg = {}
    -- msg.UserID =PlatformLogic.loginResult.dwUserID;
    -- PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_LOGON_PLAYER_LIST,msg,PlatformMsg.MSG_P_GET_PLAYERLIST)--获取角色列表
end

function HallLayer:setUserName(event)
    luaPrint("更新昵称");
    self.Text_name:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen));
    self.Clip_head:getChildByName("head"):initWithFile(getHeadPath(PlatformLogic.loginResult.bLogoID))

    --救济金的请求
    SettlementInfo:sendConfigInfoRequest(12)
end

function HallLayer:setNumFK(data)
    -- if type(data) == "table" then
    --     -- self.Text_gold:setText(FormatNumToString(data.i64WalletMoney));
    --     self.Text_zuanshi:setText(FormatNumToString(data.iRoomKey));
    -- else
    --     self.Text_zuanshi:setText(FormatNumToString(data));
    -- end
end

--回调大厅调用刷新房卡
function HallLayer:toCallUpdateRoomkey()
    luaPrint("刷新钻石")
    if device.platform ~= "windows" then
        self:stopActionByTag(11111);

        local delay1 = cc.DelayTime:create(1)
        local delay2 = cc.DelayTime:create(2)
        local delay3 = cc.DelayTime:create(3)
        local callback = cc.CallFunc:create(function () self:updateForRefreshRoomkey() end)
        local seq = cc.Sequence:create(delay1,callback,delay2,callback,delay3,callback);
        seq:setTag(11111);
        self:runAction(seq);
    end
end

--刷新更新房卡数据
function HallLayer:updateForRefreshRoomkey()
    self:getInforData()
end

function HallLayer:webLoginRoom()
    -- getSharedRoomInfo();

    -- if globalUnit.isCheckWebLogin == true then
    --     return;
    -- end

    -- if globalUnit.webRoomid ~= 0 and globalUnit.webRoomid ~= "" and globalUnit.webRoomid ~= nil then
    --     self:stopActionByTag(11111);
    --     globalUnit.isCheckWebLogin = true;
    --     local roomid = {};
    --     local str = tostring(globalUnit.webRoomid); 
    --     while true do
    --         local s = string.sub(str,1,1);
    --         table.insert(roomid, tonumber(s));

    --         if #str <= 1 then
    --             break;
    --         end

    --         str = string.sub(str, 2, -1);            
    --     end
    --     -- luaDump(roomid,"web")
    --     self:joinRoomByID(roomid);
    -- end
end

function HallLayer:GetRoleList(event)
    -- if self.roleList == nil then
    --     self.roleList = {};
    -- end
    -- self:sendIsJiuji();
    -- luaDump(event,"role")
    -- local code = event.code;
    -- local data = event.data;
    -- if code == 0 then
    --     table.insert(self.roleList, data);
    -- elseif code == 1 then
    --     for k,v in pairs(self.roleList) do
    --         if v.IsUse == true then
    --             roleData = v;
    --             PlatformLogic.loginResult.nickName = v.PlayerName;
    --             PlatformLogic.loginResult.i64Money = v.Score;
    --             if self.Text_name and self.Text_gold then
    --                 self.Text_name:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen));
    --                 self.Text_gold:setText(FormatNumToString(PlatformLogic.loginResult.i64Money))
    --             end
    --             self.AtlasLabel_lv.view:setString(":;."..v.PlayerLevel)
    --             local num = v.PlayerLevel;
    --             local point = 0;
    --             if num >= globalUnit:getLevelCount() then
    --                 point = 1;
    --             else
    --                 local sum = 0
    --                 for i=1,num+1 do
    --                     sum = sum + globalUnit:getExperienceByLevel(i);
    --                 end
    --                 local lexp = sum - v.Exper;
    --                 point = 1 - lexp/globalUnit:getExperienceByLevel(num + 1);
    --             end                
    --             if self.EXPProgress then
    --                 self.EXPProgress:setPercentage(point*78);
    --             end
    --             if self.expBody then
    --                 if num > 30 and num < 50 then
    --                     self.expBody:setTexture("jindutiao/jindu2.png");
    --                 elseif num >= 50 and num < 80 then
    --                     self.expBody:setTexture("jindutiao/jindu3.png");
    --                 elseif num >= 80 then  
    --                     self.expBody:setTexture("jindutiao/jindu4.png");  
    --                 end
    --             end
    --         end
    --     end

    --     if roleData ~= nil and self.rankLayer then
    --         self.rankLayer:refreshRankInfo(roleData)
    --     end
    --     local layer = self:getChildByName("PaotaiLayer");
    --     if roleData ~= nil and layer then
    --         layer:refreshPaotaiInfo(roleData)
    --     end
    --     self.roleList = {};
    -- else
    --     luaDump(event, "platform GetRoleList error");
    -- end
end

function HallLayer:GetMailList(event)
    -- if self.mailList == nil then
    --     self.mailList = {};
    -- end
    
    -- local code = event.code;
    -- local data = event.data;
    -- local count = 0;
    
    -- if code == 0 then
    --     table.insert(self.mailList, data);
    -- elseif code == 1 then
    --     for k,v in pairs(self.mailList) do
    --          if v.IsUse == false then 
    --             count = count + 1;
    --          end
    --     end
    --     self.mailList = {}
    --     --有未读邮件 显示标识 数量
    --     if count > 99 then
    --         count = 99;
    --     end

    --     if self.Atlnum then
    --         self.Atlnum:setString(count);
    --     end

    --     if self.newbg then
    --        self.newbg:setVisible(count > 0); 
    --     end
    -- else
    --     luaDump(event, "platform GetMailList error");
    -- end
end

function HallLayer:getIsJiujiResult(event)
    local code = event.code;
    local data = event.data;
    luaDump(data,"getIsJiujiResult");
    if data.ret == 0 then
        self.Button_jiujijin:setVisible(true);
    else
        self.Button_jiujijin:setVisible(false);
    end
    self:resetPopBtnsPos()
    -- globalUnit.jiujinum = data.JiuJiTimes;
    -- local layer = self:getChildByName("ActivityLayer")
    -- if layer then
    --     layer:setjiujiTime(data.JiuJiTimes)
    --     layer:setjiujibtn(data.ret == 0)
    -- end
end

function HallLayer:getJiujiResult(event)
    -- local code = event.code;
    -- local data = event.data;
    -- globalUnit.jiujinum = data.JiuJiTimes;
    -- if data.ret == 0 then
    --     if data.UserID == PlatformLogic.loginResult.dwUserID then
    --         self:refreshUserGold();
    --         local layer = self:getChildByName("ActivityLayer")
    --         if layer then
    --             layer:setjiujiTime(data.JiuJiTimes)
    --         end
    --     end
    --     local remainingCount = 2 - data.JiuJiTimes;
    --     if remainingCount < 0 then
    --         remainingCount = 0
    --     end

    --     Hall.showTips("成功领取救济金:"..data.Score.."金币,今日剩余"..remainingCount.."次");
    -- else
    --     -- Hall.showTips("救济金领取成功！");
    -- end
end

function HallLayer:TransRole(event)
    -- local data = event.data;
    -- local code = event.code;
    -- self.roleList = {};
    -- local msg = {};
    -- local myid = PlatformLogic.loginResult.dwUserID;
    -- msg.UserID = myid;

    -- if data.ret == 0 then
    --     if data.UserID == myid then
    --         self:sendIsJiuji();
    --         GamePromptLayer:create():showPrompt(GBKToUtf8("赠送成功"));
    --         self:refreshUserGold();
    --     elseif data.TargetUserID ==myid then
    --         self:refreshUserGold();
    --         GamePromptLayer:create():showPrompt(GBKToUtf8("您收到一个"..data.UserID.."赠送的角色"));
    --         self:refreshUserMail();
    --     end
    -- elseif data.ret == 1 then
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("必须保留一个角色！"));
    -- elseif data.ret == 2 then
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("对方用户ID不存在！"));
    -- elseif data.ret == 3 then
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("用户ID不存在！"));
    -- elseif data.ret == 4 then
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("角色正在被使用！"));
    -- elseif data.ret == 5 then
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("对方角色数量已达上限！"));
    -- elseif data.ret == 6 then
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("当前角色金币数量低于最低限额！"));        
    -- else
    --     GamePromptLayer:create():showPrompt(GBKToUtf8("赠送失败"));
    -- end
end

--用喇叭发送消息
function HallLayer:sendLabaMessage(worldmsg)
    -- if roleData ~= nil then
    --     local msg = {}
    --     msg.dwUserID = PlatformLogic.loginResult.dwUserID;
    --     msg.szMessage = roleData.PlayerName..":"..worldmsg;
    --     PlatformLogic:send(PlatformMsg.MDM_GP_PROP,PlatformMsg.ASS_PROP_BIG_BOARDCASE_BUYANDUSE,msg,PlatformMsg._TAG_BOARDCAST)          
    -- end
end

function HallLayer:checkGameList()
    if GamesInfoModule.isEnd ~= true then
        if GamesInfoModule:isGameListEmpty() then
            self:requestGameRoomTimerCallBack()
        end
    end
end

--存分
function HallLayer:saveExchangeResult(event)
    -- local text = "";
    -- luaDump(event,"兑换结果")
    -- if event.data.ret == 0 then
    --     text = "恭喜您操作成功！";
    --     local runningScene = display.getRunningScene();
    --     local layer = runningScene:getChildByName("banklayer")
    --     if layer then
    --         layer:refreshUserSaveInfo(event);
    --     end
    --     self:refreshUserGold();
    -- elseif event.data.ret == 1 then
    --     text = "用户ID不存在！";
    -- elseif event.data.ret == 2 then
    --     text = "角色ID不存在！";
    -- elseif event.data.ret == 3 then
    --     text = "金币不足！";
    -- elseif event.data.ret == 4 then
    --     text = "您正在游戏中！";       
    -- else
    --     text = "操作失败！"
    -- end

    -- GamePromptLayer:create():showPrompt(text);
end

function HallLayer:sendExchangeGold(ftype,value)--发送存取金币
    -- if roleData ~= nil then
    --     local msg = {};
    --     msg.UserID = PlatformLogic.loginResult.dwUserID;
    --     msg.PlayerID = roleData.PlayerID;
    --     msg.Score = value;

    --     if ftype == 1 then
    --         PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_GET_SCORE,msg,PlatformMsg.MSG_P_GET_SCORE) --角色取分
    --     else
    --         PlatformLogic:send(PlatformMsg.MDM_GP_PLAYER,PlatformMsg.ASS_GP_STORE_SCORE,msg,PlatformMsg.MSG_P_STORE_SCORE) --角色存分
    --     end
    -- end
end

--取分
function HallLayer:getExchangeResult(event)
    -- local text = "";
    -- luaDump(event,"兑换结果")
    -- if event.data.ret == 0 then
    --     text = "恭喜您操作成功！";
    --     local runningScene = display.getRunningScene();
    --     local layer = runningScene:getChildByName("banklayer")
    --     if layer then
    --         layer:refreshUserGetInfo(event);
    --     end
    --     self:refreshUserGold();
    -- elseif event.data.ret == 1 then
    --     text = "用户ID不存在！";
    -- elseif event.data.ret == 2 then
    --     text = "角色ID不存在！";
    -- elseif event.data.ret == 3 then
    --     text = "金币不足！";
    -- elseif event.data.ret == 4 then
    --     text = "您正在游戏中！";       
    -- else
    --     text = "操作失败！"
    -- end

    -- GamePromptLayer:create():showPrompt(text);
end

--发送喇叭结果
function HallLayer:showLabaResult(event)
    -- local code = event.code;
    -- local data = event.data;

    -- if data.ret == 0 then
    --     if data.UserID == PlatformLogic.loginResult.dwUserID then
    --         Hall.showTips("发送成功");
    --         self:refreshUserGold();
    --     end
    -- else
    --     Hall.showTips("发送失败");
    -- end

    -- if self:getChildByName("WorldMsgLayer") then
    --     self:getChildByName("WorldMsgLayer").isClick = false;
    -- end
end

--请求特惠列表
function HallLayer:sendTehuireq()
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- PlatformLogic:send(PlatformMsg.MDM_VIP, PlatformMsg.ASS_GP_GET_FavCompain, msg, PlatformMsg.MSG_P_GETFAVCOM);
end

--获取特惠列表
function HallLayer:GetTehuiList(event)
    -- if self.updateTehui then
    --     self:stopAction(self.updateTehui);
    --     self.updateTehui = nil;
    -- end
    -- if self.TehuiList == nil then
    --     self.TehuiList = {};
    -- end
    -- if self.fulinewbg then
    --     self.fulinewbg:setVisible(false);
    -- end
    -- local code = event.code;
    -- local data = event.data;
    -- if code == 0 then
    --     table.insert(self.TehuiList, data);
    -- elseif code == 1 then
    --     for i,v in ipairs(self.TehuiList) do
    --         if v.IsGet == 0 then
    --             globalUnit.isOpenfuliLayer = true;
    --             if self.fulinewbg then
    --                 self.fulinewbg:setVisible(true);
    --             end
    --         end
    --     end
        
    --     local layer = self:getChildByName("ActivityLayer")
    --     if layer then
    --         layer:updateTehuiLlist(self.TehuiList)
    --     end
    --     self.TehuiList = {};
    -- end
end

function HallLayer:createMobileBindLayer()
    local layer = require("game.MobileBindLayer"):create();
    layer:setName("MobileBindLayer");
    layer:setLocalZOrder(layerZorder);
    self:addChild(layer);
end

function HallLayer:GetCheckPhoneresult(event)
    local code = event.code;

    if code == 0 then
        PlatformLogic.loginResult.szMobileNo = globalUnit.tempPhone;
        Hall.showTips("绑定手机成功！奖励已发放！");
        self:refreshUserGold();
        local layer = self:getChildByName("MobileBindLayer");
        if layer then
            layer:delayCloseLayer();
            self:onClickBtn(self.Button_notice);
        end
    elseif code == 1 then
        Hall.showTips("未获取验证码！");
    elseif code == 2 then
        Hall.showTips("手机号已绑定！");
    elseif code == 3 then
        Hall.showTips("验证码已过期！");
    elseif code == 4 then
        Hall.showTips("验证码无效！");
    else
        Hall.showTips("绑定失败！");
    end
end

--获取物品配置
function HallLayer:sendGetGoodsConfig(id)
    local msg = {};
    msg.ID = id;
    PlatformLogic:send(PlatformMsg.MDM_CONFIG, PlatformMsg.ASS_GP_GET_CONFIG, msg, PlatformMsg.MSG_GP_GET_CONFIG);
end

--获取物品配置 1 全服发言价格
function HallLayer:getGoodSConfig(event)
    local code = event.code;
    local data = event.data;
    luaDump(data,"获取物品配置")
    if data.id == 1 then
        local layer = self:getChildByName("WorldMsgLayer");
        if layer then
            layer:refreshTip(data.val)
        end
    elseif data.id == 2 then
        local layer = self:getChildByName("OpenRoleLayer");
        local num = tonumber(data.val)
        if layer then
            if num then
                layer.minLimit = num;
            end
        end
    end
end

--获取是否首冲
function HallLayer:sendGetChongzhi()
    -- local msg = {};
    -- msg.UserID = PlatformLogic.loginResult.dwUserID;
    -- PlatformLogic:send(PlatformMsg.MDM_USERSCORE, PlatformMsg.ASS_GP_GET_SHOUCHONG, msg, PlatformMsg.MSG_GP_GET_SHOUCHONG);
end

--获取是否首冲
function HallLayer:getChongzhiResult(event)
    -- local code = event.code;
    -- local data = event.data;
    -- local winSize = cc.Director:getInstance():getWinSize();

    -- if self.Node_buy == nil then
    --     local node = cc.Node:create();
    --     node:setLocalZOrder(10);
    --     self.Image_bg:addChild(node);
    --     self.Node_buy = node;
    -- end

    -- if data.IsShouChong == 0 then
    --     local layer = self.Node_buy:getChildByName("shouchonglibao");
    --     if layer then
    --         return;
    --     end

    --     local btn = ccui.Widget:create();
    --     btn:setName("shouchonglibao");
    --     btn:setTouchEnabled(true);
    --     btn:setContentSize(cc.size(100,100));
    --     btn:setAnchorPoint(cc.p(0.5,0.5));
    --     btn:setPosition(cc.p(winSize.width*0.95,260));
    --     btn:setLocalZOrder(10)
    --     self.Node_buy:addChild(btn);
    --     btn:addClickEventListener(function(sender) self:onClickBtn(sender); end);

    --     skeleton_animation = createSkeletonAnimation("shouchongjiangli","shouchong/spine/shouchongjiangli.json", "shouchong/spine/shouchongjiangli.atlas");
    --     skeleton_animation:setPosition(50,50)
    --     skeleton_animation:setAnimation(2,"shouchongjiangli", true);
    --     btn:addChild(skeleton_animation);
        
    --     if not self.Node_buy:getChildByName("Button_xinshoulibao") then
    --         btn:setPositionY(150);
    --     else
    --         self:playPlatformEnterEffect();
    --     end
    -- elseif data.IsShouChong == 1 then
    --     local layer = self.Node_buy:getChildByName("shouchonglibao");

    --     if layer then
    --         layer:removeFromParent();
    --         Hall.showTips("充值成功，奖励已发放!")
    --     end

    --     local layer = self:getChildByName("ShouchongLayer");

    --     if layer then
    --         layer:removeFromParent();            
    --     end

    --     self:refreshUserGold();
    -- end
end

--斗地主
function HallLayer:onClickDdz(sender,isTip)
    local gameName = "bairenniuniu"

    sender.isHide = true
    self:createUpdateEvent(sender,gameName,isTip)
end

--捕鱼
function HallLayer:onClickBy(sender)
    local gameName = "fishing"

    sender.isHide = true
    self:createUpdateEvent(sender,gameName,isTip)
end

--多人
function HallLayer:onClickDr()
    local layer = require("layer.popView.DuoRenGameList"):create()
    layer:setName("dr")
    layer:setDownCallback(handler(self, self.createUpdateEvent))
    display.getRunningScene():addChild(layer)
end

--对战
function HallLayer:onClickDz()
    local layer = require("layer.popView.DuiZhanGameList"):create()
    layer:setName("dz")
    layer:setDownCallback(handler(self, self.createUpdateEvent))
    display.getRunningScene():addChild(layer)
end

function HallLayer:syncDownState(data)
    local data = data._usedata

    self:createUpdateEvent(data[1],data[2])
end

function HallLayer:createUpdateEvent(sender,gameName,isTip)
    threadCount = 2
    self.gameName = gameName
    if NO_UPDATE then
        local a,b = Hall:getGameName(gameName)
        if globalUnit.gameName == nil or a == nil then
            Hall:selectedGame(gameName)
        else
            self:requestSearchRoom()
        end
    else
        local updateInfo = UpdateManager:getDownLoadInfo(sender,gameName)
        luaDump(updateInfo,"检查更新")
        if updateInfo == nil then
            if isTip == nil then
                -- addScrollMessage("正在检查更新")
            end

            local len = 0
            for k,v in pairs(gameDownloadProgessTimer) do
                if v ~= nil and #v > 0 then 
                    len = len + 1;
                end
            end

            if len > 2 then
                addScrollMessage("已有游戏在下载中，请稍后")
                return
            end

            self:createProgessTimer(sender,gameName)
            UpdateManager:setDownloadListInfo({gameName,
                                              sender,
                                              function(finishNum,totalNum) self:updateDownloadProgress(gameName,finishNum,totalNum) end,
                                              function()end,
                                              function() Hall.closeTips() self:hideDownBtn(gameName) Hall:selectedGame(gameName) end,
                                              function(value) local temp = string.split(value,"_") self:updateUnZipProgress(gameName,tonumber(temp[1]),tonumber(temp[2])) end,})
            UpdateManager:updateDownLoadList(gameName,"isCanDown",true)
            UpdateManager:startDownload(gameName)
            -- self:updateUnNormalDeal(sender,gameName,"updateInfo == nil")
        else
            if updateInfo.downloadState == STATUEUNZIP_COMPLETE then--检查更新完毕
                sender:hide()
                local a,b = Hall:getGameName(gameName)
                if globalUnit.gameName == nil or a == nil then
                    Hall:selectedGame(gameName)
                else
                    self:requestSearchRoom()
                end
            elseif updateInfo.downloadState == STATUE_NODOWN then--未下载
                local len = 0
                for k,v in pairs(gameDownloadProgessTimer) do
                    if v ~= nil and #v > 0 then 
                        len = len + 1;
                    end
                end

                if len > 2 then
                    addScrollMessage("已有游戏在下载中，请稍后")
                    return
                end

                if isTip == nil then
                    addScrollMessage("正在检查更新")
                end
                self:createProgessTimer(sender,gameName)
                UpdateManager:setDownloadListInfo({gameName,
                                                   sender,
                                                   function(finishNum,totalNum) if not tolua.isnull(self) then self:updateDownloadProgress(gameName,finishNum,totalNum) end end,
                                                   function()end,
                                                   function() Hall.closeTips() if not tolua.isnull(self) then self:hideDownBtn(gameName) Hall:selectedGame(gameName)  end end,
                                                   function(value) local temp = string.split(value,"_") self:updateUnZipProgress(gameName,tonumber(temp[1]),tonumber(temp[2])) end,})
                UpdateManager:startDownload(gameName)
                -- self:updateUnNormalDeal(sender,gameName,"updateInfo.downloadState == STATUE_NODOWN")
            elseif updateInfo.downloadState == STATUE_WAITDOWN then--待下载
                if isTip == nil then
                    addScrollMessage("正在检查更新",0.5)
                end
                self:createProgessTimer(sender,gameName)
                UpdateManager:setDownloadListInfo({gameName,
                                                   sender,
                                                   function(finishNum,totalNum) if not tolua.isnull(self) then self:updateDownloadProgress(gameName,finishNum,totalNum) end end,
                                                   function()end,
                                                   function() Hall.closeTips() if not tolua.isnull(self) then self:hideDownBtn(gameName) end Hall:selectedGame(gameName) end,
                                                   function(value) local temp = string.split(value,"_") self:updateUnZipProgress(gameName,tonumber(temp[1]),tonumber(temp[2])) end,})
                -- self:updateUnNormalDeal(sender,gameName,"updateInfo.downloadState == STATUE_NODOWN")
            elseif updateInfo.downloadState == STATUE_HAVEUPDATE then
                local len = 0
                for k,v in pairs(gameDownloadProgessTimer) do
                    if v ~= nil and #v > 0 then 
                        len = len + 1;
                    end
                end

                if len > 2 then
                    addScrollMessage("已有游戏在下载中，请稍后")
                    return
                end
                luaPrint("有文件可以更新，直接下载")
                self:createProgessTimer(sender,gameName)
                UpdateManager:setDownloadListInfo({gameName,
                                                   sender,
                                                   function(finishNum,totalNum) if not tolua.isnull(self) then self:updateDownloadProgress(gameName,finishNum,totalNum) end end,
                                                   function()end,
                                                   function() Hall.closeTips() if not tolua.isnull(self) then self:hideDownBtn(gameName) end Hall:selectedGame(gameName) end,
                                                   function(value) local temp = string.split(value,"_") self:updateUnZipProgress(gameName,tonumber(temp[1]),tonumber(temp[2])) end})
                UpdateManager:startDownload(gameName)
                -- self:updateUnNormalDeal(sender,gameName,"updateInfo.downloadState == STATUE_HAVEUPDATE")
            elseif updateInfo.downloadState == STATUE_DOWNING then
                if updateInfo.target == sender then
                    if sender.isTip == true then
                        addScrollMessage("正在下载游戏资源")
                    end
                else
                    self:createProgessTimer(sender,gameName)
                    UpdateManager:setDownloadListInfo({gameName,
                                                   sender,
                                                   function(finishNum,totalNum) if not tolua.isnull(self) then self:updateDownloadProgress(gameName,finishNum,totalNum) end end,
                                                   function()end,
                                                   function() Hall.closeTips() if not tolua.isnull(self) then self:hideDownBtn(gameName) end Hall:selectedGame(gameName) end,
                                                   function(value) local temp = string.split(value,"_") self:updateUnZipProgress(gameName,tonumber(temp[1]),tonumber(temp[2])) end})
                    self:syncDownloadProgess(gameName,updateInfo.finishNum,updateInfo.totalNum)
                end
            elseif updateInfo.downloadState == STATUE_NOUPDATE then
                sender:hide()
                local a,b = Hall:getGameName(gameName)
                if globalUnit.gameName == nil or a == nil then
                    Hall:selectedGame(gameName)
                else
                    self:requestSearchRoom()
                end
            elseif updateInfo.downloadState == STATUEUNZIP_UNING then
                if updateInfo.target == sender then
                    if sender.isTip == true then
                        addScrollMessage("正在解压游戏资源")
                    end
                else
                    self:createProgessTimer(sender,gameName)
                    UpdateManager:setDownloadListInfo({gameName,
                                                   sender,
                                                   function(finishNum,totalNum) if not tolua.isnull(self) then self:updateDownloadProgress(gameName,finishNum,totalNum) end end,
                                                   function()end,
                                                   function() Hall.closeTips() if not tolua.isnull(self) then self:hideDownBtn(gameName) end Hall:selectedGame(gameName) end,
                                                  function(value) local temp = string.split(value,"_") self:updateUnZipProgress(gameName,tonumber(temp[1]),tonumber(temp[2])) end,})
                    self:syncDownloadProgess(gameName,updateInfo.finishNum,updateInfo.totalNum)
                end
            end
        end
    end
end

function HallLayer:requestSearchRoom()
    self.bMatchSearch = true
    luaPrint("1111111 匹配房间时检测是否在某个房间")
    local msg = {};
    msg.iUserID = PlatformLogic.loginResult.dwUserID
    PlatformLogic:send(PlatformMsg.MDM_GP_DESK_LOCK_PASS, PlatformMsg.ASS_GP_GET_ROOM, msg, PlatformMsg.MSG_GP_C_USE_ROOM_KEYINFO)
end

function HallLayer:updateUnNormalDeal(sender,gameName,msg)
    if msg then
        luaPrint("msg = "..msg)
    end

    sender:stopActionByTag(55556)
    local func = function()
        local info = UpdateManager:getDownLoadInfo(sender,gameName)

        if info and info.downloadState == STATUE_DOWNING and info.finishNum == 0 then--重置下载状态
            luaPrint("下载无反应处理 重置下载状态")
            dispatchEvent("downFileFail",{gameName,sender})
        end
    end
    performWithDelay(sender,func,60):setTag(55556)--下载无反应处理
end

function HallLayer:hideDownBtn(gameName)
    if gameDownloadProgessTimer[gameName] then
        for k,v in pairs(gameDownloadProgessTimer[gameName]) do
            if v[1].isHide == nil and v[1]:getName() == gameName then
                table.removebyvalue(gameDownloadProgessTimer[gameName],v[1],true)
                v[1]:removeAllChildren()
                v[1]:hide()
            end
        end
    end
end

--创建进度条
function HallLayer:createProgessTimer(node,gameName)
    if gameDownloadProgessTimer[gameName] == nil then
        gameDownloadProgessTimer[gameName] = {}
        dispatchEvent("notifySameGameUpdate",{node,gameName})--同步所有此游戏的更新按钮
    end

    table.insert(gameDownloadProgessTimer[gameName], {node,self:openProgressTimer(node)})
end

--扇形进度条
function HallLayer:openProgressTimer(parent)
    local image = ccui.ImageView:create("hall/downBg.png")
    image:setAnchorPoint(cc.p(0.5,0))
    image:setPosition(cc.p(parent:getContentSize().width/2,0))
    image:hide()
    parent:addChild(image)

    local amrkIcon = cc.Sprite:create("hall/progress.png")
    local myProgressTimer = cc.ProgressTimer:create(amrkIcon)
    myProgressTimer:setAnchorPoint(cc.p(0.5,0.5))
    myProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    myProgressTimer:setPercentage(0)
    myProgressTimer:setTag(1)
    myProgressTimer:setPosition(cc.p(image:getContentSize().width/2,image:getContentSize().height/2))

    image:addChild(myProgressTimer)

    --更新百分比
    local percentLabel = FontConfig.createWithSystemFont("0%")
    percentLabel:setColor(FontConfig.colorGray)
    percentLabel:setPosition(cc.p(image:getContentSize().width/2,image:getContentSize().height/2))
    percentLabel:setTag(2)
    image:addChild(percentLabel)

    return image
end

function HallLayer:updateUnZipProgress(gameName,mainID,result)
    local  timers = gameDownloadProgessTimer[gameName]
    luaPrint("updateUnZipProgress -------------     ",mainID,result)
    if mainID == 6 then
            if result == 1 then
                if timers then
                    for k,timer in pairs(timers) do
                        -- performWithDelay(timer[2]:getChildByTag(1),
                            -- function()
                                -- table.removebyvalue(gameDownloadProgessTimer[gameName],timer,true)
                                luaPrint(tostring(timer[1]:getName()).." timer[1].isHide    ",timer[1].isHide,timer[1].isHideTip)
                                if timer[1].isHide == nil then
                                    timer[1]:hide()
                                end
                                timer[2]:removeSelf()
                                if timer[1].isHideTip == 1 then
                                    addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载完成")
                                    local userDefault = cc.UserDefault:getInstance()
                                    userDefault:setStringForKey("updateChildGame", userDefault:getStringForKey("updateChildGame", "").."_"..gameName)
                                end
                            -- end,0.1)
                    end
                    gameDownloadProgessTimer[gameName] = {}
                end
            elseif result == 0 then
                -- self.downInfoLabel:setString("解压失败")
                -- table.removebyvalue(gameDownloadProgessTimer[gameName],timer,true)
                dispatchEvent("unzipFileFail",gameName)
            end
    elseif mainID == 5 then
        if timers then
            for k,timer in pairs(timers) do
                if not timer[2] or tolua.isnull(timer[2]) then
                    return
                end

                timer[2]:show()
                local percent = result

                if percent > 100 then
                    percent = 100
                end

                percent = (percent * 25 /100+75)

                local text = string.format("%d%%", percent)
                timer[2]:getChildByTag(2):stopActionByTag(5555)
                timer[2]:getChildByTag(2):setString(text)
                timer[2]:getChildByTag(1):setPercentage(percent)
            end
        end
    end
end

function HallLayer:updateDownloadProgress(gameName,finishNum,totalNum)
    local  timers = gameDownloadProgessTimer[gameName]

    if timers then
        for k,timer in pairs(timers) do
            if timer[1] and not tolua.isnull(timer[1]) then
                timer[1]:stopActionByTag(55556)
            end

            if not timer[2] or tolua.isnull(timer[2]) then
                return
            end

            timer[2]:show()
            local percent = finishNum/totalNum

            if percent > 1 then
                percent = 1
            end

            percent = percent * 75 / 100

            local text = string.format("%d%%", percent * 100)

            if percent == 1 then
                text = "100%"
            end

            timer[2]:getChildByTag(2):stopActionByTag(5555)
            timer[2]:getChildByTag(2):setString(text)

            percent =  math.floor(100 * percent)
            timer[2]:getChildByTag(1):setPercentage(percent)

            if finishNum == totalNum then
                -- performWithDelay(timer[2]:getChildByTag(1),
                    -- function()
                        -- table.removebyvalue(gameDownloadProgessTimer[gameName],timer,true)
                        if timer[1].isHide == nil then
                            -- timer[1]:hide()
                        end
                        -- timer[2]:removeSelf()
                        -- if gameName == "bairenniuniu" then
                        --     if timer[1].isHide == true then
                        --         addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载完成")
                        --     end
                        -- else
                            if timer[1].isHideTip == nil then
                                timer[1].isHideTip = 1
                                -- addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载完成")
                            end
                        -- end
                    -- end,0.1)
            else
                -- local func = function()
                --     local info = UpdateManager:getDownLoadInfo(timer[1],gameName)
                --     if info and info.downloadState == STATUE_DOWNING then--重置下载状态
                --         local percent = info.finishNum/info.totalNum

                --         local text = string.format("%.1f%%", percent * 100)

                --         if text == timer[2]:getChildByTag(2):getString() then
                --             luaPrint("下载进度停止 重置下载状态")
                --             dispatchEvent("downFileFail",{gameName,timer[1]})
                --         end
                --     end
                -- end
                -- performWithDelay(timer[2]:getChildByTag(2),func,10):setTag(5555)--下载无反应处理
            end
        end
    end
end

function HallLayer:syncDownloadProgess(gameName,finishNum,totalNum)
    self:updateDownloadProgress(gameName,finishNum,totalNum)
end

function HallLayer:removeUpdateNotify(data)
    local data = data._usedata

    if gameDownloadProgessTimer[data[1]] then
        for k,v in pairs(gameDownloadProgessTimer[data[1]]) do
            if v[1] == data[2] then
                table.removebyvalue(gameDownloadProgessTimer[data[1]],v,true)
            end
        end
    end

    luaDump(gameDownloadProgessTimer[data[1]],"gameDownloadProgessTimer[data[1]]")
end

function HallLayer:registerAccount(data)
    local msg = data._usedata

    PlatformRegister:getInstance().type = 2
    local onlyString = PlatformLogic.loginResult.MachineCode--onUnitedPlatformGetSerialNumber()

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在升级,请稍后"), LOADING):removeTimer()

    PlatformRegister:getInstance():start()
    PlatformRegister:getInstance():requestRegist(msg.name, MD5_CTX:MD5String(msg.pwd), onlyString, false)
end

function HallLayer:bindPhone(data)
    local msg = data._usedata

    PlatformRegister:getInstance().type = 3
    local onlyString = PlatformLogic.loginResult.MachineCode--onUnitedPlatformGetSerialNumber()

    LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在绑定手机号,请稍后"), LOADING):removeTimer()

    PlatformRegister:getInstance():start()
    PlatformRegister:getInstance():requestRegist("", MD5_CTX:MD5String(msg.pwd), onlyString, false)
end

function HallLayer:onReceivePlatformRegistCallback(data)
    local data = data._usedata

    self:onPlatformRegistCallback(data[1],data[2],data[3],data[4],data[5],data[6])
end

function HallLayer:onPlatformRegistCallback(success, fastRegist, message, name, pwd, loginTimes)
    LoadingLayer:removeLoading()
    PlatformRegister:getInstance():stop()
    luaPrint("升级完毕")
    if success then
        self:saveUserInfo(name,pwd)
        self:getInforData()
        PlatformLogic.loginResult.szMobileNo = globalUnit.registerInfo.phone
        PlatformLogic.loginResult.szRealName = globalUnit.registerInfo.answer
        if not isEmptyString(globalUnit.registerInfo.phone) then
            PlatformLogic.loginResult.IsCommonUser = 1
        end

        if PlatformLogic.loginResult.IsCommonUser == 1 then
            globalUnit:setLoginType(accountLogin)
        end
        PlatformLogic.loginResult.szMD5Pass = pwd
        MailInfo:sendMailListInfoRequest()
        -- MailInfo:sendQuestionListRequest()

        if isShowShop then
            isShowShop = nil
            createShop()
        end

        dispatchEvent("accountUpSuccess")
    else
        dispatchEvent("accountUpFailed")
        addScrollMessage(message)
    end
end

function HallLayer:saveUserInfo(name, pwd)
    local userDefault = cc.UserDefault:getInstance();

    if not isEmptyString(name) then
        userDefault:setStringForKey(USERNAME_TEXT, name)
    end

    if not isEmptyString(pwd) then
        userDefault:setStringForKey(PASSWORD_TEXT, pwd)
    end

    userDefault:flush()
end

function HallLayer:dealMoney()
    luaPrint("dealMoney",MoneyInfo.AllJiuJiTimes,MoneyInfo.JiuJiTimes,MoneyInfo.jiujiScore,MoneyInfo.jiujiNeed)
    if MoneyInfo.JiuJiTimes >= MoneyInfo.AllJiuJiTimes then--已领取次数大于等于总领取次数
        addScrollMessage("领取失败，今日领取次数已达上限！")
        --addScrollMessage("您今天还能领取0次救济金，每次可领取"..goldConvert(MoneyInfo.jiujiScore,1).."金币(金币不足"..goldConvert(MoneyInfo.jiujiNeed,1).."时可领取)")
    else
        local money = PlatformLogic.loginResult.i64Money + PlatformLogic.loginResult.i64Bank
        if globalUnit.isYuEbao == true then
            money = PlatformLogic.loginResult.i64Money + PlatformLogic.loginResult.i64Bank/100
        end
        if money >= MoneyInfo.jiujiNeed then
            local RemainderNum = MoneyInfo.AllJiuJiTimes - MoneyInfo.JiuJiTimes;--剩余可领取的次数
            if RemainderNum < 0 then
                RemainderNum = 0;
            end
            addScrollMessage("领取失败，金币不足"..goldConvert(MoneyInfo.jiujiNeed,1).."时可领取！")
            --addScrollMessage("今天还能领取"..RemainderNum.."次救济金，每次可领取"..goldConvert(MoneyInfo.jiujiScore,1).."金币(金币不足"..goldConvert(MoneyInfo.jiujiNeed,1).."时可领取)")
        else
            MoneyInfo:sendGetMoneyRequest()
        end
    end
end

function HallLayer:receiveMoneyInfo(data)
    local data = data._usedata
    local node = self.Button_jiujijin:getChildByName("money")
    MoneyInfo.JiuJiTimes = data.JiuJiTimes;
    -- if MoneyInfo.JiuJiTimes >= MoneyInfo.AllJiuJiTimes then--已领取次数大于等于总领取次数
    --     self.Button_jiujijin:hide();
    -- else
    --     self.Button_jiujijin:show();
    -- end
    local RemainderNum = MoneyInfo.AllJiuJiTimes - MoneyInfo.JiuJiTimes;--剩余可领取的次数
    if RemainderNum < 0 then
        RemainderNum = 0;
    end
    if node == nil then
        local text = FontConfig.createWithSystemFont(goldConvert(data.Score,1),20,cc.c3b(255,255,0))
        text:setName("money")
        text:setPosition(self.Button_jiujijin:getContentSize().width/2,-7)
        self.Button_jiujijin:addChild(text)
    else
        node:setString(goldConvert(data.Score,1))
    end
end

function HallLayer:receiveGetMoney(data)
    local data = data._usedata

    if data.ret == 0 then
        addScrollMessage("成功领取救济金"..goldConvert(data.Score,1).."金币")
        self.Button_jiujijin:hide();
        MoneyInfo:sendMoneyInfoRequest()
        self:getInforData()
    end
end

--点击下载时，同步其他的按钮
function HallLayer:syncSameGameUpdate(data)
    local data = data._usedata

    for k,v in pairs(self.updateBtn) do
        if v[1] ~= data[1] and v[2] == data[2] then
            self:selectedSynSameGameUpdate(v[1],true)
        end
    end
end

function HallLayer:selectedSynSameGameUpdate(node,flag)
    if node == self.Button_ddz then
        self:onClickDdz(node,flag)
    elseif node == self.Button_by then
        self:onClickBy(node,flag)
    end
end

function HallLayer:reDownload(data)
    local data = data._usedata

    if not isHaveGameListLayer() then
        for k,v in pairs(self.updateBtn) do
            if v[2] == data then
                self:selectedSynSameGameUpdate(v[1])
                break
            end
        end
    end
end

function HallLayer:unzipFileFail(data)
    local data = data._usedata

    if data ~= nil then
        local t = type(data)
        local gameName = data
        local func = nil

        UpdateManager:updateDownLoadList(gameName,"isCanDown",false)

        if t == "string" then
            local writePath = cc.FileUtils:getInstance():getWritablePath()
            func = function()
                if cc.FileUtils:getInstance():isFileExist(writePath.."cache/old"..data..".txt") then
                    cc.FileUtils:getInstance():removeFile(writePath.."cache/old"..data..".txt")
                end

                UpdateManager:resetDwon(data)
                luaDump(gameDownloadProgessTimer[data],"gameDownloadProgessTimer[data]")

                if gameDownloadProgessTimer[data] then
                    for k,v in pairs(gameDownloadProgessTimer[data]) do
                        if v[1] and not tolua.isnull(v[1]) then
                            if v[1].isHide == true then
                                if v[2] and not tolua.isnull(v[2]) then
                                    v[2]:removeSelf()
                                end
                            else
                                v[1]:show()
                                if v[2] and not tolua.isnull(v[2]) then
                                    v[2]:removeSelf()
                                end
                            end
                        end
                    end

                    gameDownloadProgessTimer[data] = nil
                end
            end
        end

        func()

        addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."解压文件失败，请重新下载")
    end
end

function HallLayer:downFileFail(data)
    local data = data._usedata

    if data ~= nil then
        local t = type(data)
        local gameName = data
        local func = nil

        UpdateManager:updateDownLoadList(gameName,"isCanDown",false)

        if t == "string" then
            local writePath = cc.FileUtils:getInstance():getWritablePath()
            func = function()
                if cc.FileUtils:getInstance():isFileExist(writePath.."cache/old"..data..".txt") then
                    cc.FileUtils:getInstance():removeFile(writePath.."cache/old"..data..".txt")
                end

                UpdateManager:resetDwon(data)
                luaDump(gameDownloadProgessTimer[data],"gameDownloadProgessTimer[data]")

                if gameDownloadProgessTimer[data] then
                    for k,v in pairs(gameDownloadProgessTimer[data]) do
                        if v[1] and not tolua.isnull(v[1]) then
                            if v[1].isHide == true then
                                if v[2] and not tolua.isnull(v[2]) then
                                    v[2]:removeSelf()
                                end
                            else
                                v[1]:show()
                                if v[2] and not tolua.isnull(v[2]) then
                                    v[2]:removeSelf()
                                end
                            end
                        end
                    end

                    gameDownloadProgessTimer[data] = nil
                end
            end
        elseif t == "table" then
            gameName = data[1]
            func = function()
                if gameDownloadProgessTimer[gameName] then
                    for k,v in pairs(gameDownloadProgessTimer[gameName]) do
                        if v[1] and not tolua.isnull(v[1]) then
                            if v[1].isHide == true then
                                if v[2] and not tolua.isnull(v[2]) then
                                    v[2]:removeSelf()
                                end
                            else
                                v[1]:show()
                                if v[2] and not tolua.isnull(v[2]) then
                                    v[2]:removeSelf()
                                end
                            end
                        end
                    end

                    gameDownloadProgessTimer[data] = nil
                end
                UpdateManager:updateDownLoadList(gameName,"downloadState",STATUE_HAVEUPDATE)
                self:createUpdateEvent(data[2],gameName)
            end
        end

        func()

        addScrollMessage(Hall:getChineseGameNameByGameName(gameName).."下载文件失败，请重新下载")

        -- dispatchEvent("reDownload",gameName)


        -- if Hall:getCurGameName() == nil then
            -- GamePromptLayer:create():showPrompt(Hall:getChineseGameNameByGameName(gameName).."下载文件失败，请重试！")
        -- end
    end
end

function HallLayer:accountQuit()
    globalUnit.isaccountQuit = true

    local node = display.getRunningScene():getChildByTag(1421)

    if node then
        node:delayCloseLayer(0)
    end

    RoomLogic:stopCheckNet()
    PlatformLogic:close()
    RoomLogic:close()
    local prompt = GamePromptLayer:create()
    prompt:showPrompt("您的账号在其他手机登录,请重新登录",true)
    prompt.closeBtn:removeSelf()
    prompt:setBtnClickCallBack(function()
        luaPrint("异地登陆，退出当前账号")
        Hall.exitHall()
    end)
end

--试玩场超时提示
function HallLayer:playOutTime()
    LoadingLayer:removeLoading()
    RoomLogic:stopCheckNet()
    RoomLogic:close()
    dispatchEvent("loginRoom")
    GamePromptLayer:remove()

    display.getRunningScene():addChild(require("layer.popView.PlayOutTimeLayer"):create(),99999)
end

function HallLayer:webRefreshScore(data)
    --删除原特效
    local emitter1 = display.getRunningScene():getChildByName("emitter1");
    if emitter1 then
        emitter1:removeFromParent();
    end

    local anim = display.getRunningScene():getChildByName("chongzhitexiao");
    if anim then
        anim:removeFromParent();
    end

    --播放金币特效
    local winSize = cc.Director:getInstance():getWinSize();

    local emitter1 = cc.ParticleSystemQuad:create("hall/hall/chongzhi/2jijinbi.plist")
    emitter1:setAutoRemoveOnFinish(true)    --设置播放完毕之后自动释放内存
    emitter1:setName("emitter1");
    emitter1:setPosition(cc.p(winSize.width/2,winSize.height))
    display.getRunningScene():addChild(emitter1,999999)

    --播放特效
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        local anim = createSkeletonAnimation("gongxichongzhi","hall/hall/chongzhi/gongxichongzhi.json", "hall/hall/chongzhi/gongxichongzhi.atlas");
        if anim then
            anim:setName("chongzhitexiao");
            anim:setPosition(cc.p(winSize.width/2, winSize.height/2));
            anim:setAnimation(1,"gongxichongzhi", false);
            display.getRunningScene():addChild(anim,999999);
        end
    end),cc.DelayTime:create(1),cc.CallFunc:create(function()
        local anim = display.getRunningScene():getChildByName("chongzhitexiao");
        if anim then
            anim:removeFromParent();
        end
    end)))


    MailInfo:sendMailListInfoRequest()
end

function HallLayer:receiveWeChat(data)
    showShop()
end

function HallLayer:receiveConfigInfo(data)
    local data = data._usedata
    luaDump(data,"HallLayer配置信息")
    if data.id == 12 then
        if (data.val > 0) then --领取次数大于0
            SettlementInfo:sendConfigInfoRequest(13)--请求最小领取条件
            MoneyInfo.AllJiuJiTimes = data.val;
        else
            self.Button_jiujijin:hide()--次数小于0则隐藏按钮
        end
        self:resetPopBtnsPos()
    elseif data.id == 13 then
        MoneyInfo.jiujiNeed = data.val;

        -- local money = PlatformLogic.loginResult.i64Money + PlatformLogic.loginResult.i64Bank
        -- if globalUnit.isYuEbao == true then
            -- money = PlatformLogic.loginResult.i64Money + PlatformLogic.loginResult.i64Bank/100
        -- end

        MoneyInfo:sendMoneyInfoRequest()

        -- luaPrint("救济金",money,MoneyInfo.jiujiNeed);
        --if money < MoneyInfo.jiujiNeed then
            SettlementInfo:sendConfigInfoRequest(14)--请求领取金额
            --self.Button_jiujijin:setVisible(true)--显示领取按钮
            --addScrollMessage("2222222+++++++"..PlatformLogic.loginResult.i64Money)
        -- else
        --     self.Button_jiujijin:hide()--金币大于救济金领取则隐藏
        -- end
    elseif data.id == 14 then
        MoneyInfo.jiujiScore = data.val;
    elseif data.id == serverConfig.xingYunDuoBao then
        self.Button_copy:setVisible(data.val == 1)
        self:resetPopBtnsPos()
    elseif data.id == serverConfig.qianDao then
        self.Button_sign:setVisible(data.val == 1)
        self:resetPopBtnsPos()
    elseif data.id == serverConfig.chongzhiUrl then
        initShop()
    elseif data.id == serverConfig.popWindow then
        if self.createType == nil and isShowAccountUpgrade == nil and self.isShowTip == nil then
            self.isShowTip = true
            showAccountUpgrade()
        end
    end
end

function HallLayer:resetPopBtnsPos()
    if not self.Button_sign:isVisible() then
        if not self.Button_copy:isVisible() then
            if self.Button_jiujijin:isVisible() then
                self.Button_jiujijin:setPositionX(self.Button_sign.oldx)
            end
        else
            self.Button_copy:setPositionX(self.Button_sign.oldx)
            if self.Button_jiujijin:isVisible() then
                self.Button_jiujijin:setPositionX(self.Button_copy.oldx)
            end
        end
    else
        self.Button_sign:setPositionX(self.Button_sign.oldx)
        if not self.Button_copy:isVisible() then
            if self.Button_jiujijin:isVisible() then
                self.Button_jiujijin:setPositionX(self.Button_copy.oldx)
            end
        else
            self.Button_copy:setPositionX(self.Button_copy.oldx)
            if self.Button_jiujijin:isVisible() then
                self.Button_jiujijin:setPositionX(self.Button_jiujijin.oldx)
            end
        end
    end
end

function HallLayer:receiveLuckyOpenInfo(data)
    local data = data._usedata

    local layer = require("layer.popView.activity.duobao.LuckyLayer"):create()

    if layer then
        display.getRunningScene():addChild(layer);
    end
end

function HallLayer:receiveNoGuildInfo(data)
    local data = data._usedata;
    if display.getRunningScene():getChildByName("OpenOrJoinLayer") then
        return;
    end
    local layer = require("hall.layer.popView.newExtend.vip.OpenOrJoinLayer"):create(data)
    layer:setName("OpenOrJoinLayer")
    display.getRunningScene():addChild(layer)
end

function HallLayer:receiveHaveGuildInfo(data)
    local data = data._usedata;
    local code = data[2]

    if self.GuildList == nil then
        self.GuildList = {}
    end

    if code == 0 or code == 1 or code == 2 then
        for k,v in pairs(data[1]) do
            table.insert(self.GuildList,v)
        end
    end

    if code == 0 then
        if display.getRunningScene():getChildByName("OpenOrJoinLayer") then
            display.getRunningScene():getChildByName("OpenOrJoinLayer"):removeSelf();
        end

        if display.getRunningScene():getChildByName("VipHallLayer") then
            -- display.getRunningScene():getChildByName("VipHallLayer"):removeSelf();
            display.getRunningScene():getChildByName("VipHallLayer"):refreshLayer(self.GuildList)
            self.GuildList = {}
            return;
        end

        local layer = require("hall.layer.popView.newExtend.vip.VipHallLayer"):create(self.GuildList)
        display.getRunningScene():addChild(layer)
        layer:setName("VipHallLayer")
        self.GuildList = {}
    end
end

function HallLayer:receiveGuildCommendAgree(data)
    local data = data._usedata;
    local code = data[2]

    if code == 0 then
        local text = "您已成功加入VIP厅【"..data[1].GuildName.."】 (厅ID:"..data[1].GuildID.."),可通过大厅VIP厅入口进入！"
        local prompt = GamePromptLayer:create();
        prompt:showPrompt(text);
    elseif code == 2 then
        addScrollMessage("已经是厅成员")
    end
end

function HallLayer:receiveGuildSendMoneyReq(data)
    local data = data._usedata;
    local code = data[2]

    local VipHallLayer = display.getRunningScene():getChildByName("VipHallLayer");
    local VipManagement = display.getRunningScene():getChildByName("VipManagement");
    local VipDetaislLayer = display.getRunningScene():getChildByName("VipDetaislLayer");
    local JoinVipLayer = display.getRunningScene():getChildByName("JoinVipLayer");

    if VipHallLayer then
        VipHallLayer.vipTip:setVisible(data[1].lSendMoney ~= 0);
    end
    if VipManagement then
        VipManagement.vipTip:setVisible(data[1].lSendMoney ~= 0);
    end
    if VipDetaislLayer then
        VipDetaislLayer.vipTip:setVisible(data[1].lSendMoney ~= 0);
    end
    if JoinVipLayer then
        JoinVipLayer.vipTip:setVisible(data[1].lSendMoney ~= 0);
    end
end

function HallLayer:forceUser(data)
    if not self.isForceUser then
        self.isForceUser = true
        self:unBindEvent()
        Hall.exitHall()
    end
end

function HallLayer:refreshGameList(data)
    local data = data._usedata

    data = string.split(data,"_")

    local channel = tonumber(data[1])
    local uNameId = tonumber(data[2])
    local open = tonumber(data[3])--0 关游戏 1 开游戏

    name = Hall:getGameNameByNameID(uNameId)

    if channelID == channel then
        local ret = not LoginLayer:getInstance()

        local cName,game = Hall:getCurrentGameName()

        if name == cName then
            if open == 0 then
                if globalUnit.isEnterGame then
                    if uNameId == GameCreator:getCurrentGameNameID() then
                        local gameName = globalUnit.gameName
                        Hall:exitGame(nil,function() globalUnit.isEnterGame = false end)
                        if name ~= "fishing" and name ~= "likuipiyu" and name ~= "jinchanbuyu" and cName ~= "shisanzhang" and cName ~= "shisanzhanglq" then
                            Hall:exitGame()
                        end

                        if (cName == "shisanzhang" or cName == "shisanzhanglq") and isEmptyString(gameName) then
                            Hall:exitGame()
                            dispatchEvent("onRoomLoginError",3)
                        else
                            dispatchEvent("onRoomLoginError",1);--通知VIP界面
                        end
                    end
                else
                    if name ~= "fishing" and name ~= "likuipiyu" and name ~= "jinchanbuyu" and cName ~= "shisanzhang" and cName ~= "shisanzhanglq" then
                        Hall:exitGame()
                        dispatchEvent("onRoomLoginError",2);--通知VIP界面
                    end
                end
            end
        else
            if game and game.pushLayer[1] then
               if game.pushLayer[1]:getName() ~= "gameLayer" then
                    game.pushLayer[1]:unBindEvent()
               end
            end
        end

        if ret then
            GamesInfoModule:clear()
            self:requestGameRoomTimerCallBack()
        end
    end
end

return HallLayer
