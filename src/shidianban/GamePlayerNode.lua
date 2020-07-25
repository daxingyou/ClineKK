local GamePlayerNode = class("GamePlayerNode", function() return display.newNode(); end)

--
function GamePlayerNode:ctor(viewSeat)
    local uiTable = {
        Image_player = "Image_player",
        Text_playerName = "Text_playerName",
        Text_playerMoney = "Text_playerMoney",
        Image_head = "Image_head",
        Image_progress = "Image_progress",
        Text_zhuang = "Text_zhuang",
        Image_tishi = "Image_tishi",
        Image_resultBg = "Image_resultBg",
        AtlasLabel_score = "AtlasLabel_score",
        Image_paoma = "Image_paoma",
    }

    self.viewSeat = viewSeat;

    loadNewCsb(self,"shidianban/PlayerNode",uiTable);
    self:InitUI();
    self:ClearPlayerInfo();
end

function GamePlayerNode:InitUI()
    display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
    self.Progerss_timerTb = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("sdb_daojishi.png"));
    self.Progerss_timerTb:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.Progerss_timerTb:setReverseDirection(true)
    self.Image_player:addChild(self.Progerss_timerTb)
    self.Progerss_timerTb:setPosition(self.Image_progress:getPositionX(),self.Image_progress:getPositionY())

    self.m_newTime = 0;
    if self.viewSeat == 0 then
        local delayAction = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            if self.m_newTime > 0 then
                self.m_newTime = self.m_newTime-1;
            else
                return;
            end
            luaPrint("时间------------------",self.viewSeat,self.m_newTime,self.actionFlag)
            if self.m_newTime <= 3 and self.m_newTime > 0 and self.actionFlag == false then
                audio.playSound("shidianban/sound/timeConut.mp3");
            elseif self.m_newTime > 3 and self.actionFlag then
                self.actionFlag = false;
            end
        end))
        self.Image_player:runAction(cc.RepeatForever:create(delayAction));
    end
end

--初始化玩家界面
function GamePlayerNode:ClearPlayerInfo()
    self.Text_playerName:setVisible(true);
    self.Text_playerName:setText("");
    self.Text_playerMoney:setString("");
    self.Image_head:setVisible(false);
    self.userId = GameMsg.INVALID_CHAIR;
    self.Text_zhuang:setVisible(false);
    self.playerMoney = 0;

    self:ClearPlayerGameAction();

end
--清除玩家游戏动画
function GamePlayerNode:ClearPlayerGameAction()
    self.Image_progress:setVisible(false);
    self.Image_tishi:setVisible(false);
    self.Image_tishi:setTag(0);
    self.Image_resultBg:setVisible(false);
    self.Image_resultBg:stopAllActions();
    self:HidePlayerTimer();
    self.Image_paoma:setVisible(false);
    --删除赢动画
    local winSpine = self.Image_player:getChildByName("winSpine");
    if winSpine then
        winSpine:removeFromParent();
    end
    self.actionFlag = false;--操作标志
    self.m_newTime = 0;
end

--设置玩家信息
function GamePlayerNode:SetPlayerInfo(userInfo)
    self.Text_playerName:setText(FormotGameNickName(userInfo.nickName,nickNameLen));
    self:SetPlayerMoney(userInfo.i64Money);
    self.userId = userInfo.dwUserID;
    self.Image_head:setVisible(true);
    self.Image_head:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
end
--获取玩家ID
function GamePlayerNode:GetUserId()
    return self.userId;
end
--设置玩家金币
function GamePlayerNode:SetPlayerMoney(money)
    self.playerMoney = money;
    self.Text_playerMoney:setString(self:ScoreToMoney(self.playerMoney));
end
--获取玩家金币
function GamePlayerNode:GetPlayerMoney()
    return self.playerMoney;
end

--玩家分数
function GamePlayerNode:ScoreToMoney(score)
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
    return (score/100)..remainderString;
end

--设置庄家
function GamePlayerNode:SetPlayerBank(isShow)
    self.Text_zhuang:setVisible(isShow);
end
--显示玩家倒计时
function GamePlayerNode:showPlayerTimer(allDt,leftDt)
    if leftDt == nil then
        leftDt = allDt;
    end
    luaPrint("leftDt",leftDt,allDt)
    self.Progerss_timerTb:stopAllActions()
    self.Progerss_timerTb:setVisible(true);
    local percent_begin = math.ceil(leftDt*100/allDt)
    local progress = cc.ProgressFromTo:create(leftDt,percent_begin,0)

    self.m_newTime = leftDt;
    
    self.Progerss_timerTb:runAction(progress);
end
--隐藏倒计时
function GamePlayerNode:HidePlayerTimer()
    self.Progerss_timerTb:stopAllActions()
    self.Progerss_timerTb:setVisible(false);
    self.actionFlag = false;
    self.m_newTime = 0;
end
--显示操作
function GamePlayerNode:ShowAction(actionType)
    if actionType == nil then
        self.Image_tishi:stopAllActions();
        self.Image_tishi:setVisible(false);
        self.Text_playerName:setVisible(true);
        return;
    end
    self.actionFlag = true;
    display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png");
    self.Image_tishi:stopAllActions();
    self.Image_tishi:setVisible(true);
    self.Text_playerName:setVisible(false);
    if actionType == 1 then--叫牌
        self.Image_tishi:loadTexture("sdb_jiaopai-liang.png",UI_TEX_TYPE_PLIST);
        self.Image_tishi:setTag(1);
    elseif actionType == 2 then--停牌
        self.Image_tishi:loadTexture("sdb_tingjiao-liang.png",UI_TEX_TYPE_PLIST);
        self.Image_tishi:setTag(2);
    elseif actionType == 3 then--翻倍
        self.Image_tishi:loadTexture("sdb_fanbeitext.png",UI_TEX_TYPE_PLIST);
        self.Image_tishi:setTag(3);
    elseif actionType == 4 then--下注
        self.Image_tishi:loadTexture("sdb_xiazhu-liang.png",UI_TEX_TYPE_PLIST);
        self.Image_tishi:setTag(4);
    end
    self.Image_tishi:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
        self.Image_tishi:setVisible(false);
        self.Text_playerName:setVisible(true);
        self.Image_tishi:setTag(0);
    end)))
end
--显示分数并播放特效
function GamePlayerNode:SetPlayerScore(score)
    display.loadSpriteFrames("shidianban/shidianban.plist","shidianban/shidianban.png")
    self.Image_resultBg:setVisible(true);
    self.Image_resultBg:stopAllActions();

    local winSpine = self.Image_player:getChildByName("winSpine");
    if winSpine then
        winSpine:removeFromParent();
    end

    if score >= 0 then
        self.Image_resultBg:loadTexture("sdb_ying-bg.png",UI_TEX_TYPE_PLIST);
        self.AtlasLabel_score:setProperty("+"..self:ScoreToMoney(score),"shidianban/number/sdb_zi-ying.png",21,28,'+');

        local winSpine = createSkeletonAnimation("shengli","shidianban/effect/shengli.json","shidianban/effect/shengli.atlas");
        if winSpine then
            winSpine:setPosition(cc.p(self.Text_playerName:getPositionX(),self.Text_playerName:getPositionY()+18));
            winSpine:setAnimation(1,"shengli", false);
            winSpine:setName("winSpine");
            self.Image_player:addChild(winSpine,10);
        end

    elseif score < 0 then
        self.Image_resultBg:loadTexture("sdb_shu-bg.png",UI_TEX_TYPE_PLIST);
        self.AtlasLabel_score:setProperty(self:ScoreToMoney(score),"shidianban/number/sdb_zi-shu.png",21,28,'+');
    end
    self.Image_resultBg:runAction(cc.Sequence:create(cc.DelayTime:create(3.5),cc.CallFunc:create(function()
        self.Image_resultBg:setVisible(false);
        local winSpine = self.Image_player:getChildByName("winSpine");
        if winSpine then
            winSpine:removeFromParent();
        end

    end)))
end
--获取是否有翻倍的图片
function GamePlayerNode:GetTipTag()
    return self.Image_tishi:getTag();
end

--设置跑马灯的亮暗
function GamePlayerNode:ShowPaomaState(isShow)
    self.Image_paoma:setVisible(isShow);
end

--跑马灯动画时间亮暗
function GamePlayerNode:PaomaAction(paomaTime,isEnd)
    self.Image_paoma:setVisible(true);

    self:runAction(cc.Sequence:create(cc.DelayTime:create(paomaTime),cc.CallFunc:create(function()
        if isEnd == false then
            self.Image_paoma:setVisible(false);
        end
    end)));
end


return GamePlayerNode