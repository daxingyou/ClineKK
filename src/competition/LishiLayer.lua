--历史

local LishiLayer = class("LishiLayer", BaseWindow)

function LishiLayer:create(tableLayer)
	return LishiLayer.new(tableLayer);
end

function LishiLayer:ctor(tableLayer)
    self.super.ctor(self, nil, true);

    self.tableLayer = tableLayer;

    self:setName("LishiLayer");

    self:initData();

    self:bindEvent();

    self:initUI()
end

function LishiLayer:initData()  
    self.EventID = 0;
end


function LishiLayer:initUI()
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

    -- --主页
    -- local zhuyebg = ccui.ImageView:create("zhuye/biaotiBG.png");
    -- zhuyebg:setAnchorPoint(0,1);
    -- zhuyebg:setPosition(-139,dingSize.height);
    -- dingNode:addChild(zhuyebg);
    -- local zybgsize = zhuyebg:getContentSize();

    -- local zhuye = ccui.ImageView:create("lishi/zi.png");
    -- zhuye:setAnchorPoint(1,0.5);
    -- zhuye:setPosition(zybgsize.width-80,zybgsize.height/2+5);
    -- zhuyebg:addChild(zhuye);

    -- --更多
    -- local moreBtn = ccui.Button:create("zhuye/gengduo.png","zhuye/gengduo-on.png")
    -- moreBtn:setPosition(1280-40,dingSize.height/2);
    -- dingNode:addChild(moreBtn,100);
    -- moreBtn:setName("more")
    -- -- moreBtn:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end);
    -- moreBtn:onClick(handler(self,self.onClickBtnCallBack));


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

    lsBtn:setEnabled(false);

    --返回大厅
    local fhBtn = ccui.Button:create("jingcai/fanhui.png","jingcai/fanhui-on.png")
    fhBtn:setAnchorPoint(1,0.5);
    fhBtn:setPosition(1240,dingSize.height/2);
    dingNode:addChild(fhBtn);
    -- fhBtn:addClickEventListener(function()self:delayCloseLayer();end);
    fhBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    fhBtn:setName("fanhui")
   

 
    --容器尺寸
    self.width = 1280;
    self.height = 630;
	self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setInertiaScrollEnabled(false);
    self.ScrollView_list:setContentSize(cc.size(1559, self.height));
    self.ScrollView_list:setPosition(cc.p(bgsize.width/2,0));
    pNode:addChild(self.ScrollView_list);

    self:ShowSearchGame();

    self:updateMatchLlist()
end

function LishiLayer:ShowSearchGame()
    local bgsize = cc.size(1280,720);
    --全部赛事
    local saishi = ccui.ImageView:create("zhuye/sousuokuang.png");
    saishi:setAnchorPoint(0,0.5);
    saishi:setPosition(10,680);
    saishi:setName("saishi");
    self.pNode:addChild(saishi,300);
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
function LishiLayer:DrawOtherGame(isShow)
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
        self:updateMatchLlist();

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

                local textss = FontConfig.createWithSystemFont(v.eventName,30,FontConfig.colorWhite);
                textss:setPosition(textBg:getContentSize().width/2,textBg:getContentSize().height/2);
                textBg:addChild(textss);
                textss:setName("textss");
            end
        end
    end
end

function LishiLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
  
    if name == "more" then
        self.morebg:setVisible(not self.morebg:isVisible())
    elseif name == "sousuo" then
    
    elseif name == "baoxianguijia" then

    elseif name == "jinbijia" then

    elseif name == "zhuye" then
        self.tableLayer:addChild(require("competition.MainLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "jingcai" then
        self.tableLayer:addChild(require("competition.JingcaiLayer"):create(self.tableLayer,0));
        self:delayCloseLayer();
    elseif name == "qingbao" then
        self.tableLayer:addChild(require("competition.QingbaoLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "gerenzhongxin" then
        self.tableLayer:addChild(require("competition.GerenInfoLayer"):create(self.tableLayer));
        self:delayCloseLayer();
    elseif name == "fanhui" then
        self.tableLayer:ExitGame();
    end

end

function LishiLayer:bindEvent()

end

function LishiLayer:onExit()
    self.super.onExit(self);

end


function LishiLayer:updateMatchLlist()
    -- LoadingLayer:removeLoading();

    self.ScrollView_list:removeAllChildren();

    local size = self.ScrollView_list:getInnerContainerSize();

    for k,v in pairs(self.tableLayer.GametypeEcList) do
        --判断赛事选择和赛事状态 结束的显示
        --luaDump(v.info,"历史赛事")
        for k1 = #v.info,1,-1 do
            local v1 = v.info[k1];
            luaPrint("历史",v1.game_status)
            if (v.EventID == self.EventID or self.EventID == 0) and tonumber(v1.game_status) == 2 then
                local layout = ccui.Layout:create();
                layout:setContentSize(cc.size(1559, 164));

                local LishiNodeInfo = require("competition.LishiNodeInfo")
                local node = LishiNodeInfo.new(v1);
                -- node:setReceiveCallBack(function(vipid) VipInfo:sendVipRewardRequest(vipid); end)
                node:setPosition(139.5,0);
                layout:addChild(node)
                self.ScrollView_list:pushBackCustomItem(layout);

            end
        end
    end
end


return LishiLayer
