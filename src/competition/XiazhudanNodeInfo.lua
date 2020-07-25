--主页

local XiazhudanNodeInfo = class("XiazhudanNodeInfo", function() return display.newNode(); end)

function XiazhudanNodeInfo:ctor(tableLayer,data)
    self.tableLayer = tableLayer;
    self.data = data;
    self:initUI();
end

function XiazhudanNodeInfo:initUI()
    if self.tableLayer.GametypeEcList[self.data.lEventID] == nil then
        return;
    end

    --寻找下注的游戏信息
    local gameInfo = nil;
    for k,v in pairs(self.tableLayer.GametypeEcList[self.data.lEventID].info) do
        if tonumber(v.game_id) == tonumber(self.data.lMatchID) then
            gameInfo = v;
        end
    end

    if gameInfo == nil then
        return;
    end

    local bg = ccui.ImageView:create("jingcai/xiazhudan/BGtiao.png");
    bg:setPosition(cc.p(480,62));
    self:addChild(bg);
    local bgsize = bg:getContentSize();

    local texttz = FontConfig.createWithSystemFont("BO"..gameInfo.bo,24,FontConfig.colorWhite);
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.8);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(texttz);

    local guessInfo = "";
    local betRat = 0;
    local touzhuFlag = false;
    --获取竞猜项
    for k,v in pairs(gameInfo.guess) do
        if tonumber(v.bet_id) == self.data.lBetID then
            guessInfo = v.bet_title;
            for k1,v1 in pairs(v.items) do
                if tonumber(v1.items_bet_num) == self.data.lBetNumID then
                    betRat = tonumber(v1.items_odds);
                    if tonumber(v1.items_odds_status) == 1 and tonumber(v1.isDelete) == 0 then
                        touzhuFlag = true;
                    end
                    break;
                end
            end
        end
    end

    local texttz = FontConfig.createWithSystemFont(guessInfo,24,FontConfig.colorWhite);
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.6);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont(gameInfo.teamInfo[1].name.."-"..gameInfo.teamInfo[2].name,24,cc.c3b(87, 197, 224));
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.4);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(texttz);

    local texttz = FontConfig.createWithSystemFont(gameInfo.match_info,24,cc.c3b(220, 168, 121));
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.2);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(texttz);


    --赔率
    luaPrint("当前的赔率-------------------------",betRat)
    local peilv = FontConfig.createWithCharMap(betRat/100,"jingcai/xiazhudan/zitiao3.png", 32, 39, '+');
    peilv:setPosition(bgsize.width*0.67,bgsize.height*0.50);
    bg:addChild(peilv);

    --当前赔率字
    local peilvZi = ccui.ImageView:create("jingcai/xiazhudan/dangqian.png");
    peilvZi:setPosition(bgsize.width*0.67,bgsize.height*0.17);
    bg:addChild(peilvZi);

    --投
    local tou = FontConfig.createWithCharMap(goldConvert(self.data.lBetScore),"jingcai/xiazhudan/zitiao1.png", 16, 21, '+');
    tou:setPosition(bgsize.width*0.89,bgsize.height*0.70);
    bg:addChild(tou);

    local jinbi = ccui.ImageView:create("geren/mingxi/jinbitubiao.png");
    jinbi:setPosition(bgsize.width*0.98,bgsize.height*0.7);
    bg:addChild(jinbi);

    --总下注字
    local touZi = ccui.ImageView:create("jingcai/xiazhudan/zhu.png");
    touZi:setPosition(bgsize.width*0.79,bgsize.height*0.70);
    bg:addChild(touZi);

 
    --返
    local fantu = ccui.ImageView:create("jingcai/xiazhudan/fan.png");
    fantu:setPosition(bgsize.width*0.79,bgsize.height*0.25);
    bg:addChild(fantu);

    local fanScore = self.data.lWinScore;
    --比赛没有结束 显示玩家可能赢得钱
    if self.data.lMatchState == 0 or self.data.lMatchState == 1 then
        fanScore = math.floor(self.data.lBetScore*self.data.lBetRat/100);
    end
    --如果得分是负数则显示0
    if fanScore<0 then
        fanScore = 0;
    end

    local fan = FontConfig.createWithCharMap(goldConvert(fanScore),"jingcai/xiazhudan/zitiao2.png", 16, 21, '+');
    fan:setPosition(bgsize.width*0.89,bgsize.height*0.25);
    bg:addChild(fan);

    local jinbi = ccui.ImageView:create("geren/mingxi/jinbitubiao.png");
    jinbi:setPosition(bgsize.width*0.98,bgsize.height*0.25);
    bg:addChild(jinbi);

    if touzhuFlag == false then
        local touzhuStatusSp = ccui.ImageView:create("jingcai/touzhu0.png");
        touzhuStatusSp:setAnchorPoint(0,1);
        touzhuStatusSp:setPosition(bgsize.width*0.572,bg:getContentSize().height-5);
        bg:addChild(touzhuStatusSp);
    end

    
end

return XiazhudanNodeInfo
