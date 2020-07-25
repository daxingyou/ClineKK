local SmallGameTurntable = require("shuihuzhuan.SmallGameTurntable");
--创建结算场景
local SmallGameLayer = class("SmallGameLayer", function()
    return cc.Layer:create();
end)

SmallGameLayer.Image_di = {}; --底层背景
SmallGameLayer._turnTableResult ={} --转盘获得的转动结果

SmallGameLayer.RESULT_TYPE = {
    ZHONGYITANG = 1,--忠义堂
    TITIANXINGDAO = 2,--替天行道
    SONG = 3,--宋江
    LIN = 4,--林冲
    LU = 5,--鲁智深
    DAO = 6,--刀
    QIANG = 7,--枪
    FU = 8,--斧
    EXIT = 9,--退出
};

SmallGameLayer.RESULT_TYPE_AWARD = {
    [SmallGameLayer.RESULT_TYPE.ZHONGYITANG] = 200,--忠义堂
    [SmallGameLayer.RESULT_TYPE.TITIANXINGDAO] = 100,--替天行道
    [SmallGameLayer.RESULT_TYPE.SONG] = 70,--宋江
    [SmallGameLayer.RESULT_TYPE.LIN] = 50,--林冲
    [SmallGameLayer.RESULT_TYPE.LU] = 20,--鲁智深
    [SmallGameLayer.RESULT_TYPE.DAO] = 10,--刀
    [SmallGameLayer.RESULT_TYPE.QIANG] = 5,--枪
    [SmallGameLayer.RESULT_TYPE.FU] = 2,--斧
    [SmallGameLayer.RESULT_TYPE.EXIT] = 0,--退出
};
--创建场景
function SmallGameLayer:create(tableLogic,smallGameData)
    local gameLayer = SmallGameLayer.new();
    gameLayer:init(tableLogic,smallGameData);   
    return gameLayer;
end

--构造函数
function SmallGameLayer:ctor()	
	display.loadSpriteFrames("shuihuzhuan/image/SuperMary/SuperMary.plist","shuihuzhuan/image/SuperMary/SuperMary.png");

	local uiTable = {
        --最外层元素
		Image_bg = "Image_bg",
		Node_kuang = "Node_kuang",
        Node_2 = "Node_2",
        Node_turntable = "Image_turntable",
        Text_score = "Text_score",
        Text_yafen = "Text_yafen",
        Text_yingfen = "Text_yingfen",
        Text_time = "Text_time",

        --Node_kuang中的元素
        Img_check_1 = "Image_kuang_1",
        Img_check_2 = "Image_kuang_2",
        Img_check_3 = "Image_kuang_3",
        Img_check_4 = "Image_kuang_4",
        Img_check_5 = "Image_kuang_5",
        Img_check_6 = "Image_kuang_6",
        Img_check_7 = "Image_kuang_7",
        Img_check_8 = "Image_kuang_8",
        Img_check_9 = "Image_kuang_9",
        Img_check_10 = "Image_kuang_10",
        Img_check_11 = "Image_kuang_11",
        Img_check_12 = "Image_kuang_12",
        Img_check_13 = "Image_kuang_13",
        Img_check_14 = "Image_kuang_14",
        Img_check_15 = "Image_kuang_15",
        Img_check_16 = "Image_kuang_16",
        Img_check_17 = "Image_kuang_17",
        Img_check_18 = "Image_kuang_18",
        Img_check_19 = "Image_kuang_19",
        Img_check_20 = "Image_kuang_20",
        Img_check_21 = "Image_kuang_21",
        Img_check_22 = "Image_kuang_22",
        Img_check_23 = "Image_kuang_23",
        Img_check_24 = "Image_kuang_24",
	}

	loadNewCsb(self,"shuihuzhuan/SmallMary",uiTable);

    local function onNodeEvent(eventName)
		if "enterTransitionFinish" == eventName then
			self:onEnterTransitionFinish()
		end
	end
    self.Image_bg:setTouchEnabled(true);
	self:registerScriptHandler(onNodeEvent)
end

function SmallGameLayer:init(tableLogic,smallGameData)
    self.tableLogic = tableLogic;
    self._tbGameData = smallGameData.tbGameData;
    self._nSmallCount = smallGameData.nSmallCount;
    self._nBetPoint = smallGameData.nBetPoint;
    self._nSmallBeishu = smallGameData.nBeiShu;

    self:initData();
    self:initUI();
end

function SmallGameLayer:initUI()
    for i=1,24 do
       self.Image_di[i] = self["Img_check_"..i];
       self.Image_di[i]:setVisible(false);
    end
    local node_check = self.Image_bg:getChildByName("Node_2");
    for i=1,24 do
    	local img_check = node_check:getChildByName("Image_check_"..i);
        if img_check then
            table.insert(self.checkCarTable,img_check)
        end
    end

    for i = 1, 4 do
        local singleTurntable = SmallGameTurntable:create(i);
        singleTurntable:setPosition(202+(i-1)*198,85);
        self.tbTurntableNode[#self.tbTurntableNode+1] = singleTurntable;
        self.Node_turntable:addChild(singleTurntable);
    end

    self:updateLeftNumber();--刷新剩余次数
    self:updateSelfPlayerMoney();
    self:updateWinPoint();
    self:updateBetPoint();--压分
end

function SmallGameLayer:initData()
    self.tbTurntableNode = {};--保存转盘，一共4个
    self.checkCarTable = {}; --所有选择的图标  
    self.checkCarTablePos = {};
    self.Image_di = {}; --底层背景

    self._startPos = 1;

    self._nLeftGameNumber = 0;--剩余次数
    self._nGameIndex = 0;--第几次
    self._nTurnIndex = 0;--第几轮

    self._nWinPoint = 0;
end

function SmallGameLayer:onEnterTransitionFinish()
    performWithDelay(self,function() 
        self:autoStart();
    end,1);
    
end

--断线重连回来
function SmallGameLayer:onConnectGame(nGameIndex,nTurnIndex,nWinPoint)
    --0表示还没有转过
    if nGameIndex ~= 0 then
        self._nGameIndex = nGameIndex;
        self._nTurnIndex = nTurnIndex+1;
        local thisTimeGameData = self._tbGameData[self._nGameIndex];
        local nResultIndex = thisTimeGameData.tbResultKind[self._nTurnIndex];
        self._startPos = nResultIndex + 1;
    end

    self:updateLeftNumber();--刷新剩余次数
    self:updateBetPoint();--压分

    self:setWinPoint(nWinPoint);
end

function SmallGameLayer:updateLeftNumber()
    local leftNum = self._nSmallCount - self._nGameIndex;
    if leftNum < 0 then
        leftNum = 0;
    end
    self.Text_time:setString(tostring(leftNum));
end

function SmallGameLayer:updateBetPoint()
    self.Text_yafen:setString(tostring(self._nBetPoint));
end

function SmallGameLayer:autoStart()
    if self._nGameIndex == 0 then
        self._nGameIndex = self._nGameIndex + 1;
        self._nTurnIndex = 0;
    elseif self._nResultKind == self.RESULT_TYPE.EXIT then
        --转到EXIT，进入下一次
        self._nGameIndex = self._nGameIndex + 1;
        self._nTurnIndex = 0;
    end
    --次数用完，退出小游戏
    if self._nGameIndex > self._nSmallCount then
        return;
    end

    self:updateLeftNumber();--刷新剩余次数

    if table.nums(self._tbGameData) <= 0 or not self._tbGameData[self._nGameIndex] then
        return;
    end

    local thisTimeGameData = self._tbGameData[self._nGameIndex];
    luaDump(thisTimeGameData,"thisTimeGameData");
    --当次总轮数
    if thisTimeGameData.nMaryCount <= 0 or self._nTurnIndex > thisTimeGameData.nMaryCount then
        return;
    end

    self._nTurnIndex = self._nTurnIndex + 1;

    local nResultIndex = thisTimeGameData.tbResultKind[self._nTurnIndex];
    local nResultType = thisTimeGameData.tbResultType[self._nTurnIndex];
    local tbShowKind = thisTimeGameData.tbShowKind[self._nTurnIndex];
    
    local callBackFunc = function()
        self:sendCaiJin(tbShowKind);
        self:startRunRound(nResultIndex+1,nResultType);
    end
    
    for i = 1, 4 do
        local singleTurntable = self.tbTurntableNode[i];
        if singleTurntable and tbShowKind[i] then
            singleTurntable:start(tbShowKind[i],callBackFunc);   
        end
    end  
end

-- 游戏开始转
function SmallGameLayer:startRunRound(iEndPos,nResultKind)
    if iEndPos < 1 or iEndPos > 24 then
        luaPrint("转圈的起始位置或者结束位置出错", iEndPos)
        return;
    end

    self._endPos = iEndPos;
    self._turnCount = 0;
    self._count = self._startPos;
    self.startCount = 0;
    self.isRoundFlag =1;
    self._nResultKind = nResultKind;

    if self._startPos >= self._endPos then
        self.zongCount =24*3+ self._endPos -self._startPos;
        self.MaxTurnCount = 3;
    else
        self.zongCount =24*2+ self._endPos -self._startPos;
        self.MaxTurnCount = 2;
    end

    self:turnRound();

    self._startPos = self._endPos;--当前的结束位置即为下次的开始位置
end

function SmallGameLayer:turnRound()
    local dTime = 0.03;
    if self._count > 24 then
        self._count = 1;
        self._turnCount = self._turnCount + 1;
    end

    self.startCount =self.startCount + 1;
    if self.startCount <= 5 then
        dTime = (102 - 20 *self.startCount)/100
    end
    if self.zongCount-self.startCount<= 5 then
        dTime = (102 - 20 *(self.zongCount-self.startCount))/100
    end
    if (self._turnCount == self.MaxTurnCount and self._count > self._endPos) or (self._turnCount == self.MaxTurnCount +1)then
        self:showResult();
        return;
    end

    self.Image_di[1]:runAction(cc.Sequence:create(
        cc.CallFunc:create(function() 
            if self._count > 1 then
                self.Image_di[self._count-1]:setVisible(false);
            else
                self.Image_di[24]:setVisible(false);
            end

            --播放音效
            if self.startCount <= 5 or (self.zongCount-self.startCount<= 5) then
                audio.playSound("shuihuzhuan/voice/sound-car-turn.mp3");    
            else
                if self.isRoundFlag == 1 then
                    audio.playSound("shuihuzhuan/voice/sound-car-turn.mp3");    
                    self.isRoundFlag = 2
                elseif self.isRoundFlag == 2 then
                    self.isRoundFlag = 3
                else
                    self.isRoundFlag = 1
                end
            end

            self.Image_di[self._count]:setVisible(true);
            self._count = self._count + 1;
        end),
        cc.DelayTime:create(dTime), 
        cc.CallFunc:create(function() self:turnRound(); end)
    ))
end

function SmallGameLayer:showResult()
    self.Node_2:runAction(cc.Sequence:create(
        cc.CallFunc:create(function() 
            local thisTimeGameData = self._tbGameData[self._nGameIndex];
            local tbShowKind = thisTimeGameData.tbShowKind[self._nTurnIndex]; 
            for i = 1, 4 do
                local singleTurntable = self.tbTurntableNode[i];
                if singleTurntable and tbShowKind[i] == self._nResultKind then
                    singleTurntable:showEffect();   
                end
            end 
            self:sendAward(self._nResultKind);

            self.tableLogic.sendSmallGameSelect(self._nGameIndex,self._nTurnIndex);
        end),
        cc.DelayTime:create(2), 
        cc.CallFunc:create(function() 
            self:autoStart(); 
        end)
    ));
end

function SmallGameLayer:sendCaiJin(tbShowKind)
    local sameTypeTotalLeft = 0;
    local firstTypeLeft = -1;
    for i = 1, 4 do
        if i == 1 then
            firstTypeLeft = tbShowKind[i];
        elseif firstTypeLeft ~= tbShowKind[i] then
            break;
        end
        sameTypeTotalLeft = sameTypeTotalLeft + 1;
    end 

    local sameTypeTotalRight = 0;
    local firstTypeRight = -1;
    for i = 4, 1, -1 do
        if i == 4 then
            firstTypeRight = tbShowKind[i];
        elseif firstTypeRight ~= tbShowKind[i] then
            break;
        end
        sameTypeTotalRight = sameTypeTotalRight + 1;
    end 

    if sameTypeTotalLeft < 3 and sameTypeTotalRight < 3 then
        return;
    end

    local totalAward  = 0;
    if sameTypeTotalLeft == 4 or sameTypeTotalRight == 4 then
        totalAward = 100;
    elseif sameTypeTotalLeft == 3 or sameTypeTotalRight == 3 then
        totalAward = 20;
    end

    if totalAward > 0 then
        local awardPoint = self._nBetPoint*totalAward*self._nSmallBeishu;
        self:playAwardAnimate(awardPoint);
        self:addWinPoint(awardPoint);
    end
end

function SmallGameLayer:playAwardAnimate(awardPoint)
    if awardPoint <= 0 then
        return;
    end
    audio.playSound("shuihuzhuan/voice/sound_jinbi.mp3");
    local size = self.Image_bg:getContentSize();
    --显示特效
    local particle = cc.ParticleSystemQuad:create("effects/jinbilizi.plist")
    if particle then
        particle:setPosition(size.width/2,size.height/2);
        self.Image_bg:addChild(particle);
        performWithDelay(self,function() 
            if particle then
                particle:removeFromParent();
            end
        end,2);
    end

    local textPoint = ccui.TextAtlas:create("+"..tostring(awardPoint), "image/number_res/shz_huojiangzitiao.png", 79, 128, "+");
    textPoint:setPosition(cc.p(0,-60));
    particle:addChild(textPoint);
end

function SmallGameLayer:sendAward(nResultKind)
    local totalAward  = 0;
    if self.RESULT_TYPE_AWARD[nResultKind] then
        totalAward = self.RESULT_TYPE_AWARD[nResultKind];
    end

    if totalAward > 0 then
        local awardPoint = self._nBetPoint*totalAward*self._nSmallBeishu;
        self:playAwardAnimate(awardPoint);

        self:addWinPoint(awardPoint);
    end
end

function SmallGameLayer:addWinPoint(nPoint)
    self._nWinPoint = self._nWinPoint + nPoint;
    self:updateWinPoint();
end

function SmallGameLayer:setWinPoint(nPoint)
    self._nWinPoint = nPoint;
    self:updateWinPoint();
end

function SmallGameLayer:updateWinPoint()
    if not self.Text_yingfen then
        return;
    end
    self.Text_yingfen:setString(tostring(self._nWinPoint));
end

function SmallGameLayer:updateSelfPlayerMoney()
    local mySeatNo = self.tableLogic:getMySeatNo();
    local userInfo = self.tableLogic:getUserBySeatNo(mySeatNo);
	if userInfo then
		self:ScoreToMoney(self.Text_score,userInfo.i64Money);
    end
end

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

function SmallGameLayer:playGameOver(gameOverCallBack)
    --停止所有动画特效
        for i = 1, 4 do
            local singleTurntable = self.tbTurntableNode[i];
            if singleTurntable then
                singleTurntable:stopEffect();   
            end
        end
    local action1 = cc.DelayTime:create(1);
    local action2 = cc.CallFunc:create(function()
        self:removeFromParent();
        if gameOverCallBack ~= nil then
            gameOverCallBack();
        end
    end);
    local sequence = cc.Sequence:create(action1,action2)
    self:runAction(sequence);
end

return SmallGameLayer;