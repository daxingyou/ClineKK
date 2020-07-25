
local TableLayer =  class("TableLayer", BaseWindow)

local TableLogic = require("qiangzhuangniuniu.TableLogic");
local ChipNodeManager = require("qiangzhuangniuniu.ChipNodeManager");
local HelpLayer = require("qiangzhuangniuniu.HelpLayer");
local PokerListBoard = require("qiangzhuangniuniu.PokerListBoard");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");
local RubbingCards = require("qiangzhuangniuniu.RubbingCards");
local MiCards = require("qiangzhuangniuniu.MiCards");

function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene("QznnScene");

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
	QznnInfo:init();
	
	local uiTable = {
		Image_bg = "Image_bg",
		Button_exit = "Button_exit",
		Image_shizhong = "Image_shizhong",
		AtlasLabel_time = "AtlasLabel_time",
		Button_qiang1 = "Button_qiang1",
		Button_qiang2 = "Button_qiang2",
		Button_qiang3 = "Button_qiang3",
		Button_qiang4 = "Button_qiang4",
		Button_xiazhu1 = "Button_xiazhu1",
		Button_xiazhu2 = "Button_xiazhu2",
		Button_xiazhu3 = "Button_xiazhu3",
		Button_xiazhu4 = "Button_xiazhu4",
		Button_guize = "Button_guize",
		Button_tanpai = "Button_tanpai",
		Image_pai1 = "Image_pai1",
		Image_pai2 = "Image_pai2",
		Image_pai3 = "Image_pai3",
		Image_pai4 = "Image_pai4",
		Image_pai5 = "Image_pai5",
		Image_jisuan = "Image_jisuan",
		AtlasLabel_num1 = "AtlasLabel_num1",
		AtlasLabel_num2 = "AtlasLabel_num2",
		AtlasLabel_num3 = "AtlasLabel_num3",
		AtlasLabel_num4 = "AtlasLabel_num4",
		AtlasLabel_difen = "AtlasLabel_difen",
		Node_player1 = "Node_player1",
		Node_player2 = "Node_player2",
		Node_player3 = "Node_player3",
		Node_player4 = "Node_player4",
		Node_player5 = "Node_player5",
		Image_head1 = "Image_head1",
		Image_head2 = "Image_head2",
		Image_head3 = "Image_head3",
		Image_head4 = "Image_head4",
		Image_head5 = "Image_head5",
		Image_quan1 = "Image_quan1",
		Image_quan2 = "Image_quan2",
		Image_quan3 = "Image_quan3",
		Image_quan4 = "Image_quan4",
		Image_quan5 = "Image_quan5",
		Text_name1 = "Text_name1",
		Text_name2 = "Text_name2",
		Text_name3 = "Text_name3",
		Text_name4 = "Text_name4",
		Text_name5 = "Text_name5",
		Text_jinbi1 = "Text_jinbi1",
		Text_jinbi2 = "Text_jinbi2",
		Text_jinbi3 = "Text_jinbi3",
		Text_jinbi4 = "Text_jinbi4",
		Text_jinbi5 = "Text_jinbi5",
		Image_zhuang1 = "Image_zhuang1",
		Image_zhuang2 = "Image_zhuang2",
		Image_zhuang3 = "Image_zhuang3",
		Image_zhuang4 = "Image_zhuang4",
		Image_zhuang5 = "Image_zhuang5",
		Image_tip1 = "Image_tip1",
		Image_tip2 = "Image_tip2",
		Image_tip3 = "Image_tip3",
		Image_tip4 = "Image_tip4",
		Image_tip5 = "Image_tip5",
		Image_buqiang1 = "Image_buqiang1",
		Image_buqiang2 = "Image_buqiang2",
		Image_buqiang3 = "Image_buqiang3",
		Image_buqiang4 = "Image_buqiang4",
		Image_buqiang5 = "Image_buqiang5",
		Node_qiang1 = "Node_qiang1",
		Node_qiang2 = "Node_qiang2",
		Node_qiang3 = "Node_qiang3",
		Node_qiang4 = "Node_qiang4",
		Node_qiang5 = "Node_qiang5",
		AtlasLabel_qiangbeishu1 = "AtlasLabel_qiangbeishu1",
		AtlasLabel_qiangbeishu2 = "AtlasLabel_qiangbeishu2",
		AtlasLabel_qiangbeishu3 = "AtlasLabel_qiangbeishu3",
		AtlasLabel_qiangbeishu4 = "AtlasLabel_qiangbeishu4",
		AtlasLabel_qiangbeishu5 = "AtlasLabel_qiangbeishu5",
		AtlasLabel_beishu1 = "AtlasLabel_beishu1",
		AtlasLabel_beishu2 = "AtlasLabel_beishu2",
		AtlasLabel_beishu3 = "AtlasLabel_beishu3",
		AtlasLabel_beishu4 = "AtlasLabel_beishu4",
		AtlasLabel_beishu5 = "AtlasLabel_beishu5",
		Node_qiangzhuang = "Node_qiangzhuang",
		Node_xiazhu = "Node_xiazhu",
		Button_zhunbei = "Button_zhunbei",
		Image_zhunbei1 = "Image_zhunbei1",
		Image_zhunbei2 = "Image_zhunbei2",
		Image_zhunbei3 = "Image_zhunbei3",
		Image_zhunbei4 = "Image_zhunbei4",
		Image_zhunbei5 = "Image_zhunbei5",
		AtlasLabel_changefen1 = "AtlasLabel_changefen1",
		AtlasLabel_changefen2 = "AtlasLabel_changefen2",
		AtlasLabel_changefen3 = "AtlasLabel_changefen3",
		AtlasLabel_changefen4 = "AtlasLabel_changefen4",
		AtlasLabel_changefen5 = "AtlasLabel_changefen5",
		Button_more = "Button_more",
		Node_more = "Node_more",
		Button_hidemore = "Button_hidemore",
		Button_yinyue = "Button_yinyue",
		Button_yinxiao = "Button_yinxiao",
		Image_dengdai = "Image_dengdai",
		Node_gold = "Node_gold",
		Node_zuo = {"Node_zuo",0,1},
		Node_you = {"Node_you",1},
		Image_more = "Image_more",
	}

	self:initData();

	loadNewCsb(self,"csbs/qznnTableLayer",uiTable)

	_instance = self;

	for i=1,4 do
		local key = "Button_qiang"..i;
    	table.insert(self.Button_qiang, self[key]);
    	local key1 = "Button_xiazhu"..i;
    	table.insert(self.Button_xiazhu, self[key1]);
    	local key2 = "AtlasLabel_num"..i;
    	table.insert(self.AtlasLabel_num, self[key2]);	
    		
	end
	for i=1,5 do
		local key = "Image_pai"..i;
    	table.insert(self.Image_pai, self[key]);
    	local key1 = "Image_zhunbei"..i;
    	table.insert(self.Image_zhunbei, self[key1]);
    	local key2 = "AtlasLabel_changefen"..i;
    	table.insert(self.AtlasLabel_changefen, self[key2]);
    	local key3 = "Node_player"..i;
    	table.insert(self.Node_player, self[key3]);	
    	local key4 = "Image_head"..i;
    	table.insert(self.Image_head, self[key4]);	
    	local key5 = "Image_quan"..i;
    	table.insert(self.Image_quan, self[key5]);	
    	local key6 = "Text_name"..i;
    	table.insert(self.Text_name, self[key6]);	
    	local key7 = "Text_jinbi"..i;
    	table.insert(self.Text_jinbi, self[key7]);	
    	local key8 = "Image_zhuang"..i;
    	table.insert(self.Image_zhuang, self[key8]);	
    	local key9 = "Image_tip"..i;
    	table.insert(self.Image_tip, self[key9]);	
    	local key10 = "Image_buqiang"..i;
    	table.insert(self.Image_buqiang, self[key10]);	
    	local key11 = "Node_qiang"..i;
    	table.insert(self.Node_qiang, self[key11]);	
    	local key12 = "AtlasLabel_qiangbeishu"..i;
    	table.insert(self.AtlasLabel_qiangbeishu, self[key12]);	
    	local key13 = "AtlasLabel_beishu"..i;
    	table.insert(self.AtlasLabel_beishu, self[key13]);	
	end

end


function TableLayer:initData()
	--游戏是否开始
	self.m_bGameStart = false;	
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;
	self.Button_qiang = {};				--抢庄倍数
	self.Button_xiazhu = {};			--闲家倍数
	self.Image_pai = {};				--牌
	self.pokerListBoard = {};			--牌列表
	self.AtlasLabel_num = {};			--计算牛牛
	self.Node_player = {};				--玩家
	self.Image_head = {};				--头像
	self.Image_quan = {};				--光圈
	self.Text_name = {};				--昵称
	self.Text_jinbi = {};				--金币
	self.Image_zhuang = {};				--庄标识
	self.Image_tip = {};				--抢庄，不抢，闲倍数 状态
	self.Image_buqiang = {};			--不抢
	self.Node_qiang = {};				--抢
	self.AtlasLabel_qiangbeishu = {}; 	--抢倍数
	self.AtlasLabel_beishu = {}; 		--闲倍数
	self.Image_zhunbei = {};  			--准备
	self.AtlasLabel_changefen ={}; 		--改变分数
	self.playerInfo = {};
	self.zhuangBeishu ={-1,-1,-1,-1,-1};	--抢庄倍数
	self.pangguan = {0,0,0,0,0}; 			--旁观状态
	self.isPlaying = false;
	self.cointable = {};
end

--创建扑克牌
function TableLayer:createPokers()
	self.pokerListBoard = {};

	for i=1,5 do
		-- local k = i -1;
		-- luaPrint("tempPokerList---- k = "..k)
		local tempPokerList = PokerListBoard.new(i,self);
		tempPokerList:setVisible(true);
		-- tempPokerList:setLocalZOrder(1000)
		self.Image_bg:addChild(tempPokerList);
		
		table.insert(self.pokerListBoard, tempPokerList);
	end

	local data = {1,2,3,4,5}
	self.rubbingCards = RubbingCards.new(self);
	-- self.rubbingCards:createHandPoker(data)
	self:addChild(self.rubbingCards,1000);

	self.miCards = MiCards.new(self);
	-- self.miCards:createHandPoker(data)
	self:addChild(self.miCards,1000);
	
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
	display.removeSpriteFrames("qiangzhuangniuniu/qiangzhuangniuniu.plist","qiangzhuangniuniu/qiangzhuangniuniu.png")
	display.removeSpriteFrames("qiangzhuangniuniu/card.plist","qiangzhuangniuniu/card.png")
end

function TableLayer:bindEvent()
	
	self:pushEventInfo(QznnInfo, "gameStartInfo", handler(self, self.receiveGameStartInfo))        		--游戏开始
	self:pushEventInfo(QznnInfo, "addScoreInfo", handler(self, self.receiveAddScoreInfo))          		--下注
	self:pushEventInfo(QznnInfo, "sendCardInfo", handler(self, self.receiveSendCardInfo))  				--发牌
	self:pushEventInfo(QznnInfo, "gameEndInfo", handler(self, self.receiveGameEndInfo))        			--游戏结束
	self:pushEventInfo(QznnInfo, "openCardInfo", handler(self, self.receiveOpenCardInfo))           	--摊牌
	self:pushEventInfo(QznnInfo, "callBankerInfo", handler(self, self.receiveCallBankerInfo)) 			--叫庄
	self:pushEventInfo(QznnInfo, "beginCallInfo", handler(self, self.receiveBeginCallInfo)) 			--开始叫庄
	self:pushEventInfo(QznnInfo, "watcherSitInfo", handler(self, self.receiveWatcherSitInfo)) 			--旁观
	self:pushEventInfo(QznnInfo, "userCutInfo", handler(self, self.receiveUserCutInfo))               	--断线

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
end


function TableLayer:initUI()

	self:createPokers();
	
	--基本按钮
	self:initGameNormalBtn();

	self:initMusic();

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	
end

function TableLayer:initMusic()
	
	display.loadSpriteFrames("qiangzhuangniuniu/qiangzhuangniuniu.plist", "qiangzhuangniuniu/qiangzhuangniuniu.png");

	if not getEffectIsPlay() then
		self.Button_yinxiao:loadTextures("yinxiaox.png","yinxiaox-on.png","yinxiaox-on.png",UI_TEX_TYPE_PLIST)
        self.Button_yinxiao:setTag(1);	
	end
	if not getMusicIsPlay() then
		self.Button_yinyue:loadTextures("yinyuex.png","yinyuex-on.png","yinyuex-on.png",UI_TEX_TYPE_PLIST)
        self.Button_yinyue:setTag(1);	
    else
    	--背景音乐
		audio.playMusic("sound/NiuBgm.mp3", true);
	end

	
	
end



--游戏基本按钮设置
function TableLayer:initGameNormalBtn()
	--退出游戏
	if self.Button_exit then
		self.Button_exit:onClick(handler(self,self.onClickExitGameCallBack));
		-- self.Button_exit:addClickEventListener(function()  self:onClickExitGameCallBack();  end)
	end

	if self.Button_guize then 
		self.Button_guize:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_guize:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end

	if self.Button_tanpai then
		self.Button_tanpai:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_tanpai:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end
	
	if self.Button_zhunbei then
		self.Button_zhunbei:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_zhunbei:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end

	if self.Button_more then
		self.Button_more:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_more:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end

	if self.Button_hidemore then
		self.Button_hidemore:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_hidemore:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end

	if self.Button_yinyue then
		self.Button_yinyue:setTag(0);
		self.Button_yinyue:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_yinyue:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end

	if self.Button_yinxiao then
		self.Button_yinxiao:setTag(0);
		self.Button_yinxiao:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_yinxiao:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end

	

	for i=1,4 do
		self.Button_qiang[i]:setTag(i);
		self.Button_qiang[i]:onClick(handler(self,self.onClickQiangCallBack));
		-- self.Button_qiang[i]:addClickEventListener(function(sender)  self:onClickQiangCallBack(sender); end)
		self.Button_xiazhu[i]:setTag(i);
		self.Button_xiazhu[i]:onClick(handler(self,self.onClickXiazhuCallBack));
		-- self.Button_xiazhu[i]:addClickEventListener(function(sender)  self:onClickXiazhuCallBack(sender); end)
	end

	self.AtlasLabel_difen:setString("");
	self.Image_shizhong:setPositionY(400)
	self.Node_gold:setLocalZOrder(10000)
	self.Node_you:setLocalZOrder(100)
	self.Node_more:setLocalZOrder(100)

	local winSize = cc.Director:getInstance():getWinSize()

	local btn = ccui.Button:create("guize/jixuyouxi.png","guize/jixuyouxi-on.png")
    btn:setPosition(winSize.width*0.5,winSize.height*0.35)
    self:addChild(btn)
    btn:onClick(handler(self,self.onClickBtnCallBack))
    btn:setName("Button_jixu")
    btn:setVisible(false)
    self.Button_jixu = btn;

    local btn1 = ccui.Button:create("guize/likaifangjian.png","guize/likaifangjian-on.png")
    btn1:setPosition(winSize.width*0.6,winSize.height*0.35)
    self:addChild(btn1)
    btn1:onClick(handler(self,self.onClickBtnCallBack))
    btn1:setName("Button_likai")
    btn1:setVisible(false)
    self.Button_likai = btn1;

    self.Button_tanpai:setPosition(winSize.width/2+220,self.Button_qiang[3]:getPositionY())
    local btn1 = ccui.Button:create("guize/cuopai.png","guize/cuopai-on.png")
    btn1:setPosition(winSize.width/2,self.Button_qiang[2]:getPositionY())
    self:addChild(btn1)
    btn1:onClick(handler(self,self.onClickBtnCallBack))
    btn1:setName("Button_cuopai")
    self.Button_cuopai = btn1;

    local btn1 = ccui.Button:create("guize/mipai.png","guize/mipai-on.png")
    btn1:setPosition(winSize.width/2-220,self.Button_qiang[2]:getPositionY())
    self:addChild(btn1)
    btn1:onClick(handler(self,self.onClickBtnCallBack))
    btn1:setName("Button_mipai")
    self.Button_mipai = btn1;

	self.old_shizhongPos = cc.p(self.Image_shizhong:getPosition()) 
	self.new_shizhongPos = cc.p(winSize.width/2-540,180) 

	self:clearDesk();
	-- self.Button_zhunbei:setVisible(true);
	--区块链bar
	self.m_qklBar = Bar:create("qiangzhuangniuniu",self);
	self.Button_more:addChild(self.m_qklBar);
	self.Button_more:setPositionX(self.Button_more:getPositionX()-10);
	self.m_qklBar:setPosition(cc.p(35,-80));

	if globalUnit.isShowZJ then
		self.m_logBar = LogBar:create(self);
		self.Button_more:addChild(self.m_logBar);
	end

	if globalUnit.isShowZJ then
		self.Button_more:loadTextures("qiangzhuangniuniu/zhanji/gengduo-niuniu.png","qiangzhuangniuniu/zhanji/gengduo-niuniu-on.png")
		self.Image_more:loadTexture("qiangzhuangniuniu/zhanji/xialadiban.png")
		self.Image_more:setContentSize(cc.size(96,234))
		self.Image_more:setPositionY(self.Image_more:getPositionY()-30)

		local btn = ccui.Button:create("qiangzhuangniuniu/zhanji/zhanji.png","qiangzhuangniuniu/zhanji/zhanji-on.png");
		btn:setPosition(self.Button_yinxiao:getPosition());
		self.Image_more:addChild(btn);
		btn:setName("Button_zhanji")
		btn:onClick(handler(self,self.onClickBtnCallBack));

		self.Button_yinyue:setPositionY(self.Button_yinyue:getPositionY()+65)
		self.Button_yinxiao:setPositionY(self.Button_yinxiao:getPositionY()+70)
		
	end

end

function TableLayer:onClickQiangCallBack(sender)
	local tag = sender:getTag();
	local num = {0,1,2,4}
	QznnInfo:sendQiangzhuang(num[tag]);
	-- self.Node_qiangzhuang:setVisible(false);
	self.isOperate = true;
end

function TableLayer:onClickXiazhuCallBack(sender)
	local tag = sender:getTag();
	local num = {5,10,15,20}
	QznnInfo:sendXianBeishu(num[tag]);
	-- self.Node_xiazhu:setVisible(false);
	self.isOperate = true;
end


function TableLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
    local tag = sender:getTag();
    local userDefault = cc.UserDefault:getInstance();
    display.loadSpriteFrames("qiangzhuangniuniu/qiangzhuangniuniu.plist", "qiangzhuangniuniu/qiangzhuangniuniu.png");
    luaPrint("11111111111111111")
    if name == "Button_bank" then

    elseif name == "Button_guize" then
    	local layer = HelpLayer:create();
    	self:addChild(layer,10);
    elseif name == "Button_more" then
    	self.Node_more:setVisible(true);
    elseif name == "Button_hidemore" then
    	self.Node_more:setVisible(false);
    elseif name == "Button_yinyue" then
    	setMusicIsPlay(not getMusicIsPlay())
    	if tag == 1 then
        	self.Button_yinyue:loadTextures("yinyue.png","yinyue-on.png","yinyuex-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yinyue:setTag(0);
        	--背景音乐
			audio.playMusic("sound/NiuBgm.mp3", true);
        elseif tag == 0 then
        	self.Button_yinyue:loadTextures("yinyuex.png","yinyuex-on.png","yinyuex-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yinyue:setTag(1);
        end
         
    elseif name == "Button_yinxiao" then
    	if tag == 1 then
        	self.Button_yinxiao:loadTextures("yinxiao.png","yinxiao-on.png","yinxiao-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yinxiao:setTag(0);
        elseif tag == 0 then
        	self.Button_yinxiao:loadTextures("yinxiaox.png","yinxiaox-on.png","yinxiaox-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yinxiao:setTag(1);
        end
        setEffectIsPlay(not getEffectIsPlay());
    elseif name == "Button_tanpai" then
    	if self.pokerListBoard[1].handCard and #self.pokerListBoard[1].handCard == 5 then
	    	local num = qqnnGetCardType(self.pokerListBoard[1].handCard,5)
	    	QznnInfo:sendTanpai(num);
	    	self.rubbingCards:clearData()
	    	self.miCards:clearData()
	    	self.isOperate = true;
	    else
	    	self:hideAllButton()
	    end
    elseif name == "Button_zhunbei" then
    	QznnInfo:sendMsgReady();
    	self.Button_zhunbei:setVisible(false);
    elseif name == "Button_jixu" then
    	--self.tableLogic:sendMsgReady()
    	--self.Button_jixu:setVisible(false);
    	--self.Button_likai:setVisible(false);
    	self.tableLogic:sendUserUp();
        self.tableLogic:sendForceQuit();

        UserInfoModule:clear();
        local score =  goldReconvert(tonumber(self.Text_jinbi[1]:getString()))
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

        local qiangzhuangniuniu = require("qiangzhuangniuniu");
        qiangzhuangniuniu.reStart = true;
        UserInfoModule:clear();

        Hall:exitGame(1,function()
            self:leaveDesk(1);
            qiangzhuangniuniu:ReSetTableLayer(score,self.difen);
        end);
    elseif name == "Button_likai" then
    	self:onClickExitGameCallBack()
    elseif name == "Button_zhanji" then
    	if self.m_logBar then
			self.m_logBar:CreateLog();
		end
	elseif name == "Button_cuopai" then
		self:hideAllButton()
		self.rubbingCards:createHandPoker(self.cards)
		self.Image_shizhong:setPosition(self.new_shizhongPos)
		QznnInfo:sendQiangzhuang(0);
		self.isOperate = true;
	elseif name == "Button_mipai" then
		self:hideAllButton()
		self.miCards:createHandPoker(self.cards)
		self.Image_shizhong:setPosition(self.new_shizhongPos)
		QznnInfo:sendQiangzhuang(0);
		self.isOperate = true;
    end
end

function TableLayer:hideAllButton()
	self.Button_tanpai:setVisible(false);
	self.Button_cuopai:setVisible(false);
	self.Button_mipai:setVisible(false);
end

--退出
function TableLayer:onClickExitGameCallBack(isRemove)
	luaPrint("TableLayer:onClickExitGameCallBack玩家退出")
	local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	    self:leaveDesk();
	end
	-- if self.isClick == true then
 --        return;
 --    end
    
 --    if self.isPlaying ~= true then
 --    	self.isClick = true;
	-- end

	if isRemove ~= nil and type(isRemove) == "number" then
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

		if source == nil then
			if globalUnit.nowTingId == 0 then
				RoomLogic:close();
			end
		end

		self._bLeaveDesk = true;
		_instance = nil;
	end
end

-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	self:clearDesk();
end

 -- //清理桌面
function TableLayer:clearDesk()
	--准备
	for k,v in pairs(self.Image_zhunbei) do
		v:setVisible(false);
	end
	--抢倍数
	for k,v in pairs(self.Node_qiang) do
		v:setVisible(false);
	end
	--不抢
	for k,v in pairs(self.Image_buqiang) do
		v:setVisible(false);
	end
	--闲倍数
	for k,v in pairs(self.AtlasLabel_beishu) do
		v:setString("");
	end
	--抢，不抢，倍数，提示
	for k,v in pairs(self.Image_tip) do
		v:setVisible(false);
	end
	--改变分
	for k,v in pairs(self.AtlasLabel_changefen) do
		v:setString("")
	end
	--庄
	for k,v in pairs(self.Image_zhuang) do
		v:setVisible(false);
	end
	--光圈
	for k,v in pairs(self.Image_quan) do
		v:setVisible(false);
	end
	--手牌
	for k,v in pairs(self.pokerListBoard) do
		v:clearData();
	end
	--牛几牌型计算器
	for k,v in pairs(self.AtlasLabel_num) do
		self.AtlasLabel_num[k]:setString("");
	end
	self.Button_zhunbei:setVisible(false);
	self.Image_dengdai:setVisible(false);
	self.Button_tanpai:setVisible(false);
	self.Button_cuopai:setVisible(false);
	self.Button_mipai:setVisible(false);
	self.Image_jisuan:setVisible(false);
	self.Image_shizhong:setVisible(false);
	self.Node_qiangzhuang:setVisible(false);
	self.Node_xiazhu:setVisible(false);
	if self.ziSpine then
		self.ziSpine:setVisible(false);
	end
	if self.winSpine then
		self.winSpine:removeFromParent();
		self.winSpine = nil;
	end
	if self.willStartSpine then
		self.willStartSpine:removeFromParent();
		self.willStartSpine = nil;
	end
	if self.startSpine then
		self.startSpine:removeFromParent();
		self.startSpine = nil;
	end
	if self.zhuangSpine then
		self.zhuangSpine:removeFromParent();
		self.zhuangSpine = nil;
	end
	if #self.cointable > 0 then
		for k,v in pairs(self.cointable) do
			if v and not tolua.isnull(v) then
				v:stopAllActions();
				v:removeFromParent();
			end
		end
		self.cointable = {};
	end
	self.Button_jixu:setVisible(false);
	self.Button_likai:setVisible(false)
	self.rubbingCards:clearData()
	self.miCards:clearData()
	self.Image_shizhong:setPosition(self.old_shizhongPos)
	if self.shengAction then
		self.shengAction:removeFromParent();
		self.shengAction = nil
	end
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
	
	self.isOperate = false;
	
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
		if self.daojishi == 1 and self.Button_tanpai:isVisible() then
			if self.cuocard then
				self.rubbingCards:showAction();
			elseif self.micard then
				self.miCards:showAction();
			end
		end
		if self.daojishi <= 3 and self.daojishi >0 and self.isOperate ~= true then
			audio.playSound("sound/daojishi.mp3",false);
		end
	else
		self:stopTimer();
		self.AtlasLabel_time:setString("0")
		self.Image_shizhong:setVisible(false);
	end
end

function TableLayer:receiveBeginCallInfo(data)
	local data = data._usedata;
	if self.AtlasLabel_difen then
		self.AtlasLabel_difen:setString(gameRealMoney(data.iBasePoint));
		self.difen = gameRealMoney(data.iBasePoint)
		-- addScrollMessage("底分"..data.iBasePoint)
	end
	if self.m_bGameStart ~= true then
		return;
	end
	self:clearDesk();
	self.isPlaying = true;
	luaDump(data,"gamestart")
	if self.Image_dengdai:isVisible() then
		self.pangguan[self.tableLogic._mySeatNo +1] = 1;
	end
	
	self.zhuangBeishu ={-1,-1,-1,-1,-1};
	self.pangguan = {0,0,0,0,0};
	
	audio.playSound("sound/game_start.mp3",false);
	local winSize = cc.Director:getInstance():getWinSize()
	
	local kaishi = createSkeletonAnimation("kaishiyouxi","texiao/kaishiyouxi/kaishiyouxi.json","texiao/kaishiyouxi/kaishiyouxi.atlas");
	if kaishi then
		kaishi:setPosition(winSize.width/2,winSize.height/2);
		kaishi:setAnimation(1,"kaishiyouxi", false);
		self:addChild(kaishi,2);
	end
	self.startSpine = kaishi;
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() 
		if self.startSpine then
			self.startSpine:removeFromParent();
			self.startSpine = nil;
		end

		self:setWaitTime(5);
		self.Node_qiangzhuang:setVisible(true);
		self:playZitiEffect(3);
	end)))
	
end


function TableLayer:receiveGameStartInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	self.Node_qiangzhuang:setVisible(false);
	if self.ziSpine then
		self.ziSpine:setVisible(false);
	end
	local data = data._usedata;
	luaDump(data,"gamestart")
	if not self:isValidSeat(data.wBankerUser) then 
		return;
	end
	if self.Image_dengdai:isVisible() then
		self.pangguan[self.tableLogic._mySeatNo +1] = 1;
	end
	self.isningBei = false;
	local seat = self.tableLogic:logicToViewSeatNo(data.wBankerUser);
	if self.zhuangBeishu[seat+1] == 0 then
		self.isningBei = true;
	end
	local sameSeat = {}
	local count,zcount = 0;
	for k,v in pairs(self.zhuangBeishu) do
		if self.zhuangBeishu[seat +1] == v then
			table.insert(sameSeat,k);
			count = count +1;
			if k == seat +1 then
				zcount = count;
			end
		end
	end
	local num = #sameSeat;
	luaPrint("num= "..num )
	if num > 1 then
		local zongCount = 3 * num + zcount;
		self.times = 0;
		for i=1,zongCount do
			self:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*0.1),cc.CallFunc:create(function() 
				self.times = self.times + 1;
				audio.playSound("sound/random_banker.mp3",false);
				local x1 = self.times%num
				local x2 = (self.times-1)%num;
				if x1 == 0 then
					x1 = num;
				end
				if x2 == 0 then
					x2 = num;
				end
				self.Image_quan[sameSeat[x1]]:setVisible(true);
				self.Image_quan[sameSeat[x2]]:setVisible(false);
				luaPrint("self.times ="..self.times.." zongCount="..zongCount)
				if self.times == zongCount then
					self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
						self:showZhuang(data.wBankerUser);
					end)))
				end
			end)))
		end
	else
		self:showZhuang(data.wBankerUser);
	end
	
	
end

function TableLayer:showZhuang(seatNo)
	local winSize = cc.Director:getInstance():getWinSize()

	audio.playSound("sound/set_banker.mp3",false);
	local seat = self.tableLogic:logicToViewSeatNo(seatNo);
	display.loadSpriteFrames("qiangzhuangniuniu/qiangzhuangniuniu.plist", "qiangzhuangniuniu/qiangzhuangniuniu.png");
	local zhuang = ccui.ImageView:create();
    zhuang:loadTexture("zhuang1.png",UI_TEX_TYPE_PLIST);
    zhuang:setPosition(cc.p(640,360));
    self.Node_gold:addChild(zhuang);
    
    local x,y = self.Image_zhuang[seat+1]:getPosition();
    self.zhuangSeat = seat + 1;
    self.zhuangSpine = zhuang;
    zhuang:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(1,cc.p(x,y)),cc.ScaleTo:create(1,0.2)),
			cc.CallFunc:create(function() 
				if self.zhuangSpine then
					self.zhuangSpine:removeFromParent();
				end
				self.zhuangSpine = nil;
				self.Image_zhuang[seat+1]:setVisible(true);
				if seatNo == self.tableLogic._mySeatNo then
					self:playZitiEffect(1);
				else
					if self.pangguan[self.tableLogic._mySeatNo + 1] ~= 1 then
						self.Node_xiazhu:setVisible(true);
						self:playZitiEffect(5);
					end
					
					audio.playSound("sound/xz_start.mp3",false);
				end
				self:setWaitTime(8)
				if self.isningBei then
					self.Image_buqiang[seat+1]:setVisible(false);
					self.Node_qiang[seat+1]:setVisible(true);
					self.AtlasLabel_qiangbeishu[seat+1]:setString(":;1");

				end
				for k,v in pairs(self.Image_quan) do
					v:setVisible(false);
				end
			end)))
end

function TableLayer:receiveAddScoreInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"addscore")
	if not self:isValidSeat(data.wAddScoreUser) then 
		return;
	end
	local seat = self.tableLogic:logicToViewSeatNo(data.wAddScoreUser);
	luaPrint("seat== "..seat)
	self.Image_tip[seat+1]:setVisible(true);
	self.Node_qiang[seat+1]:setVisible(false);
	self.Image_buqiang[seat+1]:setVisible(false);
	self.AtlasLabel_beishu[seat+1]:setString(":;"..data.lAddScoreCount)

	if data.wAddScoreUser == self.tableLogic._mySeatNo then  --是自己
		self.Node_xiazhu:setVisible(false);
		if self.ziSpine then
			self.ziSpine:setVisible(false);
		end
	end
end

function TableLayer:receiveSendCardInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"sendcard")
	self.Node_xiazhu:setVisible(false);
	if self.ziSpine then
		self.ziSpine:setVisible(false);
	end
	if self.Image_dengdai:isVisible() then
		self.pangguan[self.tableLogic._mySeatNo +1] = 1;
	end
			
	for i=1,5 do
		if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
			local seat = self.tableLogic:logicToViewSeatNo(i-1);
			luaPrint("seat== "..seat)
			
			self.pokerListBoard[seat+1]:createHandPoker(data.cbCardData);
			self.cards = data.cbCardData;
		end
	end
	self:showUserHandCardTip();
	self:setWaitTime(10)
end

-- 显示玩家手牌计算器
function TableLayer:showUserHandCardTip()
	if self.pangguan[self.tableLogic._mySeatNo + 1] ~= 1 then
		self.Button_tanpai:setVisible(true);
		self.Button_cuopai:setVisible(true);
		self.Button_mipai:setVisible(true);
		-- self.Image_jisuan:setVisible(true);
		self.Node_xiazhu:setVisible(false);
		self.Node_qiangzhuang:setVisible(false);
		self:playZitiEffect(4);
	end
	for k,v in pairs(self.AtlasLabel_num) do
		self.AtlasLabel_num[k]:setString("");
	end
end

function TableLayer:receiveGameEndInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	self.Image_shizhong:setPosition(self.old_shizhongPos)
	self.rubbingCards:clearData()
	self.miCards:clearData()
	self.isPlaying = false;
	local data = data._usedata;
	luaDump(data,"gameend")
	data.bAutoGiveUp = true
	self.cointable = {};
	self.Image_shizhong:setVisible(false);
	self:stopTimer();
	for i=1,5 do
		if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
			local seat = self.tableLogic:logicToViewSeatNo(i-1);
			luaPrint("seat== "..seat)
			local str = ""
			if data.lGameScore[i] >= 0 then
				str = "+"..gameRealMoney(data.lGameScore[i]);
				if seat +1 ~= self.zhuangSeat then
					for j=1,5 do
						self:runAction(cc.Sequence:create(cc.DelayTime:create((j-1)*0.1),cc.CallFunc:create(function() 
						local coin = ChipNodeManager.new(self);
						coin:ChipCreate(self.zhuangSeat,seat +1,data.lGameScore[i]);
						table.insert(self.cointable,coin);
						end)))
					end
					audio.playSound("sound/fly_gold.mp3",false);
				end
				self.AtlasLabel_changefen[seat+1]:setProperty(str,"number/jiesuanzitiao1.png", 26, 50, '+');
			else
				str = gameRealMoney(data.lGameScore[i]);
				if seat +1 ~= self.zhuangSeat then
					for j=1,5 do
						self:runAction(cc.Sequence:create(cc.DelayTime:create((j-1)*0.1),cc.CallFunc:create(function() 
						local coin = ChipNodeManager.new(self);
						coin:ChipCreate(seat +1,self.zhuangSeat,data.lGameScore[i]);
						table.insert(self.cointable,coin);
						end)))
					end
					
					audio.playSound("sound/fly_gold.mp3",false);
				end
				self.AtlasLabel_changefen[seat+1]:setProperty(str,"number/jiesuanzitiao2.png", 26, 50, '+');
			end
			-- self.AtlasLabel_changefen[seat+1]:setString(str);

			--刷新金币
			self:setUserMoney(data.i64Money[i],seat+1)
		end		
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),
				cc.CallFunc:create(function() 
					-- for k,v in pairs(self.cointable) do
					-- 	luaPrint(k,v)
					-- end
					self.cointable = {};
				end)))

	local niuSpine = nil;
	self.winSpine = nil;
	local winSize = cc.Director:getInstance():getWinSize()
	
	if self.pangguan[self.tableLogic._mySeatNo + 1] ~= 1 then
		if data.lGameScore[self.tableLogic._mySeatNo+1] >= 0  then
				niuSpine = createSkeletonAnimation("shengli","texiao/shengli/shengli.json","texiao/shengli/shengli.atlas");
				if niuSpine then
					niuSpine:setPosition(640,360);
					niuSpine:setAnimation(1,"shengli", false);
					self.Node_gold:addChild(niuSpine,2);
				end
				if qqnnGetCardType(self.pokerListBoard[1].handCard,5)>=10 then
					audio.playSound("sound/bigMoney.mp3",false);
				else
					audio.playSound("sound/win.mp3",false);
				end
		else
				niuSpine = createSkeletonAnimation("shibai","texiao/shibai/shibai.json","texiao/shibai/shibai.atlas");
				if niuSpine then
					niuSpine:setPosition(640,360);
					niuSpine:setAnimation(1,"shibai", false);
					self.Node_gold:addChild(niuSpine,2);
				end
				audio.playSound("sound/lose.mp3",false);
		end
		self.winSpine = niuSpine;
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2),
				cc.CallFunc:create(function() 
					if self.winSpine then
						self.winSpine:removeFromParent();
						self.winSpine = nil;
					end
					-- self:clearDesk();
					--self:playWillStart();
					if data.bAutoGiveUp == true then
						self.Button_jixu:setVisible(true)
						self.Button_likai:setVisible(false)

						self:setWaitTime(10)

						performWithDelay(self,
							function()
								self:onClickExitGameCallBack()
								addScrollMessage("结算阶段未操作，自动离开房间")
							end,10)
					end
					--显示准备
					-- self.Button_zhunbei:setVisible(true);
					-- QznnInfo:sendMsgReady();
					
				end)))
	else     --旁观
		self:runAction(cc.Sequence:create(cc.DelayTime:create(2),
			cc.CallFunc:create(function() 
				-- self.Button_zhunbei:setVisible(true);
				-- QznnInfo:sendMsgReady();
				-- self.Image_dengdai:setVisible(false);
				-- self:clearDesk();
				self:playWillStart();
		end)))
	end

	--播放连胜特效
	if data.nWinTime > 2 then
		local winTime = data.nWinTime;
		self:showLiansheng(winTime)
	end
end

function TableLayer:showLiansheng(winTime)
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

			shengAction:setPosition(bgSize.width/2,bgSize.height/2-200);
			shengAction:setAnimation(1,"l"..winTime, false);
			shengAction:setName("liansheng");
			self.Image_bg:addChild(shengAction);
			self.shengAction = shengAction;
		end

		audio.playSound("hall/game/gameEffect/liansheng.mp3");
	end),cc.DelayTime:create(2),cc.CallFunc:create(function()
		local shengAction = self.Image_bg:getChildByName("liansheng");
		if shengAction then
			shengAction:removeFromParent();
			self.shengAction = nil
		end
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
	local count = self:getDeskRenshu();

	if count <= 1 then
		self:clearDesk();
		QznnInfo:sendMsgReady();
		self:playZitiEffect(2)
		return;
	end
	local winSize = cc.Director:getInstance():getWinSize()

	local jijiangkaishi = createSkeletonAnimation("jijiangkaishi","game/jijiangkaishi.json","game/jijiangkaishi.atlas");
	if jijiangkaishi then
		jijiangkaishi:setPosition(winSize.width/2,winSize.height/2);
		jijiangkaishi:setAnimation(1,"3s", false);
		self:addChild(jijiangkaishi,2);
	end
	self.willStartSpine = jijiangkaishi;
	self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() 
		if self.willStartSpine then
			self.willStartSpine:removeFromParent();
		end
		self.willStartSpine = nil;
		-- self:clearDesk();
		QznnInfo:sendMsgReady();
		local count = self:getDeskRenshu();

		if count <= 1 then
			self:clearDesk();
			self:playZitiEffect(2)
			return;
		end
	end)))
	-- for i=1,3 do
	-- 	self:runAction(cc.Sequence:create(cc.DelayTime:create(i-1),cc.CallFunc:create(function()
	-- 		audio.playSound("sound/daojishi.mp3",false);
	-- 	end))) 
	-- end
end


function TableLayer:receiveOpenCardInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	self.Node_xiazhu:setVisible(false);
	local data = data._usedata;
	luaDump(data,"opencard")
	if not self:isValidSeat(data.wPlayerID) then 
		return;
	end
	if data.wPlayerID == self.tableLogic._mySeatNo then
		self.Button_tanpai:setVisible(false);
		self.Button_cuopai:setVisible(false);
		self.Button_mipai:setVisible(false);
		self.Image_jisuan:setVisible(false);
		if self.ziSpine then
			self.ziSpine:setVisible(false);
		end
	end
	
	local seat = self.tableLogic:logicToViewSeatNo(data.wPlayerID);
	luaPrint("seat=== "..seat)
	self.pokerListBoard[seat + 1]:createnewCard(data.cbCardData);
end


function TableLayer:receiveCallBankerInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	luaDump(data,"jiaozhuang")
	if not self:isValidSeat(data.wCallBanker) then 
		return;
	end
	

	local seat = self.tableLogic:logicToViewSeatNo(data.wCallBanker);
	luaPrint("seat=== "..seat)
	self.Image_tip[seat+1]:setVisible(true);
	if data.bBankRat > 0 then
		self.Node_qiang[seat+1]:setVisible(true);
		self.AtlasLabel_qiangbeishu[seat+1]:setString(":;"..data.bBankRat)
		local userinfo = self.tableLogic:getUserBySeatNo(data.wCallBanker);
		local str = "";
		if userinfo then
			if getUserSex(userinfo.bLogoID,userinfo.bBoy) == true then
				str = "sound/qiangzhuang_nan.mp3"
			else
				str = "sound/qiangzhuang_nv.mp3"
			end
		end
		audio.playSound(str,false);
	else
		self.Image_buqiang[seat+1]:setVisible(true);
	end
	self.zhuangBeishu[seat +1] = data.bBankRat;

	if data.wCallBanker == self.tableLogic._mySeatNo then  --是自己
 		self.Node_qiangzhuang:setVisible(false);
 		if self.ziSpine then
			self.ziSpine:setVisible(false);
		end
 	end

 	local isAllCalled = true;
 	for i=1,5 do
 		if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
 			local seat = self.tableLogic:logicToViewSeatNo(i-1);
 			if self.zhuangBeishu[seat +1] == -1 then
 				isAllCalled = false;
 			end
 		end
 	end
 	if isAllCalled then
 		self.Image_shizhong:setVisible(false);
 		self:stopTimer();
 	end
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

	self.pangguan[data.wChairID + 1] = 1;
	
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

--刚进入游戏游戏状态
function TableLayer:showGameStatus(data,status)
	self:stopAllActions();
	self:clearDesk();
	self.pangguan = {0,0,0,0,0}; 			--旁观状态
	self.zhuangBeishu ={-1,-1,-1,-1,-1};	--抢庄倍数
	if status == GameMsg.GS_TK_FREE then
		local data = convertToLua(data,GameMsg.CMD_S_StatusFree);
		luaDump(data,"GS_TK_FREE")
		--旁观
		for i=1,5 do
			if data.bWatcher[i] then
				self.pangguan[i] = 1;
			end
		end
		self.AtlasLabel_difen:setString(gameRealMoney(data.bCellScore));
		QznnInfo:sendMsgReady();
	elseif status == GameMsg.GS_TK_CALL then
		self.isPlaying = true;
		local data = convertToLua(data,GameMsg.CMD_S_StatusCall);
		luaDump(data,"GS_TK_CALL")
		if data.iTime > 5 then
			data.iTime = 5;
		end
		self:setWaitTime(data.iTime);
		--旁观
		for i=1,5 do
			if data.bWatcher[i] then
				self.pangguan[i] = 1;
			end
		end
		self.AtlasLabel_difen:setString(gameRealMoney(data.bCellScore));
		for i=1,5 do
			if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
				local seat = self.tableLogic:logicToViewSeatNo(i-1)
				luaPrint("seat= "..seat);
				if data.bCallStatus[i] == 1 then
					self.Image_tip[seat+1]:setVisible(true);
					if data.bCallBank[i] > 0 then
						self.Node_qiang[seat+1]:setVisible(true);
						self.AtlasLabel_qiangbeishu[seat+1]:setString(":;"..data.bCallBank[i])
					else
						self.Image_buqiang[seat+1]:setVisible(true);
					end
					self.zhuangBeishu[seat +1] = data.bCallBank[i];
				else
 					if i-1 == self.tableLogic._mySeatNo then  --是自己
 						self.Node_qiangzhuang:setVisible(true);
 						self:playZitiEffect(3);
 					end
				end
			end
		end
	elseif status == GameMsg.GS_TK_SCORE then
		self.isPlaying = true;
		local data = convertToLua(data,GameMsg.CMD_S_StatusScore);
		luaDump(data,"GS_TK_SCORE")
		if data.iTime > 8 then
			data.iTime = 8;
		end
		self:setWaitTime(data.iTime);
		--旁观
		for i=1,5 do
			if data.bWatcher[i] then
				self.pangguan[i] = 1;
			end
		end
		self.AtlasLabel_difen:setString(gameRealMoney(data.bCellScore));
		local zseat = self.tableLogic:logicToViewSeatNo(data.wBankerUser)
		self.Image_zhuang[zseat+1]:setVisible(true);
		self.Image_tip[zseat+1]:setVisible(true);
		self.Node_qiang[zseat+1]:setVisible(true);
		if data.bCallBank == 0 then
			data.bCallBank = 1;
		end
		self.AtlasLabel_qiangbeishu[zseat+1]:setString(":;"..data.bCallBank)
		self.zhuangSeat = zseat + 1;
		if data.wBankerUser == self.tableLogic._mySeatNo then
			self:playZitiEffect(1);
		end
		for i=1,5 do
			if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
				if data.wBankerUser ~= i-1 then
					local seat = self.tableLogic:logicToViewSeatNo(i-1)
					luaPrint("seat= "..seat);
					if data.lTableScore[i] > 0 then
						self.Image_tip[seat+1]:setVisible(true);
						self.AtlasLabel_beishu[seat+1]:setString(":;"..data.lTableScore[i]);
					else
						if i-1 == self.tableLogic._mySeatNo then  --是自己
 							self.Node_xiazhu:setVisible(true);
 							self:playZitiEffect(5);
 						end
					end
				end
			end
		end
	elseif status == GameMsg.GS_TK_PLAYING then
		self.isPlaying = true;
		local data = convertToLua(data,GameMsg.CMD_S_StatusPlay);
		luaDump(data,"GS_TK_PLAYING")
		if data.iTime > 10 then
			data.iTime = 10;
		end
		self:setWaitTime(data.iTime);
		--旁观
		for i=1,5 do
			if data.bWatcher[i] then
				self.pangguan[i] = 1;
			end
		end
		self.AtlasLabel_difen:setString(gameRealMoney(data.bCellScore));
		--庄倍数
		local zseat = self.tableLogic:logicToViewSeatNo(data.wBankerUser);
		self.Image_zhuang[zseat+1]:setVisible(true);
		self.Image_tip[zseat+1]:setVisible(true);
		self.Node_qiang[zseat+1]:setVisible(true);
		if data.bCallBank == 0 then
			data.bCallBank = 1;
		end
		self.AtlasLabel_qiangbeishu[zseat+1]:setString(":;"..data.bCallBank);
		self.zhuangSeat = zseat + 1;
		--闲倍数
		for i=1,5 do
			if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
				if data.wBankerUser ~= i-1 then
					local seat = self.tableLogic:logicToViewSeatNo(i-1)
					luaPrint("seat= "..seat);
					if data.lTableScore[i] > 0 then
						self.Image_tip[seat+1]:setVisible(true);
						self.AtlasLabel_beishu[seat+1]:setString(":;"..data.lTableScore[i]);
					end
				end
			end
		end
		--牌
		for i=1,5 do
			if self.tableLogic._existPlayer[i] and self.pangguan[i]~=1 then
				local seat = self.tableLogic:logicToViewSeatNo(i-1)
				luaPrint("seat1= "..seat);
				if data.bOxCard[i] == 255 then --未摊牌
					if i-1 == self.tableLogic._mySeatNo and data.cbHandCardData[i][1] > 0 then  --是自己
 						-- self.Image_jisuan:setVisible(true);
 						self.Button_tanpai:setVisible(true)
 						self.Button_cuopai:setVisible(true);
 						self.Button_mipai:setVisible(true);
 						self:playZitiEffect(4);
 					end 
 					self.pokerListBoard[seat + 1]:createHandPoker(data.cbHandCardData[i]);
 					self.cards = data.cbHandCardData[i]
				else
					self.pokerListBoard[seat + 1]:createnewCard(data.cbHandCardData[i])
				end
			end
		end
	end
	if self.pangguan[self.tableLogic._mySeatNo +1] == 1 then  --是自己
		self.Image_dengdai:setVisible(true);
		self.isPlaying = false;
	else
		self.Image_dengdai:setVisible(false);
	end
	local count = self:getDeskRenshu();
	if count == 1 then
		self:playZitiEffect(2);
	elseif status == GameMsg.GS_TK_FREE then
		self.Image_dengdai:setVisible(true);
	end

	for i=1,5 do
		local seat = self.tableLogic:logicToViewSeatNo(i-1);
		local userInfo = self.tableLogic:getUserBySeatNo(i-1);
		if userInfo then
			self.Text_jinbi[seat+1]:setString(gameRealMoney(userInfo.i64Money));
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
	luaPrint("addPlayer(userInfo) -------------------"..deskStation)
	
	if userInfo then
		-- luaDump(userInfo,"userInfo")
		self.Node_player[deskStation+1]:setVisible(true)
		self.Text_name[deskStation+1]:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
		self.Text_name[deskStation+1]:setFontSize(22)
		self.Text_jinbi[deskStation+1]:setString(gameRealMoney(userInfo.i64Money))
		
		self.Image_head[deskStation+1]:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
		self.Image_head[deskStation+1]:setScale(1.1);
		if userInfo.bUserState == 2 then
			if bSeatNo == self.tableLogic._mySeatNo then
				-- self.Button_zhunbei:setVisible(true);
				self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
					QznnInfo:sendMsgReady();
				end)))
				
			end
		elseif userInfo.bUserState == 3 then   --同意
			-- self.Image_zhunbei[deskStation+1]:setVisible(true);
		else
			-- self.Button_zhunbei:setVisible(false);
		end
	end
	local count = self:getDeskRenshu();
	if count == 1 then
		self:playZitiEffect(2);
	elseif count == 2 then
		if self.ziSpine then
			self.ziSpine:setVisible(false);
		end
	end
	
end

function TableLayer:removeUser(deskStation, bMe,bLock)
	if not self:isValidSeat(deskStation) then 
		return;
	end

	luaPrint("bLock="..bLock)
	if bMe then
		-- self:leaveDesk();
		-- Hall:exitGame();
		local time = 2.5
		local str = ""
		if bLock == 0 then
			-- str ="长时间未操作,自动退出游戏。"
		elseif bLock == 1 then
			str ="您的金币不足,自动退出游戏。"
			self:playMiaoshaEffect()
			audio.playSound("sound/noGold.mp3",false);
		elseif bLock == 2 then
			str ="您被厅主踢出VIP厅,自动退出游戏。"
		elseif bLock == 3 then
			str ="长时间未操作,自动退出游戏。"
			time = 0;
		elseif bLock == 5 then
			str ="VIP房间已关闭,自动退出游戏。"
		end

		self.Button_exit:setTouchEnabled(false);
		self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
			self.Button_exit:setTouchEnabled(true);
			if str ~="" then
				addScrollMessage(str)
			end
			self:onClickExitGameCallBack(5);
		end)))
		return;
	end

	self.Node_player[deskStation+1]:setVisible(false);
	-- local count = self:getDeskRenshu();
	-- if count == 1 then
	-- 	self:clearDesk();
	-- 	self:playZitiEffect(2);
	-- end
end


function TableLayer:setUserMoney(money,seat)
	luaPrint("money= "..money.." seat= "..seat)
	self.Text_jinbi[seat]:setString(gameRealMoney(money))
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
	local winSize = cc.Director:getInstance():getWinSize()
	
	if self.ziSpine then
		self.ziSpine:setVisible(true);
		self.ziSpine:clearTracks();
		self.ziSpine:setAnimation(1,tipzi[iType], false);
	else
		self.ziSpine = createSkeletonAnimation("tishizi","texiao/tishizi/tishizi.json","texiao/tishizi/tishizi.atlas");
		if self.ziSpine then
			self.ziSpine:setPosition(winSize.width/2,winSize.height*0.45);
			self.ziSpine:setAnimation(1,tipzi[iType], false);
			self:addChild(self.ziSpine,2);
		end
	end
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
		return;
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

--秒杀
function TableLayer:playMiaoshaEffect()
	local tipzi = {"miaosha_qiangzhuang"}
	local iType = 1;
	local winSize = cc.Director:getInstance():getWinSize()
	
	if self.MXSpine then
		self.MXSpine:setVisible(true);
		self.MXSpine:clearTracks();
		self.MXSpine:setAnimation(1,tipzi[iType], false);
	else
		self.MXSpine = createSkeletonAnimation("miaosha","texiao/miaosha/miaosha.json","texiao/miaosha/miaosha.atlas");
		if self.MXSpine then
			self.MXSpine:setPosition(winSize.width/2,winSize.height*0.45);
			self.MXSpine:setAnimation(1,tipzi[iType], false);
			self:addChild(self.MXSpine,3);
		end
	end
end

return TableLayer;
