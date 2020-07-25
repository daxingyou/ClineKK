local TableLayer = class("TableLayer", BaseWindow)
local TableLogic = require("doudizhu.TableLogic");
local PopUpLayer = require("doudizhu.PopUpLayer")
local CardSprite = require("doudizhu.CardSprite")
local CardLayer = require("doudizhu.CardLayer")
local doudizhu = require("doudizhu");

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
    display.loadSpriteFrames("doudizhu/plist/doudizhu.plist","doudizhu/plist/doudizhu.png")

    local uiTable = {
        Button_manager = {"Button_manager",0,1},
        --Node_5 = {"Node_5",0},
        Button_tuoguan = {"Button_tuoguan",1},
        Button_rule = {"Button_rule",1},

        Node_bjeffect = "Node_bjeffect",
        Panel_cardBg = "Panel_cardBg",
        Image_bg = "Image_bg",
        Image_renwu2 = "Image_renwu2",
        Image_renwu3 = "Image_renwu3",
        Image_zhuo = "Image_zhuo",
        Image_renwu1 = "Image_renwu1",

        Node_1 = "Node_1",
        Node_user1 = "Node_user1",
        Text_Name1 = "Text_Name1",
        AtlasLabel_gold1 = "AtlasLabel_gold1",
        AtlasLabel_ying1 = "AtlasLabel_ying1",
        AtlasLabel_shu1 = "AtlasLabel_shu1",
        Image_tips1 = "Image_tips1",
        Node_user2 = "Node_user2",
        AtlasLabel_gold2 = "AtlasLabel_gold2",
        Image_leftCardBg = "Image_leftCardBg",
        AtlasLabel_paishu2 = "AtlasLabel_paishu2",
        AtlasLabel_ying2 = "AtlasLabel_ying2",
        AtlasLabel_shu2 = "AtlasLabel_shu2",
        Image_tips2 = "Image_tips2",
        Node_user3 = "Node_user3",
        AtlasLabel_gold3 = "AtlasLabel_gold3",
        Image_rightCardBg = "Image_rightCardBg",
        AtlasLabel_paishu3 = "AtlasLabel_paishu3",
        AtlasLabel_ying3 = "AtlasLabel_ying3",
        AtlasLabel_shu3 = "AtlasLabel_shu3",
        Image_tips3 = "Image_tips3",

        AtlasLabel_doublenum = "AtlasLabel_doublenum",
        AtlasLabel_difen = "AtlasLabel_difen",

        Node_3 = "Node_3",
        Button_huanzhuo = "Button_huanzhuo",
        Button_startgame = "Button_startgame",
        -- Button_rule = "Button_rule",
        -- Button_tuoguan = "Button_tuoguan",
        Button_double = "Button_double",
        Button_nodouble = "Button_nodouble",
        Button_yifeng = "Button_yifeng",
        Button_liangfen = "Button_liangfen",
        Button_sanfeng = "Button_sanfeng",
        Button_nocall = "Button_nocall",
        Button_noout = "Button_noout",
        Button_tip = "Button_tip",
        Button_out ="Button_out",
        Button_yaobuqi = "Button_yaobuqi",
        Button_jdz = "Button_jdz",
        Button_bjdz = "Button_bjdz",
        Button_qdz = "Button_qdz",
        Button_bqdz = "Button_bqdz",
        Sprite_clock = "Sprite_clock",
        AtlasLabel_clock = "AtlasLabel_clock",

        Node_4 = "Node_4",
        Button_notuoguan = "Button_notuoguan",

        Node_5 = "Node_5",
        Panel_xiala = "Panel_xiala",
        Button_exit = "Button_exit",
        Button_yinxiao = "Button_yinxiao",
        Button_yinyue = "Button_yinyue",

        Image_masterCardBg = "Image_masterCardBg",

        Node_6 = "Node_6",

        Image_beilvBg = "Image_beilvBg",
        Image_difenBg = "Image_difenBg",

    }
    loadNewCsb(self,"doudizhu/tableLayer",uiTable)

    -- self.tableLogic = TableLogic.new(self, self.bDeskIndex, self.bAutoCreate, self.bMaster);
    -- self.tableLogic:enterGame();

    --初始化按钮
    self.Panel_xiala = self.Button_manager:getChildByName("Panel_xiala0");

    self.Button_exit = self.Panel_xiala:getChildByName("Button_exit");
    self.Button_yinxiao = self.Panel_xiala:getChildByName("Button_yinxiao");
    self.Button_yinyue = self.Panel_xiala:getChildByName("Button_yinyue");

    self:initData();

    _instance = self;
end

function TableLayer:onEnter()

    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");

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

    self.gameName = "dz_ddz"

    self.isTouchLayer = false;

    --self:initGameData()
end

function TableLayer:initUI()
   
    self:showDeskInfo();

    self:initBtnClick();

    self:initMusic();
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
    self.musicTable = require("DdzMusicTable")
end


function TableLayer:initBtnClick()

    -- self.Button_manager:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_hideManager:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_yinxiao:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_yinyue:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_exit:addClickEventListener(function(sender) self:onClick(sender) end)
    
    self.Button_huanzhuo:addClickEventListener(function(sender) self:onClick(sender) end)
    self.Button_startgame:addClickEventListener(function(sender) self:onClick(sender) end)
    -- self.Button_rule:addClickEventListener(function(sender) self:onClick(sender) end)
   
    self.Button_manager:onClick(handler(self,self.onClick))
    self.Button_yinxiao:onClick(handler(self,self.onClick))
    self.Button_yinyue:onClick(handler(self,self.onClick))
    self.Button_exit:onClick(handler(self,self.onClick))

    --self.Button_huanzhuo:onClick(handler(self,self.onClick))
    --self.Button_startgame:onClick(handler(self,self.onClick))
    self.Button_rule:onClick(handler(self,self.onClick))

end


--界面信息的初始化
function TableLayer:showDeskInfo()
    --隐藏下拉
    self.Panel_xiala:setVisible(false)
    --隐藏闹钟和游戏按钮
    self.Sprite_clock:setVisible(false)
    self:showGameBtn();
    --隐藏取消托管
    self.Node_4:setVisible(false)

    --隐藏结果分数
    self:showWinScore();

    --隐藏用户加倍叫分出牌等提示
    self:HideAllUserTips();
    --创建出牌层
    -- self.cardLayer = CardLayer:create(self);
    -- self.Panel_cardBg:addChild(self.cardLayer)
    --游戏背景的特效展示(一直存在)
    self:ShowGameBgSpecialEffects();

    self.Node_user2:setVisible(false)
    self.Node_user3:setVisible(false)

    self.AtlasLabel_doublenum:setString("0");
    self.AtlasLabel_difen:setString(self.score)
    self.Text_Name1:setString(FormotGameNickName(PlatformLogic.loginResult.nickName,nickNameLen));
    self:ScoreToMoney(self.AtlasLabel_gold1,self.userScore)

    self.Image_masterCardBg:setVisible(false);
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
    self.text = self.text +1;
    local senderName = sender:getName();
    local senderTag = sender:getTag();
    luaPrint("TableLayer:onClick",senderName,senderTag)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("doudizhu/plist/doudizhu.plist");
    if senderName == "Button_huanzhuo" then
        self:showFangjian();
    elseif senderName == "Button_startgame" then
        self:showFangjian();
    elseif senderName == "Button_rule" then
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
        if senderTag ~= 1001 then--关闭音效
            sender:setTag(1001); 
            setEffectIsPlay(false)
            sender:loadTextures("ddz_xlyinxiao-guan.png","ddz_xlyinxiao-guan-on.png","ddz_xlyinxiao-guan-on.png",UI_TEX_TYPE_PLIST)
        else
            sender:setTag(1002);--打开音效
            setEffectIsPlay(true)
            sender:loadTextures("ddz_xlyinxiao-kai.png","ddz_xlyinxiao-kai-on.png","ddz_xlyinxiao-kai-on.png",UI_TEX_TYPE_PLIST)
        end
    elseif senderName == "Button_yinyue" then
        if senderTag ~= 1003 then--关闭音yue
            sender:setTag(1003);
            setMusicIsPlay(false)
            sender:loadTextures("ddz_xlyinyue-guan.png","ddz_xlyinyue-guan-on.png","ddz_xlyinyue-guan-on.png",UI_TEX_TYPE_PLIST)
        else
            sender:setTag(1004);--打开音yue
            setMusicIsPlay(true)
            playMusic("effect/ddz_gameBg.mp3")
            sender:loadTextures("ddz_xlyinyue-kai.png","ddz_xlyinyue-kai-on.png","ddz_xlyinyue-kai-on.png",UI_TEX_TYPE_PLIST)
        end
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
    local WarnAnim = {
        name = "beijingtexiao",
        json = "game/beijin/beijingtexiao.json",
        atlas = "game/beijin/beijingtexiao.atlas",
    }
    addSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    local skeleton_animation = createSkeletonAnimation(WarnAnim.name ,WarnAnim.json,WarnAnim.atlas);
    self.Node_bjeffect:addChild(skeleton_animation);
    skeleton_animation:setPosition(cc.p(640,360));
       
    skeleton_animation:setAnimation(0,WarnAnim.name, true);
end

function TableLayer:showFangjian()
    if self.isTouchLayer then
        return;
    end
    self.isTouchLayer = true;
    performWithDelay(self,function()  self.isTouchLayer = false end,1);
    doudizhu.erterRoom = true;
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
