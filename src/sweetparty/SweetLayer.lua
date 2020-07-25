local SweetSprite = require("sweetparty.SweetSprite");
local TableLogic = require("sweetparty.TableLogic");
local SweetLayer = class("SweetLayer", function()
    return ccui.Layout:create();
end )

SweetLayer._nSingleHeight = 0;-- 单个糖果高度
SweetLayer._fruitListNode = nil;-- 糖果显示节点
SweetLayer._nSweetIndex = 1;
SweetLayer._bShowDropAction = false;-- 是否正在播放掉落动画
SweetLayer._NewSetTag = 0;-- 需要用来记录设置新掉落糖果的tag数
SweetLayer._tbDropLastData = { }
SweetLayer._tbDropDataTable = { }; -- 下落填充的糖果种类
SweetLayer._tbDropTagTable = { }; -- 下落填充的糖果替代tag值
SweetLayer._tbDropPostionData = { }; -- 下落填充的坐标位置
SweetLayer._SweetLayerSize = 0;
SweetLayer._SweetSize = 0;
SweetLayer._Offset_Y = 0;
SweetLayer._scale = 1;

function SweetLayer:create(sweetIndex,tablelayer)
    local sweetlayer = SweetLayer:new();
    sweetlayer:init(sweetIndex,tablelayer);
    return sweetlayer;
end

function SweetLayer:ctor()
    self:removeAllChildren();
end

function SweetLayer:init(sweetIndex,tablelayer)
    self.tablelayer = tablelayer;
    self._nSweetIndex = sweetIndex;
    self._NewSetTag = 0;
    self._bShowDropAction = false;
    -- 是否正在播放掉落动画
    self._nSingleHeight = 0;
    -- 单个糖果高度
    self._sweetListNode = nil;
    -- 糖果显示节点
    self:setAnchorPoint(0.5, 0);
    self:setClippingEnabled(true);
    self._singleSweetNode = cc.Node:create();
    -- 起始位置
    self._singleSweetNode:setPosition(cc.p(0, 0));
    self:addChild(self._singleSweetNode);
end

-- 初始化转动的水果列表
function SweetLayer:initStartTable(SweetTable,stageNum)   
    self._singleSweetNode:removeAllChildren();
    -- 糖果显示序号
    if stageNum == 1 then
        self._SweetLayerSize = cc.size(90, 500);
        self._SweetSize = 76;
        self._Offset_Y = 32;
        self._Offset_Sweet_Y = 8;
        self._scale = 1;
    elseif stageNum == 2 then
        self._SweetLayerSize = cc.size(85, 500);
        self._SweetSize = 66;
        self._Offset_Y = 100;
        self._Offset_Sweet_Y = 6.4;
        self._scale = 0.8;
    else
        self._SweetLayerSize = cc.size(80, 500);
        self._SweetSize = 58;
        self._Offset_Y = 150;
        self._Offset_Sweet_Y = 5.1;
        self._scale = 0.64;
    end

    self:setContentSize(self._SweetLayerSize);
    self._tbRemoveTagTable = { };
    self._tbDropPostionData = { }
    -- 会有新糖果掉落下来的坐标位置
    self._tbFirstDropTagTable = { }
    -- 第一次掉落现有糖果
    self._tbSecondDropDataTable = { }
    -- 第二次掉落糖果
    self:setNeedDrop(false);
    local ShowNextSweetNum = stageNum + 4;
    -- 最终下次掉落需要显示的数据获得行数
    self._singleSweetNode:setPosition(cc.p(0, 0));
    local sweetIndex = 0;
    for i = 1, 7 do
        if i > ShowNextSweetNum then
            break;
        end
        local sweetType = SweetTable[i]
        local sweetSprite = SweetSprite:create(sweetType, stageNum);
        self._nSingleHeight = self._SweetSize;      
        if sweetSprite then
            sweetSprite:setScale(self._scale);
            sweetSprite:setTag(sweetIndex + 1);
            sweetSprite:setSweetType(sweetType);
            sweetSprite:setAnchorPoint(cc.p(0.5, 0));
            local positiony = 538 + sweetIndex * self._nSingleHeight +(sweetIndex) * self._Offset_Sweet_Y;
            if i == ShowNextSweetNum then
                sweetIndex = sweetIndex + 1;
                sweetSprite:setPosition(cc.p(40, 538 + sweetIndex * self._nSingleHeight +(sweetIndex) * self._Offset_Sweet_Y));
            else
                sweetSprite:setPosition(cc.p(40, 538 + sweetIndex * self._nSingleHeight +(sweetIndex) * self._Offset_Sweet_Y));
            end
            self._singleSweetNode:addChild(sweetSprite);
            sweetIndex = sweetIndex + 1;
        end
    end
end

-- 开始转，tbResultFruit为最后要显示的水果数据
function SweetLayer:start(SweetTable, stageNum, callBackFunc)
    --    if self._bShowDropAction then
    --        return;
    --    end

    self._bShowDropAction = true;
    -- 正在掉落
    local actionTotal = 0;
    -- 动画循环次数

    local actionOnceTime = 0.6;

    local endPosY = self._nSingleHeight * 6;
    -- 停止时的Y坐标
    local action1 = cc.MoveTo:create(actionOnceTime, cc.p(0, 0 - endPosY - self._Offset_Y));
    local action2 = cc.CallFunc:create( function()
        self:playFinalAction(SweetTable, stageNum, callBackFunc);
    end );
    local sequence = cc.Sequence:create(action1, action2)
    self._singleSweetNode:runAction(sequence);
end

function SweetLayer:setRemoveSequence(RemoveTable)
    for i = 1, #RemoveTable do
        local sweetSprite = self._singleSweetNode:getChildByTag(i);
        sweetSprite:setRemoveSequence(RemoveTable[i]);
    end
    self:setNeedDrop(false);
end

function SweetLayer:checkDropSweet(NextSweetTable, stageNum, maxRemoveNum,removeEffect,callBackFunc)
    local callBackFunc = function()
        self:FirstDropAction(stageNum, callBackFunc);
    end
    self._tbRemoveTagTable = { };
    self._tbDropPostionData = { }   
    -- 会有新糖果掉落下来的坐标位置
    self._tbFirstDropTagTable = { }
    -- 第一次掉落现有糖果
    self._tbSecondDropDataTable = { }
    -- 第二次掉落糖果
    -- 最终下次掉落需要显示的数据获得行数
    local ShowNextSweetNum = stageNum + 4;
    -- 最大消除队列数
    local MaxRemoveSeqence = stageNum + 3;
    -- 每次队列消除时间
    local RemoveTime = 0.5
    -- 现有糖果中是否下边有糖果需要上面糖果掉落
    for i = 1, 7 do
        if i > ShowNextSweetNum then
            break;
        end
        local sweetSprite = self._singleSweetNode:getChildByTag(i)
        local removeSeqence = 1;
        local tempRemoveSeqence = 1;
        local function CheckRemoveSeqence(removeSeqence)
            if removeSeqence == tempRemoveSeqence then
                performWithDelay(self, function()
                    sweetSprite:RemoveSweet(removeEffect);
                end , RemoveTime *(removeSeqence - 1));
            else
                tempRemoveSeqence = tempRemoveSeqence + 1;
                if tempRemoveSeqence <= maxRemoveNum then
                    CheckRemoveSeqence(removeSeqence);
                end
            end
        end
        local sweetIndex = 0;
        if sweetSprite then
            local removeSeqence = sweetSprite:getRemoveSequence();
            local RemovePostionY = sweetSprite:getPositionY();
            if removeSeqence > 0 then
                self:setNeedDrop(true)
                -- 将需要移除的糖果数记录入表
                local sweetSpriteTag = sweetSprite:getTag()
                table.insert(self._tbRemoveTagTable, sweetSpriteTag)
                --消除效果
                if removeSeqence == tempRemoveSeqence then
                    performWithDelay(self, function()
                        sweetSprite:RemoveSweet(removeEffect);
                    end , RemoveTime *(removeSeqence - 1));
                else
                    tempRemoveSeqence = tempRemoveSeqence + 1;
                    if tempRemoveSeqence <= maxRemoveNum then
                        CheckRemoveSeqence(removeSeqence);
                    end
                end
                table.insert(self._tbDropPostionData, RemovePostionY);
            else
                if self:getNeedDrop() == true then
                    local sweetSpriteTag = sweetSprite:getTag()
                    table.insert(self._tbFirstDropTagTable, sweetSpriteTag);

                    --                    if i == ShowNextSweetNum then
                    --                        table.insert(self._tbRemoveTagTable, sweetSpriteTag)
                    --                    end
                    table.insert(self._tbDropPostionData, RemovePostionY);
                end
            end
        end
    end

    if self._nSweetIndex == stageNum + 3 then
        for i = 1, maxRemoveNum do
            performWithDelay(self, function()
                self.tablelayer:ShowRemoveSweet(i);
            end , RemoveTime *(i - 1));
        end
    end

    if self._tbRemoveTagTable[1] ~= 0 then
        self._NewSetTag = self._tbRemoveTagTable[1];
    end
--    luaDump(self._tbFirstDropTagTable, "_tbFirstDropTagTable");
--    luaDump(self._tbDropPostionData, "self._tbDropPostionData");
--    luaDump(self._tbRemoveTagTable, "self._tbRemoveTagTable");
--    luaDump(NextSweetTable, "NextSweetTable");

    for i = ShowNextSweetNum - #self._tbRemoveTagTable + 1, MaxRemoveSeqence do
        table.insert(self._tbSecondDropDataTable, NextSweetTable[i]);
    end

    --执行过关消除效果
    local actionTime = (maxRemoveNum + 1) * RemoveTime;
    performWithDelay(self, function()
    callBackFunc();
    end ,actionTime);
end

--上下震动效果
function SweetLayer:playFinalAction(SweetTable, stageNum, callBackFunc)
    self._singleSweetNode:stopAllActions();
    local endPosY = self._nSingleHeight * 6;
    -- 停止时的Y坐标
    local action1 = cc.MoveTo:create(0.1, cc.p(0, 0 - endPosY - self._Offset_Y));
    local action2 = cc.MoveTo:create(0.1, cc.p(0, 0 - endPosY - self._Offset_Y - 10));
    local action3 = cc.CallFunc:create( function()
        self._bShowDropAction = false;
        -- 停止掉落
        self._tbDropLastData = SweetTable;
        if self._nSweetIndex == stageNum + 3 and callBackFunc then
            callBackFunc()
        end
    end );
    local sequence = cc.Sequence:create(action1, action2, action3)
    self._singleSweetNode:runAction(sequence);
end

--第一次掉落
function SweetLayer:FirstDropAction(stageNum, callBackFunc)
    if #self._tbRemoveTagTable ~= 0 then
        -- 第一次容器内已有糖果进行掉落
        local actionOnceTime = 0.2;
        for i = 1, #self._tbFirstDropTagTable do
            local sweetSprite = self._singleSweetNode:getChildByTag(self._tbFirstDropTagTable[i])
            local action1 = cc.MoveTo:create(actionOnceTime, cc.p(sweetSprite:getPositionX(), self._tbDropPostionData[i]));
            local action2 = cc.MoveTo:create(0.05, cc.p(sweetSprite:getPositionX(), self._tbDropPostionData[i] + 10));
            local action3 = cc.MoveTo:create(0.05, cc.p(sweetSprite:getPositionX(), self._tbDropPostionData[i]));
            local sequence = cc.Sequence:create(action1, action2, action3)
            sweetSprite:setTag(self._NewSetTag);
            self._NewSetTag = self._NewSetTag + 1;
            sweetSprite:runAction(sequence);
        end
    end

    if self._nSweetIndex == stageNum + 3 and callBackFunc then  
        audio.playSound("sweetparty/voice/sound_drop.mp3");
        performWithDelay(self, function()
            callBackFunc();
        end , 0.3);
    end
end

--第二次掉落
function SweetLayer:SecondDropAction(stageNum, iNextFallSweet, callBackFunc)
    table.insert(self._tbSecondDropDataTable, iNextFallSweet);
    if #self._tbRemoveTagTable ~= 0 then
        local ShowNextSweetNum = stageNum + 4;
        local sweetIndex = #self._tbFirstDropTagTable;
        local actionOnceTime = 0.2;
        for i = 1, #self._tbSecondDropDataTable do
            local sweetSprite = SweetSprite:create(self._tbSecondDropDataTable[i], stageNum);
            self._nSingleHeight = self._SweetSize;
            if sweetSprite then
                sweetSprite:setScale(self._scale);
                sweetSprite:setSweetType(self._tbSecondDropDataTable[i]);
                sweetSprite:setTag(self._NewSetTag)
                self._NewSetTag = self._NewSetTag + 1;
                sweetSprite:setAnchorPoint(cc.p(0.5, 0));
                if i == #self._tbSecondDropDataTable then
                    actionOnceTime = 0.3;
                    sweetSprite:setPosition(cc.p(40, 1000 + sweetIndex * self._nSingleHeight +(sweetIndex) * 8));
                else
                    actionOnceTime = 0.2;
                    sweetSprite:setPosition(cc.p(40, 1000 + sweetIndex * self._nSingleHeight +(sweetIndex) * 8));
                end
                self._singleSweetNode:addChild(sweetSprite);
                sweetIndex = sweetIndex + 1;
                local action1 = cc.MoveTo:create(actionOnceTime, cc.p(40, self._tbDropPostionData[sweetIndex]));
                local action2 = cc.MoveTo:create(0.05, cc.p(40, self._tbDropPostionData[sweetIndex] + 10));
                local action3 = cc.MoveTo:create(0.03, cc.p(40, self._tbDropPostionData[sweetIndex]));
                local sequence = cc.Sequence:create(action1, action2, action3)
                sweetSprite:runAction(sequence);
            end
        end
    end

    if self._nSweetIndex == stageNum + 3 and callBackFunc then       
        audio.playSound("sweetparty/voice/sound_drop.mp3");
        performWithDelay(self, function()
            callBackFunc();
        end , 0.4);
    end


end

function SweetLayer:getNeedDrop()
    return self._bNeedDrop;
end

function SweetLayer:setNeedDrop(bNeedDrop)
    self._bNeedDrop = bNeedDrop;
end

function SweetLayer:AllSweetFadeOut(stageNum)
    for i =1,stageNum + 4 do
       local sweetSprite = self._singleSweetNode:getChildByTag(i) 
       if sweetSprite then
           sweetSprite:runAction(cc.FadeOut:create(1));
       end
    end
end
return SweetLayer;