local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("shuihuzhuan.TableLogic");
local Turntable = require("shuihuzhuan.Turntable");
local SmallGameLayer = require("shuihuzhuan.SmallGameLayer");
local GameRuleLayer = require("shuihuzhuan.GameRuleLayer");
local ShuiHuZhuanInfo = require("shuihuzhuan.shuihuzhuanInfo");
local CaiJinLayer = require("shuihuzhuan.CaiJinLayer");
local RuleLayer = require("shuihuzhuan.HelpLayer");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

local SINGLE_GOLD_CONFIG_LENGTH = 5;
local SINGLE_SHZ_GOLD_CONFIG = {
    [1] = {0.01},--体验
    [2] = {0.01,0.05,0.1,0.5,1},--初级
    [3] = {0.1,0.5,1,2,5},--中级
    [4] = {0.5,1,2,5,10},--高级
    [5] = {0.01,0.05,0.1,0.5,1,2,5},--土豪
};

local SINGLE_SHZ_BEISHU_CONFIG = {
    [1] = {1},--体验
    [2] = {1,2,5,10,20},--初级
    [3] = {1,2,5,10,20},--中级
    [4] = {1,2,5,10,20},--高级
    [5] = {1,2,5,10,20},--土豪
};

local SINGLE_GOLD_CONFIG = {
    [122] = 1,
    [121] = 2,
    [158] = 3,
    [159] = 4,
    [125] = 5,
};

local BEISHU = {1,2,5,10,20}
local BEISHU_TOTAL = 5;--BEISHU中元素个数
local YAFEN = {0.09,0.18,0.45,0.9,1.8,2.25,4.5,9,18,22.5,36,45,90,180,225,360,450,900,1800,2700}
local YAFEN_TOTAL = 20;--YAFEN中元素个数
local START_BTN_POS1 = cc.p(1205,470);
local START_BTN_POS2 = cc.p(1205,390);
local START_BTN_MOVE_TIME = 0.4;

local Show_zhanji =globalUnit.isShowZJ; --控制更多按钮处是否显示战绩

TableLayer._bShowTurnAction = false;--是否正在播放转动动画
TableLayer._bShowSmallGame = false;--是否正在小游戏

TableLayer._nYafen = 1;--选择的单注金币序号
TableLayer._nBeiShu = 1;--选择的单注金币序号
TableLayer._tbGoldConfig = SINGLE_SHZ_GOLD_CONFIG[1];
TableLayer._resultTable = {}; --用于存放转盘结果的表
TableLayer._bShowWinPoint = false; --赢分

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
	ShuiHuZhuanInfo:init();

	display.loadSpriteFrames("shuihuzhuan/image/tableLayer.plist","shuihuzhuan/image/tableLayer.png");

	local uiTable = {
        --最外层元素
		Image_bg = "Image_bg",
		Head_image = "HeadImage",
		Button_moreButton = "Node_button",
        AtlasLabel_wardPool = "AtlasLabel_wardPool",
        Node_kuang = "Node_alone_kuang",
        Node_line = "Node_lianxian",
        Node_Score = "Node_Score",
        Button_otherButton = "Button_otherButton",
        Image_gerenxinxi = "Image_gerenxinxi",
        Button_CaiJinChi ="Button_caijinchi",

        --Button_otherButton中的元素
		Image_otherBtnBg = "Image_otherBtnBg",
		Button_effect = "Button_effect",
		Button_music = "Button_music",
		Button_rule = "Button_rule",
		Button_insurance = "Button_insurance",

        --Node_kuang中的元素
        Image_kuang_1_1 = "Image_kuang_1_1",
        Image_kuang_2_1 = "Image_kuang_2_1",
        Image_kuang_3_1 = "Image_kuang_3_1",
        Image_kuang_4_1 = "Image_kuang_4_1",
        Image_kuang_5_1 = "Image_kuang_5_1",
        Image_kuang_1_2 = "Image_kuang_1_2",
        Image_kuang_2_2 = "Image_kuang_2_2",
        Image_kuang_3_2 = "Image_kuang_3_2",
        Image_kuang_4_2 = "Image_kuang_4_2",
        Image_kuang_5_2 = "Image_kuang_5_2",
        Image_kuang_1_3 = "Image_kuang_1_3",
        Image_kuang_2_3 = "Image_kuang_2_3",
        Image_kuang_3_3 = "Image_kuang_3_3",
        Image_kuang_4_3 = "Image_kuang_4_3",
        Image_kuang_5_3 = "Image_kuang_5_3",

        --Node_line中的元素
		Image_xian_1 = "Image_xian_1",
        Image_xian_2 = "Image_xian_2",
        Image_xian_3 = "Image_xian_3",
        Image_xian_4=  "Image_xian_4",
        Image_xian_5 = "Image_xian_5",
        Image_xian_6 = "Image_xian_6",
        Image_xian_7 = "Image_xian_7",
        Image_xian_8 = "Image_xian_8",
        Image_xian_9 = "Image_xian_9",

        --Node_score中的元素
		AtlasLabel_totalGold = "AtlasLabel_zongyafen",
		AtlasLabel_yingfen = "AtlasLabel_yingfen",
		AtlasLabel_beishu = "AtlasLabel_beishu",
		Text_playerMoney = "AtlasLabel_money",
		AtlasLabel_yaxian = "AtlasLabel_yaxian",
        AtlasLabel_yafen = "AtlasLabel_yafen",
        Button_MultipleAdd = "Button_add_multiple",
        Button_MultipleSub = "Button_sub_multiple",
        Button_ScoreAdd = "Button_add_score",
        Button_ScoreSub = "Button_sub_score",

        --Node_button中的元素
        Button_autoStart = "Button_deposit",
        Button_start = "Button_start",
        Button_back = "Button_exit",
        Button_stop = "Button_stop",
        Button_zhanji = "Button_zhanji",
        Image_deposit = "Image_deposit",
	}

	loadNewCsb(self,"shuihuzhuan/TableLayer",uiTable);

	--适配
	local framesize = cc.Director:getInstance():getWinSize()
	local addWidth = (framesize.width - 1280)/4;

    local size = self.Image_bg:getContentSize();
    --self.Node_Score:setPositionX(size.width/2);
	self.Button_back:setPositionX(self.Button_back:getPositionX()-addWidth);
	self.Button_otherButton:setPositionX(self.Button_otherButton:getPositionX()+addWidth);	

	self:initData();
	self:initUI();

    _instance = self;
end
--进入
function TableLayer:onEnter()
	self:bindEvent();--绑定消息
	self.super.onEnter(self);   
end

--绑定消息
function TableLayer:bindEvent()
    self:pushEventInfo(ShuiHuZhuanInfo,"RollResult",handler(self, self.onRollResult));
	self:pushEventInfo(ShuiHuZhuanInfo,"SmallGameResult",handler(self, self.onSmallGameResult));
    self:pushEventInfo(ShuiHuZhuanInfo,"CaiJinInfo",handler(self, self.receiveCaiJinInfo));--明细

	self:pushEventInfo(ShuiHuZhuanInfo,"UpdatePool",handler(self, self.onUpdatePool));--明细

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

    self:updateBatNodeBtnEnable();
    self:setAwardPoint(0)
end

function TableLayer:initUI()
	self.AtlasLabel_wardPool:setString("0");
	
    if Show_zhanji == false then	
        self.Button_zhanji:setVisible(false);
        self.Image_otherBtnBg:setContentSize(75,276);
    else
        self.Button_zhanji:setVisible(true)
        self.Image_otherBtnBg:setContentSize(75,350)
    end
    --基本按钮
	self:initGameNormalBtn();
    
    --初始化桌子显示信息
    self:initGameDesk();

    --初始化音效音乐
    self:InitSet();
    self:InitMusic();

    self._nodeAnimation = cc.Node:create();
    self._nodeAnimation:setPosition(cc.p(139,0));
    self.Image_bg:addChild(self._nodeAnimation,20);

    local NodePos = cc.p(self.Button_otherButton:getPosition());
    --区块链bar
	self.m_qklBar = Bar:create("shuihuzhuan",self);
	self.Image_bg:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(NodePos.x-100,NodePos.y-45);
    
    if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self);
	    self:addChild(self.m_logBar);
	end
end

--初始化按钮
function TableLayer:initGameNormalBtn()
    --彩金池
    if self.Button_CaiJinChi then
        self.Button_CaiJinChi:onClick(function(sender)
			self:ClickcaijinchiCallBack(sender);
		end)
    end
    
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
	--自动开始
	if self.Button_autoStart then
		self.Button_autoStart:onClick(function(sender)
			self:ClickAutoStartBtnCallBack(sender);
		end)
	end
	--返回
	if self.Button_back then
		self.Button_back:onClick(handler(self,self.ClickBackCallBack))
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
        self.Button_start:onClick(function(sender)
			self:ClickStartBtnCallBack(sender);
		end)
    end
    if self.Button_stop then
        self.Button_stop:setLocalZOrder(9);
        self.Button_stop:onClick(function(sender)
			self:ClickStopBtnCallBack(sender);
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

    if self.Button_MultipleAdd then
        self.Button_MultipleAdd:onClick(function(sender)
			self:ClickMultipleAddBtnCallBack(sender);
		end)
    end
    if self.Button_MultipleSub then
        self.Button_MultipleSub:onClick(function(sender)
			self:ClickMultipleSubBtnCallBack(sender);
		end)
    end
    if self.Button_ScoreAdd then
        self.Button_ScoreAdd:addClickEventListener(function(sender)
			self:ClickScoreAddBtnCallBack(sender);
		end)
    end
    if self.Button_ScoreSub then
        self.Button_ScoreSub:addClickEventListener(function(sender)
			self:ClickScoreSubBtnCallBack(sender);
		end)
    end
end

function TableLayer:initGameDesk()
    --自己金币数
    self:updateSelfPlayerMoney();
    --押线
--    self:setLineNumber(9);
    --单注金币
    local point = cc.UserDefault:getInstance():getIntegerForKey("shz_point",1);
    self:setYaFenSelectIndex(point);
    local beishu = cc.UserDefault:getInstance():getIntegerForKey("shz_beishu",1);
    self:setBeiShuSelectIndex(beishu);

    for i = 1, 9 do
        if self["Image_xian_"..i] then
            self["Image_xian_"..i]:setVisible(true);
            self["Image_xian_"..i]:setLocalZOrder(10);
        end
    end
    
    for i = 1, 5 do
        local singleTurntable = Turntable:create(i);
        singleTurntable:setPosition(-398+(i-1)*213,-220);
        self.tbTurntableNode[#self.tbTurntableNode+1] = singleTurntable;
        self.Node_line:addChild(singleTurntable);
    end    

    local size = self.Image_bg:getContentSize();
    self.WaitYaoQi = createSkeletonAnimation("daiji","effects/yaoqinahan.json","effects/yaoqinahan.atlas");
	if self.WaitYaoQi then
		self.WaitYaoQi:setPosition(size.width/2,size.height/2);
		self.WaitYaoQi:setAnimation(1,"daiji", true);
		self.Image_bg:addChild(self.WaitYaoQi);
	end
    self:updateAutoStartBtn();--自动开始按钮

--    self:updateStartBtnIsFree();--开始按钮
end

--初始化音乐音效
function TableLayer:InitSet()
	self.Image_otherBtnBg:setLocalZOrder(101);
	display.loadSpriteFrames("shuihuzhuan/shuihuzhuantable.plist","shuihuzhuan/shuihuzhuan.png");
	--音效
	self:updateEffectBtn();
	--音乐
	self:updateMusicBtn();
end

--初始化背景音乐
function TableLayer:InitMusic()
	local musicState = getMusicIsPlay();
	if musicState then
		audio.playMusic("shuihuzhuan/voice/sound-bg.mp3", true)
	else
		audio.stopMusic();
	end
end

--下拉菜单
function TableLayer:ClickOtherButtonCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	display.loadSpriteFrames("shuihuzhuan/image/tableLayer.plist","shuihuzhuan/image/tableLayer.png");
    --重新设置纹理
    self.Image_otherBtnBg:loadTexture("shz_morekuang.png",UI_TEX_TYPE_PLIST);
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
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,-160))
        else
            moveAction = cc.MoveTo:create(actionTime,cc.p(posX,-80))
        end
		sender:loadTextures("shz_gengduo.png","shz_gengduo-on.png","shz_gengduo-on.png",UI_TEX_TYPE_PLIST);
	else--上拉
		sender:setTag(0);
        if Show_zhanji == true then
            moveAction = cc.MoveTo:create(actionTime,cc.p(posX,300))
        else
		    moveAction = cc.MoveTo:create(actionTime,cc.p(posX,220))
        end
		sender:loadTextures("shz_gengduo.png","shz_gengduo-on.png","shz_gengduo-on.png",UI_TEX_TYPE_PLIST);
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
	
    local ruleLayer = RuleLayer:create();
    self:addChild(ruleLayer,1000);
end

--彩金池
function TableLayer:ClickcaijinchiCallBack(sender)    
    TableLogic:sendGetCaiJinInfoRequest();
--    local poolPoint = self.tableLogic:getPoolPoint();
--    local CaiJinLayer = CaiJinLayer:create(poolPoint);
--    self:addChild(CaiJinLayer,1000);
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

--返回
function TableLayer:ClickBackCallBack(sender)
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
	display.loadSpriteFrames("shuihuzhuan/image/tableLayer.plist","shuihuzhuan/image/tableLayer.png");
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
		self.Button_effect:loadTextures("shz_yinxiao1.png","shz_yinxiao1-on.png","shz_yinxiao1-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_effect:loadTextures("shz_yinxiao2.png","shz_yinxiao2-on.png","shz_yinxiao2-on.png",UI_TEX_TYPE_PLIST);
	end
end

--音乐
function TableLayer:ClickMusicCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	display.loadSpriteFrames("shuihuzhuan/image/tableLayer.plist","shuihuzhuan/image/tableLayer.png");
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
		self.Button_music:loadTextures("shz_yinyue1.png","shz_yinyue1-on.png","shz_yinyue1-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_music:loadTextures("shz_yinyue2.png","shz_yinyue2-on.png","shz_yinyue2-on.png",UI_TEX_TYPE_PLIST);
	end
end

function TableLayer:ClickScoreAddBtnCallBack(sender)
    --单注金币
    if self.AtlasLabel_yafen then             
        local nYafen = self._nYafen+1;
        if nYafen > YAFEN_TOTAL then
            nYafen = 1;
        end
        self:setYaFenSelectIndex(nYafen);
    end
end

function TableLayer:ClickScoreSubBtnCallBack(sender)
    --单注金币
    if self.AtlasLabel_yafen then 
        local nYafen = self._nYafen-1;
        if nYafen < 1 then
            nYafen = YAFEN_TOTAL;
        end
        self:setYaFenSelectIndex(nYafen);
    end
end

function TableLayer:ClickMultipleSubBtnCallBack(sender)    
    --单注金币
    if self.AtlasLabel_beishu then
        local nBeiShu = self._nBeiShu-1;
        if nBeiShu < 1 then
            nBeiShu = BEISHU_TOTAL;
        end
        self:setBeiShuSelectIndex(nBeiShu);
    end   
end

function TableLayer:ClickMultipleAddBtnCallBack(sender)
    local nBeiShuConfigIndex = 0;
    --单注金币
    if self.AtlasLabel_beishu then
        local nBeiShu = self._nBeiShu+1;
        if nBeiShu > BEISHU_TOTAL then
            nBeiShu = 1;
        end
        self:setBeiShuSelectIndex(nBeiShu);
    end
end

function TableLayer:updateAutoStartBtn()
    display.loadSpriteFrames("shuihuzhuan/image/tableLayer.plist","shuihuzhuan/image/tableLayer.png");
	local bAutoStart = self.tableLogic:getAutoStartBool();
	if bAutoStart then--开着自动开始
        self.Image_deposit:setVisible(true);
	else
		self.Image_deposit:setVisible(false);
	end
end

function TableLayer:ClickAutoStartBtnCallBack(sender)
    display.loadSpriteFrames("shuihuzhuan/image/tableLayer.plist","shuihuzhuan/image/tableLayer.png");
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
end

function TableLayer:setShowSmallGameBool(bShowSmallGame)
    self._bShowSmallGame = bShowSmallGame;
    self:updateBatNodeBtnEnable();
end

function TableLayer:updateBatNodeBtnEnable()
    local bShowTurnAction = self._bShowTurnAction;
    local bShowSmallGame = self._bShowSmallGame;
    local bAutoStart = self.tableLogic:getAutoStartBool();
    if self.Button_ScoreAdd then
        self.Button_ScoreAdd:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame);        
    end
    if self.Button_ScoreSub then
        self.Button_ScoreSub:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame);       
    end
    if self.Button_MultipleAdd then
        self.Button_MultipleAdd:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame);
        self.Button_MultipleAdd:setEnabled(#BEISHU ~= 1)
    end
    if self.Button_MultipleSub then
        self.Button_MultipleSub:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame);
        self.Button_MultipleSub:setEnabled(#BEISHU ~= 1)
    end
    if self.Button_start then
        self.Button_start:setEnabled(not bShowTurnAction and not bAutoStart and not bShowSmallGame);
    end
end

--开始按钮
function TableLayer:ClickStartBtnCallBack(sender)
    if self.textPoint then
        self.textPoint:setVisible(false);
    end
    self._bShowWinPoint = false;
    if self.RewardAnimatiion then
        self.RewardAnimatiion:removeFromParent();
        self.RewardAnimatiion = nil;
    end
    if self._bShowTurnAction then
        return;
    end
    if self._bShowSmallGame then
        return;
    end
    --刷新自己金币数
    self:updateSelfPlayerMoney();
    --刷新奖池
    self.tableLogic:setPoolPoint(self._niPoolPoint);
    self:updatePoolPoint();

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

    --按下按钮瞬间就将标志记为正在转动中
    self:setShowTurnActionBool(true);

    --隐藏所有线
    self:hideAllLine();
    --停止所有闪烁动画
    self:stopAllBlink();
    --停止循环播放显示线动画
    self.Node_line:stopAllActions();

    local nYafenValue = self:getNowSelectYaFenValue();
    local nBeiShuValue = self:getNowSelectBeiShuValue();
    self.tableLogic:sendStartRoll(nYafenValue*100);
    local bAutoStart = self.tableLogic:getAutoStartBool();
    if  not bAutoStart then
        self.Button_start:setVisible(false);
        self.Button_stop:setVisible(true);
    end
end

--停止按钮
function TableLayer:ClickStopBtnCallBack(sender)
     for i = 1, 5 do
--        local singleData = {};
--        for j = 1, 3 do
--            singleData[j] = resultTable[j][i];
--        end
        local singleTurntable = self.tbTurntableNode[i];
        singleTurntable:setStopFlag(true);
    end    
    self.Button_start:setVisible(true);
    self.Button_stop:setVisible(false);
end
--显示中奖的线
function TableLayer:showAllLightLine(lightLineTable,mostShzBigThanThreeLine)
    --隐藏所有线
    self:hideAllLine();
    --停止原先闪烁动画
    self:stopAllBlink();

    for lineIndex, lightData in pairs(lightLineTable) do
        if self["Image_xian_"..lineIndex] then
            --显示中奖的线
            self["Image_xian_"..lineIndex]:setVisible(true);

            if lineIndex == mostShzBigThanThreeLine then
                if lightData.bShzLeft then
                    self:showBlinkNormalFruit(lineIndex,lightData.shzNumber);
                else
                    self:showOppositeBlinkNormalFruit(lineIndex,lightData.shzNumber);
                end
            else
                self:showBlinkNormalFruit(lineIndex,lightData.sameNumberLeft);
                self:showOppositeBlinkNormalFruit(lineIndex,lightData.sameNumberRight);
            end
        end
    end    
end

function TableLayer:showLineLightRepeat(lightLineTable,mostShzBigThanThreeLine,bSmallGame,awardMultiples,iWinMoney,tbSoundSpecial)
    local nowLightLine = 0;--目前显示点亮的线
    local bShuangxiang = true;
    local action1 = cc.DelayTime:create(0.3);
    local action2 = cc.CallFunc:create(function()
        for i = 1,5 do
            for j = 1, 3 do
                self["Image_kuang_"..i.."_"..j]:setVisible(false);
            end
        end 
        local nextLightLine = 0;
        for i = nowLightLine+1, 9 do
            if lightLineTable[i] then
                nextLightLine = i;
                break;
            end
        end

        if nextLightLine == 0 then
            --停止循环
            self.Node_line:stopAllActions();
            --是否需要显示小游戏
            if bSmallGame then
                self:createSmallGameLayer();
                bSmallGame = false;

                --设置奖金
                self:setAwardPoint(iWinMoney);
                --刷新自己金币数
                self:updateSelfPlayerMoney();
                --刷新奖池
                self.tableLogic:setPoolPoint(self._niPoolPoint);
                self:updatePoolPoint();
            else
                --播放获奖特效
                self:playAwardEffect(awardMultiples,iWinMoney);
                --特殊音效
                self:playSpecialSound(tbSoundSpecial,awardMultiples);
            end

            self:hideAllLine();
            self:showTurnSpriteEffect();
            return;
        end

        if self["Image_xian_"..nextLightLine] then
            --隐藏所有线
            self:hideAllLine();
            --停止原先闪烁动画
            self:stopAllBlink();
            --显示中奖的线
            self["Image_xian_"..nextLightLine]:setVisible(true);
            --这里做了一个处理，如果是双向都有相同的图标则同一条线需要正反展示两次效果
            nowLightLine = nextLightLine;
            local lightData = lightLineTable[nextLightLine];

            if nextLightLine == mostShzBigThanThreeLine then
                if lightData.bShzLeft then
                    self:showBlinkNormalFruit(mostShzBigThanThreeLine,lightData.shzNumber);
                else
                    self:showOppositeBlinkNormalFruit(mostShzBigThanThreeLine,lightData.shzNumber);
                end
                self:playSingleLineSound(self.tableLogic.SHZ_TYPE.SHUIHUZHUAN);
            else    
                if lightData.sameNumberLeft >= 3 and lightData.sameNumberRight >= 3 and bShuangxiang == true then              
                    self:showBlinkNormalFruit(nextLightLine,lightData.sameNumberLeft);
                    self:playSingleLineSound(lightData.sameFruitLeft);
                    nowLightLine = nowLightLine - 1;
                    bShuangxiang = false;
                elseif lightData.sameNumberLeft>=3 and bShuangxiang == true then 
                    self:showBlinkNormalFruit(nextLightLine,lightData.sameNumberLeft);
                    self:playSingleLineSound(lightData.sameFruitLeft);
                elseif lightData.sameNumberRight>=3 then
                    self:showOppositeBlinkNormalFruit(nextLightLine,lightData.sameNumberRight);
                    self:playSingleLineSound(lightData.sameFruitRight);
                    bShuangxiang = true;
                end
            end
        end
	end);
    local action3 = cc.DelayTime:create(0.6);
    local sequence = cc.Sequence:create(action1, action2,action3)
    local action = cc.RepeatForever:create(sequence)
    self.Node_line:runAction(action);   
end

function TableLayer:playSpecialSound(tbSoundSpecial,awardMultiples)
    local soundName = "";
    local totalTime = 0;
    if awardMultiples >= 50 and awardMultiples < 100 then
        if tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.ZHONGYITANG then
            soundName = "sound_sp_zyt_50";
            totalTime = 4;
        else
            soundName = "sound_sp_50";
            totalTime = 1;
        end
    elseif awardMultiples >= 100 then
        if tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.ZHONGYITANG then
            soundName = "sound_sp_zyt_100";
            totalTime = 7;
        else
            soundName = "sound_sp_100";
            totalTime = 3;
        end
    else
        if tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.TITIANXINGDAO then
            soundName = "sound_sp_ttxd";
            totalTime = 3;
        elseif tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.SONG then
            soundName = "sound_sp_sj";
            totalTime = 3;
        elseif tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.LIN then
            soundName = "sound_sp_lc";
            totalTime = 3;
        elseif tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.LU then
            soundName = "sound_sp_lzs";
            totalTime = 3;
        elseif tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.DAO then
            soundName = "sound_sp_dao";
            totalTime = 3;
        elseif tbSoundSpecial.nSoundIndex == self.tableLogic.SHZ_TYPE.QIANG then
            soundName = "sound_sp_qiang";
            totalTime = 3;
        end
    end

    if soundName ~= "" then
--        audio.stopAllSounds();
        audio.playSound("shuihuzhuan/voice/"..soundName..".mp3");    
    end
    return totalTime;
end

function TableLayer:playSingleLineSound(imgType)
    local soundName = "";
    if self.tableLogic.SHZ_TYPE.SHUIHUZHUAN == imgType or self.tableLogic.SHZ_TYPE.ZHONGYITANG == imgType or self.tableLogic.SHZ_TYPE.TITIANXINGDAO == imgType then
        soundName = "sound_other";
    elseif self.tableLogic.SHZ_TYPE.FU == imgType then
        soundName = "sound_fu";
    elseif self.tableLogic.SHZ_TYPE.DAO == imgType then
        soundName = "sound_dao";
    elseif self.tableLogic.SHZ_TYPE.QIANG == imgType then
        soundName = "sound_qiang";
    else
        soundName = "sound_renwu";
    end
    if soundName ~= "" then
        audio.playSound("shuihuzhuan/voice/"..soundName..".mp3");    
    end
end

function TableLayer:hideAllLine()
    for i = 1, 9 do
        if self["Image_xian_"..i] then
            self["Image_xian_"..i]:setVisible(false);
        end
    end
end

function TableLayer:showTurnSpriteEffect()
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[index];
        singleTurntable:showSpriteEffect();
    end
end

function TableLayer:stopAllBlink()
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[index];
        singleTurntable:stopBlink();

        for j = 1, 3 do
            self["Image_kuang_"..index.."_"..j]:setVisible(false);
        end
    end
end

--显示反向普通水果闪烁
function TableLayer:showOppositeBlinkNormalFruit(lightLine,totalNum)
    if totalNum < 3 then
        return;
    end
    local lineTable = self.tableLogic.FruitLineTable[lightLine]
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[5-index+1];
        if totalNum >= index then
            singleTurntable:showBlink(lineTable[5-index+1],self._resultTable,5-index+1);
            local newindex = 5-index+1;
            self["Image_kuang_"..newindex.."_"..lineTable[5-index+1]]:setVisible(true);
        else
            singleTurntable:setAllSpriteUnEnable();
        end
    end
end

--显示普通水果闪烁
function TableLayer:showBlinkNormalFruit(lightLine,totalNum)
    if totalNum < 3 then
        return;
    end
    local lineTable = self.tableLogic.FruitLineTable[lightLine]
    for index = 1, 5 do
        local singleTurntable = self.tbTurntableNode[index];
        if totalNum >= index then
            singleTurntable:showBlink(lineTable[index],self._resultTable,index);
            self["Image_kuang_"..index.."_"..lineTable[index]]:setVisible(true);
        else
            singleTurntable:setAllSpriteUnEnable();
        end
    end
end

--转盘结果
function TableLayer:onRollResult(message)
    if self.WaitYaoQi then
        self.WaitYaoQi:clearTracks();
        self.WaitYaoQi:setAnimation(1,"yundong", true);
    end
    local data = message._usedata;    
    self._nWinPoint = data.iWinMoney;
    self._niPoolPoint = data.iPoolPoint;
	luaDump( data.iPoolPoint," data.iPoolPoint");
    luaPrint("data.iWinMoney",data.iWinMoney);
    --设置奖金清零
    self:setAwardPoint(0);

--    local nRollFreeTime = self.tableLogic:getRollFreeTime();
--    if nRollFreeTime > 0 then
--        self.tableLogic:setRollFreeTime(nRollFreeTime-1);--设置免费次数
--        --刷新开始按钮
--        self:updateStartBtnIsFree();
--    else
        local totalGold = self:getTotalGold();
        self:minusPlayerMoney(totalGold*100);--减去转一次消耗的金币
--    end

    local resultTable = data.iTypeImgid;--显示转盘数据
    self._resultTable = resultTable;
    self:setShowTurnActionBool(true);
    
    local callBackFunc = function()      
        self.Button_start:setVisible(true);
        self.Button_stop:setVisible(false);
        if self.WaitYaoQi then
            self.WaitYaoQi:clearTracks();
            self.WaitYaoQi:setAnimation(0,"daiji", true);
        end
        local bSmallGame = data.nSmallCount > 0;--是否需要进小游戏
        if bSmallGame then
            --有小游戏，取消自动开始
--            self.tableLogic:setAutoStartBool(false);
            self:setShowSmallGameBool(true);

            self:updateAutoStartBtn();
            self:updateBatNodeBtnEnable();

            if not self:getChildByName("SmallGameLayer") then
                --设置小游戏数据
                self.tableLogic:setSmallGameData(data.tbSmallWin,data.nSmallCount,data.iSmallWinMoney,self:getNowSelectYaFenValue()/9);
            end
        end
        self:setShowTurnActionBool(false);       
        --获取点亮的线数据
        local lightLineTable,awardMultiples,mostShzBigThanThreeLine,tbSoundSpecial,AllSameawardMultiples = self.tableLogic:getLightLineData(resultTable);  
        luaPrint("AllSameawardMultiples",AllSameawardMultiples);       
        if table.nums(lightLineTable) <= 0  and AllSameawardMultiples<=0 then
            local action1 = cc.DelayTime:create(1);
            local action2 = cc.CallFunc:create(function()
                if self.tableLogic:getAutoStartBool() then
                    self:ClickStartBtnCallBack();
                end
            end);
            local sequence = cc.Sequence:create(action1, action2)
            self.Node_line:runAction(sequence);
            return;
        end 
        if self.tableLogic:getAutoStartBool() then
            if  AllSameawardMultiples > 0 then
                for i=1,3 do
                     self:showBlinkNormalFruit(i,5);
                end           
                --播放获奖特效
                self:playAwardEffect(awardMultiples,data.iWinMoney);
                local action1 = cc.DelayTime:create(2);
                local action2 = cc.CallFunc:create(function()
                    if self.tableLogic:getAutoStartBool() then
                        self:ClickStartBtnCallBack();
                    end
                end);
                local sequence = cc.Sequence:create(action1, action2)
                self.Node_line:runAction(sequence);
                return;
            else
                --勾选自动开始，一次性显示所有点亮的线
                self:showAllLightLine(lightLineTable,mostShzBigThanThreeLine);
                --播放获奖特效
                self:playAwardEffect(awardMultiples,data.iWinMoney);
            end
            --特殊音效
            local soundTime = self:playSpecialSound(tbSoundSpecial,awardMultiples);
            local action1 = cc.DelayTime:create(2+soundTime);
            local action2 = cc.CallFunc:create(function()
                if not bSmallGame and self.tableLogic:getAutoStartBool() then
                    self:ClickStartBtnCallBack();
                    return;
                end
                if bSmallGame then
                    self:createSmallGameLayer();
                    return;
                end
                self:hideAllLine();
                self:showTurnSpriteEffect();
            end);
            local sequence = cc.Sequence:create(action1, action2)
            self.Node_line:runAction(sequence);
        else            
            if AllSameawardMultiples > 0 then
                luaPrint("come in");
                for i=1,3 do
                     self:showBlinkNormalFruit(i,5);
                end           
                --播放获奖特效
                self:playAwardEffect(awardMultiples,data.iWinMoney);
                return;
            end
            --未勾选自动开始，需循环播放线点亮动画           
            self:showLineLightRepeat(lightLineTable,mostShzBigThanThreeLine,bSmallGame,awardMultiples,data.iWinMoney,tbSoundSpecial);
        end   
    end

    local bAutoStart = self.tableLogic:getAutoStartBool();

    local delayTime = 0;
    for i = 1, 5 do
        local singleData = {};
        for j = 1, 3 do
            singleData[j] = resultTable[j][i];
        end
        local singleTurntable = self.tbTurntableNode[i];
        singleTurntable:start(singleData,bAutoStart,callBackFunc);   
    end  
    audio.playSound("shuihuzhuan/voice/sound_startgame.mp3");    
end

function TableLayer:createSmallGameLayer(nGameIndex,nTurnIndex,nWinPoint,nBetPoint)
    if self:getChildByName("SmallGameLayer") then
        self:removeChildByName("SmallGameLayer");
    end

    --显示特效
    local qizhiAni = createSkeletonAnimation("qizi","effects/qizi.json","effects/qizi.atlas");
	if qizhiAni then
		qizhiAni:setPosition(640,360);
		qizhiAni:setAnimation(1,"qizi", false);
        self._nodeAnimation:addChild(qizhiAni);
	end

    performWithDelay(self,function() 
        --创建小游戏界面
        local smallGameData = {};
        smallGameData.tbGameData = self.tableLogic:getSmallGameData();
        smallGameData.nSmallCount = self.tableLogic:getSmallCountTotal();
        smallGameData.nBetPoint = self.tableLogic:getSmallGameBet();
        if nBetPoint~= nil then
        	smallGameData.nBetPoint = nBetPoint;
        end
        smallGameData.nBeiShu = 1;

        local smallGameLayer = SmallGameLayer:create(self.tableLogic,smallGameData);
        smallGameLayer:setName("SmallGameLayer");
        if nGameIndex ~= nil and nTurnIndex ~= nil then
            smallGameLayer:onConnectGame(nGameIndex,nTurnIndex,nWinPoint/100);
        end
        self:addChild(smallGameLayer,99);
    end,1.8);    
end

function TableLayer:playAwardEffect(awardMultiples,nWinPoint)   
    if awardMultiples <= 0 then
        return;
    end
    local size = self.Image_bg:getContentSize();
    local strSound = 1;  
    if awardMultiples <50 then     
        audio.playSound("shuihuzhuan/voice/sound_jinbi.mp3");
        local particle = cc.ParticleSystemQuad:create("effects/1jijinbi.plist")
--        self.RewardAnimatiion = particle;
        if particle then
            particle:setPosition(size.width/2,size.height/2);
            self.Image_bg:addChild(particle,98);
            performWithDelay(self,function() 
                if particle then
                    particle:removeFromParent();
                end
            end,2);
        end
        strSound = 1;
    elseif awardMultiples >= 50 and awardMultiples < 100 then
        --显示特效
        local particle = cc.ParticleSystemQuad:create("effects/2jijinbi.plist")
--        self.RewardAnimatiion = particle;
        if particle then
            particle:setPosition(size.width/2,size.height);
            self.Image_bg:addChild(particle,98);
            performWithDelay(self,function() 
                if particle then
                    particle:removeFromParent();
                end
            end,2);
        end
        strSound = 2;
    elseif awardMultiples >= 100 then 
        --显示特效
        local awardAction = createSkeletonAnimation("caishen","effects/caishen.json","effects/caishen.atlas");
        awardAction:setAnimation(1,"caishen", true);
        awardAction:setPosition(size.width/2,size.height/2);
        self.RewardAnimatiion = awardAction;
        self.Image_bg:addChild(awardAction,98);

        local action1 = cc.DelayTime:create(0.5);
        local action2 = cc.CallFunc:create(function()
            local particle = cc.ParticleSystemQuad:create("effects/caishenyuanbao.plist")
            particle:setPosition(cc.p(0,0));
            self.RewardAnimatiion:addChild(particle);
        end);
        local action3 = cc.DelayTime:create(5);
        local action4 = cc.CallFunc:create(function()
            if self.RewardAnimatiion then
                self.RewardAnimatiion:removeFromParent();
                self.RewardAnimatiion=nil;
            end
        end);
        local sequence = cc.Sequence:create(action1,action2,action3,action4)
        self.RewardAnimatiion:runAction(sequence);
        strSound = 3;
    end

    audio.playSound("shuihuzhuan/voice/effwin"..strSound..".mp3");

    self:playWinPoint(nWinPoint);
    --设置奖金
    self:setAwardPoint(nWinPoint);
    --刷新自己金币数
    self:updateSelfPlayerMoney();
    --刷新奖池
    self.tableLogic:setPoolPoint(self._niPoolPoint);
    self:updatePoolPoint();
end

function TableLayer:playWinPoint(nWinPoint)  
    local size = self.Image_bg:getContentSize();    
    if nWinPoint > 0 then       
        local action1 = cc.CallFunc:create(function()
            if self.textPoint then
                self:ScoreToMoney(self.textPoint,nWinPoint,"+");
                self.textPoint:setVisible(true);
            else
                self.textPoint = ccui.TextAtlas:create("", "image/number_res/shz_huojiangzitiao.png", 79, 128, "+");
                self:ScoreToMoney(self.textPoint,nWinPoint,"+");
                self.textPoint:setPosition(size.width/2,size.height/2);
                self.Image_bg:addChild(self.textPoint,99);
            end
        end);
        local action2 = cc.DelayTime:create(10);
        local action3 = cc.CallFunc:create(function()
            self.textPoint:setVisible(false);
        end);
        local sequence = cc.Sequence:create(action1, action2, action3)
        self.Image_bg:runAction(sequence);
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
    local poolPoint = self.tableLogic:getPoolPoint();
--    self:ScoreToMoney(self.AtlasLabel_wardPool,poolPoint);
	changeNumAni(self.AtlasLabel_wardPool,poolPoint);
end

--刷新奖池
function TableLayer:onUpdatePool(data)
	local msg = data._usedata;
    self.tableLogic:setPoolPoint(msg.iPoolPoint);
    self:updatePoolPoint();
end

--设置奖金
function TableLayer:setAwardPoint(nPoint)
    if not self.AtlasLabel_yingfen then
        return;
    end
    self:ScoreToMoney(self.AtlasLabel_yingfen,nPoint);
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

function TableLayer:setYaFenSelectIndex(nSelectIndex)
    if not self.AtlasLabel_yafen then
        return;
    end
    if not YAFEN[nSelectIndex] then
        nSelectIndex = 1;
    end

    self._nYafen = nSelectIndex;

    self.AtlasLabel_yafen:setString(YAFEN[nSelectIndex]);
    cc.UserDefault:getInstance():setIntegerForKey("shz_point",nSelectIndex);
    --总下注
    self:updateTotalGold();
end

function TableLayer:setBeiShuSelectIndex(nSelectIndex)
    if not self.AtlasLabel_beishu then
        return;
    end

    if not BEISHU[nSelectIndex] then
        nSelectIndex = 1;
    end

    self._nBeiShu = nSelectIndex;

    self.AtlasLabel_beishu:setString(BEISHU[nSelectIndex]);
    cc.UserDefault:getInstance():setIntegerForKey("shz_beishu",nSelectIndex);
    --总下注
    self:updateTotalGold();
end

function TableLayer:updateTotalGold()
    if not self.AtlasLabel_totalGold then
        return;
    end
    local totalGold = self:getTotalGold();
    self.AtlasLabel_totalGold:setString(totalGold);
end

--function TableLayer:updateBeiShuTotalGold(nSelectIndex)
--    if not self.AtlasLabel_totalGold then
--        return;
--    end
--    local nSelectIndex = self._nGoldConfigIndex or 1;

----    if not self._tbGoldConfig[nSelectIndex] then
----        nSelectIndex = 1;
----    end
--    local totalGold = self._tbGoldConfig[nSelectIndex] * 9;
--    self.AtlasLabel_totalGold:setString(totalGold);
--end

function TableLayer:setLineNumber(nLine)
--    if self.AtlasLabel_lineNumber then
--        self.AtlasLabel_lineNumber:setString(nLine);
--    end
end

function TableLayer:getNowSelectSingleGold()
    local nSelectIndex = self._nGoldConfigIndex or 1;

    if not YAFEN[nSelectIndex] then
        nSelectIndex = 1;
    end
    return YAFEN[nSelectIndex];
end

function TableLayer:getNowSelectYaFenValue()
    local nSelectIndex = self._nYafen or 1;

    if not YAFEN[nSelectIndex] then
        nSelectIndex = 1;
    end

    return YAFEN[nSelectIndex];
end

function TableLayer:getNowSelectBeiShuValue()
    local nSelectIndex = self._nBeiShu or 1;

    if not BEISHU[nSelectIndex] then
        nSelectIndex = 1;
    end
    luaPrint("nselectIndex",nSelectIndex,BEISHU[nSelectIndex])
    return BEISHU[nSelectIndex];
end

function TableLayer:getTotalGold()
    local nYaFenValue = self:getNowSelectYaFenValue();

    return nYaFenValue ;
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
    luaPrint("self.Text_playerMoney",self.Text_playerMoney);
	if userInfo then
		self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
        self.playerMoney = clone(userInfo.i64Money);
    end
end

function TableLayer:setSelfUserInfo()
    local mySeatNo = self.tableLogic:getMySeatNo();
	local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
		self.playerMoney = clone(userInfo.i64Money);

		--更新玩家头像
		self.Image_gerenxinxi:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
        self.Image_gerenxinxi:setScale(1.5);
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

function TableLayer:onSmallGameResult(message)
    local data = message._usedata;
	luaDump(data,"小游戏结果");

    local smallGameLayer = self:getChildByName("SmallGameLayer");
    if not smallGameLayer then
        return;
    end

    local nGameIndex = data.nIndex1;
    local nTurnIndex = data.nIndex2;

    smallGameLayer:updateSelfPlayerMoney();
    
    if self.tableLogic:checkSmallGameOver(nGameIndex,nTurnIndex) then
        local gameOverCallBack = function()
            if self.tableLogic:getAutoStartBool() then
                self:ClickStartBtnCallBack();
            else
                self:showTurnSpriteEffect();
            end
        end
        smallGameLayer:playGameOver(gameOverCallBack);
        self.tableLogic:updatePoolPointAfterSmallGame();--更新小游戏之后奖池
        self.tableLogic:setSmallGameData(nil,0,0,0);
        self:setShowSmallGameBool(false);
        --刷新自己金币数
        self:updateSelfPlayerMoney();
        self:updatePoolPoint();
    end
end

--重连刷新界面
function TableLayer:ReConnectGame(msg)
    luaDump(msg,"msgmsg");
    local bSmallGame = msg.nSmallCount > 0;--是否需要进小游戏
    if bSmallGame then
        self:setShowSmallGameBool(true);
    end
    --刷新开始按钮
--    self:updateStartBtnIsFree();
    --刷新自己金币数
    self:updateSelfPlayerMoney();
    --刷新奖池   
    luaPrint("msg.iPoolPoint",msg.iPoolPoint)
    self._niPoolPoint = msg.iPoolPoint;
    self.tableLogic:setPoolPoint(self._niPoolPoint);
    self:updatePoolPoint();
    --自动开始按钮
    self:updateAutoStartBtn();
    --压分和开始按钮
    self:updateBatNodeBtnEnable();
    --玩家信息
    self:setSelfUserInfo();

    --判断轮次大于5次的话不进入小游戏，直接获取分数
    if bSmallGame and msg.nIndex2 <= 5 then
        self:createSmallGameLayer(msg.nIndex1,msg.nIndex2,0,self:getNowSelectYaFenValue()/9);
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

function TableLayer:receiveCaiJinInfo(caiJinTable)
	luaDump(caiJinTable,"caiJinTable");
    local data = caiJinTable._usedata;
    
    local poolPoint = self.tableLogic:getPoolPoint();
    local caijinLayer = CaiJinLayer:create(data,poolPoint);
    self:addChild(caijinLayer,1000);
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
    		-- self:addAnimation(nil,2);

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