local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("errenniuniu.TableLogic");
local ChouMa = require("errenniuniu.ChouMa");
local HelpLayer = require("errenniuniu.HelpLayer");
local errenniuniuLogic = require("errenniuniu.errenniuniuLogic");
local GamePlayerNode = require("errenniuniu.GamePlayerNode");
local PokerCommonDefine = require("errenniuniu.PokerCommonDefine");
local Poker = require("errenniuniu.Poker")
local TrustLayer = require("errenniuniu.TrustLayer")
local EndLayer = require("errenniuniu.EndLayer")
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");
local LookCard = require("errenniuniu.LookCard");
local MiCards = require("errenniuniu.MiCards");

local nMinRoomKey = 0;

--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	luaPrint("PLAY_COUNT",PLAY_COUNT);

	bulletCurCount = 0;


	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene();

	scene:addChild(layer);

	layer.runScene = scene;

	return scene;
end
--创建类
function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
	globalUnit.nMinRoomKey = RoomInfoModule:getRoomNeedGold(uNameId,globalUnit.selectedRoomID);
	nMinRoomKey = globalUnit.nMinRoomKey;
	luaPrint("globalUnit.isTryPlay",globalUnit.isTryPlay);
	if globalUnit.isTryPlay then
		nMinRoomKey = 500000;
	end
	luaPrint("TableLayer",uNameId, bDeskIndex, bAutoCreate, bMaster,uNameId,nMinRoomKey);
	Event:clearEventListener();
	
	local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster);

	globalUnit.isFirstTimeInGame = false;

	PLAY_COUNT = 2;

	return layer;
end
--静态函数
function TableLayer:getInstance()
	return _instance;
end
--构造函数
function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
	self.super.ctor(self, 0, true);
	ERNNInfo:init()
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;

	audio.playMusic("errenniuniu/sound/sound-happy-bg.mp3", true);

	local uiTable = {
		Image_bg = "Image_bg",
		Button_menu = {"Button_menu",0,1},
		Button_tuoguan = {"Button_tuoguan",1},
		Button_help = {"Button_help",1},


		--玩家信息
		Node_player0 = "Node_player0",
		Node_player1 = "Node_player1",
		-- Image_play0 = "Image_play0",
		-- Image_zhuang0 = "Image_zhuang0",
		-- Text_name0 = "Text_name0",
		-- AtlasLabel_money0 = "AtlasLabel_money0",
		-- AtlasLabel_resultMoney_win0 = "AtlasLabel_resultMoney_win0",
		-- AtlasLabel_resultMoney_fail0 = "AtlasLabel_resultMoney_fail0",

		-- Image_play1 = "Image_play1",
		-- Image_zhuang1 = "Image_zhuang1",
		-- Text_name1 = "Text_name1",
		-- AtlasLabel_money1 = "AtlasLabel_money1",
		-- AtlasLabel_resultMoney_win1 = "AtlasLabel_resultMoney_win1",
		-- AtlasLabel_resultMoney_fail1 = "AtlasLabel_resultMoney_fail1",

		Image_clock0 = "Image_clock0",
		AtlasLabel_time0 = "AtlasLabel_time0",
		Image_clock1 = "Image_clock1",
		AtlasLabel_time1 = "AtlasLabel_time1",

		Text_history = "Text_history",
		Text_upju = "Text_upju",
		AtlasLabel_allmoney = "AtlasLabel_allmoney",
		Image_fapaiji = "Image_fapaiji",
		Image_setting = {"Image_setting",0},
		Button_back = "Button_back",
		Button_yinxiao = "Button_yinxiao",
		Button_yinyue = "Button_yinyue",
		Button_start = "Button_start",
		Button_bank = "Button_bank",
		Button_nobank = "Button_nobank",
		Button_lookcard = "Button_lookcard",
		Image_ready0 = "Image_ready0",
		Image_ready1 = "Image_ready1",
		Node_card0 = "Node_card0",
		Node_card1 = "Node_card1",
		Node_bet = "Node_bet",
		Button_bet1 = "Button_bet1",
		Button_bet2 = "Button_bet2",
		Button_bet3 = "Button_bet3",
		Button_bet4 = "Button_bet4",
		AtlasLabel_score1 = "AtlasLabel_score1",
		AtlasLabel_score2 = "AtlasLabel_score2",
		AtlasLabel_score3 = "AtlasLabel_score3",
		AtlasLabel_score4 = "AtlasLabel_score4",
		Image_wancheng = "Image_wancheng",
		Image_trust = "Image_trust",
		Button_trust1 = "Button_trust1",
		Button_trust2 = "Button_trust2",
		Button_trust3 = "Button_trust3",
		Button_trust4 = "Button_trust4",
		Button_trust5 = "Button_trust5",
		Button_trust_close = "Button_trust_close",
		Image_dengdaibank = "Image_dengdaibank",
		Image_clock0 = "Image_clock0",
		Image_clock0 = "Image_clock0",
		Node_card = "Node_card",
		Image_history = "Image_history",
		Node_chouma = "Node_chouma",
		Button_cuopai = "Button_cuopai",
		Button_mipai = "Button_mipai",
	}

	self:initData();

	loadNewCsb(self,"errenniuniu/tableLayer",uiTable)

	_instance = self;

end

function TableLayer:loadCacheResource()
	display.loadSpriteFrames("errenniuniu/errenniuniu.plist", "errenniuniu/errenniuniu.png");
	display.loadSpriteFrames("errenniuniu/card.plist", "errenniuniu/card.png");
	--display.loadSpriteFrames("errenniuniu/cardAni.plist", "errenniuniu/cardAni.png");
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
-- --退出
function TableLayer:onExit()
	self.super.onExit(self);
	display.removeSpriteFrames("errenniuniu/errenniuniu.plist","errenniuniu/errenniuniu.png")
	display.removeSpriteFrames("errenniuniu/card.plist", "errenniuniu/card.png");
	--display.removeSpriteFrames("errenniuniu/cardAni.plist", "errenniuniu/cardAni.png");
end
--绑定消息
function TableLayer:bindEvent()
	self:pushEventInfo(ERNNInfo, "BJLGameStart", handler(self, self.BJLGameStart));
	self:pushEventInfo(ERNNInfo, "BJLGameAddMoney", handler(self, self.BJLGameAddMoney));
	self:pushEventInfo(ERNNInfo, "BJLGameSendCard", handler(self, self.BJLGameSendCard));
	self:pushEventInfo(ERNNInfo, "BJLGameEnd", handler(self, self.BJLGameEnd));
	self:pushEventInfo(ERNNInfo, "BJLGameLookCard", handler(self, self.BJLGameLookCard));
	self:pushEventInfo(ERNNInfo, "GameBank", handler(self, self.GameBank));
	self:pushEventInfo(ERNNInfo, "BJLGameTrust", handler(self, self.BJLGameTrust));
	self:pushEventInfo(ERNNInfo, "BJLGameReady", handler(self, self.BJLGameReady));
	self:pushEventInfo(ERNNInfo, "BJLBegin", handler(self, self.BJLGameBegin));
	--self:pushEventInfo(ERNNInfo, "BJLGameAddMoneyFail", handler(self, self.BJLGameAddMoneyFail));
	--self:pushEventInfo(ERNNInfo, "BJLGameCancleBank", handler(self, self.BJLGameCancleBank));
	--self:pushEventInfo(ERNNInfo, "BJLGameCancleSuccess", handler(self, self.BJLGameCancleSuccess));
	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来

end

--收到播特效消息
function TableLayer:BJLGameBegin(data)
	luaPrint("BJLGameBegin");
	if self.b_isBackGround == false then
		return;
	end
	self:removeClock();
	self:removeDengDaiTiShi();
	self:showStartAni();

end

--播放特效
function TableLayer:showStartAni()
	luaPrint("showStartAni");
	if self.b_isBackGround == false then
		return;
	end
	self:removeStartAni();
	audio.playSound("sound/StartGamewomen.mp3");
	local winSize = cc.Director:getInstance():getWinSize()
    local startAni = createSkeletonAnimation("errenniuniukaishi","animate/errenniuniukaishi/errenniuniukaishi.json","animate/errenniuniukaishi/errenniuniukaishi.atlas");
    if startAni then
        startAni:setPosition(winSize.width/2,winSize.height/2);
        startAni:setAnimation(1,"errenniuniukaishi", false);
        self:addChild(startAni,999);
        startAni:setLocalZOrder(9998);
        startAni:setName("errenniuniukaishi");
        startAni:runAction(cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function ()
        	startAni:removeFromParent();
        end)));
    end
end

--移除开始特效
function TableLayer:removeStartAni()
	local node = self:getChildByName("errenniuniukaishi");
	while(node) do
		node:removeFromParent();
		node = self:getChildByName("errenniuniukaishi");
	end
end

--进入后台
function TableLayer:refreshEnterBack(data)
	luaPrint("进入后台-----------refreshEnterBack")
	if device.platform == "windows" then
		return;
	end

	--self.m_bGameStart = false;
	self.b_isBackGround = false;
end

--后台回来
function TableLayer:refreshBackGame(data)
	luaPrint("后台回来-----------refreshBackGame")
	if device.platform == "windows" then
		return;
	end

	local prompt = self:getChildByName("prompt_erren");
	if prompt then
		return;
	end
	if RoomLogic:isConnect() then

		--self.m_bGameStart = false;
		self.b_isBackGround = false;

		self.mBackGame = true;

		self:stopAllActions();

		self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
		self:wait()
	else
		--self.m_bGameStart = false;
		--self:onClickExitGameCallBack();
	end

end

function TableLayer:wait()
	luaPrint("wait",self.isReply);
	self.isReply = true;
	if self.waitScene then
		self:stopAction(self.waitScene);
		self.waitScene = nil;
	end
	self.waitScene = cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(function ()
		luaPrint("wait00",self.isReply);
		if self.isReply == true then
			self:onClickExitGameCallBack();
		end
	end))
	self:runAction(self.waitScene);
end

function TableLayer:clearDesk()
	self.AtlasLabel_allmoney:setString(numberToString2(0));
	self.Image_ready0:setVisible(false);
	self.Image_ready1:setVisible(false);
	self.Image_dengdaibank:setVisible(false);
	self:hideAllButton();
	self:clearDeskMoney();
	self:clearPokerTable();
	self:removeEffect();
	local layer = self:getChildByName("TrustLayer");
	if layer then
		layer:removeFromParent();
	end
	self:downShowCard();
	self:clearAni();
	-- if self.startBtn then
	-- 	self.startBtn:setVisible(false);
	-- end
	self.selfReady = false;
	self:removeWillStart();
	self:removeLookCardLayer();
	self:removeMiCardLayer()
	self:removeClock();
	self:removeDengDaiTiShi();
end

--游戏开始
function TableLayer:BJLGameStart(data)
	if self.b_isBackGround == false then
		return;
	end
	luaPrint("游戏开始啦----可以下注啦------------");
	local msg = data._usedata;

	luaDump(data,"游戏开始啦");

	self:removeWillStart();

	self.AtlasLabel_allmoney:setString(numberToString2(0));

	self:hideAllButton();

	self.m_bGameStart = true;

	self.addMoneyScore = {0,0};

	self:downShowCard();

	self:updateUserInfo();

	if msg.wBankerUser == self.tableLogic:getMySeatNo() then
		self.b_isBank = true;
		local realSeat = self.tableLogic:viewToLogicSeatNo(1);
		self:setClockTime(5,realSeat);
	else
		self.b_isBank = false;
		self:setClockTime(5,self.tableLogic:getMySeatNo());
	end
	if not self.b_isBank then
		self.Node_bet:setVisible(true);
	end

	self.Image_ready0:setVisible(false);
	self.Image_ready1:setVisible(false);
	self.Image_dengdaibank:setVisible(false);

	--记录下注金额
	if msg.lTurnMaxScore>0 then
		self.m_maxScore = msg.lTurnMaxScore;
		self:setBetMoney(msg.lTurnMaxScore);
	end

	self:setBankSign(msg.wBankerUser);

	playEffect("sound/sound-star.mp3");

end

--设置庄家标志
function TableLayer:setBankSign(realSeat)
	for k,v in pairs(self.playerNodeInfo) do
		v:setBank(false);
	end
	--设置庄家标志
	local viewSeat = self.tableLogic:logicToViewSeatNo(realSeat);
	self.playerNodeInfo[viewSeat+1]:setBank(true);
end

--设置下注金额表
function TableLayer:setBetMoney(score)
	luaPrint("setBetMoney",score);
	self.m_betScoreTable = {0,0,0,0};
	self.m_betScoreTable[1] = math.floor(score); -- /5
	self.m_betScoreTable[2] = math.floor(score/2); --/10
	self.m_betScoreTable[3] = math.floor(score/4);  --/20
	self.m_betScoreTable[4] = math.floor(score/8); --/40

	self.AtlasLabel_score1:setString(numberToString2(self.m_betScoreTable[1]));
	self.AtlasLabel_score2:setString(numberToString2(self.m_betScoreTable[2]));
	self.AtlasLabel_score3:setString(numberToString2(self.m_betScoreTable[3]));
	self.AtlasLabel_score4:setString(numberToString2(self.m_betScoreTable[4]));

end

--下注
function TableLayer:BJLGameAddMoney(data)
	if self.b_isBackGround == false then
		return;
	end
	luaPrint("有人下注啦----------------");
	local msg = data._usedata;

	luaDump(msg,"有人下注啦");

	self:showAddMoneyAni(msg.lAddScoreCount,msg.wAddScoreUser);
	--显示下注总额
	self.AtlasLabel_allmoney:setString(numberToString2(msg.lAddScoreCount));
	playEffect("sound/coin.mp3");

	local viewSeat = self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser);
	self.addMoneyScore[viewSeat+1] = msg.lAddScoreCount;
end

--更新各区域分数 分数，区域 ,是否全部清0
function TableLayer:updateAreaMoney(_type,lBetScore,cbBetArea)
	luaPrint("updateAreaMoney",lBetScore,cbBetArea);
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
--游戏发牌
function TableLayer:BJLGameSendCard(data)
	if self.b_isBackGround == false then
		return;
	end
	luaPrint("发牌----------------");
	local msg = data._usedata;
	
	luaDump(msg,"发牌");
	self.Node_bet:setVisible(false);
	self.Image_dengdaibank:setVisible(false);
	self:setClockTime(10,0,true);
	--self:setClockTime(5,1);
	--记录发牌数据
	self.sendCard = msg.cbCardData;
	local tt = 1.0;
	local allTuoGuan = true;
	for k,v in pairs(self.playerNodeInfo) do
		if v.tuoguan == false then
			allTuoGuan = false;
			break;
		end
	end
	if allTuoGuan then
		luaPrint("全部托管------------------");
		tt = 0.5;
	end
	playEffect("sound/sound-fapai.mp3");
	self.a_sendCardAni = cc.Sequence:create(cc.CallFunc:create(function ( ... )
		-- body
		self:sendAnimate(msg.cbCardData);
	end),cc.DelayTime:create(tt),
	cc.CallFunc:create(function ( ... )
		-- body
		for k,v in pairs(msg.cbCardData) do
			if v > 0 then
	    		local card = self.Node_card0:getChildByName("Image_card"..k);
	    		card:loadTexture(self:getCardTextureFileName(0),UI_TEX_TYPE_PLIST);
			end
		end

		for k=1,5 do
			local card = self.Node_card1:getChildByName("Image_card"..k);
			card:loadTexture(self:getCardTextureFileName(0),UI_TEX_TYPE_PLIST);
		end

		self.Node_card0:setVisible(true);
		self.Node_card1:setVisible(true);
		
	end),cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
		self:clearPokerTable();
		self.Button_lookcard:setVisible(true);
		self.Button_cuopai:setVisible(true);
		self.Button_mipai:setVisible(true);
	end))
	self:runAction(self.a_sendCardAni);

end

--显示自己的手牌
function TableLayer:showMyCard(sendcard)
	local cardData = errenniuniuLogic:sortCard(sendcard,#sendcard);
	
	for k,v in pairs(cardData) do
		if v > 0 then
    		local card = self.Node_card0:getChildByName("Image_card"..k);
    		card:loadTexture(self:getCardTextureFileName(v),UI_TEX_TYPE_PLIST);
		end
	end
	--self.Button_cuopai:setEnabled(false);
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ()
		ERNNInfo:sendOpen(0);
	end)));
	
end

--清理扑克动画池
function TableLayer:clearPokerTable()
	luaPrint("clearPokerTable");
	for k,node in pairs(self.n_pokerTable) do
		if node then
			node:setVisible(false);
			node:stopAllActions();
			node:removeFromParent();
		end
	end
	self.n_pokerTable = {};
end

--发牌动画
function TableLayer:sendAnimate(data)
	--self.n_pokerTable
	luaDump(data,"sendAnimate");
	local posStart = cc.p(245,350)
	local cardPos0 = cc.p(487.52,50.13);
	local cardPos1 = cc.p(559.60,509.31);
	local dis = 40--间距
	local endScale = 1.0
	for i=1,5 do
		local poker = Poker.new(self:getCardTextureFileName(0), 0);
		table.insert(self.n_pokerTable,poker);
		poker:setScale(0.2);
		poker:setVisible(false);
		poker:setPosition(posStart);
		self.Node_card:addChild(poker,100)
		--poker:setTag(data[i]);
		poker:setAnchorPoint(0.5,0);
		local width = poker:getContentSize().width*endScale;
		local moveTo = cc.MoveTo:create(0.1,cc.p(cardPos0.x+dis*(i-1)+width/2,cardPos0.y));--cc.p(cardPos0.x+35*(i-1)+width/2,cardPos0.y)
		local scaleTo = cc.ScaleTo:create(0.1,endScale,endScale);
		local spawn = cc.Spawn:create(moveTo, scaleTo);
		local seq1 = cc.Sequence:create(cc.DelayTime:create(0.1),cc.OrbitCamera:create(0.1,1,0,0,-90,0,0),cc.Hide:create());
		local call = cc.CallFunc:create(function ()
			luaPrint("---------cardValueArray------------",data[i]);
			poker:updataCard(self:getCardTextureFileName(data[i]), data[i]);
		end);
		local seq2 = cc.Sequence:create(cc.Show:create(),cc.OrbitCamera:create(0.1,1,0,90,-90,0,0))
		-- local call = cc.CallFunc:create(function ( ... )
		-- 	poker:setVisible(false);
		-- 	poker:removeFromParent();
		-- end);
		local delay = cc.DelayTime:create(0.1*i);
		local show = cc.CallFunc:create(function ( ... )
			-- body
			poker:setVisible(true);
		end);
		--local ani = cc.Sequence:create(delay,show,cc.Spawn:create(moveTo, scaleTo),seq1,call,seq2);
		local ani = cc.Sequence:create(delay,show,cc.Spawn:create(moveTo, scaleTo));
		poker:runAction(ani);

	end

	for i=1,5 do
		local poker = Poker.new(self:getCardTextureFileName(0), 0);
		poker:setScale(0.2);
		poker:setPosition(posStart);
		self.Node_card:addChild(poker,100)
		poker:setAnchorPoint(0.5,0);
		table.insert(self.n_pokerTable,poker);
		local width = poker:getContentSize().width*endScale;
		local moveTo = cc.MoveTo:create(0.1,cc.p(cardPos1.x+dis*(i-1)+width/2,cardPos1.y));--cc.p(cardPos1.x+35*(i-1)+width/2,cardPos1.y)
		local scaleTo = cc.ScaleTo:create(0.1,endScale,endScale);
		-- local call = cc.CallFunc:create(function ( ... )
		-- 	poker:setVisible(false);
		-- 	poker:removeFromParent();
		-- end);
		local spawn = cc.Spawn:create(moveTo, scaleTo);
		local delay = cc.DelayTime:create(0.1*i);
		poker:runAction(cc.Sequence:create(delay,spawn,cc.CallFunc:create(function ( ... )
			-- body
			-- local card = self.Node_card0:getChildByName("Image_card"..i);
			-- card:setVisible(true);
			-- poker:setVisible(false);
		end)));
	end
	
end

--游戏结束的筹码的移动
function TableLayer:ResultChipRemove(msg)
	if msg == nil then
		return;
	end

	luaPrint("table.nums",table.nums(self.deskMoneyTable),self.m_RealSeat)
	--luaDump(lWinArea);
	local haveNiu1,value1,isNiuNiu1,isYinNiu1,isJinNiu1 = errenniuniuLogic:getNiuType(msg.cbCardData[self.tableLogic:getMySeatNo()+1],5);
	local pos = cc.p(844,138);
	if msg.lGameScore[self.m_RealSeat+1] > 0 then
		pos = cc.p(844,138);
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
			-- body
			if not isNiuNiu1 and not isYinNiu1 and not isJinNiu1 then
				playEffect("sound/niu_win.mp3");
			else
				self:playBigCardBGM("sound/bigcard.mp3");
			end
			self:addAnimation(self.Node_card0,1);
		end)))
		
	else
		pos = cc.p(474,609);
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
			-- body
			playEffect("sound/niu_lose.mp3");
			self:addAnimation(self.Node_card1,1);
		end)))
		
	end
	
	local func1 = cc.CallFunc:create(function ()
		-- body
		for i,node in ipairs(self.deskMoneyTable) do
			local moveTo = cc.MoveTo:create(i*0.01+0.5,pos);
			--luaPrint("moveTo",i);
			node:runAction(moveTo);
		end
	end);
	
	function clearAllChip()
		for k,v in pairs(self.deskMoneyTable) do
			if v then
				v:removeFromParent();
			end
		end
		
		self.deskMoneyTable = {};

	end

	self:runAction(cc.Sequence:create(func1,
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function() clearAllChip() end) ))
	
end


--游戏结束
function TableLayer:BJLGameEnd(data)
	if self.b_isBackGround == false then
		return;
	end

	self:removeSoundAni();

	local layer = self:getChildByName("LookCard");
	if layer then
    	layer:showAnimation();
    end
    local layer = self:getChildByName("MiCards");
	if layer then
    	layer:showAction();
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ()
    	self:removeLookCardLayer();
    	self:removeMiCardLayer()
    end)));

	local msg = data._usedata
	self.endMsg = msg;
	--luaDump(msg,"游戏结束");
	self:clearAni();
	self.m_bGameStart = false;
	
	self.addMoneyScore = {0,0};
	self.sendCard = {};
	--self.b_past = true;
	self.Button_lookcard:setVisible(false);
	self.Button_cuopai:setVisible(false);
	self.Button_mipai:setVisible(false);
	self.Image_wancheng:setVisible(false);
	--self.m_selfMoney = self.m_selfMoney + msg.lGameScore[self.tableLogic:getMySeatNo()+1]
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	--luaDump(userInfo,"BJLGameEnd");
	luaPrint("self.m_selfMoney",self.m_selfMoney);
	self.m_lastScore = msg.lGameScore[self.tableLogic:getMySeatNo()+1];--记录下注金额
	self.m_lastAllScore = self.m_lastAllScore + msg.lGameScore[self.tableLogic:getMySeatNo()+1];--记录总战绩

	--local otherCard = {};
	local realSeat = self.tableLogic:viewToLogicSeatNo(1)+1;
	luaPrint("realSeat",realSeat,self.tableLogic:getMySeatNo()+1);

	--msg.cbCardData = {{10,11,12,3,8},{58,42,2,50,6}}

	local cardData = errenniuniuLogic:sortCardArr(msg.cbCardData);
	--luaDump(cardData,"cardData");
	local myseat = self.tableLogic:getMySeatNo();
	for k,v in pairs(cardData[realSeat]) do
		local card = self.Node_card1:getChildByName("Image_card"..k);
		--luaPrint("card",v);
		card:loadTexture(self:getCardTextureFileName(v),UI_TEX_TYPE_PLIST);
	end

	for k,v in pairs(cardData[myseat+1]) do
		local card = self.Node_card0:getChildByName("Image_card"..k);
		--luaPrint("card",v);
		card:loadTexture(self:getCardTextureFileName(v),UI_TEX_TYPE_PLIST);
	end
	self.Node_card0:setVisible(true);
	self.Node_card1:setVisible(true);
	self:stopAction(self.a_sendCardAni);
	self:clearPokerTable();


	self:upShowCard(clone(msg.cbCardData));
	self:showEndEffect(msg);
	self.bigEndAnimate = cc.Sequence:create(cc.CallFunc:create(function ( ... )
		-- body
		
	end),cc.DelayTime:create(1.5),cc.CallFunc:create(function ( ... )
		-- body
		self:ResultChipRemove(msg);

		for k,v in pairs(msg.lGameScore) do
			local realSeat = self.tableLogic:logicToViewSeatNo(k-1);
			self.playerNodeInfo[realSeat+1]:showScoreAni(v);
		end
		-- for i=1,2 do
		-- 	local realSeat = self.tableLogic:viewToLogicSeatNo(i-1);
		-- 	self.playerNodeInfo[i]:showScoreAni(msg.lGameScore[realSeat+1]);
		-- end

		self.AtlasLabel_allmoney:setString(numberToString2(0));

		self:showHistory(self.m_lastAllScore,self.m_lastScore);

		self:updateUserInfo();

		if globalUnit.nowTingId == 0 then
			self:addButton_new();
		end

	end))

	self:runAction(self.bigEndAnimate);

	--self:checkJueSha(msg.lGameScore[realSeat]);

	--self:updateUserInfo();
	if globalUnit.nowTingId> 0 then
        self:playWillStart()
        if msg.bHaveAction  then
        	self:showEndLayer();
        end
    end
    
end

function TableLayer:removeLookCardLayer()
	local layer = self:getChildByName("LookCard");
	if layer then
		layer:removeFromParent();
	end
end

function TableLayer:removeMiCardLayer()
	local layer = self:getChildByName("MiCards");
	if layer then
		layer:removeFromParent();
	end
end

--显示游戏结束界面
function TableLayer:showEndLayer()
	local endlayer = self:getChildByName("EndLayer");
	if endlayer then
		endlayer:removeFromParent();
	end
	local endlayer = EndLayer:create(self)
	endlayer:setLocalZOrder(9998);
	self:addChild(endlayer);
end


function TableLayer:addButton()
	local size = cc.Director:getInstance():getWinSize();
	if self.startBtn then
		self.startBtn:setVisible(true);
	else
		local startBtn = ccui.Button:create("game/kaishiyouxi.png","game/kaishiyouxi-on.png");
	    self:addChild(startBtn)
	    self.startBtn = startBtn;
	    startBtn:setPosition(size.width/2,size.height/2);
	    startBtn:onClick(function() 
	    	if globalUnit.nowTingId > 0 then
	    		self.tableLogic:sendMsgReady()
	    	else
		    	self:matchGame();
		    end
		end); 
	end
end

function TableLayer:addDengDaiTiShi()
	self:removeDengDaiTiShi();
	local size = cc.Director:getInstance():getWinSize();
	local dengdai = ccui.ImageView:create("game/ddz_fangjian.png");
	dengdai:setPosition(size.width/2,size.height/2);
	self:addChild(dengdai);
	dengdai:setName("dengdai");
	dengdai:setScale(0.5);
end

function TableLayer:removeDengDaiTiShi()
	local node = self:getChildByName("dengdai");
	if node then
		node:removeFromParent();
	end
end

function TableLayer:addButton_new()

	local func = function ()
		local bit = math.random(1,100);
		if bit>10 and self.tableLogic:detectionFull() then
			--addScrollMessage("bit - 准备"..bit);
			self.tableLogic:sendMsgReady()
			self.selfReady = true;
			-- self:addDengDaiTiShi();
			-- self:removeClock();
		else
			addScrollMessage("有玩家离开房间");
			self:matchGame();
		end
	end

	local  size = cc.Director:getInstance():getWinSize();
	if self.startBtn then
		self.startBtn:setVisible(true);
	else
		local startBtn = ccui.Button:create("bg/ernn_jixuyouxi.png","bg/ernn_jixuyouxi-on.png");--继续游戏
		self:addChild(startBtn);
		self.startBtn = startBtn;
		startBtn:setPosition(size.width/2+150,size.height/2);
		startBtn:onClick(function() 
			func();
		end); 
	end

	self:addClock(5,func)

	if self.huanzhuoBtn then
		self.huanzhuoBtn:setVisible(true);
	else
		local huanzhuoBtn = ccui.Button:create("bg/huanzhuo.png","bg/huanzhuo-on.png");
		self:addChild(huanzhuoBtn);
		self.huanzhuoBtn = huanzhuoBtn;
		huanzhuoBtn:setPosition(size.width/2-150,size.height/2);
		huanzhuoBtn:onClick(function ()
			self.tableLogic:sendUserUp();
	        --self.tableLogic:sendForceQuit();
	        UserInfoModule:clear();
	        local score = self.m_selfMoney;
	        local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),globalUnit.selectedRoomID)
	        if score < gold then
	            local prompt = GamePromptLayer:create();
	            prompt:showPrompt(GBKToUtf8("最低需要"..goldConvert(gold).."金币以上！"));
	            prompt:setBtnClickCallBack(function() 
	                local func = function()
	                    self:leaveDesk();
	                end
	                Hall:exitGame(false,func);
	            end); 
	            return;
	        end
	        local errenniuniu = require("errenniuniu");
	        errenniuniu.reStart = true;
	        UserInfoModule:clear();
	        Hall:exitGame(1,function() 
	            self:leaveDesk(1);
	            errenniuniu:ReSetTableLayer(); 
	        end);
		end);
	end

end

function TableLayer:removeButton_new()
	if self.startBtn then
		self.startBtn:setVisible(false);
	end
	if self.huanzhuoBtn then
		self.huanzhuoBtn:setVisible(false);
	end
end

function TableLayer:addClock(ft,func)
	self:removeClock();
	local  size = cc.Director:getInstance():getWinSize();
	--display.loadSpriteFrames("errenniuniu/errenniuniu.plist", "errenniuniu/errenniuniu.png");
	local clock = ccui.ImageView:create("daojishi.png",UI_TEX_TYPE_PLIST)
	clock:setName("clock");
	clock:setPosition(size.width/2+350,size.height/2);
	self:addChild(clock);

	local time = FontConfig.createWithCharMap(ft,"number/zi-jishi.png",15,20,"0")
	time:setTag(ft);
	clock:addChild(time);
	time:setPosition(clock:getContentSize().width*0.5,clock:getContentSize().height*0.5);

	time:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ()
		time:setString(time:getTag()-1);
		time:setTag(time:getTag()-1);
		if time:getTag() < 1 then
			time:getParent():removeFromParent();
			if func then
				--func();
				self:onClickExitGameCallBack();
				addScrollMessage("结算阶段未操作，自动离开房间");
			end
		end
	end)),ft));
end

function TableLayer:removeClock()
	local node = self:getChildByName("clock");
	if node then
		node:removeFromParent();
	end
end

function TableLayer:matchGame()
	self.tableLogic:sendUserUp();
	-- self.tableLogic:sendForceQuit();
	UserInfoModule:clear();
    local score = self.m_selfMoney;
    local gold = RoomInfoModule:getRoomNeedGold(GameCreator:getCurrentGameNameID(),globalUnit.selectedRoomID)

    if score < gold then
        local prompt = GamePromptLayer:create();
        prompt:showPrompt(GBKToUtf8("最低需要"..goldConvert(gold).."金币以上！"));
        prompt:setBtnClickCallBack(function() 
            local func = function()
                self:leaveDesk();
            end
            Hall:exitGame(false,func);
        end); 
        return;
    end

    local errenniuniu = require("errenniuniu");
    errenniuniu.reStart = true;
    UserInfoModule:clear();

    Hall:exitGame(1,function() 
        self:leaveDesk(1);
        errenniuniu:ReSetTableLayer(score); 
    end);
end

--清除游戏结束动画
function TableLayer:removeEndAni()

	if self.bigEndAnimate then
		self:stopAction(self.bigEndAnimate);
		self.bigEndAnimate = nil;
		self:clearDeskMoney();
	end

	self:hideAllButton();

	self.AtlasLabel_allmoney:setString(numberToString2(0));

	self:showHistory(self.m_lastAllScore,self.m_lastScore);

	self:updateUserInfo();

end

function TableLayer:checkJueSha()
	luaPrint("checkJueSha",self.m_otherMoney,nMinRoomKey);
	if self.m_otherMoney < nMinRoomKey then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ( ... )
			--self:onClickExitGameCallBack();
			self:addAnimation(nil,2);
		end)));
	end
end

--弹牌
function TableLayer:upShowCard(cbCardData)

	for k,v in pairs(cbCardData) do
		local have = errenniuniuLogic:foundNiu(cbCardData[k],5);
		local node;
		if k == self.tableLogic:getMySeatNo()+1 then
			node = self.Node_card0
		else
			node = self.Node_card1
		end
		if have then
			for i=1,2 do
				local card = node:getChildByName("Image_card"..i);
				card:setPositionY(card:getPositionY()+15);
			end
		end
	end
end

--降牌
function TableLayer:downShowCard()
	for i=1,2 do
		local card5 = self.Node_card0:getChildByName("Image_card5");
		local card = self.Node_card0:getChildByName("Image_card"..i);
		card:setPositionY(card5:getPositionY());

		local card5 = self.Node_card1:getChildByName("Image_card5");
		local card = self.Node_card1:getChildByName("Image_card"..i);
		card:setPositionY(card5:getPositionY());
	end
end

--游戏展示牛牛特效
function TableLayer:showEndEffect(msg)
	local realSeat = self.tableLogic:viewToLogicSeatNo(1)+1;
	local haveNiu1,value1,isNiuNiu1,isYinNiu1,isJinNiu1 = errenniuniuLogic:getNiuType(msg.cbCardData[self.tableLogic:getMySeatNo()+1],5);
	local haveNiu2,value2,isNiuNiu2,isYinNiu2,isJinNiu2 = errenniuniuLogic:getNiuType(msg.cbCardData[realSeat],5);
	self:addEffect(haveNiu1,value1,isNiuNiu1,isYinNiu1,isJinNiu1,self.Node_card0,true);
	self:addEffect(haveNiu2,value2,isNiuNiu2,isYinNiu2,isJinNiu2,self.Node_card1,false);

	

	self:runAction(cc.Sequence:create(cc.CallFunc:create(function ( ... )
		-- body
		self:playSound(haveNiu1,value1);
	end)));

end

--牛几的声音
function TableLayer:playSound(haveNiu,value)
	local str = "sound/"
	local sex = "0"
	local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	if userInfo then
		if getUserSex(userInfo.bLogoID,userInfo.bBoy) then
			sex = "0"
		else
			sex = "1"
		end
	end
	local _type = ".mp3"
	if haveNiu == false then
		str = str.."N0_"..sex.._type;--N0_1
	elseif haveNiu  then
		if value > 10 then 
			value = 10 
		elseif value == 0 or value == 10 then
			value = 10;
		end

		str = str.."N"..value.."_"..sex.._type
	end
	luaPrint("playsoundstr111",str);
	playEffect(str);
end

function TableLayer:addEffect(haveNiu,value,isNiuNiu,isYinNiu,isJinNiu,node,playSound)
	node:setVisible(true);
	local skeleton = node:getChildByName("effect");
	if skeleton then
		skeleton:removeFromParent();
	end
	local skeleton_animation = sp.SkeletonAnimation:create("animate/errenpinshi/errenpinshi.json", "animate/errenpinshi/errenpinshi.atlas");
    skeleton_animation:setPosition(20,-10)
    local str = "";
    if haveNiu then
    	if isJinNiu then
    		str = "jinniu"
		elseif isYinNiu then
			str = "yinniu"
		elseif isNiuNiu then
			str = "niuniu"
		else
			str = "niu"..value;
		end
    else
    	str = "meiniu"
    end

    skeleton_animation:setAnimation(0,str, false);
    skeleton_animation:setName("effect");
    node:addChild(skeleton_animation,10000);
end

--音效文件，延时时间
function TableLayer:playBigCardBGM(str,ft)
	if str == "" or str == nil then
		return;
	end
	if ft == nil then
		ft = 1;
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(ft),cc.CallFunc:create(function ()
		playEffect(str);
	end)));
end


--让谁准备
function TableLayer:BJLGameReady(data)
	if self.b_isBackGround == false then
		return;
	end
	if self.m_bGameStart == true then
		return;
	end
	self.Node_bet:setVisible(false);
	self.Button_start:setVisible(false);
	self.Button_bank:setVisible(false);
	self.Button_nobank:setVisible(false);
	self.Button_lookcard:setVisible(false);
	self.Button_cuopai:setVisible(false);
	self.Button_mipai:setVisible(false);

	local msg = data._usedata
	luaPrint("BJLGameReady",msg.wCurrentUser,self.tableLogic:getMySeatNo());
	self.Image_dengdaibank:setVisible(false);
	if self.tableLogic:detectionFull() then
		self:setClockTime(15,msg.wCurrentUser);
	end
	if msg.wCurrentUser == self.tableLogic:getMySeatNo() then
		self.Button_start:setVisible(true);
	else
		self.Button_start:setVisible(false);
	end
end

function TableLayer:removeEffect()
	local node = self.Node_card0:getChildByName("effect");
	if node then
		node:removeFromParent();
	end
	local node1 = self.Node_card1:getChildByName("effect");
	if node1 then
		node1:removeFromParent();
	end
end

function TableLayer:hideAllButton()

	self.Node_bet:setVisible(false);
	self.Node_card0:setVisible(false);
	self.Node_card1:setVisible(false);
	--self.Image_ready0:setVisible(false);
	--self.Image_ready1:setVisible(false);
	self.Button_start:setVisible(false);
	self.Button_bank:setVisible(false);
	self.Button_nobank:setVisible(false);
	self.Button_lookcard:setVisible(false);
	self.Button_cuopai:setVisible(false);
	self.Button_mipai:setVisible(false);
end

--托管
function TableLayer:BJLGameTrust(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata
	--local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
	if msg.wPlayerID == self.tableLogic:getMySeatNo() then
		if msg.bTrust then
			local layer = TrustLayer:create();
			self:addChild(layer,10000);
		else
			local layer = self:getChildByName("TrustLayer");
			if layer then
				layer:removeFromParent();
			end
		end
	end

	self.playerNodeInfo[self.tableLogic:logicToViewSeatNo(msg.wPlayerID)+1]:hideTuoguan(msg.bTrust);
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

--叫庄
function TableLayer:GameBank(data)
	if self.b_isBackGround == false then
		return;
	end
	self:removeWillStart();
	self:removeStartAni();
	local msg = data._usedata
	self.m_bGameStart = true;
	self.selfReady = false;
	self:hideAllButton();
	self.AtlasLabel_allmoney:setString(numberToString2(0));
	self.Image_ready0:setVisible(false);
	self.Image_ready1:setVisible(false);
	luaDump(msg,"叫庄");
	self:setClockTime(5,msg.wCallBanker);
	if msg.wCallBanker == self.tableLogic:getMySeatNo() then
		self.Button_bank:setVisible(true);
		self.Button_nobank:setVisible(true);
		self.Image_dengdaibank:setVisible(false);
	else
		--self:showMsgString("等待叫庄");
		self.Image_dengdaibank:setVisible(true);
	end
	playEffect("sound/sound-banker.mp3");
end

--游戏摊牌
function TableLayer:BJLGameLookCard(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata
	luaPrint("摊牌",msg.wPlayerID,self.tableLogic:getMySeatNo(),msg.bOpen);
	local viewSeat = self.tableLogic:logicToViewSeatNo(msg.wPlayerID);
	if msg.wPlayerID ~= self.tableLogic:getMySeatNo() then
		self.Image_wancheng:setVisible(true);
		self.Image_clock1:setVisible(false);
		self.playerNodeInfo[viewSeat+1]:removeTime();
	elseif msg.wPlayerID == self.tableLogic:getMySeatNo() then
		self.Button_lookcard:setVisible(false);
		self.Button_cuopai:setVisible(false);
		self.Button_mipai:setVisible(false);
		self.Image_clock0:setVisible(false);
		self.playerNodeInfo[viewSeat+1]:removeTime();
	end
end

function TableLayer:isMeApplyBanker()
    local value = self.tableLogic._mySeatNo;
    for k,v in ipairs(self.t_bankTable) do
      if v == value then
          return true
      end
    end
    return false
end


--设置按钮状态
function TableLayer:setBetEnable(isTrue)
	luaPrint("setBetEnable");
	for k,v in pairs(self.Button_score) do
		luaPrint("setBetEnable",k);
		v:setEnabled(isTrue);
		if not isTrue then
			v:setScale(1.0);
		end
	end
	self.Button_again:setEnabled(isTrue);
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
	luaPrint("gameUserCut",seatNo, bCut);
	if bCut then
        self.playerNodeInfo[seatNo + 1]:setCutHead();
    else
    	local userInfo = self.tableLogic:getUserBySeatNo(seatNo);
        self.playerNodeInfo[seatNo + 1]:setHead(self.tableLogic:getUserHeadId(seatNo), self.tableLogic:getUserUserId(seatNo),userInfo.bBoy);
    end

end

--初始化数据
function TableLayer:initData()	
	
	--玩家对象存储
	self.playerNodeInfo = {};

	--玩家昵称
	self.playerInfo = {};--包括昵称 ID 登陆IP 性别
	--准备图片
	self.readyImage = {};

	self._bLeaveDesk = false; --false 在桌子上 true 离开桌子

	--游戏是否开始
	self.m_bGameStart = false;

	self._bReconding = false;

	--有事解散
	self._isHaveThing = false;

	--房间类型
	self.roomType = RoomType.NormalRoom;--默认正常房间

	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;
	self.m_maxScore = 0;--最大下注金额
	self.deskMoneyTable = {};--筹码池
	self.betMoneyTable = {100,1000,5000,10000,50000,100000}--筹码表
	self.b_isBank = false;--记录是否是庄家
	self.m_lastScore = 0;--上一轮下注金额
	self.m_lastAllScore = 0;--历史总战绩
	self.n_pokerTable = {};--动画扑克池
	self.m_selfMoney = 0;--自己的金钱
	self.m_otherMoney = 0;--对面玩家的金钱
	self.m_RealSeat = 255;
	--self.ReadyRealSeat = 255;--记录准备玩家
	--self.b_past = false; --记录玩家有木有进行过游戏
	self.a_sendCardAni = nil;--发牌动画
	self.b_isBackGround = false;--记录游戏是否切后台
	self.bigEndAnimate = nil;--游戏结束整个动画
	self.endMsg = nil;--游戏结束消息
	--玩家下注金额
	self.addMoneyScore = {0,0};
	--记录发牌结束玩家的手牌
	self.sendCard = {};
	--检测场景消息是否回复
	self.isReply = false;
	--记录自己状态，第二个回合生效
	self.selfReady = false;

	self.mBackGame = false;
end
--初始化界面
function TableLayer:initUI()
	self:loadCacheResource();
	--基本按钮
	self:initGameNormalBtn();

	self:hideClock();

	-- 初始化玩家信息
    self:initPlayerInfo();

    --适配游戏
    --self:adjustmentGame();

	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

end

--初始化玩家信息
function TableLayer:initPlayerInfo()
	--self.Image_play0:setVisible(false);
	--self.Image_play1:setVisible(false);
	self.playerNodeInfo = {};

	for i=1,PLAY_COUNT do
		local k = i -1;

		--玩家准备图片
		self["Image_ready"..k]:setVisible(false);

		--self.readyImage[i] = self["Image_ready"..k];
		table.insert(self.readyImage,self["Image_ready"..k]);

		--玩家语音图标
		--self["Image_chat"..k]:setVisible(false);
		--self.chatImage[i] = self["Image_chat"..k];

		--玩家信息
		
		local node = self["Node_player"..k];
		luaPrint("创建头像");
		--node:setLocalZOrder(100)
		local playerNode = GamePlayerNode.new(INVALID_USER_ID, k,self);--默认显示
		--playerNode:setEmptyHead();
		--node:addChild(playerNode);
		node:addChild(playerNode);
		--playerNode:showScoreAni(-100);
		if node then
			luaPrint("节点在");
		end
		playerNode:setPosition(cc.p(0,0));
		--playerNode:setPlayInfoButton();

		table.insert(self.playerNodeInfo,playerNode);

		--self:setUserMoney(k, 0);
		--self:showUserMoney(k, false);
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
	self.Node_card0:setVisible(false);
	self.Node_card1:setVisible(false);
	self.Node_bet:setVisible(false);
	self.Image_wancheng:setVisible(false);
	self.Image_trust:setVisible(false);
	self.Image_trust:setLocalZOrder(9998)
	self.Image_dengdaibank:setVisible(false);
	self.Image_history:setVisible(false);
	--下拉菜单
	if self.Button_menu then
		self.Button_menu:setTag(0);
		self.Image_setting:setVisible(false);
		self.Button_menu:addClickEventListener(function(sender)
			self:ClickOtherButtonBack(sender);
		end)
	end

	--准备按钮
	if self.Button_start then
		self.Button_start:setVisible(false);
		self.Button_start:setLocalZOrder(9998);
		self.Button_start:setTag(0);
		self.Button_start:onClick(function(sender)
			self:gameButton(sender);
		end)
	end
	--叫庄按钮
	if self.Button_bank then
		self.Button_bank:setVisible(false);
		self.Button_bank:setLocalZOrder(9998);
		self.Button_bank:setTag(1);
		self.Button_bank:onClick(function(sender)
			self:gameButton(sender);
		end)
	end
	--不叫
	if self.Button_nobank then
		self.Button_nobank:setVisible(false);
		self.Button_nobank:setLocalZOrder(9998);
		self.Button_nobank:setTag(2);
		self.Button_nobank:onClick(function(sender)
			self:gameButton(sender);
			local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
			if userInfo then
				if getUserSex(userInfo.bLogoID,userInfo.bBoy) then
					playEffect("sound/Man_bujiao.wav");
				else
					playEffect("sound/Woman_bujiao.wav");
				end
			end 
			
		end)
	end
	--摊牌
	if self.Button_lookcard then
		self.Button_lookcard:setVisible(false);
		self.Button_lookcard:setLocalZOrder(9998);
		self.Button_lookcard:setTag(3);
		self.Button_lookcard:onClick(function(sender)
			self:gameButton(sender);
		end)
	end

	--搓牌
	if self.Button_cuopai then
		self.Button_cuopai:setVisible(false);
		self.Button_cuopai:setLocalZOrder(9998);
		self.Button_cuopai:setTag(4);
		self.Button_cuopai:onClick(function(sender)
			self:gameButton(sender);
		end)
	end

	--咪牌
	if self.Button_mipai then
		self.Button_mipai:setVisible(false);
		self.Button_mipai:setLocalZOrder(9998);
		self.Button_mipai:setTag(5);
		self.Button_mipai:onClick(function(sender)
			self:gameButton(sender);
		end)
	end

	for i=1,4 do
		if self["Button_bet"..i] then
			self["Button_bet"..i]:setTag(i);
			self["Button_bet"..i]:onClick(function (sender)
				self:gameAddScore(sender);
			end);
		end
	end
	
	-- --保险箱
	-- if self.Button_insurance then
	-- 	self.Button_insurance:addClickEventListener(function(sender)
	-- 		self:ClickInsuranceBack(sender);
	-- 	end)
	-- end
	if self.Button_tuoguan then
		self.Button_tuoguan:setVisible(false);
		luaPrint("托管");
		self.Button_tuoguan:onClick(function(sender)
			--ERNNInfo:sendTrust(1)
			self.Image_trust:setVisible(true);
		end)
	end

	--托管下注选择
	for i=1,5 do
		if self["Button_trust"..i] then
			self["Button_trust"..i]:setTag(i-1);
			
			self["Button_trust"..i]:onClick(function(sender)
				luaPrint("Button_trust",sender:getTag());
				ERNNInfo:sendTrust(sender:getTag())
				self.Image_trust:setVisible(false);
			end)
		end
	end

	if self.Button_trust_close then
		self.Button_trust_close:onClick(function ()
			self.Image_trust:setVisible(false);
		end);
	end
	
	--规则
	if self.Button_help then
		luaPrint("找到规则按钮");
		self.Button_help:onClick(function(sender)
			luaPrint("Button_guize");
			local layer = HelpLayer:create();
			self:addChild(layer,10000);
		end)
	end
	--音乐
	if self.Button_yinyue then
		self.Button_yinyue:setTag(0);
		if getMusicIsPlay() then
			playMusic("sound/table_music.mp3",true);
			self.Button_yinyue:setTag(0);
			self.Button_yinyue:loadTextures("yinyuekai.png","yinyuekai-on.png","yinyuekai-on.png",UI_TEX_TYPE_PLIST);
		else
			--audio.pauseMusic();
			--setMusicIsPlay(false);
			self.Button_yinyue:setTag(1);
			self.Button_yinyue:loadTextures("yinyueguan.png","yinyueguan-on.png","yinyueguan-on.png",UI_TEX_TYPE_PLIST);
		end
		self.Button_yinyue:addClickEventListener(function(sender)
			luaPrint("Button_yinyue");
			if self.Button_yinyue:getTag() == 0 then
				audio.pauseMusic();
				setMusicIsPlay(false);
				self.Button_yinyue:setTag(1);
				self.Button_yinyue:loadTextures("yinyueguan.png","yinyueguan-on.png","yinyueguan-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("000")
			else
				audio.resumeMusic();
				setMusicIsPlay(true);
				playMusic("sound/table_music.mp3",true);
				self.Button_yinyue:setTag(0);
				self.Button_yinyue:loadTextures("yinyuekai.png","yinyuekai-on.png","yinyuekai-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("111")
			end
		end)
	end
	--音效
	if self.Button_yinxiao then
		self.Button_yinxiao:setTag(0);
		if getEffectIsPlay() then
			--playMusic("sound/sound-happy-bg.mp3",true);
			self.Button_yinxiao:setTag(0);
			self.Button_yinxiao:loadTextures("yinxiaokai.png","yinxiaokai-on.png","yinxiaokai-on.png",UI_TEX_TYPE_PLIST);
		else
			--audio.pauseMusic();
			--setMusicIsPlay(false);
			self.Button_yinxiao:setTag(1);
			self.Button_yinxiao:loadTextures("yinxiaoguan.png","yinxiaoguan-on.png","yinxiaoguan-on.png",UI_TEX_TYPE_PLIST);
		end
		self.Button_yinxiao:addClickEventListener(function(sender)
			luaPrint("Button_yinxiao");
			--self:showMsgString("关闭音效功能正在开发");
			if self.Button_yinxiao:getTag() == 0 then
				self.Button_yinxiao:setTag(1);
				--audio.setSoundsVolume(0);
				setEffectIsPlay(false);
				self.Button_yinxiao:loadTextures("yinxiaoguan.png","yinxiaoguan-on.png","yinxiaoguan-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("000")
			else
				self.Button_yinxiao:setTag(0);
				--audio.setSoundsVolume(1);
				setEffectIsPlay(true);
				self.Button_yinxiao:loadTextures("yinxiaokai.png","yinxiaokai-on.png","yinxiaokai-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("111")
			end
		end)
	end
	--退出
	if self.Button_back then
		self.Button_back:onClick(function(sender)
			self:onClickExitGameCallBack()
		end)
	end

	if globalUnit.isShowZJ then

		self.m_logBar = LogBar:create(self);
		self.Button_menu:addChild(self.m_logBar);

		self.Image_setting:loadTexture("bg/setbg.png");
		self.Image_setting:ignoreContentAdaptWithSize(true);
		self.Button_zhanji = ccui.Button:create("bg/zhanji.png","bg/zhanji-on.png");
		self.Button_zhanji:setPosition(self.Button_yinyue:getPositionX(),self.Button_yinyue:getPositionY());
		self.Button_back:setPositionY(self.Button_back:getPositionY()+70);
		self.Button_yinyue:setPositionY(self.Button_yinyue:getPositionY()+70);
		self.Button_yinxiao:setPositionY(self.Button_yinxiao:getPositionY()+70);
		self.Image_setting:addChild(self.Button_zhanji);
		self.Button_zhanji:onClick(function(sender) 
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end)
	end

	--区块链bar
	self.m_qklBar = Bar:create("errenniuniu",self);
	self.Button_help:addChild(self.m_qklBar);
	self.m_qklBar:setPosition(cc.p(40,-100));

end

--下注按钮回调
function TableLayer:gameAddScore(sender)
	local tag = sender:getTag();
	luaPrint("我要下注",tag);
	self:removeSoundAni();
	local score = 0;
	if tag == 1 then
		score = self.m_betScoreTable[1]
	elseif tag == 2 then
		score = self.m_betScoreTable[2]
	elseif tag == 3 then
		score = self.m_betScoreTable[3]
	elseif tag == 4 then
		score = self.m_betScoreTable[4]
	end

	ERNNInfo:sendAddMoney(score)

end

--游戏按钮回调
function TableLayer:gameButton(sender)

	local tag = sender:getTag();
	luaPrint("gameButton",tag);
	if tag ~= 4 and tag ~= 5 then
		self:removeSoundAni();
	end
	if tag == 0 then--开始
		ERNNInfo:sendStart();
	elseif tag == 1 then--叫庄
		ERNNInfo:sendWantBank(1);
	elseif tag == 2 then--不叫庄
		ERNNInfo:sendWantBank(0);
	elseif tag == 3 then--摊牌
		ERNNInfo:sendOpen(0);
		if self.sendCard then
			self:showMyCard(self.sendCard);
		end
	elseif tag == 4 then -- 搓牌
		if #self.sendCard == 5 then
			local layer = self:getChildByName("LookCard");
			if not layer then
				local layer = LookCard:create(self.sendCard,self);
				self:addChild(layer);
				self.Button_cuopai:setVisible(false);
				self.Button_lookcard:setVisible(false);
				self.Button_mipai:setVisible(false);
				ERNNInfo:sendAddMoney(0)
			end
		end
	elseif tag == 5 then -- 咪牌
		if #self.sendCard == 5 then
			local layer = self:getChildByName("MiCards");
			if not layer then
				local layer = MiCards:create(self);
				self:addChild(layer);
				layer:createHandPoker(self.sendCard)
				self.Button_cuopai:setVisible(false);
				self.Button_lookcard:setVisible(false);
				self.Button_mipai:setVisible(false);
				ERNNInfo:sendAddMoney(0)
			end
		end
	end
end

function TableLayer:getCardTextureFileName(pokerValue)
	local value = string.format("sdb_0x%02X", pokerValue);

	return value..".png";
end


function TableLayer:gameSetting()
	if self.Button_menu:getTag() == 0 then
		luaPrint("gameSetting",self.Button_menu:getTag());
		self.Button_menu:setTag(1)
		self.Image_setting:setVisible(true);
		self.Button_menu:loadTextures("BJL_xialaanniu1.png","BJL_xialaanniu1.png","BJL_xialaanniu1.png",UI_TEX_TYPE_PLIST);
	else
		luaPrint("gameSetting",self.Button_menu:getTag());
		self.Button_menu:setTag(0)
		self.Image_setting:setVisible(false);
		self.Button_menu:loadTextures("BJL_xialaanniu.png","BJL_xialaanniu.png","BJL_xialaanniu.png",UI_TEX_TYPE_PLIST);
	end
end

--筹码飞上桌面 
function TableLayer:showAddMoneyAni(lAddScoreCount,wAddScoreUser)
	luaPrint("showAddMoneyAni",lAddScoreCount,wAddScoreUser);
	self:createBet(lAddScoreCount,wAddScoreUser,true)
	local userInfo = self.tableLogic:getUserBySeatNo(wAddScoreUser);
	if userInfo then
		local viewSeat = self.tableLogic:logicToViewSeatNo(wAddScoreUser);
		local money = userInfo.i64Money;
		self.playerNodeInfo[viewSeat+1]:setUserMoney(money-lAddScoreCount);
		self.m_selfMoney = money-lAddScoreCount
	end
end

--下拉菜单
function TableLayer:ClickOtherButtonBack(sender)
	local tag = sender:getTag();
	if tag == 0 then
		sender:setTag(1);
		sender:loadTextures("shouna-on.png","shouna-on.png","shouna-on.png",UI_TEX_TYPE_PLIST);
		self.Image_setting:setVisible(true);
	elseif tag == 1 then
		sender:setTag(0);
		sender:loadTextures("shouna.png","shouna.png","shouna.png",UI_TEX_TYPE_PLIST);
		self.Image_setting:setVisible(false);
	end
end

--保险箱
function TableLayer:ClickInsuranceBack(sender)
	
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

-- --加载玩家信息
-- function TableLayer:showPlayerInfo()
-- 	local realSeat = self.tableLogic:getMySeatNo();
-- 	luaPrint("showPlayerInfo",realSeat);
-- 	local userInfo = self.tableLogic:getUserBySeatNo(realSeat);
-- 	luaDump(userInfo,"自己的信息");
-- 	if userInfo then
-- 		-- self.Text_selfName:setText(userInfo.nickName);
-- 		-- luaPrint("userInfo.i64Money",userInfo.i64Money);
-- 		-- self.AtlasLabel_selfMoney:setString(numberToString2(userInfo.i64Money));--userInfo.i64Money
-- 		-- self.selfMoney = userInfo.i64Money
-- 	end

-- end

--添加用户
 function TableLayer:addUser(deskStation, bMe)
	 if not self:isValidSeat(deskStation) then 
        return;
    end

    local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
    local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
    --luaDump(userInfo,"userInfo");
    if userInfo then
    	deskStation = deskStation + 1;
        self.playerNodeInfo[deskStation]:setUserId(userInfo.dwUserID);
        self.playerNodeInfo[deskStation]:setHead(userInfo.bLogoID, userInfo.dwUserID,userInfo.bBoy);
        self.playerNodeInfo[deskStation]:setDestion(bSeatNo);
        self.playerNodeInfo[deskStation]:setMan(userInfo.bBoy);
        self.playerNodeInfo[deskStation]:setIP(userInfo.dwUserIP);
    end

    self.Node_card0:setVisible(false);
    self.Node_card1:setVisible(false);
    self.m_RealSeat = self.tableLogic:getMySeatNo();
    if self.m_RealSeat == bSeatNo and userInfo then
    	self.m_selfMoney = userInfo.i64Money;
    end
end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
	if not TableLayer:getInstance() then
		return;
	end
    if not self:isValidSeat(seatNo) then 
        return;
    end
    luaPrint("removeUser ==================",self.m_selfMoney,nMinRoomKey,bLock,bIsMe)
    if bIsMe then
    	self.m_bGameStart = false;
    	local str = "";
    	local func;
    	if bLock == 1 then 
    		str = "金币不足，请退出游戏!"
    		playEffect("sound/noMoney.mp3");
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
    else
    	--第二局如果自己准备后，其他人离开就重新匹配
    	if self.selfReady then
    		addScrollMessage("有玩家离开房间");
    		self:matchGame();
    	end
	end
	if not bLock then
		self:checkJueSha();
	end
    --luaPrint("removeUser-----------ppp",seatNo);
    --local userCount = self.tableLogic:getOnlineUserCount();
    if globalUnit.nowTingId > 0 then
	    self.playerNodeInfo[seatNo+1]:setUserMoney(0);
	    self.playerNodeInfo[seatNo+1]:setUserName("");
	    self.playerNodeInfo[seatNo+1]:setEmptyHead();
	    self.playerNodeInfo[seatNo+1]:removeTime();
	    local realSeat = self.tableLogic:viewToLogicSeatNo(seatNo);
	    if realSeat == self.tableLogic:getMySeatNo() then
	    	self.Node_card0:setVisible(false);
	    	self.Image_clock0:setVisible(false);
	    	self.Image_ready0:setVisible(false);
	    else
	    	--self.Node_card1:setVisible(false);
	    	self.Image_clock1:setVisible(false);
	    	self.Image_ready1:setVisible(false);
	    end

	    for k,v in pairs(self.playerNodeInfo) do
			v:setBank(false);
		end
	end

end

--添加玩家
function TableLayer:addPlayer(userInfo,realSeatNo)
	luaPrint("addPlayer(userInfo) -------------------",realSeatNo)
	
end

function TableLayer:isValidSeat(seatNo)
	return seatNo < PLAY_COUNT and seatNo >= 0;
end

-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	--self:clearDesk();

	-- FishModule:clearData();
end

function TableLayer:hideClock()
	self.AtlasLabel_time0:getParent():setVisible(false);
	self.AtlasLabel_time1:getParent():setVisible(false);

end

--设置倒计时
function TableLayer:setClockTime(dt,realSeat,alltrue)
	if dt == nil or dt == 0 then
		return;
	end

	if realSeat == self.tableLogic:getMySeatNo() or alltrue then
		self:playSoundAni(dt);
	end

	function fun(node)
		if node then
			luaPrint("setClockTime0000000");
			node:getParent():setVisible(true);
			node:stopAllActions();
			node:setTag(dt);
			node:setString(dt);
			node:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.DelayTime:create(1),
				cc.CallFunc:create(function()
					--self:upateTime(node);
					local tag = node:getTag();
					if tag <=1 then
						node:stopAllActions();
						local parent = node:getParent();
						if parent then
							parent:setVisible(false);
						end
					end
					luaPrint("upateTime",node:getTag());
					node:setTag(node:getTag()-1);
					node:setString(node:getTag());
				 end)
				)));
		end
	end

	-- body
	luaPrint("setClockTime",dt,realSeat);
	if alltrue then
		self.Image_clock0:setVisible(true);
		self.Image_clock1:setVisible(true);
		fun(self.AtlasLabel_time0);
		fun(self.AtlasLabel_time1);
		for k=1,PLAY_COUNT  do
			local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
			self.playerNodeInfo[viewSeat+1]:removeTime();
			self.playerNodeInfo[viewSeat+1]:setTime(dt);
		end
		self.Image_clock0:setVisible(true);
		self.Image_clock1:setVisible(true);
	else
		local node;
		if realSeat == self.tableLogic:getMySeatNo() then
			self.Image_clock0:setVisible(true);
			self.Image_clock1:setVisible(false);
			node = self.AtlasLabel_time0
		else
			self.Image_clock1:setVisible(true);
			self.Image_clock0:setVisible(false);
			node = self.AtlasLabel_time1
		end
		
		fun(node);

		for k=1,PLAY_COUNT  do
			local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
			self.playerNodeInfo[viewSeat+1]:removeTime();
			if realSeat == k-1 then
				self.playerNodeInfo[viewSeat+1]:setTime(dt);
			end
		end
	end

end

function TableLayer:upateTime(node)
	if node then
		local tag = node:getTag();
		if tag <=1 then
			node:stopAllActions();
			local parent = node:getParent();
			if parent then
				parent:setVisible(false);
			end
		end
		luaPrint("upateTime",node:getTag());
		node:setTag(node:getTag()-1);
		node:setString(node:getTag());
		--playEffect("sound/audio_reminded.wav");
	end
end

--退出
function TableLayer:onClickExitGameCallBack(isRemove)
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出",self.m_bGameStart)
	local func = function()	
		self.tableLogic:sendUserUp();	
	    self:leaveDesk()
	end

	if isRemove ~= nil then
		Hall:exitGame(isRemove,func);
	else
		Hall:exitGame(self.m_bGameStart,func);
	end
end

function TableLayer:leaveDesk(source)
	-- self.tableLogic:sendUserUp();
	-- self.tableLogic:sendForceQuit();

	self:stopAllActions();
    _instance = nil;

    if source == nil then
        globalUnit.isEnterGame = false;
        if globalUnit.nowTingId == 0 then
	        RoomLogic:close();
	    end
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

--显示历史战绩
function TableLayer:showHistory(score1,score2)
	--self.m_lastScore = score1
	local str1 = "";
	local str2 = "";

	self.m_lastAllScore = score1
	self.m_lastScore = score2

	if score1>0 then
		str1 = "+"..numberToString2(score1)
	else
		str1 = numberToString2(score1)
	end
	if score2 >0 then
		str2 = "+"..numberToString2(score2)
	else
		str2 = numberToString2(score2)
	end

	self.Text_history:setString(str1);
	self.Text_upju:setString(str2);

end

--场景消息 空闲状态
function TableLayer:dealGameStationFree(msg)
	if globalUnit.nowTingId == 0 and self.mBackGame then
		addScrollMessage("游戏已结束，自动退出房间");
		self:onClickExitGameCallBack()
	end
	self:clearDesk();
	self.b_isBackGround = true;
	self.m_bGameStart = false;
	self.isReply = false;
	
	self:hideAllButton();
	self:clearDeskMoney();
	self.m_lastAllScore = msg.lUserTotalWin
	self:showHistory(msg.lUserTotalWin,msg.lUserLastWin);
	--if msg.bFirst == self.tableLogic:getMySeatNo() then
		--self.Button_start:setVisible(true);
		--self:setClockTime(15,self.tableLogic:getMySeatNo());
	--end
	--luaPrint("ReadyRealSeat",self.ReadyRealSeat,self.tableLogic:getMySeatNo());
	-- if self.ReadyRealSeat == self.tableLogic:getMySeatNo() then
	-- 	self.Button_start:setVisible(true);
	-- end
	self:updateTuoGuan(msg.lUserTrust);

	for i=1,PLAY_COUNT do
		local viewSeat = self.tableLogic:viewToLogicSeatNo(i-1);
		self.readyImage[viewSeat+1]:setVisible(false);--msg.bAgree[i]
		if i-1 == self.tableLogic:getMySeatNo() then
			self.Button_start:setVisible(false);
			if globalUnit.nowTingId>0 then
				-- self.Button_start:setVisible(not msg.bAgree[i]);
			end
		end
	end
	self.AtlasLabel_allmoney:setString(numberToString2(0));
	for k,v in pairs(self.playerNodeInfo) do
		v:setBank(false);
	end

	self:updateUserInfo();
	--self:setClockTime(15,self.tableLogic:getMySeatNo());
end
--叫庄状态
function TableLayer:dealGameStationCall(msg)
	self:removeButton_new();
	self:clearDesk();
	self.b_isBackGround = true;
	self.m_bGameStart = true;
	self.isReply = false;
	self.Image_ready0:setVisible(false);
	self.Image_ready1:setVisible(false);
	self:hideAllButton();
	self:clearDeskMoney();
	self.m_lastAllScore = msg.lUserTotalWin
	if msg.wCallBanker == self.tableLogic:getMySeatNo() then
		self.Button_bank:setVisible(true);
		self.Button_nobank:setVisible(true);
		self:setClockTime(5,self.tableLogic:getMySeatNo());
	else
		local realSeat = self.tableLogic:viewToLogicSeatNo(1);
		self:setClockTime(5,realSeat);
		self.Image_dengdaibank:setVisible(true);
	end
	self:showHistory(msg.lUserTotalWin,msg.lUserLastWin);
	self:updateTuoGuan(msg.lUserTrust);

	self.AtlasLabel_allmoney:setString(numberToString2(0));
	for k,v in pairs(self.playerNodeInfo) do
		v:setBank(false);
	end
	self:updateUserInfo();
end
--下注状态
function TableLayer:dealGameStationScore(msg)
	self:removeButton_new();
	self:clearDesk();
	self.b_isBackGround = true;
	self.m_bGameStart = true;
	self.isReply = false;
	self.Image_ready0:setVisible(false);
	self.Image_ready1:setVisible(false);
	self:hideAllButton();
	self:clearDeskMoney();
	self.m_lastAllScore = msg.lUserTotalWin
	self:setBetMoney(msg.lTurnMaxScore) 
	self:updateUserInfo();
	luaPrint("dealGameStationScore",msg.wBankerUser,self.tableLogic:getMySeatNo());
	if msg.wBankerUser ~= self.tableLogic:getMySeatNo() then--我不是庄家
		self.Node_bet:setVisible(true);
		luaPrint("轮到我下注");
		self:setClockTime(5,self.tableLogic:getMySeatNo());
	else
		self.b_isBank = true;
		local realSeat = self.tableLogic:viewToLogicSeatNo(1);
		self:setClockTime(5,realSeat);
	end
	self:showHistory(msg.lUserTotalWin,msg.lUserLastWin);
	self:setBankSign(msg.wBankerUser);
	--如果已经下注过则显示筹码
	if msg.lTableScore[self.tableLogic:getMySeatNo()+1]>0 then
		self.Node_bet:setVisible(false);
		self:createBet(msg.lTableScore[self.tableLogic:getMySeatNo()+1],self.tableLogic:getMySeatNo(),false)

		local userInfo = self.tableLogic:getUserBySeatNo(wAddScoreUser);
		if userInfo then
			local viewSeat = self.tableLogic:logicToViewSeatNo(wAddScoreUser);
			local money = userInfo.i64Money;
			self.playerNodeInfo[viewSeat+1]:setUserMoney(money-msg.lTableScore[self.tableLogic:getMySeatNo()+1]);
		end
	end
	self:updateTuoGuan(msg.lUserTrust);

	--记录下注金额
	for k,v in pairs(msg.lTableScore) do
		local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
		self.addMoneyScore[viewSeat+1] = v;
	end
	
end

--场景消息 游戏状态
function TableLayer:dealGameStationPlaying(msg)
	self:removeButton_new();
	self:clearDesk();
	self.b_isBackGround = true;
	self.m_bGameStart = true;
	self.isReply = false;
	self.m_lastAllScore = msg.lUserTotalWin
	self.Image_ready0:setVisible(false);
	self.Image_ready1:setVisible(false);
	self:hideAllButton();
	self:clearDeskMoney();
	self.Node_card0:setVisible(true);
	self.Node_card1:setVisible(true);
	self:clearPokerTable();
	self.Button_lookcard:setVisible(true);
	self.Button_cuopai:setVisible(true);
	self.Button_mipai:setVisible(true);
	self:setBankSign(msg.wBankerUser);
	self:showHistory(msg.lUserTotalWin,msg.lUserLastWin);
	self:updateUserInfo();
	self.sendCard = msg.cbHandCardData[self.tableLogic:getMySeatNo()+1];
	for k,v in pairs(msg.cbHandCardData[self.tableLogic:getMySeatNo()+1]) do
		if v > 0 then
			--local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
    		--local pFrame = sharedSpriteFrameCache:getSpriteFrame(self:getCardTextureFileName(v));
    		local card = self.Node_card0:getChildByName("Image_card"..k);
    		card:loadTexture(self:getCardTextureFileName(0),UI_TEX_TYPE_PLIST);
		end
	end

	for k=1,5 do
		--local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
		--local pFrame = sharedSpriteFrameCache:getSpriteFrame(self:getCardTextureFileName(0));
		local card = self.Node_card1:getChildByName("Image_card"..k);
		card:loadTexture(self:getCardTextureFileName(0),UI_TEX_TYPE_PLIST);
	end

	if msg.wBankerUser == self.tableLogic:getMySeatNo() then
		self.b_isBank = true;
	else
		self.b_isBank = false;
	end
	local viewSeat = 0
	if self.b_isBank then
		viewSeat = 1;
	else
		viewSeat = 0;
	end
	local realSeat = self.tableLogic:viewToLogicSeatNo(viewSeat);

	self:createBet(msg.lTableScore[realSeat+1],realSeat+1,false)
	local userInfo = self.tableLogic:getUserBySeatNo(realSeat);
	if userInfo then
		local viewSeat = self.tableLogic:logicToViewSeatNo(realSeat);
		local money = userInfo.i64Money;
		--luaPrint("9999",viewSeat);
		self.playerNodeInfo[viewSeat+1]:setUserMoney(money-msg.lTableScore[realSeat+1]);
	end
	self.AtlasLabel_allmoney:setString(numberToString2(msg.lTableScore[realSeat+1]));
	self:updateTuoGuan(msg.lUserTrust);
	
	self:setClockTime(10,0,true);
end

function TableLayer:showMsgString(text, fontSize)
	addScrollMessage(text);
end

--创建筹码直接在桌子上，不带动作(筹码值，位置)
function TableLayer:createBet(value,realSeat,isFly)
	if value<=0 then
		--luaPrint("创建筹码有误",value);
		return ;
	end
	local betTable = self:getCastByNum(value);
	local pos1 = cc.p(636,150);
	if realSeat == self.tableLogic:getMySeatNo() then
		pos1 = cc.p(636,150);
	else
		pos1 = cc.p(636,522);
	end
	luaDump(betTable,"分割出来的筹码个数");
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
				self.Node_chouma:addChild(bet,100);
				table.insert(self.deskMoneyTable,bet);

				-------------------
				local dis = 100; --随机距离
				local size = cc.Director:getInstance():getWinSize();
				local X = size.width/2;
				local Y = size.height/2;
				
				local randomX = math.random(-dis,dis)
			 	local randomY = math.random(-dis,dis)
				local posx = X +randomX;--self.Image_area[cast_pos]:getPositionX()+randomX;
				local posy = Y +randomY;
				------------------------
				local pos = cc.p(posx,posy)
				if isFly == true then
					bet:setPosition(pos1);
					local moveTo = cc.MoveTo:create(0.3,pos);
					bet:runAction(moveTo);
				else
					bet:setPosition(pos);
				end
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
		if value == 0 then
			break;
		end
		if value>=betTable[i] then
			local num = math.floor(value/betTable[i]);
			temp[i] = num;--筹码个数
			value = value - num*betTable[i];
		end
	end
	return temp;
end

--特效
function TableLayer:addAnimation(node,_type)
	if _type == 1 then
		luaPrint("胜利动画");
		self:clearAni();
		local skeleton_animation = sp.SkeletonAnimation:create("game/winner.json", "game/winner.atlas");
	    skeleton_animation:setPosition(20,0)
	    skeleton_animation:setAnimation(0,"winner", false);
	    node:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("addAnimation");
	    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ( ... )
	    	--skeleton_animation:removeFromParent();
	    	self:clearAni();
	    end)));
	elseif _type == 2 then
		luaPrint("秒杀");
		local skeleton_animation = sp.SkeletonAnimation:create("animate/miaosha/miaosha.json", "animate/miaosha/miaosha.atlas");
	    skeleton_animation:setPosition(640,360)
	    skeleton_animation:setAnimation(0,"miaosha", false);
	    local layer = cc.Director:getInstance():getRunningScene();
	    layer:addChild(skeleton_animation,2000000);
	    skeleton_animation:setName("addAnimation");
	    layer:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ( ... )
	    	skeleton_animation:removeFromParent();
	    end)));
	end
end

--去除动画
function TableLayer:clearAni()
	local node;
	node = self.Node_card0:getChildByName("addAnimation");
	while(node) do
		node:removeFromParent();
		node = self.Node_card0:getChildByName("addAnimation");
	end

	local node1;
	node1 = self.Node_card1:getChildByName("addAnimation");
	while(node1) do
		node1:removeFromParent();
		node1 = self.Node_card1:getChildByName("addAnimation");
	end
end

function TableLayer:setUserName(viewseatNo, name)
    if not self:isValidSeat(viewseatNo) then 
        return;
    end

    viewseatNo = viewseatNo + 1;

    self.playerNodeInfo[viewseatNo]:setUserName(name);

    if viewseatNo == 1 then
    	self.playerNodeInfo[viewseatNo]:setUserName(name);
    end
end

--设置玩家分数位置是视图位置
function TableLayer:setUserMoney(viewseatNo, money)
	luaPrint("setUserMoney",money,viewseatNo);
	if not self:isValidSeat(viewseatNo) then
		luaPrint("return111111111");
		return;
	end

	viewseatNo = viewseatNo + 1;--lua索引从1开始

	self.playerNodeInfo[viewseatNo]:setUserMoney(money);
end

function TableLayer:setUserTuoGuan(viewseatNo,istrue)
	luaPrint("setUserTuoGuan",viewseatNo,istrue);
	if not self:isValidSeat(viewseatNo) then
		return;
	end

	viewseatNo = viewseatNo + 1;--lua索引从1开始

	self.playerNodeInfo[viewseatNo]:hideTuoguan(istrue);
end

-- //服务器收到玩家已经准备好了
function TableLayer:playerGetReady(viewSeat, bAgree)
    -- //准备好图片
    luaPrint("服务器告诉我别人已经准备-----",viewSeat,bAgree)
    local realSeatNo = self.tableLogic:viewToLogicSeatNo(viewSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(realSeatNo);
	if userInfo then
		luaPrint("------------playerGetReady--------")
		self.readyImage[viewSeat+1]:setVisible(false);--bAgree
		self.playerNodeInfo[viewSeat+1]:removeTime();
	end

	if realSeatNo == self.tableLogic:getMySeatNo() and bAgree then
		self.Button_start:setVisible(false)
		--self:removeReadyTime();
		self:hideAllButton();
		self:removeEffect();
		for k,v in pairs(self.playerNodeInfo) do
			v:setBank(false);
		end
		--如果是自己准备的话游戏结束动画全部清掉
		self:removeEndAni();
		if self.startBtn then
			self.startBtn:setVisible(false);
			self.huanzhuoBtn:setVisible(false);
			self:addDengDaiTiShi();
			self:removeClock();
		end
	end

	if viewSeat+1 == 1 then
		self.Image_clock0:setVisible(false);
	elseif viewSeat+1 == 2 then
		self.Image_clock1:setVisible(false);
	end
	--playEffect("sound/sound-ready.mp3");
end

--恢复托管状态
function TableLayer:updateTuoGuan(lUserTrust)
	for k,bool in pairs(lUserTrust) do
		local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
		self.playerNodeInfo[viewSeat+1]:hideTuoguan(bool);
		if k-1 == self.tableLogic:getMySeatNo() and bool then
			local layer = TrustLayer:create();
			self:addChild(layer,10000);
		end
	end
end

--刷新玩家分数
function TableLayer:updateUserInfo()

	for i = 1,PLAY_COUNT do
		local k = i-1;
		local viewSeat = self.tableLogic:logicToViewSeatNo(k);
		local userInfo = self.tableLogic:getUserBySeatNo(k);
		--luaPrint("updateUserInfo",i-1);
		luaDump(userInfo,"updateUserInfo");
		if userInfo then
			self.playerNodeInfo[viewSeat+1]:setUserMoney(userInfo.i64Money);
			if viewSeat+1 == 1 then
				self.m_selfMoney = userInfo.i64Money
			elseif viewSeat+1 == PLAY_COUNT then
				luaPrint("updateUserInfo---",self.m_otherMoney);
				self.m_otherMoney = userInfo.i64Money
			end
		end
	end
end

--加载玩家信息
function TableLayer:showPlayerInfo()
	local realSeat = self.tableLogic:getMySeatNo();
	luaPrint("showPlayerInfo",realSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(realSeat);
	luaDump(userInfo,"自己的信息");
	if userInfo then
		-- self.Text_selfName:setText(userInfo.nickName);
		-- luaPrint("userInfo.i64Money",userInfo.i64Money);
		-- self.AtlasLabel_selfMoney:setString(numberToString2(userInfo.i64Money));--userInfo.i64Money
		-- self.selfMoney = userInfo.i64Money
	end

end

-- function TableLayer:gameBuymoney(msg)
-- 	if msg.UserID == PlatformLogic.loginResult.dwUserID then
-- 		self.m_selfMoney = self.m_selfMoney + msg.OperatScore;
-- 		local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
-- 		local viewSeat = self.tableLogic:logicToViewSeatNo(self.tableLogic:getMySeatNo());
-- 		self.playerNodeInfo[viewSeat+1]:setUserMoney(self.m_selfMoney);
-- 	end
-- end

--显示玩家下注之后 再充值 自己的金额 isTrue 全部刷新
function TableLayer:showMoneyAddMoneyAfter(msg,isTrue)
	luaDump(msg,"showMoneyAddMoneyAfter");
	if isTrue == false then
		local userId = msg.UserID 
		local realSeatNo = self.tableLogic:getlSeatNo(userId);
		local viewSeat = self.tableLogic:logicToViewSeatNo(realSeatNo);

		local userInfo = self.tableLogic:getUserBySeatNo(realSeatNo);
		if userInfo then
			luaPrint("self.addMoneyScore[viewSeat+1]",self.addMoneyScore[viewSeat+1]);
			self.playerNodeInfo[viewSeat+1]:setUserMoney(userInfo.i64Money - self.addMoneyScore[viewSeat+1]);
			if viewSeat+1 == 1 then
				self.m_selfMoney = userInfo.i64Money - self.addMoneyScore[viewSeat+1]
			elseif viewSeat+1 == PLAY_COUNT then
				luaPrint("updateUserInfo---",self.m_otherMoney);
				self.m_otherMoney = userInfo.i64Money - self.addMoneyScore[viewSeat+1]
			end 
		end
	else
		for k=1,PLAY_COUNT do
			local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
			local userInfo = self.tableLogic:getUserBySeatNo(k-1);
			if userInfo then
				self.playerNodeInfo[viewSeat+1]:setUserMoney(userInfo.i64Money - self.addMoneyScore[viewSeat+1]);
				if viewSeat+1 == 1 then
					self.m_selfMoney = userInfo.i64Money - self.addMoneyScore[viewSeat+1]
				elseif viewSeat+1 == PLAY_COUNT then
					luaPrint("updateUserInfo---",self.m_otherMoney);
					self.m_otherMoney = userInfo.i64Money - self.addMoneyScore[viewSeat+1]
				end
			end
		end
	end

end

--即将开始 
function TableLayer:playWillStart()
    if self.isPlaying == true then
        return;
    end
    
    local winSize = cc.Director:getInstance():getWinSize()
    local jijiangkaishi = createSkeletonAnimation("jijiangkaishi","game/jijiangkaishi.json","game/jijiangkaishi.atlas");
    if jijiangkaishi then
        jijiangkaishi:setPosition(winSize.width/2,winSize.height/2);
        jijiangkaishi:setAnimation(1,"5s", false);
        self:addChild(jijiangkaishi,999);
        jijiangkaishi:setLocalZOrder(9998);
    end
    self.willStartSpine = jijiangkaishi;
    self:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function() 
        if self.willStartSpine then
            self.willStartSpine:removeFromParent();
        end
        self.willStartSpine = nil;
        
    end)))
end

function TableLayer:removeWillStart()
	if self.willStartSpine then
		self.willStartSpine:removeFromParent();
		self.willStartSpine = nil;
	end
end

--延时声音音效
function TableLayer:playSoundAni(ft)
	if self.soundAni then
		self:stopAction(self.soundAni);
		self.soundAni = nil;
	end
	self.soundAni = cc.Sequence:create(cc.DelayTime:create(ft-3),cc.CallFunc:create(function ()
            audio.playSound("sound/clock.mp3");
        end),cc.DelayTime:create(1),cc.CallFunc:create(function ()
            audio.playSound("sound/clock.mp3");
        end),cc.DelayTime:create(1),cc.CallFunc:create(function ()
            audio.playSound("sound/clock.mp3");
        end));
        self:runAction(self.soundAni);
end

--移除声音音效
function TableLayer:removeSoundAni()
	if self.soundAni then
		self:stopAction(self.soundAni)
		self.soundAni = nil;
	end
end
return TableLayer;
