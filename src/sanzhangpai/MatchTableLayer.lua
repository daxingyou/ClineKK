local TableLayer = class("TableLayer", BaseWindow)
local TableLogic = require("sanzhangpai.TableLogic");
local PopUpLayer = require("sanzhangpai.PopUpLayer")
local sanzhangpai = require("sanzhangpai");

local difenNum = {"1.00","0.00","0.10","2.00","5.00","0.00","0.00","0.00"}


--游戏类
function TableLayer:scene(userScore,cellScore)

    bulletCurCount = 0;

    local layer = TableLayer:create(userScore,cellScore);

    local scene = display.newScene();

    scene:addChild(layer);

    layer.runScene = scene;

    return scene;
end
--创建类
function TableLayer:create(userScore,cellScore)
    --Event:clearEventListener();
    luaPrint("-----------TableLayer:create-",userScore)
    local layer = TableLayer.new(userScore,cellScore);

    globalUnit.isFirstTimeInGame = false;

    return layer;
end

--静态函数
function TableLayer:getInstance()
    return _instance;
end
--构造函数
function TableLayer:ctor(userScore,cellScore)
    self.super.ctor(self, 0, true);
    PLAY_COUNT = 3;
    --GameMsg.init();
    if globalUnit.isTryPlay == true then
        self.userScore = userScore or 10000000;
    else
        self.userScore = userScore or PlatformLogic.loginResult.i64Money;
    end
    
    self.number = globalUnit.iRoomIndex --- = 1;
    if cellScore then
        self.score = cellScore;
    else
        self.score = difenNum[self.number] ----= 1000;
    end
    --display.loadSpriteFrames("sanzhangpai/plist/doudizhu.plist","sanzhangpai/plist/doudizhu.png")

    --获取ui
    local uiTable = {
        Image_bg        =   "Image_bg",
        Panel_menu      =   "1",    --菜单栏
        Button_exit     =   "1",    --返回按钮
        Button_help     =   "1",    --帮助
        Button_sound    =   "1",    --音效

        Panel_tableInfo     =   "1",    --桌子信息层
        Image_jettonTotal   =   "1",    --桌子总下注背景
        Text_jettonTotal    =   "1",    --桌子总下注
        Image_tableInfo     =   "1",    --桌子信息背景图
        Text_baseJetton     =   "1",    --底注
        Text_singleJetton   =   "1",    --单注
        Text_round          =   "1",    --轮数

        Panel_chip          =   "1",    --下注区域
        Panel_chipArea      =   "1",    --下注区域

        Panel_cards         =   "1",    --牌层

        Panel_player        =   "1",    --玩家层

        Panel_message       =   "1",    --动作消息层

        Panel_operate       =   "1",    --操作层
        Button_auto         =   "1",    --跟到底
        Button_unAuto       =   "1",    --取消跟到底
        Button_fold         =   "1",    --弃牌
        Button_compare      =   "1",    --比牌
        Button_check        =   "1",    --看牌
        Button_raise        =   "1",    --加注
        Button_bet          =   "1",    --下注
        Button_follow       =   "1",    --跟注
        Button_allIn        =   "1",    --全下
        Button_eveal        =   "1",    --亮牌

        Panel_raise         =   "1",    --加注面板


        Panel_select        =   "1",    --比牌层
        Image_selectTipBg   =   "1",    --比牌提示背景图
        Image_selectTip     =   "1",    --比牌提示文字

        Panel_result        =   "1",    --结算显示层

        Panel_box = "1",    --菜单层
        Panel_boxList  = "1",  --菜单裁剪层
        Image_boxBg = "1",  --菜单背景图
        Button_effect = "1", --音效
        Button_music = "1", --音乐



        Panel_tip           =   "1",    --提示层
        Image_tipWaitBg     =   "1",    --游戏即将开始
        Image_tipWaitNext   =   "1",    --请等待下一局

        Image_chip          =   "1",    --筹码cell

        Image_dealer        =   "1",    --荷官

        Panel_ready         =   "1",    --准备面板
        Button_ready        =   "1",    --准备按钮

        Panel_anims         =   "1",    --动画层
        Panel_compare       =   "1",    --比牌层
        Image_foldCell      =   "1",    --弃牌

        Panel_continue      =   "1",    --玩家不操作 结算提示层
        Button_continue     =   "1",    --继续
        Button_leave        =   "1",    --离开

        Panel_countdown     =   "1",    --倒计时拦截层
    }

    
    for k,v in pairs(uiTable) do
        uiTable[k] = k;
    end

    --适配
    uiTable["Button_exit"] = {"Button_exit",0,1};
    uiTable["Button_help"] = {"Button_help",1};
    uiTable["Button_sound"] = {"Button_sound",1};
    uiTable["Panel_boxList"] = {"Panel_boxList",1};
    --Panel_boxList

    luaDump(uiTable,"uiTable------------1")

    -- 游戏内消息处理
    luaPrint("TableLayer:initUI---------------")
    loadNewCsb(self,"sanzhangpai/tablelayer",uiTable)

    _instance = self;
end

function TableLayer:onEnter()

    cc.SpriteFrameCache:getInstance():addSpriteFrames("sanzhangpai/plist/doudizhu.plist");

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

function TableLayer:initData()
	self.m_iHeartCount = 0;
	self.m_maxHeartCount = 3; 

    self.cardLayer = nil;--牌层

    self.text = 0;


    self.m_selectedNameID = 0
    self.m_selectedRoomID = 0

    self.gameName = "dz_ssz"

    self.isTouchLayer = false;

    --self:initGameData()
end

function TableLayer:initUI()
   
    self:showDeskInfo();

    self:initBtnClick();

    --self:initMusic();
end

function TableLayer:initMusic()
    local isEffect = getEffectIsPlay();
    if not isEffect then
        self.Button_yinxiao:setTag(1002);
        self:onClick(self.Button_yinxiao)
    end

    local isMusic = getMusicIsPlay();
    if isMusic then
        self.Button_yinyue:setTag(1003);
    else
        self.Button_yinyue:setTag(1004);
    end
    self:onClick(self.Button_yinyue)

    --self:initMusicFile();
    --self.musicTable = require("DdzMusicTable")
end


function TableLayer:initBtnClick()

    -- self.Button_manager:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_hideManager:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_yinxiao:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_yinyue:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_exit:addClickEventListener(function(sender) self:onClick(sender) end)
    
    --self.Button_huanzhuo:addClickEventListener(function(sender) self:onClick(sender) end)
    --self.Button_startgame:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_rule:addClickEventListener(function(sender) self:onClick(sender) end)
   
    --self.Button_manager:onClick(handler(self,self.onClick))
    --self.Button_yinxiao:onClick(handler(self,self.onClick))
    --self.Button_yinyue:onClick(handler(self,self.onClick))
    self.Button_exit:onClick(handler(self,self.onClick))

    --self.Button_huanzhuo:onClick(handler(self,self.onClick))
    --self.Button_startgame:onClick(handler(self,self.onClick))
    self.Button_help:onClick(handler(self,self.onClick))

end


--界面信息的初始化
function TableLayer:showDeskInfo()
    --隐藏下拉
    --桌子总下注
    self.Text_jettonTotal:setString(tostring(0));
    --底注
    self.Text_baseJetton:setString(tostring(0));
    --单注
    self.Text_singleJetton:setString(tostring(0));
    --轮数    
    self.Text_round:setString("0/0");
    --比牌提示背景
    self.Image_selectTipBg:setVisible(false);

    --结算层
    self.Panel_result:setVisible(false);

    --提示层
    self.Panel_tip:setVisible(false);
    --提示游戏即将开始
    self.Image_tipWaitBg:setVisible(false);
    --提示等待下一局
    self.Image_tipWaitNext:setVisible(false);

    --比牌动画层
    self.Panel_compare:setVisible(false);
    --准备层
    self.Image_readyTb = {};
    self.Button_ready:setVisible(false);
    self.Button_ready:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
    self.Button_ready:setName("Button_ready");
    for i=1,5 do
        local index = i - 1;
        local image = self.Panel_ready:getChildByName(string.format("Image_ready%d",i));
        image:setVisible(false);
        self.Image_readyTb[index] = image;
    end

    --弃牌图片
    self.Image_foldCell:setVisible(false);
    self.Image_dealer:setVisible(false);
    self.Panel_boxList:setVisible(false);
    --倒计时层
    self.Panel_countdown:setVisible(false);
    --玩家层
    self.Panel_player:setVisible(false);
    self.Panel_operate:setVisible(false);
    self.Panel_select:setVisible(false)
    self.Panel_compare:setVisible(false)
    --玩家手牌层
    self.Panel_cards:setVisible(false)
    --玩家弃牌 看牌 操作提醒
    self.Panel_message:setVisible(false)
    self.Panel_continue:setVisible(false)

    self.Button_sound:setVisible(false)
    self.Button_exit:setVisible(false);
    self.Button_help:setVisible(false);  
end

function TableLayer:showGameBtn(type1)
    self.Node_3:setVisible(true);
    self.Button_huanzhuo:setVisible(false);
    self.Button_startgame:setVisible(false);
    self.Button_double:setVisible(false);
    self.Button_nodouble:setVisible(false);
    self.Button_yifeng:setVisible(false);
    self.Button_liangfen:setVisible(false);
    self.Button_sanfeng:setVisible(false);
    self.Button_nocall:setVisible(false);
    self.Button_noout:setVisible(false);
    self.Button_tip:setVisible(false);
    self.Button_out:setVisible(false);
    self.Button_yaobuqi:setVisible(false)
    self.Button_tuoguan:setVisible(false)
    self.Button_jdz:setVisible(false);
    self.Button_bjdz:setVisible(false);
    self.Button_qdz:setVisible(false);
    self.Button_bqdz:setVisible(false);
    self.Button_exit:setVisible(false);
end

function TableLayer:showWinScore(flag)
    self.AtlasLabel_ying1:setVisible(false)
    self.AtlasLabel_shu1:setVisible(false)
    self.AtlasLabel_ying2:setVisible(false)
    self.AtlasLabel_shu2:setVisible(false)
    self.AtlasLabel_ying3:setVisible(false)
    self.AtlasLabel_shu3:setVisible(false)
end

function TableLayer:onClick(sender)
    local senderName = sender:getName();
    local senderTag = sender:getTag();
    luaPrint("TableLayer:onClick",senderName,senderTag)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("sanzhangpai/plist/doudizhu.plist");
    if senderName == "Button_huanzhuo" then
        self:showFangjian();
    elseif senderName == "Button_startgame" then
        self:showFangjian();
    elseif senderName == "Button_help" then
        self:addChild(PopUpLayer:create())
    elseif senderName == "Button_exit" then
        if self.isTouchLayer then
            addScrollMessage("房间匹配中,请稍等!")
            return;
        end
        Hall:exitGame(false,function()
            RoomLogic:close();
        end);
    elseif senderName == "Button_manager" then
        self.Panel_xiala:setVisible(not self.Panel_xiala:isVisible());

    elseif senderName == "Button_hideManager" then
        --self.Panel_xiala:setVisible(false);
        --self.Button_hideManager:setVisible(false);
    elseif senderName == "Button_yinxiao" then
    end
end

--隐藏桌面类型图片
function TableLayer:HideTips(seatNo)
    self["Image_tips"..seatNo]:setVisible(false);
end
--隐藏所有人的类型图片
function TableLayer:HideAllUserTips()
    for i=1,PLAY_COUNT do
        self:HideTips(i);
    end
end

--游戏背景特效展示
function TableLayer:ShowGameBgSpecialEffects()
    --倒计时警告动画
    -- local WarnAnim = {
    --     name = "beijingtexiao",
    --     json = "game/beijin/beijingtexiao.json",
    --     atlas = "game/beijin/beijingtexiao.atlas",
    -- }
    -- addSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    -- local skeleton_animation = createSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    -- self.Node_bjeffect:addChild(skeleton_animation);
    -- skeleton_animation:setPosition(cc.p(640,360));
       
    -- skeleton_animation:setAnimation(0,WarnAnim.name, true);
end

function TableLayer:showFangjian()
    if self.isTouchLayer then
        return;
    end
    self.isTouchLayer = true;
    performWithDelay(self,function()  self.isTouchLayer = false end,1);
    sanzhangpai.erterRoom = true;
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

return TableLayer
