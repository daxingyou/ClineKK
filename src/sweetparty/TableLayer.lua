local TableLayer = class("TableLayer", BaseWindow)
local TableLogic = require("sweetparty.TableLogic");
local SweetLayer = require("sweetparty.SweetLayer");
local SweetSprite = require("sweetparty.SweetSprite");
-- local GameRuleLayer = require("sweetparty.GameRuleLayer");
local BackTipLayer = require("sweetparty.BackTipLayer");
local SweetPartyInfo = require("sweetparty.sweetpartyInfo");
local GuildLayer = require("sweetparty.GuildLayer");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

local SINGLE_GOLD_CONFIG_LENGTH = 5;
local SINGLE_SWEET_GOLD_CONFIG = {
    [1] = { 0.1 },
    -- 体验
    [2] = { 0.1, 0.5, 1,5,10 },
    -- 初级
    [3] = { 0.5, 1, 5, 10, 50 },
    -- 中级
    [4] = { 5, 10, 50, 100, 200 },
    -- 高级
    [5] = { 1, 5, 10, 50, 100 , 200 },-- 土豪场
};

local SINGLE_SWEET_BEISHU_CONFIG = {
    [1] = { 1 },
    -- 体验
    [2] = {  1,2,3,4,5 },
    -- 初级
    [3] = {  1,2,3,4,5 },
    -- 中级
    [4] = {  1,2,3,4,5 },
    -- 高级
    [5] = { 1,2,3,4,5 },-- 土豪场
};

local SINGLE_GOLD_CONFIG = {
    [147] = 1,
    [146] = 2,
    [160] = 3,
    [161] = 4,
    [150] = 5,
};

local REMOVE_SWEET_SCORE = {
    [1] = { 2, 4, 5, 8, 10, 20, 30, 50, 100, 200, 400, 450, 500 },
    [2] = { 4, 5, 10, 20, 30, 50, 100, 250, 500, 750, 800, 1000, 1200 },
    [3] = { 5, 10, 20, 40, 80, 160, 500, 1000, 2000, 5000, 6000, 7000, 8000 },
    [4] = { 10, 30, 50, 60, 100, 750, 1000, 10000, 20000, 50000, 60000, 70000, 80000 },
    [5] = { 20, 50, 100, 500, 1000, 2000, 5000, 20000, 50000, 60000, 80000, 100000, 100000 },
}

local SWEET_PNG_NAME = {
    [TableLogic.SWEET_TYPE.ORANGE] = "SweetSprite_orange",
    [TableLogic.SWEET_TYPE.RED] = "SweetSprite_red",
    [TableLogic.SWEET_TYPE.YELLOW] = "SweetSprite_yellow",
    [TableLogic.SWEET_TYPE.GREEN] = "SweetSprite_green",
    [TableLogic.SWEET_TYPE.PURPLE] = "SweetSprite_purple",
    [TableLogic.SWEET_TYPE.PASSSWEET] = "SweetSprite_passsweet",
    [TableLogic.SWEET_TYPE.FREESWEET] = "SweetSprite_freesweet",
    [TableLogic.SWEET_TYPE.WINNINGSSWEET] = "SweetSprite_winningssweet",
};

local ZHUSHU = {1};
local ZHUSHU_TOTAL = 5;-- ZHUSHU中元素个数
local POINT = { 1, 5, 10, 50, 100, 200 }
local POINT_TOTAL = 6;-- POINT中元素个数

local Show_zhanji =globalUnit.isShowZJ; --控制更多按钮处是否显示战绩

TableLayer._bInGame = false;-- --用来判断游戏是否有消除，还需要进行下一阶段

TableLayer._nPoint = 1;-- 选择的单注金币序号
TableLayer._nZhuShu = 1;-- 选择的单注金币序号
TableLayer._stageNum = 1; -- 关卡数
TableLayer._nRemoveQueneNum = 1;-- 执行消除的队列数
TableLayer._MaxRmoveNum = 0; -- 单轮次最大消除数
TableLayer._PassSweetNum = 0; -- 左上角显示的消除的过关糖果数
TableLayer._TotalPassSweetNum = 0; -- 用来控制屏幕中间显示消除的过关糖果数
TableLayer._winPoint = 0; -- 当局获奖分数
TableLayer._bFreeGame = false -- 是否有免费次数
TableLayer._nFreeGamelv = 0; -- 免费游戏的倍数
TableLayer._bInFreeGame = false; -- 是否在免费游戏中
TableLayer._bFreeGamePoint = 0; -- 免费游戏获得的分数
TableLayer._nCaiJinPoint = 0; -- 是否有彩金糖果
TableLayer._WinPointType = 0; -- 彩金的中奖类型
TableLayer._RemoveEffect = 0; -- 播放移除的特效
TableLayer._CaijinPointTable = { } -- 存放彩金糖果中奖的数据
TableLayer._tbGoldConfig = SINGLE_SWEET_GOLD_CONFIG[1];
TableLayer._resultTable = { }; -- 用于存放转盘结果的表
TableLayer._bShowWinPoint = false; -- 赢分
TableLayer._bAlreadySendStart = false; -- 用来判断是否需要再次发送协议获取掉落数据
TableLayer._FirstResultTable = { } -- 第一次掉落结果存放表
TableLayer._ResultTable = { } -- 第一次消除后掉落结果存放表
TableLayer._RemoveSequenceTable = { } -- 消除顺序表
TableLayer._iNextFallTable = { } -- 最上面一排糖果显示存放表
TableLayer._PoolPointTable = { } -- 奖池数据
TableLayer._removeSweetNumTable = { } -- 右框显示移除糖果数量表
TableLayer._removeSweetDataTable = { } -- 右框显示移除糖果表
TableLayer._StageSweetTable = { } -- 屏幕中间糖果消除表

-- 游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

    bulletCurCount = 0;

    local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

    local scene = display.newScene();

    scene:addChild(layer);

    layer.runScene = scene;

    return scene;
end
-- 创建类
function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
    Event:clearEventListener();
    local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster);

    globalUnit.isFirstTimeInGame = false;

    return layer;
end

-- 静态函数
function TableLayer:getInstance()
    return _instance;
end

-- 构造函数
function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
    self.super.ctor(self, 0, true);

    self.uNameId = uNameId;
    self.bDeskIndex = bDeskIndex or 0;
    self.bAutoCreate = bAutoCreate or false;
    self.bMaster = bMaster or 0;
    GameMsg.init();
    SweetPartyInfo:init();

    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    display.loadSpriteFrames("sweetparty/SweetSprite.plist", "sweetparty/SweetSprite.png");
    local uiTable = {
--        -- 最外层元素
        Image_bg = "Image_bg",
        Image_6 = "Image_6",
        Node_animation = "Node_animation",
        Image_RightBall = "Image_RightBall",
        Button_moreButton = "Node_button",
        Node_score = "Node_score",
        Button_otherButton = "Button_otherButton",
        Image_youkuang = "Image_youkuang",
        Image_gamekuang = "Image_gamekuang",
        Button_autoStart = "Button_deposit",
        Button_start = "Button_sure",
        Node_Xingxing = "Panel_Xingxing",
        Panel_Game = "Panel_Game",
        Node_StageSweet = "Node_StageSweet",
        Image_FreeTime = "Image_FreeTime",
        Image_stage = "Image_Stage",
        AtlasLabel_StageNum = "AtlasLabel_StageNum",
        AtlasLabel_FreeTime = "AtlasLabel_FreeTime",
        Image_6 = "Image_6",
        Panel_mengban = "Panel_mengban",

        -- Image_gamekuang中的元素
        Image_dikuang = "Image_dikuang",

        -- Button_otherButton中的元素
        Image_otherBtnBg = "Image_otherBtnBg",
        Button_effect = "Button_effect",
        Button_music = "Button_music",
        Button_rule = "Button_rule",
        Button_insurance = "Button_insurance",
        Button_back = "Button_exit",
        Button_zhanji = "Button_zhanji",
        -- Node_score中的元素
        Text_playerMoney = "AtlasLabel_TotalPoint",
        AtlasLabel_wardPool_1 = "AtlasLabel_CurrentPoint",
        Image_PassSweetIcon = "Image_PassSweetIcon",
        Image_RewardSweetIcon = "Image_RewardSweet",
        AtlasLabel_PassSweetNum = "AtlasLabel_PassNum",
        AtlasLabel_RewardSweetNum = "AtlasLabel_RewardSweet",
        AtlasLabel_RewardSweetScore = "AtlasLabel_RewardSweetScore",
        AtlasLabel_ZhuShu = "AtlasLabel_zhushu",
        AtlasLabel_Point = "AtlasLabel_point",
        Button_ZhuShuAdd = "Button_add_zhushu",
        Button_ZhuShuSub = "Button_sub_zhushu",
        Button_PointAdd = "Button_add_point",
        Button_PointSub = "Button_sub_point",
        Node_freesweet = "Node_freesweet",

        -- Image_youkuang中的元素
        Node_ScoreRecord = "Node_ScoreRecord",
        AtlasLabel_grandPoint = "AtlasLabel_grand",
        AtlasLabel_majorPoint = "AtlasLabel_major",
        AtlasLabel_minorPoint = "AtlasLabel_minor",
        AtlasLabel_miniPoint = "AtlasLabel_mini",
    }

    loadNewCsb(self, "sweetparty/TableLayer", uiTable);

    -- 适配
    local framesize = cc.Director:getInstance():getWinSize()
    local addWidth =(framesize.width - 1280) / 4;

    self.Button_otherButton:setPositionX(self.Button_otherButton:getPositionX() + addWidth);

    self:initData();
    self:initUI();
        
    _instance = self;
end


-- 进入
function TableLayer:onEnter()
    self:bindEvent();
    -- 绑定消息
    self.super.onEnter(self);
end

-- 绑定消息
function TableLayer:bindEvent()
    self:pushEventInfo(sweetpartyInfo, "RollResult", handler(self, self.onRollResult));
    self:pushEventInfo(sweetpartyInfo, "SmallGameResult", handler(self, self.onSmallGameResult));

	self:pushEventInfo(sweetpartyInfo, "UpdatePool", handler(self, self.onUpdatePool));

    self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT", handler(self, self.refreshEnterBack));
    -- 进入后台
    self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT", handler(self, self.refreshBackGame));
    -- 后台回来
    self:pushGlobalEventInfo("TEST_CONTROL",handler(self, self.onRecTestControl));
end


-- 初始化数据
function TableLayer:initData()
    self._bInGame = false;
    self._PassSweetNum = 0;
    self._TotalPassSweetNum = 0;
    self._WinPointType = 0;
    -- 用来判断游戏是否有消除，还需要进行下一阶段
    self._stageNum = 1;
    self._MaxRmoveNum = 0;
    self.m_iHeartCount = 0;
    -- 心跳计数
    self.m_maxHeartCount = 3;
    -- 最大心跳计数
    self._bLeaveDesk = false;
    -- false 在桌子上 true 离开桌子

    -- 游戏内消息处理
    self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
    self.tableLogic:enterGame();

    self.tableLogic:setRollFreeTime(0);

    self.playerMoney = 0;
    -- 保存玩家金币

    self.tbSweetNode = { };
    -- 保存转盘，一共6个

    self._bShowAction = false;
    self._nGoldConfigIndex = 1;

    local roomInfo = RoomLogic:getSelectedRoom();
    local goldIndex = SINGLE_GOLD_CONFIG[roomInfo.uRoomID] or 1;
    if globalUnit.iRoomIndex >= 1 and globalUnit.iRoomIndex <= 5 then
        POINT = SINGLE_SWEET_GOLD_CONFIG[goldIndex];
        ZHUSHU = SINGLE_SWEET_BEISHU_CONFIG[goldIndex];
        POINT_TOTAL = #POINT;
        ZHUSHU_TOTAL = #ZHUSHU;
    end
    self:updateBatNodeBtnEnable();
    self:setAwardPoint(0)

    self.m_musicTag = 1;
end

function TableLayer:initUI()
    --转盘效   
--    self:forstshow();
    self.AtlasLabel_grandPoint:setString("0");
    self.AtlasLabel_majorPoint:setString("0");
    self.AtlasLabel_minorPoint:setString("0");
    self.AtlasLabel_miniPoint:setString("0");

    if Show_zhanji == false then	
        self.Button_zhanji:setVisible(false);
        self.Image_otherBtnBg:setContentSize(70,376);
    else
        self.Button_zhanji:setVisible(true)
        self.Button_zhanji:setPositionY(330)
        self.Button_back:setPositionY(403)
        self.Image_otherBtnBg:setContentSize(70,450)
    end
    -- 基本按钮
    self:initGameNormalBtn();
    -- 初始化桌子显示信息
    self:initGameDesk();

    -- 初始化音效音乐
    self:InitSet();
    self:InitMusic();

    self.Image_RewardSweetIcon:runAction(cc.FadeOut:create(0.001));
    --    self._nodeAnimation = cc.Node:create();
    --    self._nodeAnimation:setPosition(cc.p(139, 0));
    --    self.Image_bg:addChild(self._nodeAnimation);

    -- 屏幕中间消除糖果
    for i = 1, 45 do
        local StageSweet = self.Node_StageSweet:getChildByName("StageSweet_" .. i);
        self._StageSweetTable[i] = StageSweet;
    end

    -- 背景白云
    local size = self.Image_bg:getContentSize();
    self.BaiYun = createSkeletonAnimation("yun", "effects/yun.json", "effects/yun.atlas");
    if self.BaiYun then
        self.BaiYun:setPosition(size.width / 2, size.height / 2);
        self.BaiYun:setAnimation(1, "yun", true);
        self:addChild(self.BaiYun,-1);
    end

    -- 背景气泡
    self.QiPao = createSkeletonAnimation("qipao", "effects/qipao.json", "effects/qipao.atlas");
    if self.QiPao then
        self.QiPao:setPosition(size.width / 2, size.height / 2);
        self.QiPao:setAnimation(1, "qipao", true);
        self.Image_bg:addChild(self.QiPao);
    end


    -- 设置关卡
    self.AtlasLabel_StageNum:setString("1");
    local NodePos = cc.p(self.Button_otherButton:getPosition());
        --区块链bar
     self.m_qklBar = Bar:create("tangguopaidui",self);
     self.Image_bg:addChild(self.m_qklBar);
     self.m_qklBar:setPosition(NodePos.x-100,NodePos.y-45);

    if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self);
	    self:addChild(self.m_logBar);
	end
end


-- 初始化按钮
function TableLayer:initGameNormalBtn()
    -- 下拉菜单
    if self.Button_otherButton then
        self.Button_otherButton:setLocalZOrder(10);
        self.Button_otherButton:onClick(handler(self, self.ClickOtherButtonCallBack))
        self.Button_otherButton:setTag(0);
    end
    -- 规则
    if self.Button_rule then
        self.Button_rule:onClick( function(sender)
            self:ClickRuleCallBack(sender);
        end )
    end
    -- 保险箱
    if self.Button_insurance then
        self.Button_insurance:onClick( function(sender)
            self:ClickInsuranceCallBack(sender);
        end )
    end
    -- 自动开始
    if self.Button_autoStart then
        self.Button_autoStart:onClick( function(sender)
            self:ClickAutoStartBtnCallBack(sender);
        end )
    end
    -- 返回
    if self.Button_back then
        self.Button_back:onClick(handler(self, self.ClickBackCallBack))
    end
    -- 音效
    if self.Button_effect then
        self.Button_effect:onClick( function(sender)
            self:ClickEffectCallBack(sender);
        end )
    end
    -- 音乐
    if self.Button_music then
        self.Button_music:onClick( function(sender)
            self:ClickMusicCallBack(sender);
        end )
    end
    -- 开始
    if self.Button_start then
        self.Button_start:setLocalZOrder(9);
        self.Button_start:onClick( function(sender)
            self:ClickStartBtnCallBack(sender);
        end )
    end
    --战绩
    if self.Button_zhanji then
        self.Button_zhanji:setLocalZOrder(9);
        self.Button_zhanji:onClick(function(sender)
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end)
    end
    if self.Button_ZhuShuAdd then
        self.Button_ZhuShuAdd:onClick( function(sender)
            self:ClickZhushuAddBtnCallBack(sender);
        end )
    end
    if self.Button_ZhuShuSub then
        self.Button_ZhuShuSub:onClick( function(sender)
            self:ClickZhushuSubBtnCallBack(sender);
        end )
    end
    if self.Button_PointAdd then
        self.Button_PointAdd:onClick( function(sender)
            self:ClickPointAddBtnCallBack(sender);
        end )
    end
    if self.Button_PointSub then
        self.Button_PointSub:onClick( function(sender)
            self:ClickPointSubBtnCallBack(sender);
        end )
    end
end

function TableLayer:initGameDesk()
    self.Image_dikuang:loadTexture("sweetparty_4x4.png", UI_TEX_TYPE_PLIST);
    self.Image_PassSweetIcon:loadTexture("SweetSprite_passsweet_Show_1.png", UI_TEX_TYPE_PLIST);
    -- 自己金币数
    self:updateSelfPlayerMoney();
    self:setZhuShuSelectIndex(1);
    self:setPointSelectIndex(1);

    -- 初始化
    for i = 1, 6 do
        local CreateSweetLayer = SweetLayer:create(i, self);
        self.tbSweetNode[#self.tbSweetNode + 1] = CreateSweetLayer;
        CreateSweetLayer:setPosition((i - 1) * 86 + 53, 0);
        self.Panel_Game:addChild(CreateSweetLayer, 20);
    end
    self:updateAutoStartBtn();
    -- 自动开始按钮

    --    self:updateStartBtnIsFree();--开始按钮
end

-- 初始化音乐音效
function TableLayer:InitSet()
    self.Image_otherBtnBg:setLocalZOrder(101);
    -- 音效
    self:updateEffectBtn();
    -- 音乐
    self:updateMusicBtn();
end

-- 初始化背景音乐
function TableLayer:InitMusic(tag)
    local musicState = getMusicIsPlay();
    if musicState then
        if tag~=nil and self.m_musicTag == tag then
            return;
        end

        if tag == nil then
            tag = 1;
        end

        self.m_musicTag = tag;

        audio.playMusic("sweetparty/voice/sound_bg"..tag..".mp3", true)
    else
        audio.stopMusic();
    end
end

-- 下拉菜单
function TableLayer:ClickOtherButtonCallBack(sender)
    if self.actonFinish == false then
        return;
    end
    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    -- 重新设置纹理
    self:InitSet();

    local senderTag = sender:getTag();

    self.actonFinish = false;
    -- 将标志位置成false
    -- 将标志位置成false
    local actionTime = 0.3;
    local moveAction;

    local btnSize = self.Button_otherButton:getContentSize();
    local posX = btnSize.width / 2;
    if senderTag == 0 then
        -- 下拉
        sender:setTag(1);
        if Show_zhanji == true then
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,-450))
        else           
            moveAction = cc.MoveTo:create(actionTime, cc.p(posX, -380))
        end
        sender:loadTextures("sweetparty_gengduo.png", "sweetparty_gengduo-on.png", "sweetparty_gengduo-on.png", UI_TEX_TYPE_PLIST);
    else
        -- 上拉
        sender:setTag(0);
        if Show_zhanji == true then
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,220))
        else
            moveAction = cc.MoveTo:create(actionTime, cc.p(posX, 220))
        end      
        sender:loadTextures("sweetparty_gengduo1.png", "sweetparty_gengduo1-on.png", "sweetparty_gengduo1-on.png", UI_TEX_TYPE_PLIST);
    end
    self.Image_otherBtnBg:runAction(cc.Sequence:create(moveAction, cc.CallFunc:create( function()
        self.actonFinish = true;
    end )));
end

-- 规则
function TableLayer:ClickRuleCallBack(sender)
    if self.actonFinish == false then
        return;
    end

    local GuildLayer = GuildLayer:create();
    self:addChild(GuildLayer, 1000);
end

-- 保险箱
function TableLayer:ClickInsuranceCallBack(sender)
    if self.actonFinish == false then
        return;
    end

    if self.tableLogic:getAutoStartBool() then
        addScrollMessage("自动游戏中，请稍后进行取款操作。");
        return;
    end

    if self._bAlreadySendStart == true and not isHaveBankLayer() then
        -- 开奖状态不弹保险箱
        addScrollMessage("游戏开奖中，请稍后进行取款操作。");
        return;
    end

    createBank( function(data)
        self:DealBankInfo(data)
    end , true);
end

-- 调用保险箱函数
function TableLayer:DealBankInfo(data)
    self.playerMoney = self.playerMoney + data.OperatScore;
    self:ScoreToMoney(self.Text_playerMoney, self.playerMoney);
end

-- 返回
function TableLayer:ClickBackCallBack(sender)
    local roomInfo = RoomLogic:getSelectedRoom();
    local needGold = 0.01
    if needGold > 0 then
        local BackTipLayer = BackTipLayer:create();
        self:addChild(BackTipLayer, 1000);
        local giveBtn = BackTipLayer:getGiveupbtn()
        local saveBtn = BackTipLayer:getSavebtn()


        giveBtn:onClick(function(sender)
            self:onClickExitGameCallBack()
        end)

        saveBtn:onClick(function(sender)
            self.tableLogic:sendGetCaiJinInfoRequest();
            self:onClickExitGameCallBack()
        end)
    else
        self:onClickExitGameCallBack()
    end

end

-- 返回
function TableLayer:onClickExitGameCallBack(isRemove)
    local func = function()
        self.tableLogic:sendUserUp();
        -- self.tableLogic:sendForceQuit();
        self:leaveDesk()
    end

    if isRemove ~= nil then
        Hall:exitGame(isRemove, func);
    else
        Hall:exitGame(false, func);
    end
end

-- 音效
function TableLayer:ClickEffectCallBack(sender)
    if self.actonFinish == false then
        return;
    end
    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    local effectState = getEffectIsPlay();
    luaPrint("音效", effectState);
    if effectState then
        -- 开着音效
        setEffectIsPlay(false);
    else
        setEffectIsPlay(true);
    end
    self:updateEffectBtn();
end

function TableLayer:updateEffectBtn()
    -- 音效
    local effectState = getEffectIsPlay();
    if effectState then
        -- 开着音效
        self.Button_effect:loadTextures("sweetparty_yinxiao1.png", "sweetparty_yinxiao1-on.png", "sweetparty_yinxiao1-on.png", UI_TEX_TYPE_PLIST);
    else
        self.Button_effect:loadTextures("sweetparty_yinxiao2.png", "sweetparty_yinxiao2-on.png", "sweetparty_yinxiao2-on.png", UI_TEX_TYPE_PLIST);
    end
end

-- 音乐
function TableLayer:ClickMusicCallBack(sender)
    if self.actonFinish == false then
        return;
    end
    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    local musicState = getMusicIsPlay();
    luaPrint("音乐", musicState);
    if musicState then
        -- 开着音效
        setMusicIsPlay(false);
    else
        setMusicIsPlay(true);
    end

    self:updateMusicBtn();

    self:InitMusic();
end

function TableLayer:updateMusicBtn()
    local musicState = getMusicIsPlay();
    if musicState then
        -- 开着音效
        self.Button_music:loadTextures("sweetparty_yinyue1.png", "sweetparty_yinyue1-on.png", "sweetparty_yinyue1-on.png", UI_TEX_TYPE_PLIST);
    else
        self.Button_music:loadTextures("sweetparty_yinyue2.png", "sweetparty_yinyue2-on.png", "sweetparty_yinyue2-on.png", UI_TEX_TYPE_PLIST);
    end
end

function TableLayer:ClickPointAddBtnCallBack(sender)
    -- 单注金币
    if self.AtlasLabel_Point then
        local nPoint = self._nPoint + 1;
        if nPoint > POINT_TOTAL then
            nPoint = 1;
        end
        self:setPointSelectIndex(nPoint);
    end
end

function TableLayer:ClickPointSubBtnCallBack(sender)
    -- 单注金币
    if self.AtlasLabel_Point then
        local nPoint = self._nPoint - 1;
        if nPoint < 1 then
            nPoint = POINT_TOTAL;
        end
        self:setPointSelectIndex(nPoint);
    end
end

function TableLayer:ClickZhushuSubBtnCallBack(sender)
    -- 单注金币
    if self.AtlasLabel_ZhuShu then
        local nZhuShu = self._nZhuShu - 1;
        if nZhuShu < 1 then
            nZhuShu = ZHUSHU_TOTAL;
        end
        self:setZhuShuSelectIndex(nZhuShu);
    end
end

function TableLayer:ClickZhushuAddBtnCallBack(sender)
    local nZhuShuConfigIndex = 0;
    -- 单注金币
    if self.AtlasLabel_ZhuShu then
        local nZhuShu = self._nZhuShu + 1;
        if nZhuShu > ZHUSHU_TOTAL then
            nZhuShu = 1;
        end
        self:setZhuShuSelectIndex(nZhuShu);
    end
end

function TableLayer:updateAutoStartBtn()
    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    local bAutoStart = self.tableLogic:getAutoStartBool();
    if bAutoStart then
        -- 开着自动开始
        self.Button_autoStart:loadTextures("sweetparty_quxiaotuoguan.png", "sweetparty_quxiaotuoguan-on.png", "sweetparty_quxiaotuoguan-on.png", UI_TEX_TYPE_PLIST);
    else
        self.Button_autoStart:loadTextures("sweetparty_tuoguan.png", "sweetparty_tuoguan-on.png", "sweetparty_tuoguan2.png", UI_TEX_TYPE_PLIST);
    end
end

function TableLayer:ClickAutoStartBtnCallBack(sender)
    display.loadSpriteFrames("sweetparty/GameScene.plist", "sweetparty/GameScene.png");
    local bAutoStart = self.tableLogic:getAutoStartBool();

    -- 开启自动开始
    if self.tableLogic:getRollFreeTime() == 0 then
        if not bAutoStart then
            local roomInfo = RoomLogic:getSelectedRoom();
            local needGold = 0.01
            local goldTotal = self:getTotalGold();
            if self.playerMoney < needGold then
                showBuyTip(true);
                return;
            elseif self.playerMoney < goldTotal * 100 then
                showBuyTip();
                return;
            end
        end
    end

    self.tableLogic:setAutoStartBool(not bAutoStart);
    self:updateAutoStartBtn();
    self:updateBatNodeBtnEnable();

    if not bAutoStart and not self._bAlreadySendStart then
        self:ClickStartBtnCallBack();
    end
end


function TableLayer:updateBatNodeBtnEnable()
    local bAlreadySendStart = self._bAlreadySendStart;
    local bAutoStart = self.tableLogic:getAutoStartBool();
    if self.Button_ZhuShuAdd then
        self.Button_ZhuShuAdd:setEnabled(not bAlreadySendStart and not bAutoStart and not self._bInFreeGame);
        self.Button_ZhuShuAdd:setEnabled(#ZHUSHU ~= 1)
    end
    if self.Button_ZhuShuSub then
        self.Button_ZhuShuSub:setEnabled(not bAlreadySendStart and not bAutoStart and not self._bInFreeGame);
        self.Button_ZhuShuSub:setEnabled(#ZHUSHU ~= 1)
    end
    if self.Button_PointAdd then
        self.Button_PointAdd:setEnabled(not bAlreadySendStart and not bAutoStart and not self._bInFreeGame);
    end
    if self.Button_PointSub then
        self.Button_PointSub:setEnabled(not bAlreadySendStart and not bAutoStart and not self._bInFreeGame);
    end
    if self.Button_start then
        self.Button_start:setEnabled(not bAlreadySendStart and not bAutoStart);
    end
end

function TableLayer:setInGameBool(bInGame)
    self._bInGame = bInGame;
    self:updateBatNodeBtnEnable();
end

-- 开始按钮
function TableLayer:ClickStartBtnCallBack(sender)
    self.Panel_Game:stopAllActions();
    if self._bAlreadySendStart == true then
        return;
    end


    self._RemoveEffect = 1 --将消除特效重新开始计算
    -- 本局积分置为0
    self.AtlasLabel_wardPool_1:setString(0);
    self._bFreeGame = false;
    self._winPoint = 0;
    -- 按下按钮瞬间就将标志记为正在开始中
    self._nRemoveQueneNum = 1;
    self._FirstResultTable = { }
    self._ResultTable = { }
    self._RemoveSequenceTable = { }
    self._iNextFallTable = { }
    self._PoolPointTable = { }

    -- 刷新自己金币数
    self:updateSelfPlayerMoney();
    -- 刷新奖池
    self.tableLogic:setPoolPoint(self._niPoolPoint);   
    --    if self._bShowSmallGame then
    --        return;
    --    end
    local totalGold = self:getTotalGold();
    local roomInfo = RoomLogic:getSelectedRoom();
    local needGold = 0.01
    local goldTotal = self:getTotalGold();
    if self.tableLogic:getRollFreeTime() == 0 then
        if self.playerMoney < needGold or self.playerMoney < goldTotal * 100 then
            addScrollMessage("金币不足,请充值");
            if self.playerMoney < needGold then
                showBuyTip(true);
            else
                showBuyTip();
            end

            -- 如果在自动游戏，取消自动开始
            if self.tableLogic:getAutoStartBool() then
                self.tableLogic:setAutoStartBool(false);
                self:updateAutoStartBtn();
                self:updateBatNodeBtnEnable();
            end
            return;
        end
    end

    self._bAlreadySendStart = true;
    self:setInGameBool(false);

    local nPointValue = self:getNowSelectPointValue();
    local nZhuShuValue = self:getNowSelectZhuShuValue();
    self.tableLogic:sendStartRoll(nPointValue * 100, nZhuShuValue);
end

-- 检查消除流程
function TableLayer:CheckRemoveSweet()
    local bNextStage = false;
    local FirstResultTable = self._FirstResultTable[self._nRemoveQueneNum];
    local ResultTable = self._ResultTable[self._nRemoveQueneNum];
    local RemoveSequenceTable = self._RemoveSequenceTable[self._nRemoveQueneNum];
    local maxRemoveNum = 0;

    if self._RemoveEffect <5 then
        self._RemoveEffect = self._RemoveEffect + 1;
    end
    self._nRemoveQueneNum = self._nRemoveQueneNum + 1;
    local iNextFallTable = self._iNextFallTable[self._nRemoveQueneNum];
    local callBackFunc = function()
        local callBackFunc = function()
            self:CheckRemoveSweet()
            return;
        end
        for i = 1, self._stageNum + 3 do
            self.tbSweetNode[i]:SecondDropAction(self._stageNum, iNextFallTable[i], callBackFunc);
        end
        return;
    end
    -- 计算每组爆炸的糖果数和糖果
    local removeSweetNumTable = { };
    local removeSweetDataTable = { };
    for i = 1, self._stageNum + 3 do
        removeSweetNumTable[i] = 0;
        removeSweetDataTable[i] = 0;
    end
    -- 获取最大的消除序列数
    for i = 1, self._stageNum + 3 do
        local RemoveTable = { }
        local RemoveSweetTable = { };
        for j = 1, self._stageNum + 3 do
            RemoveTable[j] = RemoveSequenceTable[j][i];
            RemoveSweetTable[j] = FirstResultTable[j][i];
            if RemoveTable[j] > 0 then
                removeSweetNumTable[RemoveTable[j]] = removeSweetNumTable[RemoveTable[j]] + 1;
                removeSweetDataTable[RemoveTable[j]] = RemoveSweetTable[j];
                if RemoveSweetTable[j] == 6 then
                    self._PassSweetNum = self._PassSweetNum + 1;
                    self._TotalPassSweetNum = self._TotalPassSweetNum + 1;
                end
            end
            if RemoveTable[j] > maxRemoveNum then
                maxRemoveNum = RemoveTable[j]
            end
        end
    end

    -- 是否进入下一关
    if self._PassSweetNum >= 15 then
        bNextStage = true;
    end

    self._removeSweetNumTable = removeSweetNumTable;
    self._removeSweetDataTable = removeSweetDataTable;
    self._MaxRmoveNum = maxRemoveNum;
    if maxRemoveNum == 0 then
        self:updatePoolPoint();
        if self._PassSweetNum >= 15 then
            if self._stageNum < 3 then
                self._PassSweetNum = self._PassSweetNum - 15;
            else
                self._stageNum = 1;
                self._PassSweetNum = 0;
                self._TotalPassSweetNum = 0;
            end
        end
        self:setInGameBool(false);
        -- 刷新自己金币数
        self:updateSelfPlayerMoney();
        local actiontime = 1;
        if self._nCaiJinPoint > 0 or self._bFreeGame == true then
            actiontime = 4;
        end
        -- 是否有彩金糖果
        if self._nCaiJinPoint > 0 then
            self:GetCaiJin();
            performWithDelay(self, function()
                for i = 1, 6 do
                    if self.tbSweetNode[i] then
                        self.tbSweetNode[i]:setVisible(false);
                    end
                end                           
                self._bAlreadySendStart = false;
                self:updateBatNodeBtnEnable();    
            end , 2);
            return;
        end
        -- 是否有免费糖果
        if self._bFreeGame == true then
            self.tableLogic:setRollFreeTime(10);
            self:ShowFreeTimeStart();
        else
            if self._bInFreeGame == true and self.tableLogic:getRollFreeTime() == 0 then
                -- 免费游戏次数结束
                self:GetFreeTimePoint(bNextStage);
            end
        end
        local totalGold = self:getTotalGold();
        local roomInfo = RoomLogic:getSelectedRoom();
        local goldTotal = self:getTotalGold();
        local needGold = 0.01
        performWithDelay(self, function()
            for i = 1, 6 do
                if self.tbSweetNode[i] then
                    self.tbSweetNode[i]:setVisible(false);
                end
            end
            if self.tableLogic:getRollFreeTime() == 0 then
                if self.playerMoney < needGold or self.playerMoney < goldTotal * 100 then
                    addScrollMessage("金币不足,请充值");
                    if self.playerMoney < needGold then
                        showBuyTip(true);
                    else
                        showBuyTip();
                    end
                end
            end                    
            self._bAlreadySendStart = false;
            self:updateBatNodeBtnEnable();  
            if self.tableLogic:getAutoStartBool() and not self._bAlreadySendStart then
                self:ClickStartBtnCallBack();
            end
        end , actiontime);
        return;
    end
    self:setInGameBool(true);


    for i = 1, self._stageNum + 3 do
        local NextSweetTable = { };
        local RemoveTable = { }
        for j = 1, self._stageNum + 4 do
            if j == self._stageNum + 4 then
                --                NextSweetTable[j] = iNextFallTable[i];
            else
                NextSweetTable[j] = ResultTable[j][i];
                RemoveTable[j] = RemoveSequenceTable[j][i];
            end

        end
        self.tbSweetNode[i]:setRemoveSequence(RemoveTable)
        self.tbSweetNode[i]:checkDropSweet(NextSweetTable, self._stageNum, self._MaxRmoveNum,self._RemoveEffect,callBackFunc);
    end

    self.AtlasLabel_PassSweetNum:setString(self._PassSweetNum);
end



-- 右边显示消除水果
function TableLayer:ShowRemoveSweet(RemoveSquence)
    for i = 1, self._TotalPassSweetNum do
        if self._StageSweetTable[i] then
            self._StageSweetTable[i]:setVisible(false);
        end
    end
    display.loadSpriteFrames("sweetparty/SweetSprite.plist", "sweetparty/SweetSprite.png");
    local strName = ""
    if self._removeSweetDataTable[RemoveSquence] == 6 or self._removeSweetDataTable[RemoveSquence] == 1 or self._removeSweetDataTable[RemoveSquence] == 2
        or self._removeSweetDataTable[RemoveSquence] == 3 or self._removeSweetDataTable[RemoveSquence] == 4 or self._removeSweetDataTable[RemoveSquence] == 5 then
        strName = SWEET_PNG_NAME[self._removeSweetDataTable[RemoveSquence]] .. "_" .. tostring(self._stageNum) .. ".png";
    elseif self._removeSweetDataTable[RemoveSquence] == 0 then
        return;
    else
        strName = SWEET_PNG_NAME[self._removeSweetDataTable[RemoveSquence]] .. ".png";
    end
    local TotalGold = self:getTotalGold()
    local CurrentWinPoint = 0;
    if self._removeSweetDataTable[RemoveSquence] <= 5 then
        if self._bInFreeGame == true then
            if self._removeSweetNumTable[RemoveSquence] >= 14 then
                if self._removeSweetNumTable[RemoveSquence] == 14 then
                    CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][12 - self._stageNum] * TotalGold / 10 * self._nFreeGamelv;
                elseif self._removeSweetNumTable[RemoveSquence] == 15 then
                    if self._stageNum == 1 or self._stageNum == 2 then
                        CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10 + self._stageNum] * TotalGold / 10 * self._nFreeGamelv;
                    else
                        CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10] * TotalGold / 10 * self._nFreeGamelv;
                    end
                else
                    CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10 + self._stageNum] * TotalGold / 10 * self._nFreeGamelv;
                end
            else
                CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][self._removeSweetNumTable[RemoveSquence] - self._stageNum - 2] * TotalGold / 10 * self._nFreeGamelv;
            end
        else
            if self._removeSweetNumTable[RemoveSquence] >= 14 then
                if self._removeSweetNumTable[RemoveSquence] == 14 then
                    CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][12 - self._stageNum] * TotalGold / 10;
                elseif self._removeSweetNumTable[RemoveSquence] == 15 then
                    if self._stageNum == 1 or self._stageNum == 2 then
                        CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10 + self._stageNum] * TotalGold / 10;
                    else
                        CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10] * TotalGold / 10;
                    end
                else
                    CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10 + self._stageNum] * TotalGold / 10;
                end
            else
                CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][self._removeSweetNumTable[RemoveSquence] - self._stageNum - 2] * TotalGold / 10;
            end
        end
    end
    if CurrentWinPoint == 0 then
        self.AtlasLabel_RewardSweetScore:setVisible(false);
    else
        self.AtlasLabel_RewardSweetScore:setVisible(true);
    end
    self.AtlasLabel_RewardSweetScore:setString(CurrentWinPoint);
    self.Image_RewardSweetIcon:loadTexture(strName, UI_TEX_TYPE_PLIST);
    self.AtlasLabel_RewardSweetNum:setString(":;<" .. self._removeSweetNumTable[RemoveSquence]);

    self.Image_RewardSweetIcon:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(1), cc.FadeOut:create(0.3)));
    self.AtlasLabel_RewardSweetNum:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(1), cc.FadeOut:create(0.3)));
    self.AtlasLabel_RewardSweetScore:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(1), cc.FadeOut:create(0.3)));
    self._winPoint = self._winPoint + CurrentWinPoint;
    self.AtlasLabel_wardPool_1:setString(self._winPoint);

    local baozhaAction = createSkeletonAnimation("baozha", "effects/baozha.json", "effects/baozha.atlas");
    if not baozhaAction then
        return;
    end

    if self._removeSweetDataTable[RemoveSquence] == 6 then
        audio.playSound("sweetparty/voice/sound_passsweet.mp3");
    else
        audio.playSound("sweetparty/voice/sound_remove.mp3");
    end

    local size = self.Image_RightBall:getContentSize();
    if baozhaAction then
        baozhaAction:setPosition(0, 0);
        baozhaAction:setAnimation(0, "baozha", false);
        baozhaAction:setPosition(size.width / 2, size.height / 2 + 10)
        self.Image_RightBall:addChild(baozhaAction, 100000);
    end
end

-- 创建新的关卡
function TableLayer:InitNewLevel()
    local QueueNum = 1;
    self._nRemoveQueneNum = 1;
    if self._stageNum == 1 then
        -- 重新开始全部显示过关糖果
        if self._TotalPassSweetNum == 0 then
            for i = 1, 45 do
                self._StageSweetTable[i]:setVisible(true);
            end
        end
        self.AtlasLabel_PassSweetNum:setString(self._PassSweetNum);
        self.Image_dikuang:loadTexture("sweetparty_4x4.png", UI_TEX_TYPE_PLIST);
        self.Image_PassSweetIcon:loadTexture("SweetSprite_passsweet_Show_1.png", UI_TEX_TYPE_PLIST);
        for i = 1, 6 do
            self.tbSweetNode[i]:setPosition((i - 1) * 86 + 53, 0);
        end
    elseif self._stageNum == 2 then
        self.Image_dikuang:loadTexture("sweetparty_5x5.png", UI_TEX_TYPE_PLIST)
        self.AtlasLabel_PassSweetNum:setString(self._PassSweetNum);
        self.Image_PassSweetIcon:loadTexture("SweetSprite_passsweet_Show_2.png", UI_TEX_TYPE_PLIST);
        for i = 1, 6 do
--            self.tbSweetNode[i]:setVisible(false);
            self.tbSweetNode[i]:setPosition((i - 1) * 67 + 47, 0);
        end
    else
        for i = 1, 6 do
--            self.tbSweetNode[i]:setVisible(false);
            self.tbSweetNode[i]:setPosition((i - 1) * 56 + 40, 0);
        end
        self.AtlasLabel_PassSweetNum:setString(self._PassSweetNum);
        self.Image_dikuang:loadTexture("sweetparty_6x6.png", UI_TEX_TYPE_PLIST);
        self.Image_PassSweetIcon:loadTexture("SweetSprite_passsweet_Show_3.png", UI_TEX_TYPE_PLIST);
    end

    self.AtlasLabel_StageNum:setString(self._stageNum);
    self:InitMusic(self._stageNum);

    local FirstResultTable = self._FirstResultTable[QueueNum];
    local iNextFallImgid = self._iNextFallTable[QueueNum];



    -- 开始执行消除动画
    local callBackFunc = function()
        self:CheckRemoveSweet()
    end


    for i = 1, self._stageNum + 3 do
        local SweetTable = { };
        for j = 1, self._stageNum + 4 do
            if j == self._stageNum + 4 then
                SweetTable[j] = iNextFallImgid[i];
            else
                SweetTable[j] = FirstResultTable[j][i];
            end
        end
        if self._stageNum >= 2 then
            performWithDelay(self, function()
                self.tbSweetNode[i]:setVisible(true);
                self.tbSweetNode[i]:initStartTable(SweetTable, self._stageNum);
                self.tbSweetNode[i]:start(SweetTable, self._stageNum, callBackFunc);
            end , 1.5)
        else
            self.tbSweetNode[i]:setVisible(true);
            self.tbSweetNode[i]:initStartTable(SweetTable, self._stageNum);
            self.tbSweetNode[i]:start(SweetTable, self._stageNum, callBackFunc);
        end
    end
    audio.playSound("sweetparty/voice/sound_drop.mp3");
end

-- 发送开始收到结果
function TableLayer:onRollResult(message)
    local data = message._usedata;
    luaDump(data,"datadata");
    local iLevel = data.iLevel; 
    self._stageNum = iLevel + 1;
    local iRemoveNum = data.iRemoveNum;
    for i=1,iRemoveNum + 1 do
         table.insert(self._FirstResultTable,data.iTypeImgInfo[i].iTypeImgid);
    end
    for i = 1,#self._FirstResultTable do
        local iNextFallTable = self._FirstResultTable[i];        
        if i ~= 1 then
            table.insert(self._ResultTable, self._FirstResultTable[i]);
        end       
        table.insert(self._iNextFallTable, iNextFallTable[self._stageNum  + 4]);
    end
    for i=1,iRemoveNum + 1 do
        local removeSequenceTable = {};
        for j = 1,7 do
            removeSequenceTable[j] = {};
            for k=1,6 do
                removeSequenceTable[j][k] = 0;
            end
        end
        local removeSequenceNum = data.iRemoveTypeImgid[i].nRemoveNum;     
        for j = 1,removeSequenceNum do
            for k = 1,7 do
                 for l=1,6 do
                    if data.iRemoveTypeImgid[i].iRemoveTypeImgInfo[j].iRemoveImg[k][l] ~= 0 then
                        removeSequenceTable[k][l] = j;
                    end
                end
            end          
        end
        table.insert(self._RemoveSequenceTable,removeSequenceTable);
    end
 
    self.tableLogic:setPoolPoint(data.iPoolPoint);
    local FreeTimeBeilv = data.iSmallWinMoney;
    local iFreeGame = data.iFreeGame;
    local nCaiJinPoint = data.nWinPool;
    local iProgress = data.iProgress;
    if self._nFreeGamelv == 0 then
        self._nFreeGamelv = FreeTimeBeilv;
    end
--    table.insert(self._FirstResultTable, FirstResultTable);
--    table.insert(self._ResultTable, ResultTable);
--    table.insert(self._RemoveSequenceTable, RemoveSequenceTable);
--    table.insert(self._iNextFallTable, iNextFallTable);

    local nPointValue = self:getNowSelectPointValue();
    local nZhuShuValue = self:getNowSelectZhuShuValue();

    -- 是否有免费糖果
    if iFreeGame == 10 then
        self._bFreeGamePoint = 0;
        self._bFreeGame = true;
        self._nFreeGamelv = FreeTimeBeilv;
    end
    self._bFreeGamePoint = data.nSmallTotalWin;

    self._WinPointType = data.nCaijinNum;
--    -- 是否中彩金
    if data.nCaijinNum > 0 then
        self._nCaiJinPoint = nCaiJinPoint;
        self._CaijinPointTable = PoolPointTable;
    end



--    -- 一直请求数据，直到请求到无法消除为止
--    for i = 1, self._stageNum + 3 do
--        for j = 1, self._stageNum + 3 do
--            if RemoveSequenceTable[i][j] ~= 0 and ResultTable[i][j] ~= 0 then
--                self.tableLogic:sendStartRoll(nPointValue * 100, nZhuShuValue);
--                return;
--            end
--        end
--    end


    local nRollFreeTime = self.tableLogic:getRollFreeTime();
    if nRollFreeTime > 0 then
        self.tableLogic:setRollFreeTime(nRollFreeTime - 1);
        -- 设置免费次数
        self.AtlasLabel_FreeTime:setString(self.tableLogic:getRollFreeTime());
    else
        if self._bInGame == false then
            local totalGold = self:getTotalGold();
            self:minusPlayerMoney(totalGold * 100);
            -- 减去转一次消耗的金币
        end
    end


    if self._bInGame == false then
        self:InitNewLevel();
    end
    --    audio.playSound("sweetparty/voice/sound_startgame.mp3");
end


-- 进入后台
function TableLayer:refreshEnterBack(data)
    luaPrint("进入后台-----------refreshEnterBack")
    if device.platform == "windows" then
        return;
    end
end

-- 后台回来
function TableLayer:refreshBackGame(data)
    luaPrint("后台回来-----------refreshBackGame")
    if device.platform == "windows" then
        return;
    end
end

-- 提示小字符
function TableLayer:TipTextShow(tipText)
    addScrollMessage(tipText);
end

-- 设置奖池
function TableLayer:updatePoolPoint()
    if not self.AtlasLabel_grandPoint and not self.AtlasLabel_majorPoint
        and not self.AtlasLabel_minorPoint and not self.AtlasLabel_miniPoint then
        return;
    end
    local poolPointTable = self.tableLogic:getPoolPoint();
--    self.AtlasLabel_grandPoint:setString(math.ceil(poolPointTable[1] / 100));
--    self.AtlasLabel_majorPoint:setString(math.ceil(poolPointTable[2] / 100));
--    self.AtlasLabel_minorPoint:setString(math.ceil(poolPointTable[3] / 100));
--    self.AtlasLabel_miniPoint:setString(math.ceil(poolPointTable[4] / 100));

    changeNumAni(self.AtlasLabel_grandPoint,math.ceil(poolPointTable[1] / 100)*100,true)
    changeNumAni(self.AtlasLabel_majorPoint,math.ceil(poolPointTable[2] / 100)*100,true)
    changeNumAni(self.AtlasLabel_minorPoint,math.ceil(poolPointTable[3] / 100)*100,true)
    changeNumAni(self.AtlasLabel_miniPoint,math.ceil(poolPointTable[4] / 100)*100,true)
end

--刷新奖池
function TableLayer:onUpdatePool(data)
	local msg = data._usedata;
    self.tableLogic:setPoolPoint(msg.iPoolPoint);
    self:updatePoolPoint();
end

-- 设置奖金
function TableLayer:setAwardPoint(nPoint)
    if not self.AtlasLabel_yingfen then
        return;
    end
    self:ScoreToMoney(self.AtlasLabel_yingfen, nPoint);
end

function TableLayer:updateStartBtnIsFree()
    local nRollFreeTime = self.tableLogic:getRollFreeTime();
    if nRollFreeTime <= 0 then
        self.Button_start:loadTextures("sf_game_kaishi.png", "sf_game_kaishi-on.png", "sf_game_kaishi2.png", UI_TEX_TYPE_PLIST);
        self.AtlasLabel_freeTime:setVisible(false);
    else
        self.Button_start:loadTextures("sf_game_mianfei.png", "sf_game_mianfei-on.png", "sf_game_mianfei2.png", UI_TEX_TYPE_PLIST);
        self.AtlasLabel_freeTime:setString(tostring(nRollFreeTime));
        self.AtlasLabel_freeTime:setVisible(true);
    end
end

function TableLayer:setPointSelectIndex(nSelectIndex)
    if not self.AtlasLabel_Point then
        return;
    end
    if not POINT[nSelectIndex] then
        nSelectIndex = 1;
    end

    self._nPoint = nSelectIndex;

    self.AtlasLabel_Point:setString(POINT[nSelectIndex]);
end

function TableLayer:setZhuShuSelectIndex(nSelectIndex)
    if not self.AtlasLabel_ZhuShu then
        return;
    end
    if not ZHUSHU[nSelectIndex] then
        nSelectIndex = 1;
    end

    self._nZhuShu = nSelectIndex;

    self.AtlasLabel_ZhuShu:setString(ZHUSHU[nSelectIndex]);
end



function TableLayer:setLineNumber(nLine)
    --    if self.AtlasLabel_lineNumber then
    --        self.AtlasLabel_lineNumber:setString(nLine);
    --    end
end

function TableLayer:getNowSelectSingleGold()
    local nSelectIndex = self._nGoldConfigIndex or 1;

    if not self._tbGoldConfig[nSelectIndex] then
        nSelectIndex = 1;
    end
    return self._tbGoldConfig[nSelectIndex];
end

function TableLayer:getNowSelectPointValue()
    local nSelectIndex = self._nPoint or 1;

    if not POINT[nSelectIndex] then
        nSelectIndex = 1;
    end
    return POINT[nSelectIndex];
end

function TableLayer:getNowSelectZhuShuValue()
    local nSelectIndex = self._nZhuShu or 1;

    if not ZHUSHU[nSelectIndex] then
        nSelectIndex = 1;
    end
    return ZHUSHU[nSelectIndex];
end

function TableLayer:getTotalGold()
    local nPointValue = self:getNowSelectPointValue();
    local nZhuShuValue = self:getNowSelectZhuShuValue();

    return nPointValue * nZhuShuValue;
end

-- 玩家分数
function TableLayer:ScoreToMoney(pNode, score, string)
    if string == nil then
        string = "";
    end

    local remainderNum = score % 100;
    local remainderString = "";

    if remainderNum == 0 then
        -- 保留2位小数
        remainderString = remainderString .. ".00";
    else
        if remainderNum % 10 == 0 then
            remainderString = remainderString .. "0";
        end
    end
    if pNode == nil then
        return string ..(score / 100) .. remainderString;
    end
    pNode:setString(string ..(score / 100) .. remainderString);
end

function TableLayer:minusPlayerMoney(nMoney)
    self.playerMoney = self.playerMoney - nMoney;
    self:ScoreToMoney(self.Text_playerMoney, self.playerMoney);
end

function TableLayer:updateSelfPlayerMoney()
    local mySeatNo = self.tableLogic:getMySeatNo();
    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
    if userInfo then
        self:ScoreToMoney(self.Text_playerMoney, userInfo.i64Money);
        self.playerMoney = clone(userInfo.i64Money);
    end
end


function TableLayer:leaveDesk(source)
    self:stopAllActions();
    _instance = nil;

    if source == nil then
        globalUnit.isEnterGame = false;
        RoomLogic:close();
    end

    self:leaveDeskDdz();
end

function TableLayer:leaveDeskDdz(source)
    if not self._bLeaveDesk then

        self.tableLogic:stop();

        self._bLeaveDesk = true;

    end
end

-- 重连刷新界面
function TableLayer:ReConnectGame(msg)
    -- 刷新开始按钮
    --    self:updateStartBtnIsFree();
    -- 刷新自己金币数
    self:updateSelfPlayerMoney();
    --    --刷新奖池
    --    luaPrint("msg.iPoolPoint",msg.iPoolPoint)
    self._niPoolPoint = msg.iPoolPoint;
    local nPoint = msg.scorePerline / 100;
    local nPointIndex = 0;
    for i = 1, #POINT do
        if nPoint == POINT[i] then
            nPointIndex = i;
        end
    end
    local nZhuShuIndex = msg.linecount;
    if msg.iFreeGames > 0 then
        self:setPointSelectIndex(nPointIndex);
        self:setZhuShuSelectIndex(nZhuShuIndex);
    end
    self.tableLogic:setPoolPoint(self._niPoolPoint);
    self:updatePoolPoint();    
    for i = self._TotalPassSweetNum + 1, 45 do
        self._StageSweetTable[i]:setVisible(true);
    end
    self._stageNum = msg.level + 1;
    self._TotalPassSweetNum = msg.level * 15 + msg.progress;
    self._PassSweetNum = msg.progress;    
    self.AtlasLabel_PassSweetNum:setString(self._PassSweetNum);
    self.Image_PassSweetIcon:loadTexture(string.format("SweetSprite_passsweet_Show_%d.png", self._stageNum), UI_TEX_TYPE_PLIST);
    --关卡消除图案进度
    for i = 1,self._TotalPassSweetNum do
        self._StageSweetTable[i]:setVisible(false);
    end
    --关卡文字显示
    self.AtlasLabel_StageNum:setString(self._stageNum);
    self:InitMusic(self._stageNum);
    --关卡背景显示
    if self._stageNum == 1 then
        self.Image_dikuang:loadTexture("sweetparty_4x4.png", UI_TEX_TYPE_PLIST);
    elseif self._stageNum == 2 then
        self.Image_dikuang:loadTexture("sweetparty_5x5.png", UI_TEX_TYPE_PLIST);
    else
        self.Image_dikuang:loadTexture("sweetparty_6x6.png", UI_TEX_TYPE_PLIST);
    end
    if msg.iFreeGames > 0 then
        self.tableLogic:setRollFreeTime(msg.iFreeGames);
        self._nFreeGamelv = msg.nFreeGameBeilv;
        self:ShowFreeTimeStart();
        self:updateBatNodeBtnEnable();
    end
end

function TableLayer:GetCaiJin()
    self.Panel_mengban:setVisible(true);
    local size = self.Image_bg:getContentSize();
    local Caijin = createSkeletonAnimation("huodecaijin", "effects/yingdehuode.json", "effects/yingdehuode.atlas");
    if Caijin then
        Caijin:setPosition(size.width / 2, size.height / 2);
        Caijin:setAnimation(1, "huodecaijin", false);
        self.Image_bg:addChild(Caijin);
    end


    audio.playSound("sweetparty/voice/sound_getcaijin.mp3");


    local WinPoint = math.ceil(self._nCaiJinPoint / 100);


    local str1 = ""
    local str = tostring(WinPoint)
    local strLen = string.len(str)

    if deperator == nil then
        deperator = ","
    end
    deperator = tostring(deperator)

    for i = 1, strLen do
        str1 = string.char(string.byte(str, strLen + 1 - i)) .. str1
        if math.mod(i, 3) == 0 then
            -- 下一个数 还有
            if strLen - i ~= 0 then
                str1 = "," .. str1
            end
        end
    end

    WinPoint = str1;

    if self._nCaiJinPoint < 10000 then
        WinPoint = self._nCaiJinPoint / 100;
    end

    local CaiJinPoint = FontConfig.createWithCharMap(WinPoint, "number_res/sweetparty_caijin.png", 34, 57, "+");
    CaiJinPoint:setPosition(size.width / 2 - 25, 790);
    self.Image_bg:addChild(CaiJinPoint, 10000)

    local biao = ccui.ImageView:create(string.format("res/sweetparty/sweetparty_%d.png", 5 - self._WinPointType));
    local size = self.Image_bg:getContentSize();
    biao:setPosition(size.width / 2, 770)
    self.Image_bg:addChild(biao, 10000);

    local action1 = cc.DelayTime:create(1);
    local action2 = cc.MoveTo:create(0.5, cc.p(size.width / 2 - 20, 130));
    local action3 = cc.MoveTo:create(0.05, cc.p(size.width / 2 - 20, 140));
    local action4 = cc.MoveTo:create(0.05, cc.p(size.width / 2 - 20, 130));
    local sequence1 = cc.Sequence:create(action1, action2, action3, action4)
    biao:runAction(sequence1);

    local action1 = cc.DelayTime:create(1);
    local action2 = cc.MoveTo:create(0.5, cc.p(size.width / 2, 270));
    local action3 = cc.MoveTo:create(0.05, cc.p(size.width / 2, 280));
    local action4 = cc.MoveTo:create(0.05, cc.p(size.width / 2, 270));
    local action5 = cc.CallFunc:create( function()
        performWithDelay(self, function()
            biao:removeFromParent();
            CaiJinPoint:removeFromParent();
            Caijin:removeFromParent();
            self.Panel_mengban:setVisible(false);
            local totalGold = self:getTotalGold();
            local roomInfo = RoomLogic:getSelectedRoom();
            local goldTotal = self:getTotalGold();
            local needGold = 0.01
            if self.tableLogic:getRollFreeTime() == 0 then
                if self.playerMoney < needGold or self.playerMoney < goldTotal * 100 then
                    addScrollMessage("金币不足,请充值");
                    if self.playerMoney < needGold then
                        showBuyTip(true);
                    else
                        showBuyTip();
                    end
                    return;
                end
            end
            if self.tableLogic:getAutoStartBool() then
                self:ClickStartBtnCallBack();
            end
        end , 1.5);
    end );
    local sequence = cc.Sequence:create(action1, action2, action3, action4, action5)
    CaiJinPoint:runAction(sequence);

    self._nCaiJinPoint = 0;
    self._WinPointType = 0;
end

function TableLayer:GetFreeTimePoint(bNextStage)
    self._bInFreeGame = false;
    if self.Xingxing then
        self.Xingxing:removeFromParent();
    end

    audio.playSound("sweetparty/voice/sound_freepoint.mp3");

    local size = self.Image_bg:getContentSize();
    local FreeTimeShow = createSkeletonAnimation("yingdefenshu", "effects/yingdehuode.json", "effects/yingdehuode.atlas");
    if FreeTimeShow then
        FreeTimeShow:setPosition(size.width / 2, size.height / 2);
        FreeTimeShow:setAnimation(1, "yingdefenshu", false);
        self.Image_bg:addChild(FreeTimeShow);
    end


    local WinPoint = self._bFreeGamePoint / 100;

    --    local str1 =""
    --    local str = tostring(WinPoint)
    --    local strLen = string.len(str)

    --    if deperator == nil then
    --        deperator = ","
    --    end
    --    deperator = tostring(deperator)

    --    for i=1,strLen do
    --        str1 = string.char(string.byte(str,strLen+1 - i)) .. str1
    --        if math.mod(i,3) == 0 then
    --            --下一个数 还有
    --            if strLen - i ~= 0 then
    --                str1 = ","..str1
    --            end
    --        end
    --    end

    --    WinPoint = str1..tostring();

    local FreeTimePoint = FontConfig.createWithCharMap(WinPoint, "number_res/sweetparty_caijin.png", 34, 57, "+");
    FreeTimePoint:setPosition(size.width / 2 - 25, 780);

    self.Image_bg:addChild(FreeTimePoint, 10000)

    local action1 = cc.DelayTime:create(1);
    local action2 = cc.MoveTo:create(0.5, cc.p(size.width / 2 - 20, 250));
    local action3 = cc.MoveTo:create(0.05, cc.p(size.width / 2 - 20, 260));
    local action4 = cc.MoveTo:create(0.05, cc.p(size.width / 2 - 20, 250));
    local action5 = cc.CallFunc:create( function()
        performWithDelay(self, function()
            FreeTimeShow:removeFromParent();
            FreeTimePoint:removeFromParent();
            self.Image_stage:setVisible(true);
            self.AtlasLabel_StageNum:setVisible(true);
            self:InitMusic(self._stageNum);
            self.Image_FreeTime:setVisible(false);
            self.AtlasLabel_FreeTime:setVisible(false);
            self.Node_ScoreRecord:setVisible(true);
            self.FreeTimeBeilv:setVisible(false);
            if self.tableLogic:getAutoStartBool() then
                self:ClickStartBtnCallBack();
            end
        end , 2.0);
    end );
    local sequence = cc.Sequence:create(action1, action2, action3, action4, action5)
    FreeTimePoint:runAction(sequence);

    self._bFreeGamePoint = 0;
end

-- 免费次数动画展示
function TableLayer:ShowFreeTimeStart()
    self.Panel_mengban:setVisible(true);
    local freetime = self.tableLogic:getRollFreeTime()
    self._bFreeGame = false;
    self._bInFreeGame = true;
    -- 免费次数
    local size = self.Image_bg:getContentSize();
    self.FreeTime = createSkeletonAnimation("beishu", "effects/yingdehuode.json", "effects/yingdehuode.atlas");
    if self.FreeTime then
        self.FreeTime:setPosition(size.width / 2, size.height / 2);
        self.FreeTime:setAnimation(1, "beishu", false);
        self.Image_bg:addChild(self.FreeTime);
    end

    audio.playSound("sweetparty/voice/sound_lottery.mp3");
    local FreeTimeNum = 1;
    local FreeTimeBeilv = FontConfig.createWithCharMap(tostring(FreeTimeNum), "number_res/sweetparty_zitiaobeilvda.png", 136, 144, "0");
    self.FreeTimeBeilv = FreeTimeBeilv;
    FreeTimeBeilv:setScale(0.01);
    FreeTimeBeilv:setPosition(size.width / 2, size.height / 2);
    self.Node_ScoreRecord:setVisible(false);
    self.Image_bg:addChild(FreeTimeBeilv, 10000)
    local action1 = cc.ScaleTo:create(0.5, 1, 1);
    local action2 = cc.CallFunc:create( function()
        FreeTimeBeilv:setScale(0.01);
        FreeTimeNum = FreeTimeNum + 1;
        if FreeTimeNum > 5 then
            FreeTimeBeilv:stopAllActions();
            FreeTimeNum = self._nFreeGamelv;
            FreeTimeBeilv:setString(FreeTimeNum);
            local action1 = cc.ScaleTo:create(0.3, 1, 1);
            local action2 = cc.DelayTime:create(0.3);
            local action3 = cc.MoveTo:create(0.5, cc.p(self.Image_youkuang:getPositionX(), 570))
            local action4 = cc.CallFunc:create( function()
                self.FreeTime:removeFromParent()
                self.Panel_mengban:setVisible(false);
                -- 免费次数时效果
                self.Image_stage:setVisible(false);
                self.AtlasLabel_StageNum:setVisible(false);
                self.Image_FreeTime:setVisible(true);
                audio.playMusic("sweetparty/voice/freeSpinBG.mp3", true)
                self.AtlasLabel_FreeTime:setVisible(true);
                self.AtlasLabel_FreeTime:setString(self.tableLogic:getRollFreeTime());
                self.Xingxing = createSkeletonAnimation("xingxing", "effects/xingxing.json", "effects/xingxing.atlas");
                if self.Xingxing then
                    local size = self.Node_Xingxing:getContentSize();
                    self.Xingxing:setPosition(size.width / 2 - 3,(size.height / 2) -35);
                    self.Xingxing:setAnimation(1, "xingxing", true);
                    self.Node_Xingxing:addChild(self.Xingxing, 10);
                end
                if self.tableLogic:getAutoStartBool() then
                    self:ClickStartBtnCallBack();
                end
            end );
            local sequence = cc.Sequence:create(action1, action2, action3, action4)
            FreeTimeBeilv:runAction(sequence);
        end
        FreeTimeBeilv:setString(FreeTimeNum);
    end );
    local sequence = cc.Sequence:create(action1, action2)
    local action = cc.RepeatForever:create(sequence)
    FreeTimeBeilv:runAction(action);
end

function TableLayer:setSelfUserInfo()
    local mySeatNo = self.tableLogic:getMySeatNo();
    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
    if userInfo then
        self:ScoreToMoney(self.Text_playerMoney, userInfo.i64Money);
        self.playerMoney = clone(userInfo.i64Money);
    end
end

function TableLayer:gameUserCut(seatNo, bCut)
    if globalUnit.m_gameConnectState ~= STATE.STATE_OVER then
        -- //重连中状态
        -- //请求游戏状态信息 ,刷新桌子数据
        local msg = { };
        msg.bEnableWatch = 0;

        RoomLogic:send(RoomMsg.MDM_GM_GAME_FRAME, RoomMsg.ASS_GM_GAME_INFO, msg, RoomMsg.MSG_GM_S_ClientInfo);
    end

    local root = cc.Director:getInstance():getRunningScene()

    local node = root:getChildByTag(1421);
    if node then
        node:delayCloseLayer(0);
    end
end


function TableLayer:removeUser(seatNo, bIsMe, bLock)
    if not TableLayer:getInstance() then
        return;
    end
    if bIsMe then
        self.m_bGameStart = false;
        local str = "";
        local func;
        if bLock == 1 then
            str = "金币不足，请退出游戏!"
            func = function()
                if globalUnit.isEnterGame then
                    self:onClickExitGameCallBack(5)
                end
            end

            local prompt = GamePromptLayer:create();
            prompt:showPrompt(GBKToUtf8(str));
            prompt:setName("prompt_erren");
            prompt:setBtnClickCallBack(func, func);
            return;
        elseif bLock == 0 then
            self:onClickExitGameCallBack(5);
        elseif bLock == 2 then
            str = "房间已关闭,自动退出游戏。"
            self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create( function(...)
                addScrollMessage(str);
                self:onClickExitGameCallBack(5);
            end )));
        elseif bLock == 3 then
            str = "长时间未操作,自动退出游戏。"
            self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create( function(...)
                addScrollMessage(str);
                self:onClickExitGameCallBack();
            end )))
        elseif bLock == 4 then
            -- 重新匹配
            -- self:matchGame();
        elseif bLock == 5 then
            str = "vip厅房间关闭,自动退出游戏。"
            self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create( function(...)
                self:onClickExitGameCallBack(5);
                addScrollMessage(str);
            end )));
        end

        return;
    end
end


function TableLayer:onRecTestControl(msg)
    luaPrint("onRecTestControl");
	local data = msg._usedata;
	local msg = convertToLua(data,RoomMsg.MSG_GP_S_TEST_CONTROL);
	luaDump(msg, "onRecTestControl", 5)
	addScrollMessage(msg.sInfo);
end

return TableLayer;