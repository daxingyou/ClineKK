
local TableLayer =  class("TableLayer", BaseWindow)
local ChipNodeManager = require("dezhoupuke.ChipNodeManager");
local TableLogic = require("dezhoupuke.TableLogic");
local HelpLayer = require("dezhoupuke.HelpLayer");
local PokerListBoard = require("dezhoupuke.PokerListBoard");
local Common   = require("dezhoupuke.Common");
local CardLayer   = require("dezhoupuke.CardLayer");
--区块链
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

--荷官动画
local DealerAnim = {
		name = "dzpk_nvheguan",
		json = "dezhoupuke/anim/nvheguan.json",
		atlas = "dezhoupuke/anim/nvheguan.atlas",
}

local DealerAnimName = "nvheguan";

--加注动画
local RaiseAnim = {
		name = "dzpk_jiazhu",
		json = "dezhoupuke/anim/jiazhu.json",
		atlas = "dezhoupuke/anim/jiazhu.atlas",
}

local RaiseAnimName = "jiazhu";

--玩家胜利 
local WinnerAnim = {
		name = "dzpk_winner",
		json = "dezhoupuke/anim/ying.json",
		atlas = "dezhoupuke/anim/ying.atlas",
}
--己方赢
local WinnerSelfAnimName = "zijiying";
--其他赢
local WinnerOtherAnimName = "bierenying";

--全下 加注
local AllinAnim = {
		name = "dzpk_jiazhuquanxia",
		json = "dezhoupuke/anim/jiazhuquanxia.json",
		atlas = "dezhoupuke/anim/jiazhuquanxia.atlas",
}
local AllinAnimName = "quanxia";
local JiazhuAnimName = "jiazhu";

--赢了 动画
local WinCheerAnim = {
	name = "dzpk_woyingle",
	json = "dezhoupuke/anim/woyingle.json",
	atlas = "dezhoupuke/anim/woyingle.atlas",
}

local WinCheerAnimName = "woyingle";

--牌型特效 皇家同花顺
local RoyalFlushAnim = {
	name = "dzpk_huangjiatonghuashun",
	json = "dezhoupuke/anim/huangjiatonghuashun.json",
	atlas = "dezhoupuke/anim/huangjiatonghuashun.atlas",
}
local RoyalFlushAnimName = "huangjiatonghuashun";

--牌型特效 同花顺
local StraightFlushAnim = {
	name = "dzpk_tonghuashun",
	json = "dezhoupuke/anim/tonghuashun.json",
	atlas = "dezhoupuke/anim/tonghuashun.atlas",
}
local StraightFlushAnimName = "tonghuashun";

--牌型特效 四条
local FourAnim = {
	name = "dzpk_sitiao",
	json = "dezhoupuke/anim/sitiao.json",
	atlas = "dezhoupuke/anim/sitiao.atlas",
}
local FourAnimName = "sitiao";

--牌型特效 葫芦
local FullHouseAnim = {
	name = "dzpk_hulu",
	json = "dezhoupuke/anim/hulu.json",
	atlas = "dezhoupuke/anim/hulu.atlas",
}
local FullHouseAnimName = "hulu";

--其他牌型 葫芦
local WeaponAnim = {
	name = "dzpk_paixingtexiao",
	json = "dezhoupuke/anim/paixingtexiao.json",
	atlas = "dezhoupuke/anim/paixingtexiao.atlas",
}
local OnePairAnimName = "duizi";	--对子
local TwoPairAnimName =	"liangdui";	--两对
local HighCardAnimName = "gaopai";	--高牌
local ThreeAnimName = "santiao";	--三条
local StraightCardAnimName = "shunzi";	--顺子
local FlushAnimName = "tonghua";	--同花



--顺子
local ShunziAnim = {
	name = "dzpk_shunzi",
	json = "dezhoupuke/anim/shunzi.json",
	atlas = "dezhoupuke/anim/shunzi.atlas",
}

--同花
local TonghuaAnim = {
	name = "dzpk_tonghua",
	json = "dezhoupuke/anim/tonghua.json",
	atlas = "dezhoupuke/anim/tonghua.atlas",
}


local HEAP_COUNT = 30;	--筹码数量
local CARD_WIDTH = 115;	--扑克宽度
local CARD_HEIGHT = 158;--扑克高度

local CARD_ICON_TB = {
	"dzpk_gaopai.png",	--高牌
	"dzpk_duizi.png",	--对子
	"dzpk_liangdui.png", --两对
	"dzpk_santiao.png", --三条
	"dzpk_shunzi.png", --最小顺子
	"dzpk_shunzi.png", --顺子
	"dzpk_tonghua.png", --同花
	"dzpk_hulu.png", --葫芦
	"dzpk_sitiao.png", --4条
	"dzpk_tonghuashun.png", --最小同花顺
	"dzpk_tonghuashun.png", --同花顺
	"dzpk_huangjiatonghuashun.png", --皇家同花顺 --12
}

CARD_ICON_TB[0] = "dzpk_daojishiguangquan.png";--错误



function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene("DzpkScene");

	scene:addChild(layer);

	layer.runScene = scene;
	

	return scene;
end

function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
	Event:clearEventListener();
	
	local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster);

	globalUnit.isFirstTimeInGame = false;

	return layer;
end

function TableLayer:getInstance()
	return _instance;
end

function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
	self.super.ctor(self, 0, true);
	PLAY_COUNT = 5;
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;
	GameMsg.init();
	DzpkInfo:init();
	
	local uiTable = {
		Image_bg = "1",
		Image_dealer = "1",		--荷官
		
		Panel_menu = "1",		--菜单面板
		Button_exit = "1",		--返回
		Button_help = "1",		--帮助
		Button_sound = "1",		--声音

		Panel_player = "1",		--玩家面板

		Panel_cards = "1",		--玩家牌层
		Image_cardShoe = "1",	--牌靴位置
		Image_boardCard = "1",	--桌面牌位置
		Image_cardTipBg = "1",	--己方牌提示背景
		Image_cardTipWord = "1",--己方牌提示

		Panel_box = "1",		--声音面板
		Panel_boxList = "1",	--声音下拉框
		Image_boxBg = "1",
		Button_music = "1",		--音乐按钮
		Button_effect = "1",	--音效按钮

		Panel_pot = "1",		--桌面总下注池面板
		Panel_potBanner = "1",	--桌面总下注池面板 横版
		Image_mainPot = "1",	--主池底板
		Text_mainPot = "1",		--主池数额
		Image_sidePot = "1",	--边池底板
		Text_sidePot = "1",		--边池数额
		Image_pot = "1",		--底池底板
		Text_pot = "1",			--底池数额

		Panel_bet = "1",		--玩家下注面板

		Panel_banker = "1",		--庄家标志显示面板

		Panel_opWait = "1",		--玩家空闲操作面板
		Button_callCheck = "1",	--让牌或者弃牌按钮
		Button_callEnd = "1",	--跟任何注

		Panel_opTurn = "1",		--轮到玩家下注操作面板
		Panel_opCall = "1",		--玩家跟注面板
		Button_check = "1",		--让牌
		Button_call = "1",		--跟注
		Button_callRaise = "1",	--跟注加注
		Button_allIn = "1",		--全下
		Button_fold = "1",		--弃牌
		Button_raiseTo = "1",	--打开加注面板
		


		Panel_opRaise = "1",	--加注面板
		Button_raise = "1",		--加注按钮
		Button_add = "1",		--增加筹码
		Button_reduce = "1",	--减少筹码
		Image_chip = "1",		--筹码显示标志
		Text_rasieCoin = "1",	--加注筹码显示

		Panel_chipList	=	"1",	--下注筹码

		Panel_help	= "1",		--帮助层
		Image_help	=	"1",	--帮助介绍
		Panel_anim = "1",		--动画层
		Panel_result = "1",		--结算层
		Panel_comp = "1",		--比牌层
		Panel_continue = "1",	--离开继续层
		Button_continue = "1",	--继续

		Button_leave = "1",		--离开

		Text_callAmount = "1",	--跟多少

		
	}

	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end

	--适配
	uiTable["Button_exit"] = {"Button_exit",0,1};

	uiTable["Button_sound"] = {"Button_sound",1};
	uiTable["Button_help"] = {"Button_help",1};
	uiTable["Panel_boxList"] = {"Panel_boxList",1};
	-- uiTable["Panel_help"] = {"Panel_help",1};
	
	



	luaDump(uiTable,"uiTable------------1")

	self:initData();

	loadNewCsb(self,"dezhoupuke/TableLayer",uiTable)

	_instance = self;


	

end


function TableLayer:initData()
	--游戏是否开始
	self.m_bGameStart = false;	
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;
	self.isPlaying = false;

	self.m_iBigBlindVseat = -1; --大盲注玩家座位
	self.m_iSmallBlindVseat = -1 --小盲注玩家座位

	self.pos_dealer = cc.p(0,0);	--荷官位置
	self.pos_cardShoe = cc.p(0,0);	--牌靴位置
	self.pos_boardCard = cc.p(0,0);	--公共牌起始位置
	self.boardPosTb = {};			--公共牌位置表
	self.oCardScale = 0.32;			--其他玩家发牌缩放大小
	self.iCardScale = 0.8;			--自己牌缩放大小
	self.m_entryLimit = 5000;		--入场限制
	self.m_baseRaiseTb = {};		--基础加注限制
	self.m_callMoney = 0;
	self.m_addMoney = 0;
	self.m_ThinkTime = 0;
	self.iCellNode = 0; --小盲注
	
	self.m_lPlayerCoinTb = {0,0,0,0,0}; --玩家当前金额

end

function TableLayer:resetRaiseAmount(nSmallBlind)

	self.m_baseRaiseTb = {};
	local smallIndex = 1;
	for i,v in ipairs(Common.SmallBlind) do
		if v == nSmallBlind then
			smallIndex = i;
			break;
		end
	end

	luaPrint("smallIndex:",smallIndex);
	if Common.EntryLimit[smallIndex] then
		self.m_entryLimit = Common.EntryLimit[smallIndex];
	end
	--获取大盲注
	local bBigBlind = 0;
	if Common.BigBlind[smallIndex] then
		bBigBlind = Common.BigBlind[smallIndex];
	end


	luaPrint("m_entryLimit:",self.m_entryLimit);
	luaPrint("resetRaiseAmount_m_bBigBlind:",bBigBlind);
	local perTb = {0.02,0.05,0.2,0.5,1};
	for i,v in ipairs(perTb) do
		local n = math.floor(self.m_entryLimit*v);
		n = n + bBigBlind;   --加注额度需要增加大盲注的额度
		table.insert(self.m_baseRaiseTb,n);
	end
	luaDump(self.m_baseRaiseTb, "resetRaiseAmount-------m_baseRaiseTb", 5);
	--重置加注按钮的数额 和 tag --额度
	for i,v in ipairs(self.m_baseRaiseTb) do
		local amountStr = "";

		if v%100 == 0 then
			amountStr = v/100;
		else
			amountStr = gameRealMoney(v);
		end
		self.Text_rasiseCountTb[i]:setString(amountStr);
		self.Text_rasiseCountTb[i]:setTag(v);
		self.Button_rasiseTb[i]:setTag(v);
	end
end

function TableLayer:updateRaiseBtnStatus()
	--重置加注按钮的状态
	for i,v in ipairs(self.m_baseRaiseTb) do
		luaPrint(tostring(v).."wwwww"..tostring(self.m_callMoney))
		self.Button_rasiseTb[i]:setEnabled(v > self.m_callMoney);

	end
end

function TableLayer:resetRaiseBtnStatus()
	--重置加注按钮的状态
	for i,v in ipairs(self.Button_rasiseTb) do
		v:setEnabled(true);
	end
end

--创建扑克牌
function TableLayer:createPokers()
	self.pokerListBoard = {};
	--1-5 手牌 6 公共牌
	for i=1,6 do
		-- local k = i -1;
		-- luaPrint("tempPokerList---- k = "..k)
		local tempPokerList = PokerListBoard.new(i,self);
		tempPokerList:setVisible(true);
		tempPokerList:setLocalZOrder(1000)
		self.Panel_cards:addChild(tempPokerList,5);
		
		table.insert(self.pokerListBoard, tempPokerList);
	end
end

function TableLayer:onEnter()
	self:initUI()
	self:bindEvent();
	
	self.super.onEnter(self)
end

function TableLayer:onEnterTransitionFinish()

	-- self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1);

	self.super.onEnterTransitionFinish(self)
end

-- function TableLayer:onExit()
-- 	self.super.onExit(self);
-- end

function TableLayer:bindEvent()
	
	self:pushEventInfo(DzpkInfo, "gameStartInfo", handler(self, self.receiveGameStartInfo))        		--游戏开始
	self:pushEventInfo(DzpkInfo, "betRusultInfo", handler(self, self.receiveBetRusultInfo))          	--下注
	self:pushEventInfo(DzpkInfo, "sendCardInfo", handler(self, self.receiveSendCardInfo))  				--发牌
	self:pushEventInfo(DzpkInfo, "gameEndInfo", handler(self, self.receiveGameEndInfo))        			--游戏结束
	self:pushEventInfo(DzpkInfo, "betpoolupInfo", handler(self, self.receiveBetpoolupInfo))           	--边池更新
	self:pushEventInfo(DzpkInfo, "compareCardInfo", handler(self, self.receiveCompareCardInfo)) 		--比牌
	self:pushEventInfo(DzpkInfo, "autoTokenInfo", handler(self, self.receiveAutoTokenInfo))           	--托管(让/弃，跟任何注)
	self:pushEventInfo(DzpkInfo, "tokenInfo", handler(self, self.receiveTokenInfo)) 			        --令牌消息
	self:pushEventInfo(DzpkInfo, "mingCardInfo", handler(self, self.receiveMingCardInfo)) 			    --亮牌消息  
	self:pushEventInfo(DzpkInfo, "allinMingCardInfo", handler(self, self.receiveAllinMingCardInfo)) 	--allin亮牌消息  

	self:pushEventInfo(DzpkInfo, "watcherSitInfo", handler(self, self.receiveWatcherSitInfo)) 			--旁观
	self:pushEventInfo(DzpkInfo, "userCutInfo", handler(self, self.receiveUserCutInfo))               	--断线

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
end


function TableLayer:initUI()
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	self:createPokers();
	--玩家自己金币
	self.m_playerMoney = PlatformLogic.loginResult.i64Money;

	--返回按钮
	self.Button_exit:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_exit:setName("Button_exit");
	--帮助
	self.Button_help:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_help:setName("Button_help");
	--声音
	self.Button_sound:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_sound:setName("Button_sound");

	self.Button_help:setPositionX(self.Button_help:getPositionX() - 20);
	self.Button_sound:setPositionX(self.Button_sound:getPositionX() - 20);

	--荷官
	self.pos_dealer = cc.p(self.Image_dealer:getPosition());
	local skeleton_animation = createSkeletonAnimation(DealerAnim.name,DealerAnim.json,DealerAnim.atlas);
	if skeleton_animation then
		skeleton_animation:setAnimation(0,DealerAnimName, true);
		local size = self.Image_dealer:getContentSize();
		self.Image_dealer:addChild(skeleton_animation);
		skeleton_animation:setPosition(cc.p(size.width*0.5,size.height*0.5));
		skeleton_animation:setName("Skeleton_dealer");
	end
	
	self.Image_dealer:setCascadeOpacityEnabled(false);
	self.Image_dealer:setOpacity(0);
	


	
	--玩家头像UI
	self.Panel_PlayerTb = {};	--玩家头像框
	self.Image_headTb = {};		--玩家头像
	self.Text_nameTb = {};		--玩家姓名
	self.Text_coinTb = {};		--玩家金币
	self.Image_progressTb = {};	--玩家倒计时
	self.Image_ownerTb = {};	--房主标志
	self.Image_bankerTb = {};	--玩家庄家标志
	self.Image_offlineTb = {};	--玩家断线标志
	self.Image_statusTb = {};	--玩家状态
	self.Progerss_timerTb = {}; --玩家倒计时
	for i=1,5 do
		local index = i-1;
		local panel = self.Panel_player:getChildByName(string.format("Panel_player%d",i));
		self.Panel_PlayerTb[index] = panel;
		self.Image_headTb[index] = panel:getChildByName("Image_head");
		self.Image_headTb[index]:ignoreContentAdaptWithSize(true);

		self.Text_nameTb[index] = panel:getChildByName("Text_name");
		self.Text_coinTb[index] = panel:getChildByName("Text_coin");
		self.Image_progressTb[index] = panel:getChildByName("Image_frame");
		self.Image_offlineTb[index] = panel:getChildByName("Image_offline"); 
		self.Image_ownerTb[index] = panel:getChildByName("Image_owner");
		self.Image_statusTb[index] = panel:getChildByName("Image_status"); 

		--玩家倒计时
		self.Progerss_timerTb[index] = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("dzpk_daojishi.png"));
		self.Progerss_timerTb[index]:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    self.Progerss_timerTb[index]:setReverseDirection(true)
	    self.Image_progressTb[index]:getParent():addChild(self.Progerss_timerTb[index])
	    self.Progerss_timerTb[index]:setPosition(self.Image_progressTb[index]:getPositionX(),self.Image_progressTb[index]:getPositionY())

		self.Panel_PlayerTb[index]:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		self.Panel_PlayerTb[index]:setName("Panel_head");
		self.Panel_PlayerTb[index]:setTag(index);
		self.Image_headTb[index]:setVisible(false);
		self.Text_nameTb[index]:setString("");
		
		self.Text_coinTb[index]:setString("");
		self.Image_progressTb[index]:setVisible(false);
		self.Image_offlineTb[index]:setVisible(false);
		self.Image_statusTb[index]:setVisible(false);
		self.Image_ownerTb[index]:setVisible(false);
		self.Panel_PlayerTb[index]:setVisible(false);
	end

	--公共牌位置
	self.pos_cardShoe = cc.p(self.Image_cardShoe:getPosition());
	self.Image_cardShoe:setVisible(false);
	self.Image_boardCard:setVisible(false);
	local gap = 18.75;
	--310,400   - 960 =650 ,w 115*5=575
	for i=1,5 do
		local y = 400;
		local x = 310 + gap*(i-1);
		self.boardPosTb[i] = cc.p(x,y);
	end
	self.Image_card ={};
	--玩家发牌位置
	self.m_posCardTb = {};
	-- self.oCardScale = 0.32;			--其他玩家发牌缩放大小
	-- self.iCardScale = 0.8;			--自己牌缩放大小
	for i=1,5 do
		local gap = 8;
		local width = 36.8;
		local height = 50.56;
		if i == 1 then
			width = 92;
			height = 126.4;
			gap = 40;
		end

		local posTb = {};
		local imgCard = self.Panel_cards:getChildByName(string.format("Image_card%d",i));
		self.Image_card[i]=imgCard;
		imgCard:setVisible(false);
		local pos = cc.p(imgCard:getPosition());
		for j=1,2 do
			local index = j - 1;
			local pos2 = cc.p(pos.x+gap*index,pos.y);
			table.insert(posTb,pos2);
		end
		local index = i - 1;
		self.m_posCardTb[index] = posTb;
	end
	--玩家自己牌型显示
	self.Image_cardTipBg:setVisible(false);
	self.Image_cardTipWord:setVisible(false);

	--菜单盒
	self.Panel_boxList:setVisible(false);
	--增加战绩
	if globalUnit.isShowZJ then
		self.Button_sound:loadTextures("dezhoupuke/image/zhanji/gengduode.png","dezhoupuke/image/zhanji/gengduode-on.png","dezhoupuke/image/zhanji/gengduode-on.png")
		local size = self.Panel_boxList:getContentSize();
		self.Image_boxBg:ignoreContentAdaptWithSize(true);
		self.Image_boxBg:loadTexture("sanzhangpai/image/zhanji/bg3.png");
		local imgSize = self.Image_boxBg:getContentSize();
		local pap = imgSize.height - size.height;
		self.Panel_boxList:setPositionY(self.Panel_boxList:getPositionY() - pap)
		self.Image_boxBg:setPosition(cc.p(imgSize.width*0.5,imgSize.height*0.5));

		self.Button_zhanji = ccui.Button:create("dezhoupuke/image/zhanji/zhanji_zhanji.png","dezhoupuke/image/zhanji/zhanji_zhanji-on.png","dezhoupuke/image/zhanji/zhanji_zhanji-on.png");
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


	
	--音效
	self.Button_effect:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_effect:setName("Button_effect");
	--音乐
	self.Button_music:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_music:setName("Button_music");
	self.m_bEffectOn = getEffectIsPlay();
	self.m_bMusicOn = getMusicIsPlay();

	if self.m_bEffectOn then
		self.Button_effect:loadTextures("dzpk_yinxiao.png", "dzpk_yinxiao-on.png","", UI_TEX_TYPE_PLIST);
	else
		self.Button_effect:loadTextures("dzpk_yinxiao2.png", "dzpk_yinxiao2-on.png","", UI_TEX_TYPE_PLIST);
	end

	if self.m_bMusicOn then
		self.Button_music:loadTextures("dzpk_yinyue.png", "dzpk_yinyue-on.png","", UI_TEX_TYPE_PLIST);
		playMusic("dezhoupuke/sound/menubg.mp3", true); 
	else
		self.Button_music:loadTextures("dzpk_yinyue2.png", "dzpk_yinyue2-on.png","", UI_TEX_TYPE_PLIST);
		-- stopMusic()
	end

	--下注池
	--主池
	self.Image_mainPot:setVisible(false);
	self.Text_mainPot:setString("0");
	--边池
	self.Image_sidePot:setVisible(false);
	self.Text_sidePot:setString("0");
	--底池
	self.Image_pot:setVisible(true);
	self.Text_pot:setString("0")
	self.Image_boardCard:setVisible(false);

	--玩家下注区
	self.Image_BetTb = {};
	self.Text_BetTb = {};
	for i=1,5 do
		local index = i - 1;
		self.Image_BetTb[index] = self.Panel_bet:getChildByName(string.format("Image_bet%d",i));
		self.Text_BetTb[index] = self.Image_BetTb[index]:getChildByName("Text_bet");
		self.Image_BetTb[index]:setVisible(false);
		self.Text_BetTb[index]:setString("");
	end


	--庄家标志
	self.Image_bankerTb = {};
	for i=1,5 do
		local index = i - 1;
		self.Image_bankerTb[index] = self.Panel_banker:getChildByName(string.format("Image_baneker%d",i));
		self.Image_bankerTb[index]:setVisible(false);
	end

	--空闲操作面板  让或弃，跟任何注
	self.Panel_opWait:setVisible(false);
	-- self.Button_callCheck:setVisible(false);
	self.Button_callCheck:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_callCheck:setName("Button_callCheck");
	self.Button_callEnd:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_callEnd:setName("Button_callEnd");
	--让或弃 选中标志
	self.Image_callCheckMark = self.Button_callCheck:getChildByName("Image_mark");
	self.Image_callCheckMark:setVisible(false);
	--跟任何注
	self.Image_callEndMark = self.Button_callEnd:getChildByName("Image_mark");
	self.Image_callEndMark:setVisible(false);


	--下注操作面板
	self.Panel_opTurn:setVisible(false);
	--跟注面板
	self.Panel_opCall:setVisible(false);
	--跟注
	self.Button_call:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_call:setName("Button_call");
	self.Button_call:setVisible(false)
	--让牌
	self.Button_check:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_check:setName("Button_check");
	self.Button_check:setVisible(false);
	--跟注上一加注
	self.Button_callRaise:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_callRaise:setName("Button_callRaise");
	self.Button_callRaise:setVisible(false);
	--全下
	self.Button_allIn:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_allIn:setName("Button_allIn");
	self.Button_allIn:setVisible(false);
	--弃牌
	self.Button_fold:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_fold:setName("Button_fold");
	--去加注
	self.Button_raiseTo:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_raiseTo:setName("Button_raiseTo");
	--加注面板
	self.Panel_opRaise:setVisible(false);
	self.Panel_opRaise:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_opRaise:setName("Panel_opRaise");
	self.Panel_opRaise:setTouchEnabled(true);
	--加注
	self.Button_raise:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_raise:setName("Button_raise");




	--加注固定数组按钮
	self.Button_rasiseTb = {};
	self.Text_rasiseCountTb = {};  --加注数值
	for i=1,5 do
		self.Button_rasiseTb[i] = self.Panel_opRaise:getChildByName(string.format("Button_call%d",i));
		self.Text_rasiseCountTb[i] = self.Button_rasiseTb[i]:getChildByName("Text_coin");
		self.Button_rasiseTb[i]:setTag(i);
		self.Text_rasiseCountTb[i]:setString("0");
		self.Button_rasiseTb[i]:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		self.Button_rasiseTb[i]:setName("Button_rasiseTb");

	end
	--增加加注筹码
	self.Button_add:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_add:setName("Button_add");
	--减少加注筹码
	self.Button_reduce:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_reduce:setName("Button_reduce");
	--当前选择加注筹码值
	self.Text_rasieCoin:setString("0");
	self.Text_rasieCoin:setTag(0);  --tag 用作下注筹码计算
	--筹码标志
	self.Image_chip:setVisible(false);

	--帮助
	self.Panel_help:setVisible(true);
	self.Panel_help:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_help:setName("Panel_help");
	self.Panel_help:setTouchEnabled(false);
	local size = self.Image_help:getContentSize();
	self.Image_help:setPosition(cc.p(-size.width,size.height*0.5));
	self.Image_help:setVisible(false);
	self.Image_help:setAnchorPoint(0,0.5);
	self.Panel_help:setPositionX(0)
	--动画层
	-- self.Panel_anim:setVisible(true);
	--比牌层
	self.Panel_comp:setVisible(false);
	self.Panel_compTb = {};
	self.Image_cardBarTb = {};
	self.Image_cardTypeTb = {};
	self.m_cardResultPosTb = {}; --展示牌位置
	self.m_cardResultScale = 0.7;	--展示牌缩放大小
	self.m_cardSelfResultScale = 0.8;	--展示牌缩放大小
	for i=1,5 do
		local index = i-1;
		local panel = self.Panel_comp:getChildByName(string.format("Panel_comp%d",i));
		panel:setVisible(false);
		self.Panel_compTb[index] = panel;
		local imgBg = panel:getChildByName("Image_cardBg");
		self.Image_cardBarTb[index] = imgBg;
		self.Image_cardTypeTb[index] = imgBg:getChildByName("Image_cardType");
		--亮牌扑克位置
		local size = panel:getContentSize();
		local scale = self.m_cardResultScale;
		local gap = 5;
		if index == 0 then
			gap = 15;
		end

		local pos1 = cc.p(CARD_WIDTH*scale,size.height*0.5-gap);
		local pos2 = cc.p(size.width - CARD_WIDTH*scale,size.height*0.5-gap);
		local tb = {};
		table.insert(tb,pos2);
		table.insert(tb,pos1);
		self.m_cardResultPosTb[index] = tb;
	end


	--结算层
	self.Panel_resultTb = {};
	self.Image_resultTb = {}; --结算横幅 牌型 输赢
	self.Text_winTb = {}; --赢
	self.Text_lostTb = {}; --输
	self.Image_cheerTb = {}; --赢了横幅动画
	self.Image_flashTb = {}; --赢了的闪光框
	

	self.Panel_result:setVisible(false);

	self.m_posSelfResultCardTb = {};--己方展示牌位置
	for i=1,5 do
		local index = i - 1;
		local panel = self.Panel_result:getChildByName(string.format("Panel_result%d",i));
		panel:setVisible(false);
		self.Panel_resultTb[index] = panel;
		self.Panel_resultTb[index]:setVisible(false);
		self.Image_resultTb[index] = panel:getChildByName("Image_resultBg");
		self.Text_winTb[index] = self.Image_resultTb[index]:getChildByName("Text_win");
		self.Text_lostTb[index] = self.Image_resultTb[index]:getChildByName("Text_lost");
		self.Image_cheerTb[index] = panel:getChildByName("Image_cheer");
		self.Image_flashTb[index] = panel:getChildByName("Image_flash");
		self.Image_cheerTb[index]:setCascadeOpacityEnabled(false);
		self.Image_cheerTb[index]:setOpacity(0);
		self.Image_flashTb[index]:setCascadeOpacityEnabled(false);
		self.Image_flashTb[index]:setOpacity(0);
		
	end

	--继续层
	self.Panel_continue:setVisible(false);
	self.Panel_continue:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_continue:setName("Panel_continue");
	self.Panel_continue:setTouchEnabled(true);
	--继续游戏
	self.Button_continue:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_continue:setName("Button_continue");
	--离开房间
	self.Button_leave:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_leave:setName("Button_leave");

	--增加滑动筹码点击事件
	self:addChipListTouchEvent();

	self.m_cardLayer = CardLayer:create(self.Panel_comp);
	self.m_cardLayer:setTableLayer(self);
	self.Panel_cards:addChild(self.m_cardLayer);

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	--区块链bar
	self.m_qklBar = Bar:create("dezhoupuke",self);
	self.Button_sound:addChild(self.m_qklBar);
	self.m_qklBar:setPosition(cc.p(42,-65));
end

--按钮响应
function TableLayer:onBtnClickEvent(sender,event)
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        
    elseif event == ccui.TouchEventType.ended then
    	if "Button_exit" == btnName then --返回
    		
    		self:onClickExitGameCallBack();

    	elseif "Button_help" == btnName then	--帮助
    	
			local bVisible = self.Image_help:isVisible();
			if bVisible then
				self.Image_help:stopAllActions();
				self.Panel_help:setTouchEnabled(false);
				local size = self.Image_help:getContentSize();
				local moveTo = 	cc.MoveBy:create(0.25,cc.p(-size.width,0));
				if checkIphoneX() then
					if device.platform == "ios" then
						moveTo = 	cc.MoveBy:create(0.25,cc.p(-size.width - safeX-8,0));
					end
				end
				local seq = cc.Sequence:create(moveTo,cc.Hide:create());
				self.Image_help:runAction(seq);
			else
				self.Image_help:stopAllActions();
				self.Panel_help:setTouchEnabled(true);
				local size = self.Image_help:getContentSize();
				self.Image_help:setPosition(cc.p(-size.width,size.height*0.5));

				local moveTo = 	cc.MoveBy:create(0.25,cc.p(size.width,0));
				if checkIphoneX() then
					if device.platform == "ios" then
						moveTo = 	cc.MoveBy:create(0.25,cc.p(size.width + safeX+8,0));
					end
				end
				local seq = cc.Sequence:create(cc.Show:create(),moveTo);
				self.Image_help:runAction(seq);
			end
		elseif "Panel_help" == btnName then	--帮助面板
			self.Image_help:stopAllActions();
			self.Panel_help:setTouchEnabled(false);
			local size = self.Image_help:getContentSize();
			local moveTo = 	cc.MoveBy:create(0.25,cc.p(-size.width,0));
			if checkIphoneX() then
				if device.platform == "ios" then
					moveTo = 	cc.MoveBy:create(0.25,cc.p(-size.width - safeX-8,0));
				end
			end
			local seq = cc.Sequence:create(moveTo,cc.Hide:create());
			self.Image_help:runAction(seq);
    	elseif "Button_sound" == btnName then	--声音
    		local bShow = self.Panel_boxList:isVisible();
        	self.Panel_boxList:setVisible(not bShow);

        	-- self.m_cardLayer:licensingCards();
        	-- self:runCompCard();
        	-- self:runGameEnd();
        	-- self:resetRaiseAmount(50);
        	-- self.Panel_opTurn:setVisible(true);
        	-- self.Panel_opRaise:setVisible(true);
        	
        	
    	elseif "Button_effect" == btnName then	--音效
    		self.m_bEffectOn = getEffectIsPlay();
			luaPrint("音效",self.m_bEffectOn);
			if self.m_bEffectOn then
				setEffectIsPlay(false);
				self.m_bEffectOn = false;
				self.Button_effect:loadTextures("dzpk_yinxiao2.png", "dzpk_yinxiao2-on.png","", UI_TEX_TYPE_PLIST);
		        
		    else
		    	setEffectIsPlay(true);
				self.m_bEffectOn = true;
		        self.Button_effect:loadTextures("dzpk_yinxiao.png", "dzpk_yinxiao-on.png","", UI_TEX_TYPE_PLIST);
		    end


    	elseif "Button_music" == btnName then	--音乐
    		self.m_bMusicOn = getMusicIsPlay();
			luaPrint("音乐",self.m_bMusicOn);
			if self.m_bMusicOn then--开着音效
				setMusicIsPlay(false);
				self.m_bMusicOn = false;
				self.Button_music:loadTextures("dzpk_yinyue2.png", "dzpk_yinyue2-on.png","", UI_TEX_TYPE_PLIST);
				-- stopMusic()
			else
				setMusicIsPlay(true);
				self.m_bMusicOn = true;
				self.Button_music:loadTextures("dzpk_yinyue.png", "dzpk_yinyue-on.png","", UI_TEX_TYPE_PLIST);
				
				playMusic("dezhoupuke/sound/menubg.mp3", true); 
				 
			end
		elseif "Button_check" == btnName then	--让牌
			DzpkInfo:sendNodeType(3,0)
    	elseif "Button_call" == btnName then	--跟注
    		DzpkInfo:sendNodeType(1,0)
    	elseif "Button_callRaise" == btnName then	--跟注加注
    		DzpkInfo:sendNodeType(1,0)
    	elseif "Button_allIn" == btnName then	--全下
    		DzpkInfo:sendNodeType(5,0)
    	elseif "Button_fold" == btnName then	--弃牌
    		DzpkInfo:sendNodeType(4,0)
    	elseif "Button_raiseTo" == btnName then	--去加注
    		self.Panel_opCall:setVisible(false);
    		self.Panel_opRaise:setVisible(true);
    		self:resetChipList();
    		-- self.Text_rasieCoin:setString("0");

    	elseif "Button_rasiseTb" == btnName then	--固定加注数组
    		local chipAmount = sender:getTag();
    		luaPrint("Button_rasiseTb------amount:",chipAmount);
    		if chipAmount > 0 then
    			DzpkInfo:sendNodeType(2,chipAmount)
    		end

    		-- DzpkInfo:sendNodeType(itype,money)
		elseif "Panel_opRaise" == btnName then		--关闭加注面板
    		self.Panel_opRaise:setVisible(false);
    		self.Panel_opCall:setVisible(true);
    		self:resetChipList();
    	elseif "Button_raise" == btnName then	--加注筹码
    		local chipAmount = self.Text_rasieCoin:getTag();
    		luaPrint("加注筹码：",chipAmount);
    		if chipAmount > 0 then
    			DzpkInfo:sendNodeType(2,chipAmount)
    		end
    	elseif "Button_add" == btnName then	--增加下注筹码
    		local tag = self.Panel_chipList:getTag();
    		local gapCount = tag%3;  --取余
    		if tag >= HEAP_COUNT then
    			gapCount = 0;
    		else
    			gapCount = 3 - gapCount;
    		end

    		local tag_n = tag + gapCount;
    		if tag_n > HEAP_COUNT then
    			tag_n = HEAP_COUNT;
    		end
    		
    		--显示筹码掉落动画
    		local function showCoinAnim(parent,pos)
        		local skeleton_animation = createSkeletonAnimation(RaiseAnim.name,RaiseAnim.json,RaiseAnim.atlas);
        		if skeleton_animation then
        			skeleton_animation:setAnimation(0,RaiseAnimName, false);
				
					parent:addChild(skeleton_animation);
					skeleton_animation:setPosition(pos);
					-- skeleton_animation:setPosition(cc.p(0,0));
					skeleton_animation:setName("Skeleton_coin");
					skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.RemoveSelf:create()));
        		end
				
        	end


    		local children = self.Panel_chipList:getChildren();
    		for i,v in ipairs(children) do
    			local tag_v = v:getTag();
    			if tag_v <= tag_n then
    				v:setVisible(true);

    				if tag_v == tag_n then
    					local size = v:getContentSize();
    					showCoinAnim(v,cc.p(size.width/2-0.5,size.height/2+3.5));
    				else
    					v:removeAllChildren();
    				end
    			else
    				v:removeAllChildren();
    				v:setVisible(false);		
    			end	
    		end
    		
    		self.Panel_chipList:setTag(tag_n);
    		self.Button_reduce:setEnabled(tag_n > 0);
	  	 	self.Button_add:setEnabled(tag_n<HEAP_COUNT);
	  	 	if tag_n == HEAP_COUNT then
	  	 		self.Button_raise:loadTextures("dzpk_quanxiade.png", "dzpk_quanxiade-on.png","dzpk_gray_quanxiade.png", UI_TEX_TYPE_PLIST);
	  	 	else
	  	 		self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);
	  	 	end
	  	 	self:updateRaiseTxt(tag_n);

    	elseif "Button_reduce" == btnName then	--减少下注筹码
    		local tag = self.Panel_chipList:getTag();
    		local gapCount = tag%3;  --取余
    		if tag <= 0 then
    			gapCount = 0;
    		else
    			gapCount = gapCount - 3;
    		end

    		local tag_n = tag + gapCount;


    		-- local tag_n = tag - 3;
    		if tag_n < 0 then
    			tag_n = 0;
    		end
    		local children = self.Panel_chipList:getChildren();
    		for i,v in ipairs(children) do
    			local tag_v = v:getTag();
    			if tag_v <= tag_n then
    				v:setVisible(true);
    			else
    				v:setVisible(false);		
    			end	
    		end

    		self.Panel_chipList:setTag(tag_n);
    		
    		self.Button_reduce:setEnabled(tag_n > 0);
	  	 	self.Button_add:setEnabled(tag_n < HEAP_COUNT);
	  	 	self:updateRaiseTxt(tag_n);

	  	 	if tag_n == HEAP_COUNT then
	  	 		self.Button_raise:loadTextures("dzpk_quanxiade.png", "dzpk_quanxiade-on.png","dzpk_gray_quanxiade.png", UI_TEX_TYPE_PLIST);
	  	 	else
	  	 		self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);
	  	 	end
	  	 	
    	elseif "Button_callCheck" == btnName then	--让/弃
    		-- self.Image_callCheckMark:setVisible(false);
    		local bAuto = self.Image_callCheckMark:isVisible()
    		DzpkInfo:sendAutoToken(4,not bAuto)
    	elseif "Button_callEnd" == btnName then	--跟任何注
    		-- self.Image_callEndMark:setVisible(false);
    		local bAuto = self.Image_callEndMark:isVisible();
    		DzpkInfo:sendAutoToken(3,not bAuto);

    	elseif "Panel_continue" == btnName then	--继续层

    	elseif "Button_continue" == btnName then	--继续游戏
    		
    		DzpkInfo:sendMsgReady()
        	self.Panel_continue:setVisible(false);
        	self.m_bGiveUp = false;	--玩家是否未操作

    	elseif "Button_leave" == btnName then	--离开房间

    		self:onClickExitGameCallBack();
    	elseif "Button_zhanji" == btnName then --战绩
    		luaPrint("ZHANJI-----------")
    		if self.m_logBar then
				self.m_logBar:CreateLog();
			end
    	end
    end




 end

--退出
function TableLayer:onClickExitGameCallBack(isRemove)
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	end
	-- if self.isClick == true then
 --        return;
 --    end
    
 --    if self.isPlaying ~= true then
 --    	self.isClick = true;
	-- end

	if isRemove ~= nil then
		Hall:exitGame(isRemove,func);
	else
		Hall:exitGame(self.isPlaying,func);
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

		-- RoomLogic:close();
		if globalUnit.nowTingId == 0 then
			performWithDelay(display.getRunningScene(), function() RoomLogic:close(); end,0.5);
		end
		
		self._bLeaveDesk = true;
		_instance = nil;
	end
end

--更新下注筹码数额
function TableLayer:updateRaiseTxt(tag)
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	if tag == nil then
		tag = self.Panel_chipList:getTag();
	end
	-- local tag = self.Panel_chipList:getTag();
	local per = tag/HEAP_COUNT;
	local addAllMoney = self.m_playerMoney - self.m_addMoney;
	
	if addAllMoney <= 0 then
		
		return;
	end
	luaPrint("Tag =====",tag);
	if tag == 0 then
		local count = self.m_addMoney;
		local amountStr = gameRealMoney(count);
		if count%100 == 0 then
			amountStr = math.floor(count/100);
		end
		
		local tag_count = count;

		self.Text_rasieCoin:setString(amountStr);
		local lastTag = self.Text_rasieCoin:getTag();
		if lastTag == self.m_playerMoney then
			self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);
		end

		self.Text_rasieCoin:setTag(tag_count);
		self.Button_raise:setEnabled(tag_count>=count);

	elseif tag < HEAP_COUNT then
		local count = math.floor(self.m_addMoney + addAllMoney*per);
		local amountStr = math.floor(count/100);
		local tag_count = amountStr*100;

		
		self.Text_rasieCoin:setString(amountStr);
		local lastTag = self.Text_rasieCoin:getTag();
		if lastTag == self.m_playerMoney then
			self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);
		end

		self.Text_rasieCoin:setTag(tag_count);
		self.Button_raise:setEnabled(tag_count>=self.m_addMoney);
	else
		local count = self.m_playerMoney;
		local amount = gameRealMoney(self.m_playerMoney);
		local tag_count = amount*100;

		
		self.Text_rasieCoin:setString(amount);
		--实际下注筹码 记录到tag
		self.Text_rasieCoin:setTag(count);
		self.Button_raise:loadTextures("dzpk_quanxiade.png", "dzpk_quanxiade-on.png","dzpk_gray_quanxiade.png", UI_TEX_TYPE_PLIST);
		self.Button_raise:setEnabled(self.m_playerMoney>=self.m_callMoney);
	end

	
end

-- --更新下注筹码数额


--下注筹码事件监听
function TableLayer:addChipListTouchEvent()
	--test
	-- self.Panel_opTurn:setVisible(true);
	-- self.Panel_opRaise:setVisible(true);
	-- self.Panel_chipList:setVisible(true);
	-- self.m_playerMoney = 972132;

	self.Panel_chipList:setTouchEnabled(false);
	self.Panel_chipList:setTag(0);
	self:resetChipList();
	local listenner = cc.EventListenerTouchOneByOne:create()

	-- local gap = 13;--483 height coin heihgt 93,left 390  30num 
	local gap = 13;
	local height = 59;
	local len = 390;
	

	local function updateTouchCoinList(touch)
		local pos_w = touch:getLocation()
		local pos_pw = touch:getStartLocation();
		local length = pos_w.y - pos_pw.y;
		local tag = self.Panel_chipList:getTag();
		local tag_t = 0;
		if length >= 0 then
				local num = math.floor(length/gap);
				local children = self.Panel_chipList:getChildren();
				tag_t = num+tag;
				if tag_t > HEAP_COUNT then
					tag_t = HEAP_COUNT;
				end
				for i,v in ipairs(children) do
					if v:getTag() <= tag_t then
						v:setVisible(true);
					else
						v:setVisible(false);
					end
				end
		else
				length = math.abs(length);
				local num = math.floor(length/gap);
				local children = self.Panel_chipList:getChildren();
				tag_t = tag - num;
				if tag_t < 0 then
					tag_t = 0;
				end

				for i,v in ipairs(children) do
					if v:getTag() <= tag_t then
						v:setVisible(true);
					else
						v:setVisible(false);
					end
				end
		end
		self:updateRaiseTxt(tag_t);
		return tag_t;
	end

	local pos_s = cc.p(self.Image_chip:getPosition());
	--HEAP_COUNT  30
	for i=1,HEAP_COUNT do
		local img = self.Image_chip:clone();
		self.Panel_chipList:addChild(img);
		img:setTag(i);
		local pos_t = cc.p(pos_s.x,pos_s.y + gap*(i-1));
		img:setPosition(pos_t);
		img:setVisible(false);
		-- img:setScale(1.0-0.01*(i-1));
	end
	self.Image_chip:removeFromParent();
	-- self.Image_chip:setVisible(false);
	-- luaPrint("self.Image_chip::TAG",self.Image_chip:getTag());

	listenner:registerScriptHandler(function(touch, event)
		if not self.Panel_chipList:isVisible() or not self.Panel_chipList:getParent():isVisible() then
			return false;
		end
		local size = self.Panel_chipList:getContentSize();
		local location = touch:getLocation()
		local pos = self.Panel_chipList:convertTouchToNodeSpace(touch);

		if pos.x < 0 or pos.x > size.width or pos.y < 0 or pos.y > size.height then
			return false;
		end

		--玩家自己金币 小于 加注的   禁止滑动
		if self.m_playerMoney <= self.m_addMoney then
			return false;
		end


	   return true  
	end, cc.Handler.EVENT_TOUCH_BEGAN );
	 
	listenner:registerScriptHandler(function(touch, event)
		local tag_t = updateTouchCoinList(touch);
	end, cc.Handler.EVENT_TOUCH_MOVED); 
	 
	listenner:registerScriptHandler(function(touch, event)  
		local tag_t = updateTouchCoinList(touch);
		self.Panel_chipList:setTag(tag_t);
		self.Button_reduce:setEnabled(tag_t > 0);
		self.Button_add:setEnabled(tag_t < HEAP_COUNT);

	end, cc.Handler.EVENT_TOUCH_ENDED)  
	    
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.Panel_chipList);
end

--重置加注信息
function TableLayer:resetChipList()
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	self.Panel_chipList:setTag(0);
	local children = self.Panel_chipList:getChildren();
	for i,v in ipairs(children) do
		v:setVisible(false);
	end

	self:updateRaiseBtnStatus();

	local tag_count = 0;
	local countStr = "0";
	
	if self.m_addMoney > 0 then
		tag_count = self.m_addMoney;
		
		if tag_count%100 == 0 then
			countStr = math.floor(tag_count/100);
		else
			countStr = gameRealMoney(tag_count);
		end
	end


	if self.m_playerMoney <= self.m_addMoney then
		tag_count = self.m_playerMoney;

		if tag_count%100 == 0 then
			countStr = math.floor(tag_count/100);
		else
			countStr = gameRealMoney(tag_count);
		end

		--显示所有金币
		local children = self.Panel_chipList:getChildren();
		for i,v in ipairs(children) do
			if v:getTag() <= HEAP_COUNT then
				v:setVisible(true);
			else
				v:setVisible(false);
			end
		end


		luaPrint("countStr------:",countStr);
		self.Text_rasieCoin:setString(countStr);
		self.Text_rasieCoin:setTag(tag_count);
		self.Button_reduce:setEnabled(false);
		self.Button_add:setEnabled(false);
		self.Button_raise:setEnabled(true);
		self.Button_raise:loadTextures("dzpk_quanxiade.png", "dzpk_quanxiade-on.png","dzpk_gray_quanxiade.png", UI_TEX_TYPE_PLIST);
		return;
	end

	luaPrint("countStr------:",countStr);
	self.Text_rasieCoin:setString(countStr);
	self.Text_rasieCoin:setTag(tag_count);
	self.Button_reduce:setEnabled(false);
	self.Button_add:setEnabled(true);
	self.Button_raise:setEnabled(self.m_playerMoney>=self.m_addMoney);
	self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);

end








--显示比牌信息
function TableLayer:runCompCard(msg)
	--test
	-- local nCardKind = {1,2,12,3,9};
	-- local bHandCards = {
	-- {1,2},
	-- {11,11},
	-- {12,13},
	-- {22,22},
	-- {11,12},
	-- };

	-- local cardTypeTb = nCardKind;
	-- local handCardTb = bHandCards;

	local cardTypeTb = msg.nCardKind;
	local handCardTb = msg.bHandCards
	

	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	local CARD_SCALE = self.m_cardResultScale;
	local function turnCardBegin(card)   --耗时 0.4
   		local function turnFrontCard(card)
			card:loadTexture(string.format("dzpk_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
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

	
	self.Panel_comp:setVisible(true);
	for i,v in ipairs(cardTypeTb) do
		local vSeat = i-1;
		self.Panel_compTb[vSeat]:setVisible(v > 0);
		-- self.Panel_PlayerTb[vSeat]:setVisible(true);	
		if v > 0 then
			local isMe = false;
			if vSeat == 0 then
				isMe = true;
			end

			--翻开牌
			local posTb = self.m_cardResultPosTb[vSeat];
			local panel = self.Panel_compTb[vSeat]:getChildByName("Panel_poke");
			panel:removeAllChildren();
			local scale = self.m_cardResultScale;
			if isMe then
				scale = self.m_cardSelfResultScale;
			end
			panel:removeAllChildren();

			local cardTb = handCardTb[i];
			
			for j,vv in ipairs(cardTb) do
				local card = ccui.ImageView:create();
				card:loadTexture("dzpk_0x00.png",UI_TEX_TYPE_PLIST);
				card:setPosition(posTb[j]);
				card.id = vv;
				-- if isMe then
				-- 	img:setScaleY(scale);
				-- 	img:setScaleX(self.m_cardResultScale);
				-- else
				-- 	img:setScale(self.m_cardResultScale)	
				-- end
				card:setScale(self.m_cardResultScale)
				panel:addChild(card);

				turnCardBegin(card);
				
				-- img:setVisible(false);
			end

			--牌型
			-- self.Image_cardBarTb[vSeat]:setVisible(true);
			local cardType = cardTypeTb[i];
			self.Image_cardTypeTb[vSeat]:loadTexture(CARD_ICON_TB[cardType],UI_TEX_TYPE_PLIST);
			self.Image_cardBarTb[vSeat]:setVisible(false);
			self.Image_cardBarTb[vSeat]:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.Show:create()))

		end
	end
end

function TableLayer:resetCompCard()
	self.Panel_comp:setVisible(false);
	for k,v in pairs(self.Panel_compTb) do
		local panel = v:getChildByName("Panel_poke");
		panel:removeAllChildren();
		self.Image_cardBarTb[k]:setVisible(false);
	end

end


--结算动画显示
function TableLayer:runGameEnd(msg)
	self.Panel_result:setVisible(true);
	local winTb = {}
	local userState = {}
	for i,v in ipairs(msg.nScore) do
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		winTb[vSeat] = v;
		userState[vSeat] = msg.iUserState[i]
	end
	-- luaDump(winTb,"winTb")
	-- luaDump(userState,"userState")
	-- local winTb = msg.nScore;
	--for test 
	-- local winTb = {123,-234,-345,0,99};	--结算得分
	-- winTb = nScore;


	for k,v in pairs(winTb) do
		local winCount = winTb[k];
		local vSeat = k;
		local isMe = false;
		if vSeat == 0 then
			isMe = true;
		end
		local state = userState[vSeat]
		-- self.Panel_PlayerTb[vSeat]:setVisible(true);	

		self.Panel_resultTb[vSeat]:setVisible(state ~= 0 and state ~= 3);
		-- self.Panel_resultTb[vSeat]:setVisible(winCount~=0)
		local delayT = 2.0;
		if true then
			if winCount >= 0 then
				winStr = "+"..gameRealMoney(winCount);
				self.Text_winTb[vSeat]:setString(winStr);
				self.Text_winTb[vSeat]:setVisible(true);
				self.Text_lostTb[vSeat]:setVisible(false);
			else
				winStr = tostring(gameRealMoney(winCount));
				self.Text_lostTb[vSeat]:setString(winStr);
				self.Text_winTb[vSeat]:setVisible(false);
				self.Text_lostTb[vSeat]:setVisible(true);
			end

			self.Image_resultTb[vSeat]:setVisible(true);
			self.Image_resultTb[vSeat]:setOpacity(0);
			self.Image_resultTb[vSeat]:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeIn:create(0.5)
												,cc.DelayTime:create(delayT)
												,cc.Hide:create()))

			if vSeat == 0 then
				self.Text_winTb[vSeat]:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),
													cc.CallFunc:create(function()
															if winCount > 0 then
																audio.playSound("sound/win.mp3",false);
															elseif winCount < 0 then
																audio.playSound("sound/lose.mp3",false);		
															end
													    end)

												))


			end

			if winCount > 0 then		
				if isMe then	--你赢了动画
					self.Image_cheerTb[vSeat]:removeAllChildren();
					local skeleton_animation = createSkeletonAnimation(WinCheerAnim.name,WinCheerAnim.json,WinCheerAnim.atlas);
					if skeleton_animation then
						skeleton_animation:setAnimation(0,WinCheerAnimName, false);
						self.Image_cheerTb[vSeat]:addChild(skeleton_animation);
						skeleton_animation:setName("Skeleton_cheer");
						skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeIn:create(0.5)
													,cc.DelayTime:create(delayT)
													,cc.RemoveSelf:create()))
					end
					
					if msg.nWinTime > 2 then
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
				
				--闪光框动画
				local animName = WinnerOtherAnimName;
				-- if isMe then
				-- 	animName = WinnerSelfAnimName;
				-- end
				self.Image_flashTb[vSeat]:removeAllChildren();
				local skeleton_animation = createSkeletonAnimation(WinnerAnim.name,WinnerAnim.json,WinnerAnim.atlas);
				if skeleton_animation then
					skeleton_animation:setAnimation(0,animName, false);
					self.Image_flashTb[vSeat]:addChild(skeleton_animation);
					skeleton_animation:setName("Skeleton_win");
					skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.0)
													,cc.DelayTime:create(delayT)
													,cc.RemoveSelf:create()))
				end
				
			end
		end
	end
end

function TableLayer:clearGameEnd()
	for k,v in pairs(self.Panel_resultTb) do
		v:setVisible(false);
		local panel = v:getChildByName("Panel_poke");
		if panel then
			panel:removeAllChildren();	
		end
	end

	for k,v in pairs(self.Image_flashTb) do
		v:removeAllChildren();
	end

	for k,v in pairs(self.Image_cheerTb) do
		v:removeAllChildren();
	end
	
	for k,v in pairs(self.Text_winTb) do
		v:setVisible(false);
	end

	for k,v in pairs(self.Text_lostTb) do
		v:setVisible(false);
	end

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


--玩家加注特效
function TableLayer:showPlayerRaiseAnim(vSeat)
	if not self:isValidSeat(vSeat) then
		luaPrint("showPlayerRaiseAnim error vSeat:",vSeat);
		return;
	end
	local size = self.Panel_PlayerTb[vSeat]:getContentSize();
	self.Panel_PlayerTb[vSeat]:removeChildByName("Skeleton_Raise")
	local skeleton_animation = createSkeletonAnimation(AllinAnim.name,AllinAnim.json,AllinAnim.atlas);
	if skeleton_animation then
		skeleton_animation:setAnimation(0,JiazhuAnimName, false);
		self.Panel_PlayerTb[vSeat]:addChild(skeleton_animation);
		skeleton_animation:setPosition(cc.p(size.width*0.5,size.height*0.5));
		
		skeleton_animation:setName("Skeleton_Raise");
	end
	
end

--清除加注特效
function TableLayer:clearPlayerRaiseAnim(vSeat)
	if not self:isValidSeat(vSeat) then
		luaPrint("clearPlayerRaiseAnim error vSeat:",vSeat);
		return;
	end

	self.Panel_PlayerTb[vSeat]:removeChildByName("Skeleton_Raise");
end

--清除所有加注特效
function TableLayer:clearAllPlayerRaiseAnim()
	
	for k,v in pairs(self.Panel_PlayerTb) do
		v:removeChildByName("Skeleton_Raise");
	end
	
end

--发牌
function TableLayer:licensingCards(data)
	local msg = {};
	--玩家手牌
	msg.iKind = data.iCardShape;
	msg.handCards = {};
	msg.playingSeatTb = {};
	msg.m_iBigBlindVseat = data.m_iBigBlindVseat;
	for i,v in ipairs(data.byCards) do	
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		msg.handCards[vSeat] = v;
	end
	--玩家状态 1 参与玩家
	for i,v in ipairs(data.iUserState) do
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		msg.playingSeatTb[vSeat] = v;
	end
	luaDump(msg, "msg=====a", 3)
	-- self.m_cardLayer:licensingCards(msg.playingSeatTb, msg.handCards);
	self.m_cardLayer:licensingCards(msg);
end


--发桌面前三张牌
function TableLayer:licensingBoardFlopCards(cardData,count)
	local msg = {};
	msg.cards = {};
	for i,v in ipairs(cardData) do
		if v > 0 then
			msg.cards[i] = v;
		end
	end
	self.m_cardLayer:licensingBoardCards(msg.cards,count);
end

--发牌桌第四张牌 TURN 转牌 第五张牌 RIVER 河牌
function TableLayer:licensingTurnRiverCard(index,cardData)
	self.m_cardLayer:licensingTurnRiverCard(index,cardData);
end


--玩家比牌亮牌
function TableLayer:revealCards(handCardTb,cardKindTb)
	self.m_cardLayer:revealCards(handCardTb,cardKindTb);
end



-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	self:clearDesk();
end

 -- //清理桌面
function TableLayer:clearDesk()

	for i=1,5 do
		local index = i - 1;
		self.Image_bankerTb[index]:setVisible(false);
		self.Image_BetTb[index]:setVisible(false);
	end
	self.Panel_opTurn:setVisible(false)
	self.Panel_opCall:setVisible(false)
	self.Panel_opWait:setVisible(false)
	self.Panel_opRaise:setVisible(false);

	self.Image_callCheckMark:setVisible(false);
	self.Image_callEndMark:setVisible(false);

	--主池
	self.Text_mainPot:setString("0");
	--边池
	self.Text_sidePot:setString("0");
	--底池
	self.Text_pot:setString("0")
	--手牌和公共牌
	for k,v in pairs(self.pokerListBoard) do
		v:clearData();
	end
	--重置加注按钮
	self:playDengDaiEffect(false)
	self:resetRaiseBtnStatus();
	self.m_callMoney = 0;
	self.m_addMoney = 0;
	self.m_iBigBlindVseat = -1;
	self.m_cardLayer:removeDeskCard();
	self:clearAllPlayerAllinAnim();
	self.Panel_potBanner:removeAllChildren();

	if self.paiTypeSpine then
		self.paiTypeSpine:removeFromParent();
		self.paiTypeSpine = nil;
	end
	if self.willStartSpine then
		self.willStartSpine:removeFromParent();
		self.willStartSpine = nil;
	end
	self:stopAllPlayerTimer();
	self:clearGameEnd();
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

-- //处理玩家掉线协议
function TableLayer:onUserCutMessageResp(userId, seatNo)
	-- if self.playerNodeInfo[seatNo+1] and self.playerNodeInfo[seatNo+1]:getUserId() == userId then
	-- 	-- self.playerNodeInfo[seatNo+1]:setCutHead();
	-- end
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

function TableLayer:setWaitTime(num)
	self.Image_shizhong:setVisible(true);
	self.AtlasLabel_time:setString(num);
	self.daojishi = num;
	self:stopTimer();
	self:startTimer();
end

function TableLayer:startTimer()
	self.updateDaojishiSchedule = schedule(self, function() self:callEverySecond(); end, 1);
end

function TableLayer:stopTimer()
	if self.updateDaojishiSchedule then
		self:stopAction(self.updateDaojishiSchedule);
	end
end

function TableLayer:callEverySecond()
	self.daojishi = self.daojishi -1;

	if self.daojishi >= 0 then
		self.AtlasLabel_time:setString(self.daojishi);
	else
		self:stopTimer();
		self.AtlasLabel_time:setString("0")
		self.Image_shizhong:setVisible(false);
	end
end


function TableLayer:receiveGameStartInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	if self.AllinEffect then
		-- audio.resumeMusic();
		-- audio.stopSound(self.AllinEffect)
		playMusic("dezhoupuke/sound/menubg.mp3", true);
		self.AllinEffect = nil;
	end
	local data = data._usedata;
	luaDump(data,"gamestart")
	self:clearDesk();
	--庄家位置
	local zseat = self.tableLogic:logicToViewSeatNo(data.byNTUser);
	self.Image_bankerTb[zseat]:setVisible(true);
	
	local lSeat = data.bBigBlind;
	local vSeat = self.tableLogic:logicToViewSeatNo(lSeat);
	self.m_iBigBlindVseat = vSeat;

	self.isPlaying = true;



	--开始动画
	--同花
	local StartAnim = {
		name = "dzpk_kaishiyouxi",
		json = "dezhoupuke/anim/dezhoupukekaishi.json",
		atlas = "dezhoupuke/anim/dezhoupukekaishi.atlas",
	}



	local anim_start = createSkeletonAnimation(StartAnim.name,StartAnim.json,StartAnim.atlas);
	if anim_start then
		anim_start:setPosition(640,460);
		anim_start:setAnimation(1,"dezhoupukekaishi", false);
		self.Panel_anim:addChild(anim_start,2);
		anim_start:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.RemoveSelf:create()));
	end

	if self.m_bEffectOn then
    	playEffect("dezhoupuke/sound/StartGamewomen.mp3", false);
    end

end


function TableLayer:receiveBetRusultInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	local data = data._usedata;
	luaDump(data,"receiveBetRusultInfo")
	if not self:isValidSeat(data.byUser) then 
		return;
	end
	local seat = self.tableLogic:logicToViewSeatNo(data.byUser);
	self.Image_BetTb[seat]:setVisible(true);
	
	if data.byUser == self.tableLogic._mySeatNo then
		self.m_playerMoney = data.lUserMoney;
	end

	self.m_lPlayerCoinTb[seat] = data.lUserMoney;


	self.Text_coinTb[seat]:setString(gameRealMoney(data.lUserMoney));
	if data.lTurnNode >=100000 then
		self.Text_BetTb[seat]:setScale(0.8)
	else
		self.Text_BetTb[seat]:setScale(1)
	end
	local str = "";
	if data.nType == 1 then  --//跟注
		self.Text_BetTb[seat]:setString(gameRealMoney(data.lTurnNode));
		str = "genzhu"
		audio.playSound("sound/call.mp3",false);
	elseif data.nType == 2 then  --//加注
		self.Text_BetTb[seat]:setString(gameRealMoney(data.lTurnNode));
		str = "jiazhu"
		audio.playSound("sound/call.mp3",false);
	elseif data.nType == 3 then  --//过牌
		str = "rangpai"
		self.Text_BetTb[seat]:setString(gameRealMoney(data.lTurnNode));
	elseif data.nType == 4 then  --//弃牌
		str = "qipai"
		self.Image_BetTb[seat]:setVisible(false);
		-- self.pokerListBoard[seat+1]:giveupHandPoker()
		self.m_cardLayer:foldCards(seat);
		if data.byUser == self.tableLogic._mySeatNo then
			self.isPlaying = false;
		end
	elseif data.nType == 5 then  --//全下
		str = "quanxia"
		self.Text_BetTb[seat]:setString(gameRealMoney(data.lTurnNode));
		self:showPlayerAllinAnim(seat)
		audio.playSound("sound/all_in.mp3",false);
		if data.byUser == self.tableLogic._mySeatNo then
			-- audio.pauseMusic();
			playMusic("dezhoupuke/sound/newbgm.mp3", true);
			self.AllinEffect = true --audio.playSound("dezhoupuke/sound/newbgm.mp3",true);
		end
	elseif data.nType == 6 then  --//自动 大小盲注
		self.Text_BetTb[seat]:setString(gameRealMoney(data.lTurnNode));
	end
	local userinfo = self.tableLogic:getUserBySeatNo(data.byUser);
	if userinfo then
		if getUserSex(userinfo.bLogoID,userinfo.bBoy) == true then
			str = "sound/M/"..str..".mp3"
		else
			str = "sound/W/"..str..".mp3"
		end
	end
	audio.playSound(str,false);
	
	--add showchip
	self:playBetAnim(seat, data.nType)



	local naneType = {"dzpk_w_genzhutishi","dzpk_w_jiazhutishi","dzpk_w_rangpai","dzpk_w_qipaitishi","dzpk_w_quanxia-zi"}
	if data.nType ~= 6 then
		self.Image_statusTb[seat]:setVisible(true)
		self.Image_statusTb[seat]:loadTexture(naneType[data.nType]..".png",UI_TEX_TYPE_PLIST)
		self.Image_statusTb[seat]:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.FadeOut:create(1.5)))
	end

	self.Panel_opTurn:setVisible(false)
	self.Panel_opCall:setVisible(false)
	-- self.Panel_opWait:setVisible(false)
	self.Panel_opRaise:setVisible(false);
	self:stopPlayerTimer(seat)
end

function TableLayer:receiveSendCardInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"sendcard")
	if data.nTypeCard == 1 then --下发两张手牌
		data.m_iBigBlindVseat = self.m_iBigBlindVseat; --从大盲注玩家位置开始 按照顺时针方向发牌
		self:licensingCards(data);
		-- for i=1,5 do
		-- 	if self.tableLogic._existPlayer[i] and data.iUserState[i] == 1 then
		-- 		local seat = self.tableLogic:logicToViewSeatNo(i-1);
		-- 		luaPrint("seat== "..seat)
		-- 		self.pokerListBoard[seat+1]:createHandPoker(data.byCards[i]);
		-- 	end
		-- end
		if data.byPublicCards[5] > 0 then
			self:licensingBoardFlopCards(data.byPublicCards,5);
		end
		

	elseif data.nTypeCard == 2 then --下发 3张牌
		for i=1,5 do
			if self.tableLogic._existPlayer[i] then
				local seat = self.tableLogic:logicToViewSeatNo(i-1);
				luaPrint("seat== "..seat)
				self.Image_BetTb[seat]:setVisible(false);
			end
		end

		self:licensingBoardFlopCards(data.byPublicCards,3);

		if data.iCardsNum >= 3 then
			local iKind = data.iCardShape;
			if iKind > 0 then
				self.m_cardLayer:showCardKind(0, iKind);
			else
				self.m_cardLayer:hideCardKind(0);	
			end
		end

	elseif data.nTypeCard == 3 then --下发 4,5张公共牌
		-- self.pokerListBoard[6]:createCommonCard(data.byCards[1],data.iCardsNum);
		for i=1,5 do
			if self.tableLogic._existPlayer[i] then
				local seat = self.tableLogic:logicToViewSeatNo(i-1);
				luaPrint("seat== "..seat)
				self.Image_BetTb[seat]:setVisible(false);
			end
		end

		local count = self.m_cardLayer:getBoardCardsCount();
		if count == 0 then
			self:licensingBoardFlopCards(data.byPublicCards,5);
		elseif count == 3 then
			--发牌桌River 河牌 - 第4张公共牌
			if data.byPublicCards[4] == 0 then
				addScrollMessage("card 4 is 0");
			end
			self:licensingTurnRiverCard(4,data.byPublicCards[4])
		elseif count == 4 then
			--发牌桌第5张牌 TURN 转牌
			if data.byPublicCards[5] == 0 then
				addScrollMessage("card 5 is 0");
			end
			self:licensingTurnRiverCard(5,data.byPublicCards[5])
		elseif count == 5 then

		end

		local iKind = data.iCardShape;
		if iKind > 0 then
			self.m_cardLayer:showCardKind(0, iKind);
		else
			self.m_cardLayer:hideCardKind(0);	
		end
		-- if data.byCards[1][5] ~= 0  then
		-- 	--发牌桌River 河牌 - 第五张公共牌
		-- 	self:licensingTurnRiverCard(5,data.byCards[1][5])
		-- elseif data.byCards[1][4] ~= 0 then
		-- 	--发牌桌第四张牌 TURN 转牌
		-- 	self:licensingTurnRiverCard(4,data.byCards[1][4])
		-- else
		-- 	-- self:licensingBoardFlopCards(data.byCards);
		-- end
	end
	
end


function TableLayer:receiveGameEndInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	self:stopAllPlayerTimer();
	self.Panel_opTurn:setVisible(false)
	self.Panel_opCall:setVisible(false)
	self.Panel_opWait:setVisible(false)
	self.Panel_opRaise:setVisible(false);
	self:playDengDaiEffect(false)
	self.isPlaying = false;
	local data = data._usedata;
	luaDump(data,"gameend")
	self:runGameEnd(data);
	-- self.pokerListBoard[1]:setPokerTouchEnAbled(false)
	if data.bAutoGiveUp then
		self.Panel_continue:setVisible(true);
	end
	self.cointable = {};
	for i=1,5 do
		local seat = self.tableLogic:logicToViewSeatNo(i-1);
		if data.bWin[i] == true then
			for j=1,5 do
				self:runAction(cc.Sequence:create(cc.DelayTime:create((j-1)*0.1),cc.CallFunc:create(function() 
				local coin = ChipNodeManager.new(self);
				coin:ChipCreate(seat+1);
				table.insert(self.cointable,coin);
				end)))
			end
			audio.playSound("sound/fly_gold.mp3",false);
		end
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
				cc.CallFunc:create(function() 
					self.cointable = {};
				end)))

	--亮牌
	local mingTb = {}
	for i,v in ipairs(data.byMingCard) do
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		mingTb[vSeat] = v;
	end
	luaDump(mingTb, "mingTb-------", 5)
	self.m_cardLayer:showCards(mingTb);


	for i=1,5 do
		if data.nSelfMoney[i] > 0 then
			local seat = self.tableLogic:logicToViewSeatNo(i-1);
			self.m_lPlayerCoinTb[seat] = data.nSelfMoney[i];
			self.Text_coinTb[seat]:setString(gameRealMoney(data.nSelfMoney[i]));
			--self.pokerListBoard[seat+1]:updataHandPoker(data.byMingCard[i],0)
			if i-1 == self.tableLogic._mySeatNo then
				self.m_playerMoney = data.nSelfMoney[i];
			end
		end
	end


	

	-- addScrollMessage("游戏结束")
	self:runAction(cc.Sequence:create(cc.DelayTime:create(2),
			cc.CallFunc:create(function() 
				
				self:playWillStart();
		end)))
end

--获取人数
function TableLayer:getDeskRenshu()
	local count = 0
	for i=1,PLAY_COUNT do
		if self.tableLogic._existPlayer[i] then
			count = count + 1;
		end
	end
	return count;
end

--即将开始 
function TableLayer:playWillStart()
	if self.isPlaying == true then
		return;
	end
	self:stopAllPlayerTimer();
	local count = self:getDeskRenshu();

	if count <= 1 then
		self:clearDesk();
		self:playDengDaiEffect(true,2)
		return;
	end
	
	local jijiangkaishi = createSkeletonAnimation("jijiangkaishi","game/jijiangkaishi.json","game/jijiangkaishi.atlas");
	if jijiangkaishi then
		jijiangkaishi:setPosition(640,360);
		jijiangkaishi:setAnimation(1,"3s", false);
		self.Panel_anim:addChild(jijiangkaishi,2);
	end
	self.willStartSpine = jijiangkaishi;
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() 
		if self.willStartSpine then
			self.willStartSpine:removeFromParent();
		end
		self.willStartSpine = nil;
		
		local count = self:getDeskRenshu();

		if count <= 1 then
			self:clearDesk();
			self:playDengDaiEffect(true,2)
			return;
		end
	end)))
end

--边池更新
function TableLayer:receiveBetpoolupInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"receiveBetpoolupInfo")
	self:showZhuchi(data.iBetPools)
	
end

--显示主池，边池
function TableLayer:showZhuchi(data)
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	local sum = 0;
	local count = 0;
	
	for k,v in pairs(data) do
		sum = sum + v;
		if v > 0 then
			count = count +1;
		end
	end

	self.Panel_potBanner:removeAllChildren();
	--底池
	-- self.Image_pot:setVisible(true);
	self.Text_pot:setString(gameRealMoney(sum))

	local size = self.Panel_potBanner:getContentSize()
	local imgName = ""
	if count > 0 then
		for i=1,count do
			if i == 1 then
				imgName = "dzpk_zhuchi_noword.png"
			else
				imgName = "dzpk_bianchi_noword.png"
			end
			local bgchi = ccui.ImageView:create();
			bgchi:loadTexture(imgName,UI_TEX_TYPE_PLIST);
			bgchi:setPosition(size.width/2+65*(2*i-count-1),size.height/2);
			self.Panel_potBanner:addChild(bgchi);

			local bgSize = bgchi:getContentSize()
			local text = FontConfig.createWithSystemFont(gameRealMoney(data[i]),20,FontConfig.colorWhite);
			text:setPosition(bgSize.width/2+15,bgSize.height/2);
			bgchi:addChild(text);
			if data[i] >= 100000 then
				text:setScale(0.8)
			elseif data[i] >= 10000000 then
				text:setScale(0.6)
			end

		end
	end
end

--比牌
function TableLayer:receiveCompareCardInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	self.Panel_opTurn:setVisible(false)
	self.Panel_opCall:setVisible(false)
	self.Panel_opWait:setVisible(false)
	self.Panel_opRaise:setVisible(false);
	local data = data._usedata;
	luaDump(data,"receiveCompareCardInfo")
	-- for i=1,5 do
	-- 	if self.tableLogic._existPlayer[i] then
	-- 		local seat = self.tableLogic:logicToViewSeatNo(i-1);
	-- 		luaPrint("seat== "..seat)
	-- 		self.pokerListBoard[seat+1]:updataHandPoker(data.bHandCards[i],data.nCardKind[i]);
	-- 	end
	-- end
	local cardKindTb = {};
	local cardTb = {};
	for i,v in ipairs(data.bHandCards) do
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		cardTb[vSeat] = v;
	end

	for i,v in ipairs(data.nCardKind) do
		
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		cardKindTb[vSeat] = v;
	end
	
	self:revealCards(cardTb,cardKindTb);

	local vSeat = 0;
	local maxPaiType = 1;
	for k,v in pairs(data.nCardKind) do
		if maxPaiType <= v then
			vSeat = k-1;
			maxPaiType = v;
		end
	end

	self:playPaiTypeEffect(data.bMaxStation,maxPaiType)
	self:stopAllPlayerTimer();
end

--播放牌型动画
function TableLayer:playPaiTypeEffect(vSeat,maxPaiType)
	local function playSound(vSeat,nKind)
   		if not self.m_bEffectOn then
   			return;
   		end

   		local soundName = {"gaopai","duizi","liangdui","santiao","shunzi","shunzi","tonghua","hulu","sitiao","tonghuashun","tonghuashun","huangjiatonghuashun",}
		if nKind > 0 then
			local userinfo = self.tableLogic:getUserBySeatNo(vSeat);
			local str = "";
			str = soundName[nKind];
			if userinfo then
				if getUserSex(userinfo.bLogoID,userinfo.bBoy) == true then
					str = "sound/M/"..str..".mp3"
				else
					str = "sound/W/"..str..".mp3"
				end
			else
				str = "sound/W/"..str..".mp3"
			end

			audio.playSound(str,false);
		end
   	end

  
   	
   

	local spineName = {"anim/hulu/hulu",
						"anim/sitiao/sitiao",
						"anim/tonghuashun/tonghuashun",
						"anim/huangjiatonghuashun/huangjiatonghuashun",
						"dezhoupuke/anim/shunzi",
						"dezhoupuke/anim/tonghua",}
	local tName = {"hulu","sitiao","tonghuashun","huangjiatonghuashun","shunzi","tonghua"}
	
	if maxPaiType >= 5  then --葫芦及以上播放动画
		local itype = 1
		if maxPaiType == 8 then
			itype = 1
		elseif maxPaiType == 9 then
			itype = 2
		elseif maxPaiType == 10 or maxPaiType == 11  then
			itype = 3
		elseif maxPaiType == 12 then
			itype = 4
		elseif maxPaiType == 5 or maxPaiType == 6 then --顺子 5,6
			itype = 5
		elseif maxPaiType == 7 then --同花 7
			itype = 6	
		end
		
		local action1 = cc.DelayTime:create(1.2)
		local action2 = cc.CallFunc:create(function() 
			self.paiTypeSpine = createSkeletonAnimation(tName[itype],spineName[itype]..".json",spineName[itype]..".atlas");
			if self.paiTypeSpine then
				playSound(vSeat,maxPaiType);
				self.paiTypeSpine:setPosition(640,360);
				self.paiTypeSpine:setAnimation(1,tName[itype], false);
				self.Panel_anim:addChild(self.paiTypeSpine,2);
			end
		end)
		local action3 = cc.DelayTime:create(3)
		local action4 = cc.CallFunc:create(function()
						if self.paiTypeSpine then
							self.paiTypeSpine:removeFromParent()
							self.paiTypeSpine = nil;
						end

						end)
		
		self:runAction(cc.Sequence:create(action1,action2,action3,action4))


	else
		local action1 = cc.DelayTime:create(1.2);
		local action2 = cc.CallFunc:create(function() 
			playSound(vSeat,maxPaiType);
			
		end)
		local node = cc.Node:create();
		self:addChild(node);
		node:runAction(cc.Sequence:create(action1,action2,cc.RemoveSelf:create()));
	end

end

--托管
function TableLayer:receiveAutoTokenInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"receiveAutoTokenInfo")
	if data.autoType ==3 then
		self.Image_callEndMark:setVisible(data.bAuto);
		if self.Image_callCheckMark:isVisible() then
			self.Image_callCheckMark:setVisible(false);
		end
	elseif data.autoType ==4 then
		self.Image_callCheckMark:setVisible(data.bAuto);
		if self.Image_callEndMark:isVisible() then
			self.Image_callEndMark:setVisible(false);
		end
	end
	
    		
end

--令牌消息
function TableLayer:receiveTokenInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"receiveTokenInfo")

	if data.byUser == self.tableLogic._mySeatNo then
		self.Panel_opTurn:setVisible(true)
		self.Panel_opCall:setVisible(true);
		self.Panel_opWait:setVisible(false)
		self.m_callMoney = data.nCallMoney;--跟多少
		self.m_addMoney = data.nCallMoney + self.iCellNode*2;--加注多少
		if bit:_and(data.byVerbFlag,0x01) ~= 0 then      --可以跟注
			self.Button_callRaise:setVisible(true);
			self.Text_callAmount:setString(gameRealMoney(data.nCallMoney))
			if data.nCallMoney >= 100000 then
				self.Text_callAmount:setScale(0.8)
			elseif data.nCallMoney >= 10000000 then
				self.Text_callAmount:setScale(0.6)
			else
				self.Text_callAmount:setScale(1)
			end
		else
			self.Button_callRaise:setVisible(false);
		end

		if bit:_and(data.byVerbFlag,0x02) ~= 0 then 	--可以加注
			self.Button_raiseTo:setEnabled(true)
		else
			self.Button_raiseTo:setEnabled(false)
		end

		if bit:_and(data.byVerbFlag,0x04) ~= 0 then     --可以弃牌
			self.Button_fold:setEnabled(true)
		else
			self.Button_fold:setEnabled(false)
		end

		if bit:_and(data.byVerbFlag,0x08) ~= 0 then     --可以过牌
			self.Button_check:setVisible(true)
		else
			self.Button_check:setVisible(false)
		end

		if bit:_and(data.byVerbFlag,0x10) ~= 0 then     --可以全下
			self.Button_allIn:setVisible(true)
		else
			self.Button_allIn:setVisible(false)
		end
	else
		if data.iUserState[self.tableLogic._mySeatNo+1] == 1 and not data.bAllin then
			self.Panel_opWait:setVisible(true)
			self.Panel_opTurn:setVisible(false)
		end
	end
	self:updateRaiseBtnStatus();

	local seat = self.tableLogic:logicToViewSeatNo(data.byUser);
	self:stopAllPlayerTimer();
	self:showPlayerTimer(seat,self.m_ThinkTime,self.m_ThinkTime)
end


--亮牌
function TableLayer:receiveMingCardInfo(data)
	local data = data._usedata;
	-- self.pokerListBoard[1]:setPokerDeal(data.bMing)
	self.m_cardLayer:markRevealTag(0,data.bMing);
end

--allin亮牌
function TableLayer:receiveAllinMingCardInfo(data)
	local data = data._usedata;
	luaDump(data, "receiveAllinMingCardInfo---------1", 4)
	local msg = {};
	for i,v in ipairs(data.byHandCard) do
		local vSeat = self.tableLogic:logicToViewSeatNo(i-1);
		msg[vSeat] = v;
	end
	self.m_cardLayer:showAllInCards(msg);

end

--断线
function TableLayer:receiveUserCutInfo(data)
	local data = data._usedata;
	self:gameUserCut(data.bDeskStation, data.bCut);
end

--旁观
function TableLayer:receiveWatcherSitInfo(data)
	local data = data._usedata;
	luaDump(data,"pangguan")

	-- self.pangguan[data.wChairID + 1] = 1;
	
end

function TableLayer:showPlayerTimer(vSeat,allDt,leftDt)
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


function TableLayer:stopPlayerTimer(vSeat)
	luaPrint("stopPlayerTimer_vSeat:",vSeat)
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

--同意
function TableLayer:gameUserAgree(data)
	if self.m_bGameStart ~= true then
		return;
	end
	luaDump(data,"tongyi")
	local seat = self.tableLogic:logicToViewSeatNo(data.bDeskStation)
	luaPrint("seat= "..seat);

	-- self.Image_zhunbei[seat+1]:setVisible(true);
	-- if  data.bDeskStation == self.tableLogic._mySeatNo then
	-- 	self.Button_zhunbei:setVisible(false);
	-- end
	-- local count = self:getDeskRenshu();
	-- if count > 1 then
	-- 	if self.ziSpine then
	-- 		self.ziSpine:setVisible(false);
	-- 	end
	-- end
end

--刚进入游戏游戏状态
function TableLayer:showGameStatus(data,status)
	self:stopAllActions();
	self:clearDesk();
	luaDump(data,"showGameStatus")
	self.iCellNode = data.iCellNode; --小盲注
	self.m_callMoney = data.nCallMoney;--跟多少
	self.m_addMoney = data.nCallMoney + self.iCellNode*2;--加注多少
	self.m_ThinkTime = data.iThinkTime;--思考时间
	self.m_iBigBlindVseat = self.tableLogic:logicToViewSeatNo(data.bBigBlind);--大盲注位置
	self.m_iSmallBlindVseat = self.tableLogic:logicToViewSeatNo(data.bSmallBlind);--小盲注位置
	--重置下注额度
	self:resetRaiseAmount(self.iCellNode);
	if status == GameMsg.GS_FREE or status == GameMsg.GS_WAIT_NEXT then --空闲中
		self.isPlaying = false;
	elseif status == GameMsg.GS_PLAY_GAME then    --游戏中
		self.isPlaying = true;
		
		--手牌
		for i=1,5 do
			if  data.iUserState[i] == 1 or data.iUserState[i] == 2 then
				local seat = self.tableLogic:logicToViewSeatNo(i-1);
				luaPrint("seat== "..seat)
				
				-- self.pokerListBoard[seat+1]:createHandPoker(data.byHandCard);
				
				if data.iUserState[i] == 2 then--弃牌
					-- self.pokerListBoard[seat+1]:giveupHandPoker()
				else
					if data.lTurnNode[i] > 0 then
						self.Image_BetTb[seat]:setVisible(true);
						self.Text_BetTb[seat]:setString(gameRealMoney(data.lTurnNode[i]));
						if data.lTurnNode[i] >=100000 then
							self.Text_BetTb[seat]:setScale(0.8)
						else
							self.Text_BetTb[seat]:setScale(1)
						end
					end
				end
				--玩家金币
				if i-1 == self.tableLogic._mySeatNo then
					self.m_playerMoney = data.lUserMoney[i];
				end
				self.m_lPlayerCoinTb[seat] = data.lUserMoney[i];
				self.Text_coinTb[seat]:setString(gameRealMoney(data.lUserMoney[i]));
			end
			
		end
		if data.iUserState[self.tableLogic._mySeatNo + 1] == 3 then--观战
			self:playDengDaiEffect(true,1)
			self.isPlaying = false;
		elseif data.iUserState[self.tableLogic._mySeatNo + 1] == 2 then --弃牌
			self.isPlaying = false;
		end
		--参与游戏玩家
		local seatedTb = {};
		local seatedFoldTb = {};  --弃牌玩家
		for i=1,5 do
			local index = i-1;
			local vSeat = self.tableLogic:logicToViewSeatNo(index);
			if data.bAllin[i] == true then
				self:showPlayerAllinAnim(vSeat)
				if i-1 == self.tableLogic._mySeatNo then
					-- audio.pauseMusic();
					playMusic("dezhoupuke/sound/newbgm.mp3", true);
					self.AllinEffect = true --audio.playSound("dezhoupuke/sound/newbgm.mp3",true);
				end
			end
			if  data.iUserState[i] == 1 or data.iUserState[i] == 2 then
				table.insert(seatedTb,vSeat);
			end

			if data.iUserState[i] == 2 then
				table.insert(seatedFoldTb,vSeat);
			end
		end
		luaDump(seatedTb, "seatedTb---------123", 3)
		luaDump(seatedTb, "seatedFoldTb---------123", 3)
		--恢复玩家手牌
		local handCards = {}
		for i,v in ipairs(data.byHandCard) do
			local index = i-1;
			local vSeat = self.tableLogic:logicToViewSeatNo(index);
			handCards[vSeat] = v;
		end
		--bMingCard
		self.m_cardLayer:resumePlayerCards(seatedTb, handCards,data.bMingCard);
		self.m_cardLayer:resumeFoldTag(seatedFoldTb);

		--跟任何
		if  self.Image_callEndMark then
			self.Image_callEndMark:setVisible(data.bFollowAll);
		end
		
		--让或弃
		if self.Image_callCheckMark then
			self.Image_callCheckMark:setVisible(data.bCheckOrfold);
		end

		--公共牌
		if data.nCardsCount >= 3 then
			-- self.pokerListBoard[6]:createCommonCard(data.byCards,data.nCardsCount);
			self.m_cardLayer:resumeBoardCards(data.byCards);
		end

		--显示牌型
		-- local iKind = data.iCardShape;

		--iCardShape tb
		for i,v in ipairs(data.iCardShape) do
			local index = i-1;
			local vSeat = self.tableLogic:logicToViewSeatNo(index);
			local iKind = v;
			if iKind > 0 then
				self.m_cardLayer:showCardKind(vSeat, iKind);
			else
				self.m_cardLayer:hideCardKind(vSeat);	
			end
		end

		
		

		--庄家
		local zseat = self.tableLogic:logicToViewSeatNo(data.byNTUser);
		self.Image_bankerTb[zseat]:setVisible(true);
		-- 令牌玩家
		if data.byTokenUser == self.tableLogic._mySeatNo then
			self.Panel_opTurn:setVisible(true)
			self.Panel_opCall:setVisible(true);
			self.Panel_opWait:setVisible(false)

			if bit:_and(data.byVerbFlag,0x01) ~= 0 then      --可以跟注
				self.Button_callRaise:setVisible(true);
				self.Text_callAmount:setString(gameRealMoney(data.nCallMoney))
			else
				self.Button_callRaise:setVisible(false);
			end

			if bit:_and(data.byVerbFlag,0x02) ~= 0 then 	--可以加注
				self.Button_raiseTo:setEnabled(true)
			else
				self.Button_raiseTo:setEnabled(false)
			end

			if bit:_and(data.byVerbFlag,0x04) ~= 0 then     --可以弃牌
				self.Button_fold:setEnabled(true)
			else
				self.Button_fold:setEnabled(false)
			end

			if bit:_and(data.byVerbFlag,0x08) ~= 0 then     --可以过牌
				self.Button_check:setVisible(true)
			else
				self.Button_check:setVisible(false)
			end

			if bit:_and(data.byVerbFlag,0x10) ~= 0 then     --可以全下
				self.Button_allIn:setVisible(true)
			else
				self.Button_allIn:setVisible(false)
			end
		else
			if data.byTokenUser ~= 255 then 
				if data.iUserState[self.tableLogic._mySeatNo+1] == 1 and not data.bAllin[self.tableLogic._mySeatNo+1] then
					self.Panel_opWait:setVisible(true)
					self.Panel_opTurn:setVisible(false)
				end
			else
				self.Panel_opWait:setVisible(false)
				self.Panel_opTurn:setVisible(false)
				self.Panel_opCall:setVisible(false);
				self.Panel_opRaise:setVisible(false);
				self:stopAllPlayerTimer();
			end
		end
		if data.byTokenUser ~= 255 then
			local lseat = self.tableLogic:logicToViewSeatNo(data.byTokenUser);
			self:stopAllPlayerTimer();
			self:showPlayerTimer(lseat,data.iThinkTime,data.iSTime)
		end

	end
	

	--底池
	self:showZhuchi(data.nBetPools)
	
	local count = self:getDeskRenshu();
	if count == 1 then
		self:playDengDaiEffect(true,2);
	elseif status == GameMsg.GS_FREE or status == GameMsg.GS_WAIT_NEXT then
		self:playDengDaiEffect(true,1);
	end

end


--刷新其他玩家信息list
function TableLayer:gamePoint()
	luaPrint("gamePoint")
end

function TableLayer:isValidSeat(seatNo)
	return seatNo < PLAY_COUNT and seatNo >= 0;
end

--添加用户
 function TableLayer:addUser(deskStation, bMe)
	if not self:isValidSeat(deskStation) then 
		return;
	end

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
	luaPrint("addPlayer(userInfo) -------------------"..deskStation)
	
	if userInfo then
		luaDump(userInfo,"userInfo")
		self.Panel_PlayerTb[deskStation]:setVisible(true);
		
		self.Text_nameTb[deskStation]:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		self.Text_nameTb[deskStation]:setFontSize(22);
		self.m_lPlayerCoinTb[deskStation] = userInfo.i64Money;
		self.Text_coinTb[deskStation]:setString(gameRealMoney(userInfo.i64Money));
		-- self.Image_BetTb[deskStation]:setVisible(true);
		-- self.Text_BetTb[deskStation]:setString("");
		self.Image_headTb[deskStation]:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		-- self.Image_headTb[deskStation]:setScale(1.1);
		self.Image_headTb[deskStation]:setVisible(true);
		local headSize = self.Image_headTb[deskStation]:getContentSize();
		local size = cc.size(88,88);
		self.Image_headTb[deskStation]:setScale(size.width/headSize.width);
		if userInfo.bUserState == 2 then
			if bSeatNo == self.tableLogic._mySeatNo then
				self.m_playerMoney = userInfo.i64Money;
				-- self.Button_zhunbei:setVisible(true);
				self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
					-- DzpkInfo:sendMsgReady();
				end)))
				
			end
		end
	end
	
end

function TableLayer:removeUser(deskStation, bMe,bLock)
	if not self:isValidSeat(deskStation) then 
		return;
	end
	if bMe then
		local str = ""
		if bLock == 0 then
			-- str ="长时间未操作,自动退出游戏。"
		elseif bLock == 1 then
			str ="您的金币不足,自动退出游戏。"
			if self.m_bEffectOn then
	            playEffect("dezhoupuke/sound/poor.mp3", false);
	        end

	        local ziSpine = createSkeletonAnimation("pukemiaosha","game/gameEffect/pukemiaosha.json","game/gameEffect/pukemiaosha.atlas");
			if ziSpine then
				ziSpine:setPosition(640,360);
				ziSpine:setAnimation(1,"miaosha_dezhou", false);
				ziSpine:setName("ziSpine");
				self.Image_bg:addChild(ziSpine,10);
				ziSpine:runAction(cc.Sequence:create(cc.DelayTime:create(3.5),cc.CallFunc:create(function()
					self:onClickExitGameCallBack(5);
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
		self:onClickExitGameCallBack(5);
		-- self.Button_exit:setTouchEnabled(false);
		-- self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
		-- 	self.Button_exit:setTouchEnabled(true);
		-- 	addScrollMessage("您上局游戏没有操作或您的金币不足,自动退出游戏。")
		-- 	self:onClickExitGameCallBack();
		-- end)))
		return;
	end
	-- self.Node_player[deskStation+1]:setVisible(false);
	self.Panel_PlayerTb[deskStation]:setVisible(false);
	self.Image_headTb[deskStation]:setVisible(false);
	self.Text_nameTb[deskStation]:setString("");
	self.Text_coinTb[deskStation]:setString("");
	self.Image_offlineTb[deskStation]:setVisible(false);
	self.Image_ownerTb[deskStation]:setVisible(false);
	self.Image_statusTb[deskStation]:setVisible(false);
	self.Progerss_timerTb[deskStation]:setVisible(false);

	local count = self:getDeskRenshu();
	if count == 1 then
		self:clearDesk();
		self:playDengDaiEffect(true,2);
	end

	--移除弃牌玩家的牌
	self.m_cardLayer:removeSeatCard(deskStation);
end


function TableLayer:setUserMoney(money,seat)
	luaPrint("money= "..money.." seat= "..seat)
	self.m_lPlayerCoinTb[seat] = money;
	self.Text_coinTb[seat]:setString(gameRealMoney(money))
end

function gameRealMoney(money)
	return string.format("%.2f", money/100);
end

function TableLayer:showDeskInfo(gameInfo)
	-- luaDump(gameInfo,"gameInfo")

end

--字提示
function TableLayer:playZitiEffect(iType)
	local tipzi = {"dengdaitouzhu","dengdaiwanjia","qingqiangzhuang","qingtanpai","qingtouzhu"}
	
	if self.ziSpine then
		self.ziSpine:setVisible(true);
		self.ziSpine:clearTracks();
		self.ziSpine:setAnimation(1,tipzi[iType], false);
	else
		self.ziSpine = createSkeletonAnimation("tishizi","texiao/tishizi/tishizi.json","texiao/tishizi/tishizi.atlas");
		if self.ziSpine then
			self.ziSpine:setPosition(640,330);
			self.ziSpine:setAnimation(1,tipzi[iType], false);
			self:addChild(self.ziSpine,2);
		end
	end
end

function TableLayer:playDengDaiEffect(enable,iType)
	if enable then
		if self.dengDaiSpine then
			self.dengDaiSpine:setVisible(true);
		end
	else
		if self.dengDaiSpine then
			self.dengDaiSpine:setVisible(false);
		end
		return;
	end
	local tipzi = {"dengxiaju","dengwanjia"}
	if self.dengDaiSpine then
		self.dengDaiSpine:clearTracks();
		self.dengDaiSpine:setAnimation(1,tipzi[iType], true);
	else
		self.dengDaiSpine = createSkeletonAnimation("dengdai","game/dengdai/dengdai.json","game/dengdai/dengdai.atlas");
		if self.dengDaiSpine then
			self.dengDaiSpine:setPosition(800,150);
			self.dengDaiSpine:setAnimation(1,tipzi[iType], true);
			self.Panel_anim:addChild(self.dengDaiSpine,10);
		end
	end
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

	if self.tableLogic._mySeatNo ==  lSeat then
		self.m_playerMoney = self.m_playerMoney + data.OperatScore;	
	end

	local seat = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
	self.Text_coinTb[seat]:setString(gameRealMoney(self.m_playerMoney));

end

--下注筹码堆 动画
function TableLayer:playBetAnim(betVseat,betKind)
	do
		return;
	end
	--server betKind 1-跟注 2-加注 3-过牌 4-弃牌 5-全下 6-自动

-- 	Common.BET_CALL = 1; --下注跟注
-- Common.BET_RAISE = 2; --加注
-- Common.BET_ALLIN = 3; --全下
	--下注 跟注 筹码 一组 高度 6
	--加注 筹码 3组  高度6
	--全下 筹码 5组  高度9
	if betKind == 1 then  --跟注
		betKind = Common.BET_CALL;
	elseif betKind == 2 then --加注
		betKind = Common.BET_RAISE;
	elseif betKind == 5 then --全下
		betKind = Common.BET_ALLIN;
	elseif betKind == 6 then --自动
		betKind = Common.BET_CALL;
	else
		return;
	end
	-- local betKind = 3;
	-- local betVseat = 1;
	-- vSeat = betVseat;


	local xx = 1;
	local yy = 1;
	local hh = 1;
	local vSeat = betVseat;	--下注玩家位置   0--从下推上 1,2,3,4 上推下
	self.Text_BetTb[vSeat]:setVisible(false);
	if betKind == Common.BET_CALL then
		xx = 2;
		yy = 1;
		hh = 4;
	elseif betKind == Common.BET_RAISE then
		xx = 3;
		yy = 3;
		hh = 6;
	elseif betKind == Common.BET_ALLIN then
		xx = 3;
		yy = 3;
		hh = 9;
	else
		xx = 1;
		yy = 1;
		hh = 3;
	end

	-- self.Panel_anim:removeAllChildren();

	local gap = 22*0.6;
	local didth = 6.5;   --筹码间隙
	-- local node = cc.Node:create();
	local node = cc.LayerColor:create(cc.c4b(255,255,255,255))
	-- local node = ccui.ImageView:create();
	-- node:loadTexture("dezhoupuke/image/chip/szp_chouma1.png",UI_TEX_TYPE_LOCAL);
	node:setCascadeOpacityEnabled(true);
	node:setContentSize(cc.size(1,1));
	-- node:setAnchorPoint(cc.p(0.5,0.5));
	self.Panel_anim:addChild(node);

	local cellSize = cc.size(28,22);
	local times = 0;
	local height = xx*cellSize.height*0.5;

	--目标位置
	local pos_head = self.Image_headTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_headTb[vSeat]:getPosition()));
	local pos_s = self.Panel_anim:convertToNodeSpace(pos_head);

	local pos_t = self.Image_BetTb[vSeat]:getParent():convertToWorldSpace(cc.p(self.Image_BetTb[vSeat]:getPosition()));
	pos_t.x = pos_t.x + 15;

	local faceDirect = 1;
	if vSeat == 0 then
		pos_s = cc.p(pos_t.x,pos_t.y - height*2 - didth*xx - cellSize.height);
		faceDirect = -1;
	else
		pos_s = cc.p(pos_t.x,pos_t.y + height*0 + didth*xx + cellSize.height);
		faceDirect = 1;
	end

	node:setPosition(pos_s);
	--堆叠筹码
	local chipPathList = {};
	local chipStr = "dezhoupuke/image/chip/szp_chouma1.png";
	for i=1,10 do
		local str = string.format("dezhoupuke/image/chip/szp_chouma%d.png",i);
		table.insert(chipPathList,str);
	end
	luaDump(chipPathList,"chip_path_tb", 3);
	
	if xx%2 == 0 then
		--偶数
		for i=1,xx do
			local pos = pos_s;
			local x = 0;
			local number = math.floor((i-1)/2);
			local left = -1;
			if i%2 == 0 then
				left = 1;
			end
			x = number*left*cellSize.width + cellSize.width*0.5*left;
			for n=1,yy do
				local y = 0;
				local number = math.floor((y-1)/2);
				local up = 1;
				if n%2 == 0 then
					up = -1;
				end

				--总数
				local beginY = 0;
				if yy%2 == 0 then
					beginY = cellSize.height*1*up;
				else
					beginY = cellSize.height*0.5*up;
				end

				y = beginY + cellSize.height*number;

				for h=1,hh do
					local img = ccui.ImageView:create();
					-- local index = math.random(1,10);
					-- local chipPath = chipPathList[index];
					local chipPath = chipStr;
					img:loadTexture(chipPath,UI_TEX_TYPE_LOCAL);
					local order = 1000+h-faceDirect*100;
					node:addChild(img,order);
					img:setVisible(false);
					img:setScale(0.25);
					img:setPosition(cc.p(x,y+h*didth));

					local showIt = cc.Show:create();
					local delayIt = cc.DelayTime:create(h*0.04);
					seq = cc.Sequence:create(delayIt,showIt);  
					img:runAction(seq);
				end
				
			end
		end
	else
		--奇数
		for i=1,xx do  --计算y长度
			local pos = pos_s;
			for n=1,i do		--计算X宽度
				local per = (i+1)%2;
				local direct = math.floor(math.abs((n-1)%2));
				if direct == 1 then
					direct = -1;
				else
					direct = 1;
				end
				local step = math.ceil(math.abs((n-1)/2));
				local x =  per*cellSize.width*0.5+step*direct*cellSize.width;
				local y =  (i-1)*cellSize.height*faceDirect-height*faceDirect;
				for h=1,hh do
					times = times + 1;
					local img = ccui.ImageView:create();
	    			-- local index = math.random(1,10);
					-- local chipPath = chipPathList[index];
					local chipPath = chipStr;
					img:loadTexture(chipPath,UI_TEX_TYPE_LOCAL);
					local order = 1000+h-faceDirect*100;
					node:addChild(img,order);
					img:setVisible(false);
					img:setScale(0.25);
					img:setPosition(cc.p(x,y+h*didth));

					local showIt = cc.Show:create();
					local delayIt = cc.DelayTime:create(h*0.04);
					seq = cc.Sequence:create(delayIt,showIt);  
					img:runAction(seq);
				end
			end
		end
	end

	


	

	local showIt = cc.Show:create();
	local delayIt = cc.DelayTime:create(12*0.08);
	local moveTo = cc.MoveTo:create(0.3,pos_t);
	local scaleTo = cc.ScaleTo:create(0.3,0.5);
	local spawnIt = cc.Spawn:create(moveTo,scaleTo);
	local fadeOut = cc.FadeOut:create(0.25);
	local removeIt = cc.RemoveSelf:create();
	local actionCallback = cc.CallFunc:create(function (sender)
			luaPrint("run over~")
			self.Text_BetTb[vSeat]:setVisible(true);
	end)

	seq = cc.Sequence:create(delayIt,spawnIt,actionCallback,removeIt);  
	node:runAction(seq);
	
end











--进入后台
function TableLayer:refreshEnterBack(data)
	luaPrint("进入后台-----------refreshEnterBack")
	self.m_bGameStart = false;
end

--后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if device.platform == "windows" then
		-- return;
	end
	if RoomLogic:isConnect() then

		self.m_bGameStart = false;

		-- self:stopAllActions();

		-- self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
	else
		-- self.isPlaying = false;
		-- self:onClickExitGameCallBack();
	end
end

return TableLayer;
