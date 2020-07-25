local TableLogic = require("superfruitgame.TableLogic");
local SmallGameLayer =  class("FruitTurntable",function()
    return cc.Layer:create();
end);

local FruitPngName = {
    [1] = {"sf_smallgame_yingtaotong.png","sf_smallgame_yingtaotong-on.png","sf_smallgame_yingtaotong2.png"},
    [2] = {"sf_smallgame_putaotong.png","sf_smallgame_putaotong-on.png","sf_smallgame_putaotong2.png"},
    [3] = {"sf_smallgame_pingguotong.png","sf_smallgame_pingguotong-on.png","sf_smallgame_pingguotong2.png"},
    [4] = {"sf_smallgame_ningmengtong.png","sf_smallgame_ningmengtong-on.png","sf_smallgame_ningmengtong2.png"},
};
local BombPngName = {"sf_smallgame_zhadantong.png","sf_smallgame_zhadantong2.png","sf_smallgame_zhadantong2.png"};

--创建类
function SmallGameLayer:create()
	local gameLayer = SmallGameLayer:new();
    gameLayer:init();
    return gameLayer;
end

--构造函数
function SmallGameLayer:ctor()	
	display.loadSpriteFrames("superfruitgame/superfruitsmallgame.plist","superfruitgame/superfruitsmallgame.png");

	local uiTable = {
        --最外层元素
		Image_bg = "Image_bg",
		Node_game = "Node_game",
        Panel_gameOver = "Panel_gameOver",
        AtlasLabel_awardPoint = "AtlasLabel_awardPoint",
        AtlasLabel_nowPoint = "AtlasLabel_nowPoint",
	}

	loadNewCsb(self,"superfruitgame/SmallGameLayer",uiTable);
end

function SmallGameLayer:init()	
    self:initUi();
end

function SmallGameLayer:initUi()
    if self.Panel_gameOver then
        self.Panel_gameOver:setVisible(false);
        self.Panel_gameOver:setLocalZOrder(20);
    end

    if self.AtlasLabel_nowPoint then
        self.AtlasLabel_nowPoint.nPoint = 0;
        self:ScoreToMoney(self.AtlasLabel_nowPoint,0);
    end

    self._tbFruitLineNode = {};
    for i = 1, 4 do
        local fruitLineNode = self:createFruitLine(i);
        fruitLineNode:setPosition(cc.p(280,105+128*(i-1)));
        self.Node_game:addChild(fruitLineNode,i);

        self._tbFruitLineNode[i] = fruitLineNode;
    end
    
    self:setNowSelectLine(1);
end

function SmallGameLayer:createFruitLine(lineIndex)
    local fruitLineNode = cc.Node:create();
    local tbPngName = FruitPngName[lineIndex];
    for i = 1, 5 do
        local fruitBtn = ccui.Button:create();
        fruitBtn:loadTextures(tbPngName[1],tbPngName[2],tbPngName[3],UI_TEX_TYPE_PLIST);
        fruitBtn:setTag(lineIndex*10+i);
        fruitBtn:setAnchorPoint(cc.p(0.5,0));
        fruitBtn:setPosition(cc.p((i-1/2)*160,0));
        fruitBtn:setEnabled(false);
        fruitBtn:addClickEventListener(function(sender)
            TableLogic:sendSmallGameSelect(lineIndex,i);
        end);
        fruitLineNode:addChild(fruitBtn);

        local textPoint = ccui.TextAtlas:create("0", "number/zitiaoSmallGame.png", 18, 33, "+");
        local fruitBtnSize = fruitBtn:getContentSize();
        textPoint:setPosition(cc.p(fruitBtnSize.width/2,8));
        textPoint:setName("textPoint");
        textPoint:setVisible(false);
        fruitBtn:addChild(textPoint);
    end   
    
    return fruitLineNode; 
end

--设置当前需要选择的行
function SmallGameLayer:setNowSelectLine(lineIndex)
    local fruitLineNode = self._tbFruitLineNode[lineIndex];
    if not fruitLineNode then
        return;
    end

    for i = 1, 5 do
        local fruitBtn = fruitLineNode:getChildByTag(lineIndex*10+i);
        if fruitBtn then
            fruitBtn:setEnabled(true);
        end
    end
end

function SmallGameLayer:setAlreadySelectData(lineIndex,awardData)
    local fruitLineNode = self._tbFruitLineNode[lineIndex];
    if not fruitLineNode then
        return;
    end

    local selectPos = awardData.nPos;
    local selectPosPoint = awardData.nReward;--0代表炸弹
    local otherPoint = awardData.tbOtherReward;

    local otherIndex = 1;
    for i = 1, 5 do
        local fruitBtn = fruitLineNode:getChildByTag(lineIndex*10+i);
        local textPoint = fruitBtn:getChildByName("textPoint");
        if i == selectPos then
            --选择的是炸弹
            if selectPosPoint <= 0 then
                fruitBtn:loadTextures(BombPngName[1],BombPngName[2],BombPngName[3],UI_TEX_TYPE_PLIST);
                audio.playSound("superfruitgame/voice/smallGameBomb.mp3");
            end
            fruitBtn:setEnabled(true);
            fruitBtn:setTouchEnabled(false);
            --非炸弹时显示奖励分
            if selectPosPoint > 0 then
                textPoint:setColor(cc.c3b(255,255,255));
                self:ScoreToMoney(textPoint,selectPosPoint);
                textPoint:setVisible(true);
                audio.playSound("superfruitgame/voice/smallGameAward.mp3");
            end
            
        else
            local point = otherPoint[otherIndex] or 0;
            --是炸弹
            if point <= 0 then
                fruitBtn:loadTextures(BombPngName[1],BombPngName[2],BombPngName[3],UI_TEX_TYPE_PLIST);
            end
            fruitBtn:setEnabled(false);
            --非炸弹时显示奖励分
            if point > 0 then
                textPoint:setColor(cc.c3b(75,75,75));
                self:ScoreToMoney(textPoint,point);
                textPoint:setVisible(true);
            end

            otherIndex = otherIndex + 1;
        end
    end

    local nowPoint = 0;
    --设置当前奖励分
    if self.AtlasLabel_nowPoint then
        nowPoint = self.AtlasLabel_nowPoint.nPoint or 0;
        nowPoint = nowPoint + selectPosPoint;
        self.AtlasLabel_nowPoint.nPoint = nowPoint;
        self:ScoreToMoney(self.AtlasLabel_nowPoint,nowPoint);
    end
end

function SmallGameLayer:playGameOver(nPoint,gameOverCallBack)
    if self.Panel_gameOver then
        local size = self.Panel_gameOver:getContentSize();
        local gameoverAction = createSkeletonAnimation("gameover","effects/gameover.json","effects/gameover.atlas");
		if gameoverAction then
			gameoverAction:setPosition(size.width/2+30,size.height/2);
			gameoverAction:setAnimation(1,"gameover", false);
			self.Panel_gameOver:addChild(gameoverAction);
		end

        self.Panel_gameOver:setVisible(true);
    end
    local aniDelay = 1;
    local action1 = cc.DelayTime:create(aniDelay);
    local action2 = cc.CallFunc:create(function()
        if self.AtlasLabel_awardPoint then
            self.AtlasLabel_awardPoint:setLocalZOrder(2);
            self:ScoreToMoney(self.AtlasLabel_awardPoint,nPoint,"+");
        end
    end);
    local action3 = cc.DelayTime:create(3-aniDelay);
    local action4 = cc.CallFunc:create(function()
        self:removeFromParent();
        if gameOverCallBack ~= nil then
            gameOverCallBack();
        end
    end);
    local sequence = cc.Sequence:create(action1, action2,action3, action4)
    self:runAction(sequence);
end

--玩家分数
function SmallGameLayer:ScoreToMoney(pNode,score,string)
	if string == nil then
		string = "";
	end

	local remainderNum = score%100;
	local remainderString = "";

	if remainderNum == 0 then--保留2位小数
		remainderString = remainderString..".00";
	else
		if remainderNum%10 == 0 then
			remainderString = remainderString.."0";
		end
	end
	if pNode == nil then
		return string..(score/100)..remainderString;
	end
	pNode:setString(string..(score/100)..remainderString);
end

return SmallGameLayer;