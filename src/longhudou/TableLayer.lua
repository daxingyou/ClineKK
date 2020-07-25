local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("longhudou.TableLogic");
local GameRuleLayer = require("longhudou.GameRuleLayer");
local LZLogic = require("longhudou.LZLogic");
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

--下注的位置(三个区域，根据大小随机+-)
local chipRandomPos = {
	cc.p(406,380),--150,70
	cc.p(872,380),--150,70
	cc.p(639,220),--450,50
}

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
	LhdInfo:init();
	display.loadSpriteFrames("longhudou/chip/chip.plist","longhudou/chip/chip.png");
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	local uiTable = {
		Image_bg = "Image_bg",
		Button_back = "Button_back",
		Button_otherUser = "Button_otherUser",
		Sprite_gerenxinxi = "Sprite_gerenxinxi",
		Button_otherButton = "Button_otherButton",

		-- Button_back = "Button_back",
		-- Button_otherButton = "Button_otherButton",

		AtlasLabel_clock = "AtlasLabel_clock",
		Image_gameState = "Image_gameState",

		Node_score = "Node_score",
		Button_score1 = "Button_score1",
		Button_score2 = "Button_score2",
		Button_score3 = "Button_score3",
		Button_score4 = "Button_score4",
		Button_score5 = "Button_score5",
		Button_score6 = "Button_score6",
		Button_throw = "Button_throw",

		Button_village = "Button_village",
		Image_apply = "Image_apply",
		Text_lianNum = "Text_lianNum",
		Text_BankMoney = "Text_BankMoney",
		Text_BankName = "Text_BankName",
		Text_personNum = "Text_personNum",
		Text_applyNum = "Text_applyNum",
		Image_zhuangjinbi = "Image_zhuangjinbi",

		Node_luzi = "Node_luzi",
		Image_heipaidi = "Image_heipaidi",
		Image_hongpaidi = "Image_hongpaidi",
		Node_bipaicartoon = "Node_bipaicartoon",
		Button_luzi = "Button_luzi",
		--ListView_luzi2 = "ListView_luzi2",

		--Button_otherUser = "Button_otherUser",
		Text_userNum = "Text_userNum",
		Panel_usrList = "Panel_usrList",
		Panel_size = "Panel_size",
		Panel_userInfo = "Panel_userInfo",
		Image_headKuang = "Image_headKuang",
		Text_name = "Text_name",
		Text_money = "Text_money",

		-- Image_otherBtnBg = "Image_otherBtnBg",
		-- Button_effect = "Button_effect",
		-- Button_music = "Button_music",
		-- Button_rule = "Button_rule",
		-- Button_insurance = "Button_insurance",

		Node_cast = "Node_cast",
		Button_cast1_1 = "Button_cast1_1",
		Button_cast1_2 = "Button_cast1_2",
		Button_cast2_1 = "Button_cast2_1",
		Button_cast2_2 = "Button_cast2_2",
		Button_cast3_1 = "Button_cast3_1",
		Image_anliang1 = "Image_anliang1",
		Image_anliang2 = "Image_anliang2",
		Image_anliang3 = "Image_anliang3",
		Image_liang1 = "Image_liang1",
		Image_liang2 = "Image_liang2",
		Image_liang3 = "Image_liang3",
		AtlasLabel_all1 = "AtlasLabel_all1",
		AtlasLabel_all2 = "AtlasLabel_all2",
		AtlasLabel_all3 = "AtlasLabel_all3",
		AtlasLabel_me1 = "AtlasLabel_me1",
		AtlasLabel_me2 = "AtlasLabel_me2",
		AtlasLabel_me3 = "AtlasLabel_me3",

		Text_playerName = "Text_playerName",
		Text_playerMoney = "Text_playerMoney",
		Image_mejinbi = "Image_mejinbi",

		Text_playerChange = "Text_playerChange",
		Text_bankMoneyChange = "Text_bankMoneyChange",
		Text_otherPlayerChange = "Text_otherPlayerChange",

		Node_tips = "Node_tips",
		Image_bankChange = "Image_bankChange",
		Node_startAnimate = "Node_startAnimate",

		Panel_chip = "Panel_chip",
		Node_chip = "Node_chip",

		Image_gerenxinxi = "Image_gerenxinxi",


		--路子
		Panel_zhu = "Panel_zhu",
		Panel_da = "Panel_da",
		Panel_yan = "Panel_yan",
		Panel_xiao = "Panel_xiao",
		Panel_ry = "Panel_ry",
		Panel_lw = "Panel_lw",
		Panel_hw = "Panel_hw",
		AtlasLabel_lSum = "AtlasLabel_lSum",
		AtlasLabel_hSum = "AtlasLabel_hSum",
		AtlasLabel_pSum = "AtlasLabel_pSum",


		--其他6个玩家
		Image_player1 = "Image_player1",
		Image_player2 = "Image_player2",
		Image_player3 = "Image_player3",
		Image_player4 = "Image_player4",
		Image_player5 = "Image_player5",
		Image_player6 = "Image_player6",

		Sprite_gerenxinxi = "Sprite_gerenxinxi",

		--连庄
		Node_successive = "Node_successive",
		AtlasLabel_successive = "AtlasLabel_successive",

		--上庄列表
		Button_szList = "Button_szList",
		Image_szList = "Image_szList",
		Panel_szList = "Panel_szList",
		ListView_szList = "ListView_szList",

	}

	loadNewCsb(self,"longhudou/GameScene",uiTable);

	--适配iPhone X
	local framesize = cc.Director:getInstance():getWinSize()
	local addWidth = (framesize.width - 1280)/4;

	for i = 1,6 do
		if i%2~=0 then
			self["Image_player"..i]:setPositionX(self["Image_player"..i]:getPositionX()-addWidth);
		else
			self["Image_player"..i]:setPositionX(self["Image_player"..i]:getPositionX()+addWidth);
		end
	end

	self.Sprite_gerenxinxi:setPositionX(self.Sprite_gerenxinxi:getPositionX()-addWidth);
	self.Button_back:setPositionX(self.Button_back:getPositionX()-addWidth);
	self.Button_otherUser:setPositionX(self.Button_otherUser:getPositionX()-addWidth);
	self.Button_throw:setPositionX(self.Button_throw:getPositionX()+addWidth);
	self.Button_otherButton:setPositionX(self.Button_otherButton:getPositionX()+addWidth);

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

	self:initData();
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
	
	self:pushEventInfo(LhdInfo,"ErrorCode",handler(self, self.DealErrorCode));
	self:pushEventInfo(LhdInfo,"GameBegin",handler(self, self.DiceGameStartInfo));
	self:pushEventInfo(LhdInfo,"NoteResult",handler(self, self.PutChipInfoGame));
	self:pushEventInfo(LhdInfo,"OpenCard",handler(self, self.ResultMessageInfo));
	self:pushEventInfo(LhdInfo,"ShangZhuang",handler(self, self.BankStateInfoGame));
	self:pushEventInfo(LhdInfo,"WuZhuang",handler(self, self.DealNoBankWait));
	self:pushEventInfo(LhdInfo,"NoteBack",handler(self, self.DealNoteBack));
	self:pushEventInfo(LhdInfo,"ZhuangScore",handler(self, self.DealZhuangScore));
	self:pushEventInfo(LhdInfo,"XuTOU",handler(self, self.DealXuTOU));

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

		    --更新玩家头像
		    self.Image_gerenxinxi:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		end
	    self:ChipJundge();

	    --第一次进入 绘制其他玩家
	    -- local count = 1;
	    -- for k,userInfo in pairs(self.saveOtherInfo) do
	    -- 	if count<=6 and self["Image_player"..count]:getTag() == -1 then
	    -- 		self["Image_player"..count]:setTag(userInfo.bDeskStation);
	    -- 		self["Image_player"..count].userId = userInfo.dwUserID;
	    -- 		self["Image_player"..count]:setVisible(true);
	    -- 		self["Image_player"..count]:getChildByName("Image_playerHead"):loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
	    -- 		self["Image_player"..count]:setPosition(self.otherUserSetPos[count]);
	    -- 		self["Image_player"..count]:getChildByName("AtlasLabel_score"):setVisible(false);
	    -- 		local userdi = self["Image_player"..count]:getChildByName("Image_di");
	    -- 		local name = userdi:getChildByName("Text_name");
	    -- 		name:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
	    -- 		local money = userdi:getChildByName("Text_money");
	    -- 		money:setString(self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money));
	  		-- else
	  		-- 	break;
	    -- 	end
	    -- 	count = count+1;
	    -- end

	else--后面加的玩家
		-- for i = 1,6 do
		-- 	local imagePlayer = self["Image_player"..i];
		-- 	if imagePlayer:getTag() >= 0 then
		-- 		local imagePlayer = self["Image_player"..i];
		-- 		if seatNo == self.tableLogic:logicToViewSeatNo(imagePlayer:getTag()) then
		-- 			return;
		-- 		end
		-- 	end
		-- end

		-- for i = 1,6 do
		-- 	local imagePlayer = self["Image_player"..i];
		-- 	if imagePlayer:getTag() == -1 then
		-- 		local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.tableLogic:viewToLogicSeatNo(deskStation));
		-- 		imagePlayer:setTag(userInfo.bDeskStation);
	 --    		imagePlayer.userId = userInfo.dwUserID;
	 --    		imagePlayer:setVisible(true);
	 --    		imagePlayer:getChildByName("Image_playerHead"):loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
	 --    		imagePlayer:setPosition(self.otherUserSetPos[i]);
	 --    		imagePlayer:getChildByName("AtlasLabel_score"):setVisible(false);
	 --    		local userdi = imagePlayer:getChildByName("Image_di");
	 --    		local name = userdi:getChildByName("Text_name");
	 --    		name:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
	 --    		local money = userdi:getChildByName("Text_money");
	 --    		money:setString(self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money));
	 --    		break;
		-- 	end
		-- end
	end

end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
    
    if not self:isValidSeat(seatNo) then 
        return;
    end

    for i = 1,6 do
    	local imagePlayer = self["Image_player"..i];
    	if imagePlayer:getTag() >= 0 then
	    	if seatNo == self.tableLogic:logicToViewSeatNo(imagePlayer:getTag()) then
	    		imagePlayer:setVisible(false);--先隐藏 再过一秒显示其他人
	    		imagePlayer:setTag(-1);
	    		imagePlayer:stopAllActions();
	    		imagePlayer:getChildByName("AtlasLabel_score"):setVisible(false);
	    		imagePlayer.userId = -1;
	    		break;
	    	end
	    end
    end

    self:UpdateUserList();

    -- if count ~= 0 then
    -- 	for k,userInfo in pairs(self.saveOtherInfo) do
    -- 		local flag = false;
    -- 		for i =1,6 do
    -- 			local imagePlayer = self["Image_player"..i];
    -- 			if imagePlayer:getTag() == userInfo.bDeskStation then
    -- 				flag = true;
    -- 				break;
    -- 			end
    -- 		end

    -- 		if flag == false then
    -- 			local imagePlayer = self["Image_player"..count];
    -- 			imagePlayer:setPosition(self.otherUserSetPos[count]);
	   --  		imagePlayer:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
    -- 				imagePlayer:setTag(userInfo.bDeskStation);
		  --   		imagePlayer:setVisible(true);
		  --   		imagePlayer:getChildByName("Image_playerHead"):loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		  --   		imagePlayer.userId = userInfo.dwUserID;

		  --   		local userdi = imagePlayer:getChildByName("Image_di");
		  --   		local name = userdi:getChildByName("Text_name");
		  --   		name:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		  --   		local money = userdi:getChildByName("Text_money");
		  --   		money:setString(self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money));

    -- 			end)))

    -- 			break;
    -- 		end
    -- 	end
    -- end
    
    local BackCallBack = function()
        local func = function()
            self.tableLogic:sendUserUp();
            self.tableLogic:sendForceQuit();
        end

        Hall:exitGame(false,func)   
    end

    if bIsMe then
        local str = ""
	    if bLock == 3 then
	      str ="长时间未操作,自动退出游戏。"
	      BackCallBack();
      	elseif bLock == 0 then
      		BackCallBack();
	    elseif bLock == 1 then
	      str ="您的金币不足,自动退出游戏。"
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
	self.isGameStation = false;
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
		self.isGameStation = false;

		self.tableLogic._bSendLogic = false;
		self.b_suo = false;
		self.tableLogic:sendGameInfo();

		self.Node_startAnimate:stopAllActions();
		-- self.Node_startAnimate:removeChildByName(WarnAnimName);
		self.Node_startAnimate:removeChildByName("ziSpine");
		self.Node_startAnimate:removeAllChildren();
		local colorLayer = self:getChildByName("colorLayer");
		if colorLayer then
			colorLayer:removeFromParent();
		end

		local longhudouziSpine = self:getChildByName("longhudouziSpine");
		if longhudouziSpine then
			longhudouziSpine:removeFromParent();
		end
		local colorLayer = self:getChildByName("colorLayer");
		if colorLayer then
			colorLayer:removeFromParent();
		end

		if #self.cardTable > 0 then
			for i,card in ipairs(self.cardTable) do
				card:removeFromParent();
			end
		end
		self.cardTable = {};
		self.Node_bipaicartoon:removeAllChildren();
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

	self.GameStatus = 21; --21下注中22开奖中
	self.saveOtherInfo = {};--其他玩家信息
	self.savePutChipMsg = {}; --其他人下注筹码缓存处理
	
	self.playerMoney = 0;--保存玩家金币

	self.iShangZhuangLimit = 4000000;--上庄所需要的钱
	self.iXiaZhuangLimit = 2000000;--下庄所需要的钱
	self.gameBet = false;--下注状态
	self.gameStart = false;--游戏开始状态
	self.bankStation = -1;---庄家位置
	self.selfAreaSave = {};--保存自己所选择的区域

	self.cardTable = {};--存储牌 

	self.chipSaveTable = {};--所有人下注的筹码
	for i=1,3 do
		self.chipSaveTable[i] = {};
	end
	self.selfAreaSave = {0,0,0};--保存自己下注的筹码
	self.recordData = {};--历史数据保存

	self.isGameStation = false;
	--筹码出发的三个位置
	local zpos = self.Image_zhuangjinbi:getParent():convertToWorldSpace(cc.p(self.Image_zhuangjinbi:getPosition()));--cc.p(300,580) -- 庄家位置
	local mpos = self.Image_mejinbi:getParent():convertToWorldSpace(cc.p(self.Image_mejinbi:getPosition()));--cc.p(110,65) --自己的位置
	local opos = self.Button_otherUser:getParent():convertToWorldSpace(cc.p(self.Button_otherUser:getPosition()));--cc.p(45,580) --其他用户的位置
	self.ZhuangPos = self.Node_chip:convertToNodeSpace(zpos);
	self.mePos = self.Node_chip:convertToNodeSpace(mpos);
	self.otherPos = self.Node_chip:convertToNodeSpace(opos);

	self.otherUserPos = {};
	self.otherUserSetPos = {};

	for i=1,6 do
		local opos = self["Image_player"..i]:getParent():convertToWorldSpace(cc.p(self["Image_player"..i]:getPosition()));
		self.otherUserPos[i] = self.Node_chip:convertToNodeSpace(opos);
		self.otherUserSetPos[i] = cc.p(self["Image_player"..i]:getPosition());
	end

	self.test = false;
	self.b_suo = false; -- 玩家是否可以退出
	self.b_xiazhu = false; -- 玩家是否下注

	self.pourChip = false;
	--不操作的局数
	self.mOperateGameCount = 0;
end
--初始化界面
function TableLayer:initUI()
	--基本按钮
	self:initGameNormalBtn();

	--加载初始化场景
	self:LoadGameScene();

	--初始化界面参数
	self:showDeskInfo();

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	--初始化音效音乐
    self:InitSet();
    self:InitMusic();

    local size = cc.p(self.Button_otherButton:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("longhudou",self);
    self.Image_bg:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(size.x,size.y-90);
    
    if globalUnit.isShowZJ then
	    self.m_logBar = LogBar:create(self,true);
	    self.Image_bg:addChild(self.m_logBar);
	end
end

function TableLayer:showDeskInfo()
	--下注区域的隐藏
	for i=1,3 do
		if self["Image_anliang"..i] then
			self["Image_anliang"..i]:setVisible(false);
		end
		if self["Image_liang"..i] then
			self["Image_liang"..i]:setVisible(false);
		end
		if self["AtlasLabel_all"..i] then
			self["AtlasLabel_all"..i]:setString(" ")
		end
		if self["AtlasLabel_me"..i] then
			self["AtlasLabel_me"..i]:setString(" ")
		end
	end


	self.Panel_usrList:setVisible(false);
	self:ChooseChip(1);--默认选择第一个筹码

	-- self.Image_heipai:setVisible(false);
	-- self.Image_hongpai:setVisible(false);

end

--初始化按钮
function TableLayer:initGameNormalBtn()

	--投资钱的数额
	for i = 1,6 do
		if self["Button_score"..i] then
			self["Button_score"..i]:setTag(i);
			self["Button_score"..i]:setLocalZOrder(10);
			self["Button_score"..i]:addClickEventListener(function(sender) 
				local effectState = getEffectIsPlay();
				if effectState then
					audio.playSound("longhudou/sound/sound-jetton.mp3");
				end

				self:ClickScoreCallBack(sender); 
			end);
		end
	end

	--------------------------投钱区域
	self.Button_cast1_1:setTag(1);
	self.Button_cast1_2:setTag(1);
	self.Button_cast1_1:addTouchEventListener(function(sender,eventType)
		self:ClickCastCallBack(sender,eventType);
	end);
	self.Button_cast1_2:addTouchEventListener(function(sender,eventType)
		self:ClickCastCallBack(sender,eventType);
	end);
	self.Button_cast2_1:setTag(2);
	self.Button_cast2_2:setTag(2);
	self.Button_cast2_1:addTouchEventListener(function(sender,eventType)
		self:ClickCastCallBack(sender,eventType);
	end);
	self.Button_cast2_2:addTouchEventListener(function(sender,eventType)
		self:ClickCastCallBack(sender,eventType);
	end);

	self.Button_cast3_1:setTag(3);
	self.Button_cast3_1:addTouchEventListener(function(sender,eventType)
		self:ClickCastCallBack(sender,eventType);
	end);
	----------------------------

	--下拉菜单
	if self.Button_otherButton then
		-- self.Button_otherButton:addClickEventListener(function(sender)
		-- 	self:ClickOtherButtonCallBack(sender);
		-- end);
		self.Button_otherButton:setLocalZOrder(10);
		self.Button_otherButton:onClick(handler(self,self.ClickOtherButtonCallBack))
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
		-- self.Button_otherUser:setLocalZOrder(10);
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
		self["Image_anliang"..senderTag]:setVisible(true)
	elseif eventType == ccui.TouchEventType.moved then
		
    elseif eventType == ccui.TouchEventType.ended then
    	luaPrint("投钱区按钮回调",senderTag,chipType);
		self["Image_anliang"..senderTag]:setVisible(false);
		
		if self.bankStation == self.tableLogic:getMySeatNo() then
			self:TipTextShow("庄家不能下注！");
			return;
		end

		if chipType == 0 and self.pourChip then
			self:TipTextShow("金币不足,下注失败");
			 showBuyTip();
			return;
		end
		self:JudgeSelfThrow(senderTag-1,self:ChipTypeToChipMoney(chipType),chipType);
		
	elseif eventType == ccui.TouchEventType.canceled then
		self["Image_anliang"..senderTag]:setVisible(false);
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
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
    --重新设置纹理
    if globalUnit.isShowZJ then
    	self.Image_otherBtnBg:loadTexture("zhanji_di.png");
    	self.Button_zhanji:loadTextures("zhanji_zhanji.png","zhanji_zhanji-on.png","zhanji_zhanji-on.png");
    else
    	self.Image_otherBtnBg:loadTexture("lhd_setdi.png",UI_TEX_TYPE_PLIST);
    end
    self:InitSet();

	local senderTag = sender:getTag();

	self.actonFinish = false;--将标志位置成false
	local actionTime = 0.3;
	local moveAction;

	if senderTag == 0 then--下拉
		sender:setTag(1);
		--sender:loadTextures("yyy_shouna1.png","yyy_shouna1.png","yyy_shouna1.png",UI_TEX_TYPE_PLIST);
		moveAction = cc.MoveTo:create(actionTime,cc.p(0,85-self.Image_otherBtnBg:getContentSize().height-80))
		--moveAction = cc.MoveTo:create(actionTime,cc.p(self.Image_otherBtnBg:getPositionX(),305));
		sender:loadTextures("lhd_xialaanniuup.png","lhd_xialaanniuup-on.png","lhd_xialaanniuup-on.png",UI_TEX_TYPE_PLIST);
	else--上拉
		sender:setTag(0);
		--sender:loadTextures("yyy_shouna.png","yyy_shouna.png","yyy_shouna.png",UI_TEX_TYPE_PLIST);
		moveAction = cc.MoveTo:create(actionTime,cc.p(0,85))
		--moveAction = cc.MoveTo:create(actionTime,cc.p(self.Image_otherBtnBg:getPositionX(),709));
		sender:loadTextures("lhd_xialaanniu.png","lhd_xialaanniu-on.png","lhd_xialaanniu-on.png",UI_TEX_TYPE_PLIST);
	end
	self.Image_otherBtnBg:runAction(cc.Sequence:create(moveAction,cc.CallFunc:create(function()
		self.actonFinish = true;
	end)));
end
--上庄
function TableLayer:ClickVillageCallBack(sender)
	local senderTag = sender:getTag();

	if senderTag == 0 then
		if self.playerMoney < self.iShangZhuangLimit then
			addScrollMessage("金币不足"..(math.floor(self.iShangZhuangLimit/100)).."，不能上庄");
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
	-- if self.gameBet == false and self.gameStart == true and not isHaveBankLayer() then--开奖状态不弹保险箱
	-- 	addScrollMessage("游戏开奖中，请稍后进行取款操作。");
	-- 	return;
	-- end

	createBank(function (data)
        self:DealBankInfo(data)
    end,self.GameStatus == 21);

	-- createBank(function(data)
	-- 	self:DealBankInfo(data);
	-- end,true);
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
		if v>0 then
			needMoney = needMoney + v;
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
	-- luaPrint(" TableLayer:ClickThrowCallBack",sender.areaId,self:ChipTypeToChipMoney(sender.chipType),sender.chipType)

	local needMoney = 0;
	for k,v in pairs(sender.selfAreaSave) do
		if v>0 then
			needMoney = needMoney + v;
		end
	end

	if needMoney <= self.playerMoney then
		-- for k,v in pairs(sender.selfAreaSave) do
		-- 	if v>0 then
		-- 		local scoreTable = self:GetChipScoreTable(v);

		-- 		for k1,score in pairs(scoreTable) do
		-- 			--没有数据返回 有数据则发送下注消息
		-- 			self:JudgeSelfThrow(k-1,self:ChipTypeToChipMoney(score),score);
		-- 		end
		-- 	end
		-- end
		self.tableLogic:sendXuTouMsg(sender.selfAreaSave);
	else
		addScrollMessage("续投金币不足");
	end

	--没有数据返回 有数据则发送下注消息
	-- self:JudgeSelfThrow(sender.areaId,self:ChipTypeToChipMoney(sender.chipType),sender.chipType);
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
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	local effectState = getEffectIsPlay();
	luaPrint("音效",effectState);
	if effectState then--开着音效
		setEffectIsPlay(false);
		--改变音效图片
		self.Button_effect:loadTextures("lhd_yinxiao-off.png","lhd_yinxiao-off-on.png","lhd_yinxiao-off-on.png",UI_TEX_TYPE_PLIST);
	else
		setEffectIsPlay(true);
		self.Button_effect:loadTextures("lhd_yinxiao.png","lhd_yinxiao-on.png","lhd_yinxiao-on.png",UI_TEX_TYPE_PLIST);	
	end

end
--音乐
function TableLayer:ClickMusicCallBack(sender)
	if self.actonFinish == false then
		return;
	end
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	local musicState = getMusicIsPlay();
	luaPrint("音乐",musicState);
	if musicState then--开着音效
		setMusicIsPlay(false);
		self.Button_music:loadTextures("lhd_yinyue-off.png","lhd_yinyue-off-on.png","lhd_yinyue-off-on.png",UI_TEX_TYPE_PLIST);
	else
		setMusicIsPlay(true);
		self.Button_music:loadTextures("lhd_yinyue.png","lhd_yinyue-on.png","lhd_yinyue-on.png",UI_TEX_TYPE_PLIST);	
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

    self.Node_bipaicartoon:setLocalZOrder(11);

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
		        	skeleton_animation:setPosition(640,300);
		        	skeleton_animation:setName(WarnAnimName);
		        end
				local effectState = getEffectIsPlay();
	        	self.Node_startAnimate:runAction(cc.Sequence:create(
					cc.DelayTime:create(0),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end
        				if effectState then
        					audio.playSound("longhudou/sound/sound-clock-count.mp3");
        				end
		        	end),
					cc.DelayTime:create(1),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end
	        			if effectState then
        					audio.playSound("longhudou/sound/sound-clock-count.mp3");
        				end
		        	end),
					cc.DelayTime:create(1),cc.CallFunc:create(function()
						if self.gameStart == false then
							return;
						end
	        			if effectState then
        					audio.playSound("longhudou/sound/sound-clock-count.mp3");
        				end
		        	end)))
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

    --先将6个玩家的头像隐藏
    for i = 1,6 do
    	self["Image_player"..i]:setVisible(false);
    	self["Image_player"..i]:setTag(-1);--座位
    	self["Image_player"..i]:getChildByName("AtlasLabel_score"):setVisible(false);
    	self["Image_player"..i].userId = -1;
    end

    --桌子号
    local size = self.Image_bg:getContentSize();
    local deskNoBg = ccui.ImageView:create("whichtable.png")
    deskNoBg:setAnchorPoint(0.5,1)
    deskNoBg:setPosition(self.Button_back:getContentSize().width/2,7)
    deskNoBg:setScale(0.8)
    self.Button_back:addChild(deskNoBg)

    local deskNo = FontConfig.createWithCharMap(self.bDeskIndex+1,"number/longhudou_zhuohao.png",24,32,"0")
    deskNo:setPosition(35,deskNoBg:getContentSize().height/2)
    deskNo:setScale(0.6)
    deskNo:setAnchorPoint(1,0.5)
    deskNoBg:addChild(deskNo)
end
--初始化音乐音效
function TableLayer:InitSet()
	self.Image_otherBtnBg:setLocalZOrder(101);
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	--保险箱
	self.Button_insurance:loadTextures("lhd_baoxianxiangsp.png","lhd_baoxianxiangsp-on.png","lhd_baoxianxiangsp-on.png",UI_TEX_TYPE_PLIST);
	--规则
	self.Button_rule:loadTextures("lhd_guize.png","lhd_guize-on.png","lhd_guize-on.png",UI_TEX_TYPE_PLIST);
	--音效
	local effectState = getEffectIsPlay();
	if effectState then--开着音效
		self.Button_effect:loadTextures("lhd_yinxiao.png","lhd_yinxiao-on.png","lhd_yinxiao-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_effect:loadTextures("lhd_yinxiao-off.png","lhd_yinxiao-off-on.png","lhd_yinxiao-off-on.png",UI_TEX_TYPE_PLIST);
	end
	--音乐
	local musicState = getMusicIsPlay();
	if musicState then--开着音效
		self.Button_music:loadTextures("lhd_yinyue.png","lhd_yinyue-on.png","lhd_yinyue-on.png",UI_TEX_TYPE_PLIST);	
	else
		self.Button_music:loadTextures("lhd_yinyue-off.png","lhd_yinyue-off-on.png","lhd_yinyue-off-on.png",UI_TEX_TYPE_PLIST);
	end
end
--初始化背景音乐
function TableLayer:InitMusic()
	local musicState = getMusicIsPlay();
	if musicState then
		audio.playMusic("longhudou/sound/sound-bg.mp3", true)
	else
		audio.stopMusic();
	end
end

--创建筹码
function TableLayer:ChipCreate(chipType,beginPos)
	luaPrint("TableLayer:ChipCreate",chipType)
	--创建
	display.loadSpriteFrames("longhudou/chip/chip.plist","longhudou/chip/chip.png");
	local chipSp = cc.Sprite:createWithSpriteFrameName("honghei_chouma_"..chipType..".png");
	chipSp:setTag(chipType);
	chipSp:setScale(0.35);
	chipSp:setPosition(beginPos);
	self.Node_chip:addChild(chipSp);

	return chipSp;
end

--根据下注区域获取筹码生成的随机位置
function TableLayer:getRandomPosByType(type1)--type 1,2,3
	local randomPos = clone(chipRandomPos[type1]);
	--下注的位置(三个区域，根据大小随机+-)
	-- 	local ram1 = 1;
	-- local ram2 = 3;
	-- if self.test then
	-- 	self.test = false;
	-- 	ram1 = 2;
	-- 	ram2 = 4;
	-- else
	-- 	self.test = true;
	-- 	ram1 = 1;
	-- 	ram2 = 3;
	-- end
	-- local ram = {400,-400,30,-30}
	-- randomPos  = cc.p(640,160);
	-- randomPos.x = randomPos.x + ram[ram1]--math.random(0,220)-110;
	-- randomPos.y = randomPos.y - ram[ram2] --math.random(0,100)-50;
	if type1 == 3 then
		randomPos.x = randomPos.x + math.random(0,700)-350;
		randomPos.y = randomPos.y + math.random(0,50)-30;
	else
		randomPos.x = randomPos.x + math.random(0,200)-100;
		randomPos.y = randomPos.y + math.random(0,60)-40;
	end
	return randomPos;
end

--筹码移动动画实现
function TableLayer:ChipMove(chipNode,endPos,random,callBack)
	if chipNode then
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
		chipNode:runAction(cc.Sequence:create(chipMove,cc.CallFunc:create(function()
			ChipMoveCallBack();
		end)));
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
			chipAction:setPosition(size.width/2,size.height/2+5*1.2);
			chipAction:setScale(1.2);
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
		self["Button_score"..i]:setPositionY(71);
		self["Button_score"..i].selectTag = 0;--筹码选中标志置为0
		self:ShowChipAction(self["Button_score"..i],false);
		if i == chipType and self["Button_score"..i]:isEnabled() then
			self["Button_score"..i]:setPositionY(81);
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
		self["Button_score"..i]:setPositionY(71);
		self["Button_score"..i]:setEnabled(false);
		if default then
			self["Button_score"..i].selectTag = 0;
		end
		self:ShowChipAction(self["Button_score"..i],false);
	end
	self.Button_throw:setEnabled(false);
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
	self.Node_chip:removeAllChildren();
	self.chipSaveTable = {};
	for i=1,3 do
		self.chipSaveTable[i] = {};
	end
	
	self.selfAreaSave = {0,0,0};--保存自己所选择的区域

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
	local AreachipChipSum = {0,0,0}
	if chipSumTable then
		for i,v in ipairs(chipSumTable) do
			AreachipChipSum[i] = v;
		end
	end
	for i=1,3 do
		if AreachipChipSum[i] > 0 then
			self:ScoreToMoney(self["AtlasLabel_all"..i],AreachipChipSum[i]); 
		else
			self["AtlasLabel_all"..i]:setString(" ")
		end
	end
end
--转换成区域下注
function TableLayer:ChangeMyareaChip(type,chipType)
	local myChipMoney = {};
	for i = 1,GameMsg.NOTE_TYPE_COUNT do
		myChipMoney[i] = 0;
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
	local AreachipChipSum = {0,0,0}
	if chipSumTable then
		for i,v in ipairs(chipSumTable) do
			AreachipChipSum[i] = v;
		end
	end
	luaDump(chipSumTable,"刷新自己下注的注额")
	for i=1,3 do
		if AreachipChipSum[i] > 0 then
			-- self.pourChip = true;
			self:ScoreToMoney(self["AtlasLabel_me"..i],AreachipChipSum[i]); 
		else
			self["AtlasLabel_me"..i]:setString(" ")
		end
	end
end

--庄家和自己的钱增加减少动画效果
function TableLayer:MoneyActionShow(pNode)
	-- pNode:setVisible(true);
	-- pNode:setOpacity(0);
	-- local action1 = cc.MoveBy:create(1.5,cc.p(0,50));
	-- local action2 = cc.CallFunc:create(function() pNode:setVisible(false); end);
	-- local action3 = cc.MoveBy:create(0.1,cc.p(0,-50));  
	-- pNode:runAction(cc.Sequence:create(action1,action2,action3));
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
	for k,v in ipairs(winArea) do
		if v then
			local liang = self["Image_liang"..k];
			liang:setVisible(true);
			liang:setOpacity(0);
			local fadeOutAction = cc.FadeOut:create(0.15);
			local fadeInAction = cc.FadeIn:create(0.15);
			local repeatAction = cc.Repeat:create(cc.Sequence:create(fadeInAction,fadeOutAction),5);

			liang:runAction(cc.Sequence:create(repeatAction,cc.CallFunc:create(function()
				liang:setVisible(false);
			end)))
		end
	end
end
--停止赢钱动画
function TableLayer:StopWinAreaAction()
	
end
--随机加载下注筹码
function TableLayer:AddAreaChip(areaData)
	for i=1,3 do
		local totalScore = areaData[i];
		local scoreTable = self:GetChipScoreTable(totalScore);

		for k,score in pairs(scoreTable) do
			-- local castNode = self.buttonCast[v];
			-- local castPos = cc.p(castNode:getPosition());
			local randomPos = self:getRandomPosByType(i)
			local chipSp = self:ChipCreate(score,randomPos);
			chipSp.userStation = -1;
			table.insert(self.chipSaveTable[i],chipSp);
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
			ziSpine:setPosition(640,360);
			ziSpine:setAnimation(1,"dengxiaju", true);
			ziSpine:setName("ziSpine");
			self.Node_startAnimate:addChild(ziSpine,10);
		end
		return;
	end

	local time = 0;
	if iType == 3 then
		time = 1.5;
		--local winSize = cc.Director:getInstance():getWinSize()
		local colorLayer = display.newLayer(cc.c4f(0, 0, 0, 0))
		colorLayer:setOpacity(200)
		colorLayer:setPosition(0,0)
		colorLayer:setName("colorLayer")
		self:addChild(colorLayer,10)
		colorLayer:onTouch(function(event) 
						local eventType = event.name
						if eventType == "began" then
							return true
						end
			end,false, true)
		-- if self:getChildByName("LuZiLayer") then
		-- 	colorLayer:removeFromParent();
		-- end
		local ziSpine = createSkeletonAnimation("longhudou1","longhudou/cartoon/longhudou/longhudou.json","longhudou/cartoon/longhudou/longhudou.atlas");
		if ziSpine then
			local winSize = cc.Director:getInstance():getWinSize()
			ziSpine:setPosition(winSize.width/2,winSize.height/2);
			ziSpine:setAnimation(1,"longhudou", false);
			ziSpine:setName("longhudouziSpine");
			self:addChild(ziSpine,11);

			local effectState = getEffectIsPlay();
			if effectState then
				audio.playSound("longhudou/sound/sound-battle.mp3");
			end
		end
	end
	self.Node_startAnimate:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()--展示闪烁再显示结算和动画
		local ziSpine = self.Node_startAnimate:getChildByName("ziSpine");
		if ziSpine then
			ziSpine:removeFromParent();
		end

		local longhudouziSpine = self:getChildByName("longhudouziSpine");
		if longhudouziSpine then
			longhudouziSpine:removeFromParent();
		end

		local colorLayer = self:getChildByName("colorLayer");
		if colorLayer then
			colorLayer:removeFromParent();
		end

		if iType == 3 then
			audio.playSound("longhudou/sound/sound-start-wager.mp3");--开始下注
		end
		
		local ziSpine = createSkeletonAnimation("kaishixiazhu","hall/game/kaishitingzhi.json","hall/game/kaishitingzhi.atlas");
		if ziSpine then
			ziSpine:setPosition(640,360);
			ziSpine:setAnimation(1,tipzi[iType], false);
			ziSpine:setName("ziSpine");
			self.Node_startAnimate:addChild(ziSpine,10);
		end
	end)));
	
end
--存储历史记录过滤没有的记录
function TableLayer:GameHisitorySave(historyInfo,isNeedFlush)
	local newTable = {};

	if isNeedFlush then
		for k,v in pairs(historyInfo) do
			if v.iWinner~=255 then
				table.insert(newTable,v);
			end
		end

		-- if #newTable>20 then
		-- 	self.recordData = {};
		-- 	for k,v in pairs(newTable) do
		-- 		if k>#newTable-20 then
		-- 			table.insert(self.recordData,v);
		-- 		end
		-- 	end
		-- else
		-- 	self.recordData = newTable;
		-- end
		self.recordData = newTable;
	else
		table.insert(self.recordData,historyInfo);
	end

	self:RefreshAllLZ(self.recordData,isNeedFlush);

end

--设置按钮上下庄状态
function TableLayer:SetButtonVillageState(buttonState)
	luaPrint("设置按钮上下庄状态",buttonState)
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	if buttonState == villageState.zUserStatus_Null then--空闲状态
		self.Button_village:setTag(0);
		self.Button_village:loadTextures("lhd_shangzhuang.png","lhd_shangzhuang-on.png","lhd_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
	elseif buttonState == villageState.zStatus_IsZhuang then--坐庄状态
		self.Button_village:setTag(2);
		self.Button_village:loadTextures("lhd_xiazhuang.png","lhd_xiazhuang-on.png","lhd_xiazhuang-on.png",UI_TEX_TYPE_PLIST);
	elseif buttonState == villageState.zUserStatus_InList then--申请上庄状态
		luaPrint("设置按钮上下庄状态申请上庄状态",buttonState)
		self.Button_village:setTag(1);
		self.Button_village:loadTextures("lhd_qxsz.png","lhd_qxsz-on.png","lhd_qxsz-on.png",UI_TEX_TYPE_PLIST);
	elseif buttonState == villageState.zStatus_XiaZhuang then--申请下庄状态
		self.Button_village:setTag(3);
		self.Button_village:loadTextures("lhd_qxxz.png","lhd_qxxz-on.png","lhd_qxxz-on.png",UI_TEX_TYPE_PLIST);
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
	if self.isGameStation == false then
		luaPrint("场景消息前面收到上庄，不处理")
		return;	
	end

	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	--判断上庄按钮
	self:SetButtonVillageState(data.iZhuangStatus);
	if data.success == 0 then--庄失败
		
	elseif data.success == 1 then--庄成功
		-- if data.station == self.tableLogic:getMySeatNo() then
		-- 	if data.bCancel then
		-- 		if data.shang then
		-- 			self:SetButtonVillageState(villageState.zUserStatus_Null);
		-- 		else
		-- 			self:SetButtonVillageState(villageState.zStatus_IsZhuang);
		-- 		end
		-- 	else
		-- 		if data.shang then
		-- 			self:SetButtonVillageState(villageState.zStatus_IsZhuang);
		-- 		else
		-- 			self:SetButtonVillageState(villageState.zStatus_XiaZhuang);
		-- 		end

		-- 	end
		-- end
	elseif data.success == 2 then--加入上庄列表
		-- if data.station == self.tableLogic:getMySeatNo() then--如果是自己进行操作
		-- 	self:SetButtonVillageState(villageState.zUserStatus_InList);
		-- end
	elseif data.success == 3 then--移除上庄列表
		-- if data.station == self.tableLogic:getMySeatNo() then--如果是自己进行操作
		-- 	self:SetButtonVillageState(villageState.zUserStatus_Null);
		-- end
	elseif data.success == 4 then--换庄
		-- if data.station == self.tableLogic:getMySeatNo() then
		-- 	--自己成为庄家设置按钮下庄
		-- 	self:SetButtonVillageState(villageState.zStatus_IsZhuang);
		-- else
		-- 	if self.bankStation == self.tableLogic:getMySeatNo() then
		-- 		self:SetButtonVillageState(villageState.zUserStatus_Null);
		-- 	end
		-- end
		--庄家轮换
		self:TipActionShow(self.Image_bankChange);

		local effectState = getEffectIsPlay();
		if effectState then
			audio.playSound("longhudou/sound/zhuang-change.mp3");
		end

		self.bankStation = data.station;
		local userInfo = self.tableLogic:getUserBySeatNo(data.station);
		if userInfo then
			self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
		end
		self.b_suo = false; -- 玩家是否可以退出
		self.b_xiazhu = false; -- 玩家是否下注
	elseif data.success == 5 then--直接成为庄家
		-- if data.station == self.tableLogic:getMySeatNo() then--如果是自己则将按钮变为下庄按钮
		-- 	self:SetButtonVillageState(villageState.zStatus_IsZhuang);
		-- end

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
	 luaDump(data,"下注信息----------");
	if data.moneytype == 0 then
		return;
	end

	local mySeatNo = self.tableLogic:getMySeatNo();
	if mySeatNo == data.station then
		self:DealPutChipMsg({data});
		self.b_xiazhu = true;
		self.Button_throw:setEnabled(false);
	else
		table.insert(self.savePutChipMsg,data);
	end
	--刷新筹码总额
	self:UpdateAreaChipSum(data.m_iQuYuZhu);
	if self.bankStation ~= mySeatNo and mySeatNo == data.station then
		-- self:RememberChipThrow(data.moneytype,data.type);
		self:ChipJundge(false);
	end
end
--处理下注筹码
function TableLayer:DealPutChipMsg(msg)
	if self.gameStart == false then
		return;
	end
	for i,data in ipairs(msg) do
		local beginPos = self.otherPos; --cc.p(60,390);
		local mySeatNo = self.tableLogic:getMySeatNo();
		-- luaPrint("下注信息333333333--------",mySeatNo,data.station)
		if mySeatNo == data.station then
			beginPos = self.mePos; --cc.p(60,30);
			--保存自己选择地区域
			self.selfAreaSave[data.type+1] = self.selfAreaSave[data.type+1] + self:ChipTypeToChipMoney(data.moneytype);
			--table.insert(self.selfAreaSave[data.type+1],data.moneytype);
			self.pourChip = true;
		end

		for i = 1,6 do
			if data.station == self["Image_player"..i]:getTag() and self["Image_player"..i]:isVisible() then
				beginPos = self.otherUserPos[i];

				self["Image_player"..i]:stopAllActions();
				self["Image_player"..i]:setPosition(self.otherUserSetPos[i]);

				--头像做动画
				local moveLeft = cc.MoveBy:create(0.1,cc.p(-20,0));
				local moveRight = cc.MoveBy:create(0.1,cc.p(20,0));

				local sequenceAction;
				if i<4 then
					sequenceAction = cc.Sequence:create(moveRight,moveLeft);
				else
					sequenceAction = cc.Sequence:create(moveLeft,moveRight);
				end


				self["Image_player"..i]:runAction(sequenceAction);

				break;
			end
		end

		local chipSp = self:ChipCreate(data.moneytype,beginPos);
		chipSp.userStation = data.station;
		
		local randomPos = self:getRandomPosByType(data.type+1)
		self:ChipMove(chipSp,randomPos,false,function()
			table.insert(self.chipSaveTable[data.type+1],chipSp);
		end);
		--减去下注额
		if mySeatNo == data.station then
			-- luaPrint("减去下注额",self.playerMoney,data.money)
		    self.playerMoney = self.playerMoney - data.money;
		    self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);
	        self:UpdateAreaMyChip(self.selfAreaSave);
		end

		local effectState = getEffectIsPlay();
	    if effectState then
	    	audio.playSound("longhudou/sound/sound-betlow.mp3");
		end
	end

    if self.bankStation == self.tableLogic:getMySeatNo() then
    	self:SetChipGrey();
	end

    if self.playerMoney < self.ChipTypeToChipMoney(self.Button_throw.chipType) then
    	-- self.Button_throw:setEnabled(false);
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

	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	self.Image_gameState:setVisible(true);
	self.Image_gameState:loadTexture("lhd_xiazhuzhong.png",UI_TEX_TYPE_PLIST);
	--重置下注时间
	self.AtlasLabel_clock:setString(15);--data.m_iXiaZhuTime
	self.AtlasLabel_clock:setTag(15);--data.m_iXiaZhuTime

	if #self.cardTable > 0 then
		for i,card in ipairs(self.cardTable) do
			card:removeFromParent();
		end
	end
	self.cardTable = {};
	self.Node_bipaicartoon:removeAllChildren();

	self:UpdateAreaChipSum();

	--self.Text_tipNextGame:setVisible(false);
	self.b_xiazhu = false;
	self.b_suo = false;
	self.gameBet = true;
	self.gameStart = true;
	self.pourChip = false;
	self.GameStatus = 21;
	self.savePutChipMsg = {};
	self:ClearChipInDesk();--清理桌面

	--设置玩家金币
	local mySeatNo = self.tableLogic:getMySeatNo();
	local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		-- luaPrint("设置玩家金币",userInfo.i64Money);
		self.playerMoney = clone(userInfo.i64Money);
		self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
	end

	self.bankStation = data.m_iNowNtStation;
	if self.bankStation>-1 then
		local userInfo = self.tableLogic:getUserBySeatNo(self.bankStation);
		if userInfo then
			self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
		end
	end

	self.Text_lianNum:setString(data.m_iZhuangBaShu);

	self.Button_throw:setEnabled(false);--游戏开始续投置灰
	self:UpdateAreaChipSum();--筹码额显示0
	self:UpdateAreaMyChip();--自己的筹码显示0
	self:ChipJundge(false);
	
	--如果自己是庄家则将筹码置灰
	if self.bankStation == self.tableLogic:getMySeatNo() then
		self:SetChipGrey();
	end

	self.Text_personNum:setText(data.iNTListCount.."人");
	self:UpdateSZList(data.iNTList,data.iNTListCount);
	--改成下注时间

	if isHaveBankLayer() then
        createBank(function (data)
            self:DealBankInfo(data)
        end,true);
    end
	

	self.Text_lianNum:setString(data.m_iZhuangBaShu);
	--显示连庄
	self.Node_successive:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
		if data.m_iZhuangBaShu>1 then
			self.AtlasLabel_successive:setString(data.m_iZhuangBaShu)
			self:TipActionShow(self.Node_successive);
		end
	end)))

	--开始下注动画
	self:playZitiEffect(3);

	self:UpdateUserList();

	self:UpdateThrowBtn();

	self:washCard(data.iRound);
end

--洗牌
function TableLayer:washCard(iRound)
	if iRound == 1 then
		local text = ccui.ImageView:create("word.png");
		self.Image_bg:addChild(text);
		text:setPosition(self.Image_bg:getContentSize().width*0.5,self.Image_bg:getContentSize().height*0.8);
		performWithDelay(text,function() text:removeFromParent() end,2.0)

		self.recordData = {};
		self:RefreshAllLZ(self.recordData,isNeedFlush);

	end
end
--动画信息
function TableLayer:OpenCardMsg(message)
	
end
--结算消息
function TableLayer:ResultMessageInfo(message)
	self:SetChipGrey();--继续置灰
	if self.gameStart == false then
		
		--self:UpdateUserList();
		return;
	end

	if self.b_xiazhu then
		self.b_suo = true;
		GamePromptLayer:remove()
	end

	self.gameBet = false;
	self.GameStatus = 22;

	if isHaveBankLayer() then
        createBank(function (data)
            self:DealBankInfo(data)
        end,false);
	 end

	--清除所有状态
	for i=1,3 do
		if self["Image_anliang"..i] then
			self["Image_anliang"..i]:setVisible(false);
		end
		if self["Image_liang"..i] then
			self["Image_liang"..i]:setVisible(false);
		end
	end

	local data = message._usedata;
	luaDump(data,"结算消息");

	self:playZitiEffect(4);
	audio.playSound("longhudou/sound/sound-end-wager.mp3");
	
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	self.Image_gameState:setVisible(true);
	self.Image_gameState:loadTexture("lhd_kaijiangzhong.png",UI_TEX_TYPE_PLIST);
	self.AtlasLabel_clock:setString(10);
    self.AtlasLabel_clock:setTag(10);

	--检测是否下注没下注弹出提示
	if self.pourChip == false and self.bankStation~=self.tableLogic:getMySeatNo() then
		addScrollMessage("本局您没有下注！");
		--audio.playSound("longhudou/sound/sound-result-nobet.mp3")
	end
	if #self.cardTable > 0 then
		for i,card in ipairs(self.cardTable) do
			card:removeFromParent();
		end
	end
	self.cardTable = {};
	self.Node_bipaicartoon:removeAllChildren();

	self.Image_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
		if self.gameStart == false then
			return;
		end

		self:showBipaiEffect();
		self:createCard();
		self:showCardOrbit(data.iRBCard)
	end)));

	--循环遍历 有下注的时候赋值
	local flag = false;
	for k,v in pairs(self.selfAreaSave) do
		if v>0 then
			flag = true;
			break;
		end
	end

	if flag then
		self.Button_throw.selfAreaSave = self.selfAreaSave;
	end

	self.Image_bg:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function ()--展示闪烁再显示结算和动画
		if self.gameStart == false then
			return;
		end

		if #self.cardTable > 0 then
			for i,card in ipairs(self.cardTable) do
				card:removeFromParent();
			end
		end
		self.cardTable = {};
		self.Node_bipaicartoon:removeAllChildren();

		--龙赢虎赢
		if data.iWinner ~= 2 then
			local bipaitexiao = createSkeletonAnimation("longhudouying","longhudou/cartoon/longhudouying/longhudouying.json","longhudou/cartoon/longhudouying/longhudouying.atlas");
			if bipaitexiao then
				bipaitexiao:setName("bipaitexiao");
				self.Node_bipaicartoon:addChild(bipaitexiao,10);

				if data.iWinner == 0 then--龙
					bipaitexiao:setAnimation(1,"longying", false);
					bipaitexiao:setPosition(230,375);
				elseif data.iWinner == 1 then--虎
					bipaitexiao:setAnimation(1,"huying", false);
					bipaitexiao:setPosition(1060,375);
				end

			end
				if data.iWinner == 0 then--龙
					audio.playSound("longhudou/sound/lhd_long.mp3");
				elseif data.iWinner == 1 then--虎
					audio.playSound("longhudou/sound/lhd_hu.mp3");
				end
		end

		local isSound = false;
		for i=1,3 do
			if data.iWinQuYu[i] == false then--输钱区域
				for k1,node1 in pairs(self.chipSaveTable[i]) do
					isSound = true;
					local endPos = self.ZhuangPos; --cc.p(340,650)--庄位置
					self:ChipMove(node1,endPos,false,function()
						--node1:removeFromParent();--输钱区域筹码飞向庄
						node1:setVisible(false)
					end);
				end
			end
		end

		if isSound then
			audio.playSound("longhudou/sound/sound-get-gold.mp3")
		end	

	end)));

	self.Image_bg:runAction(cc.Sequence:create(cc.DelayTime:create(4.8),cc.CallFunc:create(function ()--等待输钱飞到庄家后执行
		if self.gameStart == false then
			return;
		end
		local isSound = false;
		local bankMoneyPos = self.ZhuangPos; --cc.p(340,650)--庄位置
		for i=1,3 do
			if data.iWinQuYu[i] == true then--赢钱区域
				local chipCopy = {};--创建筹码飞向赢的区域
				for k1,node1 in pairs(self.chipSaveTable[i]) do
					local chipSp = self:ChipCreate(node1:getTag(),bankMoneyPos);
					chipSp.userStation = node1.userStation;
					table.insert(chipCopy,chipSp);
				end

				for k1,node1 in pairs(chipCopy) do
					local endpos = chipRandomPos[i];
					isSound = true;
					endpos = self:getRandomPosByType(i);
					self:ChipMove(node1,endpos,false,function()
						table.insert(self.chipSaveTable[i],node1);
					end);
				end
			end
		end
		if isSound then
			audio.playSound("longhudou/sound/sound-get-gold.mp3")
		end
	end)));

	self.Image_bg:runAction(cc.Sequence:create(cc.DelayTime:create(5.6),cc.CallFunc:create(function ()--等待赢的钱飞向赢的区域后执行--将钱飞向玩家
		--如果自己选的区域赢钱则创建对象飞向自己
		if self.gameStart == false then
			return;
		end
		local isSound = false;

		--其他的钱飞向其他玩家 
		for i=1,3 do
			if data.iWinQuYu[i] then
				for k,node1 in pairs(self.chipSaveTable[i]) do
					isSound = true;

					local tagetPos = self.otherPos; --cc.p(90,350);--目标位置
					if node1.userStation == self.tableLogic:getMySeatNo() then--如果自己则飞向自己否则飞向其他玩家
						tagetPos =  self.mePos; --cc.p(60,25);

						--自己赢得话多创建
						for i = 1,1 do
							local chipPos = cc.p(node1:getPosition());

							chipPos.x = chipPos.x + math.random(0,50)-25;
							chipPos.y = chipPos.y + math.random(0,10)-5;

							local chipSp = self:ChipCreate(node1:getTag(),chipPos);
							chipSp.userStation = node1.userStation;
							self:ChipMove(chipSp,tagetPos,false,function()
								node1:setVisible(false);
							end);
						end
					else
						for count = 1,6 do
							local imagePlayer = self["Image_player"..count];
    						if imagePlayer:getTag() == node1.userStation then
    							for i = 1,2 do
									local chipPos = cc.p(node1:getPosition());

									chipPos.x = chipPos.x + math.random(0,50)-25;
									chipPos.y = chipPos.y + math.random(0,10)-5;

									local chipSp = self:ChipCreate(node1:getTag(),chipPos);
									chipSp.userStation = node1.userStation;
									self:ChipMove(chipSp,self.otherUserPos[count],false,function()
										node1:setVisible(false);
									end);
								end
    						end
						end
					end

					self:ChipMove(node1,tagetPos,false,function()
						node1:setVisible(false);
					end);
				end
			end
		end

		if isSound then
			audio.playSound("longhudou/sound/sound-get-gold.mp3")
		end

		--将结果保存，刷新历史
		local result = {};
		result.iWinner = data.iWinner;
		--result.iCardShape = data.iCardShape[data.iWinner+1];
		self:GameHisitorySave(result);

		-- --人物动画
		if data.iWinner == 0 then --long
			audio.playSound("longhudou/sound/lhd_long_win.mp3");--龙赢
			
		elseif data.iWinner == 1 then --虎
			audio.playSound("longhudou/sound/lhd_hu_win.mp3");--虎赢
			-- self:showShuYingAnimation(3);
		else
			audio.playSound("longhudou/sound/lhd_he.mp3");--和
		end
		
		--显示赢钱区域闪烁
		self:WinAreaAction(data.iWinQuYu);

		--返回金币大于0则显示提示效果
		if data.iUserScore>0 then
			if data.iUserReturnTotle >= 0 then
				self.Text_playerChange:setProperty("","longhudou/number/zi_ying.png",26,50,'+');
				self:ScoreToMoney(self.Text_playerChange,data.iUserScore,"+");
				self:MoneyActionShow(self.Text_playerChange);

				if data.iWinQuYu[3] then
					audio.playSound("longhudou/sound/bigMoney.mp3");
				else
					audio.playSound("longhudou/sound/win.mp3");--赢
				end
			end
			
		elseif data.iUserScore<0 then
			self.Text_playerChange:setProperty("","longhudou/number/zi_shu.png",26,50,'+');
			self:ScoreToMoney(self.Text_playerChange,data.iUserScore);
			self:MoneyActionShow(self.Text_playerChange);
			audio.playSound("longhudou/sound/lose.mp3");--赢
		end

		--显示庄家获得金币显示
		if data.iNTScore > 0  then
			self.Text_bankMoneyChange:setProperty("","longhudou/number/zi_ying.png",26,50,'+');
			self:ScoreToMoney(self.Text_bankMoneyChange,data.iNTScore,"+");
			self:MoneyActionShow(self.Text_bankMoneyChange);
		elseif data.iNTScore<0 then
			self.Text_bankMoneyChange:setProperty("","longhudou/number/zi_shu.png",26,50,'+');
			self:ScoreToMoney(self.Text_bankMoneyChange,data.iNTScore);
			self:MoneyActionShow(self.Text_bankMoneyChange);
		end
		--显示其他玩家
		if data.iOtherScore > 0 then
			self.Text_otherPlayerChange:setProperty("","longhudou/number/zi_ying.png",26,50,'+');
			self:ScoreToMoney(self.Text_otherPlayerChange,data.iOtherScore,"+");
			self:MoneyActionShow(self.Text_otherPlayerChange);
		elseif data.iOtherScore < 0 then
			self.Text_otherPlayerChange:setProperty("","longhudou/number/zi_shu.png",26,50,'+');
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
		--self:UpdateUserList();

		self.Node_chip:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function () self:ClearChipInDesk(); end)));--清理桌面
		
		self:SetChipGrey();--继续置灰
		-- self:UpdateAreaChipSum();--筹码额显示0
		self:UpdateAreaMyChip();--自己的筹码显示0

		--手动刷新战绩
		if globalUnit.isShowZJ then
			self.m_logBar:refreshLog();
		end

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
	 --luaDump(msg,"重连刷新界面")
	self.Node_startAnimate:stopAllActions();
	self.Image_bg:stopAllActions();
	self.Node_startAnimate:removeChildByName(WarnAnimName);
	self.Node_startAnimate:removeChildByName("ziSpine");

	local longhudouziSpine = self:getChildByName("longhudouziSpine");
	if longhudouziSpine then
		longhudouziSpine:removeFromParent();
	end
	local colorLayer = self:getChildByName("colorLayer");
	if colorLayer then
		colorLayer:removeFromParent();
	end

	self.Node_startAnimate:removeAllChildren();

	if #self.cardTable > 0 then
		for i,card in ipairs(self.cardTable) do
			card:removeFromParent();
		end
	end
	self.cardTable = {};
	self.Node_bipaicartoon:removeAllChildren();

	self.isGameStation = true; --上下庄专用

	--清空桌面
	self:ClearChipInDesk();
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");

	--设置上下庄所需要的钱
	self.iShangZhuangLimit = msg.iShangZhuangLimit;
	self.iXiaZhuangLimit = msg.iXiaZhuangLimit;
	--设置庄家的逻辑位置
	self.bankStation = msg.iNowNtStation;
	--显示庄家姓名和钱
	if msg.iNowNtStation ~= 255 then
		local userInfo = self.tableLogic:getUserBySeatNo(msg.iNowNtStation);
		if userInfo then
			self:ScoreToMoney(self.Text_BankMoney,userInfo.i64Money);
			self.Text_BankName:setText(FormotGameNickName(userInfo.nickName,4));
		end
	else
		self.Text_BankName:setText("无人坐庄");
		self:ScoreToMoney(self.Text_BankMoney,0);
	end
	--申请庄家人数
	self.Text_personNum:setText(msg.iNTListCount.."人");
	self:UpdateSZList(msg.iNTList,msg.iNTListCount);
	--连庄次数
	self.Text_lianNum:setString(msg.iZhuangBaShu)

	--判断上庄按钮
	self:SetButtonVillageState(msg.ZhuangStatus);

	self.Text_applyNum:setString(FormatDigitToString(msg.iShangZhuangLimit/100,1))

	--记录自己的金币
	local myUserInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	self.playerMoney = clone(myUserInfo.i64Money);

	--下注状态的时候设置下注
	self.Image_gameState:setVisible(false);
	self.Button_throw:setEnabled(false);--游戏开始续投置灰
	self.GameStatus = msg.bGameStation;

	--判断自己是否下注过
	for i,v in ipairs(msg.i64myZhu) do
		if v>0 then
			self.pourChip = true;
			break;
		end
	end

	if msg.bGameStation == 21 then --下注状态
		luaPrint("1剩余下注时间",msg.iSYTime)
		if msg.iSYTime >= 0 and msg.iSYTime <=15 then
			self.Image_gameState:setVisible(true);
			self.Image_gameState:loadTexture("lhd_xiazhuzhong.png",UI_TEX_TYPE_PLIST);
			self.AtlasLabel_clock:setString(msg.iSYTime);--下注时间设置
			self.AtlasLabel_clock:setTag(msg.iSYTime);
		end

		self.gameBet = true;
		self.gameStart = true;

		for k,v in pairs(msg.i64myZhu) do
			self.playerMoney = self.playerMoney - v;
			self.selfAreaSave[k] = v;
		end
		self:ScoreToMoney(self.Text_playerMoney,self.playerMoney);

		self:ChipJundge(false);
		--刷新筹码总额
    	self:UpdateAreaChipSum(msg.i64QuYuZhu);
    	self:UpdateAreaMyChip(msg.i64myZhu);
    	
		--设置区域筹码
		self:AddAreaChip(msg.i64QuYuZhu);

		-- --创建盖着的牌
		-- self:createCard();

		--保险箱
		if isHaveBankLayer() then
	        createBank(function (data)
	            self:DealBankInfo(data)
	        end,true);
	    end

	    for k,v in pairs(msg.i64myZhu) do
			if v>0 then
				self.b_xiazhu = true;
				break;
			end
		end

	elseif msg.bGameStation == 22 then --开奖状态
		local isTime = msg.iSYTime;
		isTime = msg.iSYTime-1;
		if isTime < 0 then
			isTime = 0;
		end
		luaPrint("2剩余下注时间",msg.iSYTime)
		if isTime >= 0 and isTime <=15 then
			self.Image_gameState:setVisible(true);
			self.Image_gameState:loadTexture("lhd_kaijiangzhong.png",UI_TEX_TYPE_PLIST);
			self.AtlasLabel_clock:setString(isTime);--下注时间设置
			self.AtlasLabel_clock:setTag(isTime);
		end

		local mySeatNo = self.tableLogic:getMySeatNo();
		local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
		if userInfo then
			self:ScoreToMoney(self.Text_playerMoney,userInfo.i64Money);
			self.playerMoney = clone(userInfo.i64Money);
		end

		self.gameBet = false;
		self.gameStart = false;
		self:SetChipGrey();
		-- self.Text_tipNextGame:setVisible(true);
		self:playZitiEffect(1);
		self:UpdateAreaChipSum();--筹码额显示0
		self:UpdateAreaMyChip();--自己的筹码显示0
		if isHaveBankLayer() then
	        createBank(function (data)
	            self:DealBankInfo(data)
	        end,false);
	    end

	    for k,v in pairs(msg.i64myZhu) do
			if v>0 then
				self.b_xiazhu = true;
				self.b_suo = true;
				GamePromptLayer:remove()
				break;
			end
		end

	else
		self.AtlasLabel_clock:setString(0);--下注时间设置
		self:DealNoBankWait();
		--判断上庄按钮
		self:SetButtonVillageState(msg.ZhuangStatus);
	end
	--如果自己是庄家则将筹码置灰
	if self.bankStation == self.tableLogic:getMySeatNo() then
		self:SetChipGrey();
	end

	self:GameHisitorySave(msg.ResultInfo,true);
    --过滤255的座位号
	self.Text_personNum:setText(msg.iNTListCount.."人");
	self:UpdateSZList(msg.iNTList,msg.iNTListCount);
	self:UpdateUserList();

end
--无庄等待
function TableLayer:DealNoBankWait(message)
	--清空庄家信息
	self.Text_BankName:setText("无人坐庄");
	self.Text_BankMoney:setString("");
	self.Text_lianNum:setString("0");
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
	self:ClearChipInDesk();
	--设置筹码变灰
	self:SetChipGrey();

	self.Node_bipaicartoon:removeAllChildren();

	for index,card in pairs(self.cardTable) do
		card:removeFromParent();
	end
	self.cardTable = {};

	self:UpdateUserList();

	self.b_xiazhu = false;

	self.b_suo = false;

end
--退还下注
function TableLayer:DealNoteBack(message)

	local msg = message._usedata;
	luaDump(msg,"退还下注")
	self:UpdateAreaChipSum(msg.m_iQuYuZhu);
	--addScrollMessage("退还下注")
	local i =1;
	while(self.savePutChipMsg[i]) do
		if self.savePutChipMsg[i].station == msg.bDeskStation then
			local putChipMsg = self.savePutChipMsg[i];
			table.remove(self.savePutChipMsg, i);
			--msg.iUserXiaZhuData[i] = msg.iUserXiaZhuData[i] - putChipMsg.money;
		else
			i = i + 1;
		end
	end
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
		if v>0 then
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
		self:TipTextShow("您的金币未满足上庄条件"..(math.floor(self.iShangZhuangLimit/100)).."金币，不能申请上庄。");
		-- local prompt = GamePromptLayer:create();
		-- prompt:showPrompt(GBKToUtf8("正在开发，勿提bugfree"));
		 showBuyTip();
	elseif data.errorCode == 3 then--列表中的玩家不能申请
		self:TipTextShow("列表中的玩家不能申请");
		--self:SetButtonVillageState(villageState.zUserStatus_InList);
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
		self:TipTextShow("庄家的金币少于坐庄必须金币数（"..(math.floor(self.iXiaZhuangLimit/100)).."），自动下庄");
	elseif data.errorCode == 12 then
		self:TipTextShow("下注失败，您必须有30金币才能下注");
		 showBuyTip();
	elseif data.errorCode == 13 then--庄家金币不足
		self:TipTextShow("由于你的金币少于坐庄必须金币数（"..(math.floor(self.iXiaZhuangLimit/100)).."），你自动取消上庄");
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
        gamePanel:setVisible(true);  
        self:SetGameBtnInfo(gamePanel, index);
	end
	
    
    return cell;
end

function TableLayer:SetGameBtnInfo(gamePanel,idx)
	--luaDump(self.saveOtherInfo)
	gamePanel:getChildByName("Text_name"):setText(FormotGameNickName(self.saveOtherInfo[idx+1].nickName,nickNameLen));   
	self:ScoreToMoney(gamePanel:getChildByName("Text_money"),self.saveOtherInfo[idx+1].i64Money);
	local playerHead = gamePanel:getChildByName("Image_headKuang");
	playerHead:loadTexture(getHeadPath(self.saveOtherInfo[idx+1].bLogoID,self.saveOtherInfo[idx+1].bBoy));
	playerHead:ignoreContentAdaptWithSize(true);
	playerHead:setScale(60/145);
end

function TableLayer:UpdateUserList(noUpdate)
	if noUpdate == nil then
		noUpdate = false;
	end

	self.saveOtherInfo = {};
    for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
    	if userInfo then
	        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
	            table.insert(self.saveOtherInfo,userInfo)
	        end
	    end
	end
	
	self.Text_userNum:setString(#self.saveOtherInfo);
	if self.gameBtnTableView then
		self:CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, self.Panel_userInfo:getContentSize(), true);
	end

	--刷新用户金币

	--如果6个人庄家则去除
	for i = 1,6 do
    	local imagePlayer = self["Image_player"..i];
    	if imagePlayer:getTag() >= 0 then
	    	if imagePlayer:getTag() == self.bankStation then
	    		imagePlayer:setVisible(false);--先隐藏 再过一秒显示其他人
	    		imagePlayer:setTag(-1);
	    		imagePlayer:stopAllActions();
	    		imagePlayer:getChildByName("AtlasLabel_score"):setVisible(false);
	    		imagePlayer.userId = -1;
	    		break;
	    	end
	    end
    end

	-- local count = 1;
    for k,userInfo in pairs(self.saveOtherInfo) do
    	local flag = true;
    	for i = 1,6 do
    		local imagePlayer = self["Image_player"..i];
    		if imagePlayer:getTag() == userInfo.bDeskStation then
    			flag = false;
    			break;
    		end
    	end

    	for count = 1,6 do
	    	if userInfo.bDeskStation~=self.bankStation then
		    	if count<=6 and self["Image_player"..count]:getTag() == -1 and flag then
		    		self["Image_player"..count]:setTag(userInfo.bDeskStation);
		    		self["Image_player"..count].userId = userInfo.dwUserID;
		    		self["Image_player"..count]:setVisible(true);
		    		self["Image_player"..count]:getChildByName("Image_playerHead"):loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		    		self["Image_player"..count]:setPosition(self.otherUserSetPos[count]);
		    		self["Image_player"..count]:getChildByName("AtlasLabel_score"):setVisible(false);
		    		local userdi = self["Image_player"..count]:getChildByName("Image_di");
		    		local name = userdi:getChildByName("Text_name");
		    		name:setString(FormotGameNickName(userInfo.nickName,4));
		    		local money = userdi:getChildByName("Text_money");
		    		self:ScoreToMoney(money,userInfo.i64Money)
		    		self["Image_player"..count]:getChildByName("AtlasLabel_score"):setVisible(false);
		    		-- count = count+1;
		    		break;
		  		elseif count<=6 and self["Image_player"..count]:getTag() == userInfo.bDeskStation and noUpdate == false then
		  			local userdi = self["Image_player"..count]:getChildByName("Image_di");
		    		local money = userdi:getChildByName("Text_money");
		    		self:ScoreToMoney(money,userInfo.i64Money);
		    		-- count = count+1;
		    		break;
				elseif count > 6 then
					break;
		    	end
		    end
		end
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

--创建牌先移除原先的，在展示发牌动画
function TableLayer:createCard()
	display.loadSpriteFrames("longhudou/card.plist","longhudou/card.png");

	-- self.Image_heipai:setVisible(false);
	-- self.Image_hongpai:setVisible(false);
	if #self.cardTable > 0 then
		for i,card in ipairs(self.cardTable) do
			card:removeFromParent();
		end
	end
	self.cardTable = {};
	
	for i=1,2 do
		local card  = cc.Sprite:create();
		card:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("dzpk_0x%02X.png",0)));
		card:setScale(1.2);
		card:setPosition(600,600);
		card:setVisible(false);
		table.insert(self.cardTable,card)
		audio.playSound("longhudou/sound/sound-fapai.mp3");--发牌

		self.Node_bipaicartoon:addChild(card,10)
		if i == 1 then
			card:setPosition(220,590);
		else
			card:setPosition(1060,590);

		end
	end
end

--开奖状态中的翻牌动画
function TableLayer:showCardOrbit(cardData)
	display.loadSpriteFrames("longhudou/card.plist","longhudou/card.png");

	for index,card in pairs(self.cardTable) do
		local time = 1;
		if index  == 2 then
			time = 1.5;
		end

		local seq1 = cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
			card:setVisible(true);
		end),cc.OrbitCamera:create(0.2,1,0,0,-90,0,0),cc.Hide:create());
		local call = cc.CallFunc:create(function ()
			local path = cardData[index][1];
			audio.playSound("longhudou/sound/sound-fanpai.mp3");--翻牌
			card:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("dzpk_0x%02X.png",path)));
		end);
		local seq2 = cc.Sequence:create(cc.Show:create(),cc.OrbitCamera:create(0.2,1,0,90,-90,0,0))
		--local seq4 = cc.Sequence:create(cc.DelayTime:create(0.2));
		local call2 = cc.CallFunc:create(function ()
			local value = self:GetCardValue(cardData[index][1]);
			audio.playSound("longhudou/sound/lhb_p_"..value..".mp3");--牌值
		end);

		card:runAction(cc.Sequence:create(seq1,call,seq2,call2));
	end

end


function TableLayer:GetCardValue(cbCardData) 
	local value = bit:_and(cbCardData,0x0F)+1;
	--addScrollMessage("GetCardValue"..value)
	if value < 2 or value > 14 then
		addScrollMessage("牌值转换出错"..cbCardData);
		value = 1;
	end
	return value;--cbCardData&LOGIC_MASK_VALUE; 
end


function TableLayer:showBipaiEffect()

	local bipaitexiao = createSkeletonAnimation("longhudoudaiji","longhudou/cartoon/longhudoudaiji/longhudoudaiji.json","longhudou/cartoon/longhudoudaiji/longhudoudaiji.atlas");
	if bipaitexiao then
		bipaitexiao:setPosition(640,360);
		-- if isbipai then
		-- 	bipaitexiao:setAnimation(1,biapiName, false);
		-- else
			bipaitexiao:setAnimation(1,"longhudoudaiji", false);
		--end
		bipaitexiao:setName("bipaitexiao");
		self.Node_bipaicartoon:addChild(bipaitexiao,10);
	end
end


function TableLayer:JudgeSelfThrow(chipArea,chipMoney,chipType)
	local mySeatNo = self.tableLogic:getMySeatNo();
    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
    if userInfo then
	    if userInfo.i64Money < SettlementInfo:getConfigInfoByID(46) then
	        self:TipTextShow("下注失败，您必须有"..(SettlementInfo:getConfigInfoByID(46)/100).."金币才能下注");
	        showBuyTip();
	        return false;
	    end
	end
    self.tableLogic:sendPutChipInfo(chipArea,chipMoney,chipType);
    return true;
end

--刷新所有界面
function TableLayer:RefreshAllLZ(msg,isNeedFlush)
	self:RefreshZhuLZ(msg,isNeedFlush);

	self:RefreshDaLZ(msg,isNeedFlush);

	self:RefreshYanLZ(msg,isNeedFlush);

	self:RefreshXiaoLZ(msg,isNeedFlush);

	self:RefreshRyLZ(msg,isNeedFlush);

	self:RefreshLwlLZ(msg);

	self:RefreshHwlLZ(msg);

	--获取龙 虎 平的局数
	local hCount = 0;
	local lCount = 0;
	local pCount = 0;

	for k,v in pairs(msg) do
		if v.iWinner == 0 then
			lCount = lCount+1;
		elseif v.iWinner == 1 then
			hCount = hCount+1;
		else
			pCount = pCount+1;
		end
	end

	self.AtlasLabel_lSum:setString(lCount);
	self.AtlasLabel_hSum:setString(hCount);
	self.AtlasLabel_pSum:setString(pCount);
end

--刷新珠路
function TableLayer:RefreshZhuLZ(msg,isNeedFlush)
	local lzWidth = 8;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetZLWayList(msg,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_zhu:removeAllChildren();
	local size = self.Panel_zhu:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lhd_lz2_"..v2.type..".png";

			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+2,(lzHeight - k2)*height+2);
			self.Panel_zhu:addChild(sp);

			if v2.lastFlag and not isNeedFlush then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新大路
function TableLayer:RefreshDaLZ(msg,isNeedFlush)
	local lzWidth = 25;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetNewBigWayList(msg,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_da:removeAllChildren();
	local size = self.Panel_da:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "roomcolor_"..v2.color..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+2,(lzHeight - k2)*height+2);
			self.Panel_da:addChild(sp);

			local spSize = sp:getContentSize();

			--创建和局的数
			if v2.flatCount > 0 then
				local heshu = FontConfig.createWithCharMap(v2.flatCount,"roomHistory/heshu.png",8,10,"0")--庄
				heshu:setPosition(spSize.width/2,spSize.height/2);
				sp:addChild(heshu);
			end

			if v2.lastFlag and not isNeedFlush then
				self:LastPointAction(sp);
			end
		end
	end
end

--刷新大眼仔路
function TableLayer:RefreshYanLZ(msg,isNeedFlush)
	local lzWidth = 18;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,2,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_yan:removeAllChildren();
	local size = self.Panel_yan:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lhd_lz3_"..v2.color..".png";

			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width,(lzHeight - k2)*height);
			self.Panel_yan:addChild(sp);

			if v2.lastFlag and not isNeedFlush then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新小路
function TableLayer:RefreshXiaoLZ(msg,isNeedFlush)
	local lzWidth = 18;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,3,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_xiao:removeAllChildren();
	local size = self.Panel_xiao:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lhd_lz4_"..v2.color..".png";

			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width,(lzHeight - k2)*height);
			self.Panel_xiao:addChild(sp);

			if v2.lastFlag and not isNeedFlush then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新冉由路
function TableLayer:RefreshRyLZ(msg,isNeedFlush)
	local lzWidth = 18;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,4,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_ry:removeAllChildren();
	local size = self.Panel_ry:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("longhudou/longhudou.plist","longhudou/longhudou.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lhd_lz5_"..v2.color..".png";

			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width,(lzHeight - k2)*height);
			self.Panel_ry:addChild(sp);

			if v2.lastFlag and not isNeedFlush then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新龙问路
function TableLayer:RefreshLwlLZ(msg)
	self.Panel_lw:removeAllChildren();
	local size = self.Panel_lw:getContentSize();

	local width = size.width/3;
	local height = 5;


	local lType = LZLogic:GetFutureWay(msg,1,2);

	if lType then
		local str = "lhd_lz"..lType..".png";
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10,height);
		self.Panel_lw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,1,3);

	if lType then
		local str = "lhd_lz6_"..lType..".png";
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width,height);
		self.Panel_lw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,1,4);

	if lType then
		local str = "lhd_lz7_"..lType..".png";
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width*2,height);
		self.Panel_lw:addChild(sp);

	end

end

--刷新虎问路
function TableLayer:RefreshHwlLZ(msg)
	self.Panel_hw:removeAllChildren();
	local size = self.Panel_hw:getContentSize();

	local width = size.width/3;
	local height = 5;


	local lType = LZLogic:GetFutureWay(msg,2,2);

	if lType then
		local str = "lhd_lz"..lType..".png";
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10,height);
		self.Panel_hw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,2,3);
	if lType then
		local str = "lhd_lz6_"..lType..".png";
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width,height);
		self.Panel_hw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,2,4);

	if lType then
		local str = "lhd_lz7_"..lType..".png";
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width*2,height);
		self.Panel_hw:addChild(sp);

	end

end
--路子最后个进行闪烁
function TableLayer:LastPointAction(pNode)
	pNode:setVisible(true);
	pNode:setOpacity(0);
	local fadeInAction = cc.FadeIn:create(0.4);
	local fadeOutAction = cc.FadeOut:create(0.4);
	pNode:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(fadeInAction,fadeOutAction),3),fadeInAction));
end

--显示获取
function TableLayer:ShowMoneyChange(msg)
	if self.gameStart == false then
		return;
	end

	for i=1,6 do
		if self["Image_player"..i]:getTag()~=-1 and self["Image_player"..i].userId == msg.dwUserID then
			self["Image_player"..i]:runAction(cc.Sequence:create(cc.DelayTime:create(5.6),cc.CallFunc:create(function()
				if self.gameStart == false then
					return;
				end

				local AtlasLabel_score = self["Image_player"..i]:getChildByName("AtlasLabel_score");
				if msg.dwMoney > 0 then
					AtlasLabel_score:setProperty("","longhudou/number/zi_ying.png",26,50,'+');
					self:ScoreToMoney(AtlasLabel_score,msg.dwMoney,"+");
					self:MoneyActionShow(AtlasLabel_score);
				elseif msg.dwMoney < 0 then
					AtlasLabel_score:setProperty("","longhudou/number/zi_shu.png",26,50,'+');
					self:ScoreToMoney(AtlasLabel_score,msg.dwMoney);
					self:MoneyActionShow(AtlasLabel_score);
				end

				for k,userInfo in pairs(self.saveOtherInfo) do
					if userInfo.dwUserID == msg.dwUserID then
						local userdi = self["Image_player"..i]:getChildByName("Image_di");
			    		local money = userdi:getChildByName("Text_money");
			    		self:ScoreToMoney(money,userInfo.i64Money);
			    		break;
					end
				end

			end)))
			break;
		end
	end
end

return TableLayer;