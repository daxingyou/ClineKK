local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("yaoyiyao.TableLogic");
local GameAction = require("yaoyiyao.GameAction");
local GameRuleLayer = require("yaoyiyao.GameRuleLayer");
local DiceConfig = require("yaoyiyao.DiceConfig");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

--倒计时警告动画
local WarnAnimName = "daojishi";
local WarnAnim = {
	name = "daojishi",
	json = "hall/game/daojishi/daojishi.json",
	atlas = "hall/game/daojishi/daojishi.atlas",
};

local villageState = {
	zUserStatus_Null = 0,		--//空闲状态
	zStatus_IsZhuang = 1,		--//坐庄状态
	zUserStatus_InList = 2,		--//申请上庄状态
	zStatus_XiaZhuang = 3,		--//申请下庄状态

};


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
	DiceInfo:init();

	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/chip/chip.plist");
	display.loadSpriteFrames("yaoyiyao/yaoyiyao.plist","yaoyiyao/yaoyiyao.png");
	local uiTable = {
		--背景图
		Image_bg = "Image_bg",
		Node_chipNode = "Node_chipNode",
		Panel_gameBg = "Panel_gameBg",
		--投资钱
		Button_score1 = "Button_score1",
		Button_score2 = "Button_score2",
		Button_score3 = "Button_score3",
		Button_score4 = "Button_score4",
		Button_score5 = "Button_score5",
		Button_score6 = "Button_score6",
		--下拉菜单
		Button_otherButton = "Button_otherButton",
		--上庄
		Button_village = "Button_village",
		-- --规则
		-- Button_rule = "Button_rule",
		-- --保险箱
		-- Button_insurance = "Button_insurance",
		--续投
		Button_throw  = "Button_throw",
		-- --其余按钮下拉
		-- Image_otherBtnBg = "Image_otherBtnBg",
		--返回
		Button_back = {"Button_back",0,1},
		-- --音效
		-- Button_effect = "Button_effect",
		-- --音乐
		-- Button_music = "Button_music",
		--下注倒计时
		AtlasLabel_clock = "AtlasLabel_clock",
		--庄家名字
		Text_BankName = "Text_BankName",
		--庄家金币
		Text_BankMoney = "Text_BankMoney",
		--提示下局开始
		Text_tipNextGame = "Text_tipNextGame",
		--用户列表底
		Panel_usrList = "Panel_usrList",
		--用户列表信息
		Panel_userInfo = "Panel_userInfo",
		--历史信息区域
		Panel_result = "Panel_result",
		--历史信息
		Panel_resultInfo = "Panel_resultInfo",
		--用户数量
		Text_userNum = "Text_userNum",
		--其他玩家按钮
		Button_otherUser = "Button_otherUser",
		--玩家名字和金币
		Text_playerName = "Text_playerName",
		Text_playerMoney = "Text_playerMoney",
		Text_playerChange = "Text_playerChange",
		Text_bankMoneyChange =  "Text_bankMoneyChange",
		Text_otherPlayerChange = "Text_otherPlayerChange",
		--游戏状态
		Image_gameState = "Image_gameState",
		--动画节点
		Node_startAnimate = "Node_startAnimate",
		--换庄提示
		Image_bankChange = "Image_bankChange",
		--连庄
		Node_successive = "Node_successive",
		AtlasLabel_successive = "AtlasLabel_successive",
		--上庄的人数
		Text_personNum = "Text_personNum",
		Image_stopBet = "Image_stopBet",
		--投币区节点
		Node_castArea = "Node_castArea",
		--隐藏筹码按钮
		Button_hideChip = "Button_hideChip",

		AtlasLabel_da = "AtlasLabel_da",
		AtlasLabel_xiao = "AtlasLabel_xiao",
		AtlasLabel_bao = "AtlasLabel_bao",

		Node_bankInfo = "Node_bankInfo",
		Image_xitong = "Image_xitong",

		--上庄列表
		Button_szList = "Button_szList",
		Image_szList = "Image_szList",
		Panel_szList = "Panel_szList",
		ListView_szList = "ListView_szList",
	}

	self:initData();

	loadNewCsb(self,"yaoyiyao/GameScene",uiTable);

	local framesize = cc.Director:getInstance():getWinSize()
	local addWidth = (framesize.width - 1280)/2;

		self.Button_otherButton:setPositionX(self.Button_otherButton:getPositionX() + addWidth*2-10)
		-- self.Button_otherUser:setPositionX(self.Button_otherUser:getPositionX() - addWidth)

	if globalUnit.isShowZJ then
        self.Image_otherBtnBg = self.Button_otherButton:getChildByName("Image_otherBtnBg1");
        self.Button_zhanji = self.Image_otherBtnBg:getChildByName("Button_zhanji");
    else
        self.Image_otherBtnBg = self.Button_otherButton:getChildByName("Image_otherBtnBg0");
    end
	
    self.Button_insurance = self.Image_otherBtnBg:getChildByName("Button_insurance");
    self.Button_rule = self.Image_otherBtnBg:getChildByName("Button_rule");
    self.Button_music = self.Image_otherBtnBg:getChildByName("Button_music");
    self.Button_effect = self.Image_otherBtnBg:getChildByName("Button_effect");

	self:initUI();

	_instance = self;
end
--进入
function TableLayer:onEnter()
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
	self:pushEventInfo(DiceInfo,"BankState",handler(self, self.BankStateInfoGame));
	self:pushEventInfo(DiceInfo,"PutChip",handler(self, self.PutChipInfoGame));
	self:pushEventInfo(DiceInfo,"DiceGameStart",handler(self, self.DiceGameStartInfo));
	self:pushEventInfo(DiceInfo,"GameAnimate",handler(self, self.GameAnimateInfo));
	self:pushEventInfo(DiceInfo,"ResultMessage",handler(self, self.ResultMessageInfo));
	self:pushEventInfo(DiceInfo,"ErrorCode",handler(self, self.DealErrorCode));
	self:pushEventInfo(DiceInfo,"NoBankWait",handler(self, self.DealNoBankWait));
	self:pushEventInfo(DiceInfo,"NoteBack",handler(self, self.DealNoteBack));
	self:pushEventInfo(DiceInfo,"ZhuangScore",handler(self, self.DealZhuangScore));
	self:pushEventInfo(DiceInfo,"XuTOU",handler(self, self.DealXuTOU));

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

--获取其他用户的信息
function TableLayer:getOthersTable()
    local othersTable = {};
    for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
            table.insert(othersTable,userInfo)
        end
    end
    return othersTable;
end

--添加用户
function TableLayer:addUser(deskStation, bMe)
    if not self:isValidSeat(deskStation) then 
        return;
    end

    self:UpdateUserList();

    if bMe then
	    local mySeatNo = self.tableLogic:getMySeatNo();
	    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	    if userInfo then
		    self.Text_playerName:setText(FormotGameNickName(userInfo.nickName,nickNameLen));
		    self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
		    self.playerMoney = clone(userInfo.i64Money);
		end
	    self:ChipJundge();
	end

end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
    
    if not self:isValidSeat(seatNo) then 
        return;
    end

    self:UpdateUserList();

    local BackCallBack = function()
        local func = function()
            self.tableLogic:sendUserUp();
            self.tableLogic:sendForceQuit();
        end

        Hall:exitGame(false,func)   
    end

    if bIsMe then
		-- local func = function()
		-- 	self.tableLogic:sendUserUp();
		-- 	self.tableLogic:sendForceQuit();
		-- end
		-- Hall:exitGame(false,func);

		local str = ""
	    if bLock == 3 then
			str ="长时间未操作,自动退出游戏。";
			BackCallBack();
      	elseif bLock == 0 then
      		BackCallBack();
	    elseif bLock == 1 then
			str ="您的金币不足,自动退出游戏。";
			showBuyTip(true);
	    elseif bLock == 2 then
			str ="您被厅主踢出VIP厅,自动退出游戏。";
			BackCallBack();
		elseif bLock == 5 then
			str ="VIP房间已关闭,自动退出游戏。";
			BackCallBack();
	    end

	    if str ~= "" then
			addScrollMessage(str);
		end
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

		--new 打开 gongfu关闭
		-- RoomLogic:close();
		
		self._bLeaveDesk = true;
		_instance = nil;
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
	else
		-- self.gameStart = false;
		-- self:ClickBackCallBack();
	end
end
-------------------------------------------------------------------------------------
--初始化数据
function TableLayer:initData()	
	self.m_iHeartCount = 0;--心跳计数
	self.m_maxHeartCount = 3;--最大心跳计数
	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

	self.buttonCast = {};

	self.actonFinish = true;--其他按钮伸缩动画标志
	self.chipSaveTable = {};--保存筹码
	for k,v in pairs(DiceConfig) do
		local i = v+1;
		self.chipSaveTable[i] = {};
	end

	self.villageMoney = 5000000;--上庄所需要的钱
	self.xiaZhuangMoney = 4000000;--下庄条件
	self.gameBet = false;--下注状态
	self.gameStart = false;--游戏开始状态
	self.bankStation = -1;--是否为庄家

	self.selfAreaSave = {};--保存自己所选择的区域
	for k,v in pairs(DiceConfig) do
		local i = v+1;
		self.selfAreaSave[i] = {};
	end

	self.gameBtnTableView = nil;
	self.resultTableView = nil;
	--保存其他玩家信息
	self.saveOtherInfo = {};
	--保存历史信息
	self.gameHistoryList = {};
	--保存玩家金币
	self.playerMoney = 0;
	--缓存筹码信息
	self.savePutChipMsg = {};
	--玩家是否下过注
	self.pourChip = false;
	--是否系统坐庄
	self.bEnableSysBanker = false;
	--不操作的局数
	self.mOperateGameCount = 0;
end
--初始化界面
function TableLayer:initUI()
	--基本按钮
	self:initGameNormalBtn();
	--加载初始化场景
	self:LoadGameScene();

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	self.Button_hideChip:setVisible(false);
	local size = cc.p(self.Button_otherButton:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("yaoyiyao",self);
    self.csbNode:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(size.x-100,size.y-20);
    self.Button_otherButton:setLocalZOrder(10);
    
    if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self);
	    self:addChild(self.m_logBar);
	end
end
--初始化按钮
function TableLayer:initGameNormalBtn()
	--投钱区
	for k,v in pairs(DiceConfig) do
		local castButton = self.Node_castArea:getChildByName("Button_cast"..v);
		self.buttonCast[v] = castButton;
		castButton:setTag(v);
		castButton:addTouchEventListener(handler(self, self.ClickCastCallBack));
		--所有下注的总额的数字
		local imageXiazhu = castButton:getChildByName("Image_xiazhu");
		local imageXiazhuSize = imageXiazhu:getContentSize();
		local moneySum = FontConfig.createWithCharMap("", "yaoyiyao/number/zi-zhu.png", 10, 17, "+");
		moneySum:setPosition(imageXiazhuSize.width/2,imageXiazhuSize.height/2);
		moneySum:setName("Text_moneySum");
		imageXiazhu:addChild(moneySum);
		--自己下注总额的数字
		local imageMyXiazhu = castButton:getChildByName("Image_myxiazhu");
		local imageMyXiazhuSize = imageMyXiazhu:getContentSize();
		local mySum = FontConfig.createWithCharMap("", "yaoyiyao/number/zi-zhu2.png", 10, 17, "+");
		mySum:setPosition(imageMyXiazhuSize.width/2,imageMyXiazhuSize.height/2);
		mySum:setName("Text_myMoney");
		imageMyXiazhu:addChild(mySum);
	end

	--投资钱的数额
	for i = 1,6 do
		if self["Button_score"..i] then
			self["Button_score"..i]:setTag(i);
			self["Button_score"..i]:setLocalZOrder(10);
			self["Button_score"..i]:addClickEventListener(function(sender) 
				local effectState = getEffectIsPlay();
				if effectState then
					audio.playSound("yaoyiyao/sound/sound-jetton.mp3");
				end

				self:ClickScoreCallBack(sender); 
			end);
		end
	end
	--下拉菜单
	if self.Button_otherButton then
		self.Button_otherButton:addClickEventListener(function(sender)
			self:ClickOtherButtonCallBack(sender);
		end);
		-- self.Button_otherButton:onClick(handler(self,self.ClickOtherButtonCallBack))
		self.Button_otherButton:setTag(0);
	end
	--上庄
	if self.Button_village then
		-- self.Button_village:addClickEventListener(function(sender)
		-- 	self:ClickVillageCallBack(sender);
		-- end)
		self.Button_village:onClick(handler(self,self.ClickVillageCallBack))
		self.Button_village:setTag(0);
	end

	--隐藏筹码
	if self.Button_hideChip then
		self.Button_hideChip:setTag(0);--松开按钮为0
		self.Button_hideChip:addTouchEventListener(handler(self, self.HideChipTouchCallBack))
	end
	--规则
	if self.Button_rule then
		self.Button_rule:addClickEventListener(function(sender)
			self:ClickRuleCallBack(sender);
		end)
	end
	--保险箱
	if self.Button_insurance then
		self.Button_insurance:addClickEventListener(function(sender)
			self:ClickInsuranceCallBack(sender);
		end)
	end
	--续投
	if self.Button_throw then
		self.Button_throw:setEnabled(false);
		self.Button_throw:addClickEventListener(function(sender)
			self:ClickThrowCallBack(sender);
		end)
	end
	--返回
	if self.Button_back then
		-- self.Button_back:addClickEventListener(function(sender)
		-- 	self:ClickBackCallBack(sender);
		-- end)
		self.Button_back:onClick(handler(self,self.ClickBackCallBack))
	end
	--音效
	if self.Button_effect then
		self.Button_effect:addClickEventListener(function(sender)
			self:ClickEffectCallBack(sender);
		end)
	end
	--音乐
	if self.Button_music then
		self.Button_music:addClickEventListener(function(sender)
			self:ClickMusicCallBack(sender);
		end)
	end
	--其他玩家
	if self.Button_otherUser then
		self.Button_otherUser:setTag(0);
		self.Button_otherUser:setLocalZOrder(10);
		self.Button_otherUser:addClickEventListener(function(sender)
			self:ClickOtherUserCallBack(sender);
		end)
	end

	--战绩
	if self.Button_zhanji then
		self.Button_zhanji:onClick(function(sender)
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end)
	end

	--上庄列表
	if self.Button_szList then
		self.Button_szList:onClick(function(sender)
			self.Image_szList:setVisible(not self.Image_szList:isVisible());
		end)
	end
	self.ListView_szList:setScrollBarEnabled(false);
end

--投钱区按钮回调
function TableLayer:ClickCastCallBack(sender,eventType)
	local senderTag = sender:getTag();
	--如果在等待下局开始和自己是庄家时则返回
	if self.gameBet == false then
		return;
	end

	local chipType = 0;
	for i = 1,6 do
		if self["Button_score"..i].selectTag == 1 then
			chipType = i;
			break;
		end
	end

	if eventType == ccui.TouchEventType.began then
		self.buttonCast[senderTag]:getChildByName("Image_click"):setVisible(true);
	elseif eventType == ccui.TouchEventType.moved then
		
    elseif eventType == ccui.TouchEventType.ended then
    	luaPrint("投钱区按钮回调",senderTag,chipType);
		self.buttonCast[senderTag]:getChildByName("Image_click"):setVisible(false);
		
		if self.bankStation == self.tableLogic:getMySeatNo() then
			self:TipTextShow("庄家不能下注！");
			return;
		end

		if chipType == 0 and self.pourChip then
			self:TipTextShow("金币不足,下注失败");
			showBuyTip();
			return;
		end

    	local throwState = self:JudgeSelfThrow(self:ChipTypeToChipMoney(chipType),senderTag,chipType);
		if throwState then
			-- self:RememberChipThrow(chipType,senderTag);
		end
	elseif eventType == ccui.TouchEventType.canceled then
		self.buttonCast[senderTag]:getChildByName("Image_click"):setVisible(false);
    end

end
--隐藏筹码
function TableLayer:HideChipTouchCallBack(sender,eventType)
	if self.gameBet == false then
		return;
	end

	if eventType == ccui.TouchEventType.began then--按住按钮隐藏筹码
		sender:setTag(1);
		for k,v in pairs(self.chipSaveTable) do
			for k1,v1 in pairs(v) do
				v1:setVisible(false);
			end
		end
	elseif eventType == ccui.TouchEventType.moved then
		
    elseif eventType == ccui.TouchEventType.ended then--松开按钮显示筹码
		sender:setTag(0);
    	for k,v in pairs(self.chipSaveTable) do
			for k1,v1 in pairs(v) do
				v1:setVisible(true);
			end
		end
	elseif eventType == ccui.TouchEventType.canceled then
		sender:setTag(0);
		for k,v in pairs(self.chipSaveTable) do
			for k1,v1 in pairs(v) do
				v1:setVisible(true);
			end
		end
    end

end

--投资钱的数额按钮回调
function TableLayer:ClickScoreCallBack(sender)
	local senderTag = sender:getTag();
	luaPrint("投资钱的数额按钮回调",senderTag);
	self:ChooseChip(senderTag);
end
--下拉菜单
function TableLayer:ClickOtherButtonCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
    --重新设置纹理
    if globalUnit.isShowZJ then
    	self.Image_otherBtnBg:loadTexture("yyy_zhanji.png");
    	local image1 = self.Button_zhanji:getChildByName("Image_zhanji1");
    	image1:loadTexture("yyy_zhanjisp.png");
    	local image2 = self.Button_zhanji:getChildByName("Image_zhanji2");
    	image2:loadTexture("yyy_zhanjitext.png");
    else
    	self.Image_otherBtnBg:loadTexture("yyy_setdi.png",UI_TEX_TYPE_PLIST);
    end
    self:InitSet();

	local senderTag = sender:getTag();

	self.actonFinish = false;--将标志位置成false
	local actionTime = 0.6;
	local moveAction;

	if senderTag == 0 then--下拉
		sender:setTag(1);
		sender:loadTextures("yyy_shouna1.png","yyy_shouna1.png","yyy_shouna1.png",UI_TEX_TYPE_PLIST);
		moveAction = cc.MoveTo:create(actionTime,cc.p(self.Image_otherBtnBg:getPositionX(),83-self.Image_otherBtnBg:getContentSize().height-88));
	else--上拉
		sender:setTag(0);
		sender:loadTextures("yyy_shouna.png","yyy_shouna.png","yyy_shouna.png",UI_TEX_TYPE_PLIST);
		moveAction = cc.MoveTo:create(actionTime,cc.p(self.Image_otherBtnBg:getPositionX(),83));
	end
	self.Image_otherBtnBg:runAction(cc.Sequence:create(moveAction,cc.CallFunc:create(function()
		self.actonFinish = true;
	end)));
end
--上庄
function TableLayer:ClickVillageCallBack(sender)
	local senderTag = sender:getTag();
	if senderTag == 0 then
		if self.playerMoney < self.villageMoney then
			addScrollMessage("金币不足"..(math.floor(self.villageMoney/100)).."，不能上庄");
			showBuyTip();
			return;
		end

		self.tableLogic:sendBankerState(true,false);--申请上庄
	elseif senderTag == 1 then
		self.tableLogic:sendBankerState(true,true);--取消上庄
	elseif senderTag == 2 then--申请下庄
		self.tableLogic:sendBankerState(false,false);
	else--取消下庄
		self.tableLogic:sendBankerState(false,true);
	end 
end
--规则
function TableLayer:ClickRuleCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	local layer = GameRuleLayer:create();
	self:addChild(layer,1000);
end
--保险箱
function TableLayer:ClickInsuranceCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	if (self.gameBet == false and self.gameStart == true or self.gameStart == false) and not isHaveBankLayer() then--开奖状态不弹保险箱
		addScrollMessage("游戏开奖中，请稍后进行取款操作。");
		return;
	end

	createBank(function(data)
		self:DealBankInfo(data);
	end,true);
end
--调用保险箱函数
function TableLayer:DealBankInfo(data)
	self.playerMoney = self.playerMoney + data.OperatScore;
	self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
	if self.bankStation == self.tableLogic:getMySeatNo() then
		self:ScoreToMoney(self.Text_BankMoney,self.playerMoney);
	end

	self:UpdateThrowBtn();
end

--判断续投亮起函数
function TableLayer:UpdateThrowBtn()
	--判断取完钱是否能续投
	if self.Button_throw.selfAreaSave == nil then
		return;
	end

	local needMoney = 0;
	for k,v in pairs(self.Button_throw.selfAreaSave) do
		if #v>0 then
			for k1,v1 in pairs(v) do
				needMoney = needMoney + self:ChipTypeToChipMoney(v1);
			end
		end
	end

	if needMoney > 0 and needMoney <= self.playerMoney and self.pourChip == false and self.bankStation ~= self.tableLogic:getMySeatNo() then
		self.Button_throw:setEnabled(true);
	else
		self.Button_throw:setEnabled(false);
	end
end

--续投
function TableLayer:ClickThrowCallBack(sender)
	if sender.selfAreaSave == nil or self.bankStation == self.tableLogic:getMySeatNo() then
		return;
	end

	local needMoney = 0;
	for k,v in pairs(sender.selfAreaSave) do
		if #v>0 then
			for k1,v1 in pairs(v) do
				needMoney = needMoney + self:ChipTypeToChipMoney(v1);
			end
		end
	end

	if needMoney <= self.playerMoney then
		local allMoney = {};
		for k,v in pairs(sender.selfAreaSave) do
			if #v>0 then
				local money = 0;
				for k1,v1 in pairs(v) do
					--没有数据返回 有数据则发送下注消息
					-- self:JudgeSelfThrow(self:ChipTypeToChipMoney(v1),k-1,v1);
					money = money+self:ChipTypeToChipMoney(v1);
				end
				allMoney[k] = money;
			end
		end

		self.tableLogic:sendXuTouMsg(allMoney);
	else
		addScrollMessage("金币不足");
	end
end
--返回
function TableLayer:ClickBackCallBack(sender)
	if self.bankStation == self.tableLogic:getMySeatNo() then
		addScrollMessage("庄家不能离开房间");
		return;
	end

	if self.pourChip then
		addScrollMessage("本局游戏您已参与，请等待开奖阶段结束。");
		return;
	end


	-- Hall:exitGame();
	local func = function()
		self.tableLogic:sendUserUp();
		self.tableLogic:sendForceQuit();
	end
	Hall:exitGame(false,func);
end
--音效
function TableLayer:ClickEffectCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	local effectState = getEffectIsPlay();
	local effectSp = self.Button_effect:getChildByName("Image_effect1");
	luaPrint("音效",effectState);
	if effectState then--开着音效
		setEffectIsPlay(false);
		--改变音效图片
		effectSp:loadTexture("yyy_yinxiao-off.png",UI_TEX_TYPE_PLIST);
	else
		setEffectIsPlay(true);
		effectSp:loadTexture("yyy_yinxiao.png",UI_TEX_TYPE_PLIST);
	end

end
--音乐
function TableLayer:ClickMusicCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	local musicState = getMusicIsPlay();
	local musicSp = self.Button_music:getChildByName("Image_music1");
	self.Button_music:getChildByName("Image_music2"):loadTexture("yyy_yinyuezi.png",UI_TEX_TYPE_PLIST);
	luaPrint("音乐",musicState);
	if musicState then--开着音效
		setMusicIsPlay(false);
		musicSp:loadTexture("yyy_yinyue-off.png",UI_TEX_TYPE_PLIST);
	else
		setMusicIsPlay(true);
		musicSp:loadTexture("yyy_yinyue.png",UI_TEX_TYPE_PLIST);	
	end
	self:InitMusic();
end
--显示其他玩家
function TableLayer:ClickOtherUserCallBack(sender)
	local senderTag = sender:getTag();
	if senderTag == 0 then
		self.Panel_usrList:setVisible(true);
		sender:setTag(1);
		if self.gameBtnTableView then
			self:CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, self.Panel_userInfo:getContentSize(), true);
		end
	else
		self.Panel_usrList:setVisible(false);
		sender:setTag(0);
	end
end

--加载初始化消息
function TableLayer:LoadGameScene()
    --设置倒计时动画
    self.AtlasLabel_clock:setTag(0);

    local action1 = cc.DelayTime:create(1.0);
    local action2 = cc.CallFunc:create( function()
        if self.AtlasLabel_clock:getTag() > 0 then
            local clockTag = self.AtlasLabel_clock:getTag()-1;
            self.AtlasLabel_clock:setString(clockTag);
            self.AtlasLabel_clock:setTag(clockTag);

            if self.gameBet and clockTag == 3 then--如果是下注状态最后几秒显示动画
            	local skeleton_animation = createSkeletonAnimation(WarnAnim.name,WarnAnim.json,WarnAnim.atlas);
            	if skeleton_animation then
		        	self.Node_startAnimate:addChild(skeleton_animation);
		        	skeleton_animation:setScale(1.5);
		        	skeleton_animation:setAnimation(0,WarnAnimName, false);        	
		        	skeleton_animation:setPosition(640,360);
		        	skeleton_animation:setName(WarnAnimName);
		        end

	        	local function actionEnd()
					self.Node_startAnimate:removeChildByName(WarnAnimName);
					self.Image_stopBet:setVisible(false);
	        	end
				local effectState = getEffectIsPlay();
	        	self.Node_startAnimate:runAction(cc.Sequence:create(
					cc.DelayTime:create(0),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end
        				if effectState then
        					audio.playSound("yaoyiyao/sound/sound-clock-count.mp3");
        				end
		        	end),
					cc.DelayTime:create(1),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end
	        			if effectState then
        					audio.playSound("yaoyiyao/sound/sound-clock-count.mp3");
        				end
		        	end),
					cc.DelayTime:create(1),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end
	        			if effectState then
        					audio.playSound("yaoyiyao/sound/sound-clock-count.mp3");
        				end
		        	end),cc.DelayTime:create(1),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end

		        		self:playZitiEffect(4);
		        		if effectState then
		        			audio.playSound("yaoyiyao/sound/sound-end-wager.mp3");
		        		end
		        	end)))
        	elseif self.gameBet and clockTag == 0 then
        		local effectState = getEffectIsPlay();
        		self:playZitiEffect(4);
        		if effectState then
        			audio.playSound("yaoyiyao/sound/sound-end-wager.mp3");
        		end
        	end
        end
    end);

    self.AtlasLabel_clock:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)));

    --1秒将缓存筹码信息处理
	self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1/15), cc.CallFunc:create(function()
		if #self.savePutChipMsg == 0 or self.gameBet == false or self.gameStart == false then
			return;
		end
		local chipMsg = {};
		table.insert(chipMsg,self.savePutChipMsg[1]);
		table.remove(self.savePutChipMsg, 1);

    	self:DealPutChipMsg(chipMsg);
    end))));

    --加载用户
    self.Panel_userInfo:setVisible(false);

    local showSize = self.Panel_usrList:getChildByName("Panel_size"):getContentSize();
    
    -- 创建按钮的tableview
    self.gameBtnTableView = cc.TableView:create(cc.size(showSize.width, showSize.height));
    if self.gameBtnTableView then  
        self.gameBtnTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.gameBtnTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
        self.gameBtnTableView:setAnchorPoint(cc.p(0,0)); 
        self.gameBtnTableView:setPosition(cc.p(0, 0));
        self.gameBtnTableView:setDelegate();

        self.gameBtnTableView:registerScriptHandler( handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED);  
        self.gameBtnTableView:registerScriptHandler( handler(self, self.tabel_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.gameBtnTableView:registerScriptHandler( handler(self, self.tabel_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.gameBtnTableView:registerScriptHandler( handler(self, self.tabel_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  

        self.Panel_usrList:getChildByName("Panel_size"):addChild(self.gameBtnTableView);
        self:CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, self.Panel_userInfo:getContentSize(), true);
    end

	--加载历史信息
    self.Panel_resultInfo:setVisible(false);

    local showResultSize = self.Panel_result:getContentSize();
    
    -- 创建按钮的tableview
    self.resultTableView = cc.TableView:create(cc.size(showResultSize.width, showResultSize.height));
    if self.resultTableView then  
        self.resultTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);    
        self.resultTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
        self.resultTableView:setAnchorPoint(cc.p(0,0)); 
        self.resultTableView:setPosition(cc.p(0, 0));
        self.resultTableView:setDelegate();

        self.resultTableView:registerScriptHandler( handler(self, self.resultCellTouched),cc.TABLECELL_TOUCHED);  
        self.resultTableView:registerScriptHandler( handler(self, self.result_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.resultTableView:registerScriptHandler( handler(self, self.result_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.resultTableView:registerScriptHandler( handler(self, self.result_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
            
        self.Panel_result:addChild(self.resultTableView);
        self:CommomFunc_TableViewReloadData_Horizontal(self.resultTableView, self.Panel_resultInfo:getContentSize(), true);
    end


    --初始化音效音乐
    self:InitSet();
    self:InitMusic();
end
--初始化音乐音效
function TableLayer:InitSet()
	self.Image_otherBtnBg:setLocalZOrder(101);
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	--保险箱
	self.Button_insurance:getChildByName("Image_insurance1"):loadTexture("yyy_baoxianxiangsp.png",UI_TEX_TYPE_PLIST);
	self.Button_insurance:getChildByName("Image_insurance2"):loadTexture("yyy_baoxianxiang.png",UI_TEX_TYPE_PLIST);
	--规则
	self.Button_rule:getChildByName("Image_rule1"):loadTexture("yyy_guize.png",UI_TEX_TYPE_PLIST);
	self.Button_rule:getChildByName("Image_rule2"):loadTexture("yyy_guizetext.png",UI_TEX_TYPE_PLIST);
	--音效
	local effectState = getEffectIsPlay();
	local effectSp = self.Button_effect:getChildByName("Image_effect1");
	self.Button_effect:getChildByName("Image_effect2"):loadTexture("yyy_yinxiaozi.png",UI_TEX_TYPE_PLIST);
	if effectState then--开着音效
		effectSp:loadTexture("yyy_yinxiao.png",UI_TEX_TYPE_PLIST);	
	else
		effectSp:loadTexture("yyy_yinxiao-off.png",UI_TEX_TYPE_PLIST);
	end
	--音乐
	local musicState = getMusicIsPlay();
	local musicSp = self.Button_music:getChildByName("Image_music1");
	self.Button_music:getChildByName("Image_music2"):loadTexture("yyy_yinyuezi.png",UI_TEX_TYPE_PLIST);
	if musicState then--开着音效
		musicSp:loadTexture("yyy_yinyue.png",UI_TEX_TYPE_PLIST);	
	else
		musicSp:loadTexture("yyy_yinyue-off.png",UI_TEX_TYPE_PLIST);
	end
end
--初始化背景音乐
function TableLayer:InitMusic()
	local musicState = getMusicIsPlay();
	if musicState then
		audio.playMusic("yaoyiyao/sound/sound-dice-bg.mp3", true)
	else
		audio.stopMusic();
	end
end
--创建筹码
function TableLayer:ChipCreate(chipType,beginPos)
	--创建
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/chip/chip.plist");
	local chipSp = cc.Sprite:createWithSpriteFrameName("yyy_"..chipType..".png");
	chipSp:setTag(chipType);
	chipSp:setScale(0.35);
	chipSp:setPosition(beginPos);
	self.Node_chipNode:addChild(chipSp,5);

	return chipSp;
end
--筹码移动动画实现
function TableLayer:ChipMove(chipNode,endPos,random,callBack)
	local randomPos = cc.p(0,0);       
	if random then--目标点增加随机坐标
		randomPos.x = math.random(0,100)-50;
		randomPos.y = math.random(0,100)-50;
	end
	
	--设置回调函数
	local function ChipMoveCallBack()
		if callBack then
			callBack();
		end
	end
	--创建动画
	local chipMove = cc.MoveTo:create(0.4,cc.p(endPos.x+randomPos.x,endPos.y+randomPos.y));
	chipNode:runAction(cc.Sequence:create(cc.EaseOut:create(chipMove,0.4),cc.CallFunc:create(function()
		ChipMoveCallBack();
	end)));

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
			chipAction:setPosition(size.width/2,size.height/2);
			chipAction:setAnimation(1,"xuanzhong", true);
			chipAction:setName("chipAction");
			pNode:addChild(chipAction);
		end
	else
		pNode:stopAllActions();
		pNode:removeAllChildren();
	end
end

--选择筹码
function TableLayer:ChooseChip(chipType)
	for i = 1,6 do
		self["Button_score"..i]:setPositionY(55);
		self["Button_score"..i].selectTag = 0;--筹码选中标志置为0
		self:ShowChipAction(self["Button_score"..i],false);
		if i == chipType and self["Button_score"..i]:isEnabled() then
			self["Button_score"..i]:setPositionY(65);
			self["Button_score"..i].selectTag = 1;--设置选中的筹码金额
			self:ShowChipAction(self["Button_score"..i],true);
		end
	end
end
--根据自己拥有的金额判断筹码置灰 --判断筹码100是否能亮起来 默认亮起100
function TableLayer:ChipJundge(default)
	-- luaPrint("根据自己拥有的金额判断筹码置灰");
	if self.gameStart == false or self.gameBet == false then
		return;
	end

	if default == nil then
		default = true;
	end
	local money = self.playerMoney;
	local num = 0;--有多少的筹码可以使用
	if money>=self:ChipTypeToChipMoney(6) then
		num = 6;
	elseif money>=self:ChipTypeToChipMoney(5) then
		num = 5;
	elseif money>=self:ChipTypeToChipMoney(4) then
		num = 4;
	elseif money>=self:ChipTypeToChipMoney(3) then
		num = 3;
	elseif money>=self:ChipTypeToChipMoney(2) then
		num = 2;
	elseif money>=self:ChipTypeToChipMoney(1) then
		num = 1;
	end

	-- luaPrint("设置是否能点击num",num,money)
	--设置是否能点击
	for i = 1,6 do
		self["Button_score"..i]:setEnabled(false);
		if i <= num then
			self["Button_score"..i]:setEnabled(true);
		end
	end
	--设置默认值
	if money>=self:ChipTypeToChipMoney(1) and default then
		self:ChooseChip(1);
	end
	--如果不显示默认
	if not default then
		local selectNum = 1;
		for i = 1,6 do
			if self["Button_score"..i].selectTag == 1 then
				selectNum = i;
				break;
			end
		end
		if money < self:ChipTypeToChipMoney(selectNum) then--钱不够选择默认
			self:ChooseChip(1);
			-- self.Button_throw:setEnabled(false);
		else
			self:ChooseChip(selectNum);
		end
	end

	if num == 0 then
		self:SetChipGrey(true);
	end

end
--将所有筹码置灰
function TableLayer:SetChipGrey(default)
	if default == nil then
		default = false;--如果true将提高的放回原处
	end

	for i = 1,6 do
		self["Button_score"..i]:setPositionY(55);
		self["Button_score"..i]:setEnabled(false);
		if default then
			self["Button_score"..i].selectTag = 0;
		end
		self:ShowChipAction(self["Button_score"..i],false);
	end
end

--筹码类型和筹码金额的转换
function TableLayer:ChipTypeToChipMoney(chipType)--1 10 50 100 500 1000
	if chipType == 1 then
		return 100;
	elseif chipType == 2 then
		return 1000;
	elseif chipType == 3 then
		return 5000;
	elseif chipType == 4 then
		return 10000;
	elseif chipType == 5 then
		return 50000;
	elseif chipType == 6 then
		return 100000;
	end
	return 100;
end
function TableLayer:ChipMoneyToChipType(chipMoney)
	if chipMoney == 100 then
		return 1;
	elseif chipMoney == 1000 then
		return 2;
	elseif chipMoney == 5000 then
		return 3;
	elseif chipMoney == 50000 then
		return 4;
	elseif chipMoney == 1000000 then
		return 5;
	elseif chipMoney == 100000 then
		return 6;
	end
	return 1;
end
--清空筹码
function TableLayer:ClearChipInDesk()
	self.Node_chipNode:removeAllChildren();
	self.chipSaveTable = {};
	for k,v in pairs(DiceConfig) do
		local i = v+1;
		self.chipSaveTable[i] = {};
	end

	self.selfAreaSave = {};--保存自己所选择的区域
	for k,v in pairs(DiceConfig) do
		local i = v+1;
		self.selfAreaSave[i] = {};
	end

	self:ChipJundge(false);
	self:StopWinAreaAction();
end
--记住上次投筹码的区域
function TableLayer:RememberChipThrow(chipType,areaId)
	self.Button_throw.chipType = chipType;
	self.Button_throw.areaId = areaId;
	self.Button_throw:setEnabled(true);
end
--刷新筹码区域
function TableLayer:UpdateAreaChipSum(chipSumTable)
	if chipSumTable == nil then
		chipSumTable = {};
		for k,v in pairs(DiceConfig) do
			chipSumTable[v+1] = 0;
		end
	end

	--设置钱的数量
	for k,v in pairs(chipSumTable) do
		if self.buttonCast[k-1] then
			local moneyBg = self.buttonCast[k-1]:getChildByName("Image_xiazhu");
			local moneySum = moneyBg:getChildByName("Text_moneySum");
			moneyBg:setVisible(true);
			self:ScoreToMoney(moneySum,v);
			if v == 0 then
				moneyBg:setVisible(false);
			end
		end
	end
end
--转换成区域下注
function TableLayer:ChangeMyareaChip()
	local myChipMoney = {};
	for k,v in pairs(DiceConfig) do
		myChipMoney[v+1] = 0;
	end

	for k,moneyTypeTable in pairs(self.selfAreaSave) do
		for k1,moneyType in pairs(moneyTypeTable) do
			myChipMoney[k] = myChipMoney[k] + self:ChipTypeToChipMoney(moneyType);
		end
	end

	return myChipMoney;--转换成钱
end
--刷新自己下注的注额
function TableLayer:UpdateAreaMyChip(chipSumTable)
	if chipSumTable == nil then
		chipSumTable = {};
		for k,v in pairs(DiceConfig) do
			chipSumTable[v+1] = 0;
		end
	end
	--设置钱的数量
	for k,v in pairs(chipSumTable) do
		if self.buttonCast[k-1] then
			local moneyBg = self.buttonCast[k-1]:getChildByName("Image_myxiazhu");
			local moneySum = moneyBg:getChildByName("Text_myMoney");
			moneyBg:setVisible(true);
			self:ScoreToMoney(moneySum,v);
			if v == 0 then
				moneyBg:setVisible(false);
			else
				self.pourChip = true;
			end
		end
	end

end

--庄家和自己的钱增加减少动画效果
function TableLayer:MoneyActionShow(pNode)
	pNode:setVisible(true);
	pNode:setOpacity(0);
	local fadeInAction = cc.FadeIn:create(0.5);
	local fadeOutAction = cc.FadeOut:create(0.5);
	pNode:runAction(cc.Sequence:create(fadeInAction,cc.DelayTime:create(1),fadeOutAction));
end
--大提示显示动画
function TableLayer:TipActionShow(pNode)
	pNode:setVisible(true);
	pNode:setOpacity(255);
	local fadeOutAction = cc.FadeOut:create(0.3);
	pNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),fadeOutAction));
end
--赢钱区域动画函数调用
function TableLayer:WinAreaAction(winArea)
	for k,v in pairs(DiceConfig) do
		if winArea[v+1] ~= 0 then
			local castNode = self.buttonCast[v];
			local castWinSp = castNode:getChildByName("Image_win");
			castWinSp:setVisible(true);
			castWinSp:setOpacity(0);
			local fadeOutAction = cc.FadeOut:create(0.3);
			local fadeInAction = cc.FadeIn:create(0.3);
			local repeatAction = cc.RepeatForever:create(cc.Sequence:create(fadeInAction,fadeOutAction));

			castWinSp:runAction(repeatAction);
		end
	end
end
--停止赢钱动画
function TableLayer:StopWinAreaAction()
	for k,v in pairs(DiceConfig) do
		local castNode = self.buttonCast[v];
		local castWinSp = castNode:getChildByName("Image_win");
		castWinSp:stopAllActions();
		castWinSp:setVisible(false);
	end
end
--随机加载下注筹码
function TableLayer:AddAreaChip(areaData)
	for k,v in pairs(DiceConfig) do
		local totalScore = areaData[v+1];
		local scoreTable = self:GetChipScoreTable(totalScore);

		for k,score in pairs(scoreTable) do
			local castNode = self.buttonCast[v];
			local castPos = cc.p(castNode:getPosition());
			local randomPos = cc.p(0,0);
			local shrinkLength = 40;
			randomPos.x = math.random(castPos.x+shrinkLength,castPos.x+castNode:getContentSize().width-shrinkLength);
			randomPos.y = math.random(castPos.y+shrinkLength,castPos.y+castNode:getContentSize().height-shrinkLength);
			local chipSp = self:ChipCreate(score,randomPos);
			chipSp.userStation = -1;
			table.insert(self.chipSaveTable[v+1],chipSp);
		end
	end
end
--随机筹码数量(先创建最大的)
function TableLayer:GetChipScoreTable(chipTabel)
	local scoreTable = {};
	--随机下注的筹码
	while true do
		if chipTabel < self:ChipTypeToChipMoney(1) then
			break;
		end

		local num = 1;--有多少的筹码可以使用
		if chipTabel>=self:ChipTypeToChipMoney(6) then
			num = 6;
		elseif chipTabel>=self:ChipTypeToChipMoney(5) then
			num = 5;
		elseif chipTabel>=self:ChipTypeToChipMoney(4) then
			num = 4;
		elseif chipTabel>=self:ChipTypeToChipMoney(3) then
			num = 3;
		elseif chipTabel>=self:ChipTypeToChipMoney(2) then
			num = 2;
		elseif chipTabel>=self:ChipTypeToChipMoney(1) then
			num = 1;
		end

		table.insert(scoreTable,num);
		chipTabel  = chipTabel - self:ChipTypeToChipMoney(num);
	end

	return scoreTable;
end
--播放动画
function TableLayer:playZitiEffect(iType)
	local tipzi = {"dengdaixiaju","huanzhuang","kaishixiazhu","tingzhixiazhu"}
	
	local ziSpine = self.Node_startAnimate:getChildByName("ziSpine");
	if ziSpine then
		ziSpine:removeFromParent();
	end

	if iType == 1 then
		local ziSpine = createSkeletonAnimation("spz_dengwanjia","hall/game/dengdai/dengdai.json","hall/game/dengdai/dengdai.atlas");
		if ziSpine then
			ziSpine:setPosition(640,410);
			ziSpine:setAnimation(1,"dengxiaju", true);
			ziSpine:setName("ziSpine");
			self.Node_startAnimate:addChild(ziSpine,10);
		end
		return;
	end

	local ziSpine = createSkeletonAnimation("zitiTip","hall/game/feiqinzoushou.json","hall/game/feiqinzoushou.atlas");
	if ziSpine then
		ziSpine:setPosition(640,360);
		ziSpine:setAnimation(1,tipzi[iType], false);
		ziSpine:setName("ziSpine");
		self.Node_startAnimate:addChild(ziSpine,10);
	end
end
--存储历史记录过滤没有的记录
function TableLayer:GameHisitorySave(historyInfo)
	self.gameHistoryList = {};
	for i = 1,30 do
		local haveData = true;
		for j=1,4 do--过滤空的数据
			if historyInfo[i][j] == -1 then
				haveData = false;
				break;
			end
		end
		if haveData then
			table.insert(self.gameHistoryList,historyInfo[i]);
		end
	end

	local daCount = 0;
	local xiaoCount = 0;
	local baoCount = 0;

	for k,v in pairs(self.gameHistoryList) do
		if v[4] == 2 then--大
			daCount = daCount+1;
		elseif v[4] == 3 then--豹子
			baoCount = baoCount+1;
		else--小
			xiaoCount = xiaoCount+1;
		end
	end

	self.AtlasLabel_da:setString(daCount);
	self.AtlasLabel_xiao:setString(xiaoCount);
	self.AtlasLabel_bao:setString(baoCount);

	if self.resultTableView then
		self:CommomFunc_TableViewReloadData_Horizontal(self.resultTableView, self.Panel_resultInfo:getContentSize(), false);
	end
end

--历史信息添加
function TableLayer:InsertGameHistory(historyInfo)
	for i = 30,1,-1 do
		local haveDataCount = 0;
		for j=1,4 do--过滤空的数据
			if historyInfo[i][j] ~= -1 then
				haveDataCount = haveDataCount+1;
			end
		end

		if haveDataCount == 4 then
			table.insert(self.gameHistoryList,historyInfo[i]);

			local flag = historyInfo[i][4];--添加大小统计
			if flag == 2 then--大
				self.AtlasLabel_da:setString(tonumber(self.AtlasLabel_da:getString())+1);
			elseif flag == 3 then--豹子
				self.AtlasLabel_bao:setString(tonumber(self.AtlasLabel_bao:getString())+1);
			else--小
				self.AtlasLabel_xiao:setString(tonumber(self.AtlasLabel_xiao:getString())+1);
			end

			break;
		end
	end

	if self.resultTableView then
		self:CommomFunc_TableViewReloadData_Horizontal(self.resultTableView, self.Panel_resultInfo:getContentSize(), false);
	end
end

--设置按钮上下庄状态
function TableLayer:SetButtonVillageState(buttonState)
	if buttonState == villageState.zUserStatus_Null then--空闲状态
		self.Button_village:setTag(0);
		self.Button_village:loadTextures("yyy_shangzhuang.png","yyy_shangzhuang-on.png","yyy_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
	elseif buttonState == villageState.zStatus_IsZhuang then--坐庄状态
		self.Button_village:setTag(2);
		self.Button_village:loadTextures("yyy_xiazhuang.png","yyy_xiazhuang-on.png","yyy_xiazhuang-on.png",UI_TEX_TYPE_PLIST);
	elseif buttonState == villageState.zUserStatus_InList then--申请上庄状态
		self.Button_village:setTag(1);
		self.Button_village:loadTextures("yyy_qxsz.png","yyy_qxsz-on.png","yyy_qxsz-on.png",UI_TEX_TYPE_PLIST);
	elseif buttonState == villageState.zStatus_XiaZhuang then--申请下庄状态
		self.Button_village:setTag(3);
		self.Button_village:loadTextures("yyy_qxxz.png","yyy_qxxz-on.png","yyy_qxxz-on.png",UI_TEX_TYPE_PLIST);
	end

end

--刷新上庄列表
function TableLayer:UpdateSZList(data,dataCount)
	--清除view上的元素
	self.ListView_szList:removeAllChildren();

	for i = 1,dataCount do
		if data[i].station ~= 255 then
			local temp = self.Panel_szList:clone();
			temp:setVisible(true);

			--获取信息
			local userInfo = self.tableLogic:getUserBySeatNo(data[i].station);

			if userInfo then
				--更改数据
				local Text_userName = temp:getChildByName("Text_userName");
				if Text_userName then
					Text_userName:setString(i.."."..FormotGameNickName(userInfo.nickName,nickNameLen));
				end

				local Text_money = temp:getChildByName("Text_money");
				if Text_money then
					self:ScoreToMoney(Text_money,userInfo.i64Money);
				end

				self.ListView_szList:pushBackCustomItem(temp);
			end
		end
	end
end

------------------------------------游戏消息------------------------------------
--上庄消息
function TableLayer:BankStateInfoGame(message)
	local data = message._usedata;
	luaDump(data,"上庄-----------");
	luaPrint("上庄",self.tableLogic:getMySeatNo())
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	if data.success == 0 then--庄失败
		
	elseif data.success == 1 then--庄成功
		if data.station == self.tableLogic:getMySeatNo() then
			if data.bCancel then
				if data.shang then
					self:SetButtonVillageState(villageState.zUserStatus_Null);
				else
					self:SetButtonVillageState(villageState.zStatus_IsZhuang);
				end
			else
				if data.shang then
					self:SetButtonVillageState(villageState.zStatus_IsZhuang);
				else
					self:SetButtonVillageState(villageState.zStatus_XiaZhuang);
				end

			end
		end
	elseif data.success == 2 then--加入上庄列表
		if data.station == self.tableLogic:getMySeatNo() then--如果是自己进行操作
			self:SetButtonVillageState(villageState.zUserStatus_InList);
		end
	elseif data.success == 3 then--移除上庄列表
		if data.station == self.tableLogic:getMySeatNo() then--如果是自己进行操作
			self:SetButtonVillageState(villageState.zUserStatus_Null);
		end
	elseif data.success == 4 then--换庄
		if data.station == self.tableLogic:getMySeatNo() then
			--自己成为庄家设置按钮下庄
			self:SetButtonVillageState(villageState.zStatus_IsZhuang);
		else
			if self.bankStation == self.tableLogic:getMySeatNo() then
				self:SetButtonVillageState(villageState.zUserStatus_Null);
			end

		end
		--庄家轮换
		self:TipActionShow(self.Image_bankChange);

		local effectState = getEffectIsPlay();
		if effectState then
			audio.playSound("yaoyiyao/sound/zhuang-change.mp3");
		end

		self.bankStation = data.station;
		local userInfo = self.tableLogic:getUserBySeatNo(data.station);
		if userInfo then
			self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
		end


	elseif data.success == 5 then--直接成为庄家
		if data.station == self.tableLogic:getMySeatNo() then--如果是自己则将按钮变为下庄按钮
			self:SetButtonVillageState(villageState.zStatus_IsZhuang);
		end

		self.bankStation = data.station;

		local userInfo = self.tableLogic:getUserBySeatNo(self.bankStation);
		if userInfo then
			self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
		end
	end
	--如果自己是庄家则将筹码置灰
	if self.bankStation == self.tableLogic:getMySeatNo() then
		self:SetChipGrey();
	end

	self.Text_personNum:setText(data.iNTListCount.."人");
	self:UpdateSZList(data.iNTList,data.iNTListCount);
end
--下注信息
function TableLayer:PutChipInfoGame(message)
	if self.gameStart == false then
		return;
	end

	local data = message._usedata;
	-- luaDump(data,"下注信息----------");
	if data.moneytype == 0 then
		return;
	end

	local mySeatNo = self.tableLogic:getMySeatNo();
	if mySeatNo == data.station then
		self:DealPutChipMsg({data},true);
		self.Button_throw:setEnabled(false);
	else
		table.insert(self.savePutChipMsg,data);
	end
	-- self:DealPutChipMsg({data},true);
	--刷新筹码总额
	self:UpdateAreaChipSum(data.m_iQuYuZhu);
	if self.bankStation ~= mySeatNo and mySeatNo == data.station then
		-- self:RememberChipThrow(data.moneytype,data.type);
		self:ChipJundge(false);
	end
end
--处理下注筹码
function TableLayer:DealPutChipMsg(msgTable,mySelf)
	if self.gameStart == false then
		return;
	end
	if mySelf == nil then
		mySelf = false;
	end

	for k,data in pairs(msgTable) do
		local castNode = self.buttonCast[data.type];

		if castNode == nil then
			-- addScrollMessage("非法下注区域"..data.type);
		end

		if castNode then
			local beginPos = self.Panel_gameBg:convertToNodeSpace(cc.p(self.Button_otherUser:getPosition()));
			local mySeatNo = self.tableLogic:getMySeatNo();
			if mySeatNo == data.station then
				beginPos.x = self["Button_score"..data.moneytype]:getPositionX();
				beginPos.y = self["Button_score"..data.moneytype]:getPositionY();

				--保存自己选择地区域
				table.insert(self.selfAreaSave[data.type+1],data.moneytype);
				self.pourChip = true;
			end
			local chipSp = self:ChipCreate(data.moneytype,beginPos);
			chipSp.userStation = data.station;
			-- table.insert(self.chipSaveTable[data.type+1],chipSp);

			local castPos = cc.p(castNode:getPosition());
			local randomPos = cc.p(0,0);
			local shrinkLength = 40;
			randomPos.x = math.random(castPos.x+shrinkLength,castPos.x+castNode:getContentSize().width-shrinkLength);
			randomPos.y = math.random(castPos.y+shrinkLength,castPos.y+castNode:getContentSize().height-shrinkLength);
			self:ChipMove(chipSp,randomPos,false,function()
				if self.Button_hideChip:getTag() == 1 then--按住按钮将筹码隐藏
					chipSp:setVisible(false);
				end

				table.insert(self.chipSaveTable[data.type+1],chipSp);
			end);
			--减去下注额
			if mySeatNo == data.station then
				-- luaPrint("减去下注额",self.playerMoney,data.money)
			    self.playerMoney = self.playerMoney - data.money;
			    self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
		        self:UpdateAreaMyChip(self:ChangeMyareaChip());
			end

			local effectState = getEffectIsPlay();
		    if effectState then
		    	audio.playSound("yaoyiyao/sound/sound-betlow.mp3");
			end

		    if self.bankStation == self.tableLogic:getMySeatNo() then
		    	self:SetChipGrey();
			end

		    -- if self.playerMoney<self.ChipTypeToChipMoney(self.Button_throw.chipType) then
		    -- 	self.Button_throw:setEnabled(false);
		    -- end
		end
	end

end


--游戏开始信息
function TableLayer:DiceGameStartInfo(message)
	local data = message._usedata;
	luaDump(data,"游戏开始信息");

	--判断是否在上庄列表
	local findFlag = false;
	for k,v in pairs(data.iNTList) do
		if v.station == self.tableLogic:getMySeatNo() then
			findFlag = true;
			break;
		end
	end

	--判断未操作局数置0
	if findFlag or self.bankStation == self.tableLogic:getMySeatNo() or self.pourChip then
		self.mOperateGameCount = 0;
	end

	--先判断已经未操作的局数
	if self.mOperateGameCount > 2 then
		--5局被踢出游戏
		if self.mOperateGameCount > 4 then
			addScrollMessage("您已连续5局未参与游戏，已被请出房间！");
			self:ClickBackCallBack();
			return;
		else
			--提示
			addScrollMessage("您已连续"..self.mOperateGameCount.."局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
		end
	end

	if findFlag or self.bankStation == self.tableLogic:getMySeatNo() then--是庄家置0
		self.mOperateGameCount = 0;
	else
		self.mOperateGameCount = self.mOperateGameCount + 1;
	end

	--重置下注时间
	self.AtlasLabel_clock:setString(data.m_iXiaZhuTime);
	self.AtlasLabel_clock:setTag(data.m_iXiaZhuTime);
	self.Text_tipNextGame:setVisible(false);

	self.gameBet = true;
	self.gameStart = true;
	self.savePutChipMsg = {};
	self:ClearChipInDesk();--清理桌面
	self.pourChip = false;--将玩家下注的状态重置

	local GameActionLayer = self.Panel_gameBg:getChildByName("GameAction");
	if GameActionLayer then
		GameActionLayer:removeFromParent();
	end

	--设置玩家金币
	local mySeatNo = self.tableLogic:getMySeatNo();
	local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		-- luaPrint("设置玩家金币",userInfo.i64Money);
		self.playerMoney = clone(userInfo.i64Money);
		self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
	end

	self.Button_throw:setEnabled(false);--游戏开始续投置灰
	self:UpdateAreaChipSum();--筹码额显示0
	self:UpdateAreaMyChip(self:ChangeMyareaChip());--自己的筹码显示0
	--设置庄家局数
	local userInfo = self.tableLogic:getUserBySeatNo(data.m_iNowNtStation);
	if userInfo then
		self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
	end
	--如果自己是庄家则将筹码置灰
	if self.bankStation == self.tableLogic:getMySeatNo() then
		self:SetChipGrey();
	end

	self.Text_personNum:setText(data.iNTListCount.."人");
	self:UpdateSZList(data.iNTList,data.iNTListCount);
	--改成下注时间
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	self.Image_gameState:setVisible(true);
	self.Image_gameState:loadTexture("yyy_xiazhushijian.png",UI_TEX_TYPE_PLIST);

	if isHaveBankLayer() then
        createBank(function (data)
            self:DealBankInfo(data)
        end,true);
    end
	--开始下注动画
	self:playZitiEffect(3);

	--显示连庄
	if data.m_iZhuangBaShu>1 then
		self.AtlasLabel_successive:setString(data.m_iZhuangBaShu);
		self:TipActionShow(self.Node_successive);
	end

	local effectState = getEffectIsPlay();
	if effectState then
		audio.playSound("yaoyiyao/sound/sound-start-wager.mp3");--开始下注
	end
	self:UpdateUserList();

	self:UpdateThrowBtn();

	self:GameHisitorySave(data.m_iResultInfo);
end
--动画信息
function TableLayer:GameAnimateInfo(message)
	--体验场删除退出提示
    GamePromptLayer:remove()

	if self.gameStart == false then
		return;
	end

	--将隐藏的筹码显示出来
	self.Button_hideChip:setTag(0);
	for k,v in pairs(self.chipSaveTable) do
		for k1,v1 in pairs(v) do
			v1:setVisible(true);
		end
	end


	if isHaveBankLayer() then
		-- addScrollMessage("游戏开奖中，请稍后进行取款操作。");
		createBank(function (data)
            self:DealBankInfo(data)
        end,false);
	end
	self:SetChipGrey();
	local data = message._usedata;
	luaDump(data,"动画信息");
	--延迟播放动画
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
		if self.gameStart == false then
			return;
		end
		self.Node_startAnimate:removeChildByName("ziSpine");
		local size = self:getContentSize();
		
		local GameActionLayer = GameAction:createLayer(data);
		self.Panel_gameBg:addChild(GameActionLayer,100);
	end)))

	self.gameBet = false;

	self.AtlasLabel_clock:setString(15);
	self.AtlasLabel_clock:setTag(15);
	--改成开奖时间
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	self.Image_gameState:setVisible(true);
	self.Image_gameState:loadTexture("yyy_kaijiangshijian.png",UI_TEX_TYPE_PLIST);
	self.Button_throw:setEnabled(false);

	--将点击下注区域置隐藏
	for k,v in pairs(DiceConfig) do
		self.buttonCast[v]:getChildByName("Image_click"):setVisible(false);
	end
	--将所有的筹码绘制
	-- self:DealPutChipMsg(self.savePutChipMsg);
	--将所有筹码移除
	self.savePutChipMsg = {};
	self:SetChipGrey();--继续置灰

	--循环遍历 有下注的时候赋值
	local flag = false;

	for k,v in pairs(self.selfAreaSave) do
		if #v>0 then
			flag = true;
			break;
		end
	end

	if flag then
		self.Button_throw.selfAreaSave = self.selfAreaSave;
	end
end
--结算消息
function TableLayer:ResultMessageInfo(message)
	--体验场删除退出提示
    GamePromptLayer:remove()

	self:SetChipGrey();--继续置灰
	if self.gameStart == false then
		local mySeatNo = self.tableLogic:getMySeatNo();
		local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
		if userInfo then
			self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
			self.playerMoney = clone(userInfo.i64Money);
		end
		if self.bankStation>-1 then
			local userInfo = self.tableLogic:getUserBySeatNo(self.bankStation);
			if userInfo then
				self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
			end
		end
		self:UpdateUserList();
		return;
	end

	local data = message._usedata;
	luaDump(data,"结算消息");

	--移除动画
	local GameActionLayer = self.Panel_gameBg:getChildByName("GameAction");
	if GameActionLayer then
		GameActionLayer:removeFromParent();
	end

	--检测是否下注没下注弹出提示
	if self.pourChip == false and self.bankStation~=self.tableLogic:getMySeatNo() then
		addScrollMessage("本局您没有下注！");
	end

	self:InsertGameHistory(data.iResultInfo);

	local bankMoneyPos = cc.p(self.Text_BankMoney:getPositionX()+100,self.Text_BankMoney:getPositionY());--庄家坐标

	local effectState = getEffectIsPlay();
	--显示赢钱区域闪烁
	self:WinAreaAction(data.iWinQuYu);

	self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ()--展示闪烁再显示结算和动画
		if self.gameStart == false then
			return;
		end

		local isSound = false;
		for k,v in pairs(DiceConfig) do
			local i = v+1;
			if data.iWinQuYu[i] == 0 then--输钱区域
				for k1,node1 in pairs(self.chipSaveTable[i]) do
					local chipSp = self:ChipCreate(node1:getTag(),cc.p(node1:getPosition()));
					isSound = true;
					self:ChipMove(chipSp,bankMoneyPos,false,function()
						chipSp:removeFromParent();--输钱区域筹码飞向庄
					end);
				end

				for k1,node1 in pairs(self.chipSaveTable[i]) do
					node1:removeFromParent();
				end
				self.chipSaveTable[i] = {};
			end
		end

		if isSound and effectState then
			audio.playSound("yaoyiyao/sound/sound-get-gold.mp3")
		end	

	end)));

	self:runAction(cc.Sequence:create(cc.DelayTime:create(2.8),cc.CallFunc:create(function ()--等待输钱飞到庄家后执行
		if self.gameStart == false then
			return;
		end
		local isSound = false;
		for k,v in pairs(DiceConfig) do
			local i = v+1;
			if data.iWinQuYu[i] == 1 then--赢钱区域
				local chipCopy = {};--创建筹码飞向赢的区域
				for k1,node1 in pairs(self.chipSaveTable[i]) do
					local chipSp = self:ChipCreate(node1:getTag(),bankMoneyPos);
					chipSp.userStation = node1.userStation;
					table.insert(chipCopy,chipSp);
				end

				for k1,node1 in pairs(chipCopy) do
					local castNode = self.buttonCast[i-1];
					local castPos = cc.p(castNode:getPosition());
					local randomPos = cc.p(0,0);
					local shrinkLength = 40;
					randomPos.x = math.random(castPos.x+shrinkLength,castPos.x+castNode:getContentSize().width-shrinkLength);
					randomPos.y = math.random(castPos.y+shrinkLength,castPos.y+castNode:getContentSize().height-shrinkLength);
					isSound = true;
					self:ChipMove(node1,randomPos,false,function()
						table.insert(self.chipSaveTable[i],node1);
					end);
				end
			end
		end
		if isSound and effectState then
			audio.playSound("yaoyiyao/sound/sound-get-gold.mp3")
		end
	end)));

	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.6),cc.CallFunc:create(function ()--等待赢的钱飞向赢的区域后执行--将钱飞向玩家
		--如果自己选的区域赢钱则创建对象飞向自己
		if self.gameStart == false then
			return;
		end
		local isSound = false;
		for k,v in pairs(DiceConfig) do
			local i = v+1;
			if data.iWinQuYu[i] == 1 then--赢钱区域
				if #self.selfAreaSave[i] > 0 then
					for k,v in pairs(self.selfAreaSave[i]) do
						local chipPos = cc.p(0,0);
						for j = 1,1 do--创建2遍
							chipPos.x = self.buttonCast[i-1]:getPositionX() + math.random(0,200)-100;
							chipPos.y = self.buttonCast[i-1]:getPositionY() + math.random(0,200)-100;

							local chipSp = self:ChipCreate(v,chipPos);
							self:ChipMove(chipSp,cc.p(307,32),false,function()
								chipSp:removeFromParent();
							end);
						end
					end
				end
			end
		end

		--其他的钱飞向其他玩家 
		for k,v in pairs(DiceConfig) do
			local i = v+1;
			for k,node1 in pairs(self.chipSaveTable[i]) do
				isSound = true;

				local tagetPos = self.Panel_gameBg:convertToNodeSpace(cc.p(self.Button_otherUser:getPosition()));--目标位置
				if node1.userStation == self.tableLogic:getMySeatNo() then--如果自己则飞向自己否则飞向其他玩家
					tagetPos = cc.p(307,32);
				end

				self:ChipMove(node1,tagetPos,false,function()
					node1:removeFromParent();
					--table.remove(self.chipSaveTable[i], k);
				end);
			end
		end

		if isSound and effectState then
			audio.playSound("yaoyiyao/sound/sound-get-gold.mp3")
		end
		--清空数据
		self.chipSaveTable = {};
		for k,v in pairs(DiceConfig) do
			local i = v+1;
			self.chipSaveTable[i] = {};
		end

		--返回金币大于0则显示提示效果
		if data.iUserScore>0 then
			if data.iUserReturnTotle >= 0 then
				self.Text_playerChange:setProperty("","yaoyiyao/number/zi_ying.png",21,27,'+');
				self:ScoreToMoney(self.Text_playerChange,data.iUserScore,"+");
				self:MoneyActionShow(self.Text_playerChange);

				local bigMoney = {	
									DiceConfig.NOTE_TOTLE_COUNT_SEVENTEEN,
									DiceConfig.NOTE_WEI_ONE,
									DiceConfig.NOTE_WEI_TWO,
									DiceConfig.NOTE_WEI_THREE,
									DiceConfig.NOTE_WEI_FOUR,
									DiceConfig.NOTE_WEI_FIVE,
									DiceConfig.NOTE_WEI_SIX,
									DiceConfig.NOTE_WEI_ALL,
								}

				local flag = true;
				for k,v in pairs(bigMoney) do
					if data.iWinQuYu[v+1] ~= 0 then
						flag = false;
						audio.playSound("yaoyiyao/sound/bigMoney.mp3");--赢
						break;
					end
				end

				if flag then
					audio.playSound("yaoyiyao/sound/win.mp3");--赢
				end
			end
			
		elseif data.iUserScore<0 then
			self.Text_playerChange:setProperty("","yaoyiyao/number/zi_shu.png",21,27,'+');
			self:ScoreToMoney(self.Text_playerChange,data.iUserScore);
			self:MoneyActionShow(self.Text_playerChange);
			audio.playSound("yaoyiyao/sound/lose.mp3");--赢
		end
		--显示庄家获得金币显示
		if data.iNTScore > 0  then
			self.Text_bankMoneyChange:setProperty("","yaoyiyao/number/zi_ying.png",21,27,'+');
			self:ScoreToMoney(self.Text_bankMoneyChange,data.iNTScore,"+");
			self:MoneyActionShow(self.Text_bankMoneyChange);
		elseif data.iNTScore<0 then
			self.Text_bankMoneyChange:setProperty("","yaoyiyao/number/zi_shu.png",21,27,'+');
			self:ScoreToMoney(self.Text_bankMoneyChange,data.iNTScore);
			self:MoneyActionShow(self.Text_bankMoneyChange);
		end
		--显示其他玩家
		if data.iOtherScore > 0 then
			self.Text_otherPlayerChange:setProperty("","yaoyiyao/number/zi_ying.png",21,27,'+');
			self:ScoreToMoney(self.Text_otherPlayerChange,data.iOtherScore,"+");
			self:MoneyActionShow(self.Text_otherPlayerChange);
		elseif data.iOtherScore < 0 then
			self.Text_otherPlayerChange:setProperty("","yaoyiyao/number/zi_shu.png",21,27,'+');
			self:ScoreToMoney(self.Text_otherPlayerChange,data.iOtherScore);
			self:MoneyActionShow(self.Text_otherPlayerChange);
		end
		--计算玩家和庄家分数的增减
		local mySeatNo = self.tableLogic:getMySeatNo();
		local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
		if userInfo then
			self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
			self.playerMoney = clone(userInfo.i64Money);
		end
		luaPrint("self.bankStation",self.bankStation);
		if self.bankStation>-1 then
			local userInfo = self.tableLogic:getUserBySeatNo(self.bankStation);
			if userInfo then
				self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
			end
		end
		self:UpdateUserList();

		--过滤255的座位号
		self.Text_personNum:setText(data.iNTListCount.."人");
		self:UpdateSZList(data.iNTList,data.iNTListCount);

		self.Node_chipNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function () self:ClearChipInDesk(); end)));--清理桌面
		
		self:SetChipGrey();--继续置灰
		self:UpdateAreaChipSum();--筹码额显示0
		self:UpdateAreaMyChip();--自己的筹码显示0

		--播放连胜特效
		if data.nWinTime > 2 and ((self.pourChip and self.bankStation~=self.tableLogic:getMySeatNo()) or self.bankStation==self.tableLogic:getMySeatNo()) then
			local winTime = data.nWinTime;
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
	end)));
end
--重连刷新界面
function TableLayer:ReConnectGame(msg,gameState)
	-- luaDump(self.tableLogic._deskUserList._users,"重连刷新界面")
	self.Node_startAnimate:removeChildByName(WarnAnimName);
	self.Node_startAnimate:removeChildByName("ziSpine");
	--清空桌面
	self:ClearChipInDesk();
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");

	local GameActionLayer = self.Panel_gameBg:getChildByName("GameAction");
	if GameActionLayer then
		GameActionLayer:removeFromParent();
	end

	--设置上庄所需要的钱
	self.villageMoney = msg.i64ShangZhuangLimit;
	self.bankStation = msg.iNowNtStation;
	self.xiaZhuangMoney = msg.iXiaZhuangLimit;

	--系统坐庄
	self.bEnableSysBanker = msg.bEnableSysBanker;
	if self.bEnableSysBanker then
		self.Button_village:setVisible(false);
		self.Button_szList:setVisible(false);
		self.Node_bankInfo:setVisible(false);
		self.Image_xitong:setVisible(true);
		self.Text_BankName:setVisible(false);
		self.Text_BankMoney:setVisible(false);
	else
		self.Button_village:setVisible(true);
		self.Button_szList:setVisible(true);
		self.Node_bankInfo:setVisible(true);
		self.Image_xitong:setVisible(false);
		self.Text_BankName:setVisible(true);
		self.Text_BankMoney:setVisible(true);
	end

	--显示庄家姓名和钱
	if msg.iNowNtStation ~= 255 then
		local userInfo = self.tableLogic:getUserBySeatNo(msg.iNowNtStation);
		if userInfo then
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
			self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
		end
	else
		self.Text_BankName:setText("无人坐庄");
		if self.bEnableSysBanker then
			self.Text_BankName:setText("系统坐庄");
		end
	end
	--判断上庄按钮
	self:SetButtonVillageState(msg.ZhuangStatus);

	local myUserInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	self.playerMoney = clone(myUserInfo.i64Money);

	--下注状态的时候设置下注
	self.Image_gameState:setVisible(false);
	self.Button_throw:setEnabled(false);--游戏开始续投置灰
	if gameState == GameMsg.GS_XIAZHU_TIME then
		self.AtlasLabel_clock:setString(msg.iSYTime);--下注时间设置
		self.AtlasLabel_clock:setTag(msg.iSYTime);
		self.gameBet = true;
		self.gameStart = true;
		for k,v in pairs(msg.i64myZhu) do
			self.playerMoney = self.playerMoney - v;
		end
		self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
		self:ChipJundge();
		--刷新筹码总额
    	self:UpdateAreaChipSum(msg.i64QuYuZhu);
    	self:UpdateAreaMyChip(msg.i64myZhu);
    	self.Image_gameState:setVisible(true);
		self.Image_gameState:loadTexture("yyy_xiazhushijian.png",UI_TEX_TYPE_PLIST);

		--对selfarea 赋值
		for k,v in pairs(msg.i64myZhu) do
			local scoreTable = self:GetChipScoreTable(v);
			self.selfAreaSave[k] = scoreTable;
		end

		--设置区域筹码
		self:AddAreaChip(msg.i64QuYuZhu);
		if isHaveBankLayer() then
	        createBank(function (data)
	            self:DealBankInfo(data)
	        end,true);
	    end
	else
		--体验场删除退出提示
    	GamePromptLayer:remove()

		local isTime = msg.iSYTime;
		isTime = msg.iSYTime-1;
		if isTime < 0 then
			isTime = 0;
		end
		self.AtlasLabel_clock:setString(isTime);--下注时间设置
		self.AtlasLabel_clock:setTag(isTime);

		self.gameBet = false;
		self.gameStart = false;
		self:SetChipGrey();
		-- self.Text_tipNextGame:setVisible(true);
		self:playZitiEffect(1);
		self:UpdateAreaChipSum();--筹码额显示0
		self:UpdateAreaMyChip(self:ChangeMyareaChip());--自己的筹码显示0
		if isHaveBankLayer() then
	        createBank(function (data)
	            self:DealBankInfo(data)
	        end,false);
	    end
	    self.Image_gameState:setVisible(true);
		self.Image_gameState:loadTexture("yyy_kaijiangshijian.png",UI_TEX_TYPE_PLIST);

		--设置是否下注的标志
		for k,v in pairs(msg.i64myZhu) do
			if v>0 then
				self.pourChip = true;
				break;
			end
		end

	end
	--如果自己是庄家则将筹码置灰
	if self.bankStation == self.tableLogic:getMySeatNo() then
		self:SetChipGrey();
	end

	self:GameHisitorySave(msg.iResultInfo);
    --过滤255的座位号
	self.Text_personNum:setText(msg.iNTListCount.."人");
	self:UpdateSZList(msg.iNTList,msg.iNTListCount);
end
--无庄等待
function TableLayer:DealNoBankWait(message)
	--清空庄家信息
	self.Text_BankName:setText("无人坐庄");
	if self.bEnableSysBanker then
		self.Text_BankName:setText("系统坐庄");
	end
	self.Text_BankMoney:setString("");
	--重置上庄按钮
	self:SetButtonVillageState(villageState.zUserStatus_Null);
	--显示等待下局开始
	self:playZitiEffect(1);
	-- self.Text_tipNextGame:setVisible(true);
	self.Image_gameState:setVisible(false);
	self:TipTextShow("当前无庄，请等待");
	self.bankStation = -1;
	-- self.gameStart = false;
	self.gameBet = false;
	self.pourChip = false;--将玩家下注的状态重置
	self:ClearChipInDesk();
	--设置筹码变灰
	self:SetChipGrey();
end
--退还下注
function TableLayer:DealNoteBack(message)
	local msg = message._usedata;

	local i =1;
	while(self.savePutChipMsg[i]) do
		if self.savePutChipMsg[i].station == msg.bDeskStation then
			local putChipMsg = self.savePutChipMsg[i];
			table.remove(self.savePutChipMsg, i);
			msg.iUserXiaZhuData[i] = msg.iUserXiaZhuData[i] - putChipMsg.money;
		else
			i = i + 1;
		end
	end

	self:UpdateAreaChipSum(msg.m_iQuYuZhu);
end

--庄家坐庄期间输赢金币
function TableLayer:DealZhuangScore(message)
	local msg = message._usedata;

	local BankGet = require("hall.layer.popView.BankGetLayer");

	local layer = self:getChildByName("BankGetLayer");
	if layer then
		layer:removeFromParent();
	end

	local layer = BankGet:create(msg.money);
	self:addChild(layer,999);

end

--续投
function TableLayer:DealXuTOU(message)
	local msg = message._usedata;

	luaDump(msg,"续投-----------------")
	if msg.station == self.tableLogic:getMySeatNo() then
		self.Button_throw:setEnabled(false);
	end
	--模拟下注数据
	local chipData = {};
	for k,v in pairs(msg.money) do
		local scoreTable = self:GetChipScoreTable(v);

		for k1,v1 in pairs(scoreTable) do
			local data = {};
			data.station = msg.station;
			data.moneytype = v1;
			data.money = self:ChipTypeToChipMoney(v1);
			data.type = k-1;
			table.insert(chipData,data);
		end
	end

	self:UpdateAreaChipSum(msg.money);
	self:DealPutChipMsg(chipData);
end

--处理错误信息
function TableLayer:DealErrorCode(message)
	local data = message._usedata;
	if data.errorCode == 1 then--庄家不能申请上庄
		self:TipTextShow("庄家不能申请上庄");
	elseif data.errorCode == 2 then--上庄金币不足
		self:TipTextShow("您的金币未满足上庄条件"..(math.floor(self.villageMoney/100)).."金币，不能申请上庄。");
		-- local prompt = GamePromptLayer:create();
		-- prompt:showPrompt(GBKToUtf8("正在开发，勿提bugfree"));
		showBuyTip();
	elseif data.errorCode == 3 then--列表中的玩家不能申请
		self:TipTextShow("列表中的玩家不能申请");
	elseif data.errorCode == 4 then--不是庄家也不在申请列表，下庄错误
		self:TipTextShow("不是庄家也不在申请列表，下庄错误");
	elseif data.errorCode == 5 then--申请人数已满
		self:TipTextShow("申请人数已满");
	elseif data.errorCode == 6 then--庄家无法下注
		self:TipTextShow("庄家无法下注");
	elseif data.errorCode == 7 then--庄家信息错误
		self:TipTextShow("庄家信息错误");
	elseif data.errorCode == 8 then--超出最大下注配额
		self:TipTextShow("超出最大下注配额");
	elseif data.errorCode == 9 then--金币不足
		self:TipTextShow("金币不足");
		showBuyTip();
	elseif data.errorCode == 10 then--下注庄家金币不足
		self:TipTextShow("庄家金币不足");
	elseif data.errorCode == 11 then--庄家金币不足
		self:TipTextShow("庄家的金币少于坐庄必须金币数（"..(math.floor(self.xiaZhuangMoney/100)).."），自动下庄");
	elseif data.errorCode == 12 then
		self:TipTextShow("下注失败，您必须有30金币才能下注");
		showBuyTip();
	elseif data.errorCode == 13 then--庄家金币不足
		self:TipTextShow("由于你的金币少于坐庄必须金币数（"..(math.floor(self.xiaZhuangMoney/100)).."），你自动取消上庄");
	elseif data.errorCode == 14 then--庄家金币不足
		self:TipTextShow("庄家坐庄次数达到10，强行换庄");
	end
end
-------------------------------------------------------------------------------

--tableview的reloadData后的坐标问题（上下滚动）isNeedFlush是否需要滚动到顶
function TableLayer:CommomFunc_TableViewReloadData_Vertical(pTableView, singleCellSize, isNeedFlush)
    if isNeedFlush == true then
        -- 直接重新加载数据
        pTableView:reloadData();
    else
        -- 需要设定位置
        local currOffSet = pTableView:getContentOffset();
        local viewSize = pTableView:getViewSize();
        -- 重新加载数据
        pTableView:reloadData();
        -- 获取大小
        local contentSize = pTableView:getContentSize();
        -- 如果tableview内尺寸大于可视尺寸，需要设定当前的显示位置
        if contentSize.height > viewSize.height then
            -- 
            local minPointY = viewSize.height - contentSize.height;
            local maxPointY = 0;
            if currOffSet.y < minPointY then
                currOffSet.y = minPointY;
            elseif currOffSet.y > maxPointY then
                currOffSet.y = maxPointY;
            end
            pTableView:setContentOffset(currOffSet);
        end
    end    
end
--横向的tableView刷新数据
function TableLayer:CommomFunc_TableViewReloadData_Horizontal(pTableView, singleCellSize, isNeedFlush)
    if isNeedFlush == true then
        -- 直接重新加载数据
        pTableView:reloadData();
    else
        -- 需要设定位置
        local currOffSet = pTableView:getContentOffset();
        local viewSize = pTableView:getViewSize();
        -- 重新加载数据
        pTableView:reloadData();
        -- 获取大小
        local contentSize = pTableView:getContentSize();
        -- 如果tableview内尺寸大于可视尺寸，需要设定当前的显示位置
        if contentSize.width > viewSize.width then
            local minPointX = viewSize.width - contentSize.width;
            local maxPointX = 0;
            if currOffSet.x < minPointX then
                currOffSet.x = minPointX;
            elseif currOffSet.x > maxPointX then
                currOffSet.x = maxPointX;
            end
            currOffSet.x = minPointX;
            pTableView:setContentOffset(currOffSet);
        end
    end    
end
--历史结果列表
--cell点击事件
function TableLayer:resultCellTouched(table,cell)
    --CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, cc.size( 200, self.Panel_userInfo:getContentSize().height+10), false);
end
--列表项的尺寸
function TableLayer:result_cellSizeForTable(sender, index)
	local panelSize = self.Panel_resultInfo:getContentSize();
    return panelSize.width,panelSize.height;
end

--列表项的数量 
function TableLayer:result_numberOfCellsInTableView(sender)
    return #self.gameHistoryList;
end

--创建列表项
function TableLayer:result_tableCellAtIndex(sender, index)   
    local cell = sender:dequeueCell();
    if nil == cell then
        cell = cc.TableViewCell:new();
        local gamePanel = self.Panel_resultInfo:clone();
        gamePanel:ignoreContentAdaptWithSize(true);
		gamePanel:setVisible(true);
		gamePanel:setAnchorPoint(cc.p(0,0));
		local panelSize = gamePanel:getContentSize();  
        gamePanel:setPosition(cc.p(0,0));  
        cell:addChild(gamePanel);
        self:SetResultInfo(gamePanel, index);
    else
        local gamePanel = cell:getChildByName("Panel_resultInfo");
        self:SetResultInfo(gamePanel, index);
	end
    
    return cell;
end

function TableLayer:SetResultInfo(gamePanel,idx)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	local resultInfo = self.gameHistoryList[idx+1];
	local diceNum = resultInfo[2];
	for i = 1,3 do--设置点数的图片
		gamePanel:getChildByName("Image_resultDice"..i):loadTexture("yyy_result"..(diceNum%10)..".png",UI_TEX_TYPE_PLIST);
		diceNum = math.floor(diceNum/10);
	end
	--设置点数和
	gamePanel:getChildByName("AtlasLabel_resultNum"):setString(resultInfo[3]..":;");
	--判断大小
    local judgeImage = gamePanel:getChildByName("Image_SumJudge");
    if resultInfo[4] == 2 then--大
        judgeImage:loadTexture("yyy_resultda.png",UI_TEX_TYPE_PLIST);
    elseif resultInfo[4] == 3 then--豹子
        judgeImage:loadTexture("yyy_resultbao.png",UI_TEX_TYPE_PLIST);
    else--小
        judgeImage:loadTexture("yyy_resultxiao.png",UI_TEX_TYPE_PLIST);
    end
end

--用户列表
--cell点击事件
function TableLayer:tableCellTouched(table,cell)
    --CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, cc.size( 200, self.Panel_userInfo:getContentSize().height+10), false);
end
--列表项的尺寸
function TableLayer:tabel_cellSizeForTable(sender, index)
    local itemSize = self.Panel_userInfo:getContentSize();  
    return self.Panel_usrList:getChildByName("Panel_size"):getContentSize().width, itemSize.height+10;
end

--列表项的数量 
function TableLayer:tabel_numberOfCellsInTableView(sender)
    return #self.saveOtherInfo;
end

--创建列表项
function TableLayer:tabel_tableCellAtIndex(sender, index)   
    local cell = sender:dequeueCell();
    if nil == cell then
        cell = cc.TableViewCell:new();
        local gamePanel = self.Panel_userInfo:clone();
        gamePanel:ignoreContentAdaptWithSize(true);
        gamePanel:setVisible(true);  
        gamePanel:setPosition(cc.p(self.Panel_usrList:getChildByName("Panel_size"):getContentSize().width/2,gamePanel:getContentSize().height/2+5));  
        cell:addChild(gamePanel);
        self:SetGameBtnInfo(gamePanel, index);     
    else
        local gamePanel = cell:getChildByName("Panel_userInfo");
        self:SetGameBtnInfo(gamePanel, index);
	end
	
    
    return cell;
end

function TableLayer:SetGameBtnInfo(gamePanel,idx)
	gamePanel:getChildByName("Text_name"):setText(FormotGameNickName(self.saveOtherInfo[idx+1].nickName,nickNameLen));   
	self:ScoreToMoney(gamePanel:getChildByName("Text_money"),self.saveOtherInfo[idx+1].i64Money);
	local playerHead = gamePanel:getChildByName("Image_headKuang");
	playerHead:loadTexture(getHeadPath(self.saveOtherInfo[idx+1].bLogoID,self.saveOtherInfo[idx+1].bBoy));
	playerHead:ignoreContentAdaptWithSize(true);
	playerHead:setScale(60/145);
end

function TableLayer:UpdateUserList()
	self.saveOtherInfo = {};
    for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
    	if userInfo then
	        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
	            table.insert(self.saveOtherInfo,userInfo)
	        end
	    end
	end
	local userInfo = nil;
	if self.bankStation >= 0 then
		userInfo = self.tableLogic:getUserBySeatNo(self.bankStation);
		if userInfo then
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
		end
	end
	
	self.Text_userNum:setString(#self.saveOtherInfo);
	if self.gameBtnTableView then
		self:CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, self.Panel_userInfo:getContentSize(), true);
	end
end
--更新庄家
function TableLayer:UpdateBankInfo()
	local userInfo = nil;
	if self.bankStation > 0 then
		userInfo = self.tableLogic:getUserBySeatNo(self.bankStation);
		if userInfo then
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
		end
	end
end

--提示小字符
function TableLayer:TipTextShow(tipText)
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
	-- local textBg = cc.Sprite:createWithSpriteFrameName("yyy_tishi.png");
	-- textBg:setPosition(640,500);
	-- self:addChild(textBg,301)

	-- local text = cc.Label:createWithSystemFont(tipText,"Arial", 26);
	-- text:setPosition(textBg:getContentSize().width/2,textBg:getContentSize().height/2);
	-- text:setColor(cc.c3b(255,255,0));
	-- textBg:addChild(text);

	-- if self.tipTextTable[3] then
	-- 	self:removeChild(self.tipTextTable[3]);
	-- end

	-- for i = 3,2,-1 do
	-- 	self.tipTextTable[i] = self.tipTextTable[i-1];
	-- 	if self.tipTextTable[i] then
	-- 		local posY = self.tipTextTable[i]:getPositionY()+text:getContentSize().height;
	-- 		self.tipTextTable[i]:setPositionY(posY);
	-- 	end
	-- end
	-- self.tipTextTable[1] = textBg;
	-- --显示消失动画
	-- textBg:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.FadeOut:create(1)))
	-- text:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.FadeOut:create(1)))
	addScrollMessage(tipText);
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

function TableLayer:JudgeSelfThrow(chipMoney,chipArea,chipType)
	local mySeatNo = self.tableLogic:getMySeatNo();
    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
    if userInfo then
	    if userInfo.i64Money < SettlementInfo:getConfigInfoByID(46) then
	        self:TipTextShow("下注失败，您必须有"..(SettlementInfo:getConfigInfoByID(46)/100).."金币才能下注");
	        showBuyTip();
	        return false;
	    end
	end
    self.tableLogic:sendPutChipInfo(false,chipMoney,chipArea,chipType);
    return true;
end



return TableLayer;