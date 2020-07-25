local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("bairenniuniu.TableLogic");
local CardSprite = require("bairenniuniu.CardSprite");
local GameLogic = require("bairenniuniu.GameLogic");
local EventMgr   = require("bairenniuniu.EventMgr");
--其他玩家列表
local PlayerListLayer = require("bairenniuniu.PlayerListLayer");
local RecordListLayer = require("bairenniuniu.RecordListLayer");

local PopUpLayer = require("bairenniuniu.PopUpLayer");
local HelpLayer = require("bairenniuniu.HelpLayer");

local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");


local Common = {
	EVT_DEAL_MSG = "BRNN_EVT_DEAL_MSG",
	EVT_VIEW_MSG = "BRNN_EVT_VIEW_MSG",
	ACTION_BEGIN = "BRNN_ACTION_BEGIN",
	ACTION_END   = "BRNN_ACTION_END",
}



--消息分发



local MaxTimes = 10   ---最大赔率

local MaxRecordCount = 7;

local PERCENT = 100;


--下注数值
-- TableLayer.m_BTJettonScore = {1, 10, 50, 100, 500, 1000}
-- TableLayer.m_BTJettonScore = {10,100, 1000, 5000, 10000, 50000}
TableLayer.m_BTJettonScore = {100, 1000, 5000, 10000, 50000,100000}
--下注数值资源
TableLayer.m_BTJettonScoreStr = {
				-- "brnn_jetton01.png", 
                "brnn_jetton1.png", 
                "brnn_jetton10.png", 
                "brnn_jetton50.png", 
                "brnn_jetton100.png", 
                "brnn_jetton500.png", 
                "brnn_jetton1000.png",
                            }

TableLayer.m_BTJettonScoreStr1 = {
				-- "brnn_jetton01.png", 
                "brnn_jetton1-on.png", 
                "brnn_jetton10-on.png", 
                "brnn_jetton50-on.png", 
                "brnn_jetton100-on.png", 
                "brnn_jetton500-on.png", 
                "brnn_jetton1000-on.png",
                            }

TableLayer.m_BTJettonScoreStr2 = {
				-- "brnn_jetton01.png", 
                "brnn_jetton1-b.png", 
                "brnn_jetton10-b.png", 
                "brnn_jetton50-b.png", 
                "brnn_jetton100-b.png", 
                "brnn_jetton500-b.png", 
                "brnn_jetton1000-b.png",
                            }

--牛牛动画
local NiuniuAnim ={
		name = "niuniupaixing",
		json = "bairenniuniu/anim/niuniupaixing.json",
		atlas = "bairenniuniu/anim/niuniupaixing.atlas",
}

local NiuAnimName = {
	"meiniu",
	"niu1",
	"niu2",
	"niu3",
	"niu4",
	"niu5",
	"niu6",
	"niu7",
	"niu8",
	"niu9",
	"niuniu",
	"niuniu", --小王牛
	"niuniu",	--大王牛
	"sihuaniu",
	"zhadan",
	"wuhuaniu",
	"wuxiaoniu"
}

--赢 动画
local WinAnim ={
		name = "ying",
		json = "bairenniuniu/anim/ying.json",
		atlas = "bairenniuniu/anim/ying.atlas",
}

local WinAnimName = "ying";

--游戏开始下注动画
local StartAnim = {
	-- name = "kaishixiazhu",
	-- json = "bairenniuniu/anim/kaishixiazhu.json",
	-- atlas = "bairenniuniu/anim/kaishixiazhu.atlas",
}

local StartAnimName = "kaishixiazhu";


--倒计时警告动画
local WarnAnim = {
	name = "daojishi",
	json = "game/daojishi/daojishi.json",
	atlas = "game/daojishi/daojishi.atlas",
}

local WarnAnimName = "daojishi";


--庄家变换 停止下注，请等待下一局等提示
local TipAnim = {
	name = "feiqinzoushou",
	json = "game/feiqinzoushou.json",
	atlas = "game/feiqinzoushou.atlas",
}

local TipAnimName = {
	CHANGE_BANKER = "huanzhuang",  --换庄
	WAIT_NEXT = "dengdaixiaju",	--等待下一局
	START = "kaishixiazhu",		--开始下注
	STOP = "tingzhixiazhu",		--停止下注
}


local WaitAnim ={
		name = "brnn_dengwanjia",
		json = "game/dengdai/dengdai.json",
		atlas = "game/dengdai/dengdai.atlas",
}

local WaitAnimName = "dengwanjia";
local WaitNextAnimName = "dengxiaju";


--下注已满
local EarlyAnim = {
		name = "brnn_tiqiankaijiang",
		json = "bairenniuniu/anim/tiqiankaijiang.json",
		atlas = "bairenniuniu/anim/tiqiankaijiang.atlas",
}

local EarlyAnimName = "tiqiankaijiang";



--卡牌缩放比例
local CARD_SCALE = 0.57;
local CARD_WIDTH = 145;
local CARD_HEIGHT = 188;
--gap 32
--card:setPosition(cardPos[i].x + (j-1)*gap, cardPos[i].y)
--87

--自己头像位置
local SELF_HEAD_POS = cc.p(40, 70)

--发牌位置
local cardpoint = {cc.p(690, 682), cc.p(196, 245), cc.p(196+246, 245), cc.p(196+246*2, 245), cc.p(196+246*3,245)}

--庄家头像位置
local bankerheadpoint = cc.p(445, 670) 
--玩家列表按钮位置
local userlistpoint = cc.p(45, 450)



local TAG_SELF = 101;
local TAG_BANKER = 102;
local TAG_OTHER = 103;

local DIBAN_GAP = 0;

local MAX_LOOK_ROUND = 5;  --最多不下注局数
--天地玄黄区域
TableLayer.m_jettonAreaTag ={1,2,4,8}


TableLayer._apply_state =
{
    kBankerState = 0,	--庄家状态
    kPlayerState = 1,	--闲家状态
    kBankerApplyState = 2, --申请庄家状态
    kBankerQuitState = 3,	--取消申请状态
}



local APPLY_STATE = {
    kBankerState = 1,	--庄家状态
    kPlayerState = 2,	--闲家状态
    kBankerApplyState = 3, --申请庄家状态
    kBankerQuitState = 4,	--取消申请状态
}

--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)
	bulletCurCount = 0;

	GameMsg.init();

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

	if GameMsg == nil then
		--todo
	end

	BRNNInfo:init()
	GameMsg.init();


	--获取ui
	local uiTable = {
		Image_bg = "Image_bg",		--背景图
		Image_tableBg = "1",	--背景桌子图

		Panel_menu = "1",		--菜单面板
		Button_exit = "1",		--返回按钮
		Button_menuShrink = "1",	--菜单按钮 收起
		Button_menuExpand = "1",	--菜单按钮 扩展

		Panel_info = "1",	--桌子信息面板
		Image_status = "1",	--当前时钟状态
		Image_clock = "1",
		Text_clock = "1",	--时钟倒计时
		Text_tableInfo = "1", --房间信息

		Panel_player = "1",	--用户信息面板
		Image_coinBag = "1",	--玩家金币口袋
		Image_selfHead = "1",	--自己的头像框
		Text_selfName = "1",	--自己昵称
		Button_charge = "1",	--充值按钮
		Text_selfCoin = "1",	--自己金币
		Panel_Jetton = "1",		--自己下注面板
		Button_keep = "1",	--续投按钮
		Image_jettonSelected = "1", --筹码选中光环
		Panel_others = "1", --其他玩家

		Image_buttom = "1",	--
		Image_selfBack = "1",--
		Image_top		= "1",--

		Image_bankerCoin = "1",		--庄家金币背景框
		Text_bankerName = "1",		--庄家名称
		Text_bankerCoin = "1",		--庄家金币
		Image_coinBankerBag = "1",  --庄家金币口袋
		Button_apply = "1",			--申请上庄按钮
		Button_quit = "1",			--下庄按钮
		Button_quit_cancel = "1",			--取消申请下庄
		Button_apply_cancel = "1",			--取消申请上庄

		Button_apply_list = "1",	--上庄列表 按钮
		Image_apply = "1",			--当前申请玩家人数image
		Text_apply = "1",			--当前申请玩家人数

		Button_others = "1",		--其他玩家按钮
		Text_others = "1",			--其他玩家人数

		Panel_table = "1",			--桌面层 天地雄黄
		
		Text_leftJetton = "1",		--剩余可下注数量
		Text_totalJetton = "1",		--当前总下注
		Image_remainBanker = "1",	--连庄
		Text_remainBanker = "1",	--连庄次数
		Image_cardShoe = "1",		--牌靴
		Sprite_cardBack = "1", 		--卡牌发牌位置

		Panel_jettons = "1",		--筹码层
		Panel_cards = "1",			--发牌层
		Panel_anims = "1",			--动画层
		Panel_dialog = "1",			--对话框层
		Image_tip = "1",			--等待下一局开始  等提示

		Panel_statusTip = "1",		--开始下注等 提示
		Image_startTip = "1",			--提示图片
		Image_changeBankerTip = "1", --庄家轮换

		Panel_result = "1",			--结果飘字层

		Panel_bankerlist = "1",		--上庄列表 面板
		ListView_bl = "1",			--上庄列表 面板ListView_bl 

		Panel_luzi = "1",	--路子
		Panel_unit = "1",	--路子unit
		Text_round	= "1",	--本日局数

		Panel_box = "1",	--菜单层
		Panel_boxList  = "1",  --菜单裁剪层
		Image_boxBg = "1",	--菜单背景图
		Button_safeBox = "1", --保险箱
		Button_help = "1",	--规则
		Button_effect = "1", --音效
		Button_music = "1", --音乐
		Node_left	= "1", --node
		Node_right = "1",

	}

	
	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end
	--适配
	uiTable["Button_exit"] = {"Button_exit",0,1};
	uiTable["Text_tableInfo"] = {"Text_tableInfo",0};
	uiTable["Button_others"] = {"Button_others",0};
	uiTable["Image_brackets"] = {"Image_brackets",0};
	uiTable["Text_others"] = {"Text_others",0};
	uiTable["Node_left"] = {"Node_left",0};

	uiTable["Button_menuExpand"] = {"Button_menuExpand",1};
	uiTable["Button_menuShrink"] = {"Button_menuShrink",1};
	uiTable["Panel_boxList"] = {"Panel_boxList",1};
	uiTable["Node_right"] = {"Node_right",1};	
	

	-- 游戏内消息处理

	loadNewCsb(self,"bairenniuniu/tablelayer",uiTable)
	self:initData();
	self:initUI();

	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	_instance = self;
end

function TableLayer:playBgMusic()
	if self.m_bMusicOn then
		playMusic("bairenniuniu/sound/sound-bg.mp3", true);
	end
end
--进入
function TableLayer:onEnter()

	-- self:initUI()
	
	cc.SpriteFrameCache:getInstance():addSpriteFrames("bairenniuniu/image/brnn_img.plist");
	cc.SpriteFrameCache:getInstance():addSpriteFrames("bairenniuniu/image/brnn_jetton.plist");
	cc.SpriteFrameCache:getInstance():addSpriteFrames("bairenniuniu/image/card.plist");
	self:bindEvent();--绑定消息
	
	
	self:playBgMusic();
	

	self:startGameMsgRun();

	EventMgr:registListener(Common.EVT_VIEW_MSG,self,self.onViewMsg);
    EventMgr:registListener(Common.EVT_DEAL_MSG,self,self.onDealMsg);


    self.super.onEnter(self);

    --VIP玩家
	self:initVipList();
	-- self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	-- self.tableLogic:enterGame();
end

--进入结束
function TableLayer:onEnterTransitionFinish()
	
end


function TableLayer:addPlist()
	display.loadSpriteFrames("bairenniuniu/image/brnn_img.plist","bairenniuniu/image/brnn_img.png");
	display.loadSpriteFrames("bairenniuniu/image/brnn_jetton.plist","bairenniuniu/image/brnn_jetton.png");
	display.loadSpriteFrames("bairenniuniu/image/card.plist","bairenniuniu/image/card.png");
end
--退出
function TableLayer:onExit()
	luaPrint("stopGameMsgRun-----------------")
	self.m_bEnterMsg = false;
	EventMgr:unregistListener(Common.EVT_VIEW_MSG,self,self.onViewMsg);
    EventMgr:unregistListener(Common.EVT_DEAL_MSG,self,self.onDealMsg);
	self:stopGameMsgRun();	
	self:clearTimeId();
	self.super.onExit(self);
end


--绑定消息
function TableLayer:bindEvent()
	if self.m_bBindEvent == true then
		return;
	end
	self:pushEventInfo(BRNNInfo, "BRNNGameFree", handler(self, self.onBRNNGameFree))
	self:pushEventInfo(BRNNInfo, "BRNNGameStart", handler(self, self.onBRNNGameStart))
	self:pushEventInfo(BRNNInfo, "BRNNGamePlaceJetton", handler(self, self.onBRNNGamePlaceJetton))
	self:pushEventInfo(BRNNInfo, "BRNNGameEnd", handler(self, self.onBRNNGameEnd))
	self:pushEventInfo(BRNNInfo, "BRNNApplyBanker", handler(self, self.onBRNNApplyBanker))
	self:pushEventInfo(BRNNInfo, "BRNNChangeBanker", handler(self, self.onBRNNChangeBanker))
	self:pushEventInfo(BRNNInfo, "BRNNChangeUserScore", handler(self, self.onBRNNChangeUserScore))
	self:pushEventInfo(BRNNInfo, "BRNNPlaceJettonFail", handler(self, self.onBRNNPlaceJettonFail))
	self:pushEventInfo(BRNNInfo, "BRNNCancelBanker", handler(self, self.onBRNNCancelBanker))
	self:pushEventInfo(BRNNInfo, "BRNNMaxJetton", handler(self, self.onBRNNMaxJetton))
	self:pushEventInfo(BRNNInfo, "BRNNGetBanker", handler(self, self.onBRNNGetBanker))
	self:pushEventInfo(BRNNInfo, "BRNNSendRecord", handler(self, self.onBRNNSendRecord))

	self:pushEventInfo(BRNNInfo, "BRNNCancelQuit", handler(self, self.onBRNNCancelQuit))
	self:pushEventInfo(BRNNInfo, "BRNNCancelQuitSuc", handler(self, self.onBRNNCancelQuitSuc))
	self:pushEventInfo(BRNNInfo, "BRNNCancelBet", handler(self, self.onBRNNCancelBet))
	self:pushEventInfo(BRNNInfo,"BRNNZhuangScore",handler(self, self.onBRNNDealZhuangScore));

	self:pushEventInfo(BRNNInfo,"BRNNContinueFail",handler(self, self.onBRNNContinueFail));
	--BRNNContinueFail

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来

	self.m_bBindEvent = true;
	
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

function TableLayer:onUserCutMessageResp(userId, byView)
	
end

--添加用户
 function TableLayer:addUser(deskStation, bMe)
	if not self:isValidSeat(deskStation) then 
		return;
	end

	self:refreshPlayerList(false);
	self:addNewVipSeat();
end

function TableLayer:removeUser(vSeatNo, bIsMe,bLock)
	luaPrint("removeUser:",vSeatNo,bIsMe);
	

	if bIsMe then
		local str = ""
		if bLock == 0 then
			self:onClickExitGameCallBack();
		elseif bLock == 1 then
			str ="您的金币不足,自动退出游戏。"
			showBuyTip(true);
		elseif bLock == 2 then
			str ="您被厅主踢出VIP厅,自动退出游戏。"
			self:onClickExitGameCallBack();
		elseif bLock == 3 then 
			str ="长时间未操作,自动退出游戏。"
			self:onClickExitGameCallBack();
		elseif bLock == 5 then 
			str ="VIP房间已关闭,自动退出游戏。"
			self:onClickExitGameCallBack();
		end
		addScrollMessage(str);
		
	else
		local lSeatNO = self.tableLogic:viewToLogicSeatNo(vSeatNo);
		self:removeVipSeat(lSeatNO);
		self:addNewVipSeat();
	end

	self:refreshPlayerList(false);

	

end

--退出
function TableLayer:onClickExitGameCallBack()
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	end


	local status = false;
	-- if self.m_iSelfStatus == Common.STATUS_PLAYING then
	-- 	status = true;		
	-- end

	Hall:exitGame(status,func);


	-- Hall:exitGame(self.isPlaying,func)
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

		--new 打开 gongfu关闭
		-- RoomLogic:close();
		
		self._bLeaveDesk = true;
		_instance = nil;
	end

end



function TableLayer:isValidSeat(seatNo)
	return seatNo < PLAY_COUNT and seatNo >= 0;
end

function TableLayer:setUserName(seatNo, name)
	if not self:isValidSeat(seatNo) then 
		return;
	end

	seatNo = seatNo + 1;

end
--设置玩家分数显示隐藏
function TableLayer:showUserMoney(seatNo, visible)
	
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
 -- //清理桌面f
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


function TableLayer:loadAllUser()
	self:refreshPlayerCount();
end


-------------------------------------------------------------------------------------
--初始化数据
function TableLayer:initData()

	self.playerInfo = {};--包括昵称 ID 登陆IP 性别	

	self.m_iHeartCount = 0;--心跳计数
	self.m_maxHeartCount = 3;--最大心跳计数
	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子
	--是否绑定事件
	self.m_bBindEvent = false;
	self.actonFinish = true;--其他按钮伸缩动画标志
	

    --其他玩家列表
    self.m_playerListLayer = nil;
    --游戏记录列表
    self.m_recordListLayer = nil;


	--下注按钮
	self.Button_jettonTb = {};
	--下注每个区域数量
    self.Image_jettonAreaTb = {};
    --自己下注的每个区域数量
    self.Text_jettonAreaSelfTb = {};
    --全局下注区域数量
    self.Text_jettonAreaAllTb = {};

    --玩家状态按钮数组
    self.Button_applyTb = {};


    --庄家收吐筹码的位置
    self.m_bankerPos = cc.p(0,0);
    --其他玩家筹码起始位置
    self.m_otherPos = cc.p(0,0);
    --自己玩家的筹码起始位置
    self.m_selfPos = cc.p(0,0);

    --发牌起点
	self.m_tBeginPos = cc.p(0,0);
    --发牌位置
    self.Panel_cardTb = {};
    --天地玄黄 庄 扑克起点位置
    self.m_cardPosTb = {};
    --牛牛显示的位置
    self.m_niuPosTb = {};
    --赢动画 显示的位置
    self.m_winPosTb = {}

    --牌数据
    self.m_cardArray = {};


    --系统能否做庄
    self.m_bEnableSysBanker = false

    --剩余时间
    self.m_cbTimeLeave = 0;

    --显示分数
    self.m_showScore = 0;

    --申请条件
    self.m_lApplyBankerCondition = 0;

    --区域限制
    self.m_lAreaLimitScore = 0;

    
    --区域输赢
    self.m_bUserOxCard = {}
    --区域输赢倍数
    self.m_Multiple = {}
    --牛数值
    self.m_niuPoint = {}



    --游戏结算数据
   
    --本局赢分
    self.m_lSelfWinScore = 0

  
    --申请状态
    self.m_enApplyState = APPLY_STATE.kPlayerState; 

    --下注倒计时
    self.m_fJettonTime = 0.1

    --游戏状态
    self.m_cbGameStatus = 0;


    --玩家区域总下注分
    self.m_lAllJettonScore = {0,0,0,0}

    --自己区域下注分
    self.m_lUserJettonScore = {0,0,0,0}
    --自己下注总分
    self.m_lUserAllJetton = 0

    --最大下注
    self.m_lUserMaxScore = 0;
    --玩家自己分数
    self.m_lSelfScore = 0;

    --桌面扑克数据
    self.m_cbTableCardArray = {};

    --庄家赢分
    self.m_lBankerWinScore = 0
    --庄家昵称
    self.m_tBankerName = ""

    --连庄次数
    self.m_nBankerTime = 0;	
    --当前庄家
    self.m_wBankerUser = 0
    --当前庄家分数
    self.m_lBankerScore = 0

    --当前庄家得分数
    self.m_lBankerWinScore = 0;

    --其他玩家得分
    self.m_lOtherWinScore = 0;


    --选中筹码
    self.m_nJettonSelect = 1;
    --最后选中的区域
    self.m_nJettonAreaSelect = 1;


    --游戏倍率
    self.m_lMultiple = 1;
    --是否取消下庄
    self.m_wCancleBanker = false;

    --申请上庄的玩家列表
    self.m_applyBankerList = {};

    --当天总局数
    self.m_allRound = 0;
    --天地玄黄赢局数
    self.m_areaWinRoundTb = {0,0,0,0};
    --最近天仙地黄赢的趋势
    self.m_lastAreaWinTb = {};


	--筹码下标数量
	self.countIndexTb = {}
	for i,v in ipairs(TableLayer.m_BTJettonScore) do
		local str = string.format("index%d",v);
		
		self.countIndexTb[str] = 0;
	end


	for i=1,10 do
		self:addJettonIndex(1);
		self:addJettonIndex(50);
		self:addJettonIndex(1000);
	end

	--音效
	self.m_bEffectOn = getEffectIsPlay();
	--音乐
	self.m_bMusicOn = getMusicIsPlay();
	--音乐音量
	self.m_iMuiscVolume = audio.getMusicVolume();

	--切换游戏状态时间
	self.m_tTimeBegin = os.time();

	--结算动画时间
	self.m_tDealTime = 0;

	--结算显示得分
	self.m_resultTextTb = {};
	self.m_bShowWin = true;
	



	--是否消息处理中
    self.m_bRunAction = false;
    --是否进入游戏进行中
    self.m_bEnterGame = false;
    --游戏消息队列
    self.m_gameMsgArray = {};
    --消息处理ID
    self.m_msgRunTimeId = -1;
    --发牌时间进度ID 
    self.m_sendCardTimeId = -1;
    --结算亮牌时间进度ID 
    self.m_finishTimeId = -1;

    self.m_jettonAreaTagTb ={1,2,4,8};

    self.m_bEnterMsg = false;

    self.m_nApplyCount = 0; --申请上庄人数

    self.m_bMaxJetton = false;

    self.m_nLastJetton = 0; --最后下注筹码
    self.m_nLastArea = 0;	--最后下注区域

    self.chipPosY = 0;

    --其他VIP6个玩家 座席
    self.m_vipPlayerTb = {};

    --上一场下注详情
    self.m_lastChipTb = {}
    self.m_bLastJettonDone = false;


    self.m_jettonIconTb = {}

    self.m_look_round = 0; --不下注局数
    self.m_want_bankerTb = {}; --上庄列表
end
--初始化界面
function TableLayer:initUI()
	--基本按钮
	self:initGameNormalBtn();

	--加载初始化场景
	-- self:LoadGameScene();

end
--初始化按钮
function TableLayer:initGameNormalBtn()
	self:addPlist();
	--返回按钮
	self.Button_exit:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_exit:setName("Button_exit");

	--菜单按钮
	self.Button_menuExpand:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_menuExpand:setName("Button_menuExpand");
	--菜单按钮
	self.Button_menuShrink:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_menuShrink:setName("Button_menuShrink");
	self.Button_menuShrink:setVisible(false);
	--时钟状态
	self.Image_status:loadTexture("brnn_xiazhuzhong.png",UI_TEX_TYPE_PLIST);
	--时钟
	self.Text_clock:setString(tostring(0));

	--房间信息
	self.Text_tableInfo:setString("  ");
	self.Text_tableInfo:setPositionY(self.Text_tableInfo:getPositionY()-12);
	self.Text_tableInfo:setScale(0.85);

	--玩家自己
	self.Text_selfName:setString("--");
	self.Text_selfCoin:setString("0");

	--上庄列表
	self.Image_apply:setVisible(false);
	self.Button_apply_list:setVisible(true);
	--充值功能
	self.Button_apply_list:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_apply_list:setName("Button_apply_list");
	
	self.Panel_bankerlist:setVisible(false);
	self.Panel_bankerlist_cell = self.Panel_bankerlist:getChildByName("Panel_bankerlist_cell");
	self.Panel_bankerlist_cell:setVisible(false);


	--充值功能
	self.Button_charge:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_charge:setName("Button_charge");
	self.Button_charge:setVisible(false);

	--初始化下注按钮
	self.Button_jettonTb = {};
	local jettonList = TableLayer.m_BTJettonScore;
	--选择筹码的高度
	self.chipPosY = self.Panel_Jetton:getChildByName("Button_jetton1"):getPositionY();
	for i,v in ipairs(jettonList) do
		local Button_jetton = self.Panel_Jetton:getChildByName("Button_jetton"..i);
		Button_jetton:loadTextures(TableLayer.m_BTJettonScoreStr[i], TableLayer.m_BTJettonScoreStr1[i],TableLayer.m_BTJettonScoreStr2[i], UI_TEX_TYPE_PLIST)


		if Button_jetton then
			if i == 1 then
				Button_jetton:setPositionY(self.chipPosY+10);
				self:ShowChipAction(Button_jetton,true);
			end			
			Button_jetton:setTag(i);
			Button_jetton:setName("Button_jetton"..i);
			Button_jetton:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
			table.insert(self.Button_jettonTb,Button_jetton);
		else
			luaPrint("get child nil:","Button_jetton"..i)
		end
	end

	self.Image_jettonSelected:setVisible(false);

	--续投按钮
	self.Button_keep:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_keep:setName("Button_keep");

	--庄家名称
	self.Text_bankerName:setString("--");
	--庄家金币
	self.Text_bankerName:setString("");

	--上庄按钮
	self.Button_apply:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_apply:setName("Button_apply");
	--下庄按钮
	self.Button_quit:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_quit:setName("Button_quit");
	--取消上庄
	self.Button_apply_cancel:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_apply_cancel:setName("Button_apply_cancel");
	--取消下庄
	self.Button_quit_cancel:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_quit_cancel:setName("Button_quit_cancel");

	
	--申请上庄人数
	self.Text_apply:setString(string.format("申请人数:%d",0));

	--其他玩家
	self.Button_others:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_others:setName("Button_others");
	--其他玩家人数
	self.Text_others:setString(tostring(0));

	self.Image_brackets:setPositionY(self.Image_brackets:getPositionY() - 40*0);
	self.Text_others:setPositionY(self.Text_others:getPositionY() - 40*0);
	self.Button_others:setPositionY(self.Button_others:getPositionY() - 40*0);

	--口袋位置
	self.Image_coinBag:setVisible(false);
	self.Image_coinBankerBag:setVisible(false);
	

	--菜单按钮
	self.Panel_boxList:setVisible(false);
	--保险箱
	self.Button_safeBox:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_safeBox:setName("Button_safeBox");
	self.Button_safeBox:loadTextures("brnn_menu_yuebao.png", "brnn_menu_yuebao-on.png","brnn_menu_yuebao-on.png", UI_TEX_TYPE_PLIST);


	--规则
	self.Button_help:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_help:setName("Button_help");
	--音效
	self.Button_effect:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_effect:setName("Button_effect");
	--音乐
	self.Button_music:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_music:setName("Button_music");
	self.Image_boxBg:setPosition(cc.p(0,200)); --down cc.p(105,156)   --up cc.p(105,190)

	--增加战绩
	if globalUnit.isShowZJ then
		DIBAN_GAP = 60;
		self.Panel_boxList:setContentSize(cc.size(self.Panel_boxList:getContentSize().width,self.Panel_boxList:getContentSize().height+DIBAN_GAP));
		self.Panel_boxList:setPositionY(self.Panel_boxList:getPositionY() - DIBAN_GAP)
		self.Image_boxBg:ignoreContentAdaptWithSize(true);
		self.Image_boxBg:loadTexture("brnn_zhanji_di.png",UI_TEX_TYPE_PLIST)
		self.Image_boxBg:setPosition(cc.p(0,200 + DIBAN_GAP - 20)); 
		self.Button_zhanji = ccui.Button:create("brnn_zhanji.png","brnn_zhanji-on.png","brnn_zhanji-on.png",UI_TEX_TYPE_PLIST);
		self.Image_boxBg:addChild(self.Button_zhanji);
		self.Button_zhanji:setPosition(cc.p(self.Button_music:getPositionX(),self.Button_music:getPositionY()))
		--音乐
		self.Button_zhanji:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		self.Button_zhanji:setName("Button_zhanji");


		self.Button_safeBox:setPositionY(self.Button_safeBox:getPositionY() + DIBAN_GAP);
		self.Button_help:setPositionY(self.Button_help:getPositionY() + DIBAN_GAP);
		self.Button_effect:setPositionY(self.Button_effect:getPositionY() + DIBAN_GAP);
		self.Button_music:setPositionY(self.Button_music:getPositionY() + DIBAN_GAP);

		

	end



	self.m_bEffectOn = getEffectIsPlay();
	self.m_bMusicOn = getMusicIsPlay();
	if self.m_bEffectOn then
		self.Button_effect:loadTextures("brnn_menu_yinxiao-on1.png", "brnn_menu_yinxiao-on2.png","", UI_TEX_TYPE_PLIST);
	else
		self.Button_effect:loadTextures("brnn_menu_yinxiao-on.png", "brnn_menu_yinxiao1.png","", UI_TEX_TYPE_PLIST);
	end

	if self.m_bMusicOn then
		self.Button_music:loadTextures("brnn_menu_yinyue-on1.png","brnn_menu_yinyue-on2.png", "", UI_TEX_TYPE_PLIST);
	else
		self.Button_music:loadTextures("brnn_menu_yinyue-off.png","brnn_menu_yinyue-off1.png", "", UI_TEX_TYPE_PLIST);
	end





	--下庄按钮
	table.insert(self.Button_applyTb,self.Button_quit);
	--上庄按钮
	table.insert(self.Button_applyTb,self.Button_apply);
	--取消上庄
	table.insert(self.Button_applyTb,self.Button_apply_cancel);
	--取消下庄
	table.insert(self.Button_applyTb,self.Button_quit_cancel);

	for i,v in ipairs(self.Button_applyTb) do
		v:setVisible(i == 1);
	end

	
	--天地玄黄 下注区域 下注每个区域数量
    self.Text_JettonAreaTb = {};
    --自己下注的每个区域数量
    self.Text_JettonAreaSelfTb = {};

	--初始化下注区域
	for i=1,4 do
		local Image_jettonArea = self.Panel_table:getChildByName("Image_jettonArea"..i);
		if Image_jettonArea then
			Image_jettonArea:setTouchEnabled(true);
			local tag = self.m_jettonAreaTagTb[i];
			Image_jettonArea:setTag(tag);
			Image_jettonArea:setName("Image_jettonArea"..i);
			Image_jettonArea:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
			table.insert(self.Image_jettonAreaTb,Image_jettonArea);

			local text_jetton = Image_jettonArea:getChildByName("Text_selfJetton");
			local text_all = Image_jettonArea:getChildByName("Text_allJetton");
			text_jetton:setString("0");
			text_all:setString("0");
			--全局下注文本
			table.insert(self.Text_jettonAreaAllTb,text_all);
			--自己下注数量文本
			table.insert(self.Text_jettonAreaSelfTb,text_jetton);

			--插入赢动画
			local pos = cc.p(Image_jettonArea:getPosition());
			table.insert(self.m_winPosTb,pos);
    

		else
			luaPrint("get child nil:","Image_jettonArea"..i)
		end
	end


	--连续上庄
	self.Image_remainBanker:setVisible(false);
	self.Text_remainBanker:setString("0");

	--庄家轮换提示
	self.Image_changeBankerTip:setVisible(false);
	--发牌起点
	self.Image_cardShoe:setTouchEnabled(false);
	-- self.Image_cardShoe:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.Image_cardShoe:setName("Image_cardShoe");

	self.m_tBeginPos = cc.p(self.Sprite_cardBack:getPosition());

	--发牌的终点
	for i=1,5 do
		local Panel_card = self.Panel_table:getChildByName("Panel_card"..i);
		table.insert(self.Panel_cardTb,Panel_card);
		local pos = cc.p(Panel_card:getPosition());
		local size = Panel_card:getContentSize();
		local pos1 = cc.p(pos.x + size.width*0.5,pos.y+size.width*0.15);
		local pos2 = cc.p(pos.x + CARD_WIDTH*CARD_SCALE*0.5,pos.y + CARD_HEIGHT*CARD_SCALE*0.5);
		table.insert(self.m_niuPosTb,pos1);
		table.insert(self.m_cardPosTb,pos2);

	end

	--筹码层
	self.Panel_jettons:setVisible(true);

	--开始下注等游戏进程提示
	self.Panel_dialog:setVisible(true);
	--等待下局开始
	self.Image_tip:setVisible(false);
	--开始下注
	self.Panel_statusTip:setVisible(false);


	--初始化牌
	self.m_cardArray = {};
	for i=1,5 do
		local temp = {}
		for j=1,5 do
			temp[j] = CardSprite:createCard(0);
            temp[j]:setVisible(false);
            -- temp[j]:setAnchorPoint(0, 0.5);
            temp[j]:setTag(i*1000+j);
            temp[j]:setScale(CARD_SCALE);
            self.Panel_cards:addChild(temp[j]);
		end
		table.insert(self.m_cardArray,temp);
	end
	
	self.m_otherPos = cc.p(self.Button_others:getPosition());
	self.m_selfPos = cc.p(self.Image_coinBag:getPosition());
	self.m_bankerPos = cc.p(self.Image_coinBankerBag:getPosition());

	--其他玩家列表
	self.m_playerListLayer = PlayerListLayer:create(self);
	self.Node_left:addChild(self.m_playerListLayer);
	self.m_playerListLayer:setVisible(false);

	--Vip玩家列席
	self.Panel_vipTb = {}
	self.m_vipPosTb = {}
	for i=1,6 do
		local panel = self.Panel_others:getChildByName(string.format("Panel_vip%d",i));
		panel:setVisible(false);
		table.insert(self.Panel_vipTb,panel);
		table.insert(self.m_vipPosTb,cc.p(panel:getPosition()));
	end
 
	
	--历史记录列表
	-- self.m_recordListLayer = RecordListLayer:create();
	-- self.Node_right:addChild(self.m_recordListLayer);
	self:initLuzi();
	--区块链bar
	self.m_qklBar = Bar:create("bairenniuniu",self);
	self.Node_right:addChild(self.m_qklBar);
	self.m_qklBar:setPosition(cc.p(1130,560));

	if globalUnit.isShowZJ then
		self.m_logBar = LogBar:create(self);
		self.Button_exit:addChild(self.m_logBar);
	end

	--桌子号
    local size = self.Image_bg:getContentSize();
    local deskNoBg = ccui.ImageView:create("image/whichtable.png")
    deskNoBg:setAnchorPoint(0.5,1)
    deskNoBg:setPosition(self.Button_exit:getContentSize().width/2,5)
    deskNoBg:setScale(0.8)
    self.Button_exit:addChild(deskNoBg)

    local deskNo = FontConfig.createWithCharMap(self.bDeskIndex+1,"image/brnn_zhuohao.png",24,32,"0")
    deskNo:setPosition(35,deskNoBg:getContentSize().height/2)
    deskNo:setScale(0.6)
    deskNo:setAnchorPoint(1,0.5)
    deskNoBg:addChild(deskNo)

	self.Panel_boxList:getParent():reorderChild(self.Panel_boxList, 101);
end


--路子消息
function TableLayer:initLuzi()
	self.Text_roundWinTb = {};
	self.Text_roundLostTb = {};
	self.Panel_luziTb = {};
	for i=1,4 do
		local text_win = self.Panel_luzi:getChildByName(string.format("Text_win%d",i))
		local text_lost = self.Panel_luzi:getChildByName(string.format("Text_lost%d",i))
		text_win:setString("0");
		text_lost:setString("0");
		table.insert(self.Text_roundWinTb,text_win);
		table.insert(self.Text_roundLostTb,text_lost);
	end

	table.insert(self.Panel_luziTb,self.Panel_unit);
	for i=1,6 do
		local panel_unit = self.Panel_unit:clone();
		self.Panel_luzi:addChild(panel_unit);
		table.insert(self.Panel_luziTb,panel_unit);
	end
	local pos = cc.p(40,5);
	local gap = 31;
	for i,v in ipairs(self.Panel_luziTb) do
		v:setPosition(cc.p(pos.x+(i-1)*31,pos.y));
		v:setVisible(false);
	end

	self.Text_round:setString("0");
end

function TableLayer:resetLuzi()
	for i,v in ipairs(self.Text_roundWinTb) do
		v:setString("0");
	end

	for i,v in ipairs(self.Text_roundLostTb) do
		v:setString("0");
	end

	local pos = cc.p(40,5);
	local gap = 31;
	for i,v in ipairs(self.Panel_luziTb) do
		v:setPosition(cc.p(pos.x+(i-1)*31,pos.y));
		v:setVisible(false);
	end

	self.Text_round:setString("0");
end

function TableLayer:refreshDayList(allRound,winList)

	self.Text_round:setString(tostring(allRound));
	for k,v in pairs(winList) do
		self.Text_roundWinTb[k]:setString(tostring(winList[k]));
		local lost = allRound - winList[k];
		self.Text_roundLostTb[k]:setString(tostring(lost));
	end

end

function TableLayer:refreshList(lastList)

	for i,v in ipairs(self.Panel_luziTb) do
		v:setVisible(false);
	end

	for i,v in ipairs(lastList) do
		local winItem = v;
		local item = self.Panel_luziTb[i];
		for j=1,4 do
			local img_mark = item:getChildByName("Image_mark"..j);
			if winItem[j] then
				img_mark:loadTexture("brnn_gou.png",UI_TEX_TYPE_PLIST);
			else
				img_mark:loadTexture("brnn_X.png",UI_TEX_TYPE_PLIST);
			end
		end

		local img_markNew = item:getChildByName("Image_markNew");
		local num = table.nums(lastList);
		
		img_markNew:setVisible(num == i);
		item:setVisible(true);
	end

	
end


--初始化VIP6 玩家
function TableLayer:initVipList()
	self.m_vipPlayerTb = {}
	for i,v in ipairs(self.Panel_vipTb) do
		v:setVisible(false);
		v.bDeskStation = -1;
	end


	local players = self.tableLogic._deskUserList._users;
	local num = table.nums(players);
	local MAX_COUNT_VIP = 6;

	for i,v in ipairs(players) do
		local userInfo = v ;

		if not self:isMeChair(userInfo.bDeskStation) 
			and self.m_wBankerUser ~= userInfo.bDeskStation 
			and userInfo.i64Money > 0 then

			self:addVipSeat(userInfo);

		end

		local num = table.nums(self.m_vipPlayerTb);
		if num >= MAX_COUNT_VIP then
			break;
		end
	end


end


function TableLayer:addVipSeat(userInfo)
	local num = table.nums(self.m_vipPlayerTb);
	if num >= 6 then
		return;
	end

	local userItem = {};
	userItem.i64Money = userInfo.i64Money;
	userItem.bBoy = userInfo.bBoy;
	userItem.nickName = userInfo.nickName;
	userItem.bLogoID = userInfo.bLogoID;
	userItem.bDeskStation = userInfo.bDeskStation;
	userItem.dwUserID = userInfo.dwUserID;
	
	if userItem.i64Money < 0 then
		userItem.i64Money = 0;
	end

	

	

	local validSeat = self:getValidVipSeat();
	if validSeat <= 0 or validSeat > 6 then
		luaPrint("addVipSeat index error:",index);
		return;
	end
	
	table.insert(self.m_vipPlayerTb,userItem);
	
	local panel = self.Panel_vipTb[validSeat];
	local text_vipName = panel:getChildByName("Text_vipName");
	local text_vipCoin = panel:getChildByName("Text_vipCoin");
	local image_vipHead = panel:getChildByName("Image_vipHead");
	image_vipHead:loadTexture(getHeadPath(userItem.bLogoID,userItem.bBoy));
	text_vipName:setString(FormotGameNickName(userItem.nickName,6));
	text_vipCoin:setString(GameMsg.formatCoin(userItem.i64Money));
	panel.bDeskStation = userItem.bDeskStation;
	panel:setVisible(true);
end

function TableLayer:addNewVipSeat()
	local players = self.tableLogic._deskUserList._users;
	for i,v in ipairs(players) do
		local userInfo = v ;

		if not self:isMeChair(userInfo.bDeskStation) 
			and self.m_wBankerUser ~= userInfo.bDeskStation  
			and not self:isVipSeat(userInfo.bDeskStation)
			and userInfo.i64Money > 0 then
				self:addVipSeat(userInfo);
				break;
		end
	end
end


function TableLayer:resetAllVipSeat()
	-- for i,v in ipairs(self.m_vipPlayerTb) do
	-- 	local lSeat = v.bDeskStation;
	-- 	local userInfo = self.tableLogic:getUserBySeatNo(lSeat);
	-- 	local seatIndex = self:getVipSeatIndex(lSeat);
	-- 	self:resetVipSeat(seatIndex,userInfo);
	-- end
	self:initVipList();
end


function TableLayer:resetVipSeat(index,userInfo)
	if index < 0 or index > 6 then
		luaPrint("setvipseat index error:",index);
		return;
	end

	local userItem = {};
	userItem.i64Money = userInfo.i64Money;
	userItem.bBoy = userInfo.bBoy;
	userItem.nickName = userInfo.nickName;
	userItem.bLogoID = userInfo.bLogoID;
	userItem.bDeskStation = userInfo.bDeskStation;
	userItem.dwUserID = userInfo.dwUserID;

	if userItem.i64Money < 0 then
		userItem.i64Money = 0;
	end


	for i,v in ipairs(self.m_vipPlayerTb) do
		if userItem.dwUserID == v.dwUserID then
			v = userItem;
			break;
		end
	end

	local panel = self.Panel_vipTb[index];
	local text_vipName = panel:getChildByName("Text_vipName");
	local text_vipCoin = panel:getChildByName("Text_vipCoin");
	local image_vipHead = panel:getChildByName("Image_vipHead");
	image_vipHead:loadTexture(getHeadPath(userItem.bLogoID,userItem.bBoy));
	text_vipName:setString(FormotGameNickName(userItem.nickName,6));
	text_vipCoin:setString(GameMsg.formatCoin(userItem.i64Money));
	panel.bDeskStation = userItem.bDeskStation;
	panel:setVisible(true);
end

function TableLayer:updateVipSeat(index,userInfo)
	if index < 0 or index > 6 then
		luaPrint("setvipseat index error:",index);
		return;
	end

	local userItem = {};
	userItem.i64Money = userInfo.i64Money;
	userItem.bBoy = userInfo.bBoy;
	userItem.nickName = userInfo.nickName;
	userItem.bLogoID = userInfo.bLogoID;
	userItem.bDeskStation = userInfo.bDeskStation;
	userItem.dwUserID = userInfo.dwUserID;


	for i,v in ipairs(self.m_vipPlayerTb) do
		if userInfo.dwUserID == v.dwUserID then
			v = userItem;
			break;
		end
	end

	local panel = self.Panel_vipTb[index];
	local text_vipName = panel:getChildByName("Text_vipName");
	local text_vipCoin = panel:getChildByName("Text_vipCoin");
	local image_vipHead = panel:getChildByName("Image_vipHead");
	image_vipHead:loadTexture(getHeadPath(userItem.bLogoID,userItem.bBoy));
	text_vipName:setString(FormotGameNickName(userItem.nickName,6));
	text_vipCoin:setString(GameMsg.formatCoin(userItem.i64Money));
	panel.bDeskStation = userItem.bDeskStation;
	panel:setVisible(true);
end


--移除VIP
function TableLayer:removeVipSeat(lSeat)
	for i,v in ipairs(self.m_vipPlayerTb) do
		if v.bDeskStation == lSeat  then
			table.remove(self.m_vipPlayerTb,i);
			break;
		end
	end

	for i,v in ipairs(self.Panel_vipTb) do
		if v.bDeskStation == lSeat  then
			v:setVisible(false);
			v.bDeskStation = -1;
			break;
		end
	end
end



function TableLayer:getVipSeatInfo(lSeat)
	for i,v in ipairs(self.m_vipPlayerTb) do
		if v.bDeskStation == lSeat then
			return v;
		end
	end

	return nil;
end

function TableLayer:getVipSeatIndex(lSeat)
	local seatIndex = -1;
	if not self:isVipSeat(lSeat) then
		return seatIndex;
	end

	for i,v in ipairs(self.m_vipPlayerTb) do
		if v.bDeskStation == lSeat  then
			seatIndex = i;
			break;
		end
	end

	return seatIndex;
end


--获取最近的空置VIP座席
function TableLayer:getValidVipSeat()
	for i,v in ipairs(self.Panel_vipTb) do
		if not v:isVisible()  then
			return i;
		end
	end

	return -1;
end


function TableLayer:isVipSeat(lSeat)
	for i,v in ipairs(self.m_vipPlayerTb) do
		if v.bDeskStation == lSeat  then
			return true;
		end
	end

	return false;
end



function TableLayer:runJettonHeadAnim(lSeat,coin)
	local seatIndex = -1;
	if not self:isVipSeat(lSeat) then
		return;
	end

	for i,v in ipairs(self.m_vipPlayerTb) do
		if v.bDeskStation == lSeat  then
			seatIndex = i;
			break;
		end
	end

	self.Panel_vipTb[seatIndex]:stopAllActions();
	self.Panel_vipTb[seatIndex]:setPosition(self.m_vipPosTb[seatIndex]);

	if seatIndex <= 3 then
		local move = cc.MoveBy:create(0.15,cc.p(10,0))
		local eastOut = cc.EaseInOut:create(move, 1.5);
		local eastOut2 = cc.EaseInOut:create(move:reverse(), 1.5);
		self.Panel_vipTb[seatIndex]:runAction(cc.Sequence:create(eastOut,eastOut2));
	else
		local move = cc.MoveBy:create(0.15,cc.p(-10,0))
		local eastOut = cc.EaseInOut:create(move, 1.5);
		local eastOut2 = cc.EaseInOut:create(move:reverse(), 1.5);
		self.Panel_vipTb[seatIndex]:runAction(cc.Sequence:create(eastOut,eastOut2));
	end

	
end





function TableLayer:getOtherJettonPos(lSeat)
	if self:isVipSeat(lSeat) then
		local seatIndex = self:getVipSeatIndex(lSeat);
		local panel = self.Panel_vipTb[seatIndex]
		local pos = cc.p(panel:getPosition())
		return pos;
	else

		local pos = self.Button_others:getParent():convertToNodeSpace(cc.p(self.Button_others:getPosition()));
		return pos;
	end
end



--============================================百人牛牛交互======================================================

--菜单动画 展开
function TableLayer:expandBoxList()
	self.Button_menuExpand:setVisible(false);
	self.Button_menuShrink:setVisible(true);

	self.Panel_boxList:stopAllActions();
	self.Image_boxBg:stopAllActions();
	self.Panel_boxList:setVisible(true);

	self.Image_boxBg:setVisible(true);
end


function TableLayer:shrinkBoxList()
	self.Button_menuExpand:setVisible(true);
	self.Button_menuShrink:setVisible(false);
	self.Image_boxBg:setVisible(false);
end




--获取玩家自己的得分
function TableLayer:getSelfScore()
	if PlatformLogic.loginResult.i64Money ~= nil then
		return PlatformLogic.loginResult.i64Money;
	end
	return -1;
end

--设置玩家得分
function TableLayer:setSelfScore(lScore)
	PlatformLogic.loginResult.i64Money = lScore;
end


--设置下注按钮是否可以点击
function TableLayer:setJettonEnable(bEnable)
	-- self.Button_keep:setEnabled(bEnable);
    self:setKeepEnable2(bEnable);
    for k,v in pairs(self.Button_jettonTb) do
        v:setEnabled(bEnable);
        if bEnable == false then
        	self:ShowChipAction(v,false);
        end   
    end
end

function TableLayer:setKeepEnable(bEnable)
	if self.m_cbGameStatus == GameMsg.GAME_SCENE_END then
		self.Button_keep:setEnabled(false);
    	return;
	end

	if self.m_bMaxJetton then
		self.Button_keep:setEnabled(false);
    	return;
	end

	if self.m_nLastArea <= 0 then
		self.Button_keep:setEnabled(false);
    	return;
	end


	local leftScore = self.m_lSelfScore + self.m_lUserAllJetton  - self.m_lUserAllJetton * self.m_lMultiple;
	local tScore = self.m_nLastJetton*self.m_lMultiple;
	
	if self.m_lSelfScore >= self.m_nLastJetton*self.m_lMultiple and self.m_nLastJetton > 0 and leftScore >= tScore then
		self.Button_keep:setEnabled(bEnable);
	else
		self.Button_keep:setEnabled(false);
	end
end


function TableLayer:setKeepEnable2(bEnable)
	if self.m_cbGameStatus == GameMsg.GAME_SCENE_END then
		self.Button_keep:setEnabled(false);
    	return;
	end

	if self.m_bMaxJetton then
		self.Button_keep:setEnabled(false);
    	return;
	end

	if self.m_bLastJettonDone then 
		self.Button_keep:setEnabled(false);
    	return;
	end

	local m_nLastJetton = self:getLastRecordScore()
	if m_nLastJetton <= 0 then
		self.Button_keep:setEnabled(false);
    	return;
	end


	if self.m_lUserAllJetton > 0 then
		self.Button_keep:setEnabled(false);
		return 
	end


	local leftScore = self.m_lSelfScore + self.m_lUserAllJetton  - self.m_lUserAllJetton * self.m_lMultiple;
	local tScore = m_nLastJetton*self.m_lMultiple;
	
	if self.m_lSelfScore >= m_nLastJetton*self.m_lMultiple and m_nLastJetton > 0 and leftScore >= tScore then
		self.Button_keep:setEnabled(bEnable);
	else
		self.Button_keep:setEnabled(false);
	end
end

--更新下注按钮
--score：可以下注金额*MaxTimes
function TableLayer:updateJettonList()

	if self:isMeChair(self.m_wBankerUser) then
		return;
	end

	if self.m_wBankerUser == INVALID_DESKSTATION then
		self:setJettonEnable(false);
		return;
	end

	if self.m_cbGameStatus == GameMsg.GAME_SCENE_END then
		self:setJettonEnable(false);
    	return;
	end

	if self.m_bMaxJetton then
		
		self:setJettonEnable(false);
    	return;
	end

	--小于30金币
	-- if self.m_lSelfScore < 30*PERCENT then
	-- 	self:setJettonEnable(false);
	-- 	return;
	-- end

	local score = self.m_lSelfScore + self.m_lUserAllJetton  - self.m_lUserAllJetton *self.m_lMultiple; --math.floor(self.m_lSelfScore/self.m_lMultiple);
	local index = 0;
	for i,v in ipairs(TableLayer.m_BTJettonScore) do
		local tScore = v*self.m_lMultiple
		-- local tScore = v*self.m_lMultiple*PERCENT
		if tScore <= score then
			self.Button_jettonTb[i]:setEnabled(true);
			index = i;

		else
			self.Button_jettonTb[i]:setEnabled(false);
		end
	end


	if index == 0 then
		self.m_nJettonSelect = 1;
		-- self:setKeepEnable(false);
		-- self.Button_keep:setEnabled(false);
		for i,v in ipairs(self.Button_jettonTb) do
			v:setPositionY(self.chipPosY);
			self:ShowChipAction(v,false);
			v:setEnabled(false);
		end
		self:onJettonButtonClicked(self.m_nJettonSelect,self.Button_jettonTb[self.m_nJettonSelect]);

	elseif self.m_nJettonSelect > index then

		-- self:setKeepEnable(true);
		-- self.Button_keep:setEnabled(true);
		self.m_nJettonSelect = index;
		self:onJettonButtonClicked(self.m_nJettonSelect,self.Button_jettonTb[index]);
	else
		--还原光圈
		for i,v in ipairs(self.Button_jettonTb) do
	    	if v:getTag() == self.m_nJettonSelect and v:isEnabled() then
	    		v:setPositionY(self.chipPosY+10);
	    		self:ShowChipAction(v,true);
	    	else
	    		v:setPositionY(self.chipPosY);
	    		self:ShowChipAction(v,false);
	    	end
	    end
	end
end

--筹码旋转
function TableLayer:ShowChipAction(pNode,isShow)
	if isShow then
		local chipAction = pNode:getChildByName("chipAction");

		if chipAction then
			return;
		end

		local size = pNode:getContentSize();

		local chipAction = createSkeletonAnimation("xuanzhong","hall/game/xuanzhong.json","hall/game/xuanzhong.atlas");
		if chipAction then
			chipAction:setPosition(size.width/2,size.height/2+5);
			chipAction:setAnimation(1,"xuanzhong", true);
			chipAction:setName("chipAction");
			chipAction:setScale(1.2)
			pNode:addChild(chipAction);
		end
	else
		pNode:stopAllActions();
		pNode:removeAllChildren();
	end
end



function TableLayer:UpdateUserList()

	local function onRefreshDone(sender,event)
    	local players = self.tableLogic._deskUserList._users;
	
		self:resetAllVipSeat();

		self:refreshPlayerList();

		local userInfo = self.tableLogic:getUserBySeatNo(self.m_wBankerUser);
		if  not userInfo  then
			return 
		end

	    self.m_lBankerScore = userInfo.i64Money;
		self:resetBankerInfo();
    end


	self.Panel_others:stopAllActions();
    self.Panel_others:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(onRefreshDone)));
end


--保险箱
function TableLayer:setBankBoxEnable(bEnable)

	-- self.Button_safeBox:setEnabled(bEnable);
	-- self.Button_safeBox:setBright(bEnable);
end

--刷新自己信息
function TableLayer:resetSelfInfo()
    local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
    
    if userInfo then
    	self.Text_selfName:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
		self.Text_selfCoin:setString(GameMsg.formatCoin(self.m_lSelfScore));
		local image_head = self.Image_selfHead:getParent():getChildByName("img_head");
		if not image_head then
			local headPath = getHeadPath(userInfo.bLogoID,userInfo.bBoy);
			
			image_head = ccui.ImageView:create(headPath);
			self.Image_selfHead:getParent():addChild(image_head);
			local size = self.Image_selfHead:getContentSize();
			local sizeHead = image_head:getContentSize();
			image_head:setName("ima_head");
			image_head:setScale(size.width*0.8/sizeHead.width);
			image_head:setPosition(cc.p(self.Image_selfHead:getPosition()))

		end


    else
    	self.Text_selfName:setString("--")
		self.Text_selfCoin:setString("0");
    end
	
end

function TableLayer:gameBuymoney( data )
	self:resetSelfCoin(data);

end


--更新银行保险箱 safebox
function TableLayer:resetSelfCoin(data)
	-- luaDump(data, "resetSelfCoin____data_____", 6)
	if PlatformLogic.loginResult.dwUserID ~= data.UserID then
		
		return;
	end

	self.m_lSelfScore = self.m_lSelfScore + data.OperatScore;
	self.m_lUserMaxScore = self.m_lUserMaxScore + data.OperatScore;

	
	if self:isMeChair(self.m_wBankerUser)  then
		self.m_lBankerScore = self.m_lBankerScore + data.OperatScore;
		local bankerScore = GameMsg.formatCoin(self.m_lBankerScore);
		self.Text_bankerCoin:setString(bankerScore);
	else
		if self.m_cbGameStatus == GameMsg.GAME_SCENE_END then
       
    	elseif self.m_cbGameStatus == GameMsg.GAME_SCENE_JETTON then
    		self:updateJettonList();
			self:setKeepEnable2(true);
    	end
	end
	


	local playerScore = GameMsg.formatCoin(self.m_lSelfScore);
	self.Text_selfCoin:setString(playerScore);



end





--刷新庄家信息
function TableLayer:resetBankerInfo()
    
    if self.m_wBankerUser == INVALID_DESKSTATION then
    	self.Text_bankerName:setString("无人坐庄");
    	self.Text_bankerCoin:setString(tostring(0));
        self.Button_apply:setVisible(true);
    else
    	local userInfo = self.tableLogic:getUserBySeatNo(self.m_wBankerUser);
    	if  not userInfo  then
    		return 
    	end
    	self.Text_bankerName:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		self.Text_bankerCoin:setString(GameMsg.formatCoin(userInfo.i64Money));

		-- if self.tableLogic:getMySeatNo() == self.m_wBankerUser then
		-- 	self.Button_apply:setTouchEnabled(false);
		-- 	self.Button_apply:setBright(false);
		-- else
		-- 	self.Button_apply:setTouchEnabled(true);
		-- 	self.Button_apply:setBright(true);
		-- end
    end

    --申请上庄人数
    -- local count = table.nums(self.m_applyBankerList);
    -- self.Text_apply:setString(string.format("申请人数:%d",count));

    self:refreshApplyList();


    if self:isMeChair(self.m_wBankerUser) then
    	self:setJettonEnable(false);
    else
    	self:setJettonEnable(true);
    	self:updateJettonList();
    end


end


--开始下一局，清空上局数据
function TableLayer:resetGameData()
    self:addPlist();
    for i=1,5 do
        if self.m_cardArray[i] ~= nil then
            for k,v in pairs(self.m_cardArray[i]) do
                v:stopAllActions()
                v:setVisible(false)
                v:showCardBack();
            end
        end
        
    end
    self.m_lAllJettonScore = {0,0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0,0}
    self.m_lUserAllJetton = 0

    -- self:updateAreaScore(false)
    self:clearAreaScore();

    self.m_lBankerWinScore = 0;
    self.m_lSelfWinScore = 0;  

    self.m_bRunAction = false;

    self.m_bEnterGame = false;

    self.Image_clock:stopAllActions();
	self.timeTips = 0 ;


	self.Panel_jettons:stopAllActions();
	self.Panel_jettons:removeAllChildren();

	self.Panel_anims:stopAllActions();
	self.Panel_anims:removeAllChildren();

	for i,v in ipairs(self.m_resultTextTb) do
		v:stopAllActions();
		v:removeFromParent();
	end
	self.m_resultTextTb = {};

	self.Image_tip:setVisible(false);

	self.m_bShowWin = true;
	self.m_tDealTime = -1;

	self.m_gameMsgArray = {};
   
	self.m_bMaxJetton = false;
	self.m_nLastArea = -1;
	self:clearTimeId();


	self.m_jettonIconTb = {}

end



--更新游戏状态显示
function TableLayer:showGameStatus(second)
	-- self.m_tTimeBegin = os.time();

    if self.m_cbGameStatus == GameMsg.GAME_SCENE_END then --游戏开奖中
    	if isHaveBankLayer() then
    		createBank(function(data)
					self:resetSelfCoin(data)
				end);
			-- dispatchEvent("isCanSendGetScore",false)
			-- self:TipTextShow("游戏开奖中,请稍后进行取款操作.");
		end

    	
    	self.Image_status:loadTexture("brnn_kaijiangzhong.png",UI_TEX_TYPE_PLIST);
    	self:showTimeTips(self.m_cbGameStatus, second);
    	self:setBankBoxEnable(false);
    elseif self.m_cbGameStatus == GameMsg.GAME_SCENE_JETTON then
    	if isHaveBankLayer() then
			createBank(function(data)
					self:resetSelfCoin(data)
				end,true);
		end
    	
        self.Image_status:loadTexture("brnn_xiazhuzhong.png",UI_TEX_TYPE_PLIST);
    	self:showTimeTips(self.m_cbGameStatus, second);
    	self:setBankBoxEnable(true);
    else
        self:showTimeTips(1, second);
    end
end


--刷新庄家分数
function TableLayer:resetBankerScore()

    self.Text_bankerCoin:setString(GameMsg.formatCoin(self.m_lBankerScore));
    if self.m_wBankerUser == INVALID_DESKNO then
        if self.m_bEnableSysBanker == false then
            self.Text_bankerCoin:setString("0");
        end
    end
end

--是否自己位置
function TableLayer:isMeChair( wSeat )
	if wSeat == INVALID_DESKNO then
		return false;
	end

	if self.tableLogic:getMySeatNo() == wSeat then
		return true;
	end
	return false;    
end



--获取上庄条件
function TableLayer:getApplyCondition(  )
    return self.m_lApplyBankerCondition
end


--获取能否上庄
function TableLayer:getApplyable()
    local lScore = self:getSelfScore();

    local bBanker = true;
    if self.m_wBankerUser == self.tableLogic:getMySeatNo() or lScore < self.m_lApplyBankerCondition then
    	return false;
    end

    return true;
end


--获取能否取消上庄
function TableLayer:getCancelable()
    return self.m_cbGameStatus == GameMsg.GAME_SCENE_FREE
end


function TableLayer:addApplyUser( wApplyUser )
	local bExist = false;
	if wApplyUser ~= INVALID_DESKSTATION then
		for k,v in pairs(self.m_applyBankerList) do
			if v ==  wApplyUser then
				bExist = true;
				break;
			end
		end

		if not bExist then
			table.insert(self.m_applyBankerList,wApplyUser);
		end
	end
end

function TableLayer:exitClickCallback()
	if self:isMeChair(self.m_wBankerUser) == true then
    	self:TipTextShow("庄家不能离开房间") 
    else
		
		local func = function()
			self.tableLogic:sendUserUp();
			self.tableLogic:sendForceQuit();	
		end
		
		Hall:exitGame(false,func);
    end
	luaPrint("TableLayer:onClickExit玩家退出")
end


--按钮响应
function TableLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        --playsound
        if self.m_bEffectOn then
        	-- audio.playSound("bairenniuniu/sound/sound-button.mp3", false);
        end
        

        if "Image_jettonArea1" == btnName or "Image_jettonArea2" == btnName or "Image_jettonArea3" == btnName or "Image_jettonArea4" == btnName then 
        	local worldPos = sender:getTouchBeganPosition();
        	local pos2 = sender:convertToNodeSpace(worldPos);
        	-- luaDump(worldPos, "Image_jettonArea_POS---------------", 5);
        	-- luaDump(pos2, "Image_jettonArea_POS_LOCAL---------------", 5);

        	local flag = self:isValidJettonPos(sender, worldPos);
        	if flag then
        		audio.playSound(GAME_SOUND_BUTTON)	
        	end
        else
        	audio.playSound(GAME_SOUND_BUTTON)	
        end




    elseif event == ccui.TouchEventType.ended then
        luaPrint("onBtnClickEvent_ended----- Name:",btnName);
        
        if "Button_exit" == btnName then --返回
        	-- self:removeFromParent();

        	if self:isMeChair(self.m_wBankerUser) == true then
		    	self:TipTextShow("庄家不能离开房间") 
	    	elseif self.m_lUserAllJetton > 0 then
	    		self:TipTextShow("本局游戏您已参与，请等待开奖阶段结束。");
	    	-- elseif self.m_cbGameStatus == GameMsg.GAME_SCENE_END and self.m_lUserAllJetton > 0 then
	    	-- 	self:TipTextShow("本局游戏您已参与，正在开奖中，请等待开奖阶段结束。");
		    else
				self:exitClickCallback();
		    end
        	
    		

        elseif "Button_menuExpand" == btnName then --菜单按钮 展开
        	self:expandBoxList();
        elseif "Button_menuShrink" == btnName then --菜单按钮 展开
        	self:shrinkBoxList();

        elseif "Button_safeBox" == btnName then --菜单按钮 保险箱
   --      	local prompt = GamePromptLayer:create();
			-- prompt:showPrompt(GBKToUtf8("正在开发中ing"));
			if self.m_cbGameStatus == GameMsg.GAME_SCENE_END and not isHaveBankLayer() then--开奖状态不弹保险箱
				addScrollMessage("游戏开奖中，请稍后进行取款操作。");  --框架提示  没有句号
				return;
			end
			
			createBank(
				function(data)
					self:resetSelfCoin(data)
				end,true);
			-- dispatchEvent("isCanSendGetScore",true)--true 可以取钱，false不可以取钱 游戏中调

        elseif "Button_help" == btnName then --菜单按钮 规则
        	-- local layer = HelpLayer:create(self);
        	-- self:addChild(layer);
        	self:addChild(PopUpLayer:create());

        elseif "Button_effect" == btnName then --菜单按钮 音效
        	self.m_bEffectOn = getEffectIsPlay();

			luaPrint("音效",self.m_bEffectOn);
			if self.m_bEffectOn then--开着音效
				setEffectIsPlay(false);
				self.m_bEffectOn = false;
				self.Button_effect:loadTextures("brnn_menu_yinxiao-on.png","brnn_menu_yinxiao1.png", "", UI_TEX_TYPE_PLIST);
			else
				
				setEffectIsPlay(true);
				self.m_bEffectOn = true;
				self.Button_effect:loadTextures("brnn_menu_yinxiao-on1.png","brnn_menu_yinxiao-on2.png", "", UI_TEX_TYPE_PLIST);
			end

        elseif "Button_music" == btnName then --菜单按钮 音乐
        	self.m_bMusicOn = getMusicIsPlay();
			luaPrint("音乐",self.m_bMusicOn);
			if self.m_bMusicOn then--开着音效
				-- cc.UserDefault:getInstance():setBoolForKey("brnn_music",false);
				setMusicIsPlay(false);
				self.m_bMusicOn = false;
				

				self.Button_music:loadTextures( "brnn_menu_yinyue-off.png","brnn_menu_yinyue-off1.png","", UI_TEX_TYPE_PLIST);
			else
				
				setMusicIsPlay(true);
				self.m_bMusicOn = true;
				
				playMusic("bairenniuniu/sound/sound-bg.mp3", true);

				self.Button_music:loadTextures("brnn_menu_yinyue-on1.png","brnn_menu_yinyue-on2.png", "", UI_TEX_TYPE_PLIST);	
			end
			-- self:InitMusic();



        elseif "Button_charge" == btnName then --充值按钮
   --      	local prompt = GamePromptLayer:create();
			-- prompt:showPrompt(GBKToUtf8("正在开发中ing"));
			

            --下注按钮选择
        elseif "Button_jetton1" == btnName or "Button_jetton2" == btnName or "Button_jetton3" == btnName or "Button_jetton4" == btnName or "Button_jetton5" == btnName or "Button_jetton6" == btnName then --选择下注筹码按钮

        	self:onJettonButtonClicked(btnTag,sender);

        elseif "Button_apply" == btnName then --申请上庄


        	if self.m_lSelfScore < self.m_lApplyBankerCondition then
        		self:TipTextShow(string.format("您的筹码未满足上庄条件%d金币，不能申请上庄。", GameMsg.formatCoin(self.m_lApplyBankerCondition)));
        		showBuyTip();
        	else
        		GameMsg.delayBtnEnable(sender,0.5);
        		self.tableLogic:sendApplyBanker();
        	end

        	

        elseif "Button_quit" == btnName then --下庄
        	GameMsg.delayBtnEnable(sender,0.5);
        	self.tableLogic:sendCancelBanker();

        elseif "Button_apply_cancel" == btnName then --取消申请上庄
        	--上庄条件判断
        	-- if self.m_lSelfScore < self.m_lApplyBankerCondition then
        	-- 	self:TipTextShow(string.format("上庄金币必须大于%d", self.m_lApplyBankerCondition))
        	-- else
        	-- 	self.tableLogic:sendCancelBanker();
        	-- end
        	GameMsg.delayBtnEnable(sender,0.5);
        	self.tableLogic:sendCancelBanker();


        	

        elseif "Button_quit_cancel" == btnName then --取消申请下庄
        	GameMsg.delayBtnEnable(sender,0.5);
        	self.tableLogic:sendCancelQuitBanker();


        elseif "Button_others" == btnName then --其他玩家
        	
        	self:refreshPlayerList(true);
       
        	--点击下注区域下注筹码按钮 
       	elseif "Image_jettonArea1" == btnName or "Image_jettonArea2" == btnName or "Image_jettonArea3" == btnName or "Image_jettonArea4" == btnName then 
        	
        
        	local worldPos = sender:getTouchEndPosition();
        	local pos2 = sender:convertToNodeSpace(worldPos);
        	-- luaDump(worldPos, "Image_jettonArea_POS---------------", 5);
        	-- luaDump(pos2, "Image_jettonArea_POS_LOCAL---------------", 5);

        	local flag = self:isValidJettonPos(sender, worldPos);
        	if flag then
        		self:onJettonAreaClicked(btnTag,sender);	
        	end
        	
        elseif "Button_apply_list" == btnName then --申请上庄列表
        	luaPrint("self.Panel_bankerlist:isVisible()+++++++++++++++++:",self.Panel_bankerlist:isVisible())
        	self.Panel_bankerlist:setVisible(not self.Panel_bankerlist:isVisible())

        elseif "Image_cardShoe" == btnName then
        	
        	--续投
        elseif "Button_keep" == btnName then
        	-- self:onJettonAreaClicked(self.m_nJettonAreaSelect,sender);
        	self:continueJetton();

		elseif "Button_zhanji" == btnName then --战绩
        	if self.m_logBar then
				self.m_logBar:CreateLog();
			end
        end
        
    end

    

end

function TableLayer:isValidJettonPos(sender,worldPos)
	local localPos = sender:convertToNodeSpace(worldPos);
	local posAllTb = {}

	local posTb1 = {
		cc.p(10,10),	--左下
		cc.p(98,185),	--左上
		cc.p(277,185),	--右上
		cc.p(230,10),	--右下
	}

	
	local posTb2 = {
		cc.p(6,10),	--左下
		cc.p(50,185),	--左上
		cc.p(228,185),	--右上
		cc.p(230,10),	--右下
	}

	local posTb3 = {
		cc.p(15,10),	--左下
		cc.p(10,185),	--左上
		cc.p(190,185),	--右上
		cc.p(243,10),	--右下
	}

	local posTb4 = {
		cc.p(58,10),	--左下
		cc.p(5,185),	--左上
		cc.p(185,185),	--右上
		cc.p(285,10),	--右下
	}

	table.insert(posAllTb,posTb1)
	table.insert(posAllTb,posTb2)
	table.insert(posAllTb,posTb3)
	table.insert(posAllTb,posTb4)

	local index = 1;
	for i,v in ipairs(self.Image_jettonAreaTb) do
		if v:getTag() == sender:getTag() then
			index = i;
			break;
		end
	end

	local function isPointInPoly(p,poly)
		local A = poly[1];
		local B = poly[2];
		local C = poly[3];
		local D = poly[4];

		local a = (B.x - A.x)*(p.y - A.y) - (B.y - A.y)*(p.x - A.x);
		local b = (C.x - B.x)*(p.y - B.y) - (C.y - B.y)*(p.x - B.x);
		local c = (D.x - C.x)*(p.y - C.y) - (D.y - C.y)*(p.x - C.x);
		local d = (A.x - D.x)*(p.y - D.y) - (A.y - D.y)*(p.x - D.x);
        if (a > 0 and b > 0 and c > 0 and d > 0) or (a < 0 and b < 0 and c < 0 and d < 0) then
            return true;
        end

        return false;
	end

	local result = isPointInPoly(localPos,posAllTb[index]);
	luaPrint("isPointInPoly_result---------:",result);
	return result;
end



--下注响应
function TableLayer:onJettonButtonClicked(tag, sender)
    self.m_nJettonSelect = tag
    -- self.Image_jettonSelected:setPosition(sender:getPosition())
    -- self.Image_jettonSelected:setVisible(true);
    for i,v in ipairs(self.Button_jettonTb) do
    	if v:getTag() == sender:getTag() and v:isEnabled() then
    		v:setPositionY(self.chipPosY+10);
    		self:ShowChipAction(v,true);
    	else
    		v:setPositionY(self.chipPosY);
    		self:ShowChipAction(v,false);
    	end
    end
	-- sender:setScale(1.2);    
end


--下注区域响应
function TableLayer:onJettonAreaClicked(tag,sender)
	 --非下注状态
    if self.m_cbGameStatus ~= GameMsg.GAME_SCENE_JETTON then
    	-- self:TipTextShow("非下注状态")
    	luaPrint("非下注状态")
        return
    end

    if self.m_bMaxJetton then
    	luaPrint("下注已满~~~~~~~~~~~~~~~~~~~~~")
    	return;
    end

    self.m_nJettonAreaSelect = tag;
    local jettonScore_s = TableLayer.m_BTJettonScore[self.m_nJettonSelect];
    
    if self:checkJettonValid(jettonScore_s, self.m_nJettonAreaSelect) then
    	
    	self.tableLogic:sendPlaceJetton(jettonScore_s, tag);
    end

end

--续投
function TableLayer:continueJetton()
	self.m_bLastJettonDone = true;
	self:sendLastRecordJetton();
	
	-- if self:checkJettonValid(self.m_nLastJetton, self.m_nLastArea) then
	-- 	if self.m_nLastJetton > 0 then
	-- 		self.tableLogic:sendPlaceJetton(self.m_nLastJetton, self.m_nLastArea);
	-- 	else
			
	-- 	end
 --    end
end



--下注检测
function TableLayer:checkJettonValid(jettonScore_s,area_s)
	--非下注状态
    if self.m_cbGameStatus ~= GameMsg.GAME_SCENE_JETTON then
    	luaPrint("非下注状态----")
        return false;
    end


    if self.m_bMaxJetton then
    	luaPrint("下注已满~~~~~~~~~~~~~~~~~~~~~")
    	return false;
    end

    if self:isMeChair(self.m_wBankerUser) == true then
    	self:TipTextShow("庄家不能下注") 
        return false;
    end
    
    if self.m_wBankerUser == INVALID_DESKSTATION then
        self:TipTextShow("无人坐庄，不能下注") 
        return false;
    end

    if self.m_lUserMaxScore < SettlementInfo:getConfigInfoByID(46) then  --3000 -100
    	self:TipTextShow("下注失败，您必须有"..(SettlementInfo:getConfigInfoByID(46)/100).."金币才能下注"); --self:TipTextShow("下注失败，您必须有30金币才能下注");
    	showBuyTip();
    	return false;
    end
    
    if self.m_lSelfScore < jettonScore_s then
    	self:TipTextShow("玩家金额不足");
    	showBuyTip();
    	return false;
    end

    --
    local selfscore  = (jettonScore_s + self.m_lUserAllJetton)*self.m_lMultiple
   
    if selfscore > self.m_lUserMaxScore then
        self:TipTextShow("已超过个人最大下注值")
        return false;
    end

    local indexArea = self:getJettonArea(area_s);
    local areascore = self.m_lAllJettonScore[indexArea] + jettonScore_s
    if areascore > self.m_lAreaLimitScore then
        self:TipTextShow("已超过该区域最大下注值")
        return false;
    end

    if self.m_wBankerUser ~= INVALID_DESKSTATION then
        local allscore = 0 ;
        for k,v in pairs(self.m_lAllJettonScore) do
            allscore = allscore + v
        end

        allscore = allscore*self.m_lMultiple

        if allscore >= self.m_lBankerScore then
        	
            self:TipTextShow("总下注已超过庄家下注上限")
            
            return false;
        else
        	local dValue = math.floor((self.m_lBankerScore - allscore)/self.m_lMultiple);
        	
        	if jettonScore_s - dValue > 0  then

        		local ddValue = math.floor(dValue);
        		local jettonCountTb = {0,0,0,0,0,0}
        		--下注数值
				-- TableLayer.m_BTJettonScore = {1, 10, 50, 100, 500, 1000}
				for i=6,1,-1 do
					local score = TableLayer.m_BTJettonScore[i];
					local count = 0;
					if ddValue >= score then
	        			count = math.floor(ddValue/(score));
	        	
	        			ddValue = ddValue - score*count;
	        			jettonCountTb[i] = count;
	        			
	        		end
				end
				
				for i,v in ipairs(jettonCountTb) do
					if v > 0 then
						for ii=1,v do
							self.tableLogic:sendPlaceJetton(TableLayer.m_BTJettonScore[i], area_s);	
						end
					end
				end
				
				-- self.m_nJettonAreaSelect = tag;
				local allScored = allscore + jettonScore_s;
				if allScored >= self.m_lBankerScore then
					self:TipTextShow("总下注已超过庄家下注上限!")
					
				end
				
				return false;
			
        	end

        end

    end

    return true;
end


--获取玩家角色状态
function TableLayer:getApplyState()

end


--刷新玩家状态
function TableLayer:refreshApplyBtn()
	
	for k,v in pairs(self.Button_applyTb) do
		v:setVisible(k == self.m_enApplyState);
	end
end


--刷新玩家列表
function TableLayer:refreshPlayerList(isShow)

	-- local players = self.tableLogic._deskUserList._users;
	-- local playerCount = table.nums(players);
	-- self.Text_others:setString(tostring(playerCount - 1));

	-- -- luaDump(players, "refreshPlayerList", 7)
	-- if not self.m_playerListLayer then
	-- 	return;
	-- end


	-- self.m_playerListLayer:refreshList(players,isShow);
	local function onRefreshDone(sender,event)
    	local players = self.tableLogic._deskUserList._users;
		local playerCount = table.nums(players);
		self.Text_others:setString(tostring(playerCount - 1));

		-- luaDump(players, "refreshPlayerList", 7)
		if not self.m_playerListLayer then
			return;
		end

		
		self.m_playerListLayer:refreshList(players,isShow);
    end

    onRefreshDone();
    -- self.Panel_others:stopAllActions();
    -- self.Panel_others:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onRefreshDone)));
	
end


--刷新庄家玩家列表
function TableLayer:refreshBankerList(_bankerTb,count)
	luaDump(_bankerTb,"======refreshBankerList========",5)

	local bankerTb = {}
	for i=1,count do
		bankerTb[i] = _bankerTb[i];
	end

	self.m_want_bankerTb = bankerTb;

	self.ListView_bl:removeAllChildren();
	for i,v in ipairs(bankerTb) do
		local lSeat = v;
		local item = self.Panel_bankerlist_cell:clone();
		text_name = item:getChildByName("Text_bl_name");
		text_coin = item:getChildByName("Text_bl_coin");
		
		local userInfo = self.tableLogic:getUserBySeatNo(lSeat);
		if userInfo then
			text_name:setString(i.."."..FormotGameNickName(userInfo.nickName,6))
			text_coin:setString(GameMsg.formatCoin(userInfo.i64Money))
			item:setVisible(true);
			self.ListView_bl:pushBackCustomItem(item);
		else
			luaPrint("userinfo ",lSeat," is null!")
		end	
		
	end

end


--刷新玩家数量
function TableLayer:refreshPlayerCount()
	local players = self.tableLogic._deskUserList._users;
	local playerCount = table.nums(players);
	self.Text_others:setString(tostring(playerCount-1));
end


--删除申请上庄列表玩家
function TableLayer:removeApplyUser(wBankerUser)
	local removeIdx = nil
    for k,v in pairs(self.m_applyBankerList) do
        if v == wBankerUser then
            removeIdx = k
            break
        end
    end

    if nil ~= removeIdx then
        table.remove(self.m_applyBankerList,removeIdx)
    end
end


--刷新申请玩家列表
function TableLayer:refreshApplyList()
	-- local num = table.nums(self.m_applyBankerList);
	self.Text_apply:setString(string.format("申请人数:%d",self.m_nApplyCount));
end


--获取新的手牌列表 庄家牌从1位置 调整到 5位置
function TableLayer:getSwapTableCards( cbTableCardArray )
	local cardArray = clone(cbTableCardArray);
   
    local bankerCards = clone(cardArray[1]);
   
    table.remove(cardArray,1);
   
	table.insert(cardArray,5,bankerCards);     


	return cardArray;
end


--等待下局开始提示
function TableLayer:showWaitNextTip()
	--new
	self.Panel_dialog:removeChildByName(TipAnimName.WAIT_NEXT);
	-- local pos = cc.p(display.width*0.5,display.height*0.5);
	local pos = cc.p(self.Panel_statusTip:getPosition());
	local skeleton_animation = createSkeletonAnimation(WaitAnim.name,WaitAnim.json,WaitAnim.atlas);
	if skeleton_animation then
		self.Panel_dialog:addChild(skeleton_animation);
		skeleton_animation:setAnimation(0,WaitNextAnimName, true);
		skeleton_animation:setPosition(pos);
		skeleton_animation:setName(TipAnimName.WAIT_NEXT);
	end
	
end

--隐藏下局开始提示
function TableLayer:hideWaitNextTip()
	self.Image_tip:setVisible(false);

	self.Panel_dialog:removeChildByName(TipAnimName.WAIT_NEXT);
end

    --提示小字符
function TableLayer:TipTextShow(tipText)
	luaPrint("TipTextShow:",tipText);
	addScrollMessage(tipText);
end



--显示连庄提示
function TableLayer:showRemainBankerTip(round)
	if not round or round <= 1 then
		return 
	end

	if self.m_wBankerUser == INVALID_DESKSTATION then
		return;
	end

	self.Image_remainBanker:setVisible(true);
	self.Text_remainBanker:setString(tostring(round));

	local scaleIt1 = cc.ScaleTo:create(0.15,1.3);
	local scaleIt2 = cc.ScaleTo:create(0.1,0.9);
	local scaleIt3 = cc.ScaleTo:create(0.1,1.1);
	local scaleIt4 = cc.ScaleTo:create(0.1,1.0);
	local delayIt = cc.DelayTime:create(1.0);
	local hideIt = cc.Hide:create();
	self.Image_remainBanker:stopAllActions();
	self.Image_remainBanker:runAction(cc.Sequence:create(scaleIt1,scaleIt2,scaleIt3,scaleIt4,delayIt,hideIt))
end


--显示庄家切换提示
function TableLayer:showChangeBankerTip()
	if self.m_bEffectOn then
        audio.playSound("bairenniuniu/sound/zhuang-2.mp3", false);
    end

	self.Image_changeBankerTip:stopAllActions();

	self.Image_changeBankerTip:setVisible(false);
	self.Image_changeBankerTip:setOpacity(255);
	local fadeOut = cc.FadeOut:create(0.5);
	local seq = cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(1.0),fadeOut,cc.Hide:create());
	self.Image_changeBankerTip:runAction(seq);

end




--显示时间提示
function TableLayer:showTimeTips(tipType,second)--时钟提示显示
	
	if tipType == GameMsg.GAME_SCENE_FREE then 	--空闲状态
	
	elseif tipType == GameMsg.GAME_SCENE_JETTON then  --下注状态

	elseif tipType == GameMsg.GAME_SCENE_END then 		--游戏结束

	elseif tipType == GameMsg.GAME_SEND_CARD then 		--发牌状态

	elseif tipType == GameMsg.GAME_SHOW_POINT then 	--显示牌点

	end

    self.timeTips = second;
    self.Text_clock:setString(string.format("%d",second));
   
    local function onEventCountdown(sender,event)
    	if self.timeTips >= 0 then
    		self:showTimeTipsOver()
    		self.timeTips = self.timeTips - 1;
    		self.Image_clock:stopAllActions()
    		self.Image_clock:runAction(cc.Sequence:create(cc.DelayTime:create(0.9),cc.CallFunc:create(onEventCountdown)));

    	else
    		self.Image_clock:stopAllActions()
    	end
    end

    onEventCountdown();
end

--结束时间
function TableLayer:showTimeTipsOver(ft)--时钟提示显示完成
	
	local time = self.timeTips;
    
    -- local sec = math.floor(self.timeTips/10);
    -- self.timeTips = self.timeTips - 1;
    self.Text_clock:setString(string.format("%d",self.timeTips))
    
    --游戏动画状态
    if self.m_cbGameStatus == GameMsg.GAME_SCENE_END then
        if time == self.m_cbTimeLeave - 1 then    --  -1
	        --发牌处理
	        -- self:sendCard(true);

	    elseif time == self.m_cbTimeLeave - 2  then  --  -2
	        --显示点数
	        self:showCard2(true);

	    elseif time == self.m_cbTimeLeave - 9 then   -- 9
	        --金币处理
	  		luaPrint("show jetton fly");
	  		self:dealCheckRoundOut();
	    end
    elseif self.m_cbGameStatus == GameMsg.GAME_SCENE_JETTON then
    	if self.timeTips == 3 then --三秒倒计时
    		if self.m_bEffectOn then
        		audio.playSound("bairenniuniu/sound/sound-countdown.mp3", false);
        	end
    		
    		local pos = cc.p(self.Image_tip:getPosition());
    		local skeleton_animation = createSkeletonAnimation("brnn_"..WarnAnim.name,WarnAnim.json,WarnAnim.atlas);
    		if skeleton_animation then
    			self.Panel_anims:addChild(skeleton_animation);
	        	skeleton_animation:setAnimation(0,WarnAnimName, false);        	
	        	skeleton_animation:setPosition(cc.p(pos.x - 5,pos.y - 150));
	        	skeleton_animation:setName(WarnAnimName);
    		end

        	local function actionEnd()
    			self:showStopJettonTip();
				self.Panel_anims:removeChildByName(WarnAnimName);
        	end

        	self.Panel_anims:stopAllActions();
        	self.Panel_anims:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(actionEnd)))
        elseif self.timeTips == 2 then
        	if self.m_bEffectOn then
        		audio.playSound("bairenniuniu/sound/sound-countdown.mp3", false);

       	 	end
        elseif self.timeTips == 1 then
        	if self.m_bEffectOn then
        		audio.playSound("bairenniuniu/sound/sound-countdown.mp3", false);
        	end
        elseif self.timeTips == 0 then
        	self:showStopJettonTip();
        	self.Panel_anims:stopAllActions();
			self.Panel_anims:removeChildByName(WarnAnimName);
    	end
    end

end


function TableLayer:getIconByJetton(count)
	count = tonumber(count);
     local index = 0;
     for k,v in pairs(TableLayer.m_BTJettonScore) do
     	if v == count then
     		index = k;
     		break;
     	end
     end

     if index ~= 0 then
     	return TableLayer.m_BTJettonScoreStr[index];
     end

     return nil;
end


--获取剩余可下注的筹码
function TableLayer:getleftJettonCount()
	local totalJettonedScore = 0;
    for i,v in ipairs(self.m_lAllJettonScore) do
    	totalJettonedScore = totalJettonedScore + v;
    end

    local remainCount = self.m_lBankerScore - totalJettonedScore*self.m_lMultiple;
    return remainCount;
end

function TableLayer:clearAreaScore()
	for k,v in pairs(self.Text_jettonAreaSelfTb) do
            v:setString("0");
    end
    for k,v in pairs(self.Text_jettonAreaAllTb) do
        v:setString("0");
    end

    self.Text_totalJetton:setString(tostring(0));

    -- local allScore = GameMsg.formatCoin(totalJettonedScore);
	

    self.Text_leftJetton:setString(tostring(0));
end

--更新下注分数显示
function TableLayer:updateAreaScore(bShow)
    if bShow == false then
        for k,v in pairs(self.Text_jettonAreaSelfTb) do
            v:setString("0");
        end
        for k,v in pairs(self.Text_jettonAreaAllTb) do
            v:setString("0");
        end

        self.Text_totalJetton:setString(tostring(0));

        -- local allScore = GameMsg.formatCoin(totalJettonedScore);
    	local leftScore = self:getleftJettonCount();

        self.Text_leftJetton:setString(GameMsg.formatCoin(math.floor(leftScore/self.m_lMultiple)));

        return;
    end


    for i=1,4 do
    	self.Text_jettonAreaSelfTb[i]:setVisible(true);
        if self.m_lUserJettonScore[i] > 0 then
            self.Text_jettonAreaSelfTb[i]:setString(GameMsg.formatCoin(self.m_lUserJettonScore[i]))
        end
        self.Text_jettonAreaAllTb[i]:setVisible(true);
        if self.m_lAllJettonScore[i] > 0 then
        	self.Text_jettonAreaAllTb[i]:setString(GameMsg.formatCoin(self.m_lAllJettonScore[i]))
        	
        end
    end

    local totalJettonedScore = 0;
    for i,v in ipairs(self.m_lAllJettonScore) do
    	totalJettonedScore = totalJettonedScore + v;
    end

    -- luaDump(self.m_lAllJettonScore, "totalJettonedScore-----------1", 6)
    local allScore = GameMsg.formatCoin(totalJettonedScore);
    self.Text_totalJetton:setString(allScore);

    local leftScore = self:getleftJettonCount();
    if leftScore < 0 then
    	leftScore = 0;
    end

    local reScore = leftScore/self.m_lMultiple
    -- luaPrint("reScore----------",reScore);
    self.Text_leftJetton:setString(GameMsg.formatCoin(math.floor(leftScore/self.m_lMultiple)))

end


--增加下注下标

function TableLayer:addJettonIndex(jetton)
	local str = string.format("index%d",jetton);
	if self.countIndexTb[str] ~= nil then
		self.countIndexTb[str] = self.countIndexTb[str] + 1;
	else
		
	end
end

function TableLayer:getJettonIndex(jetton)
	local str = string.format("index%d",jetton);
	if self.countIndexTb[str] ~= nil then
		return self.countIndexTb[str]
	else
		
		return 0;
	end
end

function TableLayer:resetJettonIndex()
	for k,v in pairs(self.countIndexTb) do
		self.countIndexTb[k] = 0;
	end
end


--恢复桌面的筹码
function TableLayer:replaceTableJetton()



	local otherJettonScore = {};
	for i=1,4 do
		local otherScore = self.m_lAllJettonScore[i] - self.m_lUserJettonScore[i];
		otherJettonScore[i] = otherScore;
	end

	local otherJettonTb = {};
	local selfJettonTb = {};

	for i=1,4 do
		local jettonOtherCountTb = {0,0,0,0,0,0};
		local jettonSelfCountTb = {0,0,0,0,0,0};
		local dValue = self.m_lUserJettonScore[i];
		local oVaule = otherJettonScore[i];
		for ii=6,1,-1 do
            local score = TableLayer.m_BTJettonScore[ii];
            local count = 0;
            if dValue >= score then
                count = math.floor(dValue/(score));
                dValue = dValue - score*count;
                jettonSelfCountTb[ii] = count;
            end

            count = 0;

            if oVaule >= score then
                count = math.floor(oVaule/(score));
                oVaule = oVaule - score*count;
                jettonOtherCountTb[ii] = count;
            end
        end

        table.insert(selfJettonTb,jettonSelfCountTb);
        table.insert(otherJettonTb,jettonOtherCountTb);
	end

	for i,v in ipairs(selfJettonTb) do
		local area = i;

		for ii,vv in ipairs(v) do
			for iii=1,vv do   --count
				local msg = {};
				msg.lJettonScore = TableLayer.m_BTJettonScore[ii];
				msg.wChairID = self.tableLogic:getMySeatNo();
                msg.cbJettonArea = area;
                self:showUserJetton(msg,false);
			end
		end
	end


	for i,v in ipairs(otherJettonTb) do
		local area = i;
		for ii,vv in ipairs(v) do
			for iii=1,vv do   --count
				local msg = {};
				msg.lJettonScore = TableLayer.m_BTJettonScore[ii];
				msg.wChairID = self.tableLogic:getMySeatNo()+1;
                msg.cbJettonArea = area;
                self:showUserJetton(msg,false);
			end
		end
	end





end


--显示用户下注
function TableLayer:showUserJetton(msg,bAnim)
	--如果是自己，金币从自己出飞出
    -- if self.m_cbGameStatus ~= GameMsg.GAME_SCENE_JETTON then
    -- 	luaPrint("showUserJetton self.m_cbGameStatus is:",self.m_cbGameStatus)
    --     return
    -- end

    -- if not bAnim then
    -- 	luaPrint("showUserJetton is area money----------= ",msg.cbJettonArea,msg.lJettonScore)	
    -- end
    self:addPlist();
    
    local beginPos = cc.p(self.Button_others:getPosition());
    
    -- beginPos = self.Panel_jettons:convertToNodeSpace(beginPos);
    

    


    local endPos = self:getRandPos(self.Image_jettonAreaTb[msg.cbJettonArea]);
    local offsettime = math.min(self.m_fJettonTime, 1)
    local coin = msg.lJettonScore;

    if self:isMeChair(msg.wChairID) == true then
    	local pos = self.m_selfPos;
    	-- local pos = self.Text_selfCoin:getParent():convertToWorldSpace(cc.p(self.Text_selfCoin:getPosition()));
        beginPos = pos;




    else
    	
    	if self:isVipSeat(msg.wChairID) then
    		beginPos = self:getOtherJettonPos(msg.wChairID);	
    	else
    		beginPos = self.Panel_jettons:getParent():convertToNodeSpace(cc.p(self.Button_others:getPosition()));
    	end

    	self:runJettonHeadAnim(msg.wChairID,coin)

    	offsettime = math.min(self.m_fJettonTime, 2)
    end
    

    local jettonStr = self:getIconByJetton(coin);
    -- luaPrint("jettonStr--------coin,:",jettonStr,coin);
    -- local jettonIcon = cc.Sprite:createWithSpriteFrameName(jettonStr);
    local jettonIcon = ccui.ImageView:create(jettonStr,UI_TEX_TYPE_PLIST);

    self.Panel_jettons:addChild(jettonIcon);
    jettonIcon:setScale(0.35);

    local jettonIndex = self:getJettonIndex(coin);
    -- luaPrint("msg.cbJettonArea,jettonIndex:",msg.cbJettonArea,jettonIndex)
    jettonIcon:setName(string.format("%d_%d_%d",msg.cbJettonArea,coin,jettonIndex));
    jettonIcon.bDeskStation = msg.wChairID;
    jettonIcon.lJettonScore = msg.lJettonScore;
    jettonIcon.cbJettonArea = msg.cbJettonArea;
    jettonIcon.wChairID = msg.wChairID;



    if bAnim then

    	if self:isMeChair(msg.wChairID) then
	    	self.m_nLastJetton = msg.lJettonScore;
	    	self.m_nLastArea = msg.cbJettonServerArea;
	    	-- self:setKeepEnable2(true);
	    end


    	local moveaction = self:getMoveAction(beginPos, endPos, 1,0)

  --   	local actionCallback = cc.CallFunc:create(function (sender)
		-- 		self:packedJettonIcon(sender)
		-- end)
		-- local action = cc.Sequence:create(moveaction,actionCallback)

	    jettonIcon:setPosition(beginPos);
    	jettonIcon:runAction(moveaction);

    	if self.m_bEffectOn then
	        audio.playSound("bairenniuniu/sound/sound-betlow.mp3", false);
	    end
	else
		jettonIcon:setPosition(endPos);
    end
    

    if self:isMeChair(msg.wChairID) then
    	jettonIcon.bMe = true;
    else
    	jettonIcon.bMe = false;
    end
    
end


--收纳下注筹码
function TableLayer:packedJettonIcon(jettonIcon)
	-- self.m_jettonIconTb = {}
	if self.m_jettonIconTb[jettonIcon.wChairID] == nil then
		self.m_jettonIconTb[jettonIcon.wChairID] = {}
		
	end

	if self.m_jettonIconTb[jettonIcon.wChairID][jettonIcon.cbJettonArea] == nil then
		self.m_jettonIconTb[jettonIcon.wChairID][jettonIcon.cbJettonArea] = {}
	end

	if self.m_jettonIconTb[jettonIcon.wChairID][jettonIcon.cbJettonArea][jettonIcon.lJettonScore] == nil then
		self.m_jettonIconTb[jettonIcon.wChairID][jettonIcon.cbJettonArea][jettonIcon.lJettonScore] = {}
	end

	table.insert(self.m_jettonIconTb[jettonIcon.wChairID][jettonIcon.cbJettonArea][jettonIcon.lJettonScore],jettonIcon);
	-- luaDump(self.m_jettonIconTb, "self.m_jettonIconTb-------------acb", 6)
	--TableLayer.m_BTJettonScore = {100, 1000, 5000, 10000, 50000,100000}
	local function getParentScoreIndex(jettonScore)
		for i,v in ipairs(TableLayer.m_BTJettonScore) do
			if v == jettonScore then
				index = i + 1;
				if index <= table.nums(TableLayer.m_BTJettonScore) then
					return  index;
				end
			end
		end

		return 0;
	end


	local function packedIndexJetton(jettonIcon)
		
		local _wChairID = jettonIcon.wChairID
		local _cbJettonArea = jettonIcon.cbJettonArea
		local _lJettonScore = jettonIcon.lJettonScore;
		

		 if self.m_jettonIconTb[_wChairID] == nil then
			self.m_jettonIconTb[_wChairID] = {}
			
		end

		if self.m_jettonIconTb[_wChairID][_cbJettonArea] == nil then
			self.m_jettonIconTb[_wChairID][_cbJettonArea] = {}
		end

		if self.m_jettonIconTb[_wChairID][_cbJettonArea][_lJettonScore] == nil then
			self.m_jettonIconTb[_wChairID][_cbJettonArea][_lJettonScore] = {}
		end


		local jettonScore = jettonIcon.lJettonScore;
		local parentIndex = getParentScoreIndex(jettonScore)
		local parentScore = 0;
		if parentIndex <= 0 then
			return;
		end

		-- luaDump(self.m_jettonIconTb, "--------self.m_jettonIconTb-abc", 7)

		parentScore = TableLayer.m_BTJettonScore[parentIndex];
		local allScore = 0;
		for i,v in ipairs(self.m_jettonIconTb[_wChairID][_cbJettonArea][_lJettonScore]) do
			if v then 
				allScore = allScore + v.lJettonScore;
			end
			
		end

		local perCount = math.floor(parentScore/jettonScore)
		local countParent = math.floor(allScore/parentScore)
		local allCount = countParent*perCount;

		local randomPosTb = {}
		for i=1,countParent do
			local endPos = self:getRandPos(self.Image_jettonAreaTb[jettonIcon.cbJettonArea]);
			table.insert(randomPosTb,endPos);
		end


		for i=allCount,1 ,-1 do
			if self.m_jettonIconTb[_wChairID][_cbJettonArea][_lJettonScore][i] ~= nil then
				local jettonIcon2 = self.m_jettonIconTb[_wChairID][_cbJettonArea][_lJettonScore][i]
				self.m_jettonIconTb[_wChairID][_cbJettonArea][_lJettonScore][i] = nil;
				local indexPos = math.ceil(allCount/perCount);
				if randomPosTb[indexPos] ~= nil then
					-- jettonIcon2:removeFromParent();

					local moveaction = cc.MoveTo:create(0.25,randomPosTb[indexPos])
					local action = cc.Sequence:create(moveaction,cc.DelayTime:create(0.05),cc.RemoveSelf:create())
			    	jettonIcon2:runAction(action)
				else
					jettonIcon2:removeFromParent();
				end
				
			end	
		end
		
		for i=1,countParent do
			-- local endPos = self:getRandPos(self.Image_jettonAreaTb[jettonIcon.cbJettonArea]);
			local endPos = randomPosTb[i];
		    local offsettime = math.min(self.m_fJettonTime, 1)
		    local coin = parentScore
			 local jettonStr = self:getIconByJetton(coin);
   
		    local jettonIconP = ccui.ImageView:create(jettonStr,UI_TEX_TYPE_PLIST);

		    self.Panel_jettons:addChild(jettonIconP);
		    jettonIconP:setPosition(endPos);
		    local jettonIndex = self:getJettonIndex(coin);
		    
		    jettonIconP:setName(string.format("%d_%d_%d",_cbJettonArea,coin,jettonIndex));
		    jettonIconP.bDeskStation = _wChairID;
		    jettonIconP.lJettonScore = parentScore;
		    jettonIconP.cbJettonArea = _cbJettonArea;
		    jettonIconP.wChairID = _wChairID;
		    jettonIconP:setScale(0.05);

		    local moveaction = cc.ScaleTo:create(0.15,0.35)
			local action = cc.Sequence:create(cc.DelayTime:create(0.1),moveaction)
	    	jettonIconP:runAction(action)

		    if self:isMeChair(_wChairID) then
		    	jettonIconP.bMe = true;
		    else
		    	jettonIconP.bMe = false;
		    end


		    if self.m_jettonIconTb[jettonIconP.wChairID] == nil then
				self.m_jettonIconTb[jettonIconP.wChairID] = {}
				
			end

			if self.m_jettonIconTb[jettonIconP.wChairID][jettonIconP.cbJettonArea] == nil then
				self.m_jettonIconTb[jettonIconP.wChairID][jettonIconP.cbJettonArea] = {}
			end

			if self.m_jettonIconTb[jettonIconP.wChairID][jettonIconP.cbJettonArea][jettonIconP.lJettonScore] == nil then
				self.m_jettonIconTb[jettonIconP.wChairID][jettonIconP.cbJettonArea][jettonIconP.lJettonScore] = {}
			end


		    table.insert(self.m_jettonIconTb[jettonIconP.wChairID][jettonIconP.cbJettonArea][jettonIconP.lJettonScore],jettonIconP);

		end





	end


	packedIndexJetton(jettonIcon)

end


--获取随机显示位置
function TableLayer:getRandPos(nodeArea)
    local beginpos = cc.p(nodeArea:getPositionX()-68, nodeArea:getPositionY()-40)

    local offsetx = math.random()
    local offsety = math.random()

    return cc.p(beginpos.x + offsetx*136, beginpos.y + offsety*80)
end

--获取移动动画
--inorout,0表示加速飞出,1表示加速飞入
--isreverse,0表示不反转,1表示反转
function TableLayer:getMoveAction(beginpos, endpos, inorout, isreverse)
    local offsety = (endpos.y - beginpos.y)*0.5
    local controlpos = cc.p(beginpos.x, beginpos.y+offsety)
    if isreverse == 1 then
        offsety = (beginpos.y - endpos.y)*0.7
        controlpos = cc.p(endpos.x, endpos.y+offsety)
    end
    local bezier = {
        controlpos,
        endpos,
        endpos
    }
    local beaction = cc.BezierTo:create(0.6, bezier)
    if inorout == 0 then
        return cc.EaseOut:create(beaction, 1)
    else
        return cc.EaseIn:create(beaction, 1)
    end
end


--发牌消息
function TableLayer:sendCard(bAnim)

	if not self.m_bEnterGame then
		
		return;
	end
	self:addPlist();

	local cardPos = self.m_cardPosTb;
	local beginPos = cc.p(self.Sprite_cardBack:getPosition());
	local beginScale = self.Sprite_cardBack:getScale();
	
	-- local beginRotation = self.Sprite_cardBack:getRotation();
	local beginRotation = 31;
	
	local gap = 32; --间距
	local animTime = 0.35;

	function getSendMoveAction(beginpos, endpos, inorout, isreverse)
	    local offsety = (beginpos.y - endpos.y)*0.8
	    local offsetx= (beginpos.x - endpos.x)*0.15
	    local controlpos = cc.p(endpos.x + offsetx, endpos.y+offsety)

	    if isreverse == 1 then
	        offsety = (beginpos.y - endpos.y)*0.7
	        controlpos = cc.p(endpos.x, endpos.y+offsety)
	    end

	    local bezier = {
	    	controlpos,
	        controlpos,
	        endpos
	    }
	    local beaction = cc.BezierTo:create(animTime, bezier)

	    if inorout == 0 then
	        return cc.EaseOut:create(beaction, 1)
	    else
	        return cc.EaseIn:create(beaction, 1)
	    end
	end


	if bAnim then
        
		if self.m_bEffectOn then
        	audio.playSound("bairenniuniu/sound/sound-sendcard.mp3", false);
        end
        
        for i=1,5 do
            for j=1,5 do
                local card = self.m_cardArray[i][j];
                local index = (i-1)*5 + j - 1
                card:setPosition(beginPos)
                card:setScale(beginScale);
                card:setRotation(beginRotation);
                card:setVisible(false);

                local moveTo = getSendMoveAction(beginPos,cardPos[i],0,0);
                local spawn = cc.Spawn:create(
                				cc.RotateTo:create(animTime, 0),
                				-- cc.RotateBy:create(0.2,0),
                        		cc.ScaleTo:create(animTime,CARD_SCALE),
                        		moveTo
                        		-- cc.MoveTo:create(animTime, cc.p(cardPos[i].x, cardPos[i].y))	
                        	);

                local moveTo2 = cc.MoveTo:create(0.03*j, cc.p(cardPos[i].x + (j-1)*gap, cardPos[i].y));
               	local seq = cc.Sequence:create(cc.DelayTime:create(j*0.02),cc.Show:create(),spawn,cc.DelayTime:create(j*0.02),moveTo2);
               	card:runAction(seq);
            end
        end



    else
        for i=1,5 do
            for j=1,5 do
                local card = self.m_cardArray[i][j];
                card:stopAllActions();
                card:setScale(CARD_SCALE);
                card:setRotation(0);
                card:setVisible(true);
                card:setPosition(cardPos[i].x + (j-1)*gap, cardPos[i].y)
            end
        end
    end

end


--显示扑克 显示牌跟牌值
function TableLayer:showCard(bAnim)
	if not self.m_bEnterGame then
		
		return;
	end

	self:addPlist();

	self.m_bShowWin = false;
	local progressDt = 10000;
	local cardIndex = 0;
	local niuScoreTb = {}
	local niuShowTb = {false,false,false,false,false}
	
	for i=1,5 do
		local idx = i;
		local tb = clone(self.m_cbTableCardArray[idx]);
		
   		local niuScore = GameLogic:GetCardType(self.m_cbTableCardArray[idx], 5);
   		table.insert(niuScoreTb,niuScore)
   	end



   	local function turnCardBegin(card)   --耗时 0.4
   		local function turnFrontCard(card)
			card:setCardValue(card.cardData);
			local big = cc.ScaleTo:create(0.15, CARD_SCALE * 1.2, CARD_SCALE);
			local normal = cc.ScaleTo:create(0.05, CARD_SCALE, CARD_SCALE);
		
			local seq = cc.Sequence:create(big,normal);
			card:runAction(seq);
		end

		local actionCallback = cc.CallFunc:create(function (sender)
				turnFrontCard(sender);
		end)

		local disappear = cc.ScaleTo:create(0.15, 0.01, CARD_SCALE);
		local action = cc.Sequence:create(disappear,actionCallback)
		card:runAction(action);
		-- if self.m_bEffectOn then
  --       	audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
  --       end
		
   	end

   	local function showCardOpen(areaIndex)
   		local cardTb = clone(self.m_cbTableCardArray[areaIndex]);
		for i=1,5 do
			local cardData = cardTb[i];
			local card = self.m_cardArray[areaIndex][i];
			card.cardData = cardData;
			turnCardBegin(card);
		end

		if self.m_bEffectOn then
        	audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
        end
   	end

   	local function showNiuResult(areaIndex)
   		local score = niuScoreTb[areaIndex];


		
		local pos = self.m_niuPosTb[areaIndex];
		local skeleton_animation = createSkeletonAnimation("brnn_"..NiuniuAnim.name,NiuniuAnim.json,NiuniuAnim.atlas);
		if skeleton_animation then
			self.Panel_anims:addChild(skeleton_animation);
    		skeleton_animation:setPosition(pos);
    		local niuName = NiuAnimName[score];
    		skeleton_animation:setAnimation(0,niuName, false);
		end
    	
    	
    	
    	
    	

    	local cards = self.m_cardArray[areaIndex];

    	--有牛 右边两个扑克右移
    	if score > GameLogic.BRNN_CT_POINT then  --有牛
    		for i=4,5 do
    			cards[i]:runAction(cc.MoveBy:create(0.1,cc.p(6,0)));
    		end

    		local index = score;
    		if score <= GameLogic.BRNN_CT_SPECIAL_NIUNIU then
    			index = index - 1;
    		elseif score ==  GameLogic.BRNN_CT_SPECIAL_4HUANIU then --四花牛哞哞叫
    			index = 11;
    		elseif score == GameLogic.BRNN_CT_SPECIAL_5HUANIU then
    			index = 12;
    		elseif score == GameLogic.BRNN_CT_SPECIAL_BOMEBOME then
    			index = 13;	
    		elseif score == GameLogic.BRNN_CT_SPECIAL_5XIAONIU then
    			index = 14;	

    		end

    		local path = string.format("bairenniuniu/sound/NiuSpeak_W/cow_%d.mp3", index);
    		
    		if self.m_bEffectOn then
        		audio.playSound(path, false);
        	end
    		
    	else
    		local path = string.format("bairenniuniu/sound/NiuSpeak_W/cow_0.mp3", index);
    		
    		if self.m_bEffectOn then
        		audio.playSound(path, false);
        	
        	end
    		
    	end
    
   	end

   	local function showWinResult()
    	
    	self.m_bShowWin = true;
    	for i=1,5 do
    		if i < 5 then
    			local result,mult = GameLogic:CompareCard(self.m_cbTableCardArray[5], niuScoreTb[5], self.m_cbTableCardArray[i], niuScoreTb[i])
    			
    			if result == 0 then
    				
    			end

    			if result == 1 then  --win
    				local skeleton_animation = createSkeletonAnimation("brnn_"..WinAnim.name,WinAnim.json,WinAnim.atlas);
    				if skeleton_animation then
    					self.Panel_anims:addChild(skeleton_animation);
			        	skeleton_animation:setAnimation(0,WinAnimName, false);
			        	local pos = self.m_winPosTb[i];

			        	skeleton_animation:setPosition(pos);
    				end
		        	
    			end
    		end
    	end
    end


   	local times = 0;
   	local showAreaIndex = 1;
   	local niuAreaIndex = 1;
   	local function doPercent()
   			
   			if times == 10*(showAreaIndex-1) and showAreaIndex <= 5 and showAreaIndex == niuAreaIndex  then  --亮第一手牌  60
   				if showAreaIndex <= 5 then
   					showCardOpen(showAreaIndex);
   					showAreaIndex = showAreaIndex + 1;
   				end
   			elseif times == 10*(niuAreaIndex-1) + 5  and showAreaIndex ~= niuAreaIndex and niuAreaIndex <= 5 then --亮第一个牛 100
 				if niuAreaIndex <= 5 then
 					showNiuResult(niuAreaIndex);
 					niuAreaIndex = niuAreaIndex + 1;
 				end
   			elseif times == 54 then --显示胜利 失败
   				showWinResult();
   			end
   			times = times + 1;
   	end



   	--停止消息监听
	function stopProgressTime()
	    if self.m_finishTimeId ~= nil and self.m_finishTimeId ~= -1 then
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_finishTimeId);
	        self.m_finishTimeId = -1;
	    end
	end

   	local function runProgressTime( delta )
   		if not self.m_bShowWin then
   			doPercent();
   		else
   			stopProgressTime();
   		end
   	end

   

   	local function startProgressTime()   		
   		if self.m_finishTimeId == -1 then
	     	self.m_finishTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) runProgressTime(delta) end, 0.1 ,false);
	     end
   	end

   	stopProgressTime();
   	startProgressTime();

   -- 	local function runProgressTime()
   -- 		if not self.m_bShowWin then
   -- 			doPercent();
			-- self.Panel_anims:stopAllActions();
			-- self.Panel_anims:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(runProgressTime)))
   -- 		else
   -- 			self.Panel_anims:stopAllActions();
   -- 		end
   		
   -- 	end

   -- 	runProgressTime();
end

--显示扑克 显示牌跟牌值
function TableLayer:showCard2(bAnim)
	if not self.m_bEnterGame then
		return;
	end

	self:addPlist();

	self.m_bShowWin = false;
	local progressDt = 10000;
	local cardIndex = 0;
	local niuScoreTb = {}
	local niuShowTb = {false,false,false,false,false}
	
	for i=1,5 do
		local idx = i;
		local tb = clone(self.m_cbTableCardArray[idx]);
   		local niuScore = GameLogic:GetCardType(self.m_cbTableCardArray[idx], 5);
   		table.insert(niuScoreTb,niuScore)
   	end


   	local function showCardOpen(areaIndex)
   		local cardTb = clone(self.m_cbTableCardArray[areaIndex]);
		for i=1,5 do
			local cardData = cardTb[i];
			local card = self.m_cardArray[areaIndex][i];
			card.cardData = cardData;
			turnCardBegin(card);
		end

		if self.m_bEffectOn then
        	audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
        end
   	end

   	local cardPosTb = {}
   	for areaIndex=1,5 do
   		local tb = {}
   		for i=1,5 do
			local card = self.m_cardArray[areaIndex][i];
			local pos = cc.p(card:getPosition());

			table.insert(tb,pos);
		end	
		table.insert(cardPosTb,tb);
   	end
	

   	--显示四张牌
   	local function show4CardOpen(areaIndex)

   		local function openCard(card)

   			for i=1,5 do
	   			local card = self.m_cardArray[areaIndex][i];
	   			if i ~= 4 then
	   				card:setCardValue(card.cardData);
	   			end
	   			
	   			local pos = cardPosTb[areaIndex][i];

				local moveTo = cc.MoveTo:create(0.25,cc.p(pos.x,pos.y));
	   			-- local easeAction = cc.EaseOut:create(moveTo,3)
	   			local easeAction = cc.EaseIn:create(moveTo,3)
	   			card:runAction(easeAction)

	   		end
			if self.m_bEffectOn then
				audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
			end
   		end

   		local function shrinkCard()
   			local card_t = self.m_cardArray[areaIndex][5];
   			local pos_t = cc.p(card_t:getPosition());
   			local cardTb = clone(self.m_cbTableCardArray[areaIndex]);
   			
   			for i=1,5 do
	   			local card = self.m_cardArray[areaIndex][i];
	   			local cardData = cardTb[i];
	   			card.cardData = cardData;

				local moveTo = cc.MoveTo:create(0.25,cc.p(pos_t.x+1*(5-5),pos_t.y));
				local easeAction = cc.EaseOut:create(moveTo,3)
				-- local easeAction = cc.EaseIn:create(moveTo,1.5)
	   			card:runAction(easeAction)
	   			
	   		end
	   		if self.m_bEffectOn then
	        	audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
	        end
   		end

   		local shrinkCardCallback = cc.CallFunc:create(function (sender)
			shrinkCard();
		end)

		local openCardCallback = cc.CallFunc:create(function (sender)
			openCard();
		end)

		local seqAction = cc.Sequence:create(shrinkCardCallback,cc.DelayTime:create(0.25),openCardCallback);
		self.Panel_cardTb[areaIndex]:stopAllActions();
   		self.Panel_cardTb[areaIndex]:runAction(seqAction);
   	end

   	--显示第五张牌
   	local function show5thCard(areaIndex)
   		local card_t = self.m_cardArray[areaIndex][4];
   		local pos_t = cc.p(card_t:getPosition());

   		local cardTb = clone(self.m_cbTableCardArray[areaIndex]);


   		local function openCard(card)
   			for i=1,5 do
	   			local card = self.m_cardArray[areaIndex][i];
	   			if i == 4 then
	   				card:setCardValue(card.cardData);
	   			end
	   			
	   			local pos = cardPosTb[areaIndex][i];
				local moveTo = cc.MoveTo:create(0.3,cc.p(pos.x,pos.y));
				local easeAction = cc.EaseOut:create(moveTo,3)
	   			card:runAction(easeAction)
	   			
	   		end
	   		if self.m_bEffectOn then
	        	audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
	        end
   		end

   		local function shrinkCard()
   			for i=1,5 do
	   			local card = self.m_cardArray[areaIndex][i];
	   			
	   			local cardData = cardTb[i];
	   			card.cardData = cardData;

				local moveTo = cc.MoveTo:create(0.3,cc.p(pos_t.x,pos_t.y));
				-- local action = cc.Sequence:create(moveTo,actionCallback)
				local easeAction = cc.EaseOut:create(moveTo,3)
	   			card:runAction(easeAction)

	   		end

	   		if self.m_bEffectOn then
	        	audio.playSound("bairenniuniu/sound/sound-fanpai.mp3", false);
	        end
   		end

   		local shrinkCardCallback = cc.CallFunc:create(function (sender)
			shrinkCard();
		end)

		local openCardCallback = cc.CallFunc:create(function (sender)
			openCard();
		end)

		local seqAction = cc.Sequence:create(shrinkCardCallback,cc.DelayTime:create(0.3),openCardCallback);
		self.Panel_cardTb[areaIndex]:stopAllActions();
   		self.Panel_cardTb[areaIndex]:runAction(seqAction);

   	end



   	local function showNiuResult(areaIndex)
   		local score = niuScoreTb[areaIndex];

		local pos = self.m_niuPosTb[areaIndex];
		local skeleton_animation = createSkeletonAnimation("brnn_"..NiuniuAnim.name,NiuniuAnim.json,NiuniuAnim.atlas);
		if skeleton_animation then
			self.Panel_anims:addChild(skeleton_animation);
    		skeleton_animation:setPosition(pos);
    		local niuName = NiuAnimName[score];
    		skeleton_animation:setAnimation(0,niuName, false);
		end

    	local cards = self.m_cardArray[areaIndex];
    	--有牛 右边两个扑克右移
    	if score > GameLogic.BRNN_CT_POINT then  --有牛
    		for i=4,5 do
    			cards[i]:runAction(cc.MoveBy:create(0.1,cc.p(6,0)));
    		end

    		local index = score;
    		if score <= GameLogic.BRNN_CT_SPECIAL_NIUNIU then
    			index = index - 1;
    		elseif score ==  GameLogic.BRNN_CT_SPECIAL_4HUANIU then --四花牛哞哞叫
    			index = 11;
    		elseif score == GameLogic.BRNN_CT_SPECIAL_5HUANIU then
    			index = 12;
    		elseif score == GameLogic.BRNN_CT_SPECIAL_BOMEBOME then
    			index = 13;	
    		elseif score == GameLogic.BRNN_CT_SPECIAL_5XIAONIU then
    			index = 14;
    		end

    		local path = string.format("bairenniuniu/sound/NiuSpeak_W/cow_%d.mp3", index);
    		
    		if self.m_bEffectOn then
        		audio.playSound(path, false);
        	end
    		
    	else
    		local path = string.format("bairenniuniu/sound/NiuSpeak_W/cow_0.mp3", index);
    		
    		if self.m_bEffectOn then
        		audio.playSound(path, false);
        	
        	end
    		
    	end
    
   	end

   	local function showWinResult()
    	self.m_bShowWin = true;
    	for i=1,5 do
    		if i < 5 then
    			local result,mult = GameLogic:CompareCard(self.m_cbTableCardArray[5], niuScoreTb[5], self.m_cbTableCardArray[i], niuScoreTb[i])
    			
    			if result == 0 then
    				
    			end

    			if result == 1 then  --win
    				local skeleton_animation = createSkeletonAnimation("brnn_"..WinAnim.name,WinAnim.json,WinAnim.atlas);
    				if skeleton_animation then
    					self.Panel_anims:addChild(skeleton_animation);
			        	skeleton_animation:setAnimation(0,WinAnimName, false);
			        	local pos = self.m_winPosTb[i];

			        	skeleton_animation:setPosition(pos);
    				end
		        	
    			end
    		end
    	end
    end


   	local times = 0;
   	local showAreaIndex = 1;
   	local niuAreaIndex = 1;

   	local indexList = {5,1,2,3,4}
   	local function doPercent()
   			if times == 0 then
   				for i=1,5 do
   					show4CardOpen(i);
   				end
   			
   			elseif times == 10*(showAreaIndex-1*0) and showAreaIndex <= 5 and showAreaIndex == niuAreaIndex  then  --亮第一手牌  60
   				if showAreaIndex <= 5 then
   					show5thCard(indexList[showAreaIndex]);
   					showAreaIndex = showAreaIndex + 1;
   				end
   			elseif times == 10*(niuAreaIndex-1*0) + 5  and showAreaIndex ~=niuAreaIndex and niuAreaIndex <= 5 then --亮第一个牛 100
 				if niuAreaIndex <= 5 then
 					showNiuResult(indexList[niuAreaIndex]);
 					niuAreaIndex = niuAreaIndex + 1;
 				end
   			elseif times == 54 + 10 then --显示胜利 失败
   				showWinResult();
   			end
   			times = times + 1;
   	end



   	--停止消息监听
	function stopProgressTime()
	    if self.m_finishTimeId ~= nil and self.m_finishTimeId ~= -1 then
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_finishTimeId);
	        self.m_finishTimeId = -1;
	    end
	end

   	local function runProgressTime( delta )
   		if not self.m_bShowWin then
   			doPercent();
   		else
   			stopProgressTime();
   		end
   	end

   

   	local function startProgressTime()   		
   		if self.m_finishTimeId == -1 then
	     	self.m_finishTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) runProgressTime(delta) end, 0.1 ,false);
	     end
   	end

   	stopProgressTime();
   	startProgressTime();

   -- 	local function runProgressTime()
   -- 		if not self.m_bShowWin then
   -- 			doPercent();
			-- self.Panel_anims:stopAllActions();
			-- self.Panel_anims:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(runProgressTime)))
   -- 		else
   -- 			self.Panel_anims:stopAllActions();
   -- 		end
   		
   -- 	end

   -- 	runProgressTime();
end


--小局筹码结算
function TableLayer:dealCheckRoundOut()
	if not self.m_bEnterGame then
		return;
	end


	local winSelf = self.m_lSelfWinScore;

	local niuScoreTb = {};
	local winResultTb = {}
	for i=1,5 do
		local idx = i;
   		local niuScore = GameLogic:GetCardType(self.m_cbTableCardArray[idx], 5);
   		table.insert(niuScoreTb,niuScore)
   	end

   	-- luaDump(niuScoreTb, "dealCheckRoundOut_niuScoreTb", 4)

   	for i=1,5 do
		if i < 5 then
			local result,mult = GameLogic:CompareCard(self.m_cbTableCardArray[5], niuScoreTb[5], self.m_cbTableCardArray[i], niuScoreTb[i])
			
			if result == 0 then
				
			end

			if result == 1 then  --win
				table.insert(winResultTb,true);
	        else
	        	table.insert(winResultTb,false);
			end
		end
    end
    -- luaDump(winResultTb, "dealCheckRoundOut_winResultTb", 4)

    --庄家赢的筹码区域
    local bankerWinJettons = {};
    --庄家需要扔出的筹码
    local bankerLostJettons = {};
    --剩下闲家赢的筹码
    local playerWinJettons = {};	
    local children = self.Panel_jettons:getChildren();
    local count = self.Panel_jettons:getChildrenCount();

    if count < 100 then
    	for i,v in ipairs(children) do
	    	local name = v:getName();
	    	for j,vv in ipairs(winResultTb) do  --失败的区域筹码 庄家收走
		    	if not vv then
		    		local areaJetton = tonumber(string.sub(name, 1,1)) 
		    		-- luaPrint("bankerWinJettons name,areaJetton:",name,areaJetton);
		    		if j == areaJetton then
		    			table.insert(bankerWinJettons,v);
		    		end
		    	else
		    		local areaJetton = tonumber(string.sub(name, 1,1)) 
		    		-- luaPrint("bankerLostJettons name,areaJetton:",name,areaJetton);
		    		if j == areaJetton then
		    			local bMe = v.bMe;
		    			local jettonIcon = v:clone();
		    			jettonIcon.bMe = bMe;
		    			if v.bDeskStation ~= nil and v.bDeskStation > 0 then
		    				jettonIcon.bDeskStation = v.bDeskStation;
		    			else
		    				jettonIcon.bDeskStation = -1;
		    			end
		    			

		    			self.Panel_jettons:addChild(jettonIcon);
		    			jettonIcon:setVisible(false);
		    			
		    			jettonIcon:setPosition(self.m_bankerPos);

		    			jettonIcon.areaIndex = areaJetton;
		    			table.insert(bankerLostJettons,jettonIcon);
		    			table.insert(playerWinJettons,v);
		    		end
		    	end
		    end
	    end
    else
    	local areaLostTb = {
    		[1] = 0,
    		[3] = 0,
    		[2] = 0,
    		[4] = 0,
    	}
    	local max_count = 15;
    	for i,v in ipairs(children) do
	    	local name = v:getName();
	    	for j,vv in ipairs(winResultTb) do  --失败的区域筹码 庄家收走
		    	if not vv then
		    		local areaJetton = tonumber(string.sub(name, 1,1)) 
		    		-- luaPrint("bankerWinJettons name,areaJetton:",name,areaJetton);
		    		if j == areaJetton then
		    			table.insert(bankerWinJettons,v);
		    		end
		    	else
		    		local areaJetton = tonumber(string.sub(name, 1,1)) 
		    		-- luaPrint("bankerLostJettons name,areaJetton:",name,areaJetton);
		    		if j == areaJetton then
		    			local bMe = v.bMe;
		    			table.insert(playerWinJettons,v);

		    			if bMe then
		    				local jettonIcon = v:clone();
			    			jettonIcon.bMe = bMe;
			    			if v.bDeskStation ~= nil and v.bDeskStation > 0 then
			    				jettonIcon.bDeskStation = v.bDeskStation;
			    			else
			    				jettonIcon.bDeskStation = -1;
			    			end
			    			
			    			self.Panel_jettons:addChild(jettonIcon);
			    			jettonIcon:setVisible(false);
			    			
			    			jettonIcon:setPosition(self.m_bankerPos);

			    			jettonIcon.areaIndex = areaJetton;
			    			table.insert(bankerLostJettons,jettonIcon);
			    			
		    			else

		    	-- 			local _wChairID = jettonIcon.wChairID
							-- local _cbJettonArea = jettonIcon.cbJettonArea
							-- local _lJettonScore = jettonIcon.lJettonScore;


		    				if areaLostTb[v.cbJettonArea] < max_count then
		    					local jettonIcon = v:clone();
				    			jettonIcon.bMe = bMe;
				    			if v.bDeskStation ~= nil and v.bDeskStation > 0 then
				    				jettonIcon.bDeskStation = v.bDeskStation;
				    			else
				    				jettonIcon.bDeskStation = -1;
				    			end
				    			
				    			self.Panel_jettons:addChild(jettonIcon);
				    			jettonIcon:setVisible(false);
				    			
				    			jettonIcon:setPosition(self.m_bankerPos);

				    			jettonIcon.areaIndex = areaJetton;
				    			table.insert(bankerLostJettons,jettonIcon);

				    			areaLostTb[v.cbJettonArea] = areaLostTb[v.cbJettonArea] + 1;
		    				end
		    				
		    			end
		    			
		    		end
		    	end
		    end
	    end
    end



    

    
    --庄家赢的筹码
    local bankerWinNum = table.nums(bankerWinJettons);
    --庄家输的筹码
    local bankerLostNum = table.nums(bankerLostJettons);
    --玩家赢的筹码
    local playerWinNum = table.nums(playerWinJettons);

    self.m_tDealTime = 0;
   	local showIndex = 1;


   	--庄家赢的筹码
   	local function playFlyToBanker()
   		
   		if self.m_bEffectOn then
        	audio.playSound("bairenniuniu/sound/sound-get-gold.mp3", false);
        end

   		
   		for i,v in ipairs(bankerWinJettons) do
   			local moveIt = cc.MoveTo:create(0.5,self.m_bankerPos);
   			local scaleIt = cc.ScaleTo:create(0.02,0.1);
   			local removeIt = cc.RemoveSelf:create();
   			v:runAction(cc.Sequence:create(moveIt,scaleIt,removeIt));
   		end
   	end

   	--庄家返场的筹码
   	local function playFlyOutBanker()
   		
   		if self.m_bEffectOn then
        	audio.playSound("bairenniuniu/sound/sound-get-gold.mp3", false);
        end
   		
   		for i,v in ipairs(bankerLostJettons) do
   			local area = v.areaIndex;
   			local pos = self:getRandPos(self.Image_jettonAreaTb[area]);
   			v:setPosition(self.m_bankerPos);
   			local moveIt = cc.MoveTo:create(0.5,pos);
   			local showIt = cc.Show:create();
   			v:runAction(cc.Sequence:create(showIt,moveIt));
   		end
   	end


   	--玩家赢的筹码
   	local function playFlyToPlayers()
   		
   		if self.m_bEffectOn then
        	audio.playSound("bairenniuniu/sound/sound-get-gold.mp3", false);
        end
   		
   		for i,v in ipairs(bankerLostJettons) do
   			-- local pos = self.m_otherPos;

   			local pos = self.Panel_jettons:getParent():convertToNodeSpace(cc.p(self.Button_others:getPosition()));
    		if self:isVipSeat(v.bDeskStation) then
	    		pos = self:getOtherJettonPos(v.bDeskStation);		
	    	end

   			if v.bMe then
   				pos = self.m_selfPos;
   			end

   			local moveIt = cc.MoveTo:create(0.5,pos);
   			local removeIt = cc.RemoveSelf:create();
   			v:runAction(cc.Sequence:create(moveIt,removeIt));
   		end

   		for i,v in ipairs(playerWinJettons) do
   			
    		local pos = self.Panel_jettons:getParent():convertToNodeSpace(cc.p(self.Button_others:getPosition()));
    		if self:isVipSeat(v.bDeskStation) then
	    		pos = self:getOtherJettonPos(v.bDeskStation);		
	    	end

   			if v.bMe then
   				pos = self.m_selfPos;
   			end

   			local moveIt = cc.MoveTo:create(0.5,pos);
   			local removeIt = cc.RemoveSelf:create();
   			v:runAction(cc.Sequence:create(moveIt,removeIt));
   		end
   	end

   	local function getOtherWinScore(lBankerScore,m_lSelfWinScore)
	    local zScore = lBankerScore--庄家积分
	    local uScore = m_lSelfWinScore --自己的积分
	    local otherScore = 0;
	    if zScore > 0 then
	        zScore = zScore/0.95
	    end

	    if uScore > 0 then
	        uScore = uScore/0.95
	    end

	    if zScore > 0 then 
	        otherScore = -(uScore+zScore);
	    else
	        otherScore = uScore + zScore;
	    end

	    if otherScore > 0 then
	    	otherScore = otherScore*0.95
	    end

	    return otherScore;
	end


   	--播放最后玩家输赢得分
   	local function playWinResult()
		local bankerWinScore = self.m_lBankerWinScore;
		local selfWinScore = self.m_lSelfWinScore; 

		local otherWinScore = self.m_lOtherWinScore;
		
		self.m_resultTextTb = {};

		local function getFontStr(value)
			local str = "bairenniuniu/image/brnn_zi_ying.png"
			if value < 0 then
				str = "bairenniuniu/image/brnn_zi_shu.png"
			end
			return str;
		end


		if bankerWinScore ~= 0 then
			
			local winStr = "";
			if bankerWinScore >= 0 then
				winStr = string.format("+%s",goldConvert(bankerWinScore,true));
			else
				winStr = goldConvert(bankerWinScore,true)
			end
			local text_score = FontConfig.createWithCharMap(winStr,getFontStr(bankerWinScore),27,32,"+")
			text_score:setAnchorPoint(cc.p(0,0.5));
			text_score:setPosition(cc.p(190,604));

			text_score:setVisible(false);
			self.Panel_result:addChild(text_score);
			text_score:setTag(TAG_BANKER);
			table.insert(self.m_resultTextTb,text_score)
		end
		
		--播放连胜特效
		local jettonedScore = 0;
		for i,v in ipairs(self.m_lUserJettonScore) do
			jettonedScore = jettonedScore + v;
		end

		if self.m_WinTime > 2 and ((jettonedScore > 0 and not self:isMeChair(self.m_wBankerUser)) or self:isMeChair(self.m_wBankerUser)) then
			local winTime = self.m_WinTime;
			if winTime>10 then
				winTime = 11;
			end

			self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
				local shengAction = self.Image_bg:getChildByName("liansheng");
				if shengAction then
					shengAction:removeFromParent();
				end

				local shengAction = createSkeletonAnimation("liansheng","hall/game/gameEffect/liansheng.json","hall/game/gameEffect/liansheng.atlas");
				if shengAction then
					local bgSize = self.Image_bg:getContentSize();

					shengAction:setPosition(bgSize.width/2,bgSize.height/2-50);
					shengAction:setAnimation(1,"l"..winTime, false);
					shengAction:setName("liansheng");
					self.Image_bg:addChild(shengAction);
				end

				audio.playSound("hall/game/gameEffect/liansheng.mp3");
			end),cc.DelayTime:create(2),cc.CallFunc:create(function()
				local shengAction = self.Image_bg:getChildByName("liansheng");
				if shengAction then
					shengAction:removeFromParent();
				end
			end)))

		end
		
		
		if selfWinScore ~= 0 then

			local winStr = "";
			if selfWinScore >= 0 then
				winStr = string.format("+%s",goldConvert(selfWinScore,true));
			else
				winStr = goldConvert(selfWinScore,true)
			end
			local text_score = FontConfig.createWithCharMap(winStr,getFontStr(selfWinScore),27,32,"+")
			text_score:setAnchorPoint(cc.p(0,0.5));
			text_score:setPosition(cc.p(135,93));
			text_score:setVisible(false);
			self.Panel_result:addChild(text_score);
			text_score:setTag(TAG_SELF);
			table.insert(self.m_resultTextTb,text_score)
			if selfWinScore >= 0 then
			
				if self.m_bEffectOn then
        			audio.playSound("bairenniuniu/sound/sound-result-win.mp3", false);
        		end
        	
			else
				if self.m_bEffectOn then
        			audio.playSound("bairenniuniu/sound/sound-result-lose.mp3", false);
       			end
			end

			--播放玩家自己赢动画add_a
			if selfWinScore >= 0 then
				local WinNewAnim = {
						name = "brnn_shengli",
						json = "bairenniuniu/anim/shengli.json",
						atlas = "bairenniuniu/anim/shengli.atlas",
						anim = "shengli"
				}


				local skeleton_animation = createSkeletonAnimation("brnn_self_win",WinNewAnim.json,WinNewAnim.atlas);
				if skeleton_animation then
					local pos = cc.p(self.Image_startTip:getPosition());
					local size = self.Panel_anims:getContentSize();
					self.Panel_anims:addChild(skeleton_animation);
					skeleton_animation:setName(WinNewAnim.anim);
					skeleton_animation:setPosition(cc.p(size.width*0.5,size.height*0.5));
					skeleton_animation:setAnimation(0,WinNewAnim.anim, false);
					local seq = cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create())
					skeleton_animation:runAction(seq);
				end

			end


		end

		if otherWinScore ~= 0 then
			local winStr = "";
			if otherWinScore >= 0 then
				winStr = string.format("+%s",goldConvert(otherWinScore,true));
			else
				winStr = goldConvert(otherWinScore,true)
			end
			local text_score = FontConfig.createWithCharMap(winStr,getFontStr(otherWinScore),27,32,"+")
			text_score:setAnchorPoint(cc.p(0,0.5));
			local worldPos = self.Button_others:convertToWorldSpace(cc.p(76,56))
			local pos = self.Panel_result:getParent():convertToNodeSpace(worldPos);
			text_score:setPosition(pos);
			text_score:setVisible(false);
			self.Panel_result:addChild(text_score);
			text_score:setTag(TAG_OTHER);
			table.insert(self.m_resultTextTb,text_score)
		end
		
		--VIP玩家
		for i,winScore in ipairs(self.m_winUserResult) do
			if winScore ~= 0 then
				local lSeat = i - 1;
				if self:isVipSeat(lSeat) then
					local seatIndex = self:getVipSeatIndex(lSeat);
					local winStr = "";
					if winScore >= 0 then
						winStr = string.format("+%s",goldConvert(winScore,true));
					else
						winStr = goldConvert(winScore,true)
					end
					local text_score = FontConfig.createWithCharMap(winStr,getFontStr(winScore),27,32,"+")
					if seatIndex <= 3 then
						text_score:setAnchorPoint(cc.p(0,0.5));
						local worldPos = self.Panel_vipTb[seatIndex]:convertToWorldSpace(cc.p(110,65));
						local pos = self.Panel_result:convertToNodeSpace(worldPos);
						-- local pos = cc.p(110,65);
						text_score:setPosition(pos);
					else
						local worldPos = self.Panel_vipTb[seatIndex]:convertToWorldSpace(cc.p(-10,65));
						local pos = self.Panel_result:getParent():convertToNodeSpace(worldPos);
						text_score:setAnchorPoint(cc.p(1,0.5));
						-- local pos = self.Panel_vipTb[seatIndex]:convertToWorldSpace(cc.p(-10,65));
						-- local pos = cc.p(-10,65);
						text_score:setPosition(pos);
					end
					
					text_score:setVisible(false);
					self.Panel_result:addChild(text_score);
					text_score:setTag(TAG_OTHER);
					table.insert(self.m_resultTextTb,text_score)
				end	
			end
		end



		local function updateVipScore()
			local players = self.tableLogic._deskUserList._users;
			luaDump(players, "updateVipScore_players", 5);
			--VIP玩家
			for i,winScore in ipairs(self.m_winUserResult) do
				
				if winScore ~= 0 then
					local lSeat = i - 1;
					if self:isVipSeat(lSeat) then
						local seatIndex = self:getVipSeatIndex(lSeat);
						local userInfo = self.tableLogic:getUserBySeatNo(lSeat);
						-- local userInfo = self:getVipSeatInfo(lSeat);
						
						userInfo.i64Money = userInfo.i64Money + winScore;
						self:resetVipSeat(seatIndex,userInfo);
					end	
				end
			end
		end



		for i,v in ipairs(self.m_resultTextTb) do
			local seq = cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(3.0),cc.RemoveSelf:create());
			v:runAction(seq);
		end

		self.m_resultTextTb = {};

		local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
		local bankerInfo = self.tableLogic:getUserBySeatNo(self.m_wBankerUser);
    	if userInfo then
			self.m_lSelfScore = userInfo.i64Money +selfWinScore;
    	end
		
		if bankerInfo then
			-- self.m_lBankerScore = bankerInfo.i64Money +bankerWinScore;
			--庄家结算后数据
			self.m_lBankerScore = self.m_lBankerScore + bankerWinScore;
			-- luaPrint("bankerInfo.i64Money,self.m_lBankerScore win________",bankerInfo.i64Money,self.m_lBankerScore)
		end
		
		local jettonedScore = 0;
		for i,v in ipairs(self.m_lUserJettonScore) do
			jettonedScore = jettonedScore + v;
		end
		
		if not self:isMeChair(self.m_wBankerUser) and jettonedScore <= 0 then
			self:TipTextShow("本局您没有下注");
		end


		self:updatePlayerCoin();
		-- updateVipScore();
   	end


   	local bPlayEnd = false;

   	local function doPercentFly()
   			if self.m_tDealTime == -1 then
   				

   			elseif self.m_tDealTime == 1  then
   				self:updateLastRecord();

   				if bankerWinNum > 0 then   	--播放筹码飞向庄家
   					playFlyToBanker();
   				else
   					self.m_tDealTime = 8;
   					return;
   				end
   			elseif self.m_tDealTime == 8 then --
 				if bankerLostNum > 0 then  	--播放筹码飞出庄家
 					playFlyOutBanker();
 				else
 					self.m_tDealTime = 16;
 					return;
 				end
   			elseif self.m_tDealTime == 16 then --播放筹码飞向玩家
   				if bankerLostNum > 0 or playerWinNum > 0 then
   					playFlyToPlayers();
   				else
   					self.m_tDealTime = 22;
   					return;
   				end

   			elseif self.m_tDealTime == 22 then
   				playWinResult();
   				bPlayEnd = true;

   			end

   			self.m_tDealTime = self.m_tDealTime + 1;
   	end
   	--停止消息监听
	function stopProgressTimeFly()
	    if self.m_sendCardTimeId ~= nil and self.m_sendCardTimeId ~= -1 then
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_sendCardTimeId);
	        self.m_sendCardTimeId = -1;
	    end
	end

   	local function runProgressTimeFly(delta)
   		if not bPlayEnd then
   			doPercentFly();
   		else
   			stopProgressTimeFly();
   		end
   	end

   

   	local function startProgressTimeFly()   		
   		if self.m_sendCardTimeId == -1 then
	     	self.m_sendCardTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) runProgressTimeFly(delta) end, 0.1 ,false);
	     end
   	end

   	stopProgressTimeFly();
   	startProgressTimeFly();



end


--刷新记录信息
function TableLayer:updateLastRecord()
	local niuScoreTb = {};
	local winResultTb = {}
	for i=1,5 do
		local idx = i;
   		local niuScore = GameLogic:GetCardType(self.m_cbTableCardArray[idx], 5);
   		table.insert(niuScoreTb,niuScore)
   	end



   	for i=1,5 do
		if i < 5 then
			local result,mult = GameLogic:CompareCard(self.m_cbTableCardArray[5], niuScoreTb[5], self.m_cbTableCardArray[i], niuScoreTb[i])
			if result == 1 then  --win
				table.insert(winResultTb,true);
	        else
	        	table.insert(winResultTb,false);
			end
		end
	end

	self.m_allRound = self.m_allRound + 0;
	
	if table.nums(self.m_lastAreaWinTb) >= MaxRecordCount then
		local count = table.nums(self.m_lastAreaWinTb);
		table.remove(self.m_lastAreaWinTb,1,1);
	end
	
	table.insert(self.m_lastAreaWinTb,winResultTb);



	-- self.m_recordListLayer:refreshDayList(self.m_allRound,self.m_areaWinRoundTb);
	-- self.m_recordListLayer:refreshList(self.m_lastAreaWinTb);

	self:refreshDayList(self.m_allRound,self.m_areaWinRoundTb);
	self:refreshList(self.m_lastAreaWinTb);



end


--刷新当日的局数
function TableLayer:refreshRecordDayList()
	-- self.m_recordListLayer:refreshDayList(self.m_allRound,self.m_areaWinRoundTb);
	self:refreshDayList(self.m_allRound,self.m_areaWinRoundTb);
end


function TableLayer:getJettonArea(serverJettonArea)
	local cbJettonArea = 1;
	if serverJettonArea == 4 then
		cbJettonArea = 3;

	elseif serverJettonArea == 8 then
		cbJettonArea = 4;

	elseif serverJettonArea == 2 then
		cbJettonArea = 2;

	elseif serverJettonArea == 1 then
		cbJettonArea = 1;
	else
		cbJettonArea = 1;
			
	end

	return cbJettonArea;
end

function TableLayer:getJettonAreaS(clientJettonArea)
	local cbJettonArea = 1;
	if clientJettonArea == 4 then
		cbJettonArea = 8;

	elseif clientJettonArea == 3 then
		cbJettonArea = 4;

	elseif clientJettonArea == 2 then
		cbJettonArea = 2;

	elseif clientJettonArea == 1 then
		cbJettonArea = 1;
	else
		cbJettonArea = 1;
			
	end

	return cbJettonArea;
end


function TableLayer:showGameStartTip(dt)
	self.Panel_statusTip:removeChildByName(TipAnimName.STOP);
	self.Panel_statusTip:stopAllActions();
	

	
	self.Image_startTip:setVisible(false);
	self.Panel_statusTip:setVisible(true);
	local pos = cc.p(self.Image_startTip:getPosition());

	if dt == nil then
		dt = 0.1;
	end
	
	local StartAnim ={
		name = "brnn_kaishixiazhu",
		json = "bairenniuniu/anim/kaishixiazhu.json",
		atlas = "bairenniuniu/anim/kaishixiazhu.atlas",
	}

	local skeleton_animation = createSkeletonAnimation(StartAnim.name,StartAnim.json,StartAnim.atlas);
	if skeleton_animation then
		

		self.Panel_statusTip:removeChildByName(TipAnimName.START);

		self.Panel_statusTip:addChild(skeleton_animation);
		skeleton_animation:setVisible(false);
		skeleton_animation:setName(TipAnimName.START);
		skeleton_animation:setPosition(pos);
		local actionCallback1 = cc.CallFunc:create(function ()
			skeleton_animation:setAnimation(0,"kaishixiazhu", false);
			if self.m_bEffectOn then
		        audio.playSound("bairenniuniu/sound/sound-start-wager.mp3", false);
		    end
		end)

		local seq = cc.Sequence:create(cc.DelayTime:create(dt),cc.Show:create(),actionCallback1)
		skeleton_animation:runAction(seq);
	end

	

	
	
	

	local actionCallback = cc.CallFunc:create(function ()
				self.Panel_statusTip:removeChildByName(TipAnimName.START);
	end)


	local action = cc.Sequence:create(cc.DelayTime:create(dt+1.5),actionCallback);

	

	self.Panel_statusTip:stopAllActions();
	self.Panel_statusTip:runAction(action);


end



function TableLayer:showStopJettonTip()

	if self.m_bEffectOn then
        audio.playSound("bairenniuniu/sound/sound-end-wager.mp3", false);	
    end
	

    self.Panel_statusTip:removeChildByName(TipAnimName.START);
	self.Panel_statusTip:stopAllActions();
	

	local pos = cc.p(self.Image_startTip:getPosition());
	local skeleton_animation = createSkeletonAnimation("brnn_"..TipAnimName.STOP,TipAnim.json,TipAnim.atlas);
	if skeleton_animation then
		self.Panel_statusTip:removeChildByName(TipAnimName.STOP);

		self.Panel_statusTip:addChild(skeleton_animation);
		skeleton_animation:setAnimation(0,TipAnimName.STOP, false);
		skeleton_animation:setPosition(pos);
		skeleton_animation:setName(TipAnimName.STOP);
	end
	
	

	self.Image_startTip:setVisible(false);

	self.Panel_statusTip:setVisible(true);


	local actionCallback = cc.CallFunc:create(function ()
				self.Panel_statusTip:removeChildByName(TipAnimName.STOP);
	end)
	local action = cc.Sequence:create(cc.DelayTime:create(2),actionCallback);
	self.Panel_statusTip:stopAllActions();
	self.Panel_statusTip:runAction(action);
end


--提前开奖
function TableLayer:showEarlyCheckTip()

	if self.Panel_anims:getChildByName(EarlyAnimName) then
		self.Panel_anims:removeChildByName(EarlyAnimName);
	end
	

	local pos = cc.p(self.Image_tip:getPosition());
	local skeleton_animation = createSkeletonAnimation(EarlyAnim.name,EarlyAnim.json,EarlyAnim.atlas);
	if skeleton_animation then
		self.Panel_anims:addChild(skeleton_animation);
	
		skeleton_animation:setAnimation(0,EarlyAnimName, false);
		skeleton_animation:setPosition(pos);
		skeleton_animation:setName(EarlyAnimName);
		local action = cc.Sequence:create(cc.DelayTime:create(2.5),cc.RemoveSelf:create());
		skeleton_animation:runAction(action);
	end



end


--更新玩家得分
function TableLayer:updatePlayerCoin()
	local bankerScore = GameMsg.formatCoin(self.m_lBankerScore);
	self.Text_bankerCoin:setString(bankerScore);

	local playerScore = GameMsg.formatCoin(self.m_lSelfScore);
	self.Text_selfCoin:setString(playerScore);
end


--更新房间玩家积分 dester
function TableLayer:updateUserCoin()

	local userInfo = self.tableLogic:getUserBySeatNo(self.m_wBankerUser);
	local bankerScore = GameMsg.formatCoin(userInfo.i64Money);
	self.Text_bankerCoin:setString(bankerScore);

	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	
	local playerScore = GameMsg.formatCoin(userInfo.i64Money);
	self.Text_selfCoin:setString(playerScore);
end



--获取已经下注的额度
function TableLayer:getAllJettoned()
	local lJettonScore = 0;
	--玩家总下注区域
    for k,v in pairs(self.m_lUserJettonScore) do
        lJettonScore = lJettonScore + v;
    end

    return lJettonScore;
end

-----------------------------------------------百人牛牛消息------------------------------------------------------
function TableLayer:onGameStationFree(msg)
	luaDump(msg, "msg_onGameStationFree", 5)

	self:resetGameData();
	--桌子状态
	-- self.m_cbGameStatus = msg.cbGameStatus;
	self.m_cbGameStatus =  GameMsg.GAME_SCENE_FREE;
	--游戏几倍场
	self.m_lMultiple = msg.lMultiple;

	--剩余时间
	self.m_cbTimeLeave = msg.cbTimeLeave;
	--用户金币
	self.m_lUserMaxScore = msg.lUserMaxScore;
	--用户当前金币
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
    if userInfo then
    	self.m_lSelfScore = userInfo.i64Money;
    end

	--当前庄家
	self.m_wBankerUser = msg.wBankerUser;
	--庄家局数
	self.m_cbBankerTime = msg.cbBankerTime;
	--庄家赢分
	self.m_lBankerWinScore = msg.lBankerWinScore
	--庄家分数
	self.m_lBankerScore = msg.lBankerScore;
	--系统是否能坐庄
	self.m_bEnableSysBanker = msg.bEnableSysBanker
	----区域限制
	self.m_lAreaLimitScore = msg.lAreaLimitScore;
	--申请上庄条件
	self.m_lApplyBankerCondition = msg.lApplyBankerCondition;
	
	
	--申请玩家
	self.m_nApplyCount = msg.ApplyCount;
	self.m_applyBankerList = {};

	self:refreshBankerList(msg.ApplyUsers, msg.ApplyCount)

	--是否下庄
	self.m_wCancleBanker = msg.wCancleBanker;
	self.m_enApplyState = APPLY_STATE.kPlayerState
	
	

	-- for k,v in pairs(msg.wGetUser) do
	-- 	if v ~= INVALID_DESKSTATION then
	-- 		table.insert(self.m_applyBankerList,v);
	-- 		if self:isMeChair(v) then
	-- 			self.m_enApplyState = APPLY_STATE.kBankerApplyState		
	-- 		end		
	-- 	end
	-- end


	if self:isMeChair(self.m_wBankerUser) then
		if self.m_wCancleBanker then
			
			self.m_enApplyState = APPLY_STATE.kBankerState;
		else
			
			self.m_enApplyState = APPLY_STATE.kBankerQuitState;
		end
	else
		if msg.wApplyBanker then
			self.m_enApplyState = APPLY_STATE.kBankerApplyState
		end
	end	


	--房间信息
	if globalUnit.isTryPlay == true then
		self.Text_tableInfo:setString(string.format("体验场%d倍",self.m_lMultiple));
	else
		self.Text_tableInfo:setString(string.format("现金%d倍",self.m_lMultiple));
	end

	


	--当日游戏总人数
	self.m_allRound = msg.lCount;
	--每个区域输赢
	for i,v in ipairs(msg.lWinArea) do
		self.m_areaWinRoundTb[i] = v;
	end


	--刷新当日比赛记录
    self:refreshRecordDayList();

	--初始化庄家信息
	self:resetBankerInfo();
	self:resetSelfInfo();

	self.m_lAllJettonScore = {0,0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0,0}
    self.m_lUserAllJetton = 0;

    --申请按钮状态更新
    self:refreshApplyBtn();

    self:refreshPlayerCount();

    self:setBankBoxEnable(true);
    self.m_bRunAction = false;

    self.m_bEnterMsg = true;
    self:refreshApplyList();

    self:initVipList();
end


function TableLayer:onGameStationPlaying(msg)
	self:addPlist();
	luaDump(msg, "msg_onGameStationPlaying", 5)
	self:resetGameData();


	--庄家局数
	self.m_cbBankerTime = msg.cbBankerTime;
	--桌子状态
	self.m_cbGameStatus = msg.cbGameStatus; --26 27
	-- self.m_cbGameStatus = GameMsg.GAME_SCENE_JETTON
	--游戏几倍场
	self.m_lMultiple = msg.lMultiple;
	--桌面扑克数据
	self.m_cbTableCardArray = self:getSwapTableCards(msg.cbTableCardArray);
	--系统是否能坐庄
	self.m_bEnableSysBanker = msg.bEnableSysBanker
	--剩余时间
	self.m_cbTimeLeave = msg.cbTimeLeave;

	--全部玩家下注去 天区域
	self.m_lAllJettonScore[1] = msg.lAllTianScore;
	--玩家下注去 地区域
	self.m_lAllJettonScore[2] = msg.lAllDiScore;
	--玩家下注去 玄区域
	self.m_lAllJettonScore[3] = msg.lAllXuanScore;
	--玩家下注去 黄区域
	self.m_lAllJettonScore[4] = msg.lAllHuangScore;


	--申请上庄条件
	self.m_lApplyBankerCondition = msg.lApplyBankerCondition;
	----区域限制
	self.m_lAreaLimitScore = msg.lAreaLimitScore;	

	--庄家分数
	self.m_lBankerScore = msg.lBankerScore;
	--庄家赢分
	self.m_lBankerWinScore = msg.lBankerWinScore
	--庄家成绩
	self.m_lEndBankerScore = msg.lEndBankerScore;
	--游戏税收
	self.m_lEndRevenue = msg.lEndRevenue;
	--返回积分
	self.m_lEndUserReturnScore = msg.lEndUserReturnScore;
	--玩家成绩
	self.m_lEndUserScore = msg.lEndUserScore;

	--最大下注
	self.m_lUserMaxScore = msg.lUserMaxScore;

	--玩家自己下注去 天区域
	self.m_lUserJettonScore[1] = msg.lUserTianScore;
	--玩家自己下注去 地区域
	self.m_lUserJettonScore[2] = msg.lUserDiScore;
	--玩家自己下注去 玄区域
	self.m_lUserJettonScore[3] = msg.lUserXuanScore;
	--玩家自己下注去 黄区域
	self.m_lUserJettonScore[4] = msg.lUserHuangScore;

	--玩家成绩得分
	self.m_lSelfWinScore = msg.lEndUserScore
	--申请上庄玩家
	self.m_nApplyCount = msg.ApplyCount;
	--玩家总下注区域
    for k,v in pairs(self.m_lUserJettonScore) do
        self.m_lUserAllJetton = self.m_lUserAllJetton + v
    end

    -- luaPrint("playing_m_lUserAllJetton:",self.m_lUserAllJetton);
    local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
    -- luaDump(userInfo, "--------------userInfo---------------1", 5)
    if userInfo then
    	self.m_lSelfScore = userInfo.i64Money - self.m_lUserAllJetton;
    end
    -- luaPrint("self.m_lSelfScore:---------",self.m_lSelfScore)
	--当前庄家
	self.m_wBankerUser = msg.wBankerUser;


	

	--是否取消下庄
	self.m_wCancleBanker = msg.wCancleBanker;
	self.m_enApplyState = APPLY_STATE.kPlayerState
	
	self:refreshBankerList(msg.ApplyUsers, msg.ApplyCount)

	luaPrint("wApplyBanker:--------------",msg.wApplyBanker)

	if self:isMeChair(self.m_wBankerUser) then
		if self.m_wCancleBanker then
			
			self.m_enApplyState = APPLY_STATE.kBankerQuitState;
		else
			
			self.m_enApplyState = APPLY_STATE.kBankerState;
		end
	else
		if msg.wApplyBanker then
			self.m_enApplyState = APPLY_STATE.kBankerApplyState
		end
	end	


	--当日游戏总局数
	self.m_allRound = msg.lCount;
	--每个区域输赢
	for i,v in ipairs(msg.lWinArea) do
		self.m_areaWinRoundTb[i] = v;
	end

	--房间信息
	if globalUnit.isTryPlay == true then
		self.Text_tableInfo:setString(string.format("体验场%d倍",self.m_lMultiple));
	else
		self.Text_tableInfo:setString(string.format("现金%d倍",self.m_lMultiple));
	end
	

	--刷新当日比赛记录
    self:refreshRecordDayList();

	--初始化庄家信息
	self:resetBankerInfo();
	self:resetSelfInfo();
	self:refreshApplyList();
	--申请按钮状态更新
    self:refreshApplyBtn();

	self:setJettonEnable(true);

	

    self:resetBankerScore();

    if msg.cbGameStatus == GameMsg.GAME_SCENE_JETTON then --26
      
        self:setJettonEnable(true);
        self:updateJettonList();
        self.m_bEnterGame = true;

        self:setBankBoxEnable(true);

        self:replaceTableJetton();
        self:updateAreaScore(true);
        --恢复桌面的牌
        self:sendCard(false);
        self:hideWaitNextTip();
    else
    	--体验场删除退出提示
    	if self.m_lUserAllJetton > 0 then
    		GamePromptLayer:remove()
    	end
    	

    	self.m_bEnterGame = false;
    	self.m_nLastJetton = 0; --最后下注筹码
    	self.m_nLastArea = 0;	--最后下注区域
    	--显示等待下局开始
    	self:showWaitNextTip();
        self:setJettonEnable(false);

        self:setBankBoxEnable(false);
        self:clearAreaScore();
    end

    if self:isMeChair(self.m_wBankerUser) == true then
        self:setJettonEnable(false);
    end

    self:showGameStatus(self.m_cbTimeLeave);

    self:refreshPlayerCount();

    self:initVipList();
   	

   	self.m_bEnterMsg = true;
end



--游戏历史记录
function TableLayer:onBRNNSendRecord(message)
	local msg = message._usedata; 

	--天地玄黄赢局数
    self.m_lastAreaWinTb = {};

    --天地玄黄区域
	-- self.m_jettonAreaTagTb ={1,2,4,8}
	local num = table.nums(msg);
	local beginIndex = 1;
	if num > MaxRecordCount then
		beginIndex = num - MaxRecordCount + 1;
	end

	

	local recordTb = {};
    for beginIndex,v in ipairs(msg) do
    	
    	local winTb = {false,false,false,false}
    	for j=1,4 do
    		if bit:_and(self.m_jettonAreaTagTb[j], v.cbWinner) ~= 0 then
    			winTb[j] = true;
    		else
    			winTb[j] = false;
    		end
    	end

    	table.insert(recordTb,winTb);
    	
    end

    local num = table.nums(recordTb);


    if num > MaxRecordCount then
    	for i= num - MaxRecordCount+1 ,num do
    		table.insert(self.m_lastAreaWinTb,recordTb[i]);
    	end
    else
    	self.m_lastAreaWinTb = clone(recordTb);
    end


    -- self.m_recordListLayer:refreshList(self.m_lastAreaWinTb);
    self:refreshList(self.m_lastAreaWinTb);
end


--游戏空闲 消息
function TableLayer:onBRNNGameFree(message)
	luaPrint("TableLayer:onBRNNGameFree ---------------------------------------------------")
	luaDump(message._usedata, "msg_onBRNNGameFree", 5)
	

	local msg = message._usedata; 

	self.m_cbGameStatus = GameMsg.GAME_SCENE_FREE;
	self.m_cbTimeLeave = msg.cbTimeLeave;
	

	self.m_lAllJettonScore = {0,0,0,0,0}
    self.m_lUserJettonScore = {0,0,0,0,0}
    self.m_lUserAllJetton = 0;

    self:resetGameData();

    self:showGameStatus(self.m_cbTimeLeave);

    self:setJettonEnable(false);

    self:refreshApplyBtn();

end


--游戏开始 消息
function TableLayer:onBRNNGameStart(message)

	self:resetGameData();
	--充值VIP
	self:resetAllVipSeat();

	luaDump(message._usedata, "msg_onBRNNGameStart", 5)
	local msg = message._usedata; 

	--游戏开始 设置下注阶段
	self.m_cbGameStatus = GameMsg.GAME_SCENE_JETTON;
    self.m_cbTimeLeave = msg.cbTimeLeave;
    self.m_lUserMaxScore = msg.lUserMaxScore;

    self.m_nBankerTime = msg.nBankerTime; --坐庄次数

    self.m_nLastJetton = 0; --最后下注筹码
    self.m_nLastArea = 0;	--最后下注区域

    -- local userInfo = self.tableLogic:
    local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
    if userInfo then
    	self.m_lSelfScore = userInfo.i64Money;
    	
    else
    	
    end
    
    self.m_wBankerUser = msg.wBankerUser;
    self.m_lBankerScore = msg.lBankerScore;

    self.m_lUserAllJetton = 0;
    self:showGameStatus(self.m_cbTimeLeave);

    self:setJettonEnable(true);
    
    if self:isMeChair(self.m_wBankerUser) then
        self:setJettonEnable(false);
    end


    --是否参加游戏动画进行
    self.m_bEnterGame = true;


    --隐藏下局开始
    self:hideWaitNextTip();

    --更新玩家的金币
    self:updatePlayerCoin();

    self:updateAreaScore(false);
    
    self:resetBankerScore()
 	
    self:updateJettonList();


    --显示游戏开始
    self:showGameStartTip(0.65);

    --显示连庄提示
    self:showRemainBankerTip(self.m_nBankerTime)

    self:refreshApplyBtn();

    self:sendCard(true);

    self.m_bLastJettonDone = false;

    --检测下注围观局数
    self:checklookRoundCount();
end


function TableLayer:filtJetton(msg)
	-- msg.cbJettonServerArea = msg.cbJettonArea;
	-- msg.cbJettonArea = self:getJettonArea(msg.cbJettonArea);
	--msg.lJettonScore
	for i,v in ipairs(TableLayer.m_BTJettonScore) do
		if v == msg.lJettonScore then
			return true
		end
	end


	-- luaDump(msg, "filtJetton--------abc", 5)

	local dValue = msg.lJettonScore;
	local ddValue = math.floor(dValue);
	local jettonCountTb = {0,0,0,0,0,0}

	local jettonMsgTb = {}
	--下注数值
	-- TableLayer.m_BTJettonScore = {1, 10, 50, 100, 500, 1000}
	for i=6,1,-1 do
		local score = TableLayer.m_BTJettonScore[i];
		local count = 0;
		if ddValue >= score then
			count = math.floor(ddValue/(score));
	
			ddValue = ddValue - score*count;
			jettonCountTb[i] = count;	
		end
	end
	
	local tb = {}
	for i,v in ipairs(jettonCountTb) do
		if v > 0 then
			for ii=1,v do
				-- local area_s = self:getJettonAreaS(area_c)
				-- -- self.tableLogic:sendPlaceJetton(TableLayer.m_BTJettonScore[i], area_s);
				-- if recordTb[area_s] == nil then
				-- 	recordTb[area_s] = 0;
				-- end

				-- recordTb[area_s] = recordTb[area_s] + TableLayer.m_BTJettonScore[i]
				local msg2 = {}
				msg2.lJettonScore = TableLayer.m_BTJettonScore[i]
				msg2.cbJettonArea = msg.cbJettonArea
				msg2.id = GameMsg.PLACE_JETTON_ID;
				msg2.wChairID = msg.wChairID;
				msg2.cbJettonServerArea = msg.cbJettonServerArea;
				table.insert(tb,msg2);
				
			end
		end
	end

	-- luaDump(tb, "tb----------abc", 5)
	for i,v in ipairs(tb) do
		if self:isMeChair(v.wChairID) then
			self:showUserJetton(v, true);
		else
			self:pushGameMsg(v);
		end
		
	end

	return false
end

--用户下注 消息
function TableLayer:onBRNNGamePlaceJetton(message)

	local msg = message._usedata; 
	msg.id = GameMsg.PLACE_JETTON_ID;

	msg.cbJettonServerArea = msg.cbJettonArea;
	msg.cbJettonArea = self:getJettonArea(msg.cbJettonArea);
	--更新玩家下注金额
	self:updatePlayerJetton(msg);
	--自己筹码优先绘制
	if self:isMeChair(msg.wChairID) == true then
		if self:filtJetton(msg) then
			-- self:pushGameMsg(msg);
			self:showUserJetton(msg, true);
		end
		
		return
	end


	if self:filtJetton(msg) then
		
		self:pushGameMsg(msg);
		
	end

	

end



function TableLayer:updatePlayerJetton(msg)
	if self:isMeChair(msg.wChairID) == true then
        local oldscore = self.m_lUserJettonScore[msg.cbJettonArea]
        self.m_lUserJettonScore[msg.cbJettonArea] = oldscore + msg.lJettonScore 

        --增加所有下注额度
        self.m_lUserAllJetton = self.m_lUserAllJetton + msg.lJettonScore;
        -- luaPrint("onBRNNGamePlaceJetton_self.m_lUserAllJetton:",self.m_lUserAllJetton);
    
        self.m_lSelfScore = self.m_lSelfScore - msg.lJettonScore;
        self:updatePlayerCoin();

        self:updateJettonList();
        self:setKeepEnable2(true);
    end
    	
    -- luaDump(self.m_lAllJettonScore, "self.m_lAllJettonScore_ongamedeal", 5)
    -- luaDump(msg, "onGameMessageDeal_____msg", 5);
    if self.m_lAllJettonScore ~= nil and type(self.m_lAllJettonScore) == "table" and self.m_lAllJettonScore[msg.cbJettonArea] ~= nil then
    	local oldscore = self.m_lAllJettonScore[msg.cbJettonArea]
	    self.m_lAllJettonScore[msg.cbJettonArea] = oldscore + msg.lJettonScore

	    self:updateAreaScore(true);
	    -- self:showUserJetton(msg,true);
	else
		

    end
end


-----------------------------------------游戏消息处理--------------------


--游戏开始消息
function TableLayer:pushGameMsg(msg)
    -- luaPrint("msg id:",msg.id)
    -- luaDump(msg,'pushGameMsg',6);
    table.insert(self.m_gameMsgArray,#self.m_gameMsgArray + 1,msg);
 
end

--启动消息监听
function TableLayer:startGameMsgRun()
     --帧更新,用来转发消息,消息是在onGameMessageDeal中构建的
     if self.m_msgRunTimeId == -1 then
     	self.m_msgRunTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:update(delta) end, 0.066 ,false);
     end

     -- self.m_msgRunTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:update(delta) end, 0.05 ,false);
    
end

--停止消息监听
function TableLayer:stopGameMsgRun()
    if self.m_msgRunTimeId ~= nil and self.m_msgRunTimeId ~= -1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_msgRunTimeId);
        self.m_msgRunTimeId = -1;
    end
end



--处理游戏消息
function TableLayer:update(delta)
    if self.m_bRunAction then
        return;
    end


    if #self.m_gameMsgArray <=0 then
        return;
    end
    
    local msg = self.m_gameMsgArray[1];
    -- self:onGameMessageDeal(msg);
    self:postMsgDeal(msg);
    --删除动作
    table.remove(self.m_gameMsgArray,1);
end

function TableLayer:postMsgDeal(msg)
    EventMgr:dispatch(Common.EVT_DEAL_MSG,msg);
end

--游戏消息事件
function TableLayer:onDealMsg(event)
    local msg = event._usedata;
    self:onGameMessageDeal(msg);
end


--游戏动作消息处理开关
function TableLayer:onViewMsg(event)
    local iEvent = event._usedata;
    if iEvent == Common.ACTION_BEGIN then --开始处理消息
        self.m_bRunAction = true
    elseif iEvent == Common.ACTION_END then    --处理消息完成
        self.m_bRunAction = false
    end
end



-- 游戏消息处理
function TableLayer:onGameMessageDeal(msg)
    local msgId = msg.id;

    -- luaDump(msg,'onGameMessageDeal',5);
    if msgId == GameMsg.PLACE_JETTON_ID then   --游戏筹码

		-- luaPrint("msg.cbJettonArea---------after:",msg.cbJettonArea)
		-- if self:isMeChair(msg.wChairID) == true then
	 --        local oldscore = self.m_lUserJettonScore[msg.cbJettonArea]
	 --        self.m_lUserJettonScore[msg.cbJettonArea] = oldscore + msg.lJettonScore 

	 --        --增加所有下注额度
	 --        self.m_lUserAllJetton = self.m_lUserAllJetton + msg.lJettonScore;
	 --        -- luaPrint("onBRNNGamePlaceJetton_self.m_lUserAllJetton:",self.m_lUserAllJetton);
	    
	 --        self.m_lSelfScore = self.m_lSelfScore - msg.lJettonScore;
	 --        self:updatePlayerCoin();

	 --        self:updateJettonList();
	 --    end
	    	
	    -- luaDump(self.m_lAllJettonScore, "self.m_lAllJettonScore_ongamedeal", 5)
	    -- luaDump(msg, "onGameMessageDeal_____msg", 5);
	    if self.m_lAllJettonScore ~= nil and type(self.m_lAllJettonScore) == "table" and self.m_lAllJettonScore[msg.cbJettonArea] ~= nil then
	    	-- local oldscore = self.m_lAllJettonScore[msg.cbJettonArea]
		    -- self.m_lAllJettonScore[msg.cbJettonArea] = oldscore + msg.lJettonScore

		    -- self:updateAreaScore(true);
		    self:showUserJetton(msg,true);
		else
			

	    end
	    

    end


end

function TableLayer:putJettonToTable()
	local count = table.nums(self.m_gameMsgArray);
	if count <= 0 then
		return;
	end

	-- for i,msg in ipairs(self.m_gameMsgArray) do
	-- 	self:showUserJetton(msg,false);
	-- 	luaPrint("putJettonToTable----------")
	-- end
	self:packedJetton()
	self.m_gameMsgArray = {}

end


function TableLayer:unPackJettonMsg(msg)
	local dValue = msg.lJettonScore;
	local ddValue = math.floor(dValue);
	local jettonCountTb = {0,0,0,0,0,0}

	local jettonMsgTb = {}
	--下注数值
	-- TableLayer.m_BTJettonScore = {1, 10, 50, 100, 500, 1000}
	for i=6,1,-1 do
		local score = TableLayer.m_BTJettonScore[i];
		local count = 0;
		if ddValue >= score then
			count = math.floor(ddValue/(score));
	
			ddValue = ddValue - score*count;
			jettonCountTb[i] = count;	
		end
	end
	
	local tb = {}
	for i,v in ipairs(jettonCountTb) do
		if v > 0 then
			for ii=1,v do
				local msg2 = {}
				msg2.lJettonScore = TableLayer.m_BTJettonScore[i]
				msg2.cbJettonArea = msg.cbJettonArea
				msg2.id = GameMsg.PLACE_JETTON_ID;
				msg2.wChairID = msg.wChairID;
				msg2.cbJettonServerArea = msg.cbJettonServerArea;
				table.insert(tb,msg2);
				
			end
		end
	end

	return tb;
end


--整合消息队列里的筹码
function TableLayer:packedJetton()
	local jettonList = {}

	-- luaDump(self.m_gameMsgArray, "self.m_gameMsgArray---------abcpackedJetton", 6)

	for i,msg in ipairs(self.m_gameMsgArray) do
		if jettonList[msg.wChairID] == nil then
			jettonList[msg.wChairID] = {}
		end

		if jettonList[msg.wChairID][msg.cbJettonArea] == nil then
			jettonList[msg.wChairID][msg.cbJettonArea] = {}
			jettonList[msg.wChairID][msg.cbJettonArea]["lJettonScore"] = 0;
			jettonList[msg.wChairID][msg.cbJettonArea]["count"] = 0;
		end

		if jettonList[msg.wChairID][msg.cbJettonArea]["count"] < 2 then
			jettonList[msg.wChairID][msg.cbJettonArea]["lJettonScore"] = jettonList[msg.wChairID][msg.cbJettonArea]["lJettonScore"] + msg.lJettonScore;
			jettonList[msg.wChairID][msg.cbJettonArea]["wChairID"] = msg.wChairID;
			jettonList[msg.wChairID][msg.cbJettonArea]["id"] = GameMsg.PLACE_JETTON_ID;
			jettonList[msg.wChairID][msg.cbJettonArea]["cbJettonArea"] = msg.cbJettonArea;
			jettonList[msg.wChairID][msg.cbJettonArea]["count"] = jettonList[msg.wChairID][msg.cbJettonArea]["count"] + 1;
		end
		
	end


	for wChairID,tb in pairs(jettonList) do
		for cbJettonArea,tb2 in pairs(tb) do
				local tb3 = self:unPackJettonMsg(tb2);
				for k,vv in pairs(tb3) do
					self:showUserJetton(vv, false)
				end

		end
	end



end


function TableLayer:initLastRecordJetton()
	self.m_lastChipTb = {}
end

function TableLayer:initNowRecordJetton()
	self.m_nowChipTb = {}
end

function TableLayer:setLastRecordJetton()
	local totalScore = 0;
	for i,v in ipairs(self.m_lUserJettonScore) do
		totalScore = totalScore + v;
	end

	if totalScore > 0 then
		self.m_lastChipTb = self.m_lUserJettonScore;
	else
		-- self.m_lastChipTb = {}
	end
	--玩家自己下注去 天区域
	-- self.m_lastChipTb[1] = msg.lUserTianScore;
	-- --玩家自己下注去 地区域
	-- self.m_lastChipTb[2] = msg.lUserDiScore;
	-- --玩家自己下注去 玄区域
	-- self.m_lastChipTb[3] = msg.lUserXuanScore;
	-- --玩家自己下注去 黄区域
	-- self.m_lastChipTb[4] = msg.lUserHuangScore;
end

--下注记录  下一局续投
function TableLayer:recordJetton(jettonArea,jettonScore)
	if self.m_lastChipTb == nil then
		self.m_lastChipTb = {}
	end
	if self.m_lastChipTb[jettonArea]  == nil then
		self.m_lastChipTb[jettonArea] = 0;

	end
	
	self.m_lastChipTb[jettonArea] = self.m_lastChipTb[jettonArea] + jettonedScore;
end

--发送上一局 下注
function TableLayer:sendLastRecordJetton()
	local recordTb = {
			[1] = 0,
			[2] = 0,
			[4] = 0,
			[8] = 0,
		}

	if self.m_lastChipTb and type(self.m_lastChipTb) == "table" then
		for area_c,dValue in pairs(self.m_lastChipTb) do
			local ddValue = math.floor(dValue);
    		local jettonCountTb = {0,0,0,0,0,0}
    		--下注数值
			-- TableLayer.m_BTJettonScore = {1, 10, 50, 100, 500, 1000}
			for i=6,1,-1 do
				local score = TableLayer.m_BTJettonScore[i];
				local count = 0;
				if ddValue >= score then
        			count = math.floor(ddValue/(score));
        	
        			ddValue = ddValue - score*count;
        			jettonCountTb[i] = count;	
        		end
			end
			
			for i,v in ipairs(jettonCountTb) do
				if v > 0 then
					for ii=1,v do
						local area_s = self:getJettonAreaS(area_c)
						-- self.tableLogic:sendPlaceJetton(TableLayer.m_BTJettonScore[i], area_s);
						if recordTb[area_s] == nil then
							recordTb[area_s] = 0;
						end

						recordTb[area_s] = recordTb[area_s] + TableLayer.m_BTJettonScore[i]
					end
				end
			end
		end
	end
	luaDump(recordTb, "recordTb-----------sendLastRecordJetton", 6)
	self.tableLogic:sendContinuePlaceJetton(recordTb);

end

--check record list
function TableLayer:checkLastRecord()
	local totalScore = self:getLastRecordScore()
	if totalScore > 0 then
		return self.m_lSelfScore >= totalScore;
	else
		return false;
	end
end

--get
function TableLayer:getLastRecordScore()
	if type(self.m_lastChipTb) ~= "table" then
		return 0;
	else
		local totalScore = 0;
		for k,v in pairs(self.m_lastChipTb) do
			totalScore = totalScore + v;
		end
		return totalScore;
	end

	
end


--检测围观局数
function TableLayer:checklookRoundCount()
	--是否是 庄家
	if self:isMeChair(self.m_wBankerUser) == true then
		self.m_look_round = 0;
		return;
	end

	--是否在庄家列表中
	for k,v in pairs(self.m_want_bankerTb) do
		if self:isMeChair(v) == true then
			self.m_look_round = 0;
			return;
		end
	end

	
	if self.m_look_round == 3 then
		self:TipTextShow("您已连续3局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
	elseif self.m_look_round == 4 then
		self:TipTextShow("您已连续4局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
	elseif self.m_look_round >= MAX_LOOK_ROUND then
		self:TipTextShow("您已连续5局未参与游戏，已被请出房间！");

		if self:isMeChair(self.m_wBankerUser) == true then
	    	
    	elseif self.m_lUserAllJetton > 0 then
    		
	    else
	    	self:TipTextShow("您已连续5局未参与游戏，已被请出房间！");
			self:exitClickCallback();
	    end

	end
end

--计算围观局数
function TableLayer:lookRoundCount()
	--是否是 庄家
	if self:isMeChair(self.m_wBankerUser) == true then
		self.m_look_round = 0;
		return;
	end

	--是否在庄家列表中
	for k,v in pairs(self.m_want_bankerTb) do
		if self:isMeChair(v) == true then
			self.m_look_round = 0;
			return;
		end
	end

		
	if self.m_lUserAllJetton <= 0 then
		self.m_look_round = self.m_look_round + 1;
	else
		self.m_look_round = 0;
	end
end



--游戏结束 消息
function TableLayer:onBRNNGameEnd(message)
	luaDump(message._usedata, "msg_onBRNNGameEnd", 5)

	--体验常清除离开提示
	if self.m_lUserAllJetton > 0 then
		GamePromptLayer:remove()
	end

	self:putJettonToTable();

	--recordlast
	self:setLastRecordJetton();

	local msg = message._usedata;

	self.Image_tip:setVisible(false);
	-- 手牌 第一个是 庄家的

	self.m_cbGameStatus = GameMsg.GAME_SCENE_END;
	self.m_cbTimeLeave = msg.cbTimeLeave;


    self.m_cbTableCardArray = self:getSwapTableCards(msg.cbTableCardArray);

	--当前庄家输赢得分
    self.m_lBankerWinScore = msg.lBankerScore
    self.m_lBankerTotallScore = msg.lBankerTotallScore;  --总坐庄局数得分
    -- self.m_nBankerTime = msg.nBankerTime; --坐庄次数

    self.m_lSelfWinScore = msg.lUserScore;
    self.m_lUserReturnScore = msg.lUserReturnScore;
    self.m_lRevenue = msg.lRevenue; --谁赢 扣谁

    --当日总局数
    self.m_allRound = msg.lCount;
    --天地玄黄赢局数
    self.m_areaWinRoundTb = msg.lWinArea;

    --其他玩家得分
    self.m_lOtherWinScore = msg.LOtherScore;


    self.m_WinTime = msg.nWinTime;

    self.m_winUserResult = msg.UserWinScore;
  
    -- self.m_lOccupySeatUserWinScore = msg.lOccupySeatUserWinScore


    -- self.m_lSelfScore = self.m_lSelfScore + self.m_lSelfWinScore;

    -- self.m_lSelfScore = self.m_lUserMaxScore + self.m_lSelfWinScore;

    self:setJettonEnable(false);
    self:showGameStatus(self.m_cbTimeLeave);

    self.m_nLastJetton = 0; --最后下注筹码
    self.m_nLastArea = 0;	--最后下注区域

    self.m_bLastJettonDone = false;

    --统计围观局数
    self:lookRoundCount();

end

--申请庄家 消息
function TableLayer:onBRNNApplyBanker(message)

	--添加申请庄家
	local msg = message._usedata; 
	local wApplyUser = msg.wApplyUser;
	--申请上庄玩家
	self.m_nApplyCount = msg.ApplyCount;
	
	luaDump(msg, "onBRNNApplyBanker-------", 5)
	self:refreshBankerList(msg.ApplyUsers, msg.ApplyCount)

	if self:isMeChair(wApplyUser) then  --
		self.m_enApplyState = APPLY_STATE.kBankerApplyState;
	end

	self:addApplyUser(wApplyUser);


	--刷新上庄列表 状态
	self:refreshApplyList();

	self:refreshApplyBtn();
end

--切换庄家 消息
function TableLayer:onBRNNChangeBanker(message)
	
	local msg = message._usedata; 	
	--申请上庄玩家
	self.m_nApplyCount = msg.ApplyCount;
	--删除上庄申请列表里的玩家
	self:removeApplyUser(msg.wBankerUser);

	luaDump(msg, "onBRNNChangeBanker-------", 5)
	self:refreshBankerList(msg.ApplyUsers, msg.ApplyCount)
  	self.m_nBankerTime = 1 ;
    --自己上庄
    if self:isMeChair(msg.wBankerUser) == true then
        self.m_enApplyState = APPLY_STATE.kBankerState;
    elseif self:isMeChair(self.m_wBankerUser) == true then --上一个庄家是自己
    	self.m_enApplyState = APPLY_STATE.kPlayerState;
    end

    self.m_wBankerUser = msg.wBankerUser;
    self.m_lBankerScore = msg.lBankerScore;


    self:resetBankerInfo();
    self:updateJettonList();

    --刷新做下玩家列表 庄家标志
    self:refreshApplyList();

    self:showChangeBankerTip();

    self:refreshApplyBtn();


    self:removeVipSeat(self.m_wBankerUser);
    self:addNewVipSeat();
end


--取消下庄
function TableLayer:onBRNNCancelQuit(message)
	
	self.m_enApplyState = APPLY_STATE.kBankerState;
	
	self:refreshApplyBtn();



end


--申请下庄成功
function TableLayer:onBRNNCancelQuitSuc(message)
	
	self.m_enApplyState = APPLY_STATE.kBankerQuitState;
	self:refreshApplyBtn();

	
end


--更新积分 消息
function TableLayer:onBRNNChangUserScore(message)
	
	local msg = message._usedata; 
end


--下注失败 消息
function TableLayer:onBRNNPlaceJettonFail(message)
	
	local msg = message._usedata; 

	-- self:TipTextShow("下注失败");




end


--取消申请庄家 或者 下庄 消息
function TableLayer:onBRNNCancelBanker(message)
	luaDump(message._usedata, "msg_onBRNNCancelBanker", 5)
	local msg = message._usedata; 
	local szCancelUser = msg.szCancelUser;
	--申请上庄玩家
	self.m_nApplyCount = msg.ApplyCount;

	if self:isMeChair(szCancelUser) then
		if self:isMeChair(self.m_wBankerUser) then  --下庄状态
			self.m_enApplyState = APPLY_STATE.kBankerQuitState;
		else
			self:removeApplyUser(szCancelUser);	
			self.m_enApplyState = APPLY_STATE.kPlayerState;
		end
	else
		if szCancelUser ~= self.m_wBankerUser then
			self:removeApplyUser(szCancelUser);			
		end		
	end
	
	-- local num = table.nums(self.m_applyBankerList);
	-- self.Text_apply:setString(string.format("申请人数:%d",applyCount));
	self:refreshApplyList();
	self:refreshApplyBtn();

	
	self:refreshBankerList(msg.ApplyUsers, msg.ApplyCount)


end

--庄家坐庄期间输赢金币
function TableLayer:onBRNNDealZhuangScore(message)

  local msg = message._usedata;

  luaDump(msg, "DealZhuangScore--------", 5)

  local BankGet = require("hall.layer.popView.BankGetLayer");

  local layer = self:getChildByName("BankGetLayer");
  if layer then
    layer:removeFromParent();
  end

  local layer = BankGet:create(msg.money);
  self:addChild(layer,999);

end


--最大下注 消息
function TableLayer:onBRNNMaxJetton(message)
	luaDump(message._usedata, "msg_onBRNNMaxJetton---------------------+++++++++++++++++++++", 5)
	local msg = message._usedata; 
	self.m_bMaxJetton = true;
	self.m_cbTimeLeave = msg.cbTimeLeave;
	self.m_cbTimeLeave = 0;
	-- self:TipTextShow("下注已满,提前开牌！");

	--显示下注已满提示图片
	-- self.Image_tip:stopAllActions();
	-- self.Image_tip:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(2.5),cc.Hide:create()));

	self:setJettonEnable(false);
	--下注已满 动画
	self:showEarlyCheckTip();

	self:showGameStatus(self.m_cbTimeLeave+1);



end


--获取庄家列表 消息
function TableLayer:onBRNNGetBanker(message)

	local msg = message._usedata; 

	self.m_applyBankerList = msg.wGetUser;
	
	local num = table.nums(self.m_applyBankerList);


end




--离开的筹码 消息
function TableLayer:onBRNNCancelBet(message)
	
	local msg = message._usedata; 

	local lUserPlaceScore = msg.lUserPlaceScore;
	local lTotalPlaceScore = msg.lTotalPlaceScore;

	for i,v in ipairs(lTotalPlaceScore) do
		self.m_lAllJettonScore[i] = v;
	end

	self:updateAreaScore(true);
end


--续投失败
function TableLayer:onBRNNContinueFail(message)
	luaPrint("onBRNNContinueFail")
	self:TipTextShow("庄家不够赔付。");
end


function TableLayer:clearTimeId()
	if self.m_finishTimeId ~= nil and self.m_finishTimeId ~= -1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_finishTimeId);
        self.m_finishTimeId = -1;
    end

    if self.m_sendCardTimeId ~= nil and self.m_sendCardTimeId ~= -1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_sendCardTimeId);
        self.m_sendCardTimeId = -1;
    end

end

 --进入后台
function TableLayer:refreshEnterBack(data)
	luaPrint("进入后台-----------refreshEnterBack")
	-- self.m_bGameStart = false;
end


 --后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if RoomLogic:isConnect() then
		if device.platform == "windows" then
			
			return;
		end

		-- self:playBgMusic();
		-- globalUnit.isEnterGame = false;

		self:resetGameData();

		-- self:stopAllActions();

		self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
	else
		-- self.m_wBankerUser = -1;
		-- self:exitClickCallback();
	end
end








return TableLayer;
