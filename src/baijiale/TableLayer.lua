local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("baijiale.TableLogic");
local KaiPaiLayer = require("baijiale.KaiPaiLayer");
local ChouMa = require("baijiale.ChouMa");
local LuZiLayer = require("baijiale.LuZiLayer");
local HelpLayer = require("baijiale.HelpLayer");
local baijialeLogic = require("baijiale.baijialeLogic");
local RankInfoLayer = require("baijiale.RankInfoLayer");
local LZLogic = require("baijiale.LZLogic");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

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
	BJLInfo:init()
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;

	--audio.playMusic("baijiale/sound/sound-happy-bg.mp3", true);

	local uiTable = {
		--投资区
		Image_bg = "Image_bg",
		Text_bankName = "Text_bankName",
		Text_bankMoney = "Text_bankMoney",
		Text_bankJu = "Text_bankJu",
		Button_menu = {"Button_menu",0},
		Text_selfName = "Text_selfName",
		AtlasLabel_selfMoney = "AtlasLabel_selfMoney",
		Sprite_clock = "Sprite_clock",
		AtlasLabel_time = "AtlasLabel_time",

		Image_area0 = "Image_area0",
		Image_area1 = "Image_area1",
		Image_area2 = "Image_area2",
		Image_area3 = "Image_area3",
		Image_area4 = "Image_area4",
		Image_area5 = "Image_area5",
		Image_area6 = "Image_area6",
		Image_area7 = "Image_area7",

		Button_score1 = "Button_score1",
		Button_score2 = "Button_score2",
		Button_score3 = "Button_score3",
		Button_score4 = "Button_score4",
		Button_score5 = "Button_score5",
		Button_score6 = "Button_score6",

		Button_cast1 = "Button_cast1",
		Button_cast2 = "Button_cast2",
		Button_cast3 = "Button_cast3",
		Button_cast4 = "Button_cast4",
		Button_cast5 = "Button_cast5",
		Button_cast6 = "Button_cast6",
		Button_cast7 = "Button_cast7",
		Button_cast0 = "Button_cast0",
		
		Button_bank = "Button_bank",
		Text_peopleNum = "Text_peopleNum",
		Text_upBankMoney = "Text_upBankMoney",
		Button_otherPlayer = {"Button_otherPlayer",0},
		Button_again = "Button_again",
		
		--Text_otherNum = "Text_otherNum",
		AtlasLabel_otherNum = "AtlasLabel_otherNum",
		Button_luzi = {"Button_luzi",1},
		Image_wantBank = "Image_wantBank",
		--各下注区域分数
		AtlasLabel_area_money_0 = "AtlasLabel_area_money_0",
		AtlasLabel_area_money_1 = "AtlasLabel_area_money_1",
		AtlasLabel_area_money_2 = "AtlasLabel_area_money_2",
		AtlasLabel_area_money_3 = "AtlasLabel_area_money_3",
		AtlasLabel_area_money_4 = "AtlasLabel_area_money_4",
		AtlasLabel_area_money_5 = "AtlasLabel_area_money_5",
		AtlasLabel_area_money_6 = "AtlasLabel_area_money_6",
		AtlasLabel_area_money_7 = "AtlasLabel_area_money_7",
		--Text_deskAllMoney = "Text_deskAllMoney",
		AtlasLabel_deskAllMoney = "AtlasLabel_deskAllMoney",
		Image_bank_lunhuan = "Image_bank_lunhuan",
		Image_wait_next = "Image_wait_next",
		Image_lian_zhuang = "Image_lian_zhuang",
		AtlasLabel_lian_zhuang = "AtlasLabel_lian_zhuang",

		--设置页面
		Button_baoxianxiang = {"Button_baoxianxiang",1},
		Image_setting = {"Image_setting",0},
		--Button_help = "Button_help",
		Button_yinyue = "Button_yinyue",
		Button_yinxiao = "Button_yinxiao",
		Button_exit = {"Button_exit",0,1},
		Button_guize = {"Button_guize",1},
		ListView_luzi = "ListView_luzi",
		Image_luzi = "Image_luzi",
		Image_luzi_zhuang = "Image_luzi_zhuang",
		Image_luzi_xian = "Image_luzi_xian",
		Image_luzi_ping = "Image_luzi_ping",
		Image_luzi_1 = "Image_luzi_1";
		AtlasLabel_luzi_xian_num = "AtlasLabel_luzi_xian_num",
		AtlasLabel_luzi_ping_num = "AtlasLabel_luzi_ping_num",
		AtlasLabel_luzi_zhuang_num = "AtlasLabel_luzi_zhuang_num",
		AtlasLabel_piao_numer_me = "AtlasLabel_piao_numer_me",
		AtlasLabel_piao_numer_other = "AtlasLabel_piao_numer_other",
		AtlasLabel_piao_numer_zhuang = "AtlasLabel_piao_numer_zhuang",

		AtlasLabel_me_betmoney0 = "AtlasLabel_me_betmoney0",
		AtlasLabel_me_betmoney1 = "AtlasLabel_me_betmoney1",
		AtlasLabel_me_betmoney2 = "AtlasLabel_me_betmoney2",
		AtlasLabel_me_betmoney3 = "AtlasLabel_me_betmoney3",
		AtlasLabel_me_betmoney4 = "AtlasLabel_me_betmoney4",
		AtlasLabel_me_betmoney5 = "AtlasLabel_me_betmoney5",
		AtlasLabel_me_betmoney6 = "AtlasLabel_me_betmoney6",
		AtlasLabel_me_betmoney7 = "AtlasLabel_me_betmoney7",
		Node_score = "Node_score",
		Node_luzi = {"Node_luzi",1},
		Image_playBg = {"Image_playBg",0},
		Image_bankInfo = "Image_bankInfo",
		Image_gameStation = "Image_gameStation",
		Panel_zhu = "Panel_zhu",
		Panel_da = "Panel_da",
		Panel_yan = "Panel_yan",
		Panel_xiao = "Panel_xiao",
		Panel_ry = "Panel_ry",
		Panel_lw = "Panel_lw",
		Panel_hw = "Panel_hw",
		AtlasLabel_zhuangNum = "AtlasLabel_zhuangNum",
		AtlasLabel_xianNum = "AtlasLabel_xianNum",
		AtlasLabel_xianduiNum = "AtlasLabel_xianduiNum",
		AtlasLabel_zhuangduiNum = "AtlasLabel_zhuangduiNum",
		AtlasLabel_heNum = "AtlasLabel_heNum",
		AtlasLabel_tianwangNum = "AtlasLabel_tianwangNum", 
		Node_play = "Node_play",
		Node_player1 = "Node_player1",
		Node_player2 = "Node_player2",
		Node_player3 = "Node_player3",
		Node_player4 = "Node_player4",
		Node_player5 = "Node_player5",
		Node_player6 = "Node_player6",
		Image_selfHead = "Image_selfHead",
		Node_backgroud = "Node_backgroud",
		Node_ani = "Node_ani",
		Button_zhanji = "Button_zhanji",
		Button_bankList = "Button_bankList",
	}

	self:initData();

	loadNewCsb(self,"baijiale/tableLayer",uiTable)

	_instance = self;

	local framesize = cc.Director:getInstance():getWinSize()
  	local addWidth = (framesize.width - 1280)/4;
  	for i=1,6 do
  		if i<=3 then
  			self["Node_player"..i]:setPositionX(self["Node_player"..i]:getPositionX()-addWidth);
  		else
  			self["Node_player"..i]:setPositionX(self["Node_player"..i]:getPositionX()+addWidth);
  		end
  	end
  	self["Button_otherPlayer"]:setPositionX(self["Button_otherPlayer"]:getPositionX()-addWidth);
  	self["Button_exit"]:setPositionX(self["Button_exit"]:getPositionX()-addWidth);
  	self["Button_menu"]:setPositionX(self["Button_menu"]:getPositionX()+addWidth);
  	self["Image_setting"]:setPositionX(self["Image_setting"]:getPositionX()+addWidth);
  	self["Image_playBg"]:setPositionX(self["Image_playBg"]:getPositionX()-addWidth);
  	self["Button_again"]:setPositionX(self["Button_again"]:getPositionX()+addWidth);
end

function TableLayer:loadCacheResource()
	display.loadSpriteFrames("baijiale/BJL_gameRes.plist", "baijiale/BJL_gameRes.png");
	display.loadSpriteFrames("baijiale/card.plist", "baijiale/card.png");
end

--进入
function TableLayer:onEnter()
	self:initUI()

	self:bindEvent();--绑定消息
	self.super.onEnter(self);
end
--进入结束
function TableLayer:onEnterTransitionFinish()
	

end

--退出
function TableLayer:onExit()
	self.super.onExit(self);
	display.removeSpriteFrames("baijiale/BJL_gameRes.plist","baijiale/BJL_gameRes.png")
end
--绑定消息
function TableLayer:bindEvent()
	self:pushEventInfo(BJLInfo, "BJLGameStart", handler(self, self.BJLGameStart));
	self:pushEventInfo(BJLInfo, "BJLGameAddBank", handler(self, self.BJLGameAddBank));
	self:pushEventInfo(BJLInfo, "BJLGameEnd", handler(self, self.BJLGameEnd));
	self:pushEventInfo(BJLInfo, "BJLGameApplyBank", handler(self, self.BJLGameApplyBank));
	self:pushEventInfo(BJLInfo, "BJLGameChangeBank", handler(self, self.BJLGameChangeBank));
	self:pushEventInfo(BJLInfo, "BJLGameStatusFree", handler(self, self.BJLGameStatusFree));
	self:pushEventInfo(BJLInfo, "BJLGameCancelBank", handler(self, self.BJLGameCancelBank));
	self:pushEventInfo(BJLInfo, "BJLGameRecord", handler(self, self.BJLGameRecord));
	self:pushEventInfo(BJLInfo, "BJLGameAddMoneyFail", handler(self, self.BJLGameAddMoneyFail));
	self:pushEventInfo(BJLInfo, "BJLGameCancleBank", handler(self, self.BJLGameCancleBank));
	self:pushEventInfo(BJLInfo, "BJLGameCancleSuccess", handler(self, self.BJLGameCancleSuccess));
	self:pushEventInfo(BJLInfo, "BJLGameCancleBet", handler(self, self.BJLGameCancleBet));
	self:pushEventInfo(BJLInfo, "BJLGameBankScore", handler(self, self.DealZhuangScore));
	self:pushEventInfo(BJLInfo, "XuTouFail", handler(self, self.DealXuTouFail));
	self:pushEventInfo(BJLInfo, "WashCard", handler(self, self.DealWashCard));--洗牌
	
	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来

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

		self.b_isBackGround = false;

		self:stopAllActions();

		self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
	else
		--self.m_bGameStart = false;
		--self:onClickExitGameCallBack();
	end
end

function TableLayer:clearDesk()
	self.Image_wait_next:setVisible(false);
	self:clearDeskMoney();
	self:updateAreaMoney(true);
	self:reductionArea();
	local kaiPaiLayer = self:getChildByName("KaiPaiLayer")
	if kaiPaiLayer then
		kaiPaiLayer:removeFromParent();
	end
	local resultLayer = self:getChildByName("ResultLayer")
	if resultLayer then
		resultLayer:removeFromParent();
	end

	self:clearAni();

	--恢复桌面显示各区域数据
	for k,v in pairs(self.AtlasLabel_area_money) do
		v:setString(numberToString2(0));
		v:setVisible(false);
	end
	--恢复自己各区域数据
	for k,v in pairs(self.AtlasLabel_me_betmoney) do
		v:setString(numberToString2(0));
		v:setVisible(false);
	end
	self.t_bankTable = {};
	self.bankerUserNum = 0;
	self.b_receive = false;
	self.ButtonPos = 1;
	self:setBetEnable(false);
	self.b_again = false;
	self.b_xiazhu = false;
	self.b_suo = false;
	self.m_recordScore = {0,0,0,0,0,0,0,0};--记录上局下注金额

	if self.gameEndAni then
		self:stopAction(self.gameEndAni)
		self.gameEndAni = nil;
	end
end
	

--去除动画
function TableLayer:clearAni()
	local node;
	node = self:getChildByName("addAnimation");
	while(node) do
		node:removeFromParent();
		node = self:getChildByName("addAnimation");
	end
end

--退钱
function TableLayer:BJLGameCancleBet(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;
	--luaPrint("退钱");
	for k,v in pairs(self.m_deskMoney) do
		self:updateAreaMoney(false,0-msg.lUserPlaceScore[k],k-1);
	end

end

--//取消下庄
function TableLayer:BJLGameCancleBank()
	if self.b_isBackGround == false then
		return;
	end
	self:loadCacheResource();
	self.Button_bank:loadTextures("BJL_lhd_xiazhuang.png","BJL_lhd_xiazhuang-on.png","BJL_lhd_xiazhuang-on.png",UI_TEX_TYPE_PLIST);
	self.Button_bank:setTag(2);
end

--//取消下庄成功
function TableLayer:BJLGameCancleSuccess()
	if self.b_isBackGround == false then
		return;
	end
	luaPrint("收到取消下庄消息");
	self:loadCacheResource();
	self.Button_bank:loadTextures("BJL_lhd_qxxz.png","BJL_lhd_qxxz-on.png","BJL_lhd_qxxz-on.png",UI_TEX_TYPE_PLIST);
	self.Button_bank:setTag(3);
end

--游戏开始
function TableLayer:BJLGameStart(data)
	if self.b_isBackGround == false then
		return;
	end
	luaPrint("游戏开始啦----可以下注啦------------",os.date("%X"));
	if isHaveBankLayer() then
		dispatchEvent("isCanSendGetScore",true)
	end
	local msg = data._usedata;
	self:loadCacheResource();
	luaDump(data,"游戏开始啦");
	self.b_xiazhu = false;
	self.b_suo = false;
	self.Image_gameStation:loadTexture("BJL_lhd_xiazhuzhong.png",UI_TEX_TYPE_PLIST);
	self.isfive = true;
	self.b_again = false;
	self.Image_wait_next:setVisible(false);
	self.m_bGameStart = true;
	self:startSchedule(15);
	self:setClockTime(tonumber(msg.cbTimeLeave));
	local m_time = msg.cbTimeLeave;
	-- self:runAction(cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function ( ... )
	-- 	-- body
	-- 	m_time = m_time - 1;
	-- 	if m_time <= 3 and m_time>0 then
	-- 		audio.playSound("baijiale/sound/sound-countdown.mp3");
	-- 	end
	-- 	if m_time == 3 then
	-- 		self:addAnimation(5);
	-- 	elseif m_time == 0 then
	-- 		--self:addAnimation(6);
	-- 		audio.playSound("baijiale/sound/sound-end-wager.mp3");
	-- 	end
	-- end),cc.DelayTime:create(1.0)),msg.cbTimeLeave));

	-- self.runSoundCheduler = schedule(self, function() 
        
 --        m_time = m_time - 1;
 --        if m_time<= 3 then
 --            audio.playSound("baijiale/sound/sound-countdown.mp3");
 --            if m_time == 3 then
 --            	self:addAnimation(5);
 --        	elseif m_time == 0 then
 --        		audio.playSound("baijiale/sound/sound-end-wager.mp3");
 --        		self:stopAction(self.runSoundCheduler)
 --            	self.runSoundCheduler = nil;
 --            end
 --        end
 --    end, 1.0)

 	-- self:runAction(cc.Sequence:create(cc.DelayTime:create(11),cc.CallFunc:create(function ()
 	-- 	-- body
 	-- 	self:addAnimation(5);
 	-- 	audio.playSound("baijiale/sound/sound-countdown.mp3");
 	-- 	self.num = 2;
 	-- 	self.schedule1 = schedule(self, function() 
 	-- 		self.num = self.num -1;
 	-- 		luaPrint("schedule1",self.num);
 	-- 		if self.num<= 0 then
 	-- 			self:stopAction(self.schedule1);
 	-- 			schedule1 = nil;
 	-- 		end
 	-- 		audio.playSound("baijiale/sound/sound-countdown.mp3");
 	-- 		end,1.0)
 	-- end),cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
 	-- 	-- body
 	-- 	self:addAnimation(6);
 	-- 	audio.playSound("baijiale/sound/sound-end-wager.mp3");
 	-- end)));


	--self:showMsgString("游戏开始啦",30);
	self:addAnimation(4);
	--self.bankJuShu = self.bankJuShu + 1;
	self.bankJuShu = msg.nBankerTime;
	self.Text_bankJu:setString("局数:"..self.bankJuShu);
	--self.Button_bank:setEnabled(false);
	--刷新庄家分数
	self:showPlayerInfo();
	--恢复中奖区域
	self:reductionArea();
	self.m_deskMoney = {0,0,0,0,0,0,0,0}
	self.m_DownBetScore = {0,0,0,0,0,0,0,0};
	for k,v in pairs(self.AtlasLabel_me_betmoney) do
		v:setString(0);
		v:setVisible(false);
	end
	self.alreadyGame = true;
	self.lianZhuangJuShu = self.lianZhuangJuShu + 1
	luaPrint("lianZhuangJuShu",self.lianZhuangJuShu);
	self.AtlasLabel_lian_zhuang:setString(self.bankJuShu);
	if self.bankJuShu >1 and self.bankSeatNo~=-1 and self.bankSeatNo~=255 then
		ShowAnimate(self.Image_lian_zhuang,2);
	end
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	if self.b_haveBank and not self.selfIsBanker then
		self:setBetEnable(true);
		self:setXuTouButtonEnable();
	end
	if userInfo and not self.selfIsBanker then
		self:updateBetEnable(userInfo.i64Money);
	end
	
	audio.playSound("baijiale/sound/sound-start-wager.mp3");

end

function TableLayer:getScoreIndex(lBetScore)
	local index = 0;
	for k,v in pairs(self.betMoneyTable) do
		if lBetScore == v then
			index = k;
			return index;
		end
	end
	return index;
end
--下注
function TableLayer:BJLGameAddBank(data)
	if self.b_isBackGround == false then
		return;
	end
	--luaPrint("有人下注啦----------------");
	local msg = data._usedata;

	--luaDump(msg,"有人下注啦");
	--self:showMsgString("有人下注",30);
	--luaPrint(msg.wChairID,self.tableLogic:getMySeatNo())
	if msg.wChairID == self.tableLogic:getMySeatNo() then
		self.b_again = true;
		self.b_xiazhu = true;
		self:showAddMoneyAni(msg);
		self:recordMoney(msg.lBetScore,msg.cbBetArea);
		--local value = tonumber(self.AtlasLabel_selfMoney:getString())*100-msg.lBetScore;
		self.selfMoney = self.selfMoney-msg.lBetScore;
		self.AtlasLabel_selfMoney:setString(numberToString2(self.selfMoney));
		self.castPos = msg.cbBetArea;
		self.score = msg.lBetScore;
		-- self.ButtonPos = self:getScoreIndex(msg.lBetScore);
		self:updateBetEnable(self.selfMoney);
		--自己下注金额
		self.m_DownBetScore[msg.cbBetArea+1] = self.m_DownBetScore[msg.cbBetArea+1] + msg.lBetScore;
		self.AtlasLabel_me_betmoney[msg.cbBetArea+1]:setString(numberToString2(self.m_DownBetScore[msg.cbBetArea+1]));
		if self.m_DownBetScore[msg.cbBetArea+1]>0 then
			self.AtlasLabel_me_betmoney[msg.cbBetArea+1]:setVisible(true);
		end
		self.Button_again:setEnabled(false);
		--self:updateAreaMoney(false,msg.lBetScore,msg.cbBetArea);
	else
		--self:showAddMoneyAni(msg.lBetScore,msg.cbBetArea,true);
		self:otherPlayAddScore(msg);
	end
	
end

function TableLayer:startSchedule(ft)
	if ft == nil then
		return ;
	end
	local m_time = ft
	local isfive = true
	local issix = true
	local speed = 15;
	if self.otherSchedule then
		self:stopAction(self.otherSchedule)
		self.otherSchedule = nil;
	end
	self.otherSchedule = schedule(self, function() 
		m_time = m_time - 1*1.0/speed;
		--luaPrint("startSchedule",m_time,#self.n_otherBetScore);
		if #self.n_otherBetScore > 0 then
			self:showAddMoneyAni(self.n_otherBetScore[1],true)
			--self:updateAreaMoney(false,self.n_otherBetScore[1].lBetScore,self.n_otherBetScore[1].cbBetArea);
			table.remove(self.n_otherBetScore,1);
		end
		
		if  m_time <=3.1 and self.isfive then
			--luaPrint("startSchedule1",m_time,#self.n_otherBetScore);
			self.isfive = false
			self:addAnimation(5);
		end

	end, 1.0/speed)

end

--其他人下注
function TableLayer:otherPlayAddScore(msg)
	--self.n_otherBetScore = {};--其他人下注池
	-- local msg = {};
	-- msg.lBetScore = lBetScore
	-- msg.cbBetArea =cbBetArea;

	table.insert(self.n_otherBetScore,msg);

end

--更新各区域分数 分数，区域 ,是否全部清0
function TableLayer:updateAreaMoney(_type,lBetScore,cbBetArea)
	--luaPrint("updateAreaMoney",lBetScore,cbBetArea);
	if _type == true then
		for k,v in pairs(self.AtlasLabel_area_money) do
			v:setString(0);
			v:setVisible(false);
		end
		for k,v in pairs(self.AtlasLabel_me_betmoney) do
			v:setString(0);
			v:setVisible(false);
		end
		--self.Text_deskAllMoney:setString(0);
		self.AtlasLabel_deskAllMoney:setString(0);
		return ;
	end

	self.m_deskMoney[cbBetArea+1] = self.m_deskMoney[cbBetArea+1] + lBetScore
	--local number = tonumber(self.AtlasLabel_area_money[cbBetArea+1]:getString()) + lBetScore;
	self.AtlasLabel_area_money[cbBetArea+1]:setString(numberToString2(self.m_deskMoney[cbBetArea+1]));
	if self.m_deskMoney[cbBetArea+1]>0 then
		self.AtlasLabel_area_money[cbBetArea+1]:setVisible(true);
	end


	local allScore = 0;
	for k,v in pairs(self.m_deskMoney) do
		 --local num = tonumber(v:getString());
		--v:setString(0);
		allScore = allScore + v ;
	end
	--self.Text_deskAllMoney:setString(allScore/100);
	self.AtlasLabel_deskAllMoney:setString(allScore/100);
end

--记录上一轮下注列表
function TableLayer:recordMoney(lBetScore,cbBetArea)
	luaPrint("记录下注区域",lBetScore,cbBetArea,self.addMoneyTable[cbBetArea+1]);
	self.addMoneyTable[cbBetArea+1] = self.addMoneyTable[cbBetArea+1]+lBetScore
end
--游戏结束
function TableLayer:BJLGameEnd(data)
	if self.b_isBackGround == false then
		return;
	end
	self:loadCacheResource();
	--luaPrint("游戏结束----------------",os.date("%X"));
	--游戏结束如果计时器存在，停掉
	for k=#self.n_otherBetScore,1,-1 do
		self:showAddMoneyAni(self.n_otherBetScore[k],true)
		table.remove(self.n_otherBetScore,k);
	end
	
	if self.b_xiazhu then
		self.m_recordScore = clone(self.m_DownBetScore);
	end

	self.Image_gameStation:loadTexture("BJL_lhd_kaijiangzhong.png",UI_TEX_TYPE_PLIST);
	--self:stopAction(self.otherSchedule)
	--self.otherSchedule = nil;
	self.isfive = false;
	self.m_bGameStart = false;
	if self.b_xiazhu then
		self.b_suo = true;
		GamePromptLayer:remove()
	end
	self.Image_wait_next:setVisible(false);
	self.Button_again:setEnabled(false);
	--self.Text_bankJu:setString("局数:"..self.bankJuShu);

	if isHaveBankLayer() then
		createBank(function (data)
				self:Baoxian(data);
			end,self.m_bGameStart);
	end
	
	local msg = data._usedata;

	--luaDump(data,"游戏结束");
	--self.bankJuShu = msg.nBankerTime;
	self.lianZhuangJuShu = msg.nBankerTime;
	self:setClockTime(tonumber(msg.cbTimeLeave));
	self:setBetEnable(false);
	self.score = 0;
	self:updatePlayNum();
	-- self:updateBankerMoney();
	
	-- local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	-- if userInfo then
	-- 	--显示自己的最后分数
	-- 	self.AtlasLabel_selfMoney:setString(numberToString2(userInfo.i64Money+msg.lPlayAllScore));
	-- end

	--如果自己没有参与本轮游戏则不显示结算
	if self.alreadyGame == false then
		--self:showMsgString("等待下一轮游戏开始");
		return;
	end

	local call = cc.CallFunc:create(function ( ... )
		-- body
		self:addAnimation(6);
	end);

	self.gameEndAni = cc.Sequence:create(call,cc.DelayTime:create(1.0),cc.CallFunc:create(
		function ()
			local layer = KaiPaiLayer:create(msg,self);
			self:addChild(layer,999);
		end
		),cc.DelayTime:create(6+3),
		cc.CallFunc:create(function ()
			-- 显示黄色
			for k,v in pairs(msg.lWinArea) do
				if v == true then
					self:lightArea(k-1,5,2);
				end
			end
		end),
		cc.CallFunc:create(
			function ()
				self:ResultChipRemove(msg.lWinArea);
				self:updateAreaMoney(true,0,0)
				self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
					function ( ... )
						self:moveNumberAni(msg);
					end)));
				self:addGameRecord(msg);
				if self.b_xiazhu == false and not self.selfIsBanker then
					self:showMsgString("本局您没有下注！");
					self:showPlayGameNum();
				end
			end
		))

	self:runAction(self.gameEndAni);
end

function TableLayer:updatePlayNum()

	luaPrint("updatePlayNum",self.b_xiazhu,self.selfIsBanker,self.m_playGameNum);

	if self.b_xiazhu == false and not self.selfIsBanker then
		self.m_playGameNum = self.m_playGameNum + 1;
	end

	if self.b_xiazhu or self.selfIsBanker then
		self.m_playGameNum = 0 
	end

	for k,v in pairs(self.t_bankTable) do
		if v == self.tableLogic:getMySeatNo() then
			self.m_playGameNum = 0;
			break;
		end
	end
end

--飘字动画
function TableLayer:moveNumberAni(data)
	local value_zhuang = data.lBankerScore--庄
	local value_me = data.lPlayAllScore--玩家
	local value_other = data.LOtherScore--self:getOtherWinScore(data);

	local str = "baijiale/number/zi_ying.png"
	if value_zhuang<0 then
		str = "baijiale/number/zi_shu.png"
	end
	local text_zhuang = FontConfig.createWithCharMap(goldConvert(value_zhuang,1),str,26,50,"+")--庄
	self.Node_ani:addChild(text_zhuang);
	text_zhuang:setAnchorPoint(0,0.5)
	text_zhuang:setPosition(cc.p(self.AtlasLabel_piao_numer_zhuang:getPositionX(),self.AtlasLabel_piao_numer_zhuang:getPositionY()));

	local str = "baijiale/number/zi_ying.png"
	if value_other<0 then
		str = "baijiale/number/zi_shu.png"
	end
	local text_other = FontConfig.createWithCharMap(goldConvert(value_other,1),str,26,50,"+")--别人
	self.Node_ani:addChild(text_other);
	text_other:setAnchorPoint(0,0.5)
	text_other:setPosition(cc.p(self.AtlasLabel_piao_numer_other:getPositionX(),self.AtlasLabel_piao_numer_other:getPositionY()));

	local str = "baijiale/number/zi_ying.png"
	if value_me<0 then
		str = "baijiale/number/zi_shu.png"
	end
	local text_me = FontConfig.createWithCharMap(goldConvert(value_me,1),str,26,50,"+")--自己
	self.Node_ani:addChild(text_me);
	text_me:setAnchorPoint(0,0.5)
	text_me:setPosition(cc.p(self.AtlasLabel_piao_numer_me:getPositionX(),self.AtlasLabel_piao_numer_me:getPositionY()));



	function moveAni(node,ft,num)
		luaPrint("飘字动画",ft,num);
		local pos = cc.p(node:getPositionX(),node:getPositionY());
		local str = "";
		if num> 0 then
			str = str.."+"..tostring(numberToString2(num));
		else
			str = str..tostring(numberToString2(num));
		end
		node:setString(str);
		if num~= 0 then
			node:setVisible(true);
		else
			node:removeFromParent();
			return;
		end
		local moveTo = cc.MoveTo:create(ft,cc.p(pos.x,pos.y+50));
		local fadeOut = cc.FadeOut:create(ft)
		local fadein = cc.FadeIn:create(0.1)
		node:runAction(cc.Sequence:create(cc.DelayTime:create(ft),cc.CallFunc:create(function ()
			-- body
			node:setPosition(pos);
			node:setVisible(false);
			node:removeFromParent();
		end)));
	end

	moveAni(text_me,3,value_me);
	moveAni(text_other,3,value_other);
	moveAni(text_zhuang,3,value_zhuang);

	--刷新庄家和玩家的分数
	self:updateBankerMoney();
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	if userInfo then
		--显示自己的最后分数
		self.AtlasLabel_selfMoney:setString(numberToString2(userInfo.i64Money+data.lPlayAllScore));
		self.selfMoney = userInfo.i64Money+data.lPlayAllScore;
		if data.lPlayAllScore>0 then
			if data.lPlayScore[2] > 0 or data.lPlayScore[7] > 0 or data.lPlayScore[8] > 0 then
				audio.playSound("baijiale/sound/bigMoney.mp3");
			else

				audio.playSound("baijiale/sound/win.mp3");
			end
		elseif data.lPlayAllScore < 0 then
			audio.playSound("baijiale/sound/lose.mp3");
		end
	end

	--播放连胜特效
	if data.nWinTime > 2 and ((self.b_xiazhu and not self.selfIsBanker) or self.selfIsBanker) then
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

	self:showOtherPlayScore(data);

end

-- function TableLayer:getOtherWinScore(msg)
--     local zScore = msg.lBankerScore--庄家积分
--     local uScore = msg.lPlayAllScore --自己的积分
--     local otherScore = 0;
--     if zScore > 0 then
--         zScore = zScore/0.95
--     end
--     if uScore > 0 then
--         uScore = uScore/0.95
--     end
--     if zScore > 0 then 
--         otherScore = -(uScore+zScore);
--     else
--         otherScore = uScore + zScore;
--     end
--     if otherScore >0 then 
--     	otherScore = otherScore*0.95
--     end
--     return otherScore;
-- end


--游戏结束储存战绩
function TableLayer:addGameRecord(data)

	local msg = {};--数据块
	local cbWinner,cbKingWinner,bAllPointSame,bPlayerTwoPair,bBankerTwoPair 
	= baijialeLogic:DeduceWinner(data.cbTableCardArray,data.cbCardCount);
	-- {"cbKingWinner","BYTE"},--//天王赢家
	-- {"bPlayerTwoPair","BOOL"},--//对子标识
	-- {"bBankerTwoPair","BOOL"},--//对子标识
	-- {"cbPlayerCount","BYTE"},--//闲家点数
	-- {"cbBankerCount","BYTE"},--//庄家点数 

	msg.cbKingWinner = 0
	msg.bPlayerTwoPair = bPlayerTwoPair
	msg.bBankerTwoPair = bBankerTwoPair
	msg.cbPlayerCount = GetCardListPip(data.cbTableCardArray[1],data.cbCardCount[1]);
	msg.cbBankerCount = GetCardListPip(data.cbTableCardArray[2],data.cbCardCount[2]);
	--luaDump(msg,"计算结果");
	table.insert(self.GameRecord,msg);
	luaPrint("#self.GameRecord",#self.GameRecord);
	-- if #self.GameRecord >= 100 then
	-- 	local temp = {};
	-- 	for k=1,20 do
	-- 		local value = clone(self.GameRecord[80+k]);
	-- 		table.insert(temp,value);
	-- 	end
	-- 	self.GameRecord = clone(temp);
	-- end
	--luaDump(self.GameRecord);
	self:flushRecord(true);

	local layer = self:getChildByName("LuZiLayer")
	if layer then
		layer:flushOtherMsg(self.GameRecord);
	end

	-- if self.LuZiNode then
	-- 	luaPrint("找到节点");
	-- 	self.LuZiNode:flushOtherMsg(self.GameRecord);
	-- end
end

--刷新庄家分数
function TableLayer:updateBankerMoney()
	--local realSeat = self.tableLogic:getMySeatNo();
	--luaPrint("showPlayerInfo",realSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(self.bankSeatNo);
	--luaDump(userInfo,"庄家的信息");
	if userInfo then
		self.Text_bankName:setString(FormotGameNickName(userInfo.nickName,4));
		luaPrint("userInfo.i64Money",userInfo.i64Money);
		self.Text_bankMoney:setString(numberToString2(userInfo.i64Money));--userInfo.i64Money
	end
end

--游戏结束的筹码的移动
function TableLayer:ResultChipRemove(lWinArea)
	local winChipNode = {};
	local FailChipNode = {};
	local ResultChipNode = {};

	--luaPrint("table.nums",table.nums(self.deskMoneyTable))
	--luaDump(lWinArea);

	--for k,isWin in pairs(lWinArea) do
		for i,node in ipairs(self.deskMoneyTable) do
			--luaPrint("---ResultChipNode------",node:getArea(),node.isMe,lWinArea[node:getArea()+1])

			if lWinArea[node:getArea()+1] then
				table.insert(winChipNode,node)
				table.insert(ResultChipNode,node)
			else
				table.insert(FailChipNode,node)
			end
		end
	--end

	local ZhuangPos = cc.p(420,650)--self.Node_score:convertToNodeSpace(cc.p(self.Image_bankInfo:getPosition()))
	luaDump(ZhuangPos,"ZhuangPos");
	local fun1 = cc.CallFunc:create(function() 
		for i,node in ipairs(FailChipNode) do
			node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,ZhuangPos),cc.CallFunc:create(function() node:setVisible(false) end) ));
		end
		audio.playSound("baijiale/sound/sound-get-gold.mp3");
	end)

	local fun2 = cc.CallFunc:create(function()--庄家给自己 
		for i,node in ipairs(winChipNode) do
			-- if i>20 then
			-- 	break;
			-- end
			local copyNode = ChouMa:create(node:getScore());
			copyNode:setVisible(false);
			copyNode:setScale(0.35);
			copyNode:setPosition(ZhuangPos);
			copyNode:setIsMe(node:getIsMe());
			copyNode:setSeatNo(node:getSeatNo());
			self.Node_score:addChild(copyNode,100);
    		table.insert(ResultChipNode,copyNode)
    		table.insert(self.deskMoneyTable,copyNode)
    		--audio.playSound("baijiale/sound/sound-get-gold.mp3");
    		--移动到桌子上
			local cast_pos = node:getArea();
			
    		--飞到哪里
			local pos = self:getBetPos(cast_pos);--cc.p(posx,posy)

			local moveTo = cc.MoveTo:create(0.5,pos);
			copyNode:runAction(cc.Sequence:create(cc.CallFunc:create(function ( ... )
				copyNode:setVisible(true);
			end),moveTo));
		end
		audio.playSound("baijiale/sound/sound-get-gold.mp3");
	end)

	--回到自己
	local fun3 = cc.CallFunc:create(function() 
		for i,node in ipairs(ResultChipNode) do
			--luaPrint("ResultChipNode.isMe,",node.isMe)
			local mePos = cc.p(self.Image_playBg:getPositionX(),self.Image_playBg:getPositionY())--cc.p(24,22);
			local otherPos = self:getOtherMovePos(node:getSeatNo());--cc.p(self.Button_otherPlayer:getPositionX(),self.Button_otherPlayer:getPositionY())
			
			if node:getIsMe() then
				node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,mePos),cc.CallFunc:create(function() node:setVisible(false) end) ));
			else
				node:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,otherPos),cc.CallFunc:create(function() node:setVisible(false) end) ));
			end
		end
		audio.playSound("baijiale/sound/sound-get-gold.mp3");
	end)

	function clearAllChip()
		for k,v in pairs(self.deskMoneyTable) do
			if v then
				v:removeFromParent();
			end
		end
		
		self.deskMoneyTable = {};

	end
	self:runAction(cc.Sequence:create(fun1,
		cc.DelayTime:create(0.5),fun2,
		cc.DelayTime:create(0.5),fun3,
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function() clearAllChip() end) ))
	
end

--获取其他玩家飞的位置
function TableLayer:getOtherMovePos(seatNo)
	local pos = cc.p(self.Button_otherPlayer:getPositionX(),self.Button_otherPlayer:getPositionY())
	for k,v in pairs(self.otherNode) do
		if v:getTag() == seatNo then
			pos = cc.p(v:getPositionX(),v:getPositionY());
			break;
		end
	end
	return pos;
end

--申请上庄
function TableLayer:BJLGameApplyBank(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata
	self:loadCacheResource();
	self.bankerUserNum = msg.ApplyCount;
	self:updateBankList(msg.ApplyUsers,msg.ApplyCount);
	self:updateBankerNum()

	if msg.wApplyUser == self.tableLogic:getMySeatNo() then
		-- if self.Image_wantBank then
		-- 	self.Image_wantBank:loadTexture("baijiale/ui/BJL_xiazhuang.png");
		-- 	self.Button_bank:setTag(2);
		-- end
		luaPrint("BJLGameApplyBank");
		self.b_receive = false;
		self.Button_bank:setTag(2);
		self.Button_bank:loadTextures("BJL_lhd_qxsz.png","BJL_lhd_qxsz-on.png","BJL_lhd_qxsz-on.png",UI_TEX_TYPE_PLIST);
	end
	
end

--取消上庄 (下庄消息)
function TableLayer:BJLGameCancelBank(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata

	self.bankerUserNum = msg.ApplyCount;
	self:updateBankList(msg.ApplyUsers,msg.ApplyCount);
	self:updateBankerNum()
	luaPrint("BJLGameCancelBank",msg.szCancelUser,self.tableLogic:getMySeatNo());
	if msg.szCancelUser == self.tableLogic:getMySeatNo() then
		--if self.Image_wantBank then
			--self.Image_wantBank:loadTexture("baijiale/ui/BJL_shangzhuang.png");
			self.Button_bank:loadTextures("BJL_lhd_shangzhuang.png","BJL_lhd_shangzhuang-on.png","BJL_lhd_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
			self.Button_bank:setTag(1);
		--end
	end
end

--加载游戏记录
function TableLayer:BJLGameRecord(data)
	if self.b_isBackGround == false then
		--return;
	end
	local msg = data._usedata
	self.GameRecord = msg;

	-- for k=#self.GameRecord-20,1,-1 do
	-- 	table.remove(self.GameRecord,k);
	-- end
	--luaDump(msg);
	--self:initGameRecord();
	-- if self.rankTableView_luzi then
 --        self:CommomFunc_TableViewReloadData_Vertical(self.rankTableView_luzi, self.Panel_otherMsg_luzi:getContentSize(), false);
 --    end
 	self:flushRecord();

 -- 	if self.LuZiNode then
	-- 	luaPrint("找到节点");
	-- 	self.LuZiNode:flushOtherMsg(self.GameRecord);
	-- end
end

--重新洗牌
function TableLayer:DealWashCard(data)
	if self.b_isBackGround == false then
		return;
	end

	local text = ccui.ImageView:create("BG/word.png");
	self.Image_bg:addChild(text);
	text:setPosition(self.Image_bg:getContentSize().width*0.5,self.Image_bg:getContentSize().height*0.8);
	performWithDelay(text,function() text:removeFromParent() end,2.0)

	self.GameRecord = {};
	self:flushRecord();

end

-- --绘制游戏记录
-- function TableLayer:updateGameRecord()
-- 	luaDump(self.GameRecord,"游戏记录");
-- 	for k=#self.GameRecord,1,-1 do
-- 		local str = "baijiale/"--路径
-- 		local msg = self.GameRecord[k];
-- 		local indexX = 0;
-- 		if msg.cbPlayerCount == msg.cbBankerCount then -- 平
-- 			-- if msg.bPlayerTwoPair then --平 闲对子
-- 			-- 	str = str.."ping_xiandui.png"
-- 			-- elseif msg.bBankerTwoPair then--平 庄对子
-- 			-- 	str = str.."ping_zhuangdui.png"
-- 			-- else
-- 			-- 	str = str.."ping.png"
-- 			-- end
-- 			str = str.."BJL_ping.png"
-- 			indexX = 3;
-- 		elseif msg.cbPlayerCount > msg.cbBankerCount then -- 闲
-- 			-- if msg.bPlayerTwoPair then--闲对子
-- 			-- 	str = str.."xiandui.png"
-- 			-- else
-- 			-- 	str = str.."xian.png"
-- 			-- end
-- 			str = str.."BJL_xian.png"
-- 			indexX = 2;
-- 		elseif msg.cbPlayerCount < msg.cbBankerCount then -- 庄
-- 			-- if msg.bBankerTwoPair then--庄对子
-- 			-- 	str = str.."zhuangdui.png"
-- 			-- else
-- 			-- 	str = str.."zhuang.png"
-- 			-- end
-- 			str = str.."BJL_zhuang.png"
-- 			indexX = 1;
-- 		end

-- 		--计算位置
-- 		local X = 0
-- 		if indexX == 1 then
-- 			X = self.Image_luzi_zhuang:getPositionX();
-- 		elseif indexX == 2 then
-- 			X = self.Image_luzi_xian:getPositionX();
-- 		elseif indexX == 3 then
-- 			X = self.Image_luzi_ping:getPositionX();
-- 		end
-- 		local pos = cc.p(X,(#self.GameRecord-k)*38.5+75+38.5);

-- 		--创建精灵
-- 		if str ~= "" then
-- 			local sprite = cc.Sprite:create(str);
-- 			sprite:setPosition(pos);
-- 			self.Image_luzi:addChild(sprite);
-- 		end
-- 	end
-- end

--下注失败
function TableLayer:BJLGameAddMoneyFail(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata
	-- if self.m_bGameStart then
	-- 	self:showMsgString("下注失败");
	-- else
	-- 	self:showMsgString("请稍后,还没有到下注时间");
	-- end
end

function TableLayer:updateBankerNum()
	luaPrint("更新上庄人数",self.bankerUserNum);
	if self.bankerUserNum<0 then
		self.Text_peopleNum:setString(0);
		self.bankerUserNum = 0;
		return ;
	end
	self.Text_peopleNum:setString(self.bankerUserNum);
end

--游戏空闲
function TableLayer:BJLGameStatusFree(data)
	local msg = data._usedata
	luaDump(msg,"游戏空闲");
	--self:setClockTime(tonumber(msg.cbTimeLeave));
	--self:showMsgString("游戏进入空闲状态",30);
	--self.Button_bank:setEnabled(true);
end

--切换庄家
function TableLayer:BJLGameChangeBank(data)
	if self.b_isBackGround == false then
		return;
	end
	self:loadCacheResource();
	local msg = data._usedata
	self:updateBankList(msg.ApplyUsers,msg.ApplyCount);
	ShowAnimate(self.Image_bank_lunhuan,2);
	--self:showMsgString("切换庄家成功",30);
	audio.playSound("baijiale/sound/zhuang-1.mp3");
	if msg.wBankerUser ~= 255 then
		local userInfo = self.tableLogic:getUserBySeatNo(msg.wBankerUser);
		--luaDump(userInfo,"庄家信息");
		--luaDump(self.tableLogic._deskUserList);
		if userInfo then
			self.Text_bankName:setString(FormotGameNickName(userInfo.nickName,4));
		end
		self.Text_bankMoney:setString(numberToString2(msg.lBankerScore));
		self.bankJuShu = 0;
		self.Text_bankJu:setString("局数:"..self.bankJuShu);
		--table.removebyvalue(self.t_bankTable,msg.wBankerUser);
		if msg.wBankerUser == self.tableLogic:getMySeatNo() then 
			self.Button_bank:setTag(2);
			luaPrint("我要上庄");
			--self.Image_wantBank:loadTexture("baijiale/ui/BJL_xiazhuang.png");
			self.Button_bank:loadTextures("BJL_lhd_xiazhuang.png","BJL_lhd_xiazhuang-on.png","BJL_lhd_xiazhuang-on.png",UI_TEX_TYPE_PLIST);
			self:setBetEnable(false);
			self.selfIsBanker = true;
			self.b_haveBank = false;
		else
			if self.bankSeatNo == self.tableLogic:getMySeatNo() then
				self.Button_bank:setTag(1);
				self.Button_bank:loadTextures("BJL_lhd_shangzhuang.png","BJL_lhd_shangzhuang-on.png","BJL_lhd_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
			end
			self:setBetEnable(false);
			self.b_haveBank = true;
			self.selfIsBanker = false;
		end

		self.lianZhuangJuShu = 0;
	else
		self:setBetEnable(false);
		self.b_haveBank = false;
		self.selfIsBanker = false;
		self.Text_bankName:setString("无人坐庄");
		self.Text_bankMoney:setString("");
		self.bankJuShu = 0;
		self.Text_bankJu:setString("局数:"..self.bankJuShu);
		self.Button_bank:setTag(1);
		luaPrint("我要下庄");
		--self.Image_wantBank:loadTexture("baijiale/ui/BJL_shangzhuang.png");
		self.Button_bank:loadTextures("BJL_lhd_shangzhuang.png","BJL_lhd_shangzhuang-on.png","BJL_lhd_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
	end
	self.bankSeatNo = msg.wBankerUser;
	self.bankerUserNum = msg.ApplyCount;
	self:updateBankerNum()

	self:initOtherPlayer();

end

-- function TableLayer:isMeApplyBanker()
--     local value = self.tableLogic._mySeatNo;
--     for k,v in ipairs(self.t_bankTable) do
--       if v == value then
--           return true
--       end
--     end
--     return false
-- end


--设置按钮状态
function TableLayer:setBetEnable(isTrue)
	--luaPrint("setBetEnable");
	for k,v in pairs(self.Button_score) do
		--luaPrint("setBetEnable",k);
		v:setEnabled(isTrue);
		if not isTrue then
			v:setScale(1.0);
			self:addQuan(v,false)
		end
		if isTrue and self.ButtonPos == k then
			--v:setScale(1.2);
			self:addQuan(v,true)
		end
	end
	--self.Button_again:setEnabled(isTrue);
end

function TableLayer:addQuan(node,isTrue)
	if node == nil then
		return;
	end

	--显示光圈
	if isTrue then
		local quan = node:getChildByName("xuanzhong");
		if quan then
			quan:removeFromParent();
		end

		if not node:isEnabled() then
			return;
		end
		local skeleton_animation = sp.SkeletonAnimation:create("animate/xuanzhong/xuanzhong.json", "animate/xuanzhong/xuanzhong.atlas");
	    --skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"xuanzhong", true);
	    --self:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("xuanzhong");
	    skeleton_animation:setScale(1.2);
		-- quan = ccui.ImageView:create("zhuanquan.png",UI_TEX_TYPE_PLIST)
		node:addChild(skeleton_animation);
		-- quan:setName("quan");
		node:setPositionY(69.51);
		skeleton_animation:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2+5*1.2));
		-- quan:runAction(cc.RepeatForever:create(cc.RotateBy:create(4,360)));
	else -- 不显示光圈
		local quan = node:getChildByName("xuanzhong");
		if quan then
			quan:removeFromParent();
		end
		node:setPositionY(59.51);
	end

end

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
--初始化数据
function TableLayer:initData()	
	self.tipTextTable = {};
	--玩家对象存储
	self.playerNodeInfo = {};

	--玩家昵称
	self.playerInfo = {};--包括昵称 ID 登陆IP 性别

	--聊天图片
	self.chatImage = {};

	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

	--游戏是否开始
	self.m_bGameStart = false;

	self._bReconding = false;
	--聊天记录
	self.ChatRecord={};

	--有事解散
	self._isHaveThing = false;

	--房间类型
	self.roomType = RoomType.NormalRoom;--默认正常房间

	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;
	self.ButtonPos = 1; --记录玩家选择的筹码
	self.castPos = -1;--记录玩家成功选择下注的区域
	self.score = 0;--记录玩家成功选择下注的金额
	self.bankJuShu = 0;--记录坐庄局数
	self.deskMoneyTable = {};--筹码池
	self.bankerUserNum = 0;--上庄人数
	self.addMoneyTable={0,0,0,0,0,0,0,0};--记录上一轮投注列表
	self.otherMsgTable = {};
	self.GameRecord = {};--游戏记录
	self.betMoneyTable = {100,1000,5000,10000,50000,100000}
	self.selfMoney = 0;--临时记录自己的钱
	self.selfIsBanker = false;--自己是否是庄家
	self.bankSeatNo = -1;--庄家的位置
	self.m_deskMoney = {0,0,0,0,0,0,0,0};--记录各区域下注金额
	self.alreadyGame = false; --记录自己是否已经在游戏中
	self.lianZhuangJuShu = 0;--连庄局数
	self.m_DownBetScore = {0,0,0,0,0,0,0,0};--记录自己在每块下注金额
	self.b_haveBank = false;--是否有人上庄
	self.m_bankLimitMoney = 0;--记录上庄需要金币
	self.t_bankTable = {};--上庄列表
	self.n_otherBetScore = {};--其他人下注池
	self.b_addScore = true;--是否允许玩家下注
	self.b_isBackGround = true;--记录游戏是否切后台
	self.isfive = true; -- 是否弹倒计时动画
	self.b_receive = false;--服务器是否回复
	self.b_again = false; -- 记录是否可以续投
	--self.LuZiNode = nil; -- 桌子上的路子节点
	self.otherNode = {};--其他玩家的所有节点
	self.b_xiazhu = false; --玩家是否下注
	self.b_suo = false; -- 玩家是否可以退出
	self.m_scoreLimit = 3000; --下注限制
	if SettlementInfo:getConfigInfoByID(46) then
		self.m_scoreLimit = SettlementInfo:getConfigInfoByID(46)
	end

	self.m_recordScore = {0,0,0,0,0,0,0,0};--记录上局下注金额
	self.m_playGameNum = 0;--傻瓜参与局数

end
--初始化界面
function TableLayer:initUI()
	self:loadCacheResource();
	--基本按钮
	self:initGameNormalBtn();

	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	--self:initOtherMsgPanle();

	self:updateAreaMoney(true,0,0);

	-- self:initGameRecord();
	self:initOtherPlayer();

	--桌子号
    local size = self.Image_bg:getContentSize();
    local deskNoBg = ccui.ImageView:create("BG/whichtable.png")
    deskNoBg:setAnchorPoint(0.5,1)
    deskNoBg:setPosition(self.Button_exit:getContentSize().width/2,7)
    deskNoBg:setScale(0.8)
    self.Button_exit:addChild(deskNoBg)

    local deskNo = FontConfig.createWithCharMap(self.bDeskIndex+1,"number/BJL_zhuohao.png",24,32,"0")
    deskNo:setPosition(35,deskNoBg:getContentSize().height/2)
    deskNo:setScale(0.6)
    deskNo:setAnchorPoint(1,0.5)
    deskNoBg:addChild(deskNo)
end

--初始化其他玩家信息
function TableLayer:initOtherPlayer()
	for i=1,6 do
		self["Node_player"..i]:setVisible(false);
	end
	--只显示6个
	local num = 0;
	self.otherNode = {};
	for i=1,PLAY_COUNT do
		if (i-1) ~= self.tableLogic:getMySeatNo() and (i-1) ~= self.bankSeatNo then
			local viewSeat = self.tableLogic:viewToLogicSeatNo(i-1)
			local userInfo = self.tableLogic:getUserBySeatNo(i-1);
			if userInfo then
				num = num+1;
				local node = self["Node_player"..num];
				node:setVisible(true);
				local head = node:getChildByName("Image_ohead");
				local name = node:getChildByName("Image_di"):getChildByName("Text_oname");  
				local score = node:getChildByName("Image_di"):getChildByName("Text_oscore");
				node:setTag(i-1);
				--luaDump(userInfo);
				--luaPrint("initOtherPlayer",getHeadPath(userInfo.bLogoID,userInfo.bBoy));
				head:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
				name:setString(FormotGameNickName(userInfo.nickName,5));
				score:setString(goldConvert(userInfo.i64Money,1));
				table.insert(self.otherNode,node);
			end
			if num >= 6 then
				break;
			end
		end
	end
end

function TableLayer:clearDeskMoney()
	for k,v in pairs(self.deskMoneyTable) do
		if v then
			v:removeFromParent();
		end
	end
	self.deskMoneyTable = {};
end

--初始化按钮
function TableLayer:initGameNormalBtn()

	self.AtlasLabel_piao_numer_me:setVisible(false);
	self.AtlasLabel_piao_numer_other:setVisible(false);
	self.AtlasLabel_piao_numer_zhuang:setVisible(false);

	self.AtlasLabel_me_betmoney = {} -- 自己下注金额
	for k=1,8 do
		local i = k-1;
		if self["AtlasLabel_me_betmoney"..i] then
			self["AtlasLabel_me_betmoney"..i]:setTag(i);
			self["AtlasLabel_me_betmoney"..i]:setString(0);
			self["AtlasLabel_me_betmoney"..i]:setVisible(false);
			self["AtlasLabel_me_betmoney"..i]:setLocalZOrder(1000);
			table.insert(self.AtlasLabel_me_betmoney,self["AtlasLabel_me_betmoney"..i]);
		end
	end

	self.AtlasLabel_area_money = {}

	for k = 1,8 do
		local i = k-1
		if self["AtlasLabel_area_money_"..i] then
			luaPrint("AtlasLabel_area_money_",i);
			self["AtlasLabel_area_money_"..i]:setTag(i);
			self["AtlasLabel_area_money_"..i]:setString(0);
			self["AtlasLabel_area_money_"..i]:setVisible(false);
			self["AtlasLabel_area_money_"..i]:setLocalZOrder(1000);
			table.insert(self.AtlasLabel_area_money,self["AtlasLabel_area_money_"..i]);
		end
	end
	--投钱显示区
	self.Image_area = {};
	for k = 1,8 do
		local i = k-1
		if self["Image_area"..i] then
			self["Image_area"..i]:setTag(i);
			table.insert(self.Image_area,self["Image_area"..i]);
		end
	end
	--投钱区
	self.Button_cast = {};
	for k = 1,8 do
		local i = k-1
		if self["Button_cast"..i] then
			self["Button_cast"..i]:addClickEventListener(function(sender) 
				self:ClickCastCallBack(sender); 
			end);
			self["Button_cast"..i]:setTag(i);
			table.insert(self.Button_cast,self["Button_cast"..i]);
		end
	end
	--投资钱的数额
	self.Button_score = {};
	for i = 1,6 do
		if self["Button_score"..i] then
			self["Button_score"..i]:addClickEventListener(function(sender) 
				self:ClickScoreCallBack(sender); 
			end);
			self["Button_score"..i]:setTag(i);
			
			table.insert(self.Button_score,self["Button_score"..i]);
		end
	end
	--下拉菜单
	if self.Button_otherButton then
		self.Button_otherButton:addClickEventListener(function(sender)
			self:ClickOtherButtonBack(sender);
		end)
	end
	--上庄
	if self.Button_bank then
		self.Button_bank:setTag(1);
		self.Button_bank:onClick(function(sender)
			self:ClickVillageBack(sender);
		end)
	end

	--续注
	if self.Button_again then
		self.Button_again:setEnabled(false);
		self.Button_again:onClick(function(sender)
			self:ClickAgain(sender);
		end)
	end
	--路子
	if self.Button_way then
		self.Button_way:addClickEventListener(function(sender)
			self:ClickWayBack(sender);
		end)
	end
	--规则
	if self.Button_rule then
		self.Button_rule:addClickEventListener(function(sender)
			self:ClickRuleBack(sender);
		end)
	end
	--保险箱
	if self.Button_insurance then
		self.Button_insurance:onClick(function(sender)
			self:ClickInsuranceBack(sender);
		end)
	end

	--退出
	if self.Button_menu then
		self.Button_menu:setTag(0);
		self.Image_setting:setVisible(false);
		self.Button_menu:addClickEventListener(function(sender)
			self:gameSetting();
		end)
	end

	--其他玩家
	if self.Button_otherPlayer then
		self.Button_otherPlayer:onClick(function(sender)
			local layer = RankInfoLayer:create(self);
			self:addChild(layer,1000);
		end)
	end

	--路子
	if self.Button_luzi then
		self.Button_luzi:onClick(function(sender)
			luaPrint("Button_luzi");
			-- local layer = LuZiLayer:create(self.GameRecord);
			-- self:addChild(layer,100000);
			LZLogic:GetBigWayList(self.GameRecord);
		end)
	end

	--规则
	if self.Button_guize then
		luaPrint("找到规则按钮");
		self.Button_guize:onClick(function(sender)
			luaPrint("Button_guize");
			local layer = HelpLayer:create();
			self:addChild(layer,100000);
		end)
	end
	--音乐
	if self.Button_yinyue then
		self.Button_yinyue:setTag(0);
		luaPrint("音效",getMusicIsPlay());
		if getMusicIsPlay() then
			playMusic("sound/sound-happy-bg.mp3",true);
			self.Button_yinyue:setTag(0);
			self.Button_yinyue:loadTextures("BJL_lhd_yinyue.png","BJL_lhd_yinyue-on.png","BJL_lhd_yinyue-on.png",UI_TEX_TYPE_PLIST);
		else
			--audio.pauseMusic();
			--setMusicIsPlay(false);
			self.Button_yinyue:setTag(1);
			self.Button_yinyue:loadTextures("BJL_lhd_yinyue-off.png","BJL_lhd_yinyue-off-on.png","BJL_lhd_yinyue-off-on.png",UI_TEX_TYPE_PLIST);
		end
		self.Button_yinyue:addClickEventListener(function(sender)
			luaPrint("Button_yinyue");
			if self.Button_yinyue:getTag() == 0 then
				--audio.pauseMusic();
				setMusicIsPlay(false);
				self.Button_yinyue:setTag(1);
				self.Button_yinyue:loadTextures("BJL_lhd_yinyue-off.png","BJL_lhd_yinyue-off-on.png","BJL_lhd_yinyue-off-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("000")
			else
				--audio.resumeMusic();
				setMusicIsPlay(true);
				playMusic("sound/sound-happy-bg.mp3",true);
				self.Button_yinyue:setTag(0);
				self.Button_yinyue:loadTextures("BJL_lhd_yinyue.png","BJL_lhd_yinyue-on.png","BJL_lhd_yinyue-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("111")
			end
		end)
	end
	--音效
	if self.Button_yinxiao then
		self.Button_yinxiao:setTag(0);
		luaPrint("音效",getEffectIsPlay());
		if getEffectIsPlay() then
			self.Button_yinxiao:setTag(0);
			self.Button_yinxiao:loadTextures("BJL_lhd_yinxiao.png","BJL_lhd_yinxiao-on.png","BJL_lhd_yinxiao-on.png",UI_TEX_TYPE_PLIST);
		else
			self.Button_yinxiao:setTag(1);
			self.Button_yinxiao:loadTextures("BJL_lhd_yinxiao-off.png","BJL_lhd_yinxiao-off-on.png","BJL_lhd_yinxiao-off-on.png",UI_TEX_TYPE_PLIST);
		end
		self.Button_yinxiao:addClickEventListener(function(sender)
			luaPrint("Button_yinxiao");
			if self.Button_yinxiao:getTag() == 0 then
				self.Button_yinxiao:setTag(1);
				--audio.setSoundsVolume(0);
				setEffectIsPlay(false);
				self.Button_yinxiao:loadTextures("BJL_lhd_yinxiao-off.png","BJL_lhd_yinxiao-off-on.png","BJL_lhd_yinxiao-off-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("000")
			else
				self.Button_yinxiao:setTag(0);
				--audio.setSoundsVolume(1);
				setEffectIsPlay(true);
				self.Button_yinxiao:loadTextures("BJL_lhd_yinxiao.png","BJL_lhd_yinxiao-on.png","BJL_lhd_yinxiao-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("111")
			end
		end)
	end
	--退出
	if self.Button_exit then
		self.Button_exit:onClick(function(sender)
			self:onClickExitGameCallBack();

		end)
	end

	--保险柜
	if self.Button_baoxianxiang then
		self.Button_baoxianxiang:onClick(function(sender)
			luaPrint("Button_baoxianxiang");

			--self:showMsgString("正在开发中...");
			createBank(function (data)
				-- body
				self:Baoxian(data);
			end,self.m_bGameStart);
		end)
		-- local image = self.Button_baoxianxiang:getChildByName("Image_1")
		-- image:setVisible(false);
		--self.Button_baoxianxiang:loadTextures("btn_yuebao.png","btn_yuebao_on.png","btn_yuebao_on.png");
	end

	--区块链bar
	self.m_qklBar = Bar:create("baijiale",self);
	self.Button_menu:addChild(self.m_qklBar);
	self.Button_menu:setPositionX(self.Button_menu:getPositionX()-10);
	self.m_qklBar:setPosition(cc.p(40,-80));
	
	if globalUnit.isShowZJ then
		self.m_logBar = LogBar:create(self);
		self.Button_menu:addChild(self.m_logBar);
	end

	--战绩
	if self.Button_zhanji then
		self.Button_zhanji:setVisible(globalUnit.isShowZJ);
		if globalUnit.isShowZJ then
			self.Image_setting:setSize(67,400);
		else
			self.Image_setting:setSize(67,330);
			self.Button_yinyue:setPositionY(self.Button_yinyue:getPositionY()-70);
			self.Button_yinxiao:setPositionY(self.Button_yinxiao:getPositionY()-70);
			self.Button_baoxianxiang:setPositionY(self.Button_baoxianxiang:getPositionY()-70);
			self.Button_guize:setPositionY(self.Button_guize:getPositionY()-70);
		end
		self.Button_zhanji:onClick(function(sender) 
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end)
	end

	if self.Button_bankList then
		self.Button_bankList:onClick(function ()
			self:showAddBankList();
		end);
	end
end

function TableLayer:Baoxian(data)
	--luaPrint("Baoxian");
	--local msg = data._usedata
	--luaDump(data,"data");
	self.selfMoney = self.selfMoney + data.OperatScore;
	self.AtlasLabel_selfMoney:setString(numberToString2(self.selfMoney));
	if self.selfIsBanker then
		self.Text_bankMoney:setString(numberToString2(self.selfMoney));
	end
	luaPrint("Baoxian",self.selfMoney,data.OperatScore);
	if self.m_bGameStart then
		self:setBetEnable(true);
		self:updateBetEnable(self.selfMoney);
	end
	if self.selfMoney>=self.m_scoreLimit then
		self.b_addScore = true;
	end

	self:setXuTouButtonEnable();

end

function TableLayer:getCardTextureFileName(pokerValue)
	local value = string.format("sdb_0x%02X", pokerValue);

	return value..".png";
end


function TableLayer:gameSetting()
	self:loadCacheResource();
	if self.Button_menu:getTag() == 0 then
		luaPrint("gameSetting",self.Button_menu:getTag());
		self.Button_menu:setTag(1)
		self.Image_setting:setVisible(true);
		self.Button_menu:loadTextures("BJL_lhd_xialaanniu.png","BJL_lhd_xialaanniu-on.png","BJL_lhd_xialaanniu-on.png",UI_TEX_TYPE_PLIST);
	else
		luaPrint("gameSetting",self.Button_menu:getTag());
		self.Button_menu:setTag(0)
		self.Image_setting:setVisible(false);
		self.Button_menu:loadTextures("BJL_lhd_xialaanniuup.png","BJL_lhd_xialaanniuup-on.png","BJL_lhd_xialaanniuup-on.png",UI_TEX_TYPE_PLIST);
	end
end

function TableLayer:flushOtherMsg(msg)
    --luaPrint("有玩家进入或者退出,刷新界面")
    local userCount = self.tableLogic:getOnlineUserCount();
    local num = userCount -1;
    self.AtlasLabel_otherNum:setString(num);
    self.otherMsgTable = self:getOthersTable();
    local rankInfoLayer = self:getChildByName("RankInfoLayer");
    if rankInfoLayer then
    	rankInfoLayer:flushOtherMsg()
    end
    self:updateBankerMoney();

    self:initOtherPlayer();

end

function TableLayer:showOtherPlayScore(msg)
	--luaDump(msg,"showOtherPlayScore");
	if msg == nil then
		return;
	end
	--local dwUserID = msg.data.dwUserID;
	--local score = msg.data.dwMoney;

	for k,v in pairs(self.otherNode) do
		local realSeat = v:getTag();
		local score = msg.UserWinScore[realSeat+1];
		luaPrint("showOtherPlayScore",score,k);
		
		local pos = cc.p(150,0);
		if k>3 then
			pos = cc.p(-150,0);
		end
		local str = "baijiale/number/zi_ying.png"
		if score<0 then
			str = "baijiale/number/zi_shu.png"
		end

		if score ~= 0 then
			local scoreText = FontConfig.createWithCharMap(goldConvert(score,1),str,26,50,"+")
			if score>= 0 then
				scoreText:setString("+"..goldConvert(score,1));
			end
			scoreText:setScale(1)
			v:addChild(scoreText);
			scoreText:setPosition(pos);
			scoreText:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function ()
				scoreText:removeFromParent();
			end)));
		end
			
	end
end

--投钱区按钮回调
function TableLayer:ClickCastCallBack(sender)
	local senderTag = sender:getTag();
	--luaPrint("投钱区按钮回调",senderTag,self.selfMoney);
	if not self.m_bGameStart then
		self:showMsgString("请稍后,还没有到下注时间");
		return;
	end

	if self.selfIsBanker then
		self:showMsgString("庄家不能下注！");
		return;
	end

	if not self.b_addScore then
		self:showMsgString("下注失败，您必须有"..(self.m_scoreLimit/100).."金币才能下注");
		showBuyTip();
		return;
	end

	if self.selfMoney < self.betMoneyTable[1] then
		self:showMsgString("金币不足！");
		showBuyTip();
		return;
	end

	if self.ButtonPos == 0 then
		self:showMsgString("未选择筹码");
		return;
	end

	if self.bankSeatNo == 255 or self.bankSeatNo == -1 then
		self:showMsgString("无人坐庄,不可下注！");
		return;
	end
	
	self:lightArea(senderTag,0.1,1);
	BJLInfo:sendAddMoney(self.tableLogic:getMySeatNo(),senderTag,self.ButtonPos);
	--self:showAddMoneyAni(100,senderTag);--(msg.lBetScore,msg.cbBetArea+1);
	
end

--筹码飞上桌面 
function TableLayer:showAddMoneyAni(msg,isOther)
	--luaPrint("showAddMoneyAni",score);
	-- if cast_pos == 3 or cast_pos == 4 or cast_pos == 5 then
	-- 	return;
	-- end

	local betArray = {};
	betArray = self:getCastByNum(msg.lBetScore);
	--luaDump(betArray,"betArray");
	for k,v in pairs(betArray) do
		local sum = v;
		while(sum>0) do
			local sprite = ChouMa:create(self.betMoneyTable[k]); --clone(self.Button_score[score_pos]);
			sprite:setScale(0.35);
			sprite:setArea(msg.cbBetArea);
			sprite:setSeatNo(msg.wChairID);
			--sprite:setPosition(cc.p(24,22));
			sprite:setPosition(cc.p(self.Image_playBg:getPositionX(),self.Image_playBg:getPositionY()))--self.Node_score:convertToNodeSpace(cc.p(self.Image_playBg:getPosition()))
			sprite:setIsMe(true);
			if isOther == true then
				sprite:setPosition(cc.p(self.Button_otherPlayer:getPositionX(),self.Button_otherPlayer:getPositionY()))--self.Node_score:convertToNodeSpace(cc.p(self.Button_otherPlayer:getPosition()))
				sprite:setIsMe(false);
				--起始位置（判断是否是显示的6个）
				if self:isOtherBet(msg) then
					local pos1 = self:getOtherPos(msg);
					luaPrint("其他玩家",pos1.x,pos1.y);
					sprite:setPosition(pos1);
					sprite:setIsMe(false);
				end
			end

			local pos = self:getBetPos(msg.cbBetArea);

			self.Node_score:addChild(sprite,100);
			--self.deskMoneyTable = {};
			table.insert(self.deskMoneyTable,sprite);
			--飞到哪里
			--luaPrint("飞往何处",posx,posy);

			local moveTo = cc.MoveTo:create(0.3,pos);
			sprite:runAction(moveTo);
			sum = sum - 1;
		end
	end

	self:updateAreaMoney(false,msg.lBetScore,msg.cbBetArea);
	--24,22
	audio.playSound("baijiale/sound/sound-betlow.mp3");

end

function TableLayer:isOtherBet(msg)
	local isTrue = false;
	for k,v in pairs(self.otherNode) do
		local tag = v:getTag();
		if msg.wChairID == tag then
			isTrue = true;
			local pos = cc.p(v:getPositionX(),v:getPositionY())
			if k<=3 then
				local move = cc.MoveBy:create(0.15,cc.p(10,0))
				v:runAction(cc.Sequence:create(move,move:reverse()));
			else
				local move = cc.MoveBy:create(0.15,cc.p(-10,0))
				v:runAction(cc.Sequence:create(move,move:reverse()));
			end
			break;
		end
	end
	return isTrue;
end

function TableLayer:getOtherPos(msg)
	local pos = cc.p(0,0);
	for k,v in pairs(self.otherNode) do
		local tag = v:getTag();
		if msg.wChairID == tag then
			pos = cc.p(v:getPositionX(),v:getPositionY());
			break;
		end
	end
	return pos;
end

--获取筹码飞的位置
function TableLayer:getBetPos(cast_pos)
	local disX = 90
	local disY = 30; --随机距离
	local X = 0;
	local Y = 0;
	if cast_pos == 0 then
		X = self.Button_cast0:getPositionX();
		Y = self.Button_cast0:getPositionY();
		disX = 110
	elseif cast_pos == 1 then
		X = self.Button_cast1:getPositionX();
		Y = self.Button_cast1:getPositionY();
	elseif cast_pos == 2 then
		X = self.Button_cast2:getPositionX();
		Y = self.Button_cast2:getPositionY();
		disX = 110
	elseif cast_pos == 3 then
		X = self.Button_cast3:getPositionX();
		Y = self.Button_cast3:getPositionY();
	elseif cast_pos == 4 then
		X = self.Button_cast4:getPositionX();
		Y = self.Button_cast4:getPositionY();
	elseif cast_pos == 5 then
		X = self.Button_cast5:getPositionX();
		Y = self.Button_cast5:getPositionY();
	elseif cast_pos == 6 then
		X = self.Button_cast6:getPositionX();
		Y = self.Button_cast6:getPositionY();
	elseif cast_pos == 7 then
		X = self.Button_cast7:getPositionX();
		Y = self.Button_cast7:getPositionY();
	end

	local randomX = math.random(-disX,disX)
 	local randomY = math.random(-disY,disY)
	local posx = X +randomX;
	local posy = Y +randomY-15;
	local pos = cc.p(posx,posy)
	return pos;
end

--投资钱的数额按钮回调
function TableLayer:ClickScoreCallBack(sender)
	local senderTag = sender:getTag();
	self.ButtonPos = senderTag;
	--self.score = self.betMoneyTable[senderTag];
	luaPrint("投资钱的数额按钮回调",senderTag);
	
	for k,v in pairs(self.Button_score) do
		local tag = v:getTag();
		if tag == senderTag then
			--v:setScale(1.2);
			self:addQuan(v,true)
		else
			v:setScale(1.0);
			self:addQuan(v,false)
		end
	end
	audio.playSound("baijiale/sound/sound-jetton.mp3");
end
--下拉菜单
function TableLayer:ClickOtherButtonBack(sender)
	
end
--上庄
function TableLayer:ClickVillageBack(sender)
	
	if sender:getTag() == 1 then
		luaPrint("我要上庄");
		local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
		if self.m_bankLimitMoney > self.selfMoney then
			self:showMsgString("金钱不足"..(self.m_bankLimitMoney/100).."，无法申请上庄");
			showBuyTip();
		else
			BJLInfo:sendWaitBank();
			self.b_receive = true;
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ( ... )
				if self.b_receive then
					self:refreshBackGame();
				end
			end)));
		end
		
	elseif sender:getTag() == 2 then
		luaPrint("我要下庄");
		BJLInfo:sendCancleBanker();
	elseif sender:getTag() == 3 then
		luaPrint("取消下庄");
		BJLInfo:sendCancleCancleBanker();
	end
end
--续注
function TableLayer:ClickAgain(sender)
	luaPrint("我要续注",self.score);

	if not self.m_bGameStart then
		self:showMsgString("请稍后,还没有到下注时间");
		return;
	end

	if not self.b_addScore then
		self:showMsgString("下注失败，您必须有"..(self.m_scoreLimit/100).."金币才能下注");
		showBuyTip();
		return;
	end

	-- if self.selfMoney < self.betMoneyTable[1] then
	-- 	self:showMsgString("金币不足！");
	-- 	showBuyTip();
	-- 	return;
	-- end
	
	-- if self.score == 0 then
	-- 	self:showMsgString("本轮还没有成功下注");
	-- 	return 
	-- end
	-- local scorePos = -1;
	-- for k,v in pairs(self.betMoneyTable) do
	-- 	if self.score == v then
	-- 		scorePos = k;
	-- 	end
	-- end
	-- --第二种续注
	-- BJLInfo:sendAddMoney(self.tableLogic:getMySeatNo(),self.castPos,scorePos);

	local score = 0;
	for k,v in pairs(self.m_recordScore) do
		score = score + v;
	end

	if self.selfMoney < score then
		self:showMsgString("金币不足！");
		showBuyTip();
		return;
	end

	self:recordAddScore();

end

--自动投注
function TableLayer:autoAddMoney(value,index)
	luaPrint("自动投注",value,index)
	--self.betMoneyTable
	--for k,v in 
	local num = value/self.betMoneyTable[index];
	for i=1,num do
		luaPrint("自动投注",index);
		BJLInfo:sendAddMoney(self.tableLogic:getMySeatNo(),index-1,index)
	end

end

--路子
function TableLayer:ClickWayBack(sender)
	
end
--规则
function TableLayer:ClickRuleBack(sender)
	
end
--保险箱
function TableLayer:ClickInsuranceBack(sender)
	luaPrint("保险箱");
end
--续投
function TableLayer:ClickThrowBack(sender)
	
end

function TableLayer:updateGameSceneRotation(lSeatNo)
	if self.isRotation == true then
		return;
	end

	--luaPrint("自己的逻辑位置 lSeatNo ="..lSeatNo);

	-- if lSeatNo > 1 then	
	-- 	self.isRotation = true;	
	-- 	FLIP_FISH = true
	-- 	self.rotateLayer:setRotation(180)
	-- 	FishManager:setGameRotateEvent(true);
	-- else
	-- 	FLIP_FISH = false
	-- 	self.rotateLayer:setRotation(0)
	-- end
end

--加载玩家信息
function TableLayer:showPlayerInfo()
	local realSeat = self.tableLogic:getMySeatNo();
	luaPrint("showPlayerInfo",realSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(realSeat);
	--luaDump(userInfo,"自己的信息");
	if userInfo then
		self.Text_selfName:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		luaPrint("userInfo.i64Money",userInfo.i64Money);
		self.AtlasLabel_selfMoney:setString(numberToString2(userInfo.i64Money));--userInfo.i64Money
		self.Image_selfHead:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		self.selfMoney = userInfo.i64Money
		if self.selfMoney < self.m_scoreLimit then
			self.b_addScore = false;
		end
	end

end

--添加用户
 function TableLayer:addUser(deskStation, bMe)
	if not self:isValidSeat(deskStation) then 
		return;
	end

	local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
	local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

	self:flushOtherMsg();

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
				self.playerInfo[bSeatNo] = tempInfo;
			end
		end

		deskStation = deskStation + 1;

		if userInfo.dwUserID == PlatformLogic.loginResult.dwUserID then
			self:updateGameSceneRotation(userInfo.bDeskStation);
		end

		self:addPlayer(userInfo);

	end
end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
	
    if not self:isValidSeat(seatNo) then 
        return;
    end
    luaPrint("removeUser",bIsMe,bLock);
    if bIsMe then
		local str = ""
	    if bLock == 0 then
	      --str ="长时间未操作,自动退出游戏。"
	      self:onClickExitGameCallExit();
	    elseif bLock == 1 then
	      str ="您的金币不足,自动退出游戏。"
	      showBuyTip(true);
	      --self:onClickExitGameCallExit();
	    elseif bLock == 2 then
	      	str ="房间已关闭,自动退出游戏。"
    		self:onClickExitGameCallExit();
    		--addScrollMessage(str);
    	elseif bLock == 3 then
    		str ="长时间未操作,自动退出游戏。"
    		self:onClickExitGameCallExit();
    		--addScrollMessage(str);
    	elseif bLock == 5 then
    		str ="vip厅房间关闭。"
    		self:onClickExitGameCallExit();
    		--addScrollMessage(str);
	    end
	    addScrollMessage(str);
		
		return;
    end

    luaPrint("removeUser-----------",seatNo);
    local userCount = self.tableLogic:getOnlineUserCount();
    local num = userCount -1;
    if num >= 0 then
        self.AtlasLabel_otherNum:setString(num);
    end

    --self.otherMsgTable  = self:getOthersTable();
    self:flushOtherMsg();

end

function TableLayer:onClickExitGameCallExit()
	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	end

	Hall:exitGame(false,func)
end

--添加玩家
function TableLayer:addPlayer(userInfo)
	--luaPrint("addPlayer(userInfo) -------------------")
	-- local temp = self.playerLayer:getChildByTag(userInfo.bDeskStation);
	-- if temp then
	-- 	if temp.isAlive == true then
	-- 		if FishModule.m_gameFishConfig then
	-- 			if globalUnit:getGameMode() == true then
	-- 				self.my:updateScore(FishModule.m_gameFishConfig.MatchScore);
	-- 				self.my:updateGetSocre(FishModule.m_gameFishConfig.UserNowMatch);
	-- 			end
	-- 		end
	-- 		return;
	-- 	else
	-- 		temp:removeFromParent();
	-- 	end		
	-- end

	-- local playerNode = player.new(userInfo, userInfo.bDeskStation, self.bulletLayer, self.bulletList)
	-- playerNode:setTag(userInfo.bDeskStation);
	-- self.playerLayer:addChild(playerNode);
	
	-- self.playerNodeInfo[userInfo.bDeskStation] = playerNode;

	-- if userInfo.dwUserID == PlatformLogic.loginResult.dwUserID then
	-- 	self.my = playerNode;

	-- 	if FishModule.m_gameFishConfig then
	-- 		self.my:setFortMultSection(FishModule.m_gameFishConfig.min_bullet_multiple, FishModule.m_gameFishConfig.max_bullet_multiple, FishModule.m_gameFishConfig.exchange_count)
	-- 		if globalUnit:getGameMode() == true then
	-- 			self.my:updateScore(FishModule.m_gameFishConfig.MatchScore);
	-- 			self.my:updateGetSocre(FishModule.m_gameFishConfig.UserNowMatch);
	-- 		end
	-- 	end

	-- 	self:addSeatEffect();
	-- end
end

function TableLayer:isValidSeat(seatNo)
	return seatNo < PLAY_COUNT and seatNo >= 0;
end

-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	--self:clearDesk();

	-- FishModule:clearData();
end

--设置倒计时
function TableLayer:setClockTime(dt)
	if dt == nil or dt == 0 then
		return;
	end
	-- body
	luaPrint("setClockTime",dt);
	if self.AtlasLabel_time then
		self.AtlasLabel_time:stopAllActions();
		self.AtlasLabel_time:setTag(dt);
		self.AtlasLabel_time:setString(dt);
		self.AtlasLabel_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
			cc.DelayTime:create(1),
			cc.CallFunc:create(function()
				self:upateTime();
			 end)
			)));
	end
end

function TableLayer:upateTime()
	if self.AtlasLabel_time then
		local tag = self.AtlasLabel_time:getTag();
		if tag <=1 then
			self.AtlasLabel_time:stopAllActions();
		end
		self.AtlasLabel_time:setTag(self.AtlasLabel_time:getTag()-1);
		self.AtlasLabel_time:setString(self.AtlasLabel_time:getTag());
	end
end

--退出
function TableLayer:onClickExitGameCallBack()
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
	if self.b_xiazhu then--self.b_suo 
		self:showMsgString("本局游戏您已参与,请等待开奖阶段结束。");
		return;
	end
	if self.selfIsBanker then
		self:showMsgString("庄家不能离开房间");
	else
		local func = function()
		    self.tableLogic:sendUserUp();
		    self.tableLogic:sendForceQuit();
		end

		Hall:exitGame(false,func)
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

		--new 打开 gongfu关闭
		-- RoomLogic:close();

		self._bLeaveDesk = true;
		_instance = nil;
		
	end

end

--场景消息 空闲状态
function TableLayer:dealGameStationFree(msg)
	self:clearDesk();
	self.b_isBackGround = true;
	self.n_otherBetScore = {};--其他人下注池
	self.bankJuShu = msg.wBankerTime
	self:setBankInfo(msg);
	self:setApplyPeople(msg.lApplyBankerCondition);
	--self.Button_bank:setEnabled(true);
	self.bankerUserNum = msg.ApplyCount;
	self:updateBankerNum()
	self.alreadyGame = false;
	self:setBetEnable(false);
	self.m_bGameStart = true;
	self.isfive = true;
	self:updateBankList(msg.ApplyUsers,msg.ApplyCount);
end
--场景消息 游戏状态
function TableLayer:dealGameStationPlaying(msg)
	self:clearDesk();
	self.b_isBackGround = true;
	self.alreadyGame = true;
	self:updateBankList(msg.ApplyUsers,msg.ApplyCount);
	self.n_otherBetScore = {};--其他人下注池
	self.bankJuShu = msg.wBankerTime
	self:setBankInfo(msg);
	self:setApplyPeople(msg.lApplyBankerCondition);
	--self.Button_bank:setEnabled(false);
	self.bankerUserNum = msg.ApplyCount;
	self:updateBankerNum();
	--恢复桌面筹码
	self.m_bGameStart = false;
	if self.tableLogic._gameStatus == GameMsg.GS_Play then
		self:updateDeskMoney(msg);
		self:startSchedule(msg.cbTimeLeave);
		self.m_bGameStart = true;
		self.isfive = true;
		self.Image_gameStation:loadTexture("BJL_lhd_xiazhuzhong.png",UI_TEX_TYPE_PLIST);
	elseif self.tableLogic._gameStatus == GameMsg.GS_PLAYING then
		self.alreadyGame = false;
		--self.Image_wait_next:setVisible(true);
		self:addAnimation(1);
		self:setBetEnable(false);
		self.isfive = false;
		self.Image_gameStation:loadTexture("BJL_lhd_kaijiangzhong.png",UI_TEX_TYPE_PLIST);
	end
	self:updateSelfMoney(msg);
	if isHaveBankLayer() then
		createBank(function (data)
				self:Baoxian(data);
			end,self.m_bGameStart);
	end
end

--判断开牌阶段自己是否参与，
--没有参与就不显示开牌界面
function TableLayer:judgeGame(msg)
	--self.alreadyGame = false;
	--ShowAnimate(self.Image_wait_next,2);
	-- self.Image_wait_next:setVisible(true);
	-- self:setBetEnable(false);
end

--显示游戏中金币 
function TableLayer:updateSelfMoney(msg)
	local num = 0;
	for k,v in pairs(msg.lPlayBet) do
		num = num + v;
	end
	local value = self.selfMoney - num;
	luaPrint("updateSelfMoney",self.selfMoney,value);
	self.AtlasLabel_selfMoney:setString(numberToString2(self.selfMoney));

	if num > 0 then
		self.b_suo = true;
		self.b_xiazhu = true;
		GamePromptLayer:remove()
	end
	
	self:updateBetEnable(value);
	if num >0 then
		self.b_addScore = true;
	elseif num == 0 and self.selfMoney < self.m_scoreLimit then
		self.b_addScore = false;
	end
end

--设置庄家信息
function TableLayer:setBankInfo(msg)
	self:loadCacheResource();
	self.bankSeatNo = msg.wBankerUser;
	local userInfo = self.tableLogic:getUserBySeatNo(msg.wBankerUser);
	if userInfo then--not msg.bEnableSysBanker or 
		self.Text_bankName:setString(FormotGameNickName(userInfo.nickName,4));
		if msg.wBankerUser == self.tableLogic:getMySeatNo() then
			self:setBetEnable(false);
			self.b_haveBank = false;
			self.selfIsBanker = true;
			self.Button_bank:loadTextures("BJL_lhd_xiazhuang.png","BJL_lhd_xiazhuang-on.png","BJL_lhd_xiazhuang-on.png",UI_TEX_TYPE_PLIST);
			self.Button_bank:setTag(2);
			if msg.wCancleBanker then
				self.Button_bank:loadTextures("BJL_lhd_qxxz.png","BJL_lhd_qxxz-on.png","BJL_lhd_qxxz-on.png",UI_TEX_TYPE_PLIST);
				self.Button_bank:setTag(3);
			end
		else
			self.b_haveBank = true;
			self.selfIsBanker = false;
			self:setBetEnable(true);
			self.Button_bank:loadTextures("BJL_lhd_shangzhuang.png","BJL_lhd_shangzhuang-on.png","BJL_lhd_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
			self.Button_bank:setTag(1);
			if msg.wApplyBanker then
				self.Button_bank:setTag(2);
				self.Button_bank:loadTextures("BJL_lhd_qxsz.png","BJL_lhd_qxsz-on.png","BJL_lhd_qxsz-on.png",UI_TEX_TYPE_PLIST);
			end
		end
		self.Text_bankMoney:setString(numberToString2(msg.lBankerScore));
	else
		self.Text_bankName:setString("无人坐庄");
		self.Button_bank:setTag(1);
		self.selfIsBanker = false;
		self.Button_bank:loadTextures("BJL_lhd_shangzhuang.png","BJL_lhd_shangzhuang-on.png","BJL_lhd_shangzhuang-on.png",UI_TEX_TYPE_PLIST);
		self:setBetEnable(false);
		self.b_haveBank = false;
		self.Text_bankMoney:setString("");
	end
	
	self.Text_bankJu:setString("局数"..self.bankJuShu);
	--设置时间
	luaPrint("设置时间",msg.cbTimeLeave)
	self:setClockTime(tonumber(msg.cbTimeLeave));
	self:clearDeskMoney();
	self.lianZhuangJuShu = msg.wBankerTime;

	self:initOtherPlayer();
end

function TableLayer:showMsgString(text, fontSize)
	addScrollMessage(text);
end

function TableLayer:setApplyPeople(num2)
	luaPrint("设置申请人数",num2);
	-- if tonumber(num)<0 then
	-- 	luaPrint("设置申请人数出错");
	-- 	return;
	-- end
	--self.Text_peopleNum:setString(tostring(num1));
	self.Text_upBankMoney:setString((num2/100));
	self.m_bankLimitMoney = num2;
end

--区域闪亮 区域.时间.类型 1蓝色2黄色0原色
function TableLayer:lightArea(area,t,_type)
	self:loadCacheResource();
	if _type == nil then
		_type = 0;
	end
	if t == nil then
		t = 0.1
	end
	luaPrint("lightArea",area,t);
	for k,v in pairs(self.Image_area) do
		if self.Image_area[k]:getTag() == area then
			self.Image_area[k]:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
				local str = self:getStr(area,_type)
				luaPrint("area",area,str);
				self.Image_area[k]:loadTexture(str,UI_TEX_TYPE_PLIST);
				self.Image_area[k]:setVisible(true);
				if _type == 2 then
					local fadeIn = cc.FadeIn:create(0.2)
					local fadeOut = cc.FadeOut:create(0.2)
				 	local seq = cc.Sequence:create(fadeOut,cc.DelayTime:create(0.2),fadeIn,cc.DelayTime:create(0.2))
				 	self.Image_area[k]:runAction(cc.Repeat:create(seq,t/0.8));
			 	elseif _type == 0 then
			 		self.Image_area[k]:stopAllActions();
				end
			end),
				cc.DelayTime:create(t),
				cc.CallFunc:create(function ()
					--self.Image_area[k]:loadTexture(".png");
					self:reductionArea();
				end)));
			break;
		end
	end
end

--获取路径 0还原， 1蓝色，2黄色
function TableLayer:getStr(area,_type)
	luaPrint("getStr",area,_type);
	local str = ""
	if area == 0 or area == 2 then
		if _type == 1 then
			str = "BJL_xuanzhong2.png"
		elseif _type == 2 then
			str = "xuanzhong2-2.png"	
		end
	elseif area == 1 then
		if _type == 1 then
			str = "BJL_xuanzhong1.png"
		elseif _type == 2 then
			str = "xuanzhong1-1.png"
		end
	-- elseif area == 5 then
	-- 	if _type == 1 then
	-- 		str = "BJL_xuanzhong1.png"
	-- 	elseif _type == 2 then
	-- 		str = "xuanzhong1-1.png"
	-- 	end
	-- elseif area == 3 or area == 4 then
	-- 	if _type == 1 then
	-- 		str = "lan_1.png"
	-- 	elseif _type == 2 then
	-- 		str = "huang_1.png"
	-- 	end
	elseif area == 6  or area == 7 then
		if _type == 1 then
			str = "BJL_xuanzhong1.png"
		elseif _type == 2 then
			str = "xuanzhong1-1.png"
		end
	end
	return str;
end

--区域还原
function TableLayer:reductionArea()
	-- for k,v in pairs(self.Image_area) do
	-- 	v:stopAllActions();
	-- 	local fadeIn = cc.FadeIn:create(0.1)
	-- 	v:runAction(fadeIn);
	-- 	local str = self:getStr(v:getTag(),0)
	-- 	v:loadTexture(str,UI_TEX_TYPE_PLIST);
	-- end
	for k,v in pairs(self.Image_area) do
		--local str = self:getStr(v:getTag(),0)
		--v:loadTexture(str,UI_TEX_TYPE_PLIST);
		v:setVisible(false);
	end
end

--恢复桌面筹码
function TableLayer:updateDeskMoney(msg)
	--msg.lAllBet--总注
	--msg.lPlayBet--玩家注
	--self.deskMoneyTable = {};--筹码池
	--msg.lAllBet = {0,0,0,0,0,0,0,90100}
	--msg.lPlayBet = {0,0,0,0,0,0,0,0}
	--luaDump(msg.lAllBet,"总筹码");
	--luaDump(msg.lPlayBet,"玩家筹码");
	local otherBet = {0,0,0,0,0,0,0,0}--msg.lAllBet
	for k,v in pairs(otherBet) do
		otherBet[k] = msg.lAllBet[k]-msg.lPlayBet[k]
	end
	--luaDump(otherBet,"除去玩家筹码");
	--先恢复玩家的筹码
	for k,v in pairs(msg.lPlayBet) do
		self:createBet(v,k-1,true);
		if v > 0 then
			self.b_xiazhu = true;
		end
	end
	--恢复其他玩家的筹码
	for k,v in pairs(otherBet) do
		self:createBet(v,k-1,false);
	end

	--恢复桌面显示各区域数据
	self.m_deskMoney = clone(msg.lAllBet)
	local allScore = 0;
	for k,v in pairs(self.m_deskMoney) do
		allScore = allScore + v ;
	end
	self.AtlasLabel_deskAllMoney:setString(allScore/100); --总下注

	for k,v in pairs(self.AtlasLabel_area_money) do
		v:setString(numberToString2(msg.lAllBet[k]));
		if msg.lAllBet[k]>0 then
			v:setVisible(true);
		end
	end
	--恢复自己各区域数据
	self.m_DownBetScore = clone(msg.lPlayBet);
	for k,v in pairs(self.AtlasLabel_me_betmoney) do
		v:setString(numberToString2(msg.lPlayBet[k]));
		if msg.lPlayBet[k]>0 then
			v:setVisible(true);
		end
	end
end

--创建筹码直接在桌子上，不带动作(筹码值，区域，是否自己)
function TableLayer:createBet(value,cast,isMe)
	if value<=0 then
		--luaPrint("创建筹码有误",value);
		return ;
	end
	local betTable = self:getCastByNum(value);
	--luaDump(betTable,"分割出来的筹码个数");
	local moneyTable = self.betMoneyTable--{100,1000,10000,100000,1000000,5000000};
	for k,v in pairs(betTable) do
		--luaPrint("创建个数",v);
		if v>0 then
			for i=1,v do
				--luaPrint("创建筹码",moneyTable[k],cast)
				local bet = ChouMa:create(moneyTable[k]);
				--local copyNode = ChouMa:create(node:getScore());
				bet:setScale(0.35);
				--bet:setPosition(cc.p(149,693));
				bet:setIsMe(isMe);
				bet:setArea(cast);
				self.Node_score:addChild(bet,100);
				table.insert(self.deskMoneyTable,bet);

				-------------------
				local pos = self:getBetPos(cast);
				bet:setPosition(pos);
			end
		end
	end
end

--分割数组
function TableLayer:getCastByNum(value)
	local temp = {0,0,0,0,0,0};
	if value<= 0 then
		return ;
	end
	local betTable = self.betMoneyTable -- {100,1000,10000,100000,1000000,5000000};
	for i=6,1,-1 do
		--luaPrint("i",i,value,betTable[i]);
		if value == 0 then
			--luaPrint("getCastByNum000")
			break;
		end
		if value>=betTable[i] then
			local num = math.floor(value/betTable[i]);
			temp[i] = num;--筹码个数
			value = value - num*betTable[i];
			--luaPrint("getCastByNum",betTable[i],num,value,i);
		end
	end
	return temp;
end

-- function TableLayer:initGameRecord()
--     if self.Image_luzi_1 then
--         local ListView_otherBg = self.Image_luzi_1:getChildByName("ListView_luzi");
--         local sizeScroll = ListView_otherBg:getContentSize();
--         local posScrollX,posScrollY = ListView_otherBg:getPosition();
--         self.Panel_otherMsg_luzi = ListView_otherBg:getChildByName("Panel_luzi");
--         self.Panel_otherMsg_luzi:retain();
--         -- 获取样本战绩信息的容器
--         self.rankTableView_luzi = cc.TableView:create(cc.size(sizeScroll.width,sizeScroll.height));
--         if self.rankTableView_luzi then
--         	luaPrint("initGameRecord");
--             self.rankTableView_luzi:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
--             self.rankTableView_luzi:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
--             self.rankTableView_luzi:setPosition(cc.p(posScrollX,posScrollY));
--             self.rankTableView_luzi:setDelegate();

--             self.rankTableView_luzi:registerScriptHandler( handler(self, self.Record_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
--             self.rankTableView_luzi:registerScriptHandler( handler(self, self.Record_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
--             self.rankTableView_luzi:registerScriptHandler( handler(self, self.Record_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
--             self.rankTableView_luzi:registerScriptHandler( handler(self, self.Record_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
--             self.rankTableView_luzi:reloadData();
--             self.Image_luzi_1:addChild(self.rankTableView_luzi);
--         end
--         ListView_otherBg:removeFromParent();
--     end
--     --显示各局数
--     self:setGameRecordNum();
-- end


-- function TableLayer:Record_scrollViewDidScroll(view)  
--     --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
-- end  
  
-- function TableLayer:Record_cellSizeForTable(view, idx)  

--     local width = self.Panel_otherMsg_luzi:getContentSize().width;
--     local height = self.Panel_otherMsg_luzi:getContentSize().height;
--     --luaPrint("Rank_cellSizeForTable",width, height)
--     return width, height;  
-- end  
  
-- function TableLayer:Record_numberOfCellsInTableView(view)  
--     --luaPrint("Record_numberOfCellsInTableView",table.nums(self.GameRecord))
--     return table.nums(self.GameRecord);
-- end  
  
-- function TableLayer:Record_tableCellAtIndex(view, idx)  
--     luaPrint("Record_tableCellAtIndex",idx);
--     local index = idx + 1;  
--     local cell = view:dequeueCell();
--     if nil == cell then
--         local rankItem = self.Panel_otherMsg_luzi:clone(); 
--         rankItem:setPosition(cc.p(0,0));
--         if rankItem then
--             self:setRcordInfo(rankItem,index);
--         end
--         cell = cc.TableViewCell:new();  
--         cell:addChild(rankItem);
--     else
--         local rankItem = cell:getChildByName("Panel_luzi");
--         self:setRcordInfo(rankItem,index);
--     end

--     --self.rankTableView_luzi:setContentOffset(ccp(0, 100))--self.rankTableView_luzi:getViewSize().height-self.rankTableView_luzi:getContentSize().height));

--     return cell;
-- end 

-- function TableLayer:setRcordInfo(rankItem,index)
--     --luaPrint("TableLayer:setRcordInfo--------",index)
--     local GameRecord = self.GameRecord[index];
--     --luaDump(self.tableLogic._deskUserList._users,"infoTable")
--    	--luaDump(self.GameRecord,"GameRecord")
--     if GameRecord  then
--     	local newImage = rankItem:getChildByName("Image_new");
--     	if newImage then
--     		newImage:setVisible(index == #self.GameRecord );
--     	end
--         local Image_p_zhuang = rankItem:getChildByName("Image_p_zhuang");
--         if Image_p_zhuang then
--             Image_p_zhuang:setVisible(false);
--         end
--         local Image_p_xian = rankItem:getChildByName("Image_p_xian");
--         if Image_p_xian then
--             Image_p_xian:setVisible(false);
--         end
--         local Image_p_ping = rankItem:getChildByName("Image_p_ping");

--         if Image_p_ping then
--         	Image_p_ping:setVisible(false);
--         end

--         if GameRecord.cbPlayerCount > GameRecord.cbBankerCount then--闲胜
--     		Image_p_xian:setVisible(true);
--     		Image_p_xian:getChildByName("Image_zhuangdui"):setVisible(GameRecord.bBankerTwoPair);
--     		Image_p_xian:getChildByName("Image_xiandui"):setVisible(GameRecord.bPlayerTwoPair);
--     	elseif GameRecord.cbPlayerCount == GameRecord.cbBankerCount then--平
--     		Image_p_ping:setVisible(true);
--     		Image_p_ping:getChildByName("Image_zhuangdui"):setVisible(GameRecord.bBankerTwoPair);
--     		Image_p_ping:getChildByName("Image_xiandui"):setVisible(GameRecord.bPlayerTwoPair);
--     	else--庄胜
--     		Image_p_zhuang:setVisible(true);
--     		Image_p_zhuang:getChildByName("Image_zhuangdui"):setVisible(GameRecord.bBankerTwoPair);
--     		Image_p_zhuang:getChildByName("Image_xiandui"):setVisible(GameRecord.bPlayerTwoPair);
--         end
--     end
-- end

--刷新战绩tableview
function TableLayer:flushRecord(isTrue)
	local xian = 0
	local ping = 0
	local zhuang = 0
	local xiandui = 0;
	local zhuangdui = 0;
	local tianwang = 0;
	for k,v in pairs(self.GameRecord) do
		if v.cbPlayerCount>v.cbBankerCount then
			xian = xian + 1
		elseif v.cbPlayerCount == v.cbBankerCount then
			ping = ping + 1
		elseif v.cbPlayerCount < v.cbBankerCount then
			zhuang = zhuang + 1
		end
		if v.bBankerTwoPair then
			zhuangdui = zhuangdui + 1;
		end
		if v.bPlayerTwoPair then
			xiandui = xiandui + 1;
		end
		if v.cbPlayerCount>7 or v.cbBankerCount>7 then
			tianwang = tianwang+1;
		end
	end

	self.AtlasLabel_zhuangNum:setString(zhuang);
	self.AtlasLabel_heNum:setString(ping);
	self.AtlasLabel_xianNum:setString(xian);
	self.AtlasLabel_xianduiNum:setString(xiandui);
	self.AtlasLabel_zhuangduiNum:setString(zhuangdui);
	self.AtlasLabel_tianwangNum:setString(tianwang);

 	self:RefreshAllLZ(self.GameRecord,isTrue);

end

--刷新所有界面
function TableLayer:RefreshAllLZ(msg,isTrue)
	self:RefreshZhuLZ(msg,isTrue);

	self:RefreshDaLZ(msg,isTrue);

	self:RefreshYanLZ(msg,isTrue);

	self:RefreshXiaoLZ(msg,isTrue);

	self:RefreshRyLZ(msg,isTrue);

	self:RefreshLwlLZ(msg);

	self:RefreshHwlLZ(msg);

end

--刷新珠路
function TableLayer:RefreshZhuLZ(msg,isTrue)
	local lzWidth = 8;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetZLWayList(msg,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);
	--luaDump(dataDeal,"dataDeal--");
	--先删除珠路上的所有图片
	self.Panel_zhu:removeAllChildren();
	local size = self.Panel_zhu:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("baijiale/BJL_gameRes.plist","baijiale/BJL_gameRes.png");
	for k1,v1 in pairs(dataDeal) do
		--luaDump(v1,"v1---");
		for k2, v2 in pairs(v1) do
				--2闲 1庄 0平
				local str = "BJL_xianquan.png";
				if v2.type == 0 then
					str = "BJL_he.png";
				elseif v2.type == 1 then
					str = "BJL_xianquan.png";
				elseif v2.type == 2 then
					str = "BJL_zhuangquan.png";
				end

				local sp = cc.Sprite:createWithSpriteFrameName(str);
				sp:setAnchorPoint(0,0);
				sp:setPosition((k1-1)*width+2,(lzHeight - k2)*height+2);
				self.Panel_zhu:addChild(sp);

				--庄对
				if v2.bBankerTwoPair then
					local sprite = cc.Sprite:createWithSpriteFrameName("BJL_zquan1.png")
					sprite:setPosition(3,0+sp:getContentSize().height-3);
					sp:addChild(sprite);
				end
				--闲对
				if v2.bPlayerTwoPair then
					local sprite = cc.Sprite:createWithSpriteFrameName("BJL_xquan1.png")
					sprite:setPosition(0+sp:getContentSize().width-3,3);
					sp:addChild(sprite);
				end

				if v2.lastFlag and isTrue then
					self:shanAni(sp);
				end

		end
	end
end

--闪烁函数 节点 次数
function TableLayer:shanAni(node,num)
	if node == nil then
		return;
	end
	if num == nil then
		num = 5;
	end

	local tt = 0.25;
	local fadeOut = cc.FadeOut:create(tt)
	local fadein = cc.FadeIn:create(tt)
	local delay = cc.DelayTime:create(tt);

	local squ = cc.Sequence:create(fadeOut,fadein);

	node:runAction(cc.Repeat:create(squ,num));

end

--刷新大路
function TableLayer:RefreshDaLZ(msg,isTrue)
	local lzWidth = 25;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetNewBigWayList(msg,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);
	--luaDump(dataDeal,"dataDeal");
	--先删除珠路上的所有图片
	self.Panel_da:removeAllChildren();
	local size = self.Panel_da:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("baijiale/BJL_gameRes.plist","baijiale/BJL_gameRes.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
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

			if v2.lastFlag and isTrue then
				self:shanAni(sp);
			end


		end
	end
end

--刷新大眼仔路
function TableLayer:RefreshYanLZ(msg,isTrue)
	local lzWidth = 18;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,2,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);
	--luaDump(dataDeal,"dataDeal");
	--先删除珠路上的所有图片
	self.Panel_yan:removeAllChildren();
	local size = self.Panel_yan:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	display.loadSpriteFrames("baijiale/BJL_gameRes.plist","baijiale/BJL_gameRes.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "BJL_xquan2.png";
			if v2.color == 1 then
				str = "BJL_xquan2.png";
			elseif v2.color == 2 then
				str = "BJL_zquan2.png";
			end

			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width,(lzHeight - k2)*height);
			self.Panel_yan:addChild(sp);

			if v2.lastFlag and isTrue then
				self:shanAni(sp);
			end

		end
	end
end

--刷新小路
function TableLayer:RefreshXiaoLZ(msg,isTrue)
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
	display.loadSpriteFrames("baijiale/BJL_gameRes.plist","baijiale/BJL_gameRes.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "BJL_xquan1.png";
			if v2.color == 1 then
				str = "BJL_xquan1.png";
			else
				str = "BJL_zquan1.png";
			end
			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width,(lzHeight - k2)*height);
			self.Panel_xiao:addChild(sp);

			if v2.lastFlag and isTrue then
				self:shanAni(sp);
			end

		end
	end
end

--刷新冉由路
function TableLayer:RefreshRyLZ(msg,isTrue)
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
	display.loadSpriteFrames("baijiale/BJL_gameRes.plist","baijiale/BJL_gameRes.png");
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "BJL_xquan3.png";
			if v2.color == 1 then
				str = "BJL_xquan3.png";
			else
				str = "BJL_zquan3.png";
			end

			local sp = cc.Sprite:createWithSpriteFrameName(str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width,(lzHeight - k2)*height);
			self.Panel_ry:addChild(sp);

			if v2.lastFlag and isTrue then
				self:shanAni(sp);
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
		local str = "BJL_xquan.png";
		if lType == 2 then
			str = "BJL_zquan.png";
		end
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10,height);
		self.Panel_lw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,1,3);

	if lType then
		local str = "BJL_xdian.png";
		if lType == 2 then
			str = "BJL_zdian.png";
		end 
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width,height);
		self.Panel_lw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,1,4);

	if lType then
		local str = "BJL_xgang.png";
		if lType == 2 then
			str = "BJL_zgang.png";
		end 
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
		local str = "BJL_xquan.png";
		if lType == 2 then
			str = "BJL_zquan.png";
		end
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10,height);
		self.Panel_hw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,2,3);
	if lType then
		local str = "BJL_xdian.png";
		if lType == 2 then
			str = "BJL_zdian.png";
		end 
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width,height);
		self.Panel_hw:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,2,4);

	if lType then
		local str = "BJL_xgang.png";
		if lType == 2 then
			str = "BJL_zgang.png";
		end
		local sp = cc.Sprite:createWithSpriteFrameName(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width*2,height);
		self.Panel_hw:addChild(sp);

	end

end

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

--获取其他用户的信息
function TableLayer:getOthersTable()
    local othersTable = {};
    for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
            table.insert(othersTable,userInfo)
        end
    end
    -- for i=1,30 do
    --     local userInfo = {}
    --     userInfo.nickName = "111111111"
    --     userInfo.i64Money = 12154500
    --     table.insert(othersTable,userInfo)
    -- end

    return othersTable;
end

--特效
function TableLayer:addAnimation(_type)
	self:clearAni();
	local size = cc.Director:getInstance():getWinSize();
	if _type == 1 then
		luaPrint("等待下一轮游戏开始");
		local skeleton_animation = sp.SkeletonAnimation:create("game/dengdai/dengdai.json", "game/dengdai/dengdai.atlas");
	    skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"dengxiaju", true);
	    self:addChild(skeleton_animation,999);
	    skeleton_animation:setName("addAnimation");
	elseif _type == 2 then
		luaPrint("恭喜获胜");
		local skeleton_animation = sp.SkeletonAnimation:create("animate/gongxihuosheng/gongxihuosheng.json", "animate/gongxihuosheng/gongxihuosheng.atlas");
	    skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"gongxihuosheng", false);
	    self:addChild(skeleton_animation,999);
	    skeleton_animation:setName("addAnimation");
    elseif _type == 3 then
		luaPrint("结算动画");
		local skeleton_animation = sp.SkeletonAnimation:create("animate/jiesuan/jiesuan.json", "animate/jiesuan/jiesuan.atlas");
	    skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"jiesuan", false);
	    self:addChild(skeleton_animation,999);
	    skeleton_animation:setName("addAnimation");
    elseif _type == 4 then
		luaPrint("开始下注");
		local skeleton_animation = sp.SkeletonAnimation:create("game/kaishitingzhi.json", "game/kaishitingzhi.atlas");
	    skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"kaishixiazhu", false);
	    self:addChild(skeleton_animation,999);
	    skeleton_animation:setName("addAnimation");
	    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ( ... )
	    	-- body
	    	--skeleton_animation:removeFromParent();
	    	self:clearAni();
	    end)));
    elseif _type == 5 then
	    luaPrint("游戏开始倒计时");
	    local skeleton_animation = sp.SkeletonAnimation:create("game/daojishi/daojishi.json", "game/daojishi/daojishi.atlas");
	    skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"daojishi", false);
	    self:addChild(skeleton_animation,999);
	    skeleton_animation:setName("addAnimation");
	    self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function ( ... )
	    	-- body
	    	--skeleton_animation:removeFromParent();
	    	self:clearAni();
	    end)));
	    audio.playSound("baijiale/sound/sound-countdown.mp3");
	    skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( ... )
	    	-- body
	    	audio.playSound("baijiale/sound/sound-countdown.mp3");
	    end),cc.DelayTime:create(1.0),cc.CallFunc:create(function ( ... )
	    	-- body
	    	audio.playSound("baijiale/sound/sound-countdown.mp3");
	    end)));
    elseif _type == 6 then
	 	luaPrint("停止下注");   
	 	local skeleton_animation = sp.SkeletonAnimation:create("game/kaishitingzhi.json", "game/kaishitingzhi.atlas");
	    skeleton_animation:setPosition(size.width/2,size.height/2)
	    skeleton_animation:setAnimation(0,"tingzhixiazhu", false);
	    self:addChild(skeleton_animation,999);
	    skeleton_animation:setName("addAnimation");
	    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( ... )
	    	-- body
	    	--skeleton_animation:removeFromParent();
	    	self:clearAni();
	    end)));	
	    audio.playSound("baijiale/sound/sound-end-wager.mp3");
	end
end

--刷新下注按钮
function TableLayer:updateBetEnable(money)
	luaPrint("updateBetEnable",money,self.b_haveBank,self.selfIsBanker,self.ButtonPos);
	if money <= 0 or not self.b_haveBank or self.selfIsBanker then
		self:setBetEnable(false);
		return;
	end 
	--betMoneyTable
	luaPrint("self.ButtonPos00",self.ButtonPos);
	-- if self.b_again then 
	-- 	self.Button_again:setEnabled(true);
	-- else
	-- 	self.Button_again:setEnabled(false);
	-- end

	local noEnable = false;
	for k,button in pairs(self.Button_score) do
		--button:setEnabled(true);
		if money < self.betMoneyTable[k]  then
			noEnable = true;
		end

		if noEnable then
			for i=k,#self.Button_score do
				self.Button_score[i]:setEnabled(false);
				self.Button_score[i]:setScale(1.0);
				self:addQuan(self.Button_score[i],false)
			end
			if self.ButtonPos >= k then
				if k-1 > 0 then
					self.ButtonPos = 1--k-1;
					--self.Button_score[1]:setScale(1.2);
					self:addQuan(self.Button_score[1],true)
					self.score = 100
				else
					self.ButtonPos = 1;
				end
				--self.Button_again:setEnabled(false);
			end
			break;
		end
	end

end

-- --刷新其他玩家信息
-- function TableLayer:flushOtherMsg()
--     luaPrint("有玩家进入或者退出,刷新界面")
--     local userCount = self.tableLogic:getOnlineUserCount();
--     local num = userCount -1;
--     self.Text_otherNum:setString("("..num..")");
--     self.otherMsgTable  = self:getOthersTable();
--     if self.rankTableView then
--         self:CommomFunc_TableViewReloadData_Vertical(self.rankTableView, self.Panel_otherMsg:getContentSize(), false);
--     end
-- end

-- --获取其他用户的信息
-- function TableLayer:getOthersTable()
--     local othersTable = {};
--     for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
--         if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
--             table.insert(othersTable,userInfo)
--         end
--     end
--     return othersTable;
-- end

--显示各局数
function TableLayer:setGameRecordNum()
	local xian = 0;--闲
	local ping = 0;--平
	local zhaung = 0;--庄
	for k,v in pairs(self.GameRecord) do
		if v.cbPlayerCount > v.cbBankerCount then--闲
			xian = xian+1
		elseif v.cbPlayerCount == v.cbBankerCount then--平
			ping = ping+1
		elseif v.cbPlayerCount < v.cbBankerCount then--庄
			zhaung = zhaung+1
		end
	end
	self.AtlasLabel_luzi_xian_num:setString(xian);
	self.AtlasLabel_luzi_ping_num:setString(ping);
	self.AtlasLabel_luzi_zhuang_num:setString(zhaung);

end

--庄家坐庄期间输赢金币
function TableLayer:DealZhuangScore(message)
  local msg = message._usedata;

  local BankGet = require("hall.layer.popView.BankGetLayer");

  local layer = self:getChildByName("BankGetLayer");
  if layer then
    layer:removeFromParent();
  end

  local layer = BankGet:create(msg.score);
  self:addChild(layer,10000);

end

--续投
function TableLayer:recordAddScore()
	luaDump(self.m_recordScore,"recordAddScore");
	-- for k,v in pairs(self.m_recordScore) do
	-- 	if v >0 then
	-- 		--BJLInfo:sendAddMoney(self.tableLogic:getMySeatNo(),k-1,v);
	-- 		local msg = {};
	-- 		msg.cbBetArea = k-1;
	-- 		msg.lBetScore = v;
	-- 		RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_PLACE_JETTON,msg, GameMsg.CMD_C_PlaceBet);
	-- 	end
	-- end

	BJLInfo:sendXuTouMessage(self.m_recordScore);
end

--续投按钮是否可以点击
function TableLayer:setXuTouButtonEnable()
	self.Button_again:setEnabled(false);

	local score = 0;
	for k,v in pairs(self.m_recordScore) do
		score = score + v;
	end

	if score > 0 and self.selfMoney>score and not self.b_xiazhu and self.m_bGameStart then
		self.Button_again:setEnabled(true);
	end

	if self.selfIsBanker then
		self.Button_again:setEnabled(false);
	end

end

--显示上庄列表
function TableLayer:showAddBankList()
	luaPrint("上妆列表");

	if self.listBg == nil then
		self:createBankList();
	else
		self.listBg:removeFromParent();
		self.listBg = nil;
	end

end

function TableLayer:updateBankList(date,i)
	luaDump(date,"updateBankList");
	luaPrint("updateBankList00",i);
	local temp = {};
	for k=1,i do
		table.insert(temp,date[k]);
	end
	self.t_bankTable = temp;

	luaDump(self.t_bankTable);

	if self.listBg then
		self.listBg:removeFromParent();
		self.listBg = nil;
		self:showAddBankList();
	end
end

function TableLayer:createBankList()
	local listBg = ccui.ImageView:create("BG/kuang.png");
	listBg:setPosition(self.Button_bankList:getPositionX()+listBg:getContentSize().width*0.5,
		self.Button_bankList:getPositionY()-listBg:getContentSize().height*0.5-20);
	self.Image_bg:addChild(listBg);
	self.listBg = listBg;

	local listView = ccui.ListView:create()
    listView:setAnchorPoint(cc.p(0.5,0.5))
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(listBg:getContentSize().width-10,listBg:getContentSize().height-30)
    listView:setPosition(listBg:getContentSize().width*0.5+10,listBg:getContentSize().height*0.5)
    listBg:addChild(listView)

    for i=1,#self.t_bankTable do
    	local layout = self:createItem(i);
    	if layout then
    		listView:pushBackCustomItem(layout);
    	end
    end
end

function TableLayer:createItem(i)
	local layout = ccui.Layout:create();
    layout:setContentSize(cc.size(181, 55)); 

    local userInfo = self.tableLogic:getUserBySeatNo(self.t_bankTable[i]);

    if userInfo == nil then
    	return nil;
    end

    local xian = ccui.ImageView:create("BG/xian.png");
    xian:setPosition(layout:getContentSize().width*0.5,layout:getContentSize().height*0.99);
    layout:addChild(xian);

    local image = ccui.ImageView:create("BG/tiao.png");
    image:setPosition(layout:getContentSize().width*0.5,layout:getContentSize().height*0.5);
    layout:addChild(image);

    local index = FontConfig.createWithSystemFont(tostring(i)..".", 20);
    layout:addChild(index);
    index:setPosition(layout:getContentSize().width*0.20,layout:getContentSize().height*0.7);

    local nameText = FontConfig.createWithSystemFont(FormotGameNickName(userInfo.nickName,5), 20);
    nameText:setAnchorPoint(0,0.5);
    nameText:setPosition(layout:getContentSize().width*0.3,layout:getContentSize().height*0.7);
    layout:addChild(nameText);

    local score = FontConfig.createWithSystemFont(numberToString2(userInfo.i64Money), 20,cc.c3b(252,215,27));
    score:setAnchorPoint(0,0.5);
    layout:addChild(score);
    score:setPosition(layout:getContentSize().width*0.3,layout:getContentSize().height*0.3);

    local scoreBg = ccui.ImageView:create("BG/jinbi.png");
    score:addChild(scoreBg);
    scoreBg:setPosition(-20,score:getContentSize().height*0.5);

    return layout;
end

function TableLayer:DealXuTouFail()
	addScrollMessage("庄家不够赔付");
end

function TableLayer:showPlayGameNum()
	if self.m_playGameNum >= 3 then
		if self.m_playGameNum >= 5 then
			addScrollMessage("您已连续5局未参与游戏，已被请出房间！");
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
				self:onClickExitGameCallBack();
			end)));
		else
			addScrollMessage("您已连续"..self.m_playGameNum.."局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
		end
	end
end


return TableLayer;
