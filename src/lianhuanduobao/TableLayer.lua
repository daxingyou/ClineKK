local TableLayer = class("TableLayer", BaseWindow)
local TableLogic = require("lianhuanduobao.TableLogic");
local LianhuanduobaoLayer = require("lianhuanduobao.LianhuanduobaoLayer");
local SweetSprite = require("lianhuanduobao.SweetSprite");
-- local GameRuleLayer = require("lianhuanduobao.GameRuleLayer");
local LianhuanduobaoInfo = require("lianhuanduobao.lianhuanduobaoInfo");
local GuildLayer = require("lianhuanduobao.GuildLayer");
local LeiJiLayer = require("lianhuanduobao.LeiJiLayer");
local BackTipLayer = require("lianhuanduobao.BackTipLayer");
local SmallGameLayer = require("lianhuanduobao.SmallGameLayer");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

-- local Bar = require("qukuailian.QukuailianBar");

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
    [2] = { 1,2,3,4,5 },
    -- 初级
    [3] = { 1,2,3,4,5 },
    -- 中级
    [4] = { 1,2,3,4,5 },
    -- 高级
    [5] = { 1,2,3,4,5 },-- 土豪场
};


local SINGLE_GOLD_CONFIG = {
    [149] = 1,
    [148] = 2,
    [162] = 3,
    [163] = 4,
    [152] = 5,
};

local SINGLE_SWEET_PRECENT_CONFIG = {
    [1] = {100,100,100,100,100,100},
    -- 体验
    [2] = {17, 34, 51, 68, 85, 100},
    -- 初级
    [3] = {17, 34, 51, 68, 85, 100 },
    -- 中级
    [4] = {17, 34, 51, 68, 85, 100 },
    -- 高级
    [5] = {17, 34, 51, 68, 85,100},-- 土豪场
};



local REMOVE_SWEET_SCORE = {
    [1] = { 2, 4, 5, 8, 10, 20, 30, 50, 100, 200, 400, 400,500 },
    [2] = { 4, 5, 10, 20, 30, 50, 100, 250, 500, 750, 800, 1000, 1200 },
    [3] = { 5, 10, 20, 40, 80, 160, 500, 1000, 2000, 5000, 6000, 7000, 8000 },
    [4] = { 10, 30, 50, 60, 100, 750, 1000, 10000, 20000, 50000, 60000, 70000, 80000 },
    [5] = { 20, 50, 100, 500, 1000, 2000, 5000, 20000, 50000, 60000, 80000, 100000, 100000 },
}



local SWEET_PNG_NAME = {
    [TableLogic.SWEET_TYPE.ORANGE] = "zuanshiSprite_1",
    [TableLogic.SWEET_TYPE.RED] = "zuanshiSprite_2",
    [TableLogic.SWEET_TYPE.YELLOW] = "zuanshiSprite_3",
    [TableLogic.SWEET_TYPE.GREEN] = "zuanshiSprite_4",
    [TableLogic.SWEET_TYPE.PURPLE] = "zuanshiSprite_5",
    [TableLogic.SWEET_TYPE.PASSSWEET] = "zuanshiSprite_pass",
};



local ZHUSHU = { 1, 2, 3, 4, 5 }
local ZHUSHU_TOTAL = 5;-- ZHUSHU中元素个数
local POINT = {0.1,0.5,1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,500,1000,1500,2000,3000}
local PRECENT = { 17, 34, 51, 68, 85, 100 }

local POINT_TOTAL = 26;-- POINT中元素个数

local Show_zhanji =globalUnit.isShowZJ; --控制更多按钮处是否显示战绩

TableLayer._bInGame = false;-- --用来判断游戏是否有消除，还需要进行下一阶段

TableLayer._nPoint = 1;-- 选择的单注金币序号
TableLayer._nZhuShu = 1;-- 选择的单注金币序号
TableLayer._stageNum = 1; -- 关卡数
TableLayer._nRemoveQueneNum = 1;-- 执行消除的队列数
TableLayer._MaxRmoveNum = 0; --单轮次最大消除数
TableLayer._PassSweetNum = 0; -- 左上角显示的消除的过关糖果数
TableLayer._TotalPassSweetNum = 0; -- 用来控制屏幕中间显示消除的过关糖果数
TableLayer._winPoint = 0; --当局获奖分数
TableLayer._bFreeGame = false --是否有免费次数
TableLayer._bFreeGamelv = 0; --免费游戏的倍数
TableLayer._RemoveEffect = 0; -- 播放移除的特效
TableLayer._bInFreeGame = false; --是否在免费游戏中
TableLayer._bFreeGamePoint = 0; --免费游戏获得的分数
TableLayer._bCaiJin = false --是否有彩金糖果
TableLayer._CaijinPointTable ={} --存放彩金糖果中奖的数据
TableLayer._tbGoldConfig = SINGLE_GOLD_CONFIG[2];
TableLayer._resultTable = { }; -- 用于存放转盘结果的表
TableLayer._bShowWinPoint = false; -- 赢分
TableLayer._bAlreadySendStart = false; -- 用来判断是否需要再次发送协议获取掉落数据
TableLayer._FirstResultTable = { } --第一次掉落结果存放表
TableLayer._ResultTable = { } --第一次消除后掉落结果存放表
TableLayer._RemoveSequenceTable = { } --消除顺序表
TableLayer._iNextFallTable = { } --最上面一排糖果显示存放表
TableLayer._PoolPointTable = { } --奖池数据
TableLayer._removeSweetNumTable = { } --右框显示移除糖果数量表
TableLayer._removeSweetDataTable = { } --右框显示移除糖果表
TableLayer._StageSweetTable = { } --屏幕中间糖果消除表

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
    --luaPrint("TableLayer:create");
    local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster);

    globalUnit.isFirstTimeInGame = false;

    return layer;
end

-- 静态函数
function TableLayer:getInstance()
    return _instance;
end

function TableLayer:setRes()
	cc.FileUtils:getInstance():addSearchPath("res/lianhuanduobao",true)
	cc.FileUtils:getInstance():addSearchPath("src/lianhuanduobao",true)

	local writablePath = cc.FileUtils:getInstance():getWritablePath()

	if device.platform ~= "windows" then
		cc.FileUtils:getInstance():addSearchPath(writablePath.."res/lianhuanduobao",true)
		cc.FileUtils:getInstance():addSearchPath(writablePath.."src/lianhuanduobao",true)
	end
end

-- 构造函数
function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
    self.super.ctor(self, 0, true);

    self.uNameId = uNameId;
    self.bDeskIndex = bDeskIndex or 0;
    self.bAutoCreate = bAutoCreate or false;
    self.bMaster = bMaster or 0;
    GameMsg.init();    
    LianhuanduobaoInfo:init();
    self:setRes()
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
    display.loadSpriteFrames("lianhuanduobao/zuanshiImage/zuanshi1.plist","lianhuanduobao/zuanshiImage/zuanshi1.png");
    local uiTable = {
        -- 最外层元素
        Image_bg = "Image_bg",
        Node_score = "Node_score",
        Button_otherButton = "Button_otherButton",
        Image_gamekuang = "Image_gamekuang",
        Button_autoStart = "Button_deposit",
        Button_start = "Button_sure",
        Panel_Game = "Panel_Game",
        Node_StageSweet = "Node_StageSweet",
        imgGuan = "imgGuan",
        layGameCoin = "layGameCoin",
        layThisCoin = "layThisCoin",
        layLeijijiang = "layLeijijiang",
        layAddScore = "layAddScore",
        layDanxainScore = "layDanxainScore",
        layGuoguan = "layGuoguan",
        rewardLay = "rewardLay",


        -- Button_otherButton中的元素
        Image_dikuang = "Image_dikuang",

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
        Image_RewardSweetIcon = "Image_RewardSweet",
        AtlasLabel_RewardSweetNum = "AtlasLabel_RewardSweet",
        AtlasLabel_RewardSweetScore = "AtlasLabel_RewardSweetScore",
        AtlasLabel_ZhuShu = "AtlasLabel_zhushu",
        AtlasLabel_Point = "AtlasLabel_point",
        Button_ZhuShuAdd = "Button_add_zhushu",
        Button_ZhuShuSub = "Button_sub_zhushu",
        Button_PointAdd = "Button_add_point",
        Button_PointSub = "Button_sub_point",
        SliderDanxianScore = "SliderDanxianScore",
        lblleijiCoin = "lblallCoin3",
        imgguoguan1 = "imgguoguan1",
        imgguoguan2= "imgguoguan2",
        imgguoguan3 = "imgguoguan3",
        imgguoguan4 = "imgguoguan4",
        imgguoguan5 = "imgguoguan5",
        lblguoguan1 = "lblguoguan1",
        lblguoguan2 = "lblguoguan2",
        lblguoguan3 = "lblguoguan3",
        lblguoguan4 = "lblguoguan4",
        lblguoguan5 = "lblguoguan5",
        layendScore = "layendScore",
        AtlasLabel_endScore = "AtlasLabel_endScore",

        layLeijiScore = "layLeijiScore",
        AtlasLabel_leiji = "AtlasLabel_leiji",

        Panel_Game_action = "Panel_Game_action",
        layMiddle = "layMiddle",
        layPos1 = "layPos1",
        layPos2 = "layPos2",
        Image_2 ="Image_2",
        SliderDanxianScore = "SliderDanxianScore",
    }
  
    loadNewCsb(self, "lianhuanduobao/TableLayer", uiTable);

    -- 适配
    local framesize = cc.Director:getInstance():getWinSize()
    local addWidth =(framesize.width - 1280) / 4;

    --self.Button_back:setPositionX(self.Button_back:getPositionX() - addWidth);
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
    self:pushEventInfo(lianhuanduobaoInfo, "RollResult", handler(self, self.onRollResult));
    self:pushEventInfo(lianhuanduobaoInfo, "SmallGameResult", handler(self, self.onSmallGameResult));

	self:pushEventInfo(lianhuanduobaoInfo, "UpdatePool", handler(self, self.onUpdatePool));

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
    self._winPoint = 0;

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
    self.allWinMoney = 0
    self.tbSweetNode = { };
    -- 保存转盘，一共6个

    self._bShowAction = false;
    self._nGoldConfigIndex = 1;

     self:updateBatNodeBtnEnable();
    self:setAwardPoint(0)

    self.m_musicTag = 1;
end

function TableLayer:initUI()
    -- 基本按钮
    if Show_zhanji == false then	
        self.Button_zhanji:setVisible(false);
        self.Image_otherBtnBg:loadTexture("lianhuan_xialakuang.png", UI_TEX_TYPE_PLIST);
    else
        self.Button_zhanji:setVisible(true)      
        self.Image_otherBtnBg:ignoreContentAdaptWithSize(true);
        self.Image_otherBtnBg:loadTexture("lianhuan_xialakuang2.png", UI_TEX_TYPE_PLIST);
    end
    self:initGameNormalBtn();
    -- 初始化桌子显示信息
    self:initGameDesk();

    -- 初始化音效音乐
    self:InitSet();
    self:InitMusic();

    --屏幕中间消除糖果
    for i = 1, 45 do
        local StageSweet = self.Node_StageSweet:getChildByName("StageSweet_" .. i);
        self._StageSweetTable[i] = StageSweet;
    end

    local size = self.Image_bg:getContentSize();

    --背景
    self.beijing = createSkeletonAnimation("lianhuanduobao_bg", "effects/lianhuanduobao_bg.json", "effects/lianhuanduobao_bg.atlas");
    if self.beijing then
        self.beijing:setPosition(size.width / 2, size.height / 2);
        self.beijing:setAnimation(1, "lianhuanduobao_bg", true);
        self.Image_bg:addChild(self.beijing);
    end

    self.rewardX = self.rewardLay:getPositionX()
    self.rewardY = self.rewardLay:getPositionY()
    self.layendScoreX = self.layendScore:getPositionX()
    self.layLeijiScore:setLocalZOrder(10);


    --设置关卡
    self.imgGuan:loadTexture("lianhuan_guanshu1.png", UI_TEX_TYPE_PLIST)
    local NodePos = cc.p(self.Button_otherButton:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("lianhuanduobao",self);
    self.Image_bg:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(NodePos.x-100,NodePos.y-45);

     if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self);
	    self:addChild(self.m_logBar);
	end
end


-- 初始化按钮
function TableLayer:initGameNormalBtn()
     -- 累积奖
    if self.layLeijijiang then
        self.layLeijijiang:onClick( function(sender)
            self:ClickLeijiCallBack(sender);
        end )
    end
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
        self.Button_back:setLocalZOrder(9);
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
    --开始
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
        self.Button_PointAdd:addClickEventListener( function(sender)
            self:ClickPointAddBtnCallBack(sender);
        end )
    end
    if self.Button_PointSub then
        self.Button_PointSub:addClickEventListener( function(sender)
            self:ClickPointSubBtnCallBack(sender);
        end )
    end
    self.SliderDanxianScore:addEventListener(handler(self, self.AddChipSliderCall))
end


function TableLayer:initGameDesk()
    self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_4x4.png");
    -- 自己金币数
    self:updateSelfPlayerMoney();
    -- 单注金币
    local zhushu = cc.UserDefault:getInstance():getIntegerForKey("lianhuanduobao_zhushu", 1);
    local point = cc.UserDefault:getInstance():getIntegerForKey("lianhuanduobao_point", 1);
    self:setZhuShuSelectIndex(zhushu);
    self:setPointSelectIndex(point);

    --初始化
    for i = 1, 6 do
        local CreateLianhuanduobaoLayer = LianhuanduobaoLayer:create(i, self);
        self.tbSweetNode[#self.tbSweetNode + 1] = CreateLianhuanduobaoLayer;
        CreateLianhuanduobaoLayer:setPosition((i - 1) * 86 + 400, 0);
        self.Panel_Game:addChild(CreateLianhuanduobaoLayer,20);
    end
    self:updateAutoStartBtn();
    -- 自动开始按钮
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

     	audio.playMusic("lianhuanduobao/voice/sound-bg"..tag..".mp3", true)
     else
     	audio.stopMusic();
     end
end

-- 下拉菜单
function TableLayer:ClickOtherButtonCallBack(sender)
    if self.actonFinish == false then
        return;
    end
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
    -- 重新设置纹理
--    self.Image_otherBtnBg:loadTexture("lianhuan_xialakuang.png", UI_TEX_TYPE_PLIST);
    self:InitSet();

    local senderTag = sender:getTag();

    self.actonFinish = false; --将标志位置成false
    -- 将标志位置成false
    local actionTime = 0.3;
    local moveAction;

    local btnSize = self.Button_otherButton:getContentSize();
    local posX = btnSize.width / 2;
    if senderTag == 0 then
        -- 下拉
        sender:setTag(1);
        if Show_zhanji == true then
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,-280))
        else           
            moveAction = cc.MoveTo:create(actionTime, cc.p(posX, -250))
        end
        sender:loadTextures("lianhuan_xiala.png", "lianhuan_xiala-on.png", "lianhuan_xiala-on.png", UI_TEX_TYPE_PLIST);
    else
        -- 上拉
        sender:setTag(0);
        if Show_zhanji == true then
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,150))
        else
            moveAction = cc.MoveTo:create(actionTime, cc.p(posX, 150))
        end   
        sender:loadTextures("lianhuan_shangla.png", "lianhuan_shangla-on.png", "lianhuan_shangla-on.png", UI_TEX_TYPE_PLIST);
    end
    self.Image_otherBtnBg:runAction(cc.Sequence:create(moveAction, cc.CallFunc:create( function()
        self.actonFinish = true;
    end )));
end


-- 累积奖
function TableLayer:ClickLeijiCallBack(sender)
    if self.actonFinish == false then
        return;
    end

    local LeiJiLayer = LeiJiLayer:create();
    self:addChild(LeiJiLayer, 1000);
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

    luaPrint("isHaveBankLayer",isHaveBankLayer(),self._bAlreadySendStart);
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

-- 返回sw
function TableLayer:ClickBackCallBack(sender)
     
--    if self.actonFinish == false then
--        return;
--    end


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
	        self:onClickExitGameCallBack(6)
        end)

        --giveBtn:onClick(handler(self, self.onClickExitGameCallBack()))
        --saveBtn:onClick(handler(self, self.onClickExitGameCallBack(6)))
    else
        self:onClickExitGameCallBack()
    end


--    local prompt = GamePromptLayer:create();
--    prompt:showPrompt(GBKToUtf8(str));
--    prompt:setBtnClickCallBack(okCallBack, cancelCallBack)
end

-- 返回
function TableLayer:onClickExitGameCallBack(isRemove)
    local func = function()
        self.tableLogic:sendUserUp();
        -- self.tableLogic:sendForceQuit();
        self:leaveDesk()
    end

    --保存进度退出
    if isRemove == 6 then
        self.tableLogic:sendGetCaiJinInfoRequest();
        
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
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
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
        self.Button_effect:loadTextures("lianhuan_yinxiao.png", "lianhuan_yinxiao.png", "lianhuan_yinxiao.png", UI_TEX_TYPE_PLIST);
    else
        self.Button_effect:loadTextures("lianhuan_yinxiao-on.png", "lianhuan_yinxiao-on.png", "lianhuan_yinxiao-on.png", UI_TEX_TYPE_PLIST);
    end
end

-- 音乐
function TableLayer:ClickMusicCallBack(sender)
    if self.actonFinish == false then
        return;
    end
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
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
        self.Button_music:loadTextures("lianhuan_yinyue.png", "lianhuan_yinyue.png", "lianhuan_yinyue.png", UI_TEX_TYPE_PLIST);
    else
        self.Button_music:loadTextures("lianhuan_yinyue-on.png", "lianhuan_yinyue-on.png", "lianhuan_yinyue-on.png", UI_TEX_TYPE_PLIST);
    end
end

function TableLayer:ClickPointAddBtnCallBack(sender)
    -- 单注金币
    if self.AtlasLabel_Point then
        local nPoint = self._nPoint + 1;
        print("nPoint",nPoint)
        if nPoint > POINT_TOTAL then
            nPoint = 1;
        end
        self:setPointSelectIndex(nPoint);
        cc.UserDefault:getInstance():setIntegerForKey("lianhuanduobao_point", self._nPoint);
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
        cc.UserDefault:getInstance():setIntegerForKey("lianhuanduobao_point", self._nPoint);
    end
end

function TableLayer:ClickZhushuSubBtnCallBack(sender)
    -- 单注金币
    --luaPrint("ClickZhushuSubBtnCallBack");
    if self.AtlasLabel_ZhuShu then
        local nZhuShu = self._nZhuShu - 1;
        if nZhuShu < 1 then
            nZhuShu = ZHUSHU_TOTAL;
        end
        self:setZhuShuSelectIndex(nZhuShu);
    end
end

function TableLayer:ClickZhushuAddBtnCallBack(sender)
    --luaPrint("ClickZhushuAddBtnCallBack ===============点击押注线条");
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
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
	local bAutoStart = self.tableLogic:getAutoStartBool();
	if bAutoStart then--开着自动开始
		self.Button_autoStart:loadTextures("lianhuan_quxiaotuoguan.png","lianhuan_quxiaotuoguan-on.png","lianhuan_quxiaotuoguan-on.png",UI_TEX_TYPE_PLIST);
	else
        self.Button_autoStart:loadTextures("lianhuan_tuoguanyouxi.png","lianhuan_tuoguanyouxi-on.png","lianhuan_tuoguanyouxi-b.png",UI_TEX_TYPE_PLIST);	

	end
end

function TableLayer:ClickAutoStartBtnCallBack(sender)
    display.loadSpriteFrames("lianhuanduobao/GameScene.plist", "lianhuanduobao/GameScene.png");
    local bAutoStart = self.tableLogic:getAutoStartBool();

    -- 开启自动开始
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

    self.tableLogic:setAutoStartBool(not bAutoStart);
    self:updateAutoStartBtn();
    self:updateBatNodeBtnEnable();

    if not bAutoStart and not self._bAlreadySendStart then
        self:ClickStartBtnCallBack();
    end
end


function TableLayer:updateBatNodeBtnEnable()
    --luaPrint("self._bAlreadySendStart",self._bAlreadySendStart);
    local bAlreadySendStart = self._bAlreadySendStart;
    local bAutoStart = self.tableLogic:getAutoStartBool();
    if self.Button_ZhuShuAdd then
        self.Button_ZhuShuAdd:setEnabled(not bAlreadySendStart and not bAutoStart);
        -- self.Button_ZhuShuAdd:setEnabled(#ZHUSHU ~= 1)
    end
    if self.Button_ZhuShuSub then
        self.Button_ZhuShuSub:setEnabled(not bAlreadySendStart and not bAutoStart);
        -- self.Button_ZhuShuSub:setEnabled(#ZHUSHU ~= 1)
    end
    if self.Button_PointAdd then
        self.Button_PointAdd:setEnabled(not bAlreadySendStart and not bAutoStart);
    end
    if self.Button_PointSub then
        self.Button_PointSub:setEnabled(not bAlreadySendStart and not bAutoStart);
    end

    if self.SliderDanxianScore then
        self.SliderDanxianScore:setTouchEnabled(not bAlreadySendStart and not bAutoStart);
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

    if self.notautoSmallGame == true then--因为游戏延迟了 所以有小游戏不能自动开始
       return;
     end
    --self._RemoveEffect = 1 --将消除特效重新开始计算
    --本局积分置为0
    --self.AtlasLabel_wardPool_1:setString(0);
    --self._winPoint = 0;
    -- 按下按钮瞬间就将标志记为正在开始中
    self._nRemoveQueneNum = 1;
    self._FirstResultTable = { }
    self._ResultTable = { }
    self._RemoveSequenceTable = { }
    self._iNextFallTable = { }
    self._PoolPointTable = { }

    -- 刷新自己金币数
    self:updateSelfPlayerMoney();

    local totalGold = self:getTotalGold();
    local roomInfo = RoomLogic:getSelectedRoom();
    local needGold = 0.01
    local goldTotal = self:getTotalGold();


    if self.playerMoney < needGold or self.playerMoney < goldTotal * 100 then
        --luaPrint("金币不足cc================")
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
        return
    end
    
    self._bAlreadySendStart = true;
    self:setInGameBool(false);
    
    local nPointValue = self:getNowSelectPointValue();
    local nZhuShuValue = self:getNowSelectZhuShuValue();
    self.tableLogic:sendStartRoll(nPointValue*100,nZhuShuValue)

end

--检查消除流程
function TableLayer:CheckRemoveSweet()
    local bNextStage =false;
    local FirstResultTable = self._FirstResultTable[self._nRemoveQueneNum];
    local ResultTable = self._ResultTable[self._nRemoveQueneNum];
    local RemoveSequenceTable = self._RemoveSequenceTable[self._nRemoveQueneNum];
    local maxRemoveNum = 0;

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
        audio.playSound("lianhuanduobao/voice/sound_drop.mp3");

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

     --是否进入下一关
    if self._PassSweetNum >= 15 then
       bNextStage = true;
    end


    self._removeSweetNumTable = removeSweetNumTable;
    self._removeSweetDataTable = removeSweetDataTable;
    self._MaxRmoveNum = maxRemoveNum;
    if maxRemoveNum == 0 then
        --小局轮回飘分
        --luaDump(self.allWinMoney ,"self.allWinMoney == ===============")
 
        if self.allWinMoney > 0 then
            self.layendScore:show()
            self.AtlasLabel_endScore:setString("+" .. self.allWinMoney .. "元")
            --self:ScoreToMoney(self.AtlasLabel_endScore,self.allWinMoney,"+")

            local moveTo = cc.MoveTo:create(0.35,cc.p(self.layendScoreX,239.14+250))
            self.callback = function ()
                 self.layendScore:setPosition(cc.p(self.layendScoreX,239.14))
                 self.layendScore:hide()
                 self.layendScore:setOpacity(255)
            end

            local callBack = cc.CallFunc:create(handler(self,self.callback))
            self.layendScore:runAction(cc.Sequence:create(moveTo,cc.DelayTime:create(0.2),cc.FadeOut:create(0.3),callBack)) 
        end     


         -- 刷新自己金币数
        self:updateSelfPlayerMoney();
        self.isSmallGame = false;
        performWithDelay(self, function()
            --爆炸动画 
            for i = 1, self._stageNum + 3 do
                self.tbSweetNode[i]:createZuanshiDesp(i,FirstResultTable[i],self._stageNum,self.Panel_Game_action,self.layMiddle);
                -- audio.playSound("lianhuanduobao/voice/sound_remove.mp3");
            end

            for i = 1, 6 do
               if self.tbSweetNode[i] then
                    self.tbSweetNode[i]:setVisible(false);
               end
            end   
            
            self.allWinMoney = 0
            local deyTimeLeiji = 0
            if self.bWinPool > 0 then
                 deyTimeLeiji = 1.5
            end  
            performWithDelay(self, function()
                --是否有累计奖
                if self.bWinPool > 0 then
                     self:GetCaiJin()
                end  
            end,0.5);


           if self._stageNum == 3 and self.iProgress >= 15 then
               if self.allScore <= 0 then
                  self._winPoint = 0
               else                    
                   self.isSmallGame = true;
                   self.notautoSmallGame = true
                   performWithDelay(self, function()
                        self.layLeijiScore:hide()
                        self:updatePoolPoint()

                        --luaPrint("小游戏")
                        self.isautoJump  = self.tableLogic:getAutoStartBool() 
                        
                        local callbackStart = function ()
                              self.tableLogic:sendSmallGame()                   
                        end


                        local callback = function ()
                            self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_4x4.png");
                            self.imgGuan:loadTexture("lianhuan_guanshu1.png", UI_TEX_TYPE_PLIST)
                            self._winPoint = 0
                            self.AtlasLabel_wardPool_1:setString("0")
                            -- 刷新自己金币数
                            self:updateSelfPlayerMoney();
                            
                            self.notautoSmallGame = false
                            self._bAlreadySendStart = false;
                            self:updateBatNodeBtnEnable(); 

                            if self.tableLogic:getAutoStartBool() and not self._bAlreadySendStart then
                                self:ClickStartBtnCallBack();
                                --luaPrint("小游戏结束后再自动开始")
                            end
                        end
                        local SmallGameLayer = SmallGameLayer:create(self.isautoJump,callback,callbackStart)
                        SmallGameLayer:setName("SmallGameLayer")
                        self:addChild(SmallGameLayer)
                            
                 end,1+deyTimeLeiji);
              end
          end

 

            performWithDelay(self, function()
                --luaDump(self.isSmallGame,"self.isSmallGame是否有小游戏==============")
                if self.isSmallGame == false then
                    --luaDump(self.tableLogic:getAutoStartBool(),"没有小游戏自动开始了==============")
                    self._bAlreadySendStart = false;
                    self:updateBatNodeBtnEnable(); 

                    if self.tableLogic:getAutoStartBool() and not self._bAlreadySendStart then
                        self:ClickStartBtnCallBack();
                    end

                    self.layLeijiScore:hide()
                    self:updatePoolPoint()
            
                end


                if self._PassSweetNum >= 15 then
                    if self._stageNum < 3 then                   
                        --self._stageNum = self._stageNum + 1;                    
                        self._PassSweetNum = self._PassSweetNum - 15;
                    else
                        self._stageNum = 1;
                        self._PassSweetNum = 0;
                        self._TotalPassSweetNum = 0; 
                    end
                end

            end,1.2+deyTimeLeiji)
                            
        end,1.5);

        return ;
    end
 
    for i = 1, self._stageNum + 3 do
        local NextSweetTable = { };
        local RemoveTable = { }
        local RemoveSweetTable = { };
        for j = 1, self._stageNum + 4 do
            if j == self._stageNum + 4 then
                -- NextSweetTable[j] = iNextFallTable[i];
            else
                RemoveSweetTable[j] = FirstResultTable[j][i];
                NextSweetTable[j] = ResultTable[j][i];
                RemoveTable[j] = RemoveSequenceTable[j][i];
            end

        end
        self.tbSweetNode[i]:setRemoveSequence(RemoveTable)
        self.tbSweetNode[i]:checkDropLianhuanduobao(RemoveSweetTable, NextSweetTable, self._stageNum, self._MaxRmoveNum,callBackFunc);
    end
    
end

--右边显示消除水果
function TableLayer:ShowRemoveSweet(RemoveSquence)
    --luaPrint("ShowRemoveSweet",RemoveSquence);
    if self._TotalPassSweetNum > 45 then
       self._TotalPassSweetNum = 45 
    end

    for i = 1, self._TotalPassSweetNum do
        if self._StageSweetTable[i] then
            self._StageSweetTable[i]:setVisible(false);
        end
    end
    display.loadSpriteFrames("sweetparty/SweetSprite.plist", "sweetparty/SweetSprite.png");
    local strName = ""
    if  self._removeSweetDataTable[RemoveSquence] == 1 or self._removeSweetDataTable[RemoveSquence] == 2
        or self._removeSweetDataTable[RemoveSquence] == 3 or self._removeSweetDataTable[RemoveSquence] == 4 or self._removeSweetDataTable[RemoveSquence] == 5 then
        strName = SWEET_PNG_NAME[self._removeSweetDataTable[RemoveSquence]] .. "_" .. tostring(self._stageNum) .. "_0.png";
    elseif self._removeSweetDataTable[RemoveSquence] == 0 then
        return;
    else
        strName = SWEET_PNG_NAME[self._removeSweetDataTable[RemoveSquence]] .. "_0.png";
    end
    self.Image_RewardSweetIcon:loadTexture(strName, UI_TEX_TYPE_PLIST);

    local TotalGold = self:getTotalGold()
    local CurrentWinPoint = 0;

--     if self._removeSweetDataTable[RemoveSquence] <= 5 then
--        if self._bInFreeGame == true then

--        else
--            if self._removeSweetNumTable[RemoveSquence] >= 14 then
--                if self._removeSweetNumTable[RemoveSquence] == 14 then
--                    CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][12 - self._stageNum] * TotalGold/10
--                elseif self._removeSweetNumTable[RemoveSquence] == 15 then
--                    if self._stageNum == 1 or self._stageNum == 2 then

--                        CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10 + self._stageNum] * TotalGold/10;
--                    else
--                        CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10] * TotalGold/10;
--                    end
--                else
--                    CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][10 + self._stageNum] * TotalGold/10;
--                end
--            else
--                CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][self._removeSweetNumTable[RemoveSquence] - self._stageNum - 2] * TotalGold/10;
--            end
--        end
--    end



      if self._removeSweetDataTable[RemoveSquence] <= 5 then
        if self._bInFreeGame == true then
           
        else
            local indexSecond = 0
            if self._removeSweetNumTable[RemoveSquence] >= 14 then
                if self._removeSweetNumTable[RemoveSquence] == 14 then                        
                        indexSecond = 12 - self._stageNum              
               
                elseif self._removeSweetNumTable[RemoveSquence] == 15 then
                    if self._stageNum == 1 or self._stageNum == 2 then                        
                        indexSecond = 10 + self._stageNum
                    else
                        indexSecond = 10
                    end
                
                else
                    indexSecond = 10 + self._stageNum
                end
            else
                indexSecond = self._removeSweetNumTable[RemoveSquence] - self._stageNum - 2
            end

            CurrentWinPoint = REMOVE_SWEET_SCORE[self._removeSweetDataTable[RemoveSquence]][indexSecond] * TotalGold/10;
        end
    end

    self.allWinMoney = self.allWinMoney + CurrentWinPoint


    if CurrentWinPoint == 0 then
        self.AtlasLabel_wardPool_1:setString(tostring(self._winPoint))
    else
        self._winPoint = self._winPoint + CurrentWinPoint;
        self.AtlasLabel_wardPool_1:setString(tostring(self._winPoint))

    end
    if CurrentWinPoint == 0 then
        self.AtlasLabel_RewardSweetScore:setVisible(false);
    else
        self.AtlasLabel_RewardSweetScore:setVisible(true);
    end


    self.AtlasLabel_RewardSweetScore:setString(CurrentWinPoint);
    self.AtlasLabel_RewardSweetNum:setString(":;<" .. self._removeSweetNumTable[RemoveSquence]);
    self.rewardLay:show()

    local moveTo = cc.MoveTo:create(0.3,cc.p(self.rewardX,239.14+250))
    self.callback = function ()
         self.rewardLay:setPosition(cc.p(self.rewardX,239.14))
         self.rewardLay:hide()
         self.rewardLay:setOpacity(255)

    end

    local callBack = cc.CallFunc:create(handler(self,self.callback))
    self.rewardLay:runAction(cc.Sequence:create(moveTo,cc.DelayTime:create(0.2),cc.FadeOut:create(0.2),callBack))

    if self._removeSweetDataTable[RemoveSquence] == 6 then
        audio.playSound("lianhuanduobao/voice/sound_passsweet.mp3");
    else
        audio.playSound("lianhuanduobao/voice/sound_zhongjiang.mp3");
    end

end

-- 创建新的关卡
function TableLayer:InitNewLevel()
    --luaPrint("InitNewLevel");
    local QueueNum = 1;
    self._nRemoveQueneNum = 1;
    if self._stageNum == 1 then       
        -- 重新开始全部显示过关糖果
        if self._TotalPassSweetNum == 0 then
            for i = 1, 45 do
                self._StageSweetTable[i]:setVisible(true);
            end
        end
        self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_4x4.png");
        for i = 1, 6 do
            self.tbSweetNode[i]:setPosition((i - 1) * 146 + 100, 0);
        end
    elseif self._stageNum == 2 then
        self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_5x5.png")
        for i = 1, 6 do
            self.tbSweetNode[i]:setVisible(false);
            self.tbSweetNode[i]:setPosition((i - 1) * 116 + 90, 0);
        end
    else
        for i = 1, 6 do
            self.tbSweetNode[i]:setVisible(false);
            self.tbSweetNode[i]:setPosition((i - 1) * 93 + 80, 0);
        end
        self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_6x6.png");
    end

    self.imgGuan:loadTexture("lianhuan_guanshu" ..self._stageNum ..".png", UI_TEX_TYPE_PLIST)
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
    audio.playSound("lianhuanduobao/voice/sound_drop.mp3");

end

-- 发送开始收到结果
function TableLayer:onRollResult(message)
    local data = message._usedata;
    luaDump(data,"发送开始收到结果");
    self.bWinPool = data.bWinPool;--赢得奖池数量
    self.iLevel = data.iLevel;
    self.iWinMoney = data.iWinMoney--飘分
    self._niPoolPoint = data.iJiangChiPoint;
    self.iProgress = data.iProgress;
    self._stageNum =  self.iLevel + 1;
    self.allScore = data.nTotalWin;--总赢钱数
    self.nWinSamllIndex = data.nWinSamllIndex;--小游戏中奖索引
    self.fSamllGame = data.fSamllGame;--小游戏中奖倍率

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

    self._winPoint = self._winPoint-self:getTotalGold();
    if self._winPoint < 0.1 then
        self._winPoint = 0
    end

   self.AtlasLabel_wardPool_1:setString(tostring(self._winPoint))

    if self._bInGame == false then
        local totalGold = self:getTotalGold();
        self:minusPlayerMoney(totalGold * 100);
        -- 减去转一次消耗的金币
    end
   

    if self._bInGame == false then
        self:InitNewLevel();
    end

end


function TableLayer:onSmallGameResult(message)
    local data = message._usedata;
    --luaDump(data,"收到小游戏数据");
    local iWinMoney = data.iWinMoney--飘分
    local nWinSamllIndex = data.nWinSamllIndex;--小游戏中奖索引
    local nSamllGame = data.nSamllGame;--小游戏中奖倍率
    if self:getChildByName("SmallGameLayer") then
        self:getChildByName("SmallGameLayer"):getDataOnGame(nSamllGame,nWinSamllIndex+1,iWinMoney)  
    end

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

-- 累计奖
function TableLayer:updatePoolPoint()
    --self:ScoreToMoney(self.lblleijiCoin, self._niPoolPoint); 
--    self.lblleijiCoin:setString(self._niPoolPoint/100)
    changeNumAni(self.lblleijiCoin,self._niPoolPoint)
end

--刷新奖池
function TableLayer:onUpdatePool(data)
	local msg = data._usedata;
	self._niPoolPoint = msg.iPoolPoint;
	self:updatePoolPoint();
end

-- 设置奖金
function TableLayer:setAwardPoint(nPoint)
    if not self.AtlasLabel_yingfen then
        return;
    end
    self:ScoreToMoney(self.AtlasLabel_yingfen, nPoint);
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
    -- for i = 1,5 do
    --     self["lblguoguan" .. i]:setString("0")
    --     self["lblguoguan" .. i]:hide()
    -- end

    -- for i = 1,self._nZhuShu do
    --     self["lblguoguan" .. i]:show()
    --     self["lblguoguan" .. i]:setString(POINT[nSelectIndex]);
    -- end
    -- self.SliderDanxianScore:setPercent(PRECENT[nSelectIndex])

end

function TableLayer:setZhuShuSelectIndex(nSelectIndex)
    if not self.AtlasLabel_ZhuShu then
        return;
    end

    if not ZHUSHU[nSelectIndex] then
        nSelectIndex = 1;
    end

    self._nZhuShu = nSelectIndex;
    
    for i = 1,5 do
        self["imgguoguan" .. i]:loadTexture("lianhuan_tb-on.png",1)
        self["lblguoguan" .. i]:hide()
    end

    for i = 1,self._nZhuShu do
        self["imgguoguan" .. i]:loadTexture("lianhuan_tb.png",1)
        self["lblguoguan" .. i]:show()
        self["lblguoguan" .. i]:setString(POINT[self._nPoint]);
    end


    self.AtlasLabel_ZhuShu:setString(ZHUSHU[nSelectIndex]);
end


function TableLayer:AddChipSliderCall(sender, eventType)
    local roomInfo = RoomLogic:getSelectedRoom();
    local goldIndex = SINGLE_GOLD_CONFIG[roomInfo.uRoomID] or 1;
    if eventType == ccui.SliderEventType.percentChanged then 
        local nSelectIndex    
        local percent = sender:getPercent()

        if globalUnit.iRoomIndex == 1 then
            if percent >= 0 and percent <= 100 then
                nSelectIndex = 1          
            end

        elseif globalUnit.iRoomIndex == 2 then

            if percent >= 0 and percent <= 33 then
                nSelectIndex = 1        
       
            elseif  percent > 33 and percent <= 66 then
                nSelectIndex = 2       

            elseif  percent > 66 and percent <= 100 then
                nSelectIndex = 3       
            end
        else   
            if percent >= 0 and percent <= 17 then
                nSelectIndex = 1        
            elseif  percent > 17 and percent <= 34 then
                nSelectIndex = 2       

            elseif  percent > 34 and percent <= 51 then
                nSelectIndex = 3       

            elseif  percent > 51 and percent <= 68 then
                nSelectIndex = 4        

            elseif  percent > 68 and percent <= 85 then
                nSelectIndex = 5        
        
            elseif  percent > 85 and percent <= 100 then  
                nSelectIndex =6        
            end
        end
            self:setPointSelectIndex(nSelectIndex)
        end 
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
    luaPrint("self.Text_playerMoney", self.Text_playerMoney);
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
    luaPrint("ReConnectGame");
    luaDump(msg, "msgmsg");
    -- 刷新开始按钮
    self._niPoolPoint = msg.iJiangChiPoint;
    self.scorePerLine = msg.scorePerLine
    self.lineCount = msg.lineCount;
    self.iProgress = msg.progress;
    self.allScore = msg.nTotalWinMoney
    self.iLevel = msg.level
    self.smallStage = 0--不进入小游戏
    if self.iLevel >= 3 then
       self.iLevel = 2
       self.smallStage = 3
    end

    self._stageNum  = self.iLevel +1
    

    if self.lineCount == 0 then
        self.lineCount = 1;
    end


    --更新界面数据
    --self.AtlasLabel_Point:setString(self.scorePerLine/100)
    self.AtlasLabel_ZhuShu:setString(self.lineCount)
    for i = 1,self.lineCount do
        self["imgguoguan" .. i]:loadTexture("lianhuan_tb.png",1)
        self["lblguoguan" .. i]:show()
        self["lblguoguan" .. i]:setString(self.scorePerLine/100);
    end

    --self.AtlasLabel_Point:setString("0.1")
    -- local changciBeishu = 100
    -- local indexEnd = 1
    -- local roomInfo = RoomLogic:getSelectedRoom();
    -- local goldIndex = SINGLE_GOLD_CONFIG[roomInfo.uRoomID] or 1;

    -- if globalUnit.iRoomIndex >= 1 and globalUnit.iRoomIndex <= 5 then
    --     -- POINT = SINGLE_SWEET_GOLD_CONFIG[goldIndex];
    --     -- ZHUSHU = SINGLE_SWEET_BEISHU_CONFIG[goldIndex];
    --     -- PRECENT = SINGLE_SWEET_PRECENT_CONFIG[goldIndex]
    
    --     if goldIndex == 1 then
    --         if self.scorePerLine/100 ~= 0.1 then
    --             self.AtlasLabel_Point:setString("0.1")
    --             for i = 1,self.lineCount do
    --                 self["lblguoguan" .. i]:setString("0.1")
    --             end

    --         end
    --         indexEnd = 1

    --     end

    --     if goldIndex == 2 then
    --         if self.scorePerLine/100 >= 0.1 and self.scorePerLine/100 <=10 then

    --         else
    --             self.AtlasLabel_Point:setString("0.1")
    --             for i = 1,self.lineCount do
    --                 self["lblguoguan" .. i]:setString("0.1")
    --             end
    --         end
    --         indexEnd = 5
     
    --     end

    --     if goldIndex == 3 then
    --         if self.scorePerLine/100 >= 0.5 and self.scorePerLine/100 <=50 then

    --         else
    --             self.AtlasLabel_Point:setString("0.5")
    --             for i = 1,self.lineCount do
    --                 self["lblguoguan" .. i]:setString("0.5")
    --             end
    --         end
    --         indexEnd = 5

    --     end

    
    --     if goldIndex == 4 then
    --         if self.scorePerLine/100 >= 5 and self.scorePerLine/100 <=200 then

    --         else
    --             self.AtlasLabel_Point:setString("5")
    --             for i = 1,self.lineCount do
    --                 self["lblguoguan" .. i]:setString("5")
    --             end
    --         end
    --         indexEnd = 5

    --     end

    --     if goldIndex == 5 then
    --         if self.scorePerLine/100 >= 1 and self.scorePerLine/100 <=200 then

    --         else
    --             self.AtlasLabel_Point:setString("1")
    --             for i = 1,self.lineCount do
    --                 self["lblguoguan" .. i]:setString("1")
    --             end
    --         end
    --         indexEnd = 6

    --     end
--        local SINGLE_SWEET_GOLD_CONFIG = {
--    [1] = { 0.1 },
--    -- 体验
--    [2] = { 0.1, 0.5, 1 },
--    -- 初级
--    [3] = { 0.1, 0.5, 1, 5, 10 },
--    -- 中级
--    [4] = { 1, 5, 10, 50, 100 },
--    -- 高级
--    [5] = { 1, 5, 10, 50, 100 , 200 },-- 土豪场

--         for index = 1,indexEnd do
--             luaDump(index ," index  " )
--             luaDump(self.scorePerLine/changciBeishu," self.scorePerLine/changciBeishu " )
--             luaDump(POINT[index] ," POINT[index]" )
           

--             if self.scorePerLine/changciBeishu == POINT[index] then
--                   self._nPoint = index
--                 luaDump(POINT[index] ," POINT[index]11" )

-- --            elseif self.scorePerLine/changciBeishu == POINT[index]  then 
-- --                  self._nPoint = 2
-- --            luaDump(POINT[index] ," POINT[index]2" )

-- --            elseif self.scorePerLine/changciBeishu == POINT[index]  then 
-- --                   self._nPoint = 3
-- --            luaDump(POINT[index] ," POINT[index]3" )
-- --            luaDump(self._nPoint ," self._nPoint3" )

-- --            elseif self.scorePerLine/changciBeishu == POINT[index]  then 
-- --                   self._nPoint = 4
-- --            luaDump(POINT[index] ," POINT[index]44" )

-- --            elseif self.scorePerLine/changciBeishu == POINT[index]  then
-- --                   self._nPoint = 5
-- --            luaDump(POINT[index] ," POINT[index]55" )

-- --            elseif self.scorePerLine/changciBeishu == POINT[index]  then
-- --                   self._nPoint = 6
-- --            luaDump(POINT[index] ," POINT[index]66" )

--             end
--         end
--     end

--     luaDump(PRECENT,"PRECENT======")
--         luaDump(self._nPoint,"self._nPoint======")

    -- self._nZhuShu = self.lineCount
    -- self.SliderDanxianScore:setPercent(PRECENT[self._nPoint])


    --if self.iProgress ~= 0 then
        local Sweetnums =  self.iLevel*15 + self.iProgress 
        if Sweetnums > 45 then
           Sweetnums = 45
        end
        for i = 1, Sweetnums  do
            self._StageSweetTable[i]:setVisible(false);
        end
        self._TotalPassSweetNum = Sweetnums
        self._PassSweetNum = self.iProgress 
    --end
    self.imgGuan:loadTexture("lianhuan_guanshu" .. self._stageNum  ..".png", UI_TEX_TYPE_PLIST)
    self:InitMusic(self._stageNum);

    if self._stageNum == 1 then
        self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_4x4.png");
   
    elseif self._stageNum == 2 then
        self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_5x5.png");

    elseif self._stageNum == 3 then
        self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_6x6.png");
    end


  
    self:updatePoolPoint()
    --影藏累计奖
    self.bWinPool = 0
    self.layLeijiScore:hide()       
    
   -- 刷新自己金币数
   self:updateSelfPlayerMoney();

    --恢复小游戏   
    if self.smallStage == 3 and self.iProgress >= 15 then
       self:resumeSamllGame()
       self._TotalPassSweetNum = 0
       self._PassSweetNum = 0;
    else  
       if self.allScore <= 0 then
            self._winPoint = 0
            self.AtlasLabel_wardPool_1:setString(self._winPoint)
        end
    end                   

end

--场景恢复小游戏
function TableLayer:resumeSamllGame()
    if self.allScore > 0 then             
        self.AtlasLabel_wardPool_1:setString(self.allScore/100)
        self.isSmallGame = true;
        self.notautoSmallGame = true
        self.layLeijiScore:hide()
        self.isautoJump  = self.tableLogic:getAutoStartBool() 
                        
        local callbackStart = function ()
              self.tableLogic:sendSmallGame()                   
        end


        local callback = function ()
            self.Image_dikuang:loadTexture("lianhuanduobao/lianhuan_bg/lianhuanduobao_4x4.png");
            self.imgGuan:loadTexture("lianhuan_guanshu1.png", UI_TEX_TYPE_PLIST)
            self._winPoint = 0
            self.AtlasLabel_wardPool_1:setString("0")
            -- 刷新自己金币数
            self:updateSelfPlayerMoney();
                
            self.notautoSmallGame = false
            self._bAlreadySendStart = false;
            self:updateBatNodeBtnEnable(); 

            if self.tableLogic:getAutoStartBool() and not self._bAlreadySendStart then
                self:ClickStartBtnCallBack();
            end
        end
        local SmallGameLayer = SmallGameLayer:create(self.isautoJump,callback,callbackStart)
        SmallGameLayer:setName("SmallGameLayer")
        self:addChild(SmallGameLayer)                       
    end    
end

--累积奖
function TableLayer:GetCaiJin()
    self.layLeijiScore:show()
    self.AtlasLabel_leiji:setString(self.bWinPool/100)
    --self:ScoreToMoney(self.AtlasLabel_leiji, self.bWinPool);

   audio.playSound("lianhuanduobao/voice/sound_jinbi.mp3");
    local size = self.Image_bg:getContentSize();
    --显示特效
    local particle = cc.ParticleSystemQuad:create("effects/jinbilizi.plist")
    if particle then
        particle:setPosition(size.width/2,size.height/2);
        self.layLeijiScore:addChild(particle);
        performWithDelay(self,function() 
            if particle then
                particle:removeFromParent();
            end
        end,1.5);
    end

    self.layLeijiScore:onClick(function(sender)
		self:ClickcloseBtnCallBack(sender);
	end)
   
    audio.playSound("lianhuanduobao/voice/sound_leijijiang.mp3"); 
end

function TableLayer:ClickcloseBtnCallBack(sender)
    self.layLeijiScore:hide()
end

function TableLayer:setSelfUserInfo()
    local mySeatNo = self.tableLogic:getMySeatNo();
	local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
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
            self:addAnimation(nil, 2);

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