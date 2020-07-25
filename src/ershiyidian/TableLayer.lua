local TableLayer =  class("TableLayer", BaseWindow)
local TableLogic = require("ershiyidian.TableLogic");
local HelpLayer = require("ershiyidian.HelpLayer");
local GamePlayerNode = require("ershiyidian.GamePlayerNode");
local PokerListBoard = require("ershiyidian.PokerListBoard");
local Poker = require("ershiyidian.Poker")
local ChouMa = require("ershiyidian.ChouMa")
local PokerCommonDefine = require("ershiyidian.PokerCommonDefine");
local The21stLogic = require("ershiyidian.The21stLogic");
local EndLayer = require("ershiyidian.EndLayer")
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

--加注动画
local RaiseAnim = {
		name = "esyd_jiazhu",
		json = "ershiyidian/animate/jiazhu.json",
		atlas = "ershiyidian/animate/jiazhu.atlas",
}

local HEAP_COUNT = 30;	--筹码数量
local CARD_WIDTH = 115;	--扑克宽度
local CARD_HEIGHT = 158;--扑克高度
local CHOUMA_SCALE = 0.4;

function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene("esydScene");

	scene:addChild(layer);

	layer.runScene = scene;
	

	return scene;
end

function TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster)
	globalUnit.nMinRoomKey = RoomInfoModule:getRoomNeedGold(uNameId,globalUnit.selectedRoomID);
	Event:clearEventListener();
	
	local layer = TableLayer.new(uNameId, bDeskIndex, bAutoCreate, bMaster);

	globalUnit.isFirstTimeInGame = false;

	return layer;
end

function TableLayer:getInstance()
	return _instance;
end

function TableLayer:bindEvent()

	self:pushEventInfo(ESYDInfo, "GameStart", handler(self, self.GameStart))        		--游戏开始
	self:pushEventInfo(ESYDInfo, "GameEnd", handler(self, self.GameEnd))          		    --游戏结束
	self:pushEventInfo(ESYDInfo, "GameSendCard", handler(self, self.GameSendCard))  		--发牌消息
	self:pushEventInfo(ESYDInfo, "GameBreakCard", handler(self, self.GameBreakCard))        --分牌
	self:pushEventInfo(ESYDInfo, "GameStopCard", handler(self, self.GameStopCard))          --停牌
	self:pushEventInfo(ESYDInfo, "GameDoubleScore", handler(self, self.GameDoubleScore)) 	--加倍
	self:pushEventInfo(ESYDInfo, "GameInsurance", handler(self, self.GameInsurance)) 		--保险
	self:pushEventInfo(ESYDInfo, "GameAddScore", handler(self, self.GameAddScore)) 			--下注
	self:pushEventInfo(ESYDInfo, "GameGetCard", handler(self, self.GameGetCard))            --要牌
	self:pushEventInfo(ESYDInfo, "GameBankCard", handler(self, self.GameBankCard)) 			--庄家的牌
	self:pushEventInfo(ESYDInfo, "GameNoAction", handler(self, self.GameNoAction)) 			--玩家未操作
	self:pushEventInfo(ESYDInfo, "GameQiang", handler(self, self.GameQiang)) 			    --玩家抢庄
	self:pushEventInfo(ESYDInfo, "GameBegin", handler(self, self.GameBegin)) 			    --开始抢庄
	self:pushEventInfo(ESYDInfo, "GameGiveUp", handler(self, self.GameGiveUp)) 			    --放弃庄
	self:pushEventInfo(ESYDInfo, "GameBankUser", handler(self, self.GameBankUser)) 			--通知庄家
	self:pushEventInfo(ESYDInfo, "GameBeginTX", handler(self, self.GameBeginAni));			--特效

	
	
	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
end

function TableLayer:GameBeginAni()
	luaPrint("收到消息--特效");
	if self.b_isBackGround == false then
		return;
	end
	self:showGameBegin();
	self:addGameStartAni();
end

function TableLayer:ctor(uNameId, bDeskIndex, bAutoCreate, bMaster)
	self.super.ctor(self, 0, true);
	PLAY_COUNT = 5;
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;
	GameMsg.init();
	ESYDInfo:init();
	
	local uiTable = {
		Image_bg = "Image_bg",
		Node_player0 = "Node_player0",
		Node_player1 = "Node_player1",
		Node_player2 = "Node_player2",
		Node_player3 = "Node_player3",
		Node_player4 = "Node_player4",

		Button_menu = {"Button_menu",1},
		Image_setting = {"Image_setting",1},
		Button_back = {"Button_back",0},
		Button_yinxiao = "Button_yinxiao",
		Button_yinyue = "Button_yinyue",
		Button_help = "Button_help",
		Button_baoxian = "Button_baoxian",
		Button_fenpai = "Button_fenpai",
		Button_fanbei = "Button_fanbei",
		Button_jiaopai = "Button_jiaopai",
		Button_tingpai = "Button_tingpai",
		--Panel_score = "Panel_score",
		Image_buttonBG = "Image_buttonBG",
		Button_min = "Button_min",
		Button_max = "Button_max",
		Button_sure = "Button_sure",
		Button_chongfu = "Button_chongfu",
		AtlasLabel_min = "AtlasLabel_min",
		AtlasLabel_max = "AtlasLabel_max",
		Image_area0 = "Image_area0",
		Image_area1 = "Image_area1",
		Image_area2 = "Image_area2",
		Image_area3 = "Image_area3",
		Image_area4 = "Image_area4",
		-- Button_area0 = "Button_area0",
		-- Button_area1 = "Button_area1",
		-- Button_area2 = "Button_area2",
		--Button_cancle = "Button_cancle",
		-- Button_1 = "Button_1",
		-- Button_2 = "Button_2",
		-- Button_3 = "Button_3",
		-- Button_4 = "Button_4",
		-- Button_5 = "Button_5",
		--Button_sure = "Button_sure",
		Image_buttonBG = "Image_buttonBG",--下注按钮背景图
		Image_caozuoBG = "Image_caozuoBG",--操作按钮背景图
		Node_score = "Node_score",
		Image_score1 = "Image_score1",
		Image_score2 = "Image_score2",
		Image_score3 = "Image_score3",
		Image_score4 = "Image_score4",
		Image_score5 = "Image_score5",
		Image_score6 = "Image_score6",
		Image_score7 = "Image_score7",
		Image_score8 = "Image_score8",
		Image_score9 = "Image_score9",
		Image_score10 = "Image_score10",
		Image_tishi = "Image_tishi",
		Node_ani = "Node_ani",
		Node_card = "Node_card",
		AtlasLabel_record = "AtlasLabel_record",
		------------------------------------------------
		Panel_opRaise = "Panel_opRaise",
		Panel_iterrupt = "Panel_iterrupt",
		Image_more = "Image_more",
		Button_add = "Button_add",
		Button_reduce = "Button_reduce",
		Image_bubble = "Image_bubble",
		Text_rasieCoin = "Text_rasieCoin",
		Panel_chipList = "Panel_chipList",
		Image_chip = "Image_chip",
		Node_root = "Node_root",
		Button_qiang = "Button_qiang",
		Button_buqiang = "Button_buqiang",
		Image_sikaozhong0 = "Image_sikaozhong0",
		Image_sikaozhong1 = "Image_sikaozhong1",
		Image_sikaozhong2 = "Image_sikaozhong2",
		Image_sikaozhong3 = "Image_sikaozhong3",
		Image_sikaozhong4 = "Image_sikaozhong4",
		Image_zhuang = "Image_zhuang",
		AtlasLabel_add_score0 = "AtlasLabel_add_score0",
		AtlasLabel_add_score1 = "AtlasLabel_add_score1",
		AtlasLabel_add_score2 = "AtlasLabel_add_score2",
		AtlasLabel_add_score3 = "AtlasLabel_add_score3",
		AtlasLabel_add_score4 = "AtlasLabel_add_score4",
		Panel_end = "Panel_end",
		Button_qizhuang = "Button_qizhuang",
		Node_heguan = "Node_heguan",
		-------------------------------------------------

	}

	self:initData();

	loadNewCsb(self,"tableLayer",uiTable)

	_instance = self;

end


function TableLayer:initData()
	self.The21stLogic = The21stLogic:create();
	--游戏是否开始
	self.b_isBackGround = false;
	self.m_bGameStart = false;	
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;
	--庄家的牌数据
	--self.bankerCards = {};
	--庄家的牌节点
	--self.bankerCardNodes = {};
	--庄家是否停牌
	self.bankerStop = false;
	--当前操作玩家
	self.n_CurrentUser = -1; --记录逻辑位置
	--庄家牌大小
	self.bankScale = 0.7;
	--玩家选择的筹码
	self.selfScorePos = 0;
	--每个玩家下注池 node
	self.addScoreNodeTable = {{},{},{},{},{}};
	--每个玩家下注分数池 score 
	--self.addScoreTable = {{},{},{}};
	self.addScoreTable = {0,0,0,0,0};
	--下注筹码列表
	self.scoreTable = {10,100,300,500,1000};
	--最小下注金额
	self.minScore = minScore;
	--最大下注金额
	self.maxScore = maxScore;
	--标记自己有木有参与本局游戏
	self.isPlay = false;
	--记录上局游戏自己下注金额
	self.recordScore = 0;
	--自己预下注池，分数
	self.jiaScore = 0;
	--自己预下注，节点
	self.jiaScoreNode = {};
	--保险动画
	self.baoxianAni = nil;
	--音效延时时间
	self.delayTime = 0.1;
	--发牌显示框延时动画
	self.FaPaiKuangAni = nil;
	--自己的金钱
	self.m_playerMoney = 0--PlatformLogic.loginResult.i64Money;
	--最小下注
	self.m_addMoney = 0;
	--发牌位置
	self.sendCardPos = cc.p(640,600);
	--记录抢庄玩家的座位号
	self.qiangUserTable = {};
	-- 记录庄家位置
	self.bankSeatNo = -1;
	--记录玩家是否参与游戏
	self.playerStation = {};
	--记录加倍座椅号
	self.doubleSeatNo = -1;
	--记录玩家身上的金钱
	self.playerScore = {0,0,0,0};

end

--记录每个玩家的金币
function TableLayer:initPlayScore()
	for i = 1,PLAY_COUNT do
		local k = i-1;
		local viewSeat = self.tableLogic:logicToViewSeatNo(k);
		local userInfo = self.tableLogic:getUserBySeatNo(k);
		if userInfo then
			self.playerScore[viewSeat+1] = userInfo.i64Money;
		end
	end
	luaDump(self.playerScore,"self.playerScore");
end

function TableLayer:asjustScoreTable()
	luaPrint("asjustScoreTable",globalUnit.iRoomIndex);
	globalUnit.iRoomIndex = 1
	if globalUnit.nMinRoomKey == 10 then
		globalUnit.iRoomIndex = 1
	elseif globalUnit.nMinRoomKey == 25000 then
		globalUnit.iRoomIndex = 2
	elseif globalUnit.nMinRoomKey == 50000 then
		globalUnit.iRoomIndex = 3
	elseif globalUnit.nMinRoomKey == 100000 then
		globalUnit.iRoomIndex = 4
	end

	if globalUnit.iRoomIndex == 1 then
		self.scoreTable = {10,100,300,500,1000};
	elseif globalUnit.iRoomIndex == 2 then
		self.scoreTable = {500,1000,2500,4000,5000};
	elseif globalUnit.iRoomIndex == 3 then
		self.scoreTable = {1000,3000,5000,8000,10000};
	elseif globalUnit.iRoomIndex == 4 then
		self.scoreTable = {2000,5000,10000,15000,20000};
	end

	for k,v in pairs(self.ButtonBet) do
		local AtlasLabel_num = v:getChildByName("AtlasLabel_num");
		AtlasLabel_num:setString(numberToString2(self.scoreTable[k]));
	end
end
 -- //清理桌面
function TableLayer:clearDesk()
	self.m_bGameStart = false;	
	self.n_CurrentUser = -1; --记录逻辑位置

	--self:clearBankerCard();

	for k,v in pairs(self.pokerListBoard) do
		v:clearData();
	end

	if self.Image_buttonBG then
		self.Image_buttonBG:setVisible(false);
	end

	self:light(false);
	--清理全部玩家的下注池
	self:clearAllScoreNode();

	--self.Node_score:setVisible(false);
	--影藏所有显示牌值图片
	self:hideAllImage_score();

	self:showTiShi(false);

	--self:showBankEndScore(false);
	--去除所有特效
	self:clearAllTeXiao();
	--去除等待下一局动画
	self:removeDengDaiAni();

	self:clearAddScoreNode_jia();

	self.jiaScore = 0;
	--self.Panel_opRaise:setVisible(false);
	self.Button_qiang:setVisible(false);

	self.Button_buqiang:setVisible(false);
	--隐藏思考中图片
	self:hideImage_sikaozhong();

	self.Image_zhuang:setVisible(false);
	--记录抢庄玩家的座位号
	self.qiangUserTable = {};

	self.Panel_end:setVisible(false);
	--移除游戏即将开始动画
	self:removeGameJiJiangKaiShi();

	self.Button_qizhuang:setVisible(false);
	--去除等待其他用户动画
	self:removeDengQiTaUser();
	--清空玩家下注金额
	self:clearAtlasLabel_add_score();
	--记录加倍座椅号
	self.doubleSeatNo = -1;
	--移除游戏开始动画
	self:removeStartAni();
	--移除开始游戏动画
	self:removeGameStartAni();

end

--影藏全部思考中
function TableLayer:hideImage_sikaozhong()
	for k,v in pairs(self.Image_sikaozhong) do
		v:setVisible(false);
	end
end

-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	
	self:clearDesk();

	self:setHideAllButton(true);
	self:setEnabledAllButton(false);

	self:initMusic();

end

--刷新玩家分数
function TableLayer:updateUserInfo()

	for i = 1,PLAY_COUNT do
		local k = i-1;
		local viewSeat = self.tableLogic:logicToViewSeatNo(k);
		local userInfo = self.tableLogic:getUserBySeatNo(k);
		--luaPrint("updateUserInfo",i-1);
		--luaDump(userInfo,"updateUserInfo");
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

--设置时间 ft 时间,allHide全部影藏
function TableLayer:setTime(ft,allDt,lReatNo,allHide)
	luaPrint("TableLayer-setTime",ft,allDt,lReatNo,allHide);
	if lReatNo == nil or ft == nil  or ft <0  then
		luaPrint("设置时间错误",ft,lReatNo);
		return;
	end

	if allHide then
		for k,v in pairs(self.playerNodeInfo) do
			v:moveAllTime();
		end
		return;
	end

	local vSeatNo = self.tableLogic:logicToViewSeatNo(lReatNo);
	
	for k,v in pairs(self.playerNodeInfo) do
		if k == vSeatNo+1 then
			if ft == 0 then
				v:moveAllTime();
			else
				v:setAllTime(ft,allDt);
			end
		else
			v:moveAllTime();
		end
	end
end

--设置时间(全部玩家都设置时间)
function TableLayer:setTimeToEveryone(ft,allDt)
	if ft <= 0 then
		luaPrint("setTimeToEveryone ERROR!",ft);
		return;
	end
	for k,v in pairs(self.playerNodeInfo) do
		--庄家不需要显示时间
		local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
		if vSeatNo+1 ~= k then
			local realSeatNo = self.tableLogic:viewToLogicSeatNo(k-1); 
			local userInfo = self.tableLogic:getUserBySeatNo(realSeatNo);
			luaDump(self.playerStation);
			luaPrint("setTimeToEveryone",self.playerStation[realSeatNo],realSeatNo,k-1,self.bankSeatNo);
			if userInfo and self.playerStation[realSeatNo+1] then
				v:setAllTime(ft,allDt);
			end
		end
	end
end

--去除某一个玩家头上的时间
function TableLayer:removeTimeToWhichOne(realSeatNo)
	if realSeatNo < 0 or realSeatNo > PLAY_COUNT then
		luaPrint("removeTime REEOR",realSeatNo);
		return;
	end
	local vSeatNo = self.tableLogic:logicToViewSeatNo(realSeatNo);
	for k,v in pairs(self.playerNodeInfo) do
		if k == vSeatNo+1 then
			v:moveAllTime();
			break;
		end
	end
end

--创建扑克牌
function TableLayer:createPokers()
	self.pokerListBoard = {};

	self.Image_buttonBG:setLocalZOrder(9998)
	self.Image_caozuoBG:setLocalZOrder(9998)

	for i=1,PLAY_COUNT do
		local k = i -1;
		-- luaPrint("tempPokerList---- k = "..k)
		local tempPokerList = PokerListBoard.new(k,self);
		tempPokerList:setVisible(true);
		tempPokerList:setLocalZOrder(1000)
		self.Node_card:addChild(tempPokerList,5);
		
		table.insert(self.pokerListBoard, tempPokerList);
	end

	--self:createBankerPokers({1,2});

end

-- --创建庄家的牌
-- function TableLayer:createBankerPokers(cards)
-- 	--庄家的牌数据
-- 	self.bankerCards = {};
-- 	for k,v in pairs(cards) do
-- 		table.insert(self.bankerCards,v);
-- 	end
-- 	--luaDump(self.bankerCards,"self.bankerCards");
-- 	--庄家的牌节点
-- 	for k,v in pairs(self.bankerCards) do
-- 		local poker = Poker.new(self:getCardTextureFileName(v), v);
-- 		poker:setScale(self.bankScale);
-- 		self.Node_card:addChild(poker);
-- 		table.insert(self.bankerCardNodes,poker);
-- 	end
	
-- 	--调整位置
-- 	self:adjustBankerCardPos();
-- 	--先影藏庄家的牌展示动画
-- 	self:hideAllBankerCard(false);
-- 	--庄家发牌动画
-- 	self:sendBankerCardAni(cards);
	
-- end

-- --庄家发牌动画 istrue 是否显示点数
-- function TableLayer:sendBankerCardAni(cards)
-- 	for k,v in pairs(cards) do
-- 		local poker = Poker.new(self:getCardTextureFileName(v), v);
-- 		poker:setScale(0.2);
-- 		poker:setPosition(self.sendCardPos);
-- 		self.Node_root:addChild(poker);
-- 		poker:setVisible(true);
-- 		poker:setLocalZOrder(k);

-- 		local pos = cc.p(0,0);
-- 		pos = self:getBankerMovePos(k);
-- 		local n_time = 0.2;
-- 		local scale = self.bankScale;
-- 		--动作
-- 		local move = cc.MoveTo:create(n_time,pos);
-- 		local scaleTo = cc.ScaleTo:create(n_time,scale,scale);
-- 		local spawn = cc.Spawn:create(move, scaleTo);  
-- 		poker:runAction(cc.Sequence:create(cc.DelayTime:create(n_time*k),spawn,cc.DelayTime:create(n_time),cc.CallFunc:create(function ( ... )
-- 			poker:setVisible(false);
-- 			audio.playSound("ershiyidian/sound/send_card.wav",false);
-- 			poker:removeFromParent();
-- 			self:showBankerIndexCard(k);
-- 			--显示得分
-- 			--self:showGameScore(4);
-- 		end)));
-- 	end
	
	
-- end

--获取牌位置
function TableLayer:getBankerMovePos(index)
	if index<=0 then
		return;
	end
	luaPrint("getBankerMovePos",self.bankSeatNo);
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
	local pos = cc.p(0,0)
	pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode[index]:getPositionX(),self.pokerListBoard[vSeatNo+1].handCardNode[index]:getPositionY());
	luaPrint("getBankerMovePos",pos.x,pos.y);
	return pos;
end

-- --影藏庄家所有的牌
-- function TableLayer:hideAllBankerCard(isTrue)
-- 	for k,v in pairs(self.bankerCardNodes) do
-- 		v:setVisible(isTrue);
-- 	end
-- end

-- --显示庄家第几张牌
-- function TableLayer:showBankerIndexCard(index)
-- 	if index <= 0 or self.bankerCardNodes[index] == nil then
-- 		return;
-- 	end
-- 	self.bankerCardNodes[index]:setVisible(true);
-- end

-- --清理庄家的牌
-- function TableLayer:clearBankerCard()
-- 	for k ,v in pairs(self.bankerCardNodes) do
-- 		v:removeFromParent();
-- 	end
-- 	self.bankerCardNodes = {};
-- 	self.bankerCards = {};
-- end

-- --恢复庄家的牌 (cards传进来之间筛除没用的值)
-- function  TableLayer:updateBankerPokers(cards)
-- 	self:clearBankerCard();
-- 	--庄家的牌数据
-- 	self.bankerCards = cards;
-- 	-- for k,v in pairs(cards) do
-- 	-- 	if v > 0 then
-- 	-- 		table.insert(self.bankerCards,v);
-- 	-- 	end
-- 	-- end
-- 	--luaDump(self.bankerCards,"self.bankerCards");
-- 	--庄家的牌节点
-- 	for k,v in pairs(self.bankerCards) do
-- 		local poker = Poker.new(self:getCardTextureFileName(v), v);
-- 		poker:setScale(self.bankScale);
-- 		self.Node_card:addChild(poker);
-- 		table.insert(self.bankerCardNodes,poker);
-- 	end
	
-- 	--调整位置
-- 	self:adjustBankerCardPos();
-- end

-- --庄家要牌操作
-- function TableLayer:addBankerNode(card)
-- 	if card == 0 then
-- 		luaPrint("加的牌有问题",card);
-- 	end
-- 	local poker = Poker.new(self:getCardTextureFileName(card), card);
-- 	poker:setScale(self.bankScale);
-- 	self.Node_card:addChild(poker);
-- 	table.insert(self.bankerCardNodes,poker);
-- 	table.insert(self.bankerCards,card);
-- 	--调整位置
-- 	self:adjustBankerCardPos();

-- 	--影藏最后一张牌
-- 	self:hideBankerEndCard(false);
-- 	--要牌动画
-- 	self:bankGetcardAni(card);
-- end

-- --要牌动画
-- function TableLayer:bankGetcardAni(card)
-- 	luaPrint("bankGetcardAni",card);
-- 	local poker = Poker.new(self:getCardTextureFileName(card), card);
-- 	poker:setScale(0.2);
-- 	poker:setPosition(self.sendCardPos);
-- 	self:addChild(poker);
-- 	poker:setVisible(true);

-- 	local pos = cc.p(0,0);
-- 	pos = self:getBankerMovePos(#self.bankerCardNodes);
-- 	local n_time = 0.2;
-- 	local scale = self.bankScale;
-- 	--动作
-- 	local move = cc.MoveTo:create(n_time,pos);
-- 	local scaleTo = cc.ScaleTo:create(n_time,scale,scale);
-- 	local spawn = cc.Spawn:create(move, scaleTo);  
-- 	poker:runAction(cc.Sequence:create(spawn,cc.DelayTime:create(n_time),cc.CallFunc:create(function ( ... )
-- 		poker:setVisible(false);
-- 		audio.playSound("ershiyidian/sound/send_card.wav",false);
-- 		poker:removeFromParent();
-- 		--self:hideBankerEndCard(true);
-- 		self:hideBankAllCard(true);
-- 		self:showGameScore(self.bankSeatNo,true);
-- 	end)));
-- end

-- --影藏最后一张牌
-- function TableLayer:hideBankerEndCard(isTrue)
-- 	if self.bankerCardNodes[#self.bankerCardNodes] then
-- 		self.bankerCardNodes[#self.bankerCardNodes]:setVisible(isTrue);
-- 	end
-- end

-- --显示庄家所有的牌
-- function TableLayer:hideBankAllCard( isTrue )
-- 	for k,v in pairs(self.bankerCardNodes) do
-- 		v:setVisible(isTrue);
-- 	end
-- end

-- --调整庄家扑克牌的位置
-- function TableLayer:adjustBankerCardPos()
-- 	local dis = 30;
-- 	local startPosX = 640;
-- 	local startPosY = 550;
-- 	for k,v in pairs(self.bankerCardNodes) do
-- 		dis = v:getContentSize().width*self.bankScale+10;
-- 		startPosX = 640-dis*(#self.bankerCardNodes/2)
-- 		v:setPosition(cc.p(startPosX + (k-1)*dis,startPosY));
-- 	end
-- end

function TableLayer:getCardTextureFileName(pokerValue)
	local value = string.format("sdb_0x%02X", pokerValue);

	return value..".png";
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

function TableLayer:onExit()
	self.super.onExit(self);
	display.removeSpriteFrames("ershiyidian/ershiyidian.plist","ershiyidian/ershiyidian.png")
end




function TableLayer:initUI()

	--适配游戏
    self:adjustmentGame();

	self:createPokers();

	-- 初始化玩家信息
    self:initPlayerInfo();
	
	--基本按钮
	self:initGameNormalBtn();

	--下注按钮，下注区域 
	self:initScoreButton();

	--最后各玩家牌点显示
	self:initScoreBg();

	self:initMusic();

	self:showTiShi(false);

	self:clearDesk();

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	self:setHideAllButton(true);
	self:setEnabledAllButton(false);
	--luaPrint("时间",os.date("%Y-%m-%d %H:%M:%S",os.time()))
	--增加荷官动画
	self:addHeGuan();

end

--增加荷官
function TableLayer:addHeGuan()
	local skeleton_animation = createSkeletonAnimation("nvheguan","animate/nvheguan/nvheguan.json", "animate/nvheguan/nvheguan.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(0,-20)
	    skeleton_animation:setAnimation(0,"nvheguan", false);
	    self.Node_heguan:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("nvheguan");
	end

end



--显示提示
function TableLayer:showTiShi(isTrue)
	self.Image_tishi:setVisible(isTrue);
	if isTrue then
		self.Image_tishi:stopAllActions();
		local pos = cc.p(0,0);
		local n_time = 0.15
		pos = cc.p(self.Image_tishi:getPositionX(),self.Image_tishi:getPositionY());
		local move1 = cc.MoveTo:create(n_time,cc.p(pos.x,pos.y+10));
		local move2 = cc.MoveTo:create(n_time,cc.p(pos.x,pos.y));
		self.Image_tishi:runAction(cc.RepeatForever:create(cc.Sequence:create(move1,cc.DelayTime:create(n_time),move2,cc.DelayTime:create(n_time))));
	else
		self.Image_tishi:stopAllActions();
	end
end

function TableLayer:initScoreBg()
	self.Image_score = {}; --最后一个表示的是庄家的
	for i=1,PLAY_COUNT*2 do
		local node = self["Image_score"..i];
		table.insert(self.Image_score,node);
	end

	self.AtlasLabel_add_score = {};--下注分数
	for i=1,PLAY_COUNT do
		local node = self["AtlasLabel_add_score"..i-1];
		table.insert(self.AtlasLabel_add_score,node);
	end

end

--适配游戏
function TableLayer:adjustmentGame()

	PokerCommonDefine.adjustmentGame();
end

--下注提示
function TableLayer:showAddScoreAni()
	self:Button_area_Enable(true);
	
end

--下注区域闪亮
function TableLayer:light(isTrue)
	
	--for k,v in pairs(self.Image_area) do
		--v:setVisible(true);
	--end
	
	if isTrue then
		
		-- for k,v in pairs(self.Button_area) do
		-- 	v:setEnabled(true);
		-- end
		
		self.Image_buttonBG:setVisible(true);
		self.Image_caozuoBG:setVisible(false);

		self.Panel_opRaise:setVisible(true);
		self.Panel_chipList:setVisible(true);
		self:initAddList();
		
		self.Button_sure:setEnabled(true);
	else
		
		-- for k,v in pairs(self.Button_area) do
		-- 	v:setEnabled(false);
		-- end

		self.Image_buttonBG:setVisible(false);
		self.Image_caozuoBG:setVisible(true);
		self.Panel_opRaise:setVisible(false);
	end
end

--下注区域按钮是否禁用
function TableLayer:Button_area_Enable(isTrue)
	-- for k,v in pairs(self.Button_area) do
	-- 	v:setEnabled(isTrue);
	-- end
end

--初始化下注区域和按钮
function TableLayer:initScoreButton()
	self.Image_area = {};--下注区域集合
	for i=1,PLAY_COUNT do
		local k = i -1;
		local node = self["Image_area"..k];
		node:setVisible(false);
		table.insert(self.Image_area,node);
	end

	-- --下注区域按钮集合
	-- self.Button_area = {};
	-- for i=1,3 do
	-- 	local k = i -1;
	-- 	local node = self["Button_area"..k];
	-- 	node:setTag(i);
	-- 	node:addClickEventListener(function(sender)
	-- 		self:ClickButton_area(sender);
	-- 	end)
	-- 	table.insert(self.Button_area,node);
	-- end 

	-- --下注按钮集合
	-- self.ButtonBet = {};
	-- for i=1,5 do
	-- 	local node = self["Button_"..i];
	-- 	node:setTag(i);
	-- 	node:addClickEventListener(function(sender)
	-- 		self:ClickButtonBet(sender);
	-- 	end)
	-- 	table.insert(self.ButtonBet,node);
	-- end

	--确定下注
	self.Button_sure:addClickEventListener(function(sender)
			self:ClickButton_sure(sender);
		end)
	-- --取消下注
	-- self.Button_cancle:addClickEventListener(function(sender)
	-- 		self:ClickButton_cancle(sender);
	-- 	end)
	--重复按钮
	self.Button_chongfu:addClickEventListener(function(sender)
			self:ClickButton_chongfu(sender);
		end)
	--刷新按钮下注金额
	--self:asjustScoreTable();

	--增加加注筹码
	self.Button_add:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_add:setName("Button_add");
	--减少加注筹码
	self.Button_reduce:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_reduce:setName("Button_reduce");

	--增加滑动筹码点击事件
	self:addChipListTouchEvent();


end

function TableLayer:initAddList()
	luaPrint("initAddList");
	self:resetChipList();
	for i=1,3 do
		local children = self.Panel_chipList:getChildByTag(i);
		children:setVisible(true)
	end
	self:updateRaiseTxt(3)
end

--按钮响应
function TableLayer:onBtnClickEvent(sender,event)
	--获取按钮名
    local btnName = sender:getName();

    luaPrint("onBtnClickEvent",btnName);

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        
    elseif event == ccui.TouchEventType.ended then
    	if "Button_add" == btnName then	--加注筹码
    		local tag = self.Panel_chipList:getTag();
    		luaPrint("onBtnClickEvent",tag);
    		local gapCount = tag%3;  --取余
    		if tag >= HEAP_COUNT+3 then
    			gapCount = 0;
    		else
    			gapCount = 3 - gapCount;
    		end

    		local tag_n = tag + gapCount;
    		if tag_n > HEAP_COUNT+3 then
    			tag_n = HEAP_COUNT+3;
    		end
    		luaPrint("onBtnClickEvent",tag_n,gapCount);
    		--显示筹码掉落动画
    		local function showCoinAnim(parent,pos)
        		local skeleton_animation = createSkeletonAnimation("jiazhu","ershiyidian/animate/jiazhu/jiazhu.json","ershiyidian/animate/jiazhu/jiazhu.atlas");
				if skeleton_animation then
					skeleton_animation:setAnimation(0,"jiazhu", false);
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
    		self.Button_reduce:setEnabled(tag_n > 3);
	  	 	self.Button_add:setEnabled(tag_n<HEAP_COUNT+3);
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
    		if tag_n < 3 then
    			tag_n = 3;
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
    		
    		self.Button_reduce:setEnabled(tag_n > 3);
	  	 	self.Button_add:setEnabled(tag_n < HEAP_COUNT);
	  	 	self:updateRaiseTxt(tag_n);

	  	 	-- if tag_n == HEAP_COUNT then
	  	 	-- 	self.Button_raise:loadTextures("dzpk_quanxiade.png", "dzpk_quanxiade-on.png","dzpk_gray_quanxiade.png", UI_TEX_TYPE_PLIST);
	  	 	-- else
	  	 	-- 	self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);
	  	 	-- end
    	end
	end
end

-- --加注或者减注的时候按钮的变化
-- function TableLayer:addButtonUpdate()
	
-- end

--下注筹码事件监听
function TableLayer:addChipListTouchEvent()
	--test
	-- self.Panel_opTurn:setVisible(true);
	-- self.Panel_opRaise:setVisible(true);
	-- self.Panel_chipList:setVisible(true);
	-- self.m_playerMoney = 972132;

	self.Panel_chipList:setTouchEnabled(false);
	self.Panel_chipList:setTag(3);
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
		local tag_t = 3;
		if length >= 0 then
				local num = math.floor(length/gap);
				local children = self.Panel_chipList:getChildren();
				tag_t = num+tag;
				if tag_t > HEAP_COUNT+3 then
					tag_t = HEAP_COUNT+3;
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
				if tag_t < 3 then
					tag_t = 3;
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
	for i=1,HEAP_COUNT+3 do
		local img = self.Image_chip:clone();
		self.Panel_chipList:addChild(img);
		img:setTag(i);
		local pos_t = cc.p(pos_s.x,pos_s.y + gap*(i-1));
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
		local tag_t = updateTouchCoinList(touch);
	end, cc.Handler.EVENT_TOUCH_MOVED); 
	 
	listenner:registerScriptHandler(function(touch, event)  
		local tag_t = updateTouchCoinList(touch);
		self.Panel_chipList:setTag(tag_t);
		self.Button_reduce:setEnabled(tag_t > 1);
		self.Button_add:setEnabled(tag_t < HEAP_COUNT);

	end, cc.Handler.EVENT_TOUCH_ENDED)  
	    
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.Panel_chipList);

end

--更新下注筹码数额
function TableLayer:updateRaiseTxt(tag)
	--display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	--self.m_playerMoney = 1000
	--self.m_addMoney = 100
	if tag == nil then
		tag = self.Panel_chipList:getTag();
	end
	--local m_bit = ((self.m_playerMoney)/10)/100;
	
	local per = tag/HEAP_COUNT;
	local addAllMoney = self.m_playerMoney - self.m_addMoney;
	luaPrint("updateRaiseTxt------self.m_playerMoney --------- self.m_addMoney:",self.m_playerMoney,self.m_addMoney);
	if addAllMoney <= 0 then
		luaPrint("self.m_playerMoney is less than self.m_addMoney:",self.m_playerMoney,self.m_addMoney);
		return;
	end
	luaPrint("Tag =====",tag);
	if tag == 0 or tag == 3 then
		local count = self.m_addMoney;
		local amountStr = gameRealMoney(count);
		-- if count%100 ~= 0 then
		-- 	amountStr = math.floor(count/100);
		-- end
		
		local tag_count = count;
		luaPrint("amountStr",amountStr,tag_count);
		self.Text_rasieCoin:setString(amountStr);
		local lastTag = self.Text_rasieCoin:getTag();

		self.Text_rasieCoin:setTag(tag_count);

	elseif tag <= HEAP_COUNT then
		local count = math.floor(self.m_addMoney+(self.m_playerMoney-self.m_addMoney)*(per-3/HEAP_COUNT))--math.floor(self.m_addMoney + addAllMoney*per);
		local amountStr = count--math.floor(count/100);
		local tag_count = amountStr;

		luaPrint("self.m_playerMoney---------,count,per,amountStr,tag_count,self.m_callMoney:",self.m_playerMoney,count,per,amountStr,tag_count,self.m_callMoney);
		self.Text_rasieCoin:setString(gameRealMoney(amountStr));
		local lastTag = self.Text_rasieCoin:getTag();

		self.Text_rasieCoin:setTag(tag_count);
		
	else
		local count = self.m_playerMoney;
		local amount = gameRealMoney(self.m_playerMoney);
		local tag_count = amount*100;

		luaPrint("self.m_playerMoney---------,count,per,amountStr,tag_count,self.m_callMoney:",self.m_playerMoney,count,per,amountStr,tag_count,self.m_callMoney);
		self.Text_rasieCoin:setString(amount);
		--实际下注筹码 记录到tag
		self.Text_rasieCoin:setTag(count);
		--self.Button_raise:loadTextures("dzpk_quanxiade.png", "dzpk_quanxiade-on.png","dzpk_gray_quanxiade.png", UI_TEX_TYPE_PLIST);
		--self.Button_raise:setEnabled(self.m_playerMoney>=self.m_callMoney);
	end

	self.jiaScore = tonumber(self.Text_rasieCoin:getTag());
end

--重置加注信息
function TableLayer:resetChipList()
	--display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	self.Panel_chipList:setTag(3);
	local children = self.Panel_chipList:getChildren();
	for i,v in ipairs(children) do
		v:setVisible(false);
	end

	local tag_count = 0;
	local countStr = "0";
	luaPrint("resetChipList_self.m_addMoney:",self.m_addMoney)
	if self.m_addMoney > 0 then
		tag_count = self.m_addMoney;
		
		if tag_count%100 == 0 then
			countStr = math.floor(tag_count/100);
		else
			countStr = gameRealMoney(tag_count);
		end
		
	end
	luaPrint("countStr------:",countStr);
	self.Text_rasieCoin:setString(countStr);
	self.Text_rasieCoin:setTag(tag_count);
	self.Button_reduce:setEnabled(false);
	self.Button_add:setEnabled(true);
	--self.Button_raise:setEnabled(self.m_playerMoney>=self.m_addMoney);
	--self.Button_raise:loadTextures("dzpk_jiazhud.png", "dzpk_jiazhud-on.png","dzpk_gray_jiazhud.png", UI_TEX_TYPE_PLIST);

end
--确定下注
function TableLayer:ClickButton_sure()
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
	local allScore = 0;
	allScore = self.jiaScore--self:getSelfAddScore(self.tableLogic._mySeatNo);
	
	luaPrint("最后总下注金额是",allScore);
	if allScore<= 0 then
		addScrollMessage("请选择筹码下注！");
	else
		ESYDInfo:sendAddMoney(allScore);
	end
end
--取消下注
function TableLayer:ClickButton_cancle()
	local lSeatNo = self.tableLogic._mySeatNo;
	self:clearAddScoreNode_jia(lSeatNo);
	self.jiaScore = 0;
	self:updateButtonSration();
end

--重复按钮
function TableLayer:ClickButton_chongfu()
	if self.recordScore <= 0 then
		luaPrint("出错");
		return;
	end
	ESYDInfo:sendAddMoney(self.recordScore);
end

--下注区域按钮回调
function TableLayer:ClickButton_area(sender)
	local tag = sender:getTag();
	luaPrint("ClickButton_area",tag);
	--只有玩家点击自己的下注区域才会有用
	if 0 ~= tag-1 then
		luaPrint("点其他人的下注区域干啥，你是不是傻");
		return;
	end
	-- if tag == 1 then

	-- elseif tag ==2 then

	-- elseif tag ==3 then

	-- end
	if self.selfScorePos == 0 then
		addScrollMessage("请选择筹码再下注！");
		return;
	end

	--如果下注的时候超过最大下注，提示玩家
	--if self.scoreTable[self.selfScorePos] + self:getSelfAddScore(self.tableLogic._mySeatNo) >self.maxScore then
	if self.jiaScore + self.scoreTable[self.selfScorePos] >self.maxScore then
		addScrollMessage("超过下注上限！");
		return;
	end

	-- local vSeatNo = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
	-- self.addScoreTable[vSeatNo+1] = self.addScoreTable[vSeatNo+1]+self.scoreTable[self.selfScorePos];
	-- self:createScoreNode(self.tableLogic._mySeatNo,self.scoreTable[self.selfScorePos]);
	self.jiaScore = self.jiaScore+self.scoreTable[self.selfScorePos];
	self:createJiaScoreNode(self.jiaScore);

	--刷新下注几个按钮的状态
	self:updateButtonSration();

end

--刷新下注几个按钮的状态
function TableLayer:updateButtonSration()
	local allScore = self.jiaScore--self:getSelfAddScore(self.tableLogic._mySeatNo);
	luaPrint("updateButtonSration",allScore);
	if allScore ~= 0 then
		self.Button_chongfu:setVisible(false);
		self.Button_sure:setVisible(true);
		--self.Button_cancle:setVisible(true);
	else
		if self.recordScore ~= 0 then
			self.Button_chongfu:setVisible(true);
		else
			self.Button_chongfu:setVisible(false);
		end
		self.Button_sure:setVisible(false);
		--self.Button_cancle:setVisible(false);
	end
end

--创建预下注筹码 只有自己点击筹码下注的时候调用
function TableLayer:createJiaScoreNode()
	local allScore = self.jiaScore
	luaPrint("createJiaScoreNode",allScore); 
	if allScore == 0 then
		return;
	end
	local scoreT = self:getCastByNum(allScore);--数组
	luaPrint("createJiaScoreNode00");
	local lSeatNo = self.tableLogic:getMySeatNo();
	self:clearAddScoreNode_jia(lSeatNo);
	luaDump(scoreT);
	for k,v in pairs(scoreT) do
		for i = 1,v do
			local score = self.scoreTable[k];
			luaPrint("createJiaScoreNodecreateScoreNode",score);
			local num = 10;--控制筹码个数
			local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
			local tag = 0;
			if vSeatNo == 0 then
				tag = 1
			elseif vSeatNo == 1 then
				tag = 2
			else
				tag = 3
			end

			local isHave = false;
			for k,v in pairs(self.scoreTable) do
				if v == score then
					isHave = true;
					break;
				end
			end

			if #self.jiaScoreNode<num and isHave then
				local chouma = ChouMa:create(lSeatNo,score);
				--chouma:setNum(100);
				chouma:setScale(CHOUMA_SCALE);
				--self.Image_area[tag]:addChild(chouma);
				local pos = cc.p(self.Image_area[tag]:getPositionX(),self.Image_area[tag]:getPositionY())
				chouma:setPosition(pos);
				self.Node_ani:addChild(chouma);
				table.insert(self.jiaScoreNode,chouma); -- 节点
				--刷新各玩家下注池
				self:updataAddScore_jia(lSeatNo);
			end

		end
	end
end

--移除预下注筹码
function TableLayer:clearAddScoreNode_jia()
	for k,v in pairs(self.jiaScoreNode) do
		v:removeFromParent();
	end
	self.jiaScoreNode = {};
end
--刷新自己预下注池
function TableLayer:updataAddScore_jia()
	if #self.jiaScoreNode == 0  then
		luaPrint("错误00！updataAddScore_jia");
		return;
	end
	local lSeatNo = self.tableLogic:getMySeatNo();
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	luaPrint("updataAddScore_jia",lSeatNo,#self.jiaScoreNode);
	local choumaX = 86;
	
	for k,v in pairs(self.jiaScoreNode) do
		local posX,posY = self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY();
		v:setPosition(cc.p(posX,posY-10+k*5));
		if k == #self.jiaScoreNode then
			local allScore = 0;
			allScore = self.jiaScore--self:getSelfAddScore(lSeatNo);
			luaPrint("updataAddScore 333",allScore);
			v:setNum(allScore);
		end
	end
end

--创建筹码
function TableLayer:createScoreNode(lSeatNo,score)
	luaPrint("createScoreNode",lSeatNo,score);
	if score == 0 then
		luaPrint("创建筹码为0");
		return;
	end
	local num = 10;--控制筹码个数
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	local tag = 0;
	if vSeatNo == 0 then
		tag = 1
	elseif vSeatNo == 1 then
		tag = 2
	else
		tag = 3
	end

	local isHave = false;
	for k,v in pairs(self.scoreTable) do
		if v == score then
			isHave = true;
			break;
		end
	end

	--table.insert(self.addScoreTable[vSeatNo+1],score); --分数
	--self.addScoreTable[vSeatNo+1] = self.addScoreTable[vSeatNo+1]+score;
	if #self.addScoreNodeTable[vSeatNo+1]<num and isHave then
		local chouma = ChouMa:create(lSeatNo,score);
		--chouma:setNum(100);
		chouma:setScale(CHOUMA_SCALE);
		local pos = cc.p(self.Image_area[tag]:getPositionX(),self.Image_area[tag]:getPositionY())
		chouma:setPosition(pos);
		self.Node_ani:addChild(chouma);
		table.insert(self.addScoreNodeTable[vSeatNo+1],chouma); -- 节点
		--刷新各玩家下注池
		self:updataAddScore(lSeatNo);
	end

	--自动变换筹码
	self:autoChangeBet(lSeatNo)
	
end

--自动变换筹码
function TableLayer:autoChangeBet(lSeatNo)
	local allScore = self:getSelfAddScore(lSeatNo);
	luaPrint("autoChangeBet",allScore); 
	if allScore == 0 then
		return;
	end
	local scoreT = self:getCastByNum(allScore);--数组
	luaPrint("autoChangeBet000");
	local lSeatNo = lSeatNo;
	self:clearAddScoreNode(lSeatNo);
	luaDump(scoreT);
	for k,v in pairs(scoreT) do
		for i = 1,v do
			local score = self.scoreTable[k];
			luaPrint("autoChangeBetcreateScoreNode",lSeatNo,score);
			local num = 10;--控制筹码个数
			local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
			local tag = 0;
			if vSeatNo == 0 then
				tag = 1
			elseif vSeatNo == 1 then
				tag = 2
			else
				tag = 3
			end

			local isHave = false;
			for k,v in pairs(self.scoreTable) do
				if v == score then
					isHave = true;
					break;
				end
			end

			--table.insert(self.addScoreTable[vSeatNo+1],score); --分数
			--self.addScoreTable[vSeatNo+1] = self.addScoreTable[vSeatNo+1] + score
			if #self.addScoreNodeTable[vSeatNo+1]<num and isHave then
				local chouma = ChouMa:create(lSeatNo,score);
				--chouma:setNum(100);
				chouma:setScale(CHOUMA_SCALE);
				--self.Image_area[tag]:addChild(chouma);
				local pos = cc.p(self.Image_area[tag]:getPositionX(),self.Image_area[tag]:getPositionY())
				chouma:setPosition(pos);
				self.Node_ani:addChild(chouma);
				table.insert(self.addScoreNodeTable[vSeatNo+1],chouma); -- 节点
				--刷新各玩家下注池
				self:updataAddScore(lSeatNo);
			end

		end
	end

end
--刷新各玩家下注池 
function TableLayer:updataAddScore(lSeatNo)
	if lSeatNo == nil or lSeatNo > PLAY_COUNT or lSeatNo < 0 then
		luaPrint("位置错误！");
		return;
	end
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	luaPrint("updataAddScore",lSeatNo,#self.addScoreNodeTable[vSeatNo+1]);
	local choumaX = 86;
	
	for k,v in pairs(self.addScoreNodeTable[vSeatNo+1]) do
		local posX,posY = self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY();
		v:setPosition(cc.p(posX,posY));--posY-10+k*2
		if k == #self.addScoreNodeTable[vSeatNo+1] then
			local allScore = 0;
			allScore = self:getSelfAddScore(lSeatNo);
			luaPrint("updataAddScore 111",allScore);
			v:setNum(allScore);
		end
	end

end

--恢复玩家下注筹码 score 总分数
function TableLayer:updataAddScoreNode(lSeatNo,score)
	if score == 0 then
		return;
	end
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	self.addScoreTable[vSeatNo+1] = score;
	local scoreT,shengValue = self:getCastByNum(score);--数组
	luaPrint("updataAddScoreNode");
	self:clearAddScoreNode(lSeatNo);
	luaDump(scoreT);
	
	-- for k,v in pairs(scoreT) do
	-- 	for i = 1,v do
	-- 		self:createScoreNode(lSeatNo,self.scoreTable[k]);
	-- 	end
	-- end
end

--如果玩家的下注分数有小数，额外加到表中
function TableLayer:addShengYuScore(lSeatNo,score)
	luaPrint("addShengYuScore",score);
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	--table.insert(self.addScoreTable[vSeatNo+1],score);
	self.addScoreTable[vSeatNo+1] = self.addScoreTable[vSeatNo+1] + score;
end

--分割数组
function TableLayer:getCastByNum(value)
	local shengValue = 0;
	local temp = {0,0,0,0,0};
	if value<= 0 then
		return ;
	end
	local betTable = self.scoreTable
	for i=5,1,-1 do
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
			if i == 1 and value ~= 0 then
				shengValue = value;
			end
		end
	end
	return temp,shengValue;
end

--获取自己下注总金额
function TableLayer:getSelfAddScore(lSeatNo)
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	local allScore = 0;
	--luaDump(self.addScoreTable,"getSelfAddScore");
	-- for k,v in pairs(self.addScoreTable[vSeatNo+1]) do
	-- 	allScore = allScore + v;
	-- end
	allScore = self.addScoreTable[vSeatNo+1];
	return allScore;
end

--清理某个玩家的下注池 逻辑位置
function TableLayer:clearAddScoreNode(lSeatNo)
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	for k,v in pairs(self.addScoreNodeTable[vSeatNo+1]) do
		v:removeFromParent();
	end
	self.addScoreNodeTable[vSeatNo+1] = {};
	--self.addScoreTable[vSeatNo+1] = 0;
end

--清理全部玩家的下注池
function TableLayer:clearAllScoreNode()
	-- self:clearAddScoreNode(0);
	-- self:clearAddScoreNode(1);
	-- self:clearAddScoreNode(2);
	for k,v in pairs(self.addScoreNodeTable) do
		for m,n in pairs(v) do
			n:removeFromParent();
		end
	end
	self.addScoreNodeTable = {{},{},{},{},{}};
	self.addScoreTable = {0,0,0,0,0};
end


--下注按钮回调
function TableLayer:ClickButtonBet(sender)
	local tag = sender:getTag();
	luaPrint("ClickButtonBet",tag);
	self.selfScorePos = tag
	-- if tag == 1 then

	-- elseif tag ==2 then

	-- elseif tag ==3 then

	-- elseif tag ==4 then

	-- elseif tag ==5 then
		
	-- end
	self:updateButtonBet();
	audio.playSound("ershiyidian/sound/sound-jetton.mp3",false);
end

--刷新下注按钮的状态
function TableLayer:updateButtonBet()
	if self.selfScorePos == 0 then
		luaPrint("没有选择筹码");
		return;
	end
	for k,v in pairs(self.ButtonBet) do
		if self.selfScorePos == k then
			--v:setScale(1.2);
			self:addSign(v,true);
		else
			--v:setScale(1.0);
			self:addSign(v,false);
		end
	end
end

--添加标记
function  TableLayer:addSign(node,istrue)
	if node == nil then
		return;
	end
	if istrue then
		local sprite = node:getChildByName("quan");
		if sprite then
			sprite:removeFromParent();
		end
		local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
	    local pFrame = sharedSpriteFrameCache:getSpriteFrame("21D_biandaxuanzhong.png");
	    local sprite = cc.Sprite:createWithSpriteFrame(pFrame); 
	    sprite:setName("quan");
	    node:addChild(sprite);
	    sprite:setPosition(50,59);--node:getContentSize().width/2,node:getContentSize().height/2
	else
		local sprite = node:getChildByName("quan");
		if sprite then
			sprite:removeFromParent();
		end
	end
end

--显示下注结果
function TableLayer:showAddScore()
	
end

-- 初始化玩家信息
function TableLayer:initPlayerInfo()
	self.playerNodeInfo = {};
	for i=1,PLAY_COUNT do
		local k = i -1;

		local node = self["Node_player"..k];
		luaPrint("创建头像");
		local playerNode = GamePlayerNode.new(INVALID_USER_ID, k,self);--默认显示
		luaDump(playerNode,"ppp");
		node:addChild(playerNode);
		node:setLocalZOrder(1000);
		if node then
			luaPrint("节点在");
		end
		playerNode:setPosition(cc.p(0,0));
		table.insert(self.playerNodeInfo,playerNode);
	end
	--思考中图标
	self.Image_sikaozhong = {};
	for i=1,PLAY_COUNT do
		local k = i-1;
		local node = self["Image_sikaozhong"..k];
		table.insert(self.Image_sikaozhong,node);
	end
end

function TableLayer:initMusic()
	
	display.loadSpriteFrames("ershiyidian/ershiyidian.plist", "ershiyidian/ershiyidian.png");
	display.loadSpriteFrames("ershiyidian/card.plist", "ershiyidian/card.png");


	if not getEffectIsPlay() then
		self.Button_yinxiao:loadTextures("21D_yinxiao2.png","21D_yinxiao2-on.png","21D_yinxiao2-on.png",UI_TEX_TYPE_PLIST)
        self.Button_yinxiao:setTag(1);	
	end
	if not getMusicIsPlay() then
		self.Button_yinyue:loadTextures("21D_yinyue2.png","21D_yinyue2-on.png","21D_yinyue2-on.png",UI_TEX_TYPE_PLIST)
        self.Button_yinyue:setTag(1);	
    else
    	--背景音乐
		audio.playMusic("ershiyidian/sound/bg.mp3", true);
	end

	
	
end



--游戏基本按钮设置
function TableLayer:initGameNormalBtn()
	--下拉菜单
	if self.Button_menu then
		self.Button_menu:setTag(0);
		self.Image_setting:setVisible(false);
		self.Button_menu:addClickEventListener(function(sender)
			self:ClickOtherButtonBack(sender);
			--self:showPaoMaDeng(0);
		end)
	end

	--音乐
	if self.Button_yinyue then
		self.Button_yinyue:setTag(0);
		if getMusicIsPlay() then
			playMusic("ershiyidian/sound/bg.mp3",true);
			self.Button_yinyue:setTag(0);
			self.Button_yinyue:loadTextures("21D_yinyue.png","21D_yinyue-on.png","21D_yinyue-on.png",UI_TEX_TYPE_PLIST);
		else
			--audio.pauseMusic();
			--setMusicIsPlay(false);
			self.Button_yinyue:setTag(1);
			self.Button_yinyue:loadTextures("21D_yinyue2.png","21D_yinyue2-on.png","21D_yinyue2-on.png",UI_TEX_TYPE_PLIST);
		end
		self.Button_yinyue:addClickEventListener(function(sender)
			luaPrint("Button_yinyue");
			if self.Button_yinyue:getTag() == 0 then
				audio.pauseMusic();
				setMusicIsPlay(false);
				self.Button_yinyue:setTag(1);
				self.Button_yinyue:loadTextures("21D_yinyue2.png","21D_yinyue2-on.png","21D_yinyue2-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("000")
			else
				audio.resumeMusic();
				setMusicIsPlay(true);
				playMusic("ershiyidian/sound/bg.mp3",true);
				self.Button_yinyue:setTag(0);
				self.Button_yinyue:loadTextures("21D_yinyue.png","21D_yinyue-on.png","21D_yinyue-on.png",UI_TEX_TYPE_PLIST);
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
			self.Button_yinxiao:loadTextures("21D_yinxiao.png","21D_yinxiao-on.png","21D_yinxiao-on.png",UI_TEX_TYPE_PLIST);
		else
			--audio.pauseMusic();
			--setMusicIsPlay(false);
			self.Button_yinxiao:setTag(1);
			self.Button_yinxiao:loadTextures("21D_yinxiao2.png","21D_yinxiao2-on.png","21D_yinxiao2-on.png",UI_TEX_TYPE_PLIST);
		end
		self.Button_yinxiao:addClickEventListener(function(sender)
			luaPrint("Button_yinxiao");
			--self:showMsgString("关闭音效功能正在开发");
			if self.Button_yinxiao:getTag() == 0 then
				self.Button_yinxiao:setTag(1);
				--audio.setSoundsVolume(0);
				setEffectIsPlay(false);
				self.Button_yinxiao:loadTextures("21D_yinxiao2.png","21D_yinxiao2-on.png","21D_yinxiao2-on.png",UI_TEX_TYPE_PLIST);
				luaPrint("000")
			else
				self.Button_yinxiao:setTag(0);
				--audio.setSoundsVolume(1);
				setEffectIsPlay(true);
				self.Button_yinxiao:loadTextures("21D_yinxiao.png","21D_yinxiao-on.png","21D_yinxiao-on.png",UI_TEX_TYPE_PLIST);
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

	--规则
	if self.Button_help then
		luaPrint("找到规则按钮");
		self.Button_help:onClick(function(sender)
			luaPrint("Button_guize");
			local layer = HelpLayer:create();
			self:addChild(layer,10000);
		end)
	end

	--保险
	if self.Button_baoxian then
		self.Button_baoxian:setTag(1);
		self.Button_baoxian:onClick(function(sender) 
			self:onClick(sender)
			end)
	end
	--分牌
	if self.Button_fenpai then
		self.Button_fenpai:setTag(2);
		self.Button_fenpai:onClick(function(sender) 
			self:onClick(sender)
			end)
	end
	--翻倍
	if self.Button_fanbei then
		self.Button_fanbei:setTag(3);
		self.Button_fanbei:onClick(function(sender) 
			self:onClick(sender)
			end)
	end
	--叫牌
	if self.Button_jiaopai then
		self.Button_jiaopai:setTag(4);
		self.Button_jiaopai:onClick(function(sender) 
			self:onClick(sender)
			end)
	end
	--停牌
	if self.Button_tingpai then
		self.Button_tingpai:setTag(5);
		self.Button_tingpai:onClick(function(sender) 
			self:onClick(sender)
			end)
	end

	--抢庄
	self.Button_qiang:setPositionY(self.Button_qiang:getPositionY());
	if self.Button_qiang then
		self.Button_qiang:setTag(6);
		self.Button_qiang:setVisible(false);
		self.Button_qiang:onClick(function(sender) 
			self:onClick(sender)
			end)
	end
	--不抢
	self.Button_buqiang:setPositionY(self.Button_buqiang:getPositionY());
	if self.Button_buqiang then
		self.Button_buqiang:setTag(7);
		self.Button_buqiang:setVisible(false);
		self.Button_buqiang:onClick(function(sender) 
			self:onClick(sender)
			end)
	end

	--最小注
	if self.Button_min then
		self.Button_min:setTag(8);
		self.Button_min:onClick(function(sender) 
			self:onClick(sender)
			end)
	end

	--最大注
	if self.Button_max then
		self.Button_max:setTag(9);
		self.Button_max:onClick(function(sender) 
			self:onClick(sender)
			end)
	end

	--弃庄按钮
	if self.Button_qizhuang then
		self.Button_qizhuang:setTag(0);
		self.Button_qizhuang:onClick(function(sender) 
				local tag = sender:getTag();
				if tag == 0 then
					luaPrint("弃庄");
					ESYDInfo:giveUpBanker(true);
				else
					luaPrint("取消弃庄");
					ESYDInfo:giveUpBanker(false);
				end
			end)
	end

	--区块链bar
	self.m_qklBar = Bar:create("ershiyidian",self);
	self.m_qklBar:setScale(0.8)
	self.Button_menu:addChild(self.m_qklBar);
	self.Button_menu:setPositionX(self.Button_menu:getPositionX()-10);
	self.m_qklBar:setPosition(cc.p(40,-45));

	if globalUnit.isShowZJ then
		self.m_logBar = LogBar:create(self);
		self.Button_menu:addChild(self.m_logBar);
		self.Image_setting:setPositionY(self.Image_setting:getPositionY()-30);
		self.Image_setting:setSize(self.Image_setting:getSize().width,self.Image_setting:getSize().height*4/3);
		self.Button_zhanji = ccui.Button:create("bg/zhanji.png","bg/zhanji-on.png");
		self.Button_zhanji:setPosition(self.Button_yinyue:getPositionX(),self.Button_yinyue:getPositionY());
		self.Button_help:setPositionY(self.Button_help:getPositionY()+70);
		self.Button_yinyue:setPositionY(self.Button_yinyue:getPositionY()+70);
		self.Button_yinxiao:setPositionY(self.Button_yinxiao:getPositionY()+70);
		self.Image_setting:addChild(self.Button_zhanji);
		self.Button_zhanji:onClick(function(sender) 
			if self.m_logBar then
				self.m_logBar:CreateLog();
			end
		end)
	end
	
end

--按钮回调函数
function TableLayer:onClick(sender)
	local tag = sender:getTag();
	luaPrint("onClick",tag);
	if tag == 1 then--保险
		--addScrollMessage("保险");
		ESYDInfo:sendInsure(true);
	elseif tag == 2 then--分牌
		--addScrollMessage("分牌");
		ESYDInfo:sendBreakCard();
	elseif tag == 3 then--翻倍
		--addScrollMessage("翻倍");
		ESYDInfo:sendDoubleScore();
	elseif tag == 4 then--叫牌
		--addScrollMessage("要牌");
		ESYDInfo:sendGetCard();
	elseif tag == 5 then--停牌
		--addScrollMessage("停牌");
		ESYDInfo:sendStopCard();
	elseif tag == 6 then--抢庄
		luaPrint("抢");
		ESYDInfo:sendQiang();
	elseif tag == 7 then--不抢
		ESYDInfo:sendBuQiang()
		luaPrint("不抢");
	elseif tag == 8 then--最小注
		luaPrint("最小注",self.minScore );
		if self.minScore >0 then
			ESYDInfo:sendAddMoney(self.minScore);
		else
			luaPrint("最小注有问题");
		end
	elseif tag == 9 then--最大注
		luaPrint("最大注",self.maxScore );
		if self.maxScore >0 then
			ESYDInfo:sendAddMoney(self.maxScore);
		else
			luaPrint("最大注有问题");
		end
	end

	self:removeTimeSound();
	
end

--下拉菜单
function TableLayer:ClickOtherButtonBack(sender)
	local tag = sender:getTag();
	if tag == 0 then
		sender:setTag(1);
		--sender:loadTextures("shouna-on.png","shouna-on.png","shouna-on.png",UI_TEX_TYPE_PLIST);
		self.Image_setting:setVisible(true);
	elseif tag == 1 then
		sender:setTag(0);
		--sender:loadTextures("shouna.png","shouna.png","shouna.png",UI_TEX_TYPE_PLIST);
		self.Image_setting:setVisible(false);
	end
end

function TableLayer:onClickQiangCallBack(sender)
	
end

function TableLayer:onClickXiazhuCallBack(sender)
	
end

--退出
function TableLayer:onClickExitGameCallBack(isRemove)
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出",self.m_bGameStart)
	local func = function()		
	    self.tableLogic:sendUserUp();
	    -- self.tableLogic:sendForceQuit();
	    self:leaveDesk()
	end

	local isCan = false;

	if self:isPlayGame() and self.m_bGameStart then
		isCan = true;
	end

	--Hall:exitGame(isCan,func)

	if isRemove ~= nil and type(isRemove) == "number" then
		Hall:exitGame(isRemove,func);
	else
		Hall:exitGame(isCan,func);
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

		if globalUnit.nowTingId == 0 then
			performWithDelay(display.getRunningScene(), function() RoomLogic:close(); end,0.5);
		end
		
		self._bLeaveDesk = true;
		_instance = nil;
	end
end



-- -- //处理玩家掉线协议
-- function TableLayer:onUserCutMessageResp(userId, seatNo)
-- 	if self.playerNodeInfo[seatNo+1] and self.playerNodeInfo[seatNo+1]:getUserId() == userId then
-- 		self.playerNodeInfo[seatNo+1]:setCutHead();
-- 	end
-- end


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

function TableLayer:startTimer()
	self.updateDaojishiSchedule = schedule(self, function() self:callEverySecond(); end, 1);
end

function TableLayer:stopTimer()
	if self.updateDaojishiSchedule then
		self:stopAction(self.updateDaojishiSchedule);
	end
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

--同意
function TableLayer:gameUserAgree(data)
	if self.m_bGameStart ~= true then
		return;
	end
	luaDump(data,"tongyi")
	local seat = self.tableLogic:logicToViewSeatNo(data.bDeskStation)
	luaPrint("seat= "..seat);

	-- self.Image_zhunbei[seat+1]:setVisible(true);
	if  data.bDeskStation == self.tableLogic._mySeatNo then
		self.Button_zhunbei:setVisible(false);
	end
	local count = self:getDeskRenshu();
	if count > 1 then
		if self.ziSpine then
			self.ziSpine:setVisible(false);
		end
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
    --luaDump(userInfo,"userInfo");

    if userInfo then
    	deskStation = deskStation + 1;
    	self.playerNodeInfo[deskStation]:setUserName(userInfo.nickName);
    	self.playerNodeInfo[deskStation]:setUserMoney(userInfo.i64Money);
        self.playerNodeInfo[deskStation]:setUserId(userInfo.dwUserID);
        self.playerNodeInfo[deskStation]:setHead(userInfo.bLogoID, userInfo.dwUserID,userInfo.bBoy);
        self.playerNodeInfo[deskStation]:setDestion(bSeatNo);
        self.playerNodeInfo[deskStation]:setMan(userInfo.bBoy);
        self.playerNodeInfo[deskStation]:setIP(userInfo.dwUserIP);
        local lSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation-1);
        self.playerNodeInfo[deskStation]:setSeatNoString(lSeatNo);

        self.AtlasLabel_add_score[deskStation]:setString(numberToString2(0));

        self.Image_area[deskStation]:setVisible(true);
        
    end

end

function TableLayer:setUserName(viewseatNo, name)
    if not self:isValidSeat(viewseatNo) then 
        return;
    end

    viewseatNo = viewseatNo + 1;

    self.playerNodeInfo[viewseatNo]:setUserName(name);

end

--人不在不显示
function TableLayer:hidePlay(viewseatNo,isTrue)
	-- if not self:isValidSeat(viewseatNo) then 
 --        return;
 --    end
 --    viewseatNo = viewseatNo + 1;

 --    self.playerNodeInfo[viewseatNo]:setVisible(isTrue);

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

function TableLayer:gameUserCut(seatNo, bCut)
	luaPrint("gameUserCut",seatNo, bCut);
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

-- //服务器收到玩家已经准备好了
function TableLayer:playerGetReady(viewSeat, bAgree)
    -- //准备好图片
    luaPrint("服务器告诉我别人已经准备-----",viewSeat,bAgree)
    local realSeatNo = self.tableLogic:viewToLogicSeatNo(viewSeat);
	local userInfo = self.tableLogic:getUserBySeatNo(realSeatNo);
	-- if userInfo then
	-- 	self.playerNodeInfo[viewSeat+1]:setZhunbei(true);
	-- end
end

-- function TableLayer:removeAllReady()
-- 	for k,v in pairs(self.playerNodeInfo) do
-- 		v:setZhunbei(false);
-- 	end
-- end

function TableLayer:removeUser(deskStation, bMe, bLock)
	luaPrint("removeUser",deskStation,bMe,bLock);
	if not self:isValidSeat(deskStation) then 
		return;
	end
	if bMe then
		self.m_bGameStart = false;

		if bLock == 1 then
			-- self:removeGameJiJiangKaiShi();
			self:addMiaoShaAni();
			audio.playSound("sound/noMoney.mp3");
    		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
	    		addScrollMessage("您的金币不足,自动退出游戏。")
	    		self:onClickExitGameCallBack(5);
	    	end)));
    	elseif bLock == 0 then
    		--addScrollMessage("长时间未操作,自动退出游戏。")
	    	self:onClickExitGameCallBack(5);
	    elseif bLock == 2 then
	    	self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
					str ="房间已关闭,自动退出游戏。"
			    	self:onClickExitGameCallBack(5);
			    	addScrollMessage(str);
			end)));
    	elseif bLock == 3 then
    		str ="长时间未操作,自动退出游戏。"
    		self:onClickExitGameCallBack(5);
    		addScrollMessage(str);
    	elseif bLock == 5 then
    		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
					str ="vip厅房间关闭,自动退出游戏。"
			    	self:onClickExitGameCallBack(5);
			    	addScrollMessage(str);
			end)));
    	end
		return;
	end

	self.playerNodeInfo[deskStation+1]:setUserMoney(0);
    self.playerNodeInfo[deskStation+1]:setUserName("");
    self.playerNodeInfo[deskStation+1]:setEmptyHead();
    self.AtlasLabel_add_score[deskStation+1]:setString(numberToString2(0));
    self.Image_area[deskStation+1]:setVisible(false);

    --根据人数显示等待玩家动画
	if self:GetUserNum() <= 1 then
		--self:addDengQiTaUser();
		self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function()
			if self.m_bGameStart == false then
				--清牌
	    		for k,v in pairs(self.pokerListBoard) do
					v:clearData();
				end
				--添加等待其他玩家动画
				self:addDengQiTaUser();
				--去除所有庄家标志
				self:setBanker(0,false);
				--影藏所有显示牌值图片
				self:hideAllImage_score();
				self.Panel_end:setVisible(false);
			end
    	end)));
	end
end

function TableLayer:addMiaoShaAni()
	local skeleton_animation = createSkeletonAnimation("miaosha","game/gameEffect/pukemiaosha.json", "game/gameEffect/pukemiaosha.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(640,360)
	    skeleton_animation:setAnimation(0,"miaosha_21dian", false);
	    local layer = cc.Director:getInstance():getRunningScene();
	    self.Node_ani:addChild(skeleton_animation,2000000);
	    skeleton_animation:setName("addMiaoShaAni");
	    -- skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function ()
	    -- 	skeleton_animation:removeFromParent();
	    -- end)));
	end
end


function TableLayer:setUserMoney(money,seat)
	luaPrint("money= "..money.." seat= "..seat)
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

		-- self:stopAllActions();

		self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
		
	else
		-- self.isPlaying = false;
		-- self:onClickExitGameCallBack();
	end

	if not audio.isMusicPlaying() then
		audio.playMusic("ershiyidian/sound/bg.mp3", true);
	end

end

--游戏开始
function TableLayer:GameStart(data)
	if self.b_isBackGround == false then
		return;
	end
	self:removeGameStartAni();
	self:removeDengDaiAni();
	self:showGameBegin();

	self:addStartAni();
	self:hideImage_sikaozhong();
	--addScrollMessage("游戏开始可以下注了");
	local msg = data._usedata;
	--记录庄家座位
	self.bankSeatNo = msg.wBankerUser;

	self:hideBankMoney(msg.wBankerUser);--影藏庄家分数
	--设置属性
	local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wBankerUser);
	self.pokerListBoard[vSeatNo+1]:setBanker(true);

	self.playerStation = msg.bUserStatus
	--没参加游戏
	if not self.playerStation[self.tableLogic._mySeatNo+1] then
		self:addDengDaiAni();
	end
	self:setMinMax(msg.lCellScore,msg.lMaxScore);
	self.jiaScore = self.minScore;
	
	self.m_bGameStart = true;

	if self.bankSeatNo ~= self.tableLogic._mySeatNo and self:isPlayGame() then
		self.Image_buttonBG:setVisible(true);
		self:light(true);
	
		self:showUpDownAni(self.Image_buttonBG,true,self.Image_caozuoBG,false);
	    --判断重复按钮是否可见
		self:judgeButton();

		--self:setTime(10,self.tableLogic._mySeatNo,false);

	else
		--self:setTime(10,self.tableLogic._mySeatNo,false);
	end
	self:setTimeToEveryone(10,10);

	--影藏全部玩家的灯
	for k,v in pairs(self.playerNodeInfo) do
		v:showImage_shanliang(false);
	end

	if msg.wBankerUser then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( ... )
			self:setBanker(msg.wBankerUser);
		end)));
	end

	self:updateUserInfo()
	self:initPlayScore();

	--audio.playSound("ershiyidian/sound/start.wav",false);

end

--添加游戏开始动画
function TableLayer:addStartAni()
	local pos = cc.p(640,360)
	self:removeStartAni();
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ( ... )
		audio.playSound("ershiyidian/sound/sound-start-wager.mp3");
	end)));
	local skeleton_animation = createSkeletonAnimation("kaishixiazhu","game/feiqinzoushou.json", "game/feiqinzoushou.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"kaishixiazhu", false);
	    self.Node_ani:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("kaishixiazhu");
	    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ( ... )
	    	self:removeStartAni();
	    end)));
	end
end

--移除游戏开始动画
function TableLayer:removeStartAni()
	local node;
	node = self.Node_ani:getChildByName("kaishixiazhu");
	while(node) do
		node:removeFromParent();
		node = nil;
		node = self.Node_ani:getChildByName("kaishixiazhu");
	end

end

--判断重复按钮是否可见
function TableLayer:judgeButton()
	self.AtlasLabel_record:setString(numberToString2(self.recordScore));
	if self.recordScore ~= 0 then
		self.Button_chongfu:setVisible(true);
		self.Button_chongfu:setEnabled(true);
	else
		self.Button_chongfu:setVisible(true);
		self.Button_chongfu:setEnabled(false);
	end
	self.Button_sure:setVisible(true);
	self.Button_sure:setEnabled(true);

end

--移除保险动画
function TableLayer:removeBaoXianAni()
	if self.baoxianAni then
		self:stopAction(self.baoxianAni);
		self.baoxianAni = nil;
		for k,v in pairs(self.baoxianTable) do
			v:removeFromParent();
		end
		self.baoxianTable = {};
	end
	--对按钮也有一个动画也要去掉
	if self.baoxianAni_Button then
		self:stopAction(self.baoxianAni_Button)
		self.baoxianAni_Button = nil;
	end
	--把庄家的牌也要显示出来
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
	self.pokerListBoard[vSeatNo+1]:hideAllCard(true);
end

--游戏结束
function TableLayer:GameEnd(data)
	luaPrint("GameEnd时间",os.date("%Y-%m-%d %H:%M:%S",os.time()))
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;

	--游戏结束去除保险动画
	self:removeBaoXianAni();

	self.addScoreTable = {0,0,0,0,0};

	--胜利失败特效
	local seq1 = cc.CallFunc:create(function ( ... )
		self:showEndAni(msg.lGameScore);

	end);
	--分数特效
	local seq2 = cc.CallFunc:create(function ( ... )
		for k,v in pairs(msg.lGameScore) do
			if v ~= 0 then
				local vSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
				self.playerNodeInfo[vSeatNo+1]:showScoreAni(v);
			end
		end
		self:showLianShengAni(msg);
	end);

	self:runAction(cc.Sequence:create(seq1,cc.DelayTime:create(1.5),seq2));
	
	--设置按钮
	self:setHideAllButton(true);
	self:setEnabledAllButton(false);
	--游戏结束展示筹码移动动画
	--self:gameEndAni(msg.lGameScore);--msg.lGameScore

	--self:clearAllScoreNode();
	--显示庄家分数
	--self:showBankEndScore(true,msg.lBankScore);
	self:setTime(20,20,4,true);--游戏结束，去除全部玩家的时间
	--self:setTime(5,5,self.tableLogic._mySeatNo,false);
	self:showKuang(0,false);
	self:updateUserInfo()
	self.m_bGameStart = false;
	--清空玩家下注金额
	--self:clearAtlasLabel_add_score();

	self.Panel_end:setVisible(true);

	--等待开始动画
	self:addGameJiJiangKaiShi();
	--弃庄按钮是否显示
	if msg.bShowGiveUp then
		self.Button_qizhuang:setVisible(true);
		self.Button_qizhuang:setTag(0);
		self.Button_qizhuang:loadTextures("21D_qizhuang1.png","21D_qizhuang1-on.png","21D_qizhuang1-on.png",UI_TEX_TYPE_PLIST);
	end

end

--播放连胜特效
function TableLayer:showLianShengAni(data)
		if data.nWinTime > 2 then
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

					shengAction:setPosition(bgSize.width/2,bgSize.height/2+80);
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

--游戏结束展示筹码移动动画
function TableLayer:gameEndAni(lGameScore)
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
	local zhuangPos = cc.p(self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY())--cc.p(640,700);
	local n_time = 0.5;

	--庄家输赢 筹码移动
	local seq1 = cc.CallFunc:create(function ( ... )
		for k,v in pairs(lGameScore) do
			local score = math.abs(v);
			luaPrint("gameEndAni",score)
			local scoreT = self:getCastByNum(score);--数组
			luaDump(scoreT);
			if score ~= 0 then
				if v>0 then
					local lSeatNo = k-1;
					local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
					--table.insert(self.addScoreTable[vSeatNo+1],v);
					--for i,j in pairs(scoreT) do
						--for m = 1,j do
							if v>0 then
								local chouma = ChouMa:create(lSeatNo,self.scoreTable[1]);
								chouma:setScale(CHOUMA_SCALE);
								chouma:setNum(v);
								local pos1 = cc.p(0,0);--开始位置
								local pos2 = cc.p(0,0);--结束位置
								--self["Node_player"..vSeatNo]
								pos1 = cc.p(self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY());
								pos2 = zhuangPos --cc.p(self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY());

								chouma:setPosition(pos2);
								self.Node_ani:addChild(chouma);
								table.insert(self.addScoreNodeTable[vSeatNo+1],chouma);
								--luaPrint("坐标")
								local move = cc.MoveTo:create(n_time,pos1);
								chouma:runAction(cc.Sequence:create(move,cc.DelayTime:create(n_time),cc.CallFunc:create(function ( ... )
									--刷新各玩家下注池
									self:updataAddScore(lSeatNo);

								end)));

							end

						--end
					--end
				else
					local lSeatNo = k-1;
					local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
					
					luaPrint("输钱",#self.addScoreNodeTable[vSeatNo+1]);
					for k,v in pairs(self.addScoreNodeTable[vSeatNo+1]) do
						local pos2 = cc.p(0,0);--结束位置
						pos2 = zhuangPos;
						luaPrint("输钱000",pos2.x,pos2.y);
						local move = cc.MoveTo:create(n_time,pos2); 
						v:runAction(cc.Sequence:create(move,cc.CallFunc:create(function ( ... )
							--v:setVisible(false);
						end)));
					end
				end
			end
		end
	end);

	--赢钱的再移回自己家
	local seq2 = cc.CallFunc:create(function ( ... )
		for k,v in pairs(lGameScore) do
			if v> 0 then
				local lSeatNo = k-1;
				local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
				for m,node in pairs(self.addScoreNodeTable[vSeatNo+1]) do
					local pos2 = cc.p(0,0);
					pos2 = cc.p(self["Node_player"..vSeatNo]:getPositionX(),self["Node_player"..vSeatNo]:getPositionY());
					local move = cc.MoveTo:create(n_time,pos2);  
					node:runAction(move);
				end
			end
		end
	end);

	--清除桌子上的所有筹码
	local seq3 = cc.CallFunc:create(function ( ... )
		self:clearAllScoreNode();
	end);

	local ani = cc.Sequence:create(seq1,cc.DelayTime:create(n_time),seq2,cc.DelayTime:create(n_time),seq3);--seq2,cc.DelayTime:create(n_time),seq3
	self:runAction(ani);

end


--游戏结束动画
function TableLayer:showEndAni(lGameScore)
	local func = function (vSeatNo,score )
		if score == 0 then
			return;
		end
		local pos = cc.p(self["Node_player"..vSeatNo]:getPositionX(),self["Node_player"..vSeatNo]:getPositionY()+80)
		if score >0 then
			self:addAnimation(4,pos);
		else
			self:addAnimation(3,pos);
		end
	end

	for k,v in pairs(lGameScore) do
		local vSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
		if v ~= 0 then
			func(vSeatNo,v);--展示动画
		end
	end

	if lGameScore[self.tableLogic._mySeatNo+1]>= 0 then
		audio.playSound("ershiyidian/sound/win.wav",false);
	else
		audio.playSound("ershiyidian/sound/lost.wav",false);
	end

end

--显示游戏结束界面
function TableLayer:showEndLayer()
	self:removeGameJiJiangKaiShi();
	local endlayer = self:getChildByName("EndLayer");
	if endlayer then
		endlayer:removeFromParent();
	end
	local endlayer = EndLayer:create(self)
	self:addChild(endlayer);
end

--发牌消息
function TableLayer:GameSendCard(data)
	if self.b_isBackGround == false then
		return;
	end

	luaPrint("GameSendCard时间",os.date("%Y-%m-%d %H:%M:%S",os.time()))
	
	local msg = data._usedata;

	self.Image_buttonBG:setVisible(false);

	self:light(false);
	--self:showUpDownAni(self.Image_buttonBG,false,self.Image_caozuoBG,true);
	--玩家牌
	--msg.cbHandCardData = {{1,11},{1,12},{1,13},{1,13},{1,13}};
	for k,v in pairs(msg.cbHandCardData) do--pokerListBoard
		local vSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
		self.pokerListBoard[vSeatNo+1]:createHandNode(v);
		--测试代码--------------------- start
		--local vSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
		--if vSeatNo == 1 then
			-- self.pokerListBoard[vSeatNo+1]:createHandNode({1,1});
			-- self.pokerListBoard[vSeatNo+1]:separateCardNode(true)
			-- self.pokerListBoard[vSeatNo+1]:addCardNode1(13);
			-- self.pokerListBoard[vSeatNo+1]:addCardNode2(13);
			-- self.pokerListBoard[vSeatNo+1]:addCardNode1(13);
			-- self.pokerListBoard[vSeatNo+1]:addCardNode1(13);
			-- self.pokerListBoard[vSeatNo+1]:addCardNode2(13);
			-- self.pokerListBoard[vSeatNo+1]:addCardNode2(13);
			--self.pokerListBoard[vSeatNo+1]:addCardNode(3);
			--self.pokerListBoard[vSeatNo+1]:addCardNode(3);
		--测试代码--------------------- end
		-- if v[1] ~= 0 then
		-- 	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ( ... )
		-- 		self:showGameScore(k-1,false);
		-- 	end)));
		-- end
	end

	--发牌的时候延迟显示分数
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ( ... )
		for k,v in pairs(msg.cbHandCardData) do
			if v[1] ~= 0 then
				self:showGameScore(k-1,false);
			end
		end
	end)));


	--庄家牌
	--self:createBankerPokers(msg.cbBankerHandCardData);
	--记录当前玩家
	self.n_CurrentUser = msg.cbCurrentUser;

	local baoxian = false;--是否需要买保险
	--是否需要买保险
	luaPrint("self.bankSeatNo",self.bankSeatNo);
	if GetCardValue(msg.cbHandCardData[self.bankSeatNo+1][1]) == 1 then
		baoxian = true;
		luaPrint("需要买保险",baoxian);
		if self.isPlay and self.bankSeatNo ~= self.tableLogic._mySeatNo then
			self:showTiShi(true);
		end
	end
	--当前玩家操作
	self:showCurrentUser(baoxian);
	--设置时间
	if baoxian  then --要买保险
		--self:setTime(5,self.tableLogic._mySeatNo,false);
		self:setTimeToEveryone(5,5);
	else
		self:setTime(20,20,msg.cbCurrentUser,false);

		self.FaPaiKuangAni = cc.Sequence:create(cc.DelayTime:create(1.2),cc.CallFunc:create(function ( ... )
			self:showKuang(msg.cbCurrentUser);
			self.FaPaiKuangAni = nil;
		end))
		self:runAction(self.FaPaiKuangAni);
		-- if msg.cbCurrentUser == self.tableLogic._mySeatNo then
		-- 	self:setTime(20,self.tableLogic._mySeatNo,false);
		-- else
		-- 	self:setTime(20,msg.cbCurrentUser,false);
		-- end
	end

	--audio.playSound("ershiyidian/sound/send_card.wav",false);
		
end

--去除发牌的时候显示框延时动画
function TableLayer:removeFaPaiKuangAni()
	if self.FaPaiKuangAni then
		self:stopAction(self.FaPaiKuangAni);
		self.FaPaiKuangAni = nil;
	end
end

--显示框 istrue 是否全部影藏
function TableLayer:showKuang(lSeatNo,istrue)
	luaPrint("showKuang",lSeatNo,istrue);
	if lSeatNo < 0 or lSeatNo > PLAY_COUNT then
		luaPrint("showKuang REEOR!")
		return;
	end

	if istrue == false then
		for k,v in pairs(self.pokerListBoard) do
			v:updateCaoZuoKuang(false);
		end
	else
		local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
		luaPrint("showKuang",vSeatNo);
		for k,v in pairs(self.pokerListBoard) do
			if k == vSeatNo+1 then
				v:updateCaoZuoKuang(true);
			else
				v:updateCaoZuoKuang(false);
			end
		end
	end
end

--是否隐藏所有按钮
function TableLayer:setHideAllButton(isTrue)
	self.Button_baoxian:setVisible(isTrue);
	self.Button_fenpai:setVisible(isTrue);
	self.Button_fanbei:setVisible(isTrue);
	self.Button_jiaopai:setVisible(isTrue);
	self.Button_tingpai:setVisible(isTrue);
end
--是否所有按钮不可触摸
function TableLayer:setEnabledAllButton(isTrue)
	self.Button_baoxian:setEnabled(isTrue);
	self.Button_fenpai:setEnabled(isTrue);
	self.Button_fanbei:setEnabled(isTrue);
	self.Button_jiaopai:setEnabled(isTrue);
	self.Button_tingpai:setEnabled(isTrue);
end


--显示当前玩家操作 once 是否需要买保险
function TableLayer:showCurrentUser(once)
	luaPrint("showCurrentUser",once);
	if once == nil then
		once = false;
	end

	--需要买保险
	if once then
		if self.bankSeatNo ~= self.tableLogic._mySeatNo then
			self.Image_buttonBG:setVisible(false);
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
			if self.isPlay then
				self.Button_baoxian:setEnabled(once);
			else
				self.Button_baoxian:setEnabled(false);
			end
		end
	else
		--不需要买保险，轮到自己操作
		if self.n_CurrentUser == self.tableLogic._mySeatNo then
			self.Image_buttonBG:setVisible(false);
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
			self.Button_baoxian:setEnabled(once);
			local vSeatNo = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
			if self.pokerListBoard[vSeatNo+1]:isBreakCard() then
				self.Button_fenpai:setEnabled(true);
			else
				self.Button_fenpai:setEnabled(false);
			end
			self.Button_fanbei:setEnabled(true);
			self.Button_jiaopai:setEnabled(true);
			self.Button_tingpai:setEnabled(true);
		else
			self.Image_buttonBG:setVisible(false);
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
		end
	end
end

--操作模块升降操作
function TableLayer:showUpDownAni(node1,visible1,node2,visible2) --上升，影藏
	luaPrint("showUpDownAni");
	if node1 == nil or node2 == nil then
		return;
	end
	local Pos = cc.p(640,19)--cc.p(node:getPositionX(),node:getPositionY())--原始坐标

	--开始坐标
	local startPos = cc.p(0,0)
	
	startPos = cc.p(Pos.x,Pos.y-100);

	node1:setVisible(false);
	node2:setVisible(false);
	
	if visible1 and not visible2 then --上升

		node2:setVisible(false);

		node1:setPosition(startPos);

		node1:setVisible(true);

		local move = cc.MoveTo:create(0.3,Pos);
		node1:stopAllActions();
		node1:runAction(cc.Sequence:create(move));

	elseif not visible1 and  visible2 then

		node1:setVisible(false);

		node2:setPosition(startPos);

		node2:setVisible(true);

		local move = cc.MoveTo:create(0.3,Pos);
		node2:stopAllActions();
		node2:runAction(cc.Sequence:create(move));
	end
	

end
--分牌
function TableLayer:GameBreakCard(data)
	if self.b_isBackGround == false then
		return;
	end

	local msg = data._usedata;

	self.Image_buttonBG:setVisible(false);
	self:light(false);
	--设置时间
	--self:setTime(10,msg.wSplitUser,false);
	local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wSplitUser);
	--设置牌对象分牌
	self.pokerListBoard[vSeatNo+1]:separateCardNode(true);
	--添加二张牌
	self.pokerListBoard[vSeatNo+1]:addCardNode1(msg.cbCardData[1]);

	self.pokerListBoard[vSeatNo+1]:addCardNode2(msg.cbCardData[2]);

	--设置按钮
	self:setHideAllButton(true);
	self:setEnabledAllButton(false);
	if msg.wSplitUser == self.tableLogic._mySeatNo then
		self.Button_tingpai:setEnabled(true);
		self.Button_jiaopai:setEnabled(true);
		self.Button_fanbei:setEnabled(true);
	end
	--加钱
	self:addInsuranceScore(msg.wSplitUser,msg.lAddScore);
	--显示得分
	self:showGameScore(msg.wSplitUser);
	self:setPlayerStation(msg.wSplitUser,2)
	self:showKuang(msg.wSplitUser);
	--显示玩家下注金额
	self:showScoreString(msg.wSplitUser,msg.lAddScore);
	self:showBankAfterScore(msg.wSplitUser,msg.lAddScore);
end
--停牌
function TableLayer:GameStopCard(data)
	if self.b_isBackGround == false then
		return;
	end

	--停牌去除保险动画
	self:removeBaoXianAni();
	--去除发牌显示操作框延迟动画
	self:removeFaPaiKuangAni();
	
	local msg = data._usedata;

	self.Image_buttonBG:setVisible(false);
	self:light(false);

	--自己停牌了
	if msg.wStopCardUser == msg.cbCurrentUser then--self.tableLogic._mySeatNo
		self.Image_buttonBG:setVisible(false);
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);
		
		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wStopCardUser);
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then
			self.pokerListBoard[vSeatNo+1]:setStop(true);
		else
			self.pokerListBoard[vSeatNo+1]:setStop_num(true);
		end
		self.Button_jiaopai:setEnabled(true);
		self.Button_tingpai:setEnabled(true);
		self.Button_fanbei:setEnabled(true);

	else--其他玩家

		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wStopCardUser);
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then
			self.pokerListBoard[vSeatNo+1]:setStop(true);
		else
			--如果已经分过牌了，那就判断是第几滩
			luaPrint("GameStopCard",self.pokerListBoard[vSeatNo+1]:getStop2());
			self.pokerListBoard[vSeatNo+1]:setStop_num(true);
			--self.pokerListBoard[vSeatNo+1]:setStop_num(true);--加一次手动停牌
		end

	end

	--轮到玩家操作
	if msg.cbCurrentUser == self.tableLogic._mySeatNo and self.bankSeatNo ~= self.tableLogic._mySeatNo then
		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wStopCardUser);
		local nextPlay = false;
		if not self.pokerListBoard[vSeatNo+1]:getSeparate() and self.pokerListBoard[vSeatNo+1]:getStop() then
			nextPlay = true;
		end
		if self.pokerListBoard[vSeatNo+1]:getSeparate() and self.pokerListBoard[vSeatNo+1]:getStop1() and self.pokerListBoard[vSeatNo+1]:getStop2() then
			nextPlay = true;
		end

		if nextPlay then
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
			self.Button_jiaopai:setEnabled(true);
			self.Button_tingpai:setEnabled(true);
			local vSeatNo = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
			if self.pokerListBoard[vSeatNo+1]:isBreakCard() then
				self.Button_fenpai:setEnabled(true);
			end
			--没翻倍 2张牌 可翻倍
			if not self.pokerListBoard[vSeatNo+1]:getSeparate() and #self.pokerListBoard[vSeatNo+1].handCardNode == 2 then
				self.Button_fanbei:setEnabled(true);
			end
			--分牌第2滩 2张牌 可翻倍
			if self.pokerListBoard[vSeatNo+1]:getSeparate() then
				if self.pokerListBoard[vSeatNo+1]:getStop2() == false then
					self.Button_fanbei:setEnabled(true);
				end
			end
		end

		--如果(自己是黑夹克)就不可以把按钮亮起来 or (是21)也不可以操作了
		self:judgeSelfCardTypeForButton();

	else
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);
	end

	--显示停牌玩家的点数
	--self:showGameScore(msg.wStopCardUser);

	if msg.cbCurrentUser == msg.wStopCardUser then
		self:showKuang(msg.wStopCardUser);
	else
		self:setTime(20,20,msg.cbCurrentUser,false);
		self:showKuang(msg.cbCurrentUser);
	end

	if self.doubleSeatNo ~= msg.wStopCardUser then
		self:setPlayerStation(msg.wStopCardUser,5)	
	end

	--音效
	local tt = self.delayTime;
	local isPlay = true;
	isPlay = self:isTeXiaoPaiType(msg.wStopCardUser);
	if self.doubleSeatNo == msg.wStopCardUser or not isPlay then
		tt = 0;
	end 

	self:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime),cc.CallFunc:create(function ( ... )
		--添加音效
		luaPrint("音效000",isPlay);
		if self.doubleSeatNo ~= msg.wStopCardUser and isPlay then
			self:addEffectSound(5,msg.wStopCardUser)--停牌
		end
	end)));

	self:runAction(cc.Sequence:create(cc.DelayTime:create(tt+self.delayTime),cc.CallFunc:create(function ( ... )
		self:addValueSound(msg.wStopCardUser);
		self.doubleSeatNo = -1;
	end)));

end

--判断自己的按钮要不要显示
--如果(自己是黑夹克)就不可以把按钮亮起来 or (是21点)也不可以操作了
function TableLayer:judgeSelfCardTypeForButton()
	luaPrint("judgeSelfCardTypeForButton");
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
	if not self.pokerListBoard[vSeatNo+1]:getSeparate()  then
		luaPrint("judgeSelfCardTypeForButton0");
		--#self.pokerListBoard[vSeatNo+1].handCardNode == 2
		local cards= self.pokerListBoard[vSeatNo+1]:getHandCard();
		local value1,value2,value3;
		value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,false);
		if value1 == PokerCommonDefine.Poker_Value_Type.CT_BJ then--黑夹克
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
		end
	else
		if  self.pokerListBoard[vSeatNo+1]:getStop1() and not self.pokerListBoard[vSeatNo+1]:getStop2() then
			local cards2 = self.pokerListBoard[vSeatNo+1]:getHandCard2();
			local value1,value2,value3;
			value1,value2,value3 = self.The21stLogic:GetCardType(cards2,#cards2,true);
			luaPrint("judgeSelfCardTypeForButton1",value1,value2,value3);
			if  value1 == 21 then
				self:setHideAllButton(true);
				self:setEnabledAllButton(false);
			end
		elseif  self.pokerListBoard[vSeatNo+1]:getStop1() and self.pokerListBoard[vSeatNo+1]:getStop2() then
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
		end
	end
end

--判断是否是特别牌型
function TableLayer:isTeXiaoPaiType(lSeatNo)
	local value1,value2,value3;
	local cards = {};

	if lSeatNo then
		-- cards = self.bankerCards
		-- value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,false);

		local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then
			cards= self.pokerListBoard[vSeatNo+1]:getHandCard();
		else
			if self.pokerListBoard[vSeatNo+1]:getStop1() and not self.pokerListBoard[vSeatNo+1]:getStop2() then
				cards= self.pokerListBoard[vSeatNo+1]:getHandCard1();
			elseif  self.pokerListBoard[vSeatNo+1]:getStop1() and  self.pokerListBoard[vSeatNo+1]:getStop2() then
				cards= self.pokerListBoard[vSeatNo+1]:getHandCard2();
			end
		end
		--luaDump(cards);
		--luaPrint("222---",self.pokerListBoard[vSeatNo+1]:getSeparate());
		local isbreak = self.pokerListBoard[vSeatNo+1]:getSeparate(); 
		value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,isbreak);
	end
	luaPrint("isTeXiaoPaiType",value1,value2,value3)
	if value1 == 21 or value1 == PokerCommonDefine.Poker_Value_Type.CT_BAOPAI  or value1 == PokerCommonDefine.Poker_Value_Type.CT_BJ then
		return false;
	else
		return true;
	end

end

--停牌的时候音效
function TableLayer:addValueSound(lSeatNo)
	luaPrint("addValueSound",lSeatNo);
	local value1,value2,value3;
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	if lSeatNo  then
		local cards = {}
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then
			cards= self.pokerListBoard[vSeatNo+1]:getHandCard();
		else
			if self.pokerListBoard[vSeatNo+1]:getStop1() and not self.pokerListBoard[vSeatNo+1]:getStop2() then
				cards= self.pokerListBoard[vSeatNo+1]:getHandCard1();
			elseif self.pokerListBoard[vSeatNo+1]:getStop1() and self.pokerListBoard[vSeatNo+1]:getStop2() then
				cards= self.pokerListBoard[vSeatNo+1]:getHandCard2();
			end
		end
		local isbreak = self.pokerListBoard[vSeatNo+1]:getSeparate(); 
		value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,isbreak);
	end

	--判断是不是二个21点,二个21点只需要一个21点音效
	local twoErShiYi = true;
	if self.pokerListBoard[vSeatNo+1]:getSeparate() then
		cards1 = self.pokerListBoard[vSeatNo+1]:getHandCard1();
		cards2 = self.pokerListBoard[vSeatNo+1]:getHandCard2();
		local value1 = self.The21stLogic:GetCardType(cards1,#cards1,true);
		local value2 = self.The21stLogic:GetCardType(cards2,#cards2,true);
		if value1 == value2 then
			if value1 == 21 then --只有21点一个可能，爆牌和黑杰克都不可能
				twoErShiYi = false;
			end
		end
	end
	luaPrint("addValueSound***",value1);
	if value1 == 21 and twoErShiYi then
		self:addEffectSound(8,lSeatNo)--21点
	end
	if value1 == PokerCommonDefine.Poker_Value_Type.CT_BAOPAI then--爆牌
		self:addEffectSound(6,lSeatNo)
	end
	if value1 == PokerCommonDefine.Poker_Value_Type.CT_BJ then--黑杰克
		self:addEffectSound(7,lSeatNo)
	end

end


--展示每个玩家的分数 (只在场景消息里调用)
function TableLayer:showPlayGameScore()
	luaPrint("showPlayGameScore");
	for k,v in pairs(self.pokerListBoard) do
		luaPrint("showPlayGameScore1",v:getSeparate());
		local lSeatNo = self.tableLogic:viewToLogicSeatNo(k-1);
		if lSeatNo ~= self.bankSeatNo  then
			luaPrint("庄家位置不显示");
				if v:getSeparate() == false then --没有分牌
					--if v:getStop() == false then
						local cards = v:getHandCard();
						if #cards > 0 then
							local value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,false);
							local vSeatNo = k-1;
							luaPrint("showPlayGameScore000",value1,2*vSeatNo+1);
							self.Image_score[2*vSeatNo+1]:setVisible(true);
							local text = self.Image_score[2*vSeatNo+1]:getChildByName("AtlasLabel_value");
							self:setGameTextColor(text,value1,value2,value3,vSeatNo);
						end
					--end
				else--分过牌
					--第一滩
					local cards = v:getHandCard1();
					if #cards > 0  then
						local value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,true);
						
						local vSeatNo = k-1;
						luaPrint("玩家牌值1",value1,k-1,2*vSeatNo+1);
						self.Image_score[2*vSeatNo+1]:setVisible(true);
						local text = self.Image_score[2*vSeatNo+1]:getChildByName("AtlasLabel_value");
						self:setGameTextColor(text,value1,value2,value3,vSeatNo,1);
					end
					--第二滩
					if #cards > 0  then
						local cards = v:getHandCard2();
						local value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,true);
						
						local vSeatNo = k-1;
						luaPrint("玩家牌值2",value1,k-1,2*vSeatNo+2);
						self.Image_score[2*vSeatNo+2]:setVisible(true);
						local text = self.Image_score[2*vSeatNo+2]:getChildByName("AtlasLabel_value");
						self:setGameTextColor(text,value1,value2,value3,vSeatNo,2);
					end
				end
		end
	end
end

--显示停牌玩家的点数
function TableLayer:showGameScore(lSeatNo,isBank)
	luaPrint("showGameScore",lSeatNo,isBank);
	if isBank == nil then
		isBank = false;
	end
	if lSeatNo<0 or lSeatNo>4 then
		luaPrint("停牌玩家座位号错误！");
	end

	if lSeatNo == self.bankSeatNo and not isBank then
		luaPrint("庄家位置不显示");
		return;
	end

	if lSeatNo>=0 and lSeatNo<PLAY_COUNT then--玩家停牌
		local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then--没分牌
			local cards = self.pokerListBoard[vSeatNo+1]:getHandCard();
			local value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,false);
			luaDump(cards,"玩家牌值");
			luaPrint("玩家牌值",value1,2*vSeatNo+1);
			self.Image_score[2*vSeatNo+1]:setVisible(true);
			local text = self.Image_score[2*vSeatNo+1]:getChildByName("AtlasLabel_value");
			self:setGameTextColor(text,value1,value2,value3,vSeatNo);

		else--分牌了
			
			luaPrint("showGameScore000",2*vSeatNo+1);
			self.Image_score[2*vSeatNo+1]:setVisible(true);
			local text = self.Image_score[2*vSeatNo+1]:getChildByName("AtlasLabel_value");
			local cards = self.pokerListBoard[vSeatNo+1]:getHandCard1();
			local value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,true);
			self:setGameTextColor(text,value1,value2,value3,vSeatNo,1);
		
	
			luaPrint("showGameScore111",2*vSeatNo+2);
			self.Image_score[2*vSeatNo+2]:setVisible(true);
			local text = self.Image_score[2*vSeatNo+2]:getChildByName("AtlasLabel_value");
			local cards = self.pokerListBoard[vSeatNo+1]:getHandCard2();
			local value1,value2,value3 = self.The21stLogic:GetCardType(cards,#cards,true);
			luaDump(cards);
			luaPrint("showGameScore111--",value);
			self:setGameTextColor(text,value1,value2,value3,vSeatNo,2);	
		end
	-- elseif lSeatNo == 4 then--庄家停牌
	-- 		self.Image_score[#self.Image_score]:setVisible(true);
	-- 		local text = self.Image_score[#self.Image_score]:getChildByName("AtlasLabel_value");
	-- 		local value1,value2,value3 = self.The21stLogic:GetCardType(self.bankerCards,#self.bankerCards,false);--
	-- 		luaPrint("pyf------",value1,value2,value3);
	-- 		self:setGameTextColor(text,value1,value2,value3,4);
	else
		luaPrint("停牌玩家错误！");
	end
end

--设置文本颜色 节点 牌型 牌点数 是否A算11 视图位置 第几滩（nil表示没有分牌）
function TableLayer:setGameTextColor(text,value1,value2,value3,vSeatNo,tan)
	luaPrint("setGameTextColor",value1,value2,value3,vSeatNo);
	if value1 == 0 then
		text:getParent():setVisible(false);
		return;
	end
	text:setString(value1);

	if value1 == PokerCommonDefine.Poker_Value_Type.CT_BAOPAI then--爆牌
		luaPrint("红色",value2);
		text:setColor(cc.c3b(255, 0, 0));
		text:setString(value2);
		self:addTeXiao(vSeatNo,1,text,tan);
	elseif value1 == PokerCommonDefine.Poker_Value_Type.CT_BJ then--黑杰克
		luaPrint("黑杰克",value1);
		text:setColor(cc.c3b(255, 255, 255));
		text:setString(":;<=>?");--Blackjack
		self:addTeXiao(vSeatNo,2,text,tan);
	else
		text:setColor(cc.c3b(255, 255, 255));
		luaPrint("黑色",value1);

		-- if value1 == 21 then
		-- 	if vSeatNo == 4 then
		-- 		self:addEffectSound(8,4)
		-- 	else
		-- 		self:addEffectSound(8,self.tableLogic:viewToLogicSeatNo(vSeatNo))
		-- 	end
		-- end
	end

	--判断玩家是否有二个值
	if value3 and value1~=PokerCommonDefine.Poker_Value_Type.CT_BJ then
		local str = tostring(value1-10).."/"..tostring(value1);
		text:setString(str);
	end

	if value1>0 then
		self:adjustTextPos(vSeatNo);
	end
end

--添加特效 爆了/黑夹克
function TableLayer:addTeXiao(vSeatNo,nType,node,tan)
	luaPrint("addTeXiao",vSeatNo,nType);
	if node == nil then
		return;
	end
	local pos = cc.p(0,0)
	if vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then --南边
		pos = cc.p(20,-100)
		if self.pokerListBoard[vSeatNo+1]:getSeparate() then
			pos = cc.p(10,-100)
		end
	elseif vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then --西边
		pos = cc.p(-150,0)
		if self.pokerListBoard[vSeatNo+1]:getSeparate() then
			local num_zhong = 0;
			if tan == 1 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum1()/2)-1;
			elseif tan == 2 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum2()/2)-1;
			end
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(-120-dis,-10)
		else
			local num_zhong = math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum()/2)-1;
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(-120-dis,-10)
		end
	elseif vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East then --东边
		pos = cc.p(200,0)
		if self.pokerListBoard[vSeatNo+1]:getSeparate() then
			local num_zhong = 0;
			if tan == 1 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum1()/2)-1;
			elseif tan == 2 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum2()/2)-1;
			end
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(150+dis,-10)
		else
			local num_zhong = math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum()/2);
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(150+dis,-10)
		end
	elseif vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 then --北1
		pos = cc.p(-150,0)
		if self.pokerListBoard[vSeatNo+1]:getSeparate() then
			local num_zhong = 0;
			if tan == 1 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum1()/2)-1;
			elseif tan == 2 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum2()/2)-1;
			end
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(-120-dis,-10)
		else
			local num_zhong = math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum()/2)-1;
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(-120-dis,-10)
		end
	elseif vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then --北2
		pos = cc.p(200,0)
		if self.pokerListBoard[vSeatNo+1]:getSeparate() then
			local num_zhong = 0;
			if tan == 1 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum1()/2);
			elseif tan == 2 then
				num_zhong= math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum2()/2);
			end
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(150+dis,-10)
		else
			local num_zhong = math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum()/2);
			local dis = num_zhong*60*0.6 or 0;
			pos = cc.p(150+dis,-10)
		end
	end
	if nType == 1 then--爆了
		luaPrint("爆了",vSeatNo);
		local sp = node:getChildByName("baole");
		if sp then
			sp:setPosition(pos)
			return;
		end
		local skeleton_animation = createSkeletonAnimation("baole","ershiyidian/animate/baole/baole.json", "ershiyidian/animate/baole/baole.atlas");
	    if skeleton_animation then
		    skeleton_animation:setPosition(pos)
		    skeleton_animation:setAnimation(0,"baole", false);
		    node:addChild(skeleton_animation,10000);
		    luaPrint("添加爆了",vSeatNo)
		    skeleton_animation:setName("baole");
		end
	    --audio.playSound("ershiyidian/sound/button.mp3",false);
	    
	elseif nType == 2 then--黑夹克
		luaPrint("黑杰克",vSeatNo);
		pos = cc.p(65,20);
		local sp = node:getChildByName("blackjack");
		if sp then
			sp:setPosition(pos)
			return;
		end
		
		local skeleton_animation = createSkeletonAnimation("blackjack","ershiyidian/animate/blackjack/blackjack.json", "ershiyidian/animate/blackjack/blackjack.atlas");
	    if skeleton_animation then
		    skeleton_animation:setPosition(pos)
		    skeleton_animation:setAnimation(0,"blackjack", true);
		    node:addChild(skeleton_animation,10000);
		    skeleton_animation:setName("blackjack");
		    luaPrint("添加blackjack",vSeatNo)
		end
	    
	end

end

--清除所有特效
function  TableLayer:clearAllTeXiao()
	luaPrint("clearAllTeXiao",#self.Image_score);
	for k,v in pairs(self.Image_score) do
		local sp1 = v:getChildByName("AtlasLabel_value"):getChildByName("baole");
		if sp1 then
			luaPrint("去除爆了");
			sp1:removeFromParent();
		end
		local sp2 = v:getChildByName("AtlasLabel_value"):getChildByName("blackjack");
		if sp2 then
			luaPrint("去除blackjack");
			sp2:removeFromParent();
		end
	end
end

--调整分数图片位置
function TableLayer:adjustTextPos(vSeatNo)
	if vSeatNo == nil then
		return;
	end
	luaPrint("adjustTextPos",vSeatNo,self.pokerListBoard[vSeatNo+1]:getSeparate());
	
	--南边位置
	if vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then
		local disX = 50;
		local disY = 130;
		if self.pokerListBoard[vSeatNo+1]:getSeparate()==false then -- 未分牌
			disY = 140;
			local cardNum = self.pokerListBoard[vSeatNo+1]:getCardNum();
			local pos = cc.p(0,0);
			local num_zhong = math.ceil(cardNum/2);
			pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode[num_zhong]:getPositionX()+disX,self.pokerListBoard[vSeatNo+1].handCardNode[num_zhong]:getPositionY()+disY);
			self.Image_score[2*vSeatNo+1]:setPosition(pos);
		else--分过牌
			--if self.pokerListBoard[vSeatNo+1]:getStop1() and not self.pokerListBoard[vSeatNo+1]:getStop2() then
				disY = 130;
				local cardNum = self.pokerListBoard[vSeatNo+1]:getCardNum1();
				local pos = cc.p(0,0);
				local num_zhong = math.ceil(cardNum/2);
				luaPrint("adjustTextPos000",num_zhong,self.pokerListBoard[vSeatNo+1].handCardNode1[num_zhong]:getPositionX(),self.pokerListBoard[vSeatNo+1].handCardNode1[num_zhong]:getPositionY());
				pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode1[num_zhong]:getPositionX()+disX,self.pokerListBoard[vSeatNo+1].handCardNode1[num_zhong]:getPositionY()+disY);
				self.Image_score[2*vSeatNo+1]:setPosition(pos);
			--elseif self.pokerListBoard[vSeatNo+1]:getStop1() and self.pokerListBoard[vSeatNo+1]:getStop2() then
				local cardNum = self.pokerListBoard[vSeatNo+1]:getCardNum2();
				local pos = cc.p(0,0);
				local num_zhong = math.ceil(cardNum/2);
				luaPrint("adjustTextPos111",num_zhong,self.pokerListBoard[vSeatNo+1].handCardNode2[num_zhong]:getPositionX(),self.pokerListBoard[vSeatNo+1].handCardNode2[num_zhong]:getPositionY());
				pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode2[num_zhong]:getPositionX()+disX,self.pokerListBoard[vSeatNo+1].handCardNode2[num_zhong]:getPositionY()+disY);
				self.Image_score[2*vSeatNo+2]:setPosition(pos);
			--end
		end
	elseif vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West or vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East 
	or vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 or vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then--西边
		if self.pokerListBoard[vSeatNo+1]:getSeparate()==false then -- 未分牌
			local pos = cc.p(0,0);
			num_zhong = self.pokerListBoard[vSeatNo+1]:getCardNum();
			local disX = 155
			local disY = 50
			if vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East or vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
				disX = -1*disX/2;
				disY = disY
				num_zhong = 1;
			end
			pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode[num_zhong]:getPositionX()+disX,self.pokerListBoard[vSeatNo+1].handCardNode[num_zhong]:getPositionY()+disY);
			self.Image_score[2*vSeatNo+1]:setPosition(pos);
		else--分过牌

			--if self.pokerListBoard[vSeatNo+1]:getStop1() and not self.pokerListBoard[vSeatNo+1]:getStop2() then
				local pos = cc.p(0,0);
				num_zhong = self.pokerListBoard[vSeatNo+1]:getCardNum1();
				local disX = 155
				local disY = 50
				if vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East or vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
					disX = -1*disX/2;
					disY = disY
					num_zhong = 1;
				end
				pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode1[num_zhong]:getPositionX()+disX,self.pokerListBoard[vSeatNo+1].handCardNode1[num_zhong]:getPositionY()+disY);
				self.Image_score[2*vSeatNo+1]:setPosition(pos);
			--elseif self.pokerListBoard[vSeatNo+1]:getStop1() and self.pokerListBoard[vSeatNo+1]:getStop2() then
				local pos = cc.p(0,0);
				num_zhong = self.pokerListBoard[vSeatNo+1]:getCardNum2();
				local disX = 155
				local disY = 50
				if vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East or vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
					disX = -1*disX/2;
					disY = disY
					num_zhong = 1;
				end
				pos = cc.p(self.pokerListBoard[vSeatNo+1].handCardNode2[num_zhong]:getPositionX()+disX,self.pokerListBoard[vSeatNo+1].handCardNode2[num_zhong]:getPositionY()+disY);
				self.Image_score[2*vSeatNo+2]:setPosition(pos);
			--end
		end
	end
end

--最后点数背景全部影藏,但是节点显示
function TableLayer:hideAllImage_score()
	luaPrint("hideAllImage_score",#self.Image_score);
	for k,v in pairs(self.Image_score) do
		v:setVisible(false);
	end
end
--加倍
function TableLayer:GameDoubleScore(data)
	if self.b_isBackGround == false then
		return;
	end

	local msg = data._usedata;
	self.doubleSeatNo = msg.wDoubleScoreUser;
	self.Image_buttonBG:setVisible(false);
	self:light(false);
	--if msg.wDoubleScoreUser == self.tableLogic._mySeatNo then
		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wDoubleScoreUser);
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then
			self.pokerListBoard[vSeatNo+1]:addCardNode(msg.cbCardData);
		else
			self.pokerListBoard[vSeatNo+1]:addCardNode_num(msg.cbCardData);
		end
	--end
	--加钱
	self:addInsuranceScore(msg.wDoubleScoreUser,msg.lAddScore);
	self:setPlayerStation(msg.wDoubleScoreUser,3)
	self:addEffectSound(2,msg.wDoubleScoreUser)
	self:showKuang(msg.wDoubleScoreUser);
	--显示玩家下注金额
	self:showScoreString(msg.wDoubleScoreUser,msg.lAddScore);
	self:showBankAfterScore(msg.wDoubleScoreUser,msg.lAddScore);
end
--保险
function TableLayer:GameInsurance(data)
	if self.b_isBackGround == false then
		return;
	end
	
	local msg = data._usedata;
	self.Image_buttonBG:setVisible(false);
	self:light(false);
	if msg.IsComplete > 0 then
		--self:setTime(20,20,msg.cbCurrentUser,false);
		--self:showKuang(msg.cbCurrentUser);
	else
		self:removeTimeToWhichOne(msg.wInsureUser);
	end

	-- if msg.cbCurrentUser == self.tableLogic._mySeatNo then
	-- 	self:showTiShi(false);
	-- end
	--如果保险已经完成
	if msg.IsComplete > 0  then --and msg.cbCurrentUser == self.tableLogic._mySeatNo
		luaPrint("保险已完成");
		local vSeatNo = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);
		self:showTiShi(false);

		--轮到玩家操作
		-- if msg.cbCurrentUser == self.tableLogic._mySeatNo then
		-- 	self.Button_fanbei:setEnabled(true);
		-- 	self.Button_jiaopai:setEnabled(true);
		-- 	self.Button_tingpai:setEnabled(true);
		-- 	if self.pokerListBoard[vSeatNo+1]:isBreakCard() then
		-- 		self.Button_fenpai:setEnabled(true);
		-- 	end

		-- 	self:showTiShi(false);
		-- end
		self:showTiShi(false);
		self:addInsuranceScore(msg.wInsureUser,msg.lInsureScore);
		
		local seq1 = cc.CallFunc:create(function ( ... )
			--保险动画
			self:showInsuranceAni(msg.IsComplete);
		end);
		local seq2 = cc.CallFunc:create(function ( ... )
			    --测试要求，时间对不上就不管了
				self:setTime(20,20,msg.cbCurrentUser,false);
				self:showKuang(msg.cbCurrentUser);
				if msg.cbCurrentUser == self.tableLogic._mySeatNo then
					self.Button_fanbei:setEnabled(true);
					self.Button_jiaopai:setEnabled(true);
					self.Button_tingpai:setEnabled(true);
					if self.pokerListBoard[vSeatNo+1]:isBreakCard() then
						self.Button_fenpai:setEnabled(true);
					end
				end
				self:stopAction(self.baoxianAni_Button);
				self.baoxianAni_Button = nil;
		end);
		self.baoxianAni_Button = cc.Sequence:create(seq1,cc.DelayTime:create(1.5),seq2)
		self:runAction(self.baoxianAni_Button);

		
	else--保险阶段还没有完成，某个玩家操作结果
		luaPrint("保险没完成",msg.wInsureUser,self.tableLogic._mySeatNo);
		self:addInsuranceScore(msg.wInsureUser,msg.lInsureScore);
		if msg.wInsureUser == self.tableLogic._mySeatNo then
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
			self:showTiShi(false);
		end

		if msg.IsInsure then
			self:addEffectSound(1,msg.wInsureUser)
		end
	end
	--显示保险小字
	if msg.IsInsure then
		self:setPlayerStation(msg.wInsureUser,1)
	end

	--显示玩家下注金额
	self:showScoreString(msg.wInsureUser,msg.lInsureScore);
	self:showBankAfterScore(msg.wInsureUser,msg.lInsureScore);
	
end

--增加保险金 或者 翻倍
function TableLayer:addInsuranceScore(lSeatNo,score)

	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	--table.insert(self.addScoreTable[vSeatNo+1],score); --分数
	self.addScoreTable[vSeatNo+1] = self.addScoreTable[vSeatNo+1] + score

	-- local scoreT = self:getCastByNum(score);--数组
	-- local max = 10;
	-- local n_time = 0.2;
	-- luaPrint("addInsuranceScore");
	-- luaDump(scoreT);
	
	-- local s_num = 1;--寻找筹码
	-- for k,v in pairs(self.scoreTable) do
	-- 	if v == score then
	-- 		s_num = k;
	-- 		break;
	-- 	end
	-- end
	-- if score > 0 then
	-- 	local chouma = ChouMa:create(lSeatNo,self.scoreTable[s_num]);
	-- 	chouma:setScale(CHOUMA_SCALE);
	-- 	self:addChild(chouma);
	-- 	local pos1 = cc.p(0,0)
	-- 	--self["Node_player"..k]
	-- 	pos1 = cc.p(self["Node_player"..vSeatNo]:getPositionX(),self["Node_player"..vSeatNo]:getPositionY());

	-- 	chouma:setPosition(pos1);
	-- 	local pos2 = cc.p(0,0);
	-- 	pos2 = cc.p(self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY());

	-- 	local moveto = cc.MoveTo:create(n_time,pos2);
	-- 	chouma:runAction(cc.Sequence:create(moveto,cc.CallFunc:create(function ()
	-- 		chouma:removeFromParent();
	-- 		local chouma = ChouMa:create(lSeatNo,self.scoreTable[s_num]);
	-- 		chouma:setScale(CHOUMA_SCALE);
	-- 		--self.Image_area[vSeatNo+1]:addChild(chouma);
	-- 		local pos = cc.p(self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY())
	-- 		chouma:setPosition(pos);
	-- 		self.Node_ani:addChild(chouma);
	-- 		table.insert(self.addScoreNodeTable[vSeatNo+1],chouma); -- 节点
	-- 		--刷新各玩家下注池
	-- 		self:updataAddScore(lSeatNo);
	-- 	end)));
	-- end

	-- self:updataAddScore(lSeatNo);

end

--保险动画
function TableLayer:showInsuranceAni(value)
	local n_time = 0.5;--每一步的时间
	--显示庄家是不是21点（保险阶段）
	self:runAction(cc.Sequence:create(cc.DelayTime:create(n_time*3),cc.CallFunc:create(function ( ... )
		self:showBankerValue(value);
	end)));

	--影藏庄家动画
	if self.tableLogic._mySeatNo == self.bankSeatNo then
		luaPrint("自己是庄家,不需要动画");
		return;
	end
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
	self.pokerListBoard[vSeatNo+1]:hideAllCard(false);

	local scale = 0.7;
	if self.pokerListBoard[vSeatNo+1]:getSeparate() then
		scale = 0.6;
	end

	self.baoxianTable = {};--动画节点
	local bankerCards = {};--动画牌值
	bankerCards = self.pokerListBoard[vSeatNo+1]:getHandCard();

	if #bankerCards ~= 2 then
		luaPrint("动画获取牌值出错！");
		return;
	end

	for k,v in pairs(bankerCards) do
		local poker = Poker.new(self:getCardTextureFileName(v), v);
		poker:setScale(scale);
		self.Node_root:addChild(poker);
		poker:setLocalZOrder(#bankerCards-k);
		table.insert(self.baoxianTable,poker);
		poker:setPosition(self:getBankerMovePos(k));
	end

	local pos = cc.p(0,0);
	pos = cc.p(self.baoxianTable[2]:getPositionX(),self.baoxianTable[2]:getPositionY());
	
	local seq1 = cc.CallFunc:create(function ()
		local move = cc.MoveTo:create(n_time,pos);
		self.baoxianTable[1]:runAction(move);
	end);

	local seq2 = cc.CallFunc:create(function ()
		local move = cc.MoveTo:create(n_time,cc.p(pos.x,pos.y+50));
		self.baoxianTable[1]:runAction(move);
		--nodeTable[2]:setVisible(false);
		local move = cc.MoveTo:create(n_time,cc.p(pos.x,pos.y+50));
		self.baoxianTable[2]:runAction(move);
	end);

	local seq3 = cc.CallFunc:create(function ()
		local move = cc.MoveTo:create(n_time,self:getBankerMovePos(1));
		self.baoxianTable[2]:setVisible(true);
		self.baoxianTable[1]:runAction(move);
		local move = cc.MoveTo:create(n_time,pos);
		self.baoxianTable[2]:runAction(move);
	end);

	local seq4 = cc.CallFunc:create(function ()
		for k,v in pairs(self.baoxianTable) do
			v:removeFromParent();
		end
		self.pokerListBoard[vSeatNo+1]:hideAllCard(true);
		self.baoxianAni = nil;
		self.baoxianTable = {};

	end);

	self.baoxianAni = cc.Sequence:create(seq1,cc.DelayTime:create(n_time),seq2,cc.DelayTime:create(n_time),seq3,cc.DelayTime:create(n_time),seq4)
	self:runAction(self.baoxianAni);

end

--显示庄家是不是21点（保险阶段）
function TableLayer:showBankerValue(value)
	luaPrint("showBankerValue",value,PokerCommonDefine.Poker_Value_Type.CT_BJ );
	--不是黑杰克
	if value ~= PokerCommonDefine.Poker_Value_Type.CT_BJ then
		local sp = cc.Sprite:create("ershiyidian/bg/wu.png");
		local pos = cc.p(0,0);
		local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
		local num_zhong = math.floor(self.pokerListBoard[vSeatNo+1]:getCardNum()/2);
		local dis = num_zhong*60*0.6 or 0;
		pos = cc.p(0,30)
		sp:setPosition(pos);
		luaPrint("-----",self.bankSeatNo,vSeatNo,num_zhong);
		local node;
		node = self.pokerListBoard[vSeatNo+1].handCardNode[self.pokerListBoard[vSeatNo+1]:getCardNum()];
		self:addWuBlackjack(node,pos);
		--node:addChild(sp);
	end
end

--添加无黑杰克动画
function TableLayer:addWuBlackjack(node,pos)
	local pos1 = cc.p(node:getPositionX(),node:getPositionY())
	local skeleton_animation = createSkeletonAnimation("wublackjack","ershiyidian/animate/wublackjack/wublackjack.json", "ershiyidian/animate/wublackjack/wublackjack.atlas");
    if skeleton_animation then
	    skeleton_animation:setAnimation(0,"wublackjack", false);
	    self.Node_ani:addChild(skeleton_animation);
	    skeleton_animation:setPosition(cc.p(pos1.x,pos1.y+30));
	    skeleton_animation:setName("wublackjack");
	    node:runAction(cc.Sequence:create(cc.DelayTime:create(15),cc.CallFunc:create(function ( ... )
				skeleton_animation:removeFromParent();
				skeleton_animation = nil;
			end)));
	end
end

--下注
function TableLayer:GameAddScore(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;
	
	luaPrint("GameAddScore",msg.wAddScoreUser,self.tableLogic._mySeatNo);

	self:removeTimeToWhichOne(msg.wAddScoreUser);
	if msg.wAddScoreUser == self.tableLogic._mySeatNo then--自己下注
		self:clearAddScoreNode_jia();
		self.jiaScore = 0;
		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser);
		self.Image_buttonBG:setVisible(false);
		self:light(false);
		self:showUpDownAni(self.Image_buttonBG,false,self.Image_caozuoBG,true);
		self:showTiShi(false);
		self:updataAddScoreNode(msg.wAddScoreUser,msg.lAddScore);
		--self:setTime(0,self.tableLogic._mySeatNo,false);
		self.isPlay = true;
		self.recordScore = msg.lAddScore;
	else--别人下注
		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wAddScoreUser);
		self:updataAddScoreNode(msg.wAddScoreUser,msg.lAddScore);
	end
	--显示玩家下注金额
	self:showScoreString(msg.wAddScoreUser,msg.lAddScore);
	--显示下注动画
	--self:addScoreAni(msg.wAddScoreUser,msg.lAddScore);
	self:setPlayerStation(msg.wAddScoreUser,6)
	self:showBankAfterScore(msg.wAddScoreUser,msg.lAddScore);
	audio.playSound("ershiyidian/sound/count_score.wav",false);
end

--下注后金币显示，玩家金币减去下注金币 逻辑位置，下注分数
function TableLayer:showBankAfterScore(lSeatNo,score)
	local viewSeat = self.tableLogic:logicToViewSeatNo(lSeatNo);
	local userInfo = self.tableLogic:getUserBySeatNo(lSeatNo);
	if userInfo then
		local allScore = self.playerScore[viewSeat+1];
		self.playerScore[viewSeat+1] = self.playerScore[viewSeat+1]-score;
		self.playerNodeInfo[viewSeat+1]:setUserMoney(allScore-score);
	end

end

--显示玩家下注金额
function TableLayer:showScoreString(lSeatNo,score)
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	local allScore = 0;
	allScore = self:getSelfAddScore(lSeatNo);

	self.AtlasLabel_add_score[vSeatNo+1]:setString(numberToString2(allScore));
end

--清空玩家下注金额
function TableLayer:clearAtlasLabel_add_score()
	for k,v in pairs(self.AtlasLabel_add_score) do
		v:setString(numberToString2(0));
	end
end

--展示下注动画
function TableLayer:addScoreAni(lSeatNo,score)
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	--table.insert(self.addScoreNodeTable[vSeatNo+1],chouma); -- 节点
	--先把桌子上的筹码全部影藏
	for k,v in pairs(self.addScoreNodeTable[vSeatNo+1]) do
		v:setVisible(false);
	end
	local choumaTable = {};--保存临时筹码
	local seq1 = cc.CallFunc:create(function ( ... )
		local scoreT = self:getCastByNum(score);--数组
		for k,v in pairs(scoreT) do
			for i = 1,v do
				local chouma = ChouMa:create(lSeatNo,self.scoreTable[k]);
				chouma:setScale(CHOUMA_SCALE);
				table.insert(choumaTable,chouma);
				local pos1 = cc.p(0,0);--开始位置
				local pos2 = cc.p(0,0);--结束位置

				pos1 = cc.p(self["Node_player"..vSeatNo]:getPositionX(),self["Node_player"..vSeatNo]:getPositionY());
				pos2 = cc.p(self.Image_area[vSeatNo+1]:getPositionX(),self.Image_area[vSeatNo+1]:getPositionY());

				chouma:setPosition(pos1);
				self.Node_card:addChild(chouma);

				local move = cc.MoveTo:create(0.3,pos2);
				chouma:runAction(move);
			end
		end
	end);

	local seq2 = cc.CallFunc:create(function ( ... )
		for k,v in pairs(choumaTable) do 
			v:removeFromParent();
		end

		for k,v in pairs(self.addScoreNodeTable[vSeatNo+1]) do
			v:setVisible(true);
		end
	end);

	local addScore = cc.Sequence:create(seq1,cc.DelayTime:create(0.3),seq2)
	self:runAction(addScore);

end

--要牌
function TableLayer:GameGetCard(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;
	self.Image_buttonBG:setVisible(false);
	self:light(false);
	--要牌
	if msg.wGetCardUser then
		local vSeatNo = self.tableLogic:logicToViewSeatNo(msg.wGetCardUser);
		if self.pokerListBoard[vSeatNo+1]:getSeparate() == false then --没有分过牌
			self.pokerListBoard[vSeatNo+1]:addCardNode(msg.cbCardData);
		else
			self.pokerListBoard[vSeatNo+1]:addCardNode_num(msg.cbCardData);
			for k,v in pairs(self.pokerListBoard) do
				luaPrint("ppp",v.stop,v.stop1,v.stop2);
			end
		end
		--设置按钮 如果是庄家按钮不要
		if self.tableLogic._mySeatNo == msg.wGetCardUser and self.tableLogic._mySeatNo ~= self.bankSeatNo then
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
			self.Button_jiaopai:setEnabled(true);
			self.Button_tingpai:setEnabled(true);

			--玩家只有2张牌的时候才可以加倍
			local myViewSeat = self.tableLogic:logicToViewSeatNo(self.tableLogic._mySeatNo);
			if self.pokerListBoard[myViewSeat+1]:getSeparate() == false then
				if #self.pokerListBoard[myViewSeat+1].handCardNode == 2 then
					self.Button_fanbei:setEnabled(true);
				end
			end
		else
			self:setHideAllButton(true);
			self:setEnabledAllButton(false);
		end

		--要牌音效
		self:addEffectSound(4,msg.wGetCardUser)

	end

	self:setPlayerStation(msg.wGetCardUser,4)
	self:showKuang(msg.wGetCardUser);

end
--庄家的牌
function TableLayer:GameBankCard(data)
	luaPrint("GameBankCard时间",os.date("%Y-%m-%d %H:%M:%S",os.time()))
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;
	--游戏结束去除保险动画
	self:removeBaoXianAni();

	self.Image_buttonBG:setVisible(false);
	self:light(false);
	--self:updateBankerPokers(msg.cbBankerHandCardData);
	luaPrint("GameBankCard",self.bankSeatNo);
	local vSeatNo = self.tableLogic:logicToViewSeatNo(self.bankSeatNo);
	self.pokerListBoard[vSeatNo+1]:updateHandCardForBanker(msg.cbBankerHandCardData);
	--特效牌型声音
	self:addValueSound(self.bankSeatNo);
	--设置按钮
	self:setHideAllButton(true);
	self:setEnabledAllButton(false);
	self:setTime(20,20,4,true);--庄家操作，去除全部玩家的时间
	self:showGameScore(self.bankSeatNo,true);
	self:showKuang(0,false);
end
--//玩家未操作
function TableLayer:GameNoAction(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;
	self.Image_buttonBG:setVisible(false);
	self:light(false);

	self:showEndLayer()

end

--//玩家抢庄
function TableLayer:GameQiang(data)
	if self.b_isBackGround == false then
		return;
	end

	local msg = data._usedata;
	luaPrint("GameQiang",msg.wChairID,self.tableLogic._mySeatNo);
	if msg.wChairID == self.tableLogic._mySeatNo then
		self.Button_qiang:setVisible(false);
		self.Button_buqiang:setVisible(false);
		--self:setTime(5,5,self.tableLogic._mySeatNo,true);
	end
	if msg.bQiang then
		table.insert(self.qiangUserTable,msg.wChairID);	
	end
	self:showImage_sikaozhong(msg.wChairID,msg.bQiang);
	self:removeTimeToWhichOne(msg.wChairID);


	local userInfo = self.tableLogic:getUserBySeatNo(msg.wChairID);
	if userInfo and msg.bQiang then
		local str = "";
		if getUserSex(userInfo.bLogoID,userInfo.bBoy) then
			str = "ershiyidian/sound/qiangzhuang_nan.mp3"
		else
			str = "ershiyidian/sound/qiangzhuang_nv.mp3"
		end
		audio.playSound(str,false);
	end
end
--//开始抢庄
function TableLayer:GameBegin(data)
	if self.b_isBackGround == false then
		return;
	end

	self:removeGameStartAni();
	self:removeDengDaiAni();
	self:showGameBegin();

	local msg = data._usedata;

	self.m_bGameStart = true;
	self.bankSeatNo = -1;
	
	self.playerStation = msg.byUserStatus;--记录有几个玩家参与游戏
	--self:setTime(5,self.tableLogic._mySeatNo,false);
	self:setTimeToEveryone(5,5);
	if msg.byUserStatus[self.tableLogic._mySeatNo+1] == 1 then
		self.isPlay = true;
		self.Button_qiang:setVisible(true);
		self.Button_buqiang:setVisible(true);
	end
	self:setBanker(0,false);
	--几个人参加游戏就显示几个思考
	for k,v in pairs(msg.byUserStatus) do
		if v == 1 then
			local vSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
			self.Image_sikaozhong[vSeatNo+1]:setVisible(true);
		end
	end 

	self:initPlayScore();
	
end
--//放弃庄
function TableLayer:GameGiveUp(data)
	if self.b_isBackGround == false then
		return;
	end

	local msg = data._usedata;
	luaPrint("GameGiveUp",msg.wChairID);
	self:removeTimeToWhichOne(msg.wChairID);
	if msg.wChairID == self.tableLogic._mySeatNo then
		if msg.bGiveUp then
			self.Button_qizhuang:setTag(1);
			self.Button_qizhuang:loadTextures("21D_qizhuang2.png","21D_qizhuang2-on.png","21D_qizhuang2-on.png",UI_TEX_TYPE_PLIST);
		else
			self.Button_qizhuang:setTag(0);
			self.Button_qizhuang:loadTextures("21D_qizhuang1.png","21D_qizhuang1-on.png","21D_qizhuang1-on.png",UI_TEX_TYPE_PLIST);
		end
	end
end

--显示思考中，抢庄，不抢 图片
function TableLayer:showImage_sikaozhong(lSeatNo,istrue)
	luaPrint("showImage_sikaozhong",lSeatNo,istrue);
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	for k,v in pairs(self.Image_sikaozhong) do
		if k == vSeatNo+1 then
			v:setVisible(true);
			if istrue then
				v:loadTexture("21D_qiangzhuang.png",UI_TEX_TYPE_PLIST);
			else
				v:loadTexture("21D_buqiang.png",UI_TEX_TYPE_PLIST);
			end
		else
			--v:setVisible(false);
		end
		v:ignoreContentAdaptWithSize(true);
	end
end

--//通知庄家
function TableLayer:GameBankUser(data)
	if self.b_isBackGround == false then
		return;
	end
	local msg = data._usedata;
	luaDump(msg,"GameBankUser");
	self.bankSeatNo = msg.wChairID;
	self:showPaoMaDeng(msg.wChairID);
end

--影藏庄家玩家的下注金额
function TableLayer:hideBankMoney(realSeatNo)
	luaPrint("hideBankMoney",realSeatNo);
	local viewSeat = self.tableLogic:logicToViewSeatNo(realSeatNo);
	for k,v in pairs(self.Image_area) do
		if k == viewSeat+1 then
			v:setVisible(false);
		else
			local lSeatNo = self.tableLogic:viewToLogicSeatNo(k-1);
			local userInfo = self.tableLogic:getUserBySeatNo(lSeatNo);
			if userInfo then -- self.playerStation[k]
				v:setVisible(true);
			else
				v:setVisible(false);
			end
		end
	end
end

--设置庄家
function TableLayer:setBanker(lSeatNo,istrue)
	if istrue == false then
		--移除所有头像庄家标志
		for k,v in pairs(self.playerNodeInfo) do
			v:setBank(false);
		end

		--思考中图片重置隐藏
		for k,v in pairs(self.Image_sikaozhong) do
			v:loadTexture("21D_sikaozhong.png",UI_TEX_TYPE_PLIST);
			v:setVisible(false);
			v:ignoreContentAdaptWithSize(true);
		end

		return;
	end

	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	for k,v in pairs(self.playerNodeInfo) do
		if k == vSeatNo+1 then
			v:setBank(true);
		else
			v:setBank(false);
		end
	end

	self.pokerListBoard[vSeatNo+1]:setBanker(true);

	self.bankSeatNo = lSeatNo;

end

--跑马灯动画
function TableLayer:showPaoMaDeng(lSeatNo)
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);--中奖者的视图位置

	local tempNode = {};-- = self.playerNodeInfo--{};--参与抢庄的玩家
	luaDump(self.qiangUserTable,"self.qiangUserTable");
	for k,v in pairs(self.qiangUserTable) do
		local vSeatNo = self.tableLogic:logicToViewSeatNo(v);
		table.insert(tempNode,self.playerNodeInfo[vSeatNo+1]);
	end

	--tempNode = self.playerNodeInfo

	if #tempNode == 0 then
		table.insert(tempNode,self.playerNodeInfo[lSeatNo+1]);
	end

	--显示灯亮
	function func(i)
		luaPrint("func000",i);
		i = (i%(#tempNode))
		luaPrint("func",i);
		for k,v in pairs(tempNode) do
			if i+1 == k then
				v:showImage_shanliang(true);
			else
				v:showImage_shanliang(false);
			end
		end
	end

	function removeSchedule()
		local startPos = cc.p(self.Image_zhuang:getPositionX(),self.Image_zhuang:getPositionY());
		local pos = cc.p(self["Node_player"..vSeatNo]:getPositionX()+114/2,self["Node_player"..vSeatNo]:getPositionY()+148/2);
		local moveto = cc.MoveTo:create(0.5,pos);
		local scaleTo = cc.ScaleTo:create(0.5,0.4,0.4);
		local spawn = cc.Spawn:create(moveto, scaleTo); 
		self.Image_zhuang:setVisible(true);
		self.Image_zhuang:runAction(cc.Sequence:create(spawn,cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
			self.Image_zhuang:setVisible(false);
			self.Image_zhuang:setPosition(startPos);
			self.Image_zhuang:setScale(1.0);
			for k,v in pairs(self.playerNodeInfo) do
				v:showImage_shanliang(false);
			end
			self:setBanker(lSeatNo);
		end)));
		self:stopAction(self.n_schedule);
		self.n_schedule = nil;
	end
	
	if #tempNode >= 2 then
		local speed = 4;--速度
		local m_time = 2;--时间
		local num = math.floor(m_time/(1/speed));
		if self.n_schedule then
			self:stopAction(self.n_schedule);
			self.n_schedule = nil;
		end
		self.n_schedule = schedule(self, function() 
			m_time = m_time - 1*1.0/speed;
			num = num -1
			if num <=0 then
				for k,v in pairs(self.playerNodeInfo) do
					v:showImage_shanliang(false);
				end
				func(vSeatNo);--最后胜利者
				removeSchedule();
				audio.playSound("random_banker.mp3",false);
				return;
			end
			func(num);
			
		end, 1.0/speed);
	else
		local seq1 = cc.CallFunc:create(function ( ... )
			func(vSeatNo);
		end);
		local seq2 = cc.CallFunc:create(function ( ... )
			--removeSchedule();
			for k,v in pairs(self.playerNodeInfo) do
				v:showImage_shanliang(false);
			end
		end);
		self:runAction(cc.Sequence:create(seq1,cc.DelayTime:create(2.0),seq2));
	end

end

--场景消息 空闲状态
function TableLayer:gameStationFree(msg)
	luaPrint("空闲状态");
	self:showGameBegin();

	self.b_isBackGround = true;
	self:setButtonStation(1);
	self:setMinMax(msg.lCellScore,msg.lMaxScore);
	self:updateUserInfo()
	self:initPlayScore();

	if msg.bShowGiveUp then
		self.Panel_end:setVisible(true);
		self.Button_qizhuang:setVisible(true);
		if msg.bGiveUp then
			self.Button_qizhuang:setTag(1);
			self.Button_qizhuang:loadTextures("21D_qizhuang2.png","21D_qizhuang2-on.png","21D_qizhuang2-on.png",UI_TEX_TYPE_PLIST);
		else
			self.Button_qizhuang:setTag(0);
			self.Button_qizhuang:loadTextures("21D_qizhuang1.png","21D_qizhuang1-on.png","21D_qizhuang1-on.png",UI_TEX_TYPE_PLIST);
		end
	end

	--根据人数显示等待玩家动画
	if self:GetUserNum() <= 1 then
		self:addDengQiTaUser();
	else
		self:removeDengQiTaUser();
	end
	--ESYDInfo:sendStart()
end
--场景消息 抢庄状态
function TableLayer:gameStationQiang(msg)
	luaPrint("抢庄状态");
	self:showGameBegin();
	self.b_isBackGround = true;
	self.m_bGameStart = true;
	--记录玩家是否参与游戏
	self.playerStation = msg.bUserStatus;
	self:setMinMax(msg.lCellScore,msg.lMaxScore);
	self:setTimeToEveryone(msg.iLeftTime,5);--5
	self:initPlayScore();

	--恢复抢庄人数
	for k,v in pairs(msg.bQiang) do
		if v == 1 then
			table.insert(self.qiangUserTable,k-1);
		end
	end
	
	luaPrint("msg.bQiang[self.tableLogic._mySeatNo+1]",msg.bQiang[self.tableLogic._mySeatNo+1]);
	if  tonumber(msg.bQiang[self.tableLogic._mySeatNo+1]) == 255 then
		luaPrint("yes");
		if self:isPlayGame() then
			self.Button_qiang:setVisible(true);
			self.Button_buqiang:setVisible(true);
			--self:setTime(5,self.tableLogic._mySeatNo,false);
		end
	else
		luaPrint("no");
		self.Button_qiang:setVisible(false);
		self.Button_buqiang:setVisible(false);
		self:removeTimeToWhichOne(self.tableLogic._mySeatNo);
	end

	--恢复思考中图片
	for k,v in pairs(msg.bUserStatus) do
		local vSeatNo = self.tableLogic:logicToViewSeatNo(k-1);
		if v == true then --参与游戏了
			if msg.bQiang[k] == 255 then
				self.Image_sikaozhong[vSeatNo+1]:setVisible(true);
				self.Image_sikaozhong[vSeatNo+1]:loadTexture("21D_sikaozhong.png",UI_TEX_TYPE_PLIST);
			elseif msg.bQiang[k] == 1 then
				self.Image_sikaozhong[vSeatNo+1]:setVisible(true);
				self.Image_sikaozhong[vSeatNo+1]:loadTexture("21D_qiangzhuang.png",UI_TEX_TYPE_PLIST);
				self:removeTimeToWhichOne(k-1);
			elseif msg.bQiang[k] == 0 then
				self.Image_sikaozhong[vSeatNo+1]:setVisible(true);
				self.Image_sikaozhong[vSeatNo+1]:loadTexture("21D_buqiang.png",UI_TEX_TYPE_PLIST);
				self:removeTimeToWhichOne(k-1);
			end
			self.Image_sikaozhong[vSeatNo+1]:ignoreContentAdaptWithSize(true);
		end
	end
	--没参加游戏
	if not msg.bUserStatus[self.tableLogic._mySeatNo+1] then
		self:addDengDaiAni();
	end

end

--场景消息 叫分状态
function TableLayer:gameStationAddScore(msg)
	luaPrint("叫分状态");
	self:showGameBegin();

	self.b_isBackGround = true;
	self.m_bGameStart = true;

	self:initPlayScore();

	-- 记录庄家位置
	self.bankSeatNo = msg.wBankerChair;
	--记录玩家是否参与游戏
	self.playerStation = msg.bUserStatus;

	self:setButtonStation(2);
	self:setMinMax(msg.lCellScore,msg.lMaxScore);
	self:setBanker(msg.wBankerChair);

	self.jiaScore = self.minScore;

	self:setHideAllButton(true);
	self:setEnabledAllButton(false);
	--恢复桌面下注
	self:restoreAddScoreNode(msg.lTableScore)

	self:setTimeToEveryone(msg.dwTimerLeftMS,10);--10
	for k,v in pairs(msg.lTableScore) do
		if v>0 and msg.bUserStatus[k] then
			self:removeTimeToWhichOne(k-1);
		end
	end
	--判断自己有木有参与本局游戏
	if msg.bUserStatus[self.tableLogic._mySeatNo+1] == false then--没有参与
		luaPrint("000000000");
		self:addDengDaiAni();
		self:showTiShi(false);
		self.isPlay = false;
		self.Image_buttonBG:setVisible(false);
		self.Image_caozuoBG:setVisible(true);
		self:removeTimeToWhichOne(self.tableLogic._mySeatNo);
	else--参与
		self.isPlay = true;
		self.m_bGameStart = true;
		--没下注并且不是庄家
		if msg.lTableScore[self.tableLogic._mySeatNo+1] == 0 and self.tableLogic._mySeatNo ~= self.bankSeatNo then
			luaPrint("11111111111",msg.dwTimerLeftMS);
			--self:setTime(5,self.tableLogic._mySeatNo,false);
			self:light(true);
			self.Image_buttonBG:setVisible(true);
			self.Image_caozuoBG:setVisible(false);
			--判断重复按钮是否可见
			self:judgeButton();
		else--下过猪
			luaPrint("222222222222");
			--self:setTime(0,self.tableLogic._mySeatNo,false);
			self:light(false);
			self.Image_buttonBG:setVisible(false);
			self.Image_caozuoBG:setVisible(true);
		end

	end
	self:hideBankMoney(msg.wBankerChair);
	self:updateUserInfo()
	self:updateUserInfoForBankAfter(msg.lTableScore);
end

--场景恢复 下注后金额
function TableLayer:updateUserInfoForBankAfter(lTableScore)

	for k,v in pairs(lTableScore) do
		local lSeatNo = k-1;
		local viewSeat = self.tableLogic:logicToViewSeatNo(lSeatNo);
		self:showBankAfterScore(lSeatNo,v);
	end

end

--场景消息 保险状态
function TableLayer:gameStatusInsure(msg)
	luaPrint("保险状态");
	self:showGameBegin();

	self.b_isBackGround = true;
	self.m_bGameStart = true;

	self:initPlayScore();
	
	self.n_CurrentUser = msg.cbCurrentUser;
	-- 记录庄家位置
	self.bankSeatNo = msg.wBankerChair;
	--记录玩家是否参与游戏
	self.playerStation = msg.bUserStatus;

	self:setButtonStation(3,msg);
	self:setMinMax(msg.lCellScore,msg.lMaxScore);
	self:setBanker(msg.wBankerChair);
	--self:setTime(msg.dwTimerLeftMS,self.n_CurrentUser,false);--msg.dwTimerLeftMS
	self:setTimeToEveryone(msg.dwTimerLeftMS,5);
	for k,v in pairs(msg.bInsureCard) do
		if v == 1 then
			self:removeTimeToWhichOne(k-1);
		end
	end
	
	--恢复牌对象的牌数据
	for k,v in pairs(self.pokerListBoard) do
		local lSeatNo = self.tableLogic:viewToLogicSeatNo(k-1);
		if msg.cbHandCardData[2*(lSeatNo) +2][1] ~= 0 then -- 分过牌
			v:updateHandBreakCard(msg.cbHandCardData[2*(lSeatNo) +1],msg.cbHandCardData[2*(lSeatNo) +2]);
		else
			v:updateHandCard(msg.cbHandCardData[2*(lSeatNo) +1]);
		end
	end

	--设置牌对象是否分过牌
	for k,v in pairs(self.pokerListBoard) do
		v:setSeparate(false);
	end

	--恢复桌面下注
	self:restoreAddScoreNode(msg.lTableScore)

	--显示得分
	self:showPlayGameScore();

	--判断自己有木有参与本局游戏
	luaPrint("判断自己有木有参与本局游戏",msg.bUserStatus[self.tableLogic._mySeatNo+1])
	if msg.bUserStatus[self.tableLogic._mySeatNo+1] == false then
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);
		self:showTiShi(false);
		self.isPlay = false;
		self:addDengDaiAni();
	else
		self.isPlay = true;
		self.m_bGameStart = true;
	end
	self:hideBankMoney(msg.wBankerChair);
	self:updateUserInfo()
	self:updateUserInfoForBankAfter(msg.lTableScore);
end
--恢复桌面下注
function TableLayer:restoreAddScoreNode(lTableScore)
	luaDump(lTableScore,"lTableScore");
	for k,v in pairs(lTableScore) do
		if v>0 then
			self:updataAddScoreNode(k-1,v);
			--显示玩家下注金额
			self:showScoreString(k-1,v);
		end
	end
end

--场景消息 要牌状态
function TableLayer:gameStationGetCard(msg)
	luaPrint("要牌状态");
	self:showGameBegin();

	self.b_isBackGround = true;
	self.m_bGameStart = true;

	self:initPlayScore();

	-- 记录庄家位置
	self.bankSeatNo = msg.wBankerChair;
	--记录玩家是否参与游戏
	self.playerStation = msg.bUserStatus;
	
	--恢复按钮状态
	self:setButtonStation(4,msg);

	self:setMinMax(msg.lCellScore,msg.lMaxScore);
	self:setBanker(msg.wBankerChair);
	self:setTime(msg.dwTimerLeftMS,20,msg.cbCurrentUser,false);--msg.dwTimerLeftMS

	--设置牌对象是否分过牌
	for k,v in pairs(self.pokerListBoard) do
		local lSeatNo = self.tableLogic:viewToLogicSeatNo(k-1);
		if msg.cbHandCardData[2*(lSeatNo) +2][1] ~= 0 then -- 分过牌
			v:setSeparate(true);
		else--没分牌
			v:setSeparate(false);
		end
	end

	--恢复玩家是否停牌
	for k,v in pairs(self.pokerListBoard) do
		local lSeatNo = self.tableLogic:viewToLogicSeatNo(k-1);
		if msg.cbHandCardData[2*(lSeatNo) +2][1] ~= 0 then -- 分过牌
			--分别判断 1,2 滩是否分过牌
			if msg.bStopCard[2*(lSeatNo) +1] == 1 then
				v:setStop1(true);
			else
				v:setStop1(false);
			end
			if msg.bStopCard[2*(lSeatNo) +2] == 1 then
				v:setStop2(true);
			else
				v:setStop2(false);
			end
		else --没有分牌是否停牌
			if msg.bStopCard[2*(lSeatNo) +1] == 1 then
				v:setStop(true);
			else
				v:setStop(false);
			end
		end
	end

	-- for k,v in pairs(self.pokerListBoard) do
	-- 	luaPrint("ppp",v.stop,v.stop1,v.stop2);
	-- end

	--恢复牌对象的牌数据
	for k,v in pairs(self.pokerListBoard) do
		local lSeatNo = self.tableLogic:viewToLogicSeatNo(k-1);
		if msg.cbHandCardData[2*(lSeatNo) +2][1] ~= 0 then -- 分过牌
			v:updateHandBreakCard(msg.cbHandCardData[2*(lSeatNo) +1],msg.cbHandCardData[2*(lSeatNo) +2]);
		else
			v:updateHandCard(msg.cbHandCardData[2*(lSeatNo) +1]);
		end
	end

	self.b_isBackGround = true;

	--恢复桌面下注
	self:restoreAddScoreNode(msg.lTableScore)

	--显示得分
	self:showPlayGameScore();

	--判断自己有木有参与本局游戏
	luaPrint("判断自己有木有参与本局游戏",msg.bUserStatus[self.tableLogic._mySeatNo+1])
	if msg.bUserStatus[self.tableLogic._mySeatNo+1] == false then
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);
		self:showTiShi(false);
		self.isPlay = false;
		self:addDengDaiAni();
	else
		self.isPlay = true;
		self.m_bGameStart = true;
	end

	self:showKuang(msg.cbCurrentUser);
	self:hideBankMoney(msg.wBankerChair);
	self:updateUserInfo()
	self:updateUserInfoForBankAfter(msg.lTableScore);

end

--设置按钮的状态 station:1,2,3,4分别是 空闲状态 叫分状态 保险状态 要牌状态
function TableLayer:setButtonStation(station,msg)
	if station == nil then
		station = 1;
	end
	if station == 1 then--空闲状态

	elseif station == 2 then--叫分状态
		self.Image_buttonBG:setVisible(true);
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);
	elseif station == 3 then--保险状态
		self.Image_buttonBG:setVisible(false);
		self:setHideAllButton(true);
		--self.Button_baoxian:setEnabled(true);
		self:setEnabledAllButton(false);

		if msg.bInsureCard[2*self.tableLogic._mySeatNo +1] == 0 or msg.bInsureCard[2*self.tableLogic._mySeatNo +1] == 255 then
			self.Button_baoxian:setEnabled(true);
			self:showTiShi(true);
		elseif msg.bInsureCard[2*self.tableLogic._mySeatNo +1] == 1 then
			self.Button_baoxian:setEnabled(false);
		end

	elseif station == 4 then--要牌状态
		self.Image_buttonBG:setVisible(false);
		self:setHideAllButton(true);
		self:setEnabledAllButton(false);

		if  msg.cbCurrentUser ~= self.tableLogic._mySeatNo then --当前操作用户不是自己按钮全部不可操作
			return;
		end
		
		--先判断有没有分牌
		if msg.cbHandCardData[2*self.tableLogic._mySeatNo +2][1] == 0 then -- 没有分过牌
			luaPrint("未分牌");
			--只有二张的时候可以加倍，并且自己没有加倍过
			if msg.cbCardCount[2*self.tableLogic._mySeatNo +1] == 2 and msg.bDoubleCard[2*self.tableLogic._mySeatNo +1] == 0 then
				self.Button_fanbei:setEnabled(true);
			else
				self.Button_fanbei:setEnabled(false);
			end
			--如果自己的牌是2张并且是对子的话可以分牌
			if msg.cbCardCount[2*self.tableLogic._mySeatNo +1] == 2  and 
				GetCardValue(msg.cbHandCardData[2*self.tableLogic._mySeatNo+1][1]) == GetCardValue(msg.cbHandCardData[2*self.tableLogic._mySeatNo+1][2]) then
					self.Button_fenpai:setEnabled(true);
			else
				self.Button_fenpai:setEnabled(false);
			end

			-- --判断自己有没有翻过倍并且牌张数是2张 第一滩
			-- if msg.bDoubleCard[2*self.tableLogic._mySeatNo +1] == 0 and msg.cbCardCount[2*self.tableLogic._mySeatNo +1] == 2 then
			-- 	self.Button_fanbei:setEnabled(true);
			-- else
			-- 	self.Button_fanbei:setEnabled(false);
			-- end

		else--分过牌
			luaPrint("分牌了");
			if msg.bStopCard[2*self.tableLogic._mySeatNo +1] == 0 and msg.cbCardCount[2*self.tableLogic._mySeatNo +1] == 2 then
				self.Button_fanbei:setEnabled(true);
			elseif msg.bStopCard[2*self.tableLogic._mySeatNo +2] == 0 and msg.cbCardCount[2*self.tableLogic._mySeatNo +2] == 2 then 
				self.Button_fanbei:setEnabled(true);
			end

		end

		--判断自己是否停牌了
		if msg.bStopCard[2*self.tableLogic._mySeatNo +1] == 0 then
			self.Button_jiaopai:setEnabled(true);
			self.Button_tingpai:setEnabled(true);
		else
			if msg.bStopCard[2*self.tableLogic._mySeatNo +2] == 0 and msg.cbHandCardData[2*self.tableLogic._mySeatNo +2][1] ~= 0 then
				self.Button_jiaopai:setEnabled(true);
				self.Button_tingpai:setEnabled(true);
			end
		end


	end

end

--设置最小最大分数
function TableLayer:setMinMax(minScore,maxScore)
	self.AtlasLabel_min:setString((minScore/100));
	self.AtlasLabel_max:setString((maxScore/100));
	self.minScore = minScore;
	self.maxScore = maxScore;
	self.m_addMoney = minScore;
	self.m_playerMoney = maxScore;
end

--去除动画
function TableLayer:clearAni(str)
	local node;
	node = self:getChildByName(str);
	if node then
		node:removeFromParent();
	end
end

--特效
function TableLayer:addAnimation(_type,pos)
	--self:clearAni();
	local size = cc.Director:getInstance():getWinSize();
	if pos == nil then
		pos = cc.p(size.width/2,size.height/2);
	end

	if _type == 1 then
		luaPrint("爆了");
		local skeleton_animation = createSkeletonAnimation("baole","ershiyidian/animate/baole/baole.json", "ershiyidian/animate/baole/baole.atlas");
	    if skeleton_animation then
		    skeleton_animation:setPosition(pos)
		    skeleton_animation:setAnimation(0,"baole", false);
		    self.Node_ani:addChild(skeleton_animation,10000);
		    skeleton_animation:setName("baole");
		end
	    
	elseif _type == 2 then
		luaPrint("黑杰克");
		local skeleton_animation = createSkeletonAnimation("blackjack","ershiyidian/animate/blackjack/blackjack.json", "ershiyidian/animate/blackjack/blackjack.atlas");
	    if skeleton_animation then
		    skeleton_animation:setPosition(pos)
		    skeleton_animation:setAnimation(0,"blackjack", false);
		    self.Node_ani:addChild(skeleton_animation,10000);
		    skeleton_animation:setName("blackjack");
		end
    elseif _type == 3 then
		luaPrint("输");
		local skeleton_animation = createSkeletonAnimation("shuying","ershiyidian/animate/shuying/shuying.json", "animate/shuying/shuying.atlas");
	    if skeleton_animation then
		    skeleton_animation:setPosition(pos)
		    skeleton_animation:setAnimation(0,"shu", false);
		    self.Node_ani:addChild(skeleton_animation,10000);
		    skeleton_animation:setName("shu");
		    skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ( ... )
		    	skeleton_animation:removeFromParent();
		    end)));
		end
	elseif _type == 4 then
		luaPrint("赢");
		local skeleton_animation = createSkeletonAnimation("shuying","ershiyidian/animate/shuying/shuying.json", "animate/shuying/shuying.atlas");
	    if skeleton_animation then
		    skeleton_animation:setPosition(pos)
		    skeleton_animation:setAnimation(0,"ying", false);
		    self.Node_ani:addChild(skeleton_animation,10000);
		    skeleton_animation:setName("ying");
		    skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ( ... )
		    	skeleton_animation:removeFromParent();
		    end)));
		end
	end
end

--设置玩家状态
function TableLayer:setPlayerStation(lSeatNo,station)
	if station<0 or station>6 then
		luaPrint("setPlayerStation REEOR!",lSeatNo,station);
		return;
	end
	-- if lSeatNo == 4 then
	-- 	luaPrint("庄家操作不显示");
	-- 	return;
	-- end
	local vSeatNo = self.tableLogic:logicToViewSeatNo(lSeatNo);
	self.playerNodeInfo[vSeatNo+1]:setStation(station);
end

--添加音效 
function TableLayer:addEffectSound(n_type,lSeatNo)
	luaPrint("addEffectSound");
	if lSeatNo<0 or lSeatNo>4 then
		return;
	end
	local userInfo = nil;

	if lSeatNo then
		userInfo = self.tableLogic:getUserBySeatNo(lSeatNo);
		luaDump(userInfo,"addEffectSound");
	end
	local str = "ershiyidian/sound/";
	local sex = "_boy";--_boy
	if userInfo then
		luaPrint("getUserSex",getUserSex(userInfo.bLogoID,userInfo.bBoy));
		if not getUserSex(userInfo.bLogoID,userInfo.bBoy) then
			sex = "_girl";
		end
	end
	if n_type == 1 then --保险
		str = str.."insure"
	elseif n_type == 2 then--加倍
		str = str.."double"
	elseif n_type == 3 then--分牌
		--str = ""
		return;
	elseif n_type == 4 then--叫牌
		str = str.."get_card"
	elseif n_type == 5 then--停牌
		str = str.."stop_card"
	elseif n_type == 6 then-- 爆牌
		str = str.."burst"
	elseif n_type == 7 then-- 黑杰克
		str = str.."bj"
	elseif n_type == 8 then-- 21点
		--str = str.."game21"
		return;--21点音效不要了
	end
	str = str..sex;
	str = str..".wav";
	luaPrint("str",n_type,str);
	self:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime),cc.CallFunc:create(function ( ... )
		-- body
		audio.playSound(str,false);
	end)));
end

--添加等待动画
function TableLayer:addDengDaiAni()
	self:removeDengDaiAni();
	local size = cc.Director:getInstance():getWinSize();
	
	local pos = cc.p(640,210);--size.width/2,size.height/3
	
	local skeleton_animation = createSkeletonAnimation("dengdai","game/dengdai/dengdai.json", "game/dengdai/dengdai.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"dengxiaju", true);
	    self.Node_ani:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("dengdai");
	end
end

--移除等待动画
function TableLayer:removeDengDaiAni()
	local node = nil;
	node = self.Node_ani:getChildByName("dengdai");
	while node do
		node:removeFromParent();
		node = nil;
		node = self.Node_ani:getChildByName("dengdai");
	end
end

--添加等待动画
function TableLayer:addDengQiTaUser()
	self:removeDengQiTaUser();
	local size = cc.Director:getInstance():getWinSize();
	
	local pos = cc.p(640,210);
	
	local skeleton_animation = createSkeletonAnimation("dengdai","game/dengdai/dengdai.json", "game/dengdai/dengdai.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"dengwanjia", true);
	    self.Node_ani:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("dengdai");
	end
end

--移除等待动画
function TableLayer:removeDengQiTaUser()
	local node = nil;
	node = self.Node_ani:getChildByName("dengdai");
	while node do
		node:removeFromParent();
		node = nil;
		node = self.Node_ani:getChildByName("dengdai");
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

--添加游戏即将开始动画
function TableLayer:addGameJiJiangKaiShi()
	self:removeGameJiJiangKaiShi();
	local endlayer = self:getChildByName("EndLayer");
	if endlayer then
		return;
	end
	local size = cc.Director:getInstance():getWinSize();
	--if pos == nil then
	local pos = cc.p(1559/2,360);
	--end
	local skeleton_animation = createSkeletonAnimation("jijiangkaishi","game/jijiangkaishi.json", "game/jijiangkaishi.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"5s", false);
	    self.Panel_end:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("jijiangkaishi");
	end
end

--移除游戏即将开始动画
function TableLayer:removeGameJiJiangKaiShi()
	local node = nil;
	node = self.Panel_end:getChildByName("jijiangkaishi");
	while(node) do
		luaPrint("移除即将开始");
		node:removeFromParent();
		node = nil;
		node = self.Panel_end:getChildByName("jijiangkaishi");
	end
end

--查询自己是否参与游戏
function TableLayer:isPlayGame()
	if #self.playerStation == 0 then
		luaPrint("各玩家状态出错");
		return false;
	end
	local realSeatNo = self.tableLogic._mySeatNo;
	return self.playerStation[realSeatNo+1];
end

-- function TableLayer:gameBuymoney(msg)
-- 	if msg.UserID == PlatformLogic.loginResult.dwUserID then
-- 		self.m_selfMoney = self.m_selfMoney + msg.OperatScore;
-- 		local userInfo = self.tableLogic:getUserBySeatNo(self.tableLogic:getMySeatNo());
-- 		local viewSeat = self.tableLogic:logicToViewSeatNo(self.tableLogic:getMySeatNo());
-- 		self.playerNodeInfo[viewSeat+1]:setUserMoney(self.m_selfMoney);
-- 	end
-- end

function TableLayer:gameBuymoney(msg)
	if msg.UserID == PlatformLogic.loginResult.dwUserID then
		local viewSeat = self.tableLogic:logicToViewSeatNo(self.tableLogic:getMySeatNo());
		self.playerScore[viewSeat+1] = self.playerScore[viewSeat+1] + msg.OperatScore;
		self.playerNodeInfo[viewSeat+1]:setUserMoney(self.playerScore[viewSeat+1]);
	end
end

--显示玩家下注之后 再充值 自己的金额 isTrue 全部刷新
function TableLayer:showMoneyAddMoneyAfter(msg,isTrue)
	if isTrue == false then
		local userId = msg.UserID 
		local realSeatNo = self.tableLogic:getlSeatNo(userId);
		local viewSeat = self.tableLogic:logicToViewSeatNo(realSeatNo);

		local userInfo = self.tableLogic:getUserBySeatNo(realSeatNo);
		if userInfo then
			self.playerNodeInfo[viewSeat+1]:setUserMoney(userInfo.i64Money - self.addScoreTable[viewSeat+1]);
		end
	else
		for k=1,PLAY_COUNT do
			local viewSeat = self.tableLogic:logicToViewSeatNo(k-1);
			local userInfo = self.tableLogic:getUserBySeatNo(k-1);
			if userInfo then
				self.playerNodeInfo[viewSeat+1]:setUserMoney(userInfo.i64Money - self.addScoreTable[viewSeat+1]);
			end
		end
	end

end

--添加游戏开始动画
function TableLayer:addGameStartAni()
	if self.b_isBackGround == false then
		return;
	end
	self:removeGameStartAni();
	local size = cc.Director:getInstance():getWinSize();
	
	local pos = cc.p(640,360);--size.width/2,size.height/3
	audio.playSound("ershiyidian/sound/StartGamewomen.mp3");
	local skeleton_animation = createSkeletonAnimation("21diankaishi","animate/gameStart/21diankaishi.json", "animate/gameStart/21diankaishi.atlas");
    if skeleton_animation then
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"21diankaishi", false);
	    self.Node_ani:addChild(skeleton_animation,10000);
	    skeleton_animation:setName("21diankaishi");
	    -- skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function ( ... )
		   --  	skeleton_animation:removeFromParent();
		   --  end)));
	end
end

--移除游戏开始动画
function TableLayer:removeGameStartAni()
	local node = nil;
	node = self.Node_ani:getChildByName("21diankaishi");
	while(node) do
		luaPrint("移除开始动画");
		node:removeFromParent();
		node = nil;
		node = self.Panel_end:getChildByName("21diankaishi");
	end
end

--移除音效
function TableLayer:removeTimeSound()
	for k,v in pairs(self.playerNodeInfo) do
		v:removeSoundAni();
	end
end


return TableLayer;
