
local TableLayer =  class("TableLayer", BaseWindow)

local TableLogic = require("qiangzhuangniuniu.TableLogic");
local ChipNodeManager = require("qiangzhuangniuniu.ChipNodeManager");
local HelpLayer = require("qiangzhuangniuniu.HelpLayer");
local PokerListBoard = require("qiangzhuangniuniu.PokerListBoard");
local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");
local RubbingCards = require("qiangzhuangniuniu.RubbingCards");
local MiCards = require("qiangzhuangniuniu.MiCards");
local qiangzhuangniuniu = require("qiangzhuangniuniu");

function TableLayer:scene(userScore,difen)

    local layer = TableLayer:create(userScore,difen);

    local scene = display.newScene("QznnScene");

    scene:addChild(layer);

    layer.runScene = scene;

    return scene;
end

function TableLayer:create(userScore,difen)
    Event:clearEventListener();
    
    local layer = TableLayer.new(userScore,difen);

    globalUnit.isFirstTimeInGame = false;

    return layer;
end

function TableLayer:getInstance()
    return _instance;
end

function TableLayer:ctor(userScore,difen)
    self.super.ctor(self, 0, true);
    PLAY_COUNT = 5;
    self.uNameId = uNameId;
    self.bDeskIndex = bDeskIndex or 0;
    self.bAutoCreate = bAutoCreate or false;
    self.bMaster = bMaster or 0;
    --GameMsg.init();
    self.userScore = userScore or PlatformLogic.loginResult.i64Money;

    local difenNum = {"0.10","1.00","10.00","50.00"}
    self.difen = difen or difenNum[globalUnit.iRoomIndex]

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
    self.Button_qiang = {};             --抢庄倍数
    self.Button_xiazhu = {};            --闲家倍数
    self.Image_pai = {};                --牌
    self.pokerListBoard = {};           --牌列表
    self.AtlasLabel_num = {};           --计算牛牛
    self.Node_player = {};              --玩家
    self.Image_head = {};               --头像
    self.Image_quan = {};               --光圈
    self.Text_name = {};                --昵称
    self.Text_jinbi = {};               --金币
    self.Image_zhuang = {};             --庄标识
    self.Image_tip = {};                --抢庄，不抢，闲倍数 状态
    self.Image_buqiang = {};            --不抢
    self.Node_qiang = {};               --抢
    self.AtlasLabel_qiangbeishu = {};   --抢倍数
    self.AtlasLabel_beishu = {};        --闲倍数
    self.Image_zhunbei = {};            --准备
    self.AtlasLabel_changefen ={};      --改变分数
    self.playerInfo = {};
    self.zhuangBeishu ={-1,-1,-1,-1,-1};    --抢庄倍数
    self.pangguan = {0,0,0,0,0};            --旁观状态
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
    self:pushGlobalEventInfo("I_R_M_EndMatchRoom",handler(self, self.onEndMatch))
    self:pushGlobalEventInfo("I_P_M_Login",handler(self, self.onReceiveLogin))--断线重连刷新
    self:pushGlobalEventInfo("I_R_M_DisConnect",handler(self, self.onReceiveLogin))--断线重连刷新

    self:initUI()

    self.super.onEnter(self)
end

function TableLayer:onExit()
    self.super.onExit(self);
    self:stopAllActions();
end

function TableLayer:initUI()

    self:createPokers();
    
    --基本按钮
    self:initGameNormalBtn();

    self:initMusic();
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

    self.AtlasLabel_difen:setString(self.difen);
    self.Image_shizhong:setPositionY(400)
    self.Node_gold:setLocalZOrder(10000)
    self.Node_you:setLocalZOrder(100)
    self.Node_more:setLocalZOrder(100)

    local winSize = cc.Director:getInstance():getWinSize()

    local btn = ccui.Button:create("guize/jixuyouxi.png","guize/jixuyouxi-on.png")
    btn:setPosition(winSize.width*0.4,winSize.height*0.35)
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

    self.Text_name[1]:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen));
    self.Text_name[1]:setFontSize(22)
    self.Text_jinbi[1]:setString(gameRealMoney(self.userScore))
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
    end
    -- if self.isClick == true then
 --        return;
 --    end
    
 --    if self.isPlaying ~= true then
 --     self.isClick = true;
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

        if globalUnit.nowTingId == 0 then
            performWithDelay(display.getRunningScene(), function() RoomLogic:close(); end,0.5);
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

function gameRealMoney(money)
    return string.format("%.2f", money/100);
end

function TableLayer:showDeskInfo(gameInfo)
    -- luaDump(gameInfo,"gameInfo")

end

function TableLayer:showFangjian()
    if self.isTouchLayer then
        return;
    end
    self.isTouchLayer = true;
    performWithDelay(self,function()  self.isTouchLayer = false end,1);
    qiangzhuangniuniu.erterRoom = true;
    dispatchEvent("matchRoom",globalUnit.selectedRoomID);
    self:showChangeLoading();
end

function TableLayer:onReceiveLogin()
    addScrollMessage("网络不太好哦，请检查网络")
    LoadingLayer:removeLoading();
    Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end);
end

function TableLayer:showChangeLoading()
    luaPrint("showChangeLoading-----------------")
    local scene = display.getRunningScene();

    LoadingLayer:createLoading(FontConfig.gFontConfig_22,"正在匹配,请稍后");

    if scene then
        local layer = scene:getChildByTag(9999);
        if layer then
            layer:updateLayerOpacity(0)
            if layer:getChildByName("enterText") then
                self:ChangeOldLayer(layer);--更改统一的loading界面
                self:startClock(layer) --创建启动倒计时
                self:cancelMatch(layer);
            end
        end
    end
end

--更改统一的loading界面
function TableLayer:ChangeOldLayer(layer)
    luaPrint("ChangeOldLayer------------");
    --隐藏进入房间字
    local enterText = layer:getChildByName("enterText");
    if enterText then
        enterText:setVisible(false);
    end
    --将动画向上移动
    local loadImage = layer:getChildByName("loadImage");
    if loadImage then
        loadImage:setPositionY(560);
        loadImage:removeSelf()
    end
    local winSize = cc.Director:getInstance():getWinSize();
    local enterText = cc.Sprite:create("game/ddz_fangjian.png");
    enterText:setPosition(winSize.width/2,winSize.height*0.65);
    enterText:setScale(0.5)
    layer:addChild(enterText)

    -- layer:updateLayerOpacity(200)
end

function TableLayer:startClock(layer)
    local times = 10
    local winSize = cc.Director:getInstance():getWinSize();
    local daojishi = FontConfig.createWithCharMap(tostring(times), "game/ddz_daojishizitiao.png", 34, 42, "+");
    daojishi:setPosition(winSize.width/2,winSize.height/2);
    layer:addChild(daojishi)

    daojishi:setString(tostring(times));
    local temp = tostring(times);
    -- local checkClockScheduler = nil;
    -- self.checkClockScheduler = schedule(self, function() 
    --     temp = temp -1;
    --     daojishi:setString(temp);
    --     if temp <= 0 then
    --         -- RoomLogic:close();
    --         self:sendCancelMatchMsg();
    --         self:stopAction(self.checkClockScheduler)
    --         self.checkClockScheduler = nil;
    --     end
    -- end, 1)

    local action1 = cc.DelayTime:create(1.0);
    local action2 = cc.CallFunc:create(function()
        temp = temp -1;
        if temp == 0 then
            -- RoomLogic:close();
            self:sendCancelMatchMsg();
            --self.Node_3:stopAllActions();
        elseif temp < 0 then
            temp = 0
        end

        local scene = display.getRunningScene();
        local layer = scene:getChildByTag(9999);
        if layer and daojishi and not tolua.isnull(daojishi) then 
            daojishi:setString(temp);
        end
    end);

    layer:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)));
end

function TableLayer:cancelMatch(layer)
    local winSize = cc.Director:getInstance():getWinSize();
    local btn = ccui.Button:create("game/ddz_quxiao.png","game/ddz_quxiao-on.png")
    btn:setPosition(winSize.width/2,winSize.height*0.35);
    layer:addChild(btn)
    btn:onClick(handler(self, self.onClickCancel))
end

function TableLayer:onClickCancel()
    luaPrint("TableLayer:onClickCancel")
    -- self:stopAction(self.checkClockScheduler)
    -- self.checkClockScheduler = nil; 
    --self.Node_3:stopAllActions();
    -- RoomLogic:close();
    self:sendCancelMatchMsg();
end

function TableLayer:sendCancelMatchMsg()
    local msg = {};
    msg.dwUserID = PlatformLogic.loginResult.dwUserID
    local cf = {
     {"dwUserID","INT"}
    }
    RoomLogic:send(RoomMsg.MDM_GR_LOGON,RoomMsg.ASS_END_MATCH_ROOM, msg, cf)
end

function TableLayer:onEndMatch()
    luaPrint("TableLayer 取消匹配",globalUnit.isEnterGame)
    LoadingLayer:removeLoading();
    Hall:exitGame(false,function() globalUnit.isEnterGame = false RoomLogic:close() end);
end


return TableLayer;
