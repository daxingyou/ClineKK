local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("shidianban.TableLogic");
local PopUpLayer = require("shidianban.PopUpLayer");
local GamePlayerNode = require("shidianban.GamePlayerNode");
local CardLayer = require("shidianban.CardLayer");
local CardSprite = require("shidianban.CardSprite");
local GameLogic = require("shidianban.GameLogic");
local ChipNodeManager = require("shidianban.ChipNodeManager");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

local HEAP_COUNT = 30;	--筹码数量

--加注动画
local RaiseAnim = {
		name = "dzpk_jiazhu",
		json = "shidianban/effect/jiazhu.json",
		atlas = "shidianban/effect/jiazhu.atlas",
}

local RaiseAnimName = "jiazhu";

--即将开始
local BeginAnim = {
	name = "spz_jijiangkaishi",
	json = "game/jijiangkaishi.json",
	atlas = "game/jijiangkaishi.atlas",
}

local BeginAnimAnimName = "5s";

local WaitAnim ={
		name = "spz_dengwanjia",
		json = "game/dengdai/dengdai.json",
		atlas = "game/dengdai/dengdai.atlas",
}

local WaitAnimName = "dengwanjia";
local WaitNextAnimName = "dengxiaju";

local qzState = {
	sikao = 255,
	buqiang = 0,
	qiang = 1,

}


--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

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
	PLAY_COUNT = GameMsg.GAME_PLAYER;
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;
	-- GameMsg.init();
	SDBInfo:init();

	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
	display.loadSpriteFrames("shidianban/card.plist","shidianban/card.png")

	local uiTable = {
		Image_bg = "Image_bg",
		--玩家
		Node_player0 = "Node_player0",
		Node_player1 = "Node_player1",
		Node_player2 = "Node_player2",
		Node_player3 = "Node_player3",
		Node_player4 = "Node_player4",
		--下注按钮
		Node_zhuBtn = "Node_zhuBtn",
		Button_zhu1 = "Button_zhu1",
		Button_zhu2 = "Button_zhu2",
		Button_zhu3 = "Button_zhu3",
		Button_zhu4 = "Button_zhu4",
		Button_zhu5 = "Button_zhu5",
		Button_zhuSure = "Button_zhuSure",
		Panel_sliderZhu = "Panel_sliderZhu",
		Panel_chipList = "Panel_chipList",
		Image_chip = "Image_chip",
		Button_add = "Button_add",
		Button_reduce = "Button_reduce",
		Text_rasieCoin = "Text_rasieCoin",
		--游戏按钮
		Node_gameBtn = "Node_gameBtn",
		Button_jiaopai = "Button_jiaopai",
		Button_tingpai = "Button_tingpai",
		Button_fanbei = "Button_fanbei",

		Image_fapaiqi = "Image_fapaiqi",
		--用户按钮
		Button_tuichu = {"Button_tuichu",0,1},
		Button_rule = {"Button_rule",1},
		Button_shengyin = {"Button_shengyin",1},

		Node_cardMove = "Node_cardMove",
		--特效层
		Node_beginAnim = "Node_beginAnim",

		Node_noAction = "Node_noAction",
		--离开和继续按钮
		Button_jixu = "Button_jixu",
		Button_likai = "Button_likai",
		Node_playerAction = "Node_playerAction",
		--下拉菜单
		-- Image_voiceBg = "Image_voiceBg",
		-- Button_effect = "Button_effect",
		-- Button_music = "Button_music",
		--金币移动
		Node_goldMove = "Node_goldMove",
		--抢庄按钮层
		Node_qiangzhuang = "Node_qiangzhuang",
		Button_qiang = "Button_qiang",
		Button_buqiang = "Button_buqiang",
		--放弃庄家
		Button_giveupBank = "Button_giveupBank",


	}

	self:initData();

	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")

	loadNewCsb(self,"shidianban/GameScene",uiTable);

	--初始化按钮
    if globalUnit.isShowZJ then
        self.Image_voiceBg = self.Button_shengyin:getChildByName("Image_voiceBg1");
        self.Button_zhanji = self.Image_voiceBg:getChildByName("Button_zhanji");
    else
        self.Image_voiceBg = self.Button_shengyin:getChildByName("Image_voiceBg0");
    end

    self.Button_effect = self.Image_voiceBg:getChildByName("Button_effect");
    self.Button_music = self.Image_voiceBg:getChildByName("Button_music");

	_instance = self;
end
--进入
function TableLayer:onEnter()
	self:initUI();
	self:bindEvent();--绑定消息
	self.super.onEnter(self);
end
--退出
-- function TableLayer:onExit()
-- 	self.tableLogic:sendUserUp();
-- 	self.tableLogic:sendForceQuit();
-- 	globalUnit.isEnterGame = false;
-- 	self.super.onExit(self);

-- 	self.tableLogic:stop();

-- 	audio.stopMusic();

-- 	self:stopAllActions();
	
-- 	local node = self:getChildByTag(1421);
-- 	if node then
-- 		node:delayCloseLayer(0);
-- 	end
-- end
--绑定消息
function TableLayer:bindEvent()
	self:pushEventInfo(SDBInfo, "GameStart", handler(self, self.onGameStart))--游戏开始
	self:pushEventInfo(SDBInfo, "GameEnd", handler(self, self.onGameEnd))--游戏结束
	self:pushEventInfo(SDBInfo, "AddScore", handler(self, self.onAddScore))--玩家操作命令
	self:pushEventInfo(SDBInfo, "SendCard", handler(self, self.onSendCard))--发牌命令
	self:pushEventInfo(SDBInfo, "GiveUp", handler(self, self.onGiveUp))--停牌命令
	self:pushEventInfo(SDBInfo, "GamePlay", handler(self, self.onGamePlay))--游戏开始
	self:pushEventInfo(SDBInfo, "BankerCard", handler(self, self.onBankerCard))--庄家的牌
	self:pushEventInfo(SDBInfo, "NoAction", handler(self, self.onNoAction))--玩家未操作
	self:pushEventInfo(SDBInfo, "PutScore", handler(self, self.onPutScore))--玩家下注
	self:pushEventInfo(SDBInfo, "BaoCard", handler(self, self.onBaoCard))--玩家爆牌

	self:pushEventInfo(SDBInfo, "PlayerQiang", handler(self, self.onPlayerQiang))--玩家抢庄
	self:pushEventInfo(SDBInfo, "QiangBegin", handler(self, self.onQiangBegin))--开始抢庄
	self:pushEventInfo(SDBInfo, "GiveUpBank", handler(self, self.onGiveUpBank))--放弃庄
	self:pushEventInfo(SDBInfo, "PlayBank", handler(self, self.onPlayBank))--播放跑马灯动画
	self:pushEventInfo(SDBInfo, "Begin", handler(self, self.onBegin))--玩家开始状态

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
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


--添加用户
function TableLayer:addUser(deskStation, bMe)
    if not self:isValidSeat(deskStation) then 
        return;
    end

    local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:viewToLogicSeatNo(deskStation));
    luaDump(self.playerNode,"添加用户")
    luaPrint("添加用户",deskStation)
    self.playerNode[deskStation+1]:SetPlayerInfo(userInfo);
    -- self["Node_player"..deskStation]:getChildByName("Node_chouma"):setVisible(true);

end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
    
    if not self:isValidSeat(seatNo) then 
        return;
    end

    if seatNo == 0 then
    	if bLock == 1 then
    		self:runAction(cc.Sequence:create(cc.CallFunc:create(function()
				local beginAnim = self.Node_beginAnim:getChildByName("beginAnim");
				if beginAnim then
					beginAnim:removeFromParent();
				end
    			
    			self:playZitiEffect(2);
    			audio.playSound("shidianban/sound/coinNeed.mp3");
    		end),cc.DelayTime:create(3),cc.CallFunc:create(function()
	    		self:BackCallBack(5);
	    		addScrollMessage("您的金币不足!")
	    	end)));
	    	-- self:BackCallBack(5);
    		-- addScrollMessage("您的金币不足!")
		elseif bLock == 0 then
			self:BackCallBack(5);
    	elseif bLock == 3 then
	    	self:BackCallBack(5);
    		addScrollMessage("您长时间未操作!")
		elseif bLock == 2 or bLock == 5 then
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
				self:BackCallBack(5);
				if bLock == 2 then
					addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。");
				else
					addScrollMessage("VIP房间已关闭,自动退出游戏。");
				end
			end)));
    	end
    	return;
    end

    self.playerNode[seatNo+1]:ClearPlayerInfo();
    -- self.playerCardNode[seatNo+1]:ClearCardLayer();
    self["Node_player"..seatNo]:getChildByName("Node_chouma"):setVisible(false);

    --根据人数显示等待玩家动画
	if self:GetUserNum() <= 1 then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
			if self.gameStart == false then
	    		self:ClearDeakInfo();
				self:ShowWaitingOther();
				self.playerNode[1]:SetPlayerBank(false);
			end
    	end)));

	-- else
	-- 	self:RemoveWaiting();
	-- 	if self.playerState[self.tableLogic:getMySeatNo()+1] == false then
	-- 		self:ShowWaitingNext();
	-- 	end
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

    -- self.playerNodeInfo[seatNo]:setUserName(name);
end
--设置玩家分数显示隐藏
function TableLayer:showUserMoney(seatNo, visible)
    --luaPrint("设置玩家分数显示隐藏 ------------ seatNo "..seatNo)
    if not self:isValidSeat(seatNo) then
        return;
    end
    
    --luaPrint("设置玩家分数显示隐藏")
    seatNo = seatNo + 1;

    -- self.playerNodeInfo[seatNo]:showUserMoney(visible);
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

		if globalUnit.nowTingId == 0 then
			performWithDelay(display.getRunningScene(), function() RoomLogic:close(); end,0.5);
		end
		
		self._bLeaveDesk = true;
		_instance = nil;
		self.gameStart = false;--游戏结束
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

	self.gameStart = false;
end

--后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if device.platform == "windows" then
		return;
	end
	if RoomLogic:isConnect() then

		self.gameStart = false;

		-- self:stopAllActions();

		-- self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
		self:InitMusic();
	else
		-- self.gameStart = false;
		-- self:BackCallBack();
	end
end
-------------------------------------------------------------------------------------
--初始化数据
function TableLayer:initData()	
	self.m_iHeartCount = 0;--心跳计数
	self.m_maxHeartCount = 3;--最大心跳计数
	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

	self.gameStart = false;--游戏状态

	self.playerNode = {};--玩家结点
	self.playerCardNode = {};--玩家牌的数据

	self.lCellScore = 0;--游戏入场限制

	self.lMaxScore = 0;--玩家滑动条上限

	self.bankStation = -1;--庄家的座位号

	self.playerState = {}--玩家的状态

	self.actonFinish = true;--其他按钮伸缩动画标志

	self.qiangTable = {};--抢庄的数组
end
--初始化界面
function TableLayer:initUI()
	--初始化玩家
	self:InitPlayerNode();
	--基本按钮
	self:initGameNormalBtn();
	--加载初始化场景
	self:LoadGameScene();
	-- 初始化音乐
	self:InitMusic();

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	self.Button_rule:setPositionX(self.Button_rule:getPositionX()-10);
	self.Button_rule:setLocalZOrder(5);

	local size = cc.p(self.Button_rule:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("shidianban",self);
    self.Image_bg:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(size.x+85,size.y-105);

    if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self);
	    self:addChild(self.m_logBar);
	end

end
--初始化玩家信息
function TableLayer:InitPlayerNode()
	for i = 0,GameMsg.GAME_PLAYER-1 do
		local playerNode = GamePlayerNode.new(i);
		self["Node_player"..i]:addChild(playerNode);
		table.insert(self.playerNode,playerNode);
		local Node_chouma = self["Node_player"..i]:getChildByName("Node_chouma");
		Node_chouma:setVisible(false);
		self:SetPlayerZhuMoney(i);
	end
end

--初始化按钮
function TableLayer:initGameNormalBtn()
	for i = 1,5 do--下注按钮
		self["Button_zhu"..i]:addClickEventListener(function(sender) self:onPlayerPutScore(sender) end)
		self["Button_zhu"..i]:setTag(i);
	end
	self.Node_zhuBtn:setVisible(false);
	--叫牌按钮
	self.Button_jiaopai:onClick(handler(self,self.SendGiveCard))
	--停牌按钮
	self.Button_tingpai:onClick(handler(self,self.SendGiveUp))
	--翻倍按钮
	self.Button_fanbei:onClick(handler(self,self.SendAddScore))
	--确定下注
	self.Button_zhuSure:addClickEventListener(function(sender) self:SendSliderZhu(sender) end)
	--取消滑动下注
	self.Panel_sliderZhu:addClickEventListener(function(sender) self:CancleSliderZhu() end)
	--退出
	self.Button_tuichu:onClick(handler(self,self.BackCallBack))
	--规则
	self.Button_rule:addClickEventListener(function(sender) self:RuleCallBack(sender) end)
	--声音
	self.Button_shengyin:addClickEventListener(function(sender) self:VoiceCallBack(sender) end)
	self.Button_shengyin:setTag(0);
	--增加筹码
	self.Button_add:addClickEventListener(function(sender) self:AddCallBack(sender) end)
	--减少筹码
	self.Button_reduce:addClickEventListener(function(sender) self:ReduceCallBack(sender) end)
	--继续和离开按钮
	self.Button_jixu:onClick(handler(self,self.JixuCallBack));
	self.Button_likai:onClick(handler(self,self.BackCallBack));
	--音效
	self.Button_effect:addClickEventListener(function(sender) self:EffectCallBack(sender) end)
	--音乐
	self.Button_music:addClickEventListener(function(sender) self:MusicCallBack(sender) end)

	--抢庄按钮
	self.Button_qiang:onClick(handler(self,self.SendPlayerQiang))

	--不抢庄按钮
	self.Button_buqiang:onClick(handler(self,self.SendNoPlayerQiang))
	--放弃庄家按钮
	self.Button_giveupBank:setVisible(false);
	self.Button_giveupBank:setTag(0);
	self.Button_giveupBank:onClick(handler(self,self.SendGiveUpBank))

	--战绩
	if self.Button_zhanji then
		self.Button_zhanji:onClick(function(sender)
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end)
	end
end

--初始化背景音乐
function TableLayer:InitMusic()
	-- local musicState = cc.UserDefault:getInstance():getIntegerForKey("yyy_music",1);
	local musicState = getMusicIsPlay();
	if musicState then
		audio.playMusic("shidianban/sound/bg.mp3", true)
	else
		audio.stopMusic();
	end
end

--初始化音乐音效
function TableLayer:InitSet()
	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")

	--重新设置纹理
    if globalUnit.isShowZJ then
    	self.Image_voiceBg:loadTexture("sdb_diban1.png");
    	self.Button_zhanji:loadTextures("sdb_zhanji.png","sdb_zhanji-on.png");
    else
    	self.Image_voiceBg:loadTexture("sdb_diban.png",UI_TEX_TYPE_PLIST);
    end

	--音效
	local effectState = getEffectIsPlay();
	if effectState then--开着音效
		self.Button_effect:loadTextures("sdb_yinxiao.png","sdb_yinxiao-on.png","sdb_yinxiao-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_effect:loadTextures("sdb_yinxiao2.png","sdb_yinxiao2-on.png","sdb_yinxiao2-on.png",UI_TEX_TYPE_PLIST);	
	end
	--音乐
	local musicState = getMusicIsPlay();
	if musicState then--开着音效
		self.Button_music:loadTextures("sdb_yinyue.png","sdb_yinyue-on.png","sdb_yinyue-on.png",UI_TEX_TYPE_PLIST);		
	else
		self.Button_music:loadTextures("sdb_yinyue2.png","sdb_yinyue2-on.png","sdb_yinyue2-on.png",UI_TEX_TYPE_PLIST);	
	end
end

--加载初始化消息
function TableLayer:LoadGameScene()
	--初始化牌的数据
	for i = 0,GameMsg.GAME_PLAYER-1 do
		local cardLayer = CardLayer:create(i);
		local Node_card = self["Node_player"..i]:getChildByName("Node_card");
		Node_card:addChild(cardLayer);
		table.insert(self.playerCardNode,cardLayer);
	end
	--增加滑动筹码点击事件
	self:addChipListTouchEvent();
	self.Node_noAction:setVisible(false);
	self.Node_qiangzhuang:setVisible(false);
	self.Node_gameBtn:setVisible(false);

	for i =1,GameMsg.GAME_PLAYER do
		self.qiangTable[i] = qzState.sikao;
	end
	--显示荷官动画
	local DealerAnim = {
		name = "spz_nvheguan",
		json = "shidianban/effect/nvheguan.json",
		atlas = "shidianban/effect/nvheguan.atlas",
	}

	local DealerAnimName = "nvheguan";

	local skeleton_animation = createSkeletonAnimation(DealerAnim.name,DealerAnim.json,DealerAnim.atlas);
	if skeleton_animation then
		skeleton_animation:setAnimation(0,DealerAnimName, true);
		self.Image_fapaiqi:addChild(skeleton_animation);
		skeleton_animation:setName("Skeleton_dealer");
	end
end
--叫牌按钮
function TableLayer:SendGiveCard()
	self.tableLogic:SendGiveCard();
end
--停牌按钮
function TableLayer:SendGiveUp()
	self.tableLogic:SendGiveUp();
end
--翻倍按钮
function TableLayer:SendAddScore()
	self.tableLogic:SendAddScore();
end
--抢庄按钮
function TableLayer:SendPlayerQiang()
	self.tableLogic:SendPlayerQiang(true);
end

--不抢庄按钮
function TableLayer:SendNoPlayerQiang()
	self.tableLogic:SendPlayerQiang(false);
end

--放弃庄
function TableLayer:SendGiveUpBank()
	if self.Button_giveupBank:getTag() == 0 then--没有弃庄改为弃庄
		self.tableLogic:SendGiveUpBank(true);
	else
		self.tableLogic:SendGiveUpBank(false);
	end
end

--设置放弃庄按钮的图片
function TableLayer:SetGiveUpBankButton(isGiveUp)
	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
	if isGiveUp then
		self.Button_giveupBank:setTag(1);
		self.Button_giveupBank:loadTextures("sdb_qizhuang2.png","sdb_qizhuang-on.png","sdb_qizhuang-on.png",UI_TEX_TYPE_PLIST);
	else
		self.Button_giveupBank:setTag(0);
		self.Button_giveupBank:loadTextures("sdb_qizhuang.png","sdb_qizhuang-on.png","sdb_qizhuang-on.png",UI_TEX_TYPE_PLIST);
	end
end

--退出
function TableLayer:BackCallBack(isRemove)
	local func = function()
        self.tableLogic:sendUserUp();
        self.tableLogic:sendForceQuit();  
    end

    if isRemove ~= nil and type(isRemove) == "number" then
		Hall:exitGame(isRemove,func);
	else
		if self.playerState[self.tableLogic:getMySeatNo()+1] then
	    	Hall:exitGame(self.gameStart,func);
	    else
	    	Hall:exitGame(false,func);
	    end
	end

end
--帮助按钮
function TableLayer:RuleCallBack(sender)
	self:addChild(PopUpLayer:create(),100);
end
--声音按钮
function TableLayer:VoiceCallBack(sender)
	if self.actonFinish == false then
		return;
	end

	self:InitSet();

	local senderTag = sender:getTag();

	self.actonFinish = false;--将标志位置成false
	local actionTime = 0.4;
	local moveAction;

	if senderTag == 0 then--下拉
		sender:setTag(1);
		moveAction = cc.MoveTo:create(actionTime,cc.p(self.Image_voiceBg:getPositionX(),82-self.Image_voiceBg:getContentSize().height-88));
	else--上拉
		sender:setTag(0);
		moveAction = cc.MoveTo:create(actionTime,cc.p(self.Image_voiceBg:getPositionX(),82));
	end
	self.Image_voiceBg:runAction(cc.Sequence:create(moveAction,cc.CallFunc:create(function()
		self.actonFinish = true;
	end)));

end
--音效按钮
function TableLayer:EffectCallBack(sender)
	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
	-- local effectState = cc.UserDefault:getInstance():getIntegerForKey("yyy_effect",1);
	local effectState = getEffectIsPlay();
	luaPrint("音效",effectState);
	if effectState then--开着音效
		-- cc.UserDefault:getInstance():setIntegerForKey("yyy_effect",0);
		setEffectIsPlay(false);
		--改变音效图片
		self.Button_effect:loadTextures("sdb_yinxiao2.png","sdb_yinxiao2-on.png","sdb_yinxiao2-on.png",UI_TEX_TYPE_PLIST);
	else
		-- cc.UserDefault:getInstance():setIntegerForKey("yyy_effect",1);
		setEffectIsPlay(true);
		self.Button_effect:loadTextures("sdb_yinxiao.png","sdb_yinxiao-on.png","sdb_yinxiao-on.png",UI_TEX_TYPE_PLIST);
	end
end
--音乐按钮
function TableLayer:MusicCallBack(sender)
	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
	--local musicState = cc.UserDefault:getInstance():getIntegerForKey("yyy_music",1);
	local musicState = getMusicIsPlay();
	luaPrint("音乐",musicState);
	if musicState then--开着音效
		--cc.UserDefault:getInstance():setIntegerForKey("yyy_music",0);
		setMusicIsPlay(false);
		self.Button_music:loadTextures("sdb_yinyue2.png","sdb_yinyue2-on.png","sdb_yinyue2-on.png",UI_TEX_TYPE_PLIST);
	else
		-- cc.UserDefault:getInstance():setIntegerForKey("yyy_music",1);
		setMusicIsPlay(true);
		self.Button_music:loadTextures("sdb_yinyue.png","sdb_yinyue-on.png","sdb_yinyue-on.png",UI_TEX_TYPE_PLIST);	
	end
	self:InitMusic();
end

--继续游戏
function TableLayer:JixuCallBack()
	self.tableLogic:SendGameContinue();
	self.Node_noAction:setVisible(false);
end

--增加筹码
function TableLayer:AddCallBack(sender)
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
 	self:updateRaiseTxt();
end

--减少筹码
function TableLayer:ReduceCallBack(sender)
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
 	self:updateRaiseTxt();
end

--下注
function TableLayer:onPlayerPutScore(sender)
	local senderTag = sender:getTag();

	if self.bankStation == self.tableLogic:getMySeatNo() then
		addScrollMessage("庄家不能下注")
		return;
	end

	if senderTag == 5 then
		self.Button_zhuSure:setVisible(true);
		self.Panel_sliderZhu:setVisible(true);
		self.Button_zhu5:setVisible(false);
		self:resetChipList();
	elseif senderTag == 1 then
		self.tableLogic:SendPutScore(self.lCellScore/20);
	elseif senderTag == 2 then
		self.tableLogic:SendPutScore(self.lCellScore/30);
	elseif senderTag == 3 then
		self.tableLogic:SendPutScore(self.lCellScore/40);
	elseif senderTag == 4 then
		self.tableLogic:SendPutScore(self.lCellScore/50);
	end
end
--显示滑动下注
function TableLayer:SendSliderZhu(sender)
	self:CancleSliderZhu();
	luaPrint("滑动下注",self.lCellScore/50,self.Text_rasieCoin:getTag())
	self.tableLogic:SendPutScore(self.lCellScore/50+self.Text_rasieCoin:getTag());
end
--取消滑动下注
function TableLayer:CancleSliderZhu()
	self.Button_zhuSure:setVisible(false);
	self.Panel_sliderZhu:setVisible(false);
	self.Button_zhu5:setVisible(true);
end

--播放动画
function TableLayer:playZitiEffect(iType)
	local ziSpine = self.Node_cardMove:getChildByName("ziSpine");
	if ziSpine then
		ziSpine:removeFromParent();
	end

	local ziSpine = self.Node_cardMove:getChildByName("kaishi");
	if ziSpine then
		ziSpine:removeFromParent();
	end

	if iType == 3 then
		local tipzi = {"dengdaixiaju","huanzhuang","kaishixiazhu","tingzhixiazhu"}
		local ziSpine = createSkeletonAnimation("zitiTip","game/feiqinzoushou.json","game/feiqinzoushou.atlas");
		if ziSpine and self.gameStart then
			ziSpine:setPosition(640,370);
			ziSpine:setAnimation(1,tipzi[iType], false);
			ziSpine:setName("ziSpine");
			self.Node_cardMove:addChild(ziSpine,10);
		end
	elseif iType == 1 then--开始游戏
		local ziSpine = createSkeletonAnimation("10dianbankaishi","shidianban/effect/10dianbankaishi.json","shidianban/effect/10dianbankaishi.atlas");
		if ziSpine then
			ziSpine:setPosition(640,360);
			ziSpine:setAnimation(1,"10dianbankaishi", false);
			ziSpine:setName("kaishi");
			self.Node_cardMove:addChild(ziSpine,10);

			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
				local ziSpine = self.Node_cardMove:getChildByName("kaishi");
				if ziSpine then
					ziSpine:removeFromParent();
				end
			end)))
		end
	elseif iType == 2 then--秒杀
		local ziSpine = createSkeletonAnimation("pukemiaosha","game/gameEffect/pukemiaosha.json","game/gameEffect/pukemiaosha.atlas");
		if ziSpine then
			ziSpine:setPosition(640,360);
			ziSpine:setAnimation(1,"miaosha_shidianban", false);
			ziSpine:setName("ziSpine");
			self.Node_cardMove:addChild(ziSpine,10);
		end
	end
end
--清除头像桌面头像
function TableLayer:ClearDeakInfo()
	for k,v in pairs(self.playerCardNode) do--清理桌面
		v:ClearCardLayer();
	end

	for k,v in pairs(self.playerNode) do--清理桌面
		v:ClearPlayerGameAction();
		v:SetPlayerBank(false);
	end

	self.Node_gameBtn:setVisible(false);
	self.Node_zhuBtn:setVisible(false);

	--将筹码区域隐藏
	for i = 0,GameMsg.GAME_PLAYER-1 do
		self:SetChoumaVisible(i,false);
	end

	local beginAnim = self.Node_beginAnim:getChildByName("beginAnim");
	if beginAnim then
		beginAnim:removeFromParent();
	end

	self:RemoveWaiting();

	--清除所有金币移动
	self.Node_goldMove:stopAllActions();
	self.Node_goldMove:removeAllChildren();
	--清除所有移动的牌
	self.Node_cardMove:stopAllActions();
	self.Node_cardMove:removeAllChildren();

	self.qiangTable = {};
	for i =1,GameMsg.GAME_PLAYER do
		self.qiangTable[i] = qzState.sikao;
	end
	self.Button_giveupBank:setVisible(false);
	self:SetGiveUpBankButton(false);
	-- self.Node_noAction:setVisible(false);

	self:ShowPlayerQiangState(false);
	
end
--设置下注筹码显示
function TableLayer:SetChoumaVisible(viewSeat,isVisible)
	self["Node_player"..viewSeat]:getChildByName("Node_chouma"):setVisible(isVisible);
end

--更新下注筹码数额
function TableLayer:updateRaiseTxt(tag)
	if tag == nil then
		tag = self.Panel_chipList:getTag();
	end
	-- local tag = self.Panel_chipList:getTag();
	local per = tag/HEAP_COUNT;
	local myMoney = self.lMaxScore - self.lCellScore/50;
	if per ~= 1 then
		local count = math.floor(myMoney*per);
		local amount = math.floor(count/100);
		local tag_count = math.floor(count);

		luaPrint("count,per,amount,tag_count:",self:ScoreToMoney(self.lCellScore/50),count,per,amount,tag_count);
		self.Text_rasieCoin:setString(self:ScoreToMoney(self.lCellScore/50+tag_count));
		self.Text_rasieCoin:setTag(tag_count);
		-- self.Button_raise:setEnabled(tag_count>self.m_callMoney);

	else
		local count = math.floor(myMoney*per);
		local amount = self:ScoreToMoney(myMoney*per);
		local tag_count = amount*100;

		luaPrint("count,per,amount:",count,per,amount)
		self.Text_rasieCoin:setString(self:ScoreToMoney(self.lCellScore/50+count));
		--实际下注筹码 记录到tag
		self.Text_rasieCoin:setTag(count);
		-- self.Button_raise:setEnabled(myMoney>self.m_callMoney);
	end
end
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
	
	local function updateRaiseTxt(tag)
		if tag == nil then
			tag = self.Panel_chipList:getTag();
		end
		local myMoney = self.lMaxScore - self.lCellScore/50;
		local per = tag/HEAP_COUNT;
		local count = math.floor(myMoney*per);



		if per ~= 1 then
			
			-- local amount = math.floor(count/100);
			local tag_count = math.floor(count);

			luaPrint("count,per,amount,tag_count:",count,per,amount,tag_count);
			self.Text_rasieCoin:setString(self:ScoreToMoney(self.lCellScore/50+tag_count));
			self.Text_rasieCoin:setTag(tag_count);
		else
			
			local amount = math.floor(myMoney*per/100);
			local tag_count = amount*100;
			luaPrint("count,per,amount:",tag_count,per,amount)
			self.Text_rasieCoin:setString(self:ScoreToMoney(self.lCellScore/50+count));
			--实际下注筹码 记录到tag
			self.Text_rasieCoin:setTag(count);
		end
	end


	local pos_s = cc.p(self.Image_chip:getPosition());
	--HEAP_COUNT  30
	for i=1,HEAP_COUNT do
		local img = self.Image_chip:clone();
		self.Panel_chipList:addChild(img);
		img:setTag(i);
		local pos_t = cc.p(pos_s.x,pos_s.y + gap*(i));
		img:setPosition(pos_t);
		img:setVisible(false);
		-- img:setScale(1.0-0.01*(i-1));
	end
	-- self.Image_chip:removeFromParent();
	self.Image_chip:setVisible(false);


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
	   return true  
	end, cc.Handler.EVENT_TOUCH_BEGAN );
	 
	listenner:registerScriptHandler(function(touch, event)
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
	   updateRaiseTxt(tag_t);
	end, cc.Handler.EVENT_TOUCH_MOVED); 
	 
	listenner:registerScriptHandler(function(touch, event)  
		local pos_w = touch:getLocation()
		local pos_pw = touch:getStartLocation();
		local length = pos_w.y - pos_pw.y;
		local tag = self.Panel_chipList:getTag();
		local tag_t = 0;
		if length >= 0 then
			local num = math.floor(length/gap);
			local children = self.Panel_chipList:getChildren();
			tag_t = num+tag;
			if tag_t > 30 then
				tag_t = 30;
			end
			for i,v in ipairs(children) do
				if v:getTag() <= tag_t then
					v:setVisible(true);
				else
					v:setVisible(false);
				end
			end

			self.Panel_chipList:setTag(tag_t);
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
			self.Panel_chipList:setTag(tag_t);
		end
		self.Button_reduce:setEnabled(tag_t > 0);
		self.Button_add:setEnabled(tag_t < HEAP_COUNT);
		updateRaiseTxt();
	end, cc.Handler.EVENT_TOUCH_ENDED)  
	    
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.Panel_chipList);
end

--重置加注信息
function TableLayer:resetChipList()
	self.Panel_chipList:setTag(0);
	local children = self.Panel_chipList:getChildren();
	for i,v in ipairs(children) do
		v:setVisible(false);
	end

	self.Text_rasieCoin:setString(self:ScoreToMoney(self.lCellScore/50));
	self.Text_rasieCoin:setTag(0);
	self.Button_reduce:setEnabled(false);
	self.Button_add:setEnabled(true);
end

------------------------------------------------游戏消息处理---------------------------------------------
--空闲状态
function TableLayer:gameStationFree(msg)
	self:stopAllActions();
	self:ClearDeakInfo();
	self.lCellScore = msg.lCellScore;
	self.gameStart = false;--游戏结束
	self:LoadPlayerState();
	self:SetPlayerChipNum();
	self.Node_zhuBtn:setVisible(false);
	self.Node_qiangzhuang:setVisible(false);
	self:UpdateUserMoney();

	--根据人数显示等待玩家动画
	if self:GetUserNum() <= 1 then
		self:ShowWaitingOther();
	else
		self:RemoveWaiting();

		self.Button_giveupBank:setVisible(msg.bShowGiveUp);
		if msg.bShowGiveUp then
			self:SetGiveUpBankButton(msg.bGiveUp);
		end
	end

end

--开始状态
function TableLayer:gameStationStart()
	self:stopAllActions();
	self:ClearDeakInfo();
	self.gameStart = true;--游戏结束
	self:LoadPlayerState();
	self:SetPlayerChipNum();
	self.Node_zhuBtn:setVisible(false);
	self.Node_qiangzhuang:setVisible(false);
	self:UpdateUserMoney();

	self:playZitiEffect(1);

end

--抢庄状态
function TableLayer:gameStationQiang(msg)
	self:stopAllActions();
	self:ClearDeakInfo();
	self.lCellScore = msg.lCellScore;
	self.gameStart = true;--游戏开始
	self:LoadPlayerState(msg.bUserStatus);
	self:SetPlayerChipNum();
	self.Node_zhuBtn:setVisible(false);

	self:ShowPlayerQiangState(true);

	--显示玩家的状态
	for k,v in ipairs(self.playerState) do
		if v then
			self:ChangePlayerQaingState(self.tableLogic:logicToViewSeatNo(k-1),msg.bQiang[k]);
		end
	end

	
	if msg.bQiang[self.tableLogic:getMySeatNo()+1] == qzState.sikao and msg.bUserStatus[self.tableLogic:getMySeatNo()+1] then--判断是否要显示抢庄界面
		self.Node_qiangzhuang:setVisible(true);
	else
		self.Node_qiangzhuang:setVisible(false);
	end

	self.qiangTable = msg.bQiang;

	--设置抢庄倒计时
	for k,v in pairs(self.playerState) do
		if v and msg.bQiang[k] == qzState.sikao then
			self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:showPlayerTimer(5,msg.iLeftTime);
		end
	end
	
	self:UpdateUserMoney();

	--播放等待下局
	if msg.bUserStatus[self.tableLogic:getMySeatNo()+1] == false then
		self:ShowWaitingNext();
		self.Node_zhuBtn:setVisible(false);
	end
end
--下注状态
function TableLayer:gameStationScore(msg)
	self:stopAllActions();
	self:ClearDeakInfo();
	self.Node_noAction:setVisible(false);
	self:LoadPlayerState(msg.bUserStatus);
	self.lCellScore = msg.lCellScore;
	self.lMaxScore = msg.lMaxScore;
	self.Node_gameBtn:setVisible(false);
	self:SetPlayerChipNum();
	--显示下注
	self.Node_zhuBtn:setVisible(true);
	self.Button_zhuSure:setVisible(false);
	self.Panel_sliderZhu:setVisible(false);
	self.Button_zhu5:setVisible(true);
	self.Node_qiangzhuang:setVisible(false);
	self:UpdateUserMoney();

	-- self.Node_zhuBtn:setVisible(true);
	self:ZhuNodeAction();

	self.bankStation = msg.wBankerUser;
	self.gameStart = true;--游戏开始
	--设置玩家头像庄家
	for k,v in pairs(self.playerNode) do
		if self.tableLogic:logicToViewSeatNo(msg.wBankerUser)+1 == k then
			v:SetPlayerBank(true);
			self:SetChoumaVisible(k-1,false);
		else
			v:SetPlayerBank(false);
			self:SetChoumaVisible(k-1,false);
			if msg.bUserStatus[self.tableLogic:viewToLogicSeatNo(k-1)+1] then
				self:SetChoumaVisible(k-1,true);
			end
			self:SetZhuBtnEnable(true);
		end
		self:SetPlayerZhuMoney(k-1);
	end

	if msg.wBankerUser == self.tableLogic:getMySeatNo() then
		self:SetZhuBtnEnable(false);
	end

	for k,v in pairs(msg.bUserStatus) do
		if v and k-1~=msg.wBankerUser and msg.lTableScore[k] == 0 then
			self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:showPlayerTimer(8,msg.iLeftTime);
		end
	end

	--设置玩家下注筹码
	for k,v in pairs(msg.lTableScore) do
		if msg.bUserStatus[k] and v>0 then
			self:SetPlayerZhuMoney(self.tableLogic:logicToViewSeatNo(k-1),v);
			local playerNode = self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1];
			playerNode:SetPlayerMoney(playerNode:GetPlayerMoney()-v);
			if k-1 == self.tableLogic:getMySeatNo() then--下过注则将下注按钮置灰
				self:SetZhuBtnEnable(false);
			end
		end
	end
	--播放等待下局
	if msg.bUserStatus[self.tableLogic:getMySeatNo()+1] == false then
		self:ShowWaitingNext();
		self.Node_zhuBtn:setVisible(false);
	end
end
--游戏状态
function TableLayer:gameStationPlay(msg)
	self:stopAllActions();
	self:ClearDeakInfo();
	self.Node_noAction:setVisible(false);
	self:LoadPlayerState(msg.byUserStatus);
	self.Node_gameBtn:setVisible(true);
	self.Node_zhuBtn:setVisible(false);
	self.Node_qiangzhuang:setVisible(false);
	self:GameNodeAction();
	self.bankStation = msg.wBankerUser;
	self.gameStart = true;--游戏开始
	self.lCellScore = msg.lCellScore;
	self:SetPlayerChipNum();
	self:UpdateUserMoney();
	--设置按钮
	if msg.wCurrentUser == self.tableLogic:getMySeatNo() then
		self.Button_jiaopai:setEnabled(true);
		self.Button_tingpai:setEnabled(true);
		self.Button_fanbei:setEnabled(true);
		if self.bankStation == self.tableLogic:getMySeatNo() then
			self.Button_fanbei:setEnabled(false);
		end
	else
		self.Button_jiaopai:setEnabled(false);
		self.Button_tingpai:setEnabled(false);
		self.Button_fanbei:setEnabled(false);
	end

	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wCurrentUser)+1]:showPlayerTimer(15,msg.iLeftTime);

	--设置玩家头像庄家
	for k,v in pairs(self.playerNode) do
		if self.tableLogic:logicToViewSeatNo(msg.wBankerUser)+1 == k then
			v:SetPlayerBank(true);
			self:SetChoumaVisible(k-1,false);
		else
			v:SetPlayerBank(false);
			self:SetChoumaVisible(k-1,false);
			if msg.byUserStatus[self.tableLogic:viewToLogicSeatNo(k-1)+1] then
				self:SetChoumaVisible(k-1,true);
			end
		end
		self:SetPlayerZhuMoney(k-1);
	end

	--绘制牌
	for k,v in pairs(msg.cbCardCount) do
		if v>0 then
			local cardData = {};
			for i = 1,v do
				cardData[i] = msg.cbHandCardData[k][i];
			end
			self.playerCardNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:SetCardData(cardData);
			local cardVaule,cardType = GameLogic:GetCardType(cardData);

			if cardType == GameLogic.Error and k-1 ~=self.tableLogic:getMySeatNo() then
				self.playerCardNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:ShowCardSum();
			end


			if k-1 ==self.tableLogic:getMySeatNo() then
				self.playerCardNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:ShowCardSum();
				--如果发的牌的数量大于2 将翻倍置灰
				if #self.playerCardNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:GetCardData()>1 then
					self.Button_fanbei:setEnabled(false);
				end
				--判断10点半的话不能进行叫牌
				if cardVaule == 10.5 then
					self.Button_jiaopai:setEnabled(false);
				end

			end
		end
	end
	--设置玩家下注筹码
	for k,v in pairs(msg.lTableScore) do
		if msg.byUserStatus[k] and v>0 then
			self:SetPlayerZhuMoney(self.tableLogic:logicToViewSeatNo(k-1),v);
			local playerNode = self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1];
			-- luaPrint("playerNode:GetPlayerMoney()",playerNode:GetPlayerMoney())
			playerNode:SetPlayerMoney(playerNode:GetPlayerMoney()-v);
		end
	end

	--播放等待下局
	if msg.byUserStatus[self.tableLogic:getMySeatNo()+1] == false then
		self:ShowWaitingNext();
		self.Node_gameBtn:setVisible(false);
	end

end
--游戏开始
function TableLayer:onGameStart(data)

	self:ClearDeakInfo();
	self.Node_noAction:setVisible(false);

	local msg = data._usedata;
	self.Node_gameBtn:setVisible(false);
	--下注按钮初始化
	self.Node_zhuBtn:setVisible(true);
	self.Button_zhuSure:setVisible(false);
	self.Panel_sliderZhu:setVisible(false);
	self.Button_zhu5:setVisible(true);
	self:UpdateUserMoney();--更新金币
	self.Node_qiangzhuang:setVisible(false);
	self.gameStart = true;

	self.bankStation = msg.wBankerUser;
	self.lCellScore = msg.lCellScore;
	self.lMaxScore = msg.lMaxScore;

	-- self.Node_zhuBtn:setVisible(true);
	self:ZhuNodeAction();

	for k,v in pairs(self.playerCardNode) do
		v:ClearCardLayer();
	end
	--设置玩家状态
	self:LoadPlayerState(msg.bUserStatus);

	--播放等待下局
	if msg.bUserStatus[self.tableLogic:getMySeatNo()+1] == false then
		self:ShowWaitingNext();
	end

	--设置玩家头像庄家
	for k,v in pairs(self.playerNode) do
		if self.tableLogic:logicToViewSeatNo(msg.wBankerUser)+1 == k then
			v:SetPlayerBank(true);
			self:SetChoumaVisible(k-1,false);

		else
			v:SetPlayerBank(false);
			if msg.bUserStatus[self.tableLogic:viewToLogicSeatNo(k-1)+1] then
				self:SetChoumaVisible(k-1,true);
			end
			self:SetZhuBtnEnable(true);
		end

		self:SetPlayerZhuMoney(k-1);
	end

	if msg.wBankerUser == self.tableLogic:getMySeatNo() then
		self:SetZhuBtnEnable(false);
	end

	for k,v in pairs(msg.bUserStatus) do
		if v and k-1~=msg.wBankerUser then
			self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:showPlayerTimer(8,8);
		elseif v == false and k-1 == self.tableLogic:getMySeatNo() then
			self.Node_zhuBtn:setVisible(false);
		end
	end
	--播放开始下注的动画
	self:playZitiEffect(3);
	local effectState = getEffectIsPlay();
	if effectState then
		audio.playSound("shidianban/sound/sound-start-wager.mp3");
	end
end
--游戏结束
function TableLayer:onGameEnd(data)
	if self.gameStart == false then
		return;
	end

	local msg = data._usedata;
	-- self.Node_gameBtn:setVisible(true);
	-- self.Node_zhuBtn:setVisible(false);
	-- for k,v in pairs(self.playerCardNode) do
	-- 	v:ClearCardLayer();
	-- end
	luaDump(self.playerState,"玩家状态")

	self.Image_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
		
		--显示牌
		for k,v in pairs(msg.byCardData) do
			if v>0 and self.playerState[k] then
				if k-1 ~= self.tableLogic:getMySeatNo() then
					self.playerCardNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:SetFirstCard(v);
					self.playerCardNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:ShowCardSum();
				end
			end
		end

		--更新玩家金币
		for k,v in pairs(self.playerState) do
			if v then
				local userInfo = self.tableLogic:getUserBySeatNo(k-1);
				if userInfo then
					-- luaDump(userInfo,"更新玩家金币")
					self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:SetPlayerMoney(userInfo.i64Money);
					self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:ShowAction();
				end
			end
		end
		--显示玩家输赢
		for k,v in pairs(self.playerState) do
			if v then
				local playerScore = msg.lGameScore[k];

				local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
				-- if playerScore~=0 then
					self.playerNode[viewSeat+1]:SetPlayerScore(playerScore);

					if k ~= self.bankStation+1 then
						self:GoldMoveAction(viewSeat,playerScore>0);
					end
				-- end

				--如果是自己则再播下输赢音效
				if viewSeat == 0 then
					local str = "shidianban/sound/";

					if playerScore > 0 then
						str = str.."win.mp3";
					elseif playerScore < 0 then
						str = str.."lose.mp3";
					end

					self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
						audio.playSound(str);
					end)))
				end
			end
			
		end

		--播放连胜特效
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

					shengAction:setPosition(bgSize.width/2,bgSize.height/2);
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


		local effectState = getEffectIsPlay();
		if effectState then
			audio.playSound("shidianban/sound/fly_gold.mp3",false);
		end
		--如果有操作则显示倒计时
		-- if self.noAction == false then
			local beginAnim = self.Node_beginAnim:getChildByName("beginAnim");
			if beginAnim then
				beginAnim:removeFromParent();
			end

			local skeleton_animation = createSkeletonAnimation(BeginAnim.name,BeginAnim.json,BeginAnim.atlas);
			if skeleton_animation then
				self.Node_beginAnim:addChild(skeleton_animation);
				-- local pos = cc.p(640,360)
				skeleton_animation:setAnimation(0,BeginAnimAnimName, false);
				skeleton_animation:setName("beginAnim");
			end

		-- end

		--去掉按钮变亮和倒计时
		self.Button_jiaopai:setEnabled(false);
		self.Button_tingpai:setEnabled(false);
		self.Button_fanbei:setEnabled(false);

		--隐藏玩家倒计时
		for k,v in pairs(self.playerNode) do
			v:HidePlayerTimer();
		end

		self.Node_zhuBtn:setVisible(false);
		self.Node_gameBtn:setVisible(false);

		--放弃庄家按钮的显示
		if self.bankStation == self.tableLogic:getMySeatNo() then
			self.Button_giveupBank:setVisible(msg.bShowGiveUp);
		end
	end)))


	self.gameStart = false;--游戏结束
end

--更新玩家金币
function TableLayer:UpdateUserMoney()
	for k=0,GameMsg.GAME_PLAYER-1 do
		local userInfo = self.tableLogic:getUserBySeatNo(k);
		if userInfo then
			-- luaDump(userInfo,"更新玩家金币")
			self.playerNode[self.tableLogic:logicToViewSeatNo(k)+1]:SetPlayerMoney(userInfo.i64Money);
		end
	end
end

--玩家操作命令
function TableLayer:onAddScore(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	self.Button_fanbei:setEnabled(false);
	--发一张牌
	local viewSeat = self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser);
	self:SendCardAction(viewSeat,msg.cbCardData,self:GetCardLastPos(viewSeat));
	-- if msg.wAddScoreUser ==self.tableLogic:getMySeatNo() then
	-- 	-- self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser)+1]:ShowCardSum();
	-- 	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser)+1]:ShowAction(3);
	-- end
	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser)+1]:ShowAction(3);
	--设置加倍
	self:PlayerMoneyAdd(self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser));
	--播放加倍音效
	self:PlayOperateEffect(msg.wAddScoreUser,3);

end
--发牌命令
function TableLayer:onSendCard(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;

	--如果发的牌是0或255则不发牌
	-- if msg.cbCardData == 0 or msg.cbCardData == 255 then
	-- 	return;
	-- end

	-- self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wSendCardUser)+1]:AddCardData(msg.cbCardData);
	local viewSeat = self.tableLogic:logicToViewSeatNo(msg.wSendCardUser);
	self:SendCardAction(viewSeat,msg.cbCardData,self:GetCardLastPos(viewSeat));
	luaPrint("发牌",self.tableLogic:getMySeatNo(),self.bankStation)
	-- if msg.wSendCardUser ==self.tableLogic:getMySeatNo() then
	-- 	-- self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wSendCardUser)+1]:ShowCardSum();
	-- 	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wSendCardUser)+1]:ShowAction(1);
	-- end
	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wSendCardUser)+1]:ShowAction(1);
	--播放发牌音效
	self:PlayOperateEffect(msg.wSendCardUser,1);
end
--停牌命令
function TableLayer:onGiveUp(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	if msg.wGiveUpUser == self.tableLogic:getMySeatNo() then
		self.Button_jiaopai:setEnabled(false);
		self.Button_tingpai:setEnabled(false);
		self.Button_fanbei:setEnabled(false);
	end
	--轮到自己
	if msg.wCurrentUser == self.tableLogic:getMySeatNo() then
		self.Button_jiaopai:setEnabled(true);
		self.Button_tingpai:setEnabled(true);
		self.Button_fanbei:setEnabled(true);
		if self.bankStation == self.tableLogic:getMySeatNo() then
			self.Button_fanbei:setEnabled(false);
		end
	end
	--隐藏玩家倒计时
	for k,v in pairs(self.playerNode) do
		v:HidePlayerTimer();
	end
	if msg.wCurrentUser ~= GameMsg.INVALID_CHAIR then
		self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wCurrentUser)+1]:showPlayerTimer(15,15);
	end

	local giveUpCard = self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wGiveUpUser)+1]:GetCardData();
	local cardVaule,cardType = GameLogic:GetCardType(giveUpCard);
	luaPrint("玩家是否爆牌",cardType);

	if msg.wGiveUpUser ~= GameMsg.INVALID_CHAIR and (self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wGiveUpUser)+1]:GetTipTag()~=3 and cardType~=GameLogic.Error) then
		self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wGiveUpUser)+1]:ShowAction(2);
		--播放停牌音效
		self:PlayOperateEffect(msg.wGiveUpUser,2);
	end
	-- if msg.wCurrentUser ==self.tableLogic:getMySeatNo() or self.bankStation == msg.wCurrentUser then
	-- 	self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wCurrentUser)+1]:ShowCardSum();
	-- end
end
--游戏开始
function TableLayer:onGamePlay(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	luaPrint("游戏开始")
	--按钮操作
	self.Node_zhuBtn:setVisible(false);
	self.Node_gameBtn:setVisible(true);
	self.Node_qiangzhuang:setVisible(false);
	self:GameNodeAction();
	--所有按钮变量
	self.Button_jiaopai:setEnabled(false);
	self.Button_tingpai:setEnabled(false);
	self.Button_fanbei:setEnabled(false);
	if msg.wCurrentUser == self.tableLogic:getMySeatNo() then
		self.Button_jiaopai:setEnabled(true);
		self.Button_tingpai:setEnabled(true);
		self.Button_fanbei:setEnabled(true);
		if self.bankStation == self.tableLogic:getMySeatNo() then
			self.Button_fanbei:setEnabled(false);
		end
	end
	--添加牌 循环发牌动画
	self:FirstSendCard(msg.byCardData);
	--隐藏玩家倒计时
	for k,v in pairs(self.playerNode) do
		v:HidePlayerTimer();
	end
	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wCurrentUser)+1]:showPlayerTimer(15,15);

	if self.playerState[self.tableLogic:getMySeatNo()+1] == false then
		self.Node_gameBtn:setVisible(false);
	end

end
--庄家的牌
function TableLayer:onBankerCard(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	if self.bankStation ~= self.tableLogic:getMySeatNo() and msg.cbBankerHandCardData>0 then
		self.playerCardNode[self.tableLogic:logicToViewSeatNo(self.bankStation)+1]:SetFirstCard(msg.cbBankerHandCardData);
		-- self.playerCardNode[self.tableLogic:logicToViewSeatNo(self.bankStation)+1]:ShowCardSum();
	end
end
--玩家未操作
function TableLayer:onNoAction(data)
	if self.gameStart == false then
		return;
	end

	-- self.noAction = true;
	self.Node_noAction:setVisible(true);
end

--充值
function TableLayer:DealBankInfo(data)
	local realSeat = self.tableLogic:getlSeatNo(data.UserID);

	local playerNode = self.playerNode[self.tableLogic:logicToViewSeatNo(realSeat)+1];
	playerNode:SetPlayerMoney(playerNode:GetPlayerMoney()+data.OperatScore);
end


--玩家下注
function TableLayer:onPutScore(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	self:SetPlayerZhuMoney(self.tableLogic:logicToViewSeatNo(msg.wChairID),msg.lScore);
	local playerNode = self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1];
	playerNode:SetPlayerMoney(playerNode:GetPlayerMoney()-msg.lScore);
	--如果是自己则将下注筹码置灰
	if msg.wChairID == self.tableLogic:getMySeatNo() then
		self:SetZhuBtnEnable(false);
		self.Button_zhuSure:setVisible(false);
		self.Panel_sliderZhu:setVisible(false);
		self.Button_zhu5:setVisible(true);
	end
	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1]:HidePlayerTimer();
	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1]:ShowAction(4);
	local effectState = getEffectIsPlay();
	if effectState then
		audio.playSound("shidianban/sound/xiazhu.mp3");
	end
end

--玩家爆牌
function TableLayer:onBaoCard(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	--如果是自己爆牌则按钮置灰
	luaPrint("如果是自己爆牌则按钮置灰",msg.wChairID,self.tableLogic:getMySeatNo(),msg.byCardData,self.playerState[msg.wChairID+1])

	if msg.wChairID ~= self.tableLogic:getMySeatNo() and msg.byCardData>0 and self.playerState[msg.wChairID+1] then
		self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1]:SetFirstCard(msg.byCardData);
		self.playerCardNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1]:ShowCardSum();
	end
	-- self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1]:ShowAction();
end

--玩家抢庄
function TableLayer:onPlayerQiang(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;
	if msg.bQiang then
		self.qiangTable[msg.wChairID+1] = qzState.qiang;
	else
		self.qiangTable[msg.wChairID+1] = qzState.buqiang;
	end

	if msg.wChairID == self.tableLogic:getMySeatNo() then
		self.Node_qiangzhuang:setVisible(false);
	end
	self:ChangePlayerQaingState(self.tableLogic:logicToViewSeatNo(msg.wChairID),self.qiangTable[msg.wChairID+1]);
	self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wChairID)+1]:HidePlayerTimer();

	local effectState = getEffectIsPlay();
	if effectState and msg.bQiang then--播放抢庄的音效
		local effectPath = "shidianban/sound/";
		--获取性别
		local userInfo = self.tableLogic:getUserBySeatNo(msg.wChairID);
		if getUserSex(userInfo.bLogoID,userInfo.bBoy) then
			effectPath = effectPath.."man/";
		else
			effectPath = effectPath.."woman/";
		end
		audio.playSound(effectPath.."qiangzhuang.mp3");
	end

end

--开始抢庄
function TableLayer:onQiangBegin(data)
	self:ClearDeakInfo();

	local msg = data._usedata;

	self.Node_noAction:setVisible(false);

	self.Node_gameBtn:setVisible(false);
	--下注按钮初始化
	self.Node_zhuBtn:setVisible(false);
	self:UpdateUserMoney();--更新金币


	self.gameStart = true;--游戏开始

	if msg.byUserStatus[self.tableLogic:getMySeatNo()+1] then
		self.Node_qiangzhuang:setVisible(true);
	else
		self:ShowWaitingNext();
	end

	self:LoadPlayerState(msg.byUserStatus);

	self:ShowPlayerQiangState(true);

	self:SetInitQaingState();
	--设置抢庄倒计时
	for k,v in pairs(self.playerState) do
		if v then
			self.playerNode[self.tableLogic:logicToViewSeatNo(k-1)+1]:showPlayerTimer(5,5);
		end
	end
end

--放弃庄
function TableLayer:onGiveUpBank(data)
	local msg = data._usedata;

	if msg.wChairID == self.tableLogic:getMySeatNo() then
		self:SetGiveUpBankButton(msg.bGiveUp);
	end
end

--播放跑马灯动画
function TableLayer:onPlayBank(data)
	if self.gameStart == false then
		return;
	end
	local msg = data._usedata;

	self:ShowPlayerQiangState(false);

	for k,v in pairs(self.playerNode) do
		v:HidePlayerTimer();
	end

	local qzTable = {};
	--塞入抢庄的玩家的逻辑位置
	for k,v in pairs(self.qiangTable) do
		if v == 1 then
			table.insert(qzTable,k-1);
		end
	end
	luaDump(qzTable);
	--创建跑马灯
	local pPaomaBank = 0;
	for k,v in pairs(qzTable) do
		if v == msg.wBankerUser then
			break;
		end
		pPaomaBank = pPaomaBank+1;
	end
	local xunhuan = 1;
	local repeatTimes = 1.2/(pPaomaBank + #qzTable*xunhuan);
	luaPrint("repeatTimes",repeatTimes,pPaomaBank);
	while(repeatTimes > 0.15) do
		xunhuan = xunhuan+1;
		repeatTimes = 1.2/(pPaomaBank + #qzTable*xunhuan);
		luaPrint("repeatTimes while",repeatTimes);
	end
	local repeatCount = 0;
	self.Node_goldMove:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
		repeatCount = repeatCount+1;

		if pPaomaBank + #qzTable*xunhuan < repeatCount then--循环大于总循环 停止循环
			self.Node_goldMove:stopAllActions();
			local zhuangImage = cc.Sprite:createWithSpriteFrameName("sdb_zhuang.png");
			zhuangImage:setPosition(640,550);
			self.Node_goldMove:addChild(zhuangImage);
			--移动并且变小
			local zhuangPos = cc.p(self["Node_player"..self.tableLogic:logicToViewSeatNo(msg.wBankerUser)]:getPositionX()-52,
				self["Node_player"..self.tableLogic:logicToViewSeatNo(msg.wBankerUser)]:getPositionY()+70);
			zhuangImage:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.5,zhuangPos),cc.ScaleTo:create(0.5,0.3)),cc.CallFunc:create(function()
				self.playerNode[self.tableLogic:logicToViewSeatNo(msg.wBankerUser)+1]:SetPlayerBank(true);
				zhuangImage:setVisible(false);
				zhuangImage:removeFromParent();
			end)));
		else--如果小于总循环则播放跑马灯效果
			local effectState = getEffectIsPlay();
			if effectState then--播放跑马灯随机庄的音效
				audio.playSound("shidianban/sound/random_banker.mp3");
			end

			self.playerNode[self.tableLogic:logicToViewSeatNo(qzTable[repeatCount%#qzTable+1])+1]:PaomaAction(repeatTimes,pPaomaBank + #qzTable*xunhuan == repeatCount);
		end

	end),cc.DelayTime:create(repeatTimes))));

end

function TableLayer:onBegin()
	self:ClearDeakInfo();
	self:playZitiEffect(1);
	audio.playSound("shidianban/sound/StartGame.mp3");
end



----------------------------工具----------------------------
--获取牌的位置
function TableLayer:GetCardLastPos(viewSeat)
	local lastPos = self.playerCardNode[viewSeat+1]:GetLastCardPos();
	local cardNode = self["Node_player"..viewSeat]:getChildByName("Node_card");
	local card_worldPos = cc.p(cardNode:convertToWorldSpace(cc.p(0,0)));--转换世界坐标系
	--设置最后个点的位置
	return cc.p(self.Node_cardMove:convertToNodeSpace(cc.p(card_worldPos.x+lastPos.x,card_worldPos.y)));
end
--创建发牌动画
function TableLayer:SendCardAction(viewSeat,cardData,endPos)
	if self.gameStart == false then
		return;
	end

	local cardSpeed = 1800;
	local cardSp = CardSprite:create(0);--创建初始牌
	cardSp:setAnchorPoint(0,0);
	cardSp:setScale(0.2);
	local fapaiPos = cc.p(self.Node_cardMove:convertToNodeSpace(cc.p(self.Image_fapaiqi:getPosition())));
	cardSp:setPosition(fapaiPos);
	self.Node_cardMove:addChild(cardSp);
	self.playerCardNode[viewSeat+1]:AddCardData(cardData);

	local cardMoveLength = cc.pGetDistance(fapaiPos,endPos);

	local cardMove = cc.MoveTo:create(cardMoveLength/cardSpeed,endPos);
	local cardScale = cc.ScaleTo:create(cardMoveLength/cardSpeed,0.8);
	local callBack = cc.CallFunc:create(function()
		--动画完创建牌在cardlayer上
		cardSp:removeFromParent();
		local cardData = self.playerCardNode[viewSeat+1]:GetCardData();
		local cardVaule,cardType = GameLogic:GetCardType(cardData);
		self.playerCardNode[viewSeat+1]:DrawCard();
		if viewSeat == 0 then
			self.playerCardNode[1]:ShowCardSum();
			if #cardData > 1 then--要牌加倍时播放音效

				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
					self:PlayCardEffect(cardVaule,cardType);
				end
				)));

			end
		elseif cardType == GameLogic.Error then
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
					self:PlayCardEffect(cardVaule,cardType,self.tableLogic:viewToLogicSeatNo(viewSeat));
				end
			)));
		end
	end);
	--播放发牌音效
	local effectState = getEffectIsPlay();
	if effectState then
		audio.playSound("shidianban/sound/fapai.mp3");
	end

	--如果发的牌的数量大于2 将翻倍置灰
	if #self.playerCardNode[viewSeat+1]:GetCardData()>1 and viewSeat == 0 then
		self.Button_fanbei:setEnabled(false);
	end

	--判断10点半的话不能进行叫牌
	if viewSeat == 0 then
		local cardData = self.playerCardNode[1]:GetCardData();
		local cardVaule,cardType = GameLogic:GetCardType(cardData);
		if cardVaule == 10.5 then
			self.Button_jiaopai:setEnabled(false);
		end
	end 


	cardSp:runAction(cc.Sequence:create(cc.Spawn:create(cardMove,cardScale),callBack));
end
--第一次发牌从庄家下家开始发牌
function TableLayer:FirstSendCard(cardData)
	if self.gameStart == false then
		return;
	end
	local sendData = {};
	for i = 1,GameMsg.GAME_PLAYER do--从庄家开始遍历每个玩家
		local playerSeat = self.bankStation+i;
		if playerSeat>GameMsg.GAME_PLAYER-1 then
			playerSeat = playerSeat-GameMsg.GAME_PLAYER;
		end

		if cardData[playerSeat+1] ~= GameMsg.INVALID_CHAIR and self.playerState[playerSeat+1] then
			local playerData = {};--将座位号和牌值对应塞入
			playerData.realSeat = playerSeat;
			playerData.cardData = cardData[playerSeat+1];
			table.insert(sendData,playerData);
		end
	end


	for k,v in pairs(sendData) do
		-- local delayTime = cc.DelayTime:create(0.4*(k-1));
		-- local callBack = cc.CallFunc:create(function()
		-- 	local viewSeat = self.tableLogic:logicToViewSeatNo(v.realSeat);
		-- 	self:SendCardAction(viewSeat,v.cardData,self:GetCardLastPos(viewSeat));
		-- end);

		-- self:runAction(cc.Sequence:create(delayTime,callBack));--延迟发牌动画创建
		local viewSeat = self.tableLogic:logicToViewSeatNo(v.realSeat);
		self:SendCardAction(viewSeat,v.cardData,self:GetCardLastPos(viewSeat));
	end

end
--设置玩家状态
function TableLayer:LoadPlayerState(state)
	local playerState = {false,false,false,false,false};
	if state then
		playerState = state;
	end

	--初始化玩家状态
	for i = 1,GameMsg.GAME_PLAYER do
		self.playerState[i] = playerState[i];
	end
end
--播放牌的音效
function TableLayer:PlayCardEffect(cardVaule,cardType,realSeat)
	local effectState = getEffectIsPlay();
	if effectState == false then
		return
	end

	-- audio.stopAllSounds();

	local userInfo;

	if realSeat then
		userInfo = self.tableLogic:getUserBySeatNo(realSeat);
	else
		local mySeatNo = self.tableLogic:getMySeatNo();
		userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	end

	if userInfo == nil then
		return;
	end

	local effectPath = "shidianban/sound/";
	--获取性别
	if getUserSex(userInfo.bLogoID,userInfo.bBoy) then
		effectPath = effectPath.."man/";
	else
		effectPath = effectPath.."woman/";
	end

	if cardType == GameLogic.Error then
		audio.playSound(effectPath.."baodian.mp3");
	elseif cardType == GameLogic.TianWang then
		audio.playSound(effectPath.."tw.mp3");
	elseif cardType == GameLogic.RenWuXiao then
		audio.playSound(effectPath.."rwx.mp3");
	elseif cardType == GameLogic.WuXiao then
		audio.playSound(effectPath.."wx.mp3");
	else
		audio.playSound(effectPath..cardVaule..".mp3");
	end
end

--播放操作的音效
function TableLayer:PlayOperateEffect(realSeat,operate)
	local effectState = getEffectIsPlay();
	if effectState == false then
		return
	end

	local userInfo = self.tableLogic:getUserBySeatNo(realSeat);
	if userInfo == nil then
		return;
	end

	-- audio.stopAllSounds();

	local effectPath = "shidianban/sound/";
	--获取性别
	if getUserSex(userInfo.bLogoID,userInfo.bBoy) then
		effectPath = effectPath.."man/";
	else
		effectPath = effectPath.."woman/";
	end

	if operate == 1 then--要牌
		effectPath = effectPath.."get_card.wav";
	elseif operate == 2 then--停牌
		effectPath = effectPath.."stop_card.wav";
	elseif operate == 3 then--翻倍
		effectPath = effectPath.."double.wav";
	end

	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
			audio.playSound(effectPath);
		end
	)));
	
end

--设置筹码按钮上的下注额
function TableLayer:SetPlayerChipNum()
	self["Button_zhu1"]:getChildByName("AtlasLabel_num"):setString(self:ScoreToMoney(math.floor(self.lCellScore/20)));

	self["Button_zhu2"]:getChildByName("AtlasLabel_num"):setString(self:ScoreToMoney(math.floor(self.lCellScore/30)));

	self["Button_zhu3"]:getChildByName("AtlasLabel_num"):setString(self:ScoreToMoney(math.floor(self.lCellScore/40)));

	self["Button_zhu4"]:getChildByName("AtlasLabel_num"):setString(self:ScoreToMoney(math.floor(self.lCellScore/50)));

end
--设置筹码
function TableLayer:SetPlayerZhuMoney(viewSeat,money)
	local Text_chouma = self["Node_player"..viewSeat]:getChildByName("Node_chouma"):getChildByName("Text_chouma");
	Text_chouma:setTag(0);
	if money then
		Text_chouma:setString(self:ScoreToMoney(money));
		Text_chouma:setTag(money);
	else
		Text_chouma:setString("0.00");
	end
end
--玩家加倍
function TableLayer:PlayerMoneyAdd(viewSeat)
	local Text_chouma = self["Node_player"..viewSeat]:getChildByName("Node_chouma"):getChildByName("Text_chouma");
    local money = tonumber(Text_chouma:getTag());
    if money then
        Text_chouma:setString(self:ScoreToMoney(money*2));
        local playerNode = self.playerNode[viewSeat+1];
		playerNode:SetPlayerMoney(playerNode:GetPlayerMoney()-money);
		Text_chouma:setTag(money*2);
    end
end

--玩家分数
function TableLayer:ScoreToMoney(score)
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
    return (score/100)..remainderString;
end
--设置下注按钮能否点击
function TableLayer:SetZhuBtnEnable(isEnable)
	for i = 1,5 do
		self["Button_zhu"..i]:setEnabled(isEnable);
		if i~=5 then
			local buttonZi = self["Button_zhu"..i]:getChildByName("AtlasLabel_num");
			if isEnable then
				buttonZi:setProperty("","shidianban/number/sdb_anniuzi.png",23,34,'+');
			else
				buttonZi:setProperty("","shidianban/number/sdb_anniuzi-b.png",23,34,'+');
			end
		end
	end
	self:SetPlayerChipNum();
end

--显示等待其他玩家
function TableLayer:ShowWaitingOther()
	self:RemoveWaiting();

	local skeleton_animation = createSkeletonAnimation(WaitAnim.name,WaitAnim.json,WaitAnim.atlas);
	if skeleton_animation then
		self.Node_playerAction:addChild(skeleton_animation);
		skeleton_animation:setAnimation(0,WaitAnimName, true);
		skeleton_animation:setName(WaitAnim.name);
	end
end

--去除等待其他玩家
function TableLayer:RemoveWaiting()
	local waitAnim = self.Node_playerAction:getChildByName(WaitAnim.name);
	if waitAnim then
		waitAnim:removeFromParent();
	end
end
--显示等待下一局
function TableLayer:ShowWaitingNext()
	self:RemoveWaiting();

	local skeleton_animation = createSkeletonAnimation(WaitAnim.name,WaitAnim.json,WaitAnim.atlas);
	if skeleton_animation then
		self.Node_playerAction:addChild(skeleton_animation);
		skeleton_animation:setAnimation(0,WaitNextAnimName, true);
		skeleton_animation:setName(WaitAnim.name);
	end
end

--获取玩家数量
function TableLayer:GetUserNum()
	local userCount = 0;

	for i = 0,GameMsg.GAME_PLAYER-1 do
		local userInfo = self.tableLogic:getUserBySeatNo(i);
		if userInfo then
			userCount = userCount+1;
		end
	end
	return userCount
end

--创建输赢玩家金币移动 玩家输赢
function TableLayer:GoldMoveAction(viewSeat,isWin)
	--默认是赢 最终飞到玩家

	local playerNodePos = self.Node_goldMove:convertToNodeSpace(self["Node_player"..viewSeat]:convertToWorldSpace(cc.p(0,0)));
	local bankNodePos = self.Node_goldMove:convertToNodeSpace(cc.p(self["Node_player"..self.tableLogic:logicToViewSeatNo(self.bankStation)]:convertToWorldSpace(cc.p(0,0))));

	local beginPos = bankNodePos;
	local endPos = playerNodePos;

	if isWin == false then
		beginPos = playerNodePos;
		endPos = bankNodePos;
	end

	-- for i = 1,8 do
	-- 	local coin = ChipNodeManager.new(self);
	-- 	coin:ChipCreate(beginPos,endPos);
	-- end

	for i=1,8 do
		self:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*0.1),cc.CallFunc:create(function() 
			local coin = ChipNodeManager.new(self);
			coin:ChipCreate(beginPos,endPos);
		end)))
	end

end
--下注的底动画
function TableLayer:ZhuNodeAction()
	self.Node_zhuBtn:stopAllActions();
	local beginNode = cc.p(self.Node_zhuBtn:getPositionX(),-140);
	self.Node_zhuBtn:setPosition(beginNode);

	self.Node_zhuBtn:runAction(cc.MoveTo:create(0.2,cc.p(0,0)));
end

--操作的底动画
function TableLayer:GameNodeAction()
	self.Node_gameBtn:stopAllActions();
	local beginNode = cc.p(self.Node_gameBtn:getPositionX(),-120);
	self.Node_gameBtn:setPosition(beginNode);

	self.Node_gameBtn:runAction(cc.MoveTo:create(0.2,cc.p(0,0)));
end

--更改玩家抢庄状态
function TableLayer:ChangePlayerQaingState(viewSeat,qiangState)
	display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
	local Image_qzState = self["Node_player"..viewSeat]:getChildByName("Image_qzState");
	Image_qzState:setVisible(true);
	Image_qzState:ignoreContentAdaptWithSize(true);
	if qiangState == qzState.sikao then
		Image_qzState:loadTexture("sdb_sikaozhong_text.png",UI_TEX_TYPE_PLIST);
	elseif qiangState == qzState.buqiang then
		Image_qzState:loadTexture("sdb_buqiang_text.png",UI_TEX_TYPE_PLIST);
	elseif qiangState == qzState.qiang then			
		Image_qzState:loadTexture("sdb_qiangzhuang_text.png",UI_TEX_TYPE_PLIST);
	end
end
--隐藏和显示所有玩家的抢庄状态
function TableLayer:ShowPlayerQiangState(isShow)
	if isShow then
		for i = 0,GameMsg.GAME_PLAYER-1 do
			local realSeat = self.tableLogic:viewToLogicSeatNo(i);
			if self.playerState[realSeat+1] then
				local Image_qzState = self["Node_player"..i]:getChildByName("Image_qzState");
				Image_qzState:setVisible(true);
			end
		end
	else
		for i = 0,GameMsg.GAME_PLAYER-1 do
			local Image_qzState = self["Node_player"..i]:getChildByName("Image_qzState");
			Image_qzState:setVisible(false);
		end
	end
end
--显示玩家抢庄为初始值
function TableLayer:SetInitQaingState()
	for i = 0,GameMsg.GAME_PLAYER-1 do
		local realSeat = self.tableLogic:viewToLogicSeatNo(i);
		if self.playerState[realSeat+1] then
			self:ChangePlayerQaingState(i,qzState.sikao);
		end
	end
end

return TableLayer;