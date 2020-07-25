--local GameLogic = require("app.views_pdk.Logic")
local CardSprite = require("doudizhu.CardSprite")

--卡牌
local CardLayer = class("CardLayer",function()
    return ccui.Layout:create()
end)

function CardLayer:create(tableLayer)
    local view = CardLayer.new()
    view:onCreate(tableLayer)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end

function CardLayer:onEnter()

end

function CardLayer:onExit()
    self.cardLayout = nil;
end

function CardLayer:onCreate(tableLayer)
    --local params = {...};
    --luaDump(params, '----------onCreate---------------', 6)
    
    self.tableLayer = tableLayer
    -- if params[2] ~= nil then
    --     self.playerInfo = params[2];
    -- else
    --     self.playerInfo = g_tableRoomUserInfo;
    -- end
    

    -- jdump(self.playerInfo,'------------------------ onCreate_self.playerInfo ------------------------',5)

    self.hardCardNode = nil;
    self.outCardPos = {};
    -- for i=0,2 do
    --     --local node = self.cardLayout:getChildByName("Node_out"..i);
    --     self.outCardPos[i] = cc.p(node:getPosition());
    -- end

    self.outCardPos[0] = cc.p(640,390);--自己出牌的位置
    self.outCardPos[1] = cc.p(900,430);--右手
    self.outCardPos[2] = cc.p(300,430);--左手

    self.cbHandCardData = {};
    
  
    -- self.interval = 50;
    -- self.cardWidth = 97;
    -- self.cardHight = 135;
    -- self.bottomHigth = 100;

    self.interval = 70;
    self.cardWidth = 135.8;
    self.cardHight = 189;
    self.bottomHigth = 5;
    self.nCardScale = 1.4;
    self.isTouch = false;

    
    self.shootHight = 30;
    self.cbUpCardData = {};
    self.cbUpCardCount = 0;
    self.cbTurnCardData = {};
    self.cbTurnCardCount = 0;  
    self.cbTiCardData = {};
    self.cbTiCardCount = 0;
    self.beganTouchPoint = 0;
    self.max_count = 16;

    self.cbTempHandCardData = {};
    self.cbTempHandCardCount = 0;
    
    self.pCardNodeR = cc.Node:create();
    self:addChild(self.pCardNodeR,101);
    self.pCardNodeL = cc.Node:create();
    self:addChild(self.pCardNodeL,101);
    self.pCardNodeM = cc.Node:create();
    self:addChild(self.pCardNodeM,101);

    --测试用结点
    self.testNodeR = cc.Node:create();
    self:addChild(self.testNodeR,101);
    self.testNodeL = cc.Node:create();
    self:addChild(self.testNodeL,101);
    self.testNodeM = cc.Node:create();
    self:addChild(self.testNodeM,101);

    --回放玩家手牌展示
    self.cbhandCardDataL = {};   --左边玩家手牌
    self.cbHandCardDataLCount = 0;   --左边玩家手牌数量
    self.cbhandCardDataR = {};   --右边玩家手牌
    self.cbHandCardDataRCount = 0;   --右边玩家手牌数量
    
    -- self.pHandCardNodeL = self.cardLayout:getChildByName("Node_hand1");
    -- self.pHandCardNodeR = self.cardLayout:getChildByName("Node_hand2");

    self.winSize = cc.Director:getInstance():getWinSize()

    self.hardCardNode = cc.Node:create()
    self:addChild(self.hardCardNode)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch,unused_event) return self:onTouchBegan(touch,unused_event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch,unused_event) self:onTouchMoved(touch,unused_event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch,unused_event) self:onTouchEnded(touch,unused_event) end, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)

    return true
end

function CardLayer:onTouchBegan(touch, unused_event)

    if self.isTouch then
        return;
    end

    luaPrint("触摸出牌")
    self.beganTouchPoint = self.tableLayer.Panel_cardBg:convertToNodeSpace(touch:getLocation())
    self.pos1 = 0
    local HandCardVector = self.hardCardNode:getChildren()
    for i=#HandCardVector,1,-1 do
        local pCardSprite = HandCardVector[i]
        local spriteRect = pCardSprite:getBoundingBox()
        local rect = {}
        -- if i ~= #HandCardVector then
        --     rect = cc.rect(spriteRect.x,spriteRect.y,self.interval + 13,spriteRect.height)
        -- else
            rect = cc.rect(spriteRect.x,spriteRect.y,spriteRect.width,spriteRect.height)
        --end
        if cc.rectContainsPoint(rect,self.beganTouchPoint) then
            self.pos1 = i
            pCardSprite:setColor(cc.c3b(166,166,166))
            pCardSprite.bSelect = true
            return true
        end
    end

    self:hideUpCardAction();
    self.tableLayer:CheckHandCard();
    return false
end

function CardLayer:onTouchMoved(touch,unused_event)

    if self.isTouch then
        return;
    end

    local touchPoint = self.tableLayer.Panel_cardBg:convertToNodeSpace(touch:getLocation())
    local HandCardVector = self.hardCardNode:getChildren()
    self.pos2 = 0
    for i=1,#HandCardVector do
        local pCardSprite = HandCardVector[i]
        local spriteRect = pCardSprite:getBoundingBox()
        local rect = {}
        if i ~= #HandCardVector then
            rect = cc.rect(spriteRect.x,spriteRect.y,self.interval+13,spriteRect.height)
        else
            rect = cc.rect(spriteRect.x,spriteRect.y,spriteRect.width,spriteRect.height)
        end
        if cc.rectContainsPoint(rect,touchPoint) then
            pCardSprite:setColor(cc.c3b(166,166,166))
            pCardSprite.bSelect = true
            self.pos2 = i
        end
    end
    --两点之间找到牌,滑动一下
    if self.pos1 ~= 0 and self.pos2 ~= 0 then
        local tmp1 = self.pos1
        local tmp2 = self.pos2
        if self.pos1 < self.pos2 then
            tmp1 = self.pos1
            tmp2 = self.pos2
        else
            tmp1 = self.pos2
            tmp2 = self.pos1
        end
        for i=1,#HandCardVector do
        --for i=tmp1,tmp2 do
            local pCardSprite = HandCardVector[i]
            if i >= tmp1 and i <= tmp2 then
                pCardSprite:setColor(cc.c3b(166,166,166))
                pCardSprite.bSelect = true
            else
                pCardSprite:setColor(cc.c3b(255,255,255))
                pCardSprite.bSelect = false
            end
        end
    end
end

function CardLayer:onTouchEnded(touch, unused_event)

    if self.isTouch then
        return;
    end

    self.cbUpCardCount = 0
    self.cbUpCardData = {}
    
    local cbTempCardCount = 0
    local cbTempCardData = {}
    for i=1,self.max_count do
        cbTempCardData[i] = 0
    end
    local cbTempCardCount2 = 0
    local cbTempCardData2 = {}
    for i=1,self.max_count do
        cbTempCardData2[i] = 0
    end
    --收集准备提的牌对象
    local HandCardVector = self.hardCardNode:getChildren()
    for i=1,#HandCardVector do
        local pCardSprite = HandCardVector[i]
        if pCardSprite.bSelect then
            if not pCardSprite.bUp then
                cbTempCardCount =cbTempCardCount + 1
                cbTempCardData[cbTempCardCount] = pCardSprite  --取得牌的具体数值
                cbTempCardCount2 = cbTempCardCount2 + 1
                cbTempCardData2[cbTempCardCount2] = pCardSprite.cbCard
            end
        end
    end
    
    --设置牌动画
    for i=1,#HandCardVector do
        local pCardSprite = HandCardVector[i]
        if pCardSprite.bSelect then
            local nPosY = 0
            if pCardSprite.bUp then
                nPosY = pCardSprite:getPositionY() - self.shootHight
                pCardSprite.bUp = false
                
                local action = cc.MoveTo:create(0.1,cc.p(pCardSprite:getPositionX(),nPosY))
                pCardSprite:runAction(action)
                pCardSprite:setColor(cc.c3b(255,255,255))
                pCardSprite.bSelect = false
            else
                --播放牌选中声音
                self:playUpCardSound();

                nPosY = pCardSprite:getPositionY() + self.shootHight
                pCardSprite.bUp = true
                local action = cc.MoveTo:create(0.1,cc.p(pCardSprite:getPositionX(),nPosY))
                pCardSprite:runAction(action)
                pCardSprite:setColor(cc.c3b(255,255,255))
                pCardSprite.bSelect = false
            end
        end
    end

    playEffect("effect/ddz_touchCard.mp3")
    
    self:setTouchEndedCard()  --效验设置的牌是否打得过上家的牌,或者牌搭配正确

end

function CardLayer:setHandCardData(data,count)
    self.cbHandCardData = {};
    for i=1,count do
        self.cbHandCardData[i] = data[i]
    end
    self.cbHandCardCount = count;

end

--手牌扩展效果
function CardLayer:showHandCardEx()
    luaPrint("CardLayer:showHandCardEx(")
	self.hardCardNode:removeAllChildren() --删除所有的牌
    
    local time = 0.145;

    for i=1,self.cbHandCardCount do
        luaPrint("牌",self.cbHandCardCount,self.cbHandCardData[i])
        local card = self:getCardSprite(self.cbHandCardData[i])
        
        card:setPosition(cc.p(140,60))
        card:setAnchorPoint(cc.p(0,0))
        card.bUp = false
        card.bSelect = false
        card.cbCard = self.cbHandCardData[i]
        --card:setScale(1.1)
        self.hardCardNode:addChild(card)
        card:runAction(cc.Sequence:create(cc.MoveBy:create(time*i,cc.p(50*i,0)) ))
        
    end
end

function CardLayer:getCardSprite(cbCard)
    local card = CardSprite:create(cbCard);
    return card
end

-- 出牌和显示的牌
function CardLayer:getOutCardSprite(cbCard)
    local card = CardSprite:create(cbCard,1);
    return card
end

--重置卡牌
function CardLayer:resetUpCardView()
	local HandCardVector = self.hardCardNode:getChildren() --获取所有的牌
	for i=1,#HandCardVector do
        local cardSprite = HandCardVector[i]
        if cardSprite.bUp then --牌是上牌状态
            cardSprite.bUp = false --设置牌是默认状态
            local nPosY = cardSprite:getPositionY()-self.shootHight
            cardSprite:setPositionY(nPosY) --设置牌的坐标
        end
	end
	
	self:resetUpCardData()  --重置上牌卡牌数据
end

--重置上牌卡牌数据
function CardLayer:resetUpCardData()
    self.cbUpCardData = {}
    self.cbUpCardCount = 0
end

--查找自动出牌的结果
function CardLayer:searchOutCard()
    luaPrint("自动查找出牌")
    local OutCardResult = {}
    OutCardResult.cbResultCard = {}
    OutCardResult.cbCardCount = 0
    --上家出牌数量为0,表示自己随便出牌,以右边最小的牌出,如
    --果左边最小的是单张就出单张,是对子出对子,是三个就是出3带二,
    --是4个就出最右第二小的牌,以此类推
	if self.cbTurnCardCount == 0 then
	   luaPrint("上家没牌")
        if GameLogic:GetCardType(self.cbHandCardData,self.cbHandCardCount,true) ~= 0 then  --自己手上全部的牌能不能一把出
            return true,{cbResultCard=self.cbHandCardData,cbCardCount=self.cbHandCardCount} --能出,直接返回自己手上的牌 
	    end
	    local AnalysebData = {}
        AnalysebData = GameLogic:AnalysebCardData(self.cbHandCardData,self.cbHandCardCount,false)
        local ret,OutCardResult = GameLogic:getNewFreshOutCardData(self.cbHandCardData,self.cbHandCardCount,AnalysebData)
        if not ret then
            luaPrint("上家没牌自己出牌错误")
        end
        --下家报警,表示下家只有一张牌,这个时候就要以一对为最小出牌,单牌出最大,SameCardNum 表示没有找到对子
        --设置左边最大的单牌,牌数为1
        if self.bNextWarn and OutCardResult.cbCardCount == 1 then --如果自己也是出单张,但是下家只剩一张牌的话,只能从左边单张最大的牌出
            luaPrint("下家报警,自己随便出牌,只能从左边最大的牌出")
            OutCardResult.cbResultCard[1] = self.cbHandCardData[1] --左边最大的牌
            OutCardResult.cbCardCount = 1
        end
        if OutCardResult.cbCardCount == 0 then  --到这里出现了未知错误,错误最小化处理,出左边最小的牌,单张
            OutCardResult.cbResultCard[1] = self.cbHandCardData[self.cbHandCardCount] --右边最小的牌
            OutCardResult.cbCardCount = 1
        end
        luaPrint("找到牌个数",OutCardResult.cbCardCount)
        return true,OutCardResult  --返回牌结果
	end
	
	--这里,如果上家出牌了,这里找出比上家大的牌,或者 ,没有大的牌就什么都不做
	--参数为自己的牌,上家的牌
    local ret = GameLogic:SearchOutCard(self.cbHandCardData,self.cbHandCardCount,self.cbTurnCardData,self.cbTurnCardCount,OutCardResult)
    luaPrint("上家有牌,查找出牌结果",OutCardResult.cbCardCount,"返回结果",ret)
   
	if self.cbTurnCardCount == 1 and self.bNextWarn and ret then --如果上家出的牌为一张,而且下家是报警,这里就改成最大的单张牌出,
	   OutCardResult.cbCardCount = 1
	   OutCardResult.cbResultCard[1] = GameLogic:GetHandMaxCard(self.cbHandCardData,self.cbHandCardCount) --在自己的牌里取最大单张
	end
    for i=1,OutCardResult.cbCardCount do
        luaPrint("上家有牌,自动查找牌最终的出牌",i,OutCardResult.cbResultCard[i])
	end
	luaPrint("上家有牌,最终出牌的个数",OutCardResult.cbCardCount)
	return ret,OutCardResult
end




--手上牌是否可以自动出
function CardLayer:isCanPlayOnce()
    local bBoom= GameLogic:hasBoom(self.cbHandCardData,self.cbHandCardCount);
    local result = not bBoom;
    return result;
end


--将各家的出牌数据保存起来,再执行出牌动作
function CardLayer:setOutCardData(seatId,cbCard,nCount)
	self.nMinIdx = 0
	luaPrint("开始出牌动作",nCount,self.pCardNodeM:getPositionX(),self.pCardNodeM:getPositionY())
	self.cbTurnCardData = {}  --上家的出牌清零
    self.cbTurnCardCount = nCount
	for i=1,nCount do  --设置上家的牌数据
	   self.cbTurnCardData[i] = cbCard[i]
	end
	
	self.outSeatId = seatId  --出牌的位置

    local outCardTime = 0.01; --出牌时间

    if self.outSeatId == 0 then
        self.pCardNodeM:removeAllChildren()  --自己
        for i=1,nCount do  
            local pCardSprite = self:getOutCardSprite(cbCard[i])  --新建一张牌
            local ptX = 640
            if nCount%2 == 1 then  --单数
                if i < nCount/2 then
                    ptX = 640 - (math.floor(nCount/2) -i)*32
                elseif i > nCount/2 then
                    ptX = 640 + (i-math.floor(nCount/2))*32
                end
            else
                if i <= nCount/2 then
                    ptX = 640 - (nCount/2 -i)*32
                elseif i > nCount/2 then
                    ptX = 640 + (i-nCount/2)*32
                end
            end
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,100)
            pCardSprite:setScale(0.05)  --缩小
            pCardSprite:setVisible(true)  --显示
            self.pCardNodeM:addChild(pCardSprite);
            local move = cc.MoveBy:create(outCardTime,cc.p(0,240))
            local scaleAction = cc.ScaleTo:create(outCardTime,1);
            pCardSprite:runAction(cc.Spawn:create(move,scaleAction));
        end
    elseif self.outSeatId == 1 then
        self.pCardNodeR:removeAllChildren()  --右上的出牌节点
        for i=1,nCount do 
            local pCardSprite = self:getOutCardSprite(cbCard[i])  --新建一张牌
            local ptX = 975 - (nCount -i)*32
            
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(1150,520)
            pCardSprite:setScale(0.05)  --缩小
            pCardSprite:setVisible(true)  --显示
            self.pCardNodeR:addChild(pCardSprite);
            local move = cc.MoveTo:create(outCardTime,cc.p(ptX,500))
            local scaleAction = cc.ScaleTo:create(outCardTime,1);
            pCardSprite:runAction(cc.Spawn:create(move,scaleAction));
        end
    elseif self.outSeatId == 2 then
        self.pCardNodeL:removeAllChildren()  --左上的出牌节点
        for i=1,nCount do  
            local pCardSprite = self:getOutCardSprite(cbCard[i])  --新建一张牌
            local ptX = 280 + i*32
            
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(100,520)
            pCardSprite:setScale(0.05)  --缩小
            pCardSprite:setVisible(true)  --显示
            self.pCardNodeL:addChild(pCardSprite,i);
            local move = cc.MoveTo:create(outCardTime,cc.p(ptX,500))
            local scaleAction = cc.ScaleTo:create(outCardTime,1);
            pCardSprite:runAction(cc.Spawn:create(move,scaleAction));
        end
    end
    playEffect("effect/Special_give.mp3")
end

--不播放动画的出牌
function CardLayer:setResultCard(seatId,cbCard,nCount)
    self.outSeatId = seatId  --出牌的位置
    
    if self.outSeatId == 0 then
        self.pCardNodeM:removeAllChildren()  --自己
        for i=1,nCount do  
            local pCardSprite = self:getOutCardSprite(cbCard[i])  --新建一张牌
            local ptX = 640
            if nCount%2 == 1 then  --单数
                if i < nCount/2 then
                    ptX = 640 - (math.floor(nCount/2) -i)*32
                elseif i > nCount/2 then
                    ptX = 640 + (i-math.floor(nCount/2))*32
                end
            else
                if i <= nCount/2 then
                    ptX = 640 - (nCount/2 -i)*32
                elseif i > nCount/2 then
                    ptX = 640 + (i-nCount/2)*32
                end
            end
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,340)
            pCardSprite:setVisible(true)  --显示
            self.pCardNodeM:addChild(pCardSprite);
        end
    elseif self.outSeatId == 1 then
        self.pCardNodeR:removeAllChildren()  --右上的出牌节点
        for i=1,nCount do 
            local pCardSprite = self:getOutCardSprite(cbCard[i])  --新建一张牌

            local ptY = 500;
            local ptXCount = i-1;
            local maxCount = 9;
            local zorder = nCount-i;
            --大于10张时候放在下面
            if nCount>maxCount then
                if i > maxCount then
                    ptY = 440;
                    -- ptXCount = maxCount-(i-(nCount - maxCount));
                    ptXCount = i-maxCount-1;
                    zorder = zorder+maxCount*2+1;
                else
                    ptXCount = i-1;
                end
            end

            local ptX = 975 - ptXCount*32
            
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,ptY)
            pCardSprite:setVisible(true)  --显示
            self.pCardNodeR:addChild(pCardSprite,zorder);
        end
    elseif self.outSeatId == 2 then
        self.pCardNodeL:removeAllChildren()  --左上的出牌节点
        for i=1,nCount do  
            local pCardSprite = self:getOutCardSprite(cbCard[i])  --新建一张牌

            local ptY = 500;
            local ptXCount = i-1;
            local maxCount = 9;
            local zorder = i;
            --大于10张时候放在下面
            if nCount>maxCount then
                if i > maxCount then
                    ptY = 440;
                    ptXCount = i - maxCount - 1;
                    zorder = zorder+maxCount+1;
                else
                    ptXCount = i-1;
                end
            end

            local ptX = 305 + ptXCount*32
            
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,ptY)
            pCardSprite:setVisible(true)  --显示
            self.pCardNodeL:addChild(pCardSprite,zorder);
        end
    end
end

function CardLayer:setTestCard(seatId,cbCard,nCount)
    self.outSeatId = seatId  --出牌的位置
    
    if self.outSeatId == 0 then
        self.testNodeM:removeAllChildren()  --自己
        for i=1,nCount do  
            local pCardSprite = self:getCardSprite(cbCard[i])  --新建一张牌
            local ptX = 640
            if nCount%2 == 1 then  --单数
                if i < nCount/2 then
                    ptX = 640 - (math.floor(nCount/2) -i)*40
                elseif i > nCount/2 then
                    ptX = 640 + (i-math.floor(nCount/2))*40
                end
            else
                if i <= nCount/2 then
                    ptX = 640 - (nCount/2 -i)*40
                elseif i > nCount/2 then
                    ptX = 640 + (i-nCount/2)*40
                end
            end
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,300)
            pCardSprite:setScale(0.6)  --缩小
            pCardSprite:setVisible(true)  --显示
            self.testNodeM:addChild(pCardSprite);
        end
    elseif self.outSeatId == 1 then
        self.testNodeR:removeAllChildren()  --右上的出牌节点
        for i=1,nCount do 
            local pCardSprite = self:getCardSprite(cbCard[i])  --新建一张牌
            local ptX = 1000 - (nCount -i)*20

            --测试用往左多移动
            ptX = 1200 - (nCount -i)*20

            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,580)
            pCardSprite:setScale(0.6)  --缩小
            pCardSprite:setVisible(true)  --显示
            self.testNodeR:addChild(pCardSprite);
        end
    elseif self.outSeatId == 2 then
        self.testNodeL:removeAllChildren()  --左上的出牌节点
        for i=1,nCount do  
            local pCardSprite = self:getCardSprite(cbCard[i])  --新建一张牌
            local ptX = 260 + i*20

            --测试用往又多移动
            ptX = 60 + i*20
            
            luaPrint("ptX=========",ptX)
            pCardSprite:setPosition(ptX,580)
            pCardSprite:setScale(0.6)  --缩小
            pCardSprite:setVisible(true)  --显示
            self.testNodeL:addChild(pCardSprite,i);
        end
    end
end

--设置不可触摸
function CardLayer:setTouchEnabled(isEnabled)
    if isEnabled == nil then 
        isEnabled = true;
    end

    self.isTouch = isEnabled;
end

--出牌的位置
function CardLayer:getOutCardPos(seatId)
	local pt = {};
    
    pt.x = self.outCardPos[seatId].x;
    pt.y = self.outCardPos[seatId].y;
    return pt;
end

--手牌中的位置
function CardLayer:getHandCardNodePosition(cbCard)
    local pt = {x=0,y=0}
    local HandCardVector = self.hardCardNode:getChildren()
    for i=1,#HandCardVector do
        local pCardSprite = HandCardVector[i]
        --if GameLogic:GetCardLogicValue(pCardSprite.cbCard) == GameLogic:GetCardLogicValue(cbCard) then  
            pt.x,pt.y = pCardSprite:getPosition()
        --end
    end
	return pt
end

function CardLayer:showHandCard(cbCard,nCount)
    luaPrint("showHandCard",nCount)
	self.hardCardNode:removeAllChildren()
	
    local ptIndeX = 640
    if nCount <= 17 then
        ptIndeX = 540
    end

	local nTallWidth = nCount * self.interval + self.cardWidth
	local winSize = cc.Director:getInstance():getWinSize()
	for i=1,nCount do
        local pCardSprite = self:getCardSprite(cbCard[i])
        if nCount%2 == 1 then  --单数
            if i <  math.floor(nCount/2) then
                ptX = ptIndeX - (math.floor(nCount/2) -i)*50
            elseif i >  math.floor(nCount/2) then
                ptX = ptIndeX + (i-math.floor(nCount/2))*50
            else
                ptX = ptIndeX
            end
        else
            if i <= nCount/2 then
                ptX = ptIndeX - (nCount/2 -i)*50
            elseif i > nCount/2 then
                ptX = ptIndeX + (i-nCount/2)*50
            end
        end
        luaPrint("--------------------",ptX)
        pCardSprite:setPosition(ptX,60)
        pCardSprite:setAnchorPoint(cc.p(0,0))
        pCardSprite.bUp = false
        pCardSprite.bSelect = false
        pCardSprite.cbCard = cbCard[i]
        --pCardSprite:setScale(self.nCardScale); --scale = 1.4
        self.hardCardNode:addChild(pCardSprite)
	end
end

--刷新手牌 只重新load纹理
function CardLayer:refreshHandCard(cbCard,nCount)
    luaPrint("refreshHandCard",nCount)
    local children = self.hardCardNode:getChildren()
    
    for i=1,nCount do
        local card = children[i];
        if card then
            card:loadCard(cbCard[i]);
        end
    end
end

--获取手牌位置
function CardLayer:getHandCardPos(nIndex,nCount)
    local nTallWidth = nCount * self.interval + self.cardWidth
    local winSize = cc.Director:getInstance():getWinSize()
    local pt = {x=0,y=0}
    pt.x = (winSize.width - nTallWidth) / 2 - self.cardWidth*0.5 + nIndex * self.interval ; -- - 85
    pt.y = self.bottomHigth
    return pt;
end

--播放选中牌声音
function CardLayer:playUpCardSound()
    -- local path = "voice/effect/";
    -- path = path..'flop.mp3';
    -- luaPrint('up_card_sound_path:',path);
    -- PlayCustomSE(path);
end 



--播放报单声音
function CardLayer:playOnlyCardSound(logicSeatId,nCount)
    if nCount == nil then
        nCount = 1;
    end

    if nCount ~= 2 and nCount ~= 1 then
        return;
    end

    local path = "voice/effect/Normal/"
    -- jdump(g_tableRoomUserInfo,'=========playOnlyCardSound g_tableRoomUserInfo========',6)
    -- local sex = g_tableRoomUserInfo[logicSeatId].nSex;
    local sex = self.playerInfo[logicSeatId].nSex;

    --0 女性 1男性
    if sex ~= 0 and sex ~= 1 then
        sex = 1;
    end
    
    if sex == 0 then
        path = path..'W/'
    else
        path = path..'M/'
    end

    local str = string.format('SHENYU%d.mp3',nCount)

    path = path..str;
    luaPrint('card_sound_path:',path);
    PlayCustomSE(path);
end 

--播放过牌声音
function CardLayer:playPassSound(logicSeatId)
    local path = "voice/effect/Normal/"
    -- jdump(g_tableRoomUserInfo,'=========playPassSound g_tableRoomUserInfo========',6)
    local sex = self.playerInfo[logicSeatId].nSex;

    --0 女性 1男性
    
    if sex ~= 0 and sex ~= 1 then
        sex = 1;
    end
    
    if sex == 0 then
        path = path..'W/'
    else
        path = path..'M/'
    end

    path = path..'GUO.mp3';
    luaPrint('card_sound_path:',path)
    PlayCustomSE(path);

end

--播放出牌声音
function CardLayer:playOutCardSound(logicSeatId,cbCard,nCount)
    local bLast = true;
    local cbCardType = GameLogic:GetCardType(cbCard,nCount,bLast);
    -- local sex = GameCommon:getUserInfo(nChair).cbSex
    luaPrint('playOutCardSound______ cbCardType,nCount :',cbCardType,nCount)
    local path = "voice/effect/Normal/"
    -- jdump(self.playerInfo,'=========self.playerInfo========',6)



    local sex = self.playerInfo[logicSeatId].nSex;

    --0 女性 1男性
    
    if sex ~= 0 and sex ~= 1 then
        sex = 1;
    end
    
    if sex == 0 then
        path = path..'W/'
    else
        path = path..'M/'
    end
    


	local str = nil
	
	-- if cbCardType == 6 and nCount > 5 then
	--    cbCardType = 9
	-- elseif cbCardType == 6 and nCount == 5 then
	--    cbCardType = 11
	-- elseif cbCardType == 6 and nCount == 4 then
	--    cbCardType = 10
	-- elseif cbCardType == 6 and nCount == 3 then
	--    cbCardType = 12
	-- end
	
	local value = 0
	local AnalyseResult = {}
	if cbCardType == 1 then  --单牌
        value = GameLogic:GetCardLogicValue(cbCard[1])
	    if value == 13 then
            value = 14; --A
        elseif value == 14 then
             value = 2; --2
        else
            value = value + 1;
        end

        str = string.format('S%d.mp3',value);
        
    elseif cbCardType == 2 then  --对牌
        value = GameLogic:GetCardLogicValue(cbCard[1])
        if value == 13 then
            value = 14; --A
        elseif value == 14 then
             value = 2; --2
        else
            value = value + 1;
        end

        str = string.format('D%d.mp3',value);
        
    elseif cbCardType == 3 then  --顺子
        str = 'SHUNZI.mp3';
        
    elseif cbCardType == 4 then  --对连
        str = 'LIANDUI.mp3';
        
    elseif cbCardType == 6 then     --三单张 or 三带一 or 三带二
        if nCount == 3 then 
            str = 'T30.mp3';
            
        elseif nCount == 4 then
            str = 'T31.mp3';
            
        elseif nCount == 5 then
            str = 'T32.mp3';              
        end

        
    elseif cbCardType == 6 or cbCardType == 12 then  --三带二
        -- AnalyseResult = GameLogic:AnalysebCardData(cbCard,nCount,false)
        -- value = AnalyseResult.cbThreeCardData[1]
        str = 'T32.mp3';
       

    elseif cbCardType == 8 then  --炸弹
        str = 'ZHADAN.mp3';
        
        
    elseif cbCardType == 9 then  --飞机类型
        str = 'FEIJI.mp3';
       
        
    elseif cbCardType == 10 then  --四带二
        str = 'T42.mp3';
	end
	
	if str == nil then
	   return 
	end
	
    path = path..str;
    luaPrint('card_sound_path:',path)
    PlayCustomSE(path);
    
end

--判断是不是新的一轮
function CardLayer:compareUpCard(bNewTurn)
    local isLast = false
    if self.cbUpCardCount == self.cbHandCardCount then
        isLast = true
    end
	if bNewTurn then  --如果是新的一轮
        local ret = GameLogic:GetCardType(self.cbUpCardData,self.cbUpCardCount,isLast)  --取得up的牌数据

	   if self.bNextWarn then  --下家就剩一张牌了
	       if self.cbUpCardCount > 1 then  --而且自己出的牌大于单张,就不用顶最大的单牌了
	           return ret
	       end    
	       local firstCard = GameLogic:GetCardLogicValue(GameLogic:GetHandMaxCard(self.cbHandCardData,self.cbHandCardCount))  --否则,获取自己最大的牌
	       local secondCard = GameLogic:GetCardLogicValue(self.cbUpCardData[1])  --获取up牌中最大的牌
	       return firstCard == secondCard  --返回他两是不是相等
	   end
	   return ret
	end
	
	if self.cbTurnCardCount ~= 0 and self.cbUpCardCount ~= 0 then  --不是新的一轮,上家有牌
        local ret = GameLogic:CompareCard(self.cbTurnCardData,self.cbUpCardData,self.cbTurnCardCount,self.cbUpCardCount,isLast)  --比较下是不是大于上家的牌
	   if self.bNextWarn and self.cbUpCardCount == 1 then  --否则,下家就剩一张牌,而且自己出的牌就一张的话,必须顶最大牌
	       local firstCard = GameLogic:GetCardLogicValue(GameLogic:GetHandMaxCard(self.cbHandCardData,self.cbHandCardCount))  --找下自己出的牌和自己最大的牌是不是一样
	       local secondCard = GameLogic:GetCardLogicValue(self.cbUpCardData[1])
	       return firstCard == secondCard  
	   end
	   return ret
	end
	return false
end

--所有牌放下去
function CardLayer:hideUpCardAction()
    local HandCardVector = self.hardCardNode:getChildren()  --先将所有的牌全部放下
    for i=1,#HandCardVector do
       local pCardSprite = HandCardVector[i]
       if pCardSprite.bUp then
           local nPosY = pCardSprite:getPositionY()-self.shootHight
           pCardSprite.bUp = false
           pCardSprite:setPosition(cc.p(pCardSprite:getPositionX(),nPosY))
       end
    end
    self:resetTiCardData();
    self:resetUpCardData();

end

--提示牌上升
function CardLayer:setUpCardAction()
	local HandCardVector = self.hardCardNode:getChildren()  --先将所有的牌全部放下
	for i=1,#HandCardVector do
	   local pCardSprite = HandCardVector[i]
	   if pCardSprite.bUp then
	       local nPosY = pCardSprite:getPositionY()-self.shootHight
	       pCardSprite.bUp = false
	       pCardSprite:setPosition(cc.p(pCardSprite:getPositionX(),nPosY))
	   end
	end
	
	--将有提示的牌设置到上面去
	for i=1,self.cbTiCardCount do
	   local pCardSprite = self:getHandCardSprite(self.cbTiCardData[i])
       if pCardSprite then
            local nPosY = pCardSprite:getPositionY() + self.shootHight
            pCardSprite.bUp = true
            local action = cc.MoveTo:create(0.1,cc.p(pCardSprite:getPositionX(),nPosY))
            pCardSprite:runAction(action)
            pCardSprite.color = cc.c3b(255,255,255)
	   end
	end
end

function CardLayer:getHandCardSprite(cbCard)
	local HandCardVector = self.hardCardNode:getChildren()
	for i=1,#HandCardVector do
	   local pCardSprite = HandCardVector[i]
        if not pCardSprite.bUp and pCardSprite.cbCard == cbCard then
	       return pCardSprite
	   end
	end
	return nil
end

--在自己的牌组中删除传过来的牌
function CardLayer:removeCardData(cbCard,nCount)
    if count == nil then
        luaPrint('removeCardData count is nil :',nCount);
    end

    local ret = GameLogic:RemoveCard(cbCard,nCount,self.cbHandCardData,self.cbHandCardCount)
    if ret then
        self.cbHandCardCount = self.cbHandCardCount - nCount  --更新下牌数
        GameLogic:SortCardList(self.cbHandCardData,self.cbHandCardCount,0)  --排序下牌
    end
    return ret
end

--设置提示的牌数据
function CardLayer:setTiCardData(cardData,cardCount)
    self.cbTiCardData = {}
    self.cbTiCardCount = cardCount
    for i=1,cardCount do
        self.cbTiCardData[i] = cardData[i]
    end
end

function CardLayer:resetTiCardData()
    self.cbTiCardData = {}
    self.cbTiCardCount = 0
end

function CardLayer:getShootCardCount(cbCard)
    local nCount = 0
    local HandCardVector = self.hardCardNode:getChildren()
    for i=1,#HandCardVector do
        local pCardSprite = HandCardVector[i]
        if pCardSprite.bUp then
            nCount = nCount + 1
            cbCard[nCount] = pCardSprite.cbCard
        end
    end
    return nCount
end

function CardLayer:removeOutCard(viewSeatNo)
    if viewSeatNo == 0 then  --自己
        self.pCardNodeM:removeAllChildren()  --自己
    elseif viewSeatNo == 1 then  --右边
        self.pCardNodeR:removeAllChildren()  --右上的出牌节点
    elseif viewSeatNo == 2 then  --左边
        self.pCardNodeL:removeAllChildren()
    end 
end

function CardLayer:removeAllOutCard()
     self.pCardNodeM:removeAllChildren()  --自己
     self.pCardNodeR:removeAllChildren()  --右上的出牌节点
     self.pCardNodeL:removeAllChildren()
end

function CardLayer:setEndCardData(wChair,cbCard,nCount)
	local width = 0
	local widthInterval = self.interval * 0.5
	local nTallWidth = (nCount - 1) * widthInterval
	local winSize = cc.Director:getInstance():getWinSize()
	
	for i=1,nCount do
        luaPrint(cbCard[i])
	   local pCardSprite = self:getCardSprite(cbCard[i])
	   pCardSprite:setScale(0.8)
	   local pt = self:getOutCardPos(wChair)
	   if wChair == 2 then
	       pt.x = pt.x - nTallWidth / 2 + (i-1) * widthInterval
	       pt.y = pt.y
	       pCardSprite:setPosition(pt)
	       self.pCardNodeR:addChild(pCardSprite)
	   elseif wChair == 1 then
	       pt.x = pt.x - nTallWidth / 2 + (i-1) * widthInterval
	       pt.y = pt.y
	       pCardSprite:setPosition(pt)
	       self.pCardNodeL:addChild(pCardSprite)
	   end
	end
end

function CardLayer:setTouchEndedCard()
	local HandCardVector = self.hardCardNode:getChildren()
	for i=1,#HandCardVector do
	   local pCardSprite = HandCardVector[i]
	   if pCardSprite.bUp then
	       self.cbUpCardCount = self.cbUpCardCount + 1
	       self.cbUpCardData[self.cbUpCardCount] = pCardSprite.cbCard
	   end
    end
    self.tableLayer:CheckHandCard();
end

function CardLayer:getUpCardData()
    return self.cbUpCardData;
end

function CardLayer:setUpCardData(cardData)
    self.cbUpCardData = {};
    self.cbUpCardData = cardData;
    self.cbUpCardCount = #cardData;
end

function CardLayer:resetUpCardData()
    self.cbUpCardData = {};
    self.cbUpCardCount = 0
end

function CardLayer:setCardScene(scene)
	self.cardScene = scene
end

function CardLayer:initGame()
    self.pCardNodeR:removeAllChildren()
    self.pCardNodeL:removeAllChildren()
    self.pCardNodeM:removeAllChildren()
    luaPrint("删除自己的出牌点4")
    self.hardCardNode:removeAllChildren()
    self.cbHandCardData = {}
    self.cbHandCardCount = 0

    self.cbUpCardData = {}
    self.cbUpCardCount = 0
    self.cbTurnCardData = {}
    self.cbTurnCardCount = 0  
    self.cbTiCardData = {}
    self.cbTiCardCount = 0
    self.cbTempHandCardData = {}
    self.cbTempHandCardCount = 0
    
    --下家只剩单张为false
    self.bNextWarn = false
end

return CardLayer