--历史竞猜

local LishijingcaiLayer = class("LishijingcaiLayer", BaseWindow)
local GameConfig = require("competition.GameConfig")

function LishijingcaiLayer:create(tableLayer)
	return LishijingcaiLayer.new(tableLayer);
end

function LishijingcaiLayer:ctor(tableLayer)
    self.super.ctor(self, nil, true);

    self.tableLayer = tableLayer;

    self:initData();

    self:bindEvent();

    self:initUI()
end

function LishijingcaiLayer:initData()  
    self.EventID = 0;
end

function LishijingcaiLayer:initUI()
    local winSize = cc.Director:getInstance():getWinSize();
    local bg = ccui.ImageView:create("zhuye/bg.png");
    bg:setPosition(winSize.width/2,winSize.height/2);
    self:addChild(bg);
    self.bg = bg;

    local pNode = cc.Node:create();
    pNode:setPosition(139.5,0);
    bg:addChild(pNode,10);
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
    local zhuye = ccui.ImageView:create("geren/lishi/zi.png");
    zhuye:setPosition(bgsize.width*0.2,bgsize.height*0.95);
    pNode:addChild(zhuye,300);

    --返回
    local fanhuiBtn = ccui.Button:create("jingcai/fanhui.png","jingcai/fanhui-on.png")
    fanhuiBtn:setPosition(bgsize.width*0.05,bgsize.height*0.95);
    self.pNode:addChild(fanhuiBtn,300);
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


    self.matchList = self.tableLayer.GameBetList;

    self:ShowSearchGame();

    self:receiveMatchListInfo();

end

function LishijingcaiLayer:ShowSearchGame()
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
function LishijingcaiLayer:DrawOtherGame(isShow)
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

function LishijingcaiLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
  
    if name == "xinshou" then

    elseif name == "fanhui" then
        self:delayCloseLayer();
    end

end

function LishijingcaiLayer:bindEvent()
    -- self:pushEventInfo(CompetInfo, "onEcResult", handler(self, self.onEcResult))--
    self:pushGlobalEventInfo("onEcResult",handler(self, self.onEcResult))
    local msg = {};
    msg.lUserID = PlatformLogic.loginResult.dwUserID;

    RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_RESULT,msg,GameMsg.MSG_GP_RC_RESULT);
end

function LishijingcaiLayer:onExit()
    self.super.onExit(self);

end

function LishijingcaiLayer:onEcResult()

    self.matchList = self.tableLayer.GameBetList;

    self:receiveMatchListInfo()
end

function LishijingcaiLayer:receiveMatchListInfo()
    local msg = self.matchList;

    local resultData = {};
    for k,v in pairs(msg) do
        if self.tableLayer.GametypeEcList[v.lEventID] then
            for k1,v1 in pairs(self.tableLayer.GametypeEcList[v.lEventID].info) do
                --根据名字寻找eventid
                local eventId = self.EventID;
                if tonumber(v1.game_id) == tonumber(v.lMatchID) and (tonumber(v1.event_id)==eventId or eventId == 0) then
                    local oneData = {};
                    --时间的组成
                    local dateStr = "星期";

                    if tonumber(os.date("%w",v.lTime)) == 1 then
                        dateStr = dateStr.."一 ";
                    elseif tonumber(os.date("%w",v.lTime)) == 2 then
                        dateStr = dateStr.."二 ";
                    elseif tonumber(os.date("%w",v.lTime)) == 3 then
                        dateStr = dateStr.."三 ";
                    elseif tonumber(os.date("%w",v.lTime)) == 4 then
                        dateStr = dateStr.."四 ";
                    elseif tonumber(os.date("%w",v.lTime)) == 5 then
                        dateStr = dateStr.."五 ";
                    elseif tonumber(os.date("%w",v.lTime)) == 6 then
                        dateStr = dateStr.."六 ";
                    elseif tonumber(os.date("%w",v.lTime)) == 0 then
                        dateStr = dateStr.."日 ";
                    end

                    oneData.dateStr = dateStr..os.date("%m月%d日 %H:%M",v.lTime);

                    oneData.matchInfo = v1.match_info.." "..v1.teamInfo[1].name.."-"..v1.teamInfo[2].name;

                    oneData.guessInfo = "";
                    oneData.winInfo = "";
                    --获取竞猜项
                    for k2,v2 in pairs(v1.guess) do
                        if tonumber(v2.bet_id) == v.lBetID then
                            oneData.guessInfo = v2.bet_title;
                            --获取投注项
                            for k3,v3 in pairs(v2.items) do
                                if v.lBetNumID == tonumber(v3.items_bet_num) then
                                    oneData.winInfo = v3.items_odds_name.."("..(tonumber(v3.items_odds)/100)..")";
                                end
                            end
                        end
                    end
                    --投注
                    oneData.touScore = v.lBetScore;

                    local fanScore = v.lWinScore;
                    --比赛没有结束 显示玩家可能赢得钱
                    if v.lMatchState == 0 or v.lMatchState == 1 then
                        fanScore = math.floor(v.lBetScore*v.lBetRat/100);
                    end
                    --如果得分是负数则显示0
                    if fanScore<0 then
                        fanScore = 0;
                    end

                    oneData.fanScore = fanScore;

                    local str = "";
                    if v.lMatchState == 0 then
                        str = "未开始";
                    elseif v.lMatchState == 1 then
                        str = "未结束";
                    else
                        str = "已结束";
                    end

                    oneData.statetip = str

                    table.insert(resultData,oneData);
                end
            end
        end
    end

    --luaDump(resultData,"处理数据");

    self:updateMatchLlist(resultData);
end

function LishijingcaiLayer:updateMatchLlist(matchList)
    -- LoadingLayer:removeLoading();

    self.ScrollView_list:removeAllChildren();

    local size = self.ScrollView_list:getInnerContainerSize();
    -- luaDump(matchList,"matchList")
    for k,v in pairs(matchList) do
        
        local layout = ccui.Layout:create();
        layout:setContentSize(cc.size(1559, 175));

        local LishijingcaiNodeInfo = require("competition.LishijingcaiNodeInfo")
        local node = LishijingcaiNodeInfo.new(k,v);
        -- node:setReceiveCallBack(function(vipid) VipInfo:sendVipRewardRequest(vipid); end)
        node:setPosition(139.5,0);
        layout:addChild(node)
        self.ScrollView_list:pushBackCustomItem(layout);

    end
end


return LishijingcaiLayer
