--金币明细

local JinbiMingxiLayer = class("JinbiMingxiLayer", BaseWindow)
local GameConfig = require("competition.GameConfig")

function JinbiMingxiLayer:create(tableLayer)
	return JinbiMingxiLayer.new(tableLayer);
end

function JinbiMingxiLayer:ctor(tableLayer)
    self.super.ctor(self, nil, true);

    self.tableLayer = tableLayer;

    self:initData();

    self:bindEvent();

    self:initUI()
end

function JinbiMingxiLayer:initData()  
    self.EventID = 0;
end


function JinbiMingxiLayer:initUI()
    local winSize = cc.Director:getInstance():getWinSize();
    local bg = ccui.ImageView:create("zhuye/bg.png");
    -- local bg = ccui.ImageView:create("geren/mingxi/bg.jpg");
    bg:setPosition(winSize.width/2,winSize.height/2);
    self.bg = bg;
    self:addChild(bg);
    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode);
    self.pNode = pNode;
    local bgsize = cc.size(1280,720);

    --金币明细
    local dinglan = ccui.ImageView:create("zhuye/dinglan.png");
    dinglan:setAnchorPoint(0.5,1);
    dinglan:setPosition(bgsize.width/2,bgsize.height);
    pNode:addChild(dinglan,200);


    local dingNode = cc.Node:create();
    dingNode:setPosition(139.5,0);
    dinglan:addChild(dingNode);
    local dingSize = dinglan:getContentSize();

    local zhuye = ccui.ImageView:create("geren/mingxi/zi.png");
    zhuye:setPosition(bgsize.width*0.2,bgsize.height*0.95);
    pNode:addChild(zhuye,300);


    --返回
    local fanhuiBtn = ccui.Button:create("jingcai/fanhui.png","jingcai/fanhui-on.png")
    fanhuiBtn:setPosition(bgsize.width*0.05,bgsize.height*0.95);
    pNode:addChild(fanhuiBtn,300);
    fanhuiBtn:setName("fanhui")
    -- moreBtn:addClickEventListener(function(sender)  self:onClickBtnCallBack(sender); end);
    fanhuiBtn:onClick(handler(self,self.onClickBtnCallBack));

 
    --容器尺寸
    self.width = 1280;
    self.height = 640;
	self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0.5));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setInertiaScrollEnabled(false);
    self.ScrollView_list:setContentSize(cc.size(1559, self.height));
    self.ScrollView_list:setPosition(cc.p(bgsize.width/2,bgsize.height/2-40));
    pNode:addChild(self.ScrollView_list);

    self:ShowSearchGame();

    self.matchList = self.tableLayer.GameBetList;
    self:receiveMatchListInfo();

end

function JinbiMingxiLayer:ShowSearchGame()
    local bgsize = cc.size(1280,720);
    --全部赛事
    local saishi = ccui.ImageView:create("zhuye/sousuokuang.png");
    saishi:setPosition(bgsize.width*0.80,bgsize.height*0.95);
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
function JinbiMingxiLayer:DrawOtherGame(isShow)
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
        self:receiveMatchListInfo()

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

function JinbiMingxiLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
  
    if name == "sousuo" then

    elseif name == "xinshou" then

    elseif name == "fanhui" then
        self:delayCloseLayer();
    end

end

function JinbiMingxiLayer:bindEvent()
    -- self:pushEventInfo(CompetInfo, "onEcResult", handler(self, self.onEcResult))

    self:pushGlobalEventInfo("onEcResult",handler(self, self.onEcResult))

    local msg = {};
    msg.lUserID = PlatformLogic.loginResult.dwUserID;

    RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_RESULT,msg,GameMsg.MSG_GP_RC_RESULT);
end

function JinbiMingxiLayer:onExit()
    self.super.onExit(self);

end

function JinbiMingxiLayer:onEcResult()

    self.matchList = self.tableLayer.GameBetList;

    self:receiveMatchListInfo()
end

function JinbiMingxiLayer:receiveMatchListInfo()
    --处理消息 将已经完成下注筛选并对数据处理
    local msg = self.matchList;

    local TimeToString = function(time)
        local dateStr = "星期";

        if tonumber(os.date("%w",time)) == 1 then
            dateStr = dateStr.."一 ";
        elseif tonumber(os.date("%w",time)) == 2 then
            dateStr = dateStr.."二 ";
        elseif tonumber(os.date("%w",time)) == 3 then
            dateStr = dateStr.."三 ";
        elseif tonumber(os.date("%w",time)) == 4 then
            dateStr = dateStr.."四 ";
        elseif tonumber(os.date("%w",time)) == 5 then
            dateStr = dateStr.."五 ";
        elseif tonumber(os.date("%w",time)) == 6 then
            dateStr = dateStr.."六 ";
        elseif tonumber(os.date("%w",time)) == 0 then
            dateStr = dateStr.."日 ";
        end

        return dateStr..os.date("%m月%d日 %H:%M",time);
    end

    local resultData = {};
    for k,v in pairs(msg) do
        if self.tableLayer.GametypeEcList[v.lEventID] then
            for k1,v1 in pairs(self.tableLayer.GametypeEcList[v.lEventID].info) do
                --根据名字寻找eventid
                local eventId = self.EventID;
                if tonumber(v1.game_id) == tonumber(v.lMatchID) and (tonumber(v1.event_id)==eventId or eventId == 0) then
                    local oneData = {};
                    --时间的组成
                    

                    oneData.dateStr = TimeToString(v.lTime);
                    oneData.time = v.lTime;
                    local beginTime = string.split(v1.begin_time," ");

                    local guessInfo = "";
                    --获取竞猜项
                    for k,v2 in pairs(v1.guess) do
                        if tonumber(v2.bet_id) == v.lBetID then
                            guessInfo = v2.bet_title;

                            for k,v3 in pairs(v2.items) do
                                if v.lBetNumID == tonumber(v3.items_bet_num) then
                                    guessInfo = guessInfo.." "..v3.items_odds_name;
                                end
                            end
                        end
                    end

                    oneData.content = beginTime[1].." "..v1.match_info.." "..v1.teamInfo[1].name.."-"..v1.teamInfo[2].name.." "..guessInfo;

                    if v.lWinScore > 0 then
                        oneData.score = v.lWinScore;
                    else
                        oneData.score = v.lBetScore*-1;
                    end

                    oneData.lMatchState = v.lMatchState;


                    if v.lMatchState > 1 and v.lWinScore > 0 then
                        local dataCopy = clone(oneData);
                        dataCopy.score = v.lBetScore*-1;
                        oneData.dateStr = TimeToString(v.lEndTime);
                        oneData.time = v.lEndTime;
                        table.insert(resultData,dataCopy);
                    end

                    table.insert(resultData,oneData);
                end
            end
        end
    end

    --对时间进行排序
    table.sort(resultData,function(a,b)
        return a.time>b.time;
    end);

    --luaDump(resultData,"将已经完成下注筛选并对数据处理")
    self:updateMatchLlist(resultData);
end

function JinbiMingxiLayer:updateMatchLlist(matchList)
    -- LoadingLayer:removeLoading();

    self.ScrollView_list:removeAllChildren();

    local size = self.ScrollView_list:getInnerContainerSize();
    -- luaDump(matchList,"matchList")
    for k,v in pairs(matchList) do
        
        local layout = ccui.Layout:create();
        layout:setContentSize(cc.size(1559, 160));

        local MingxiNodeInfo = require("competition.MingxiNodeInfo")
        local node = MingxiNodeInfo.new(v);
        -- node:setReceiveCallBack(function(vipid) VipInfo:sendVipRewardRequest(vipid); end)
        node:setPosition(139.5,0);
        layout:addChild(node)
        self.ScrollView_list:pushBackCustomItem(layout);

    end
end


return JinbiMingxiLayer
