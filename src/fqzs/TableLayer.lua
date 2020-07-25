
local TableLayer =  class("TableLayer", BaseWindow)

local TableLogic = require("fqzs.TableLogic");
local ChipNodeManager = require("fqzs.ChipNodeManager");
local HelpLayer = require("fqzs.HelpLayer");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

DongWuBeishu ={8,12,8,6,12,8,8,6,24,100,0,0,0,0}
--//类型0 ~ 14 ,走兽(0-猴子、1-狮子、2-熊猫、3-兔子)、飞禽(4-老鹰、5-孔雀、6-鸽子、7-燕子)、8-银鲨鱼、9-金鲨鱼，10-走兽*2，11-飞禽*2, 12通吃 13通赔, 14 续押
--游戏类
function TableLayer:scene(uNameId, bDeskIndex, bAutoCreate, bMaster)

	local layer = TableLayer:create(uNameId, bDeskIndex, bAutoCreate, bMaster);

	local scene = display.newScene("FqzsScene");

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
	
	self.uNameId = uNameId;
	self.bDeskIndex = bDeskIndex or 0;
	self.bAutoCreate = bAutoCreate or false;
	self.bMaster = bMaster or 0;
	GameMsg.init();
	FqzsInfo:init();

	local uiTable = {
		Image_bg = "Image_bg",
		Button_exit = "Button_exit",
		Button_more = "Button_more",
		Button_other = "Button_other",
		AtlasLabel_othernum = "AtlasLabel_othernum",
		Image_morebg = "Image_morebg",
		Image_other = "Image_other",
		Button_bank = "Button_bank",
		Button_help = "Button_help",
		Button_yinyue = "Button_yinyue",
		Button_yixiao = "Button_yixiao",
		Button_chouma1 = "Button_chouma1",
		Button_chouma2 = "Button_chouma2",
		Button_chouma3 = "Button_chouma3",
		Button_chouma4 = "Button_chouma4",
		Button_chouma5 = "Button_chouma5",
		Button_chouma6 = "Button_chouma6",
		Button_xuya = "Button_xuya",
		Image_di1 = "Image_di1",
		Image_di2 = "Image_di2",
		Image_di3 = "Image_di3",
		Image_di4 = "Image_di4",
		Image_di5 = "Image_di5",
		Image_di6 = "Image_di6",
		Image_di7 = "Image_di7",
		Image_di8 = "Image_di8",
		Image_di9 = "Image_di9",
		Image_di10 = "Image_di10",
		Image_di11 = "Image_di11",
		Image_di12 = "Image_di12",
		Image_di13 = "Image_di13",
		Image_di14 = "Image_di14",
		Image_di15 = "Image_di15",
		Image_di16 = "Image_di16",
		Image_di17 = "Image_di17",
		Image_di18 = "Image_di18",
		Image_di19 = "Image_di19",
		Image_di20 = "Image_di20",
		Image_di21 = "Image_di21",
		Image_di22 = "Image_di22",
		Image_di23 = "Image_di23",
		Image_di24 = "Image_di24",
		Image_di25 = "Image_di25",
		Image_di26 = "Image_di26",
		Image_di27 = "Image_di27",
		Image_di28 = "Image_di28",
		Text_name = "Text_name",
		AtlasLabel_ownJB = "AtlasLabel_ownJB",
		Button_fqzs1 = "Button_fqzs1",
		Button_fqzs2 = "Button_fqzs2",
		Button_fqzs3 = "Button_fqzs3",
		Button_fqzs4 = "Button_fqzs4",
		Button_fqzs5 = "Button_fqzs5",
		Button_fqzs6 = "Button_fqzs6",
		Button_fqzs7 = "Button_fqzs7",
		Button_fqzs8 = "Button_fqzs8",
		Button_fqzs9 = "Button_fqzs9",
		Button_fqzs10 = "Button_fqzs10",
		Button_fqzs11 = "Button_fqzs11",
		Button_fqzs12 = "Button_fqzs12",
		AtlasLabel_myqu1 = "AtlasLabel_myqu1",
		AtlasLabel_myqu2 = "AtlasLabel_myqu2",
		AtlasLabel_myqu3 = "AtlasLabel_myqu3",
		AtlasLabel_myqu4 = "AtlasLabel_myqu4",
		AtlasLabel_myqu5 = "AtlasLabel_myqu5",
		AtlasLabel_myqu6 = "AtlasLabel_myqu6",
		AtlasLabel_myqu7 = "AtlasLabel_myqu7",
		AtlasLabel_myqu8 = "AtlasLabel_myqu8",
		AtlasLabel_myqu9 = "AtlasLabel_myqu9",
		AtlasLabel_myqu10 = "AtlasLabel_myqu10",
		AtlasLabel_myqu11 = "AtlasLabel_myqu11",
		AtlasLabel_myqu12 = "AtlasLabel_myqu12",
		AtlasLabel_qu1 = "AtlasLabel_qu1",
		AtlasLabel_qu2 = "AtlasLabel_qu2",
		AtlasLabel_qu3 = "AtlasLabel_qu3",
		AtlasLabel_qu4 = "AtlasLabel_qu4",
		AtlasLabel_qu5 = "AtlasLabel_qu5",
		AtlasLabel_qu6 = "AtlasLabel_qu6",
		AtlasLabel_qu7 = "AtlasLabel_qu7",
		AtlasLabel_qu8 = "AtlasLabel_qu8",
		AtlasLabel_qu9 = "AtlasLabel_qu9",
		AtlasLabel_qu10 = "AtlasLabel_qu10",
		AtlasLabel_qu11 = "AtlasLabel_qu11",
		AtlasLabel_qu12 = "AtlasLabel_qu12",
		Image_win1 = "Image_win1",
		Image_win2 = "Image_win2",
		Image_win3 = "Image_win3",
		Image_win4 = "Image_win4",
		Image_win5 = "Image_win5",
		Image_win6 = "Image_win6",
		Image_win7 = "Image_win7",
		Image_win8 = "Image_win8",
		Image_win9 = "Image_win9",
		Image_win10 = "Image_win10",
		Image_win11 = "Image_win11",
		Image_win12 = "Image_win12",
		Image_history = "Image_history";
		ListView_dongwu = "ListView_dongwu",
		ListView_other = "ListView_other",
		AtlasLabel_time = "AtlasLabel_time",
		Image_statetip = "Image_statetip",
		Button_zhuang = "Button_zhuang",
		Text_zhuangtip = "Text_zhuangtip",
		Text_zhuangname = "Text_zhuangname",
		AtlasLabel_zhuangmoney = "AtlasLabel_zhuangmoney",
		AtlasLabel_zongxiazhu = "AtlasLabel_zongxiazhu",
		AtlasLabel_me = "AtlasLabel_me",
		AtlasLabel_other = "AtlasLabel_other",
		AtlasLabel_zhuang = "AtlasLabel_zhuang",
		Image_xiazhutipbg = "Image_xiazhutipbg",
		Image_xiazhutip = "Image_xiazhutip",
		Image_zhuanglunhuan = "Image_zhuanglunhuan",
		Image_lianzhuang = "Image_lianzhuang",
		AtlasLabel_zhuangjushu = "AtlasLabel_zhuangjushu",
		Image_dengdaikaishi = "Image_dengdaikaishi";
		Node_mid = "Node_mid",
		Node_di = "Node_di",
		Node_zuo = {"Node_zuo",0,1},
		Node_you = {"Node_you",1},
		Button_hideOther = "Button_hideOther",
		Button_hidemore = "Button_hidemore",
		Node_more = "Node_more",
		Node_other = "Node_other",
		Image_dongwu11 = "Image_dongwu11",
		Image_dongwu25 = "Image_dongwu25",
	}

	self:initData();

	loadNewCsb(self,"fqzs/csbs/fqzsTableLayer",uiTable)

	_instance = self;

	for i=1,28 do
		local key = "Image_di"..i;
    	table.insert(self.Image_di, self[key]);
	end
	for i=1,12 do
		local key = "Button_fqzs"..i;
    	table.insert(self.Button_fqzs, self[key]);
    	local key1 = "AtlasLabel_myqu"..i;
    	table.insert(self.AtlasLabel_myqu, self[key1]);
    	local key2 = "AtlasLabel_qu"..i;
    	table.insert(self.AtlasLabel_qu, self[key2]);
    	local key3 = "Image_win"..i;
    	table.insert(self.Image_win, self[key3]);
    	
	end
	for i=1,6 do
		local key = "Button_chouma"..i;
    	table.insert(self.Button_chouma, self[key]);
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

function TableLayer:onExit()
	self.super.onExit(self);
	display.removeSpriteFrames("fqzs/fqzs.plist","fqzs/fqzs.png")
end

function TableLayer:bindEvent()
	
	self:pushEventInfo(FqzsInfo, "xiazhuResultInfo", handler(self, self.receiveXiazhuResult))        --下注结果
	self:pushEventInfo(FqzsInfo, "gameBeginInfo", handler(self, self.receiveGameBeginInfo))          --游戏开始
	self:pushEventInfo(FqzsInfo, "gameBeginXiazhuInfo", handler(self, self.receiveGameBeginXiazhuInfo))  --开始下注
	self:pushEventInfo(FqzsInfo, "gamePlayGameInfo", handler(self, self.receiveGamePlayGameInfo))        --开始游戏转盘
	self:pushEventInfo(FqzsInfo, "showResultInfo", handler(self, self.receiveShowResultInfo))            --结算
	self:pushEventInfo(FqzsInfo, "shangzhuangResultInfo", handler(self, self.receiveShangzhuangResultInfo))--上下庄结果
	self:pushEventInfo(FqzsInfo, "changeZhuangInfo", handler(self, self.receiveChangeZhuangInfo))       --换庄
	self:pushEventInfo(FqzsInfo, "wuZhuangInfo", handler(self, self.receiveWuZhuangInfo))               --无庄
	self:pushEventInfo(FqzsInfo, "userCutInfo", handler(self, self.receiveUserCutInfo))               --断线
	self:pushEventInfo(FqzsInfo,"ErrorCode",handler(self, self.receiveErrorCode));
	self:pushEventInfo(FqzsInfo,"ZhuangScore",handler(self, self.DealZhuangScore));
	self:pushEventInfo(FqzsInfo,"XiazhuResultXT",handler(self, self.DealXiazhuResultXT));

	

	self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
	self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
end

function TableLayer:playEnterEffect()
	self.Node_mid:setPositionY(400);
	self.Node_di:setPositionY(-100);
	self.Node_you:setPositionX(100);
	self.Node_zuo:setPositionX(-100);
	local move = cc.MoveTo:create(0.2,cc.p(0,0));
	local move1 = cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(0.2,cc.p(0,0)))
	self.Node_mid:runAction(move);
	self.Node_di:runAction(move1);
	self.Node_you:runAction(move1:clone());
	self.Node_zuo:runAction(move1:clone());
end

function TableLayer:initUI()
	
	-- self:initTouchLayer();
	--基本按钮
	self:initGameNormalBtn();
	
	-- self:playEnterEffect();
	
	self:initMusic();

	self.chipNodeManager = ChipNodeManager.new(self);

	-- 游戏内消息处理
	self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

	--桌子号
    local size = self.Image_bg:getContentSize();
    local deskNoBg = ccui.ImageView:create("bg/whichtable.png")
    deskNoBg:setAnchorPoint(0.5,1)
    deskNoBg:setPosition(self.Button_exit:getContentSize().width/2,-3)
    deskNoBg:setScale(0.8)
    self.Button_exit:addChild(deskNoBg)

    local deskNo = FontConfig.createWithCharMap(self.bDeskIndex+1,"fqzs_zhuohao.png",24,32,"0")
    deskNo:setPosition(35,deskNoBg:getContentSize().height/2)
    deskNo:setScale(0.6)
    deskNo:setAnchorPoint(1,0.5)
    deskNoBg:addChild(deskNo)
end

function TableLayer:initMusic()
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");

	if not getEffectIsPlay() then
		self.Button_yixiao:loadTextures("yinxiaox.png","yinxiaox-on.png","yinxiaox-on.png",UI_TEX_TYPE_PLIST)
        self.Button_yixiao:setTag(1);	
	end
	if not getMusicIsPlay() then
		self.Button_yinyue:loadTextures("yinyuex.png","yinyuex-on.png","yinyuex-on.png",UI_TEX_TYPE_PLIST)
        self.Button_yinyue:setTag(1);	
    else
    	audio.playMusic("sound/sound-fly-bg.mp3", true);
	end
	
	
	
end


function TableLayer:initData()	
	--游戏是否开始
	self.m_bGameStart = false;
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;
	self.Image_di = {}; --动物底图
	self.Button_fqzs = {};--押注按钮区
	self.AtlasLabel_myqu = {};  --押注按钮区筹码
	self.AtlasLabel_qu = {};  --押注按钮区筹码
	self.Image_win = {};
	self.Button_chouma = {};--筹码
	self.chouma = 100; --当前下注筹码
	self.ownzongNode = 0;--本局自己下注数量
	self.playerMoney = 0;--自己的钱
	self.myUseNotes = 0; --上一局自己下的总注
	self.t_bankTable = {};
	--不操作的局数
	self.mOperateGameCount = 0;
end

--游戏基本按钮设置
function TableLayer:initGameNormalBtn()

	self.Image_dongwu11:loadTexture("animal8.png",UI_TEX_TYPE_PLIST)
	local dongwu = self.Image_dongwu11:getChildByName("Image_dongwu")
	if dongwu then
		dongwu:loadTexture("animal8.png",UI_TEX_TYPE_PLIST)
	end
	self.Image_dongwu25:loadTexture("animal8.png",UI_TEX_TYPE_PLIST)
	local dongwu = self.Image_dongwu25:getChildByName("Image_dongwu")
	if dongwu then
		dongwu:loadTexture("animal8.png",UI_TEX_TYPE_PLIST)
	end
	--退出游戏
	if self.Button_exit then
		self.Button_exit:onClick(handler(self,self.onClickExitGameCallBack));
		-- self.Button_exit:addClickEventListener(function()  self:onClickExitGameCallBack(); end)
	end
	--更多
	if self.Button_more then
		self.Button_more:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_more:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end
	--保险柜
	if self.Button_bank then
		self.Button_bank:loadTextures("yuerbao.png","yuerbao-on.png")
		self.Button_bank:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_bank:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end
	--规则
	if self.Button_help then
		self.Button_help:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_help:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end
	--音乐
	if self.Button_yinyue then
		self.Button_yinyue:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_yinyue:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
		self.Button_yinyue:setTag(0);
	end
	--音效
	if self.Button_yixiao then
		self.Button_yixiao:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_yixiao:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
		self.Button_yixiao:setTag(0);
	end
	
	--上下庄
	if self.Button_zhuang then
		self.Button_zhuang:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_zhuang:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
		self.Button_zhuang:setTag(0);
		self.Button_zhuang:setPositionY(self.Button_zhuang:getPositionY()+8)
	end

	--其他玩家
	if self.Button_other then
		self.Button_other:onClick(handler(self,self.onClickBtnCallBack));
		-- self.Button_other:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end)
	end
	self.AtlasLabel_othernum:setString(":0;");
	self.Node_zuo:setLocalZOrder(10)
	if self.Button_hidemore then
		self.Button_hidemore:onClick(handler(self,self.onClickBtnCallBack));
	end
	if self.Button_hideOther then
		self.Button_hideOther:onClick(handler(self,self.onClickBtnCallBack));
	end

	self.Text_name:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen));
	-- self.AtlasLabel_ownJB:setString(gameRealMoney(PlatformLogic.loginResult.i64Money));
	self.AtlasLabel_ownJB:setString("");
	-- self.playerMoney = PlatformLogic.loginResult.i64Money;
	for k,v in pairs(self.Button_chouma) do
		v:addClickEventListener(function(sender)  self:onClickChoumaCallBack(sender); end)
		v:setTag(k);
	end
	-- self.Button_chouma[1]:setHighlighted(true);
	-- self.Button_chouma[1]:setScale(1.1)
	self:ChooseChip(1);
	--下注区
	for k,v in pairs(self.Button_fqzs) do
		v:addClickEventListener(function(sender)  self:onClickXiazhuCallBack(sender); end)
		v:setTag(k);
	end
	
	self.Button_xuya:addClickEventListener(function(sender)  self:onClickXiazhuCallBack(sender); end)
	self.Button_xuya:setTag(15);
	self.Button_xuya:setEnabled(false);
	for k,v in pairs(self.AtlasLabel_qu) do
		v:setString("");
	end
	self.AtlasLabel_time:setString("0");--倒计时
	self.Node_more:setVisible(false);
	self.Node_other:setVisible(false);
	self:clearDesk();

	--上庄列表
	self.Text_zhuangtip:setVisible(false);
	local btn1 = ccui.Button:create("bg/banklist.png","bg/banklist-on.png","bg/banklist-on.png")
    btn1:setPosition(self.Text_zhuangtip:getPosition())
    self.Node_di:addChild(btn1,2)
    btn1:setName("Button_zzlb")
    btn1:onClick(function(sender) self:onClickBtnCallBack(sender); end)
    self.Button_bankList = btn1;

    local winSize = cc.Director:getInstance():getWinSize()
    local xtzz = ccui.ImageView:create("bg/xtzz.png")
    xtzz:setPosition(winSize.width*0.5,winSize.height*0.65+6)
    self.Node_di:addChild(xtzz,2)
    xtzz:setPositionX(self.Text_zhuangtip:getPositionX())
    xtzz:setVisible(false)
    self.xtzz = xtzz;

	--区块链bar
	self.m_qklBar = Bar:create("feiqinzoushou",self,0);
	self.Button_exit:addChild(self.m_qklBar);
	self.m_qklBar:setScale(0.8);
	self.Button_exit:setPositionX(self.Button_exit:getPositionX());
	self.m_qklBar:setPosition(cc.p(40,-80));

	if globalUnit.isShowZJ then
		self.m_logBar = LogBar:create(self);
		self.Button_exit:addChild(self.m_logBar);
	end

	if globalUnit.isShowZJ then
		self.Image_morebg:loadTexture("fqzs/zhanji/xialadiban.png")
		self.Image_morebg:setContentSize(cc.size(99,385))
		self.Image_morebg:setPositionY(self.Image_morebg:getPositionY()-30)

		local btn = ccui.Button:create("fqzs/zhanji/zhanji.png","fqzs/zhanji/zhanji-on.png");
		btn:setPosition(self.Button_yixiao:getPosition());
		self.Image_morebg:addChild(btn);
		btn:setName("Button_zhanji")
		btn:onClick(handler(self,self.onClickBtnCallBack));

		self.Button_yinyue:setPositionY(self.Button_yinyue:getPositionY()+75)
		self.Button_yixiao:setPositionY(self.Button_yixiao:getPositionY()+75)
		self.Button_bank:setPositionY(self.Button_bank:getPositionY()+75)
		self.Button_help:setPositionY(self.Button_help:getPositionY()+75)
		
	end
end

function TableLayer:initTouchLayer()
	--触摸层
	local touchLayer = display.newLayer();
	self:addChild(touchLayer);
	touchLayer:setContentSize(cc.Director:getInstance():getWinSize())
	touchLayer:setTouchEnabled(true);
	local function touchCallback(event)
	 		local eventType = event.name;
	 		if eventType == "began" then
	 			if self.Image_other:isVisible() then
	 				local retsize = self.Image_other:getBoundingBox();
	                if not cc.rectContainsPoint(retsize,event) then 
	                	self.Image_other:setVisible(false);
	            	end
	 			end
	 			if self.Image_morebg:isVisible() then
	 				local retsize = self.Image_morebg:getBoundingBox();
	                if not cc.rectContainsPoint(retsize,event) then 
	                	self.Image_morebg:setVisible(false);
	                	-- self.Button_more:setRotation(0);
	            	end
	 			end
			elseif eventType == "moved" then 
			elseif eventType == "ended" then
			elseif eventType == "cancel" then
			end
		end

	touchLayer:onTouch(touchCallback,0, false);
end

function TableLayer:onClickXiazhuCallBack(sender)
	if self.m_bGameStart ~= true then
		return;
	end
	if self.isXiazhutime == false or self.isXiazhutime == nil then
		addScrollMessage("请稍后,还没有到下注时间！");
		return;
	end
	if self.isZhuang == true then
		addScrollMessage("庄家不能下注！")
		return;
	end
	local tag = sender:getTag();
	if self.playerMoney <SettlementInfo:getConfigInfoByID(46) and self.ownzongNode == 0 then
		addScrollMessage("下注失败，您必须有"..(SettlementInfo:getConfigInfoByID(46)/100).."金币才能下注");
		showBuyTip();
		return;
	end
    --发送下注消息
    if tag == 15 then
    	self:dealXuya();
    else
	    FqzsInfo:sendNote(tag-1,self.chouma);
	end
 --    if self.playerMoney and self.playerMoney > self.chouma then
	--     self.Button_xuya:setEnabled(true);
	-- end
end

function TableLayer:onClickChoumaCallBack(sender)
	local tag = sender:getTag();
	-- for k,v in pairs(self.Button_chouma) do
	-- 	-- v:setHighlighted(false);
	-- 	v:setScale(1);
	-- end
	-- self.Button_chouma[tag]:setScale(1.1);
	self:ChooseChip(tag);
	-- self.Button_chouma[tag]:setHighlighted(true);
	if tag == 1 then 
		self.chouma = 100;
	elseif tag == 2 then
		self.chouma = 1000;
	elseif tag == 3 then
		self.chouma = 5000;
	elseif tag == 4 then
		self.chouma = 10000;
	elseif tag == 5 then
		self.chouma = 50000;
	elseif tag == 6 then
		self.chouma = 100000;
	end
end

function TableLayer:bankInfoDeal(data)
	-- luaDump(data,"bankInfoDeal")
	-- if data.ret == 0 then
		self.playerMoney = self.playerMoney + data.OperatScore;
		self:setUserMoney(gameRealMoney(self.playerMoney));
		if self.isZhuang then
			self.AtlasLabel_zhuangmoney:setString(gameRealMoney(self.playerMoney));
		else
			if self.isXiazhutime then
				self:ChipJundge();
				if self.myUseNotes > 0 and self.myUseNotes <= self.playerMoney then
					self.Button_xuya:setEnabled(true);
				else
					self.Button_xuya:setEnabled(false);
				end
			end
		end
		
	-- elseif data.ret == 1 then

	-- end
end

function TableLayer:onClickBtnCallBack(sender)
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
    local name = sender:getName();
    local tag = sender:getTag();
    luaPrint("onClickBtnCallBack"..name)
    if name == "Button_more" then
    	self.Image_morebg:setVisible(true);
    	self.Node_more:setVisible(true);
    	-- self.Button_more:setRotation(180);
    elseif name == "Button_hidemore" then
    	self.Image_morebg:setVisible(false);
    	self.Node_more:setVisible(false);
    elseif name == "Button_hideOther" then
    	self.Image_other:setVisible(false);
    	self.Node_other:setVisible(false);
    elseif name == "Button_bank" then
    		createBank(function(data)
    			self:bankInfoDeal(data);
    		end,self.isXiazhutime)

    elseif name == "Button_help" then
    	local layer = HelpLayer:create();
    	self:addChild(layer,100);
    elseif name == "Button_yinyue" then
    	setMusicIsPlay(not getMusicIsPlay())
    	if tag == 1 then
        	self.Button_yinyue:loadTextures("yinyue.png","yinyue-on.png","yinyuex-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yinyue:setTag(0);
        	audio.playMusic("sound/sound-fly-bg.mp3", true);
        elseif tag == 0 then
        	self.Button_yinyue:loadTextures("yinyuex.png","yinyuex-on.png","yinyuex-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yinyue:setTag(1);
        end
        
    elseif name == "Button_yixiao" then
    	if tag == 1 then
        	self.Button_yixiao:loadTextures("yinxiao.png","yinxiao-on.png","yinxiao-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yixiao:setTag(0);
        elseif tag == 0 then
        	self.Button_yixiao:loadTextures("yinxiaox.png","yinxiaox-on.png","yinxiaox-on.png",UI_TEX_TYPE_PLIST)
        	self.Button_yixiao:setTag(1);
        end
        setEffectIsPlay(not getEffectIsPlay());
    elseif name == "Button_other" then
        self.Image_other:setVisible(true);
        self.Node_other:setVisible(true);
        local others = self:getOthersInfo();
        self:refreshOther(others);
    elseif name == "Button_zhuang" then
  --   	local money = PlatformLogic.loginResult.i64Money;
		-- if money < 10000 then
		-- 	Hall.showTips("金币不足10000，不能上庄");
		-- 	return;
		-- end
		if self.m_bGameStart ~= true then
			return;
		end
    	local isshang = true;
    	local bCancel = false;
        if tag == 0 then --上庄
   --      	if self.minShangzhuang == nil then
			-- 	self.minShangzhuang = 4000000;
			-- end
        	if self.playerMoney < self.minShangzhuang then
        		addScrollMessage("金币不足"..(self.minShangzhuang/100).."，不能上庄");
        		showBuyTip();
        		return;
        	end
        	isshang = true;
        	bCancel = false;
        elseif tag == 1 then --下庄
        	isshang = false;
        	bCancel = false;
        elseif tag == 2 then --取消上庄
        	isshang = true;
        	bCancel = true;
        elseif tag == 3 then --取消下庄
        	isshang = false;
        	bCancel = true;
        end
        FqzsInfo:sendRspZhuang(isshang,bCancel);
    elseif name == "Button_zhanji" then
    	if self.m_logBar then
			self.m_logBar:CreateLog();
		end
	elseif name == "Button_zzlb" then
		self:showAddBankList();
    end
end

--退出
function TableLayer:onClickExitGameCallBack()
	if self.ownzongNode > 0 then
		addScrollMessage("本局游戏您已参与，请等待开奖阶段结束。")
		return;
	end
	if self.isZhuang then
		-- Hall.showTips("您当前是庄家，不能离开")
		addScrollMessage("您当前是庄家，不能离开!")
	else
		self:exitClickCallback();
	end
end

function TableLayer:exitClickCallback()
	luaPrint("TableLayer:onClickExit玩家退出")
	-- if self.isClick == true then
 --        return;
 --    end
    
 --    self.isClick = true;
    local func = function()		
	    self.tableLogic:sendUserUp();
	    self.tableLogic:sendForceQuit();
	end

	Hall:exitGame(false,func)
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



-- 游戏开始转
function TableLayer:startRunRound(iStarPos, iEndPos, iWinnings, iEndAnimal)
	if isHaveBankLayer() then
		createBank(function(data)
    			self:bankInfoDeal(data);
    		end,false)
		-- dispatchEvent("isCanSendGetScore",false)--true 可以取钱，false不可以取钱 游戏中调
		-- addScrollMessage("游戏开奖中，请稍后进行取款操作。")
	end

	self.kaijiangTime = true;
	if (not iStarPos) or (not iEndPos) or iStarPos < 1 or iStarPos > 28 or iEndPos < 1 or iEndPos > 28  then 
		luaPrint("iStarPos="..tostring(iStarPos).." iEndPos="..tostring(iEndPoss))
		return;
	end
	self._startPos = iStarPos;
	self._endPos = iEndPos;
	self._turnCount = 0;
	self._count = self._startPos;
	self._iEndAnimal = iEndAnimal;
	self.startCount = 0;
	self.isRoundFlag =1;
	
	if self._startPos >= self._endPos then
		self.zongCount =28*3+ self._endPos -self._startPos;
		self.MaxTurnCount = 3;
	else
		self.zongCount =28*2+ self._endPos -self._startPos;
		self.MaxTurnCount = 2;
	end
	self:turnRound();
	local x = (self._startPos-3)%28
	if x ==0 then
		x= 28;
	end
	-- self:playKaijiangEffect(x)
end

function TableLayer:turnRound()
	local dTime = 0.03;
	if self._count > 28 then
		self._count = 1;
	 	self._turnCount = self._turnCount + 1;
	end
	
	-- if self._turnCount == 0 and self._count < (self._startPos + 7) then
	-- 	dTime =  (self._startPos + 7 - self._count)/ 10.0;
	-- end
	-- if self._turnCount == 3 and self._count > (self._endPos - 7) then
	-- 	dTime = (self._count + 7 - self._endPos) / 10.0;
	-- end
	-- if (self._turnCount == 3 and self._count > self._endPos) or self._turnCount == 4 then
	-- 	self:endRound();
	--     return;
	-- end
	self.startCount =self.startCount + 1;
	if self.startCount <= 5 then
		dTime = (102 - 20 *self.startCount)/100
	end
	if self.zongCount-self.startCount<= 5 then
		dTime = (102 - 20 *(self.zongCount-self.startCount))/100
	end
	if (self._turnCount == self.MaxTurnCount and self._count > self._endPos) or (self._turnCount == self.MaxTurnCount +1)then
		self:endRound();
	    return;
	end
	
	self.Image_di[1]:runAction(cc.Sequence:create(cc.CallFunc:create(function() 
		if self._count > 1 then
			self.Image_di[self._count-1]:setVisible(false);
		else
			self.Image_di[28]:setVisible(false);
		end
		-- luaPrint("wangkang"..self._count)
		self.Image_di[self._count]:setVisible(true);
		--播放音效
		if self.startCount <= 5 or (self.zongCount-self.startCount<= 5) then
			audio.playSound("sound/sound-fly-turn.mp3",false);
		end
		if dTime == 0.03 and self.startCount%3 == 1 then
			audio.playSound("sound/sound-fly-turn.mp3",false);
		end
		-- if dTime == 0.03 and self.isRoundFlag then
	 --        self:playsoundMusic(self.zongCount-10)
	 --         self.isRoundFlag = nil;
	 --    end
	 	self._count = self._count + 1;
		end),
		cc.DelayTime:create(dTime), 
		cc.CallFunc:create(function() self:turnRound(); end)))
end

function TableLayer:playsoundMusic(timeCounts)
    local count = timeCounts *0.3;
    local times = timeCounts *0.03;
    local dTime = times/count;
    local runSoundCheduler = nil;
    luaPrint("dTime",dTime)
    runSoundCheduler = schedule(self, function() 
        audio.playSound("sound/sound-fly-turn.mp3",false);
        times = times - dTime;
        if times<= 0 then
            self:stopAction(runSoundCheduler)
            runSoundCheduler = nil;
        end
    end, dTime)
end

function TableLayer:endRound()
	self.Image_di[self._endPos]:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5),cc.FadeOut:create(0.5),cc.FadeIn:create(0.5),cc.FadeOut:create(0.5),cc.FadeIn:create(0.5)));
	luaPrint("self._iEndAnimal="..self._iEndAnimal)
	if self._iEndAnimal < 13 then
		
		self.Image_win[self._iEndAnimal]:setVisible(true)
		self.Image_win[self._iEndAnimal]:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5),cc.FadeOut:create(0.5),cc.FadeIn:create(0.5),cc.FadeOut:create(0.5),cc.FadeIn:create(0.5)));
		local othernum = 0
		if self._iEndAnimal <=4 then
			othernum = 11
		elseif self._iEndAnimal <=8 then
			othernum = 12
		end
		if othernum > 10 then
			self.Image_win[othernum]:setVisible(true);
			self.Image_win[othernum]:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5),cc.FadeOut:create(0.5),cc.FadeIn:create(0.5),cc.FadeOut:create(0.5),cc.FadeIn:create(0.5)));
		end
	end
	local dongwuAni = {"houzi","shizi","xiongmao","tuzi","laoying","kongque","gezi","yanzi","shayu","jinsha","","","tongsha","tongpei"}
	-- luaPrint("self._iEndAnimal="..self._iEndAnimal)
	-- luaPrint(dongwuAni[self._iEndAnimal].."  fqzs/texiao/"..(self._iEndAnimal-1).."/"..dongwuAni[self._iEndAnimal]..".json--".."fqzs/texiao/"..(self._iEndAnimal-1).."/"..dongwuAni[self._iEndAnimal]..".atlas")
	local dongwu =nil;
	if self._iEndAnimal < 11 then
		dongwu = createSkeletonAnimation(dongwuAni[self._iEndAnimal],"fqzs/texiao/"..(self._iEndAnimal-1).."/"..dongwuAni[self._iEndAnimal]..".json", "fqzs/texiao/"..(self._iEndAnimal-1).."/"..dongwuAni[self._iEndAnimal]..".atlas");
	else
		dongwu = createSkeletonAnimation("tongshatongpei","fqzs/texiao/10/tongshatongpei.json", "fqzs/texiao/10/tongshatongpei.atlas");
	end
	if dongwu then
		dongwu:setPosition(640,360);
		dongwu:clearTracks();
		dongwu:setAnimation(1,dongwuAni[self._iEndAnimal], false);
		self.Node_di:addChild(dongwu,10);
		self.dongwuSpine = dongwu;
		dongwu:runAction(cc.Sequence:create(cc.DelayTime:create(1.7),
			cc.Spawn:create(cc.MoveTo:create(0.2,cc.p(1220,200)),cc.ScaleTo:create(0.2,0.1)),
			cc.CallFunc:create(function() 
				if self.dongwuSpine then
					self.dongwuSpine:removeFromParent();
				end
				self.dongwuSpine = nil;
				--筹码动画
				self.chipNodeManager:ResultChipRemove(self._iEndAnimal)
			
			end)))

	end

	--播放音效

	audio.playSound("sound/sound-fly-"..(self._iEndAnimal-1)..".mp3",false);

	if self._iEndAnimal > 0 and self._iEndAnimal < 9 then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
			audio.playSound("sound/sound-fly-"..(self._iEndAnimal-1).."-0.mp3",false);			
		end)))

	elseif self._iEndAnimal == 9 or self._iEndAnimal == 10 then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
			audio.playSound("sound/bigMoney.mp3",false);
		end)))
	end

	-- if self._iEndAnimal == 9 or self._iEndAnimal == 10 then
		-- audio.playSound("sound/bigwin.mp3",false);
	-- end
end


-- //游戏开始时的UI处理
function TableLayer:showGameBegin()
	self:clearDesk();
end

 -- //清理桌面
function TableLayer:clearDesk()
	-- self._bLeaveDesk = false;
	for k,v in pairs(self.AtlasLabel_myqu) do
		v:setString("");
	end
	for k,v in pairs(self.AtlasLabel_qu) do
		v:setString("");
	end
	for k,v in pairs(self.Image_win) do
		v:setVisible(false)
	end
	self.AtlasLabel_zongxiazhu:setString("0");
	if self.chipNodeManager  then
		self.chipNodeManager:clearAllChip();
	end
	if self.dongwuSpine then
		self.dongwuSpine:stopAllActions();
		self.dongwuSpine:removeFromParent();
		self.dongwuSpine = nil;
	end
	if self.daojishiSpine then
		self.daojishiSpine:removeFromParent();
		self.daojishiSpine = nil;
	end
	if self.ziSpine then
		self.ziSpine:setVisible(false);
	end
	-- self.t_bankTable = {};
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
	-- self.tableLogic:sendUserUp();
	-- self.tableLogic:sendForceQuit();
	Hall:exitGame();
end


function TableLayer:updateCheckNet()
	-- PlatformLogic:sendHeart();--防止大厅网络离开大厅后被服务端断开

	-- if not RoomLogic:isConnect() then
	-- 	if self:getChildByTag(1421) == nil then
	-- 		self:onGameDisconnect(function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end);
	-- 	end
	-- else
	-- 	luaPrint("send self.m_iHeartCount = "..self.m_iHeartCount)
	-- 	if self.m_iHeartCount > self.m_maxHeartCount then
	-- 		self.m_iHeartCount = 0;
	-- 		self:onGameDisconnect(function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end);
	-- 	else
	-- 		RoomLogic:sendHeart();
	-- 		self.m_iHeartCount = self.m_iHeartCount + 1;
	-- 	end
	-- end
end

function TableLayer:gameNetHeart()
	-- luaPrint("roomlogic rece self.m_iHeartCount = "..self.m_iHeartCount)
	-- if self.m_iHeartCount > 0 then
	-- 	self.m_iHeartCount = self.m_iHeartCount - 1;
	-- else
	-- 	self.m_iHeartCount = 0;
	-- end
end

function TableLayer:onGameDisconnect(callback)
	-- if self.updateCheckNetSchedule  then
	-- 	self:stopAction(self.updateCheckNetSchedule);
	-- 	self.updateCheckNetSchedule = nil;
	-- end

	-- if globalUnit:getGameMode() ~= true then
	-- 	local root = cc.Director:getInstance():getRunningScene();
	-- 	local node = root:getChildByName("prompt");
		
	-- 	if node or self._isGameEnd == true then
	-- 		return;
	-- 	end

	-- 	RoomLogic:close();

	-- 	local prompt = GamePromptLayer:create();
	-- 	prompt:showPrompt(GBKToUtf8("网络断开连接，请重新登陆!"));
	-- 	prompt:setBtnClickCallBack(function()
	-- 		self.tableLogic:sendUserUp();
	-- 		self.tableLogic:sendForceQuit();
	-- 	end);
	-- else
		
	-- 	-- //--断线重连提示
	-- 	local node = self:getChildByTag(1421);
	-- 	if node then
	-- 		return;-- node:delayCloseLayer(0);
	-- 	end

	-- 	RoomLogic:close();

	-- 	if callback == nil then
	-- 		callback = function() self.updateCheckNetSchedule = schedule(self, function() self:updateCheckNet(); end, 1); end
	-- 	end

	-- 	local prompt = GameRelineLayer:create(callback);
	-- 	prompt:setTag(1421);
	-- 	self:addChild(prompt, 1000);
	-- 	prompt:sureReline();
	-- end
	
end

function TableLayer:updateGameSceneRotation(lSeatNo)
end

function TableLayer:setWaitTime(num)
	luaPrint("1111111111num=",num)
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
		self.updateDaojishiSchedule = nil;
	end
end

function TableLayer:callEverySecond()
	self.daojishi = self.daojishi -1;
	local winSize = cc.Director:getInstance():getWinSize()
	
	if self.daojishi > 0 then
		self.AtlasLabel_time:setString(self.daojishi);
		if self.isXiazhutime and self.daojishi == 3 then
			local dongwu = createSkeletonAnimation("djstexiao","game/daojishi/daojishi.json","game/daojishi/daojishi.atlas");
			if dongwu then
				dongwu:setScale(2)
				dongwu:setPosition(winSize.width/2,winSize.height*0.63);
				dongwu:setAnimation(1,"daojishi", false);
				self:addChild(dongwu,10);
			end
			self.daojishiSpine = dongwu;
			self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() 
				if self.daojishiSpine then
					self.daojishiSpine:removeFromParent();
				end
				self.daojishiSpine = nil;
			end)));
		end
		if self.isXiazhutime and self.daojishi <= 3 then
			audio.playSound("sound/sound-countdown.mp3",false);
			if self.daojishi == 1 then
				self.chipNodeManager:stopTimer();
			end
		end
	else
		self:stopTimer();
		self.AtlasLabel_time:setString("0")
		if not self.isXiazhutime then
			-- self.ownzongNode = 0;
		end
	end
end

function TableLayer:setUserMoney(money)
	self.AtlasLabel_ownJB:setString(money);
end

function TableLayer:receiveXiazhuResult(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	-- luaDump(data,"XiazhuResult")
	-- Hall.showTips("下注结果",1);
	local zongSum = 0;
	local ownzongNode = 0;
	
	--每个区总注
	for k,v in pairs(self.AtlasLabel_qu) do
		if data.iOneAllNum[k] >0 then 
			v:setString(gameRealMoney(data.iOneAllNum[k]))
		end
		zongSum = zongSum + data.iOneAllNum[k];
		
	end

	local nodetype = 1;

	if data.bDeskStation == self.tableLogic._mySeatNo then
		nodetype = 1;
		self:setUserMoney(gameRealMoney(data.iUserMoney));
		self.playerMoney = data.iUserMoney;
		self:ChipJundge();
		--每个区个人总注
		for k,v in pairs(self.AtlasLabel_myqu) do
			if data.iOwnNotes[k] >0 then 
				v:setString(gameRealMoney(data.iOwnNotes[k]))
			end
			ownzongNode = ownzongNode + data.iOwnNotes[k];
		end

		self.ownzongNode = ownzongNode;
		-- addScrollMessage("self.ownzongNode1 = "..self.ownzongNode)
		if self.ownzongNode > 0 then
			self.Button_xuya:setEnabled(false);
		end

		-- if  self.playerMoney < data.iNoteNum then
		-- 	self.Button_xuya:setEnabled(false);
		-- end
	else
		nodetype = 2;
	end

	

	local ichoumatype = self:getChoumaType(data.iNoteNum);
	self.chipNodeManager:ChipCreate(nodetype,ichoumatype,data.iType+1,nodetype == 1,false,true);
	
	-- local castTable = self:getCastByNum(data.iNoteNum)
 --   	-- luaDump(castTable)
 --    for index,num in ipairs(castTable) do
 --        if tonumber(num) > 0 then
 --            for i=1,num do
 --                self.chipNodeManager:ChipCreateIMG(nodetype,index,data.iType+1,nodetype == 1,false,true);
 --            end
 --        end
 --    end
	
	self.AtlasLabel_zongxiazhu:setString(gameRealMoney(zongSum));
	
end


function TableLayer:receiveGameBeginInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	if isHaveBankLayer() then
		createBank(function(data)
	    			self:bankInfoDeal(data);
	    		end,true)
		-- dispatchEvent("isCanSendGetScore",true)--true 可以取钱，false不可以取钱 游戏中调
	end

	local data = data._usedata;
	-- luaDump(data,"Begin")
	self.noReceive = false;
	-- Hall.showTips("游戏开始",2);
	-- self:setWaitTime(data.iTime);
	if data.iZhuangBaShu > 1 then
		-- Hall.showTips("连庄"..data.iZhuangBaShu.."局",1);
		self.Image_lianzhuang:setVisible(true);
		self.AtlasLabel_zhuangjushu:setString(data.iZhuangBaShu);
		self.Image_lianzhuang:runAction(cc.Sequence:create(cc.FadeIn:create(1),cc.FadeOut:create(1)))
	end
	-- self.Image_dengdaikaishi:setVisible(false);
	if self.ziSpine then
		self.ziSpine:setVisible(false);
	end
	self.kaijiangTime = false;
end

function TableLayer:receiveGameBeginXiazhuInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end

	self:playDengDaiEffect(false);
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	local data = data._usedata;

	--判断是否在上庄列表
	local findFlag = false;
	
	 for k,v in pairs(self.t_bankTable) do
        if v == self.tableLogic:getMySeatNo() then
            findFlag = true;
            break;
        end
    end

	--判断未操作局数置0
	if findFlag or self.isZhuang or self.ownzongNode>0 then
		self.mOperateGameCount = 0;
	end

	--先判断已经未操作的局数
	if self.mOperateGameCount > 2 then
		--5局被踢出游戏
		if self.mOperateGameCount > 4 then
			addScrollMessage("您已连续5局未参与游戏，已被请出房间！");
			self:onClickExitGameCallBack();
			return;
		else
			--提示
			addScrollMessage("您已连续"..self.mOperateGameCount.."局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
		end
	end

	if findFlag or self.isZhuang then
	else
		self.mOperateGameCount = self.mOperateGameCount + 1;
	end

	-- luaDump(data,"BeginXiazhu")
	-- Hall.showTips("开始下注",2);
	self:setWaitTime(data.iTime);
	-- self.Text_statetip:setString("下注中");
	self.Image_statetip:loadTexture("xiazhuzhong.png",UI_TEX_TYPE_PLIST);
	self:clearDesk();

	if self.isZhuang then
		self:setChoumaEnable(false);
	else
		self:setChoumaEnable(true);
		self:ChipJundge();
	end
	-- self.Button_xuya:setEnabled(false);
	self.isXiazhutime = true;
	-- self.Image_xiazhutipbg:setVisible(true);
	-- self.Image_xiazhutip:loadTexture("kaishixiazhu1.png",UI_TEX_TYPE_PLIST)
	-- self.Image_xiazhutipbg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.FadeOut:create(0.5)))
	self:playZitiEffect(3)
	audio.playSound("sound/sound-start-wager.mp3",false);
	if self.myUseNotes == 0 or self.myUseNotes > self.playerMoney then
		self.Button_xuya:setEnabled(false);
	end
	self.ownzongNode = 0;
end

function TableLayer:getChoumaType(num)
	local itype = 1;
	if num == 100 then 
		itype = 1;
	elseif num == 1000 then
		itype = 2;
	elseif num == 5000 then
		itype = 3;
	elseif num == 10000 then
		itype = 4;
	elseif num == 50000 then
		itype = 5;
	elseif num == 100000 then
		itype = 6;
	end
	return itype;
end

function TableLayer:receiveGamePlayGameInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	self:getMyNotes()
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	local data = data._usedata;
	-- luaDump(data,"zhuanpan")
	-- Hall.showTips("停止下注",2);
	-- self.Text_statetip:setString("开奖中");
	self.Image_statetip:loadTexture("kaijiangzhong.png",UI_TEX_TYPE_PLIST);
	self:setWaitTime(15);
	self:startRunRound(data.iStarPos+1,data.iEndPos+1,data.iWinnings,data.iEndAnimal+1)
	
	self:setChoumaEnable(false);
	self.isXiazhutime = false;
	-- self.Image_xiazhutip:loadTexture("tingzhixiazhu.png",UI_TEX_TYPE_PLIST)
	-- self.Image_xiazhutipbg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),cc.FadeOut:create(0.5)))
	audio.playSound("sound/sound-end-wager.mp3",false);
	self:playZitiEffect(4)
	if self.ownzongNode>0 then
		GamePromptLayer:remove()
	end
end

--设置筹码状态
function TableLayer:setChoumaEnable(enable)
	local itype = self:getChoumaType(self.chouma);
	-- self.Button_chouma[itype]:setHighlighted(enable);
	for k,v in pairs(self.Button_chouma) do 
		v:setEnabled(enable);
		v:setScale(1)
	end
	if enable then
		-- self.Button_chouma[itype]:setScale(1.1);
		self:ChooseChip(itype);
	else
		-- if self.quan then
		-- 	self.quan:setVisible(false);
		-- end
		self:ShowChipAction(self.Button_chouma[itype],false)
	end
	
	-- for k,v in pairs(self.Button_fqzs) do 
	-- 	v:setTouchEnabled(enable);
	-- 	v:setHighlighted(false);
	-- end
	self.Button_xuya:setHighlighted(false);
	self.Button_xuya:setEnabled(enable);
end

function TableLayer:receiveShowResultInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	local data = data._usedata;
	-- luaDump(data,"jiesuan")
	-- Hall.showTips("结算",2);
	self.playerMoney = data.i64Money;
	self:setUserMoney(gameRealMoney(data.i64Money));
	self:showLuzi(data.iHistory);
	
	local userInfo = self.tableLogic:getUserBySeatNo(data.iNowNTStation);
		if userInfo then
			-- luaDump(userInfo,"userInfo111")
			self.Text_zhuangname:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
			self.AtlasLabel_zhuangmoney:setString(gameRealMoney(userInfo.i64Money))
		end
	if self.noReceive then
		return;
	end
	local str = "";
	if data.iOwnAllCountNote > 0 or self.isZhuang then

		if data.iOwnPoint >= 0 then
			if data.iOwnPoint > 0 then
				audio.playSound("sound/win.mp3",false);
			end
			str = "+"..gameRealMoney(data.iOwnPoint);
			self.AtlasLabel_me:setProperty(str,"zitiao1.png", 26, 50, '+');
			-- self.AtlasLabel_me:setString("+"..gameRealMoney(data.iOwnPoint));
		else
			-- self.AtlasLabel_me:setString(gameRealMoney(data.iOwnPoint));
			str = gameRealMoney(data.iOwnPoint);
			self.AtlasLabel_me:setProperty(str,"zitiao2.png", 26, 50, '+');
			audio.playSound("sound/lose.mp3",false);
		end
		self.AtlasLabel_me:setVisible(true);
		self.AtlasLabel_me:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
		cc.MoveBy:create(0.5,cc.p(0,30)),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function() 
			self.AtlasLabel_me:setString("");
		end),cc.MoveBy:create(1,cc.p(0,-30))));
	end
	
	if data.iOtherPoint >= 0 then
		-- self.AtlasLabel_other:setString("+"..gameRealMoney(data.iOtherPoint));
		str = "+"..gameRealMoney(data.iOtherPoint);
		self.AtlasLabel_other:setProperty(str,"zitiao1.png", 26, 50, '+');
	else
		-- self.AtlasLabel_other:setString(gameRealMoney(data.iOtherPoint));
		str = gameRealMoney(data.iOtherPoint);
		self.AtlasLabel_other:setProperty(str,"zitiao2.png", 26, 50, '+');
	end
	self.AtlasLabel_other:setVisible(true);

	if data.iNTPoint >= 0 then
		-- self.AtlasLabel_zhuang:setString("+"..gameRealMoney(data.iNTPoint));
		str = "+"..gameRealMoney(data.iNTPoint);
		self.AtlasLabel_zhuang:setProperty(str,"zitiao1.png", 26, 50, '+');
	else
		-- self.AtlasLabel_zhuang:setString(gameRealMoney(data.iNTPoint));
		str = gameRealMoney(data.iNTPoint);
		self.AtlasLabel_zhuang:setProperty(str,"zitiao2.png", 26, 50, '+');
	end
	self.AtlasLabel_zhuang:setVisible(true);
	
	
	self.AtlasLabel_other:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
		cc.MoveBy:create(0.5,cc.p(0,30)),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function() 
			self.AtlasLabel_other:setString("");
		end),cc.MoveBy:create(1,cc.p(0,-30))));
	self.AtlasLabel_zhuang:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
		cc.MoveBy:create(0.5,cc.p(0,30)),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function() 
			self.AtlasLabel_zhuang:setString("");
		end),cc.MoveBy:create(1,cc.p(0,-30))));

	--播放连胜特效
	if data.nWinTime > 2 and ((self.ownzongNode>0 and not self.isZhuang) or self.isZhuang) then
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
end

--上下庄结果
function TableLayer:receiveShangzhuangResultInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	local data = data._usedata;
	-- luaDump(data,"shangzhuangResult")
	luaPrint("data.station ="..data.station.." ww "..self.tableLogic._mySeatNo)

	self:updateBankList(data.iNTList,data.ntListNum);
	if data.station == self.tableLogic._mySeatNo then
		if data.shang and not data.bCancel then
			if data.success == 1 then
				self:setChoumaEnable(false);
				self.isZhuang = true;
				self.Button_zhuang:loadTextures("xiazhuang.png","xiazhuang-on.png","xiazhuang-on.png",UI_TEX_TYPE_PLIST);
				self.Button_zhuang:setTag(1)
				luaPrint("11111111111111111111111")
			elseif data.success == 2 then
				-- Hall.showTips("已加入申请列表")
				self.isZhuang = false;
				self.Button_zhuang:loadTextures("quxiaoshangzhuang.png","quxiaoshangzhuang-on.png","quxiaoshangzhuang-on.png",UI_TEX_TYPE_PLIST);
				self.Button_zhuang:setTag(2)
			end
		elseif data.shang and data.bCancel then

			if data.success == 3 then
				self.isZhuang = false;
				self.Button_zhuang:loadTextures("shangzhuang.png","shangzhuang-on.png","shangzhuang-on.png",UI_TEX_TYPE_PLIST);
				self.Button_zhuang:setTag(0)
			end
		elseif not data.shang and  data.bCancel then
			if data.success == 1 then
				self:setChoumaEnable(false);
				self.isZhuang = true;
				self.Button_zhuang:loadTextures("xiazhuang.png","xiazhuang-on.png","xiazhuang-on.png",UI_TEX_TYPE_PLIST);
				self.Button_zhuang:setTag(1)
			end
		elseif not data.shang and not data.bCancel then
			if data.success == 1 then
				self:setChoumaEnable(false);
				self.isZhuang = true;
				self.Button_zhuang:loadTextures("quxiaoxiazhuang.png","quxiaoxiazhuang-on.png","quxiaoxiazhuang-on.png",UI_TEX_TYPE_PLIST);
				self.Button_zhuang:setTag(3)
			end
		end
	end
	if data.shang and not data.bCancel and data.success == 1 then
		local userInfo = self.tableLogic:getUserBySeatNo(data.station);
		if userInfo then
			-- luaDump(userInfo,"userInfo")
			self.Text_zhuangname:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
			self.AtlasLabel_zhuangmoney:setString(gameRealMoney(userInfo.i64Money))
		end
	end
	self.Text_zhuangtip:setString("申请人数:"..data.ntListNum)
end

--换庄
function TableLayer:receiveChangeZhuangInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	local data = data._usedata;
	-- luaDump(data,"ChangezhuangResult 庄家轮换")
	self:updateBankList(data.iNTList,data.ntListNum);
	self.Image_zhuanglunhuan:setVisible(true);
	self.Image_zhuanglunhuan:runAction(cc.Sequence:create(cc.FadeIn:create(0.7),cc.FadeOut:create(0.7)))
	self.Text_zhuangname:setString(FormotGameNickName(data.nickName,nickNameLen))
	self.AtlasLabel_zhuangmoney:setString(gameRealMoney(data.i64Money))
	self.Text_zhuangtip:setString("申请人数:"..data.ntListNum)
	if self.isZhuang then
		self.Button_zhuang:loadTextures("shangzhuang.png","shangzhuang-on.png","shangzhuang-on.png",UI_TEX_TYPE_PLIST);
		self.Button_zhuang:setTag(0)
	end
	if data.station == self.tableLogic._mySeatNo then
		self.Button_zhuang:loadTextures("xiazhuang.png","xiazhuang-on.png","xiazhuang-on.png",UI_TEX_TYPE_PLIST);
		self.Button_zhuang:setTag(1)
		self:setChoumaEnable(false);
		self.isZhuang = true;
	else
		-- self.Button_zhuang:loadTextures("shangzhuang.png","shangzhuang-on.png","shangzhuang-on.png",UI_TEX_TYPE_PLIST);
		-- self.Button_zhuang:setTag(0)
		self.isZhuang = false;
	end
	self.zhuangSeatNo = data.station;
	audio.playSound("sound/zhuang-huan.mp3",false);
	-- self:playZitiEffect(2)
end

--无庄
function TableLayer:receiveWuZhuangInfo(data)
	if self.m_bGameStart ~= true then
		return;
	end
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	self.Text_zhuangname:setString("无人上庄");
	self.Text_zhuangtip:setString("申请人数:0");
	self.AtlasLabel_zhuangmoney:setString("");
	self.Button_zhuang:loadTextures("shangzhuang.png","shangzhuang-on.png","shangzhuang-on.png",UI_TEX_TYPE_PLIST);
	self.Button_zhuang:setTag(0)
	self.isZhuang = false;
	self:setChoumaEnable(false);
	performWithDelay(self,function() 
		local str = self.AtlasLabel_zhuangmoney:getString();
		if str == "" then
			self:playDengDaiEffect(true); 
			self.ownzongNode = 0;
		end
		end, 4)
	
	-- self.Text_statetip:setString("当前无人上庄");
end

--断线
function TableLayer:receiveUserCutInfo(data)
	local data = data._usedata;
	self:gameUserCut(data.bDeskStation, data.bCut);
end

--刚进入游戏游戏状态
function TableLayer:showGameStatus(data,status)
	for k,v in pairs(self.Image_di) do
		v:stopAllActions();
		v:setVisible(false);
	end
	-- self.ownzongNode = 0;
	
	--刷新自己信息
	local myInfo = self.tableLogic:getUserBySeatNo(self.tableLogic._mySeatNo);
	if myInfo then
		luaDump(myInfo,"myInfo")
		self.Text_name:setString(FormotGameNickName(myInfo.nickName,nickNameLen))
		self.AtlasLabel_ownJB:setString(gameRealMoney(myInfo.i64Money))
		self.playerMoney = myInfo.i64Money;
	end
	self:stopAllActions();
	self:clearDesk();
	-- self:playEnterEffect();
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	luaPrint("status =  "..status)
	luaDump(data,"showGameStatus")
	self.minShangzhuang = data.gameStation.ishangzhuangLimit;
	self.minXiazhuang = data.gameStation.ixiazhuangLimit;
	local strTip = "kaijiangzhong.png";
	local waitTime = data.gameStation.iTime;
	if status == GameMsg.GS_WAIT_SETGAME or status == GameMsg.GS_GAME_FINISH  then
		strTip = "kaijiangzhong.png";
		-- self.Image_dengdaikaishi:setVisible(true);
		-- self:playZitiEffect(1)
		self:playDengDaiEffect(true);
		self:setChoumaEnable(false);
		self.isXiazhutime = false;
	elseif status == GameMsg.GS_XIAZHU then
		strTip = "xiazhuzhong.png";
		self.isXiazhutime = true;
		self.chipNodeManager:clearAllChip()
		self:regainGameChip(data)
		self:setChoumaEnable(true);
		self:ChipJundge();
		self.Button_xuya:setEnabled(false);
		self:playDengDaiEffect(false);
		if self.myUseNotes > 0 and self.myUseNotes <= self.playerMoney and self.ownzongNode == 0 then
			self.Button_xuya:setEnabled(true);
		else
			self.Button_xuya:setEnabled(false);
		end
	elseif status == GameMsg.GS_KAIJIANG or status == GameMsg.GS_XIAZHU_FINISH then
		self.noReceive = true;
		strTip = "kaijiangzhong.png";
		waitTime = waitTime;
		self.isXiazhutime = false;
		-- Hall.showTips("等待下局开始")
		-- self.Image_dengdaikaishi:setVisible(true);
		-- self:playZitiEffect(1)
		self:playDengDaiEffect(true);
		self.kaijiangTime = true;
		self:setChoumaEnable(false);
	end
	if waitTime > 15 then
		waitTime = 0;
	end
	self:setWaitTime(waitTime)
	if isHaveBankLayer() then
		createBank(function(data)
    			self:bankInfoDeal(data);
    		end,self.isXiazhutime)
	end
	-- self.Text_statetip:setString(strTip);
	self.Image_statetip:loadTexture(strTip,UI_TEX_TYPE_PLIST);
	local userInfo = self.tableLogic:getUserBySeatNo(data.gameStation.iNowNTStation);
	if userInfo then
		luaDump(userInfo,"userInfo")
		self.zhuangSeatNo = data.gameStation.iNowNTStation;
		self.Text_zhuangname:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
		self.AtlasLabel_zhuangmoney:setString(gameRealMoney(userInfo.i64Money))
		self.Text_zhuangtip:setString("申请人数:"..data.gameStation.iNTListNum)
	else
		if not data.gameStation.bEnableSysBanker then
			self.Text_zhuangname:setString("无人上庄")
			self.Text_zhuangtip:setString("申请人数:0")
			self:setChoumaEnable(false)
		end
	end
	self:updateBankList(data.gameStation.iNTList,data.gameStation.iNTListNum);
	if data.gameStation.zhuangStatus == 0 then --非庄
		self.Button_zhuang:loadTextures("shangzhuang.png","shangzhuang-on.png","shangzhuang-on.png",UI_TEX_TYPE_PLIST);
		self.Button_zhuang:setTag(0)
		self.isZhuang = false;	
	elseif data.gameStation.zhuangStatus == 1 then --是庄
		self.Button_zhuang:loadTextures("xiazhuang.png","xiazhuang-on.png","xiazhuang-on.png",UI_TEX_TYPE_PLIST);
		self.Button_zhuang:setTag(1)
		self:setChoumaEnable(false);
		self.isZhuang = true;
	elseif data.gameStation.zhuangStatus == 2 then --在上庄列表
		self.Button_zhuang:loadTextures("quxiaoshangzhuang.png","quxiaoshangzhuang-on.png","quxiaoshangzhuang-on.png",UI_TEX_TYPE_PLIST);
		self.Button_zhuang:setTag(2)
		self.isZhuang = false;
	elseif data.gameStation.zhuangStatus == 3 then --取消下庄
		self.Button_zhuang:loadTextures("quxiaoxiazhuang.png","quxiaoxiazhuang-on.png","quxiaoxiazhuang-on.png",UI_TEX_TYPE_PLIST);
		self.Button_zhuang:setTag(3)
		self:setChoumaEnable(false);
		self.isZhuang = true;
	end
	self:showLuzi(data.gameStation.iHistory);
	
	luaPrint(data.gameStation.iNowNTStation.."and"..self.tableLogic._mySeatNo)
	if data.gameStation.iNowNTStation == self.tableLogic._mySeatNo then
		self:setChoumaEnable(false);
		self.isZhuang = true;
	end
	--系统坐庄
    if data.gameStation.bEnableSysBanker then
    	self.Button_bankList:setVisible(false)
    	self.Button_zhuang:setVisible(false)
    	self.Text_zhuangname:setString("");
    	self.AtlasLabel_zhuangmoney:setString("")
    	self.xtzz:setVisible(true)
    end
    self.bEnableSysBanker = data.gameStation.bEnableSysBanker;
end

--路子
function TableLayer:showLuzi(history)
	display.loadSpriteFrames("fqzs/fqzs.plist", "fqzs/fqzs.png");
	-- luaDump(history,"history")
	self.ListView_dongwu:removeAllChildren();
	local _count = 0;
	for i=1,#history do
		if history[i] >= 0 then 
			_count = _count + 1;
		end
	end

	for i=1,#history do
		if history[i] >= 0  and history[i] <= 13 then 
			local layout = ccui.Layout:create();
	        layout:setContentSize(cc.size(68, 68));

	        local imgPath = "animal"..history[i]..".png";
	        local dongwu = cc.Sprite:createWithSpriteFrameName(imgPath)
	       	-- local dongwu = cc.Sprite:create("animal"..history[i]..".png")
	       	dongwu:setPosition(34,34)
	       	dongwu:setScale(0.6);
	        layout:addChild(dongwu)
	        if i == _count then
	        	-- local new = ccui.ImageView:create("xin.png");
	        	local imgPath = "xin.png";
	        	local new = cc.Sprite:createWithSpriteFrameName(imgPath)
			    new:setPosition(cc.p(57,37));
			    new:setScale(2);
			    dongwu:addChild(new);
	        end
			
			self.ListView_dongwu:pushBackCustomItem(layout);
		end
	end
	self.ListView_dongwu:scrollToPercentVertical(100,0.1,true);
end

--获取其他玩家人数
function TableLayer:getOthersInfo()
    local othersTable = {};
    for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
            table.insert(othersTable,userInfo)
        end
    end
    return othersTable;
end

--刷新其他玩家信息
function TableLayer:refreshOther(others)
	self.ListView_other:removeAllChildren();
	-- luaDump(others,"others")
	for k,v in pairs(others) do
		local layout = ccui.Layout:create();
	     layout:setContentSize(cc.size(250, 60));

	     local other = require("fqzs.PlayerInfo").new(self, k, v);
	     
	     other:setContentSize(layout:getContentSize());
	     layout:addChild(other);
			
		self.ListView_other:pushBackCustomItem(layout);
	end
end

--刷新其他玩家人数
function TableLayer:refreshOtherNum()
	local others = self:getOthersInfo();
	local num = table.nums(others);
	self.AtlasLabel_othernum:setString(":"..num..";");
end

--刷新其他玩家信息list
function TableLayer:gamePoint()
	-- Hall.showTips("gamePoint");
	luaPrint("gamePoint")
	 for _,userInfo in ipairs(self.tableLogic._deskUserList._users) do
        if userInfo.bDeskStation == self.zhuangSeatNo then
            self.Text_zhuangname:setString(FormotGameNickName(userInfo.nickName,nickNameLen))
			self.AtlasLabel_zhuangmoney:setString(gameRealMoney(userInfo.i64Money))
        end
    end
	-- if self.Image_other:isVisible() then
	-- 	local others = self:getOthersInfo();
	-- 	self:refreshOther(others);
	-- end
end

function gameRealMoney(money)
	return string.format("%.2f", money/100);
end

function TableLayer:playZitiEffect(iType)
	local tipzi = {"dengdaixiaju","huanzhuang","kaishixiazhu","tingzhixiazhu"}
	local winSize = cc.Director:getInstance():getWinSize()
	
	if self.ziSpine then
		self.ziSpine:setVisible(true);
		self.ziSpine:clearTracks();
		self.ziSpine:setAnimation(1,tipzi[iType], false);
	else
		self.ziSpine = createSkeletonAnimation("zitiTip","game/feiqinzoushou.json","game/feiqinzoushou.atlas");
		if self.ziSpine then
			-- self.ziSpine:setScale(2)
			self.ziSpine:setPosition(winSize.width/2,winSize.height/2);
			self.ziSpine:setAnimation(1,tipzi[iType], false);
			self:addChild(self.ziSpine,10);
		end
	end
end

function TableLayer:playKaijiangEffect(iType)
	local winSize = cc.Director:getInstance():getWinSize()
	if self.kaijiangSpine then
		self.kaijiangSpine:setVisible(true);
		self.kaijiangSpine:clearTracks();
		self.kaijiangSpine:setAnimation(1,tostring(iType), false);
	else
		self.kaijiangSpine = createSkeletonAnimation("kaijiang","texiao/kaijiang/kaijiang.json","texiao/kaijiang/kaijiang.atlas");
		if self.kaijiangSpine then
			self.kaijiangSpine:setPosition(winSize.width/2,winSize.height/2);
			self.kaijiangSpine:setAnimation(1,tostring(iType), false);
			self:addChild(self.kaijiangSpine,10);
		end
	end
end

function TableLayer:playDengDaiEffect(enable)
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
	local winSize = cc.Director:getInstance():getWinSize()
	
	if self.dengDaiSpine then
		self.dengDaiSpine:clearTracks();
		self.dengDaiSpine:setAnimation(1,"dengxiaju", true);
	else
		self.dengDaiSpine = createSkeletonAnimation("dengdai","game/dengdai/dengdai.json","game/dengdai/dengdai.atlas");
		if self.dengDaiSpine then
			self.dengDaiSpine:setPosition(winSize.width/2,winSize.height/2);
			self.dengDaiSpine:setAnimation(1,"dengxiaju", true);
			self:addChild(self.dengDaiSpine,10);
		end
	end
end

--处理错误信息
function TableLayer:receiveErrorCode(data)
	if self.m_bGameStart ~= true then
		return;
	end
	-- if self.minShangzhuang == nil then
	-- 	self.minShangzhuang = 4000000;
	-- end
	local data = data._usedata;
	local text = ""
	if data.errorCode == 1 then--庄家不能申请上庄
		text = "庄家不能申请上庄";
	elseif data.errorCode == 2 then--上庄金币不足
		text = "上庄金币不足"..(self.minShangzhuang/100)..",不能上庄。";
		showBuyTip();
	elseif data.errorCode == 3 then--列表中的玩家不能申请
		-- text = "列表中的玩家不能申请";
	elseif data.errorCode == 4 then--不是庄家也不在申请列表，下庄错误
		text = "不是庄家也不在申请列表，下庄错误";
	elseif data.errorCode == 5 then--列表已满
		text = "列表已满";
	elseif data.errorCode == 6 then--庄家无法下注
		text = "庄家无法下注";
	elseif data.errorCode == 7 then--庄家信息错误
		text = "庄家信息错误";
	elseif data.errorCode == 8 then--超出最大下注配额
		text = "超出该区域最大下注配额，下注失败！";
	elseif data.errorCode == 9 then--金币不足30
		text = "下注失败，您钱包至少拥有30金币才能下注！";
		showBuyTip();
		self.Button_xuya:setEnabled(false);
	elseif data.errorCode == 10 then--庄家金币不足
		text = "庄家金币少于坐庄必须金币数"..(self.minXiazhuang/100).."，自动下庄。";
	elseif data.errorCode == 11 then--金币不足筹码
		text = "下注失败，您金币不足。";
		showBuyTip();
		self.Button_xuya:setEnabled(false);
	elseif data.errorCode == 12 then--金币不足
		text = "您的金币少于坐庄必须金币数"..(self.minXiazhuang/100).."，自动取消上庄。";
	elseif data.errorCode == 13 then--强行下庄
		text = "庄家坐庄局数达到10局，强行下庄。";
	end
	-- Hall.showTips(text,1);
	if text ~= "" then
		addScrollMessage(text)
	end
end

--根据自己拥有的金额判断筹码置灰 --判断筹码100是否能亮起来 默认亮起100
function TableLayer:ChipJundge(default)
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
	--设置是否能点击
	for i = 1,6 do
		self.Button_chouma[i]:setEnabled(false);
		if i <= num then
			self.Button_chouma[i]:setEnabled(true);
		end
	end
	--设置默认值
	local itype = self:getChoumaType(self.chouma);

	if money>self:ChipTypeToChipMoney(itype)  then
		self:ChooseChip(itype);
	else
		if num > 0 then
			self:ChooseChip(num);
			self.chouma = self:ChipTypeToChipMoney(num)
		else
			self.chouma = 100;
			for k,v in pairs(self.Button_chouma) do
				self:ShowChipAction(v,false)
			end
		end
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

function TableLayer:ChooseChip(chipType)
	local y = self.Button_xuya:getPositionY()
	for k,v in pairs(self.Button_chouma) do
		v:setPositionY(y);
		self:ShowChipAction(v,false)
	end
	
	if self.Button_chouma[chipType]:isEnabled() then
		self.Button_chouma[chipType]:setPositionY(y+10);
		self:ShowChipAction(self.Button_chouma[chipType],true)
	end
	
	-- if self.chipType == chipType then
	-- 	if self.quan then
	-- 		self.quan:setVisible(true);
	-- 		return;
	-- 	end
	-- end
	-- self.chipType = chipType;

	-- if self.quan then
	-- 	self.quan:removeFromParent();
	-- end
	
	-- local size = self.Button_chouma[chipType]:getContentSize()
	-- local quan = ccui.ImageView:create("hall/game/guangquan.png")
	-- quan:setPosition(size.width/2,size.height/2)
	-- self.Button_chouma[chipType]:addChild(quan)
	-- quan:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)));
	-- self.quan = quan;
end

function TableLayer:regainGameChip(data)
	local zongSum = 0;
	local ownSum = 0;
    for k,v in pairs(self.AtlasLabel_qu) do
    	if data.iOneAllNum[k] >0 then
    		zongSum = zongSum + data.iOneAllNum[k];
    		v:setString(gameRealMoney(data.iOneAllNum[k]));
    		if data.iOneAllNum[k] - data.gameStation.iOwnNotes[k] > 0 then
    			local castTable = self:getCastByNum(data.iOneAllNum[k] - data.gameStation.iOwnNotes[k])
	           -- luaDump(castTable)
	            for index,num in ipairs(castTable) do
	                if tonumber(num) > 0 then
	                    for i=1,num do
	                        self.chipNodeManager:ChipCreateIMG(3,index,k,false,true);
	                    end
	                end
	            end
    		end
    	end
    end
    self.AtlasLabel_zongxiazhu:setString(gameRealMoney(zongSum));
    for k,v in pairs(self.AtlasLabel_myqu) do
    	if data.gameStation.iOwnNotes[k] >0 then
    		ownSum = ownSum + data.gameStation.iOwnNotes[k];
    		v:setString(gameRealMoney(data.gameStation.iOwnNotes[k]))
    		local castTable = self:getCastByNum(data.gameStation.iOwnNotes[k])
	           -- luaDump(castTable)
	        for index,num in ipairs(castTable) do
	            if tonumber(num) > 0 then
	                for i=1,num do
	                    self.chipNodeManager:ChipCreateIMG(3,index,k,true,true);
	                end
	            end
	        end
    	end
    end
    local myInfo = self.tableLogic:getUserBySeatNo(self.tableLogic._mySeatNo);
	if myInfo and ownSum > 0 then
	    self.AtlasLabel_ownJB:setString(gameRealMoney(myInfo.i64Money-ownSum))
	    self.playerMoney = myInfo.i64Money - ownSum;
	    GamePromptLayer:remove();
	end
	self.ownzongNode = ownSum;
end

--根据分数获取筹码
function TableLayer:getCastByNum(num)
    if num <= 0 then
        luaPrint("下注分数为空")
        return;
    end
    local temp = {0,0,0,0,0,0};

    if num >= 100000 then
        local temp1 = math.modf(num/100000)
        luaPrint("----------",temp1)
        temp[6] = temp1;
        num = num%100000
    end
    if num >= 50000 then
        local temp1 = math.modf(num/50000)
        temp[5] = temp1;
        num = num%50000
    end
    if num >= 10000 then
        local temp1 = math.modf(num/10000)
        temp[4] = temp1;
        num = num%10000
    end
    if num >= 5000 then
        local temp1 = math.modf(num/5000)
        temp[3] = temp1;
        num = num%5000
    end
    if num >= 1000 then
        local temp1 = math.modf(num/1000)
        temp[2] = temp1;
        num = num%1000
    end
    if num >= 100 then
        local temp1 = math.modf(num/100)
        temp[1] = temp1;
        num = num%100
    end
    luaPrint("num",num)
    -- luaDump(temp,"temp")
    return temp;
   
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

		-- for k,v in pairs(self.Image_di) do
		-- 	v:stopAllActions();
		-- 	v:setVisible(false);
		-- end

		-- self:stopAllActions();

		-- self:clearDesk();
		
		self.tableLogic._bSendLogic = false;
		self.tableLogic:sendGameInfo();
	else
		-- self:exitClickCallback();
	end
end

function TableLayer:removeUser(deskStation, bMe,bLock)
	if not self:isValidSeat(deskStation) then 
		return;
	end
	if bMe then
		if bLock == 1 then
			addScrollMessage("您的金币不足,自动退出游戏。")
			showBuyTip(true);
		elseif bLock == 2 then
			addScrollMessage("您被厅主踢出VIP厅,自动退出游戏。")
			self:exitClickCallback();
		elseif bLock == 0 then
			self:exitClickCallback();
		elseif bLock == 3 then 
			addScrollMessage("长时间未操作,自动退出游戏。")
			self:exitClickCallback();
		elseif bLock == 5 then 
			addScrollMessage("VIP房间已关闭,自动退出游戏。")
			self:exitClickCallback();
		end
		
		-- self:onClickExitGameCallBack();
		-- self.Button_exit:setTouchEnabled(false);
		-- self:runAction(cc.Sequence:create(cc.DelayTime:create(2.5),cc.CallFunc:create(function()
		-- 	self.Button_exit:setTouchEnabled(true);
		-- 	addScrollMessage("您的金币不足,不能继续游戏。")
		-- 	self:onClickExitGameCallBack();
		-- end)))
	end
	
end

function TableLayer:isValidSeat(seatNo)
    return seatNo < PLAY_COUNT and seatNo >= 0;
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

--充值刷新金币
function TableLayer:gameBuymoney(msg)

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

--续押
function TableLayer:DealXiazhuResultXT(message)
  local msg = message._usedata;
  

	--每个区总注
	for k,v in pairs(self.AtlasLabel_qu) do
		if msg.iOneAllNum[k] >0 then 
			v:setString(gameRealMoney(msg.iOneAllNum[k]))
		end
	end
	local nodetype = 1;
	local ownzongNode = 0
	if msg.bDeskStation == self.tableLogic._mySeatNo then
		nodetype = 1;
		self:setUserMoney(gameRealMoney(msg.iUserMoney));
		self.playerMoney = msg.iUserMoney;
		self:ChipJundge();
		--每个区个人总注
		for k,v in pairs(self.AtlasLabel_myqu) do
			if msg.iOwnNotes[k] >0 then 
				v:setString(gameRealMoney(msg.iOwnNotes[k]))
			end
			ownzongNode = ownzongNode + msg.iOwnNotes[k];
		end

		self.ownzongNode = ownzongNode;
	else
		nodetype = 2;
	end
	self.AtlasLabel_zongxiazhu:setString(gameRealMoney(msg.iOwnAllCountNote));

	  for k,v in pairs(msg.money) do
	  	if v >0 then
			local castTable = self:getCastByNum(v)
	           -- luaDump(castTable)
	        for index,num in ipairs(castTable) do
	            if tonumber(num) > 0 then
	                for i=1,num do
	                    -- self.chipNodeManager:ChipCreateIMG(3,index,k,true,true);
	                    self.chipNodeManager:ChipCreate(nodetype,index,k,nodetype==1,false,true);
	                end
	            end
	        end
		end
	  end
	  

end

--统计下注结束，自己下的注
function TableLayer:getMyNotes()
	if self.ownzongNode == 0 then
		return
	end
	local myNotes = {}
	for k,v in pairs(self.AtlasLabel_myqu) do
		local x = v:getString();
		table.insert(myNotes,x)
	end
	self.myNotes = myNotes;
	self.myUseNotes  = self.ownzongNode;
end

--续押
function TableLayer:dealXuya()
	local xuyamsg = {}
	if self.myNotes then
		for k,v in pairs(self.myNotes) do
			-- self.AtlasLabel_myqu[k]:setString(v);
			if v ~= "" then
				local x = tonumber(v)
				-- FqzsInfo:sendNote(k-1,x*100);
				-- addScrollMessage(k.."aaa"..v)
				table.insert(xuyamsg,x*100)
			else
				table.insert(xuyamsg,0)
			end
		end
		self.Button_xuya:setEnabled(false)
		FqzsInfo:sendXutou(xuyamsg)
	end

end

--显示上庄列表
function TableLayer:showAddBankList()
	luaPrint("上庄列表");

	if self.listBg == nil then
		self:createBankList();
	else
		self.listBg:removeFromParent();
		self.listBg = nil;
	end

end

function TableLayer:updateBankList(date,n)
	local temp = {};
	if n and n > 0 then
		for i=1,n do
			table.insert(temp,date[i]);
		end
	end
	self.t_bankTable = temp;

	if self.listBg then
		self.listBg:removeFromParent();
		self.listBg = nil;
		self:showAddBankList();
	end
end

function TableLayer:createBankList()
	local listBg = ccui.ImageView:create("bg/kuang.png");
	listBg:setPosition(self.Button_bankList:getPositionX(),
		self.Button_bankList:getPositionY()-listBg:getContentSize().height*0.5-20);
	self.Node_di:addChild(listBg,2);
	self.listBg = listBg;

	local listView = ccui.ListView:create()
    listView:setAnchorPoint(cc.p(0.5,0.5))
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(listBg:getContentSize().width-10,listBg:getContentSize().height-30)
    listView:setPosition(listBg:getContentSize().width*0.5+10,listBg:getContentSize().height*0.5)
    listBg:addChild(listView)

    for k,v in pairs(self.t_bankTable) do
    	local layout = self:createItem(k);
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

    local xian = ccui.ImageView:create("bg/xian.png");
    xian:setPosition(layout:getContentSize().width*0.5,layout:getContentSize().height*0.99);
    layout:addChild(xian);

    local image = ccui.ImageView:create("bg/tiao.png");
    image:setPosition(layout:getContentSize().width*0.5,layout:getContentSize().height*0.5);
    layout:addChild(image);

    local index = FontConfig.createWithSystemFont(tostring(i)..".", 20);
    layout:addChild(index);
    index:setPosition(layout:getContentSize().width*0.05,layout:getContentSize().height*0.7);

    local nameText = FontConfig.createWithSystemFont(FormotGameNickName(userInfo.nickName,nickNameLen), 20);
    nameText:setAnchorPoint(0,0.5);
    nameText:setPosition(layout:getContentSize().width*0.25,layout:getContentSize().height*0.7);
    layout:addChild(nameText);

    local score = FontConfig.createWithSystemFont(gameRealMoney(userInfo.i64Money), 20,cc.c3b(252,215,27));
    score:setAnchorPoint(0,0.5);
    layout:addChild(score);
    score:setPosition(layout:getContentSize().width*0.25,layout:getContentSize().height*0.26);

    local scoreBg = ccui.ImageView:create("bg/jinbi.png");
    layout:addChild(scoreBg);
    scoreBg:setPosition(layout:getContentSize().width*0.15,layout:getContentSize().height*0.27);

    return layout;
end

return TableLayer;
