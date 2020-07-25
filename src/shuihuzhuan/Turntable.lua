local TableLogic = require("shuihuzhuan.TableLogic");
local TurntableSprite = require("shuihuzhuan.TurntableSprite");
local Turntable = class("Turntable",function()
    return ccui.Layout:create();
end);

Turntable._nSingleHeight = 0;--单个水果高度
Turntable._nFruitTotal = 0;--水果个数
Turntable._fruitListNode = nil;--水果显示节点
Turntable._tbShowFruitData = nil;
Turntable._bShowTurnAction = false;--是否正在播放转动动画
Turntable._nTurnIndex = 1;

local TURNTABLE_SIZE = cc.size(185,415);--单个转盘尺寸

local SHZ_PNG_NAME = {
    [TableLogic.SHZ_TYPE.SHUIHUZHUAN] = "shz_shuihuzhuan",
    [TableLogic.SHZ_TYPE.ZHONGYITANG] = "shz_zhongyitang",
    [TableLogic.SHZ_TYPE.TITIANXINGDAO] = "shz_titianxingdao",
    [TableLogic.SHZ_TYPE.SONG] = "shz_song",
    [TableLogic.SHZ_TYPE.LIN] = "shz_lin",
    [TableLogic.SHZ_TYPE.LU] = "shz_lu",
    [TableLogic.SHZ_TYPE.DAO] = "shz_dao",
    [TableLogic.SHZ_TYPE.QIANG] = "shz_qiang",
    [TableLogic.SHZ_TYPE.FU] = "shz_fu",
};

--转盘第一次显示的水果数据
local FRUIT_SHOW_DATA_FIRST = {3,4,5};
--转盘上水果总数
local FRUIT_LIST_TOTAL = 18;

function Turntable:create(turnIndex)
    local turntable = Turntable:new();
    turntable:init(turnIndex);
    return turntable;
end

function Turntable:init(turnIndex)
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
function Turntable:initSingleFruitList()
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
        local tempFruitType = random(TableLogic.SHZ_TYPE_MIN,TableLogic.SHZ_TYPE_MAX);
        tbFruitData[#tbFruitData+1] = tempFruitType;
    end
    
    --水果显示序号
    local fruitIndex = 0;
    for _, fruit in ipairs(tbFruitData) do
        --判断是否是配置存在的水果
        if SHZ_PNG_NAME[fruit] then
            local sFruitName = SHZ_PNG_NAME[fruit];
            local fruitSprite = TurntableSprite:create(fruit);
            if self._nSingleHeight == 0 then
                self._nSingleHeight = fruitSprite:getContentSize().height;
            end
            fruitSprite:setTag(fruitIndex+1);
            fruitSprite:setAnchorPoint(cc.p(0.5,0));
            fruitSprite:setPosition(cc.p(0,fruitIndex*self._nSingleHeight+(fruitIndex)*20));
            sinleFruitNode:addChild(fruitSprite);
            fruitIndex = fruitIndex + 1;
        end
    end
    
    self._nFruitTotal = fruitIndex;
    self._fruitListNode = sinleFruitNode;
end

--开始转，tbResultFruit为最后要显示的水果数据
function Turntable:start(tbResultFruit,bAutoStart,callBackFunc)
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
                    fruitSprite:updateSpriteFrameByType(tbResultFruit[i]);
                end
                if i > 3 then
                    local tempFruitType = random(TableLogic.SHZ_TYPE_MIN,TableLogic.SHZ_TYPE_MAX);
                    fruitSprite:updateSpriteFrameByType(tbResultFruit[i]);
                end
            end
        end
        
        self._fruitListNode:setPosition(cc.p(TURNTABLE_SIZE.width/2,0));
    end

    for i = 1, 3 do
        local fruitSprite = self._fruitListNode:getChildByTag(self._nFruitTotal-i+1);
        if fruitSprite and tbResultFruit[i] then
            fruitSprite:updateSpriteFrameByType(tbResultFruit[i]);
        end
    end
    
    local actionTotal = 0;--动画循环次数

    local actionOnceTime = 0.1;
    
    
    local actionBeturnNumber = self._nTurnIndex*5;
    
--    if bAutoStart == true then
--       actionBeturnNumber = 3;
--    end
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
function Turntable:setStopFlag(bStop)
    self._bStopFlag = bStop;
end

function Turntable:playFinalAction(tbResultFruit,callBackFunc)
    self._fruitListNode:stopAllActions();

    self._bStopFlag = false;--是否立即停止

    local endPosY = (self._nSingleHeight+20)*(self._nFruitTotal-3);--停止时的Y坐标
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
function Turntable:showBlink(nBlinkFruitIndex,resultTable,index)
    --如果正在转动，则不闪烁
    if self._bShowTurnAction then
        return;
    end
--    if nBlinkFruitIndex < 1 or nBlinkFruitIndex > 3 then
--        return;
--    end

    for i = 1, 3 do
        local fruitSprite = self._fruitListNode:getChildByTag(self._nFruitTotal-i+1);   
        if fruitSprite then 
            if nBlinkFruitIndex == i then
                fruitSprite:playFrameAnimateBlink();
            else
                fruitSprite:setSpriteEnable(false);
            end
        end
    end
end

function Turntable:setAllSpriteUnEnable()
    for i = 1, 3 do
        local fruitSprite = self._fruitListNode:getChildByTag(self._nFruitTotal-i+1);   
        if fruitSprite then 
            fruitSprite:setSpriteEnable(false);
        end
    end
end

function Turntable:stopBlink()
    for i = self._nFruitTotal, self._nFruitTotal-2,-1 do
        local fruitSprite = self._fruitListNode:getChildByTag(i);
        if fruitSprite then
            fruitSprite:stopAllFrameAnimate();
        end
    end
end

function Turntable:showSpriteEffect()
    for i = self._nFruitTotal, self._nFruitTotal-2,-1 do
        local fruitSprite = self._fruitListNode:getChildByTag(i);
        if fruitSprite then
            local bNormal = fruitSprite:playFrameAnimateEffect();
            if not bNormal then
                fruitSprite:setSpriteEnable(false);
            end
        end
    end
end

return Turntable;
