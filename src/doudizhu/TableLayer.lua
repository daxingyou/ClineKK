local TableLayer = class("TableLayer", BaseWindow)
local TableLogic = require("doudizhu.TableLogic");
local PopUpLayer = require("doudizhu.PopUpLayer");
local CardSprite = require("doudizhu.CardSprite");
local CardLayer = require("doudizhu.CardLayer");
local CGameLogic = require("doudizhu.CGameLogic");
local EndLayer = require("doudizhu.EndLayer")
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

--//逻辑类型
local CT_ERROR						= 0;									--//错误类型
local CT_SINGLE						= 1;									--//单牌类型
local CT_DOUBLE						= 2;									--//对牌类型
local CT_THREE						= 3;									--//三条类型
local CT_SINGLE_LINE				= 4;									--//单连类型
local CT_DOUBLE_LINE				= 5;									--//对连类型
local CT_THREE_LINE					= 6;									--//三连类型
local CT_THREE_TAKE_ONE				= 7;									--//三带一单
local CT_THREE_TAKE_TWO				= 8;									--//三带一对
local CT_FOUR_TAKE_ONE				= 9;									--//四带两单
local CT_FOUR_TAKE_TWO				= 10;									--//四带两对
local CT_BOMB_CARD					= 11;									--//炸弹类型
local CT_MISSILE_CARD				= 12;									--//火箭类型

local ST_ORDER			 			= 1;--大小排序
local ST_COUNT			 			= 2;--数目排序
local ST_CUSTOM			 			= 3;--自定排序

local ClockType = {
    Game_Me_Double = 1,--自己加倍
    Game_Right_Double = 2,--右边加倍
    Game_Left_Double = 3,--左边加倍
    Game_Me_CallLandLord = 4,--自己叫地主
    Game_Right_CallLandLord = 5,--右边叫地主
    Game_Left_CallLandLord = 6,--左边叫地主
    Game_Me_OutCard = 7, --自己出牌
    Game_Right_OutCard = 8, --右边出牌
    Game_Left_OutCard = 9, --左边出牌
    Game_Start = 10,--游戏开始
    Game_Me_Pass = 11,--自己要不起
    Game_Me_JDZ = 12,--自己叫地主
    Game_Right_JDZ = 13,--右边叫地主
    Game_Left_JDZ = 14,--左边叫地主
    Game_Me_QDZ = 15,--自己抢地主
    Game_Right_QDZ = 16,--右边抢地主
    Game_Left_QDZ = 17,--左边抢地主
    Game_GameEnd = 18,--游戏结束倒计时
}

local ClockTime = {
    Game_Call_Score = 15,--叫分时间
    Game_Double = 10,--加倍时间
    Game_OutCard = 15,--出牌时间
    Game_NoCard = 5,--出牌时间
    Game_Qdz = 15,--抢地主时间
    Game_End = 10,--游戏结束
}

local TipsType = {
    Game_Ready = 1,--准备
    Game_OneScore = 2,--一分
    Game_TwoScore = 3,--二分
    Game_ThreeScore = 4,--三分
    Game_NoCallScore = 5,--三分
    Game_DoubleScore = 6,--加倍
    Game_NoScore = 7,--不加倍
    Game_NoOut = 8,--不出牌
    Game_Jdz = 9,--叫地主
    Game_Bjdz = 10,--不叫
    Game_Qdz = 11,--抢地主
    Game_Bqdz = 12,--不抢
}

local cardDataTest = {1,2,3,4,5,6,7,8,9,10,11,12,13,17,18,19,20,21,22,23}

--测试控制
local TESTTAG = false;

local leaveFlag = -1;

--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

    bulletCurCount = 0;


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
    PLAY_COUNT = 3;
    self.uNameId = uNameId;
    self.bDeskIndex = bDeskIndex or 0;
    self.bAutoCreate = bAutoCreate or false;
    self.bMaster = bMaster or 0;
    GameMsg.init();

    if TESTTAG == true then
        table.insert(GameMsg.CMD_S_GameStart,{"cbHandData","BYTE["..PLAY_COUNT.."]["..GameMsg.MAX_COUNT.."]"});
        table.insert(GameMsg.CMD_S_GameStart,{"cbHandCount","BYTE["..PLAY_COUNT.."]"});
    end

    DDZInfo:init();

    display.loadSpriteFrames("doudizhu/plist/doudizhu.plist","doudizhu/plist/doudizhu.png")
    display.loadSpriteFrames("doudizhu/card.plist","doudizhu/card.png")

    local uiTable = {
        Button_manager = {"Button_manager",0,1},
        --Node_5 = {"Node_5",0},
        Button_tuoguan = {"Button_tuoguan",1},
        Button_rule = {"Button_rule",1},

        Node_bjeffect = "Node_bjeffect",
        Panel_cardBg = "Panel_cardBg",
        Image_bg = "Image_bg",
        Image_renwu2 = "Image_renwu2",
        Image_renwu3 = "Image_renwu3",
        Image_zhuo = "Image_zhuo",
        Image_renwu1 = "Image_renwu1",

        Node_1 = "Node_1",
        Node_user1 = "Node_user1",
        Text_Name1 = "Text_Name1",
        AtlasLabel_gold1 = "AtlasLabel_gold1",
        AtlasLabel_ying1 = "AtlasLabel_ying1",
        AtlasLabel_shu1 = "AtlasLabel_shu1",
        Image_tips1 = "Image_tips1",
        Image_tipNoCard = "Image_tipNoCard",
        Node_user2 = "Node_user2",
        AtlasLabel_gold2 = "AtlasLabel_gold2",
        Text_userName2 = "Text_userName2",
        Image_leftCardBg = "Image_leftCardBg",
        AtlasLabel_paishu2 = "AtlasLabel_paishu2",
        AtlasLabel_ying2 = "AtlasLabel_ying2",
        AtlasLabel_shu2 = "AtlasLabel_shu2",
        Image_tips2 = "Image_tips2",
        Node_user3 = "Node_user3",
        AtlasLabel_gold3 = "AtlasLabel_gold3",
        Text_userName3 = "Text_userName3",
        Image_rightCardBg = "Image_rightCardBg",
        AtlasLabel_paishu3 = "AtlasLabel_paishu3",
        AtlasLabel_ying3 = "AtlasLabel_ying3",
        AtlasLabel_shu3 = "AtlasLabel_shu3",
        Image_tips3 = "Image_tips3",

        AtlasLabel_doublenum = "AtlasLabel_doublenum",
        AtlasLabel_difen = "AtlasLabel_difen",

        Node_3 = "Node_3",
        Button_huanzhuo = "Button_huanzhuo",
        Button_startgame = "Button_startgame",
        -- Button_rule = "Button_rule",
        -- Button_tuoguan = "Button_tuoguan",
        Button_double = "Button_double",
        Button_nodouble = "Button_nodouble",
        Button_yifeng = "Button_yifeng",
        Button_liangfen = "Button_liangfen",
        Button_sanfeng = "Button_sanfeng",
        Button_nocall = "Button_nocall",
        Button_noout = "Button_noout",
        Button_tip = "Button_tip",
        Button_out ="Button_out",
        Button_yaobuqi = "Button_yaobuqi",
        Button_jdz = "Button_jdz",
        Button_bjdz = "Button_bjdz",
        Button_qdz = "Button_qdz",
        Button_bqdz = "Button_bqdz",
        Sprite_clock = "Sprite_clock",
        AtlasLabel_clock = "AtlasLabel_clock",

        Node_4 = "Node_4",
        Button_notuoguan = "Button_notuoguan",

        Node_5 = "Node_5",
        -- Panel_xiala = "Panel_xiala",
        -- Button_exit = "Button_exit",
        -- Button_yinxiao = "Button_yinxiao",
        -- Button_yinyue = "Button_yinyue",

        Node_6 = "Node_6",

        --比赛场界面
        Image_contestBg = "Image_contestBg",
        Node_contestEnd = "Node_contestEnd",
        AtlasLabel_maxPlayer = "AtlasLabel_maxPlayer",
        AtlasLabel_minPlayer = "AtlasLabel_minPlayer",
        AtlasLabel_myRank = "AtlasLabel_myRank",
        AtlasLabel_allRank = "AtlasLabel_allRank",
        Node_contest1 = "Node_contest1",
        Node_contest2 = "Node_contest2",
        AtlasLabel_contestWait = "AtlasLabel_contestWait",

        Node_contest2 = "Node_contest2",
        AtlasLabel_contestEnter = "AtlasLabel_contestEnter",
        Image_contestEnterLoading = "Image_contestEnterLoading",

        --排名
        Image_rankBg = "Image_rankBg",
        AtlasLabel_ranknum = "AtlasLabel_ranknum",

    }
    loadNewCsb(self,"doudizhu/tableLayer",uiTable)

    self:initData();

    --初始化按钮
    if globalUnit.isShowZJ then
        self.Panel_xiala = self.Button_manager:getChildByName("Panel_xiala1");
        self.Button_zhanji = self.Panel_xiala:getChildByName("Button_zhanji");
    else
        self.Panel_xiala = self.Button_manager:getChildByName("Panel_xiala0");
    end

    self.Button_exit = self.Panel_xiala:getChildByName("Button_exit");
    self.Button_yinxiao = self.Panel_xiala:getChildByName("Button_yinxiao");
    self.Button_yinyue = self.Panel_xiala:getChildByName("Button_yinyue");
    self.Button_huanzhuo:loadTextures("bg/ernn_jixuyouxi.png","bg/ernn_jixuyouxi-on.png","bg/ernn_jixuyouxi.png")
    self.Button_startgame:loadTextures("bg/ernn_likaifangjian.png","bg/ernn_likaifangjian-on.png","bg/ernn_likaifangjian.png")
    self.Button_huanzhuo:setPositionX(self.Button_huanzhuo:getPositionX() + self.Button_startgame:getPositionX()/2 - self.Button_huanzhuo:getPositionX()/2)

    self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
    self.tableLogic:enterGame();

    _instance = self;

    
end

function TableLayer:onEnter()

    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/card.plist");
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");

    self:initUI()

    self:bindEvent()

    self.super.onEnter(self)
end

-- function TableLayer:onExit()
--     self.tableLogic:sendUserUp();
--     self.tableLogic:sendForceQuit();

--     globalUnit.isEnterGame = false;
--     self.super.onExit(self);

--     if self.contactListener then
--         local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
--         eventDispathcher:removeEventListener(self.contactListener);
--         self.contactListener = nil;
--     end

--     self.tableLogic:stop();

--     self:stopAllActions();
-- end

function TableLayer:bindEvent()
    -- self:pushEventInfo(DDZInfo, "DDZGameReady", handler(self, self.onDDZGameReady))--游戏开始
    self:pushEventInfo(DDZInfo, "DDZSendCard", handler(self, self.onDDZSendCard))--游戏发牌
    self:pushEventInfo(DDZInfo, "DDZGameStart", handler(self, self.onDDZGameStart))--游戏开始
    self:pushEventInfo(DDZInfo, "DDZCallScore", handler(self, self.onDDZCallScore))--用户叫分
    self:pushEventInfo(DDZInfo, "DDZBakerInfo", handler(self, self.onDDZBankerInfo))--庄家信息
    self:pushEventInfo(DDZInfo, "DDZOutCard", handler(self, self.onDDZOutCard))--用户出牌
    self:pushEventInfo(DDZInfo, "DDZPassCard", handler(self, self.onDDZPassCard))--用户放弃
    self:pushEventInfo(DDZInfo, "DDZGameEnd", handler(self, self.onDDZGameEnd))--游戏结束
    self:pushEventInfo(DDZInfo, "DDZTrustee", handler(self, self.onDDZTrustee))--用户托管
    self:pushEventInfo(DDZInfo, "DDZDouble", handler(self, self.onDDZDouble))--用户加倍
    self:pushEventInfo(DDZInfo, "DDZNoCard", handler(self, self.onDDZNoCard))--用户要不起
    self:pushEventInfo(DDZInfo, "DDZRobNt", handler(self, self.onDDZRobNt))--用户叫地主

    self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
end

function TableLayer:initData()
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3; 
    self.cardLayer = nil;--牌层
    self.text = 0;
    self.CGameLogic = CGameLogic:create();--逻辑函数
    self.bankStation = -1;--庄家的逻辑位置
    self.rightCardNum = 0;--右邊玩家的牌的數量
    self.leftCardNum = 0;--左邊玩家的牌的數量
    self.otherCardData = {};--其他玩家出的牌的數據
    self.tipsData = {};--牌提示的数据
    self.tipsNum = 0;--牌提示数据的第N个提示
    self.outCardUser = -1--当前出牌的玩家
    self.bankCallScore = 0;--庄家叫分
    self.allCallScore = 0;--自己的总叫分数
    self.isPlaying = false;--是否游戏中
    self.isGameEnd = false;--游戏是否结束

    self.userScoreTable = {0,0,0};--三个玩家的分数(视图位置123保存)

    self.musicTable = {};

    self.saveCardData = {};--剩余牌的张数 用于记牌器
    self:InitSaveCardData();

    self.actionFinish = true;
    --测试用其他玩家牌的数据
    self.otherHandCard = {{},{},{}};

    self.isMeOutCard = false;--是否自己主动出牌

    self.mMyRankNum = "--";

    self.mFirstStart = false;

    self.m_playerLeave = false;

    self.m_showEnd = false;
end
--重新赋值数据
function TableLayer:ClearData()
    self.bankStation = -1;--庄家的逻辑位置
    self.rightCardNum = 0;--右邊玩家的牌的數量
    self.leftCardNum = 0;--左邊玩家的牌的數量
    self.otherCardData = {};--其他玩家出的牌的數據
    self.tipsData = {};--牌提示的数据
    self.tipsNum = 0;--牌提示数据的第N个提示
    self.outCardUser = -1--当前出牌的玩家

    self.m_showEnd = false;

    self.isGameEnd = false;
    self.cardLayer:setTouchEnabled(false);

    self:InitSaveCardData();
    self:RefreshSveCard();
    if self.willStartSpine then
        self.willStartSpine:removeFromParent();
        self.willStartSpine = nil;
    end

    self:ShowCallScoreButton(0);

    local biao = self.Node_6:getChildByName("dizhubiao");
    if biao then
        biao:removeFromParent();
    end

    self.bankCallScore = 0;--庄家叫分
    self.allCallScore = 0;--自己的总叫分数

    self.AtlasLabel_doublenum:setString(self.allCallScore);

    --移除斗地主升级特效
    self:ShowDZChangeEffect(false);

    local dengdaitip = self.Image_bg:getChildByName("dengdaitip");
    if dengdaitip then
        dengdaitip:removeFromParent();
    end

end

function TableLayer:InitSaveCardData()
    self.saveCardData = {};
    for i = 1,15 do
        self.saveCardData[i] = 4;
        if i == 14 or i == 15 then
            self.saveCardData[i] = 1;
        end
    end
end

function TableLayer:initUI()
   
    self:showDeskInfo();

    self:initBtnClick();

    self:initMusic();

    self:InitSaveCard();

    self.Button_rule:setPositionX(self.Button_rule:getPositionX()-15);
    self.Button_tuoguan:setPositionX(self.Button_tuoguan:getPositionX()-15);

    local pos = cc.p(self.Button_rule:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("doudizhu",self);
    self.Button_rule:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(self.Button_rule:getContentSize().width/2,-60);

    if globalUnit.isShowZJ then
        self.m_logBar = LogBar:create(self);
        self.Image_bg:addChild(self.m_logBar);
    end
    
end


function TableLayer:initBtnClick()

    --self.Button_manager:addClickEventListener(function(sender) self:onClick(sender) end)
    --self.Button_hideManager:addClickEventListener(function(sender) self:onClick(sender) end)
    --self.Button_yinxiao:addClickEventListener(function(sender) self:onClick(sender) end)
    --self.Button_yinyue:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_exit:addClickEventListener(function(sender) self:onClick(sender) end)
    
    -- self.Button_notuoguan:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_tuoguan:addClickEventListener(function(sender) self:onClick(sender) end)

    -- self.Button_huanzhuo:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_startgame:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_rule:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_double:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_nodouble:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_yifeng:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_liangfen:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_sanfeng:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_nocall:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_noout:addClickEventListener(function(sender) self:onClick(sender) end)
    self.Button_tip:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_out:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_yaobuqi:addClickEventListener(function(sender) self:onClick(sender) end)

    self.Button_manager:onClick(handler(self,self.onClick))
    self.Button_yinxiao:onClick(handler(self,self.onClick))
    self.Button_yinyue:onClick(handler(self,self.onClick))
    self.Button_exit:onClick(handler(self,self.onClick))

    self.Button_notuoguan:onClick(handler(self,self.onClick))
    self.Button_tuoguan:onClick(handler(self,self.onClick))

    self.Button_huanzhuo:onClick(handler(self,self.onClick))
    self.Button_startgame:onClick(handler(self,self.onClick))
    self.Button_rule:onClick(handler(self,self.onClick))
    self.Button_double:onClick(handler(self,self.onClick))
    self.Button_nodouble:onClick(handler(self,self.onClick))
    self.Button_yifeng:onClick(handler(self,self.onClick))
    self.Button_liangfen:onClick(handler(self,self.onClick))
    self.Button_sanfeng:onClick(handler(self,self.onClick))
    self.Button_nocall:onClick(handler(self,self.onClick))
    self.Button_noout:onClick(handler(self,self.onClick))
    --self.Button_tip:onClick(handler(self,self.onClick))
    self.Button_out:onClick(handler(self,self.onClick))
    self.Button_yaobuqi:onClick(handler(self,self.onClick))

    self.Button_jdz:onClick(handler(self,self.onClick))
    self.Button_bjdz:onClick(handler(self,self.onClick))
    self.Button_qdz:onClick(handler(self,self.onClick))
    self.Button_bqdz:onClick(handler(self,self.onClick))


    local winSize = cc.Director:getInstance():getWinSize()
    -- if globalUnit.nowTingId > 0 and self.Button_zhunbei==nil then
        local btn1 = ccui.Button:create("desk/zhunbei.png","desk/zhunbei-on.png")
        btn1:setPosition(winSize.width*0.5,winSize.height*0.2)
        self:addChild(btn1)
        btn1:onClick(handler(self,self.onClick))
        btn1:setName("Button_zhunbei")
        btn1:setVisible(false)
        self.Button_zhunbei = btn1;
    -- end

    if self.Button_zhanji then
        self.Button_zhanji:onClick(function(sender)
            if self.m_logBar then
                self.m_logBar:CreateLog();
            end
        end)
    end

end

function TableLayer:initMusic()
    local isEffect = getEffectIsPlay();
    if not isEffect then
        self.Button_yinxiao:setTag(1002);
        self:onClick(self.Button_yinxiao)
    end

    local isMusic = getMusicIsPlay();
    if isMusic then
        self.Button_yinyue:setTag(1003);
    else
        self.Button_yinyue:setTag(1004);
    end
    self:onClick(self.Button_yinyue)

    --self:initMusicFile();
    self.musicTable = require("DdzMusicTable")
end

function TableLayer:playDdzEffect(lSeatNo,type1)
    if lSeatNo == nil then
        return;
    end
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(lSeatNo);
    if userInfo then
        if userInfo.bBoy == false then
            type1 = type1 +1;
        end
    end
    playEffect("effect/"..self.musicTable[type1]);
end

--界面信息的初始化
function TableLayer:showDeskInfo()
    --隐藏下拉
    self.Panel_xiala:setVisible(false)

    self.AtlasLabel_difen:setVisible(false);
    self.AtlasLabel_doublenum:setVisible(false);
    --隐藏闹钟和游戏按钮
    self.Sprite_clock:setVisible(false)
    self:showGameBtn();
    --隐藏托管取消托管
    self.Button_tuoguan:setVisible(false)
    self.Node_4:setVisible(false)

    --隐藏结果分数
    self:showWinScore();

    --隐藏用户加倍叫分出牌等提示
    self:HideAllUserTips();
    --创建出牌层
    self.cardLayer = CardLayer:create(self);
    self.Panel_cardBg:addChild(self.cardLayer)
    --游戏背景的特效展示(一直存在)
    self:ShowGameBgSpecialEffects();

    self.AtlasLabel_paishu3:setString("0")
    self.AtlasLabel_paishu2:setString("0")
    self.AtlasLabel_contestEnter:setTag(0);
    
    if TESTTAG == true then
	    --测试 显示玩家昵称
	    local text1 = FontConfig.createWithSystemFont("",30,FontConfig.colorWhite);
	    self:addChild(text1,100);
	    text1:setName("text1");
	    text1:setPosition(1189,350);

	    local text2 = FontConfig.createWithSystemFont("",30,FontConfig.colorWhite);
	    self:addChild(text2,100);
	    text2:setName("text2");
	    text2:setPosition(88,350);
	end
end

--创建记牌器
function TableLayer:InitSaveCard()
    --创建背景图
    local saveCardBg = ccui.ImageView:create("doudizhu/plist/savecardbg.png");
    saveCardBg:setAnchorPoint(1,0);
    saveCardBg:setName("saveCardBg");
    
    local bgSize = saveCardBg:getContentSize();

    local saveCardLayout = ccui.Layout:create();
    saveCardLayout:setContentSize(bgSize.width,bgSize.height);
    saveCardLayout:setAnchorPoint(0,1);
    saveCardLayout:setPosition(320,720);
    saveCardLayout:setName("saveCardLayout");
    self.Node_6:addChild(saveCardLayout,10);
    saveCardLayout:setClippingEnabled(true)

    saveCardLayout:addChild(saveCardBg);
    saveCardBg:setPosition(0,0);

    --设置回调
    local btn = ccui.Button:create("doudizhu/plist/savecardBtn.png","doudizhu/plist/savecardBtn-on.png");
    btn:setAnchorPoint(1,1);
    btn:setPosition(310,720);
    self.Node_6:addChild(btn,10);
    btn:setTag(0);
    self.m_saveCardBtn = btn;

    btn:addClickEventListener(function(sender)
        self:SaveCardClick(sender)
    end)

    --绘制张数并将A2放到后面
    for i = 1,#self.saveCardData do
        local pos = cc.p(0,23);
        if i == 1 or i == 2 then
            pos.x = 40.5*(i+10);
        elseif i>2 and i<14 then
            pos.x = 40.5*(i-3);
        else
            if i==14 then
                pos.x = 40.5*(i-2)+52;
            elseif i == 15 then
                pos.x = 40.5*(i-2)+64;
            else
                pos.x = 40.5*(i-1);
            end
        end

        pos.x = 652 - pos.x;

        local numText = FontConfig.createWithCharMap(self.saveCardData[i],"doudizhu/plist/savecardnum.png", 15, 21, '0');
        numText:setPosition(pos);
        saveCardBg:addChild(numText);
        numText:setName("num"..i);
    end
end

--点击记牌器
function TableLayer:SaveCardClick(sender)
    if self.actionFinish == false then
        return;
    end

    local saveCardLayout = self.Node_6:getChildByName("saveCardLayout");

    if saveCardLayout then
        local saveCardBg = saveCardLayout:getChildByName("saveCardBg");

        local bgSize = saveCardBg:getContentSize();

        self.actionFinish = false;
        local senderTag = sender:getTag();
        local targetPos = cc.p(bgSize.width,0);
        if senderTag == 0 then--进行显示
            sender:setTag(1);
        else--进行隐藏
            sender:setTag(0);
            targetPos = cc.p(0,0);
        end
        saveCardBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,targetPos),cc.CallFunc:create(function()
            self.actionFinish = true;
        end)))
    end
end


function TableLayer:setTest()
    
   -- self.cardLayer = CardLayer:create(self);
    self.cardLayer:setHandCardData(cardDataTest,20)
    self.cardLayer:showHandCard(cardDataTest,20);
    --self.Panel_cardBg:addChild(self.cardLayer)
end

function TableLayer:setMyCard(cardData)
    --整理牌从大到小
    for i = 1,#cardData do
        for j = i,#cardData do
            if self.CGameLogic:GetCardLogicValue(cardData[i])<self.CGameLogic:GetCardLogicValue(cardData[j]) then
                local temp = cardData[i];
                cardData[i] = cardData[j];
                cardData[j] = temp;
            end
        end
    end

    self.cardLayer:setHandCardData(cardData,#cardData)
    self.cardLayer:showHandCardEx();

    playEffect("effect/Special_Dispatch.mp3")
end

function TableLayer:onClickExitGameCallBack()
    -- Hall:exitGame(self.isPlaying);
    local func = function()
        self.tableLogic:sendUserUp();
        self.tableLogic:sendForceQuit();
        self:leaveDesk();
    end
    Hall:exitGame(self.isPlaying,func);
end

function TableLayer:onClick(sender)
    self.text = self.text +1;
    local senderName = sender:getName();
    local senderTag = sender:getTag();
    luaPrint("TableLayer:onClick按钮触摸"..senderName..senderTag)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");
    if senderName == "Button_exit" then
        self:onClickExitGameCallBack();

    elseif senderName == "Button_manager" then
        self.Panel_xiala:setVisible(not self.Panel_xiala:isVisible());
        --self.Button_hideManager:setVisible(true);
    elseif senderName == "Button_hideManager" then
        --self.Panel_xiala:setVisible(false);
        --self.Button_hideManager:setVisible(false);
    elseif senderName == "Button_yinxiao" then
        if senderTag ~= 1001 then--关闭音效
            sender:setTag(1001); 
            setEffectIsPlay(false)
            sender:loadTextures("ddz_xlyinxiao-guan.png","ddz_xlyinxiao-guan-on.png","ddz_xlyinxiao-guan-on.png",UI_TEX_TYPE_PLIST)
        else
            sender:setTag(1002);--打开音效
            setEffectIsPlay(true)
            sender:loadTextures("ddz_xlyinxiao-kai.png","ddz_xlyinxiao-kai-on.png","ddz_xlyinxiao-kai-on.png",UI_TEX_TYPE_PLIST)
        end
    elseif senderName == "Button_yinyue" then
       if senderTag ~= 1003 then--关闭音yue
            sender:setTag(1003);
            setMusicIsPlay(false)
            sender:loadTextures("ddz_xlyinyue-guan.png","ddz_xlyinyue-guan-on.png","ddz_xlyinyue-guan-on.png",UI_TEX_TYPE_PLIST)
        else
            sender:setTag(1004);--打开音yue
            setMusicIsPlay(true)
            playMusic("doudizhu/effect/ddz_gameBg.mp3")
            sender:loadTextures("ddz_xlyinyue-kai.png","ddz_xlyinyue-kai-on.png","ddz_xlyinyue-kai-on.png",UI_TEX_TYPE_PLIST)
        end
    elseif senderName == "Button_huanzhuo" then
        self.tableLogic:sendUserUp();
        self.tableLogic:sendForceQuit();

        self.Sprite_clock:setVisible(false)
        self.Image_rankBg:stopAllActions();
        UserInfoModule:clear();
        local score = self.userScoreTable[1];
        local cellScore = self.AtlasLabel_difen:getString();
        local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),globalUnit.selectedRoomID)

        if score < gold then
            local prompt = GamePromptLayer:create();
            prompt:showPrompt(GBKToUtf8("最低需要"..goldConvert(gold).."金币以上！"));
            prompt:setBtnClickCallBack(function() 
                local func = function()
                    self:leaveDesk();
                end
                Hall:exitGame(false,func);
            end); 
            return;
        end

        local doudizhu = require("doudizhu");
        doudizhu.reStart = true;
        UserInfoModule:clear();

        Hall:exitGame(1,function() 
            self:leaveDesk(1);
            doudizhu:ReSetTableLayer(score,cellScore); 
        end);
    elseif senderName == "Button_startgame" then
        self:onClickExitGameCallBack();
        -- self.Sprite_clock:setVisible(false)
        -- self.Image_rankBg:stopAllActions();
        -- local flag = true;

        -- --人数不满直接匹配
        -- local count = 0;
        -- for i = 1,PLAY_COUNT do
        --     local userInfo = self.tableLogic:getUserBySeatNo(i-1);
        --     if userInfo then
        --         count = count+1;
        --     end
        -- end

        -- if count < 3 then
        --     flag = false;
        -- end

        -- --随机概率
        -- local randomNum = math.random(1,10);

        -- if randomNum > 9 and flag then
        --     flag = false;
        --     addScrollMessage("有玩家离开房间");
        -- end

        -- if flag then
        --     self.tableLogic:sendMsgReady();
        -- else
        --     self.tableLogic:sendUserUp();
        --     self.tableLogic:sendForceQuit();
        --     UserInfoModule:clear();
        --     local score = self.userScoreTable[1];
        --     local cellScore = self.AtlasLabel_difen:getString();
        --     local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),globalUnit.selectedRoomID)

        --     if score < gold then
        --         local prompt = GamePromptLayer:create();
        --         prompt:showPrompt(GBKToUtf8("最低需要"..goldConvert(gold).."金币以上！"));
        --         prompt:setBtnClickCallBack(function() 
        --             local func = function()
        --                 self:leaveDesk();
        --             end
        --             Hall:exitGame(false,func);
        --         end); 
        --         return;
        --     end
        --     local doudizhu = require("doudizhu");
        --     doudizhu.reStart = true;
        --     UserInfoModule:clear();
        --     Hall:exitGame(1,function() 
        --         self:leaveDesk(1);
        --         doudizhu:ReSetTableLayer(score,cellScore); 
        --     end);
        --    end
    elseif senderName == "Button_rule" then
        --self:ShowDZGetCard(false,{3,5,8},3);
        self:addChild(PopUpLayer:create());
        -- self:tipsTest();
    elseif senderName == "Button_double" then
        self.tableLogic:sendDoubleMsg(true);
    elseif senderName == "Button_nodouble" then
        self.tableLogic:sendDoubleMsg(false);
    elseif senderName == "Button_yifeng" then
        self.tableLogic:sendCallMsg(1);
    elseif senderName == "Button_liangfen" then
        self.tableLogic:sendCallMsg(2);
    elseif senderName == "Button_sanfeng" then
        self.tableLogic:sendCallMsg(3);
    elseif senderName == "Button_nocall" then
        self.tableLogic:sendCallMsg(255);
    elseif senderName == "Button_noout" then
        self.tableLogic:sendPassCardMsg();
    elseif senderName == "Button_tip" then
        -- if #self.otherCardData == 0 then--没有其他玩家牌的数据则返回
        --     return;
        -- end

        if #self.tipsData == 0 then--没有提示数据先赋值查找
            local tipsCardCount,tipsCardData =self.CGameLogic:SearchOutCard(self.cardLayer.cbHandCardData,self.cardLayer.cbHandCardCount,self.otherCardData,#self.otherCardData);        
            tipsCardData = self:removeBombTips(self.cardLayer.cbHandCardData,tipsCardData,tipsCardCount);
            self.tipsData = tipsCardData;
            luaDump(self.tipsData,"提示牌的数据");
        end
        --luaDump(self.tipsData,"提示牌的数据");

        if self.tipsData.cbCardCount[self.tipsNum] > 0 then--按顺序排序
            local tipsCardData = {};
            for i = 0,self.tipsData.cbCardCount[self.tipsNum]-1 do
                tipsCardData[i+1] = self.tipsData.cbResultCard[self.tipsNum][i];
            end

            self.cardLayer:setTiCardData(tipsCardData,self.tipsData.cbCardCount[self.tipsNum]);
            self.cardLayer:setUpCardData(tipsCardData)
            self.cardLayer:setUpCardAction();
            self.tipsNum = self.tipsNum+1;
            if self.tipsData.cbCardCount[self.tipsNum] == nil then
                self.tipsNum = 0;
            end
        end

        self:CheckHandCard();
    elseif senderName == "Button_out" then
        local outCradData = self.cardLayer:getUpCardData();
        if #outCradData > 0 then
            self.isMeOutCard = true;
            self:showMeOutCard(outCradData)
            self.tableLogic:sendOutCardMsg(outCradData);
        end
    elseif senderName == "Button_tuoguan" then
        self.tableLogic:sendTrustee();
    elseif senderName == "Button_notuoguan" then
        self.tableLogic:sendTrustee();
    elseif senderName == "Button_yaobuqi" then
        self.tableLogic:sendPassCardMsg();
    elseif senderName == "Button_zhunbei" then
        self.tableLogic:sendMsgReady()
    elseif senderName == "Button_jdz" then
        self.tableLogic:sendRobNT(true);
    elseif senderName == "Button_bjdz" then
        self.tableLogic:sendRobNT(false);
    elseif senderName == "Button_qdz" then
        self.tableLogic:sendRobNT(true);
    elseif senderName == "Button_bqdz" then
        self.tableLogic:sendRobNT(false);
    end
   
end

function TableLayer:tipsTest()
    local myCard = {0x4E,0x02,0x12,0x0D,0x2D,0x1D,0x3D,0x3B,0x1B,0x0A,0x38,0x08,0x07,0x37,0x16,0x26,0x35};
    local otherCard = {0x34};

    local tipsCardCount,tipsCardData =self.CGameLogic:SearchOutCard(myCard,#myCard,otherCard,#otherCard);
    luaDump(tipsCardData,"没有删除的牌数据");        
    tipsCardData = self:removeBombTips(myCard,tipsCardData,tipsCardCount);
    luaDump(tipsCardData,"提示牌的数据");
end

--移除含有炸弹的牌型
function TableLayer:removeBombTips(handCard,cardData,cardCount)
    local tipsCardData = {};
    tipsCardData.cbCardCount = {};
    tipsCardData.cbResultCard = {};

    for i = 0,cardCount-1 do--提示个数
        local findBomb = false;
        if cardData.cbCardCount[i] == 1 and (cardData.cbResultCard[i][0] == 0x4E or cardData.cbResultCard[i][0] == 0x4F) then--筛选王炸
            local count = 0;
            for k,v in pairs(handCard) do
                if v == 0x4E or v == 0x4F then
                    count = count+1;
                end
            end
            if count == 2 then
                findBomb = true;
            end

        else
            for j = 0,cardData.cbCardCount[i]-1 do--提示具体的数据循环
                local count = 0;
                for k,v in pairs(handCard) do
                    -- luaPrint("提示具体的数据循环",i,self.CGameLogic:GetCardLogicValue(v),self.CGameLogic:GetCardLogicValue(cardData.cbResultCard[i][j]))
                    if self.CGameLogic:GetCardLogicValue(v) ==  self.CGameLogic:GetCardLogicValue(cardData.cbResultCard[i][j]) then
                        count = count+1;
                    end
                end
                if count == 4 then
                    findBomb = true;
                    break;
                end
            end
            --如果本身是炸弹则需要塞入
            if cardData.cbCardCount[i] == 4 then
                local count = 0;
                for j = 1,cardData.cbCardCount[i]-1 do
                    if  self.CGameLogic:GetCardLogicValue(cardData.cbResultCard[i][j-1]) ==  self.CGameLogic:GetCardLogicValue(cardData.cbResultCard[i][j]) then
                        count = count+1;
                    end
                end
                if count == 3 then
                    findBomb = false;
                end
            end
        end

        if findBomb == false then--如果没有找到炸弹则塞入
            tipsCardData.cbCardCount[self.CGameLogic:sizeof(tipsCardData.cbCardCount)] = cardData.cbCardCount[i];
            tipsCardData.cbResultCard[self.CGameLogic:sizeof(tipsCardData.cbResultCard)] = cardData.cbResultCard[i];
        end

    end

    return tipsCardData;
end
--检测是否能出牌 将出牌按钮亮起
function TableLayer:CheckHandCard()
    self.Button_out:setEnabled(false);
    if #self.otherCardData == 0 then
        self.Button_noout:setEnabled(false);
        self.Button_tip:setEnabled(false);
    else
        self.Button_noout:setEnabled(true);
        self.Button_tip:setEnabled(true);
    end
    if self.outCardUser ~= self.tableLogic:getMySeatNo() then
        luaPrint("不是当前玩家")
        return;
    end

    local outCradData = self.cardLayer:getUpCardData();
    if #outCradData == 0 then
        luaPrint("没有将牌选中");
        return;
    end
    if #self.otherCardData>0 then--如果有其他牌则先判断牌型
        --将出牌数据和自己出牌的数据从0开始赋值
        local otherCard = {};
        local outCard = {};
        self.CGameLogic:CopyMemory(otherCard,0,self.otherCardData,0,#self.otherCardData)
        self.CGameLogic:CopyMemory(outCard,0,outCradData,0,#outCradData)
        self.CGameLogic:SortCardList(otherCard,#self.otherCardData,ST_ORDER);
        self.CGameLogic:SortCardList(outCard,#outCradData,ST_ORDER);
        luaDump(otherCard,"otherCard");
        luaDump(outCard,"outCard");
        luaPrint("出牌--------------",#self.otherCardData,#outCradData)
        if self.CGameLogic:CompareCard(otherCard,outCard,#self.otherCardData,#outCradData) then
            self.Button_out:setEnabled(true);
        end
    else
        local outCard = {};
        self.CGameLogic:CopyMemory(outCard,0,outCradData,0,#outCradData);
        self.CGameLogic:SortCardList(outCard,#outCradData,ST_ORDER);
        luaDump(outCard,"出的牌");
        -- luaPrint("檢測的遊戲類型",self.CGameLogic:GetCardType(outCard,#outCradData));
        if self.CGameLogic:GetCardType(outCard,#outCradData) > CT_ERROR then
            self.Button_out:setEnabled(true);
        end
    end

end
--加倍的时钟
function TableLayer:showDoubleClock(time,type1)
    luaPrint("TableLayer:showDoubleClock",time,type1)
    local haveClockBg = nil;
    if type1 == ClockType.Game_Me_Double then --自己加倍
        haveClockBg = self.Node_3:getChildByName("DoubleClock0");
        self:showGameBtn(type1);
    elseif type1 == ClockType.Game_Right_Double then--右边加倍
        haveClockBg = self.Node_3:getChildByName("DoubleClock1");
    elseif type1 == ClockType.Game_Left_Double then--左边加倍
        haveClockBg = self.Node_3:getChildByName("DoubleClock2");
    end

    if haveClockBg then
        return;
    end

    --创建闹钟底
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");
    local clockBg = cc.Sprite:createWithSpriteFrameName("ddz_naozhong.png");
    local clockBgSize = clockBg:getContentSize();
    --创建闹钟数字
    local clockAtlas=cc.LabelAtlas:create(tostring(time), "doudizhu/number/ddz_naozhongzitiao.png", 23, 35, string.byte("+"));
    clockAtlas:setTag(time);
    clockAtlas:setName("clockAtlas");
    clockAtlas:setAnchorPoint(cc.p(0.5,0.5));
    clockAtlas:setPosition(cc.p(clockBgSize.width/2,clockBgSize.height/2));
    clockBg:addChild(clockAtlas);

    local action1 = cc.DelayTime:create(1.0);
    local action2 = cc.CallFunc:create( function()
        if clockAtlas:getTag() > 0 then
            local clockTag = clockAtlas:getTag()-1;
            clockAtlas:setString(clockTag);
            clockAtlas:setTag(clockTag);
        elseif clockAtlas:getTag() == 0 then
            clockBg:removeFromParent();
            self.Button_double:setVisible(false);
            self.Button_nodouble:setVisible(false);
        end
    end);
    clockAtlas:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)));
    if type1 == ClockType.Game_Me_Double then --自己加倍
        local haveClockBg = self.Node_3:getChildByName("DoubleClock0");
        if haveClockBg then
            haveClockBg:removeFromParent();
        end

        self:showGameBtn(type1);
        clockBg:setPosition(643,345);
        clockBg:setName("DoubleClock0");
    elseif type1 == ClockType.Game_Right_Double then--右边加倍
        local haveClockBg = self.Node_3:getChildByName("DoubleClock1");
        if haveClockBg then
            haveClockBg:removeFromParent();
        end

        clockBg:setPosition(900,500);
        clockBg:setName("DoubleClock1");
    elseif type1 == ClockType.Game_Left_Double then--左边加倍
        local haveClockBg = self.Node_3:getChildByName("DoubleClock2");
        if haveClockBg then
            haveClockBg:removeFromParent();
        end

        clockBg:setPosition(360,500);
        clockBg:setName("DoubleClock2");
    end

    self.Node_3:addChild(clockBg);

end

--显示托管  (lSeatNo逻辑位置)isShow(true为托管false取消)
function TableLayer:showTrustee(lSeatNo,isShow)
    luaPrint("TableLayer:showTrustee",lSeatNo,isShow,self.tableLogic._mySeatNo,self.tableLogic:logicToViewSeatNo(lSeatNo))
    if lSeatNo == self.tableLogic._mySeatNo then--自己
        if isShow == false then
            self.Button_tuoguan:setVisible(true)
            self.Node_4:setVisible(false);
        else
            self.Button_tuoguan:setVisible(false)
            self.Node_4:setVisible(true);
        end
        return;
    end

    local viewSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);

    local tuoguanjiqiren = self.Node_3:getChildByName("tuoguanjiqiren_"..viewSeatNo)
    if tuoguanjiqiren then
        if isShow == false then
            luaPrint("用户取消托管,移除机器人"..viewSeatNo)
            tuoguanjiqiren:removeFromParent();
        end
    else
        if isShow then
            cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");
            local tuoguanjiqiren = cc.Sprite:createWithSpriteFrameName("ddz_tuoguanjiqiren.png");
            tuoguanjiqiren:setName("tuoguanjiqiren_"..viewSeatNo)
            self.Node_3:addChild(tuoguanjiqiren);

            if viewSeatNo == 1 then
                tuoguanjiqiren:setPosition(950,590);
            elseif viewSeatNo == 2 then
                tuoguanjiqiren:setPosition(330,590);
            end
        end
    end

end

function TableLayer:showClock(time,type1)
    self:showGameBtn();
    if time == nil or type1 == nil then
        self.Sprite_clock:setVisible(false)
        return;
    end

    if type1 == ClockType.Game_Me_Double then --自己加倍
        self:showGameBtn(type1);
        self.Sprite_clock:setPosition(665,345)
        self:startClock(time)
    elseif type1 == ClockType.Game_Right_Double then--右边加倍
        self.Sprite_clock:setPosition(900,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Left_Double then--左边加倍
        self.Sprite_clock:setPosition(360,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Me_JDZ then --自己叫地主
        self:showGameBtn(type1);
        self.Sprite_clock:setPosition(643,345)
        self:startClock(time)
    elseif type1 == ClockType.Game_Right_JDZ then--右边叫地主
        self.Sprite_clock:setPosition(900,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Left_JDZ then--左边叫地主
        self.Sprite_clock:setPosition(360,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Me_QDZ then --自己抢地主
        self:showGameBtn(type1);
        self.Sprite_clock:setPosition(643,345)
        self:startClock(time)
    elseif type1 == ClockType.Game_Right_QDZ then--右边抢地主
        self.Sprite_clock:setPosition(900,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Left_QDZ then--左边抢地主
        self.Sprite_clock:setPosition(360,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Me_CallLandLord then--自己叫地主
        self:showGameBtn(type1);
        self.Sprite_clock:setPosition(648,430)
        self:startClock(time)
    elseif type1 == ClockType.Game_Right_CallLandLord then--右边叫地主
        self.Sprite_clock:setPosition(900,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Left_CallLandLord then--左边叫地主
        self.Sprite_clock:setPosition(360,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Me_OutCard then--自己出牌
        self:showGameBtn(type1);
        self.Sprite_clock:setPosition(544,345)
        self:startClock(time)
    elseif type1 == ClockType.Game_Right_OutCard then--右边出牌
        self.Sprite_clock:setPosition(900,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Left_OutCard then--左边出牌
        self.Sprite_clock:setPosition(360,500)
        self:startClock(time)
    elseif type1 == ClockType.Game_Me_Pass then --自己要不起
        self:showGameBtn(type1);
        self.Sprite_clock:setPosition(530,345)
        self:startClock(time)
    elseif type1 == ClockType.Game_GameEnd then --结束倒计时
        self.Sprite_clock:setPosition(820,340)
        self:startClock(time)
    end

    --将所有的加倍闹钟去除
    for i = 0,2 do
        local doubleClock = self.Node_3:getChildByName("DoubleClock"..i);
        if doubleClock then
            doubleClock:removeFromParent();
        end
    end
end

function TableLayer:startClock(time)
    self.Sprite_clock:setVisible(true)
    self.AtlasLabel_clock:setString(time)
    luaPrint("启动倒计时--",time)
    self:stopAction(self.checkClockScheduler)
    self.checkClockScheduler = nil;

    
    self.checkClockScheduler = schedule(self, function() 
        time = time -1;
        self.AtlasLabel_clock:setString(time);
        if time <= 0 then
            self:stopAction(self.checkClockScheduler)
        end
    end, 1)
end

function TableLayer:showGameBtn(type1)
    if self.Button_zhunbei then
        self.Button_zhunbei:setVisible(false)
    end
    self.Node_3:setVisible(true);
    self.Button_huanzhuo:setVisible(false);
    self.Button_startgame:setVisible(false);
    self.Button_double:setVisible(false);
    self.Button_nodouble:setVisible(false);
    self.Button_yifeng:setVisible(false);
    self.Button_liangfen:setVisible(false);
    self.Button_sanfeng:setVisible(false);
    self.Button_nocall:setVisible(false);
    self.Button_noout:setVisible(false);
    self.Button_tip:setVisible(false);
    self.Button_out:setVisible(false);
    self.Button_yaobuqi:setVisible(false);
    self.Button_jdz:setVisible(false);
    self.Button_bjdz:setVisible(false);
    self.Button_qdz:setVisible(false);
    self.Button_bqdz:setVisible(false);

    if type1 == ClockType.Game_Me_Double then --自己加倍
        self.Button_double:setVisible(true);
        self.Button_nodouble:setVisible(true);
    elseif type1 == ClockType.Game_Me_JDZ then--自己叫地主
        self.Button_jdz:setVisible(true);
        self.Button_bjdz:setVisible(true);
    elseif type1 == ClockType.Game_Me_QDZ then--自己抢地主
        self.Button_qdz:setVisible(true);
        self.Button_bqdz:setVisible(true);
    elseif type1 == ClockType.Game_Me_CallLandLord then--自己叫地主
        self.Button_yifeng:setVisible(true);
        self.Button_liangfen:setVisible(true);
        self.Button_sanfeng:setVisible(true);
        self.Button_nocall:setVisible(true);
    elseif type1 == ClockType.Game_Me_OutCard then--自己出牌
        self.Button_noout:setVisible(true);
        self.Button_tip:setVisible(true);
        self.Button_out:setVisible(true);
        self:CheckHandCard();
    elseif type1 == ClockType.Game_Start then--游戏开始
        self.Button_huanzhuo:setVisible(true);
        self.Button_startgame:setVisible(false);
    elseif type1 == ClockType.Game_Me_Pass then --自己要不起
        self.Button_yaobuqi:setVisible(true)
    end
       
end

--结束显示输赢分
function TableLayer:showWinScore(GameScore)
    luaPrint("TableLayer:showWinScore")
    self.AtlasLabel_ying1:setVisible(false)
    self.AtlasLabel_shu1:setVisible(false)
    self.AtlasLabel_ying2:setVisible(false)
    self.AtlasLabel_shu2:setVisible(false)
    self.AtlasLabel_ying3:setVisible(false)
    self.AtlasLabel_shu3:setVisible(false)
    if GameScore == nil then
        return;
    end
    for index,score in pairs(GameScore) do
        local viewSeatNo = self.tableLogic:logicToViewSeatNo(index-1);
        local vIndex = viewSeatNo + 1;
        if tonumber(score) >= 0 then
            self:ScoreToMoney(self["AtlasLabel_ying"..vIndex],"+"..score)
            self["AtlasLabel_ying"..vIndex]:setVisible(false);
        else
            self:ScoreToMoney(self["AtlasLabel_shu"..vIndex],score)
            self["AtlasLabel_shu"..vIndex]:setVisible(false);
        end

    end
end

function TableLayer:hideWinScore()
    self.AtlasLabel_ying1:setVisible(false)
    self.AtlasLabel_shu1:setVisible(false)
    self.AtlasLabel_ying2:setVisible(false)
    self.AtlasLabel_shu2:setVisible(false)
    self.AtlasLabel_ying3:setVisible(false)
    self.AtlasLabel_shu3:setVisible(false)
    for i=1,PLAY_COUNT do
        if self.cardLayer then
            self.cardLayer:removeOutCard(i-1);
        end
    end
end

--游戏结束显示剩余手牌(其他两个人)
function TableLayer:showResultCard(cardData,mySeatNo)
    luaPrint("TableLayer:showResultCard")
    for index,cardTable in pairs(cardData) do
        local lSeatNo = index -1;
        if lSeatNo ~= mySeatNo then--非自己显示剩余牌
            local viewSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo)
            local realCard = {};
            for _,card in pairs(cardTable) do
                if card > 0 then
                    table.insert(realCard,card)
                end
            end
            if #realCard >0 then
                self.cardLayer:setResultCard(viewSeatNo,realCard,#realCard);
            end
        end
    end
    self.cardLayer:hideUpCardAction();
    self.cardLayer:setTouchEnabled(true);--设置手牌不可点击
end
--显示桌面类型图片
function TableLayer:showTips(seatNo,type1)
    local min = TipsType.Game_OneScore;
    -- if globalUnit.nowTingId > 0 then
    --     min = TipsType.Game_Ready
    -- else
    --     min = TipsType.Game_OneScore
    -- end
    if type1 and type1>=min and type1<=TipsType.Game_Bqdz then
        luaPrint("显示桌面类型图片11111",seatNo,PLAY_COUNT);
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");
        local viewSeatNo = self.tableLogic:logicToViewSeatNo(seatNo);
        luaPrint("显示桌面类型图片",viewSeatNo);
        self["Image_tips"..(viewSeatNo+1)]:setVisible(true);
        self["Image_tips"..(viewSeatNo+1)]:loadTexture("ddz_game_type"..type1..".png",UI_TEX_TYPE_PLIST);
        self["Image_tips"..(viewSeatNo+1)]:ignoreContentAdaptWithSize(true);
    end
end
--隐藏桌面类型图片
function TableLayer:HideTips(seatNo)
    if seatNo == GameMsg.INVALID_CHAIR then
        return;
    end
    local viewSeatNo = self.tableLogic:logicToViewSeatNo(seatNo);
    self["Image_tips"..(viewSeatNo+1)]:setVisible(false);
end
--隐藏所有人的类型图片
function TableLayer:HideAllUserTips()
    for i=0,PLAY_COUNT-1 do
        self:HideTips(i);
    end
end
--刷新用户信息
function TableLayer:flushUserMsg()
--    luaDump(self.tableLogic._deskUserList._users,"用户信息刷新")
    -- if self.isGameEnd and globalUnit.nowTingId == 0 then -- 游戏结束不刷新用户信息了
    --     return;
    -- end
    luaPrint("刷新用户信息");
    for i=1,PLAY_COUNT do
        local k = i -1;
        local userInfo = self.tableLogic:getUserBySeatNo(k);
        local vSeatNo = self.tableLogic:logicToViewSeatNo(k);
        local index = vSeatNo + 1;
        luaPrint("flushUserMsg--vSeatNo",vSeatNo)
        if userInfo ~= nil then
            self["Node_user"..index]:setVisible(true)
            if vSeatNo == 0 then --自己
                self.Text_Name1:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
            else
                self["Text_userName"..index]:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
            end
            self.userScoreTable[index] = clone(userInfo.i64Money);
            self:flushUserScore();
            luaPrint("flushUserMsg--vSeatNo",userInfo.i64Money,self.userScoreTable[index])
            if self.bankStation == -1 then
                if userInfo.bBoy then
                   self:ShowGameRenwuSpecialEffects(vSeatNo,1)
                else
                    self:ShowGameRenwuSpecialEffects(vSeatNo,2)
                end
            else
                if self.bankStation == k then
                    luaPrint("设置庄",self.bankStation,vSeatNo)
                    if userInfo.bBoy then
                        self:ShowGameRenwuSpecialEffects(vSeatNo,3)
                    else
                        self:ShowGameRenwuSpecialEffects(vSeatNo,4)
                    end
                else
                    if userInfo.bBoy then
                        self:ShowGameRenwuSpecialEffects(vSeatNo,1)
                    else
                        self:ShowGameRenwuSpecialEffects(vSeatNo,2)
                    end
                end
            end
	    
    	    if TESTTAG == true then
                --测试用
                if vSeatNo~=0 then
                    local text = self:getChildByName("text"..vSeatNo);
                    if text then
                        text:setString(userInfo.nickName);
                    end
                end
    	    end

        else
            self["Node_user"..index]:setVisible(false)
            if vSeatNo == 1 then
                self.AtlasLabel_gold2:setString("")
                self.Text_userName2:setString("");
            end
            if vSeatNo == 2 then
                self.AtlasLabel_gold3:setString("")
                self.Text_userName3:setString("");
            end
            self:ShowGameRenwuSpecialEffects(vSeatNo,0,true)
        end
    end
end

function TableLayer:flushUserNameAndSex(vSeatNo,name,bBoy)
    luaPrint("当前的视图位置flushUserNameAndSex---",vSeatNo,name,bBoy)
    local index = vSeatNo + 1;
    local text_tips = ccui.Text:create(name.."-"..tostring(bBoy),FONT_PTY_TEXT,20);
    self:addChild(text_tips);
    --self["Node_user"..index]:addChild(text_tips);
    if (vSeatNo == 1) then
        text_tips:setPosition(cc.p(1120,340))
    else
        text_tips:setPosition(cc.p(100,340))
    end
end

--刷新玩家分数
function TableLayer:flushUserScore()
    for i=1,3 do
        self:ScoreToMoney(self["AtlasLabel_gold"..i],self.userScoreTable[i])
    end  
end

--创建地主3张牌的效果
function TableLayer:ShowDZGetCard(isShow,cardData,score)
    local cardWidth = 27;


    if isShow then--显示牌背
        for i = 1,3 do--如果有牌背则删除重新创建
            local DZcard = self.Panel_cardBg:getChildByName("DZCardShow"..i);
            if DZcard then
                DZcard:removeFromParent();
            end
        end
        for i = 1,3 do
            local poker = CardSprite:create(0,2);
            poker:setName("DZCardShow"..i);
            poker:setAnchorPoint(cc.p(1,1));
            poker:setPosition(cc.p(640,710));
            self.Panel_cardBg:addChild(poker);
            local move = cc.MoveBy:create(0.3*(i-1),cc.p(cardWidth*(i-1),0))
            poker:runAction(cc.Sequence:create(move))
        end
    else--显示牌的正面
        cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");
        for i = 1,3 do
            local DZcard = self.Panel_cardBg:getChildByName("DZCardShow"..i);
            if DZcard == nil then
                DZcard = CardSprite:create(0,2);
                DZcard:setName("DZCardShow"..i);
                DZcard:setAnchorPoint(cc.p(1,1));
                DZcard:setPosition(cc.p(640+cardWidth*(i-1),710));
                self.Panel_cardBg:addChild(DZcard);
            end

            if DZcard then
                DZcard:loadCard(cardData[i]);
                
                if i == 3 then
                    local DZScoreBg = cc.Sprite:createWithSpriteFrameName("ddz_tiao.png");
                    DZScoreBg:setAnchorPoint(cc.p(0,1));
                    DZScoreBg:setPosition(cc.p(cardWidth,DZcard:getContentSize().height));
                    DZcard:addChild(DZScoreBg);

                    local DZScore = cc.Sprite:createWithSpriteFrameName("ddz_score_"..score..".png");
                    -- DZScoreBg:setAnchorPoint(cc.p(0.5,0.5));
                    DZScore:setPosition(cc.p(DZScoreBg:getContentSize().width/2,DZScoreBg:getContentSize().height/2));
                    DZScoreBg:addChild(DZScore);
                end
            end
        end
    end
end

-------------------工具类-----------------

--提示小字符
function TableLayer:TipTextShow(tipText)
    local text = cc.Label:createWithSystemFont(tipText,"Arial", 15);
    text:setColor(cc.c3b(255, 255, 0));
    --self:addChild(text,301);

    local tipBg = "hall/common/ty_pao_ma_bg.png"
    local tipSp = cc.Sprite:create(tipBg);
    local fullRect = cc.rect(0,0,tipSp:getContentSize().width,tipSp:getContentSize().height)
    local insetRect = cc.rect(420,10,1,1);

    local background = cc.Scale9Sprite:create(tipBg,fullRect,insetRect)
    background:setContentSize(cc.size(900,30 ))

    text:setPosition(cc.p(background:getContentSize().width/2,background:getContentSize().height/2 ));

    background:setPosition(cc.p(640,450))
    background:addChild(text)
    self:addChild(background);

    if self.tipTextTable[3] then
        self:removeChild(self.tipTextTable[3]);
    end

    for i = 3,2,-1 do
        self.tipTextTable[i] = self.tipTextTable[i-1];
        if self.tipTextTable[i] then
            local posY = self.tipTextTable[i]:getPositionY()+ 40;
            self.tipTextTable[i]:setPositionY(posY);
        end
    end
    self.tipTextTable[1] = background;
    --显示消失动画
    background:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeOut:create(1.5)))
    text:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeOut:create(1.5)))

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

--游戏背景特效展示
function TableLayer:ShowGameBgSpecialEffects()
    --倒计时警告动画
    local WarnAnim = {
        name = "beijingtexiao",
        json = "doudizhu/game/beijin/beijingtexiao.json",
        atlas = "doudizhu/game/beijin/beijingtexiao.atlas",
    }
    addSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    local skeleton_animation = createSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    self.Node_bjeffect:addChild(skeleton_animation);
    skeleton_animation:setPosition(cc.p(640,360));
       
    skeleton_animation:setAnimation(0,WarnAnim.name, true);
end

--人物特效展示
function TableLayer:ShowGameRenwuSpecialEffects(seat,type1,isMove)--seat位置0-2
    --人物动画列表
    local RenwuAnimTable = {--type1=1老头，2女孩，3地主，4地主婆
        {
            name = "laotou",
            json = "doudizhu/game/renwu/man/laotou.json",
            atlas = "doudizhu/game/renwu/man/laotou.atlas",
        },
        {
            name = "nvhai",
            json = "doudizhu/game/renwu/woman/nvhai.json",
            atlas = "doudizhu/game/renwu/woman/nvhai.atlas",
        },
        {
            name = "dizhu",
            json = "doudizhu/game/renwu/LandLord/dizhu.json",
            atlas = "doudizhu/game/renwu/LandLord/dizhu.atlas",
        },
        {
            name = "dizhupo",
            json = "doudizhu/game/renwu/LandLordShiva/dizhupo.json",
            atlas = "doudizhu/game/renwu/LandLordShiva/dizhupo.atlas",
        },
    }
    local index = seat+1;

    local renwu_animation = self["Image_renwu"..index]:getChildByName("renwu"..type1)
    if renwu_animation then
        if isMove then
            renwu_animation:removeFromParent();
        end
        return;
    end

    if isMove then
        self["Image_renwu"..index]:removeAllChildren();
        return;
    end

    self["Image_renwu"..index]:removeAllChildren();

    addSkeletonAnimation(RenwuAnimTable[type1].name ,RenwuAnimTable[type1].json,RenwuAnimTable[type1].atlas);
    local skeleton_animation = createSkeletonAnimation(RenwuAnimTable[type1].name ,RenwuAnimTable[type1].json,RenwuAnimTable[type1].atlas);

    self["Image_renwu"..index]:addChild(skeleton_animation);

    skeleton_animation:setAnimation(0,RenwuAnimTable[type1].name, true);

    
end

--游戏的特效(每次都需要重新创建)
function TableLayer:ShowGameSpecialEffects(type1,seat) --(地主出现，警报灯)需要位置
    luaPrint("TableLayer:ShowGameSpecialEffects",type1,seat)
    if isPlaying  == false then--非游戏状态
       return;
    end

    if type1 == 1 or type1 == 9 then
        if seat<0 or seat>2 then
            return;
        end
    end

    local GameAnim = {--type1= 1地主出现2，春天3，反春天4，飞机5，连队6，顺子7，天王炸，8炸弹,9警报灯
        {
        name = "dizhuchuxian",
        json = "doudizhu/game/dizhuchuxian/dizhuchuxian.json",
        atlas = "doudizhu/game/dizhuchuxian/dizhuchuxian.atlas",
        },
        {
        name = "chuntian",
        json = "doudizhu/game/chuntian/chuntian.json",
        atlas = "doudizhu/game/chuntian/chuntian.atlas",
        },
        {
        name = "fanchun",
        json = "doudizhu/game/fanchun/fanchun.json",
        atlas = "doudizhu/game/fanchun/fanchun.atlas",
        },
        {
        name = "feiji",
        json = "doudizhu/game/feiji/feiji.json",
        atlas = "doudizhu/game/feiji/feiji.atlas",
        },
        {
        name = "liandui",
        json = "doudizhu/game/liandui/liandui.json",
        atlas = "doudizhu/game/liandui/liandui.atlas",
        },
        {
        name = "shunzi",
        json = "doudizhu/game/shunzi/shunzi.json",
        atlas = "doudizhu/game/shunzi/shunzi.atlas",
        },
        {
        name = "tianwangzha",
        json = "doudizhu/game/tianwangzha/tianwangzha.json",
        atlas = "doudizhu/game/tianwangzha/tianwangzha.atlas",
        },
        {
        name = "zhadan",
        json = "doudizhu/game/zhadan/zhadan.json",
        atlas = "doudizhu/game/zhadan/zhadan.atlas",
        },
        {
        name = "jingbaodeng",
        json = "doudizhu/game/jingbaodeng/jingbaodeng.json",
        atlas = "doudizhu/game/jingbaodeng/jingbaodeng.atlas",
        },

    }
    addSkeletonAnimation(GameAnim[type1].name ,GameAnim[type1].json,GameAnim[type1].atlas);
    local skeleton_animation = createSkeletonAnimation(GameAnim[type1].name ,GameAnim[type1].json,GameAnim[type1].atlas);
    
    if type1 == 1 then --地主出现需要位置
        local biao = self.Node_6:getChildByName("dizhubiao");
        if biao then
            biao:removeFromParent();
        end

        if seat then
            local Pos = {cc.p(220,305),cc.p(1000,590),cc.p(280,590)}
            skeleton_animation:setPosition(Pos[seat+1])
        end
        skeleton_animation:setName("dizhubiao");

        skeleton_animation:setAnimation(0,GameAnim[type1].name, false);
    elseif type1 == 9 then --警报灯出现需要位置
        if seat then
            local Pos = {cc.p(360,270),cc.p(900,430),cc.p(360,430)}
            skeleton_animation:setPosition(Pos[seat+1])
        end
        skeleton_animation:setAnimation(0,GameAnim[type1].name, true);
        skeleton_animation:setName("jingbaodeng"..seat)
        performWithDelay(self,function() skeleton_animation:removeFromParent() end,1.5);
    else
        if type1 == 7 then--天王炸播放时放大
            skeleton_animation:setScale(1.5);
        end
        skeleton_animation:setPosition(cc.p(630,360));
        skeleton_animation:setAnimation(0,GameAnim[type1].name, false);
    end

    self.Node_6:addChild(skeleton_animation);

end

--创建移除 人物升级的特效
function TableLayer:ShowDZChangeEffect(isShow,viewSeat)
    local effect = self.Image_bg:getChildByName("effrctsj");
    if effect then
        effect:removeFromParent();
    end

    if isShow then
         local GameAnim = {
            {
            name = "shengji",
            json = "doudizhu/game/shengji/shengji.json",
            atlas = "doudizhu/game/shengji/shengji.atlas",
            }
        }


        addSkeletonAnimation(GameAnim[1].name ,GameAnim[1].json,GameAnim[1].atlas);
        local skeleton_animation = createSkeletonAnimation(GameAnim[1].name ,GameAnim[1].json,GameAnim[1].atlas);
        self.Image_bg:addChild(skeleton_animation);
        skeleton_animation:setName("effrctsj");
        skeleton_animation:setAnimation(0,GameAnim[1].name, false);
        --获取人物的坐标
        local index = viewSeat+1;
        skeleton_animation:setPosition(self["Image_renwu"..index]:getPosition());
    end
end

--游戏输赢的特效展示
function TableLayer:ShowGameEndSpecialEffects(score)

    local maskLayer = CCLayerColor:create(ccc4(0, 0, 0, 120), 1280*2, 720*2);
    maskLayer:setName("maskLayer")
    maskLayer:setPosition(-640,-360);
    self.Node_6:addChild(maskLayer,15);
    local gameEndTable = {};
    if tonumber(score) > 0 then
        gameEndTable = { 
            name = "shengli",
            json = "doudizhu/game/result/shengli.json",
            atlas = "doudizhu/game/result/shengli.atlas",
        }
    else
        gameEndTable = { 
            name = "shibai",
            json = "doudizhu/game/result/shibai.json",
            atlas = "doudizhu/game/result/shibai.atlas",
        }
    end
       
    addSkeletonAnimation(gameEndTable.name ,gameEndTable.json,gameEndTable.atlas);
    local skeleton_animation = createSkeletonAnimation(gameEndTable.name ,gameEndTable.json,gameEndTable.atlas);
    maskLayer:addChild(skeleton_animation);
    local size = maskLayer:getContentSize();
    skeleton_animation:setPosition(cc.p(size.width/2,size.height/2));

    skeleton_animation:setAnimation(0,gameEndTable.name, false);
    performWithDelay(self,function() maskLayer:removeFromParent() end,2);
end
--逻辑位置转换出牌图片类型
function TableLayer:RealSeatNoToOutType(realSeatNo)
    local viewSeatNo = self.tableLogic:logicToViewSeatNo(realSeatNo);
    if viewSeatNo == 0 then
        return ClockType.Game_Me_OutCard;
    elseif viewSeatNo == 1 then
        return ClockType.Game_Right_OutCard;
    elseif viewSeatNo == 2 then
        return ClockType.Game_Left_OutCard;
    end
    return ClockType.Game_Me_OutCard;
end
--遊戲開始其他玩家手牌數量設置的動畫
function TableLayer:OtherCardAction()
    local time = 0.05;
    self:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
        self.rightCardNum = self.rightCardNum+1;
        self.leftCardNum = self.leftCardNum+1;
        self:SetOtherCardNum(1,self.rightCardNum);
        self:SetOtherCardNum(2,self.leftCardNum);
    end)),17));
end
--設置其他玩家手牌數量
function TableLayer:SetOtherCardNum(viewSeatNo,cardNum)
    self["AtlasLabel_paishu"..(viewSeatNo+1)]:setString(cardNum);
end
--設置其他玩家手牌數量減少
function TableLayer:ReduceOtherCradNum(viewSeatNo,cardNum)
    if viewSeatNo == 1 then
        self.rightCardNum = self.rightCardNum - cardNum;
        self:SetOtherCardNum(viewSeatNo,self.rightCardNum);
        local lSeatNo = self.tableLogic:viewToLogicSeatNo(1)
        if self.rightCardNum < 3 and self.rightCardNum > 0 then
            self:ShowGameSpecialEffects(9,viewSeatNo);
            if self.rightCardNum == 1 then
                self:playDdzEffect(lSeatNo,27)
            end
            if self.rightCardNum == 2 then
                self:playDdzEffect(lSeatNo,29)
            end
        end
    elseif viewSeatNo == 2 then
        self.leftCardNum = self.leftCardNum - cardNum;
        self:SetOtherCardNum(viewSeatNo,self.leftCardNum);
        local lSeatNo = self.tableLogic:viewToLogicSeatNo(2)
        if self.leftCardNum < 3 and self.leftCardNum > 0 then
            self:ShowGameSpecialEffects(9,viewSeatNo);
            if self.leftCardNum == 1 then
                self:playDdzEffect(lSeatNo,27)
            end
            if self.leftCardNum == 2 then
                self:playDdzEffect(lSeatNo,29)
            end
        end
    end
end
--显示能否叫的分数
function TableLayer:ShowCallScoreButton(callScore)
    self.Button_yifeng:setEnabled(true);
    self.Button_liangfen:setEnabled(true);
    if callScore >= 1 then
        self.Button_yifeng:setEnabled(false);
    end

    if callScore >= 2 then
        self.Button_liangfen:setEnabled(false);
    end
end
--根据加分得到图片类型
function TableLayer:GetCallTipsType(callScore,lSeatNo)
    local tipType = TipsType.Game_OneScore;
    if callScore == 1 then
        tipType = TipsType.Game_OneScore;
        self:playDdzEffect(lSeatNo,35)
    elseif callScore == 2 then
        tipType = TipsType.Game_TwoScore;
        self:playDdzEffect(lSeatNo,37)
    elseif callScore == 3 then
        tipType = TipsType.Game_ThreeScore;
        self:playDdzEffect(lSeatNo,39)
    elseif callScore == 255 then
        tipType = TipsType.Game_NoCallScore;
        self:playDdzEffect(lSeatNo,41)
    end
    return tipType;
end
--设置玩家的手牌(无动画)
function TableLayer:setMyHandCard(cardData)
    local hanCardData = {};
    for i = 1,#cardData do
        if cardData[i] ~= 0 then
            table.insert(hanCardData,cardData[i]);
        end
    end

    --整理牌从大到小
    for i = 1,#hanCardData do
        for j = i,#hanCardData do
            if self.CGameLogic:GetCardLogicValue(hanCardData[i])<self.CGameLogic:GetCardLogicValue(hanCardData[j]) then
                local temp = hanCardData[i];
                hanCardData[i] = hanCardData[j];
                hanCardData[j] = temp;
            end
        end
    end

    -- luaDump("",hanCardData);
    self.cardLayer:setHandCardData(hanCardData,#hanCardData);
    self.cardLayer:showHandCard(hanCardData,#hanCardData);
end

--刷新玩家手牌
function TableLayer:refreshMyHandCard(cardData)
    local hanCardData = {};
    for i = 1,#cardData do
        if cardData[i] ~= 0 then
            table.insert(hanCardData,cardData[i]);
        end
    end

    --整理牌从大到小
    for i = 1,#hanCardData do
        for j = i,#hanCardData do
            if self.CGameLogic:GetCardLogicValue(hanCardData[i])<self.CGameLogic:GetCardLogicValue(hanCardData[j]) then
                local temp = hanCardData[i];
                hanCardData[i] = hanCardData[j];
                hanCardData[j] = temp;
            end
        end
    end

    -- luaDump("",hanCardData);
    self.cardLayer:setHandCardData(hanCardData,#hanCardData);
    self.cardLayer:refreshHandCard(hanCardData,#hanCardData);
end

--根据出牌类型播放出牌动画
function TableLayer:PlayOutCardAction(cardData,cardCount,lSeatNo)
    local outCard = {};
    self.CGameLogic:CopyMemory(outCard,0,cardData,0,cardCount);
    luaDump(outCard,"根据出牌类型播放出牌动画");
    luaPrint("cardCount",cardCount);
    self.CGameLogic:SortCardList(outCard,cardCount,ST_ORDER);
    local cardType = self.CGameLogic:GetCardType(outCard,cardCount);

    if cardType == CT_THREE_LINE then--飞机
        self:ShowGameSpecialEffects(4);
        self:playDdzEffect(lSeatNo,1)
    elseif cardType == CT_DOUBLE_LINE then--连对
        self:ShowGameSpecialEffects(5);
        self:playDdzEffect(lSeatNo,7)
    elseif cardType == CT_SINGLE_LINE then--顺子
        self:ShowGameSpecialEffects(6);
        self:playDdzEffect(lSeatNo,5)
    elseif cardType == CT_MISSILE_CARD then--天王炸
        self:ShowGameSpecialEffects(7);
        self:playDdzEffect(lSeatNo,11);
        self.allCallScore = self.allCallScore*2;  
        self.AtlasLabel_doublenum:setString(self.allCallScore);
    elseif cardType == CT_BOMB_CARD then--炸弹
        self:ShowGameSpecialEffects(8);
        self:playDdzEffect(lSeatNo,3);
        self.allCallScore = self.allCallScore*2;  
        self.AtlasLabel_doublenum:setString(self.allCallScore);
    elseif cardType == CT_THREE then -- 三个
        local cardValue = outCard[0]%16;
        if cardValue == 1 then
            self:playDdzEffect(lSeatNo,135) 
        else
            self:playDdzEffect(lSeatNo,109+2*(cardValue-1)) 
        end
    elseif cardType == CT_THREE_TAKE_ONE then -- 三带一单
        if cardCount == 8 or cardCount == 12 or cardCount == 16 then--飞机带翅膀
            self:ShowGameSpecialEffects(4);
            self:playDdzEffect(lSeatNo,1)
        else
            self:playDdzEffect(lSeatNo,15)
        end
    elseif cardType == CT_THREE_TAKE_TWO then -- 三带一对
        if cardCount == 10 or cardCount == 15 then--飞机带翅膀
            self:ShowGameSpecialEffects(4);
            self:playDdzEffect(lSeatNo,1)
        else
            self:playDdzEffect(lSeatNo,17)
        end
    elseif cardType == CT_FOUR_TAKE_ONE then -- 四带两单
        self:playDdzEffect(lSeatNo,43)
    elseif cardType == CT_FOUR_TAKE_TWO then -- 四带两对
        self:playDdzEffect(lSeatNo,45) 
    elseif cardType == CT_SINGLE then
        if outCard[0] == 0x4E then--小王
            self:playDdzEffect(lSeatNo,107) 
        elseif outCard[0] == 0x4F then--大王
            self:playDdzEffect(lSeatNo,109) 
        else
            local cardValue = outCard[0]%16;
            if cardValue == 1 then
                self:playDdzEffect(lSeatNo,105) 
            else
                self:playDdzEffect(lSeatNo,79+2*(cardValue-1))
            end
        end
    elseif cardType == CT_DOUBLE then
        local cardValue = outCard[0]%16;
        if cardValue == 1 then
            self:playDdzEffect(lSeatNo,75) 
        else
            self:playDdzEffect(lSeatNo,49+2*(cardValue-1)) 
        end
    end
end

--将剩余的牌数减去已知牌并绘制
function TableLayer:ReduceSvaeCardData(cardData,cardCount)
    if cardCount == nil then
        cardCount = #cardData;
    end

    for k1 = 1,cardCount do--遍历
        for k,v in pairs(self.saveCardData) do  
            if cardData[k1] ~= 0 and self.CGameLogic:GetCardValue(cardData[k1]) == k then
                self.saveCardData[k] = v - 1;
                break;
            end
        end
    end


    self:RefreshSveCard();
end

--设置剩余的牌并绘制
function TableLayer:SetSaveCardData(cardData)
    self.saveCardData = cardData;
    self:RefreshSveCard();
end

--刷新绘制界面
function TableLayer:RefreshSveCard()
    local saveCardLayout = self.Node_6:getChildByName("saveCardLayout");
    if saveCardLayout then
        local saveCardBg = saveCardLayout:getChildByName("saveCardBg");
        if saveCardBg then
            for i = 1,#self.saveCardData do
                local cardNum = saveCardBg:getChildByName("num"..i);
                if cardNum then
                    cardNum:setString(self.saveCardData[i]);
                end
            end
        end
    end
end

------------------------消息处理-------------------
function TableLayer:playerGetReady(data)--游戏准备
    luaPrint("TableLayer:onDDZGameReady");
    local msg = data;
    self:showTips(msg.bDeskStation,TipsType.Game_Ready);

    if msg.bDeskStation == self.tableLogic:getMySeatNo() then
        self:showGameBtn();
    end

    --显示等待其他玩家
    if globalUnit.nowTingId == 0 and msg.bDeskStation == self.tableLogic:getMySeatNo() then
        local bgSize = self.Image_bg:getContentSize();
        local tip = ccui.ImageView:create("hall/game/ddz_fangjian.png");
        tip:setPosition(bgSize.width/2,bgSize.height/2);
        self.Image_bg:addChild(tip,10);
        tip:setName("dengdaitip");
        if self.m_playerLeave then
            self:onClick(self.Button_huanzhuo);
        end
    end
end

function TableLayer:onDDZSendCard(data)--游戏开始
    luaPrint("TableLayer:onDDZSendCard")
    local msg = data._usedata;
    self:ClearData();
    self.isPlaying = true;
    self.mFirstStart = true;
    self:hideWinScore();
    self:flushUserMsg()

    self:InitSaveCardData();
    self.rightCardNum = GameMsg.NORMAL_COUNT;
    self.leftCardNum = GameMsg.NORMAL_COUNT;
    self:SetOtherCardNum(1,self.rightCardNum);
    self:SetOtherCardNum(2,self.leftCardNum);

    self:HideAllUserTips();
    
    self:setMyCard(msg.cbCardData);--设置自己的手牌
    self:ShowDZGetCard(true);
    --self:OtherCardAction();
    self:ReduceSvaeCardData(msg.cbCardData,#msg.cbCardData);
end

function TableLayer:onDDZGameStart(data)--游戏开始
    luaPrint("TableLayer:onDDZGameStart")
    local msg = data._usedata;
    --设置闹钟
    local validviewSeat = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);

    if validviewSeat == 0 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Me_CallLandLord);
    elseif validviewSeat == 1 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Right_CallLandLord);
    else
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Left_CallLandLord);
    end

end 

function TableLayer:onDDZCallScore(data)--用户叫分
    luaPrint("TableLayer:onDDZCallScore")
    if self.isPlaying == false then
        return;
    end
    local msg = data._usedata;
    local validviewSeat = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);
    self:showClock();
    if validviewSeat == 0 then--当前叫分玩家
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Me_CallLandLord);
        --显示能否叫的分数
        self:ShowCallScoreButton(msg.cbCurrentScore);
    elseif validviewSeat == 1 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Right_CallLandLord);
    else
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Left_CallLandLord);
    end
    
    --叫分分数
    self:showTips(msg.wCallScoreUser,self:GetCallTipsType(msg.cbUserCallScore,msg.wCallScoreUser));
end 

function TableLayer:onDDZBankerInfo(data)--庄家信息
    luaPrint("TableLayer:onDDZBankerInfo")
    if self.isPlaying == false then
        return;
    end
    local msg = data._usedata;
    self:HideAllUserTips();
    self:showClock();
    local viewSeatNo = self.tableLogic:logicToViewSeatNo(msg.wBankerUser);
    luaPrint("庄家信息---------------",viewSeatNo);
    --创建加倍
    if viewSeatNo ~= 0 then
        self:showDoubleClock(ClockTime.Game_Double,ClockType.Game_Me_Double);
    else
        for k,v in pairs(msg.cbBankerCard) do--将补的3张牌加入手牌
            table.insert(self.cardLayer.cbHandCardData,v);
        end
        self.cardLayer.cbHandCardCount = self.cardLayer.cbHandCardCount+3;
        self:setMyHandCard(self.cardLayer.cbHandCardData);

        self.cardLayer:setTiCardData(msg.cbBankerCard,3);
        self.cardLayer:setUpCardData(msg.cbBankerCard)
        self.cardLayer:setUpCardAction();
    end

    if viewSeatNo ~= 1 then
        self:showDoubleClock(ClockTime.Game_Double,ClockType.Game_Right_Double);
    else
        self.rightCardNum = GameMsg.MAX_COUNT;
        self:SetOtherCardNum(1,self.rightCardNum);
    end

    if viewSeatNo ~= 2 then
        self:showDoubleClock(ClockTime.Game_Double,ClockType.Game_Left_Double);
    else
        self.leftCardNum = GameMsg.MAX_COUNT;
        self:SetOtherCardNum(2,self.leftCardNum);
    end

    self.bankStation = msg.wBankerUser;--存储庄家的逻辑位置

    self:ShowGameSpecialEffects(1,self.tableLogic:logicToViewSeatNo(self.bankStation))
    self:ShowDZChangeEffect(true,self.tableLogic:logicToViewSeatNo(self.bankStation));
    self:flushUserMsg();
    self.bankCallScore = msg.cbBankerScore;
    self:ShowDZGetCard(false,msg.cbBankerCard,msg.cbBankerScore)
    if self.bankStation == self.tableLogic:getMySeatNo() then
        self.allCallScore = self.bankCallScore*2;  
    else
        self.allCallScore = self.bankCallScore;  
    end
    self.AtlasLabel_doublenum:setString(self.allCallScore);
    if TESTTAG == true then
	    --测试用
	    for k,v in pairs(msg.cbBankerCard) do
	        table.insert(self.otherHandCard[msg.wBankerUser+1],v);
	    end
	    if msg.wBankerUser ~= self.tableLogic:getMySeatNo() then
	        local card = {};
	        for k1,v in pairs(self.otherHandCard[msg.wBankerUser+1]) do
	            card[k1-1] = v;
	        end

	        self.CGameLogic:SortCardList(card,#self.otherHandCard[msg.wBankerUser+1],ST_ORDER);

	        for k1,v in pairs(card) do
	            self.otherHandCard[msg.wBankerUser+1][k1+1] = v;
	        end
	        self.cardLayer:setTestCard(self.tableLogic:logicToViewSeatNo(msg.wBankerUser),self.otherHandCard[msg.wBankerUser+1],#self.otherHandCard[msg.wBankerUser+1]);
	    end
    end
    --如果地主是自己则去除自己的手牌
    if viewSeatNo == 0 then
        self:ReduceSvaeCardData(msg.cbBankerCard,#msg.cbBankerCard);
    end

    if self.m_saveCardBtn then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
            self:SaveCardClick(self.m_saveCardBtn);
        end)))
    end
end 

function TableLayer:showMeOutCard(cbCardData)
    luaDump(cbCardData,"要出的牌")
    local outCardData = {};
    for k1,outCard in pairs(cbCardData) do
        if outCard ~= 0 then
            table.insert(outCardData,outCard)
        end
        for k,handCard in pairs(self.cardLayer.cbHandCardData) do
            if outCard == handCard then
                table.remove(self.cardLayer.cbHandCardData,k);
                break;
            end
        end
    end
    self.cardLayer.cbHandCardCount = #self.cardLayer.cbHandCardData;
    --self.cardLayer:setHandCardData(self.cardLayer.cbHandCardData,#self.cardLayer.cbHandCardData);
    self:showClock();
    self.cardLayer:resetUpCardData();  --将保存Up的牌组清零
    self.cardLayer:resetTiCardData();  --将保存提示的牌组清零
    self.cardLayer:showHandCard(self.cardLayer.cbHandCardData,self.cardLayer.cbHandCardCount)  --刷新牌界面self.actionLayer:playCardAnim(0,msg.cardData,msg.cardCount);

    if self.cardLayer.cbHandCardCount < 3 and  self.cardLayer.cbHandCardCount > 0 then
        self:ShowGameSpecialEffects(9,0);
        if self.cardLayer.cbHandCardCount == 1 then
            self:playDdzEffect(self.tableLogic:getMySeatNo(),27)
        end
        if self.cardLayer.cbHandCardCount == 2 then
            self:playDdzEffect(self.tableLogic:getMySeatNo(),29)
        end
    end
     self.cardLayer:setOutCardData(0,outCardData,#outCardData);
     
end

function TableLayer:onDDZOutCard(data)--用户出牌
    luaPrint("TableLayer:onDDZOutCard")
    if self.isPlaying == false then
        return;
    end
    local msg = data._usedata;
    self:showClock();
    if msg.wOutCardUser == self.tableLogic:getMySeatNo() then
        if self.isMeOutCard == false then--自己没有点过出牌按钮
            self:showMeOutCard(msg.cbCardData);
        end
        self.isMeOutCard = false;
        -- for k1,outCard in pairs(msg.cbCardData) do
        --     for k,handCard in pairs(self.cardLayer.cbHandCardData) do
        --         if outCard == handCard then
        --             table.remove(self.cardLayer.cbHandCardData,k);
        --             break;
        --         end
        --     end
        -- end
        -- self.cardLayer.cbHandCardCount = #self.cardLayer.cbHandCardData;
        -- --self.cardLayer:setHandCardData(self.cardLayer.cbHandCardData,#self.cardLayer.cbHandCardData);

        -- self.cardLayer:resetUpCardData();  --将保存Up的牌组清零
        -- self.cardLayer:resetTiCardData();  --将保存提示的牌组清零
        -- self.cardLayer:showHandCard(self.cardLayer.cbHandCardData,self.cardLayer.cbHandCardCount)  --刷新牌界面self.actionLayer:playCardAnim(0,msg.cardData,msg.cardCount);

        -- if self.cardLayer.cbHandCardCount < 3 and  self.cardLayer.cbHandCardCount > 0 then
        --     self:ShowGameSpecialEffects(9,0);
        --     if self.cardLayer.cbHandCardCount == 1 then
        --         self:playDdzEffect(self.tableLogic:getMySeatNo(),27)
        --     end
        --     if self.cardLayer.cbHandCardCount == 2 then
        --         self:playDdzEffect(self.tableLogic:getMySeatNo(),29)
        --     end
        -- end
    else
        if msg.cbCardCount > 0 then --上个用户出牌的话在保存
            self:ReduceOtherCradNum(self.tableLogic:logicToViewSeatNo(msg.wOutCardUser),msg.cbCardCount);
            -- playEffect("doudizhu/effect/ddz_clock.mp3");
            self.otherCardData = {};
            for k,v in pairs(msg.cbCardData) do
                if v>0 then
                    table.insert(self.otherCardData,v);
                end
            end
        end
        self.cardLayer:setOutCardData(self.tableLogic:logicToViewSeatNo(msg.wOutCardUser),msg.cbCardData,msg.cbCardCount);
    end
    --将提示信息清空
    self.tipsData = {};--牌提示的数据
    self.tipsNum = 0;--牌提示数据的第N个提示
    
    self.cardLayer:removeOutCard(self.tableLogic:logicToViewSeatNo(msg.wCurrentUser));

    --去除记牌器出过的牌
    if msg.wOutCardUser ~= self.tableLogic:getMySeatNo() then
        self:ReduceSvaeCardData(msg.cbCardData,msg.cbCardCount);
    end

    self:PlayOutCardAction(msg.cbCardData,msg.cbCardCount,msg.wOutCardUser);
    self.outCardUser = msg.wCurrentUser;
    self:HideTips(msg.wCurrentUser);

    if TESTTAG == true then
	    --测试用显示其他玩家手牌
	    luaDump(self.otherHandCard,"测试用游戏开始----------11111111111")
	    for k1,outCard in pairs(msg.cbCardData) do
	        if self.otherHandCard[msg.wOutCardUser+1] ~= nil then 
	            table.removebyvalue(self.otherHandCard[msg.wOutCardUser+1],outCard);
	        end
	    end 
	    luaDump(self.otherHandCard,"测试用游戏开始----------222222222")

	    for k,v in pairs(self.otherHandCard) do
	        if k-1~= self.tableLogic:getMySeatNo() then
	            self.cardLayer:setTestCard(self.tableLogic:logicToViewSeatNo(k-1),self.otherHandCard[k],#self.otherHandCard[k]);  
	        end
	    end      
    end    

    if msg.wCurrentUser == self.tableLogic:getMySeatNo() and #self.otherCardData>0 then
        luaDump(self.otherCardData,"出的牌");
        luaDump(self.cardLayer.cbHandCardData,"提示的牌");
        luaPrint("提示牌的数量",self.cardLayer.cbHandCardCount);

        local tipsCardCount,tipsCardData =self.CGameLogic:SearchOutCard(self.cardLayer.cbHandCardData,self.cardLayer.cbHandCardCount,self.otherCardData,#self.otherCardData);
        if tipsCardCount == 0 then
            self:showClock(ClockTime.Game_NoCard,ClockType.Game_Me_Pass);
            self.Image_tipNoCard:setVisible(true);
            luaPrint("出现提示");
            self.Image_tipNoCard:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                -- luaPrint("出现提示111111111111111");
                self.Image_tipNoCard:setVisible(false);
            end)));
            return;
        end
    end  
    self:showClock(ClockTime.Game_OutCard,self:RealSeatNoToOutType(msg.wCurrentUser));
    self:CheckHandCard();
end 

function TableLayer:onDDZPassCard(data)--用户放弃
    luaPrint("TableLayer:onDDZPassCard")
    if self.isPlaying == false then
        return;
    end
    local msg = data._usedata;

    self:showTips(msg.wPassCardUser,TipsType.Game_NoOut);
    self:playDdzEffect(msg.wPassCardUser,21)
    self:showClock();
    self.cardLayer:removeOutCard(self.tableLogic:logicToViewSeatNo(msg.wCurrentUser));
    if msg.wPassCardUser == self.tableLogic:getMySeatNo() then
        self.cardLayer:hideUpCardAction();
        self.Image_tipNoCard:setVisible(false);
    end

    if msg.cbTurnOver ~= 0 then
        -- self:HideAllUserTips();
        self.otherCardData = {};
    else--清除自己的數據
        self.Image_tipNoCard:setVisible(false);
    end
    self:HideTips(msg.wCurrentUser);
    local viewSeatNo = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);
    self.outCardUser = msg.wCurrentUser;
    --将提示信息清空
    self.tipsData = {};--牌提示的数据
    self.tipsNum = 0;--牌提示数据的第N个提示

    if #self.otherCardData > 0 and viewSeatNo == 0 then
        luaDump(self.otherCardData,"出的牌");
        luaDump(self.cardLayer.cbHandCardData,"提示的牌");
        luaPrint("提示牌的数量",self.cardLayer.cbHandCardCount);
        local tipsCardCount,tipsCardData =self.CGameLogic:SearchOutCard(self.cardLayer.cbHandCardData,self.cardLayer.cbHandCardCount,self.otherCardData,#self.otherCardData);
        if tipsCardCount == 0 then
            self:showClock(ClockTime.Game_NoCard,ClockType.Game_Me_Pass);
            self.Image_tipNoCard:setVisible(true);
            luaPrint("出现提示");
            self.Image_tipNoCard:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
                luaPrint("出现提示22222222222");
                self.Image_tipNoCard:setVisible(false);
            end)));
            return;
        end
    end
    self:showClock(ClockTime.Game_OutCard,self:RealSeatNoToOutType(msg.wCurrentUser));
    self:CheckHandCard();
end 

function TableLayer:onDDZGameEnd(data)--游戏结束
    luaPrint("TableLayer:onDDZGameEnd")
    if self.isPlaying == false then
        return;
    end
    local msg = data._usedata;

    self:showClock();
    self:HideAllUserTips();
    local delayTime = 0;
    if msg.bChunTian ~= 0 then--春天
        delayTime = 2;
        self:ShowGameSpecialEffects(2,0);
        self.allCallScore = self.allCallScore*2;  
        self.AtlasLabel_doublenum:setString(self.allCallScore);
	    self:playDdzEffect(self.tableLogic:getMySeatNo(),9)
    elseif msg.bFanChunTian ~= 0 then--反春天
        self:ShowGameSpecialEffects(3,0);
        self:playDdzEffect(self.tableLogic:getMySeatNo(),9)
        delayTime = 2;
        self.allCallScore = self.allCallScore*2;  
        self.AtlasLabel_doublenum:setString(self.allCallScore);
    end

    --刷新玩家分数
    for index,score in pairs(msg.lGameScore) do
        local viewSeatNo = self.tableLogic:logicToViewSeatNo(index-1);
        local vIndex = viewSeatNo + 1;
        self.userScoreTable[vIndex] = self.userScoreTable[vIndex] + score;
    end
    self:flushUserScore();


    local mySeatNo = self.tableLogic:getMySeatNo();

    self:showWinScore(msg.lGameScore);--显示输赢分

    local temp = {};

    for k,v in pairs(msg.lGameScore) do
        local viewSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
        temp[viewSeatNo+1] = v;
    end

    local myScore = msg.lGameScore[mySeatNo+1];

    for i=0,PLAY_COUNT-1 do--取消所有用户托管
        self:showTrustee(i,false);
    end

    --将庄家置成-1
    self.bankStation = -1;
    
    self.isGameEnd = true;

    self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function()
        self:ShowGameEndSpecialEffects(msg.lGameScore[mySeatNo+1]);--输赢特效
        self:showResultCard(msg.cbHandCardData,mySeatNo);--显示剩余牌
        for i=1,PLAY_COUNT do--取消所有用户托管
            if temp[i] >= 0 then
                self["AtlasLabel_ying"..i]:setVisible(true);
            else
                self["AtlasLabel_shu"..i]:setVisible(true);
            end
        end
        self.Button_tuoguan:setVisible(false)


        if tonumber(myScore) > 0 then
            playEffect("effect/ddz_You_Win.mp3")
        else
            playEffect("effect/ddz_You_Lose.mp3")
        end
        
        end),cc.DelayTime:create(2),cc.CallFunc:create(function()
            self.isPlaying = false;

            if globalUnit.nowTingId == 0 then
                self.m_showEnd = true;

                if self.m_playerLeave then
                    addScrollMessage("有玩家离开房间");
                end
                self.m_playerLeave = false;

                local score = self.userScoreTable[1];
                local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),globalUnit.selectedRoomID)
                if score < gold then
                    addScrollMessage("您的金币不足,自动退出游戏。");

                    self:onClickExitGameCallBack();

                    return;
                end

                self:showClock(ClockTime.Game_End,ClockType.Game_GameEnd);
                self:showGameBtn(ClockType.Game_Start);--显示开始游戏按钮
                --显示倒计时5秒
                self.Image_rankBg:runAction(cc.Sequence:create(cc.DelayTime:create(ClockTime.Game_End),cc.CallFunc:create(function()
                    -- self:onClick(self.Button_startgame);
                    self.Image_rankBg:stopAllActions();
                    self:onClickExitGameCallBack();
                    addScrollMessage("结算阶段未操作，自动离开房间");
                end)));

            else
                -- if self.Button_zhunbei then
                --     self.Button_zhunbei:setVisible(true)
                -- end
            end

            if leaveFlag ~= -1 then
                local BackCallBack = function(isRemove)
                    local func = function()
                        self.tableLogic:sendUserUp();
                        self.tableLogic:sendForceQuit();
                        self:leaveDesk();  
                    end
                    Hall:exitGame(isRemove,func);
                end
                BackCallBack(5);
                if leaveFlag == 2 then
                    addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。")
                elseif leaveFlag == 0 then

                elseif leaveFlag == 1 then
                    addScrollMessage("您的金币不足!")
                elseif leaveFlag == 3 then
                    addScrollMessage("您长时间未操作!")
                elseif leaveFlag == 4 then

                elseif leaveFlag == 5 then
                    addScrollMessage("VIP房间已关闭,自动退出游戏。")
                end
            end
        end)

    ))

    -- self.tableLogic:sendUserUp();
    -- self.tableLogic:sendForceQuit();
    self:leaveDeskDdz();
    if globalUnit.nowTingId> 0 then
        self:playWillStart()
        if msg.bHaveAction then
            self:showEndLayer();
        end
    end

end

--等待结算
function TableLayer:onContestWaitGameOver(data)
    local msg = data._usedata;

    --显示等待
    self.Image_contestBg:setVisible(true);
    self.Node_contest1:setVisible(true);
    self.Node_contest2:setVisible(false);
    self.AtlasLabel_contestWait:setString(msg.iLeftDesk);

    self.AtlasLabel_maxPlayer:setString(msg.iMatchUserCount);
    self.AtlasLabel_minPlayer:setString(msg.iMatchUserCount/2);
    self.AtlasLabel_myRank:setString(msg.iRankNum);
    self.AtlasLabel_allRank:setString(msg.iMatchUserCount);
end

--通知下一轮
function TableLayer:onContestNextRound(data)
    local msg = data._usedata;

    local doudizhu = require("doudizhu");
    doudizhu.erterRoom = true;
    UserInfoModule:clear(); 

    --显示等待
    self.Image_contestBg:setVisible(true);
    self.Node_contest1:setVisible(false);
    self.Node_contest2:setVisible(true);
    self.AtlasLabel_contestEnter:setString("5:")
    self.AtlasLabel_contestEnter:setTag(5);

    --定时器 每秒-1
    self.AtlasLabel_contestEnter:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        local tag = self.AtlasLabel_contestEnter:getTag();
        if tag <= 0 then
            self.AtlasLabel_contestEnter:stopAllActions();
        else
            self.AtlasLabel_contestEnter:setTag(tag-1);
            self.AtlasLabel_contestEnter:setString((tag-1)..":");
        end

    end))))

    self.AtlasLabel_maxPlayer:setString(msg.iMatchUserCount*2);
    self.AtlasLabel_minPlayer:setString(msg.iMatchUserCount);
    self.AtlasLabel_myRank:setString(msg.iRankNum);
    self.AtlasLabel_allRank:setString(msg.iMatchUserCount);

   --创建帧动画

    --///////////////动画开始//////////////////////
    display.loadSpriteFrames("doudizhu/contest/ddz_loading.plist", "doudizhu/contest/ddz_loading.png");

    local frames = display.newFrames("ddz_loading_%d.png", 0, 12);

    if frames then
        local _activeFrameAnimation = display.newAnimation(frames, 0.08);
        local animate= cc.Animate:create(_activeFrameAnimation);
        local aimateAction=cc.RepeatForever:create(animate);
        self.Image_contestEnterLoading:runAction(aimateAction);
    end 
 
end

--输赢
function TableLayer:onContestAward(data)
    local msg = data._usedata;

    local effect = "henyihan";

    if msg.iRankAward == 0 then
        effect = "henyihan";
    else
        effect = "gongxihuojiang";
    end

    --先清除界面上所有东西
    self.Node_contestEnd:removeAllChildren();

    self.Image_contestBg:setVisible(false);
    self.Node_contest1:setVisible(false);
    self.Node_contest2:setVisible(false);

    local skeleton_animation = createSkeletonAnimation(effect,"doudizhu/game/contest/"..effect..".json","doudizhu/game/contest/"..effect..".atlas");

    if skeleton_animation then
        self.Node_contestEnd:addChild(skeleton_animation);
        skeleton_animation:setAnimation(0,effect, false);         
        skeleton_animation:setPosition(640,460);

        local animSize = skeleton_animation:getContentSize();

        --界面上显示按钮和第几名
        local rankText = FontConfig.createWithCharMap(msg.iRankNum,"doudizhu/contest/ddz_paiminzitiao.png",65,94,"0");
        rankText:setPosition(animSize.width/2,-50);
        skeleton_animation:addChild(rankText);

        local rankButton = ccui.Button:create("doudizhu/contest/ddz_anniu.png","doudizhu/contest/ddz_anniu-on.png");
        rankButton:setPosition(animSize.width/2,-350);
        skeleton_animation:addChild(rankButton);
        rankButton:onClick(function(sender)
            self:onClickExitGameCallBack();
        end)

        local buttonSize = rankButton:getContentSize();
        --创建文字
        local tipText = ccui.ImageView:create("doudizhu/contest/ddz_zhidaole.png");
        tipText:setAnchorPoint(0,0.5);
        tipText:setPosition(30,buttonSize.height/2+10);
        rankButton:addChild(tipText);

        --创建倒计时
        local tipCount = FontConfig.createWithCharMap("10:","doudizhu/contest/ddz_anniuzitiao.png",25,43,"+");
        tipCount:setPosition(tipText:getPositionX()+tipText:getContentSize().width+40,tipText:getPositionY()-5);
        tipCount:setTag(10);
        rankButton:addChild(tipCount);

        tipCount:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            local tag = tipCount:getTag();
            if tag <= 0 then
                tipCount:stopAllActions();
                self:onClickExitGameCallBack();
            else
                tipCount:setTag(tag-1);
                tipCount:setString((tag-1)..":");
            end

        end))))

    end
end


--显示游戏结束界面
function TableLayer:showEndLayer()
    local endlayer = self:getChildByName("EndLayer");
    if endlayer then
        endlayer:removeFromParent();
    end
    local endlayer = EndLayer:create(self)
    endlayer:setLocalZOrder(9999);
    self:addChild(endlayer);
end

function TableLayer:onDDZTrustee(data)--用户托管出牌
    luaPrint("TableLayer:onDDZTrustee")
    local msg = data._usedata;

    self:showTrustee(msg.wCurrentUser,msg.bTrustee)
end 

function TableLayer:onDDZDouble(data)--用户加倍
    luaPrint("TableLayer:onDDZDouble")
    if self.isPlaying == false then
        return;
    end
    local msg = data._usedata;
    local viewSeatNo = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);
    local doubleClock = self.Node_3:getChildByName("DoubleClock"..viewSeatNo);
    if doubleClock then
        doubleClock:removeFromParent();
    end
    if viewSeatNo == 0 then--是自己则将按钮隐藏
        self:showGameBtn();
    end

    if msg.bDouble then
        self:playDdzEffect(msg.wCurrentUser,31)
        self:showTips(msg.wCurrentUser,TipsType.Game_DoubleScore);
        if viewSeatNo == 0 or self.bankStation == self.tableLogic:getMySeatNo() then
            self.allCallScore = self.allCallScore+self.bankCallScore;
        end
    else
        self:playDdzEffect(msg.wCurrentUser,33)
        self:showTips(msg.wCurrentUser,TipsType.Game_NoScore);
    end
    self.AtlasLabel_doublenum:setString(self.allCallScore);

    if msg.wBankUser~=GameMsg.INVALID_CHAIR then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
            self:HideAllUserTips();
        end)));
        self:showClock(ClockTime.Game_OutCard,self:RealSeatNoToOutType(msg.wBankUser));
        self.outCardUser = msg.wBankUser;
        --出牌时托管按钮显示
        self.Button_tuoguan:setVisible(true);

        --将所有的加倍闹钟去除
        for i = 0,2 do
            local doubleClock = self.Node_3:getChildByName("DoubleClock"..i);
            if doubleClock then
                doubleClock:removeFromParent();
            end
        end

    end
    self:CheckHandCard();
end 

function TableLayer:onDDZNoCard(data)--用户要不起
    luaPrint("TableLayer:onDDZNoCard")
    local msg = data._usedata;
end


-- enum eRobStat 
-- { 
--     eRob_Null,    ///空 
--     eRob_CallRob,  ///叫地主
--     eRob_NoCall,  ///不叫
--     eRob_Rob,    ///抢地主
--     eRob_NoRob,    ///不抢
-- };


function TableLayer:onDDZRobNt(data)--用户叫地主
    luaPrint("TableLayer:onDDZRobNt")
    local msg = data._usedata;

    --显示叫地主状态 和 声音
    if msg.iRobStat ~= 0 then
        self:playDdzEffect(msg.wRobUser,137+2*math.ceil((msg.iRobStat-1)/2));
        self:showTips(msg.wRobUser,TipsType.Game_NoOut+msg.iRobStat);

        --叫地主 抢地主状态时倍数加
        if msg.iRobStat == 1 or msg.iRobStat == 3 then
            if self.bankCallScore == 0 then
                self.bankCallScore = 1;
            else
                self.bankCallScore = self.bankCallScore*2;
            end

            self.AtlasLabel_doublenum:setString(self.bankCallScore);
        end
    end

    --如果不是第一个人则变成叫地主
    local addTemp = 0;
    if msg.bFirstRob == false then
        addTemp = addTemp+3;
    end

    --桌子号是255弹出
    if msg.wCurrentUser == 255 then
        self:showClock();
        return;
    end

    local validviewSeat = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);

    --先隐藏桌面图片
    self:HideTips(msg.wCurrentUser);

    if validviewSeat == 0 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Me_JDZ+addTemp);
    elseif validviewSeat == 1 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Right_JDZ+addTemp);
    else
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Left_JDZ+addTemp);
    end
end

--空闲状态
function TableLayer:gameStationFree(msg)
    luaPrint("TableLayer:gameStationFree")
    self:ClearData();
    self.AtlasLabel_difen:setVisible(true);
    self.AtlasLabel_doublenum:setVisible(true);
    self:ScoreToMoney(self.AtlasLabel_difen,msg.lCellScore);
    self:HideAllUserTips();
    self.isPlaying = false;
    if globalUnit.nowTingId == 0 then
        addScrollMessage("游戏已结束，自动退出房间");
        self:onClickExitGameCallBack();
    else
        -- if self.Button_zhunbei then
        --     self.Button_zhunbei:setVisible(true)
        -- end
    end

    for i=1,PLAY_COUNT do
        if globalUnit.nowTingId == 0 then
            self:ShowGameRenwuSpecialEffects(i-1,0,true)
        else
            -- if msg.bAgree[i] == true then
            --     self:showTips(i-1, 1);
            --     if i-1== self.tableLogic._mySeatNo then
            --         if self.Button_zhunbei then
            --             self.Button_zhunbei:setVisible(false)
            --         end
            --     end
            -- end
        end
    end
end

--发牌状态
function TableLayer:gameStationSend(msg)
    luaPrint("TableLayer:gameStationSend")
    self:ClearData();
    self.isPlaying = true;
    self:HideAllUserTips();
    self.AtlasLabel_difen:setVisible(true);
    self.AtlasLabel_doublenum:setVisible(true);
    self:ScoreToMoney(self.AtlasLabel_difen,msg.lCellScore);

    self:flushUserMsg();

    local validviewSeat = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);
    self:showClock();

    if self.mFirstStart then
        self:refreshMyHandCard(msg.cbHandCardData);
    else
        self:setMyHandCard(msg.cbHandCardData);
    end

    self.mFirstStart = false;
    
    self.rightCardNum = GameMsg.NORMAL_COUNT;
    self.leftCardNum = GameMsg.NORMAL_COUNT;
    self:SetOtherCardNum(1,self.rightCardNum);
    self:SetOtherCardNum(2,self.leftCardNum);
    self:ShowDZGetCard(true);

    self:ReduceSvaeCardData(msg.cbHandCardData,#msg.cbHandCardData);
end

--叫分状态
function TableLayer:gameStationCall(msg)
    luaPrint("TableLayer:gameStationCall")
    self:ClearData();
    self.isPlaying = true;
    self:HideAllUserTips();
    self.AtlasLabel_difen:setVisible(true);
    self.AtlasLabel_doublenum:setVisible(true);
    self:ScoreToMoney(self.AtlasLabel_difen,msg.lCellScore);

    self:flushUserMsg();

    local validviewSeat = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);
    self:showClock();
    if validviewSeat == 0 then--当前叫分玩家
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Me_CallLandLord);
        --显示能否叫的分数
        self:ShowCallScoreButton(msg.cbBankerScore);
    elseif validviewSeat == 1 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Right_CallLandLord);
    else
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Left_CallLandLord);
    end
    --叫分分数
    for k,v in pairs(msg.cbScoreInfo) do
        if v > 0 then
            self:showTips(k-1,self:GetCallTipsType(v,k-1));
        end
    end

    if self.mFirstStart then
        self:refreshMyHandCard(msg.cbHandCardData);
    else
        self:setMyHandCard(msg.cbHandCardData);
    end

    self.mFirstStart = false;
    
    self.rightCardNum = GameMsg.NORMAL_COUNT;
    self.leftCardNum = GameMsg.NORMAL_COUNT;
    self:SetOtherCardNum(1,self.rightCardNum);
    self:SetOtherCardNum(2,self.leftCardNum);
    self:ShowDZGetCard(true);

    self:ReduceSvaeCardData(msg.cbHandCardData,#msg.cbHandCardData);
end

--叫地主状态
function TableLayer:gameStationRobNt(msg)
    luaPrint("TableLayer:gameStationRobNt")
    self:ClearData();
    self.isPlaying = true;
    self:HideAllUserTips();
    self.AtlasLabel_difen:setVisible(true);
    self.AtlasLabel_doublenum:setVisible(true);
    self:ScoreToMoney(self.AtlasLabel_difen,msg.lCellScore);

    self:flushUserMsg();

    --判断是否有人叫过地主
    local robNtFlag = false;

    for k,v in pairs(msg.iRobNTStat) do
        if v == 1 or v == 3 then
            robNtFlag = true;
            break;
        end
    end

    local addTemp = 0;
    if robNtFlag then
        addTemp = addTemp+3;
    end

    local validviewSeat = self.tableLogic:logicToViewSeatNo(msg.wCurrentUser);
    self:showClock();
    if validviewSeat == 0 then--当前叫分玩家
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Me_JDZ+addTemp);
    elseif validviewSeat == 1 then
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Right_JDZ+addTemp);
    else
        self:showClock(ClockTime.Game_Call_Score,ClockType.Game_Left_JDZ+addTemp);
    end
    
    self.bankCallScore = msg.cbBankerScore;--底分
    self.allCallScore = self.bankCallScore;

    self.AtlasLabel_doublenum:setString(self.allCallScore);

    self:setMyHandCard(msg.cbHandCardData);
    self.rightCardNum = GameMsg.NORMAL_COUNT;
    self.leftCardNum = GameMsg.NORMAL_COUNT;
    self:SetOtherCardNum(1,self.rightCardNum);
    self:SetOtherCardNum(2,self.leftCardNum);
    self:ShowDZGetCard(true);

    self:ReduceSvaeCardData(msg.cbHandCardData,#msg.cbHandCardData);
end

--加倍状态
function TableLayer:gameStationDouble(msg)
    luaPrint("TableLayer:gameStationDouble")
    self:ClearData();
    self.isPlaying = true;
    self.AtlasLabel_difen:setVisible(true);
    self.AtlasLabel_doublenum:setVisible(true);
    self:ScoreToMoney(self.AtlasLabel_difen,msg.lCellScore);
    self.bankStation = msg.wBankerUser;--当前庄家赋值
    self:setMyHandCard(msg.cbHandCardData);--设置自己的手牌
    self:showClock();
    self:HideAllUserTips();
    self.bankCallScore = msg.cbBankerScore;
    if self.bankStation == self.tableLogic:getMySeatNo() then
        self.allCallScore = self.bankCallScore*2;
    else
        self.allCallScore = self.bankCallScore;
    end

    for k,v in pairs(msg.cbUserDouble) do
        if k-1 ~= msg.wBankerUser then--过滤庄家
            local viewSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
            if v == 255 then--加倍没有选择
                --创建加倍
                if viewSeatNo == 0 then
                    self:showDoubleClock(ClockTime.Game_Double,ClockType.Game_Me_Double);
                end

                if viewSeatNo == 1 then
                    self:showDoubleClock(ClockTime.Game_Double,ClockType.Game_Right_Double);
                end

                if viewSeatNo == 2 then
                    self:showDoubleClock(ClockTime.Game_Double,ClockType.Game_Left_Double);
                end
            elseif v == 0 then--没有加倍
                self:showTips(k-1,TipsType.Game_NoScore);
            elseif v == 1 then--加倍
                self:showTips(k-1,TipsType.Game_DoubleScore);
                if viewSeatNo == 0 or self.bankStation == self.tableLogic:getMySeatNo() then
                    self.allCallScore = self.allCallScore+self.bankCallScore;
                end
            end
        end
    end
    self.AtlasLabel_doublenum:setString(self.allCallScore);
    self.rightCardNum = GameMsg.NORMAL_COUNT;
    self.leftCardNum = GameMsg.NORMAL_COUNT;
    local bankViewSeat = self.tableLogic:logicToViewSeatNo(self.bankStation);
    if bankViewSeat == 1 then
        self.rightCardNum = GameMsg.MAX_COUNT;
    elseif bankViewSeat == 2 then
        self.leftCardNum = GameMsg.MAX_COUNT;
    end

    self:SetOtherCardNum(1,self.rightCardNum);
    self:SetOtherCardNum(2,self.leftCardNum);

    self:ShowGameSpecialEffects(1,self.tableLogic:logicToViewSeatNo(self.bankStation))
    self:flushUserMsg()

    for index,isTrustee in pairs(msg.cbTrustee) do
        local lSeatNo = index - 1;
        self:showTrustee(lSeatNo,isTrustee);
    end
    self:ShowDZGetCard(false,msg.cbBankerCard,msg.cbBankerScore);

    self:ReduceSvaeCardData(msg.cbHandCardData,#msg.cbHandCardData);

end
--游戏进行状态
function TableLayer:gameStationPlaying(msg)
    luaPrint("TableLayer:gameStationPlaying")
    --去除加倍闹钟
    for i = 0,2 do
        local doubleClock = self.Node_3:getChildByName("DoubleClock"..i);
        luaPrint("移除doubleClock",doubleClock)
        if doubleClock then
            doubleClock:removeFromParent();
        end
    end

    self:ClearData();
    self.cardLayer:resetUpCardData();  --将保存Up的牌组清零
    self.cardLayer:resetTiCardData();  --将保存提示的牌组清零
    self.isPlaying = true;
    self.AtlasLabel_difen:setVisible(true);
    self.AtlasLabel_doublenum:setVisible(true);
    self:ScoreToMoney(self.AtlasLabel_difen,msg.lCellScore);

    self.cardLayer:removeAllOutCard(); --清除所有牌值
    self.bankStation = msg.wBankerUser;--当前庄家赋值
    self.outCardUser = msg.wCurrentUser;
    self:setMyHandCard(msg.cbHandCardData);--设置自己的手牌
    self:showClock();
    self:HideAllUserTips();

    if msg.cbTurnCardCount>0 then--将出牌的数据保存并显示
        for i = 1,msg.cbTurnCardCount do
            self.otherCardData[i] = msg.cbTurnCardData[i];
        end
        -- self.cardLayer:setResultCard(self.tableLogic:logicToViewSeatNo(msg.wTurnWiner),self.otherCardData,msg.cbTurnCardCount);
    end

    for k,v in pairs(msg.cbSecondTurnCardCount) do
        if k-1 ~= msg.wCurrentUser and v~=0 then
            if v == 255 then
                self:showTips(k-1,TipsType.Game_NoOut);
            else
                local outCardData = {};
                for i = 1,v do
                    outCardData[i] = msg.cbSecondTurnCardData[k][i];
                end
                self.cardLayer:setResultCard(self.tableLogic:logicToViewSeatNo(k-1),outCardData,v);
            end
        end
    end

    self.rightCardNum = msg.cbHandCardCount[self.tableLogic:viewToLogicSeatNo(1)+1];
    self.leftCardNum = msg.cbHandCardCount[self.tableLogic:viewToLogicSeatNo(2)+1];

    self:SetOtherCardNum(1,self.rightCardNum);
    self:SetOtherCardNum(2,self.leftCardNum);

    --地主的标志显示
    self:ShowGameSpecialEffects(1,self.tableLogic:logicToViewSeatNo(self.bankStation))
    self:flushUserMsg();

    --设置记牌器剩余牌的张数
    -- if msg.cbDistributing then
        self:SetSaveCardData(msg.cbDistributing);
        -- self:ReduceSvaeCardData(msg.cbHandCardData,#msg.cbHandCardData);
    -- end

    for index,isTrustee in pairs(msg.cbTrustee) do
        local lSeatNo = index - 1;
        self:showTrustee(lSeatNo,isTrustee);
    end
    self.bankCallScore = msg.cbBankerScore;--底分
    if self.bankStation == self.tableLogic:getMySeatNo() then
        self.allCallScore = self.bankCallScore*2;
    else
        self.allCallScore = self.bankCallScore;
    end
    --加倍
    for k,v in pairs(msg.cbUserDouble) do
        if v == 1 and (k-1 == self.tableLogic:getMySeatNo() or self.bankStation == self.tableLogic:getMySeatNo()) then--加倍
            self.allCallScore = self.allCallScore+self.bankCallScore;
        end
    end
    self.allCallScore = self.allCallScore*math.pow(2,msg.cbBombCount);
    self.AtlasLabel_doublenum:setString(self.allCallScore);

    self:ShowDZGetCard(false,msg.cbBankerCard,msg.cbBankerScore);

    if msg.wCurrentUser == self.tableLogic:getMySeatNo() and #self.otherCardData>0 then
        local tipsCardCount,tipsCardData =self.CGameLogic:SearchOutCard(self.cardLayer.cbHandCardData,self.cardLayer.cbHandCardCount,self.otherCardData,#self.otherCardData);
        if tipsCardCount == 0 then
            self:showClock(ClockTime.Game_NoCard,ClockType.Game_Me_Pass);
            return;
        end
    end

    self:showClock(ClockTime.Game_OutCard,self:RealSeatNoToOutType(msg.wCurrentUser));
    
end

------------------音乐播放-------------------
function TableLayer:playBcbmMusic(code)
    local rootPath = "benchibaoma/game/music/"
    if code == 2 then
        audio.playMusic(rootPath..musicTable[2], true);
        return;
    end

    audio.playSound(rootPath..musicTable[code], false);
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

--获取其他用户的信息
function TableLayer:getOthersTable()
    local othersTable = {};
    for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
            table.insert(othersTable,userInfo)
        end
    end

    -- for i=1,30 do
    --     local userInfo = {}
    --     userInfo.szName = "111111111"
    --     userInfo.i64Money = "12154500"
    --     table.insert(othersTable,userInfo)
    -- end
    
    return othersTable;
end

--添加用户
function TableLayer:addUser(deskStation, bMe)
    if not self:isValidSeat(deskStation) then 
        return;
    end
    
    local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
    local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

    self:flushUserMsg()

    -- local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
    -- local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
    -- if bSeatNo == self.tableLogic._mySeatNo  then
    --     self.tableLogic:sendMsgReady();
    -- end
end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
    
    if not self:isValidSeat(seatNo) then 
        return;
    end

    if seatNo == 0 then
        leaveFlag = bLock;

        if self.isPlaying == false then
            local BackCallBack = function(isRemove)
                local func = function()
                    self.tableLogic:sendUserUp();
                    self.tableLogic:sendForceQuit();
                    self:leaveDesk();    
                end
                Hall:exitGame(isRemove,func);
            end
            BackCallBack(5);
            if leaveFlag == 2 then
                addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。")
            elseif leaveFlag == 0 then

            elseif leaveFlag == 1 then
                addScrollMessage("您的金币不足!")
            elseif leaveFlag == 3 then
                addScrollMessage("您长时间未操作!")
            elseif leaveFlag == 4 then

            elseif leaveFlag == 5 then
                addScrollMessage("VIP房间已关闭,自动退出游戏。")
            end
        end
        return;
    else
        if globalUnit.nowTingId == 0 then
            if self.m_showEnd then
                addScrollMessage("有玩家离开房间");
            end

            self.m_playerLeave = true;

            local dengdaitip = self.Image_bg:getChildByName("dengdaitip");
            if dengdaitip then
                self:onClick(self.Button_huanzhuo);
            end
            return;
        end
    end
    self:flushUserMsg();

    -- self:HideTips(seatNo);
    -- self["Image_tips"..(seatNo+1)]:setVisible(false);

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
    luaPrint("设置玩家分数显示隐藏 ------------ seatNo "..seatNo)
    if not self:isValidSeat(seatNo) then
        return;
    end
    
    luaPrint("设置玩家分数显示隐藏")
    seatNo = seatNo + 1;

    -- self.playerNodeInfo[seatNo]:showUserMoney(visible);
end

function TableLayer:leaveDesk(source)
    globalUnit.isEnterGame = false;
    self:stopAllActions();
    _instance = nil;
    self.tableLogic:stop();
    if source == nil then
        globalUnit.isEnterGame = false;
        if globalUnit.nowTingId == 0 then
            RoomLogic:close();
        end
    end
end

function TableLayer:leaveDeskDdz(source)
    luaPrint("leaveDeskDdz",self._bLeaveDesk)
    if not self._bLeaveDesk then
        self._bLeaveDesk = true;

    end

    -- globalUnit.isEnterGame = false;
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
	self.isPlaying = false;
end

--后台回来
function TableLayer:refreshBackGame(data)
    luaPrint("后台回来-----------refreshBackGame")
    if device.platform == "windows" then
		return;
	end
	if RoomLogic:isConnect() then

		self.isPlaying = false;

		self:stopAllActions();

        if self.isGameEnd then
            local maskLayer = self.Node_6:getChildByName("maskLayer")
            if (maskLayer) then
                maskLayer:removeFromParent();
            end
            if globalUnit.nowTingId == 0 then 
                self:showGameBtn(ClockType.Game_Start);--显示开始游戏按钮
            end
        else
            self.tableLogic._bSendLogic = false;
            self.tableLogic:sendGameInfo();
        end

        for i=0,2 do
            local jingbaodeng = self.Node_6:getChildByName("jingbaodeng"..i)
            if jingbaodeng then
                jingbaodeng:removeFromParent();
            end
        end
		
	end
end

--充值
function TableLayer:DealBankInfo(data)
    local realSeat = self.tableLogic:getlSeatNo(data.UserID);

    local viewSeatNo = self.tableLogic:logicToViewSeatNo(realSeat);
    local vIndex = viewSeatNo + 1;
    self.userScoreTable[vIndex] = self.userScoreTable[vIndex] + data.OperatScore;
    self:flushUserScore();
end

--即将开始 
function TableLayer:playWillStart()
    if self.isPlaying == true then
        return;
    end
    
    local winSize = cc.Director:getInstance():getWinSize()
    local jijiangkaishi = createSkeletonAnimation("jijiangkaishi","game/jijiangkaishi.json","game/jijiangkaishi.atlas");
    if jijiangkaishi then
        jijiangkaishi:setPosition(winSize.width/2,winSize.height/2);
        jijiangkaishi:setAnimation(1,"5s", false);
        self:addChild(jijiangkaishi,999);
        jijiangkaishi:setLocalZOrder(10000);
    end
    self.willStartSpine = jijiangkaishi;
    self:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function() 
        if self.willStartSpine then
            self.willStartSpine:removeFromParent();
        end
        self.willStartSpine = nil;
        
    end)))
end

return TableLayer
