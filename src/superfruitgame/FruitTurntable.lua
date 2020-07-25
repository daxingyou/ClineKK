local TableLogic = require("superfruitgame.TableLogic");
local FruitTurntable = class("FruitTurntable",function()
    return ccui.Layout:create();
end);

FruitTurntable._nSingleHeight = 0;--单个水果高度
FruitTurntable._nFruitTotal = 0;--水果个数
FruitTurntable._fruitListNode = nil;--水果显示节点
FruitTurntable._tbShowFruitData = nil;
FruitTurntable._bShowTurnAction = false;--是否正在播放转动动画
FruitTurntable._nTurnIndex = 1;

local TURNTABLE_SIZE = cc.size(140,365);--单个转盘尺寸

local FRUIT_PNG_NAME = {
    [TableLogic.FRUIT_TYPE.YINGTAO] = "sf_game_yingtao.png",
    [TableLogic.FRUIT_TYPE.PUTAO] = "sf_game_putao.png",
    [TableLogic.FRUIT_TYPE.LINGDANG] = "sf_game_lingdang.png",
    [TableLogic.FRUIT_TYPE.PINGGUO] = "sf_game_pingguo.png",
    [TableLogic.FRUIT_TYPE.XIGUA] = "sf_game_xigua.png",
    [TableLogic.FRUIT_TYPE.NINGMENG] = "sf_game_ningmeng.png",
    [TableLogic.FRUIT_TYPE.LIZHI] = "sf_game_lizhi.png",
    [TableLogic.FRUIT_TYPE.CHENGZI] = "sf_game_chengzi.png",
    [TableLogic.FRUIT_TYPE.SIYECAO] = "sf_game_xingyuncao.png",
    [TableLogic.FRUIT_TYPE.BAR] = "sf_game_bar.png",
    [TableLogic.FRUIT_TYPE.QIQIQI] = "sf_game_777.png",
};

--转盘第一次显示的水果数据
local FRUIT_SHOW_DATA_FIRST = {0,1,2};
--转盘上水果总数
local FRUIT_LIST_TOTAL = 18;

function FruitTurntable:create(turnIndex)
    local turntable = FruitTurntable:new();
    turntable:init(turnIndex);
    return turntable;
end

function FruitTurntable:init(turnIndex)
    self._nTurnIndex = turnIndex;
    self._bShowTurnAction = false;--是否正在播放转动动画
    self._nSingleHeight = 0;--单个水果高度
    self._nFruitTotal = 0;--水果个数
    self._fruitListNode = nil;--水果显示节点
    self._tbShowFruitData = nil;

    self:setAnchorPoint(0.5,0);
	self:setContentSize(TURNTABLE_SIZE);
	self:setClippingEnabled(true);

    self:initSingleFruitList();
end

--初始化转动的水果列表
function FruitTurntable:initSingleFruitList()
    if self._fruitListNode then
        return;
    end
    local sinleFruitNode = cc.Node:create();
    --起始位置
    sinleFruitNode:setPosition(cc.p(TURNTABLE_SIZE.width/2,0));
    self:addChild(sinleFruitNode);

    --水果列表数据
    local tbFruitData = {};
    --初始显示的水果
    for _, fruit in ipairs(FRUIT_SHOW_DATA_FIRST) do
        tbFruitData[#tbFruitData+1] = fruit;
    end
    --随机数种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6)..os.time())
    --随机产生剩余水果数据
    for i = 1, FRUIT_LIST_TOTAL-#tbFruitData do
        local tempFruitType = random(TableLogic.FRUIT_TYPE_MIN,TableLogic.FRUIT_TYPE_MAX);
        tbFruitData[#tbFruitData+1] = tempFruitType;
    end
    
    --水果显示序号
    local fruitIndex = 0;
    for _, fruit in ipairs(tbFruitData) do
        --判断是否是配置存在的水果
        if FRUIT_PNG_NAME[fruit] then
            local sFruitName = FRUIT_PNG_NAME[fruit];
            local fruitSprite = cc.Sprite:createWithSpriteFrameName(sFruitName);
            if self._nSingleHeight == 0 then
                self._nSingleHeight = fruitSprite:getContentSize().height;
            end
            fruitSprite:setTag(fruitIndex+1);
            fruitSprite:setAnchorPoint(cc.p(0.5,0));
            fruitSprite:setPosition(cc.p(0,fruitIndex*self._nSingleHeight));
            sinleFruitNode:addChild(fruitSprite);
            fruitIndex = fruitIndex + 1;
        end
    end
    
    self._nFruitTotal = fruitIndex;
    self._fruitListNode = sinleFruitNode;
end

--开始转，tbResultFruit为最后要显示的水果数据
function FruitTurntable:start(tbResultFruit,callBackFunc)
    if self._bShowTurnAction then
        return;
    end
    self._bStopFlag = false;--是否立即停止
    self._bShowTurnAction = true;--正在转动

    if self._tbShowFruitData then
        --将开始的3个水果设置成当前显示的水果
        for i = 1, self._nFruitTotal-3 do
            local fruitSprite = self._fruitListNode:getChildByTag(i);
            if fruitSprite then
                if i <= 3 and self._tbShowFruitData[i] then
                    fruitSprite:setSpriteFrame(FRUIT_PNG_NAME[self._tbShowFruitData[i]]);
                end
                if i > 3 then
                    local tempFruitType = random(TableLogic.FRUIT_TYPE_MIN,TableLogic.FRUIT_TYPE_MAX);
                    fruitSprite:setSpriteFrame(FRUIT_PNG_NAME[tempFruitType]);
                end
            end
        end
        
        self._fruitListNode:setPosition(cc.p(TURNTABLE_SIZE.width/2,0));
    end

    for i = 1, 3 do
        local fruitSprite = self._fruitListNode:getChildByTag(self._nFruitTotal-i+1);
        if fruitSprite and tbResultFruit[i] then
            fruitSprite:setSpriteFrame(FRUIT_PNG_NAME[tbResultFruit[i]]);
        end
    end
    
    local actionTotal = 0;--动画循环次数
    
    local actionOnceTime = 0.1;
    local actionBeturnNumber = self._nTurnIndex*3;

    local endPosY = self._nSingleHeight*(self._nFruitTotal-6);--停止时的Y坐标
    local action1 = cc.MoveTo:create(actionOnceTime,cc.p(TURNTABLE_SIZE.width/2,0-endPosY));
    local action2 = cc.CallFunc:create(function()
                    if self._bStopFlag or actionTotal >= actionBeturnNumber then
                        self:playFinalAction(tbResultFruit,callBackFunc);
                        return;
                    end
                    self._fruitListNode:setPosition(cc.p(TURNTABLE_SIZE.width/2,0));
                    actionTotal = actionTotal + 1;
			end);
    local sequence = cc.Sequence:create(action1, action2)
    local action = cc.RepeatForever:create(sequence)
    self._fruitListNode:runAction(action);
end

--是否立即停止
function FruitTurntable:setStopFlag(bStop)
    self._bStopFlag = bStop;
end

function FruitTurntable:playFinalAction(tbResultFruit,callBackFunc)
    self._fruitListNode:stopAllActions();

    self._bStopFlag = false;--是否立即停止

    local endPosY = self._nSingleHeight*(self._nFruitTotal-3);--停止时的Y坐标
    local action1 = cc.MoveTo:create(0.35,cc.p(TURNTABLE_SIZE.width/2,0-endPosY-80));
    local action2 = cc.MoveTo:create(0.15,cc.p(TURNTABLE_SIZE.width/2,0-endPosY));
    local action3 = cc.CallFunc:create(function()
        self._tbShowFruitData = tbResultFruit;--将当前显示数据设置为传入的数据
        self._bShowTurnAction = false;--停止转动
        if self._nTurnIndex == 5 and callBackFunc then
            callBackFunc();
        end
    end);
    local sequence = cc.Sequence:create(action1, action2 ,action3)
    self._fruitListNode:runAction(sequence);
end

--显示水果闪烁
--nBlinkFruitIndex为闪烁的编号,每列一次只会闪烁一个
function FruitTurntable:showBlink(nBlinkFruitIndex)
    --如果正在转动，则不闪烁
    if self._bShowTurnAction then
        return;
    end
    if nBlinkFruitIndex < 1 or nBlinkFruitIndex > 3 then
        return;
    end

    local fruitSprite = self._fruitListNode:getChildByTag(self._nFruitTotal-nBlinkFruitIndex+1);
    if fruitSprite then
        --利用渐隐和渐现实现闪烁
        local sequence = cc.Sequence:create(
		    cc.FadeOut:create(0.2),
		    cc.FadeIn:create(0.2));
        local action = cc.RepeatForever:create(sequence)
        fruitSprite:runAction(action);
    end
end

function FruitTurntable:stopBlink()
    for i = self._nFruitTotal, self._nFruitTotal-2,-1 do
        local fruitSprite = self._fruitListNode:getChildByTag(i);
        if fruitSprite then
            fruitSprite:stopAllActions();
            fruitSprite:setOpacity(255);
        end
    end
end

return FruitTurntable;
