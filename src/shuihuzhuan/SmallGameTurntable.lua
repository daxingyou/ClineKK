local TableLogic = require("shuihuzhuan.TableLogic");
local TurntableSprite = require("shuihuzhuan.TurntableSprite");
local Turntable = class("SmallGameTurntable",function()
    return ccui.Layout:create();
end);

Turntable._nSingleHeight = 0;--单个水果高度
Turntable._nFruitTotal = 0;--水果个数
Turntable._fruitListNode = nil;--水果显示节点
Turntable._nShowFruitData = nil;
Turntable._bShowTurnAction = false;--是否正在播放转动动画

local TURNTABLE_SIZE = cc.size(185,140);--单个转盘尺寸

local SHZ_PNG_NAME = {
    [TableLogic.SHZ_TYPE.ZHONGYITANG] = "zhongjian_zhongyitang.png",
    [TableLogic.SHZ_TYPE.TITIANXINGDAO] = "zhongjian_titianxingdao.png",
    [TableLogic.SHZ_TYPE.SONG] = "zhongjian_song.png",
    [TableLogic.SHZ_TYPE.LIN] = "zhongjian_lin.png",
    [TableLogic.SHZ_TYPE.LU] = "zhongjian_lu.png",
    [TableLogic.SHZ_TYPE.DAO] = "zhongjian_dao.png",
    [TableLogic.SHZ_TYPE.QIANG] = "zhongjian_qiang.png",
    [TableLogic.SHZ_TYPE.FU] = "zhongjian_fu.png",
};

--转盘第一次显示的水果数据
local FRUIT_SHOW_DATA_FIRST = {3};
--转盘上水果总数
local FRUIT_LIST_TOTAL = 18;

local actionMax = 6;
local actionOnceTime = 0.05;

function Turntable:create(turnIndex)
    local turntable = Turntable:new();
    turntable:init(turnIndex);
    return turntable;
end

function Turntable:init(turnIndex)
    self._turnIndex = turnIndex;
    self._bShowTurnAction = false;--是否正在播放转动动画
    self._nSingleHeight = 0;--单个水果高度
    self._nFruitTotal = 0;--水果个数
    self._fruitListNode = nil;--水果显示节点
    self._nShowFruitData = nil;

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
        tbFruitData[#tbFruitData+1] = FRUIT_SHOW_DATA_FIRST[i];
    end
    --随机数种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6)..os.time())
    --随机产生剩余水果数据
    for i = 1, FRUIT_LIST_TOTAL-#tbFruitData do
        local tempFruitType = random(TableLogic.SHZ_TYPE_MIN,TableLogic.SHZ_TYPE_MAX-1);
        tbFruitData[#tbFruitData+1] = tempFruitType;
    end
    
    --水果显示序号
    local fruitIndex = 0;
    for _, fruit in ipairs(tbFruitData) do
        --判断是否是配置存在的水果
        if SHZ_PNG_NAME[fruit] then
            local sFruitName = SHZ_PNG_NAME[fruit];
            local fruitSprite = TurntableSprite:create(fruit)--cc.Sprite:createWithSpriteFrameName(sFruitName);
--            if self._nSingleHeight == 0 then
                self._nSingleHeight = fruitSprite:getContentSize().height;
--            end
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

--开始转，nResultFruit为最后要显示的水果数据
function Turntable:start(nResultFruit,callBackFunc)
    if self._bShowTurnAction then
        return;
    end
    self._bShowTurnAction = true;--正在转动

    self:stopEffect();

    if self._nShowFruitData then
        --将开始的3个水果设置成当前显示的水果
        for i = 1, self._nFruitTotal-1 do
            local fruitSprite = self._fruitListNode:getChildByTag(i);
            if fruitSprite then
                if i == 1 then
                    fruitSprite:updateSpriteFrameByType(self._nShowFruitData);
                end
                if i > 1 then
                    local tempFruitType = random(TableLogic.SHZ_TYPE_MIN,TableLogic.SHZ_TYPE_MAX-1);
                    fruitSprite:updateSpriteFrameByType(tempFruitType);
                end
            end
        end
        
        self._fruitListNode:setPosition(cc.p(TURNTABLE_SIZE.width/2,0));
    end

    local fruitSprite = self._fruitListNode:getChildByTag(self._nFruitTotal);
    if fruitSprite and nResultFruit then
        fruitSprite:updateSpriteFrameByType(nResultFruit);
    end

    local actionTotal = 0;--动画循环次数
    
    local endPosY = (self._nSingleHeight+20)*(self._nFruitTotal-1);--停止时的Y坐标
    local action1 = cc.MoveTo:create(actionOnceTime,cc.p(TURNTABLE_SIZE.width/2,0-endPosY));
    local action2 = cc.CallFunc:create(function()
                    if actionTotal >= actionMax then
                        self._fruitListNode:stopAllActions();
                        self._nShowFruitData = nResultFruit;--将当前显示数据设置为传入的数据
                        self._bShowTurnAction = false;--停止转动
                        if callBackFunc and self._turnIndex == 4 then
                            callBackFunc();
                        end
                        return;
                    end
                    self._fruitListNode:setPosition(cc.p(TURNTABLE_SIZE.width/2,20));
                    actionTotal = actionTotal + 1;
			end);
    local sequence = cc.Sequence:create(action1, action2)
    local action = cc.RepeatForever:create(sequence)
    self._fruitListNode:runAction(action);
end

function Turntable:showEffect()
    local tempSprite = self._fruitListNode:getChildByTag(self._nFruitTotal);
    if tempSprite then
        tempSprite:playFrameAnimateEffect(true);
    end
end

function Turntable:stopEffect()
    local tempSprite = self._fruitListNode:getChildByTag(self._nFruitTotal);
    if tempSprite then
        tempSprite:stopAllFrameAnimate();
    end
end

function Turntable:getTurnNeedTime()
    return actionMax*actionOnceTime;
end

return Turntable;
