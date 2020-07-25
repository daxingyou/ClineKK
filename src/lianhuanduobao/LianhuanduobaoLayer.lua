local SweetSprite = require("lianhuanduobao.SweetSprite");
local TableLogic = require("lianhuanduobao.TableLogic");
local LianhuanduobaoLayer = class("LianhuanduobaoLayer", function()
    return ccui.Layout:create();
end )

LianhuanduobaoLayer._nSingleHeight = 0;-- 单个糖果高度
LianhuanduobaoLayer._fruitListNode = nil;-- 糖果显示节点
LianhuanduobaoLayer._nLianhuanduobaoIndex = 1;
LianhuanduobaoLayer._bShowDropAction = false;-- 是否正在播放掉落动画
LianhuanduobaoLayer._NewSetTag = 0;-- 需要用来记录设置新掉落糖果的tag数
--LianhuanduobaoLayer._RemoveType = 1;-- 用来记录消失动画的序列
LianhuanduobaoLayer._tbDropLastData = { }
LianhuanduobaoLayer._tbDropDataTable = { }; -- 下落填充的糖果种类
LianhuanduobaoLayer._tbDropTagTable = { }; -- 下落填充的糖果替代tag值
LianhuanduobaoLayer._tbDropPostionData = { }; -- 下落填充的坐标位置
LianhuanduobaoLayer._LianhuanduobaoLayerSize = 0;
LianhuanduobaoLayer._LianhuanduobaoSize = 0;
LianhuanduobaoLayer._Offset_Y = 0;
LianhuanduobaoLayer._scale = 1;

function LianhuanduobaoLayer:create(lianhuanduobaoIndex,tablelayer)
    local lianhuanduobaolayer = LianhuanduobaoLayer:new();
    lianhuanduobaolayer:init(lianhuanduobaoIndex,tablelayer);
    return lianhuanduobaolayer;
end

function LianhuanduobaoLayer:ctor()
    self:removeAllChildren();
end

function LianhuanduobaoLayer:init(lianhuanduobaoIndex,tablelayer)
    self.tablelayer = tablelayer;
    self._nLianhuanduobaoIndex = lianhuanduobaoIndex;
    self._RemoveType = 1;
    self._NewSetTag = 0;
    self._bShowDropAction = false;
    -- 是否正在播放掉落动画
    self._nSingleHeight = 0;
    -- 单个糖果高度
    self._lianhuanduobaoListNode = nil;
    -- 糖果显示节点
    self:setAnchorPoint(0.5, 0);
    self:setClippingEnabled(true);
    self._singleLianhuanduobaoNode = cc.Node:create();
    --luaPrint("removeAllChildren");
    -- 起始位置
    self._singleLianhuanduobaoNode:setPosition(cc.p(0, 0));
    self:addChild(self._singleLianhuanduobaoNode);
end

-- 初始化转动的水果列表
function LianhuanduobaoLayer:initStartTable(LianhuanduobaoTable,stageNum)   
    self._RemoveType = 1;
    self._singleLianhuanduobaoNode:removeAllChildren();
    --luaPrint("initStartTable");
    -- 糖果显示序号
    --stageNum = 2
    if stageNum == 1 then
        self._LianhuanduobaoLayerSize = cc.size(146, 440);
        self._LianhuanduobaoSize = 60;
        self._Offset_Y = 35;
        self._Offset_Lianhuanduobao_Y = 14;
        self._scale = 1;
    elseif stageNum == 2 then
        self._LianhuanduobaoLayerSize = cc.size(140, 440);
        self._LianhuanduobaoSize = 53;
        self._Offset_Y = 78;
        self._Offset_Lianhuanduobao_Y = 10;
        self._scale =  0.8;
    else
        self._LianhuanduobaoLayerSize = cc.size(135, 440);
        self._LianhuanduobaoSize = 45;
        self._Offset_Y = 135;
        self._Offset_Lianhuanduobao_Y = 9;
        self._scale = 0.64;
    end

    self:setContentSize(self._LianhuanduobaoLayerSize);
    self._tbRemoveTagTable = { };
    self._tbDropPostionData = { }
    -- 会有新糖果掉落下来的坐标位置
    self._tbFirstDropTagTable = { }
    -- 第一次掉落现有糖果
    self._tbSecondDropDataTable = { }
    -- 第二次掉落糖果
    self:setNeedDrop(false);
    local ShowNextLianhuanduobaoNum = stageNum + 4;
    -- 最终下次掉落需要显示的数据获得行数
    self._singleLianhuanduobaoNode:setPosition(cc.p(0, 0));
    local lianhuanduobaoIndex = 0;
    for i = 1, 7 do
        if i > ShowNextLianhuanduobaoNum then
            break;
        end
        local lianhuanduobaoType = LianhuanduobaoTable[i]
        local lianhuanduobaoSprite = SweetSprite:create(lianhuanduobaoType, stageNum,true);
        self._nSingleHeight = self._LianhuanduobaoSize;      
        if lianhuanduobaoSprite then
            lianhuanduobaoSprite:setScale(self._scale);
            lianhuanduobaoSprite:setTag(lianhuanduobaoIndex + 1);
            lianhuanduobaoSprite:setSweetType(lianhuanduobaoType);
            lianhuanduobaoSprite:setAnchorPoint(cc.p(0.5, 0));
            local positiony = 538 + lianhuanduobaoIndex * self._nSingleHeight +(lianhuanduobaoIndex) * self._Offset_Lianhuanduobao_Y;
            if i == ShowNextLianhuanduobaoNum then
                lianhuanduobaoIndex = lianhuanduobaoIndex + 1;
                lianhuanduobaoSprite:setPosition(cc.p(40, 440 + lianhuanduobaoIndex * self._nSingleHeight +(lianhuanduobaoIndex) * self._Offset_Lianhuanduobao_Y));
            else
                lianhuanduobaoSprite:setPosition(cc.p(40, 440 + lianhuanduobaoIndex * self._nSingleHeight +(lianhuanduobaoIndex) * self._Offset_Lianhuanduobao_Y));
            end
            self._singleLianhuanduobaoNode:addChild(lianhuanduobaoSprite);
            lianhuanduobaoIndex = lianhuanduobaoIndex + 1;
        end
    end
end

-- 开始转，tbResultFruit为最后要显示的水果数据
function LianhuanduobaoLayer:start(LianhuanduobaoTable, stageNum, callBackFunc)
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
        self:playFinalAction(LianhuanduobaoTable, stageNum, callBackFunc);
    end );
    local sequence = cc.Sequence:create(action1, action2)
    self._singleLianhuanduobaoNode:runAction(sequence);
end

function LianhuanduobaoLayer:setRemoveSequence(RemoveTable)
    for i = 1, #RemoveTable do
        --luaPrint("i", i);
        --luaPrint("self._nLianhuanduobaoIndex", self._nLianhuanduobaoIndex);
        local lianhuanduobaoSprite = self._singleLianhuanduobaoNode:getChildByTag(i);
        lianhuanduobaoSprite:setRemoveSequence(RemoveTable[i]);
    end
    self:setNeedDrop(false);
end

-- 抛物线钻石
function LianhuanduobaoLayer:createZuanshiDesp(index,LianhuanduobaoTable,stageNum,node)  
    --luaDump(stageNum,"stageNum=========抛物线钻石") 
    self._singleLianhuanduobaoNode:removeAllChildren(); 
    local ShowNextLianhuanduobaoNum = stageNum + 4;   

    for i = 1, 7 do
        if i > ShowNextLianhuanduobaoNum then
            break;
        end
        local lianhuanduobaoType = LianhuanduobaoTable[i]
        local lianhuanduobaoSprite = SweetSprite:create(lianhuanduobaoType, stageNum,false);
        self._nSingleHeight = self._LianhuanduobaoSize;      
        if lianhuanduobaoSprite then        
            node:addChild(lianhuanduobaoSprite);  
 
            if stageNum == 1 then
               lianhuanduobaoSprite:setPosition(cc.p(143.75*index-70,113*i-50))  

            elseif stageNum == 2 then
               lianhuanduobaoSprite:setScale(0.8)
               lianhuanduobaoSprite:setPosition(cc.p(115*index-50,90.4*i-45))  
          
            elseif stageNum == 3 then
               lianhuanduobaoSprite:setScale(0.64)
               lianhuanduobaoSprite:setPosition(cc.p(94*index-45,75*i-37))  
            end


            self.callback1 = function ()
                  node:removeAllChildren()
            end
   
            local random = math.ceil(math.random(2))
            local direction = (random == 1 and -1 or 1)
            --luaPrint("direction=================",direction)
            local minX = 260*direction
            local jump = cc.JumpTo:create(0.6,cc.p(lianhuanduobaoSprite:getPositionX()+ minX + math.random(350)*direction,-50),math.random(200)+200,1)


            local callFun = cc.CallFunc:create(handler(self,self.callback1))
           lianhuanduobaoSprite:runAction(cc.Sequence:create(jump,callFun))
        end
    end
end

function LianhuanduobaoLayer:checkDropLianhuanduobao(NextLianhuanduobaoTable, NextSweetTable, stageNum, maxRemoveNum,callBackFunc)
    if self._RemoveType <4  then
        self._RemoveType = self._RemoveType + 1
    end
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
    local ShowNextLianhuanduobaoNum = stageNum + 4;
    -- 最大消除队列数
    local MaxRemoveSeqence = stageNum + 3;
    -- 每次队列消除时间
    local RemoveTime = 0.85
    -- 现有糖果中是否下边有糖果需要上面糖果掉落
    for i = 1, 7 do
        if i > ShowNextLianhuanduobaoNum then
            break;
        end
        local LianhuanduobaoSprite = self._singleLianhuanduobaoNode:getChildByTag(i)
        local removeSeqence = 1;
        local tempRemoveSeqence = 1;
        local function CheckRemoveSeqence(removeSeqence)
            if removeSeqence == tempRemoveSeqence then
                performWithDelay(self, function()
                    LianhuanduobaoSprite:RemoveSweet(self._RemoveType, stageNum);
                end , RemoveTime *(removeSeqence - 1));
            else
                tempRemoveSeqence = tempRemoveSeqence + 1;
                if tempRemoveSeqence <= maxRemoveNum then
                    CheckRemoveSeqence(removeSeqence);
                end
            end
        end
        local LianhuanduobaoIndex = 0;
        if LianhuanduobaoSprite then
            local removeSeqence = LianhuanduobaoSprite:getRemoveSequence();
            local RemovePostionY = LianhuanduobaoSprite:getPositionY();
            if removeSeqence > 0 then
                self:setNeedDrop(true)
                -- 将需要移除的糖果数记录入表
                local LianhuanduobaoSpriteTag = LianhuanduobaoSprite:getTag()
                table.insert(self._tbRemoveTagTable, LianhuanduobaoSpriteTag)
                --消除效果
                if removeSeqence == tempRemoveSeqence then
                    performWithDelay(self, function()
                          LianhuanduobaoSprite:RemoveSweet(self._RemoveType, stageNum);

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
                    local LianhuanduobaoSpriteTag = LianhuanduobaoSprite:getTag()
                    table.insert(self._tbFirstDropTagTable, LianhuanduobaoSpriteTag);

                    --                    if i == ShowNextLianhuanduobaoNum then
                    --                        table.insert(self._tbRemoveTagTable, LianhuanduobaoSpriteTag)
                    --                    end
                    table.insert(self._tbDropPostionData, RemovePostionY);
                end
            end
        end
    end

    local xiaochuTime = 1.5

    if self._nLianhuanduobaoIndex == stageNum + 3 then
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
--    luaDump(NextLianhuanduobaoTable, "NextLianhuanduobaoTable");
--    luaDump(NextLianhuanduobaoTable,"NextLianhuanduobaoTable");
    for i = ShowNextLianhuanduobaoNum - #self._tbRemoveTagTable + 1, MaxRemoveSeqence do
        table.insert(self._tbSecondDropDataTable, NextSweetTable[i]);
    end

    --执行过关消除效果
    local actionTime = (maxRemoveNum + 1) * (RemoveTime-0.3);
    performWithDelay(self, function()
    callBackFunc();
    end ,actionTime);
end



--上下震动效果
function LianhuanduobaoLayer:playFinalAction(LianhuanduobaoTable, stageNum, callBackFunc)
    self._singleLianhuanduobaoNode:stopAllActions();
    local endPosY = self._nSingleHeight * 6;
    -- 停止时的Y坐标
    local action1 = cc.MoveTo:create(0.1, cc.p(0, 0 - endPosY - self._Offset_Y));
    local action2 = cc.MoveTo:create(0.1, cc.p(0, 0 - endPosY - self._Offset_Y - 10));
    local action3 = cc.CallFunc:create( function()
        self._bShowDropAction = false;
        -- 停止掉落
        self._tbDropLastData = LianhuanduobaoTable;
        if self._nLianhuanduobaoIndex == stageNum + 3 and callBackFunc then
            --luaPrint("come on");
            callBackFunc()
        end
    end );
    local sequence = cc.Sequence:create(action1, action2, action3)
    self._singleLianhuanduobaoNode:runAction(sequence);
end

--第一次掉落
function LianhuanduobaoLayer:FirstDropAction(stageNum, callBackFunc)
    --luaPrint("FirstDropAction", self._nLianhuanduobaoIndex);
    if #self._tbRemoveTagTable ~= 0 then
        -- 第一次容器内已有糖果进行掉落
        local actionOnceTime = 0.2;
        for i = 1, #self._tbFirstDropTagTable do
            local lianhuanduobaoSprite = self._singleLianhuanduobaoNode:getChildByTag(self._tbFirstDropTagTable[i])
            local action1 = cc.MoveTo:create(actionOnceTime, cc.p(lianhuanduobaoSprite:getPositionX(), self._tbDropPostionData[i]));
            local action2 = cc.MoveTo:create(0.05, cc.p(lianhuanduobaoSprite:getPositionX(), self._tbDropPostionData[i] + 10));
            local action3 = cc.MoveTo:create(0.05, cc.p(lianhuanduobaoSprite:getPositionX(), self._tbDropPostionData[i]));
            local sequence = cc.Sequence:create(action1, action2, action3)
            --luaPrint("self._NewSetTag1", self._NewSetTag);
            lianhuanduobaoSprite:setTag(self._NewSetTag);
            self._NewSetTag = self._NewSetTag + 1;
            lianhuanduobaoSprite:runAction(sequence);
        end
    end

    if self._nLianhuanduobaoIndex == stageNum + 3 and callBackFunc then
        performWithDelay(self, function()
            callBackFunc();
        end , 0.3);
    end
end

--第二次掉落
function LianhuanduobaoLayer:SecondDropAction(stageNum, iNextFallLianhuanduobao, callBackFunc)
    --luaPrint("SecondDropAction", self._nLianhuanduobaoIndex);
    table.insert(self._tbSecondDropDataTable, iNextFallLianhuanduobao);
    --luaDump(self._tbSecondDropDataTable, "_tbSecondDropDataTable");
    if #self._tbRemoveTagTable ~= 0 then
        local ShowNextLianhuanduobaoNum = stageNum + 4;
        local lianhuanduobaoIndex = #self._tbFirstDropTagTable;
        local actionOnceTime = 0.2;
        for i = 1, #self._tbSecondDropDataTable do
            local lianhuanduobaoSprite = SweetSprite:create(self._tbSecondDropDataTable[i], stageNum,true);
            self._nSingleHeight = self._LianhuanduobaoSize;
            if lianhuanduobaoSprite then
                lianhuanduobaoSprite:setScale(self._scale);
                lianhuanduobaoSprite:setSweetType(self._tbSecondDropDataTable[i]);
                lianhuanduobaoSprite:setTag(self._NewSetTag)
                --luaPrint("self._NewSetTag2", self._NewSetTag);
                self._NewSetTag = self._NewSetTag + 1;
                lianhuanduobaoSprite:setAnchorPoint(cc.p(0.5, 0));
                if i == #self._tbSecondDropDataTable then
                    actionOnceTime = 0.3;
                    lianhuanduobaoSprite:setPosition(cc.p(40, 1000 + lianhuanduobaoIndex * self._nSingleHeight +(lianhuanduobaoIndex) * 8));
                else
                    actionOnceTime = 0.2;
                    lianhuanduobaoSprite:setPosition(cc.p(40, 1000 + lianhuanduobaoIndex * self._nSingleHeight +(lianhuanduobaoIndex) * 8));
                end
                self._singleLianhuanduobaoNode:addChild(lianhuanduobaoSprite);
                lianhuanduobaoIndex = lianhuanduobaoIndex + 1;
                --luaPrint("self._tbDropPostionData[lianhuanduobaoIndex+1]", self._tbDropPostionData[lianhuanduobaoIndex])
                local action1 = cc.MoveTo:create(actionOnceTime, cc.p(40, self._tbDropPostionData[lianhuanduobaoIndex]));
                local action2 = cc.MoveTo:create(0.05, cc.p(40, self._tbDropPostionData[lianhuanduobaoIndex] + 10));
                local action3 = cc.MoveTo:create(0.03, cc.p(40, self._tbDropPostionData[lianhuanduobaoIndex]));
                local sequence = cc.Sequence:create(action1, action2, action3)
                lianhuanduobaoSprite:runAction(sequence);
            end
        end
    end

    if self._nLianhuanduobaoIndex == stageNum + 3 and callBackFunc then
        --luaPrint("self._nLianhuanduobaoIndex == stageNum + 3");
        performWithDelay(self, function()
            callBackFunc();
        end , 0.4);
    end


end

function LianhuanduobaoLayer:getNeedDrop()
    return self._bNeedDrop;
end

function LianhuanduobaoLayer:setNeedDrop(bNeedDrop)
    self._bNeedDrop = bNeedDrop;
end

function LianhuanduobaoLayer:AllLianhuanduobaoFadeOut(stageNum)
    --luaPrint("#_singleLianhuanduobaoNode");
    for i =1,stageNum + 4 do
       local lianhuanduobaoSprite = self._singleLianhuanduobaoNode:getChildByTag(i) 
       if lianhuanduobaoSprite then
           lianhuanduobaoSprite:runAction(cc.FadeOut:create(1));
       end
    end
end
return LianhuanduobaoLayer;