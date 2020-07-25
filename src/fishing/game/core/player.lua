local player = class("player", BaseNode);
local FishManager = require("fishing.game.core.FishManager"):getInstance();
local DataCacheManager = require("fishing.game.core.DataCacheManager"):getInstance();

--bBlankPlayer 标志等待玩家
bulletMaxCount = 20;--最大发送子弹个数
bulletCurCount  = {};--当前屏幕自己子弹计数
ionTime = 8;--能量炮总时间
function player:ctor(userinfo, lSeatNo, container, database)
    self.super.ctor(self)
    self:setAnchorPoint(cc.p(0.5,0.5));
    self.lSeatNo = lSeatNo or 0;
    self.userInfo = userinfo;

    self.lSeatNo = self.lSeatNo  + 1;

    self:initData();

    self.isAlive = false;
    self.isFortLevelHookFortMult = false;--炮倍是否和炮台挂钩

    if userinfo then
        self.isAlive = true;
        self.score = userinfo.i64Money;
        self:setDefaultData();
        self:setDefaultModel(container, database);
        bulletCurCount[self.lSeatNo] = 0
    else
        self:setBlankPlayer();
    end
end

function player:initData()
    local winSize = cc.Director:getInstance():getWinSize();
    -- self.userPoints = {winSize.width/2-400,winSize.width/2,winSize.width/2+400,37.5, winSize.height-37.5};
    self.userPoints = {winSize.width/3.3,winSize.width-winSize.width/3.3,37.5, winSize.height-37.5, winSize.width/2};

    self.fireBulletDataCache = {}

    self.score = 0;

    if globalUnit.iRoomIndex == 1 then
        self.cur_zi_dan_cost = 1
    elseif globalUnit.iRoomIndex == 2 then
        self.cur_zi_dan_cost = 10
    elseif globalUnit.iRoomIndex == 3 then
        self.cur_zi_dan_cost = 100
    elseif globalUnit.iRoomIndex == 4 then
        self.cur_zi_dan_cost = 1000
    else
        self.cur_zi_dan_cost = 1000
    end
    
    self.zi_dan_level = 1;

    self.lockFish = nil;

    --锁定开启减速标志
    self.setLockFishSlow = false

    self.getCoinAnimationTime = 0

    self.cannon = nil;

    self.minFortMult = 0;
    self.maxFortMult = 0;
    self.fortStep = 0;
    self.ionUserTm = 0;

    self.isEnergyCannon = false;

    if self.lSeatNo == 1 then
        if globalUnit:getIsEnterRoomMode() == true then
            self:setPosition(cc.p(self.userPoints[2], self.userPoints[3]));
        else
            self:setPosition(cc.p(self.userPoints[5], self.userPoints[3]));
        end
    elseif self.lSeatNo == 2 then
        self:setPosition(cc.p(self.userPoints[1], self.userPoints[3]));
    elseif self.lSeatNo == 3 then
        self:setPosition(cc.p(self.userPoints[1], self.userPoints[4]));
    elseif self.lSeatNo == 4 then
        self:setPosition(cc.p(self.userPoints[2], self.userPoints[4]));
    end
end

function player:getIsAlive()
    return self.isAlive;
end

function player:setBlankPlayer(seat)
    local bgSprite = ccui.ImageView:create("game/wait.png");
    -- bgSprite:setScale9Enabled(true);
    -- bgSprite:setContentSize(cc.size(150,70));
    self:addChild(bgSprite);

    -- local label = FontConfig.createLabel(FontConfig.gFontConfig_26, "等待玩家...", cc.c3b(255,224,20));
    -- label:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2);
    -- bgSprite:addChild(label);

    local seq = cc.Sequence:create(cc.FadeTo:create(1,0), cc.FadeIn:create(1));
    bgSprite:runAction(cc.RepeatForever:create(seq));
    -- label:runAction(cc.RepeatForever:create(seq:clone()));
    if FLIP_FISH then
        bgSprite:setRotation(180);
    end
end

function player:setDefaultData()
    if self.userInfo.dwUserID == PlatformLogic.loginResult.dwUserID then
        self.mainPlayer = true;
        self:setLocalZOrder(0)
    else
        self.mainPlayer = false;
        self:setLocalZOrder(1)
        --子弹发射控制
        performWithDelay(self, function() self:createUpdateFunction(0.2) end, 0.5)
    end
end

function player:setFortMultSection(minMult, maxMult)
    if minMult == nil then
        if globalUnit.iRoomIndex == 1 then
            self.minFortMult = 1
        elseif globalUnit.iRoomIndex == 2 then
            self.minFortMult = 10
        elseif globalUnit.iRoomIndex == 3 then
            self.minFortMult = 100
        elseif globalUnit.iRoomIndex == 4 then
            self.minFortMult = 1000
        else
            self.minFortMuit = 1000
        end
    else
        self.minFortMult = minMult;
    end

    if maxMult == nil then
        if globalUnit.iRoomIndex == 1 then
            self.maxFortMult = 10
        elseif globalUnit.iRoomIndex == 2 then
            self.maxFortMult = 100
        elseif globalUnit.iRoomIndex == 3 then
            self.maxFortMult = 1000
        elseif globalUnit.iRoomIndex == 4 then
            self.maxFortMult = 5500
        else
            self.maxFortMult = 5500
        end
    else
        self.maxFortMult = maxMult
    end

    self.cur_zi_dan_cost = self.minFortMult;

    self:updateBullet(self.cur_zi_dan_cost);

    if self.cannon then
        if self.isFortLevelHookFortMult == true then
            self.cannon:setPaoOption(globalUnit:getSelectedCannon());
        else
            self.zi_dan_level = self:getFireGunLevel(self.cur_zi_dan_cost);
            self.cannon:setPaoOption(self.zi_dan_level);
        end
    end
end

--设置合适炮倍
function player:setAutoPaoMult()
    local score = self.score;

    local chuji = {1,2,3,4,5,6,7,8,9,10};
    local zhongji = {10,20,30,40,50,60,70,80,90,100};
    local gaoji = {100,200,300,400,500,600,700,800,900,1000};
    local haiyang = {1000,2000,3000,4000,5000,6000,7000,8000,9000,10000};

    local zidan = 0;
    luaPrint("自动切换时 score = "..score)
    if(score >=1 and score <= 10)then
        luaPrint("初级场")
        for i=#chuji,1, -1 do
            luaPrint("chuji[i] = "..chuji[i])
            if score >= chuji[i] then
                zidan = chuji[i];
                luaPrint("找到了")
                break;
            end
        end
    elseif(score >= 10 and score <= 100)then
        for i=#zhongji,1, -1 do
            if score >= zhongji[i] then
                zidan = zhongji[i];
                break;
            end
        end
    elseif(score >= 100 and score <= 1000)then
        for i=#gaoji,1, -1 do
            if score >= gaoji[i] then
                zidan = gaoji[i];
                break;
            end
        end
    else--if(score >= 1000 and score <= 5500)then
        for i=#haiyang,1, -1 do
            if score >= haiyang[i] then
                zidan = haiyang[i];
                break;
            end
        end
    end
    luaPrint("自动切换炮倍 ------------"..zidan)
    if zidan ~= 0 then
        self:palyerChangeEffect()
        self.cur_zi_dan_cost = zidan;        
        self:updateBullet(self.cur_zi_dan_cost)
        self.zi_dan_level = self:getFireGunLevel(self.cur_zi_dan_cost);

        if self.isFortLevelHookFortMult == true then
            
        else
            self.cannon:setPaoOption(self.zi_dan_level)
        end

        audio.playSound("sound/gun_up.mp3");
    end
end

function player:onEnter()
    self.playerUpdateSchedule = schedule(self, function() self:playerUpdate(1/60); end, 1/60);

    self.bindIds = {}
    self.bindIds[#self.bindIds + 1] = BindTool.bind(FishManager, "gameRotateEvent", handler(self, self.gameRotateEvent))
    if self.mainPlayer == true then
        self.bindIds[#self.bindIds + 1] = BindTool.bind(globalUnit, "updatePao", handler(self, self.updatePao))
    end
end

function player:onExit()
    self:deleteUpdateFunction()
    
    if self.playerUpdateSchedule then
       self:stopAction(self.playerUpdateSchedule);
       self.playerUpdateSchedule = nil;
    end

    for _, bindid in ipairs(self.bindIds) do
        BindTool.unbind(bindid)
    end
end

function player:getSeatNo()
    return self.lSeatNo-1;
end

function player:gameSceneTouchEvent()
    self:exitToolBoxLayer()
    if self.showDescLayer then
        self.showDescLayer:removeFromParent();
        self.showDescLayer = nil;
    end
end

function player:gameRotateEvent()
    if FLIP_FISH then        
        self:setRotation(180);
        if self.cannon and self.cannon.paoTai then
            if self.seat < 3 then
                paoTai:setPosition(cc.p(self:getContentSize().width/2,-10));
            else
                paoTai:setPosition(cc.p(self:getContentSize().width/2,10));
            end
        end
    end
end

function player:updatePao()
    if self.cannon then
        self.cannon:setPaoOption(globalUnit:getSelectedCannon());
    end    
end

function player:createUpdateFunction(updateTime)
    self:deleteUpdateFunction();

    if self.isRobot ~= true then
        self.playerBulletUpdate = schedule(self, function() self:bulletUpdate() end, updateTime);
    end
end

function player:deleteUpdateFunction()
    if self.playerBulletUpdate then
        self:stopAction(self.playerBulletUpdate);
        self.plyaerBulletUpdate = nil;
    end
end

function player:setLockFish(fish)
    if(self.mainPlayer and fish ~= self.lockFish and fish ~= nil)then
        self.aimLineIcon:setScale(7)
        self.aimLineIcon:runAction(cc.EaseSineIn:create(cc.ScaleTo:create(0.5,1)))
        -- self:showLockFish(true,fish)
    end

    if fish and not tolua.isnull(fish) then
        self:showLockFish(true,fish)
    else
        self:showLockFish(false)
    end

    self.lockFish = fish
end

function player:showLockFish(visible,lockFish)
    local scale = {0.8,0.7,0.6,0.6,0.6,
                   0.6,0.5,0.5,0.4,0.5,
                   0.3,0.3,0.25,0.24,0.2,
                   0.25,0.25,0.2,0.15,0.15,

                   0.2,0.25,0.25,0.25,0.3,

                   0.3,0.3,0.2,0.2,0.2,

                   0.5,0.5,0.5,0.5,0.5,
                   0.5,0.5,0.5,0.5,0.5,

                   0.15,0.12,0.07,0.1,0.5,
                   0.7,0.5,0.5,0.5,0.5,
                   0.3,0.3,0.2,0.25,0.2,
                   0.2,0.3,0.22,0.5,0.5,
                   0.4,0.23,0.2,0.2};
    self.lockdibg:setVisible(visible)
    if lockFish ~= self.lockFish and visible and lockFish and not tolua.isnull(lockFish) then
        self.lockdibg:removeAllChildren()
        local suo = ccui.ImageView:create("game/suo.png");
        self.lockdibg:addChild(suo,2);
        suo:setPosition(50,12)

        local v = lockFish._fishType;
        local str = "";
        local image = nil;
        if v >= FishType.FISH_FENGHUANG and v <= FishType.FISH_KIND_40 then--鱼王
            str = "fish_"..(v-30).."_1.png";
            image = ccui.ImageView:create("effect/39/dish.png");
            image:setPosition(self.lockdibg:getContentSize().width/2,self.lockdibg:getContentSize().height/2);
            self.lockdibg:addChild(image);
            image:setScale(scale[v]);
        elseif v >= 25 and v <= 27 then--三元
            str = "fish";
            image = ccui.ImageView:create("game/jiesuan/sanyuan/s"..(v-24)..".png");
            image:setPosition(self.lockdibg:getContentSize().width/2,self.lockdibg:getContentSize().height/2);
            self.lockdibg:addChild(image);
            image:setScale(scale[v]);
        elseif v >= 28 and v <= 30 then--四喜
            str = "fish";
            image = ccui.ImageView:create("game/jiesuan/sanyuan/s"..(v-24)..".png");
            image:setPosition(self.lockdibg:getContentSize().width/2,self.lockdibg:getContentSize().height/2);
            self.lockdibg:addChild(image);
            image:setScale(scale[v]);
        else
            str = "fish_"..v.."_1.png";
        end
        display.loadSpriteFrames("fishing/fishing/fish/fish_test1.plist", "fishing/fishing/fish/fish_test1.png");
        display.loadSpriteFrames("fishing/fishing/fish/fish_test2.plist", "fishing/fishing/fish/fish_test2.png");
        display.loadSpriteFrames("fishing/fishing/fish/fish_test3.plist", "fishing/fishing/fish/fish_test3.png");
        display.loadSpriteFrames("fishing/fishing/fish/fish_test4.plist", "fishing/fishing/fish/fish_test4.png");
        display.loadSpriteFrames("fishing/fishing/fish/boss.plist", "fishing/fishing/fish/boss.png");
        display.loadSpriteFrames("fishing/fishing/fish/boss1.plist", "fishing/fishing/fish/boss1.png");
        display.loadSpriteFrames("fishing/fishing/fish/boss2.plist", "fishing/fishing/fish/boss2.png");
        if str ~= "" then
            local x = 0;
            local fish = nil;
            if str ~= "fish" then
                fish = cc.Sprite:createWithSpriteFrameName(str);
            else
                fish =cc.Sprite:create("hall/common/touming.png")
            end
            if image == nil then
                fish:setPosition(self.lockdibg:getContentSize().width/2,self.lockdibg:getContentSize().height/2);            
                fish:setScale(scale[v]);
                self.lockdibg:addChild(fish);
            else
                fish:setPosition(image:getContentSize().width/2,image:getContentSize().height/2);
                image:addChild(fish);
            end 
        end    
    end
end

function player:setDefaultModel(container, database)
    local seat = self.lSeatNo;

    --炮台
    local lv = self.zi_dan_level;
    if self.mainPlayer and self.isFortLevelHookFortMult == true then
        lv = globalUnit:getSelectedCannon();
    end

    local cannon = require("fishing.game.core.cannon").new(container, database, seat, self, lv);
    self:addChild(cannon,10);
    self.cannon = cannon;
    cannon.model:setAnimation(lv+2,"pao"..(lv-1).."dong", false);

    --瞄准线
    self.aimLine = {}
    for i=1,6 do
        table.insert(self.aimLine, display.newSprite("game/dian.png"):addTo(self):hide())
    end
    local aimLineIcon = display.newSprite("game/focus.png"):addTo(self):hide();
    table.insert(self.aimLine, aimLineIcon)
 
    aimLineIcon:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 360)));
    self.aimLineIcon = aimLineIcon

    --子弹倍率
    local bulletCostBg = ccui.ImageView:create("game/bullet_cost_bg.png")
    self.cannon.paoTai:addChild(bulletCostBg,11)
    self.bulletCostBg = bulletCostBg;
    bulletCostBg:setAnchorPoint(cc.p(0.5,0));
    bulletCostBg:setPosition(cc.p(self.cannon.paoTai:getContentSize().width/2, 0));

    self.labelValue = FontConfig.createWithCharMap(goldConvert(self.cur_zi_dan_cost), "game/zidannum.png", 18, 23, "+",{{"x","+"}})--FontConfig.createLabel(FontConfig.gFontConfig_28, self.cur_zi_dan_cost, cc.c3b(255,224,20));
    bulletCostBg:addChild(self.labelValue);
    self.labelValue:setPosition(cc.p(bulletCostBg:getContentSize().width/2, bulletCostBg:getContentSize().height/2));

     --金币底框
    local bgSprite = ccui.ImageView:create("playing_bg.png");
    -- bgSprite:setScale9Enabled(true);
    bgSprite:setAnchorPoint(cc.p(0.5,0));
    cannon.paoTai:addChild(bgSprite,9);
    self.playBg = bgSprite;

    local bgSpriteNode = ccui.ImageView:create();
    bgSpriteNode:setContentSize(bgSprite:getContentSize())
    bgSpriteNode:setAnchorPoint(cc.p(0.5,0.5))
    bgSpriteNode:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2)
    bgSprite:addChild(bgSpriteNode)

    local lockdibg = ccui.ImageView:create("game/lockdibg.png");
    cannon.paoTai:addChild(lockdibg,9);
    lockdibg:setPosition(-100,120)
    lockdibg:setVisible(false)
    self.lockdibg = lockdibg;

    local suo = ccui.ImageView:create("game/suo.png");
    lockdibg:addChild(suo,2);
    suo:setPosition(50,12)

    if FLIP_FISH then
        if self.lSeatNo == 1 or self.lSeatNo == 4 then
            bgSprite:loadTexture("playing_bg2.png");
        end
    else
        if self.lSeatNo == 2 or self.lSeatNo == 3 then
            bgSprite:loadTexture("playing_bg2.png");
        end
    end

    if FLIP_FISH then
        if self.lSeatNo == 2 or self.lSeatNo == 4 then
            lockdibg:setPositionX(280)
        end
    else
        if self.lSeatNo == 2 or self.lSeatNo == 4 then
            lockdibg:setPositionX(280)
        end
    end

    local userCoreBgPosX = cannon.paoTai:getContentSize().width/2;

    if FLIP_FISH then
         if(self.lSeatNo == 2)then
            userCoreBgPosX = 10;
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
            bgSprite:setAnchorPoint(cc.p(0,0));
        elseif(self.lSeatNo == 4)then
            userCoreBgPosX = 10;
            bgSprite:setAnchorPoint(cc.p(1,0));
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
        elseif(self.lSeatNo == 1)then
            userCoreBgPosX = userCoreBgPosX*2-10;
            bgSprite:setAnchorPoint(cc.p(1,0));
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
        elseif(self.lSeatNo == 3)then
            userCoreBgPosX = userCoreBgPosX*2 - 10;
            bgSprite:setAnchorPoint(cc.p(0,0));
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
        end
    else
         if(self.lSeatNo == 3)then
            userCoreBgPosX = userCoreBgPosX*2 - 10;
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
            bgSprite:setAnchorPoint(cc.p(1,0));
        elseif(self.lSeatNo == 2)then
            userCoreBgPosX = 10;
            bgSprite:setAnchorPoint(cc.p(1,0));
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
        elseif(self.lSeatNo == 4)then            
            userCoreBgPosX = 10;
            bgSprite:setAnchorPoint(cc.p(0,0));
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
        elseif(self.lSeatNo == 1)then
            userCoreBgPosX = userCoreBgPosX*2 - 10;
            bgSprite:setPosition(cc.p(userCoreBgPosX,0));
            bgSprite:setAnchorPoint(cc.p(0,0));
        end
    end

    local size = bgSprite:getContentSize();

    local gold = ccui.ImageView:create("game/gold.png");
    gold:setPosition(size.width/4-25,44);
    bgSpriteNode:addChild(gold);

    self.numberLayer = FontConfig.createWithCharMap(string.format("%.2f", FormatNumToString(goldConvert(self.score),1)), "game/zidannum.png", 18, 23, "+")
    self.numberLayer:setAnchorPoint(0,0.5)
    self.numberLayer:setPosition(gold:getPositionX()+gold:getContentSize().width/2+10,44)
    bgSpriteNode:addChild(self.numberLayer)

    self.lv = FontConfig.createWithSystemFont("", 18, cc.c3b(38, 254, 241));
    self.lv:setPosition(size.width/4,17)
    bgSpriteNode:addChild(self.lv)

    self.nickname = FontConfig.createWithSystemFont(FormotGameNickName(self.userInfo.nickName,7), 18, FontConfig.colorWhite)
    self.nickname:setPosition(self.lv:getPositionX()+self.lv:getContentSize().width/2+10,17)
    self.nickname:setAnchorPoint(cc.p(0,0.5));
    bgSpriteNode:addChild(self.nickname)
    if self.userInfo.IsYueKa == 1 then
        self.nickname:setColor(cc.c3b(255,0,0))
    end

    --能量炮
    self.energyPaoNode = ccui.ImageView:create();
    self.energyPaoNode:setContentSize(bgSprite:getContentSize())
    self.energyPaoNode:setAnchorPoint(cc.p(0.5,0.5))
    self.energyPaoNode:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2)
    bgSprite:addChild(self.energyPaoNode)
    self.energyPaoNode:setVisible(false);

    local commonPath = ""
    if FLIP_FISH then
        if self.lSeatNo == 3 then
            commonPath = "energycannon/youxia/"
        elseif self.lSeatNo == 4 then
            commonPath = "energycannon/zuoxia/"
        end

        if self.lSeatNo == 1 or self.lSeatNo == 2 then
            commonPath = "energycannon/"..(self.lSeatNo+2).."/";
        end
    else
        if self.lSeatNo == 1 then
            commonPath = "energycannon/youxia/"
        elseif self.lSeatNo == 2 then
            commonPath = "energycannon/zuoxia/"
        end

        if self.lSeatNo == 3 or self.lSeatNo == 4 then
            commonPath = "energycannon/"..self.lSeatNo.."/";
        end
    end
    
    local r = -2
    self.energyPao = ccui.ImageView:create(commonPath.."zi.png");
    self.energyPao:setAnchorPoint(0.5,0);
    self.energyPao:setPosition(cc.p(self.energyPao:getContentSize().width/2-r,size.height/2));
    self.energyPaoNode:addChild(self.energyPao);

    self.barbg = ccui.ImageView:create(commonPath.."dutiao-bg.png");
    self.barbg:setAnchorPoint(0,0);
    self.barbg:setPosition(cc.p(self.energyPao:getContentSize().width-5,0));
    self.energyPao:addChild(self.barbg);

    local energyBody = cc.Sprite:create(commonPath.."dutiao.png")
    self.energyProgress = cc.ProgressTimer:create(energyBody)  
    self.energyProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)--条形 
    if FLIP_FISH then
        if self.lSeatNo == 1 or self.lSeatNo == 4 then
            self.energyProgress:setMidpoint(cc.p(1, 0))
        else
            self.energyProgress:setMidpoint(cc.p(0, 0))
        end
    else
        if self.lSeatNo == 2 or self.lSeatNo == 3 then
            self.energyProgress:setMidpoint(cc.p(1, 0))
        else
            self.energyProgress:setMidpoint(cc.p(0, 0))
        end
    end
    self.energyProgress:setBarChangeRate(cc.p(1, 0))
    self.energyProgress:setPercentage(100) -- 设置初始进度
    self.energyProgress:setPosition(cc.p(self.barbg:getContentSize().width/2,self.barbg:getContentSize().height/2));
    self.barbg:addChild(self.energyProgress);

    if FLIP_FISH then
        if self.lSeatNo == 1 or self.lSeatNo == 4 then
            gold:setPositionX(gold:getPositionX()+245);
            self.numberLayer:setAnchorPoint(cc.p(1,0.5))
            self.numberLayer:setPositionX(gold:getPositionX()-gold:getContentSize().width/2-5);
            self.lv:setPositionX(self.lv:getPositionX()+60);
            self.nickname:setPositionX(self.lv:getPositionX()+self.lv:getContentSize().width/2+10);
        end
    else
        if self.lSeatNo == 2 or self.lSeatNo == 3 then
            gold:setPositionX(gold:getPositionX()+245);
            self.numberLayer:setAnchorPoint(cc.p(1,0.5))
            self.numberLayer:setPositionX(gold:getPositionX()-gold:getContentSize().width/2-5);
            self.lv:setPositionX(self.lv:getPositionX()+60);
            self.nickname:setPositionX(self.lv:getPositionX()+self.lv:getContentSize().width/2+10);
        end
    end

    if FLIP_FISH then
        if self.lSeatNo == 1 then
            self.energyPao:setAnchorPoint(cc.p(0,1));
            self.energyPao:setPositionX(size.width-self.energyPao:getContentSize().width+r);
            self.barbg:setAnchorPoint(cc.p(1,1));
            self.barbg:setPosition(3,self.energyPao:getContentSize().height);
        elseif self.lSeatNo == 2 then
            self.energyPao:setAnchorPoint(cc.p(0.5,1));
            self.barbg:setAnchorPoint(cc.p(0,1));
            self.barbg:setPosition(self.energyPao:getContentSize().width-3,self.energyPao:getContentSize().height);
        elseif self.lSeatNo == 4 then
            self.energyPao:setPositionX(size.width-self.energyPao:getContentSize().width/2+r);
            self.barbg:setAnchorPoint(cc.p(1,0));
            self.barbg:setPositionX(3);
        end
    else
        if self.lSeatNo == 2 then
            self.energyPao:setPositionX(size.width-self.energyPao:getContentSize().width/2+r);
            self.barbg:setAnchorPoint(cc.p(1,0));
            self.barbg:setPositionX(3);
        elseif self.lSeatNo == 3 then
            self.energyPao:setAnchorPoint(cc.p(0,1));
            self.energyPao:setPositionX(size.width-self.energyPao:getContentSize().width+r);
            self.barbg:setAnchorPoint(cc.p(1,1));
            self.barbg:setPosition(3,self.energyPao:getContentSize().height);
        elseif self.lSeatNo == 4 then
            self.energyPao:setAnchorPoint(cc.p(0.5,1));
            self.barbg:setAnchorPoint(cc.p(0,1));
            self.barbg:setPosition(self.energyPao:getContentSize().width-3,self.energyPao:getContentSize().height);
        end
    end

    if FLIP_FISH then
        self:setRotation(180);
        if self.lSeatNo <= 2 then
            self:specialForUp()
        end
    else
        if self.lSeatNo > 2 then
            self:specialForUp();
        end
    end

    if FLIP_FISH then
        if self.lSeatNo <= 2 then
            bgSprite:setFlippedX(true);
            self.numberLayer:setScaleX(-1);
            self.numberLayer:setRotation(180);
            self.nickname:setScaleX(-1);
            self.nickname:setRotation(180);
            self.lv:setScaleX(-1);
            self.lv:setRotation(180);
            gold:setScaleX(-1);
            gold:setRotation(180);
            self.labelValue:setRotation(180);
            self.energyPao:setScaleX(-1);
            self.energyPao:setRotation(180);
        end
    else
        if self.lSeatNo > 2 then
            bgSprite:setFlippedX(true);
            self.numberLayer:setScaleX(-1);
            self.numberLayer:setRotation(180);
            self.nickname:setScaleX(-1);
            self.nickname:setRotation(180);
            self.lv:setScaleX(-1);
            self.lv:setRotation(180);
            gold:setScaleX(-1);
            gold:setRotation(180);
            self.labelValue:setRotation(180);
            self.energyPao:setScaleX(-1);
            self.energyPao:setRotation(180);
        end
    end
     --破产图标
    if self.score < self.cur_zi_dan_cost then
        if(self.poSprite)then
           self.poSprite:show()
        else
           self:playPoChanAnimation()
        end
    end
end

--显示能量炮
function player:showEnergyPao()
    if self.getenergyAnimate == nil then
        local getenergyAnimate = createSkeletonAnimation("huodenengliangpao","energycannon/huodenengliangpao/huodenengliangpao.json", "energycannon/huodenengliangpao/huodenengliangpao.atlas");
        if getenergyAnimate then
            getenergyAnimate:setAnimation(2,"huodenengliangpao", false);
            getenergyAnimate:setPosition(cc.p(self.cannon.paoTai:getContentSize().width/2,200));
            self.cannon.paoTai:addChild(getenergyAnimate,10);
            performWithDelay(self, function() getenergyAnimate:setVisible(false); end,5);
            self.getenergyAnimate = getenergyAnimate;
        end
    else
        if self.ionUserTm <= 0 then
            self.getenergyAnimate:setVisible(true)
            self.getenergyAnimate:setAnimation(2,"huodenengliangpao", false);        
        end
    end

    if self.ionUserTm <= 0 then
        self.energyPaoNode:setVisible(true);
    end
    
    self.energyProgress:setPercentage(100)
    self.ionUserTm = 0;
    if self.updateEnergyScheduler then
        self:stopAction(self.updateEnergyScheduler)
        self.updateEnergyScheduler = nil;
    end
    
    self.updateEnergyScheduler = schedule(self, function() self:updateEnergyjindu(); end, 0.1)
end

function player:updateEnergyjindu()
    self.ionUserTm = self.ionUserTm + 1;
    local per = 1-(self.ionUserTm/(ionTime*10));
    
    if per < 0 then
        per = 0;
    end

    self.energyProgress:setPercentage(per*100);
    if self.ionUserTm == (ionTime*10) then
        self.ionUserTm = 0;
        self.energyPaoNode:setVisible(false);
        if self.updateEnergyScheduler then
            self:stopAction(self.updateEnergyScheduler)
            self.updateEnergyScheduler = nil;
        end
    end
end

--获取当前炮倍
function player:getFloorFortMultip(isAdd)
    
    -- if isAdd == nil or isAdd == true then
    --     self.zi_dan_level = self.zi_dan_level + 1;
    -- else
    --     self.zi_dan_level = self.zi_dan_level - 1;
    -- end

    local chuji = {1,2,3,4,5,6,7,8,9,10};
    local zhongji = {10,20,30,40,50,60,70,80,90,100};
    local gaoji = {100,200,300,400,500,600,700,800,900,1000};
    local haiyang = {1000,2000,3000,4000,5000,6000,7000,8000,9000,10000};

    local pao = {};

    if FishModule.m_gameFishConfig then
        self.minFortMult = FishModule.m_gameFishConfig.min_bullet_multiple
        self.maxFortMult = FishModule.m_gameFishConfig.max_bullet_multiple
    end

    if self.minFortMult == chuji[1] and self.maxFortMult == chuji[#chuji] then
        pao = chuji;
    elseif self.minFortMult == zhongji[1] and self.maxFortMult == zhongji[#zhongji] then
        pao = zhongji;
    elseif self.minFortMult == gaoji[1] and self.maxFortMult == gaoji[#gaoji] then
        pao = gaoji;
    elseif self.minFortMult == haiyang[1] and self.maxFortMult == haiyang[#haiyang] then
        pao = haiyang;
    end

    luaPrint("self.minFortMult = "..self.minFortMult.."  self.maxFortMult = "..self.maxFortMult)

    local index = nil

    for k,v in pairs(pao) do
        if v == self.cur_zi_dan_cost then
            index = k
            break
        end
    end
    luaPrint("index = "..tostring(index))
    local p = self.cur_zi_dan_cost

    if index ~= nil then
        if isAdd == nil or isAdd == true then
            if index == #pao then
                p = pao[1]
            else
                p = pao[index + 1]
            end
        else
            if index == 1 then
                p = pao[#pao]
            else
                p = pao[index - 1]
            end
        end
    end

    self.zi_dan_level = self:getFireGunLevel(p/100)

    return p
end

--自己炮倍改变+-炮
function player:changePaoMultiple(isAdd)
    if self.isEnergyCannon == true then
        return;
    end
    if self.mainPlayer then
        self:palyerChangeEffect()
    end

    self.cur_zi_dan_cost = self:getFloorFortMultip(isAdd) or self.cur_zi_dan_cost;
    
    self:updateBullet(self.cur_zi_dan_cost)
    if self.isFortLevelHookFortMult ~= true then
        self.cannon:setPaoOption(self.zi_dan_level)
    end

    -- DataCacheManager:setPlayerBulletConst(FishManager:getGameLayer().roomIndex,self.cur_zi_dan_cost)
    if self.isRobot ~= true then
        audio.playSound("sound/gun_up.mp3");
    end
end

function player:setPlayerMode(isEnabled,isReset)
    if isEnabled == nil then
        isEnabled = true;
    end

    -- if true then
    --     return;
    -- end

    --客户端是非能量炮状态时，收到服务端能量炮过期消息，不处理
    if isEnabled == false and self.isEnergyCannon ~= true then
        return;
    end

    if isEnabled == true and self.isEnergyCannon == true and isReset ~= 3 then
        return;
    end

    self.isEnergyCannon = isEnabled;

    self:changePoalMultWithIon(isReset);
end

--能量炮模式，仅改变炮等级 isReset 1能量炮结束 2 开炮同步能量炮状态 3 能量炮开始
function player:changePoalMultWithIon(isReset)
    self.cannon:setEnergyCannon(self.isEnergyCannon);

    if isReset == 2 then
        return;
    end

    if self.isEnergyCannon == true then
        if self.cannon then
            self.cannon.oldPaoOption = self.cannon.paoOption
            -- self.cannon:setPaoOption(5);
            if isReset == 3 then
                self:showEnergyPao();
            end
        end
    else
        -- self.cannon:setPaoOption(self.cannon.oldPaoOption);
        self.ionUserTm = 0;
        self.energyPaoNode:setVisible(false);
        if self.updateEnergyScheduler then
            self:stopAction(self.updateEnergyScheduler)
            self.updateEnergyScheduler = nil;
        end
    end
end

function player:createGuide()
    if self.guideNode then
        self.guideNode:removeFromParent()
        self.guideNode = nil
    end

    local guide = require("fishing.game.core.guideLayer").new(GuideTypeCannonUnlock);
    guide:setPosition(self.cannon.paoTai:getContentSize().width/2, 180);
    self.cannon.paoTai:addChild(guide);
    self.guideNode = guide
end

--其他玩家炮台
function player:setFortMultip(currentMultiple,paoLv)
    if currentMultiple == nil then
        luaPrint("数据错误")
        return
    end

    if FishModule.m_gameFishConfig.min_bullet_multiple <= currentMultiple and currentMultiple <= FishModule.m_gameFishConfig.max_bullet_multiple then
        self.cur_zi_dan_cost = currentMultiple
    elseif currentMultiple > FishModule.m_gameFishConfig.max_bullet_multiple then
        self.cur_zi_dan_cost = FishModule.m_gameFishConfig.max_bullet_multiple;
    end

    self:updateBullet(self.cur_zi_dan_cost)
    if self.isEnergyCannon ~= true then
        self.cannon:setPaoOption(paoLv);
    else
        self.cannon:setMoreFastFire(paoLv > 8);
    end
    
    -- DataCacheManager:setPlayerBulletConst(FishManager:getGameLayer().roomIndex,self.cur_zi_dan_cost)
end

function player:setFortInfo(fortOption,fortLevel)
    self.cannon:setFortInfo(fortOption,fortLevel)
end

function player:specialForUp()
    self.cannon.paoTai:setRotation(180);

    self.inUp = true;
end

function player:fireToPonit(targetPt)
    if not targetPt then
        return
    end

    --体验场时间结束不能发炮
    if self.mainPlayer and FishManager:getGameLayer().isNoFire == true then
        return
    end

    if bulletCurCount[self.lSeatNo] >= bulletMaxCount then
        Hall.showTips("屏幕子弹已达上限，不能发炮",0.5)
        return;
    end

    -- if true then
    --     return;
    -- end
    local winSize = cc.Director:getInstance():getWinSize();

    local x,y = targetPt.x,targetPt.y;

    if x < 0 or x > winSize.width or y < 0 or y > winSize.height then
        return true;
    end

    local potion = self:convertToNodeSpace(targetPt);
    local ptFrom = cc.p(self:getPositionX(), self:getPositionY());
    ptFrom = self:convertToNodeSpace(self.cannon:getPaoTongPos());

    if self:checkPoint(potion) == true then
        return;
    end

    --疯狂射击的时候发射三个子弹 所以扣三倍钱
    local fireCost = self.cur_zi_dan_cost;
    if(self.mainPlayer == true and self.isMoreFastShoot == true)then
       fireCost = self.cur_zi_dan_cost*3
    end

    self.score = self.score - fireCost;

    if self.score < 0 then
         --发射炮弹失败
        self.score = self.score + fireCost;
        self:updateScore(self.score)
        self:fireFailTip()
    else
        self.showTipsStation = nil;
        -- if self:getChildByName("draw1") then
        --     self:getChildByName("draw1"):removeFromParent();
        -- end
        -- local draw = cc.DrawNode:create()
        -- draw:setAnchorPoint(0,0)
        -- draw:setName("draw1");
        -- self:addChild(draw, 20)
        -- draw:setLocalZOrder(10000)
        -- draw:drawLine(cc.p(ptFrom.x,ptFrom.y), potion, cc.c4f(1,1,1,1))
        local angle =  math.atan((ptFrom.x - potion.x)/(ptFrom.y- potion.y)) / math.pi * 180;   

        if(ptFrom.y - potion.y >= 0)then
            angle = angle + 180;
        end

        if(FLIP_FISH)then
            if self.lSeatNo < 2 then
                angle = angle + 180;
            end
             if self.isRobot == true then
                if self.lSeatNo == 2 then
                    angle = angle + 180;
                end
            end
        else
            -- FishManager:getGameLayer().pnumberLayer:setString(tostring(self.isRobot))
            if self.isRobot == true then
                if self.lSeatNo > 2 then
                    angle = angle + 180;
                end
            end
        end
        self.cannon:rotationAndFire(angle,true,self.cur_zi_dan_cost,self.setLockFishSlow);
        self:updateScore(self.score)

         --子弹音效
        if self.mainPlayer then
            audio.playSound("sound/cannon.mp3");
        end
    end
end

function player:checkPoint(point)
    if not self.mainPlayer and not self.isRobot then
        return false
    end

    local size = cc.size(230,60)
    local pos = cc.p(0,-7)

    if self.isRobot then
        if self.lSeatNo > 2 then
            pos = cc.p(0,7)
        end
    end

    local ret = self:pointCompare(pos,size,point,1)

    if ret ~= true then
        size = cc.size(100,160)
        pos = cc.p(0,35)

         if self.isRobot then
             if self.lSeatNo > 2 then
                pos = cc.p(0,-35)
            end
        end

        ret = self:pointCompare(pos,size,point,0)
    end

    if self.isRobot then
        if FLIP_FISH then
            if self.lSeatNo == 3 then
                pos = cc.p(-115-275/2,-7+30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            elseif self.lSeatNo == 4 then
                pos = cc.p(115+275/2,-7+30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            elseif self.lSeatNo == 2 then
                pos = cc.p(-115-275/2,7-30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            elseif self.lSeatNo == 1 then
                pos = cc.p(115+275/2,7-30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            end
        else
            if self.lSeatNo == 1 then
                pos = cc.p(-115-275/2,-7+30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            elseif self.lSeatNo == 4 then
                pos = cc.p(-115-275/2,7-30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            elseif self.lSeatNo == 2 then
                pos = cc.p(115+275/2,-7+30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            elseif self.lSeatNo == 3 then
                pos = cc.p(115+275/2,7-30/2)
                size = cc.size(275,90)
                ret = self:pointCompare(pos,size,point,0.5)
            end
        end
    end

    return ret;
end

function player:pointCompare(pos,size,point,r)
    local x,y = pos.x,pos.y;

    local screenRect = cc.rect(x-size.width/2,y-size.height/2,size.width,size.height);

    -- local draw = cc.DrawNode:create()
    -- draw:setAnchorPoint(0,0)
    -- draw:setName("draw");
    -- self:addChild(draw, 1000)
    -- draw:setLocalZOrder(1000)
    -- -- draw:drawRect(cc.p(x-size.width/2,y-size.height/2), cc.p(x+size.width/2,y+size.height/2), cc.c4f(1,1,r,1))
    -- -- draw:drawPoint((cc.p(point.x,point.y)), 4, cc.c4f(1,0,0,1))
    -- draw:drawPoint((cc.p(x-size.width/2,y-size.height/2)), 4, cc.c4f(1,0,0,1))
    if cc.rectContainsPoint(screenRect, point) then
        return true;
    end

    return false;
end

function player:getRobotRotation()
    local lockFish = self.lockFish

    if lockFish == nil then
        return nil;
    end

    local targetPt = lockFish:getFishPos();

    local potion = self:convertToNodeSpace(targetPt);

    local ptFrom = self:convertToNodeSpace(self.cannon:getPaoTongPos());

    if self:checkPoint(potion) == true then
        return nil;
    end

    local angle =  math.atan((ptFrom.x - potion.x)/(ptFrom.y- potion.y)) / math.pi * 180;

    if(FLIP_FISH)then
        if self.lSeatNo > 2 then
            if(ptFrom.y - potion.y >= 0)then
                angle = angle - 180;                
            end
        else
            if(ptFrom.y - potion.y <= 0)then
                angle = angle + 180;
            end
        end
    else
        if self.lSeatNo > 2 then
            if(ptFrom.y - potion.y <= 0)then
                angle = angle - 180;    
            end
        else
            if(ptFrom.y - potion.y >= 0)then
                angle = angle + 180;
            end
        end
    end

    return angle;
end

function player:fireToDirection(angle,cost,bullet_id,android_chairid,lockFishID)
    local fireItem = {}
    fireItem.angle = angle
    fireItem.cost = cost
    fireItem.android_chairid = android_chairid
    fireItem.bullet_id = bullet_id
    if lockFishID > 0 then
        fireItem.isLockFishID = true;
    else
        fireItem.isLockFishID = false;
    end
    

    -- if android_chairid ~= 255 then
        -- local a = self:getRobotRotation();
        -- if a then
        --     fireItem.angle = a;
        -- else
        --     if FLIP_FISH then
        --         if self.lSeatNo > 2 then
        --             fireItem.angle = fireItem.angle + 180;
        --         end
        --     else 
        --         if self.lSeatNo > 2 then
        --           fireItem.angle = fireItem.angle + 180;
        --         end
        --     end
        -- end
    -- end

    table.insert(self.fireBulletDataCache,fireItem)
end

function player:updateFireToDirection(angle,cost,bullet_id,android_chairid,isRotate,isLockFishID)    
    if FLIP_FISH then
        if self.lSeatNo > 2 then
            angle = angle + 180;
        end
    else 
        if self.lSeatNo > 2 then
          angle = angle + 180;
        end
    end

    self.cannon:rotationAndFire(angle,false,cost,nil,bullet_id,android_chairid,isRotate,isLockFishID);

    --其他玩家的炮弹样式刷新
    self.cur_zi_dan_cost = cost
    self:updateBullet(cost)
end

function player:changeGameCallBack( result )
    if result then
        luaPrint("Player:changeGameCallBack( result )   true ")
        self:performWithDelay(function() FishManager:getGameLayer():exitGame(true) end, 0.2);
    else
        luaPrint("Player:changeGameCallBack( result )  false ")
    end

    self.isSHowWindow = nil

end

function player:fireFailTip()
    if self.mainPlayer == false then
        return
    end

    if self.showTipsStation then
        -- return
    end

    FishManager:getGameLayer():onClickAutoCallBack(FishManager:getGameLayer().Button_task,1);

    --锁定状态下取消技能状态
    if FishManager:getGameLayer().isAutoShoot == true then
        FishManager:getGameLayer():onClickUnLock();
    end
    
    FishManager:getGameLayer().isFiring = false;
    if goldReconvert(self.score) >= goldReconvert(self.cur_zi_dan_cost) and self.isMoreFastShoot == true then -- 当前金币可以发射炮弹，因为技能原因导致发射失败
        -- Hall.showTips("当前金币不够发射多颗子弹，请等技能冷却后再发！")
        FishManager:getGameLayer():onClickFastShoot(FishManager:getGameLayer().Button_fast,1);
    elseif self.cur_zi_dan_cost >= FishModule.m_gameFishConfig.min_bullet_multiple and FishModule.m_gameFishConfig.min_bullet_multiple <= self.score then --当前炮台倍数大于当前场次最低炮
        self:setAutoPaoMult();
    elseif self.score <  FishModule.m_gameFishConfig.min_bullet_multiple and self.score >= 10 and FishModule.m_gameFishConfig.min_bullet_multiple > 10 then -- 分数不够最低炮
        -- FishManager:getGameLayer():createBankLayer();
    elseif FishModule.m_gameFishConfig.min_bullet_multiple > self.score then --最低倍数也不够发射子弹
        -- if globalUnit:getIsRequestReliefMoney() == true then--救济金次数未用完
        -- else
        --     FishManager:getGameLayer():createBankLayer();
        -- end
    end

    -- self.showTipsStation = true

    -- self:runAction(cc.Sequence:create(
    --     cc.DelayTime:create(2),
    --     cc.CallFunc:create(function() self.showTipsStation = nil end)
    --     ))
end

--kind 鱼的类型; fishMulti 鱼的倍数
function player:changeScore(score, kind, fishMulti,isLiquan,isCrit,realScore)
    kind = kind or 0
    fishMulti = fishMulti or 0
    isLiquan = false;
    if isLiquan then
        self.gift = self.gift + score
    end

    self.score = realScore;
    if score and score > 0 then        
        -- self.score = self.score + score;

        self:showScoreAnimation(score, kind,fishMulti)
        -- self:getCoinAnimation(fishMulti,score)
    end

   --赚翻了
    kind = kind + 1
    if fishMulti>=80 then
        self:addZhuanfanleEffect(score,fishMulti,kind,isCrit);
    end

    if fishMulti >= 30 then
        --震屏
        self:playerShakeAction()
    end
    self:updateScore(self.score)
end

function player:updateBullet(const)
    if self.labelValue then
        const = goldConvert(const)
        if self.cannon.isMoreFastShoot == true then
            const = const.."+3"
        end
        self.labelValue:setString(const);
    end    
end

function player:updateScore(score)
    self.score = score or 0;

    self.numberLayer:setString(string.format("%.2f", FormatNumToString(goldConvert(self.score),1)));
    if FishModule.m_gameFishConfig == nil then
        return;
    end
    --破产图标
    if (self.score >= FishModule.m_gameFishConfig.min_bullet_multiple)then
        if(self.poSprite)then
           self.poSprite:hide()
        end

        if self.mainPlayer then
            if self.updateRelief then
                self:stopAction(self.updateRelief);
                self.updateRelief = nil;
            end
            FishManager:getInstance():getGameLayer():hideFreeCoin(1);
        end
    else
        FishManager:getInstance():getGameLayer().isResponeClick = true;
        if(self.poSprite)then
           self.poSprite:show()
        else
           self:playPoChanAnimation()
        end

        if self.mainPlayer then
            self:requestRelief();
        end
    end
    if tonumber(self.score) < 0 then
        luaPrint("self.score=="..self.score)
        luaPrint("self.score=="..bb)
    end
end

--救济金
function player:requestRelief()    
    if bulletCurCount[self.lSeatNo] <= 0 and FishManager:getGameLayer().chaoticBeadFish == nil then
        if self.updateRelief then
            self:stopAction(self.updateRelief);
            self.updateRelief = nil;
        end
        
        if not self:getActionByTag(5555) then
            performWithDelay(self,function()
                if self.score < FishModule.m_gameFishConfig.min_bullet_multiple then
                    addScrollMessage("您的金币不足")
                    showBuyTip();
                end
             end,1):setTag(5555)
        end
    else
        if self.updateRelief == nil then
            self.updateRelief = schedule(self,function() self:requestRelief(); end,0.5);
        end
    end
end

function player:updateLv(lv)
    if self.lv then
        -- lv = lv or self.vl:getString();
        lvstr = "lv:"..lv;
        self.lv:setString(lvstr);
    end
end

function player:changeGift( gift )

    gift = gift or 0
    self.gift = self.gift + gift

    self:updateGift(self.gift)
end

function player:updateGift(gift)
    
    self.gift = gift
    
    if self.giftNumberLabel then
        self.giftNumberLabel:setString(""..FormatNumToString(self.gift))
    end
end

function player:changeGem( gem )
    
    gem = gem or 0
    self.gem = self.gem + gem

    self:updateGem(self.gem)

end

function player:updateGem(gem)
    
    self.gem = gem
    if self.gemCountLabel then
        self.gemCountLabel:setString(""..FormatNumToString(self.gem))
    end 

    if self.mainPlayer then
        GoodsInfoDataCache:setGoodsInfoByID( GOODS_TYPE_GEM ,self.gem,false)
    end

end

function player:addZhuanfanleEffect(score,multi,fishType,isCrit)
    local bigFishCoinArmature = DataCacheManager:createEffect(GAME_ZHUANFAN_EFFECT)
    bigFishCoinArmature:setData(score,multi,fishType,isCrit,self.mainPlayer)
    bigFishCoinArmature:setPosition(cc.p(self.cannon:getContentSize().width+100,self.cannon:getContentSize().height+160));
    bigFishCoinArmature:addLinePathTo(cc.p(0,0));
    bigFishCoinArmature:playAction();
    self.cannon:addChild(bigFishCoinArmature);

    if FLIP_FISH then
        if self.lSeatNo <= 2 then
            bigFishCoinArmature:setScale(0.8);
            bigFishCoinArmature:setPosition(cc.p(self.cannon:getContentSize().width+100,-self.cannon:getContentSize().height-160))
        end
    else
        if self.lSeatNo > 2 then
            bigFishCoinArmature:setScale(0.8);
            bigFishCoinArmature:setPosition(cc.p(self.cannon:getContentSize().width+100,-self.cannon:getContentSize().height-160))
        end
    end

    --屏幕中
    if(self.mainPlayer == true)then
        bigFishCoinArmature:setPosition(self.cannon:convertToNodeSpace(getScreenCenter()));
    end 
end

function player:playerShakeAction()
   if(FishManager:getGameLayer():getActionByTag(1002) ~= nil)then
        return
    end

    local sakeTime = 0.05;
    --震屏效果
    local paths = {};

    local shakeCount = 1 / sakeTime

    local x = 0
    local y = 0

    for i=1,shakeCount do
        x = math.random(-10,10)
        y = math.random(-10,10)
        table.insert(paths,cc.MoveTo:create(sakeTime, cc.p(x, y)));
    end

    table.insert(paths,cc.MoveTo:create(sakeTime, cc.p(0, 0)));

    local skadeAction = cc.Sequence:create(paths);
    skadeAction:setTag(1002)

    FishManager:getInstance():getGameLayer():runAction(skadeAction);
end

function player:showScoreAnimation(score,kind1, fishMulti)
    local kind = kind1 + 1

    --代表大鱼
    if score and score >= 0 then
        if fishMulti and fishMulti >= 30 and fishMulti <= 79 then--鱼type
            local scoreHighAni = DataCacheManager:createEffect(GAME_ZHUANLUN_EFFECT)
            scoreHighAni:setData(score)
            scoreHighAni:playAction()

            if scoreHighAni then    
                scoreHighAni:setPosition(cc.p(140,self.cannon:getContentSize().height+160))
                self.cannon:addChild(scoreHighAni,-1)
                
                if FLIP_FISH then
                    if self.lSeatNo <= 2 then
                        scoreHighAni:setPosition(cc.p(140,-self.cannon:getContentSize().height-160))
                    end
                else
                    if self.lSeatNo > 2 then
                        scoreHighAni:setPosition(cc.p(140,-self.cannon:getContentSize().height-160))
                    end
                end
            end

            audio.playSound("sound/rolling.mp3");
        end
    else
        luaPrint("出错了 .............. score 为 0 .......")
    end
end

function player:getFireGunLevel(gunNumber)
    local paoLvC = {["1"]=1,["2"]=1,["3"]=1,["4"]=1,["5"]=1,["6"]=2,["7"]=2,["8"]=2,["9"]=2,["10"]=2}
    local paoLvZ = {["10"]=1,["20"]=1,["30"]=1,["40"]=1,["50"]=1,["60"]=2,["70"]=2,["80"]=2,["90"]=2,["100"]=2}
    local paoLvG = {["100"]=1,["200"]=1,["300"]=1,["400"]=1,["500"]=1,["600"]=2,["700"]=2,["800"]=2,["900"]=2,["1000"]=2}
    local paoLvH = {["1000"]=1,["2000"]=1,["3000"]=1,["4000"]=1,["5000"]=1,["6000"]=2,["7000"]=2,["8000"]=2,["9000"]=2,["10000"]=2}

    local chuji = {1,2,3,4,5,6,7,8,9,10};
    local zhongji = {10,20,30,40,50,60,70,80,90,100};
    local gaoji = {100,200,300,400,500,600,700,800,900,1000};
    local haiyang = {1000,2000,3000,4000,5000,6000,7000,8000,9000,10000};

    local lv = nil;
    
    if FishModule.m_gameFishConfig then
        self.minFortMult = FishModule.m_gameFishConfig.min_bullet_multiple
        self.maxFortMult = FishModule.m_gameFishConfig.max_bullet_multiple
    end
    if gunNumber < self.minFortMult then
        gunNumber = gunNumber *100;
    end
    if self.minFortMult == chuji[1] and self.maxFortMult == chuji[#chuji] then
        lv = paoLvC[tostring(gunNumber)];
    elseif self.minFortMult == zhongji[1] and self.maxFortMult == zhongji[#zhongji] then
        lv = paoLvZ[tostring(gunNumber)];
    elseif self.minFortMult == gaoji[1] and self.maxFortMult == gaoji[#gaoji] then
        lv = paoLvG[tostring(gunNumber)];
    elseif self.minFortMult == haiyang[1] and self.maxFortMult == haiyang[#haiyang] then
        lv = paoLvH[tostring(gunNumber)];
    end
    
    if lv == nil then
        lv = 1;
    end

    return lv;
end

function player:showAimLine(pos1)
    if self.score <= 0 then
       self:hideAimLine()
       return
    end

    -- local x, y = self.lockFish:getFishPos()
    -- local pos = self.lockFish:getParent():convertToWorldSpace(cc.p(x,y))
    local fishp =pos1 --self.lockFish:getFishPos()
    if fishp == nil then
        fishp = self.lockFish:getFishPos()
    end
    local newPos = self:convertToNodeSpace(fishp)
    local pos = self:convertToNodeSpace(self.cannon:getPaoTongPos());--self.cannon:getPosition()
    local sx,sy = pos.x,pos.y;
    
    -- if self:getChildByName("draw") then
    --     self:getChildByName("draw"):removeFromParent()
    -- end
    -- local draw = cc.DrawNode:create()
    -- draw:setAnchorPoint(0,0)
    -- draw:setName("draw");
    -- self:addChild(draw, 1000)
    -- draw:setLocalZOrder(1000)
    -- draw:drawPoint((cc.p(sx,sy)), 4, cc.c4f(1,1,1,1))
    -- draw:drawLine(pos,newPos,cc.c4f(1,1,0,1))
    local disX = (newPos.x-sx)/8
    local disY = (newPos.y-sy)/8
    for k,v in ipairs(self.aimLine) do
        v:show()
        v:setPosition(cc.p(sx+disX*(k+1), sy+disY*(k+1)))
    end

    -- self.setLockFishSlow = true
end

function player:hideAimLine()
    if(self.aimLine)then
        for k,v in ipairs(self.aimLine) do
            v:hide()
        end
        -- self.setLockFishSlow = false
    end
end

--堆币动画
function player:getCoinAnimation(num,score)

    if nil == num or num == 0 then
        luaPrint("出错了:鱼的倍数num为nil............")
        return
    end
    
    if num > 50 then
        num = 50
    end
   
    self.getCoinAnimationTime =  self.getCoinAnimationTime + 0.01 * num + 0.3

    -- luaPrint("创建金币动画  延时 = "..self.getCoinAnimationTime.."  num = "..num)

    local sequence = cc.Sequence:create(
        cc.DelayTime:create(self.getCoinAnimationTime),
        cc.CallFunc:create(function()
            self:playGetCoinAnimation(num,score)
        end)
    )
    self:runAction(sequence)
end

function player:playGetCoinAnimation(num,score)
    local size = cc.size(37,8)

    if self.coinAnimation == nil then
        self.coinAnimation = 0;
    end

    if self.coinNode == nil then
        self.coinNode = cc.Node:create();
        self:addChild(self.coinNode,10000);
    end

    self.coinAnimation = self.coinAnimation + 1;
    local container = ccui.ImageView:create("blank.png");
    container:setScale9Enabled(true);
    container:setContentSize(cc.size(size.width,size.height*num));
    container:setAnchorPoint(cc.p(0,0))
    container:setName("coincontainer"..self.coinAnimation)

    local winSize = cc.Director:getInstance():getWinSize();
    local ppos = self:convertToNodeSpace(cc.p(winSize.width/2,0))
    if globalUnit.isEnterRoomMode ~= true then --单人场
        ppos.x =  ppos.x - (winSize.width-winSize.width/3.5-winSize.width/2);
    end
    container:setPosition(ppos.x, -35)
    self.coinNode:addChild(container,10000)

    local tag = self.coinAnimation;

    if FLIP_FISH then
        if self.lSeatNo <= 2 then
            container:setFlippedY(true)
            container:setFlippedX(true)
            container:setPositionY(35)
        end
    else
        if self.lSeatNo > 2 then
            container:setFlippedY(true)
            container:setFlippedX(true)
            container:setPositionY(35)
        end
    end

    for i=1,1 do
        local bgSprite = display.newSprite("game/game_spec_coin.png")
        bgSprite:setAnchorPoint(cc.p(0.5,0))
        bgSprite:setPosition(size.width/2, (i-1)*size.height)
        container:addChild(bgSprite)

        if num == 1 then
            local number = FontConfig.createLabel(FontConfig.gFontConfig_26, FormatNumToString(score), cc.c3b(255,224,20))
            number:setPosition(size.width/2, 1*size.height+5)
            number:setAnchorPoint(cc.p(0.5,0));
            container:addChild(number)
        end
    end

    local start = 1

    local callFunc = function()
        start = start + 1
        if start <= num then
            local bgSprite = display.newSprite("game/game_spec_coin.png")
            bgSprite:setAnchorPoint(cc.p(0.5,0))
            bgSprite:setPosition(size.width/2, (start-1)*size.height)
            container:addChild(bgSprite)
        
            if start == num then
                local number = FontConfig.createLabel(FontConfig.gFontConfig_26, FormatNumToString(score), cc.c3b(255,224,20))
                number:setPosition(size.width/2, start*size.height+5)
                number:setAnchorPoint(cc.p(0.5,0));
                container:addChild(number)
            end
        else
            container:stopAllActions()
            local sequence = transition.sequence(
                {
                    cc.Sequence:create(cc.MoveBy:create(1.0, cc.p(-ppos.x,0))),
                    cc.CallFunc:create(
                        function()
                            audio.playSound("sound/sound_coin.mp3");
                            if container and not tolua.isnull(container) then
                                container:removeFromParent();
                            else
                                local node = self:getChildByName("coincontainer"..tag);
                                if node then
                                    node:removeFromParent();
                                end
                            end

                            local children = self.coinNode:getChildren();

                            if #children == 0 then
                                self.coinAnimation = 0;
                            end
                        end
                    )
                }
            )
            container:runAction(sequence)            
        end
    end

    local sequence = transition.sequence(
        {
            cc.DelayTime:create(0.01),
            cc.CallFunc:create(callFunc)
        }
    )
    container:runAction(cc.RepeatForever:create(sequence))
end

function player:playPoChanAnimation()
    if not self.poSprite then
        self.poSprite = display.newSprite("game/game_po_chan.png")
        self.poSprite:setPosition(self.cannon.paoTai:getContentSize().width/2, 36)
        self.poSprite:setScale(2.0)
        self.cannon.paoTai:addChild(self.poSprite,100)
        -- self.poSprite:hide()

        self.poSprite:runAction(cc.ScaleTo:create(0.1,1.0))
    else
       self.poSprite:show() 
    end
end

function player:popSelectPaoLayer()
    if self.mainPlayer == false then
        --简介
        local gameLayer = FishManager:getGameLayer()

        if self.mainPlayer == false and gameLayer and gameLayer.isAutoShoot == false then
            local pos = self:getParent():convertToWorldSpace(cc.p(self:getPositionX(),self:getPositionY()))
            gameLayer:fireToPonit(pos,false);
        end

        if self.showDescLayer then
            self.showDescLayer:removeFromParent();
            self.showDescLayer = nil
            return
        end
      
        self.showDescLayer = UIManager:showUserDescLayer(self)
        self.showDescLayer:setPosition(self.cannon.paoTai:getContentSize().width/2, 180)
        self.cannon.paoTai:addChild(self.showDescLayer,100)

        if FLIP_FISH then
            if self.lSeatNo <= 2 then
              self.showDescLayer:setRotation(0);
              self.showDescLayer:setScale(-1);
            end
        else
            if self.lSeatNo > 2 then
              self.showDescLayer:setRotation(0);
              self.showDescLayer:setScale(-1);
            end
        end

    else
        --工具箱
        self:showToolbox()
    end
end

function player:refreshUserInfo(userInfo)
    self.userInfo = userinfo;

    self.score = userinfo.score;
end

function player:refreshScore(score)
    self.score = score
    self:updateScore(self.score)
end

function player:playerUpdate(dt)
  --获取金币动画时间
    if self.getCoinAnimationTime > 0 then
        self.getCoinAnimationTime = self.getCoinAnimationTime - dt
    else   
        self.getCoinAnimationTime = 0 
    end
end

function player:bulletUpdate()
    if self.cannon == nil then
        luaPrint("炮台异常, 未知情况,待查找 ")
        return;
    end

    --发射子弹个数
    local fireBulletCount = 1
    -- if self.cannon.kuangbaoObj and self.cannon.kuangbaoObj:isVisible() == true then
    if self.cannon.isMoreFastShoot then
        fireBulletCount = 3 -- 狂暴发射一颗
    end

    --子弹不够的时候等待
    if #self.fireBulletDataCache < fireBulletCount then
        return
    end

    -- local isplaySound = false
    local bulletCount = 0
    for k,v in pairs(self.fireBulletDataCache) do
        if bulletCount < fireBulletCount then
            if fireBulletCount == 3 then
                if bulletCount < 2 then
                    self:updateFireToDirection(v.angle ,v.cost,v.bullet_id,v.android_chairid,1,v.isLockFishID)
                else
                    self:updateFireToDirection(v.angle ,v.cost,v.bullet_id,v.android_chairid,nil,v.isLockFishID)
                end
            else
                self:updateFireToDirection(v.angle ,v.cost,v.bullet_id,v.android_chairid,nil,v.isLockFishID)
            end

                      
            bulletCount = bulletCount + 1
            -- isplaySound = true
        end
    end

    self.fireBulletDataCache = {}

    -- if isplaySound then
    --     --子弹音效
    --     if 1 == cc.UserDefault:getInstance():getIntegerForKey("Sound",1) then
    --         -- audio.playSound("sound/cannon.mp3");
    --     end
    -- end
end

function player:showChatMsg(messageInfoTalbe)  
    local bg = ccui.ImageView:create("hall/chat/game_expression_bg.png");
    bg:setAnchorPoint(cc.p(0.5,0));
    bg:setPosition(self.cannon.paoTai:getContentSize().width/2, 180)
    self.cannon.paoTai:addChild(bg,100)

    local richText = ccui.RichText:create()  
    richText:ignoreContentAdaptWithSize(false)  
    richText:setContentSize(cc.size(bg:getContentSize().width - 50,bg:getContentSize().height-30))
    richText:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2-5)  
    bg:addChild(richText);

    local msg
    for k,v in pairs(messageInfoTalbe) do
        if v.textType == 1 then
            msg = ccui.RichElementText:create( k, cc.c3b(255, 255, 255), 255,v.text, "Helvetica", 22 )  
        elseif v.textType == 2 then
            local expressionIcon = display.newSprite("hall/expression/"..tonumber(v.text)..".png");
            expressionIcon:setScale(0.45)
            expressionIcon:setContentSize(cc.size(expressionIcon:getContentSize().width*0.45,expressionIcon:getContentSize().height*0.45))
            msg = ccui.RichElementCustomNode:create(k,cc.c3b(255, 255, 255), 255, expressionIcon);
        end

       richText:pushBackElement(msg)  
    end

    if FLIP_FISH then
        if self.lSeatNo <= 2 then
          richText:setRotation(0);
          richText:setScale(-1);
          richText:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2 + 12)  
        end

    else
        if self.lSeatNo > 2 then
          richText:setRotation(0);
          richText:setScale(-1);
          richText:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2 + 12)
        end
    end

    self:performWithDelay(function() bg:removeFromParent() end, 3);
end  

function player:exitToolBoxLayer()
    self:performWithDelay(function()
            if self.toolBoxLayer then
                self.toolBoxLayer:removeFromParent()
                self.toolBoxLayer = nil
            end
        end,0.1)
       
end

function player:showToolbox()
    if self.toolBoxLayer then

        self.toolBoxLayer:removeFromParent()
        self.toolBoxLayer = nil

        return
    end

    --引导解锁
    if self.cur_zi_dan_cost == FortUpgradeInfo.nextFortMultiple then
        local layer = require("popView.cannonUnlockLayer").new();
        display.getRunningScene():addChild(layer,POP_LAYER_ZORDER)
    else
        
        local bg = ccui.ImageView:create();
        bg:setAnchorPoint(cc.p(0.5,0));
        bg:setPosition(self.cannon.paoTai:getContentSize().width/2, 180)
        self.cannon.paoTai:addChild(bg,100)

        self.toolBoxLayer = bg
        --聊天
        local btn = ccui.Button:create("game/chat_btn.png");
        btn:setAnchorPoint(1,0.5)
        btn:setPosition(cc.p(-15, 0));
        btn:onClick(
            function()
                self:exitToolBoxLayer()
                local layer = require("popView.chatLayer").new()
                display.getRunningScene():addChild(layer)
            end
        );
        bg:addChild(btn);

        --换炮
        local btn = ccui.Button:create("game/change_fort.png");
        btn:setAnchorPoint(0,0.5)
        btn:setPosition(cc.p(15, 0));
        btn:onClick(
            function()
                self:exitToolBoxLayer()
                local layer = require("popView.unlockFort").new(self,self);
                display.getRunningScene():addChild(layer)
            end
        );
        bg:addChild(btn);

        --三个宝箱
        local posx = 115
        for i=1,3 do

            local goodsInfo = GoodsInfoDataCache:getGoodsInfoByID(1008 + i)

            local btn = ccui.Button:create("game/toolbox_goods_bg.png");
            btn:setPosition(cc.p(posx*(i-2), 90));
            btn:onClick(
                function()
                    self:exitToolBoxLayer()
                    local layer = require("show.popView_Hall.GoodsLayer").new(goodsInfo,GAME,true);
                    FishManager:getGameLayer():addChild(layer,POP_LAYER_ZORDER);
                end
            );
            bg:addChild(btn);

            local goodsIcon = display.newSprite("hall/goods/"..goodsInfo.goodsIcon);
            goodsIcon:setScale(0.8)
            goodsIcon:setPosition(btn:getContentSize().width/2, btn:getContentSize().height/2)
            btn:addChild(goodsIcon);

            local goodsCountLabel = ccui.Text:create(goodsInfo.goodsCount,FONT_PTY_TEXT,22);
            goodsCountLabel:setPosition(105,95)
            goodsIcon:addChild(goodsCountLabel);
           
        end
    end
end

function player:palyerChangeEffect()
    if(self.forChangeArmature)then
        self.forChangeArmature:getAnimation():playWithIndex(0,1,0)
        return
    end

    self.forChangeArmature = createArmature("fishEffect/eff_paotai_bian0.png","fishEffect/eff_paotai_bian0.plist","fishEffect/eff_paotai_bian.ExportJson")
    self.forChangeArmature:getAnimation():playWithIndex(0,1,0)
    self.forChangeArmature:setPosition(cc.p(self.cannon.paoTai:getContentSize().width/2,35))
    self.cannon.paoTai:addChild(self.forChangeArmature,100);
end

return player;
