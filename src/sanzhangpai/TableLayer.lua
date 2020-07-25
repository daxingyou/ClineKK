local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("sanzhangpai.TableLogic");
local CardSprite = require("sanzhangpai.CardSprite");
local CoinView 	 = require("sanzhangpai.CoinView");
local EventMgr   = require("sanzhangpai.EventMgr");
local Common   = require("sanzhangpai.Common");
local HelpLayer = require("sanzhangpai.HelpLayer");
local PopUpLayer = require("sanzhangpai.PopUpLayer");
--区块链
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

local CARD_WIDTH = 115;
local CARD_HEIGHT = 158;
local CARD_SCALE = 0.73;

local TABLE_SELF = 1
local TABLE_RIGHT_DOWN = 2
local TABLE_RIGHT_UP = 3
local TABLE_LEFT_UP = 4
local TABLE_LEFT_DOWN = 5

local TAG_CHECK = 4;
local TAG_FOLD = 5;
local TAG_CARD_KIND = 6;	--牌型
local TAG_CARD_KIND_ANIM = 7; --大牌特效

local CHECK_ROUND = 2;
local COMPARE_ROUND = 2;

local TAG_WIN_ANIM = 100;
local TAG_WIN_WORD = 500;
--赢 动画
local WinAnim ={
		name = "spz_ying",
		json = "sanzhangpai/anim/ying.json",
		atlas = "sanzhangpai/anim/ying.atlas",
}

local WinAnimName = "ying";


local LostAnim ={
		name = "spz_shu",
		json = "sanzhangpai/anim/shu.json",
		atlas = "sanzhangpai/anim/shu.atlas",
}

local LostAnimName = "shu";


local WaitAnim ={
		name = "spz_dengwanjia",
		json = "game/dengdai/dengdai.json",
		atlas = "game/dengdai/dengdai.atlas",
}

local WaitAnimName = "dengwanjia";
local WaitNextAnimName = "dengxiaju";


local VSAnim ={
		name = "spz_vs",
		json = "sanzhangpai/anim/vs.json",
		atlas = "sanzhangpai/anim/vs.atlas",
}

local VSAnimName = "vs";


local DealerAnim = {
		name = "spz_nvheguan",
		json = "sanzhangpai/anim/nvheguan.json",
		atlas = "sanzhangpai/anim/nvheguan.atlas",
}

local DealerAnimName = "nvheguan";


--全局比牌
local FinalFightAnim = {
	name = "spz_quanjubipai",
	json = "sanzhangpai/anim/quanjubipai.json",
	atlas = "sanzhangpai/anim/quanjubipai.atlas",
}

local FinalFightAnimName = "quanjubipai";

--即将开始
local BeginAnim = {
	name = "spz_jijiangkaishi",
	json = "game/jijiangkaishi.json",
	atlas = "game/jijiangkaishi.atlas",
}

local BeginAnimAnimName = "5s";


--赢家动画
local WinnerAnim = {
	name = "spz_dayingjia",
	json = "sanzhangpai/anim/dayingjia.json",
	atlas = "sanzhangpai/anim/dayingjia.atlas",
}

local WinnerAnimName = "dayingjia";


--全下 加注
local AllinAnim = {
		name = "szp_jiazhuquanxia",
		json = "sanzhangpai/anim/jiazhuquanxia.json",
		atlas = "sanzhangpai/anim/jiazhuquanxia.atlas",
}
local AllinAnimName = "quanxia";
local JiazhuAnimName = "jiazhu";


local CardKindTb = {
	[0] = {
		name = "cuowu",	--错误牌型
		name_cn = "错误牌型",
		sound = "",	--音效
		anim = {
				name = "szp_cuowu",
				json = "sanzhangpai/anim/cardkind/cuowu.json",
				atlas = "sanzhangpai/anim/cardkind/cuowu.atlas",
				word = "cuowu",
			},
		image = "sanzhangpai/image/kind/szp_kind_danzhang.png"
	}, 
	[1] = {
		name = "teshu",	--特殊牌型
		name_cn = "特殊牌型",
		sound = "",	--音效
		anim = {
				name = "szp_teshu",
				json = "sanzhangpai/anim/cardkind/teshu.json",
				atlas = "sanzhangpai/anim/cardkind/teshu.atlas",
				word = "teshu",
			},
		image = "sanzhangpai/image/kind/szp_kind_danzhang.png",
	}, 
	[2] = {
		name = "danpai",	--单牌
		name_cn = "单牌",
		sound = "",	--音效
		anim = {
				name = "szp_danpai",
				json = "sanzhangpai/anim/cardkind/danpai.json",
				atlas = "sanzhangpai/anim/cardkind/danpai.atlas",
				word = "danpai",
			},
		image = "sanzhangpai/image/kind/szp_kind_danzhang.png",
	}, 
	[3] = {
		name = "duizi",	--对子
		name_cn = "对子",
		sound = "",	--音效
		anim = {
				name = "szp_duizi",
				json = "sanzhangpai/anim/cardkind/duizi.json",
				atlas = "sanzhangpai/anim/cardkind/duizi.atlas",
				word = "duizi",
			},
		image = "sanzhangpai/image/kind/szp_kind_duizi.png",
	}, 
	[4] = {
		name = "shunzi",	--顺子
		name_cn = "顺子",
		sound = "",	--音效
		anim = {
				name = "szp_shunzi",
				json = "sanzhangpai/anim/cardkind/shunzi.json",
				atlas = "sanzhangpai/anim/cardkind/shunzi.atlas",
				word = "shunzi",
			},
		image = "sanzhangpai/image/kind/szp_kind_sunzi.png",
	},
	[5] = {
		name = "tonghua",	--同花
		name_cn = "同花",
		sound = "",	--音效
		anim = {
				name = "szp_tonghua",
				json = "sanzhangpai/anim/cardkind/tonghua.json",
				atlas = "sanzhangpai/anim/cardkind/tonghua.atlas",
				word = "tonghua",
			},
		image = "sanzhangpai/image/kind/szp_kind_tonghua.png",
	},
	[6] = {
		name = "tonghuahun",	--同花顺
		name_cn = "同花顺",
		sound = "",	--音效
		anim = {
				name = "szp_tonghuashun",
				json = "sanzhangpai/anim/cardkind/tonghuashun.json",
				atlas = "sanzhangpai/anim/cardkind/tonghuashun.atlas",
				word = "tonghuashun",
			},
		image = "sanzhangpai/image/kind/szp_kind_tonghuasun.png",
	},

	[7] = {
		name = "santiao",	--三条
		name_cn = "三条",
		sound = "",	--音效
		anim = {
				name = "szp_baozi",
				json = "sanzhangpai/anim/cardkind/baozi.json",
				atlas = "sanzhangpai/anim/cardkind/baozi.atlas",
				word = "baozi",
			},
		image = "sanzhangpai/image/kind/szp_kind_baozi.png",
	},
	
}
--牌型特效
local CardKind_Santiao = {
	name = "szp_baozi",
	json = "sanzhangpai/anim/cardkind/baozi.json",
	atlas = "sanzhangpai/anim/baozi.atlas",
	anim = "baozi",
}

















--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	luaPrint("uNameId, bDeskIndex, bAutoCreate, bMaster",uNameId, bDeskIndex, bAutoCreate, bMaster)
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



	-- luaPrint("TableLayer:create__________________1");

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

	if GameMsg ~= nil then
		GameMsg.init();
	end
	SZPInfo:init();

	--获取ui
	local uiTable = {
		Image_bg        =   "Image_bg",
		Panel_menu 		= 	"1",	--菜单栏
		Button_exit 	=	"1",	--返回按钮
		Button_help		=	"1",	--帮助
		Button_sound	=	"1",	--音效

		Panel_tableInfo		=	"1",	--桌子信息层
		Image_jettonTotal	=	"1",	--桌子总下注背景
		Text_jettonTotal	=	"1",	--桌子总下注
		Image_tableInfo		=	"1",	--桌子信息背景图
		Text_baseJetton		=	"1",	--底注
		Text_singleJetton	=	"1",	--单注
		Text_round			=	"1",	--轮数

		Panel_chip			=	"1",	--下注区域
		Panel_chipArea		=	"1",	--下注区域

		Panel_cards			=	"1",	--牌层

		Panel_player		=	"1",	--玩家层

		Panel_message		=	"1",	--动作消息层

		Panel_operate		=	"1",	--操作层
		Button_auto			=	"1",	--跟到底
		Button_unAuto		=	"1",	--取消跟到底
		Button_fold			=	"1",	--弃牌
		Button_compare		=	"1",	--比牌
		Button_check		=	"1",	--看牌
		Button_raise		=	"1",	--加注
		Button_bet			=	"1",	--下注
		Button_follow		=	"1",	--跟注
		Button_allIn		=	"1",	--全下
		Button_eveal		=	"1",	--亮牌

		Panel_raise			=	"1",	--加注面板


		Panel_select		=	"1",	--比牌层
		Image_selectTipBg	=	"1",	--比牌提示背景图
		Image_selectTip		=	"1",	--比牌提示文字

		Panel_result		=	"1",	--结算显示层

		Panel_box = "1",	--菜单层
		Panel_boxList  = "1",  --菜单裁剪层
		Image_boxBg = "1",	--菜单背景图
		Button_effect = "1", --音效
		Button_music = "1", --音乐



		Panel_tip			=	"1",	--提示层
		Image_tipWaitBg		=	"1",	--游戏即将开始
		Image_tipWaitNext	=	"1",	--请等待下一局

		Image_chip			=	"1",	--筹码cell

		Image_dealer 		=	"1",	--荷官

		Panel_ready			=	"1",	--准备面板
		Button_ready		=	"1",	--准备按钮

		Panel_anims 		=	"1",	--动画层
		Panel_compare		=	"1",	--比牌层
		Image_foldCell		=	"1",	--弃牌

		Panel_continue		=	"1",	--玩家不操作 结算提示层
		Button_continue		=	"1",	--继续
		Button_leave		=	"1",	--离开

		Panel_countdown		=	"1",	--倒计时拦截层
	}

	
	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end

	--适配
	uiTable["Button_exit"] = {"Button_exit",0,1};
	uiTable["Button_help"] = {"Button_help",1};
	uiTable["Button_sound"] = {"Button_sound",1};
	uiTable["Panel_boxList"] = {"Panel_boxList",1};
	--Panel_boxList

	luaDump(uiTable,"uiTable------------1")

	-- 游戏内消息处理
	luaPrint("TableLayer:initUI---------------")
	loadNewCsb(self,"sanzhangpai/tablelayer",uiTable)
	self:initData();
	-- self:initUI();
	-- self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	-- self.tableLogic:enterGame();

	_instance = self;
end

--进入
function TableLayer:onEnter()
	self:addPlist();

	self:initUI()

	
	self:startGameMsgRun();
	EventMgr:registListener(Common.EVT_VIEW_MSG,self,self.onViewMsg);
    EventMgr:registListener(Common.EVT_DEAL_MSG,self,self.onDealMsg);

    PLAY_COUNT = 5;
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();


	self:bindEvent();--绑定消息
	

	luaPrint("self.m_iMuiscVolume:",self.m_iMuiscVolume);
	if self.m_bMusicOn then
		 local index = math.random(1,1000);
		 luaPrint("bg_sound_index:",index);
		 if index%2 == 0 then
		 	playMusic("sanzhangpai/sound/bgm01.mp3", true); 
		 else
			playMusic("sanzhangpai/sound/bgm02.mp3", true); 	
		 end
	end

	self.super.onEnter(self);

	
end

function TableLayer:addPlist()
	display.loadSpriteFrames("sanzhangpai/image/img_szp.plist","sanzhangpai/image/img_szp.png");
	display.loadSpriteFrames("sanzhangpai/image/szp_card.plist","sanzhangpai/image/szp_card.png");
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("sanzhangpai/image/img_szp.plist");
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("sanzhangpai/image/szp_card.plist");
end

--进入结束
function TableLayer:onEnterTransitionFinish()
	self.super.onEnterTransitionFinish(self)
end



--退出
function TableLayer:onExit()

	-- self.tableLogic:sendUserUp();
    -- self.tableLogic:sendForceQuit();

	-- globalUnit.isEnterGame = false;
	
	-- if self.contactListener then
    --     local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
    --     eventDispathcher:removeEventListener(self.contactListener);
    --     self.contactListener = nil;
    -- end
    luaPrint("stopGameMsgRun-----------------")

    EventMgr:unregistListener(Common.EVT_VIEW_MSG,self,self.onViewMsg);
    EventMgr:unregistListener(Common.EVT_DEAL_MSG,self,self.onDealMsg);
    self:stopGameMsgRun();

    -- self:leaveDesk();

    self.super.onExit(self);


end

--初始化界面
function TableLayer:initUI()
	--返回按钮
	self.Button_exit:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_exit:setName("Button_exit");

	self.Button_help:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_help:setName("Button_help");

	self.Button_sound:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_sound:setName("Button_sound");

	self.Button_help:setPositionX(self.Button_help:getPositionX() - 20);
	self.Button_sound:setPositionX(self.Button_sound:getPositionX() - 20);


	--桌子总下注
	self.Text_jettonTotal:setString(tostring(0));
	--底注
	self.Text_baseJetton:setString(tostring(0));
	--单注
	self.Text_singleJetton:setString(tostring(0));
	--轮数	
	self.Text_round:setString("0/0");

	--筹码层
	self.m_coinView  = CoinView:create();
	self.m_coinView:setChipImage(self.Image_chip);
	self.Panel_chip:addChild(self.m_coinView);
	self.m_coinView:setPosition(cc.p(0,0));
	self.m_coinView:setRect(cc.rect(self.Panel_chipArea:getPositionX(),self.Panel_chipArea:getPositionY(),self.Panel_chipArea:getContentSize().width,self.Panel_chipArea:getContentSize().height))

	--初始化发牌位置
	self.m_posCardTb = {};
	self.m_posCardKindTb = {};	--牌型提示
	self.m_posCardKindAnimTb = {};	--牌型特效
	for i=1,5 do
		local gap = 33;
		local width = 84;
		local height = 73;
		if i == 1 then
			width = 115;
			height = 158;
			gap = 50;
		end

		--玩家自己的发牌位置
		local posTb = {};
		local panel_card = self.Panel_cards:getChildByName(string.format("Panel_cards%d",i));
		local pos_b = cc.p(panel_card:getPosition());
		for j=1,3 do
			local index = j - 1;
			local pos = cc.p(pos_b.x+gap*index+width*0.5,pos_b.y+height*0.5);
			table.insert(posTb,pos);
		end
		local index = i - 1;
		self.m_posCardTb[index] = posTb;

		--牌型位置
		local pSize = panel_card:getContentSize();

		local posCardKindAnim = cc.p(0,0);
		local posCardKind = cc.p(0,0);
		if index == 0 then	--自己
			posCardKindAnim = cc.p(pos_b.x + pSize.width + 80,pos_b.y+90);

			posCardKind = cc.p(pos_b.x + pSize.width*0.5,pos_b.y+30);
		elseif index == 1 then	--右下
		  	posCardKindAnim = cc.p(pos_b.x - 50,pos_b.y+ 40);

		  	posCardKind = cc.p(pos_b.x + pSize.width*0.5,pos_b.y+15);
		elseif index == 2 then	--右上
			posCardKindAnim = cc.p(pos_b.x - 40,pos_b.y+ 40);

			posCardKind = cc.p(pos_b.x + pSize.width*0.5,pos_b.y+15);
		elseif index == 3 then	--左上  
			posCardKindAnim = cc.p(pos_b.x + pSize.width + 40,pos_b.y+25);

			posCardKind = cc.p(pos_b.x + pSize.width*0.5,pos_b.y+15);

		elseif index == 4 then	--左下
			posCardKindAnim = cc.p(pos_b.x + pSize.width + 50,pos_b.y+40);

			posCardKind = cc.p(pos_b.x + pSize.width*0.5,pos_b.y+15);
		end

		self.m_posCardKindTb[index] = posCardKind;
		self.m_posCardKindAnimTb[index] = posCardKindAnim;
		



		-- table.insert(self.m_posCardKindTb,posKind);
	end
	-- luaDump(self.m_posCardTb, "card_pos_tb--------------1", 6);
	self.Panel_cards:removeAllChildren();

	--玩家头像UI
	self.Panel_PlayerTb = {};	--玩家头像框
	self.Image_headTb = {};		--玩家头像
	self.Text_nameTb = {};		--玩家姓名
	self.Image_coinTb = {};		--玩家金币ICON
	self.Text_coinTb = {};		--玩家金币
	self.Image_progressTb = {};	--玩家倒计时
	self.Image_lightTb = {};	--玩家倒计时亮光
	self.Image_bankerTb = {};	--玩家庄家标志
	self.Image_chipBannerTb = {};	--玩家下注背景图
	self.Text_chipTb = {};	--玩家下注数值
	self.Progerss_timerTb = {}; --倒计时
	for i=1,5 do
		local index = i-1;
		local panel = self.Panel_player:getChildByName(string.format("Panel_player%d",i));
		self.Panel_PlayerTb[index] = panel;
		self.Image_headTb[index] = panel:getChildByName("Image_head");
		self.Image_headTb[index]:ignoreContentAdaptWithSize(true);

		self.Text_nameTb[index] = panel:getChildByName("Text_name");
		
		self.Image_coinTb[index] = panel:getChildByName("Image_coin");
		self.Text_coinTb[index] = panel:getChildByName("Text_coin");
		self.Image_progressTb[index] = panel:getChildByName("Image_progress");
		self.Image_lightTb[index] = self.Image_progressTb[index]:getChildByName("Image_light");		
		self.Image_bankerTb[index] = panel:getChildByName("Image_banker");
		self.Image_chipBannerTb[index] = panel:getChildByName("Image_chipBanner");
		self.Text_chipTb[index] = panel:getChildByName("Image_chipBanner"):getChildByName("Text_chip");

		--玩家倒计时
		self.Progerss_timerTb[index] = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("szp_daojishi.png"));
		self.Progerss_timerTb[index]:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    self.Progerss_timerTb[index]:setReverseDirection(true)
	    self.Image_progressTb[index]:getParent():addChild(self.Progerss_timerTb[index])
	    self.Progerss_timerTb[index]:setPosition(self.Image_progressTb[index]:getPositionX(),self.Image_progressTb[index]:getPositionY())

		self.Panel_PlayerTb[index]:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		self.Panel_PlayerTb[index]:setName("Panel_head");
		self.Panel_PlayerTb[index]:setTag(index);
		self.Image_headTb[index]:setVisible(false);
		self.Text_nameTb[index]:setString("");
		self.Image_coinTb[index]:setVisible(false);
		self.Text_coinTb[index]:setString("");
		self.Image_progressTb[index]:setVisible(false);
		self.Image_lightTb[index]:setVisible(false);
		self.Image_bankerTb[index]:setVisible(false);
		self.Image_chipBannerTb[index]:setVisible(false);
		self.Text_chipTb[index]:setString("0");

		self.Image_coinTb[index]:setPosition(cc.p(15.5,21))
		self.Text_coinTb[index]:setPosition(cc.p(27,18))


	end

	--玩家弃牌 看牌 操作提醒
	self.Panel_speakTb = {};
	self.Image_speakTb = {};
	for i=1,5 do
		local index = i-1;
		local panel = self.Panel_message:getChildByName(string.format("Panel_speaker%d",i));
		self.Panel_speakTb[index] = panel;
		self.Image_speakTb[index] = panel:getChildByName("Image_speak");
		self.Panel_speakTb[index]:setVisible(false);
		self.Image_speakTb[index]:setPosition(cc.p(88,-54));
	end


	--玩家自己操作按钮  下注 跟注 弃牌 看牌
	--跟到底
	self.Button_auto:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_auto:setName("Button_auto");
	self.Button_auto:setEnabled(false);
	
	--跟到底 取消
	self.Button_unAuto:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_unAuto:setName("Button_unAuto");
	self.Button_unAuto:setEnabled(false);
	
	--弃牌
	self.Button_fold:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_fold:setName("Button_fold");
	self.Button_fold:setEnabled(false);
	
	--比牌
	self.Button_compare:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_compare:setName("Button_compare");
	self.Button_compare:setEnabled(false);
	
	--看牌
	self.Button_check:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_check:setName("Button_check");
	self.Button_check:setEnabled(false);
	
	--加注
	self.Button_raise:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_raise:setName("Button_raise");
	self.Button_raise:setEnabled(false);
	
	--下注
	self.Button_bet:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_bet:setName("Button_bet");
	self.Button_bet:setEnabled(false);
	
	--跟注
	self.Button_follow:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_follow:setName("Button_follow");
	self.Button_follow:setEnabled(false);
	
	self.Button_follow:setVisible(false);
	--全下ALL IN
	self.Button_allIn:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_allIn:setName("Button_allIn");
	self.Button_allIn:setEnabled(false);
	
	self.Button_allIn:setVisible(false);

	--亮牌
	self.Button_eveal:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_eveal:setName("Button_eveal");
	self.Button_eveal:setVisible(false);

	--加注界面
	self.Panel_raise:setVisible(false);
	self.Panel_raise:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_raise:setName("Panel_raise");
	self.Panel_raise:setEnabled(true);
	--加注按钮集合
	self.Button_raiseTb = {};
	self.Text_jettonTb = {};
	for i=1,5 do
		local button = self.Panel_raise:getChildByName("Image_raiseBg"):getChildByName(string.format("Button_raise%d",i));
		button:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		button:setName("Button_raiseBet");
		-- button:setName(string.format("Button_raiseBet%d",i));
		button:setEnabled(true);
		self.Button_raiseTb[i] = button;
		self.Text_jettonTb[i] = button:getChildByName("Text_chip");
		self.Text_jettonTb[i]:setString(tostring(0));
	end

	--比牌界面
	self.Panel_select:setVisible(false);
	self.Panel_select:setVisible(false);
	self.Panel_select:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_select:setName("Panel_select");

	self.Panel_areaTb = {};
	self.Image_arrowTb = {};
	for i=1,5 do
		local index = i-1;
		local image = self.Panel_select:getChildByName(string.format("Image_arrow%d",i));
		self.Image_arrowTb[index] = image;
		self.Image_arrowTb[index]:setVisible(false);
		self.m_ArrowPosTb[index] = cc.p(self.Image_arrowTb[index]:getPosition());

		--比牌选择玩家层
		local panel = self.Panel_select:getChildByName(string.format("Panel_area%d",i));
		panel:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		panel:setName("Panel_area");
		panel:setTag(index);
		self.Panel_areaTb[index] = panel;

	end
	--比牌提示背景
	self.Image_selectTipBg:setVisible(false);

	--结算层
	self.Panel_result:setVisible(false);

	--提示层
	self.Panel_tip:setVisible(false);
	--提示游戏即将开始
	self.Image_tipWaitBg:setVisible(false);
	--提示等待下一局
	self.Image_tipWaitNext:setVisible(false);

	--比牌动画层
	self.Panel_compare:setVisible(false);
	--准备层
	self.Image_readyTb = {};
	self.Button_ready:setVisible(false);
	self.Button_ready:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_ready:setName("Button_ready");
	for i=1,5 do
		local index = i - 1;
		local image = self.Panel_ready:getChildByName(string.format("Image_ready%d",i));
		image:setVisible(false);
		self.Image_readyTb[index] = image;
	end

	--弃牌图片
	self.Image_foldCell:setVisible(false);

	

	
	--卡牌数组
	self.m_CardsTb = {};

	-- --初始化输赢的位置
	-- for i=1,5 do
	-- 	local index = i-1;
	-- 	local text = self.Text_nameTb[index];
	-- 	local parent = text:getParent();
	-- 	local pos = cc.p(text:getPosition());
	-- 	local worldPos =  parent:convertToWorldSpace(pos);
	-- 	self.m_ReulstPosTb[index] = cc.p(worldPos.x,worldPos.y+20);
	-- end


	--初始化大赢家位置
	for i=1,5 do
		local index = i-1;
		local pos = cc.p(self.Panel_PlayerTb[index]:getPosition());
		self.m_WinnerPosTb[index] = pos;
	end

	--初始化输赢的位置
	for k,pos in pairs(self.m_WinnerPosTb) do
		self.m_ReulstPosTb[k] = cc.p(pos.x,pos.y+70);
	end



	--荷官动画
	local pos_dealer = cc.p(self.Image_dealer:getPosition());


	local DealerAnim = {
		name = "spz_nvheguan",
		json = "sanzhangpai/anim/nvheguan.json",
		atlas = "sanzhangpai/anim/nvheguan.atlas",
	}

	local DealerAnimName = "nvheguan";

	local skeleton_animation = createSkeletonAnimation(DealerAnim.name,DealerAnim.json,DealerAnim.atlas);
	if skeleton_animation then
		skeleton_animation:setAnimation(0,DealerAnimName, true);
		self.Panel_tableInfo:addChild(skeleton_animation);
		skeleton_animation:setPosition(pos_dealer);
		skeleton_animation:setName("Skeleton_dealer");
	end
	
	self.Image_dealer:setVisible(false);


	--菜单盒
	--增加战绩
	if globalUnit.isShowZJ then
		self.Button_sound:loadTextures("sanzhangpai/image/zhanji/gengduo-niuniu.png","sanzhangpai/image/zhanji/gengduo-niuniu-on.png","sanzhangpai/image/zhanji/gengduo-niuniu-on.png")
		local size = self.Panel_boxList:getContentSize();
		self.Image_boxBg:ignoreContentAdaptWithSize(true);
		self.Image_boxBg:loadTexture("sanzhangpai/image/zhanji/bg3.png");
		local imgSize = self.Image_boxBg:getContentSize();
		local pap = imgSize.height - size.height;
		self.Panel_boxList:setPositionY(self.Panel_boxList:getPositionY() - pap)
		self.Image_boxBg:setPosition(cc.p(imgSize.width*0.5,imgSize.height*0.5));

		self.Button_zhanji = ccui.Button:create("sanzhangpai/image/zhanji/zhanji_zhanji.png","sanzhangpai/image/zhanji/zhanji_zhanji-on.png","sanzhangpai/image/zhanji/zhanji_zhanji-on.png");
		self.Image_boxBg:addChild(self.Button_zhanji);
		self.Button_zhanji:setPosition(cc.p(self.Button_effect:getPositionX(),self.Button_effect:getPositionY()))
		self.Button_zhanji:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		self.Button_zhanji:setName("Button_zhanji");

		self.Button_effect:setPosition(cc.p(self.Button_music:getPositionX(),self.Button_music:getPositionY()))
		local pp = self.Button_music:getPositionY() - self.Button_zhanji:getPositionY()
		self.Button_music:setPosition(cc.p(self.Button_music:getPositionX(),self.Button_effect:getPositionY() +pp ))


		self.m_logBar = LogBar:create(self);
		self.Button_exit:addChild(self.m_logBar);
	end

	self.Panel_boxList:setVisible(false);
	




	--音效
	self.Button_effect:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_effect:setName("Button_effect");
	--音乐
	self.Button_music:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_music:setName("Button_music");

	self.m_bEffectOn = getEffectIsPlay();
	self.m_bMusicOn = getMusicIsPlay();

	if self.m_bEffectOn then
		self.Button_effect:loadTextures("szp_yinxiao1.png", "szp_yinxiao-on.png","", UI_TEX_TYPE_PLIST);
	else
		self.Button_effect:loadTextures("szp_yinxiao2.png", "szp_yinxiao2-on.png","", UI_TEX_TYPE_PLIST);
	end

	if self.m_bMusicOn then
		self.Button_music:loadTextures("szp_yinyue.png", "szp_yinyue-on.png","", UI_TEX_TYPE_PLIST);
	else
		self.Button_music:loadTextures("szp_yinyue2.png", "szp_yinyue2-on.png","", UI_TEX_TYPE_PLIST);
	end


	self.Panel_continue:setVisible(false);
	--继续
	self.Button_continue:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_continue:setName("Button_continue");
	--离开
	self.Button_leave:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_leave:setName("Button_leave");


	--玩家头像位置
	self.m_headPosTb = {}
	for i=1,5 do
		local index = i - 1;
		-- local pos = self.Image_headTb[index]:getParent():convertToWorldSpace(cc.p(self.Image_headTb[index]:getPosition()));
		local pos = cc.p(self.Panel_PlayerTb[index]:getPosition());
		self.m_headPosTb[index] = pos;
	end

	--倒计时层
	self.Panel_countdown:setVisible(false);


	--区块链bar
	self.m_qklBar = Bar:create("sanzhangpai",self);
	self.Button_sound:addChild(self.m_qklBar);
	self.m_qklBar:setPosition(cc.p(36,-80));

	self.Button_leave:setVisible(false)
	self.Button_continue:setPositionY(self.Button_continue:getPositionY()+50)
	self.Button_continue:setPositionX(self.Button_continue:getPositionX() -  (self.Button_continue:getPositionX()/2 - self.Button_leave:getPositionX()/2))
end



--绑定消息
function TableLayer:bindEvent()
	self:pushEventInfo(SZPInfo, "SZPBeginUpgrade", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPSendCard", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPGamePlay", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPNoteResult", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPNote", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPLookCard", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPContinueEnd", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPBipaiResult", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPMingCard", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPFinishCompare", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPBipaiReq", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPOpponentCard", handler(self, self.onSZPGameMsg));
	self:pushEventInfo(SZPInfo, "SZPAutoFollow", handler(self, self.onSZPGameMsg));

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
	--SZPBipaiResult
	-- SZPMingCard
	--SZPFinishCompare
	--SZPBipaiReq
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

function TableLayer:backPlatform()
	Hall:exitGame();
end


function TableLayer:updateCheckNet()
end

function TableLayer:gameNetHeart()
end

function TableLayer:onGameDisconnect(callback)
	
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

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

	if userInfo then
		--//逻辑位置
		if bSeatNo < PLAY_COUNT then
			if userInfo then
				local tempInfo = {};
				--//名字中有 \' 这个符号，对本地数据库保存有影响，所以需要替换
				for k,v in pairs(userInfo) do
					tempInfo[k] = v;
					if k == "nickName" then
						tempInfo.nickName = string.gsub(v,'\'',' ');
					elseif k == "dwUserID" then
						tempInfo.bDestion = v;
					elseif k == "bBoy" then
						if v == true then
							tempInfo._sex = 1;
						else
							tempInfo._sex = 0;	
						end
					elseif k == "dwUserIP" then
						tempInfo._dwIP = v;
					end
				end
				self.playerInfo[deskStation] = tempInfo;
			end
		end
	end

	
	-- luaDump(self.playerInfo, "-------addUser self.playerInfo-----------", 3)
end

function TableLayer:removeUser(vSeatNo, bIsMe,bLock)
	luaPrint("removeUser:",vSeatNo,bIsMe);
	local vSeat = vSeatNo; 
	-- self:leaveUser(vSeatNo, bIsMe)
	if bIsMe then
		local str = ""
		if bLock == 0 then
			-- str ="长时间未操作,自动退出游戏。"
		elseif bLock == 1 then
			str ="您的金币不足,自动退出游戏。"

			if self.m_bEffectOn then
	            playEffect("sanzhangpai/sound/poor.mp3", false);
	        end

	        local ziSpine = createSkeletonAnimation("pukemiaosha","game/gameEffect/pukemiaosha.json","game/gameEffect/pukemiaosha.atlas");
			if ziSpine then
				ziSpine:setPosition(640,360);
				ziSpine:setAnimation(1,"miaosha_zhajinhua", false);
				ziSpine:setName("ziSpine");
				self.Image_bg:addChild(ziSpine,10);
				ziSpine:runAction(cc.Sequence:create(cc.DelayTime:create(3.5),cc.CallFunc:create(function()
					--self:onClickExitGameCallBack(5);
				end)));
			end
			return;
		elseif bLock == 2 then
			str ="您被厅主踢出VIP厅,自动退出游戏。"
		elseif bLock == 3 then
			str ="长时间未操作,自动退出游戏。"
		elseif bLock == 5 then
			str ="VIP房间已关闭,自动退出游戏。"
		end
		if str ~="" then
			addScrollMessage(str)
		end
		--self:onClickExitGameCallBack(5);
		return;
	end

	luaPrint("TableLayer leaveUser------------++++++++++++ vSeat:",vSeat)
	if not self:checkViewSeat(vSeat) then
		luaPrint("vSeat is error:",vSeat)
		return;
	end


	self.m_iPlayerStatusTb[vSeat] = Common.STATUS_IDLE;
	self.m_SeatDownTb[vSeat] = false;
	self.Image_headTb[vSeat]:setVisible(false);
	self.Text_nameTb[vSeat]:setString("");
	self.Image_coinTb[vSeat]:setVisible(false);
	self.Text_coinTb[vSeat]:setString("");
	self.Image_progressTb[vSeat]:setVisible(false);
	self.Image_lightTb[vSeat]:setVisible(false);
	self.Image_bankerTb[vSeat]:setVisible(false);
	self.Image_chipBannerTb[vSeat]:setVisible(false);
	self.Text_chipTb[vSeat]:setString("");
	self.m_lPlayerCoin[vSeat] = 0;
	--玩家离开 牌型保留
	-- self:removeSeatCard(vSeat);
	self:setPlayerGray(vSeat, false);
	self.Image_readyTb[vSeat]:setVisible(false);
	self:removeSeatAnim(vSeat);
	self:showWaitingTip();

	

end

function TableLayer:leaveDesk(source)
	print("leaveDeskleaveDesk",source)
	globalUnit.isEnterGame = false;

	if self.contactListener then
		local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
		eventDispathcher:removeEventListener(self.contactListener);
		self.contactListener = nil;
	end

	self.tableLogic:stop();

	self:stopAllActions();
	if source == nil then
		if globalUnit.nowTingId == 0 then
			globalUnit.isEnterGame = false;
			performWithDelay(display.getRunningScene(), function() RoomLogic:close(); end,0.5);
		end
	end
	_instance = nil;
end

function TableLayer:leaveDesk(source)
    print("leaveDeskleaveDesk",source,globalUnit.nowTingId)
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

function TableLayer:leaveDeskSsz(source)
    luaPrint("leaveDeskSzz",self._bLeaveDesk)
    if not self._bLeaveDesk then
        self._bLeaveDesk = true;

    end

    -- globalUnit.isEnterGame = false;
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
	luaPrint("globalUnit.m_gameConnectState="..globalUnit.m_gameConnectState)
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


function TableLayer:UpdateUserList()
	luaPrint("TableLayer:UpdateUserList----------------")

end


-------------------------------------------------------------------------------------
--初始化数据
function TableLayer:initData()
	--old begin
	self.playerInfo = {};
	--old end


	--底注
	self.m_lBaseChip = 0;	
	--单注
	self.m_lSingleChip = 0;
	--轮数
	self.m_iNowRound = 0;
	--最大轮数
	self.m_iMaxRound = 20;
	--庄家座位
	self.m_wBankerSeat = 0;
	--玩家下注
	self.m_lPlayerChipTb = {0,0,0,0};
	self.m_lPlayerChipTb[0] = 0;
	--玩家当前金币
	self.m_lPlayerCoin = {0,0,0,0,};
	self.m_lPlayerCoin[0] = 0;
	--当前桌子总下注
	self.m_lTotalChip = 0;
	--当前轮到谁说话
	self.m_wTurnSeat = 0;
	--每个玩家的当前状态
	self.m_iPlayerStatusTb = {0,0,0,0};
	self.m_iPlayerStatusTb[0] = Common.STATUS_IDLE;
	--每个玩家是否看牌
	self.m_bPlayerCheckedTb = {false,false,false,false}
	self.m_bPlayerCheckedTb[0] = false;
	--每个玩家是否看牌
	self.m_bPlayerFoldedTb = {false,false,false,false}
	self.m_bPlayerFoldedTb[0] = false;
	--是否比牌输
	self.m_bPlayerLostTb = {false,false,false,false}
	self.m_bPlayerLostTb[0] = false;

	--玩家自己是否跟到底状态
	self.m_bAutoBet = false;
	--当前场次下注最大注数
	self.m_lLimitChip = 0;
	--当前操作剩余时间
	self.m_iLeftTime = 0;
	--桌子状态
	self.m_cbGameStatus = 0;
	--下注配置
	self.m_iRaseChipTb = {10,20,40,100,200}

	--牌桌剩余牌数
	self.m_iLeftCardCount = 0;
	--玩家操作时间
	self.m_nDealTime = 15;
	
	--是否消息处理中
    self.m_bRunAction = false;

    --游戏消息队列
    self.m_gameMsgArray = {};
    --消息处理ID
    self.m_msgRunTimeId = -1;
    --房间等级
    self.m_nRoomLevel = 1;
    --房间筹码配置
    self.m_nBetConfigTb = Common.BetTb[self.m_nRoomLevel];
    --当前房间最大筹码
    self.m_nMaxBet = 10;
    
    --当前游戏中的玩家
    self.m_playSeatTb = {0,0,0,0};
    self.m_playSeatTb[0] = 0;
    --是否首先出牌的玩家
    self.m_bFirstBetSeat = false;
    --玩家当前牌桌状态
    self.m_iSelfStatus = Common.STATUS_IDLE;
    --玩家是否看牌
    self.m_bChecked = false;
    --玩家是否弃牌
    self.m_bFolded = false;
    --玩家是否比牌输
    self.m_bLosted = false;
    --玩家手牌
    self.m_HandCardTb = {0,0,0};
    --所有玩家手牌
    self.m_AllHandCardTb = {};

    --玩家播放输赢的位置
    self.m_ReulstPosTb = {};
    --大赢家输赢的位置
    self.m_WinnerPosTb = {};
    --玩家得分播放的位置
    self.m_WinCoinPosTb = {cc.p(1170,210),cc.p(860,580),cc.p(420,580),cc.p(120,210)};
    self.m_WinCoinPosTb[0] = cc.p(890,250);

    --比牌头像位置
    self.m_LeftCompPos = cc.p(430,336+77);
    self.m_RightCompPos = cc.p(836,270+77);

    --选择箭头位置
    self.m_ArrowPosTb = {};

    --当前是否到玩家操作
    self.m_bSelfTurning = false;

    self.level_rases = {};

    --比牌时间10秒
    self.m_nCompTime = 10;
    --玩家当前金币
    self.m_lSelfScore = 0;
    --是否进入房间
    self.m_bEnterGame = false;
    --牌桌状态 空闲
    self.m_iTableStatus = Common.STATUS_IDLE;

    --是否游戏未操作
    self.m_bGiveUp = false;

    --超时退出房间
    self.m_bOutTime = false;

    --是否未离开
    self.m_SeatDownTb = {false,false,false,false};
    self.m_SeatDownTb[0] = false;


    --玩家手牌
    self.m_playerCardTb = {};

    --是否只能跟注
    self.m_bOnlyFollow = false; --最后一轮 最后一个玩家只能跟注

end









--============================================三张牌交互======================================================
function TableLayer:autoSendReady(dt)
	if dt == nil then
		dt = 1.0
	end

	self.Button_ready:stopAllActions();
	self.Button_ready:setVisible(false);

	local delayIt = cc.DelayTime:create(dt);
	local autoFunc = cc.CallFunc:create(
			function (sender)
					self.tableLogic:sendMsgReady();
			end
		);
	self.Button_ready:runAction(cc.Sequence:create(delayIt,autoFunc));


end

--载入座位玩家
function TableLayer:loadUser(vSeat,bIsMe)
	luaPrint("TableLayer loadUser:",vSeat)
	if not self:checkViewSeat(vSeat) then
		return;
	end

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	-- luaDump(userInfo, "TableLayer:loadUser", 5)

	if userInfo then
		self.m_iPlayerStatusTb[vSeat] = Common.STATUS_WAITING;
		self.Image_headTb[vSeat]:setVisible(true);
		self.Image_headTb[vSeat]:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		local headSize = self.Image_headTb[vSeat]:getContentSize();
		local size = cc.size(88,88);
		
		self.Image_headTb[vSeat]:setScale(size.width/headSize.width);
		

		self.m_lSelfScore = userInfo.i64Money;
		self.Text_coinTb[vSeat]:setString(GameMsg.formatCoin(userInfo.i64Money));
		self.m_lPlayerCoin[vSeat] = userInfo.i64Money;


		self.Text_nameTb[vSeat]:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		-- self.Text_nameTb[vSeat]:setString("seat_"..userInfo.bDeskStation);
		self.Text_chipTb[vSeat]:setString("0");
		self.Image_coinTb[vSeat]:setVisible(true);
		self.Image_bankerTb[vSeat]:setVisible(false);
		self.Image_chipBannerTb[vSeat]:setVisible(false);

		if self:isMeSeat(vSeat) then
			self:autoSendReady();
			-- self.Button_ready:setVisible(true);
		end
	end


	self:showWaitingTip();

end

--载入空置玩家位置
function TableLayer:loadIdleUser(vSeat)
	luaPrint("TableLayer loadIdleUser vSeat:",vSeat)
	if not self:checkViewSeat(vSeat) then
		return;
	end

	self.m_iPlayerStatusTb[vSeat] = Common.STATUS_IDLE;
	self.Image_headTb[vSeat]:setVisible(false);
	self.Text_nameTb[vSeat]:setString("");
	self.Image_coinTb[vSeat]:setVisible(false);
	self.Text_coinTb[vSeat]:setString("");
	self.Image_progressTb[vSeat]:setVisible(false);
	self.Image_lightTb[vSeat]:setVisible(false);
	self.Image_bankerTb[vSeat]:setVisible(false);
	self.Image_chipBannerTb[vSeat]:setVisible(false);
	self.Text_chipTb[vSeat]:setString("");
	self.m_lPlayerCoin[vSeat] = 0;
end


--进入玩家
function TableLayer:enterUser(vSeat,bIsMe)
	luaPrint("TableLayer enterUser:",vSeat)
	if not self:checkViewSeat(vSeat) then
		return;
	end

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	-- luaDump(userInfo, "TableLayer:enterUser", 5)
	if userInfo then
		self.m_iPlayerStatusTb[vSeat] = Common.STATUS_WAITING;

		self.Image_headTb[vSeat]:setVisible(true);
		self.Image_headTb[vSeat]:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		local headSize = self.Image_headTb[vSeat]:getContentSize();
		local size = cc.size(88,88);
		
		self.Image_headTb[vSeat]:setScale(size.width/headSize.width);
		self.m_lSelfScore = userInfo.i64Money;
		self.Text_coinTb[vSeat]:setString(GameMsg.formatCoin(userInfo.i64Money));
		self.m_lPlayerCoin[vSeat] = userInfo.i64Money;
		self.Text_nameTb[vSeat]:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		-- self.Text_nameTb[vSeat]:setString("seat_"..userInfo.bDeskStation);
		self.Text_chipTb[vSeat]:setString("0");
		self.Image_coinTb[vSeat]:setVisible(true);
		self.Image_bankerTb[vSeat]:setVisible(false);
		self.Image_chipBannerTb[vSeat]:setVisible(false);

		self:removeSeatAnim(vSeat);
		if self:isMeSeat(vSeat) then
			self:autoSendReady();
		end

		self:showWaitingTip();


	end
end


--玩家离开
function TableLayer:leaveUser(vSeat,bIsMe)
	luaPrint("TableLayer leaveUser------------++++++++++++ vSeat:",vSeat)
	if not self:checkViewSeat(vSeat) then
		luaPrint("vSeat is error:",vSeat)
		return;
	end

	if vSeat == 0 then

		addScrollMessage("上局游戏没有操作或您的金币不足,自动退出游戏")
		--self:onClickExitGameCallBack(5);

		-- if self.m_bOutTime then --超时退出房间
			
		-- else
		-- 	if self.m_bGiveUp then
		-- 		addScrollMessage("上局游戏没有操作,自动退出游戏!")
		-- 		self:onClickExitGameCallBack();
		-- 		return;
		-- 	end

		-- 	luaPrint("self:getRoomMin() > self.m_lSelfScore:-----------------------",self:getRoomMin() , self.m_lSelfScore);
		-- 	if self:getRoomMin() > self.m_lSelfScore then
		-- 		self.Button_exit:stopAllActions();
		-- 		local callFunc = cc.CallFunc:create(
		-- 				function ()
		-- 					addScrollMessage("您的金币不足,不能继续游戏。")
		-- 					self:onClickExitGameCallBack();
		-- 				end
		-- 			);
		-- 		self.Button_exit:runAction(cc.Sequence:create(cc.DelayTime:create(2),callFunc));
		-- 		return;
		-- 	end



		-- end

		

		return;
	end

	self.m_iPlayerStatusTb[vSeat] = Common.STATUS_IDLE;
	self.m_SeatDownTb[vSeat] = false;
	self.Image_headTb[vSeat]:setVisible(false);
	self.Text_nameTb[vSeat]:setString("");
	self.Image_coinTb[vSeat]:setVisible(false);
	self.Text_coinTb[vSeat]:setString("");
	self.Image_progressTb[vSeat]:setVisible(false);
	self.Image_lightTb[vSeat]:setVisible(false);
	self.Image_bankerTb[vSeat]:setVisible(false);
	self.Image_chipBannerTb[vSeat]:setVisible(false);
	self.Text_chipTb[vSeat]:setString("");
	self.m_lPlayerCoin[vSeat] = 0;

	self:removeSeatCard(vSeat);
	self:setPlayerGray(vSeat, false);
	self.Image_readyTb[vSeat]:setVisible(false);
	self:removeSeatAnim(vSeat);
	self:showWaitingTip();



	-- luaDump(self.m_iPlayerStatusTb, "self.m_iPlayerStatusTb----------------leaveuser", 5)
end




function TableLayer:checkViewSeat(vSeat)
	if vSeat == nil or vSeat < 0 or vSeat > 4 then
		luaPrint("checkViewSeat seat error",vSeat)
		return false;
	end

	return true;
end


function TableLayer:isMeSeat(vSeat)

	if not self:checkViewSeat(vSeat) then
		luaPrint("isMeSeat error:",vSeat);
		return;
	end

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
	if self.tableLogic:getMySeatNo() == bSeatNo then
		return true;
	end

	return false;
end




--退出
function TableLayer:onClickExitGameCallBack(isRemove)
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	    self:leaveDesk();
	end


	local status = false;
	if self.m_iSelfStatus == Common.STATUS_PLAYING then
		status = true;		
	end

	if isRemove ~= nil then
		Hall:exitGame(isRemove,func);
	else
		Hall:exitGame(status,func);
	end

	


	-- Hall:exitGame(self.isPlaying,func)
end


--按钮响应
function TableLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        
    elseif event == ccui.TouchEventType.ended then
        luaPrint("onBtnClickEvent----- Name:",btnName);
        
        if "Button_exit" == btnName then --返回

        	self:onClickExitGameCallBack();
   --      	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
			
			-- local func = function()
			-- 	self.tableLogic:sendUserUp();
			-- 	self.tableLogic:sendForceQuit();	
			-- end
			
			-- local status = false;
			-- if self.m_iSelfStatus == Common.STATUS_PLAYING then
			-- 	status = true;		
			-- end

			-- Hall:exitGame(status,func);


    		--游戏未开始 结束 false
    		--其他为空
        elseif "Button_continue" == btnName then
        	-- self.tableLogic:sendMsgReady();
        	-- self.Panel_continue:setVisible(false);
        	-- self.m_bGiveUp = false;
        	self.tableLogic:sendUserUp();
        	self.tableLogic:sendForceQuit();
        	UserInfoModule:clear();
        	local score = 0;
        	for vSeat=0,4 do 
	        	if self:isMeSeat(vSeat) then
					score = goldReconvert(tonumber(self.Text_coinTb[vSeat]:getString()))
				end
			end
	        local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),globalUnit.selectedRoomID)

	        if score < gold then
	            local prompt = GamePromptLayer:create();
	            prompt:showPrompt(GBKToUtf8("最低需要"..goldConvert(gold).."金币以上！"));
	            prompt:setBtnClickCallBack(function() 
	                local func = function()
	                    self:leaveDesk(3);
	                end
	                Hall:exitGame(false,func);
	            end); 
	            return;
	        end

	        local sanzhangpai = require("sanzhangpai");
	        sanzhangpai.reStart = true;
	        UserInfoModule:clear();

	        Hall:exitGame(1,function() 
            self:leaveDesk(1);
	            sanzhangpai:ReSetTableLayer(); 
	        end);
        elseif "Button_leave" == btnName then
        	self:onClickExitGameCallBack();



        elseif "Button_safeBox" == btnName then --菜单按钮 保险箱
        	
        elseif "Button_help" == btnName then --菜单按钮 规则
 		
        	self:addChild(PopUpLayer:create());	
   --      	if not self.m_testIndex then
   --      		self.m_testIndex = 0;
   --      	end
        	
   --      	local vSeat = self.m_testIndex;
   --      	luaPrint("vvvvvvvvvvvvvvseat  = ",vSeat)
   --      	self.Panel_anims:removeChildByTag(TAG_WIN_ANIM + vSeat, cleanup)
   --      	local skeleton_animation = createSkeletonAnimation(WinnerAnim.name,WinnerAnim.json,WinnerAnim.atlas);
			-- skeleton_animation:setAnimation(0,WinnerAnimName, false);
			-- self.Panel_anims:addChild(skeleton_animation);
			-- local pos = self.m_WinnerPosTb[vSeat];
			
			-- skeleton_animation:setPosition(pos);
			-- skeleton_animation:setTag(TAG_WIN_ANIM + vSeat);

			-- self.m_testIndex = self.m_testIndex + 1;
			-- if self.m_testIndex  > 4 then
			-- 	self.m_testIndex  = 0;
			-- end



        elseif "Button_effect" == btnName then --菜单按钮 音效
        	self.m_bEffectOn = getEffectIsPlay();

			luaPrint("音效",self.m_bEffectOn);
			if self.m_bEffectOn then
				setEffectIsPlay(false);
				self.m_bEffectOn = false;
				self.Button_effect:loadTextures("szp_yinxiao2.png", "szp_yinxiao2-on.png","", UI_TEX_TYPE_PLIST);
		        
		    else
		    	setEffectIsPlay(true);
				self.m_bEffectOn = true;
		        self.Button_effect:loadTextures("szp_yinxiao1.png", "szp_yinxiao-on.png","", UI_TEX_TYPE_PLIST);
		    end
        elseif "Button_music" == btnName then --菜单按钮 音乐
        	self.m_bMusicOn = getMusicIsPlay();
			luaPrint("音乐",self.m_bMusicOn);
			if self.m_bMusicOn then--开着音效
				setMusicIsPlay(false);
				self.m_bMusicOn = false;
				self.Button_music:loadTextures("szp_yinyue2.png", "szp_yinyue2-on.png","", UI_TEX_TYPE_PLIST);
			else
				setMusicIsPlay(true);
				self.m_bMusicOn = true;
				self.Button_music:loadTextures("szp_yinyue.png", "szp_yinyue-on.png","", UI_TEX_TYPE_PLIST);
				-- playMusic("bairenniuniu/sound/sound-bg.mp3", true);

				local index = math.random(1,1000);
				 luaPrint("bg_sound_index:",index);
				 if index%2 == 0 then
				 	playMusic("sanzhangpai/sound/bgm01.mp3", true); 
				 else
					playMusic("sanzhangpai/sound/bgm02.mp3", true); 	
				 end
			end



        elseif "Button_sound" == btnName then --音效
        	-- self:test(false);
        	local bShow = self.Panel_boxList:isVisible();
        	self.Panel_boxList:setVisible(not bShow);



        elseif "Panel_player" == btnName then --音效

        	--Panel_player1
        elseif "Button_ready" == btnName then --准备
        	self.tableLogic:sendMsgReady();

        elseif "Button_bet" == btnName then --下注
        	Common.delayBtnEnable(sender, 1.0);
        	self:sendBet();

        elseif "Button_follow" == btnName then --跟注
        	Common.delayBtnEnable(sender, 1.0);
        	self:sendFollowBet();

        elseif "Button_raise" == btnName then --加注打开
        	self:showRasisePanel();
        elseif "Panel_raise" == btnName then --加注面板关闭
        	self:hideRaisePanel();
        elseif "Button_raiseBet" == btnName then  --加注
        	local nChip = btnTag;
        	self:sendRaiseBet(nChip);

        elseif "Button_fold" == btnName then  --弃牌
        	Common.delayBtnEnable(sender, 1.0);
        	self:sendFold();

        elseif "Button_check" == btnName then  --看牌
        	Common.delayBtnEnable(sender, 1.0);
        	self:sendCheck();
        elseif "Button_compare" == btnName then  --请求比牌
        	Common.delayBtnEnable(sender, 1.0);
        	self:sendReqCompare();
        	-- seneder:setEnabled(false);
        	

        	-- self:showCompSelect();
        elseif "Button_allIn" == btnName then  --全下
        	Common.delayBtnEnable(sender, 1.0);
        	self:sendAllIn();


        elseif "Button_eveal" == btnName then  --亮牌
        	
        	self:sendEveal();
        	


        elseif "Panel_area" == btnName then --头像点击
        	local vSeat = btnTag;
        	local lSeat = self.tableLogic:viewToLogicSeatNo(vSeat);
        	luaPrint("sendComp:----",vSeat,lSeat)

        	Common.delayBtnEnable(sender, 1.0);


        	self:sendComp(lSeat)

        elseif "Button_auto" == btnName then --跟到底
        		
    		if self.m_iSelfStatus == Common.STATUS_PLAYING then
    			-- self.Button_unAuto:setVisible(true);
    			-- self.Button_unAuto:setEnabled(true);
    			

    			-- self.Button_auto:setVisible(false);

    			-- self.m_bAutoBet = true;	

    			-- if self.m_bSelfTurning then
    			-- 	if self.Button_bet:isVisible() then
    			-- 		self:sendBet();
    			-- 	else
    			-- 		self:sendFollowBet();
    			-- 	end	
    			-- end
    			self.tableLogic:sendAutoFollow(true);
    		end

        elseif "Button_unAuto" == btnName then --取消跟到底
        	if self.m_iSelfStatus == Common.STATUS_PLAYING then
    			-- self.Button_auto:setVisible(true);
    			-- self.Button_auto:setEnabled(true);
    			

    			-- self.Button_unAuto:setVisible(false);

    			-- self.m_bAutoBet = false;
    			self.tableLogic:sendAutoFollow(false);	
    		end

    	elseif "Button_zhanji" == btnName then --战绩
    		luaPrint("ZHANJI-----------")
    		if self.m_logBar then
				self.m_logBar:CreateLog();
			end
        end
        
    end

    

end





function TableLayer:beginBetBaseCoin()
	self:addPlist();
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		if v == Common.STATUS_PLAYING then
			local pos = self:getBagPosbySeat(vSeat);
			self.m_coinView:betMoveCoin(self.m_lBaseChip, pos);
			self:addPlayerChip(vSeat, self.m_lBaseChip);
			self:updatePlayerChip(vSeat);
			self:updatePlayerCoin(vSeat);
		end
	end

	self:resetTableInfo();


end


function TableLayer:playSendCards()
	
	self.Panel_cards:removeAllChildren();

	local seatedTb = {3,4,0,1,2};

	-- for seat1,v in pairs(self.m_playSeatTb) do
	-- 	if v <= 0 then
	-- 		for kk,seat2 in pairs(seatedTb) do
	-- 			if seat1 == seat2 then
	-- 				table.remove(seatedTb,kk);
	-- 				break;
	-- 			end
	-- 		end
	-- 	end
	-- end

	for seat1,v in pairs(self.m_iPlayerStatusTb) do
		if v ~= Common.STATUS_PLAYING then
			for kk,seat2 in pairs(seatedTb) do
				if seat1 == seat2 then
					table.remove(seatedTb,kk);
					break;
				end
			end
		end
	end



	local function getCard(id)
        local img_card = ccui.ImageView:create(string.format("szp_0x%02X.png",id),UI_TEX_TYPE_PLIST);
        img_card:setScale(0.54)
        return img_card
    end


	-- self.m_iPlayerStatusTb
	-- local seatedTb = {3,1,2};
	local bSize = cc.size(CARD_WIDTH*0.3,CARD_HEIGHT*0.3);
	local spead = 1200;
	for i,vSeat in ipairs(seatedTb) do
		local posTb = self.m_posCardTb[vSeat];

		local lSeat = self.tableLogic:viewToLogicSeatNo(vSeat);
		luaPrint("vSeat,lSeat:",vSeat,lSeat)
		local cards = self.m_playerCardTb[lSeat+1];

		
		for j=1,3 do
			-- local card = self:cardOfSeat(vSeat);
			local pos_s = cc.p(self.Image_dealer:getPosition());
			--test 
			local card = getCard(cards[j]);
			
			if cards[j] ~= nil and cards[j] > 0 then
				card = getCard(cards[j]);
				
			else
				card = self:cardOfSeat(vSeat);
				local size = card:getContentSize();
				card:setScale(bSize.width/size.width);
				card:setTag(self:getCardTag(vSeat,j));
			end


			-- local size = card:getContentSize();
			-- card:setScale(bSize.width/size.width);
			card:setTag(self:getCardTag(vSeat,j));
			-- local pos_s = cc.p(self.Image_dealer:getPosition());
			card:setPosition(pos_s);
			self.Panel_cards:addChild(card);
			card:setVisible(false);	

			local delayIt = cc.DelayTime:create(0.15*(i-1));
			local delayIt2 = cc.DelayTime:create(0.02*(j-1));
			local showIt = cc.Show:create();

			local length = cc.pGetDistance(pos_s,posTb[1]);
			local dt = length/spead;
			local moveIt = cc.MoveTo:create(dt,posTb[1]);
			local scale = 1.0;
			if cards[j] ~= nil and cards[j] > 0 then
				if vSeat == 0 then
					scale = 1.0;
				else
					scale = 0.54;
				end
				
			else
				if vSeat == 0 then
					scale = 1.0;
				elseif vSeat == 1 or vSeat == 4 then
					scale = 1.0;
				else
					scale = 0.73;
				end
			end
			

			local scaleIt = cc.ScaleTo:create(dt,scale);
			local spawn = cc.Spawn:create(moveIt,scaleIt)
			local delayIt3 = cc.DelayTime:create(1*0.02*1);
			local moveTo = cc.MoveTo:create(0.03*j*1,posTb[j]);


			local animCallback = cc.CallFunc:create(function (sender)
					if self.m_bEffectOn then
			        	playEffect("sanzhangpai/sound/fapai.mp3", false);
			        end
			end)


			local seq = cc.Sequence:create(delayIt,delayIt2,showIt,spawn,delayIt3,animCallback,moveTo);
			card:runAction(seq);

			-- if self.m_bEffectOn then
	  --       	playEffect("sanzhangpai/sound/fapai.mp3", false);
	  --       end


		end
	end


end


function TableLayer:cardOfSeat(vSeat)
	self:addPlist();
	local card = nil;
	if vSeat == 0 then
		-- card = ccui.ImageView:create("szp_paibei_l.png",UI_TEX_TYPE_PLIST);
		-- card = cc.Sprite:createWithSpriteFrameName("szp_paibei.png");
		card = ccui.ImageView:create("szp_paibei.png",UI_TEX_TYPE_PLIST);
	elseif vSeat == 1 then
		-- card = cc.Sprite:createWithSpriteFrameName("szp_paibei_r.png");
		card = ccui.ImageView:create("szp_paibei_r.png",UI_TEX_TYPE_PLIST);
	elseif vSeat == 2 then
		-- card = cc.Sprite:createWithSpriteFrameName("szp_paibei_r.png");
		card = ccui.ImageView:create("szp_paibei_r.png",UI_TEX_TYPE_PLIST);
	elseif vSeat == 3 then
		-- card = cc.Sprite:createWithSpriteFrameName("szp_paibei_l.png");
		card = ccui.ImageView:create("szp_paibei_l.png",UI_TEX_TYPE_PLIST);
	elseif vSeat == 4 then
		-- card = cc.Sprite:createWithSpriteFrameName("szp_paibei_l.png");
		card = ccui.ImageView:create("szp_paibei_l.png",UI_TEX_TYPE_PLIST);
	end
	return card;
end


function TableLayer:getCardTag(vSeat,_card_index)
	return vSeat*10+_card_index
end

function TableLayer:getCardBySeat(vSeat,_card_index)
	local tag = self:getCardTag(vSeat,_card_index);
	local card = self.Panel_cards:getChildByTag(tag);
	return card;
end


function TableLayer:removeAllSeatCards()
	for k,v in pairs(self.m_iPlayerStatusTb) do
		self:removeSeatCard(k);
	end
end

function TableLayer:removeSeatCard(vSeat)
	for i=1,7 do
		local tag = vSeat*10 + i
		if self.Panel_cards:getChildByTag(vSeat*10 + i) then
			self.Panel_cards:removeChildByTag(vSeat*10 + i)
		end
	end
end


function TableLayer:removeSeatAnim(vSeat)
	self.Panel_anims:removeChildByTag(TAG_WIN_ANIM + vSeat);
end


--获取玩家位置
function TableLayer:getBagPosbySeat(vSeat)

	-- local pos = self.Image_headTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_headTb[vSeat]:getPosition()));

	if self:checkViewSeat(vSeat) then
		return self.m_headPosTb[vSeat];
	end

	return cc.p(640,320);
end


function TableLayer:addPlayerChip(vSeat,nChip)
	self.m_lPlayerChipTb[vSeat] = self.m_lPlayerChipTb[vSeat] + nChip;
	self.m_lTotalChip = self.m_lTotalChip + nChip;
end

function TableLayer:updatePlayerCoin(vSeat)
	local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	if userInfo then
		self.m_lPlayerCoin[vSeat] = userInfo.i64Money - self.m_lPlayerChipTb[vSeat];

		if self:isMeSeat(vSeat) then
			self.m_lSelfScore = self.m_lPlayerCoin[vSeat];
		end

		self.Text_coinTb[vSeat]:setString(GameMsg.formatCoin(self.m_lPlayerCoin[vSeat]));
	end
end


function TableLayer:updatePlayerChip(vSeat)
	self.Text_chipTb[vSeat]:setString(GameMsg.formatCoin(self.m_lPlayerChipTb[vSeat]));
end


--显示加注面板
function TableLayer:showRasisePanel()
	self.Panel_raise:setVisible(true);



end

function TableLayer:hideRaisePanel()
	self.Panel_raise:setVisible(false);
end


function TableLayer:updateRasieBtns()
	
	-- luaDump(self.level_rases, "self.level_rases", 3)
	-- self.m_nBetConfigTb
	for i,v in ipairs(self.m_nBetConfigTb) do
		local value = v
		

		local img_path = Common.CHIP_IMG[10]
		local text = self.Button_raiseTb[i]:getChildByName("Text_chip")

		if self.m_bChecked then
			value = value * 2;
		end

		self.Button_raiseTb[i]:setTag(value)

		if self.level_rases[value] then
			local index = self.level_rases[value]
			img_path = Common.CHIP_IMG[index]
		end
		
		self.Button_raiseTb[i]:loadTextureNormal(img_path,UI_TEX_TYPE_PLIST);
		text:setString(Common.getCoinStr(value));
	end
end


function TableLayer:resetRaseBtns()
	for i,v in ipairs(self.Button_raiseTb) do
		v:setEnabled(true)
		
		v:setOpacity(255)
	end
end

function TableLayer:disableRaseBtn()
	local limitChip = self.m_lSingleChip;
	if self.m_bChecked then
		limitChip = limitChip * 2;
	end
	luaPrint("disableRaseBtn self.m_bChecked,limitChip",self.m_bChecked,limitChip)
	for i,v in ipairs(self.Button_raiseTb) do
		if v:getTag() <= limitChip then
			v:setEnabled(false)
			
		else
			
		end
	end
end



function TableLayer:test(bGray)
	--播放动画
	-- self.Panel_anims:removeAllChildren();
	-- local pos = cc.p(self.Image_tipWaitBg:getPosition());

	-- local skeleton_animation = createSkeletonAnimation(BeginAnim.name,BeginAnim.json,BeginAnim.atlas);
	-- self.Panel_anims:addChild(skeleton_animation);
	-- -- local pos = cc.p(640,360)
	-- skeleton_animation:setPosition(pos);
	-- skeleton_animation:setTag(102);
	-- skeleton_animation:setAnimation(0,BeginAnimAnimName, false);


	--播放动画
	self.Panel_anims:removeAllChildren();
	self.Panel_anims:stopAllActions();
	local pos = cc.p(self.Image_tipWaitBg:getPosition());

	local skeleton_animation = createSkeletonAnimation(BeginAnim.name,BeginAnim.json,BeginAnim.atlas);
	if skeleton_animation then
		self.Panel_anims:addChild(skeleton_animation);
		-- local pos = cc.p(640,360)
		skeleton_animation:setPosition(pos);
		skeleton_animation:setTag(102);
		skeleton_animation:setAnimation(0,BeginAnimAnimName, false);
	end
	

	local animCallback = cc.CallFunc:create(function (sender)
			self.Panel_anims:removeAllChildren();
	end)

	self.Panel_anims:runAction(cc.Sequence:create(cc.DelayTime:create(4),animCallback))


	-- local panel = self.Panel_anims:getChildByName("Panel_test1");

	-- local skeleton_animation = createSkeletonAnimation(WinAnim.name,WinAnim.json,WinAnim.atlas);
	-- self.Panel_anims:addChild(skeleton_animation);
	-- local pos = cc.p(panel:getPosition())
	-- skeleton_animation:setPosition(pos);
	-- skeleton_animation:setTag(102);
	-- skeleton_animation:setAnimation(0,WinAnimName, false);

	-- for i=1,5 do
		-- local index = i-1;

		-- self.Panel_anims:removeChildByTag(100+index, true);

		-- local pos = self.m_ReulstPosTb[index];
		-- local skeleton_animation = createSkeletonAnimation(WinAnim.name,WinAnim.json,WinAnim.atlas);
		-- self.Panel_anims:addChild(skeleton_animation);
		
		-- skeleton_animation:setPosition(pos);
		-- skeleton_animation:setTag(100+index);
		-- skeleton_animation:setAnimation(0,WinAnimName, false);
	-- end
	
	-- local skeleton_animation = createSkeletonAnimation(LostAnim.name,LostAnim.json,LostAnim.atlas);
	-- self.Panel_anims:addChild(skeleton_animation);
	-- local pos = cc.p(panel:getPosition())
	-- skeleton_animation:setPosition(pos);
	-- skeleton_animation:setTag(102);
	-- skeleton_animation:setAnimation(0,LostAnimName, false);

	
	-- local skeleton_animation = createSkeletonAnimation(WaitAnim.name,WaitAnim.json,WaitAnim.atlas);
	-- self.Panel_anims:addChild(skeleton_animation);
	-- local pos = cc.p(panel:getPosition())
	-- skeleton_animation:setPosition(pos);
	-- skeleton_animation:setTag(102);
	-- skeleton_animation:setAnimation(0,WaitAnimName, false);


	-- self.Panel_anims:removeAllChildren();

	-- local skeleton_animation = createSkeletonAnimation(VSAnim.name,VSAnim.json,VSAnim.atlas);
	-- self.Panel_anims:addChild(skeleton_animation);
	-- local pos = cc.p(640,360)
	-- skeleton_animation:setPosition(pos);
	-- skeleton_animation:setTag(102);
	-- skeleton_animation:setAnimation(0,VSAnimName, false);

	-- local panelLeft = self.Panel_PlayerTb[0]:clone();
	-- local Image_progress = panelLeft:getChildByName("Image_progress");
	-- Image_progress:setVisible(false);
	-- panelLeft:setVisible(false);

	-- local Image_chipBanner = panelLeft:getChildByName("Image_chipBanner");
	-- Image_chipBanner:setVisible(false);

	-- local panelRight = self.Panel_PlayerTb[0]:clone();
	-- local Image_progress2 = panelRight:getChildByName("Image_progress");
	-- Image_progress2:setVisible(false);

	-- local Image_chipBanner2 = panelRight:getChildByName("Image_chipBanner");
	-- Image_chipBanner2:setVisible(false);
	-- panelRight:setVisible(false);


	-- for i=1,2 do
	-- 	local panelLeft = self.Panel_PlayerTb[0]:clone();
	-- 	local Image_progress = panelLeft:getChildByName("Image_progress");
	-- 	Image_progress:setVisible(false);
	-- 	panelLeft:setVisible(false);
	-- 	local pos = nil;
	-- 	if i == 1 then
	-- 		pos = self.m_LeftCompPos;
	-- 	else
	-- 		pos = self.m_RightCompPos;
	-- 	end
	-- 	self.Panel_anims:addChild(panelLeft);
	-- 	panelLeft:setPosition(pos);

	-- 	local delayIt = cc.DelayTime:create(0.65);
	-- 	local showIt = cc.Show:create();
	-- 	panelLeft:runAction(cc.Sequence:create(delayIt,showIt));


	-- end



	-- luaDump(pos, "test----------1", 4)
		
	-- local cardData = {1,2,3};
	-- local vSeat = 3;
	-- local posTb = self.m_posCardTb[vSeat];
	-- local pos_tt = posTb[1];

	-- local scale_y = 1.1
 --    local scale_b = 0.55
 --    local scale_p = 0.7
 --    local img_cards = {}
 --    local img_backs = {}
 --    local scale = 0.54
 --    local up = 20
 --    local padding = 86


 --    local gap = 33;
	-- 	local width = 84;
	-- 	local height = 73;

	-- if vSeat == 1 then
	-- 	width = 115;
	-- 	height = 158;
	-- 	gap = 50;
	-- end




 --    self.Panel_cards:removeAllChildren();

 --    local function getCard(id)
 --        local img_card = ccui.ImageView:create(string.format("szp_0x%02X.png",id),UI_TEX_TYPE_PLIST);
 --        img_card:setScale(scale)
 --        return img_card
 --    end
    
 --    local function getCardBack()
 --        local img_card = ccui.ImageView:create("szp_0x00.png",UI_TEX_TYPE_PLIST);
 --        img_card:setScale(scale)
 --        return img_card
 --    end


 --    local function runTurnFront()
 --        local speed_x = 1600
 --        for i,v in ipairs(cardData) do
 --        	local tag = self:getCardTag(vSeat, i);
 --            local pos_t = posTb[i];
 --            if i == 3 then
 --                pos_t = cc.p(pos_t.x + 10 ,pos_t.y)
 --            end
            
 --            local length = pos_t.x
           
 --            local dt1 = length/(speed_x+100*i)
 --            img_backs[i]:loadTexture(string.format("szp_0x%02X.png",v),UI_TEX_TYPE_PLIST);
 --            img_backs[i]:setScaleX(0.01)
 --            img_backs[i]:setScaleY(scale_y*scale)
     
 --            local showIt = cc.Show:create()
 --            local turnFront = cc.ScaleTo:create(0.1,1.1*scale,1.0*scale)
 --            local turnFront2 = cc.ScaleTo:create(0.05,1.0*scale,1.0*scale)
 --            local moveDown = cc.MoveBy:create(0.05,cc.p(0,-up-i*2))
 --            local delayIt = cc.DelayTime:create(0.05)
 --            local moveTo = cc.MoveTo:create(dt1, pos_t)

 --            if i == 3 then
 --                local moveBack = cc.MoveBy:create(0.05,cc.p(-10,0))
 --                img_backs[i]:runAction(cc.Sequence:create(showIt,turnFront,turnFront2,moveDown,delayIt,moveTo,moveBack,delayIt2))
 --            else
 --                img_backs[i]:runAction(cc.Sequence:create(showIt,turnFront,turnFront2,moveDown,delayIt,moveTo))
 --            end
 --        end
 --    end


	
	-- local function showBackCard()
 --        for i=1,3 do
 --        	local index = i - 1;

 --            img_backs[i] = getCardBack()
 --            img_backs[i]:setPosition(posTb[i])
 --            self.Panel_cards:addChild(img_backs[i]);
 --            local tag = self:getCardTag(vSeat, i);
 --            img_backs[i]:setTag(tag);

 --            local delayIt = cc.DelayTime:create(0.1)
 --            local moveBack = cc.MoveBy:create(0.1, cc.p(-gap*index-9,0))

 --            local moveUp = cc.MoveBy:create(0.2,cc.p(0,up+i*5))
 --            local turnBack = cc.ScaleTo:create(0.2,0.01,scale_y*scale_b)
 --            local spawn = cc.Spawn:create(moveUp,turnBack)
            
 --            if i == 3 then
 --                img_backs[i]:runAction(cc.Sequence:create(delayIt,moveBack,spawn,cc.CallFunc:create(runTurnFront)))    
 --            else
 --                img_backs[i]:runAction(cc.Sequence:create(delayIt,moveBack,spawn))
 --            end
    
 --        end
 --    end



 --    showBackCard();

 	-- self.Image_dealer:setVisible(true);
 	-- local pos = cc.p(680,360);
 	-- self.Image_dealer:setPosition(pos);
 	-- Common.setImageGray(self.Image_dealer,bGray);

end



-----------------------------------------------三张牌框架消息------------------------------------------------------
--准备消息
function TableLayer:onReadyMsg(vSeat,bIsMe)
	luaPrint("onReadyMsg:---",vSeat,bIsMe)
	if not self:checkViewSeat(vSeat) then
		return;
	end

	-- self.Image_readyTb[vSeat]:setVisible(true);

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

	if bSeatNo == self.tableLogic:getMySeatNo() then
		-- self.Button_ready:setVisible(false);
		-- self:clearTable();
		self.m_bGiveUp = false;
	end

	

end

function TableLayer:onGameStationWait(msg)
	luaDump(msg, "onGameStationWait", 5)
	-- self:pushGameMsg(msg);
	self:resumeTableFree(msg);


end


function TableLayer:onGameStationPlaying(msg)
	luaDump(msg, "onGameStationPlaying", 5)
	-- self:pushGameMsg(msg);
	self:resumeTablePlaying(msg);



end

function TableLayer:onGameStationSend(msg)
	luaDump(msg, "onGameStationSend", 5)
	self:resumeTableSending(msg);
	
end


function TableLayer:onSZPGameMsg(msg)
	-- luaDump(msg._usedata, "onSZPGameMsg", 5)
	local message = msg._usedata;
	self:pushGameMsg(message);
end






-----------------------------------------游戏消息处理--------------------

--三张牌消息处理
--游戏开始消息
function TableLayer:pushGameMsg(msg)
    luaPrint("msg id:",msg.id)
    -- luaDump(msg,'pushGameMsg',6);
    if self.m_bEnterGame  then
    	table.insert(self.m_gameMsgArray,#self.m_gameMsgArray + 1,msg);
    	luaPrint("当前游戏消息数量:%d",#self.m_gameMsgArray);
    else
    	luaPrint("游戏还没初始化消息");
    end

    

    --

end

--启动消息监听
function TableLayer:startGameMsgRun()
     --帧更新,用来转发消息,消息是在onGameMessageDeal中构建的
     if self.m_msgRunTimeId == -1 then
     	self.m_msgRunTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:update(delta) end, 0.02,false);
     end
      luaPrint("startGameMsgRun self.m_msgRunTimeId:",self.m_msgRunTimeId)
    -- self.m_msgRunTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:update(delta) end, 0.05 ,false);
   
end

--停止消息监听
function TableLayer:stopGameMsgRun()
	luaPrint("stopGameMsgRun self.m_msgRunTimeId:",self.m_msgRunTimeId)
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

function TableLayer:postActionBegin()
    EventMgr:dispatch(Common.EVT_VIEW_MSG,Common.ACTION_BEGIN);
end

function TableLayer:postActionEnd()
    EventMgr:dispatch(Common.EVT_VIEW_MSG,Common.ACTION_END);
end


--游戏消息事件
function TableLayer:onDealMsg(event)
    local msg = event._usedata;
    self:onGameMessageDeal(msg);


end

--游戏动作消息处理开关
function TableLayer:onViewMsg(event)
    local iEvent = event._usedata;
    luaPrint("onViewMsg",iEvent)
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
    if msgId == Common.MSG_TABLE_FREE then   --游戏等待
 
    	self:resumeTableFree(msg);
    elseif msgId == Common.MSG_TABLE_PLAYING then  --游戏发牌中
    	self:resumeTablePlaying(msg);
    elseif msgId == Common.MSG_BEGIN_GAME then  --开始游戏
    	self:beginGame(msg);
    elseif msgId == Common.MSG_SEND_CARD then 	--游戏发牌
    	self:onSendCard(msg);
    elseif msgId == Common.MSG_BEGIN_BET then 	--开始下注
    	self:onBeginBet(msg);
    elseif msgId == Common.MSG_PLAYER_BET then 	--玩家下注
    	self:onPlayerBet(msg);
    elseif msgId == Common.MSG_TURN_BET then 	--通知玩家下注
    	self:onTurnPlayerBet(msg);
    elseif msgId == Common.MSG_CHECK_CARD then   --玩家看牌
    	self:onPlayerCheck(msg);
    elseif msgId == Common.MSG_GAME_END then   --玩家看牌
    	self:onGameEnd(msg);
    elseif msgId == Common.MSG_COMP_CARD then   --比牌结果
    	self:onCompResult(msg);
    elseif msgId == Common.MSG_EVEAL_CARD then 	--亮牌
    	self:onEvealCards(msg);
    elseif msgId == Common.MSG_ALL_COMPARE then --全局比牌
    	self:onAllCompare(msg);
    elseif msgId == Common.MSG_REQ_COMPARE then --请求比牌
    	self:onReqCompare(msg);
    elseif msgId == Common.MSG_OPPONENT_CARD then --比牌亮牌
    	self:onOpponentCards(msg);
    elseif msgId == Common.MSG_AUTO_BET then --自动跟注
    	self:onAutoFollow(msg);
    	
    end
end


function TableLayer:getRoomMin()
	local difenNum = {10,100,500,1000}
	local ruchang = {3000,5000,30000,60000}

	local index = 1;
	for k,v in pairs(difenNum) do
		if v == difenNum then
			index = k;
			break;
		end
	end

	local minCoin = ruchang[index];
	return minCoin;

end


function TableLayer:resumeTableFree(msg)
	luaDump(msg, 'resumeTableFree-----------msg', 5)
	self.m_gameMsgArray = {}
	self:clearTable();
	
	self.Button_exit:setEnabled(true);


	--剩余牌数
	self.m_iLeftCardCount = msg.iAllCardCount;
	--玩家每次操作的时间
	-- self.m_nDealTime 	= msg.iThinkTime; --15
	--底注
	self.m_lBaseChip 	= msg.iGuoDi;
	--单注
	self.m_lSingleChip 	= self.m_lBaseChip;
	--房间最大筹码
	self.m_nMaxBet 		= msg.iLimtePerNote;
	--庄家
	self.m_wBankerSeat  = msg.iUpGradePeople;
	--当前轮数
	self.m_iNowRound 	= msg.iBeenPlayGame;
	--桌子状态
	self.m_iTableStatus = Common.STATUS_IDLE;

	self:hideReady();
	self:initBetConfig();
	self:resetTableInfo();
	-- self.Button_ready:setVisible(true);


	
	

    --是否进入房间
    self.m_bEnterGame = true;
    self:autoSendReady();
    self:showWaitingTip();


end


--准备发牌
function TableLayer:resumeTableSending(msg)
	luaDump(msg, 'resumeTableSending-----------msg', 5)
	self.m_gameMsgArray = {}
	self:clearTable();

	local gameStation = msg.bGameStation
	if gameStation == GameMsg.GS_PLAY_GAME then
		 --牌桌状态 空闲
    	self.m_iTableStatus = Common.STATUS_PLAYING;
	else
		self.m_iTableStatus = Common.STATUS_IDLE;
	end

	--底注
	self.m_lBaseChip 	= msg.iGuoDi;
	--单注
	self.m_lSingleChip = self.m_lBaseChip;
	--庄家
	self.m_wBankerSeat  = msg.bNtPeople;
	--当前轮数
	self.m_iNowRound 	= 0;

	--玩家状态
	for k,v in pairs(msg.iUserStation) do
		local vSeat =self.tableLogic:logicToViewSeatNo(k-1);
		if v == -1 then  --空闲
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_IDLE;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_IDLE;
			end
		elseif v == 7 then --旁观
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_WAITING;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_WAITING;
			end
		elseif v == GameMsg.TYPE_NOTE_ALL then --全下状态
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
				self:turnPlayerAllIn(k-1, self.m_nDealTime, self.m_iLeftTime);
			end
		else
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
			end
		end
	end


	if self.m_iSelfStatus == Common.STATUS_PLAYING then
		self:removeWaiting();
	else		
		self:showWaitingNext();
	end

	--重置牌桌信息
	self:resetTableInfo();
	--刷新筹码
	self:initBetConfig();
	--加注
	self:disableRaseBtn();
	--庄家
	self:showBankerIcon();	

	self:showPlayerBetBanner();

	self:showCountDownTip();


end



--恢复游戏进行中状态
function TableLayer:resumeTablePlaying(msg)
	luaDump(msg, 'resumeTablePlaying-----------msg', 5)
	
	self.Button_exit:setEnabled(true);
	

	self.m_gameMsgArray = {}
	self:clearTable();
	

	local gameStation = msg.bGameStation
	if gameStation == GameMsg.GS_PLAY_GAME then
		 --牌桌状态 空闲
    	self.m_iTableStatus = Common.STATUS_PLAYING;
	else
		self.m_iTableStatus = Common.STATUS_IDLE;
	end
	local lastBetSeat = msg.iFirstOutPeople;
	local lastVSeat = self.tableLogic:logicToViewSeatNo(lastBetSeat);
	--底注
	self.m_lBaseChip 	= msg.iGuoDi;
	--当前轮数
	self.m_iNowRound 	= msg.iBeenPlayGame;
	
	--房间最大筹码
	self.m_nMaxBet 		= msg.iLimtePerNote;
	--庄家
	self.m_wBankerSeat  = msg.bNtPeople;
	--轮到谁出牌
	self.m_wTurnSeat 	= msg.iOutCardPeople;
	--剩余时间
	local leftTime = msg.iTimeRest;

	--上次操作玩家
	local lastTurnSeat = msg.iNowBigPeople;

	--是否强制比牌
	local bForceCompare = msg.bForceCompare;

	local lastStatus = Common.STATUS_IDLE;
	--自动跟注
	self.m_bAutoBet = msg.bAutoFollow;

	 --是否只能跟注
    self.m_bOnlyFollow = msg.bForceFollow; --最后一轮 最后一个玩家只能跟注

	--比牌中玩家
	local compMsg = {};

	--玩家状态
	for k,v in pairs(msg.iUserStation) do
		local vSeat = self.tableLogic:logicToViewSeatNo(k-1);
		if v == -1 then  --空闲
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_IDLE;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_IDLE;
			end

		elseif v == 7 then --旁观
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_WAITING;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_WAITING;
			end
		elseif v == GameMsg.TYPE_COMPARE_REQ then --请求比牌
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;
			self.m_SeatDownTb[vSeat] = true;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
				lastStatus = Common.STATUS_COMPARE_REQ; --请求比牌
				-- if self.m_wTurnSeat == k-1 then
				-- 	self:showCompSelect();
				-- end


				-- self:showCompSelect();
			end
		elseif v == GameMsg.TYPE_COMPARE_CARD then  --比牌中
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;
			self.m_SeatDownTb[vSeat] = true;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
				lastStatus = Common.STATUS_COMPARE; --比牌中
			end

			-- if compMsg.defender == nil then
			-- 	compMsg.defender = k - 1;
			-- else
			-- 	compMsg.fighter = k - 1;
			-- end


		elseif v == GameMsg.TYPE_NOTE_ALL then --全下状态

			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;
			self.m_SeatDownTb[vSeat] = true;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
				
			end

			if lastTurnSeat == k-1 then
				lastStatus = Common.STATUS_ALLIN;
			end
			if k-1 == self.tableLogic._mySeatNo then
				-- audio.pauseMusic();
				playMusic("sanzhangpai/sound/newbgm.mp3",true)
				self.AllinEffect = true --audio.playSound("sanzhangpai/sound/newbgm.mp3",true);
			end
		else
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;
			self.m_SeatDownTb[vSeat] = true;
			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
			end
		end
	end

	luaPrint("lastStatus======================",lastStatus)
	if self.m_iSelfStatus == Common.STATUS_PLAYING then
		self:removeWaiting();
	else		
		self:showWaitingNext();
	end
	--玩家下注额度
	for k,v in pairs(msg.iPerJuTotalNote) do
		local vSeat = self.tableLogic:logicToViewSeatNo(k-1);
		self.m_lPlayerChipTb[vSeat] = v;

		self:updatePlayerCoin(vSeat);
		self:updatePlayerChip(vSeat);
	end
	--玩家看牌
	for k,v in pairs(msg.iMing) do
		local vSeat =self.tableLogic:logicToViewSeatNo(k-1);
		self.m_bPlayerCheckedTb[vSeat] = v;

		if self:isMeSeat(vSeat) then
			self.m_bChecked = v;
		end
	end
	--是否比牌输
	for k,v in pairs(msg.bOpenLose) do
		local logicSeat = k - 1;
		local vSeat =self.tableLogic:logicToViewSeatNo(k-1);
		self.m_bPlayerLostTb[vSeat] = v;
		if v then
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_LOST;
		end

		if self:isMeSeat(vSeat) then
			self.m_bLosted = v;
			if v then
				self.m_iSelfStatus = Common.STATUS_LOST;
			end
		end
	end

	-- luaDump(self.m_bPlayerLostTb, "self.m_bPlayerLostTb", 5);

	--是否弃牌
	for k,v in pairs(msg.bIsGiveUp) do
		local vSeat =self.tableLogic:logicToViewSeatNo(k-1);
		self.m_bPlayerFoldedTb[vSeat] = v;
		if v then
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_FOLDED;
		end
		
		if self:isMeSeat(vSeat) then
			self.m_bFolded = v;
			if v then
				self.m_iSelfStatus = Common.STATUS_FOLDED; --玩家自己的状态
			end
		end
	end
	
	--单注
	if msg.iCurNote > 0 then
		self.m_lSingleChip = msg.iCurNote;
	else
		self.m_lSingleChip = self.m_lBaseChip;
	end

	--首次下注
	self.m_bFirstBetSeat = msg.bIsFirstNote;
	--回合
	self.m_iNowRound = msg.iNoteGroup;

	--总下注
	self.m_lTotalChip = msg.iTotalNote;
	--用户手牌
	for k,v in pairs(msg.iUserCard) do
		local vSeat = self.tableLogic:logicToViewSeatNo(k-1);
		if self:isMeSeat(vSeat) then
			self.m_HandCardTb = v;
		end
	end

	--重置牌桌信息
	self:resetTableInfo();
	--刷新筹码
	self:initBetConfig();
	--加注
	self:disableRaseBtn();
	--庄家
	self:showBankerIcon();

	self:resumePlayerStatus(msg);
	
	if self:checkViewSeat(self.m_wTurnSeat) then
		local vSeat = self.tableLogic:logicToViewSeatNo(self.m_wTurnSeat);
		if self:isMeSeat(vSeat) then
			luaPrint("lastStatus == Common.STATUS_ALLIN",lastStatus ,Common.STATUS_ALLIN)
			if lastStatus == Common.STATUS_ALLIN then
				self:turnPlayerAllIn(self.m_wTurnSeat, self.m_nDealTime, leftTime);
			elseif lastStatus == Common.STATUS_COMPARE_REQ then
				self:resetOpButton();
				self:stopAllPlayerTimer();
				self:showPlayerTimer(vSeat,  self.m_nDealTime, leftTime);
				self:showCompSelect();
			elseif lastStatus == Common.STATUS_COMPARE then
				self:resetOpButton();
				self:stopAllPlayerTimer();
			else
				if self.m_iSelfStatus ==  Common.STATUS_PLAYING then
					if bForceCompare then
						self:turnPlayerForceComp(self.m_wTurnSeat,self.m_nDealTime, leftTime);	
					else
						self:turnPlayerDeal(self.m_wTurnSeat,self.m_nDealTime, leftTime);	
					end
				else
					self:resetOpButton();
				end
			end
		else
			if lastStatus == Common.STATUS_ALLIN then
				self.m_iSelfStatus = Common.STATUS_ALLIN;
				self:showPlayerAllinAnim(0);
			end
			self:turnPlayerDeal(self.m_wTurnSeat,self.m_nDealTime, leftTime);	
		end
	end
	
	--显示自己牌型
	local iKind = msg.bCardShape;
	self:showCardKind(0, iKind);
	-- self:showCardKindAnim(0, iKind);


	--显示提示状态
	self:showWaitingTip();
	--是否进入房间
    self.m_bEnterGame = true;
end











--开始游戏
function TableLayer:beginGame(msg)
	luaDump(msg,"TableLayer:beginGame----");
	if self.AllinEffect then
		-- audio.resumeMusic();
		-- audio.stopSound(self.AllinEffect)
		local index = math.random(1,1000);
		 luaPrint("bg_sound_index:",index);
		 if index%2 == 0 then
		 	playMusic("sanzhangpai/sound/bgm01.mp3", true); 
		 else
			playMusic("sanzhangpai/sound/bgm02.mp3", true); 	
		 end
		self.AllinEffect = nil;
	end
	--底注
	self.m_lBaseChip = msg.iGuoDi;

	self:clearTable();
	self.m_iNowRound = 1;
	self:resetTableInfo();
	
	self.m_iTableStatus = Common.STATUS_PLAYING;
	self.m_iSelfStatus = Common.STATUS_PLAYING;
	--庄家位置
	self.m_wBankerSeat = msg.bNtStation;
	self:showBankerIcon();
	-- --游戏开始

	--开始动画
	local StartAnim = {
		name = "szp_kaishiyouxi",
		json = "sanzhangpai/anim/zhajinhuakaishi.json",
		atlas = "sanzhangpai/anim/zhajinhuakaishi.atlas",
	}



	local anim_start = createSkeletonAnimation(StartAnim.name,StartAnim.json,StartAnim.atlas);
	if anim_start then
		anim_start:setPosition(640,460);
		anim_start:setAnimation(1,"zhajinhuakaishi", false);
		self.Panel_anims:addChild(anim_start,2);
		anim_start:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.RemoveSelf:create()));
	end

	if self.m_bEffectOn then
    	playEffect("sanzhangpai/sound/StartGamewomen.mp3", false);
    end


	-- self.Button_exit:setEnabled(false);
	
	-- --播放动画
	-- self.Panel_anims:removeAllChildren();
	-- self.Panel_anims:stopAllActions();
	-- local pos = cc.p(self.Image_tipWaitBg:getPosition());

	-- local skeleton_animation = createSkeletonAnimation(BeginAnim.name,BeginAnim.json,BeginAnim.atlas);
	-- self.Panel_anims:addChild(skeleton_animation);
	-- -- local pos = cc.p(640,360)
	-- skeleton_animation:setPosition(pos);
	-- skeleton_animation:setTag(102);
	-- skeleton_animation:setAnimation(0,BeginAnimAnimName, false);

	-- local animCallback = cc.CallFunc:create(function (sender)
	-- 		self.Panel_anims:removeAllChildren();
	-- end)
	-- --动画4秒
	-- self.Panel_anims:runAction(cc.Sequence:create(cc.DelayTime:create(4),animCallback))

	self.m_bGiveUp = false; 
end


--显示下注筹码栏
function TableLayer:showPlayerBetBanner()
	-- luaDump(self.m_iPlayerStatusTb, "showPlayerBetBanner----self.m_iPlayerStatusTb--------------", 6)
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		self.Image_chipBannerTb[vSeat]:setVisible(false);
	end

	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		if v == Common.STATUS_PLAYING or v == Common.STATUS_FOLDED or v== Common.STATUS_LOST then
			self.Image_chipBannerTb[vSeat]:setVisible(true);
		end
	end
end



--发牌
function TableLayer:onSendCard(msg)
	luaPrint("TableLayer:sendCard----")
	
	-- for k,v in pairs(self.m_playSeatTb) do
	-- 	self.m_playSeatTb[k] = 0;
	-- end

	--玩家手牌
	self.m_playerCardTb = msg.bCard;

	self:removeWaiting();

	local tb = msg.bCardCount;
	for k,v in pairs(tb) do
		local lSeatNO = k - 1;
		local vSeat = self.tableLogic:logicToViewSeatNo(lSeatNO);
		-- self.m_playSeatTb[vSeat] = v;

		if v > 0 then
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_PLAYING;

			if self:isMeSeat(vSeat) then
				self.m_iSelfStatus = Common.STATUS_PLAYING;
			end

			self.m_SeatDownTb[vSeat] = true;
		else
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_IDLE;
			self.m_SeatDownTb[vSeat] = false;
		end

	end

	self:showPlayerBetBanner();

	self:beginBetBaseCoin();

	local function beginLicensingCards()
		self:playSendCards()

		self.Button_exit:setEnabled(true);
		
	end

	self.Panel_chip:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(beginLicensingCards)))

	-- self:playSendCards();

end


--开始下注
function TableLayer:onBeginBet(msg)


	--开始下注的人
	self.m_wTurnSeat = msg.iOutDeskStation;
	--庄家位置
	self.m_wBankerSeat = msg.bNtPeople;
	self.m_iLeftTime = self.m_nDealTime;

	--首先出牌玩家
	self.m_bFirstBetSeat = true;
	self:turnPlayerDeal(self.m_wTurnSeat,self.m_nDealTime, self.m_iLeftTime)
end


--玩家下注  弃牌
function TableLayer:onPlayerBet(msg)
	local opType = msg.iVerbType;	--操作类型
	local lSeat = msg.iOutPeople;	--操作玩家者
	local nChip = msg.iCurNote;	--当前玩家下注数

	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);

	if opType == GameMsg.TYPE_NOTE or opType == GameMsg.TYPE_ADD or opType == GameMsg.TYPE_FOLLOW then
		local checked = self.m_bPlayerCheckedTb[vSeat];

		if opType == GameMsg.TYPE_ADD then
			local sexStr = self:sexOfSeat(vSeat);
			-- local index = math.random(1,100);
			-- --取消 来点压力再加注
			-- index = index%4 + 1;
			-- if index == 2 then
			-- 	index = 1
			-- end

			local str = string.format("sanzhangpai/sound/%s/Add_01.mp3",sexStr);
			-- local str = string.format("sanzhangpai/sound/%s/Add_0%d.mp3",sexStr,index);
			-- luaPrint("luaPrint play add_str:",str);
			if self.m_bEffectOn then
	        	playEffect(str, false);
	        end
	    elseif opType == GameMsg.TYPE_FOLLOW then
	    	local sexStr = self:sexOfSeat(vSeat);
			local index = math.random(1,100);
			index = index%3 + 1;
			local str = string.format("sanzhangpai/sound/%s/Call_0%d.mp3",sexStr,index);
			-- luaPrint("luaPrint play TYPE_FOLLOW:",str);
			if self.m_bEffectOn then
	        	playEffect(str, false);
	        end


		end




		if checked then
			self.m_lSingleChip = nChip*0.5;
		else
			self.m_lSingleChip = nChip;
		end

		if opType == GameMsg.TYPE_ADD then
			self:disableRaseBtn();
		end


		self:showBubbleTip(vSeat, opType);
		self:addPlayerChip(vSeat, nChip);
		self:updatePlayerCoin(vSeat);
		self:updatePlayerChip(vSeat);

		
		self:stopPlayerTimer(vSeat);

		local pos = self:getBagPosbySeat(vSeat);
		self:addPlist();
		self.m_coinView:betMoveCoin(nChip, pos);

	elseif opType == GameMsg.TYPE_GIVE_UP then  --弃牌

		
		local sexStr = self:sexOfSeat(vSeat);
		local index = math.random(1,100);
		index = index%5 + 1;
		local str = string.format("sanzhangpai/sound/%s/Quit_0%d.mp3",sexStr,index);
		--luaPrint("luaPrint play TYPE_GIVE_UP:",str);
		if self.m_bEffectOn then
        	playEffect(str, false);
        end

	    --玩家强制离开 状态不改变
		if self.m_iPlayerStatusTb[vSeat] ~= Common.STATUS_IDLE then
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_FOLDED;
		end

		if self:isMeSeat(vSeat) then
			self.m_bFolded = true;
			self.m_iSelfStatus = Common.STATUS_FOLDED;
			self:resetOpButton();
			self:hideCompSelect();

			self:removeCardKind(vSeat);
			self:removeCardKindAnim(vSeat);
			self.Panel_continue:setVisible(true);
		else
			local vTurnSeat = self.tableLogic:logicToViewSeatNo(self.m_wTurnSeat);
			if self:isMeSeat(vTurnSeat) then
				local count = 0;
				for k,v in pairs(self.m_iPlayerStatusTb) do
					if v == Common.STATUS_PLAYING then
						count = count + 1;
					end
				end

				self.Button_allIn:setVisible(count == 2 and self.m_iNowRound >= CHECK_ROUND);
				self.Button_allIn:setEnabled(count == 2 and self.m_iNowRound >= CHECK_ROUND);
			end
		end

		
		-- self.m_iPlayerStatusTb[vSeat] = Common.STATUS_FOLDED;

		self:stopPlayerTimer(vSeat);

		self:showBubbleTip(vSeat, Common.TIP_FOLD);
		self:showPlayerFold(vSeat);
		--移除弃牌中的玩家
		self:removeCompSeat();


	
	elseif opType == GameMsg.TYPE_NOTE_ALL then   --全下
		local checked = self.m_bPlayerCheckedTb[vSeat];

		-- if checked then
		-- 	self.m_lSingleChip = nChip*0.5;
		-- else
		-- 	self.m_lSingleChip = nChip;
		-- end
		if self.m_bEffectOn then
			local sexStr = self:sexOfSeat(vSeat);
			local str = string.format("sanzhangpai/sound/%s/showhand.mp3",sexStr);
        	playEffect(str, false);
        end

        if self.m_iPlayerStatusTb[vSeat] ~= Common.STATUS_IDLE then
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_ALLIN;
		end

        if lSeat == self.tableLogic._mySeatNo then
			-- audio.pauseMusic();
			playMusic("sanzhangpai/sound/newbgm.mp3",true)
			self.AllinEffect = true--audio.playSound("sanzhangpai/sound/newbgm.mp3",true);
		end
		if self:isMeSeat(vSeat) then
			self:resetOpButton();
			self:hideCompSelect();
			self.m_iSelfStatus = Common.STATUS_ALLIN;
		end

		self:showBubbleTip(vSeat, Common.TIP_ALLIN);
		
		if vSeat == 0 then
			self:showPlayerAllinAnim(vSeat);
		end

		self:addPlayerChip(vSeat, nChip);
		self:updatePlayerCoin(vSeat);
		self:updatePlayerChip(vSeat);

		self:stopPlayerTimer(vSeat);

		local pos = self:getBagPosbySeat(vSeat);
		self:addPlist();
		self.m_coinView:betMoveCoin(nChip, pos);




	end

	self:resetTableInfo();


	

end


--通知玩家下注
function TableLayer:onTurnPlayerBet(msg)
	-- {"bCountNotePeople","BYTE"},		--当前未放弃玩家数
	-- {"bAddTime","INT"},					--押注次数

	-- {"iNowBigNoteStyle","BYTE"},		--当前最大下注类型
	-- {"iNowBigPeople","BYTE"},			--最大玩家
	-- {"iOutPeople","BYTE"},				--下注者

	-- {"iNowBigNote","INT"},				--当前最大下注
	-- {"iTotalNote","INT"},				--总下注
	-- {"iUserStation","INT["..PLAY_COUNT.."]"},		--玩家状态
	-- {"iFirstOutPeople","INT"},			--第一位置玩家

	-- {"iUserNote","LLONG["..PLAY_COUNT.."]"},			--用户本轮下注
	-- {"bIsFirstNote","BOOL"},			--
	local playerCount = msg.bCountNotePeople; --当前未放弃玩家数
	local round = msg.iNoteGroup;				--当前轮数
	
	local iNowBigNoteStyle = msg.iNowBigNoteStyle;	--当前最大下注类型
	local iNowBigPeople = msg.iNowBigPeople;		--最大玩家
	local iOutPeople = msg.iOutPeople;			--下注者
	local iNowBigNote = msg.iNowBigNote;		--当前最大下注
	local iTotalNote =	msg.iTotalNote;			--当前最大注数
	local iUserStation = msg.iUserStation;		--玩家状态
	local iFirstOutPeople = msg.iFirstOutPeople;	--第一位置玩家
	local iUserNote	= msg.iUserNote;			--用户本轮下注
	local bIsFirstNote = msg.bIsFirstNote;			--是否首先出牌
	local bForceCompare = msg.bForceCompare;		--是否强制比牌

	self.m_bOnlyFollow = msg.bForceFollow; --最后一轮 最后一个玩家只能跟注

	self.m_iNowRound = msg.iNoteGroup;
	self.m_bFirstBetSeat = msg.bIsFirstNote;
	-- self.m_lSingleChip = msg.iNowBigNote;  --当前最大注数 xxxx
	self.m_lTotalChip = msg.iTotalNote;	--当前最大注数
	self.m_wTurnSeat  = msg.iOutPeople;	--下注者
	self:resetTableInfo();
	
	self.m_iLeftTime = self.m_nDealTime;
	--上一个玩家下注类型 是否全下
	if iNowBigNoteStyle == GameMsg.TYPE_NOTE_ALL then

		self:turnPlayerAllIn(self.m_wTurnSeat,self.m_nDealTime, self.m_iLeftTime);
		return;
	end

	--金币不够  强制比牌
	if bForceCompare then
		self:turnPlayerForceComp(self.m_wTurnSeat,self.m_nDealTime, self.m_iLeftTime);
		return;
	end

	
	self:turnPlayerDeal(self.m_wTurnSeat,self.m_nDealTime, self.m_iLeftTime);


end


--玩家看牌消息
function TableLayer:onPlayerCheck(msg)
	local lSeat = msg.bDeskStation;
	local cardData = msg.iUserCard;
	local bForceCompare = msg.bForceCompare;
	local iCardKind = msg.bCardShape;	--牌型
	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
	self.m_bPlayerCheckedTb[vSeat] = true;
	if self:isMeSeat(vSeat) then
		self.m_bChecked = true;
		self.m_HandCardTb = cardData;
		self.Button_check:setEnabled(false);
		
		self:updateRasieBtns();

		if bForceCompare then
			self:turnPlayerForceComp(lSeat, 0, 0,true)
		end

		self:showCardKind(vSeat,iCardKind);
		if vSeat == 0 then
			-- self:showCardKindAnim(vSeat,iCardKind);
		end
	else
		
	end
	
	
	self:showPlayerCheck(vSeat,true);
	

	

end


--请求比牌消息
function TableLayer:onReqCompare(msg)
	local lSeat = msg.bDeskStation;
	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);

	self:showPlayerTimer(vSeat, self.m_nCompTime, self.m_nCompTime);
	if self:isMeSeat(vSeat) then
		self:showCompSelect();
	end


end


--比牌结果消息
function TableLayer:onCompResult(msg)
	-- local timeStr = os.time();
	-- luaPrint("TIME_onCompResult-------------:",timeStr);

	local fighter = msg.iNt; --挑战者
	local defender = msg.iNoNt --被挑战者
	local loster = msg.iLoster;
	local winner = msg.bWinner;
	local flag = msg.flag; --比牌类型

	local costChip = msg.iCurNote;  --比牌花费筹码
	local iNote = msg.iNote;
	local bGameFinish = msg.bGameFinish;

	local message = {};
	message.fighter = self.tableLogic:logicToViewSeatNo(fighter);
	message.defender = self.tableLogic:logicToViewSeatNo(defender);
	message.loster = self.tableLogic:logicToViewSeatNo(loster);
	message.winner = self.tableLogic:logicToViewSeatNo(winner);


	if flag == 1 then --强制比牌 ()
		message.costChip = costChip;
	elseif flag == 2 then --全自动比牌 （全下比牌）
		message.costChip = 0;
	elseif flag == 0 then 	--正常比牌
		message.costChip = costChip;   
		--更新总下注
		-- self.m_lTotalChip = self.m_lTotalChip + costChip;
	end
	


	if loster >= 0 and loster < 5 then
		self.m_iPlayerStatusTb[message.loster] = Common.STATUS_LOST;
		self.m_bPlayerLostTb[message.loster] = true;
	end

	
	self:resetTableInfo();


	if self:isMeSeat(message.loster) then
		self.m_iSelfStatus = Common.STATUS_LOST;
		self.m_bLosted = true;
	end


	self:hideCompSelect();
	self:playCompAnim(message);



	-- {"iNt","BYTE"},	--比牌者
	-- {"iNoNt","BYTE"},	--比牌者
	-- {"iLoster","BYTE"},	--败者
	-- {"bWinner","BYTE"},	--胜利者，若比牌结束后，下一家马上达到下注上限，则此时客户端需要知道胜利者是谁

	-- {"iCurNote","INT"},	--当前玩家比牌下的下注数
	-- {"iNote","INT"},	 --当前有效注数
	-- {"bGameFinish","BOOL"},

end




--游戏结束消息
function TableLayer:onGameEnd(msg)
	-- local handcards = msg.bCard;   --玩家手牌
	-- local timeStr = os.time(); --1532597212
	-- luaPrint("TIME_onGameEnd-------------:",timeStr);

	local winCoins = msg.iTurePoint;	--玩家得分
	local bAutoGiveUp = msg.bAutoGiveUp;
	-- self:setAllHandCards(handcards);
	
	self.m_bGiveUp = bAutoGiveUp;
	local winSeat = nil;

	local winCoinTb = {};
	for k,v in pairs(winCoins) do
		local index = k - 1;
		if v ~= 0 then
			local vSeat = self.tableLogic:logicToViewSeatNo(index);
			winCoinTb[vSeat] = v;
			if v > 0 then
				winSeat = vSeat;
			end
		end
	end

	local message = {};
	message.winCoinTb = clone(winCoinTb);
	message.winSeat = winSeat;
	message.bAutoGiveUp = bAutoGiveUp; --是否未操作
	message.iHandCard = msg.iHandCard;  --玩家手牌
	message.nWinTime = msg.nWinTime;	--连胜局数

	--重置玩家状态
	-- luaDump(self.m_iPlayerStatusTb, "self.m_iPlayerStatusTb----------------1", 5)
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		if self.m_iPlayerStatusTb[vSeat] ~= Common.STATUS_IDLE then  --未离开的玩家都重置为等待
			self.m_iPlayerStatusTb[vSeat] = Common.STATUS_WAITING;
		end
	end

	-- luaDump(self.m_iPlayerStatusTb, "self.m_iPlayerStatusTb----------------2", 5)

	--玩家自己的状态  等待
	self.m_iSelfStatus = Common.STATUS_WAITING;


	--桌子状态
	self.m_iTableStatus = Common.STATUS_IDLE;

	self:resetOpButton();	
	self:stopAllPlayerTimer();
	self:hideCompSelect();
	self:playGameResult(message);
	self:removeWaiting();
    self:leaveDeskSsz();
	-- self:resetGameData();


end


--玩家亮牌消息
function TableLayer:onEvealCards(msg)
	local lSeat = msg.bDeskStation;
	local cards = msg.iUserCard;
	local iKind = msg.bCardShape; --牌型
	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
	if self:isMeSeat(vSeat) then
		self.Button_eveal:setVisible(false);
		self:stopPlayerTimer(vSeat);
	end

	self:showBubbleTip(vSeat,Common.TIP_CARD);
	self:playerEvealCards(vSeat, cards);

	self:showCardKindAnim(vSeat, iKind,true);
	if vSeat == 0 then
		local tag1 = self:getCardTag(vSeat, TAG_FOLD);  --弃牌or比牌输
		local img = self.Panel_cards:getChildByTag(tag1);
		if img == nil then 
			self:showCardKind(vSeat, iKind);	--显示牌型
		end
	end
	

end


--全局比牌
function TableLayer:onAllCompare(msg)
	local message = {};
	message.winTb = {};
	message.lostTb = {};
	for seat,v in pairs(msg.bWin) do
		local lSeat = seat - 1;
		if v ~= INVALID_CHAIR then
			local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
			if v == 1 then  --win
				table.insert(message.winTb,vSeat);
			elseif v == 0 then
				table.insert(message.lostTb,vSeat);
			end
		end
	end

	self:playAllCompare(message);
end

--比牌玩家亮牌消息
function TableLayer:onOpponentCards(msg)
	-- luaDump(msg.iCards, "---------------msg_onOpponentCards------------------", 5)
	local iCards = msg.iCards;
	local iCardKinds = msg.bCardShapes;

	for k,v in pairs(iCards) do
		local lSeat = k - 1;
		local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
		local cards = v;
		if cards[1] ~= 0 then
			self:showOpponentCards(vSeat, cards);
		end
	end

	for i,v in ipairs(iCardKinds) do
		local lSeat = i - 1;
		local iKind = v;
		local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
		if vSeat == 0 then
			self:showCardKind(vSeat, iKind);
			-- self:showCardKindAnim(vSeat, iKind, true);
		end
		-- self:showCardKindAnim(vSeat, iKind, true);
	end



end

--自动跟注
function TableLayer:onAutoFollow(msg)
	local bFollow = msg.bAutoFollow;
	self.m_bAutoBet = msg.bAutoFollow;

	--自动跟注
	self.Button_auto:setEnabled(not self.m_bAutoBet);
	
	self.Button_auto:setVisible(not self.m_bAutoBet);

	--跟到底取消
	self.Button_unAuto:setEnabled(self.m_bAutoBet);
	
	self.Button_unAuto:setVisible(self.m_bAutoBet);
	

end



function TableLayer:setAllHandCards(cards)
	for k,v in pairs(cards) do
		local index = k - 1;
		self.m_AllHandCardTb[index] = v;
	end
end


function TableLayer:resetAllHandCards()
	for k,v in pairs(self.m_AllHandCardTb) do
		self.m_AllHandCardTb[k] = {};
	end
end




function TableLayer:resetGameData()
	--当前桌子总下注
    self.m_lTotalChip = 0;
    --最大轮数
    self.m_iMaxRound = 20;
    --玩家自己是否跟到底状态
    self.m_bAutoBet = false;
    --玩家自己看牌状态
    self.m_bChecked = false;

    --玩家底注
    self.m_lSingleChip = self.m_lBaseChip;
    --重置玩家看牌状态
    for k,v in pairs(self.m_bPlayerCheckedTb) do
    	self.m_bPlayerCheckedTb[k] = false;
    end
    --玩家下注
    for k,v in pairs(self.m_lPlayerChipTb) do
    	self.m_lPlayerChipTb[k] = 0;
    end
    --每个玩家的当前状态
    for k,v in pairs(self.m_iPlayerStatusTb) do
    	self.m_iPlayerStatusTb[k] = Common.STATUS_IDLE;
    end
    --每个玩家是否弃牌
    for k,v in pairs(self.m_bPlayerFoldedTb) do
    	self.m_bPlayerFoldedTb[k] = false;
    end
    --是否比牌输
    for k,v in pairs(self.m_bPlayerLostTb) do
    	self.m_bPlayerLostTb[k] = false;
    end

    --是否坐下
    for k,v in pairs(self.m_SeatDownTb) do
    	self.m_SeatDownTb[k] = false;
    end

    --玩家自己是否跟到底状态
    self.m_bAutoBet = false;
    --是否消息处理中
    self.m_bRunAction = false;
    --游戏消息队列
    -- self.m_gameMsgArray = {};
    --玩家当前牌桌状态
    self.m_iSelfStatus = Common.STATUS_IDLE;
    --玩家是否看牌
    self.m_bChecked = false;
    --玩家是否弃牌
    self.m_bFolded = false;
    --玩家比牌输
    self.m_bLosted = false;


    --玩家手牌
    self.m_HandCardTb = {0,0,0};
    --所有玩家手牌
    self.m_AllHandCardTb = {};

    --是否轮到自己
    self.m_bSelfTurning = false;

   	--轮数
   	self.m_iNowRound = 0;

   	 --是否只能跟注
    self.m_bOnlyFollow = false;
   	-- self.m_bGiveUp = false;

    -- self.Panel_anims:stopAllActions();
    -- self.Panel_anims:removeAllChildren();

    -- self.Panel_compare:stopAllActions();
    -- self.Panel_compare:removeAllChildren();

    -- self.Panel_result:stopAllActions();
    -- self.Panel_result:removeAllChildren();

    -- self:hideCompSelect();
    -- self:removeAllSeatCards();

    -- self.m_coinView:removeAllCoin();
    -- self.Button_eveal:setVisible(false);


end

--重置牌桌玩家下注
function TableLayer:resetPlayerChip()
	for vSeat,v in pairs(self.m_lPlayerChipTb) do
		self.Text_chipTb[vSeat]:setString(GameMsg.formatCoin(self.m_lPlayerChipTb[vSeat]));
	end
	
end

--更新玩家金币
function TableLayer:resetPlayerCoin()
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		if v ~= Common.STATUS_IDLE then
			local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
			local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
			-- luaDump(userInfo, "resetPlayerCoin_vSeat_"..vSeat, 4)
			if userInfo then
				self.m_lPlayerCoin[vSeat] = userInfo.i64Money;
				if self:isMeSeat(vSeat) then
					self.m_lSelfScore = userInfo.i64Money;
				end
				self.Text_coinTb[vSeat]:setString(GameMsg.formatCoin(self.m_lPlayerCoin[vSeat]));
			end
		end		
	end
end


--重置牌桌
function TableLayer:resetTableCards()
	self.Panel_cards:removeAllChildren();
end

--重置气泡
function TableLayer:resetBubbleTip()
	for vSeat,v in pairs(self.Panel_speakTb) do
		self.Panel_speakTb[vSeat]:setVisible(false);
	end

	for vSeat,v in pairs(self.Image_speakTb) do
		self.Image_speakTb[vSeat]:stopAllActions();
		self.Image_speakTb[vSeat]:setVisible(false);
	end
	
end

--清除桌子
function TableLayer:clearTable()
	self.Button_ready:setVisible(false);
	self.Button_eveal:setVisible(false);
	self.Panel_countdown:setVisible(false);
	--重置牌桌数据
	self:resetGameData();
	--清除泡泡消息
	self:resetBubbleTip();
	--清除桌面扑克
	self:resetTableCards();
	--重置玩家下注筹码
	self:resetPlayerChip();
	--重置桌面信息
	self:resetTableInfo();
	--重置玩家操作按钮
	self:resetOpButton();
	--恢复玩家头像
	self:resetPlayerNormal();
	--重置加注按钮
	self:updateRasieBtns();
	self:resetRaseBtns();
	--清除桌子
	self:resetTablePanel();

	self:resetPlayerCoin();
	self:removeWaiting();
	--
	self:hideCompSelect();

	self:hideReady();

	self:clearAllPlayerAllinAnim();

end






--设置房间筹码配置
function TableLayer:initBetConfig()

	-- for i,tb in ipairs(Common.BetTb) do
	-- 	if self.m_nMaxBet == tb[5] then
	-- 		--房间筹码配置
 --    		self.m_nBetConfigTb = clone(tb);
	-- 	end
	-- end
	local index = 1;
	for i,v in ipairs(Common.BetBase) do
		if v == self.m_lBaseChip then
			index = i;
			break;
		end
	end



	self.m_nBetConfigTb = clone(Common.BetTb[index]);

	-- luaDump(self.m_nBetConfigTb, "init_self.m_nBetConfigTb", 4)

	self.level_rases = {}
  	self.level_rases[self.m_lBaseChip] = 1

	for i,v in ipairs(self.m_nBetConfigTb) do
  		if not self.level_rases[v] then
  			self.level_rases[v] = table.nums(self.level_rases)+1
  		end
  	end

  	for i,v in ipairs(self.m_nBetConfigTb) do
  		if not self.level_rases[v*2] then
  			self.level_rases[v*2] = table.nums(self.level_rases)+1
  		end
  	end
  	self.m_coinView:setLevelRase(self.level_rases);

  	-- luaDump(self.level_rases, "self.level_rases----init", 4)
  	-- luaDump(self.m_nBetConfigTb, "self.m_nBetConfigTb----init", 4)
  	
  	self:updateRasieBtns();
end


--隐藏所有的准备标志
function  TableLayer:hideReady()
	for k,v in pairs(self.Image_readyTb) do
		v:setVisible(false);
	end
	self.Button_ready:setVisible(false);


end

--更新桌子信息
function TableLayer:resetTableInfo()

	--桌子总下注
	self.Text_jettonTotal:setString(GameMsg.formatCoin(self.m_lTotalChip));
	--底注
	self.Text_baseJetton:setString(GameMsg.formatCoin(self.m_lBaseChip));
	--单注
	self.Text_singleJetton:setString(GameMsg.formatCoin(self.m_lSingleChip));
	--轮数	
	self.Text_round:setString(string.format("%d/%d",self.m_iNowRound,self.m_iMaxRound ));
end




function TableLayer:resetOpButton()
	--跟到底
	self.Button_auto:setEnabled(false);
	
	self.Button_auto:setVisible(true);
	--跟到底取消
	self.Button_unAuto:setEnabled(false);
	
	self.Button_unAuto:setVisible(false);
	--弃牌
	self.Button_fold:setEnabled(false);
	
	--比牌
	self.Button_compare:setEnabled(false);
	
	--看牌
	self.Button_check:setEnabled(false);
	
	--加注
	self.Button_raise:setEnabled(false);
	
	--下注
	self.Button_bet:setEnabled(false);
	
	--跟注
	self.Button_follow:setEnabled(false);
	
	self.Button_follow:setVisible(true);
	--全下ALL IN
	self.Button_allIn:setEnabled(false);
	
	self.Button_allIn:setVisible(false);
	--加注界面
	self.Panel_raise:setVisible(false);
	--亮牌
	self.Button_eveal:setVisible(false);
end

--开启
function TableLayer:enableOpButton() 
	--跟到底
	self.Button_auto:setEnabled(true);
	
	--跟到底取消
	self.Button_unAuto:setEnabled(false);
	
	self.Button_unAuto:setVisible(false);
	--弃牌
	self.Button_fold:setEnabled(true);
	
	--比牌
	self.Button_compare:setEnabled(true);
	
	--看牌
	self.Button_check:setEnabled(true);
	
	--加注
	self.Button_raise:setEnabled(true);
	
	--下注
	self.Button_bet:setEnabled(true);
	
	--跟注
	self.Button_follow:setEnabled(false);
	
	self.Button_follow:setVisible(false);
	--全下ALL IN
	self.Button_allIn:setEnabled(false);
	
	self.Button_allIn:setVisible(false);
	--加注界面
	self.Panel_raise:setVisible(false);
end


--显示庄家标志
function TableLayer:showBankerIcon()
	local vSeat = self.tableLogic:logicToViewSeatNo(self.m_wBankerSeat);
	for k,v in pairs(self.Image_bankerTb) do
		v:setVisible(k == vSeat);
	end
end


--玩家强制比牌
function TableLayer:turnPlayerForceComp(lSeat,allDt,leftDt,bContinueTime)

	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
	
	if bContinueTime == nil then
		self:showPlayerTimer(vSeat,allDt, leftDt);	
	end
	
	if self:isMeSeat(vSeat) then
		self.m_bSelfTurning = true;
		-- self.m_bAutoBet = false;
		
		self.Button_compare:setEnabled(true);
		
		--弃牌
		self.Button_fold:setEnabled(true);
		

		--看牌
		-- self.Button_check:setEnabled(false);
		if self.m_bChecked then
			self.Button_check:setEnabled(false);
		else
			self.Button_check:setEnabled(self.m_iNowRound >= CHECK_ROUND);			
		end



		--自动跟注
		self.Button_auto:setEnabled(false);
		
		self.Button_auto:setVisible(true);

		--跟到底取消
		self.Button_unAuto:setEnabled(self.m_bAutoBet);
		
		self.Button_unAuto:setVisible(false);
		
		--加注
		self.Button_raise:setEnabled(false);
		

		--下注
		self.Button_bet:setEnabled(false);  --是否首位说话
		
		self.Button_bet:setVisible(false);
		--跟注
		self.Button_follow:setEnabled(false);
		
		self.Button_follow:setVisible(true);

		local count = 0;
		for k,v in pairs(self.m_iPlayerStatusTb) do
			if v == Common.STATUS_PLAYING then
				count = count + 1;
			end
		end

		--全下
		self.Button_allIn:setVisible(count == 2 and self.m_iNowRound >= CHECK_ROUND);
		self.Button_allIn:setEnabled(count == 2 and self.m_iNowRound >= CHECK_ROUND);
	else
		self:turnOtherOp(vSeat)
	end

end


--全下轮到玩家操作
function TableLayer:turnPlayerAllIn(lSeat,allDt,leftDt)
	
	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
	self:showPlayerTimer(vSeat,allDt, leftDt);
	
	if self:isMeSeat(vSeat) then

		if self.m_bEffectOn then
        	playEffect("sanzhangpai/sound/lottery_xz_start.mp3", false);
        end

		
		self.m_bSelfTurning = true;
		-- self.m_bAutoBet = false;
		
		self.Button_compare:setEnabled(false);
		
		--弃牌
		self.Button_fold:setEnabled(true);
		

		--看牌
		if self.m_bChecked then
			self.Button_check:setEnabled(false);
			
		else
			self.Button_check:setEnabled(self.m_iNowRound >= CHECK_ROUND);
			
		end


		--自动跟注
		self.Button_auto:setEnabled(false);
		
		self.Button_auto:setVisible(true);

		--跟到底取消
		self.Button_unAuto:setEnabled(self.m_bAutoBet);
		
		self.Button_unAuto:setVisible(false);
		
		--加注
		self.Button_raise:setEnabled(false);
		

		--下注
		self.Button_bet:setEnabled(false);  --是否首位说话
		
		self.Button_bet:setVisible(false);
		--跟注
		self.Button_follow:setEnabled(false);
		
		self.Button_follow:setVisible(true);

		--全下
		self.Button_allIn:setVisible(true);
		
		self.Button_allIn:setEnabled(true);

	else
		self:turnOtherOp(vSeat);
	end

end


--显示玩家操作
function TableLayer:turnPlayerDeal(lSeat,allDt,leftDt)
	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
	
	self:stopAllPlayerTimer();
	self:showPlayerTimer(vSeat,allDt, leftDt);

	if self:isMeSeat(vSeat) then
		self:turnSelfOp();
	else
		self:turnOtherOp();
	end
	
end

--轮到自己的菜单
function TableLayer:turnSelfOp()
	--比

	self.m_bSelfTurning = true;

	if self.m_bAutoBet then
		-- self:autoDelayTimeBet();
	end


	if self.m_bEffectOn then
    	playEffect("sanzhangpai/sound/lottery_xz_start.mp3", false);
    end
	
	
	--弃牌
	self.Button_fold:setEnabled(true);
	
	--看牌
	if self.m_bChecked then
		self.Button_check:setEnabled(false);
		
	else
		self.Button_check:setEnabled(self.m_iNowRound >= CHECK_ROUND);
		
	end

	--自动跟注
	self.Button_auto:setEnabled(not self.m_bAutoBet);
	
	self.Button_auto:setVisible(not self.m_bAutoBet);

	--跟到底取消
	self.Button_unAuto:setEnabled(self.m_bAutoBet);
	
	self.Button_unAuto:setVisible(self.m_bAutoBet);
	
	-- if self.Button_unAuto:isVisible() then
	-- 	self.Button_compare:setEnabled(false);
	-- else
	-- 	self.Button_compare:setEnabled(self.m_iNowRound >= COMPARE_ROUND);
	-- end

	self.Button_compare:setEnabled(self.m_iNowRound >= COMPARE_ROUND);
	
	--加注
	-- self.Button_raise:setEnabled(true);
	self.Button_raise:setEnabled(self.m_nMaxBet > self.m_lSingleChip and not self.m_bOnlyFollow);


	--下注
	self.Button_bet:setEnabled(self.m_bFirstBetSeat);  --是否首位说话
	
	self.Button_bet:setVisible(self.m_bFirstBetSeat);
	--跟注
	self.Button_follow:setEnabled(not self.m_bFirstBetSeat);
	
	self.Button_follow:setVisible(not self.m_bFirstBetSeat);
	
	local count = 0;
	for k,v in pairs(self.m_iPlayerStatusTb) do
		if v == Common.STATUS_PLAYING then
			count = count + 1;
		end
	end


	-- luaPrint("count = ",count)
	-- luaDump(self.m_iPlayerStatusTb, "-----self.m_iPlayerStatusTb-----", 5);
	self.Button_allIn:setVisible(count == 2 and self.m_iNowRound >= CHECK_ROUND and not self.m_bOnlyFollow);
	
	self.Button_allIn:setEnabled(count == 2 and self.m_iNowRound >= CHECK_ROUND and not self.m_bOnlyFollow);

end


function TableLayer:turnOtherOp(vSeat)
	self.m_bSelfTurning = false;

	if self.m_iSelfStatus ~= Common.STATUS_PLAYING then
		luaPrint("turnOtherOp self.m_iSelfStatus=====",self.m_iSelfStatus)
		self:resetOpButton();
		return;
	end

	if self.m_bLosted then
		luaPrint("turnOtherOp self.m_bLosted=====",self.m_bLosted)
		self:resetOpButton();
		return;
	end
	--弃牌
	if self.m_bFolded then
		luaPrint("turnOtherOp self.m_bFolded=====",self.m_bFolded)
		self:resetOpButton();
		return;
	end

	--自动跟注
	self.Button_auto:setEnabled(not self.m_bAutoBet);
	
	self.Button_auto:setVisible(not self.m_bAutoBet);

	--跟到底取消
	self.Button_unAuto:setEnabled(self.m_bAutoBet);
	
	self.Button_unAuto:setVisible(self.m_bAutoBet);

	--比牌
	self.Button_compare:setEnabled(false);
	
	--弃牌
	if self.m_iSelfStatus == Common.STATUS_ALLIN then
		self.Button_fold:setEnabled(false);
	else
		self.Button_fold:setEnabled(true);
	end
	
	
	--看牌
	if self.m_bChecked then
		self.Button_check:setEnabled(false);
		
	else
		self.Button_check:setEnabled(self.m_iNowRound >= CHECK_ROUND);
		
	end

	--加注
	self.Button_raise:setEnabled(false);
	
	--下注
	self.Button_bet:setEnabled(false);  --是否首位说话
	
	self.Button_bet:setVisible(false);
	--跟注
	self.Button_follow:setEnabled(false);
	
	self.Button_follow:setVisible(true);

	local count = 0;
	for k,v in pairs(self.m_iPlayerStatusTb) do
		if v == Common.STATUS_PLAYING then
			count = count + 1;
		end
	end

	self.Button_allIn:setVisible(count == 2 and self.m_iNowRound >= CHECK_ROUND);
	self.Button_allIn:setEnabled(false);

end


--显示全下特效
function TableLayer:showPlayerAllinAnim(vSeat)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerAllinAnim error vSeat:",vSeat);
		return;
	end
	local size = self.Panel_PlayerTb[vSeat]:getContentSize();
	self.Panel_PlayerTb[vSeat]:removeChildByName("Skeleton_Allin")
	local skeleton_animation = createSkeletonAnimation(AllinAnim.name,AllinAnim.json,AllinAnim.atlas);
	if skeleton_animation then
		skeleton_animation:setAnimation(0,AllinAnimName, true);
		self.Panel_PlayerTb[vSeat]:addChild(skeleton_animation);
		skeleton_animation:setPosition(cc.p(size.width*0.5,size.height*0.5));
		
		skeleton_animation:setName("Skeleton_Allin");
	end
	
end

--清除全下特效
function TableLayer:clearPlayerAllinAnim(vSeat)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerAllinAnim error vSeat:",vSeat);
		return;
	end

	self.Panel_PlayerTb[vSeat]:removeChildByName("Skeleton_Allin");
end

--清除所有全下特效
function TableLayer:clearAllPlayerAllinAnim()
	
	for k,v in pairs(self.Panel_PlayerTb) do
		v:removeChildByName("Skeleton_Allin");
	end
	
end



function TableLayer:showPlayerTimer(vSeat,allDt,leftDt,bWarning)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerTimer---------vSeat "..vSeat.."is not valid+++++++++++++++++++++++++++!")
		return ;	
	end


	if not allDt then
		allDt = self.m_nDealTime
	end

	if TABLE_SELF == vSeat then
		--play turn sound
	end

	self.Progerss_timerTb[vSeat]:stopAllActions()
	self.Progerss_timerTb[vSeat]:setVisible(false)
	local percent_begin = math.ceil(leftDt*100/allDt)
	local progress = cc.ProgressFromTo:create(leftDt,percent_begin,0)
	self.Progerss_timerTb[vSeat]:runAction(progress);
	self.Progerss_timerTb[vSeat]:setVisible(true);

	--增加倒计时
	self.Image_progressTb[vSeat]:stopAllActions();
	if bWarning == nil then
		if 0 == vSeat then
			for i=1,3 do
				local dt = leftDt - 3 + i-1;
				if dt >= 0 then
					self.Image_progressTb[vSeat]:runAction(cc.Sequence:create(cc.DelayTime:create(dt),cc.CallFunc:create(function()
					      audio.playSound("sound/daojishi.mp3",false);
					    end))) 
				
				end
			end
		end
	end
	

end


function TableLayer:stopPlayerTimer(vSeat)
	self.Progerss_timerTb[vSeat]:stopAllActions()
	self.Progerss_timerTb[vSeat]:setVisible(false)

	--增加倒计时
	self.Image_progressTb[vSeat]:stopAllActions();
end

function TableLayer:stopAllPlayerTimer()
	for i=1,5 do
		self:stopPlayerTimer(i-1);
	end
	-- for k,v in pairs(self.Progerss_timerTb) do
	-- 	v:stopAllActions()
	-- 	v:setVisible(false)
	-- end
end

function TableLayer:showBubbleTip(vSeat,tipType)
	-- Common.TIP_ALLIN = 1;	--全下
	-- Common.TIP_RAISE = 2;	--加注
	-- Common.TIP_FOLLOW = 3;	--跟注
	-- Common.TIP_CHECK = 4;	--看牌
	-- Common.TIP_FOLD = 5;	--弃牌
	-- Common.TIP_CARD = 6;	--亮牌

	-- self:resetBubbleTip();
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerCheck---------vSeat "..vSeat.."is not valid+++++++++++++++++++++++++++!")
		return ;	
	end

	local img = self.Image_speakTb[vSeat];
	self.Image_speakTb[vSeat]:stopAllActions();
	self.Image_speakTb[vSeat]:setVisible(false);
	self.Panel_speakTb[vSeat]:setVisible(true);

	self.Image_speakTb[vSeat]:loadTexture(Common.TIP_RES[tipType],UI_TEX_TYPE_PLIST);
	local size = self.Image_speakTb[vSeat]:getContentSize();
	self.Image_speakTb[vSeat]:setPosition(cc.p(size.width*0.5,-size.height*0.5));

	local pos_t = cc.p(size.width*0.5,size.height*0.5);
	local showIt = cc.Show:create();
	local moveTo = cc.MoveTo:create(0.3,pos_t);
	local delayIt = cc.DelayTime:create(1.5)
	local fadeOut = cc.FadeOut:create(0.3)
	local hideIt = cc.Hide:create();	
	img:setOpacity(255);
	img:runAction(cc.Sequence:create(showIt,moveTo,delayIt,fadeOut,hideIt));



end



function TableLayer:showPlayerCheck(vSeat,bAnim)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerCheck---------vSeat "..vSeat.."is not valid+++++++++++++++++++++++++++!")
		return ;	
	end

	self:addPlist();
	

	if bAnim then
		local sexStr = self:sexOfSeat(vSeat);
		local index = math.random(1,100);
		index = index%3 + 1;
		local str = string.format("sanzhangpai/sound/%s/Look_0%d.mp3",sexStr,index);
		
		if self.m_bEffectOn then
        	playEffect(str, false);
        end

        self:showBubbleTip(vSeat, Common.TIP_CHECK);
	end

	if self:isMeSeat(vSeat) then
		if bAnim then
			self:turnOnCard(vSeat, self.m_HandCardTb,bAnim)
		else
			self:turnOnCard(vSeat, self.m_HandCardTb,false);
		end
		

	else
		local tag = self:getCardTag(vSeat,3);
		local card = self.Panel_cards:getChildByTag(tag);
		local pos = cc.p(card:getPosition());

		local img_check = ccui.ImageView:create("szp_kanpaixianshi.png",UI_TEX_TYPE_PLIST);
		if vSeat == 2 or vSeat == 3 then
			img_check:setScale(0.8);
		end
		img_check:setPosition(pos);
		local tag2 = self:getCardTag(vSeat,TAG_CHECK);
		img_check:setTag(tag2);
		self.Panel_cards:addChild(img_check);
	end
	
end


function TableLayer:turnOnCard(vSeat,cardData,bAnim)
	
	if bAnim then
		local CARD_SCALE = 1.0;
		local function turnCardBegin(card)   --耗时 0.4
	   		local function turnFrontCard(card)
	   			-- card:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("spz_0x%02X.png",card.id)));	
	   			
				card:loadTexture(string.format("szp_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
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
	   	end


		if self:isMeSeat(vSeat) then
			local posTb = self.m_posCardTb[vSeat];
			for k,v in pairs(cardData) do
				luaPrint("k----",k)
				if k > 0 and  k < 4 then
					local tag = self:getCardTag(vSeat,k);
					local card = self.Panel_cards:getChildByTag(tag);
					if card == nil then
						card = self:cardOfSeat(vSeat);
						card:setTag(self:getCardTag(vSeat,k));
						local scale = 1.0;
						if vSeat == 0 then
							scale = 1.0;
						elseif vSeat == 1 or vSeat == 4 then
							scale = 1.0;
						else
							scale = 0.73;
						end
						card:setScale(scale);
						card:setPosition(posTb[k]);
						self.Panel_cards:addChild(card);
					end

					card.id = v;
					turnCardBegin(card);	
				end
				
			end
		else


		end
	else
		if self:isMeSeat(vSeat) then
			local posTb = self.m_posCardTb[vSeat];
			for k,v in pairs(cardData) do
				luaPrint("k----",k)
				if k > 0 and  k < 4 then
					local tag = self:getCardTag(vSeat,k);
					local card = self.Panel_cards:getChildByTag(tag);
					if card == nil then
						card = self:cardOfSeat(vSeat);
						card:setTag(self:getCardTag(vSeat,k));
						local scale = 1.0;
						if vSeat == 0 then
							scale = 1.0;
						elseif vSeat == 1 or vSeat == 4 then
							scale = 1.0;
						else
							scale = 0.73;
						end
						card:setScale(scale);
						card:setPosition(posTb[k]);
						self.Panel_cards:addChild(card);
					end

					card.id = v;
					card:loadTexture(string.format("szp_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
				end
				
				
			end
		end
	end
	
end


--显示弃牌
function TableLayer:showPlayerFold(vSeat)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerFold---------vSeat "..vSeat.."is not valid+++++++++++++++++++++++++++!")
		return ;	
	end

	self:addPlist();
	if self:isMeSeat(vSeat) then
		local pos = cc.p(662,166);
		local img_fold = ccui.ImageView:create("szp_qipaixianshi.png",UI_TEX_TYPE_PLIST);
		self.Panel_cards:addChild(img_fold);
		img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
		img_fold:setPosition(pos);
	else
		self:removeSeatCard(vSeat);
		local img_fold = self.Image_foldCell:clone();
		img_fold:setVisible(true);
		
		local posTb = self.m_posCardTb[vSeat];
		local pos = posTb[2];
		-- local pos1 = self.Image_speakTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_speakTb[vSeat]:getPosition()));
		-- local pos = cc.p(pos1.x,self.Panel_speakTb[vSeat]:getPositionY() - 30);
		img_fold:setPosition(pos);
		img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
		self.Panel_cards:addChild(img_fold);

		if self.m_iPlayerStatusTb[vSeat]  == Common.STATUS_IDLE then
			img_fold:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.RemoveSelf:create()));
		end


	end

	self:setPlayerGray(vSeat,true);

end




--游戏结束结算
function TableLayer:playGameResult(msg)
	-- luaDump(msg, "playGameResult_msg", 5)
	--游戏结束10 秒

	if msg.bAutoGiveUp then
		self.Panel_continue:setVisible(true);
	else
		--self:autoSendReady(5);
	end
	

	local winSeat = msg.winSeat;
	local winCoinTb = msg.winCoinTb;

	-- local winPos = self:getBagPosbySeat(winSeat);
	-- self.m_coinView:coinMoveToWinner(winPos);
	 
	-- for vSeat,v in pairs(winCoinTb) do
	-- 	if self:isMeSeat(vSeat) then
	-- 		self.Button_eveal:setVisible(true);
	-- 	end
	-- end
	

	--显示玩家自己手牌
	if msg.iHandCard[1] > 0 then
		self.m_HandCardTb = msg.iHandCard;
		self:turnOnCard(0, self.m_HandCardTb,false);
	end
	



	local function showWinWord()
		

		for vSeat,v in pairs(winCoinTb) do
			-- local vSeat = self.tableLogic:logicToViewSeatNo(k);
			local skeleton_animation = nil;
			if v > 0 then
				skeleton_animation = createSkeletonAnimation(WinnerAnim.name,WinnerAnim.json,WinnerAnim.atlas);
				if skeleton_animation then
					skeleton_animation:setAnimation(0,WinnerAnimName, false);
				end
				
			elseif v < 0 then
				-- skeleton_animation = createSkeletonAnimation(LostAnim.name,LostAnim.json,LostAnim.atlas);
				-- skeleton_animation:setAnimation(0,LostAnimName, false);
			end

			if skeleton_animation then
				self.Panel_anims:addChild(skeleton_animation);
				if self.m_iPlayerStatusTb[vSeat]  == Common.STATUS_IDLE then
					skeleton_animation:setVisible(false);
				end

				if self.m_SeatDownTb[vSeat] == false then
					skeleton_animation:setVisible(false);
				end

				local pos = self.m_WinnerPosTb[vSeat];
				skeleton_animation:setPosition(pos);
				skeleton_animation:setTag(TAG_WIN_ANIM + vSeat);
			end
			
			local tagStr = "";
			if v >= 0 then
				tagStr = "+";
			end
			
			local winStr = GameMsg.formatCoin(v,tagStr);

			local winScore = ccui.TextAtlas:create(winStr, "sanzhangpai/image/szp_jiesuanzitiao1.png", 26, 50, "+");
			self.Panel_anims:addChild(winScore);
			local pos = self.m_WinCoinPosTb[vSeat];
			winScore:setPosition(pos)

			local moveByIt1 = cc.MoveBy:create(0.05,cc.p(0,-20));
			local moveByIt2 = cc.MoveBy:create(0.05,cc.p(0,15));
			local moveByIt3 = cc.MoveBy:create(0.05,cc.p(0,-10));
			local moveByIt4 = cc.MoveBy:create(0.05,cc.p(0,6));
			local moveByIt5 = cc.MoveBy:create(0.05,cc.p(0,-6));
			local seq = cc.Sequence:create(cc.Show:create(),moveByIt1,moveByIt2,moveByIt3,moveByIt4,moveByIt5,cc.DelayTime:create(1.5),cc.RemoveSelf:create());
			winScore:runAction(seq);

			local callFunc = cc.CallFunc:create(
					function()
						self:removeAllSeatCards();
						self.Button_eveal:setVisible(false);
						self:resetGameData();
						self:resetTableInfo();
						self:resetPlayerChip();
						self.Panel_anims:removeAllChildren();
					end
				);
			local seq2 = cc.Sequence:create(cc.DelayTime:create(4.5),callFunc);
			self.Panel_anims:runAction(seq2)

			--重置玩家金币
			local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
    		local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

    		if userInfo then
    			
    			self.m_lPlayerCoin[vSeat] = userInfo.i64Money;
    			if self:isMeSeat(vSeat) then
    			
    				self.m_lSelfScore = self.m_lPlayerCoin[vSeat];
    			end

    			if v > 0  then
    				if self:isMeSeat(vSeat) then
	    				if self.m_bEffectOn then
				            playEffect("sanzhangpai/sound/game_win.mp3", false);
				        end
	    			end
    			else
    				if self:isMeSeat(vSeat) then
	    				if self.m_bEffectOn then
				            playEffect("sanzhangpai/sound/game_lose.mp3", false);
				        end
	    			end
    			end
    			
        		self.Text_coinTb[vSeat]:setString(Common.getCoinStr(self.m_lPlayerCoin[vSeat]));
    		end
		end
		self.Panel_continue:setVisible(true)
	    self:startClock();
	end
	

	local function showEvealCards()
		for vSeat,v in pairs(winCoinTb) do
			if self:isMeSeat(vSeat) then
				--移除自己牌型提示
				-- self:removeCardKind(lostSeat);
 				--移除自己牌型特效提示 动画效果遮挡按钮
				self:removeCardKindAnim(vSeat);
				
				self.Button_eveal:setVisible(true);
				self:showPlayerTimer(vSeat, 5, 5,true);  --是否显示倒计时

				self.Button_eveal:runAction(cc.Sequence:create(cc.DelayTime:create(4.7),cc.Hide:create()));
			end
		end
	end

	local function showCountDown()
		self:showCountDownAnim();
	end

	local function showWinTime()
		if msg.nWinTime >= 2 then
			local winTime = msg.nWinTime;
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
	end


	------------------------------fenge----------------
	local function collectCoinToWinner()
		local winPos = self:getBagPosbySeat(winSeat);
		self.m_coinView:coinMoveToWinner(winPos);

		if self.m_bEffectOn then
        	playEffect("sanzhangpai/sound/jetton_recyle.mp3", false);
        end
	end

	self.Panel_result.times = 0;
   	local proIndex = 1;
   	local bEnd = false;
   	local function doPercent()
   			local times = self.Panel_result.times;
   			luaPrint("doPercent:",times);
   			if times == 1  then  --收集筹码
   				collectCoinToWinner();
   				showEvealCards();
   				--showCountDown();
   			
   			elseif times == 10 then --播放胜利失败动画
   				bEnd = true;
   				showWinWord();
   				showWinTime(msg);
   			elseif times == 38 then
   				-- self.Button_eveal:setVisible(false);
   				-- showCountDown();	   
   							
   			end
   			self.Panel_result.times = self.Panel_result.times + 1;
   	end

   	local function runProgressTime()
   		if not bEnd then
   			doPercent();
			self.Panel_result:stopAllActions();
			self.Panel_result:runAction(cc.Sequence:create(cc.DelayTime:create(0.09),cc.CallFunc:create(runProgressTime)))
   		else
   			self.Panel_result:stopAllActions();
   		end
   		
   	end

   	runProgressTime();
end



--显示比牌选择
function TableLayer:showCompSelect()
	--disable 按钮
	self:resetOpButton();

	self.Panel_select:setVisible(true);
	self.Image_selectTipBg:setVisible(true);
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		if vSeat > 0 then
			self.Image_arrowTb[vSeat]:stopAllActions();
			if v == Common.STATUS_PLAYING then
				self.Image_arrowTb[vSeat]:setVisible(true);
				self.Panel_areaTb[vSeat]:setTouchEnabled(true);
				self.Image_arrowTb[vSeat]:setPosition(self.m_ArrowPosTb[vSeat]);
				local moveF = cc.MoveBy:create(0.2,cc.p(-20,0));
				local moveB = cc.MoveBy:create(0.2,cc.p(20,0));
				local seq = cc.Sequence:create(moveF,cc.DelayTime:create(0.05),moveB);
				self.Image_arrowTb[vSeat]:runAction(cc.RepeatForever:create(seq));
			else
				self.Image_arrowTb[vSeat]:setVisible(false);
				self.Panel_areaTb[vSeat]:setTouchEnabled(false);

			end
		end
	end
end

--隐藏比牌的选择
function TableLayer:removeCompSeat()
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		if vSeat > 0 then
			if v ~= Common.STATUS_PLAYING then
				self.Image_arrowTb[vSeat]:setVisible(false);
				self.Panel_areaTb[vSeat]:setTouchEnabled(false);
				self.Image_arrowTb[vSeat]:stopAllActions();
			end
		end
	end
end



function TableLayer:hideCompSelect()
	self.Panel_select:setVisible(false);
	for k,v in pairs(self.Image_arrowTb) do
		v:stopAllActions();
		self.Image_arrowTb[k]:setPosition(self.m_ArrowPosTb[k]);
	end

end


function TableLayer:playCompAnim(msg,bResume)
	self:addPlist();
	-- local message = {};
	-- message.fighter = self.tableLogic:logicToViewSeatNo(fighter);
	-- message.defender = self.tableLogic:logicToViewSeatNo(defender);
	-- message.loster = self.tableLogic:logicToViewSeatNo(loster);
	-- message.winner = self.tableLogic:logicToViewSeatNo(winner);
	-- message.costChip = costChip;
	local fightSeat = msg.fighter;
	local defendSeat = msg.defender;
	local lostSeat = msg.loster;
	local winSeat = msg.winner;
	local nChip = msg.costChip;

	--暂停其他消息
	self:postActionBegin();

	local sexStr = self:sexOfSeat(fightSeat);
	local index = math.random(1,100);
	index = index%5 + 1;
	local str = string.format("sanzhangpai/sound/%s/PK_0%d.mp3",sexStr,1);
	
	if self.m_bEffectOn then
    	playEffect(str, false);
    end


	
	
	--播放比牌筹码
	local function runCostChip()
		
		self:resetOpButton();
		self:showBubbleTip(fightSeat, Common.TIP_COMP);

		self:addPlayerChip(fightSeat, nChip);
		self:updatePlayerCoin(fightSeat);
		self:updatePlayerChip(fightSeat);
		self:resetTableInfo();

		self:stopPlayerTimer(fightSeat);

		local pos = self:getBagPosbySeat(fightSeat);
		if nChip > 0 then
			self:addPlist();
			self.m_coinView:betMoveCoin(nChip, pos);	
		end
		
	end

	--播放比牌动画
	local function runCompAnim()

		self.Panel_compare:removeAllChildren();
		self.Panel_compare:setVisible(true);
		self.Panel_compare:setBackGroundColorOpacity(80);
		
		

		local skeleton_animation = createSkeletonAnimation(VSAnim.name,VSAnim.json,VSAnim.atlas);
		if skeleton_animation then
			self.Panel_compare:addChild(skeleton_animation);
			local pos = cc.p(640,360)
			skeleton_animation:setPosition(pos);
			skeleton_animation:setTag(102);
			skeleton_animation:setAnimation(0,VSAnimName, false);
		end
		

		if self.m_bEffectOn then
        	playEffect("sanzhangpai/sound/gamesolo.mp3", false);
        end

		for i=1,2 do
			local seat = fightSeat;
			if i == 2 then
				seat = defendSeat;
			end

			local panelFighter = self.Panel_PlayerTb[seat]:clone();
			local Image_progress = panelFighter:getChildByName("Image_progress");
			local Image_chipBanner = panelFighter:getChildByName("Image_chipBanner");
			Image_progress:setVisible(false);
			panelFighter:setVisible(false);
			Image_chipBanner:setVisible(false);

			local pos = nil;
			if i == 1 then
				pos = self.m_LeftCompPos;
			else
				pos = self.m_RightCompPos;
			end
			self.Panel_compare:addChild(panelFighter);
			panelFighter:setPosition(pos);

			local delayIt = cc.DelayTime:create(0.65);
			local showIt = cc.Show:create();
			local moveF1 = cc.MoveBy:create(0.05,cc.p(-15,0))
			local moveF2 = cc.MoveBy:create(0.05,cc.p(15,0))
			local moveF3 = cc.MoveBy:create(0.05,cc.p(-10,0))
			local moveF4 = cc.MoveBy:create(0.05,cc.p(10,0))
			local moveF5 = cc.MoveBy:create(0.05,cc.p(-10,0))
			local moveF6 = cc.MoveBy:create(0.05,cc.p(10,0))

			-- local soundCallback = cc.CallFunc:create(function (sender)
			-- 		if self.m_bEffectOn then
			--         	playEffect("sanzhangpai/sound/gamesolo.mp3", false);
			--         end
			-- end)


			panelFighter:runAction(cc.Sequence:create(delayIt,showIt,moveF1,moveF2,moveF3,moveF4,moveF5,moveF6));

			
		end
	end


	local function runCompCardFail()
		self.Panel_compare:removeAllChildren();
		self.Panel_compare:setBackGroundColorOpacity(0);
		if self:isMeSeat(lostSeat) then
			local pos = cc.p(662,166);
			local img_fail = ccui.ImageView:create("szp_shibai.png",UI_TEX_TYPE_PLIST);
			self.Panel_cards:addChild(img_fail);
			img_fail:setTag(self:getCardTag(lostSeat,TAG_FOLD));
			img_fail:setPosition(pos);

			--移除自己牌型提示
			self:removeCardKind(lostSeat);
			performWithDelay(self,function() self.Panel_continue:setVisible(true) end,3);
			-- for i=1,3 do
			-- 	local card = self:getCardBySeat(lostSeat, i);
			-- 	Common.setImageGray(card,true);
			-- end
		else
			local vSeat = lostSeat;
			self:removeSeatCard(vSeat);
			local img_fold = self.Image_foldCell:clone();
			img_fold:setVisible(true);
			local img_fail = img_fold:getChildByName("Image_foldWord");
			img_fail:loadTexture("szp_shibai.png",UI_TEX_TYPE_PLIST);
			-- local tag = self:getCardTag(vSeat,2);
			-- local card = self.Panel_cards:getChildByTag(tag);
			local posTb = self.m_posCardTb[vSeat];
			local pos = posTb[2];

			-- local pos1 = self.Image_speakTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_speakTb[vSeat]:getPosition()));
			-- local pos = cc.p(pos1.x,self.Panel_speakTb[vSeat]:getPositionY() - 30);
			img_fold:setPosition(pos);
			img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
			self.Panel_cards:addChild(img_fold);
		end
	end

	--播放比牌输赢动画
	local function runCompResultAnim()
			--自己失败 需要关闭所有按钮
			if self:isMeSeat(lostSeat) then
				self:resetOpButton();

				if self.m_bEffectOn then
		        	playEffect("sanzhangpai/sound/game_lose.mp3", false);
		        end
			end

			if self:isMeSeat(winSeat) then
				if self.m_bEffectOn then
		        	playEffect("sanzhangpai/sound/game_win.mp3", false);
		        end
			end


			self:setPlayerGray(lostSeat,true);

			self.Panel_compare:removeAllChildren();

			local skeleton_animation = createSkeletonAnimation(WinAnim.name,WinAnim.json,WinAnim.atlas);
			if skeleton_animation then
				skeleton_animation:setAnimation(0,WinAnimName, false);

				self.Panel_compare:addChild(skeleton_animation);
				local pos = self.m_ReulstPosTb[winSeat];
				skeleton_animation:setPosition(pos);
				skeleton_animation:setTag(TAG_WIN_ANIM + winSeat);
			end
			


			local skeleton_animation2 = createSkeletonAnimation(LostAnim.name,LostAnim.json,LostAnim.atlas);
			if skeleton_animation2 then
				skeleton_animation2:setAnimation(0,LostAnimName, false);

				self.Panel_compare:addChild(skeleton_animation2);
				local pos = self.m_ReulstPosTb[lostSeat];
				skeleton_animation2:setPosition(pos);
				skeleton_animation2:setTag(TAG_WIN_ANIM + lostSeat);
			end
			
	end


	local function runClearAllAnim()
		self.Panel_compare:removeAllChildren();
		self.Panel_compare:setVisible(false);
		self:postActionEnd();
	end

	local times = 0;
   	local proIndex = 1;
   	local bEnd = false;
   	local function doPercent()
   			-- luaPrint("doPercent:",times,os.time());
   			if times == 1  then  --播放下注筹码
   				runCostChip();
   			elseif times == 3 then --播放比牌是
   				runCompAnim();
   			elseif times == 18 then
   				runCompCardFail();
   			elseif times == 20 then
   				runCompResultAnim();
   			elseif times == 30 then --
   				runClearAllAnim();
   				bEnd = true;
   			end
   			times = times + 1;

   	end

   	local function runProgressTime()
   		if not bEnd then
   			doPercent();
			self.Panel_compare:stopAllActions();
			self.Panel_compare:runAction(cc.Sequence:create(cc.DelayTime:create(0.09),cc.CallFunc:create(runProgressTime)))
   		else
   			self.Panel_compare:stopAllActions();
   		end
   		
   	end

   	runProgressTime();

end


--全局比牌
function TableLayer:playAllCompare(msg)
	self:addPlist();
	--暂停其他消息
	self:postActionBegin();
	self:resetOpButton();
	
	--播放比牌动画


	self:stopAllPlayerTimer();
	local function runCompAnim()

		self.Panel_compare:removeAllChildren();
		self.Panel_compare:setVisible(true);
		self.Panel_compare:setBackGroundColorOpacity(80);
		
		local skeleton_animation = createSkeletonAnimation(FinalFightAnim.name,FinalFightAnim.json,FinalFightAnim.atlas);
		if skeleton_animation then
			self.Panel_compare:addChild(skeleton_animation);
			local pos = cc.p(640,360)
			skeleton_animation:setPosition(pos);
			skeleton_animation:setTag(102);
			skeleton_animation:setAnimation(0,FinalFightAnimName, false);
		end
		

	end



	local function runCompCardFail()
		self.Panel_compare:removeAllChildren();
		self.Panel_compare:setBackGroundColorOpacity(0);

		for _,lostSeat in pairs(msg.lostTb) do
			if self:isMeSeat(lostSeat) then
				local pos = cc.p(662,166);
				local img_fail = ccui.ImageView:create("szp_shibai.png",UI_TEX_TYPE_PLIST);
				self.Panel_cards:addChild(img_fail);
				img_fail:setTag(self:getCardTag(lostSeat,TAG_FOLD));
				img_fail:setPosition(pos);

				--移除自己牌型提示
				self:removeCardKind(lostSeat);
			else
				local vSeat = lostSeat;
				self:removeSeatCard(vSeat);
				local img_fold = self.Image_foldCell:clone();
				img_fold:setVisible(true);
				local img_fail = img_fold:getChildByName("Image_foldWord");
				img_fail:loadTexture("szp_shibai.png",UI_TEX_TYPE_PLIST);
				-- local tag = self:getCardTag(vSeat,2);
				-- local card = self.Panel_cards:getChildByTag(tag);
				local posTb = self.m_posCardTb[vSeat];
				local pos = posTb[2];
				-- local pos1 = self.Image_speakTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_speakTb[vSeat]:getPosition()));
				-- local pos = cc.p(pos1.x,self.Panel_speakTb[vSeat]:getPositionY() - 30);
				img_fold:setPosition(pos);
				img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
				self.Panel_cards:addChild(img_fold);
			end
		end
		
	end


	--播放比牌输赢动画
	local function runCompResultAnim()
			--自己失败 需要关闭所有按钮
			if self:isMeSeat(lostSeat) then
				self:resetOpButton();
			end

			

			self.Panel_compare:removeAllChildren();

			for _,winSeat in pairs(msg.winTb) do
				local skeleton_animation = createSkeletonAnimation(WinAnim.name,WinAnim.json,WinAnim.atlas);
				if skeleton_animation then
					skeleton_animation:setAnimation(0,WinAnimName, false);

					self.Panel_compare:addChild(skeleton_animation);
					local pos = self.m_ReulstPosTb[winSeat];
					skeleton_animation:setPosition(pos);
					skeleton_animation:setTag(TAG_WIN_ANIM + winSeat);
				end
				
			end
			
			for _,lostSeat in pairs(msg.lostTb) do

				self:setPlayerGray(lostSeat,true);

				local skeleton_animation2 = createSkeletonAnimation(LostAnim.name,LostAnim.json,LostAnim.atlas);
				if skeleton_animation2 then
					skeleton_animation2:setAnimation(0,LostAnimName, false);

					self.Panel_compare:addChild(skeleton_animation2);
					local pos = self.m_ReulstPosTb[lostSeat];
					skeleton_animation2:setPosition(pos);
					skeleton_animation2:setTag(TAG_WIN_ANIM + lostSeat);
				end
				
			end
	end


	local function runClearAllAnim()
		self.Panel_compare:removeAllChildren();
		self.Panel_compare:setVisible(false);
		self:postActionEnd();
	end



	local times = 0;
   	local proIndex = 1;
   	local bEnd = false;
   	local function doPercent()
   			-- luaPrint("doPercent:",times);
   			if times == 1  then  --播放全局比牌
   				runCompAnim();
   			elseif times == 15 then --牌灰度
   				runCompCardFail();
   			elseif times == 20 then --播放比牌结果
   				runCompResultAnim();
   			elseif times == 30 then --
   				runClearAllAnim();
   				bEnd = true;
   			end
   			times = times + 1;

   	end


	local function runProgressTime()
   		if not bEnd then
   			doPercent();
			self.Panel_compare:stopAllActions();
			self.Panel_compare:runAction(cc.Sequence:create(cc.DelayTime:create(0.09),cc.CallFunc:create(runProgressTime)))
   		else
   			self.Panel_compare:stopAllActions();
   		end
   		
   	end

   	runProgressTime();
end

--比牌结算展示
function TableLayer:showOpponentCards(vSeat,cards)
	self:addPlist();
	local cardData = cards;
	if cardData == nil or table.nums(cardData) < 3 then
		luaPrint("playerEvealCards vseat error:",vSeat);
	end

	if self:isMeSeat(vSeat) then
		self:turnOnCard(vSeat,cards,false);
		return
	end

	if self.m_SeatDownTb[vSeat] == false then
		--玩家离开 依然显示牌值
		-- return;
	end

	local posTb = self.m_posCardTb[vSeat];
	
	local scale_y = 1.1
    local scale_b = 0.55
    local scale_p = 0.7
    local img_cards = {}
    local scale = 0.54
	self:removeSeatCard(vSeat);

	local function getCard(id)
        local img_card = ccui.ImageView:create(string.format("szp_0x%02X.png",id),UI_TEX_TYPE_PLIST);
        img_card:setScale(scale)
        return img_card
    end


	local function showCard()
        for i=1,3 do
        	local index = i - 1;
            img_cards[i] = getCard(cardData[i])
            img_cards[i]:setPosition(posTb[i])
            self.Panel_cards:addChild(img_cards[i]);
            local tag = self:getCardTag(vSeat, i);
            img_cards[i]:setTag(tag);
            img_cards[i]:setScale(scale);
        end
    end

    showCard();
end

--玩家亮牌
function TableLayer:playerEvealCards(vSeat,cards)
	self:addPlist();
	local cardData = cards;
	if cardData == nil or table.nums(cardData) < 3 then
		luaPrint("playerEvealCards vseat error:",vSeat);
		return
	end
	

	if self:isMeSeat(vSeat) then
		self:turnOnCard(vSeat,cards,true);
		return
	end


	local posTb = self.m_posCardTb[vSeat];
	local pos_tt = posTb[1];

	local scale_y = 1.1
    local scale_b = 0.55
    local scale_p = 0.7
    local img_cards = {}
    local img_backs = {}
    local scale = 0.54
    local up = 20
    local padding = 86


    local gap = 33;
	local width = 84;
	local height = 73;

	-- if vSeat == 1 or vSeat == 4 then
	-- 	width = 115;
	-- 	height = 158;
	-- 	gap = 50;
	-- end


	self:removeSeatCard(vSeat);
    -- self.Panel_cards:removeAllChildren();

    local function getCard(id)
        local img_card = ccui.ImageView:create(string.format("szp_0x%02X.png",id),UI_TEX_TYPE_PLIST);
        img_card:setScale(scale)
        return img_card
    end
    
    local function getCardBack()
        local img_card = ccui.ImageView:create("szp_0x00.png",UI_TEX_TYPE_PLIST);
        img_card:setScale(scale)
        return img_card
    end


    local function runTurnFront()
        local speed_x = 250
        for i,v in ipairs(cardData) do
        	local tag = self:getCardTag(vSeat, i);
            local pos_t = posTb[i];
            if i == 3 then
                pos_t = cc.p(pos_t.x + 10 ,pos_t.y)
            end
            
            local length = cc.pGetDistance(posTb[1],posTb[3]);
           
            local dt1 = length/(speed_x)
            -- local dt1 = length/(speed_x+100*i)
            img_backs[i]:loadTexture(string.format("szp_0x%02X.png",v),UI_TEX_TYPE_PLIST);
            img_backs[i]:setScaleX(0.01)
            img_backs[i]:setScaleY(scale_y*scale)
     
            local showIt = cc.Show:create()
            local turnFront = cc.ScaleTo:create(0.1,1.1*scale,1.0*scale)
            local turnFront2 = cc.ScaleTo:create(0.05,1.0*scale,1.0*scale)
            local moveDown = cc.MoveBy:create(0.05,cc.p(0,-up-i*5))
            local delayIt = cc.DelayTime:create(0.05)
            local moveTo = cc.MoveTo:create(dt1, pos_t)

            if i == 3 then
                local moveBack = cc.MoveBy:create(0.05,cc.p(-10,0))
                img_backs[i]:runAction(cc.Sequence:create(showIt,turnFront,turnFront2,moveDown,delayIt,moveTo,moveBack,delayIt2))
            else
                img_backs[i]:runAction(cc.Sequence:create(showIt,turnFront,turnFront2,moveDown,delayIt,moveTo))
            end
        end
    end


	
	local function showBackCard()
        for i=1,3 do
        	local index = i - 1;

            img_backs[i] = getCardBack()
            img_backs[i]:setPosition(posTb[i])
            self.Panel_cards:addChild(img_backs[i]);
            local tag = self:getCardTag(vSeat, i);
            img_backs[i]:setTag(tag);

            local delayIt = cc.DelayTime:create(0.01)
            local moveBack = cc.MoveBy:create(0.1, cc.p(-gap*index,0))

            local moveUp = cc.MoveBy:create(0.1,cc.p(0,up+i*5))
            local turnBack = cc.ScaleTo:create(0.1,0.01,scale_y*scale_b)
            local spawn = cc.Spawn:create(moveUp,turnBack)
            
            if i == 3 then
                img_backs[i]:runAction(cc.Sequence:create(delayIt,moveBack,spawn,cc.CallFunc:create(runTurnFront)))    
            else
                img_backs[i]:runAction(cc.Sequence:create(delayIt,moveBack,spawn))
            end
    
        end
    end



    showBackCard();

end




--自动跟注
function TableLayer:autoDelayTimeBet()
	self.Panel_PlayerTb[0]:stopAllActions();
	local function autoBet()
		if self.Button_bet:isVisible() then
			self:sendBet();
		else
			self:sendFollowBet();
		end
	end
	local delayIt = cc.DelayTime:create(0.25);

	self.Panel_PlayerTb[0]:runAction(cc.Sequence:create(delayIt,cc.CallFunc:create(function() 
        autoBet();
     end)));
end


--灰度玩家
function TableLayer:setPlayerGray(vSeat,bGray)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerCheck---------vSeat "..vSeat.."is not valid+++++++++++++++++++++++++++!")
		return ;	
	end
	
	luaPrint("setPlayerGray_vSeat:",vSeat)

	if self:isMeSeat(vSeat) then
		local posTb = self.m_posCardTb[vSeat];

		for i=1,3 do
			local card = self:getCardBySeat(vSeat, i);
			if card then
				card:stopAllActions();
			else
				card = self:cardOfSeat(vSeat);
				self.Panel_cards:addChild(card);
			end
			card:setTag(self:getCardTag(vSeat,i));
			local scale = 1.0;
			card:setScale(scale);
			card:setPosition(posTb[i]);
			card:setVisible(true);
			Common.setImageGray(card,bGray);
			
		end
	else

	end

	Common.setImageGray(self.Image_headTb[vSeat],bGray);
	Common.setImageGray(self.Image_coinTb[vSeat],bGray);
	Common.setImageGray(self.Image_bankerTb[vSeat],bGray);
	Common.setImageGray(self.Image_chipBannerTb[vSeat],bGray);

end


--恢复玩家状态
function TableLayer:resetPlayerNormal()
	for i=0,4 do
		self:setPlayerGray(i,false);
	end
end


--恢复桌面筹码
function TableLayer:resumTableChip(msg)
	-- self.m_lBaseChip
	self:addPlist();
	local chipTb = msg.iPerJuTotalNote;
	for k,v in pairs(chipTb) do
		local vSeat = self.tableLogic:logicToViewSeatNo(k-1);
		if v >= self.m_lBaseChip then
			-- local followChip = v - self.m_lBaseChip;
			-- self.m_coinView:betCoin(self.m_lBaseChip);

			-- local count = math.floor(followChip/self.m_lSingleChip);
			-- followChip = followChip - self.m_lSingleChip*count;
			-- for i=1,count do
			-- 	self.m_coinView:betCoin(self.m_lSingleChip);				
			-- end
			

			-- count = math.floor(followChip/self.m_lBaseChip);

			-- for i=1,count do
			-- 	self.m_coinView:betCoin(self.m_lBaseChip);				
			-- end

			--更新玩家下注
			self:updatePlayerChip(vSeat);	
		else

		end
	end

	local chipRecordTb = msg.iNoteRecord;
	for i,v in ipairs(chipRecordTb) do
		if v > 0 then
			self.m_coinView:betCoin(v);
		end
		

	end

end


--恢复桌面牌
function TableLayer:resumeTableCards()
	local bSize = cc.size(CARD_WIDTH*0.3,CARD_HEIGHT*0.3);
	for vSeat,v in pairs(self.m_iPlayerStatusTb) do
		luaPrint("resumeTableCards____________________vSeat,status:",vSeat,v);
		if v == Common.STATUS_PLAYING or v == Common.STATUS_FOLDED or v == Common.STATUS_LOST then
			local posTb = self.m_posCardTb[vSeat];
			for j=1,3 do
				local card = self:cardOfSeat(vSeat);
				card:setTag(self:getCardTag(vSeat,j));
				local scale = 1.0;
				if vSeat == 0 then
					scale = 1.0;
				elseif vSeat == 1 or vSeat == 4 then
					scale = 1.0;
				else
					scale = 0.73;
				end
				card:setScale(scale);
				card:setPosition(posTb[j]);
				self.Panel_cards:addChild(card);
			end
		end
		
	end
end


--恢复玩家牌状态
function TableLayer:resumePlayerStatus(msg)
	--判断是否看牌
	self:resumeTableCards();
	for vSeat,v in pairs(self.m_bPlayerCheckedTb) do
		if v then
			self:showPlayerCheck(vSeat,false);	
			-- if self.m_iPlayerStatusTb[vSeat] == Common.STATUS_PLAYING then
				
			-- end
		end
	end


	--判断是否比牌输
	for vSeat,v in pairs(self.m_bPlayerLostTb) do
		if v then
			--自己失败 需要关闭所有按钮
			if self:isMeSeat(vSeat) then
			    self:resetOpButton();
			end
			

			if self:isMeSeat(vSeat) then
			    local pos = cc.p(662,166);
			    local img_fail = ccui.ImageView:create("szp_shibai.png",UI_TEX_TYPE_PLIST);
			    self.Panel_cards:addChild(img_fail);
			    img_fail:setTag(self:getCardTag(vSeat,TAG_FOLD));
			    img_fail:setPosition(pos);
			    self:setPlayerGray(vSeat,true);
			else
				self:removeSeatCard(vSeat);
				if self.m_iPlayerStatusTb[vSeat] ~= Common.STATUS_IDLE then
					self:setPlayerGray(vSeat,true);

					local img_fold = self.Image_foldCell:clone();
				    img_fold:setVisible(true);
				    local img_fail = img_fold:getChildByName("Image_foldWord");
				    img_fail:loadTexture("szp_shibai.png",UI_TEX_TYPE_PLIST);
				    
				    -- local pos1 = self.Image_speakTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_speakTb[vSeat]:getPosition()));
				    -- local pos = cc.p(pos1.x,self.Panel_speakTb[vSeat]:getPositionY() - 30);
				    local posTb = self.m_posCardTb[vSeat];
					local pos = posTb[2];

				    img_fold:setPosition(pos);
				    img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
				    self.Panel_cards:addChild(img_fold);
				end
			end
		end
	end


	--判断是否弃牌
	for vSeat,v in pairs(self.m_bPlayerFoldedTb) do
		if v then
			--自己弃牌 需要关闭所有按钮
			if self:isMeSeat(vSeat) then
			    self:resetOpButton();
			end
			

			if self:isMeSeat(vSeat) then
				local pos = cc.p(662,166);
				local img_fold = ccui.ImageView:create("szp_qipaixianshi.png",UI_TEX_TYPE_PLIST);
				self.Panel_cards:addChild(img_fold);
				img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
				img_fold:setPosition(pos);
				self:setPlayerGray(vSeat,true);
			else
				self:removeSeatCard(vSeat);
				if self.m_iPlayerStatusTb[vSeat] ~= Common.STATUS_IDLE then
					self:setPlayerGray(vSeat,true);
				
					local img_fold = self.Image_foldCell:clone();
					img_fold:setVisible(true);
					-- local pos1 = self.Image_speakTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_speakTb[vSeat]:getPosition()));
					-- local pos = cc.p(pos1.x,self.Panel_speakTb[vSeat]:getPositionY() - 30);

					local posTb = self.m_posCardTb[vSeat];
					local pos = posTb[2];
					img_fold:setPosition(pos);
					img_fold:setTag(self:getCardTag(vSeat,TAG_FOLD));
					self.Panel_cards:addChild(img_fold);
				end

				
			end

			
		end
		
	end

	--显示下注栏
	self:showPlayerBetBanner();

	--重置桌子筹码
	self:resumTableChip(msg);
end


--清除面板
function TableLayer:resetTablePanel()
	self.Panel_continue:setVisible(false);
	self.Panel_continue:stopAllActions();

	self.Panel_compare:stopAllActions();
	self.Panel_compare:removeAllChildren();
	self.Panel_compare:setVisible(false);

	self.Panel_anims:stopAllActions();
    self.Panel_anims:removeAllChildren();

    self.Panel_compare:stopAllActions();
    self.Panel_compare:removeAllChildren();

    self.Panel_result:stopAllActions();
    self.Panel_result:removeAllChildren();

    self:hideCompSelect();
    self:removeAllSeatCards();

    self.m_coinView:removeAllCoin();
    self.Button_eveal:setVisible(false);

    self:stopAllPlayerTimer();

end

--播放开始倒计时
function TableLayer:showCountDownTip()
	--播放动画
	-- self.Panel_countdown:removeAllChildren();
	-- self.Panel_countdown:stopAllActions();
	-- local pos = cc.p(self.Image_tipWaitBg:getPosition());

	-- local image_tip = self.Image_tipWaitBg:clone();
	-- image_tip:setVisible(true);
	-- self.Panel_countdown:addChild(image_tip);
	-- -- local pos = cc.p(640,360)
	-- image_tip:setPosition(pos);
	-- image_tip:setTag(102);

	-- local animCallback = cc.CallFunc:create(function (sender)
	-- 		self.Panel_countdown:removeAllChildren();
	-- 		self.Panel_countdown:setVisible(false);
	-- end)
	-- --动画4秒
	-- self.Panel_countdown:runAction(cc.Sequence:create(cc.DelayTime:create(5),animCallback))
	-- self.Panel_countdown:setVisible(true);
end


--播放开始倒计时
function TableLayer:showCountDownAnim()
	local count = 0;
	
	for k,v in pairs(self.m_iPlayerStatusTb) do
		if v == Common.STATUS_WAITING then
			count = count + 1;
		end
	end

	if count <= 1 then
		self:showWaitingTip();
		return;
	end

	--播放动画
	self:removeWaiting();


	local pos = cc.p(self.Image_tipWaitBg:getPosition());

	local skeleton_animation = createSkeletonAnimation(BeginAnim.name,BeginAnim.json,BeginAnim.atlas);
	if skeleton_animation then
		self.Panel_tip:addChild(skeleton_animation);
		-- local pos = cc.p(640,360)
		skeleton_animation:setPosition(pos);
		skeleton_animation:setTag(102);
		skeleton_animation:setAnimation(0,BeginAnimAnimName, false);
		skeleton_animation:setName(BeginAnimAnimName);
	end
	

	local animCallback = cc.CallFunc:create(function (sender)
			self:removeWaiting();
			
	end)
	--动画4秒
	self.Panel_tip:runAction(cc.Sequence:create(cc.DelayTime:create(5),animCallback))
	self.Panel_tip:setVisible(true);
end



function TableLayer:showWaitingTip()
	-- if not self.m_bEnterGame then
	-- 	return;
	-- end

	-- if self.m_iTableStatus == Common.STATUS_IDLE then
	-- 	local count = 0;
	-- 	for k,v in pairs(self.m_iPlayerStatusTb) do
	-- 		if v == Common.STATUS_WAITING then
	-- 			count = count + 1;
	-- 		end
	-- 	end
	-- 	if count > 1 then
	-- 		if self.Panel_tip:getChildByName(BeginAnimAnimName) then
	-- 			-- luaPrint("11111111111B")
	-- 		else
	-- 			self:showWaitingOther();
	-- 		end
	-- 	else
	-- 		self:showWaitingOther();
	-- 	end
	-- else
	-- 	-- self:showWaitingNext();
	-- 	if self.m_iSelfStatus == Common.STATUS_WAITING then
	-- 		self:showWaitingNext();
	-- 	else
	-- 		-- self:removeWaiting();
	-- 		-- luaPrint("11111111111A_self.m_iSelfStatus",self.m_iSelfStatus)
	-- 	end
	-- end
end


function TableLayer:showWaitingNext()
	self:removeWaiting();

	local pos = cc.p(self.Image_tipWaitNext:getPosition());
	local skeleton_animation = createSkeletonAnimation(WaitAnim.name,WaitAnim.json,WaitAnim.atlas);
	if skeleton_animation then
		self.Panel_tip:addChild(skeleton_animation);
		self.Panel_tip:setVisible(true);
		skeleton_animation:setAnimation(0,WaitNextAnimName, true);
		skeleton_animation:setPosition(pos);
		skeleton_animation:setName(WaitAnim.name);
	end
	

end




--显示等待其他玩家
function TableLayer:showWaitingOther()
	self:removeWaiting();

	local pos = cc.p(self.Image_tipWaitNext:getPosition());
	local skeleton_animation = createSkeletonAnimation(WaitAnim.name,WaitAnim.json,WaitAnim.atlas);
	if skeleton_animation then
		self.Panel_tip:addChild(skeleton_animation);
		self.Panel_tip:setVisible(true);
		skeleton_animation:setAnimation(0,WaitAnimName, true);
		skeleton_animation:setPosition(pos);
		skeleton_animation:setName(WaitAnim.name);
	end
	

end


function TableLayer:removeWaiting()
	self.Panel_tip:stopAllActions();
	self.Panel_tip:removeChildByName(WaitAnim.name)
	self.Panel_tip:removeChildByName(BeginAnimAnimName)
	--BeginAnimAnimName

end


--展示牌型
function TableLayer:showCardKind(vSeat,iKind,bEffect)
	if iKind < 1 or iKind > 7 then
		return;
	end

	
	local img_cardKind = ccui.ImageView:create(CardKindTb[iKind].image);
	if img_cardKind then
		local tag = self:getCardTag(vSeat,TAG_CARD_KIND);
		self.Panel_cards:removeChildByTag(tag);
		
		self.Panel_cards:addChild(img_cardKind);
		self.Panel_cards:setVisible(true);
		img_cardKind:setPosition(self.m_posCardKindTb[vSeat]);
		img_cardKind:setTag(tag);
		local index = vSeat;
		if index == 0 then
			img_cardKind:setScale(1);
		elseif index == 2 or index == 3 then
			img_cardKind:setScale(0.65);
		elseif index == 1 or index == 4 then
			img_cardKind:setScale(0.75);
		end
	end

end

--展示牌型
function TableLayer:removeCardKind(vSeat)
	local tag = self:getCardTag(vSeat,TAG_CARD_KIND);
	self.Panel_cards:removeChildByTag(tag);
end

function TableLayer:removeCardKindAnim(vSeat)
	local tag = self:getCardTag(vSeat,TAG_CARD_KIND_ANIM);
	self.Panel_cards:removeChildByTag(tag);
end

--展示牌型特效
function TableLayer:showCardKindAnim(vSeat,iKind,bEffect)
	if iKind < 1 or iKind > 7 then
		return;
	end

	if iKind < 4 then
		-- local tag = self:getCardTag(vSeat,TAG_CARD_KIND_ANIM);
		-- self.Panel_cards:removeChildByTag(tag);
		-- local text_kind = ccui.Text:create(CardKindTb[iKind].name_cn,FONT_PTY_TEXT,20);
		-- self.Panel_cards:addChild(text_kind);
		-- text_kind:setPosition(self.m_posCardKindAnimTb[vSeat]);
		
		-- text_kind:setTag(tag);
		return;
	end




	local pos = cc.p(self.Image_tipWaitNext:getPosition());
	local skeleton_animation = createSkeletonAnimation(CardKindTb[iKind].name,CardKindTb[iKind].anim.json,CardKindTb[iKind].anim.atlas);
	if skeleton_animation then
		local tag = self:getCardTag(vSeat,TAG_CARD_KIND_ANIM);
		self.Panel_cards:removeChildByTag(tag);
		
		self.Panel_cards:addChild(skeleton_animation);
		self.Panel_cards:setVisible(true);
		skeleton_animation:setAnimation(0,CardKindTb[iKind].anim.word, false);
		skeleton_animation:setPosition(self.m_posCardKindAnimTb[vSeat]);
		skeleton_animation:setTag(tag);
		local index = vSeat;
		if index == 0 then
			skeleton_animation:setScale(1);
		elseif index == 2 or index == 3 then
			skeleton_animation:setScale(0.55);
		elseif index == 1 or index == 4 then
			skeleton_animation:setScale(0.6);
		end
	end
end


--获取玩家性别
function TableLayer:sexOfSeat(vSeat)
	local bSeatNo = self.tableLogic:viewToLogicSeatNo(vSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	
	
	if userInfo and getUserSex(userInfo.bLogoID,userInfo.bBoy) then
		return "male";
	end

	return "female";

	
end


--更新金币
function TableLayer:gameBuymoney(data)
	luaDump(data,"gameBuymoney----123")
	-- if PlatformLogic.loginResult.dwUserID ~= data.UserID then
	-- 	return;
	-- end

	local lSeat = self.tableLogic:getlSeatNo(data.UserID);
	if not self:isValidSeat(lSeat) then
		return;
	end

	local vSeat = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
	self.m_lPlayerCoin[vSeat] = self.m_lPlayerCoin[vSeat] + data.OperatScore;

	if self.tableLogic._mySeatNo ==  lSeat then
		self.m_lSelfScore = self.m_lPlayerCoin[vSeat];
	end

	self.Text_coinTb[vSeat]:setString(GameMsg.formatCoin(self.m_lPlayerCoin[vSeat]));
end


----------------------------发送消息处理---------------------------
--下注处理
function TableLayer:sendBet()
	self.tableLogic:sendBet(self.m_lSingleChip);
end


--跟注
function TableLayer:sendFollowBet()
	local nChip = self.m_lSingleChip;
	if self.m_bChecked then
		nChip = nChip*2;
	end
	self.tableLogic:sendFollowBet(nChip);
end


--加注
function TableLayer:sendRaiseBet(nChip)
	self.tableLogic:sendRasieBet(nChip);
	self:hideRaisePanel();
end

--弃牌
function TableLayer:sendFold()
	self.tableLogic:sendFold();
end

function TableLayer:sendCheck()
	self.tableLogic:sendCheck();
end


--请求比牌
function TableLayer:sendReqCompare()
	self.tableLogic:sendReqCompare();
end


--比牌
function TableLayer:sendComp(tSeat)
	self.tableLogic:sendCompare(tSeat);
end

--全下 allin
function TableLayer:sendAllIn()
	self.tableLogic:sendAllIn();
end


--亮牌
function TableLayer:sendEveal()
	self.tableLogic:sendEveal();
end



--进入后台
function TableLayer:refreshEnterBack(data)
	luaPrint("进入后台-----------refreshEnterBack")
	if device.platform == "windows" then
		luaPrint("device.platform is windows~")
		-- return;
	end

	self.m_bEnterGame = false;
end

 --后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if RoomLogic:isConnect() then
		self.m_bOutTime = false;

		if device.platform == "windows" then
			luaPrint("device.platform is windows~")

			return;
		end

		self.m_gameMsgArray = {}
		self:clearTable();

		-- self:stopAllActions();

		self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();

	else
		luaPrint("---------------------------dddddddddddddisconnect_2222222------------------------------a")
		-- self.m_iSelfStatus = Common.STATUS_IDLE;
		-- self.m_gameMsgArray = {};
		-- self.m_bOutTime = true;
		-- self:onClickExitGameCallBack();
	end
end

function TableLayer:startClock()
    local times = 10
    local winSize = cc.Director:getInstance():getWinSize();
    local daojishi = FontConfig.createWithCharMap(tostring(times), "game/ddz_daojishizitiao.png", 34, 42, "+");
    daojishi:setPosition(winSize.width/2,winSize.height/2+80);
    self.Image_bg:addChild(daojishi)

    daojishi:setString(tostring(times));
    local temp = tostring(times);

    local action1 = cc.DelayTime:create(1.0);
    local action2 = cc.CallFunc:create(function()
        temp = temp -1;
        if temp == 0 then
            self:onClickExitGameCallBack();
            self.Image_bg:stopAllActions();
        	addScrollMessage("结算阶段未操作，自动离开房间");
        end

        if daojishi and not tolua.isnull(daojishi) then 
            daojishi:setString(temp);
        end
    end);

    self.Image_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)));
end

return TableLayer;
