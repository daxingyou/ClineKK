--主页

local MainLayer = class("MainLayer", BaseWindow)

function MainLayer:create(tableLayer,flag)
	return MainLayer.new(tableLayer,flag);
end

function MainLayer:ctor(tableLayer,flag)
    self.super.ctor(self, nil, true);

    self.tableLayer = tableLayer;

    self:setName("MainLayer");

    self:initData();

    self:initUI();

    if flag == nil then
        self:InitMatchList();
    end

end

function MainLayer:initData()
    self.EventID = 0;
    self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.receiveRefreshScoreBank))
    self:pushEventInfo(CompetInfo, "UserMoneyUpdate", handler(self, self.onReceiveUserPoint))--


end


function MainLayer:initUI()
    local winSize = cc.Director:getInstance():getWinSize();
    local bg = ccui.ImageView:create("zhuye/bg.png");
    bg:setPosition(winSize.width/2,winSize.height/2);
    self:addChild(bg);
    self.bg = bg;


    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode);
    self.pNode = pNode;
    local bgsize = cc.size(1280,720);

    local dinglan = ccui.ImageView:create("zhuye/dinglan.png");
    dinglan:setAnchorPoint(0.5,1);
    dinglan:setPosition(bgsize.width/2,bgsize.height);
    pNode:addChild(dinglan,200);


    local dingNode = cc.Node:create();
    dingNode:setPosition(139.5,0);
    dinglan:addChild(dingNode);
    local dingSize = dinglan:getContentSize();

    --主页
    -- local zhuyebg = ccui.ImageView:create("zhuye/biaotiBG.png");
    -- zhuyebg:setAnchorPoint(0,1);
    -- zhuyebg:setPosition(-139,dingSize.height);
    -- dingNode:addChild(zhuyebg);
    -- local zybgsize = zhuyebg:getContentSize();

    -- local zhuye = ccui.ImageView:create("zhuye/zi-zhuye.png");
    -- zhuye:setPosition(zybgsize.width-150,zybgsize.height/2+5);
    -- zhuyebg:addChild(zhuye);

    -- --更多
    -- local moreBtn = ccui.Button:create("zhuye/gengduo.png","zhuye/gengduo-on.png")
    -- moreBtn:setPosition(1280-40,dingSize.height/2);
    -- dingNode:addChild(moreBtn,100);
    -- moreBtn:setName("more")
    -- -- moreBtn:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end);
    -- moreBtn:onClick(handler(self,self.onClickBtnCallBack));


    local baoxiangui = ccui.ImageView:create("zhuye/baoxianxiang.png");
    baoxiangui:setAnchorPoint(0,0.5);
    baoxiangui:setPosition(300,dingSize.height/2);
    dingNode:addChild(baoxiangui);

    self.baoxianguinum = FontConfig.createWithCharMap(goldConvertFour(PlatformLogic.loginResult.i64Bank),"zhuye/zitiao.png", 15, 21, '+');
    self.baoxianguinum:setPosition(cc.p(60,22));
    self.baoxianguinum:setAnchorPoint(cc.p(0, 0.5));
    baoxiangui:addChild(self.baoxianguinum);

    --保险柜加
    local baoxianBtn = ccui.Button:create("zhuye/jia.png","zhuye/jia-on.png")
    baoxianBtn:setAnchorPoint(0,0.5);
    baoxianBtn:setPosition(baoxiangui:getPositionX()+baoxiangui:getContentSize().width-15,dingSize.height/2);
    dingNode:addChild(baoxianBtn);
    -- baoxianBtn:addClickEventListener(function()self:delayCloseLayer();end);
    baoxianBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    baoxianBtn:setName("baoxianguijia")


    
    local jinbi = ccui.ImageView:create("zhuye/jinbi.png");
    jinbi:setAnchorPoint(0,0.5);
    jinbi:setPosition(20,dingSize.height/2);
    dingNode:addChild(jinbi);

    self.jinbinum = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.i64Money),"zhuye/zitiao.png", 15, 21, '+');
    self.jinbinum:setPosition(cc.p(60,22));
    self.jinbinum:setAnchorPoint(cc.p(0, 0.5));
    jinbi:addChild(self.jinbinum);

    --金币加
    local jinbiBtn = ccui.Button:create("zhuye/jia.png","zhuye/jia-on.png")
    jinbiBtn:setAnchorPoint(0,0.5);
    jinbiBtn:setPosition(jinbi:getPositionX()+jinbi:getContentSize().width-15,dingSize.height/2);
    dingNode:addChild(jinbiBtn);
    -- jinbiBtn:addClickEventListener(function()self:delayCloseLayer();end);
    jinbiBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    jinbiBtn:setName("jinbijia")


    --日历
    local rilibg = ccui.ImageView:create("zhuye/sousuokuang.png");
    rilibg:setAnchorPoint(0,0.5);
    rilibg:setPosition(335,600);
    pNode:addChild(rilibg);

    local textBg = ccui.ImageView:create("zhuye/sousuokuang2.png");
    textBg:setAnchorPoint(cc.p(0,0.5));
    textBg:setPosition(5,rilibg:getContentSize().height/2);
    rilibg:addChild(textBg);

    local textdate = FontConfig.createWithSystemFont(self.tableLayer.saveDate[1].."-"..self.tableLayer.saveDate[2].."-"..self.tableLayer.saveDate[3],34,FontConfig.colorWhite);
    textdate:setPosition(textBg:getContentSize().width/2,textBg:getContentSize().height/2);
    textBg:addChild(textdate);
    self.textdate = textdate;
    --
    local rili = ccui.Button:create("zhuye/rili.png","zhuye/rili-on.png");
    rili:setAnchorPoint(1,0.5);
    rili:setPosition(rilibg:getContentSize().width-3,rilibg:getContentSize().height/2);
    rilibg:addChild(rili);
    rili:setName("rili")
    rili:newOnClick(handler(self,self.onClickBtnCallBack));

    -- --更多
    -- local morebg = ccui.ImageView:create("zhuye/anniuBG.png");
    -- morebg:setAnchorPoint(0.5,1);
    -- morebg:setPosition(moreBtn:getPositionX(),moreBtn:getPositionY()+35);
    -- dingNode:addChild(morebg,10);
    -- local morebgsize = morebg:getContentSize();
    -- self.morebg = morebg;
    -- self.morebg:setVisible(false)

    --主页
    local zyBtn = ccui.Button:create("zhuye/zhuye.png","zhuye/zhuye-on.png","zhuye/zhuye-l.png")
    zyBtn:setPosition(670,dingSize.height/2);
    dingNode:addChild(zyBtn);
    -- zyBtn:addClickEventListener(function()self:delayCloseLayer();end);
    zyBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    zyBtn:setName("zhuye")

    --历史
    local lsBtn = ccui.Button:create("zhuye/lishi.png","zhuye/lishi-on.png","zhuye/lishi-l.png")
    lsBtn:setPosition(zyBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(lsBtn);
    -- lsBtn:addClickEventListener(function()self:delayCloseLayer();end);
    lsBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    lsBtn:setName("lishi")

    --情报
    local qbBtn = ccui.Button:create("zhuye/qingbao.png","zhuye/qingbao-on.png","zhuye/qingbao-l.png")
    qbBtn:setPosition(lsBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(qbBtn);
    -- qbBtn:addClickEventListener(function()self:delayCloseLayer();end);
    qbBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    qbBtn:setName("qingbao")

    --个人中心
    local grBtn = ccui.Button:create("zhuye/gerenzhongxin.png","zhuye/gerenzhongxin-on.png","zhuye/gerenzhongxin-l.png")
    grBtn:setPosition(qbBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(grBtn);
    -- grBtn:addClickEventListener(function()self:delayCloseLayer();end);
    grBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    grBtn:setName("gerenzhongxin")

    --竞猜
    local jingcaiBtn = ccui.Button:create("zhuye/dianjingjingcai.png","zhuye/dianjingjingcai-on.png","zhuye/dianjingjingcai-l.png")
    jingcaiBtn:setPosition(grBtn:getPositionX()+90,dingSize.height/2);
    dingNode:addChild(jingcaiBtn);
    jingcaiBtn:setName("jingcai")
    -- jingcaiBtn:addClickEventListener(function()self:delayCloseLayer();end);
    jingcaiBtn:newOnClick(handler(self,self.onClickBtnCallBack));

    zyBtn:setEnabled(false);

    --返回大厅
    local fhBtn = ccui.Button:create("jingcai/fanhui.png","jingcai/fanhui-on.png")
    fhBtn:setAnchorPoint(1,0.5);
    fhBtn:setPosition(1240,dingSize.height/2);
    dingNode:addChild(fhBtn);
    -- fhBtn:addClickEventListener(function()self:delayCloseLayer();end);
    fhBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    fhBtn:setName("fanhui")
   
    self:ShowSearchGame();
 
    --容器尺寸
    self.width = 1280;
    self.height = 560;
	self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setInertiaScrollEnabled(false);
    self.ScrollView_list:setContentSize(cc.size(1559, self.height));
    self.ScrollView_list:setPosition(cc.p(bgsize.width/2,0));
    pNode:addChild(self.ScrollView_list);

end


function MainLayer:UpdateSearchList()
    self.saveSearchList = self.tableLayer:GetAllEcList();
end

function MainLayer:ShowSearchGame()
    local bgsize = cc.size(1280,720);
    --全部赛事
    local saishi = ccui.ImageView:create("zhuye/sousuokuang.png");
    saishi:setAnchorPoint(0,0.5);
    saishi:setPosition(10,600);
    saishi:setName("saishi");
    self.pNode:addChild(saishi,100);
    --
    local xiala = ccui.Button:create("zhuye/xiala.png","zhuye/xiala-on.png")
    xiala:setAnchorPoint(1,0.5);
    xiala:setPosition(saishi:getContentSize().width-3,saishi:getContentSize().height/2);
    saishi:addChild(xiala);
    xiala:setTag(0);
    xiala:addClickEventListener(function(sender)
        local tag = sender:getTag();
        if tag == 0 then
            self:DrawOtherGame(true);
            sender:setTag(1);
        else
            self:DrawOtherGame(false);
            sender:setTag(0);
        end
    end);

    self.xiala = xiala;

    self.saveSearchList = self.tableLayer:GetAllEcList();

    self:DrawOtherGame(false);

end
--绘制赛事列表
function MainLayer:DrawOtherGame(isShow)
    local saishi = self.pNode:getChildByName("saishi");

    if isShow == nil then
        isShow = false;
    end

    --将其他销毁重新创建
    for k,v in pairs(self.saveSearchList) do
        local textBg = saishi:getChildByName("textBg"..k);
        if textBg then
            saishi:removeChild(textBg);
        end
    end

    --处理点击事件
    local function SelectGameClick(sender)
        local senderTag = sender:getTag();

        --跟第一个进行交换 如果第一个不是全部赛事则将第二个换成全部赛事
        local saveData = clone(self.saveSearchList[1]);
        self.saveSearchList[1] = self.saveSearchList[senderTag];
        self.saveSearchList[senderTag] = saveData;

        if #self.saveSearchList > 2 then
            if tonumber(self.saveSearchList[1].event_id) ~= 0 and tonumber(self.saveSearchList[2].event_id) ~= 0 then
                local saveData = clone(self.saveSearchList[2]);
                for k,v in pairs(self.saveSearchList) do
                    if tonumber(v.event_id) == 0 then
                        self.saveSearchList[2] = self.saveSearchList[k];
                        self.saveSearchList[k] = saveData;
                        break;
                    end
                end
            end
        end

        self.EventID = tonumber(self.saveSearchList[1].event_id);

        self:DrawOtherGame(false);
        self.xiala:setTag(0);
        --更新列表
        self:UpdateGameList();

    end

    if saishi then
        local posY = saishi:getContentSize().height/2;
        for k,v in pairs(self.saveSearchList) do
            if isShow or k == 1 then
                local textBg = ccui.Button:create("zhuye/sousuokuang2.png","zhuye/sousuokuang2.png");
                textBg:setAnchorPoint(cc.p(0,0.5));
                textBg:setPosition(5+math.floor((k-1)/17)*textBg:getContentSize().width,posY);
                saishi:addChild(textBg);
                textBg:setTag(k);
                textBg:setName("textBg"..k);

                --数组第一个都会显示
                if k == 1 then
                    textBg:setVisible(true);
                else
                    textBg:setVisible(isShow);
                end
                textBg:setTouchEnabled(isShow);
                textBg:addClickEventListener(function(sender)
                    SelectGameClick(sender);
                end);

                --变更下个textBg的Y轴位置
                posY = posY - textBg:getContentSize().height-5;
                if k%17 == 0 then
                    posY = saishi:getContentSize().height/2 - textBg:getContentSize().height-5;
                end

                local textss = FontConfig.createWithSystemFont(v.eventName,34,FontConfig.colorWhite);
                textss:setPosition(textBg:getContentSize().width/2,textBg:getContentSize().height/2);
                textBg:addChild(textss);
                textss:setName("textss");
            end
        end
    end
end



function MainLayer:receiveRefreshScoreBank(data)
    local data = data._usedata
    if data then
        self.jinbinum:setText(goldConvert(data.i64WalletMoney))
        self.baoxianguinum:setText(goldConvertFour(data.i64BankMoney))
    end
end

function MainLayer:onReceiveUserPoint()
    self.jinbinum:setText(goldConvert(PlatformLogic.loginResult.i64Money))
end

function MainLayer:onClickBtnCallBack(sender,data)
    local name = sender:getName();
  
    if name == "more" then
        self.morebg:setVisible(not self.morebg:isVisible())
    elseif name == "sousuo" then
    
    elseif name == "baoxianguijia" then
        createBank(function(data)
            self:DealBankInfo(data);
        end,true);
    elseif name == "jinbijia" then
        createShop();
    elseif name == "rili" then
        self:addChild(require("competition.CalendarLayer"):create(self,self.tableLayer.saveDate));
    elseif name == "zhuye" then

    elseif name == "jingcai" then
        self.tableLayer:addChild(require("competition.JingcaiLayer"):create(self.tableLayer,0));
        self:delayCloseLayer();
    elseif name == "lishi" then
        self.tableLayer:addChild(require("competition.LishiLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "qingbao" then
        self.tableLayer:addChild(require("competition.QingbaoLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "gerenzhongxin" then
        self.tableLayer:addChild(require("competition.GerenInfoLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "fanhui" then
        self.tableLayer:ExitGame();
    elseif name == "bisai" then 
        self.tableLayer:addChild(require("competition.JingcaiLayer"):create(self.tableLayer,sender:getTag()));
        self:delayCloseLayer();
    end

end

--调用保险箱函数
function MainLayer:DealBankInfo(data)
    -- self.playerMoney = self.playerMoney + data.OperatScore;
end

--更新当前时间的游戏列表
function MainLayer:UpdateGameList(year,month,day)
    if year and month and day then
        self.tableLayer.saveDate[1] = year;
        self.tableLayer.saveDate[2] = month;
        self.tableLayer.saveDate[3] = day;

        self.textdate:setString(self.tableLayer.saveDate[1].."-"..self.tableLayer.saveDate[2].."-"..self.tableLayer.saveDate[3]);
    end
    self:ClearMatchLlist();


    for k,gameListInfo in pairs(self.tableLayer.GametypeEcList) do
        if self.EventID == 0 or gameListInfo.EventID == self.EventID then
            for k,v in pairs(gameListInfo.info) do
                self:UpdateMatchList(v);
            end
        end
    end
end

--初始化设置列表
function MainLayer:InitMatchList()
    self:ClearMatchLlist();

    --luaDump(self.tableLayer.GametypeEcList,"初始化设置列表");

    self.saveSearchList = self.tableLayer:GetAllEcList();
    self:DrawOtherGame(false);

    for k,gameInfo in pairs(self.tableLayer.GametypeEcList) do
        for k1,v1 in pairs(gameInfo.info) do
            self:UpdateMatchList(v1);
        end
    end
end


--更改数据结构
function MainLayer:UpdateMatchList(matchData)
    if self.EventID == 0 or tonumber(matchData.event_id) == self.EventID then
        local beginTime = string.split(matchData.begin_time," ");
        local timeSplit = string.split(beginTime[1],"-");

        if tonumber(timeSplit[1]) == tonumber(self.tableLayer.saveDate[1]) and tonumber(timeSplit[2]) == tonumber(self.tableLayer.saveDate[2]) and tonumber(timeSplit[3]) == tonumber(self.tableLayer.saveDate[3]) then
            self:updateMatchLlist(matchData);
        end
    end

end

function MainLayer:ClearMatchLlist()
    self.ScrollView_list:removeAllChildren();
end

function MainLayer:updateMatchLlist(matchData)
    -- LoadingLayer:removeLoading();


    local size = self.ScrollView_list:getInnerContainerSize();
    -- luaDump(matchList,"matchList")
        
    local layout = ccui.Layout:create();
    layout:setContentSize(cc.size(1559, 164));

    local btn = ccui.Widget:create()
    btn:setContentSize(cc.size(1559,164))
    btn:setAnchorPoint(cc.p(0.5,0.5))
    btn:setPosition(self.width/2,84)
    btn:setCascadeOpacityEnabled(true)
    btn:setTouchEnabled(true)
    btn:setName("bisai")
    layout:addChild(btn)
    btn:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender,matchData) end)
    -- btn:onClick(handler(self,self.onClickBtnCallBack));

    local MatchNodeInfo = require("competition.MatchNodeInfo")
    local node = MatchNodeInfo.new(matchData);
    -- node:setReceiveCallBack(function(vipid) VipInfo:sendVipRewardRequest(vipid); end)
    node:setPosition(139.5,0);
    layout:addChild(node)
    self.ScrollView_list:pushBackCustomItem(layout);

    btn:setTag(tonumber(matchData.game_id));
end



return MainLayer
