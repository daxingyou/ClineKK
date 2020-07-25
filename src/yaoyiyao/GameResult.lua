local GameResult =  class("GameResult", PopLayer)

function GameResult:createLayer(resultMsg)
    local layer = GameResult.new(resultMsg);

    layer:setName("GameResult");

    return layer;
end

function GameResult:ctor(resultMsg)
    self.super.ctor(self,PopType.none)

    self:InitLayer(resultMsg);
end

function GameResult:InitLayer(resultMsg)
    self:removeAllChildren();

    local rootNode = cc.CSLoader:createNode("yaoyiyao/GameResult.csb");
    if rootNode == nil then
        return nil;
    end
    self.xBg = rootNode
    self:addChild(rootNode,1);

    self.ImageBg = rootNode:getChildByName("Node_resultInfo");
    local Text_userScore = self.ImageBg:getChildByName("Text_userScore");
    Text_userScore:setLocalZOrder(10);
    local Text_bankScore = self.ImageBg:getChildByName("Text_bankScore");
    Text_bankScore:setLocalZOrder(10);
    local Text_userBackScore = self.ImageBg:getChildByName("Text_userBackScore");
    Text_userBackScore:setLocalZOrder(10);
    local Text_bankBackScore = self.ImageBg:getChildByName("Text_bankBackScore");
    Text_bankBackScore:setLocalZOrder(10);

    local ziSpine = createSkeletonAnimation("benlunjiesuan","effect/benlunjiesuan.json","effect/benlunjiesuan.atlas");
    if ziSpine then
        ziSpine:setPosition(640,360);
        ziSpine:setAnimation(1,"benlunjiesuan", false);
        self.ImageBg:addChild(ziSpine);
    end
    --结果动画
    --设置结算结果
    local userScore = resultMsg.iUserScore;
    if userScore>=0 then
        userScore = userScore + resultMsg.iUserReturnTotle;
    end

    self:ScoreToMoney(Text_userScore,userScore);
    self:ScoreToMoney(Text_bankScore,resultMsg.iNTScore);
    self:ScoreToMoney(Text_userBackScore,resultMsg.iUserReturnTotle);
    self:ScoreToMoney(Text_bankBackScore,0);
   
end

function GameResult:ScoreToMoney(pNode,score,string)
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

    pNode:setString(string..(score/100)..remainderString);
end

function GameResult:DestoryLayer()
    self:removeFromParent();
end

return GameResult