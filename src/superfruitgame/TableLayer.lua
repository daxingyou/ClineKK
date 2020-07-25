local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("superfruitgame.TableLogic");
local FruitTurntable = require("superfruitgame.FruitTurntable");
local SmallGameLayer = require("superfruitgame.SmallGameLayer");
local GameRuleLayer = require("superfruitgame.GameRuleLayer");
local SuperFriutInfo = require("superfruitgame.SuperFriutInfo");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

local SINGLE_FRUIT_GOLD_CONFIG_LENGTH = 5;
local SINGLE_FRUIT_GOLD_CONFIG = {
    [1] = {0.01},--体验
    [2] = {0.1,0.5,1},--初级
    [3] = {0.1,0.5,1,5,10},--中级
    [4] = {1,5,10,50,100},--高级
    [5] = {1,5,10,50,100},--土豪
};
local FRUIT_GOLD_INDEX_CONFIG = {
    [117] = 1,
    [118] = 2,
    [119] = 3,
    [120] = 4,
    [121] = 5,
};

local START_BTN_POS1 = cc.p(1205,470);
local START_BTN_POS2 = cc.p(1205,390);
local START_BTN_MOVE_TIME = 0.4;

local Show_zhanji =globalUnit.isShowZJ; --控制更多按钮处是否显示战绩

TableLayer._bShowTurnAction = false;--是否正在播放转动动画
TableLayer._bShowSmallGame = false;--是否正在小游戏

TableLayer._nGoldConfigIndex = 1;--选择的单注金币序号
TableLayer._tbGoldConfig = SINGLE_FRUIT_GOLD_CONFIG[1];

TableLayer._bShowGanAction = false;--是否正在播放杆子动画

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
	
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;
	GameMsg.init();
	SuperFriutInfo:init();

	display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");

	local uiTable = {
        --最外层元素
		Image_bg = "Image_bg",
		Button_back = "Button_back",
		Sprite_gerenxinxi = "Sprite_gerenxinxi",
		Button_otherButton = "Button_otherButton",
        Image_notice = "Image_notice",
        Node_machine = "Node_machine",
        Node_bat = "Node_bat",
        Button_autoStart = "Button_autoStart",

        --Node_machine中的元素
        AtlasLabel_wardPool = "AtlasLabel_wardPool",
        AtlasLabel_wardPool_1 = "AtlasLabel_wardPool_1",
        Image_line_1 = "Image_line_1",
        Image_line_2 = "Image_line_2",
        Image_line_3 = "Image_line_3",
        Image_line_4 = "Image_line_4",
        Image_line_5 = "Image_line_5",
        Image_line_6 = "Image_line_6",
        Image_line_7 = "Image_line_7",
        Image_line_8 = "Image_line_8",
        Image_line_9 = "Image_line_9",
        Button_start = "Button_start",
        Image_startGan = "Image_startGan",
        AtlasLabel_freeTime = "AtlasLabel_freeTime",

        --Button_otherButton中的元素
		Image_otherBtnBg = "Image_otherBtnBg",
		Button_effect = "Button_effect",
		Button_music = "Button_music",
		Button_rule = "Button_rule",
		Button_insurance = "Button_insurance",
        Button_zhanji = "Button_zhanji",

        --Sprite_gerenxinxi中的元素
		Text_playerName = "Text_playerName",
		Text_playerMoney = "Text_playerMoney",
		Image_mejinbi = "Image_mejinbi",
		Text_playerChange = "Text_playerChange",
		Image_gerenxinxi = "Image_gerenxinxi",

        --Node_bat中的元素
        AtlasLabel_totalGold = "AtlasLabel_totalGold",
        AtlasLabel_singleGold = "AtlasLabel_singleGold",
        AtlasLabel_lineNumber = "AtlasLabel_lineNumber",
        Button_singleGoldMinus = "Button_singleGoldMinus",
        Button_singleGoldAdd = "Button_singleGoldAdd",
        Button_batMost = "Button_batMost",
	}

	loadNewCsb(self,"superfruitgame/GameScene",uiTable);

	--适配
	local framesize = cc.Director:getInstance():getWinSize()
	local addWidth = (framesize.width - 1280)/4;

	self.Sprite_gerenxinxi:setPositionX(self.Sprite_gerenxinxi:getPositionX()-addWidth);
	self.Button_back:setPositionX(self.Button_back:getPositionX()-addWidth);
	self.Button_autoStart:setPositionX(self.Button_autoStart:getPositionX()+addWidth);
	self.Button_otherButton:setPositionX(self.Button_otherButton:getPositionX()+addWidth);	

	self:initData();
	self:initUI();

    _instance = self;
end
--进入
function TableLayer:onEnter()
	self:bindEvent();--绑定消息
	self.super.onEnter(self);

    --显示特效
    local bgAction = createSkeletonAnimation("shuiguojibeijing","effects/shuiguojibeijing.json","effects/shuiguojibeijing.atlas");
	if bgAction then
		bgAction:setPosition(640,360);
		bgAction:setAnimation(1,"shuiguojibeijing", true);
		self.Node_machine:addChild(bgAction);
	end
end

--绑定消息
function TableLayer:bindEvent()
    self:pushEventInfo(SuperFriutInfo,"RollResult",handler(self, self.onRollResult));
	self:pushEventInfo(SuperFriutInfo,"SmallGameResult",handler(self, self.onSmallGameResult));

	self:pushEventInfo(SuperFriutInfo,"UpdatePool",handler(self, self.onUpdatePool));

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来

	self:pushGlobalEventInfo("TEST_CONTROL",handler(self, self.onRecTestControl));
end

--初始化数据
function TableLayer:initData()	
    self.m_iHeartCount = 0;--心跳计数
	self.m_maxHeartCount = 3;--最大心跳计数
	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

    -- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

    self.playerMoney = 0;--保存玩家金币

    self.tbTurntableNode = {};--保存转盘，一共5个

    self._bShowTurnAction = false;
    self._bShowSmallGame = false;
    self._nGoldConfigIndex = 1;
    self._bShowGanAction = false;

    local roomInfo = RoomLogic:getSelectedRoom();
    local goldIndex = FRUIT_GOLD_INDEX_CONFIG[roomInfo.uRoomID] or 1;
    if goldIndex >= 1 and goldIndex <= 5 then
        self._tbGoldConfig = SINGLE_FRUIT_GOLD_CONFIG[goldIndex];
        SINGLE_FRUIT_GOLD_CONFIG_LENGTH = #self._tbGoldConfig
    end
end

function TableLayer:initUI()	
    if Show_zhanji == false then	
        self.Button_zhanji:setVisible(false);
        self.Image_otherBtnBg:setContentSize(85,260);
    else
        self.Button_zhanji:setVisible(true)
        self.Image_otherBtnBg:setContentSize(85,320)
    end
    --基本按钮
	self:initGameNormalBtn();
    
    --初始化桌子显示信息
    self:initGameDesk();

    --初始化音效音乐
    self:InitSet();
    self:InitMusic();
end

--初始化按钮
function TableLayer:initGameNormalBtn()
	--下拉菜单
	if self.Button_otherButton then
		self.Button_otherButton:setLocalZOrder(10);
		self.Button_otherButton:onClick(handler(self,self.ClickOtherButtonCallBack))
		self.Button_otherButton:setTag(0);
	end
	--规则
	if self.Button_rule then
		self.Button_rule:onClick(function(sender)
			self:ClickRuleCallBack(sender);
		end)
	end
    --保险箱
	if self.Button_insurance then
		self.Button_insurance:onClick(function(sender)
			self:ClickInsuranceCallBack(sender);
		end)
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

	--自动开始
	if self.Button_autoStart then
		self.Button_autoStart:onClick(function(sender)
			self:ClickAutoStartBtnCallBack(sender);
		end)
	end
	--返回
	if self.Button_back then
		self.Button_back:onClick(function(sender)
			self:onClickBackBtn(sender);
		end)
	end
	--音效
	if self.Button_effect then
		self.Button_effect:onClick(function(sender)
			self:ClickEffectCallBack(sender);
		end)
	end
	--音乐
	if self.Button_music then
		self.Button_music:onClick(function(sender)
			self:ClickMusicCallBack(sender);
		end)
	end
    if self.Button_start then
        self.Button_start:setLocalZOrder(9);
        self.Button_start:addClickEventListener(function(sender)
			self:ClickStartBtnCallBack(sender);
		end)
    end
    if self.Button_singleGoldAdd then
        self.Button_singleGoldAdd:onClick(function(sender)
			self:ClickGoldAddBtnCallBack(sender);
		end)
    end
    if self.Button_singleGoldMinus then
        self.Button_singleGoldMinus:onClick(function(sender)
			self:ClickGoldMinusBtnCallBack(sender);
		end)
    end
    if self.Button_batMost then
        self.Button_batMost:onClick(function(sender)
			self:ClickBatMostBtnCallBack(sender);
		end)
    end

    local NodePos = cc.p(self.Button_otherButton:getPosition());
     --区块链bar
    self.m_qklBar = Bar:create("chaojishuiguoji",self);
    self.Image_bg:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(NodePos.x-100,NodePos.y-45);
    
    if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self);
	    self:addChild(self.m_logBar);
	end
end

function TableLayer:initGameDesk()
    --自己金币数
    self:updateSelfPlayerMoney();
    --押线
    self:setLineNumber(9);
    --单注金币
    self:setSingleGoldSelectIndex(1);
    
    for i = 1, 9 do
        if self["Image_line_"..i] then
            self["Image_line_"..i]:setVisible(true);
            self["Image_line_"..i]:setLocalZOrder(10);
        end
    end
    
    for i = 1, 5 do
        local singleTurntable = FruitTurntable:create(i);
        singleTurntable:setPosition(300+(i-1)*155,185);
        self.tbTurntableNode[#self.tbTurntableNode+1] = singleTurntable;
        self.Node_machine:addChild(singleTurntable);
    end    

    if self.Image_startGan then
        self.Image_startGan:setRotation(0);
        self.Image_startGan:setLocalZOrder(8);
    end

    if self.Button_start then
        self.Button_start:setPosition(START_BTN_POS1);
    end

    self:updateAutoStartBtn();--自动开始按钮

    self:updateStartBtnIsFree();--开始按钮
end

--初始化音乐音效
function TableLayer:InitSet()
	self.Image_otherBtnBg:setLocalZOrder(101);
	display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");
	--音效
	self:updateEffectBtn();
	--音乐
	self:updateMusicBtn();
end

--初始化背景音乐
function TableLayer:InitMusic()
	local musicState = getMusicIsPlay();
	if musicState then
		audio.playMusic("superfruitgame/voice/sound-bg.mp3", true)
	else
		audio.stopMusic();
	end
end

--下拉菜单
function TableLayer:ClickOtherButtonCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");
    --重新设置纹理
    self.Image_otherBtnBg:loadTexture("sf_game_gengduoxiala.png",UI_TEX_TYPE_PLIST);
    self:InitSet();

	local senderTag = sender:getTag();

	self.actonFinish = false;--将标志位置成false
	local actionTime = 0.3;
	local moveAction;

    local btnSize = self.Button_otherButton:getContentSize();
    local posX = btnSize.width/2;
	if senderTag == 0 then--下拉
		sender:setTag(1);
		 if Show_zhanji == true then
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,-330))
        else
            moveAction = cc.MoveTo:create(actionTime,cc.p(posX,-280))
        end
		sender:loadTextures("sf_game_gengduo1.png","sf_game_gengduo1_on.png","sf_game_gengduo1_on.png",UI_TEX_TYPE_PLIST);
	else--上拉
		sender:setTag(0);
		 if Show_zhanji == true then
            moveAction = cc.MoveTo:create(actionTime,cc.p(posX,270))
        else
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,220))
        end
		sender:loadTextures("sf_game_gengduo.png","sf_game_gengduo_on.png","sf_game_gengduo_on.png",UI_TEX_TYPE_PLIST);
	end
	self.Image_otherBtnBg:runAction(cc.Sequence:create(moveAction,cc.CallFunc:create(function()
		self.actonFinish = true;
	end)));
end

--规则
function TableLayer:ClickRuleCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	
    local ruleLayer = GameRuleLayer:create();
    self:addChild(ruleLayer,1000);
end

--保险箱
function TableLayer:ClickInsuranceCallBack(sender)
	if self.actonFinish == false then
		return;
	end

    if self.tableLogic:getAutoStartBool() then
        addScrollMessage("自动游戏中，请稍后进行取款操作。");
		return;
    end

    if (self._bShowTurnAction == true or self._bShowSmallGame == true) and not isHaveBankLayer() then--开奖状态不弹保险箱
		addScrollMessage("游戏开奖中，请稍后进行取款操作。");
		return;
	end

	createBank(function (data)
        self:DealBankInfo(data)
    end,true);
end

--调用保险箱函数
function TableLayer:DealBankInfo(data)
	self.playerMoney = self.playerMoney + data.OperatScore;
	self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
end

function TableLayer:onClickBackBtn(sender)
    --有免费次数不能退出
    if self.tableLogic:getRollFreeTime() > 0 then
        addScrollMessage("免费次数使用完后才可以退出房间");
        return;
    end
    self:onClickExitGameCallBack();
end

--返回
function TableLayer:onClickExitGameCallBack(isRemove)
	local func = function()		
	    self.tableLogic:sendUserUp();
	    -- self.tableLogic:sendForceQuit();
	    self:leaveDesk()
	end

	if isRemove ~= nil then
		Hall:exitGame(isRemove,func);
	else
		Hall:exitGame(false,func);
	end
end

--音效
function TableLayer:ClickEffectCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");
	local effectState = getEffectIsPlay();
	luaPrint("音效",effectState);
	if effectState then--开着音效
		setEffectIsPlay(false);
	else
		setEffectIsPlay(true);
	end
    self:updateEffectBtn();
end

function TableLayer:updateEffectBtn()
    --音效
	local effectState = getEffectIsPlay();
	if effectState then--开着音效
		self.Button_effect:loadTextures("sf_game_yinxiao.png","sf_game_yinxiao-on.png","sf_game_yinxiao-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_effect:loadTextures("sf_game_yinxiao2.png","sf_game_yinxiao2-on.png","sf_game_yinxiao2-on.png",UI_TEX_TYPE_PLIST);
	end
end

--音乐
function TableLayer:ClickMusicCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");
	local musicState = getMusicIsPlay();
	luaPrint("音乐",musicState);
	if musicState then--开着音效
		setMusicIsPlay(false);
	else
		setMusicIsPlay(true);
	end

    self:updateMusicBtn();

	self:InitMusic();
end

function TableLayer:updateMusicBtn()
    local musicState = getMusicIsPlay();
	if musicState then--开着音效
		self.Button_music:loadTextures("sf_game_yinle.png","sf_game_yinle-on.png","sf_game_yinle-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_music:loadTextures("sf_game_yinle2.png","sf_game_yinle2-on.png","sf_game_yinle2-on.png",UI_TEX_TYPE_PLIST);
	end
end

function TableLayer:ClickGoldMinusBtnCallBack(sender)
    local nGoldConfigIndex = 1;
    --单注金币
    if self.AtlasLabel_singleGold then
        nGoldConfigIndex = self._nGoldConfigIndex or 1;
        nGoldConfigIndex = (nGoldConfigIndex - 1)%SINGLE_FRUIT_GOLD_CONFIG_LENGTH;
        if nGoldConfigIndex == 0 then
            nGoldConfigIndex = SINGLE_FRUIT_GOLD_CONFIG_LENGTH;
        end
    end
    self:setSingleGoldSelectIndex(nGoldConfigIndex);
end

function TableLayer:ClickGoldAddBtnCallBack(sender)
    local nGoldConfigIndex = 1;
    --单注金币
    if self.AtlasLabel_singleGold then
        nGoldConfigIndex = self._nGoldConfigIndex or 1;
        nGoldConfigIndex = (nGoldConfigIndex + 1)%SINGLE_FRUIT_GOLD_CONFIG_LENGTH;
        if nGoldConfigIndex == 0 then
            nGoldConfigIndex = SINGLE_FRUIT_GOLD_CONFIG_LENGTH;
        end
    end

    self:setSingleGoldSelectIndex(nGoldConfigIndex);
end

function TableLayer:ClickBatMostBtnCallBack(sender)
    --单注金币
    self:setSingleGoldSelectIndex(#self._tbGoldConfig);
end

function TableLayer:updateAutoStartBtn()
    display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");
	local bAutoStart = self.tableLogic:getAutoStartBool();
	if bAutoStart then--开着自动开始
        self.Button_autoStart:loadTextures("sf_game_zidongyouxi2.png","sf_game_zidongyouxi2-on.png","sf_game_zidongyouxi2-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_autoStart:loadTextures("sf_game_zidongyouxi1.png","sf_game_zidongyouxi1-on.png","sf_game_zidongyouxi1-on.png",UI_TEX_TYPE_PLIST);
	end
end

function TableLayer:ClickAutoStartBtnCallBack(sender)
    display.loadSpriteFrames("superfruitgame/superfruittable.plist","superfruitgame/superfruittable.png");
	local bAutoStart = self.tableLogic:getAutoStartBool();

    --开启自动开始
    if not bAutoStart then
        local roomInfo = RoomLogic:getSelectedRoom();
        local needGold = 0.01
        local goldTotal = self:getTotalGold();
        if self.playerMoney < needGold then
		    showBuyTip(true);
		    return;
        elseif self.playerMoney < goldTotal*100 then
            showBuyTip();
            return;
	    end
    end

    self.tableLogic:setAutoStartBool(not bAutoStart);
    self:updateAutoStartBtn();
    self:updateBatNodeBtnEnable();

    if not bAutoStart and not self._bShowTurnAction and not self._bShowSmallGame then
        self:ClickStartBtnCallBack();
    end
end

function TableLayer:setShowTurnActionBool(bShowTurnAction)
    self._bShowTurnAction = bShowTurnAction;
    self:updateBatNodeBtnEnable();
    self:updateStartBtnIsFree();
end

function TableLayer:setShowSmallGameBool(bShowSmallGame)
    self._bShowSmallGame = bShowSmallGame;
    self:updateBatNodeBtnEnable();
end

function TableLayer:updateBatNodeBtnEnable()
    local bShowTurnAction = self._bShowTurnAction;
    local bShowSmallGame = self._bShowSmallGame;
    local bAutoStart = self.tableLogic:getAutoStartBool();
    local bHaveFreeTime = self.tableLogic:getRollFreeTime() > 0;
    if self.Button_singleGoldAdd then
        self.Button_singleGoldAdd:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame and not bHaveFreeTime);
    end
    if self.Button_singleGoldMinus then
        self.Button_singleGoldMinus:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame and not bHaveFreeTime);
    end
    if self.Button_batMost then
        self.Button_batMost:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame and not bHaveFreeTime);
    end
    if self.Button_start then
        self.Button_start:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame);
    end
end

--开始按钮
function TableLayer:ClickStartBtnCallBack(sender)
    if self._bShowGanAction then
        return;
    end
    if self._bShowSmallGame then
        return;
    end
--    local totalGold = self:getTotalGold();
    local roomInfo = RoomLogic:getSelectedRoom();
    local needGold = 0.01
    local goldTotal = self:getTotalGold();
    if self.playerMoney < needGold or self.playerMoney < goldTotal*100 then
        addScrollMessage("金币不足,请充值");
        if self.playerMoney < needGold then
		    showBuyTip(true);
        else
            showBuyTip();
        end

        --如果在自动游戏，取消自动开始
        if self.tableLogic:getAutoStartBool() then
            self.tableLogic:setAutoStartBool(false);
            self:updateAutoStartBtn();
            self:updateBatNodeBtnEnable();
        end

		return;
	end

	if self._bShowTurnAction then
		local ganAction1 = cc.RotateTo:create(START_BTN_MOVE_TIME/2,25);
	    local ganAction2 = cc.RotateTo:create(START_BTN_MOVE_TIME/2,0);
	    local sequenceGan = cc.Sequence:create(ganAction1, ganAction2)
	    self.Image_startGan:runAction(sequenceGan);
		
		local btnAction1 = cc.MoveTo:create(START_BTN_MOVE_TIME/2,START_BTN_POS2)
	    local btnAction2 = cc.MoveTo:create(START_BTN_MOVE_TIME/2,START_BTN_POS1)
	    local sequenceBtn = cc.Sequence:create(btnAction1, btnAction2,cc.CallFunc:create(function()
	    	for i = 1, 5 do
		--        local singleData = {};
		--        for j = 1, 3 do
		--            singleData[j] = resultTable[j][i];
		--        end
		        local singleTurntable = self.tbTurntableNode[i];
		        singleTurntable:setStopFlag(true);
		    end    
	    end))
	    self.Button_start:runAction(sequenceBtn);

		return;
	end

    --按下按钮瞬间就将标志记为正在转动中
    self:setShowTurnActionBool(true);

    local ganAction1 = cc.RotateTo:create(START_BTN_MOVE_TIME/2,25);
    local ganAction2 = cc.RotateTo:create(START_BTN_MOVE_TIME/2,0);
    local sequenceGan = cc.Sequence:create(ganAction1, ganAction2)
    self.Image_startGan:runAction(sequenceGan);

    self._bShowGanAction = true;
    local btnAction1 = cc.MoveTo:create(START_BTN_MOVE_TIME/2,START_BTN_POS2)
    local btnAction2 = cc.MoveTo:create(START_BTN_MOVE_TIME/2,START_BTN_POS1)
    local sequenceBtn = cc.Sequence:create(btnAction1, btnAction2,cc.CallFunc:create(function()
    	self.Button_start:loadTextures("superfruitgame/sf_tingzhi.png","superfruitgame/sf_tingzhi-on.png","superfruitgame/sf_tingzhi-on.png");
    	self:updateBatNodeBtnEnable();
    	self.Button_start:setEnabled(true);
    	self._bShowGanAction = false;
    end))
    self.Button_start:runAction(sequenceBtn);

    audio.playSound("superfruitgame/voice/clickStart.mp3");

    --隐藏所有线
    self:hideAllLine();
    --停止所有闪烁动画
    self:stopAllBlink();
    --停止循环播放显示线动画
    self.Node_machine:stopAllActions();

    local nSingleGold = self:getNowSelectSingleGold();
    self.tableLogic:sendStartRoll(nSingleGold*100);
end

--显示中奖的线
function TableLayer:showAllLightLine(lightLineTable)
    --隐藏所有线
    self:hideAllLine();
    --停止原先闪烁动画
    self:stopAllBlink();

    for lineIndex, lightData in pairs(lightLineTable) do
        if self["Image_line_"..lineIndex] then
            --显示中奖的线
            self["Image_line_"..lineIndex]:setVisible(true);

            if lightData.bLightSpecial then
                local sycNumber = lightData.sycTable.num;
                local barNumber = lightData.barTable.num;
                local qqqNumber = lightData.qqqTable.num;
                if sycNumber >= 3 then
                    self:showBlinkSpecialFruit(lineIndex,lightData.sycTable);
                elseif barNumber >= 3 then
                    self:showBlinkSpecialFruit(lineIndex,lightData.barTable);
                elseif qqqNumber >= 3 then
                    self:showBlinkSpecialFruit(lineIndex,lightData.qqqTable);
                end
            else
                self:showBlinkNormalFruit(lineIndex,lightData.sameNumber);
            end
        end
    end
end

function TableLayer:showLineLightRepeat(lightLineTable,bSmallGame)
    local nowLightLine = 0;--目前显示点亮的线
    local action1 = cc.DelayTime:create(0.3);
    local action2 = cc.CallFunc:create(function()
        local nextLightLine = 0;
        for i = nowLightLine+1, 9 do
            if lightLineTable[i] then
                nextLightLine = i;
                break;
            end
        end

        if nextLightLine == 0 then
            if bSmallGame then
                if self:getChildByName("SmallGameLayer") then
                    return;
                end
                --创建小游戏界面
                local smallGameLayer = SmallGameLayer:create();
                smallGameLayer:setName("SmallGameLayer");
                self:addChild(smallGameLayer,99);

                bSmallGame = false;
            end
            for i = 1, 9 do
                if lightLineTable[i] then
                    nextLightLine = i;
                    break;
                end
            end
        end

        if self["Image_line_"..nextLightLine] then
            --隐藏所有线
            self:hideAllLine();
            --停止原先闪烁动画
            self:stopAllBlink();
            --显示中奖的线
            self["Image_line_"..nextLightLine]:setVisible(true);

            nowLightLine = nextLightLine;
            local lightData = lightLineTable[nextLightLine];
            if lightData.bLightSpecial then
                local sycNumber = lightData.sycTable.num;
                local barNumber = lightData.barTable.num;
                local qqqNumber = lightData.qqqTable.num;
                if sycNumber >= 3 then
                    self:showBlinkSpecialFruit(nextLightLine,lightData.sycTable);
                elseif barNumber >= 3 then
                    self:showBlinkSpecialFruit(nextLightLine,lightData.barTable);
                elseif qqqNumber >= 3 then
                    self:showBlinkSpecialFruit(nextLightLine,lightData.qqqTable);
                end
            else
                self:showBlinkNormalFruit(nextLightLine,lightData.sameNumber);
            end
        end
	end);
    local action3 = cc.DelayTime:create(1.3);
    local sequence = cc.Sequence:create(action1, action2,action3)
    local action = cc.RepeatForever:create(sequence)
    self.Node_machine:runAction(action);

end

function TableLayer:hideAllLine()
    for i = 1, 9 do
        if self["Image_line_"..i] then
            self["Image_line_"..i]:setVisible(false);
        end
    end
end

function TableLayer:stopAllBlink()
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[index];
        singleTurntable:stopBlink();
    end
end

--显示普通水果闪烁
function TableLayer:showBlinkNormalFruit(lightLine,totalNum)
    local lineTable = self.tableLogic.FruitLineTable[lightLine]
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[index];
        if totalNum >= index then
            singleTurntable:showBlink(lineTable[index]);
--        else
--            singleTurntable:stopBlink();
        end
    end
end

--显示特殊水果闪烁
function TableLayer:showBlinkSpecialFruit(lightLine,tbFruitData)
    local lineTable = self.tableLogic.FruitLineTable[lightLine]
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[index];
        if singleTurntable then
            if tbFruitData.data[index] then
                singleTurntable:showBlink(lineTable[index]);
--            else
--                singleTurntable:stopBlink();
            end
        end
    end
end

--转盘结果
function TableLayer:onRollResult(message)
    local data = message._usedata;
	luaDump(data,"转盘结果");

    --设置奖金清零
    self:setAwardPoint(0);

    local nRollFreeTime = self.tableLogic:getRollFreeTime();
    if nRollFreeTime > 0 then
        self.tableLogic:setRollFreeTime(nRollFreeTime-1);--设置免费次数
        --刷新开始按钮
        self:updateStartBtnIsFree();
    else
        local totalGold = self:getTotalGold();
        self:minusPlayerMoney(totalGold*100);--减去转一次消耗的金币
    end

    local resultTable = data.iTypeImgid;--显示水果数据
    self:setShowTurnActionBool(true);

    local callBackFunc = function()
        local bSmallGame = data.bSmallGame;--是否需要进小游戏
        if bSmallGame then
--            --有小游戏，取消自动开始
--            self.tableLogic:setAutoStartBool(false);
            self:setShowSmallGameBool(true);

            self:updateAutoStartBtn();
            self:updateBatNodeBtnEnable();
        
            if not self:getChildByName("SmallGameLayer") then
                --设置小游戏数据
                self.tableLogic:setSmallGameData(data.tbSmallWin,data.iSmallWinMoney);
            end
        end
        self:setShowTurnActionBool(false);
        --设置奖金
        self:setAwardPoint(data.iWinMoney);
        --刷新自己金币数
        self:updateSelfPlayerMoney();
        --刷新奖池
        self.tableLogic:setPoolPoint(data.iPoolPoint);
        self:updatePoolPoint();
        --免费次数
        if data.iFreeGame > 0 then
--            self.tableLogic:setRollFreeTime(nRollFreeTime + data.iFreeGame);
            self.tableLogic:setRollFreeTime(data.iFreeGame);
            --刷新开始按钮
            self:updateStartBtnIsFree();
            --撒花特效
            self:startFlowerEffect();
        else
            --撒花特效
            self:stopFlowerEffect();
        end

        --获取点亮的线数据
        local lightLineTable,awardMultiples = self.tableLogic:getLightLineData(resultTable); 
        if awardMultiples > 0 then
            self:playAwardEffect(awardMultiples,data.iWinMoney);
        end
        if table.nums(lightLineTable) <= 0 then
            local action1 = cc.DelayTime:create(1);
            local action2 = cc.CallFunc:create(function()
                if self.tableLogic:getAutoStartBool() and not self._bShowSmallGame then
                    self:ClickStartBtnCallBack();
                elseif self._bShowSmallGame then
                    --没有点亮的线，但是有小游戏
                    self:showSmallGameLayer();
                end
            end);
            local sequence = cc.Sequence:create(action1, action2)
            self.Node_machine:runAction(sequence);
            return;
        end 
        if self.tableLogic:getAutoStartBool() then
            --勾选自动开始，一次性显示所有点亮的线
            self:showAllLightLine(lightLineTable);
            local action1 = cc.DelayTime:create(2);
            local action2 = cc.CallFunc:create(function()
                if not self._bShowSmallGame and self.tableLogic:getAutoStartBool() then
                    self:ClickStartBtnCallBack();
                    return;
                end
                if self._bShowSmallGame then
                    self:showSmallGameLayer();
                end
            end);
            local sequence = cc.Sequence:create(action1, action2)
            self.Node_machine:runAction(sequence);
        else
            --未勾选自动开始，需循环播放线点亮动画
            self:showLineLightRepeat(lightLineTable,bSmallGame);
        end
    end
    
    local delayTime = 0;
    for i = 1, 5 do
        local singleData = {};
        for j = 1, 3 do
            singleData[j] = resultTable[j][i];
        end
        local singleTurntable = self.tbTurntableNode[i];
        singleTurntable:start(singleData,callBackFunc);   
    end      
end

function TableLayer:showSmallGameLayer()
    if self:getChildByName("SmallGameLayer") then
        return;
    end
    --创建小游戏界面
    local smallGameLayer = SmallGameLayer:create();
    smallGameLayer:setName("SmallGameLayer");
    self:addChild(smallGameLayer,99);
end

function TableLayer:playAwardEffect(awardMultiples,nWinPoint)
    if awardMultiples <= 0 then
        return;
    end

    local size = self.Image_bg:getContentSize();

    if awardMultiples < 30 then
        --显示特效
        local goldAction = createSkeletonAnimation("yinga","effects/yinga.json","effects/yinga.atlas");
	    if goldAction then
		    goldAction:setPosition(size.width/2,size.height/2);
		    goldAction:setAnimation(1,"yinga", true);
		    self.Image_bg:addChild(goldAction);
            performWithDelay(self,function() 
                if goldAction then
                    goldAction:removeFromParent();
                end
            end,2);
	    end
        audio.playSound("superfruitgame/voice/sound_jinbi.mp3");
        return;
    end

    --显示特效
    local awardAction = createSkeletonAnimation("zhongjiang","effects/zhongjiang.json","effects/zhongjiang.atlas");
	if not awardAction then
		return;
	end
    awardAction:setPosition(size.width/2,size.height/2);

    local strSound = 1;
    if awardMultiples >= 30 and awardMultiples < 50 then
        awardAction:setAnimation(1,"zhongjiangla", true);
        strSound = 2;
    elseif awardMultiples >= 50 and awardMultiples < 100 then
        awardAction:setAnimation(1,"bucuo", true);
        strSound = 3;
    elseif awardMultiples >= 100 and awardMultiples < 150 then
        awardAction:setAnimation(1,"facaila", true);
        strSound = 4;
    elseif awardMultiples >= 150 then
        awardAction:setAnimation(1,"damanguan", true);
        strSound = 5;
    end
    self.Image_bg:addChild(awardAction);

    audio.playSound("superfruitgame/voice/effwin"..strSound..".mp3");

    local action1 = cc.DelayTime:create(1);
    local action2 = cc.CallFunc:create(function()
        local textPoint = ccui.TextAtlas:create("", "number/huojiangzitiao.png", 79, 128, "+");
        self:ScoreToMoney(textPoint,nWinPoint,"+");
        textPoint:setPosition(cc.p(0,-60));
        awardAction:addChild(textPoint);
    end);
    local action3 = cc.DelayTime:create(1);
    local action4 = cc.CallFunc:create(function()
        awardAction:removeFromParent();
    end);
    local sequence = cc.Sequence:create(action1, action2, action3, action4)
    self:runAction(sequence);
end

--撒花特效
function TableLayer:startFlowerEffect()
    local actionOld = self.Image_bg:getChildByName("mianfeitexiaoAni");
    if actionOld then
        return;
    end
    local size = self.Image_bg:getContentSize();
    --显示特效
    local action = createSkeletonAnimation("mianfeitexiao","effects/mianfeitexiao.json","effects/mianfeitexiao.atlas");
	if action then
		action:setPosition(size.width/2,size.height/2);
		action:setAnimation(1,"mianfeitexiao", true);
        action:setName("mianfeitexiaoAni");
		self.Image_bg:addChild(action);
	end
end

function TableLayer:stopFlowerEffect()
    local action = self.Image_bg:getChildByName("mianfeitexiaoAni");
    if action then
        action:removeFromParent();
    end
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
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
    end
end

--提示小字符
function TableLayer:TipTextShow(tipText)
	addScrollMessage(tipText);
end

--设置奖池
function TableLayer:updatePoolPoint()
    if not self.AtlasLabel_wardPool then
        return;
    end
	local last = lastPoint;
    local poolPoint = self.tableLogic:getPoolPoint();
--    self:ScoreToMoney(self.AtlasLabel_wardPool,poolPoint);
	luaPrint("poolPoint===========",poolPoint)
	changeNumAni(self.AtlasLabel_wardPool,poolPoint)
end

--刷新奖池
function TableLayer:onUpdatePool(data)
	local msg = data._usedata;
    self.tableLogic:setPoolPoint(msg.iPoolPoint);
    self:updatePoolPoint();
end


--设置奖金
function TableLayer:setAwardPoint(nPoint)
    if not self.AtlasLabel_wardPool_1 then
        return;
    end
    self:ScoreToMoney(self.AtlasLabel_wardPool_1,nPoint);
end

function TableLayer:updateStartBtnIsFree()
    local nRollFreeTime = self.tableLogic:getRollFreeTime();
    if nRollFreeTime <= 0 then
	    self.Button_start:loadTextures("sf_game_kaishi.png","sf_game_kaishi-on.png","sf_game_kaishi2.png",UI_TEX_TYPE_PLIST);
        self.AtlasLabel_freeTime:setVisible(false);
    else
        self.Button_start:loadTextures("sf_game_mianfei.png","sf_game_mianfei-on.png","sf_game_mianfei2.png",UI_TEX_TYPE_PLIST);
        self.AtlasLabel_freeTime:setString(tostring(nRollFreeTime));
        self.AtlasLabel_freeTime:setVisible(true);
    end
end

function TableLayer:setSingleGoldSelectIndex(nSelectIndex)
    if not self.AtlasLabel_singleGold then
        return;
    end
    if not self._tbGoldConfig[nSelectIndex] then
        nSelectIndex = 1;
    end
    self._nGoldConfigIndex = nSelectIndex;
    self.AtlasLabel_singleGold:setString(self._tbGoldConfig[nSelectIndex]);

    --总下注
    self:updateTotalGold();
end

function TableLayer:updateTotalGold()
    if not self.AtlasLabel_totalGold then
        return;
    end
    local nSelectIndex = self._nGoldConfigIndex or 1;

    if not self._tbGoldConfig[nSelectIndex] then
        nSelectIndex = 1;
    end
    local totalGold = self._tbGoldConfig[nSelectIndex] * 9;
    self.AtlasLabel_totalGold:setString(totalGold);
end

function TableLayer:setLineNumber(nLine)
    if self.AtlasLabel_lineNumber then
        self.AtlasLabel_lineNumber:setString(nLine);
    end
end

function TableLayer:getNowSelectSingleGold()
    local nSelectIndex = self._nGoldConfigIndex or 1;

    if not self._tbGoldConfig[nSelectIndex] then
        nSelectIndex = 1;
    end
    return self._tbGoldConfig[nSelectIndex];
end

function TableLayer:getTotalGold()
    local nSingleGold = self:getNowSelectSingleGold();
    return 9*nSingleGold;
end

--玩家分数
function TableLayer:ScoreToMoney(pNode,score,string)
	if string == nil then
		string = "";
	end

	local remainderNum = score%100;
	local remainderString = "";

	if remainderNum == 0 then--保留2位小数
		remainderString = remainderString..".00";
	else
		if remainderNum%10 == 0 then
			remainderString = remainderString.."0";
		end
	end
	if pNode == nil then
		return string..(score/100)..remainderString;
	end
	pNode:setString(string..(score/100)..remainderString);
end

function TableLayer:minusPlayerMoney(nMoney)
    self.playerMoney = self.playerMoney - nMoney;
    self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
end

function TableLayer:updateSelfPlayerMoney()
    local mySeatNo = self.tableLogic:getMySeatNo();
    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
        self.playerMoney = clone(userInfo.i64Money);
    end
end

function TableLayer:setSelfUserInfo()
    local mySeatNo = self.tableLogic:getMySeatNo();
	local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		self.Text_playerName:setText(FormotGameNickName(userInfo.nickName,nickNameLen));
		self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
		self.playerMoney = clone(userInfo.i64Money);

		--更新玩家头像
		self.Image_gerenxinxi:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
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
    luaPrint("leaveDeskDdz",self._bLeaveDesk)
    if not self._bLeaveDesk then
        
        self.tableLogic:stop();
       
        self._bLeaveDesk = true;

    end
end

function TableLayer:onSmallGameResult(message)
    local data = message._usedata;
	luaDump(data,"小游戏结果");

    local smallGameLayer = self:getChildByName("SmallGameLayer");
    if not smallGameLayer then
        return;
    end

    local nStep = data.nStep;
    local nPos = data.nPos;
    local tbData = self.tableLogic:getSmallGameDataByIndex(nStep);
    tbData.nPos = nPos;
    smallGameLayer:setAlreadySelectData(nStep,tbData);

    --第4行选择完或者选中炸弹，游戏结束
    if nStep >= 4 or tbData.nReward <= 0 then   
        local gameOverCallBack = function()
            if self.tableLogic:getAutoStartBool() then
                self:ClickStartBtnCallBack();
            end
        end
        smallGameLayer:playGameOver(self.tableLogic:getSmallGamePoint(),gameOverCallBack);
        self.tableLogic:updatePoolPointAfterSmallGame();--更新小游戏之后奖池
        self:updatePoolPoint();
        self.tableLogic:setSmallGameData(nil,0);
        self:setShowSmallGameBool(false);
    else
        smallGameLayer:setNowSelectLine(nStep+1);
    end
end

--重连刷新界面
function TableLayer:ReConnectGame(msg)
    local bSmallGame = msg.bSmallGame;--是否需要进小游戏
    if bSmallGame then
        self:setShowSmallGameBool(true);
    end
    --免费次数
    self.tableLogic:setRollFreeTime(msg.iFreeGame);
    if msg.iFreeGame > 0 then
        for goldIndex, goldValue in ipairs(self._tbGoldConfig) do
            if msg.iCellMoney == goldValue*100 then
                self:setSingleGoldSelectIndex(goldIndex);
                break;
            end
        end

        --撒花特效
        self:startFlowerEffect();
    end
    --刷新开始按钮
    self:updateStartBtnIsFree();
    --刷新自己金币数
    self:updateSelfPlayerMoney();
    --刷新奖池
    self.tableLogic:setPoolPoint(msg.iPoolPoint);
    self:updatePoolPoint();
    --自动开始按钮
    self:updateAutoStartBtn();
    --压分和开始按钮
    self:updateBatNodeBtnEnable();
    --玩家信息
    self:setSelfUserInfo();

    if bSmallGame then
        if self:getChildByName("SmallGameLayer") then
            self:removeChildByName("SmallGameLayer");
        end
        --创建小游戏界面
        local smallGameLayer = SmallGameLayer:create();
        smallGameLayer:setName("SmallGameLayer");
        self:addChild(smallGameLayer,99);

        --设置小游戏数据
        self.tableLogic:setSmallGameData(msg.tbSmallWin,msg.iSmallWinMoney);

        for nStep = 1, 4 do
            local tbData = self.tableLogic:getSmallGameDataByIndex(nStep);
            if tbData and tbData.nPos > 0 then
                smallGameLayer:setAlreadySelectData(nStep,tbData);
            else
                smallGameLayer:setNowSelectLine(nStep);
                break;
            end
        end
    end

    if isHaveBankLayer() then
        createBank(function (data)
            self:DealBankInfo(data)
        end,true);
    end
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

function TableLayer:removeUser(seatNo, bIsMe,bLock)
    if not TableLayer:getInstance() then
		return;
	end
    if bIsMe then
    	self.m_bGameStart = false;
    	local str = "";
    	local func;
    	if bLock == 1 then 
    		str = "金币不足，请退出游戏!"
    		func = function ()
        		if globalUnit.isEnterGame then
        			self:onClickExitGameCallBack(5)
        		end
        	end
    		self:addAnimation(nil,2);

    		local prompt = GamePromptLayer:create();
	    	prompt:showPrompt(GBKToUtf8(str));
	    	prompt:setName("prompt_erren");
	    	prompt:setBtnClickCallBack(func,func);
	    	return;
	    elseif bLock == 0 then
    		self:onClickExitGameCallBack(5);
    	elseif bLock == 2 then
    		str ="房间已关闭,自动退出游戏。"
    		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
    			addScrollMessage(str);
    			self:onClickExitGameCallBack(5);
    		end)));
    	elseif bLock == 3 then
    		str ="长时间未操作,自动退出游戏。"
    		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
    		addScrollMessage(str);
    			self:onClickExitGameCallBack();
    		end)))
    	elseif bLock == 4 then--重新匹配
    		-- self:matchGame();
    	elseif bLock == 5 then
    		str ="vip厅房间关闭,自动退出游戏。"
    		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
    			self:onClickExitGameCallBack(5);
    			addScrollMessage(str);
    		end)));
    	end
    	
        return;
	end
end

function TableLayer:onRecTestControl(msg)
	local data = msg._usedata;
	local msg = convertToLua(data,RoomMsg.MSG_GP_S_TEST_CONTROL);
	addScrollMessage(msg.sInfo);
end

return TableLayer;