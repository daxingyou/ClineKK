--竞猜界面

local JingcaiLayer = class("JingcaiLayer", BaseWindow)

function JingcaiLayer:create(tableLayer,key)
	return JingcaiLayer.new(tableLayer,key);
end

function JingcaiLayer:ctor(tableLayer,key)
    self.super.ctor(self, nil, true);
    self.tableLayer = tableLayer;
    --第几个
    self.key = key;

    self.openTag = 0;

    self:initData();

    self:bindEvent();

end

function JingcaiLayer:initData()
    self.EventID = 0;
end

--进入
function JingcaiLayer:onEnter()
    self.super.onEnter(self);

    self:initUI();
end

function JingcaiLayer:initUI()
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

    local layout = ccui.Layout:create();
    layout:setContentSize(cc.size(dinglan:getContentSize().width, dinglan:getContentSize().height));
    layout:setPosition(bgsize.width*0.5,bgsize.height*0.95);
    pNode:addChild(layout,5);


    -- local zhuye = ccui.ImageView:create("jincai/zi.png");
    -- zhuye:setPosition(bgsize.width*0.2,bgsize.height*0.95);
    -- bg:addChild(zhuye);


    --下注单
    local xiazhudan = ccui.Button:create("jingcai/xiazhudan.png","jingcai/xiazhudan-on.png")
    xiazhudan:setAnchorPoint(0,0.5);
    xiazhudan:setPosition(340,dinglan:getContentSize().height/2);
    dingNode:addChild(xiazhudan,10);
    xiazhudan:setName("xiazhudan")
    xiazhudan:onClick(handler(self,self.onClickBtnCallBack));

    local hongdian = ccui.ImageView:create("jingcai/tishi.png");
    hongdian:setPosition(100,48);
    xiazhudan:addChild(hongdian,10);

    local danCount = 0;
    for k,v in pairs(self.tableLayer.GameBetList) do
        if v.lMatchState == 0 or v.lMatchState == 1 then
            danCount = danCount+1;
        end
    end

    local texttz = FontConfig.createWithSystemFont(danCount,24,FontConfig.colorWhite);
    texttz:setPosition(16,16);
     -- texttz:setAnchorPoint(cc.p(0, 0.5));
    hongdian:addChild(texttz,10);
    self.texttz = texttz

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

    jingcaiBtn:setEnabled(false);

    --返回大厅
    local fhBtn = ccui.Button:create("jingcai/fanhui.png","jingcai/fanhui-on.png")
    fhBtn:setAnchorPoint(1,0.5);
    fhBtn:setPosition(1240,dingSize.height/2);
    dingNode:addChild(fhBtn);
    -- fhBtn:addClickEventListener(function()self:delayCloseLayer();end);
    fhBtn:newOnClick(handler(self,self.onClickBtnCallBack));
    fhBtn:setName("fanhui");

    --容器尺寸
    self.width = 1280;
    self.height = 630;
    self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setInertiaScrollEnabled(true);
    self.ScrollView_list:setContentSize(cc.size(1559, self.height));
    self.ScrollView_list:setPosition(cc.p(640,0));
    
    self.pNode:addChild(self.ScrollView_list);

    self.ScrollView_list:setBounceEnabled(false);

    self:updateMatchLlist(self.tableLayer.GametypeEcList,0)

    self:ShowSearchGame();
end


function JingcaiLayer:ShowSearchGame()
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
function JingcaiLayer:DrawOtherGame(isShow)
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
        self.key = 0;
        --更新数据
        self:updateMatchLlist(self.tableLayer.GametypeEcList,0);

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



function JingcaiLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
  
    if name == "xiazhudan" then
       self.tableLayer:addChild(require("competition.XiazhudanLayer"):create(self.tableLayer));
    elseif name == "zhuye" then
        self.tableLayer:addChild(require("competition.MainLayer"):create(self.tableLayer));
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
    end

end

function JingcaiLayer:bindEvent()
    self:pushEventInfo(CompetInfo, "EcResult", handler(self, self.onEcResult))--

    self:pushGlobalEventInfo("onRealtimeInfo",handler(self, self.onRealtimeInfo))
    
end

--比赛动态信息 9.1
function JingcaiLayer:onRealtimeInfo(data)
    self:updateMatchLlist(self.tableLayer.GametypeEcList,false)

    self.saveSearchList = self.tableLayer:GetAllEcList();

    self:DrawOtherGame(false);
end

function JingcaiLayer:onExit()
    self.super.onExit(self);
end

function JingcaiLayer:onEcResult(data)
    local msg = data._usedata;

    local danCount = 0;
    for k,v in pairs(msg) do
        if v.lMatchState == 0 or v.lMatchState == 1 then
            danCount = danCount+1;
        end
    end

    self.texttz:setString(danCount);
end


function JingcaiLayer:updateMatchLlist(matchList,tag)
    if tag == nil then
        tag = 0;
        self.openTag = tag;
    end

    if tag == false then
        local flag = false;
        for eventId,gameInfo in pairs(matchList) do
            if eventId == self.EventID or self.EventID == 0 then
                for k,v in pairs(gameInfo.info) do
                    if tonumber(self.key)==tonumber(v.game_id) then
                        flag = true;
                        break;
                    end
                end
            end
        end

        if flag == false then
            self.openTag = 0;
        end
    else
        self.openTag = tag;
    end

    -- if self.ScrollView_list ~= nil then
    --     self.ScrollView_list:removeFromParent();
    -- end

    self.ScrollView_list:removeAllChildren();

    -- --luaDump(matchList,"matchList")
    local index = 0;
    local selectSizeH = 90;
    for eventId,gameInfo in pairs(matchList) do
        if eventId == self.EventID or self.EventID == 0 then
            for k,v in pairs(gameInfo.info) do
                -- --luaDump(v,"matchList")
                local layout = ccui.Layout:create();
                layout:setContentSize(cc.size(1559, 90));

                local JingcaiNodeInfo = require("competition.JingcaiNodeInfo")
                local node = JingcaiNodeInfo.new(clone(v),layout,self,tonumber(self.key)==tonumber(v.game_id),self.openTag,self.tableLayer);
                -- node:setReceiveCallBack(function(vipid) VipInfo:sendVipRewardRequest(vipid); end)
                -- node:setPosition(139.5,0);
                layout:addChild(node)
                self.ScrollView_list:pushBackCustomItem(layout);

                local btn = ccui.Widget:create()
                btn:setContentSize(cc.size(1559,90))
                btn:setAnchorPoint(cc.p(0.5,1))
                btn:setPosition(layout:getContentSize().width/2,layout:getContentSize().height)
                btn:setCascadeOpacityEnabled(true)
                btn:setTouchEnabled(true)
                layout:addChild(btn)
                btn:addClickEventListener(function(sender) node:NodeClick() end)

                if tonumber(self.key)==tonumber(v.game_id) then
                    index = k;
                    selectSizeH = layout:getContentSize().height;
                end
            end
        end
    end

    self.ScrollView_list:refreshView();
    local itemsSizeH = index*90;
    local viewSizeH = self.ScrollView_list:getContentSize().height;

    local totalHeight = 0;
    if #self.ScrollView_list:getChildren() == 0 or index*90 <= 360 then
        return;
    else
        totalHeight = totalHeight + (#self.ScrollView_list:getChildren()-1)*90+selectSizeH;
    end

    self.ScrollView_list:jumpToPercentVertical(itemsSizeH/totalHeight*100);

end


return JingcaiLayer
