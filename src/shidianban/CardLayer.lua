local CardLayer = class("CardLayer", function() return cc.Layer:create() end);

local CardSprite = require("shidianban.CardSprite");
local GameLogic = require("shidianban.GameLogic");

--根据视图位置设置牌的位置
function CardLayer:create(viewSeat)
    local layer=CardLayer.new(viewSeat);

    layer.viewSeat = viewSeat;
    layer.cbCardData = {};

    return layer;
end
--清除牌的数据
function CardLayer:ClearCardLayer()
    self.cbCardData = {};
    self:removeAllChildren();
end

--获取视图位置
function CardLayer:GetViewSeat()
    return self.viewSeat;
end

--添加牌的数据
function CardLayer:AddCardData(cardData)
    table.insert(self.cbCardData,cardData);
    -- self:DrawCard();
end
--设置牌的数据
function CardLayer:SetCardData(cardData)
    self.cbCardData = cardData;
    self:DrawCard();
end
--设置第一张牌的数据
function CardLayer:SetFirstCard(cardData)
    if self.cbCardData[1] == nil then
        return;
    end

    if self.cbCardData[1] > 0 then
        return;
    end

    self.cbCardData[1] = cardData;

    self:DrawCard();
end
--获取牌的数据
function CardLayer:GetCardData()
    return self.cbCardData;
end
--绘制牌
function CardLayer:DrawCard()
    -- self:removeAllChildren();

    for i=1,5 do
        local cardSp = self:getChildByTag(100+i);
        if cardSp then
            cardSp:removeFromParent();
        end
    end

    for index,cardData in pairs(self.cbCardData) do
        local cardSp = CardSprite:create(cardData);
        self:addChild(cardSp);
        cardSp:setScale(0.8);
        cardSp:setAnchorPoint(0,0);
        cardSp:setTag(100+index);
        if self.viewSeat == 1 or self.viewSeat == 2 then
            cardSp:setPosition(30*(index-#self.cbCardData),0);
        else
            cardSp:setPosition(30*(index-1),0);
        end
    end

end
--显示牌的数值
function CardLayer:ShowCardSum(isEnd)
    if isEnd == nil then
        isEnd = false;
    end

    local cardContentWidth = 0;
    local cardSp = CardSprite:create(0);
    cardSp:setScale(0.8);
    cardContentWidth = cardSp:getBoundingBox().width;

    local cardVaule,cardType = GameLogic:GetCardType(self.cbCardData);
    luaPrint("显示牌的数值",cardVaule,cardType,isEnd)

    if cardType == GameLogic.Error and isEnd == false then--游戏没结束爆牌显示
        local cardNum = self:getChildByName("cardNum");
        if cardNum then
            cardNum:removeFromParent();
        end

        local skeleton_animation = createSkeletonAnimation("sdb_shidianbantexiao","shidianban/effect/shidianbantexiao.json","shidianban/effect/shidianbantexiao.atlas");
        if skeleton_animation then
            self:addChild(skeleton_animation,10);
            if self.viewSeat == 1 or self.viewSeat == 2 then
                skeleton_animation:setPosition((-30*(#self.cbCardData-1)+cardContentWidth)/2,10);
            else 
                skeleton_animation:setPosition((30*(#self.cbCardData-1)+cardContentWidth)/2,10);
            end
            luaDump(cc.p(skeleton_animation:getPosition()),"位置-------------");

            skeleton_animation:setAnimation(0,"baopai", false);
            skeleton_animation:setName("cardNum");
        end

    elseif cardVaule>0 and cardVaule<=10.5 then
        local cardNum = self:getChildByName("cardNum");
        if cardNum then
            cardNum:removeFromParent();
        end
        local skeleton_animation = createSkeletonAnimation("sdb_shidianbantexiao","shidianban/effect/shidianbantexiao.json","shidianban/effect/shidianbantexiao.atlas");
        if skeleton_animation then
            self:addChild(skeleton_animation,10);
            if self.viewSeat == 1 or self.viewSeat == 2 then
                skeleton_animation:setPosition((-30*(#self.cbCardData-1)+cardContentWidth)/2,10);
            else 
                skeleton_animation:setPosition((30*(#self.cbCardData-1)+cardContentWidth)/2,10);
            end
            skeleton_animation:setName("cardNum");
        end

        local animName = "";


        if cardType == GameLogic.TianWang then
            animName = "tianwang";
        elseif cardType == GameLogic.RenWuXiao then
            animName = "renwuxiao";
        elseif cardType == GameLogic.WuXiao then
            animName = "wuxiao";
        else
            if cardVaule > math.floor(cardVaule) then
                animName = math.floor(cardVaule).."dianban";
            else
                animName = math.floor(cardVaule).."dian";
            end
        end

        if animName ~= "" and skeleton_animation then
            skeleton_animation:setAnimation(0,animName, false);
        end

    end

    -- if cardVaule>0 and cardVaule<=10.5 then
    --     -- local cardNum = FontConfig.createWithSystemFont(cardVaule,25,FontConfig.colorBlack);
    --     -- cardNum:setName("cardNum");
    --     -- cardNum:setAnchorPoint(0.5,0);
    --     -- if self.viewSeat == 1 then
    --     --     cardNum:setPosition((-30*(#self.cbCardData-1)+cardContentWidth)/2,0);
    --     -- else 
    --     --     cardNum:setPosition((30*(#self.cbCardData-1)+cardContentWidth)/2,0);
    --     -- end
    --     -- self:addChild(cardNum,10);

        

    -- elseif cardVaule>10.5 and isEnd == false then--游戏没结束爆牌显示
    --     local cardNum = FontConfig.createWithSystemFont(cardVaule,25,FontConfig.colorBlack);
    --     cardNum:setName("cardNum");
    --     cardNum:setAnchorPoint(0.5,0);
    --     cardNum:setPosition((30*(#self.cbCardData-1)+cardContentWidth)/2,0);
    --     self:addChild(cardNum,10);
    -- end
end
--清除牌提示
function CardLayer:ClearCardSum()
    local cardNum = self:getChildByName("cardNum");
    if cardNum then
        cardNum:removeFromParent();
    end
end

--获取最后张牌的位置
function CardLayer:GetLastCardPos()
    return cc.p(30*(#self.cbCardData),0);
end

return CardLayer