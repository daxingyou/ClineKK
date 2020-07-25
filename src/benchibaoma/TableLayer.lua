

local TableLayer = class("TableLayer", BaseWindow)
local TableLogic = require("benchibaoma.TableLogic");
local ChipNodeManager = require("benchibaoma.ChipNodeManager");
local PopUpLayer = require("benchibaoma.PopUpLayer")

local Bar = require("qukuailian.QukuailianBar");
local LogBar = require("UserLog.LogBar");

local winSize = cc.Director:getInstance():getWinSize()

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
    BCBMInfo:init()

    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist","benchibaoma/game/benchibaoma.png")
    local uiTable = {
        Button_exit = {"Button_exit",0,1},
        Node_1 = {"Node_1",0},
        Node_4 = {"Node_4",0},
        Node_6 = {"Node_6",1},
        Node_5 = {"Node_5",1},

        Image_bg = "Image_bg",
        --Button_exit = "Button_exit",
    	--Node_1 = "Node_1",
        Text_meName = "Text_meName",
        Text_meGold = "Text_meGold",
        Button_useradd = "Button_useradd",

        Node_2 = "Node_2",
        Button_score1 = "Button_score1",
        Button_score2 = "Button_score2",
        Button_score3 = "Button_score3",
        Button_score4 = "Button_score4",
        Button_score5 = "Button_score5",
        Button_score6 = "Button_score6",
        Button_xuzhu = "Button_xuzhu",

        Node_3 = "Node_3",
        Node_8 = "Node_8",
        Button_xiazhu1 = "Button_xiazhu1",
        Button_xiazhu2 = "Button_xiazhu2",
        Button_xiazhu3 = "Button_xiazhu3",
        Button_xiazhu4 = "Button_xiazhu4",
        Button_xiazhu5 = "Button_xiazhu5",
        Button_xiazhu6 = "Button_xiazhu6",
        Button_xiazhu7 = "Button_xiazhu7",
        Button_xiazhu8 = "Button_xiazhu8",
        Text_score1 = "Text_score1",
        Text_score2 = "Text_score2",
        Text_score3 = "Text_score3",
        Text_score4 = "Text_score4",
        Text_score5 = "Text_score5",
        Text_score6 = "Text_score6",
        Text_score7 = "Text_score7",
        Text_score8 = "Text_score8",
        AtlasLabel_userxz1 = "AtlasLabel_userxz1",
        AtlasLabel_userxz2 = "AtlasLabel_userxz2",
        AtlasLabel_userxz3 = "AtlasLabel_userxz3",
        AtlasLabel_userxz4 = "AtlasLabel_userxz4",
        AtlasLabel_userxz5 = "AtlasLabel_userxz5",
        AtlasLabel_userxz6 = "AtlasLabel_userxz6",
        AtlasLabel_userxz7 = "AtlasLabel_userxz7",
        AtlasLabel_userxz8 = "AtlasLabel_userxz8",

        Node_9 = "Node_9",
       -- Image_select = "Image_select",
        Node_10 = "Node_10",
        Text_zhuangName = "Text_zhuangName",
        Text_zhuangGold = "Text_zhuangGold",
        Button_shangzhuang = "Button_shangzhuang",
        Text_zhuangNum = "Text_zhuangNum",
        Text_allchipin = "Text_allchipin",
        Node_11 = "Node_11",
        Image_state = "Image_state",
        AtlasLabel_time = "AtlasLabel_time",

        AtlasLabel_coin1 = "AtlasLabel_coin1",
        AtlasLabel_coin2 = "AtlasLabel_coin2",
        AtlasLabel_coin3 = "AtlasLabel_coin3",
        AtlasLabel_coin4 = "AtlasLabel_coin4",
        AtlasLabel_coin5 = "AtlasLabel_coin5",
        AtlasLabel_coin6 = "AtlasLabel_coin6",

        --Node_4 = "Node_4",
        Button_hideOther = "Button_hideOther",
        Button_otherWanjia = "Button_otherWanjia",
        Text_otherNum = "Text_otherNum",
        Panel_otherBg = "Panel_otherBg",
        ListView_otherBg = "ListView_otherBg",
        Panel_otherMsg = "Panel_otherMsg",
        Image_otherHead ="Image_otherHead",
        Image_headBg ="Image_headBg",
        Text_otherName = "Text_otherName",
        Text_otherMoney ="Text_otherMoney",

        --Node_6 = "Node_6",
        ListView_history = "ListView_history",

        Node_5 = "Node_5",
        Button_manager = "Button_manager",
        -- Panel_xiala = "Panel_xiala",
        -- Button_safe = "Button_safe",
        -- Button_rule = "Button_rule",
        -- Button_yinxiao = "Button_yinxiao",
        -- Button_yinyue = "Button_yinyue",
        Button_hideManager = "Button_hideManager",

        Node_7 = "Node_7",
        Image_startXiahu = "Image_startXiahu",
        Image_startXiazhuType = "Image_startXiazhuType",
        Image_changZhuang = "Image_changZhuang",
        Image_lianzhuang = "Image_lianzhuang",
        AtlasLabel_lianzhuang = "AtlasLabel_lianzhuang",
        Panel_dengdai = "Panel_dengdai",
        Button_bankList = "Button_bankList",
        Image_bankbg = "Image_bankbg",

    }
    loadNewCsb(self,"benchibaoma/tableLayer",uiTable)

    self:initData();

    --初始化按钮
    if globalUnit.isShowZJ then
        self.Panel_xiala = self.Node_5:getChildByName("Panel_xiala2");
        self.Button_zhanji = self.Panel_xiala:getChildByName("Button_zhanji");
    else
        self.Panel_xiala = self.Node_5:getChildByName("Panel_xiala1");
    end

    self.Button_safe = self.Panel_xiala:getChildByName("Button_safe");
    self.Button_rule = self.Panel_xiala:getChildByName("Button_rule");
    self.Button_yinxiao = self.Panel_xiala:getChildByName("Button_yinxiao");
    self.Button_yinyue = self.Panel_xiala:getChildByName("Button_yinyue");


    self.ChipManager = ChipNodeManager.new(self);
    self.ChipManager:startChipScheduler();

    self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
	self.tableLogic:enterGame();

    _instance = self;
    
end

function TableLayer:onEnter()

    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
     
    self:initUI()

    self:bindEvent()

    self.super.onEnter(self)
end

function TableLayer:bindEvent()

    self:pushEventInfo(BCBMInfo, "BCBMGameFree", handler(self, self.onBCBMGameFree))
    self:pushEventInfo(BCBMInfo, "BCBMGameStart", handler(self, self.onBCBMGameStart))
    self:pushEventInfo(BCBMInfo, "BCBMGamePlaceJetton", handler(self, self.onBCBMGamePlaceJetton))
    self:pushEventInfo(BCBMInfo, "BCBMGameEnd", handler(self, self.onBCBMGameEnd))
    self:pushEventInfo(BCBMInfo, "BCBMApplyBanker", handler(self, self.onBCBMApplyBanker))
    self:pushEventInfo(BCBMInfo, "BCBMChangeBanker", handler(self, self.onBCBMChangeBanker))
    self:pushEventInfo(BCBMInfo, "BCBMChangeUserScore", handler(self, self.onBCBMChangeUserScore))

    self:pushEventInfo(BCBMInfo, "BCBMPlaceJettonFail", handler(self, self.onBCBMPlaceJettonFail))
    self:pushEventInfo(BCBMInfo, "BCBMCancelBanker", handler(self, self.onBCBMCancelBanker))
    self:pushEventInfo(BCBMInfo, "BCBMSendScoreHistory", handler(self, self.onBCBMSendScoreHistory))
    self:pushEventInfo(BCBMInfo, "BCBMChangeSysBanker", handler(self, self.onBCBMChangeSysBanker))
    self:pushEventInfo(BCBMInfo, "BCBMGetBanker", handler(self, self.onBCBMGetBanker))
    --self:pushEventInfo(BCBMInfo, "BCBMUserCut", handler(self, self.onBCBMUserCut))
    self:pushEventInfo(BCBMInfo, "BCBMCancelCancel", handler(self, self.onBCBCancelCancel))
    self:pushEventInfo(BCBMInfo, "BCBMCancelSuccess", handler(self, self.onBCBCancelSuccess))
    self:pushEventInfo(BCBMInfo, "BCBMCancelBet", handler(self, self.onBCBMCancelBet))
    self:pushEventInfo(BCBMInfo,"ZhuangScore",handler(self, self.DealZhuangScore));
    self:pushEventInfo(BCBMInfo, "XuTouFail", handler(self, self.DealXuTouFail));

    self:pushGlobalEventInfo("APP_ENTER_BACKGROUND_EVENT",handler(self, self.refreshEnterBack));      --进入后台
    self:pushGlobalEventInfo("APP_ENTER_FOREGROUND_EVENT",handler(self, self.refreshBackGame));      --后台回来
    
end

function TableLayer:initData()
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3;

    self.checkCarTable = {}; --所有选择的车辆
    self.checkCarTablePos = {};

    self.checkNowNum = 23; --当前选择的车辆1-32

    self.otherMsgTable = {}; --其他用户的信息

    self.btn_scoreTable = {}; -- 下注的按钮

    self.chipType = 0;--选择的筹码

    self.ScoreHistoryTable = {};

    self.GameStatus = 26;--游戏状态(默认下注状态)26下注27开奖中

    self.isUserXiazhu = false; -- 自己这把是否下注
    self.isOtherXiazhu = false; -- 其他人这把是否下注

    self.WinXiaZhuPos = 1; --下注获胜的位置
    self.WinCheBiaoEndPos = 1;--下注获胜的车标位置1-32

    self.BankerWinScore = 0; --庄家获胜的金币
    self.UserWinScore = 0; --自己
    self.OtherWinScore = 0;    --用户

    self.BankerScore = 0; --庄家的金币
    self.UserScore = 0; --自己的金币
    self.lBetCondition = SettlementInfo:getConfigInfoByID(46);

    self.coinTextTable  = {};

    self.lApplyBankerCondition = 1000000; --上庄条件

    self.ApplyBankerNums = 0; --申请上庄人数

    self.ApplyBanerTable = {}; --申请上庄人数信息列表

    self.resuLtUserScore = {}; --存储自己上一轮所投金币

    self.Button_xuzhu.chipScore = -1;
    self.Button_xuzhu.xiazhuType = -1;
    self.isXiaZhu = false;--本局是否下注(弹本局你没有下注用)

    self.Image_di = {}; --底层背景

    self.AllChipInScore = 0; --总下注数量

    self.bankerLseatNo = -1; --庄家的逻辑位置

    self.tipTextTable = {}; --提示字符

    self.TextCeshi = 1;

    self.xiazhuScoreTable = {0,0,0,0,0,0,0,0} --每个区域所下分数
    self.xiazhuUserScoreTable = {0,0,0,0,0,0,0,0} --自己每个区域所下分数

    self.nBankerTime = 0;

    self.isGamePlaying = false;--断线重连开奖状态隐藏所有特效

    self.isGameStation = false;--且后台不处理任何消息

    self.chipPosY = 0;

    self.b_suo = false; -- 玩家是否可以退出

    self.t_bankTable = {};--上庄列表
    self.m_recordScore = {0,0,0,0,0,0,0,0};--记录上局下注金额
    self.m_playGameNum = 0;--傻瓜参与局数
end

function TableLayer:initUI()
    for i=1,32 do
    	local img_check = self.Node_9:getChildByName("Image_check"..i);
        if img_check then
            table.insert(self.checkCarTable,img_check)
            local posx = img_check:getPositionX()
            local posy = img_check:getPositionY()
            --luaPrint("pos",posx,posy)
            table.insert(self.checkCarTablePos,cc.p(posx,posy))

            local img_select = img_check:getChildByName("Image_select");
            img_select:setVisible(false);
            self.Image_di[i] = img_select;
        end
    end

    self.chipPosY = self["Button_score1"]:getPositionY();

    self:ChooseChip(1) --默认选择筹码1
 
    self:initOtherMsgPanle(); --其他玩家的列表

    self:initGameNormalBtn() --按钮

    self:showDeskInfo() --界面显示

    self:initcoinText();  --飘字效果

    self.Node_7:setVisible(false)

    self.Node_2:setLocalZOrder(10);

    local NodePos = cc.p(self.Node_5:getPosition());
    --区块链bar
    self.m_qklBar = Bar:create("benchibaoma",self);
    self.Image_bg:addChild(self.m_qklBar);
    self.m_qklBar:setPosition(NodePos.x-100,NodePos.y-45);
    
    if globalUnit.isShowZJ then
        self.m_logBar = LogBar:create(self);
        self.Image_bg:addChild(self.m_logBar);
    end

    --桌子号
    local size = self.Image_bg:getContentSize();
    local deskNoBg = ccui.ImageView:create("BG/whichtable.png")
    deskNoBg:setAnchorPoint(0.5,1)
    deskNoBg:setPosition(self.Button_exit:getContentSize().width/2,0)
    deskNoBg:setScale(0.8)
    self.Button_exit:addChild(deskNoBg)

    local deskNo = FontConfig.createWithCharMap(self.bDeskIndex+1,"game/bcbm_zhuohao.png",24,32,"0")
    deskNo:setPosition(35,deskNoBg:getContentSize().height/2)
    deskNo:setScale(0.6)
    deskNo:setAnchorPoint(1,0.5)
    deskNoBg:addChild(deskNo)
end

function TableLayer:showDengdaiTip()
    local skeleton_animation0 = self:getChildByName("skeleton_animation0")
    if skeleton_animation0 then
        self:removeChildByName("skeleton_animation0")
    end

    local WarnAnim = {
        name = "dengxiaju",
        json = "game/dengdai/dengdai.json",
        atlas = "game/dengdai/dengdai.atlas",
    }
    local WarnAnimName = "dengxiaju"
    addSkeletonAnimation(WarnAnim.name,WarnAnim.json,WarnAnim.atlas);
    local skeleton_animation = createSkeletonAnimation(WarnAnim.name,WarnAnim.json,WarnAnim.atlas);
    if skeleton_animation then
        self:addChild(skeleton_animation);
        skeleton_animation:setName("skeleton_animation0")
        skeleton_animation:setPosition(cc.p(winSize.width/2,winSize.height/2));
        skeleton_animation:setAnimation(0,WarnAnimName, true);
    end
end

function TableLayer:ShowDaojishi()  
    if self.isGamePlaying  then --断线重连隐藏特效
        return;
    end

    local skeleton_animation1 = self:getChildByName("skeleton_animation1")
    if skeleton_animation1 then
        self:removeChildByName("skeleton_animation1")
    end

    local WarnAnim = {
        name = "daojishi",
        json = "hall/game/daojishi/daojishi.json",
        atlas = "hall/game/daojishi/daojishi.atlas",
    }
    local WarnAnimName = "daojishi"
    addSkeletonAnimation(WarnAnim.name,WarnAnim.json,WarnAnim.atlas);
    local skeleton_animation = createSkeletonAnimation(WarnAnim.name,WarnAnim.json,WarnAnim.atlas);
    if skeleton_animation then
        self:addChild(skeleton_animation);
        skeleton_animation:setScale(2)
        skeleton_animation:setName("skeleton_animation1")
        skeleton_animation:setPosition(cc.p(winSize.width/2,winSize.height/2));
        skeleton_animation:setAnimation(0,WarnAnimName, false);
    end
end

function TableLayer:ShowKaishiXiazhu(temp)
    if self.isGamePlaying  then --断线重连隐藏特效
        return;
    end

    --先移除原先的动画
    local skeleton_animation2 = self:getChildByName("skeleton_animation2")
    if skeleton_animation2 then
        self:removeChildByName("skeleton_animation2")
    end

    local skeleton_animation3 = self:getChildByName("skeleton_animation3")
    if skeleton_animation3 then
        self:removeChildByName("skeleton_animation3")
    end

    --游戏开始下注动画
    local WarnAnimName = "kaishixiazhu"

    if temp then
        WarnAnimName = "tingzhixiazhu"
    end

    local WarnAnim = {
        name = "kaishixiazhu",
        json = "game/kaishixiazhu.json",
        atlas = "game/kaishixiazhu.atlas",
    } 

    addSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    local skeleton_animation = createSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    if skeleton_animation then
        self:addChild(skeleton_animation);
        skeleton_animation:setPosition(cc.p(winSize.width/2,winSize.height/2));
        if temp then
            skeleton_animation:setName("skeleton_animation3")
        else
            skeleton_animation:setName("skeleton_animation2")
        end
           
        skeleton_animation:setAnimation(0,WarnAnimName, false);
        performWithDelay(self,function() 
            luaPrint("skeleton_animation-----",skeleton_animation,tolua.isnull(skeleton_animation))
            if skeleton_animation and not tolua.isnull(skeleton_animation) then
                skeleton_animation:removeFromParent();
            end
        end,1.5);
    end

end

function TableLayer:ShowZhongjiang(pos)
    if self.isGamePlaying  then --断线重连隐藏特效
        return;
    end

    --先移除原先的
    local skeleton_animation4 = self.Node_9:getChildByName("skeleton_animation4")
    if skeleton_animation4 then
        self.Node_9:removeChildByName("skeleton_animation4")
    end

    --车标中奖特效
    local WarnAnimName = "chebiaozhongjiang"

    local WarnAnim = {
        name = WarnAnimName,
        json = "benchibaoma/game/zhongjiang/chebiaozhongjiang.json",
        atlas = "benchibaoma/game/zhongjiang/chebiaozhongjiang.atlas",
    } 

    addSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    local skeleton_animation = createSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    if skeleton_animation then
        skeleton_animation:setName("skeleton_animation4")
        self.Node_9:addChild(skeleton_animation);
        local pos = self.checkCarTablePos[self.WinCheBiaoEndPos]
        if self.checkCarTablePos[self.WinCheBiaoEndPos] then
            skeleton_animation:setPosition(pos);
        end
           
        skeleton_animation:setAnimation(0,WarnAnimName, false);
    end


    --显示中奖车的特效
    local temp = {"dabaoshijie","xiaobaoshijie","dabaoma","xiaobaoma","dabenchi","xiaobenchi","dadazhong","xiaodazhong"};
    local soundTemp = {"baoshijie","baoma","benchi","dazhong"};

    local che_animation = self.Image_bg:getChildByName("che_animation")
    if che_animation then
        self.Image_bg:removeChildByName("che_animation")
    end

    local animName = temp[self.WinXiaZhuPos];

    local skeleton_animation = createSkeletonAnimation(animName ,"benchibaoma/effect/"..animName..".json","benchibaoma/effect/"..animName..".atlas");
    if skeleton_animation then
        skeleton_animation:setName("che_animation")
        self.Image_bg:addChild(skeleton_animation);

        local bgSize = self.Image_bg:getContentSize();
        skeleton_animation:setPosition(bgSize.width/2,bgSize.height/2);
           
        skeleton_animation:setAnimation(0,animName, false);
        --播放音效
        audio.playSound("benchibaoma/game/music/"..soundTemp[math.floor((self.WinXiaZhuPos-1)/2)+1]..".mp3");

        self.Image_bg:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function()
            local che_animation = self.Image_bg:getChildByName("che_animation")
            if che_animation then
                self.Image_bg:removeChildByName("che_animation")
            end
        end)));
    end
end

function TableLayer:initcoinText()
    -- local pos= {cc.p(105,120),cc.p(100,620),cc.p(380,600)} --自己/其他人/庄家
    -- for i=1,3 do
    --      --得分
    --     local content = FontConfig.createWithCharMap("", "benchibaoma/game/bcbm_ying_1.png", 21, 27, "+");
    --     --content:setScale(0.3)
    --     content:setPosition(pos[i])
    --     content:setVisible(false)
    --     table.insert(self.coinTextTable,content)
    --     self:addChild(content,100)

    --     local content = FontConfig.createWithCharMap("", "benchibaoma/game/bcbm_shu_1.png", 21, 27, "+");
    --     --content:setScale(0.3)
    --     content:setPosition(pos[i])
    --     content:setVisible(false)
    --     table.insert(self.coinTextTable,content)
    --     self:addChild(content,100)
    -- end
    for i=1,6 do
        table.insert(self.coinTextTable,self["AtlasLabel_coin"..i])
    end
    --luaDump(self.coinTextTable)
end


--界面信息的初始化
function TableLayer:showDeskInfo()
    --luaDump(PlatformLogic.loginResult)
    self.Text_meName:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen));
    -- self.UserScore = PlatformLogic.loginResult.i64Money;
    -- luaPrint("自己的金币-------1111111---------",self.UserScore)
    -- self:ScoreToMoney(self.Text_meGold,self.UserScore)

    --刷新其他玩家信息
    self:flushOtherMsg()

    --刷新申请庄人数
    self.Text_zhuangNum:setString("0")

    self.Text_zhuangName:setString("");
    self.Text_zhuangGold:setString(" ")

    --设置所下注金额
    self:ScoreToMoney(self.Text_allchipin,self.AllChipInScore)

    self.Image_startXiahu:setVisible(false)
    self.Image_changZhuang:setVisible(false)
    self.Image_lianzhuang:setVisible(false)
    self.Panel_dengdai:setVisible(false)

    self.AtlasLabel_coin3:setPosition(10,620)
    self.AtlasLabel_coin4:setPosition(10,620)
    self.AtlasLabel_coin3:setAnchorPoint(0,0.5)
    self.AtlasLabel_coin4:setAnchorPoint(0,0.5)

end

--初始化按钮
function TableLayer:initGameNormalBtn()

    --self.Button_useradd:addClickEventListener(function(sender) self:onClickBank(sender) end)
    self.Button_xuzhu:setEnabled(false)
    --self.Button_xuzhu:onClick(handler(self,self.onClickXuzhu))
    self.Button_xuzhu:onClick(function(sender) self:onClickXuzhu(sender) end);

    --投资钱的数额
    for i = 1,6 do
        if self["Button_score"..i] then
            self["Button_score"..i]:addClickEventListener(function(sender) 
                self:onClickScoreCallBack(sender); 
            end);
            self["Button_score"..i]:setTag(i);
        end
    end

    --投钱区
    for i = 1,8 do
        if self["Button_xiazhu"..i] then
            self["Button_xiazhu"..i]:addTouchEventListener(function(sender,event) 
                self:onClickCastCallBack(sender,event); 
            end);
            self["Button_xiazhu"..i]:setTag(i);
        end
    end

    for i = 1,8 do
        if self["Text_score"..i] then
            self["Text_score"..i]:setString(" ")
        end
    end

    for i = 1,8 do
        if self["AtlasLabel_userxz"..i] then
            self["AtlasLabel_userxz"..i]:setString(" ")
        end
    end
    
    self.Button_hideOther:onClick(handler(self,function(sender)  self.Panel_otherBg:setVisible(false) self.Button_hideOther:setVisible(false) end))
    self.Button_otherWanjia:onClick(handler(self,function(sender)  self.Panel_otherBg:setVisible(true) self.Button_hideOther:setVisible(true) end))
    --self.Button_hideOther:addClickEventListener(function(sender)  self.Panel_otherBg:setVisible(false) self.Button_hideOther:setVisible(false) end);
    --self.Button_otherWanjia:addClickEventListener(function(sender) self.Panel_otherBg:setVisible(true) self.Button_hideOther:setVisible(true) end);

    self.Button_shangzhuang:setTag(1);
    self.Button_shangzhuang:onClick(handler(self,self.onClickApplyShangZhuang))
    --self.Button_shangzhuang:addClickEventListener(function(sender) self:onClickApplyShangZhuang(sender) end);

    self.Button_exit:onClick(handler(self,self.onClickExit))
    --self.Button_exit:addClickEventListener(function(sender) self:onClickExit(sender) end);

    self.Panel_xiala:setVisible(false);
    self.Button_hideManager:setVisible(false);
    self.Button_manager:onClick(handler(self,function(sender) self.Panel_xiala:setVisible(true) self.Button_hideManager:setVisible(true); end))
    self.Button_hideManager:onClick(handler(self,function(sender) self.Panel_xiala:setVisible(false) self.Button_hideManager:setVisible(false); end))
    --self.Button_manager:addClickEventListener(function(sender) self.Panel_xiala:setVisible(true) self.Button_hideManager:setVisible(true); end);
    --self.Button_hideManager:addClickEventListener(function(sender) self.Panel_xiala:setVisible(false) self.Button_hideManager:setVisible(false); end);
    self.Button_safe:loadTextures("game/bcbm_yuerbao.png","game/bcbm_yuerbao-on.png")
    self.Button_safe:onClick(handler(self,self.onClickBank))
    self.Button_rule:onClick(handler(self,function(sender) self:addChild(PopUpLayer:create(),100) end))
    -- self.Button_safe:addClickEventListener(function(sender) self:onClickBank(sender) end)
    -- self.Button_rule:addClickEventListener(function(sender) self:addChild(PopUpLayer:create(),100) end) 

    self.Button_yinyue:onClick(handler(self,self.onClickYinyue))
    --self.Button_yinyue:addClickEventListener(function(sender) self:onClickYinyue(sender) end)
    local isMusic = getMusicIsPlay();
    if isMusic then
        self.Button_yinyue:setTag(2);
    else
        self.Button_yinyue:setTag(1);
    end
    self:onClickYinyue(self.Button_yinyue)

    --self.Button_yinxiao:setTag(1);
    self.Button_yinxiao:onClick(handler(self,self.onClickYinxiao))
    --self.Button_yinxiao:addClickEventListener(function(sender) self:onClickYinxiao(sender) end)
    local isEffect = getEffectIsPlay();
    if isEffect then
        self.Button_yinxiao:setTag(2);
    else
        self.Button_yinxiao:setTag(1);
    end
    self:onClickYinxiao(self.Button_yinxiao)

    if self.Button_zhanji then
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

function TableLayer:initOtherMsgPanle()
   --其他用户信息的显示隐藏
    self.Button_hideOther:setVisible(false)
    self.Panel_otherBg:setVisible(false)
    if self.Panel_otherBg then
        local ListView_otherBg = self.Panel_otherBg:getChildByName("ListView_otherBg");
        local sizeScroll = ListView_otherBg:getContentSize();
        local posScrollX,posScrollY = ListView_otherBg:getPosition();
        self.Panel_otherMsg = ListView_otherBg:getChildByName("Panel_otherMsg");
        self.Panel_otherMsg:retain();
        -- 获取样本战绩信息的容器
        self.rankTableView = cc.TableView:create(cc.size(sizeScroll.width,sizeScroll.height));
        if self.rankTableView then
            self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
            self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
            self.rankTableView:setPosition(cc.p(posScrollX,posScrollY));
           -- self.rankTableView:setScrollBarColor(cc.RED); --–滚动条的颜色 
            self.rankTableView:setDelegate();

            self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
            self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
            self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
            self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
            self.rankTableView:reloadData();
            self.Panel_otherBg:addChild(self.rankTableView);
        end
        ListView_otherBg:removeFromParent();
    end
end

function TableLayer:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y,view:getViewSize().height);
end  
  
function TableLayer:Rank_cellSizeForTable(view, idx)  

    local width = self.Panel_otherMsg:getContentSize().width;
    local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return width, height;  
end  
  
function TableLayer:Rank_numberOfCellsInTableView(view)  
    --luaPrint("Rank_numberOfCellsInTableView",table.nums(self.rankInfoTable))
    return table.nums(self.otherMsgTable);
end  
  
function TableLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self.Panel_otherMsg:clone(); 
        rankItem:setPosition(cc.p(0,0));
        if rankItem then
            self:setRankInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("Panel_otherMsg");
        self:setRankInfo(rankItem,index);
    end
    
    return cell;
end  

function TableLayer:setRankInfo(rankItem,index)
   -- luaPrint("TableLayer:setRankInfo--------",index)
    local userInfo = self.otherMsgTable[index];
   --luaDump(self.otherMsgTable,"infoTable2")
    if userInfo then
        local nameText = rankItem:getChildByName("Text_otherName");
        if nameText then
            nameText:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
        end

        local Text_otherMoney = rankItem:getChildByName("Text_otherMoney");
        if Text_otherMoney then
            self:ScoreToMoney(Text_otherMoney,userInfo.i64Money)
        end
        
        local Image_headBg = rankItem:getChildByName("Image_headBg"); 
        if Image_headBg then
            Image_headBg:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy))
            --Image_headBg:setVisible(false)
        end
        local Image_otherHead = rankItem:getChildByName("Image_otherHead");
        if Image_otherHead then
           
        end
    end
    
end

--刷新庄家信息
function TableLayer:flushBankerMsg()
    if self.bankerLseatNo ~= -1 then
        local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.bankerLseatNo);
        if userInfo then
            self.BankerScore = userInfo.i64Money;
            self:ScoreToMoney(self.Text_zhuangGold,self.BankerScore)
        end
    end
end

function TableLayer:baoxian(data)
    self.UserScore = self.UserScore + data.OperatScore;
    self:ScoreToMoney(self.Text_meGold,self.UserScore)
    if self.bankerLseatNo == self.tableLogic._mySeatNo then --庄家是自己
        self.BankerScore = self.BankerScore + data.OperatScore;
        self:ScoreToMoney(self.Text_zhuangGold,self.BankerScore)
    end

    luaPrint("baoxian",self:getGameState(),GameMsg.GS_Play);
    if self:getGameState() == GameMsg.GS_Play then
        self:ChipJundge();
    end

    self:setXuTouButtonEnable();
end

--保险箱
function TableLayer:onClickBank(sender)
    luaPrint("TableLayer:onClickBank保险箱")
    createBank(function (data)
        self:baoxian(data)
    end,self:getGameState() == 26);
end

function TableLayer:onClickYinyue(sender)
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    local senderTag = sender:getTag();
    if senderTag == 1 then
        sender:setTag(2);
        setMusicIsPlay(false)
        sender:loadTextures("bcbm_yinyuex.png","bcbm_yinyuex-on.png","bcbm_yinyuex-on.png",UI_TEX_TYPE_PLIST)
    else
        sender:setTag(1);
        setMusicIsPlay(true)
        self:playBcbmMusic(2);
        sender:loadTextures("bcbm_yinyue.png","bcbm_yinyue-on.png","bcbm_yinyue-on.png",UI_TEX_TYPE_PLIST)
    end
end

function TableLayer:onClickYinxiao(sender)
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    local senderTag = sender:getTag();
    if senderTag == 1 then
        sender:setTag(2);
        setEffectIsPlay(false)
        sender:loadTextures("bcbm_yinxiaox.png","bcbm_yinxiaox-on.png","bcbm_yinxiaox-on.png",UI_TEX_TYPE_PLIST)
    else
        sender:setTag(1);
        setEffectIsPlay(true)
        sender:loadTextures("bcbm_yinxiao.png","bcbm_yinxiao-on.png","bcbm_yinxiao-on.png",UI_TEX_TYPE_PLIST)
    end
end

function TableLayer:onClickXuzhu(sender)
    luaPrint("TableLayer:onClickXuzhu")
    -- if self.Button_xuzhu.chipScore == -1 or self.Button_xuzhu.xiazhuType == -1 then
    --     self:TipTextShow("你还未下注，无法续注！");
    --     return;
    -- end
   
    if self:getGameState() == 26 then
        --luaPrint("xiazhu",self.Button_xuzhu.xiazhuType,self.Button_xuzhu.chipScore)
        --self.tableLogic:sendPlaceJetton(self.Button_xuzhu.xiazhuType,self.Button_xuzhu.chipScore)
    else
        self:TipTextShow("非下注状态,请稍等!");
    end

    local score = 0;
    for k,v in pairs(self.m_recordScore) do
        score = score + v;
    end

    if self.UserScore < score then
        self:showMsgString("金币不足！");
        showBuyTip();
        return;
    end

    self:recordAddScore();
    
end

--投资钱的数额按钮回调
function TableLayer:onClickScoreCallBack(sender)
    local senderTag = sender:getTag();
    luaPrint("投资钱的数额按钮回调",senderTag);
    self:ChooseChip(senderTag);

end

--投钱区按钮回调
function TableLayer:onClickCastCallBack(sender,event)
    local senderTag = sender:getTag();
    luaPrint("投钱区按钮回调",senderTag,self.UserScore);
    local Image_anliang = sender:getChildByName("Image_anliang");
    if Image_anliang then
        --luaPrint("------------------------",event)
        if event == ccui.TouchEventType.began then
            Image_anliang:setVisible(true)  
        elseif event == ccui.TouchEventType.ended then
            Image_anliang:setVisible(false) 
            if self:getGameState() == 27 then
                self:TipTextShow("游戏开奖中,不能下注!");
                return;
            end 
            -- if self.bankerLseatNo == -1 then
            --     self:TipTextShow("无人上庄,不能下注!");
            --     return;
            -- end
        
            if self.bankerLseatNo == self.tableLogic._mySeatNo and self:getGameState() == 26 then
                self:TipTextShow("庄家不能下注!");
                return;
            end

            local mySeatNo = self.tableLogic:getMySeatNo();
            local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
            if userInfo then
                if userInfo.i64Money < self.lBetCondition then
                    -- if self.Button_xuzhu.chipScore == -1 or self.Button_xuzhu.xiazhuType == -1 then
                        local num = self.lBetCondition/100
                        self:TipTextShow("下注失败，您必须有"..num.."金币才能下注");
                        showBuyTip();
                        return;
                    -- end

                end

            end

            if self.UserScore < 100 and self:getGameState() == 26 then
                self:TipTextShow("金币不足!");
                showBuyTip();
                return;
            end

            local score = 1;
            if self.chipType == 1 then
                score = 100
            elseif self.chipType == 2 then
                score = 1000
            elseif self.chipType == 3 then
                score = 5000
            elseif self.chipType == 4 then
                score = 10000
            elseif self.chipType == 5 then
                score = 50000
            elseif self.chipType == 6 then
                score = 100000
            end
            if self:getGameState() == 26 then
                --luaPrint("xiazhu",senderTag,score)
                self.tableLogic:sendPlaceJetton(senderTag,score)
            else
                self:TipTextShow("请稍后,还没有到下注时间！");
            end
        elseif event == ccui.TouchEventType.canceled then
            Image_anliang:setVisible(false)  
        end
       
    end 

end

--退出
function TableLayer:onClickExit()
    luaPrint("TableLayer:onClickExit玩家退出",self.isXiaZhu)
    if self.isXiaZhu then--b_suo
        addScrollMessage("本局游戏您已参与,请等待开奖阶段结束。");
        return;
    end
    if self.bankerLseatNo == self.tableLogic._mySeatNo then
        self:TipTextShow("庄家不能离开！");
        return;
    end 

    local func = function()
        self.tableLogic:sendUserUp();
        self.tableLogic:sendForceQuit();
    end

    Hall:exitGame(false,func)   
end

function TableLayer:onClickApplyShangZhuang(sender)
    luaPrint("TableLayer:onClickApplyShangZhuang")
    local tag = sender:getTag();
    audio.playSound(GAME_SOUND_BUTTON);

    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.tableLogic._mySeatNo);
    --luaDump(userInfo)
    if userInfo and tag == 1 then
        luaPrint("------------self.UserScore----",self.UserScore,self.lApplyBankerCondition)
        if self.UserScore < self.lApplyBankerCondition then
            local num = self.lApplyBankerCondition/100
            self:TipTextShow("申请最少需要"..num.."金币");
            showBuyTip();
            return;
        end
    end
    
    if tag == 1 then
        self.tableLogic:sendApplyZhuang();
    elseif tag == 2 then--下庄
        self.tableLogic:sendCancelApplyZhuang(); --取消申请上庄
    elseif tag == 3 then--取消下庄
        self.tableLogic:sendCancelCancel();
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

    self.chipType = chipType;
    for i = 1,6 do
        self["Button_score"..i]:setPositionY(self.chipPosY);
        self:ShowChipAction(self["Button_score"..i],false);
        if i == chipType and self["Button_score"..i]:isEnabled() then
            self["Button_score"..i]:setPositionY(self.chipPosY+10);
            self:ShowChipAction(self["Button_score"..i],true);
        end
    end
end

function TableLayer:showCastBth(flag)
    for i = 1,6 do
        self["Button_score"..i]:setEnabled(flag)
    end
    -- for i = 1,8 do
    --     self["Button_xiazhu"..i]:setEnabled(flag)
    -- end
    --self.Button_xuzhu:setEnabled(false)

    if flag then
        --self.Button_xuzhu:setEnabled(false)

        self:ChipJundge();
        self:ChooseChip(self.chipType);
    else
        for i = 1,6 do
            self["Button_score"..i]:setPositionY(self.chipPosY);
            self:ShowChipAction(self["Button_score"..i],false);
        end
    end
end

--根据自己拥有的金额判断筹码置灰
function TableLayer:ChipJundge()
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.tableLogic._mySeatNo);
    if userInfo then
        local money = self.UserScore;
        local num = 0;--有多少的筹码可以使用
        if money>=100000 then
            num = 6;
        elseif money>=50000 then
            num = 5;
        elseif money>=10000 then
            num = 4;
        elseif money>=5000 then
            num = 3;
        elseif money>=1000 then
            num = 2;
        elseif money>=100 then
            num = 1;
        end

        local flag = true;
        for i = 1,6 do
            self["Button_score"..i]:setEnabled(false);
            if i <= num then
                flag = false;
                self["Button_score"..i]:setEnabled(true);
                if money < self:getChipTypeByScore(self.chipType) then
                    self:ChooseChip(num);
                else
                    if self.chipType == 0 then
                        self.chipType = 1;
                    end

                    self:ChooseChip(self.chipType);
                end
            end
        end

        if flag then
            self:ChooseChip(0);
        end
    end

end

function TableLayer:showZhuangTips(tipsCode)
    self.Node_7:setVisible(true);
    self.Image_startXiahu:setVisible(false)
    --self.Image_changZhuang:setVisible(false)
    self.Image_lianzhuang:setVisible(false)
    self.Panel_dengdai:setVisible(false)
    if tipsCode == 1 then --开始下注

        
        -- self.Image_startXiazhuType:loadTexture("bcbm_kaishixiazhu.png",UI_TEX_TYPE_PLIST)
        -- self.Image_startXiahu:setVisible(true)
        -- performWithDelay(self.Image_startXiahu,function() self.Image_startXiahu:setVisible(false); end,1);
    elseif tipsCode == 2 then --停止下注
        -- self:playBcbmMusic(11)
        -- self.Image_startXiazhuType:loadTexture("bcbm_tingzhixiazhu.png",UI_TEX_TYPE_PLIST)
        -- self.Image_startXiahu:setVisible(true)
        -- performWithDelay(self.Image_startXiahu,function() self.Image_startXiahu:setVisible(false); end,1);
    elseif tipsCode == 3 then --庄家轮换
        
    elseif tipsCode == 4 then --连庄次数
        self.AtlasLabel_lianzhuang:setString(self.nBankerTime)
        self.Image_lianzhuang:setVisible(true)
        performWithDelay(self.Image_lianzhuang,function() self.Image_lianzhuang:setVisible(false); end,1); 
    elseif tipsCode == 5 then
        --self.Panel_dengdai:setVisible(true)
        self:showDengdaiTip()
        for i = 1,8 do
            if self["Button_xiazhu"..i] then
                self["Button_xiazhu"..i]:setEnabled(false)
            end
        end

        --倒计时动画可能移除不了(预防)
        local skeleton_animation1 = self:getChildByName("skeleton_animation1")
        if skeleton_animation1 then
            self:removeChildByName("skeleton_animation1")
        end
    end
end

function TableLayer:showChangeZhuang()
    self:playBcbmMusic(10)
    self.Node_7:setVisible(true);
    self.Image_changZhuang:setVisible(true)
    performWithDelay(self.Image_changZhuang,function() self.Image_changZhuang:setVisible(false); end,1);
end


--停止所有动画
function TableLayer:hideRunRoundAnimation()
    --转圈动画
    self.Image_di[1]:stopAllActions();
    for i=1,32 do
        local img_check = self.Node_9:getChildByName("Image_check"..i);
        if img_check then
            local img_select = img_check:getChildByName("Image_select");
            if img_select then
                img_select:setVisible(false);
            end
        end
    end

    for i=1,8 do
        local Image_light =  self["Button_xiazhu"..i]:getChildByName("Image_light");
        if Image_light then
            Image_light:stopAllActions();
            Image_light:setVisible(false)
        end

        local Image_lightdi =  self["Button_xiazhu"..i]:getChildByName("Image_lightdi");
        if Image_lightdi then
            Image_lightdi:stopAllActions();
            Image_lightdi:setVisible(false)
        end
    end

    self.xiazhuScoreTable = {0,0,0,0,0,0,0,0} --每个区域所下分数
    for i = 1,8 do
        if self["Text_score"..i] then
            self["Text_score"..i]:setString(" ")
        end
    end

    self.xiazhuUserScoreTable = {0,0,0,0,0,0,0,0} --自己每个区域所下分数
    for i = 1,8 do
        if self["AtlasLabel_userxz"..i] then
            self["AtlasLabel_userxz"..i]:setString(" ")
        end
    end

    self.AllChipInScore = 0;
    --设置所下注金额
    self:ScoreToMoney(self.Text_allchipin,self.AllChipInScore)
end

-- 游戏开始转
function TableLayer:startRunRound(iStarPos, iEndPos)
    luaPrint("开始转圈---------------iStarPos, iEndPos------",iStarPos, iEndPos)
    if iStarPos == 0 then --游戏刚开始是0自己改为1
        iStarPos = 1;
    end
    if iStarPos < 1 or iStarPos > 32 or iEndPos < 1 or iEndPos > 32 then
        luaPrint("转圈的起始位置或者结束位置出错",iStarPos, iEndPos)
        return;
    end
    self._startPos = iStarPos;
    self._endPos = iEndPos;
    self._turnCount = 0;
    self._count = self._startPos;
    self.startCount = 0;
    self.isRoundFlag =1;

    if self._startPos >= self._endPos then
        self.zongCount =32*3+ self._endPos -self._startPos;
        self.MaxTurnCount = 3;
    else
        self.zongCount =32*2+ self._endPos -self._startPos;
        self.MaxTurnCount = 2;
    end

    self:turnRound();
end

function TableLayer:turnRound()
    local dTime = 0.03;
    if self._count > 32 then
        self._count = 1;
        self._turnCount = self._turnCount + 1;
    end

    self.startCount =self.startCount + 1;
    if self.startCount <= 5 then
        dTime = (102 - 20 *self.startCount)/100
    end
    if self.zongCount-self.startCount<= 5 then
        dTime = (102 - 20 *(self.zongCount-self.startCount))/100
    end
    if (self._turnCount == self.MaxTurnCount and self._count > self._endPos) or (self._turnCount == self.MaxTurnCount +1)then
        self:showResult();
        return;
    end

    

    self.Image_di[1]:runAction(cc.Sequence:create(cc.CallFunc:create(function() 
        if self._count > 1 then
            self.Image_di[self._count-1]:setVisible(false);
        else
            self.Image_di[32]:setVisible(false);
        end
        --播放音效
        if self.startCount <= 5 or (self.zongCount-self.startCount<= 5) then
            self:playBcbmMusic(7)
        else
            if self.isRoundFlag == 1 then
                self:playBcbmMusic(7)
                self.isRoundFlag = 2
            elseif self.isRoundFlag == 2 then
                self.isRoundFlag = 3
            else
                self.isRoundFlag = 1
            end
        end

        -- if dTime == 0.03 and self.isRoundFlag then
        --     self:playsoundMusic(self.zongCount-10)
        --     self.isRoundFlag = nil;
        -- end

        luaPrint("self._count",self._count)
        self.Image_di[self._count]:setVisible(true);
        self._count = self._count + 1;
        end),
        cc.DelayTime:create(dTime), 
        cc.CallFunc:create(function() self:turnRound(); end)))
end

function TableLayer:playsoundMusic(timeCounts)
    local count = timeCounts *0.5;
    local times = timeCounts *0.03;
    local dTime = times/count;
    local runSoundCheduler = nil;
    luaPrint("dTime",dTime,times,timeCounts)
    runSoundCheduler = schedule(self, function() 
        self:playBcbmMusic(7)
        times = times - dTime;
        if times<= 0 then
            self:stopAction(runSoundCheduler)
            runSoundCheduler = nil;
        end
    end, dTime)
end

function TableLayer:startClock(num)
    luaPrint("启动倒计时--",num)
    if num == nil or num == "" then
        luaPrint("启动倒计时出错")
        return;
    end
    self:stopAction(self.checkClockScheduler)
    self.checkClockScheduler = nil;

    self.AtlasLabel_time:setString(tostring(num));
    local temp = tostring(num);
    local checkClockScheduler = nil;
    local isGameColck = false;--是否需要闹钟
    self.checkClockScheduler = schedule(self, function() 
        temp = temp -1;
        if temp == 3 and self:getGameState() == 26 then
            self:ShowDaojishi()
            isGameColck = true;
            self:playBcbmMusic(5)
        elseif temp == 2 and isGameColck then
            self:playBcbmMusic(5)
        elseif temp == 1 and isGameColck then
            self:playBcbmMusic(5)
        end
        self.AtlasLabel_time:setString(temp);
        if temp <= 0 then
            self:stopAction(self.checkClockScheduler)
            self.checkClockScheduler = nil;
            self.AtlasLabel_time:setString(0);
        end
    end, 1)
end

--刷新其他玩家信息
function TableLayer:flushOtherMsg()
    luaPrint("有玩家进入或者退出,刷新界面")
    local userCount = self.tableLogic:getOnlineUserCount();
    local num = userCount -1;
    self.Text_otherNum:setString("("..num..")");
    self.otherMsgTable  = self:getOthersTable();
    if self.rankTableView then
        self:CommomFunc_TableViewReloadData_Vertical(self.rankTableView, self.Panel_otherMsg:getContentSize(), false);
    end
end

--刷新上庄申请人数
function TableLayer:flushApplyBankerNum(lSeatNo,isMove)
    if lSeatNo == 255 or lSeatNo == nil then
        return;
    end
    local isfind = self:isInclude(lSeatNo,self.ApplyBanerTable);
    luaPrint("flushApplyBankerNum",lSeatNo,isMove,isfind)
    if isMove then
        if isfind then
            table.removebyvalue(self.ApplyBanerTable,lSeatNo)
        end
    else
        if not isfind then
            table.insert(self.ApplyBanerTable,lSeatNo)
        end
    end
    --luaDump(self.ApplyBanerTable,"self.ApplyBanerTable")
    luaPrint("上庄人数.....",count)
    local count = table.nums(self.ApplyBanerTable);
    self.Text_zhuangNum:setString(count)
end

function TableLayer:isInclude(value, tab)
    for k,v in pairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end

function TableLayer:isMeApplyBanker()
    local value = self.tableLogic._mySeatNo;
    for k,v in pairs(self.ApplyBanerTable) do
      if v == value then
          return true
      end
    end
    return false
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
            --pTableView:setContentOffset(currOffSet);
        end
    end    
end

--路子
function TableLayer:showHistory(history)
   -- luaDump(history,"history")
    self.ListView_history:removeAllChildren();
    local _count = 0;
    for i=1,#history do
        if history[i] and history[i] > 0 then 
            _count = _count + 1;
        end
    end

    for i=1,#history do
        if history[i] and history[i] > 0 then 
            local layout = ccui.Layout:create();
            layout:setContentSize(cc.size(80, 68));

            local imgPath = "bcbm_chebiaodi_2.png"
            if history[i] == 2 or history[i] == 4 or history[i] == 6 or history[i] == 8 then
                imgPath = "bcbm_chebiaodi.png" 
            end
            local dikuang = cc.Sprite:createWithSpriteFrameName(imgPath)
            dikuang:setPosition(40,34)
            dikuang:setScale(0.8)
            local content = cc.Sprite:createWithSpriteFrameName("bcbm_cm_"..history[i]..".png")
            content:setScale(0.95)
            if history[i] == 2 or history[i] == 4 or history[i] == 8 then
                content:setScale(0.8)     
            end
            content:setPosition(42,39)
            dikuang:addChild(content,1)
            layout:addChild(dikuang)

            luaPrint("--------------",i == _count,i,_count)
            if i == _count then
                self.Historyxinzi = cc.Sprite:createWithSpriteFrameName("bcbm_xin.png");
                --new:setPosition(cc.p(12,33));
                --new:setScale(0.8);
                self.Historyxinzi:setPosition(55,60)
                layout:addChild(self.Historyxinzi,3);

                local dikuangLight = "bcbm_faguangquan.png"
                if history[i] == 2 or history[i] == 4 or history[i] == 6 or history[i] == 8 then
                    dikuangLight = "bcbm_faguangquan_2.png"
                end
                self.Historylightbg = cc.Sprite:createWithSpriteFrameName(dikuangLight);
                self.Historylightbg:setScale(0.8)
                self.Historylightbg:setPosition(40,34)
                layout:addChild(self.Historylightbg,2);
            end
            
            self.ListView_history:pushBackCustomItem(layout);
        end
    end
    self.ListView_history:scrollToPercentVertical(100,0.1,true);
end


function TableLayer:setStateStr(GameStatus)
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    local str = ""
    if GameStatus == 26 then
        if isHaveBankLayer() then
            createBank(function (data)
                self:baoxian(data)
            end,true);
        end
        self.Image_state:loadTexture("bcbm_xiazhuzhong.png",UI_TEX_TYPE_PLIST)
    elseif GameStatus == 27 then 
        if isHaveBankLayer() then
            createBank(function (data)
                self:baoxian(data)
            end,false);
        end
        self.Image_state:loadTexture("bcbm_kaijiangzhong.png",UI_TEX_TYPE_PLIST)
    end
    self.GameStatus = GameStatus;

end

function TableLayer:getGameState()
   return self.GameStatus
end

function TableLayer:refreshUserInfo(event)

end

function TableLayer:showResult()
    if self.isGamePlaying  then --断线重连隐藏特效
        return;
    end

    --胜利的结果
    self:ShowZhongjiang();--中奖特效
    self.ChipManager:ResultChipRemove(self.WinXiaZhuPos);--播放筹码移动动画
    if self.Historyxinzi and self.Historylightbg then
        self.Historyxinzi:setVisible(false);
        self.Historylightbg:setVisible(false)
    end

    local Image_light =  self["Button_xiazhu"..self.WinXiaZhuPos]:getChildByName("Image_light");
    if Image_light then
        Image_light:setVisible(true)
        local action1 =  cc.FadeOut:create(0.25);
        local action2 =  cc.FadeIn:create(0.25);
        local repeatAction = cc.Repeat:create(cc.Sequence:create(action1,action2),3);
        Image_light:runAction(cc.Sequence:create(repeatAction))
    end

    local Image_lightdi =  self["Button_xiazhu"..self.WinXiaZhuPos]:getChildByName("Image_lightdi");
    if Image_lightdi then
        Image_lightdi:setVisible(true)  
        local action1 =  cc.FadeOut:create(0.25);
        local action2 =  cc.FadeIn:create(0.25);
        local repeatAction = cc.Repeat:create(cc.Sequence:create(action1,action2),3);
        Image_lightdi:runAction(cc.Sequence:create(repeatAction))
    end 

    -- local castNode = self["Button_cast"..k];
    -- local castWinSp = castNode:getChildByName("Image_win");
    -- castWinSp:setVisible(true);
    -- castWinSp:setOpacity(0);
    -- local fadeOutAction = cc.FadeOut:create(0.15);
    -- local fadeInAction = cc.FadeIn:create(0.15);
    -- local repeatAction = cc.Repeat:create(cc.Sequence:create(fadeInAction,fadeOutAction),3);

    -- castWinSp:runAction(cc.Sequence:create(repeatAction,cc.CallFunc:create(function()
    --     castWinSp:setVisible(false);
    -- end)))
    self:showPlayGameNum();

end

function TableLayer:updatePlayNum()

    if self.isXiaZhu == false and self.bankerLseatNo ~= self.tableLogic._mySeatNo then
        self.m_playGameNum = self.m_playGameNum + 1;
    end

    if self.isXiaZhu or self.bankerLseatNo == self.tableLogic._mySeatNo then
        self.m_playGameNum = 0;
    end

    for k,v in pairs(self.t_bankTable) do
        if v == self.tableLogic:getMySeatNo() then
            self.m_playGameNum = 0;
            break;
        end
    end

    

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
    --luaDump(temp,"temp")
    return temp;
   
end

function TableLayer:getSingleCastByNum(num)
    luaPrint("根据分数获取筹码分数="..num)
    local type1 = 1;
    if num == 100000 then
        type1 = 6
    elseif num == 50000 then
        type1 = 5
    elseif num == 10000 then 
        type1 = 4
    elseif num == 5000 then
        type1 = 3
    elseif num == 1000 then 
        type1 = 2
    else
        type1 = 1
    end   
    return type1;
end

function TableLayer:getChipTypeByScore(type1)
    luaPrint("根据筹码获取分数="..type1)
    local num = 100000
    if type1 == 6 then
        num = 100000
    elseif type1 == 5 then
        num = 50000
    elseif type1 == 4 then 
        num = 10000
    elseif type1 == 3 then
        num = 5000
    elseif type1 == 2 then 
        num = 1000
    else
        num = 100
    end   
    return num;
end

function TableLayer:getXuzhu()
    local isXuzhu = false;
    for i,score in ipairs(self.resuLtUserScore) do
        if score > 0 then
            isXuzhu = true;
        end
    end
    return isXuzhu;
end

--刷新自己和庄家的金币（动画结束后调用）
function TableLayer:updateUserAndBankScore()
    luaPrint("updateUserAndBankScore",self.BankerScore,self.UserScore)
    if self.isGamePlaying then--断线重连不播放任何特效
        return;
    end

    if self.isXiaZhu == false and self.bankerLseatNo ~= self.tableLogic._mySeatNo then
        self:TipTextShow("本局您没有下注！")
    end
    

    self:showCoinText(false);
    if self.bankerLseatNo ~= -1 then
        self:ScoreToMoney(self.Text_zhuangGold,self.BankerScore)
        self:ScoreToMoney(self.Text_meGold,self.UserScore)
    end

    if self.bankerLseatNo == self.tableLogic._mySeatNo then
        if self.BankerWinScore >= 0 then
            self:playBcbmMusic(14)
        else
            self:playBcbmMusic(15)
        end
    else
        if self.UserWinScore >= 0 then
            if self.resuLtUserScore[self.WinXiaZhuPos] > 0 and self.WinXiaZhuPos%2>0 then
                self:playBcbmMusic(4);
            else
                self:playBcbmMusic(14)
            end
        else
            self:playBcbmMusic(15)
        end
    end

    if self.m_winTime > 2 and ((self.isXiaZhu and self.bankerLseatNo ~= self.tableLogic._mySeatNo) or self.bankerLseatNo == self.tableLogic._mySeatNo) then
        local winTime = self.m_winTime;
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
                    self.Image_bg:addChild(shengAction,10);
                end

                audio.playSound("hall/game/gameEffect/liansheng.mp3");
            end),cc.DelayTime:create(2),cc.CallFunc:create(function()
                local shengAction = self.Image_bg:getChildByName("liansheng");
                if shengAction then
                    shengAction:removeFromParent();
                end
            end)))

    end

    self.isXiaZhu = false;

    -- self.Text_zhuangGold:setString(FormatNumToString(self.BankerScore)) --刷新庄金币
    -- self.Text_meGold:setString(FormatNumToString(self.UserScore))
end

--提示小字符
function TableLayer:TipTextShow1(tipText)
    local text = cc.Label:createWithSystemFont(tipText,"Arial", 20);
    text:setPosition(640,450);
    text:setColor(cc.c3b(255, 255, 0));
    self:addChild(text,301);

    if self.tipTextTable[3] then
        self:removeChild(self.tipTextTable[3]);
    end

    for i = 3,2,-1 do
        self.tipTextTable[i] = self.tipTextTable[i-1];
        if self.tipTextTable[i] then
            local posY = self.tipTextTable[i]:getPositionY()+text:getContentSize().height;
            self.tipTextTable[i]:setPositionY(posY);
        end
    end
    self.tipTextTable[1] = text;
    --显示消失动画
    text:runAction(cc.Sequence:create(cc.FadeOut:create(4)))
    
end


--提示小字符
function TableLayer:TipTextShow(tipText)
    addScrollMessage(tipText)
    -- local text = cc.Label:createWithSystemFont(tipText,"Arial", 15);
    -- text:setColor(cc.c3b(255, 255, 0));
    -- --self:addChild(text,301);

    -- local tipBg = "hall/common/ty_pao_ma_bg.png"
    -- local tipSp = cc.Sprite:create(tipBg);
    -- local fullRect = cc.rect(0,0,tipSp:getContentSize().width,tipSp:getContentSize().height)
    -- local insetRect = cc.rect(420,10,1,1);

    -- local background = cc.Scale9Sprite:create(tipBg,fullRect,insetRect)
    -- background:setContentSize(cc.size(900,30 ))

    -- text:setPosition(cc.p(background:getContentSize().width/2,background:getContentSize().height/2 ));

    -- background:setPosition(cc.p(640,450))
    -- background:addChild(text)
    -- self:addChild(background);

    -- if self.tipTextTable[3] then
    --     self:removeChild(self.tipTextTable[3]);
    -- end

    -- for i = 3,2,-1 do
    --     self.tipTextTable[i] = self.tipTextTable[i-1];
    --     if self.tipTextTable[i] then
    --         local posY = self.tipTextTable[i]:getPositionY()+ 40;
    --         self.tipTextTable[i]:setPositionY(posY);
    --     end
    -- end
    -- self.tipTextTable[1] = background;
    -- --显示消失动画
    -- background:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeOut:create(1.5)))
    -- text:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeOut:create(1.5)))

end

--玩家分数
function TableLayer:ScoreToMoney(pNode,score)
    local remainderNum = score%100;
    local remainderString = "";

    if remainderNum == 0 then--保留2位小数
        remainderString = remainderString..".00";
    else
        if remainderNum%10 == 0 then
            remainderString = remainderString.."0";
        end
    end

    if pNode then
        pNode:setString((score/100)..remainderString);
    else
        return (score/100)..remainderString;
    end
end

function TableLayer:showCoinText(flag)
    if flag then
        if self.UserWinScore > 0 then
            self.coinTextTable[1]:setString("+"..(self:ScoreToMoney(nil,self.UserWinScore) ))
        else
            self.coinTextTable[2]:setString(self:ScoreToMoney(nil,self.UserWinScore))
        end

        if self.OtherWinScore > 0 then
            self.coinTextTable[3]:setString("+"..(self:ScoreToMoney(nil,self.OtherWinScore)))
        else
            self.coinTextTable[4]:setString(self:ScoreToMoney(nil,self.OtherWinScore))
        end

        if self.BankerWinScore > 0 then
            self.coinTextTable[5]:setString("+"..(self:ScoreToMoney(nil,"+"..self.BankerWinScore)))
        else
            self.coinTextTable[6]:setString(self:ScoreToMoney(nil,self.BankerWinScore))
        end
    else
        if self.UserWinScore > 0 then
            self.coinTextTable[1]:setVisible(true);
            self.coinTextTable[1]:runAction(cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,50)),
                 cc.CallFunc:create(function() self.coinTextTable[1]:setVisible(false); end),cc.MoveBy:create(0.1,cc.p(0,-50))))
        elseif self.UserWinScore < 0 then
            self.coinTextTable[2]:setVisible(true);
            self.coinTextTable[2]:runAction(cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,50)),
                 cc.CallFunc:create(function() self.coinTextTable[2]:setVisible(false); end),cc.MoveBy:create(0.1,cc.p(0,-50))))
        end

        if self.OtherWinScore > 0 then
            self.coinTextTable[3]:setVisible(true);
            self.coinTextTable[3]:runAction(cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,50)),
                 cc.CallFunc:create(function() self.coinTextTable[3]:setVisible(false); end),cc.MoveBy:create(0.1,cc.p(0,-50))))
        elseif self.OtherWinScore < 0 then
            self.coinTextTable[4]:setVisible(true);
            self.coinTextTable[4]:runAction(cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,50)),
                 cc.CallFunc:create(function() self.coinTextTable[4]:setVisible(false); end),cc.MoveBy:create(0.1,cc.p(0,-50))))
        end

        if self.BankerWinScore > 0 then
            self.coinTextTable[5]:setVisible(true);
            self.coinTextTable[5]:runAction(cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,50)),
                 cc.CallFunc:create(function() self.coinTextTable[5]:setVisible(false); end),cc.MoveBy:create(0.1,cc.p(0,-50))))
        elseif self.BankerWinScore < 0 then
            self.coinTextTable[6]:setVisible(true);
            self.coinTextTable[6]:runAction(cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,50)),
                 cc.CallFunc:create(function() self.coinTextTable[6]:setVisible(false); end),cc.MoveBy:create(0.1,cc.p(0,-50))))
        end
    end
end

------------------------消息处理-------------------
function TableLayer:onBCBMGameFree(msg)
    luaPrint("TableLayer:onBCBMGameFree空闲中",msg.cbTimeLeave)
    --self:startClock(msg._usedata.cbTimeLeave) 
    --self:setStateStr(25)

    -- self.Image_select:setVisible(false)
    -- self.Image_select:setScale(1)

    --self.isUserXiazhu = false;
end

function TableLayer:onBCBMGameStart(msg)
    luaPrint("TableLayer:onBCBMGameStart下注中")

    if self.isGameStation == false then
        return;
    end
    self.isGamePlaying = false;
    self.b_suo = false;
    self.isXiaZhu = false;

    if self.ScoreHistoryTable then
        self:showHistory(self.ScoreHistoryTable)--刷新历史
    end

    self:flushBankerMsg();

    self.BankerWinScore = 0--庄家输赢的积分
    self.UserWinScore = 0 --自己的积分
    self.OtherWinScore = 0--self:getOtherWinScore(msg)

    --self.Panel_dengdai:setVisible(false)
    local skeleton_animation0 = self:getChildByName("skeleton_animation0")
    if skeleton_animation0 then
        self:removeChildByName("skeleton_animation0")
    end
    for i = 1,8 do
        if self["Button_xiazhu"..i] then
            self["Button_xiazhu"..i]:setEnabled(true)
        end
    end

    self.nBankerTime = msg._usedata.nBankerTime

    if self.nBankerTime > 1 and self.bankerLseatNo ~= -1 then--连庄的时候庄家不为空
        self:showZhuangTips(4);
    end

    for i=1,8 do
        local Image_light =  self["Button_xiazhu"..i]:getChildByName("Image_light");
        if Image_light then
            Image_light:setVisible(false)
        end

        local Image_lightdi =  self["Button_xiazhu"..i]:getChildByName("Image_lightdi");
        if Image_lightdi then
            Image_lightdi:setVisible(false)
        end
    end

    self.xiazhuScoreTable = {0,0,0,0,0,0,0,0} --每个区域所下分数
    for i = 1,8 do
        if self["Text_score"..i] then
            self["Text_score"..i]:setString(" ")
        end
    end

    self.xiazhuUserScoreTable = {0,0,0,0,0,0,0,0} --自己每个区域所下分数
    for i = 1,8 do
        if self["AtlasLabel_userxz"..i] then
            self["AtlasLabel_userxz"..i]:setString(" ")
        end
    end

    self.AllChipInScore = 0;
    self:ScoreToMoney(self.Text_allchipin,self.AllChipInScore)

    self:setStateStr(26)
    self:startClock(msg._usedata.cbTimeLeave)
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.tableLogic._mySeatNo);
    if userInfo then
        luaPrint("----------11111111---",self.UserScore,userInfo.i64Money)
        self.UserScore = userInfo.i64Money
        self:ScoreToMoney(self.Text_meGold,self.UserScore)
    end  
    -- if self.bankerLseatNo ~= -1 then
    --     local bankUserInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.bankerLseatNo);
    --     if bankUserInfo then
    --         self.BankerScore = bankUserInfo.i64Money
    --     end
    -- end

    luaPrint("onBCBMGameStart下注中")
    if self.bankerLseatNo == self.tableLogic._mySeatNo then
        self:showCastBth(false)
    else
        self:showCastBth(true)
        self:setXuTouButtonEnable();
    end

    self:playBcbmMusic(12)--播放音乐
    self:ShowKaishiXiazhu()--显示下注动画
   
end

function TableLayer:onBCBMGamePlaceJetton(msg)
    luaPrint("TableLayer:onBCBMGamePlaceJetton下注成功")

    if self.isGameStation == false then
        return;
    end
    -- {"wChairID","WORD"},--//用户位置    
    -- {"cbJettonArea","BYTE"},    --//筹码区域
    -- {"iJettonScore","LLONG"},--//加注数目       
    local xiazhuType = msg._usedata.cbJettonArea
    --刷新每个区域的分数
    if xiazhuType > 0 and xiazhuType <9 then
        if self.xiazhuScoreTable[xiazhuType] then
            self.xiazhuScoreTable[xiazhuType] = self.xiazhuScoreTable[xiazhuType] + msg._usedata.iJettonScore;
            if self["Text_score"..xiazhuType] then
                self:ScoreToMoney(self["Text_score"..xiazhuType],self.xiazhuScoreTable[xiazhuType])
            end
        end
        if self.tableLogic._mySeatNo == msg._usedata.wChairID then
            if self.xiazhuUserScoreTable[xiazhuType] then
                self.xiazhuUserScoreTable[xiazhuType] = self.xiazhuUserScoreTable[xiazhuType] + msg._usedata.iJettonScore;
                if self["AtlasLabel_userxz"..xiazhuType] then
                    self:ScoreToMoney(self["AtlasLabel_userxz"..xiazhuType],self.xiazhuUserScoreTable[xiazhuType])
                    luaPrint("刷新自己下注",self.xiazhuUserScoreTable[xiazhuType]);
                end
            end
        end
    end

    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(msg._usedata.wChairID);
    if userInfo then
        local createType = 2; -- 其他用户下注
        local isMe = false;
        local chipType_T = self:getCastByNum(msg._usedata.iJettonScore)--getSingleCastByNum
        
        luaPrint("下注成功是不是自己",self.tableLogic._mySeatNo,msg._usedata.wChairID)
        if self.tableLogic._mySeatNo == msg._usedata.wChairID then
            isMe = true;
            createType = 1;
            self.isXiaZhu = true;
            self.UserScore = self.UserScore - msg._usedata.iJettonScore; --减去当前筹码的金币
            luaPrint("自己的金币-------2222222222--------",self.UserScore)
            self:ScoreToMoney(self.Text_meGold,self.UserScore)
            --self.Text_meGold:setString(FormatNumToString(self.UserScore));
            self:ChipJundge();

            self.Button_xuzhu.chipScore = msg._usedata.iJettonScore;
            self.Button_xuzhu.xiazhuType = xiazhuType;
            -- if self.UserScore >= self.Button_xuzhu.chipScore then
            --     self.Button_xuzhu:setEnabled(true)
            -- else
            --     self.Button_xuzhu:setEnabled(false)
            -- end
            self.Button_xuzhu:setEnabled(false);
        end

        if self.tableLogic._mySeatNo == msg._usedata.wChairID then
            luaDump(chipType_T,"chipType_T");
        end
        for k,v in pairs(chipType_T) do
            --luaPrint("v",v);
            local sum = v;
            while(sum>0) do
                local chipNode = self.ChipManager:ChipCreate(createType,k,xiazhuType,false,isMe);
                if isMe then
                    self.ChipManager:ChipMove(chipNode,3,xiazhuType,true)
                end
                sum = sum - 1;
            end
        end
        
        self.AllChipInScore = self.AllChipInScore + msg._usedata.iJettonScore;
        self:ScoreToMoney(self.Text_allchipin,self.AllChipInScore)
        --self.Text_allchipin:setString(self.AllChipInScore)
    end
    
end
function TableLayer:onBCBMGameEnd(msg)
    luaPrint("TableLayer:onBCBMGameEnd游戏结束")

    if self.isGameStation == false then
        return;
    end

    if self.isXiaZhu then
        self.b_suo = true;
        GamePromptLayer:remove()
    end

    self:updatePlayNum();

    self.ChipManager:showAllCreateChip();
    if self.isXiaZhu then
        self.m_recordScore = clone(self.xiazhuUserScoreTable);
    end
    self.Button_xuzhu.chipScore = -1;
    self.Button_xuzhu.xiazhuType = -1;
    self:showCastBth(false)
    self.Button_xuzhu:setEnabled(false);

    self:setStateStr(27)
    self:startClock(msg._usedata.cbTimeLeave)

    -- if isHaveBankLayer() then 
    --     self:TipTextShow("游戏开奖中，请稍后进行取款操作。");
    -- end

    -- if isHaveBankLayer() then
    --     createBank(function (data)
    --         self:baoxian(data)
    --     end,false);
    -- end

    self.m_winTime = msg._usedata.nWinTime;

    self:startRunRound(msg._usedata.cbLastResultIndex,msg._usedata.cbEndIndex)

    self.WinCheBiaoEndPos = msg._usedata.cbEndIndex;
    self.WinXiaZhuPos = msg._usedata.cbResultIndex;--1-8

    self.BankerWinScore = msg._usedata.lBankerScore--庄家输赢的积分
    self.UserWinScore = msg._usedata.lUserScore --自己的积分
    self.OtherWinScore = msg._usedata.LOtherScore--self:getOtherWinScore(msg)

    luaPrint("庄家的金币-----------",self.BankerWinScore,self.BankerScore)
    self.BankerScore = self.BankerScore + self.BankerWinScore
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.tableLogic._mySeatNo);
    if userInfo then
        luaPrint("自己的金币----333333333------",self.UserScore,userInfo.i64Money,self.UserWinScore)
        self.UserScore = userInfo.i64Money + self.UserWinScore;
    end

    --self.nBankerTime = msg._usedata.nBankerTime

    self:showCoinText(true);

    self.resuLtUserScore = {};
    table.insert(self.resuLtUserScore,msg._usedata.lUserBigBCScore)--下大奔驰的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserSmallBCScore)--下小奔驰的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserBigBMScore)--下大宝马的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserSmallBMScore)--下小宝马的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserBigADScore)--下大奥迪的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserSmallADScore)--下小奥迪的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserBigDZScore)--下大大众的筹码
    table.insert(self.resuLtUserScore,msg._usedata.lUserSmallDZScore)--下小大众的筹码

    self:playBcbmMusic(11)
    --停止下注动画
    self:ShowKaishiXiazhu(1)
end

function TableLayer:onBCBMApplyBanker(msg)
    luaPrint("TableLayer:onBCBMApplyBanker"..msg._usedata.wApplyUser)
    --luaDump(self.ApplyBanerTable)
   
    if self.isGameStation == false then
        return;
    end
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    --self:flushApplyBankerNum(msg._usedata.wApplyUser);
    self.Text_zhuangNum:setString(msg._usedata.ApplyCount)
    self:updateBankList(msg._usedata.ApplyUsers,msg._usedata.ApplyCount);
    if msg._usedata.wApplyUser == self.tableLogic._mySeatNo then --自己
        self.Button_shangzhuang:setTag(2);
        self.Button_shangzhuang:loadTextures("bcbm_quxiaoshangzhuang.png","bcbm_quxiaoshangzhuang-on.png","bcbm_quxiaoshangzhuang-on.png",UI_TEX_TYPE_PLIST)
    end
end

function TableLayer:onBCBMChangeBanker(msg)
    luaPrint("TableLayer:onBCBMChangeBanker")

    if self.isGameStation == false then
        return;
    end

    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(msg._usedata.wBankerUser);
    --luaDump(userInfo)
    --刷新申请人数
    --self:flushApplyBankerNum(msg._usedata.wBankerUser,true);
    self.Text_zhuangNum:setString(msg._usedata.ApplyCount)

    self:updateBankList(msg._usedata.ApplyUsers,msg._usedata.ApplyCount);

    self.nBankerTime = 0;

    local lastBankerLseatNo = self.bankerLseatNo;

    self:showChangeZhuang();--庄家轮换

    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    if userInfo then
        self.Text_zhuangName:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
        self.BankerScore = msg._usedata.lBankerScore;
        self:ScoreToMoney(self.Text_zhuangGold,msg._usedata.lBankerScore)
        --self.Text_zhuangGold:setString(FormatNumToString(msg._usedata.lBankerScore))
        self.bankerLseatNo = msg._usedata.wBankerUser
        if msg._usedata.wBankerUser == self.tableLogic._mySeatNo then
            self:showCastBth(false)
            self.Button_shangzhuang:setTag(2);
            self.Button_shangzhuang:loadTextures("bcbm_xiazhuang.png","bcbm_xiazhuang-on.png","bcbm_xiazhuang-on.png",UI_TEX_TYPE_PLIST)
        else
            if lastBankerLseatNo == self.tableLogic._mySeatNo then --如果上一个庄家是自己
                self.Button_shangzhuang:setTag(1);
                self.Button_shangzhuang:loadTextures("bcbm_shangzhuang.png","bcbm_shangzhuang-on.png","bcbm_shangzhuang-on.png",UI_TEX_TYPE_PLIST)
            end
            self:showCastBth(true)
        end
    else
        self.Text_zhuangName:setString("");
        self.BankerScore = 0;
        self.Text_zhuangGold:setString(" ")
        self.bankerLseatNo = -1;
        if msg._usedata.wBankerUser == 255  then
            self.Button_shangzhuang:setTag(1);
            self.Button_shangzhuang:loadTextures("bcbm_shangzhuang.png","bcbm_shangzhuang-on.png","bcbm_shangzhuang-on.png",UI_TEX_TYPE_PLIST)
        end
        self:showCastBth(true)
        luaPrint("上庄用户信息未找到")
    end
 
end

function TableLayer:onBCBMChangeUserScore(msg)
    luaPrint("TableLayer:onBCBMChangeUserScore")
    -- body
end

function TableLayer:onBCBMPlaceJettonFail(msg)
    luaPrint("TableLayer:onBCBMPlaceJettonFail下注失败")
    -- {"lJettonArea","BYTE"},                             --//下注区域
    -- {"lPlaceScore","LLONG"},                            --//当前下注
    --self:TipTextShow("下注失败！");
end

function TableLayer:onBCBMCancelBanker(msg)
    luaPrint("TableLayer:onBCBMCancelBanker取消上庄")

    if self.isGameStation == false then
        return;
    end
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    local isApply = self:isMeApplyBanker()
    --刷新申请人数
    --self:flushApplyBankerNum(msg._usedata.szCancelUser,true);
    self.Text_zhuangNum:setString(msg._usedata.ApplyCount)
    if msg._usedata.szCancelUser == self.tableLogic._mySeatNo then
      --  if isApply then
            -- self.Text_zhuangName:setString(" ");
            -- self.Text_zhuangGold:setString(" ")

            self.Button_shangzhuang:setTag(1);
            self.Button_shangzhuang:loadTextures("bcbm_shangzhuang.png","bcbm_shangzhuang-on.png","bcbm_shangzhuang-on.png",UI_TEX_TYPE_PLIST)
       -- end
        --self.Image_shangzhuang:loadTexture("bcbm_shangzhuang.png",UI_TEX_TYPE_PLIST)
        --self.Button_shangzhuang:loadTextures("benchibaoma/table/apply_down.png","benchibaoma/table/apply_up.png")
    else
        luaPrint(msg._usedata.wCancelUser.."取消上庄")
    end
    self:updateBankList(msg._usedata.ApplyUsers,msg._usedata.ApplyCount);
    --local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(msg._usedata.wBankerUser);

end
function TableLayer:onBCBMSendScoreHistory(msg)
    luaPrint("TableLayer:onBCBMSendScoreHistory")
    self.ScoreHistoryTable = msg._usedata.cbScoreHistroy; --历史中奖记录
   

end
function TableLayer:onBCBMChangeSysBanker(msg)
    luaPrint("TableLayer:onBCBMChangeSysBanker")
    -- body
end
function TableLayer:onBCBMGetBanker(msg)
    luaPrint("TableLayer:onBCBMGetBanker")
    --luaDump(msg._usedata.wGetUser)

    --self.Text_zhuangNum:setString(table.nums(msg._usedata.wGetUser)) --申请上庄人数
end

function TableLayer:onBCBMUserCut()
    luaPrint("TableLayer:onBCBMUserCut")
    self:gameUserCut();
end

--庄家反悔下庄
function TableLayer:onBCBCancelCancel( ... )
    luaPrint("TableLayer:onBCBCancelCancel庄家反悔下庄")
    if self.isGameStation == false then
        return;
    end
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    self.Button_shangzhuang:setTag(2);
    self.Button_shangzhuang:loadTextures("bcbm_xiazhuang.png","bcbm_xiazhuang-on.png","bcbm_xiazhuang-on.png",UI_TEX_TYPE_PLIST)
end

--庄家下庄按钮点击返回
function TableLayer:onBCBCancelSuccess( ... )
    luaPrint("TableLayer:onBCBCancelSuccess庄家下庄")
    if self.isGameStation == false then
        return;
    end
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    self.Button_shangzhuang:setTag(3);
    self.Button_shangzhuang:loadTextures("bcbm_quxiaoxiazhuang.png","bcbm_quxiaoxiazhuang-on.png","bcbm_quxiaoxiazhuang-on.png",UI_TEX_TYPE_PLIST)
end

--退注
function TableLayer:onBCBMCancelBet(msg)
    luaPrint("TableLayer:onBCBMCancelBet")
    if self.isGameStation == false then
        return;
    end

    local removeOtherChipTable = msg._usedata.lUserPlaceScore;
    for xiazhuType,score in pairs(msg._usedata.lUserPlaceScore) do
        if self.xiazhuScoreTable[xiazhuType] and score > 0 then
            self.xiazhuScoreTable[xiazhuType] = self.xiazhuScoreTable[xiazhuType] - score;
            if self["Text_score"..xiazhuType] and self.xiazhuScoreTable[xiazhuType] >=0 then
                self:ScoreToMoney(self["Text_score"..xiazhuType],self.xiazhuScoreTable[xiazhuType])
            end
        end
    end

    -- if #self.ChipManager.ChipNodeTable >0 then--筹码不为空
    --     for index,chip in pairs(self.ChipManager.ChipNodeTable) do
    --         for removeXiazhuType,score in pairs(removeOtherChipTable) do
    --             if score >0 and chip.xiazhuType == removeXiazhuType then--当前筹码与移除的筹码区域相同
    --                 local castTable = self:getCastByNum(score)
    --                 for removeChipType,num in ipairs(castTable) do
    --                     if tonumber(num) > 0 then
    --                         luaPrint("num------",num,removeChipType)
    --                         for i=1,num do
    --                             if chip.chipType == removeChipType then--减去分数，移除筹码
    --                                 luaPrint("减去分数，移除筹码",removeChipType)
    --                                 removeOtherChipTable[removeXiazhuType] = removeOtherChipTable[removeXiazhuType] - self:getChipTypeByScore(removeChipType);
    --                                 chip:removeFromParent();
    --                                 table.remove(self.ChipManager.ChipNodeTable,index)
    --                             end
    --                         end
    --                     end
    --                 end
    --             end
    --         end
            
    --     end
    -- end
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

function TableLayer:gameStationPlaying(msg)
    luaPrint("TableLayer:gameStationPlaying游戏状态")

    self.isGameStation = true;

    self:clearDeskInfo();
    self:flushOtherMsg();
    self.Text_zhuangNum:setString(msg.ApplyCount)--刷新申请上庄人数
    self:updateBankList(msg.ApplyUsers,msg.ApplyCount);

    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(msg.wBankerUser);
    --luaDump(userInfo)
    if userInfo then
        self.Text_zhuangName:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
        self.BankerScore = userInfo.i64Money;
        self:ScoreToMoney(self.Text_zhuangGold,userInfo.i64Money)
        --self.Text_zhuangGold:setString(FormatNumToString(userInfo.i64Money)) 
    end

    self.bankerLseatNo = msg.wBankerUser
    if msg.wBankerUser == self.tableLogic._mySeatNo then
        self:showCastBth(false)
        if msg.wCancleBanker then
            self.Button_shangzhuang:setTag(3);
            self.Button_shangzhuang:loadTextures("bcbm_quxiaoxiazhuang.png","bcbm_quxiaoxiazhuang-on.png","bcbm_quxiaoxiazhuang-on.png",UI_TEX_TYPE_PLIST)
        else 
            self.Button_shangzhuang:setTag(2);
            self.Button_shangzhuang:loadTextures("bcbm_xiazhuang.png","bcbm_xiazhuang-on.png","bcbm_xiazhuang-on.png",UI_TEX_TYPE_PLIST)
        end
    else
        if msg.wApplyBanker then
            self.Button_shangzhuang:setTag(2);
            self.Button_shangzhuang:loadTextures("bcbm_quxiaoshangzhuang.png","bcbm_quxiaoshangzhuang-on.png","bcbm_quxiaoshangzhuang-on.png",UI_TEX_TYPE_PLIST)
        else
            self.Button_shangzhuang:setTag(1);
            self.Button_shangzhuang:loadTextures("bcbm_shangzhuang.png","bcbm_shangzhuang-on.png","bcbm_shangzhuang-on.png",UI_TEX_TYPE_PLIST)
        end
        self:showCastBth(true)
    end

    self:showSystemBank(msg.bEnableSysBanker);

    self:setStateStr(msg.cbGameStatus)--状态
    self:startClock(msg.cbTimeLeave)--倒计时
    
    if msg.cbGameStatus ~= 26 then --非游戏状态设置所有按钮不可点击
        self:showCastBth(false) 
        self:showZhuangTips(5);
        self.isGamePlaying = true;
        --performWithDelay(self, function() end,msg.cbTimeLeave);
    else
        for i = 1,8 do
            if self["Button_xiazhu"..i] then
                self["Button_xiazhu"..i]:setEnabled(true)
            end
        end
    end
    
    self.ChipManager:clearAllChip();--清除所有筹码
    if msg.cbGameStatus == 26 and not self.isGamePlaying then
        self:regainGameChip(msg) --下注状态桌面上筹码恢复
    else
        self:regainMeScore(msg);--下注状态恢复自己的分数
    end

    self.lApplyBankerCondition = msg.lApplyBankerCondition;--上庄条件
    -- if msg.cbLastResultIndex >0  and msg.cbLastResultIndex <= 32 and self.Image_di[msg.cbLastResultIndex] then
    --     self.Image_di[msg.cbLastResultIndex]:setVisible(true)
    -- end

    self.lBetCondition = SettlementInfo:getConfigInfoByID(46);

    if self.ScoreHistoryTable then
        self:showHistory(self.ScoreHistoryTable)--刷新历史
    end

end

function TableLayer:gameStationFree(msg)
    luaPrint("TableLayer:gameStationFree空闲状态")

    self.isGameStation = true;

    self:clearDeskInfo();
    self:flushOtherMsg();

    self.Text_zhuangNum:setString(msg.ApplyCount)--刷新申请上庄人数
    display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(msg.wBankerUser);
    if userInfo then
       self.Text_zhuangName:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
        self.BankerScore = userInfo.i64Money;
        self:ScoreToMoney(self.Text_zhuangGold,userInfo.i64Money)
        self.bankerLseatNo = msg.wBankerUser
        if msg.wBankerUser == self.tableLogic._mySeatNo then
            self:showCastBth(false)
            if msg.wCancleBanker then
                self.Button_shangzhuang:setTag(3);
                self.Button_shangzhuang:loadTextures("bcbm_quxiaoxiazhuang.png","bcbm_quxiaoxiazhuang-on.png","bcbm_quxiaoxiazhuang-on.png",UI_TEX_TYPE_PLIST)
            else 
                self.Button_shangzhuang:setTag(2);
                self.Button_shangzhuang:loadTextures("bcbm_xiazhuang.png","bcbm_xiazhuang-on.png","bcbm_xiazhuang-on.png",UI_TEX_TYPE_PLIST)
            end
        else
            if msg.wApplyBanker then
                self.Button_shangzhuang:setTag(2);
                self.Button_shangzhuang:loadTextures("bcbm_quxiaoshangzhuang.png","bcbm_quxiaoshangzhuang-on.png","bcbm_quxiaoshangzhuang-on.png",UI_TEX_TYPE_PLIST)
            else
                self.Button_shangzhuang:setTag(1);
                self.Button_shangzhuang:loadTextures("bcbm_shangzhuang.png","bcbm_shangzhuang-on.png","bcbm_shangzhuang-on.png",UI_TEX_TYPE_PLIST)
            end
            self:showCastBth(true)
        end
    end
    
    self:showSystemBank(msg.bEnableSysBanker);

    self:setStateStr(25)--状态
    self:startClock(msg.cbTimeLeave)

    self.lApplyBankerCondition = msg.lApplyBankerCondition;--上庄条件
    self.lBetCondition = SettlementInfo:getConfigInfoByID(46);

    self.ChipManager:clearAllChip();--清除所有筹码

    self:updateBankList(msg.ApplyUsers,msg.ApplyCount);

end

function TableLayer:regainMeScore(msg)
    local resuLtUserScore = {};
    table.insert(resuLtUserScore,msg.lUserBigBCScore)--下大奔驰的筹码
    table.insert(resuLtUserScore,msg.lUserSmallBCScore)--下小奔驰的筹码
    table.insert(resuLtUserScore,msg.lUserBigBMScore)--下大宝马的筹码
    table.insert(resuLtUserScore,msg.lUserSmallBMScore)--下小宝马的筹码
    table.insert(resuLtUserScore,msg.lUserBigADScore)--下大奥迪的筹码
    table.insert(resuLtUserScore,msg.lUserSmallADScore)--下小奥迪的筹码
    table.insert(resuLtUserScore,msg.lUserBigDZScore)--下大大众的筹码
    table.insert(resuLtUserScore,msg.lUserSmallDZScore)--下小大众的筹码
    local num = 0;
    for xiazhuType,xiazhuScore in ipairs(resuLtUserScore) do
        num = num + xiazhuScore;
    end
    local userInfo = self.tableLogic._deskUserList:getUserByDeskStation(self.tableLogic._mySeatNo);
    if userInfo then
        luaPrint("断线重连恢复分数----",self.UserScore,userInfo.i64Money,num)
        self.UserScore = userInfo.i64Money - num;
        self:ScoreToMoney(self.Text_meGold,self.UserScore)
    end  

    if msg.cbGameStatus == 27 then
        if num > 0 then
            self.isXiaZhu = true;
            self.b_suo = true;
            GamePromptLayer:remove()
        end
    end
end

--恢复下注的筹码(断线重连界面专用)
function TableLayer:regainGameChip(msg)

    self.AllChipInScore = 0;
    --清除数据
    self.xiazhuScoreTable = {0,0,0,0,0,0,0,0} --每个区域所下分数
    self.xiazhuUserScoreTable = {0,0,0,0,0,0,0,0} --自己每个区域所下分数
    local temp = {};
    table.insert(temp,msg.lALLBigBCScore-msg.lUserBigBCScore)--下大奔驰的筹码
    table.insert(temp,msg.lALLSmallBCScore-msg.lUserSmallBCScore)--下小奔驰的筹码
    table.insert(temp,msg.lALLBigBMScore-msg.lUserBigBMScore)--下大宝马的筹码
    table.insert(temp,msg.lALLSmallBMScore-msg.lUserSmallBMScore)--下小宝马的筹码
    table.insert(temp,msg.lALLBigADScore-msg.lUserBigADScore)--下大奥迪的筹码
    table.insert(temp,msg.lALLSmallADScore-msg.lUserSmallADScore)--下小奥迪的筹码
    table.insert(temp,msg.lALLBigDZScore-msg.lUserBigDZScore)--下大大众的筹码
    table.insert(temp,msg.lALLSmallDZScore-msg.lUserSmallDZScore)--下小大众的筹码
    for xiazhuType,xiazhuScore in ipairs(temp) do
        if tonumber(xiazhuScore) > 0 then
            --刷新分数
            self.xiazhuScoreTable[xiazhuType] = self.xiazhuScoreTable[xiazhuType] + xiazhuScore;
            if self["Text_score"..xiazhuType] then
                self:ScoreToMoney(self["Text_score"..xiazhuType],self.xiazhuScoreTable[xiazhuType])
            end

            self.AllChipInScore = self.AllChipInScore + xiazhuScore;
            local castTable = self:getCastByNum(xiazhuScore)
           -- luaDump(castTable)
            for index,num in ipairs(castTable) do
                if tonumber(num) > 0 then
                    for i=1,num do
                        self.ChipManager:ChipCreate(3,index,xiazhuType,true,false,true);
                    end
                end
            end
        end
    end

    self.resuLtUserScore = {};
    table.insert(self.resuLtUserScore,msg.lUserBigBCScore)--下大奔驰的筹码
    table.insert(self.resuLtUserScore,msg.lUserSmallBCScore)--下小奔驰的筹码
    table.insert(self.resuLtUserScore,msg.lUserBigBMScore)--下大宝马的筹码
    table.insert(self.resuLtUserScore,msg.lUserSmallBMScore)--下小宝马的筹码
    table.insert(self.resuLtUserScore,msg.lUserBigADScore)--下大奥迪的筹码
    table.insert(self.resuLtUserScore,msg.lUserSmallADScore)--下小奥迪的筹码
    table.insert(self.resuLtUserScore,msg.lUserBigDZScore)--下大大众的筹码
    table.insert(self.resuLtUserScore,msg.lUserSmallDZScore)--下小大众的筹码

    for xiazhuType,xiazhuScore in ipairs(self.resuLtUserScore) do
        if tonumber(xiazhuScore) > 0 then
            --刷新分数
            self.xiazhuScoreTable[xiazhuType] = self.xiazhuScoreTable[xiazhuType] + xiazhuScore;
            if self["Text_score"..xiazhuType] then
                self:ScoreToMoney(self["Text_score"..xiazhuType],self.xiazhuScoreTable[xiazhuType])
            end

            self.AllChipInScore = self.AllChipInScore + xiazhuScore;
            --刷新自己下注分数
            self.xiazhuUserScoreTable[xiazhuType] = xiazhuScore;
            if self["AtlasLabel_userxz"..xiazhuType] then
                self:ScoreToMoney(self["AtlasLabel_userxz"..xiazhuType],self.xiazhuUserScoreTable[xiazhuType])
            end
           
            local castTable = self:getCastByNum(xiazhuScore)
            --luaDump(castTable)
            for index,num in ipairs(castTable) do
                if tonumber(num) > 0 then
                    for i=1,num do
                        self.ChipManager:ChipCreate(3,index,xiazhuType,true,true,true);
                    end
                end
            end
        end
    end

    if msg.cbGameStatus == 26 then
        for k,v in pairs(self.xiazhuUserScoreTable) do
            if v > 0 then
                self.isXiaZhu = true;
                break;
            end
        end
    end

    self:ScoreToMoney(self.Text_allchipin,self.AllChipInScore) 
end

function TableLayer:clearDeskInfo()
    self.ChipManager:clearAllChip();--清除所有筹码
    self.ChipManager:claerCreateChip();
    self.ChipManager:startChipScheduler();

    self:hideRunRoundAnimation();--隐藏转圈动画

    for i=0,3 do
        local skeleton_animation = self:getChildByName("skeleton_animation"..i)
        luaPrint("---------------skeleton_animation,",skeleton_animation,i)
        if skeleton_animation and not tolua.isnull(skeleton_animation) then
            skeleton_animation:setVisible(false);
        end
    end

    --先移除原先的
    local skeleton_animation4 = self.Node_9:getChildByName("skeleton_animation4")
    if skeleton_animation4 then
        self.Node_9:removeChildByName("skeleton_animation4")
    end
    self.b_suo = false;
    self.isXiaZhu = false;
    self.m_recordScore = {0,0,0,0,0,0,0,0};--记录上局下注金额
end

------------------音乐播放-------------------
function TableLayer:playBcbmMusic(code)
    local musicTable = {
        "sound-bet-high.mp3",--下注筹码
        "sound-car-bg.mp3",--背景音乐
        "sound-car-lose.mp3",--失败
        "sound-car-win.mp3",--胜利
        "sound-clock-count.mp3",--倒计时(每秒)
        "sound-get-gold.mp3",--获得金币
        "sound-car-turn.mp3",--跑动
        "sound-car-turn-end",--跑动结束的
        "zhuang-1.mp3",--庄家轮换男
        "zhuang-2.mp3",--庄家轮换女
        "sound-end-wager.mp3",--停止下注
        "sound-start-wager.mp3",--开始下注
        "sound-betlow.mp3",--下注筹码 
        "win.mp3",--新赢 音效
        "lose.mp3",--新输 音效
    }

    local rootPath = "benchibaoma/game/music/"
    if code == 2 then
        audio.playMusic(rootPath..musicTable[2], true);
        return;
    end

    audio.playSound(rootPath..musicTable[code], false);
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
    for _,userInfo in pairs(self.tableLogic._deskUserList._users) do
        if userInfo.dwUserID ~= PlatformLogic.loginResult.dwUserID then
            table.insert(othersTable,userInfo)
        end
    end

    -- for i=1,30 do
    --     local userInfo = {}
    --     userInfo.nickName = "111111111"
    --     userInfo.i64Money = "12154500"
    --     table.insert(othersTable,userInfo)
    -- end
    
    return othersTable;
end

--添加用户
function TableLayer:addUser(deskStation, bMe)
    if not self:isValidSeat(deskStation) then 
        return;
    end

    local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
    local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);
    if bMe then
        luaPrint("addUser0000000000------",self.UserScore,userInfo.i64Money,bSeatNo)
        self.UserScore = userInfo.i64Money
        self:ScoreToMoney(self.Text_meGold,self.UserScore)
    end

    self:flushOtherMsg()

    -- local bSeatNo = self.tableLogic:viewToLogicSeatNo(deskStation);
    -- local userInfo = self.tableLogic:getUserBySeatNo(bSeatNo);

end

function TableLayer:removeUser(seatNo, bIsMe,bLock)
    luaPrint("TableLayer:removeUser",seatNo,bIsMe)
    if not self:isValidSeat(seatNo) then 
        return;
    end

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
        elseif bLock == 1 then
          str ="您的金币不足,自动退出游戏。"
          showBuyTip(true);
        elseif bLock == 0 then
            BackCallBack();
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
        return;
    end

    self:flushOtherMsg();

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
    luaPrint("设置玩家分数显示隐藏 ------------ seatNo "..seatNo)
    if not self:isValidSeat(seatNo) then
        return;
    end
    
    luaPrint("设置玩家分数显示隐藏")
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

function TableLayer:onUserCutMessageResp( ... )
    -- body
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

--进入后台
function TableLayer:refreshEnterBack(data)
    luaPrint("奔驰宝马--进入后台-----------refreshEnterBack")
    if device.platform == "windows" then
        return;
    end
    self.isGameStation = false;
end

--后台回来
function TableLayer:refreshBackGame(data)
    luaPrint("奔驰宝马--后台回来-----------refreshBackGame")
    if device.platform == "windows" then
        return;
    end
    if RoomLogic:isConnect() then

        self.isGameStation = false;

        --self:stopAllActions();
        self.tableLogic._bSendLogic = false;
        self.tableLogic:sendGameInfo();

        self:clearDeskInfo();
    else
        -- self.isGameStation = false;
        -- self:onClickExit();
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

    if self.listBg then
        self.listBg:removeFromParent();
        self.listBg = nil;
        self:showAddBankList();
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

function TableLayer:createBankList()
    local listBg = ccui.ImageView:create("BG/kuang.png");
    listBg:setPosition(self.Button_bankList:getPositionX()+listBg:getContentSize().width*0,
        self.Button_bankList:getPositionY()-listBg:getContentSize().height*0.5-20);
    self.Node_5:addChild(listBg);
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

    local score = FontConfig.createWithSystemFont(goldConvert(userInfo.i64Money,1), 20,cc.c3b(252,215,27));
    score:setAnchorPoint(0,0.5);
    layout:addChild(score);
    score:setPosition(layout:getContentSize().width*0.3,layout:getContentSize().height*0.3);

    local scoreBg = ccui.ImageView:create("BG/jinbi.png");
    score:addChild(scoreBg);
    scoreBg:setPosition(-20,score:getContentSize().height*0.5);

    return layout;
end

--续投
function TableLayer:recordAddScore()
    luaDump(self.m_recordScore,"recordAddScore");
    -- for k,v in pairs(self.m_recordScore) do
    --     if v >0 then
    --         msg = {}
    --         msg.cbJettonArea = k;
    --         msg.iJettonScore = v;
    --         luaPrint("发送下注");
    --         RoomLogic:send(RoomMsg.MDM_GM_GAME_NOTIFY, GameMsg.SUB_C_PLACE_JETTON,msg,GameMsg.CMD_C_PlaceJetton)
    --     end
    -- end
    BCBMInfo:sendXuTouMessage(self.m_recordScore);
end

--续投按钮是否可以点击
function TableLayer:setXuTouButtonEnable()
    self.Button_xuzhu:setEnabled(false);

    local score = 0;
    for k,v in pairs(self.m_recordScore) do
        score = score + v;
    end

    if score > 0 and self.UserScore>score and not self.isXiaZhu and self:getGameState() == GameMsg.GS_Play then
        self.Button_xuzhu:setEnabled(true);
    end

    if self.bankerLseatNo == self.tableLogic._mySeatNo then --庄家是自己
        self.Button_xuzhu:setEnabled(false);
    end
end

function TableLayer:showSystemBank(isTrue)

    luaPrint("showSystemBank",isTrue);

    local system = self.Image_bankbg:getParent():getChildByName("system");
    if system then
        system:removeFromParent();
    end

    if isTrue then
        local system = ccui.ImageView:create("BG/xitong.png");
        system:setName("system");
        system:setPosition(self.Image_bankbg:getPositionX()+40,self.Image_bankbg:getPositionY());
        self.Image_bankbg:getParent():addChild(system);
        self.Image_bankbg:setVisible(false);
        self.Button_bankList:setVisible(false);
        self.Button_shangzhuang:setVisible(false);
    else
        self.Image_bankbg:setVisible(true);
        self.Button_bankList:setVisible(true);
        self.Button_shangzhuang:setVisible(true);
    end
end

function TableLayer:DealXuTouFail()
    addScrollMessage("庄家不够赔付");
end

function TableLayer:showPlayGameNum()
    if self.m_playGameNum >= 3 then
        if self.m_playGameNum >= 5 then
	        addScrollMessage("您已连续5局未参与游戏，已被请出房间！");
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
                self:onClickExit();
            end)));
        else
            addScrollMessage("您已连续"..self.m_playGameNum.."局未参与游戏，连续5局未参与游戏会被暂时请出房间哦！");
        end
    end
end

return TableLayer
