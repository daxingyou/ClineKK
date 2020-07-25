--下注单界面

local XiazhudanLayer = class("XiazhudanLayer", BaseWindow)

function XiazhudanLayer:create(tableLayer)
	return XiazhudanLayer.new(tableLayer);
end

function XiazhudanLayer:ctor(tableLayer)
    self.super.ctor(self, nil, true);
    self.tableLayer = tableLayer;

    self:initData();

    self:bindEvent();

    self:initUI()
end

function XiazhudanLayer:initData()  
    
end

function XiazhudanLayer:initUI()
    local winSize = cc.Director:getInstance():getWinSize();
    local bg = ccui.ImageView:create("jingcai/xiazhudan/kuang.png");
    bg:setPosition(winSize.width/2,winSize.height/2);
    self:addChild(bg);
    local bgsize = bg:getContentSize();

    

    --关闭
    local guanbiBtn = ccui.Button:create("jingcai/xiazhudan/guanbi.png","jingcai/xiazhudan/guanbi-on.png")
    guanbiBtn:setPosition(bgsize.width*0.96,bgsize.height*0.87);
    bg:addChild(guanbiBtn,100);
    guanbiBtn:setName("guanbi")
    -- moreBtn:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end);
    guanbiBtn:onClick(handler(self,self.onClickBtnCallBack));

    --下注单数量
    local danCount = 0;
    for k,v in pairs(self.tableLayer.GameBetList) do
        if v.lMatchState == 0 or v.lMatchState == 1 then
            danCount = danCount+1;
        end
    end
   
    local texttz = FontConfig.createWithSystemFont("投注单："..danCount,24,FontConfig.colorWhite);
    texttz:setPosition(bgsize.width*0.02,bgsize.height*0.77);
    texttz:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(texttz);
    self.texttz = texttz;

    local baoxiangui = ccui.ImageView:create("zhuye/baoxianxiang.png");
    baoxiangui:setPosition(bgsize.width*0.8,bgsize.height*0.77);
    baoxiangui:setScale(0.8);
    bg:addChild(baoxiangui);

    self.baoxianguinum = FontConfig.createWithCharMap(goldConvertFour(PlatformLogic.loginResult.i64Bank),"zhuye/zitiao.png", 15, 21, '+');
    self.baoxianguinum:setPosition(cc.p(60,22));
    self.baoxianguinum:setAnchorPoint(cc.p(0, 0.5));
    baoxiangui:addChild(self.baoxianguinum);

    --保险柜加
    local baoxianBtn = ccui.Button:create("zhuye/jia.png","zhuye/jia-on.png")
    baoxianBtn:setPosition(baoxiangui:getContentSize().width,baoxiangui:getContentSize().height/2);
    baoxiangui:addChild(baoxianBtn);
    -- baoxianBtn:addClickEventListener(function()self:delayCloseLayer();end);
    baoxianBtn:onClick(handler(self,self.onClickBtnCallBack));
    baoxianBtn:setName("baoxianguijia")

    local jinbi = ccui.ImageView:create("zhuye/jinbi.png");
    jinbi:setPosition(bgsize.width*0.57,bgsize.height*0.77);
    jinbi:setScale(0.8);
    bg:addChild(jinbi);

    self.jinbinum = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.i64Money),"zhuye/zitiao.png", 15, 21, '+');
    self.jinbinum:setPosition(cc.p(60,22));
    self.jinbinum:setAnchorPoint(cc.p(0, 0.5));
    jinbi:addChild(self.jinbinum);

    --金币加
    local jinbiBtn = ccui.Button:create("zhuye/jia.png","zhuye/jia-on.png")
    jinbiBtn:setPosition(jinbi:getContentSize().width,jinbi:getContentSize().height/2);
    jinbi:addChild(jinbiBtn);
    -- jinbiBtn:addClickEventListener(function()self:delayCloseLayer();end);
    jinbiBtn:onClick(handler(self,self.onClickBtnCallBack));
    jinbiBtn:setName("jinbijia")

 
    --容器尺寸
    self.width = 960;
    self.height = 375;
	self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0.5));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setInertiaScrollEnabled(false);
    self.ScrollView_list:setContentSize(cc.size(self.width, self.height));
    self.ScrollView_list:setPosition(cc.p(bgsize.width/2,bgsize.height/2-60));
    bg:addChild(self.ScrollView_list);

    self:receiveMatchListInfo(self.tableLayer.GameBetList);
    
end

function XiazhudanLayer:onEcResult(data)
    local msg = data._usedata;
    --luaDump(msg,"游戏战绩消息--------------")

    local danCount = 0;
    for k,v in pairs(msg) do
        if v.lMatchState == 0 or v.lMatchState == 1 then
            danCount = danCount+1;
        end
    end

    self.texttz:setString("投注单："..danCount);
    self:receiveMatchListInfo(msg)
end

function XiazhudanLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
  
    if name == "jinbijia" then
        createShop();
    elseif name == "baoxianguijia" then
        createBank(function(data)
            self:DealBankInfo(data);
        end,true);
    elseif name == "guanbi" then
        self:delayCloseLayer();
    end

end

function XiazhudanLayer:bindEvent()
    self:pushEventInfo(CompetInfo, "EcResult", handler(self, self.onEcResult))--
    self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.receiveRefreshScoreBank))

    self:pushEventInfo(CompetInfo, "UserMoneyUpdate", handler(self, self.onReceiveUserPoint))--
end

function XiazhudanLayer:onExit()
    self.super.onExit(self);

end

--调用保险箱函数
function XiazhudanLayer:DealBankInfo(data)
    -- self.playerMoney = self.playerMoney + data.OperatScore;
end

function XiazhudanLayer:receiveMatchListInfo(data)
    -- self.matchList = data._usedata;
    self.matchList = data;
    -- luaDump(self.matchList,"比赛列表")
    self:updateMatchLlist(self.matchList);
end

function XiazhudanLayer:updateMatchLlist(matchList)
    -- LoadingLayer:removeLoading();

    self.ScrollView_list:removeAllChildren();

    local size = self.ScrollView_list:getInnerContainerSize();
    for k,v in pairs(matchList) do
        if v.lMatchState == 0 or v.lMatchState == 1 then
            local layout = ccui.Layout:create();
            layout:setContentSize(cc.size(self.width, 125));


            local btn = ccui.Widget:create()
            btn:setContentSize(cc.size(self.width,125))
            btn:setAnchorPoint(cc.p(0.5,0.5))
            btn:setPosition(self.width/2,125/2)
            btn:setCascadeOpacityEnabled(true)
            btn:setTouchEnabled(true)
            layout:addChild(btn)
            btn:addClickEventListener(function(sender)  
                local  layer = self.tableLayer:getChildByName("XiazhuLayer");
                if layer then
                    return;
                end

                --寻找下注的游戏信息
                for k1,v1 in pairs(self.tableLayer.GametypeEcList[v.lEventID].info) do
                    if tonumber(v1.game_id) == tonumber(v.lMatchID) then

                        for k2,v2 in pairs(v1.guess) do
                            if tonumber(v2.bet_id) == v.lBetID then
                                for k3,v3 in pairs(v2.items) do
                                    if tonumber(v3.items_bet_num) == v.lBetNumID then

                                        if tonumber(v3.items_odds_status) == 1 and tonumber(v3.isDelete) == 0 then
                                            local XiazhuLayer = require("competition.XiazhuLayer");

                                            local newLayer = XiazhuLayer:create(v1,k2,k3);

                                            newLayer:setName("XiazhuLayer");

                                            self.tableLayer:addChild(newLayer);

                                        else
                                            addScrollMessage("当前场次已停止下注，下注失败");
                                        end
                                    end
                                end
                            end
                        end
                        break;
                    end
                end

            end);


            local XiazhudanNodeInfo = require("competition.XiazhudanNodeInfo")
            local node = XiazhudanNodeInfo.new(self.tableLayer,v);
            -- node:setReceiveCallBack(function(vipid) VipInfo:sendVipRewardRequest(vipid); end)
            node:setContentSize(layout:getContentSize());
            layout:addChild(node)
            self.ScrollView_list:pushBackCustomItem(layout);
        end

    end
end

function XiazhudanLayer:onReceiveUserPoint()
    self.jinbinum:setText(goldConvert(PlatformLogic.loginResult.i64Money));
end

function XiazhudanLayer:receiveRefreshScoreBank(data)
    local data = data._usedata
    if data then
        self.jinbinum:setText(goldConvert(data.i64WalletMoney))
        self.baoxianguinum:setText(goldConvertFour(data.i64BankMoney))
    end
end


return XiazhudanLayer
