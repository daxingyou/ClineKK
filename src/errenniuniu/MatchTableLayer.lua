local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("errenniuniu.TableLogic");
local ChouMa = require("errenniuniu.ChouMa");
local HelpLayer = require("errenniuniu.HelpLayer");
local errenniuniuLogic = require("errenniuniu.errenniuniuLogic");
local GamePlayerNode = require("errenniuniu.GamePlayerNode");
local PokerCommonDefine = require("errenniuniu.PokerCommonDefine");
local Poker = require("errenniuniu.Poker")
local TrustLayer = require("errenniuniu.TrustLayer")
local errenniuniu = require("errenniuniu");

local difenNum = {"0.10","0.50","1.00","3.00","5.00","10.00","20.00","0.00"}
local ruchang = {"2.00","10.00","18.00","72.00","120.00","240.00","480.00","0.00"}

--游戏类
function TableLayer:scene(userScore)

    bulletCurCount = 0;

    local layer = TableLayer:create(userScore);

    local scene = display.newScene();

    scene:addChild(layer);

    layer.runScene = scene;

    return scene;
end
--创建类
function TableLayer:create(userScore)
    --Event:clearEventListener();
    luaPrint("-----------TableLayer:create-",userScore)
    local layer = TableLayer.new(userScore);

    globalUnit.isFirstTimeInGame = false;

    return layer;
end

--静态函数
function TableLayer:getInstance()
    return _instance;
end
--构造函数
function TableLayer:ctor(userScore)
    self.super.ctor(self, 0, true);
    PLAY_COUNT = 2;
    --GameMsg.init();
    if globalUnit.isTryPlay == true then
        self.userScore = userScore or 10000000;
    else
        self.userScore = userScore or PlatformLogic.loginResult.i64Money;
    end
    
    self.number = globalUnit.iRoomIndex --- = 1;
    local uiTable = {
        Image_bg = "Image_bg",
        Button_menu = {"Button_menu",0,1},
        Button_tuoguan = {"Button_tuoguan",1},
        Button_help = {"Button_help",1},


        --玩家信息
        Node_player0 = "Node_player0",
        Node_player1 = "Node_player1",
        -- Image_play0 = "Image_play0",
        -- Image_zhuang0 = "Image_zhuang0",
        -- Text_name0 = "Text_name0",
        -- AtlasLabel_money0 = "AtlasLabel_money0",
        -- AtlasLabel_resultMoney_win0 = "AtlasLabel_resultMoney_win0",
        -- AtlasLabel_resultMoney_fail0 = "AtlasLabel_resultMoney_fail0",

        -- Image_play1 = "Image_play1",
        -- Image_zhuang1 = "Image_zhuang1",
        -- Text_name1 = "Text_name1",
        -- AtlasLabel_money1 = "AtlasLabel_money1",
        -- AtlasLabel_resultMoney_win1 = "AtlasLabel_resultMoney_win1",
        -- AtlasLabel_resultMoney_fail1 = "AtlasLabel_resultMoney_fail1",

        Image_clock0 = "Image_clock0",
        AtlasLabel_time0 = "AtlasLabel_time0",
        Image_clock1 = "Image_clock1",
        AtlasLabel_time1 = "AtlasLabel_time1",

        Text_history = "Text_history",
        Text_upju = "Text_upju",
        AtlasLabel_allmoney = "AtlasLabel_allmoney",
        Image_fapaiji = "Image_fapaiji",
        Image_setting = {"Image_setting",0},
        Button_back = "Button_back",
        Button_yinxiao = "Button_yinxiao",
        Button_yinyue = "Button_yinyue",
        Button_start = "Button_start",
        Button_bank = "Button_bank",
        Button_nobank = "Button_nobank",
        Button_lookcard = "Button_lookcard",
        Image_ready0 = "Image_ready0",
        Image_ready1 = "Image_ready1",
        Node_card0 = "Node_card0",
        Node_card1 = "Node_card1",
        Node_bet = "Node_bet",
        Button_bet1 = "Button_bet1",
        Button_bet2 = "Button_bet2",
        Button_bet3 = "Button_bet3",
        Button_bet4 = "Button_bet4",
        AtlasLabel_score1 = "AtlasLabel_score1",
        AtlasLabel_score2 = "AtlasLabel_score2",
        AtlasLabel_score3 = "AtlasLabel_score3",
        AtlasLabel_score4 = "AtlasLabel_score4",
        Image_wancheng = "Image_wancheng",
        Image_trust = "Image_trust",
        Button_trust1 = "Button_trust1",
        Button_trust2 = "Button_trust2",
        Button_trust3 = "Button_trust3",
        Button_trust4 = "Button_trust4",
        Button_trust5 = "Button_trust5",
        Button_trust_close = "Button_trust_close",
        Image_dengdaibank = "Image_dengdaibank",
        Image_clock0 = "Image_clock0",
        Image_clock0 = "Image_clock0",
        Node_card = "Node_card",
        Image_history = "Image_history",

    }
    loadNewCsb(self,"errenniuniu/tableLayer",uiTable)

    -- self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
    -- self.tableLogic:enterGame();

    self:initData();

    _instance = self;
end

function TableLayer:onEnter()
    self:initUI()

    --self:bindEvent();--绑定消息
    self:pushGlobalEventInfo("I_R_M_EndMatchRoom",handler(self, self.onEndMatch))
    self:pushGlobalEventInfo("I_P_M_Login",handler(self, self.onReceiveLogin))--断线重连刷新
    self:pushGlobalEventInfo("I_R_M_DisConnect",handler(self, self.onReceiveLogin))--断线重连刷新

    self.super.onEnter(self);
end

function TableLayer:onExit()
    self.super.onExit(self);
    self:stopAllActions();
end

--初始化数据
function TableLayer:initData()  
    
    --玩家对象存储
    self.playerNodeInfo = {};

    --玩家昵称
    self.playerInfo = {};--包括昵称 ID 登陆IP 性别
    --准备图片
    self.readyImage = {};

    self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

    --游戏是否开始
    self.m_bGameStart = false;

    self._bReconding = false;

    --有事解散
    self._isHaveThing = false;

    --房间类型
    self.roomType = RoomType.NormalRoom;--默认正常房间

    self.m_iHeartCount = 0;
    self.m_maxHeartCount = 3;
    self.m_maxScore = 0;--最大下注金额
    self.deskMoneyTable = {};--筹码池
    self.betMoneyTable = {100,1000,5000,10000,50000,100000}--筹码表
    self.b_isBank = false;--记录是否是庄家
    self.m_lastScore = 0;--上一轮下注金额
    self.m_lastAllScore = 0;--历史总战绩
    self.n_pokerTable = {};--动画扑克池
    self.m_selfMoney = 0;--自己的金钱
    self.m_otherMoney = 0;--对面玩家的金钱
    self.m_RealSeat = 255;
    --self.ReadyRealSeat = 255;--记录准备玩家
    --self.b_past = false; --记录玩家有木有进行过游戏
    self.a_sendCardAni = nil;--发牌动画
    self.b_isBackGround = false;--记录游戏是否切后台
    self.bigEndAnimate = nil;--游戏结束整个动画
    self.endMsg = nil;--游戏结束消息
    self.isTouchLayer = false;

end

function TableLayer:initUI()
   
    self:loadCacheResource();
    --基本按钮
    self:initGameNormalBtn();

    self:hideClock();

    -- 初始化玩家信息
    self:initPlayerInfo();

    --适配游戏
    -- self:addButton();

    -- self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
    -- self.tableLogic:enterGame();

    --self:playSound(false,1)
    --self:addAnimation(2);
end

function TableLayer:addButton()
     local size = cc.Director:getInstance():getWinSize();
    -- local huanzhuoBtn = ccui.Button:create("errenniuniu/bg/huanzhuo.png","errenniuniu/bg/huanzhuo-on.png");
    -- self:addChild(huanzhuoBtn);
    -- huanzhuoBtn:setPosition(size.width/2-150,size.height/2);
    -- huanzhuoBtn:onClick(function(sender) self:showFangjian(sender); end);
    
    local startBtn = ccui.Button:create("game/kaishiyouxi.png","game/kaishiyouxi-on.png");
    self:addChild(startBtn)
    startBtn:setPosition(size.width/2,size.height/2);
    startBtn:onClick(function(sender) self:showFangjian(sender); end);

end

--下拉菜单
function TableLayer:ClickOtherButtonBack(sender)
    display.loadSpriteFrames("errenniuniu/errenniuniu.plist", "errenniuniu/errenniuniu.png");
    self:loadCacheResource();
    local tag = sender:getTag();
    if tag == 0 then
        sender:setTag(1);
        sender:loadTextures("shouna-on.png","shouna-on.png","shouna-on.png",UI_TEX_TYPE_PLIST);
        self.Image_setting:setVisible(true);
    elseif tag == 1 then
        sender:setTag(0);
        sender:loadTextures("shouna.png","shouna.png","shouna.png",UI_TEX_TYPE_PLIST);
        self.Image_setting:setVisible(false);
    end
end

function TableLayer:showFangjian(sender)
    if self.isTouchLayer then
        return;
    end
    self.isTouchLayer = true;
    performWithDelay(self,function()  self.isTouchLayer = false end,1);
    errenniuniu.erterRoom = true;
    
    luaPrint("showFangjian",globalUnit.iRoomIndex,globalUnit.selectedRoomID);
    dispatchEvent("matchRoom",globalUnit.selectedRoomID);
    self:showChangeLoading();
end

function TableLayer:showChangeLoading()
    luaPrint("showChangeLoading-----------------")
    local scene = display.getRunningScene();

    LoadingLayer:createLoading(FontConfig.gFontConfig_22,"正在匹配,请稍后");

    if scene then
        local layer = scene:getChildByTag(9999);
        if layer then
            layer:updateLayerOpacity(0)
            if layer:getChildByName("enterText") then
                self:ChangeOldLayer(layer);--更改统一的loading界面
                self:startClock(layer) --创建启动倒计时
                self:cancelMatch(layer);
            end
        end
    end
end

--更改统一的loading界面
function TableLayer:ChangeOldLayer(layer)
    luaPrint("ChangeOldLayer------------");
    --隐藏进入房间字
    local enterText = layer:getChildByName("enterText");
    if enterText then
        enterText:setVisible(false);
    end
    --将动画向上移动
    local loadImage = layer:getChildByName("loadImage");
    if loadImage then
        loadImage:setPositionY(560);
        loadImage:removeSelf()
    end
    local winSize = cc.Director:getInstance():getWinSize();
    local enterText = cc.Sprite:create("game/ddz_fangjian.png");
    enterText:setPosition(winSize.width/2,winSize.height*0.65);
    enterText:setScale(0.5)
    layer:addChild(enterText)

    -- layer:updateLayerOpacity(200)
end

function TableLayer:startClock(layer)
    local times = 10
    local winSize = cc.Director:getInstance():getWinSize();
    local daojishi = FontConfig.createWithCharMap(tostring(times), "game/ddz_daojishizitiao.png", 34, 42, "+");
    daojishi:setPosition(winSize.width/2,winSize.height/2);
    layer:addChild(daojishi)

    daojishi:setString(tostring(times));
    local temp = tostring(times);
    -- local checkClockScheduler = nil;
    -- self.checkClockScheduler = schedule(self, function() 
    --     temp = temp -1;
    --     daojishi:setString(temp);
    --     if temp <= 0 then
    --         -- RoomLogic:close();
    --         self:sendCancelMatchMsg();
    --         self:stopAction(self.checkClockScheduler)
    --         self.checkClockScheduler = nil;
    --     end
    -- end, 1)

    local action1 = cc.DelayTime:create(1.0);
    local action2 = cc.CallFunc:create(function()
        temp = temp -1;
        if temp == 0 then
            -- RoomLogic:close();
            self:sendCancelMatchMsg();
            --self.Node_3:stopAllActions();
        elseif temp < 0 then
            temp = 0
        end

        local scene = display.getRunningScene();
        local layer = scene:getChildByTag(9999);
        if layer and daojishi and not tolua.isnull(daojishi) then 
            daojishi:setString(temp);
        end
    end);

    layer:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)));
end

function TableLayer:cancelMatch(layer)
    local winSize = cc.Director:getInstance():getWinSize();
    local btn = ccui.Button:create("game/ddz_quxiao.png","game/ddz_quxiao-on.png")
    btn:setPosition(winSize.width/2,winSize.height*0.35);
    layer:addChild(btn)
    btn:onClick(handler(self, self.onClickCancel))
end

function TableLayer:onClickCancel()
    luaPrint("TableLayer:onClickCancel")
    -- self:stopAction(self.checkClockScheduler)
    -- self.checkClockScheduler = nil; 
    --self.Node_3:stopAllActions();
    -- RoomLogic:close();
    self:sendCancelMatchMsg();
end

function TableLayer:sendCancelMatchMsg()
    local msg = {};
    msg.dwUserID = PlatformLogic.loginResult.dwUserID
    local cf = {
     {"dwUserID","INT"}
    }
    RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_END_MATCH_ROOM, msg, cf)
end

function TableLayer:onEndMatch()
    luaPrint("TableLayer 取消匹配",globalUnit.isEnterGame)
    LoadingLayer:removeLoading();
    Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end);
end

function TableLayer:onReceiveLogin()
    addScrollMessage("网络不太好哦，请检查网络")
    LoadingLayer:removeLoading();
    Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end);
end

--初始化玩家信息
function TableLayer:initPlayerInfo()
    --self.Image_play0:setVisible(false);
    --self.Image_play1:setVisible(false);
    self.playerNodeInfo = {};

    for i=1,PLAY_COUNT do
        local k = i -1;

        --玩家准备图片
        self["Image_ready"..k]:setVisible(false);

        --self.readyImage[i] = self["Image_ready"..k];
        table.insert(self.readyImage,self["Image_ready"..k]);

        --玩家语音图标
        --self["Image_chat"..k]:setVisible(false);
        --self.chatImage[i] = self["Image_chat"..k];

        --玩家信息
        
        local node = self["Node_player"..k];
        luaPrint("创建头像");
        --node:setLocalZOrder(100)
        local playerNode = GamePlayerNode.new(INVALID_USER_ID, k,self);--默认显示
        --playerNode:setEmptyHead();
        --node:addChild(playerNode);
        node:addChild(playerNode);
        node:setVisible(false);
        --playerNode:showScoreAni(-100);
        if node then
            luaPrint("节点在");
        end
        playerNode:setPosition(cc.p(0,0));
        --playerNode:setPlayInfoButton();

        table.insert(self.playerNodeInfo,playerNode);

        --self:setUserMoney(k, 0);
        --self:showUserMoney(k, false);
    end
end

function TableLayer:hideClock()
    self.AtlasLabel_time0:getParent():setVisible(false);
    self.AtlasLabel_time1:getParent():setVisible(false);

end

function TableLayer:loadCacheResource()
    display.loadSpriteFrames("errenniuniu/errenniuniu.plist", "errenniuniu/errenniuniu.png");
    display.loadSpriteFrames("errenniuniu/card.plist", "errenniuniu/card.png");
end

--初始化按钮
function TableLayer:initGameNormalBtn()
    self.Node_card0:setVisible(false);
    self.Node_card1:setVisible(false);
    self.Node_bet:setVisible(false);
    self.Image_wancheng:setVisible(false);
    self.Image_trust:setVisible(false);
    self.Image_trust:setLocalZOrder(100000)
    self.Image_dengdaibank:setVisible(false);
    self.Image_history:setVisible(false);
    --下拉菜单
    if self.Button_menu then
        self.Button_menu:setTag(0);
        self.Image_setting:setVisible(false);
        self.Button_menu:setTouchEnabled(false)
        -- self.Button_menu:addClickEventListener(function(sender)
        --     self:ClickOtherButtonBack(sender);
        -- end)
    end

    --准备按钮
    if self.Button_start then
        self.Button_start:setVisible(false);
    end
    --叫庄按钮
    if self.Button_bank then
        self.Button_bank:setVisible(false);
    end
    --不叫
    if self.Button_nobank then
        self.Button_nobank:setVisible(false);
    end
    --摊牌
    if self.Button_lookcard then
        self.Button_lookcard:setVisible(false);
    end

    for i=1,4 do
        if self["Button_bet"..i] then
            self["Button_bet"..i]:setTag(i);
        end
    end
    
    -- --保险箱
    -- if self.Button_insurance then
    --  self.Button_insurance:addClickEventListener(function(sender)
    --      self:ClickInsuranceBack(sender);
    --  end)
    -- end
    if self.Button_tuoguan then
        luaPrint("托管");
        self.Button_tuoguan:setVisible(false);
    end

    --托管下注选择
    for i=1,5 do
        if self["Button_trust"..i] then
            self["Button_trust"..i]:setTag(i-1);
            
            self["Button_trust"..i]:onClick(function(sender)
                luaPrint("Button_trust",sender:getTag());
                ERNNInfo:sendTrust(sender:getTag())
                self.Image_trust:setVisible(false);
            end)
        end
    end

    if self.Button_trust_close then
        self.Button_trust_close:onClick(function ()
            self.Image_trust:setVisible(false);
        end);
    end
    
    --规则
    if self.Button_help then
        luaPrint("找到规则按钮");
        self.Button_help:onClick(function(sender)
            luaPrint("Button_guize");
            local layer = HelpLayer:create();
            self:addChild(layer,10000);
        end)
    end
    display.loadSpriteFrames("errenniuniu/errenniuniu.plist", "errenniuniu/errenniuniu.png");
    --音乐
    if self.Button_yinyue then
        self.Button_yinyue:setTag(0);
        if getMusicIsPlay() then
            playMusic("sound/table_music.mp3",true);
            self.Button_yinyue:setTag(0);
            self.Button_yinyue:loadTextures("yinyuekai.png","yinyuekai-on.png","yinyuekai-on.png",UI_TEX_TYPE_PLIST);
        else
            --audio.pauseMusic();
            --setMusicIsPlay(false);
            self.Button_yinyue:setTag(1);
            self.Button_yinyue:loadTextures("yinyueguan.png","yinyueguan-on.png","yinyueguan-on.png",UI_TEX_TYPE_PLIST);
        end
        self.Button_yinyue:addClickEventListener(function(sender)
            luaPrint("Button_yinyue");
            if self.Button_yinyue:getTag() == 0 then
                audio.pauseMusic();
                setMusicIsPlay(false);
                self.Button_yinyue:setTag(1);
                self.Button_yinyue:loadTextures("yinyueguan.png","yinyueguan-on.png","yinyueguan-on.png",UI_TEX_TYPE_PLIST);
                luaPrint("000")
            else
                audio.resumeMusic();
                setMusicIsPlay(true);
                playMusic("sound/table_music.mp3",true);
                self.Button_yinyue:setTag(0);
                self.Button_yinyue:loadTextures("yinyuekai.png","yinyuekai-on.png","yinyuekai-on.png",UI_TEX_TYPE_PLIST);
                luaPrint("111")
            end
        end)
    end
    --音效
    if self.Button_yinxiao then
        self.Button_yinxiao:setTag(0);
        if getEffectIsPlay() then
            --playMusic("sound/sound-happy-bg.mp3",true);
            self.Button_yinxiao:setTag(0);
            self.Button_yinxiao:loadTextures("yinxiaokai.png","yinxiaokai-on.png","yinxiaokai-on.png",UI_TEX_TYPE_PLIST);
        else
            --audio.pauseMusic();
            --setMusicIsPlay(false);
            self.Button_yinxiao:setTag(1);
            self.Button_yinxiao:loadTextures("yinxiaoguan.png","yinxiaoguan-on.png","yinxiaoguan-on.png",UI_TEX_TYPE_PLIST);
        end
        self.Button_yinxiao:addClickEventListener(function(sender)
            luaPrint("Button_yinxiao");
            --self:showMsgString("关闭音效功能正在开发");
            if self.Button_yinxiao:getTag() == 0 then
                self.Button_yinxiao:setTag(1);
                --audio.setSoundsVolume(0);
                setEffectIsPlay(false);
                self.Button_yinxiao:loadTextures("yinxiaoguan.png","yinxiaoguan-on.png","yinxiaoguan-on.png",UI_TEX_TYPE_PLIST);
                luaPrint("000")
            else
                self.Button_yinxiao:setTag(0);
                --audio.setSoundsVolume(1);
                setEffectIsPlay(true);
                self.Button_yinxiao:loadTextures("yinxiaokai.png","yinxiaokai-on.png","yinxiaokai-on.png",UI_TEX_TYPE_PLIST);
                luaPrint("111")
            end
        end)
    end
    
    --退出
    if self.Button_back then
        self.Button_back:addClickEventListener(function ()
            -- body
            if self.isTouchLayer then
                addScrollMessage("房间匹配中,请稍等!")
                return;
            end
            Hall:exitGame(false,function()
                RoomLogic:close();
            end);
        end)
    end

end

--退出
function TableLayer:onClickExitGameCallBack(isRemove)
    luaPrint("TableLayer:onClickExitGameCallBack玩家退出",self.m_bGameStart)
    local func = function()     
        self.tableLogic:sendUserUp();
        -- self.tableLogic:sendForceQuit();
        self:leaveDesk()
    end

    if isRemove ~= nil then
        Hall:exitGame(isRemove,func);
    else
        Hall:exitGame(self.m_bGameStart,func);
    end
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

        if not display.getRunningScene():getChildByName("deskLayer") then
            RoomLogic:close();
        end

        self._bLeaveDesk = true;
        _instance = nil;
        
    end
end

--玩家分数
function TableLayer:ScoreToMoney(pNode,score)
    local remainderNum = score%100;
    local remainderString = "";

    if remainderNum == 0 then--保留2位小数
        remainderString = remainderString..".00";
    else
        if remainderNum%10 == 0 then
            remainderString = remainderString.."0";
        end
    end

    if pNode then
        pNode:setString((score/100)..remainderString);
    else
        return (score/100)..remainderString;
    end
end

return TableLayer
