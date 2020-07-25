local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("saoleihongbao.TableLogic");
-- local PlayerLayer = require("saoleihongbao.PlayerLayer");
-- local LayMineLayer = require("saoleihongbao.LayMineLayer");
local Common   = require("saoleihongbao.Common");
local HelpLayer = require("saoleihongbao.HelpLayer");

--local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

--扫雷玩家位置
local STAND_POS_ARR ={
	cc.p(33,446),
	cc.p(33,351),
	cc.p(33,256),
	cc.p(33,161),
	cc.p(33,66),

	cc.p(1008,446),
	cc.p(1008,351),
	cc.p(1008,256),
	cc.p(1008,161),
	cc.p(1008,66),
}

local WIN_POS_ARR ={
	cc.p(295,489),
	cc.p(295,394),
	cc.p(295,299),
	cc.p(295,204),
	cc.p(295,109),

	cc.p(988,489),
	cc.p(988,394),
	cc.p(988,299),
	cc.p(988,204),
	cc.p(988,109),
}

local TAG_PLAYER = 1000;
local TAG_WIN = 2000;

--手指
local Spine_Shouzhi ={
		name = "shouzhi",
		json = "saoleihongbao/anim/shouzhi.json",
		atlas = "saoleihongbao/anim/shouzhi.atlas",		
}

local Spine_Win ={
		name = "huodehongbao",
		json = "saoleihongbao/anim/huodehongbao.json",
		atlas = "saoleihongbao/anim/huodehongbao.atlas",		
}

local Spine_Lost ={
		name = "henyihan",
		json = "saoleihongbao/anim/henyihan.json",
		atlas = "saoleihongbao/anim/henyihan.atlas",		
}

local ROOM_TEN = 1;
local ROOM_SEVEN = 2;

--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)
	luaPrint("uNameId, bDeskIndex, bAutoCreate, bMaster",uNameId, bDeskIndex, bAutoCreate, bMaster)
	bulletCurCount = 0;
	-- GameMsg.init();

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

	PLAY_COUNT = 30;

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

	SLHBInfo:init();
	GameMsg.init();

	--获取ui
	local uiTable = {
		Image_bg = "Image_bg",		--背景图
		Panel_root = "1",	--背景桌子图

		Panel_richer = "1",		--埋雷层
		Button_richer = "1",		--申请布雷
		Image_richerHead = "1",		--埋雷头像
		Text_richerName = "1",			--埋雷玩家
		Button_expand = "1",	--	展开
		Button_shrink = "1",	--收缩 面板
		Text_winRicher = "1",	--财神赢钱
		Text_lostRicher = "1",	--财神输钱

		Panel_self = "1",	--玩家自己
		Image_selfHead = "1",	--头像
		Image_selfFrame = "1",	--头像框
		Text_selfName = "1",	--玩家名称
		Text_selfCoin = "1",	--玩家金币
		Button_player = "1",	--玩家按钮

		Panel_sweeper = "1",	--扫雷层
		Panel_cell = "1",	--扫雷玩家item
		Text_winScore = "1",	--结算win
		Text_lostScore = "1",	--结算lost
		Panel_layer = "1",	--玩家按钮
		Button_catch = "1",	--红包按钮
		Image_flash = "1",	--背光闪光
		Image_finger = "1",	--提示手指
		Image_clickme = "1",	--点我

		Panel_redBag = "1",
		Panel_banner = "1",	--信息层
		Image_redBanner = "1",	--红包金额图
		Image_redValue = "1",	--红包金额
		Text_redValue = "1",	--红包金额
		Image_redCount = "1",	--红包数量图
		Text_redCount = "1",	--红包数量
		Image_mineKey = "1",	--雷号图
		Text_mineKey = "1",	--雷号
		Image_countTime = "1",	--倒计时
		Image_countWord = "1",	--倒计时
		Text_time = "1",	--倒计时
		Text_tip  = "1",	--提示error

		Panel_box = "1",
		Panel_menu = "1",
		Button_exit = "1",
		Button_music = "1",
		Button_musicOff = "1",
		Button_bank = "1",
		Button_help = "1",
		Button_effect = "1",
		Button_effectOff = "1",

	}

	
	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end

	--适配
	uiTable["Button_expand"] = {"Button_expand",1};

	
	luaDump(uiTable,"uiTable------------1")

	-- 游戏内消息处理
	luaPrint("TableLayer:initUI---------------")
	loadNewCsb(self,"res/saoleihongbao/tablelayer",uiTable)

	local framesize = cc.Director:getInstance():getWinSize()
  	local addWidth = (framesize.width - 1280)/4;
  	
  	self["Panel_menu"]:setPositionX(self["Panel_menu"]:getPositionX()+addWidth);
  	self["Button_shrink"]:setPositionX(self["Button_shrink"]:getPositionX()+addWidth);
  	self["Button_expand"]:setPositionX(self["Button_expand"]:getPositionX()+addWidth);
  	self["Button_exit"]:setPositionX(self["Button_exit"]:getPositionX()-addWidth);

	self:initData();
	self:initUI();

	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	_instance = self;

end

function TableLayer:playBgMusic()
	luaPrint("self.m_iMuiscVolume:",self.m_iMuiscVolume,self.m_bMusicOn);
	if self.m_bMusicOn then
		playMusic("saoleihongbao/sound/bgm.mp3", true);
	end
end

--替换背景音乐 0 播放正常音效 1 埋雷成功后音效
function TableLayer:updataBgMusic(type)
	if self.m_bMusicOn then
		if type == 0 then
			playMusic("saoleihongbao/sound/bgm.mp3", true);
		else
			playMusic("saoleihongbao/sound/bgm1.mp3", true);
		end
	end
end
--进入
function TableLayer:onEnter()

	-- self:initUI()
	
	self:addPlist();
	
	self:bindEvent();--绑定消息
	
	
	self:playBgMusic();
	

	-- self:startGameMsgRun();

	-- EventMgr:registListener(Common.EVT_VIEW_MSG,self,self.onViewMsg);
 --  EventMgr:registListener(Common.EVT_DEAL_MSG,self,self.onDealMsg);


    self.super.onEnter(self);

    -- --进入房间提示
    -- self:showFingerTip();

end

--进入结束
function TableLayer:onEnterTransitionFinish()
	
end


function TableLayer:addPlist()
		display.loadSpriteFrames("saoleihongbao/image/slhb_image1.plist","saoleihongbao/image/slhb_image1.png");
		display.loadSpriteFrames("saoleihongbao/image/slhb_image2.plist","saoleihongbao/image/slhb_image2.png");
		display.loadSpriteFrames("saoleihongbao/image/slhb_finger.plist","saoleihongbao/image/slhb_finger.png");


end
--退出
function TableLayer:onExit()
	self.super.onExit(self);
	luaPrint("stopGameMsgRun-----------------")
	self.m_bEnterMsg = false;
	display.removeSpriteFrames("saoleihongbao/image/slhb_image1.plist","saoleihongbao/image/slhb_image1.png");
	display.removeSpriteFrames("saoleihongbao/image/slhb_image2.plist","saoleihongbao/image/slhb_image2.png");
	display.removeSpriteFrames("saoleihongbao/image/slhb_finger.plist","saoleihongbao/image/slhb_finger.png");
	self.super.onExit(self);
end


--绑定消息
function TableLayer:bindEvent()
	if self.m_bBindEvent == true then
		luaPrint("SLHB_bind_event true________________");
		return;
	end
	self:pushEventInfo(SLHBInfo, "SLHBGameFree", handler(self, self.onSLHBGameFree))
	self:pushEventInfo(SLHBInfo, "SLHBGameStart", handler(self, self.onSLHBGameStart))
	self:pushEventInfo(SLHBInfo, "SLHBGamePlantMine", handler(self, self.onSLHBGamePlantMine))
	self:pushEventInfo(SLHBInfo, "SLHBOpenRedbag", handler(self, self.onSLHBOpenRedbag))
	self:pushEventInfo(SLHBInfo, "SLHBGameEnd", handler(self, self.onSLHBGameEnd))
	self:pushEventInfo(SLHBInfo, "SLHBGameFinish", handler(self, self.onSLHBGameFinish))
	self:pushEventInfo(SLHBInfo, "SLHBRedBagList", handler(self, self.onSLHBRedBagList))

	
	

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

end

function TableLayer:removeUser(vSeatNo, bIsMe,bLock)
	luaPrint("removeUser:",vSeatNo,bIsMe);

	luaPrint("removeUser",bIsMe,bLock);
    if bIsMe then
		local str = ""
	    if bLock == 0 then
	      --str ="长时间未操作,自动退出游戏。"
	      self:onClickExitGameCallExit();
	    elseif bLock == 1 then
	      str ="您的金币不足,自动退出游戏。"
	      showBuyTip(true);
	    elseif bLock == 2 then
	      	str ="房间已关闭,自动退出游戏。"
    		self:onClickExitGameCallExit();
    		--addScrollMessage(str);
    	elseif bLock == 3 then
    		str ="长时间未操作,自动退出游戏。"
    		self:onClickExitGameCallExit();
    		--addScrollMessage(str);
    	elseif bLock == 5 then
    		str ="VIP房间已关闭,自动退出游戏。"
    		self:onClickExitGameCallExit();
    		--addScrollMessage(str);
	    end
	    addScrollMessage(str);
		
		return;
    end


end

function TableLayer:onClickExitGameCallExit()
	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	end

	Hall:exitGame(false,func)
end

--退出
function TableLayer:onClickExitGameCallBack()
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
	if self.m_curRicher == self.tableLogic._mySeatNo then
		addScrollMessage("庄家不能离开房间");
		return;
	end

	if self.isJoinGame then
		addScrollMessage("本局游戏您已参与,请等待开奖阶段结束。");
		return;
	end

	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	end

	local status = false;

	Hall:exitGame(status,func);
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

	
		RoomLogic:close();
		
		self._bLeaveDesk = true;
		_instance = nil;
	end

end

function TableLayer:UpdateUserList()
	if self.m_playerLayer:isVisible() then
		self.m_playerLayer:showIt();
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
	
end
-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	self:clearDesk();
end
 -- //清理桌面f
function TableLayer:clearDesk()
	for i=1,PLAY_COUNT do
	
	end
	
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
	-- self:refreshPlayerCount();
end


-------------------------------------------------------------------------------------
--初始化数据
function TableLayer:initData()
	self.m_gameMsgArray = {};
	self.playerInfo = {};--包括昵称 ID 登陆IP 性别	

	self.m_iHeartCount = 0;--心跳计数
	self.m_maxHeartCount = 3;--最大心跳计数
	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子
	--是否绑定事件
	self.m_bBindEvent = false;
	self.actonFinish = true;--其他按钮伸缩动画标志

	self.m_gameStatus = 0; --游戏状态
	self.m_roomKind = 0; --10人场  7人场 体验场
	
	self.m_curRedBag = {};  --当前红包信息
	self.m_leftTime = 10;  --倒计时

	self.m_curRicher = -1; --当前财神
	self.m_curRedBagValue = 0; -- 当前红包金额
	self.m_curRedBagAllCount = 10; --当前红包总数量
	self.m_curRedBagCount = 0; --当前红包数量
	self.m_curMineKey = 0;	   --当前雷号 0-9
	self.m_curRedBagPlayerList = {}; --当前扫雷玩家
	self.m_playerList = {}; --房间玩家数据
	self.m_redBagList = {}; --红包列表
	self.m_curRicherWin = 0; --财神输赢金币
	self.m_playerWin = 0;   --玩家输赢

	self.m_redBagList = {};
	self.m_lSelfMaxScore = 0; --初始金币
	self.m_lSelfScore = 0; --玩家当前金币显示
	self.m_bInRedBagList = false; --是否在红包列表中

	self.m_myRedBagScore = 0;--记录自己埋雷红包金额



	--音效
	self.m_bEffectOn = getEffectIsPlay();
	--音乐
	self.m_bMusicOn = getMusicIsPlay();
	--音乐音量
	self.m_iMuiscVolume = audio.getMusicVolume();

	self.b_isBackGround = false;

	self.ucMaxRedScore = 0; -- 最大红包金额

	self.m_playGameNum = 0;--傻瓜参与局数

	self.isJoinGame = false;--记录玩家是否抢过包


	-- for i=1,100 do
	-- 	local data = {};
	-- 	data.name = "好一朵蜜獾"..i;
	-- 	data.value = math.abs(random(100,1000));
	-- 	table.insert(self.m_redBagList,data);
	-- end



end
--初始化界面
function TableLayer:initUI()
	self.Text_winRicher:setString("+0.00");
	self.Text_lostRicher:setString("+0.00");
	--玩家列表
	self.Button_player:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_player:setName("Button_player");
	self.Button_player:setVisible(false);

	--菜单扩展
	self.Button_expand:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_expand:setName("Button_expand");
	self.Button_expand:getParent():reorderChild(self.Button_expand, 100);
    --菜单收缩
	self.Button_shrink:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_shrink:setName("Button_shrink");
	self.Button_shrink:setVisible(false);
    --申请埋雷
	self.Button_richer:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_richer:setName("Button_richer");
    --扫雷红包
	self.Button_catch:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_catch:setName("Button_catch");

	--菜单面板
	self.Panel_box:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_box:setName("Panel_box");

	--菜单面板
	self.Panel_menu:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_menu:setName("Panel_menu");
	--退出
	self.Button_exit:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_exit:setName("Button_exit");
	--音乐
	self.Button_music:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_music:setName("Button_music");
	--音乐关
	self.Button_musicOff:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_musicOff:setName("Button_musicOff");
	self.Button_musicOff:loadTextures("slhb_yinyue2.png","slhb_yinyue2-on.png","slhb_yinyue2-on.png",UI_TEX_TYPE_PLIST);

	--余额宝 
	self.Button_bank:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_bank:setName("Button_bank");
	--帮助
	self.Button_help:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_help:setName("Button_help");
	--音效
	self.Button_effect:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_effect:setName("Button_effect");
	--音效关
	self.Button_effectOff:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_effectOff:setName("Button_effectOff");
	self.Button_effectOff:loadTextures("slhb_yinxiao-c.png","slhb_yinxiao-c-on.png","slhb_yinxiao-c-on.png",UI_TEX_TYPE_PLIST);

	if self.m_bMusicOn then
		self.Button_musicOff:setVisible(false);
		self.Button_music:setVisible(true);
	else
		self.Button_music:setVisible(false);
		self.Button_musicOff:setVisible(true);
	end

	if self.m_bEffectOn then
		self.Button_effect:setVisible(true);
		self.Button_effectOff:setVisible(false);
	else
		self.Button_effect:setVisible(false);
		self.Button_effectOff:setVisible(true);
	end

	self.Panel_box:setVisible(false);

	self.Text_tip:setVisible(false);


	self.Panel_cell:setVisible(false);
	self.Text_winScore:setVisible(false);
	self.Text_lostScore:setVisible(false);

	local PlayerLayer = require("saoleihongbao.PlayerLayer");
	local LayMineLayer = require("saoleihongbao.LayMineLayer");

	self.m_playerLayer = PlayerLayer:create(self);
	self:addChild(self.m_playerLayer);
	self.m_playerLayer:setVisible(false);

	self.m_layMineLayer = LayMineLayer:create(self);
	self:addChild(self.m_layMineLayer);
	self.m_layMineLayer:setVisible(false);


	--进入房间提示
    self:showFingerTip();


    --区块链bar
	-- self.m_qklBar = Bar:create("saoleihongbao",self,1);
	-- self.Button_expand:addChild(self.m_qklBar);
	-- self.m_qklBar:setPosition(cc.p(-15-95,34));

	--战绩
	if globalUnit.isShowZJ then
		local Image_15 = self.Panel_menu:getChildByName("Image_15");
		-- local contentSize1 = Image_15:getContentSize();
		-- luaDump(contentSize1, "contentSize1---", 4)
		-- Image_15:ignoreContentAdaptWithSize(true);
		-- Image_15:loadTexture("saoleihongbao/image/slhb_xialadi.png");
		-- local contentSize2 = Image_15:getContentSize();
		-- luaDump(contenSize2, "contentSize2---", 4)
		Image_15:setContentSize(cc.size(81,487));
		
		local pos = cc.p(self.Panel_menu:getPosition());
		self.Panel_menu:setContentSize(contenSize2);
		local gap = 45
		self.Panel_menu:setPositionY(pos.y -gap);
		local children = self.Panel_menu:getChildren();
		
		local Button_zhanji = ccui.Button:create("saoleihongbao/image/slhb_zhanji.png","saoleihongbao/image/slhb_zhanji-on.png","saoleihongbao/image/slhb_zhanji-on.png")
		self.Panel_menu:addChild(Button_zhanji)
		local p1 = cc.p(41,10);
		Button_zhanji:setPosition(p1);
		Button_zhanji:setName("Button_zhanji");
		Button_zhanji:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		for i,v in ipairs(children) do
			local name = v:getName();
			if name ~= "Image_15" then
				v:setPositionY(v:getPositionY() + 44);
			end
		end

		self.m_logBar = LogBar:create(self);
		self.Panel_menu:addChild(self.m_logBar);


		-- self.m_logBar = LogBar:create(self);
		-- self.Button_exit:addChild(self.m_logBar);
	end
end

function TableLayer:getPlayerScore(lSeat)
	local userInfo = self.tableLogic:getUserBySeatNo(lSeat);
	if userInfo then
		return userInfo.i64Money;
	end

	return 0;
end


function TableLayer:getPlayerName(lSeat,bFullName)
	local userInfo = self.tableLogic:getUserBySeatNo(lSeat);
	if userInfo then
		if bFullName then
			return userInfo.nickName;
		else
			return FormotGameNickName(userInfo.nickName,nickNameLen)
		end
	end

	return "";
end

function TableLayer:getPlayerHead(lSeat)
	local userInfo = self.tableLogic:getUserBySeatNo(lSeat);
	if userInfo then
		local headPath = getHeadPath(userInfo.bLogoID,userInfo.bBoy);
		return headPath;
	end

	return "";
end

--重置玩家个人信息
function TableLayer:resetSelfInfo()
	luaPrint("self.tableLogic:getMySeatNo():",self.m_lSelfScore,self.m_myRedBagScore);
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
    luaDump(userInfo, "resetSelfInfo_userInfo------------", 5);
    if userInfo then
    	self.Text_selfName:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
    	--addScrollMessage(GameMsg.formatCoin(self.m_lSelfScore-self.m_myRedBagScore).."0");
		self.Text_selfCoin:setString(GameMsg.formatCoin(self.m_lSelfScore-self.m_myRedBagScore));
		local headPath = getHeadPath(userInfo.bLogoID,userInfo.bBoy);
		luaPrint("headPath:",headPath)
		self.Image_selfHead:loadTexture(headPath,UI_TEX_TYPE_LOCAL);
		self.Image_selfHead:setVisible(true);
    else
    	self.Text_selfName:setString("")
		self.Text_selfCoin:setString("");
		--addScrollMessage("".."1");
		self.Image_selfHead:setVisible(false);
    end


	-- self.Text_selfName:setString("飞快得小乌龟");
	-- self.Text_selfCoin:setString("56763.00");

end

--刷新玩家分数
function TableLayer:updateUserInfo()
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	luaDump(userInfo,"updateUserInfo");
	if userInfo then
		self.Text_selfName:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
		--addScrollMessage(GameMsg.formatCoin(self.m_lSelfScore-self.m_myRedBagScore).."2");
		self.Text_selfCoin:setString(GameMsg.formatCoin(self.m_lSelfScore-self.m_myRedBagScore));
		--self.m_lSelfScore = userInfo.i64Money-self.m_myRedBagScore;
		local headPath = getHeadPath(userInfo.bLogoID,userInfo.bBoy);
		self.Image_selfHead:loadTexture(headPath,UI_TEX_TYPE_LOCAL);
		self.Image_selfHead:setVisible(true);
	end
end

--重置埋雷玩家个人信息
function TableLayer:resetRicher()
	self.Text_richerName:setString("");
	self.Text_winRicher:setString("");
	self.Text_winRicher:setVisible(false);
	self.Text_lostRicher:setString("");
	self.Text_lostRicher:setVisible(false);
	self.Image_richerHead:setVisible(false);

end


function TableLayer:showFingerTip()
	self:addPlist();

	self.Image_finger:setVisible(false);
	
	while (self.Panel_redBag:getChildByTag(301) ) do
		self.Panel_redBag:removeChildByTag(301)
	end
	local  node = cc.Node:create();
	node:setTag(301);
	self.Panel_redBag:addChild(node)
	node:setPosition(278*0.5,100);

	local spriteFrame = cc.SpriteFrameCache:getInstance();

	local animation= cc.Animation:create()
	for i=1,11 do
		 local blinkFrame = spriteFrame:getSpriteFrame(string.format("slhb_shouzhi-an_%d.png", i));
    	animation:addSpriteFrame( blinkFrame )  
	end
	animation:setDelayPerUnit(0.1)
	animation:setRestoreOriginalFrame(true)
	local action = cc.Animate:create(animation)

	local image = cc.Sprite:createWithSpriteFrameName("slhb_shouzhi-an_0.png");
	image:setPosition(0,0)
	node:addChild(image)
	image:setTag(301);
	image:runAction(cc.RepeatForever:create(action))
	node:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create()));

	self.Image_clickme:setVisible(true);
	self.Image_clickme:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.Hide:create()));

-- 	local skeleton_animation = createSkeletonAnimation("slhb_"..Spine_Shouzhi.name,Spine_Shouzhi.json,Spine_Shouzhi.atlas);
-- 	if skeleton_animation then
-- 		self.Panel_redBag:addChild(skeleton_animation);
--     	skeleton_animation:setAnimation(0,Spine_Shouzhi.name, false);
--     	skeleton_animation:setPosition(278*0.5,100);
--     	skeleton_animation:setTag(301);
--     else
--     	luaPrint("skeleton_animation-----------------------:",skeleton_animation)
-- 	end

	-- local skeleton_animation = createSkeletonAnimation("slhb_"..Spine_Win.name,Spine_Win.json,Spine_Win.atlas);
	-- if skeleton_animation then
	-- 	self.Panel_redBag:addChild(skeleton_animation);
 --    	skeleton_animation:setAnimation(0,Spine_Win.name, false);
 --    	skeleton_animation:setPosition(278*0.5,165);
 --    	skeleton_animation:setTag(301);
 --    else
 --    	luaPrint("skeleton_animation-----------------------:",skeleton_animation)
	-- end

	-- local skeleton_animation = createSkeletonAnimation("slhb_"..Spine_Lost.name,Spine_Lost.json,Spine_Lost.atlas);
	-- if skeleton_animation then
	-- 	self.Panel_redBag:addChild(skeleton_animation);
 --    	skeleton_animation:setAnimation(0,Spine_Lost.name, false);
 --    	skeleton_animation:setPosition(278*0.5,165);
 --    	skeleton_animation:setTag(301);
 --    else
 --    	luaPrint("skeleton_animation-----------------------:",skeleton_animation)
	-- end

	-- local layer = require("saoleihongbao.WinLayer");
	-- local playerLayer = layer:create(self,-45334);
	-- playerLayer:setTag(301);
	-- self:addChild(playerLayer);
end







--============================================扫雷红包交互======================================================





--获取玩家自己的得分
function TableLayer:getSelfScore()
	if PlatformLogic.loginResult.i64Money ~= nil then
		return PlatformLogic.loginResult.i64Money;
	end
	return 0;
end

--设置玩家得分
function TableLayer:setSelfScore(lScore)
	PlatformLogic.loginResult.i64Money = lScore;
end


--更新当前地雷信息
function TableLayer:updateRedBag(data)
	self.m_curRedBag = data;
	local redValue = data.value;--红包金额
	local redCount = data.count;--红包数量
	local mineKey = data.key;--雷号
	self.Text_redValue:setString(Common.gameRealMoney(redValue));
	self.Text_redCount:setString(redCount);
	self.Text_mineKey:setString(mineKey);

end


--显示时间提示
function TableLayer:showTimeTips(second)--时钟提示显示

	self.Image_countTime:setVisible(true);
    self.m_leftTime = second;
    self.Text_time:setString(string.format("%d",second));
   
    local function onEventCountdown(sender,event)
    	if self.m_leftTime >= 0 then
    		self:showTimeTipsOver();
    		self.m_leftTime = self.m_leftTime - 1;

    		self.Image_countWord:stopAllActions();
    		self.Image_countWord:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventCountdown)));

    	else
    		self.Image_countWord:stopAllActions()
    	end
    end

    onEventCountdown();
end

--结束时间
function TableLayer:showTimeTipsOver(ft)--时钟提示显示完成
	
	local time = self.m_leftTime;

    self.Text_time:setString(string.format("%d",self.m_leftTime));

 end

function TableLayer:stopTimeTips()--时钟提示显示完成
	
	self.Image_countWord:stopAllActions();

    self.Text_time:setString("0");

 end 

function TableLayer:pushCacther(data)
	local name = data.name;
	local coin = data.money;

	if table.nums(self.m_curRedBagPlayerList) < 10 then
		table.insert(self.m_curRedBagPlayerList,data);
	end

	-- luaDump(self.m_curRedBagPlayerList, "pushCacther", 5)
end

function TableLayer:addCatcher(data,index)
	self:addPlist();

	-- local num = table.nums(self.m_curRedBagPlayerList);

	if self.Panel_layer:getChildByTag(TAG_PLAYER+index) then
		self.Panel_layer:removeChildByTag(TAG_PLAYER+index);
	end

	if self.Panel_layer:getChildByTag(TAG_WIN+index) then
		self.Panel_layer:removeChildByTag(TAG_WIN+index);
	end

	local nameStr = self:getPlayerName(data.seat);
	local headStr = self:getPlayerHead(data.seat);

	local cell = self.Panel_cell:clone();
	cell:setTag(TAG_PLAYER+index);

	cell:setVisible(true);
	cell:setPosition(STAND_POS_ARR[index]);
	self.Panel_layer:addChild(cell);
	local img_head = cell:getChildByName("Image_head");

	img_head:loadTexture(headStr);


	local text_name = cell:getChildByName("Text_name");
	text_name:setString(nameStr);
	local text_coin = cell:getChildByName("Text_coin");
	text_coin:setString(Common.gameRealMoney(data.value));
	local img_mine  = cell:getChildByName("Image_mine");
	-- img_mine:setVisible(data.coin <= 0);

	-- local img_bg = cell:getChildByName("Image_winbg");
	-- local text = nil;
	-- if data.coin > 0 then
	-- 	text = self.Text_winLeft:clone();
	-- 	img_bg:loadTexture("slhb_xinxikuang1.png",UI_TEX_TYPE_PLIST);
	-- else
	-- 	text = self.Text_winRight:clone();
	-- 	img_bg:loadTexture("slhb_xinxikuang2.png",UI_TEX_TYPE_PLIST);
	-- end

	-- if index <= 5 then
	-- 	text:setAnchorPoint(0,0.5);
	-- else
	-- 	text:setAnchorPoint(1,0.5);
	-- end

	-- text:setVisible(true);
	-- text:setString(data.coinStr);
	-- text:setPosition(WIN_POS_ARR[index]);
	-- self.Panel_layer:addChild(text);
	-- text:setTag(TAG_WIN+index);
end



--更新银行保险箱
function TableLayer:resetSelfCoin(data)
	luaDump(data, "resetSelfCoin____data_____", 6)
	if PlatformLogic.loginResult.dwUserID ~= data.UserID then
		
		return;
	end

	self.m_lSelfScore = self.m_lSelfScore + data.OperatScore;
	--self.m_lUserMaxScore = self.m_lUserMaxScore + data.OperatScore;
	

	local playerScore = GameMsg.formatCoin(self.m_lSelfScore);
	self.Text_selfCoin:setString(playerScore);
	--addScrollMessage(playerScore.."4");



end



function TableLayer:test()
		local data = {};
		data.name = "四季豆玩";
		local coin = random(1000,100000);
		local value = coin;
		local r = value%2;
		local str = Common.gameRealMoney(coin)
		if r == 1 then
			str = "+"..str;
		else
			-- str = "-"..str;
			str = "-"..str;
			coin = -coin;
		end

		data.money = value;
		data.coinStr = str;
		data.coin = coin;
		luaPrint("data.coin:"..data.coin)

		self:pushCacther(data);
		local index2 = table.nums(self.m_curRedBagPlayerList);
		self:addCatcher(data,index2);


		
		luaPrint("value:"..value);
		if value%2 == 1 then
			local layer = require("saoleihongbao.WinLayer");
	    	local playerLayer = layer:create(self,value);
	    	self:addChild(playerLayer);
		else
			local value2  = value*-1;
			local layer = require("saoleihongbao.WinLayer");
			local playerLayer = layer:create(self,value2);
	    	self:addChild(playerLayer);
		end

end

function TableLayer:reset()
	self.m_curRedBagPlayerList = {};
	self.Panel_layer:removeAllChildren();


end


function TableLayer:test2()
	local data = {};
	data.value = random(100,10000);
	data.count = random(1,20);
	data.key = random(0,9);
	self:updateRedBag(data);

end



function TableLayer:addOpenPlayer(data,index)
	self:addPlist();

	--local num = table.nums(self.m_curRedBagPlayerList);
	local seatNo = data.seatNo;
	if self.Panel_layer:getChildByTag(TAG_PLAYER+seatNo) then
		self.Panel_layer:removeChildByTag(TAG_PLAYER+seatNo);
	end

	if self.Panel_layer:getChildByTag(TAG_WIN+seatNo) then
		self.Panel_layer:removeChildByTag(TAG_WIN+seatNo);
	end

	local nameStr = self:getPlayerName(data.seatNo);
	local headStr = self:getPlayerHead(data.seatNo);

	local cell = self.Panel_cell:clone();
	cell:setTag(TAG_PLAYER+seatNo);

	cell:setVisible(true);
	cell:setPosition(STAND_POS_ARR[index]);
	self.Panel_layer:addChild(cell);
	local img_head = cell:getChildByName("Image_head");

	img_head:loadTexture(headStr);


	local text_name = cell:getChildByName("Text_name");
	text_name:setString(nameStr);
	local text_coin = cell:getChildByName("Text_coin");
	text_coin:setVisible(false);
	-- text_coin:setString(Common.gameRealMoney(data.value));
	local img_mine  = cell:getChildByName("Image_mine");
	-- if data.bHitMine == 1 then 
	-- 	img_mine:setVisible(true);
	-- else
		img_mine:setVisible(false);
	-- end
	local img_bg = cell:getChildByName("Image_winbg");
	-- local text = nil;
	if data.bHitMine == 1 then
		text = self.Text_lostScore:clone();
		-- img_bg:loadTexture("slhb_xinxikuang2.png",UI_TEX_TYPE_PLIST);
	elseif data.bHitMine == 0 then
		text = self.Text_winScore:clone();
		-- img_bg:loadTexture("slhb_xinxikuang1.png",UI_TEX_TYPE_PLIST);
	end

	if index <= 5 then
		text:setAnchorPoint(0,0.5);
	else
		text:setAnchorPoint(1,0.5);
	end

	-- text:setVisible(true);
	-- text:setString(data.coinStr);
	text:setPosition(WIN_POS_ARR[index]);
	self.Panel_layer:addChild(text);
	text:setTag(TAG_WIN+seatNo);
end




--按钮响应
function TableLayer:onBtnClickEvent(sender,event)
	
    --获取按钮名
    local btnName = sender:getName();
    local btnTag = sender:getTag();
 
    if event == ccui.TouchEventType.began then
    	audio.playSound(GAME_SOUND_BUTTON)
    elseif event == ccui.TouchEventType.ended then
        luaPrint("onBtnClickEvent----- Name:",btnName);
        
        if "Button_expand" == btnName then --扩展
        	self.Panel_box:setVisible(true);
        	-- self.Button_expand:setVisible(false);
        	self.Button_expand:loadTextures("slhb_xialaanniu.png","slhb_xialaanniu-on.png","slhb_xialaanniu-on.png",UI_TEX_TYPE_PLIST);
        	sender:setName("Button_shrink");
        elseif "Button_shrink" == btnName then --收缩
        	sender:setName("Button_expand");
        	self.Panel_box:setVisible(false);
        	self.Button_expand:loadTextures("slhb_xialaanniu2.png","slhb_xialaanniu2-on.png","slhb_xialaanniu2-on.png",UI_TEX_TYPE_PLIST);
        	-- self.Button_expand:setVisible(true);
        elseif "Button_player" == btnName then --玩家列表
        	
        	self.m_playerLayer:showIt();
        	
        elseif "Button_richer" == btnName then --申请埋雷

        	-- self.m_layMineLayer:setVisible(not self.m_layMineLayer:isVisible());
        	if self.m_lSelfScore>=200000 then
        		self.m_layMineLayer:showLayMine();
        	else
        		addScrollMessage("抱歉，您的金币低于埋雷限制2000，不能埋雷！");
        	end

        elseif "Button_catch" == btnName then --红包
        	-- self:test();

        	-- self:showFingerTip();
        	self:sendOpenRedbag();
        elseif "Panel_box" == btnName then --菜单层
        	self.Panel_box:setVisible(false);
        	self.Button_expand:setVisible(true);
        	self.Button_expand:setName("Button_expand");
        	self.Button_expand:loadTextures("slhb_xialaanniu2.png","slhb_xialaanniu2-on.png","slhb_xialaanniu2-on.png",UI_TEX_TYPE_PLIST);
        elseif "Panel_menu" == btnName then --菜单按钮
        	
        elseif "Button_music" == btnName then --音乐
        	self.Button_music:setVisible(false);
        	self.Button_musicOff:setVisible(true);
        	setMusicIsPlay(false);
			self.m_bMusicOn = false;
			self:playBgMusic();
        elseif "Button_musicOff" == btnName then --音乐关
        	self.Button_music:setVisible(true);
        	self.Button_musicOff:setVisible(false);
        	setMusicIsPlay(true);
			self.m_bMusicOn = true;
			self:playBgMusic();
        elseif "Button_bank" == btnName then --余额宝
        	if self.m_cbGameStatus == GameMsg.GAME_SCENE_FREE and not isHaveBankLayer() then--开奖状态不弹保险箱
				addScrollMessage("游戏进行中，请稍后进行取款操作。");  --框架提示  没有句号
				return;
			end
			
			createBank(
				function(data)
					self:resetSelfCoin(data)
				end,true);
        elseif "Button_help" == btnName then --帮助
        	local layer = HelpLayer:create();
			self:addChild(layer,100000);
        elseif "Button_effect" == btnName then --音效
        	self.Button_effect:setVisible(false);
        	self.Button_effectOff:setVisible(true);
        	setEffectIsPlay(false);
			self.m_bEffectOn = false;
        elseif "Button_effectOff" == btnName then --音效关
        	self.Button_effect:setVisible(true);
        	self.Button_effectOff:setVisible(false);
        	setEffectIsPlay(true);
			self.m_bEffectOn = true;
        elseif "Button_exit" == btnName then --退出
        	self:onClickExitGameCallBack();
        elseif "Button_zhanji" == btnName then --战绩
        	if self.m_logBar then
				self.m_logBar:CreateLog();
			end

        end
        
    end

end
    
function TableLayer:resetGameData()
	self.m_gameMsgArray = {};
	self.m_gameStatus = 0;
	self.m_curRedBag = {};  --当前红包信息
	self.m_leftTime = 10;  --倒计时

	self.m_richer = -1; --当前财神
	self.m_curRedBagValue = 0; -- 当前红包金额
	self.m_curRedBagCount = 0; --当前红包数量
	self.m_curMineKey = 0;	   --当前雷号 0-9
	self.m_curRedBagPlayerList = {}; --当前扫雷玩家
	self.m_playerList = {}; --房间玩家数据
	-- self.m_redBagList = {}; --红包列表



	self.Panel_layer:removeAllChildren();
	self.Image_flash:setVisible(false);
	self.Button_catch:setEnabled(false);
	self.Image_finger:setVisible(false);
	self.Image_clickme:setVisible(false);

	self.Image_countWord:stopAllActions(); --倒计时进度
	self.Text_time:setString("0"); --倒计时

	self.Text_redValue:setString("0"); --红包金额
	self.Text_redCount:setString("0"); --红包数量
	self.Text_mineKey:setString("0"); --雷号

	-- self.Image_layHead:loadTexture(""); 当前财神
	self.Text_richerName:setString(""); --雷号
	self.Text_winRicher:setVisible(false); --财神输赢
	self.Text_lostRicher:setVisible(false);

	self.Image_countTime:setVisible(false); --红包倒计时

	-- if self.m_roomKind == ROOM_TEN then
	-- 	self.m_curRedBagCount = 10;
	-- 	self.m_curRedBagAllCount = 10; --当前红包总数量
	-- else
	-- 	self.m_curRedBagCount = 7;
	-- 	self.m_curRedBagAllCount = 7; --当前红包总数量
	-- end
end


function TableLayer:showGameStatus()
	


end


function TableLayer:getMeSeat()
	return self.tableLogic._mySeatNo;
end


function TableLayer:isMeSeat(lSeat)
	return self.tableLogic._mySeatNo == lSeat;
end

-- function TableLayer:isValidSeat(lSeat)
-- 	return 255 ~= lSeat and lSeat > 0;
-- end

function TableLayer:updateRedBagList(data)
	self.m_bInRedBagList = false;
	self.m_myRedBagScore = 0;
	self.m_redBagList = {};
	for k,v in pairs(data) do
		if v then
			if v.llRedBagScore > 0 then
				table.insert(self.m_redBagList,v);	
				if v.ucChairID == self.tableLogic._mySeatNo then
					self.m_bInRedBagList = true;
					self.m_myRedBagScore = v.llRedBagScore;
					self:resetSelfInfo();
				end
			end
		end
	end

	luaDump(self.m_redBagList, "updateRedBagList_m_redBagList", 6)
end


function TableLayer:resumeOpenRedbagList()
	--self.m_curRedBagPlayerList
	luaDump(self.m_curRedBagPlayerList,"resumeOpenRedbagList");
	for i,v in ipairs(self.m_curRedBagPlayerList) do
		
		self:addOpenPlayer(v, i);		
	end




end



-- ============================= 消息 =========================================
--打开红包
function TableLayer:sendOpenRedbag()
	luaPrint("self.m_lSelfScore:",self.m_lSelfScore,"self.m_curRedBagValue:",self.m_curRedBagValue)

	if self.m_gameStatus == GameMsg.GAME_SCENE_END or  self.m_gameStatus == GameMsg.GAME_SCENE_FREE then
		addScrollMessage("抢红包已经结束，等下一轮!");
		return;
	end

	local bit = 1;
	if self.m_roomKind == ROOM_SEVEN then
		bit = 1.5;
	end

	if (self.m_lSelfScore-self.m_myRedBagScore) < self.m_curRedBagValue*bit then
		addScrollMessage("余额不足，不能抢红包!");
		return;
	end

	if self:isMeSeat(self.m_curRicher) then
		addScrollMessage("自己的红包无法抢!");
	else
		self.tableLogic:sendOpenRedbag();
	end
	

end
































-----------------------------------------------百人牛牛消息------------------------------------------------------



-----------------------------------------游戏消息处理--------------------


--游戏开始消息
function TableLayer:pushGameMsg(msg)
    -- luaPrint("msg id:",msg.id)
    -- luaDump(msg,'pushGameMsg',6);
    table.insert(self.m_gameMsgArray,#self.m_gameMsgArray + 1,msg);
    luaPrint("当前游戏消息数量:%d",#self.m_gameMsgArray)

    --

end

--启动消息监听
function TableLayer:startGameMsgRun()
     --帧更新,用来转发消息,消息是在onGameMessageDeal中构建的
     if self.m_msgRunTimeId == -1 then
     	self.m_msgRunTimeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:update(delta) end, 0.05 ,false);
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
    if msgId == GameMsg.PLACE_JETTON_ID then   --游戏筹码

		
	    

    end


end

----------------------------框架消息-----------------------------
function TableLayer:onGameStationFree(msg)
	
	self:addPlist();
	self:resetGameData();

	self.b_isBackGround = true;
	self.isJoinGame = false;
	--todo
	if msg.ucMaxRedBags == 10 then
		self.m_roomKind = ROOM_TEN; --十人场
		self.m_curRedBagCount = 10;
	else
		self.m_roomKind = ROOM_SEVEN; --七人场
		self.m_curRedBagCount = 7;
	end

	self.ucMaxRedScore = msg.ucMaxRedScore
	if self.m_layMineLayer then
		self.m_layMineLayer:updateMoney();
	end
	self.m_gameStatus = msg.cbGameStatus; --游戏状态
	self.m_leftTime = msg.cbTimeLeave;  --剩余时间
	-- self.m_redBagList = msg.tagPlantMines; --当前红包数据
	self.m_lSelfScore = self:getPlayerScore(self.tableLogic._mySeatNo);
	-- self:updateRedBagList(msg.tagPlantMines)

	self:resetSelfInfo();
	self:resetRicher();

	self.Button_catch:setEnabled(false);
	self:showGameStatus();
	luaPrint("PLAY_COUNT =----onGameStationFree-----=   "..PLAY_COUNT);
end




function TableLayer:onGameStationPlaying(msg)
	self:addPlist();


	self:resetGameData();

	self.b_isBackGround = true;
	self.isJoinGame = false;
	--todo
	self.m_gameStatus = msg.cbGameStatus; --游戏状态
	self.m_leftTime = msg.cbTimeLeave;  --剩余时间
	local richer = msg.curPlantMine;
	self.m_curRicher = richer.ucChairID; --红包家
	self.m_curRedBagValue = richer.llRedBagScore; --红包金额
	self.m_curMineKey = richer.ucMinesIndex;
	self.m_curRicherWin	  = msg.lBankerWinScore; --庄家输赢金币
	self.ucMaxRedScore = msg.ucMaxRedScore
	if self.m_layMineLayer then
		self.m_layMineLayer:updateMoney();
	end
	--self.m_playerWin = msg.llEndUserScore;--玩家成绩

	--local richerValue = msg.llEndBankerScore;--庄家成绩

	--红包列表
	--self:updateRedBagList(msg.tagPlantMines);
	if self:isMeSeat(self.m_curRicher) then
		self:updataBgMusic(1);
	end



	self.m_lSelfScore = self:getPlayerScore(self.tableLogic._mySeatNo);
	if self.tableLogic._mySeatNo == self.m_curRicher then
		self.m_myRedBagScore = self.m_curRedBagValue;
	end
	self:resetSelfInfo();
	if msg.ucMaxRedBags == 10 then
		self.m_roomKind = ROOM_TEN; --十人场
		self.m_curRedBagCount = 10;
		self.m_curRedBagCount = 10;
	else
		self.m_roomKind = ROOM_SEVEN; --七人场
		self.m_curRedBagCount = 7;
		self.m_curRedBagCount = 7;
	end

	



	-- self.m_curRedBagPlayerList = msg.tagRedBag; --当前红包数据
	for i,v in ipairs(msg.tagRedBag) do
		if self:isValidSeat(v.ucChairID) then
			v.seatNo = v.ucChairID;
			table.insert(self.m_curRedBagPlayerList,v);
		end
		if self:isMeSeat(v.ucChairID) then
			self.isJoinGame = true;
		end
	end

	self.Text_richerName:setString(self:getPlayerName(self.m_curRicher));
	self.Image_richerHead:loadTexture(self:getPlayerHead(self.m_curRicher),UI_TEX_TYPE_LOCAL);
	self.Image_richerHead:setVisible(true);	
	self.Text_redValue:setString(GameMsg.formatCoin(self.m_curRedBagValue));

	self.m_curRedBagCount = self.m_curRedBagAllCount - table.nums(self.m_curRedBagPlayerList);
	self.Text_redCount:setString(tostring(self.m_curRedBagAllCount - table.nums(self.m_curRedBagPlayerList)));
	self.Text_mineKey:setString(self.m_curMineKey);
	self.Button_catch:setEnabled(true);

	if self.tableLogic._gameStatus == GameMsg.GAME_SCENE_PLAYING then
		self:showTimeTips(self.m_leftTime);
	end



	self.Button_catch:setEnabled(msg.cbGameStatus == GameMsg.GAME_SCENE_PLAYING);
	self:showGameStatus();
	self:resumeOpenRedbagList();

end

function TableLayer:onSLHBGameFree(message)
	luaDump(message._usedata, "msg,onSLHBGameFree", 5)
	
	local msg = message._usedata; 	
end


function TableLayer:onSLHBGameStart(message)
	if self.b_isBackGround == false then
		return;
	end
	luaDump(message._usedata, "msg,onSLHBGameStart", 5)

	self:resetGameData();
	
	local msg = message._usedata;

	self.m_gameStatus = GameMsg.GAME_SCENE_PLAYING;
	self.isJoinGame = false;
	self.m_curRedBagCount = msg.ucMaxRedBags;--当前红包数量
	self.m_curRedBagAllCount = msg.ucMaxRedBags;--当前红包总数量


	self.m_curRicher = msg.wBankerUser; --当前财神
	self.m_curRedBagValue = msg.llRedBagScore; -- 当前红包金额

	self.m_curMineKey = msg.ucMineIndex;	   --当前雷号 0-9
	self.m_leftTime = msg.cbLeaveTime; --剩余时间

	self.Text_richerName:setString(self:getPlayerName(self.m_curRicher));
	self.Image_richerHead:loadTexture(self:getPlayerHead(self.m_curRicher),UI_TEX_TYPE_LOCAL);
	self.Image_richerHead:setVisible(true);	
	self.Text_redValue:setString(GameMsg.formatCoin(self.m_curRedBagValue))
	self.Text_redCount:setString(tostring(msg.ucMaxRedBags));
	self.Text_mineKey:setString(self.m_curMineKey);
	self.Button_catch:setEnabled(true);
	self:showTimeTips(self.m_leftTime);

	--移除列表中的红包
	for i,v in ipairs(self.m_redBagList) do
		if v.ucChairID  == self.m_curRicher then
			table.remove(self.m_redBagList,i);
			self.m_layMineLayer:reloadRedbagList();
			break;
		end
	end

	--财神自己  更新金币
	if self:isMeSeat(self.m_curRicher) then
		luaPrint("自己是财神");
		self.m_bInRedBagList = false;
		GamePromptLayer:remove()
		--self:resetSelfInfo();
	end


end

function TableLayer:onSLHBGamePlantMine(message)
	if self.b_isBackGround == false then
		return;
	end
	luaDump(message._usedata, "msg,onSLHBGamePlantMine", 5)
	
	local msg = message._usedata;

	if msg.ucChairID == self.tableLogic._mySeatNo then
		self.m_bInRedBagList = true;
		self.m_playGameNum = 0;
		self.m_myRedBagScore = msg.llRedBagScore;
		self:resetSelfInfo();
		self:updataBgMusic(1);
	end

	--local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic._mySeatNo);
	--self.m_lSelfScore = userInfo.i64Money-self.m_myRedBagScore
	
	-- self.m_lSelfScore = self.m_lSelfScore-msg.llRedBagScore;
	-- self:resetSelfInfo();

	-- local data = msg.tagPlantMines;
	-- self:updateRedBagList(data);
	-- self.m_layMineLayer:reloadRedbagList();



end


function TableLayer:onSLHBOpenRedbag(message)
	if self.b_isBackGround == false then
		return;
	end
	luaDump(message._usedata, "msg,onSLHBOpenRedbag", 5)
	
	local msg = message._usedata;
	local value = msg.llRedBagScore;--红包金额
	local seat = msg.wOpenUser;
	if self:isValidSeat(seat) then
		local data = {};
		data.seatNo = seat;
		data.value = value;
		data.bHitMine = msg.bHitMine;

		table.insert(self.m_curRedBagPlayerList,data);
		local index = table.nums(self.m_curRedBagPlayerList);
		self:addOpenPlayer(data, index);

		-- self.m_curRedBagCount = self.m_curRedBagAllCount - index;
		-- self.Text_redCount:setString(tostring(self.m_curRedBagCount));

		if self:isMeSeat(seat) then
			self.Button_catch:setEnabled(false);
			local layer = require("saoleihongbao.WinLayer");
			local playerLayer = layer:create(self,data.value,data.bHitMine);
			playerLayer:setTag(301);
			self:addChild(playerLayer);
			self.m_playGameNum = 0;
			self.isJoinGame = true;
			-- self.m_lSelfScore = self.m_lSelfScore + data.value;
			-- self:resetSelfInfo();
		end
	end

	--红包数量减少
	self:reduceRedBag();

end

--红包数量减少一个显示
function TableLayer:reduceRedBag()
	self.m_curRedBagCount = self.m_curRedBagCount - 1;
	if self.m_curRedBagCount <=0 then
		self.m_curRedBagCount = 0;
	end
	self.Text_redCount:setString(self.m_curRedBagCount);
end


function TableLayer:onSLHBGameEnd(message)
	if self.b_isBackGround == false then
		return;
	end
	luaPrint("_mySeatNo",self.tableLogic:getMySeatNo());
	luaDump(message._usedata, "msg,onSLHBGameEnd", 5)
	
	local msg = message._usedata; 	

	self.m_gameStatus = GameMsg.GAME_SCENE_END;

	self.Button_catch:setEnabled(false);

	local bankerWin = msg.lBankerWinScore; --庄家输赢
	local playerList = {};
	for i=1,10 do
		local seatNo = msg.ucUserChairs[i];
		if self:isValidSeat(seatNo) then
			local data = {};
			data.seatNo = seatNo;
			data.redbagValue = msg.lRegBagScores[i];
			data.winValue = msg.lUserWinScores[i]
			table.insert(playerList,data);
		end
	end

	local tagStr = "";
	if bankerWin > 0 then
		tagStr = "+";
	end

	local text = self.Text_lostRicher;
	if bankerWin>=0 then
		text = self.Text_winRicher;
	end
	text:setString(GameMsg.formatCoin(bankerWin,tagStr));
	text:stopAllActions();
	text:setVisible(true);
	text:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.Hide:create()));


	--显示玩家列表
	self:addPlist();
	luaDump(playerList, "playerList----------gameend", 5)
	for i,v in ipairs(playerList) do
		local data = v;
		local seatNo = data.seatNo;
		local cell = self.Panel_layer:getChildByTag(TAG_PLAYER+seatNo);
		if cell then
			local text_coin = cell:getChildByName("Text_coin");
			local img_bg = cell:getChildByName("Image_winbg");
			local img_mine  = cell:getChildByName("Image_mine");
			text_coin:setVisible(true);
			text_coin:setString(Common.gameRealMoney(data.redbagValue));
			local text_win = self.Panel_layer:getChildByTag(TAG_WIN+seatNo);
			if text_win then
				if data.winValue >=0 then
					text_win:setProperty("","saoleihongbao/image/slhb_jiesuanzitiao1.png",26,50,'+');
					text_win:setString("+"..Common.gameRealMoney(data.winValue));
					if img_bg then
						img_bg:loadTexture("slhb_xinxikuang1.png",UI_TEX_TYPE_PLIST);
					end
					if img_mine then
						img_mine:setVisible(false);
					end
				else
					text_win:setProperty("","saoleihongbao/image/slhb_jiesuanzitiao2.png",26,50,'+');
					text_win:setString(Common.gameRealMoney(data.winValue));
					if img_bg then
						img_bg:loadTexture("slhb_xinxikuang2.png",UI_TEX_TYPE_PLIST);
					end
					if img_mine then
						img_mine:setVisible(true);
					end
				end
				
				text_win:setVisible(true);
			end
		else
			luaPrint("报错了",seatNo);
		end
	end

	self:stopTimeTips();

	--self:showTimeTips(msg.cbLeaveTime);

	self:playEndEffect(msg);

	self:showUserEndScore(msg);

	if self:isMeSeat(self.m_curRicher) then
		self:updataBgMusic(0);
	end

	self:updatePlayNum(msg.ucUserChairs);
	
end

function TableLayer:updatePlayNum(data)
	local isPlay = false;
	for k,v in pairs(data) do
		if v == self.tableLogic:getMySeatNo() then
			isPlay = true;
			self.m_playGameNum = 0;
			break;
		end 
	end

	if isPlay == false then
		self.m_playGameNum = self.m_playGameNum + 1;
	end

	--自己在上庄列表不计算局数
	if self.m_bInRedBagList then
		self.m_playGameNum  = 0;
	end

	if self:isMeSeat(self.m_curRicher) then
		self.m_playGameNum  = 0;
	end

	self:showPlayGameNum();

end

function TableLayer:showUserEndScore(msg)
	if self:isMeSeat(self.m_curRicher) then--庄家
		self.m_lSelfScore = self.m_lSelfScore + msg.lBankerWinScore; --- self.m_curRedBagValue;
		self:resetSelfInfo();
	else
		for k,v in pairs(msg.ucUserChairs) do
			if v == self.tableLogic:getMySeatNo() then
				self.m_lSelfScore = self.m_lSelfScore + msg.lUserWinScores[k];
				self.m_playGameNum = 0;
				self:resetSelfInfo();
				break;
			end
		end
	end
end


function TableLayer:onSLHBGameFinish(message)
	if self.b_isBackGround == false then
		return;
	end
	luaDump(message._usedata, "msg,onSLHBGameFinish", 5)
	
	local msg = message._usedata; 	

	self:resetGameData();

	--self:updateUserInfo();

	self.m_gameStatus = GameMsg.GAME_SCENE_FREE;

	self.isJoinGame = false;

end

function TableLayer:playEndEffect(msg)
	luaPrint("playEndEffect",self:isMeSeat(self.m_curRicher),msg.lBankerWinScore);
	if msg then
		if self:isMeSeat(self.m_curRicher) then--庄家
			if msg.lBankerWinScore>=0 then
				audio.playSound("saoleihongbao/sound/sound-result-win.mp3");
			else
				audio.playSound("saoleihongbao/sound/sound-result-lose.mp3");
			end
		else --玩家
			local isHave = false;
			local score = 0;
			for k,v in pairs(msg.ucUserChairs) do
				if v == self.tableLogic:getMySeatNo() then
					isHave = true;
					score = msg.lUserWinScores[k];
					break;
				end
			end
			luaPrint("playEndEffect11",isHave,score,self.tableLogic:getMySeatNo());
			if isHave then
				if score >=0 then
					audio.playSound("saoleihongbao/sound/sound-result-win.mp3");
				else
					audio.playSound("saoleihongbao/sound/sound-result-lose.mp3");
				end
			end
		end
	end
end


function TableLayer:onSLHBRedBagList(message)
	if self.b_isBackGround == false then
		return;
	end
	-- luaDump(message._usedata, "msg,onSLHBRedBagList", 5)
	local msg = message._usedata; 	

	self:updateRedBagList(msg.tagPlantMines);
	self.m_layMineLayer:reloadRedbagList();
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
	if device.platform == "windows" then
		return;
	end
	self.b_isBackGround = false;
end


 --后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if device.platform == "windows" then
		return;
	end
	if RoomLogic:isConnect() then
		if device.platform == "windows" then
			luaPrint("device.platform is windows~")
			return;
		end

		-- self:playBgMusic();
		-- globalUnit.isEnterGame = false;

		self:resetGameData();

		self:stopAllActions();

		self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
	else
		-- self.m_wBankerUser = -1;
		-- self:exitClickCallback();
	end
end


function TableLayer:showPlayGameNum()
	if self.m_playGameNum >= 3 then
		if self.m_playGameNum >= 5 then
			addScrollMessage("您已连续5局未参与游戏，已被请出房间！");
			self:onClickExitGameCallBack();
		else
			addScrollMessage("您已连续"..self.m_playGameNum.."局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
		end
	end
end


return TableLayer;
