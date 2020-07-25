local GameAction = class("GameAction", BaseWindow)

function GameAction:createLayer(diceMsg)
    local layer = GameAction.new();

    layer:setName("GameAction");

    layer:InitLayer(diceMsg);

    return layer;
end

function GameAction:ctor(diceMsg)
    self.super.ctor(self,0,true)
end

function GameAction:InitLayer(diceMsg)
    local effectState = getEffectIsPlay();
    local diceNum = {};
    --提取色子点数
    for i = 1,diceMsg.one do
        table.insert(diceNum,1);
    end
    for i = 1,diceMsg.two do
        table.insert(diceNum,2);
    end
    for i = 1,diceMsg.three do
        table.insert(diceNum,3);
    end
    for i = 1,diceMsg.four do
        table.insert(diceNum,4);
    end
    for i = 1,diceMsg.five do
        table.insert(diceNum,5);
    end
    for i = 1,diceMsg.six do
        table.insert(diceNum,6);
    end


    local gameSpine = createSkeletonAnimation("touzi","yaoyiyao/effect/touzi.json","yaoyiyao/effect/touzi.atlas");
    gameSpine:setPosition(640,360);
    gameSpine:setAnimation(1,"touzi", false);
    gameSpine:setName("touzi");
    self:addChild(gameSpine);
    --播放动画音效
    if effectState then
        audio.playSound("yaoyiyao/sound/sound-dice-shake.mp3");
    end

    cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/yaoyiyao.plist");
    local diceCreate = function(type)
        local dice = cc.Sprite:createWithSpriteFrameName("yyy_shaizi"..diceNum[type]..".png");
        self:addChild(dice,10);
        local pos = cc.p(640,420);
        if type == 1 then
            pos.x = pos.x + 40;
            pos.y = pos.y - 44;
        elseif type == 2 then

        else
            pos.x = pos.x - 40;
            pos.y = pos.y - 44;
        end
        dice:setAnchorPoint(1,0);
        dice:setPosition(cc.p(pos.x+dice:getContentSize().width/2,pos.y-dice:getContentSize().height/2));
        dice:setRotation(5);

        local diceRotaAction1 = function()
            dice:runAction(cc.RotateTo:create(0.03,0));
        end

        local diceRotaAction2 = function()
            dice:setAnchorPoint(0,0);
            dice:setPosition(cc.p(pos.x-dice:getContentSize().width/2,pos.y-dice:getContentSize().height/2));
            dice:runAction(cc.Sequence:create(cc.RotateTo:create(0.03,-5),cc.RotateTo:create(0.03,0)));
        end

        dice:runAction(cc.Sequence:create(cc.CallFunc:create(diceRotaAction1),cc.CallFunc:create(diceRotaAction2)));
    end
    --展示色子点数
    local ShowDiceData = function()
        local diceDataLayer = cc.Layer:create();
        diceDataLayer:ignoreAnchorPointForPosition(false);
        diceDataLayer:setContentSize(cc.size(500,280));
        diceDataLayer:setAnchorPoint(0.5,1);
        diceDataLayer:setPosition(640,350);
        self:addChild(diceDataLayer,20);
        diceDataLayer:setScale(0.3);

        local bgScale = cc.ScaleTo:create(0.3,1);
        diceDataLayer:runAction(bgScale);

        --创建色子摇出的数字
        for i = 1,3 do
            local diceSp = cc.Sprite:createWithSpriteFrameName("yyy_Dice"..diceNum[i]..".png");
            diceDataLayer:addChild(diceSp);
            local dicePos = cc.p(diceDataLayer:getContentSize().width/2,100);
            if i == 1 then
                dicePos.x = dicePos.x-120;
            elseif i == 3 then
                dicePos.x = dicePos.x+120;
            end
            diceSp:setPosition(dicePos);
        end

        local diceNumTotal = diceNum[1]+diceNum[2]+diceNum[3];
        --显示色子的总和数值
        local diceNumText=cc.LabelAtlas:create(tostring(diceNumTotal), "yaoyiyao/number/zi_dianshu.png", 49, 64, string.byte("0"));
        diceNumText:setAnchorPoint(1,0.5);
        diceNumText:setPosition(diceDataLayer:getContentSize().width/2-65,210);
        diceDataLayer:addChild(diceNumText);

        local diceDian = cc.Sprite:createWithSpriteFrameName("yyy_dian.png");
        diceDian:setAnchorPoint(1,0.5);
        diceDian:setPosition(diceDataLayer:getContentSize().width/2+20,210);
        diceDataLayer:addChild(diceDian);

        --色子的大小
        local diceTotalJudge = nil;
        if diceNum[1] == diceNum[2] and diceNum[1] == diceNum[3] and diceNum[3] == diceNum[2] then
            diceTotalJudge = cc.Sprite:createWithSpriteFrameName("yyy_bao.png");
        else
            if diceNumTotal < 11  then
                diceTotalJudge = cc.Sprite:createWithSpriteFrameName("yyy_xiao.png");
            else
                diceTotalJudge = cc.Sprite:createWithSpriteFrameName("yyy_da.png");
            end
        end

        if diceTotalJudge then
            diceTotalJudge:setAnchorPoint(0,0.5);
            diceTotalJudge:setPosition(diceDataLayer:getContentSize().width/2+60,210);
            diceDataLayer:addChild(diceTotalJudge);
        end

        diceDataLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function() 
            if effectState then
                audio.playSound("yaoyiyao/sound/"..diceNum[1]..".mp3");
            end
        end),cc.DelayTime:create(0.8),cc.CallFunc:create(function() 
            if effectState then
                audio.playSound("yaoyiyao/sound/"..diceNum[2]..".mp3");
            end
        end),cc.DelayTime:create(0.8),cc.CallFunc:create(function() 
            if effectState then
                audio.playSound("yaoyiyao/sound/"..diceNum[3]..".mp3");
            end
        end),cc.DelayTime:create(0.8),cc.CallFunc:create(function() 
            if effectState then
                audio.playSound("yaoyiyao/sound/total-"..diceNumTotal..".mp3");
            end
        end),cc.DelayTime:create(1),cc.CallFunc:create(function()
            if effectState then
                local diceNumTotal = diceNum[1]+diceNum[2]+diceNum[3]; 
                if diceNum[1] == diceNum[2] and diceNum[1] == diceNum[3] and diceNum[3] == diceNum[2] then
                    audio.playSound("yaoyiyao/sound/tongchi.mp3");
                else
                    if diceNumTotal < 11  then
                        audio.playSound("yaoyiyao/sound/small.mp3");
                    else
                        audio.playSound("yaoyiyao/sound/big.mp3");
                    end
                end
            end
        end)));

    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1/30*43),cc.CallFunc:create(function() diceCreate(1) end),
    cc.DelayTime:create(1/30*2),cc.CallFunc:create(function() diceCreate(2) end),
    cc.DelayTime:create(1/30*4),cc.CallFunc:create(function() diceCreate(3) end),
    cc.DelayTime:create(0.5),cc.CallFunc:create(function() ShowDiceData() end),
    cc.DelayTime:create(3),cc.CallFunc:create(function()  end)))

end

return GameAction