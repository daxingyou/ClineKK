local MyAdDepositNode = class("MyAdDepositNode", BaseWindow)
--我的预提

local MaxLength = 4;

--创建类
function MyAdDepositNode:create(parent)
    local layer = MyAdDepositNode.new(parent);
    layer:setName("MyAdDepositNode");
    return layer;
end

--构造函数
function MyAdDepositNode:ctor(parent)
    self.parent = parent;
    self.super.ctor(self, 0, false);
    local uiTable = {
        Button_help = "Button_help",
        Image_content = "Image_content",
        Button_up = "Button_up",
        Button_down = "Button_down",
        Text_page = "Text_page",
        Panel_template = "Panel_template",
        Text_playerId = "Text_playerId",
        Text_playerSum = "Text_playerSum",
        Text_playerDeposit = "Text_playerDeposit",
        Text_playerMoney = "Text_playerMoney",
        Button_tixian = "Button_tixian",
    }

    loadNewCsb(self,"Node_MyAdDeposit",uiTable);

    self:InitData();

    self:InitUI();

end

--进入
function MyAdDepositNode:onEnter()
    self:bindEvent();
    self.super.onEnter(self); 
    ExtendInfo:sendGetCashLog(3);
end

function MyAdDepositNode:bindEvent()
    self:pushEventInfo(ExtendInfo,"ExtendProvisions",handler(self, self.onReceiveProvisions));
    self:pushEventInfo(ExtendInfo,"ReceiveGetCashLog",handler(self, self.onReceiveGetCashLog));
    self:pushEventInfo(ExtendInfo,"ExtendTotalCount",handler(self, self.onExtendTotalCount));
end

function MyAdDepositNode:InitData()
    --设置默认的页数为第一页
    self.pageIndex = 1;
end

function MyAdDepositNode:InitUI()
    --设置帮助弹出界面
    if self.Button_help then
        self.Button_help:onClick(handler(self,self.HelpClick));
    end

    --将模板数据隐藏
    self.Panel_template:setVisible(false);

    self.Text_page:setString("1/1");

    --设置上一页和下一页的按钮
    if self.Button_up then
        self.Button_up:onClick(handler(self,self.UpClick));
    end

    if self.Button_down then
        self.Button_down:onClick(handler(self,self.DownClick));
    end

    --显示预提界面
    if self.Button_tixian then
        self.Button_tixian:onClick(handler(self,self.TixianClick));
    end

    self:RefreshPlayerInfo();

    ---模拟数据
    self.data = {};
    -- for i = 1,40 do
    --     table.insert(self.data,{time=1553075784+i,id = 14548,money=4544,type = "提现到银行卡",idCard = 4444849494,status = "已成功"});
    -- end

    self:RefreshScene();
end

function MyAdDepositNode:onReceiveProvisions(data)
    local msg = data._usedata;

    luaDump(msg,"预提现");

    if msg.ret == 0 then--收到提现成功 发送log 和 total消息
        ExtendInfo:sendGetCashLog(3);
        ExtendInfo:sendExtendTotalCountRequest();
    end

end


function MyAdDepositNode:onReceiveGetCashLog(data)
    local msg = data._usedata;

    self:RefreshScene(msg);

end

function MyAdDepositNode:onExtendTotalCount(data)
    local msg = data._usedata;

    self:RefreshPlayerInfo();

end

function MyAdDepositNode:RefreshPlayerInfo()
    if self.parent.totalCount then
        self.Text_playerId:setString(PlatformLogic.loginResult.dwUserID);
        self.Text_playerSum:setString(goldConvert(self.parent.totalCount.LeftProvisionsReward+self.parent.totalCount.TodayProvisionsScore));
        self.Text_playerDeposit:setString(goldConvert(self.parent.totalCount.TodayProvisionsScore));
        self.Text_playerMoney:setString(goldConvert(self.parent.totalCount.LeftProvisionsReward));
    end
end

--帮助界面
function MyAdDepositNode:HelpClick(sender)
    if self.parent then
        local PopUpLayer = require(GeneralizePath..".PopUpLayer");
        local layer = PopUpLayer:create();
        self.parent:addChild(layer);
    end
end

--重置页面信息
function MyAdDepositNode:RefreshScene(data)
    if data then
        self.data = data;
    end

    self.pageIndex = 1;

    if #self.data > 0 then
        self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#self.data/MaxLength));
    else
        self.Text_page:setString("1/1");
    end

    self:RefreshPlayerData(self.data);

end

--刷新信息
function MyAdDepositNode:RefreshPlayerData(data)
    --清除界面的显示的数据
    for i =1,MaxLength do
        local node = self.Image_content:getChildByName("data"..i);
        if node then
            node:removeFromParent();
        end
    end

    local bgSize = self.Image_content:getContentSize();

    for k,v in pairs(data) do
        if (self.pageIndex-1)*MaxLength < k and self.pageIndex*MaxLength >= k then
            local node = self.Panel_template:clone();
            node:setVisible(true);
            node:setName("data"..(k-(self.pageIndex-1)*MaxLength));
            node:setPosition(0,bgSize.height-(k-(self.pageIndex-1)*MaxLength-1)*node:getContentSize().height);
            self.Image_content:addChild(node);

            --设置数据
            local Text_time = node:getChildByName("Text_time");
            if Text_time then
                Text_time:setString(""..os.date("%Y",v.CollectTime).."."..os.date("%m",v.CollectTime).."."..os.date("%d",v.CollectTime));
            end

            local Text_id = node:getChildByName("Text_id");
            if Text_id then
                Text_id:setString(v.OrderNum);
            end

            local Text_money = node:getChildByName("Text_money");
            if Text_money then
                Text_money:setString(goldConvert(v.lScore));
            end

            local Text_type = node:getChildByName("Text_type");
            if Text_type then
                local str = "提现到游戏";
                if v.bType == 5 then
                    str = "提现到银行卡";
                end

                Text_type:setString(str);
            end

            local Text_idCard = node:getChildByName("Text_idCard");
            if Text_idCard then
                local str = "无";
                if v.BankNo ~= "" then
                    local str1 = string.sub(v.BankNo,1,4);
                    local str2 = string.sub(v.BankNo,-4);
                    str = str1.."*******"..str2;
                end

                Text_idCard:setString(str);
            end

            local Text_status = node:getChildByName("Text_status");
            if Text_status then

                local str = "锁定";
                Text_status:setTextColor(cc.c3b(255,255,255));
                if v.Operate == 0 then
                    str = "审核中";
                    Text_status:setTextColor(cc.c3b(105,152,238));
                elseif v.Operate == 1 then
                    str = "已发放";
                    Text_status:setTextColor(cc.c3b(241,73,56));
                elseif v.Operate == 2 then
                    str = "已退回";
                    Text_status:setTextColor(cc.c3b(211,194,46));
                end
            end

        end
    end
end

--上一页的按钮
function MyAdDepositNode:UpClick(sender)
    if self.pageIndex>1 and #self.data>0 then
        self.pageIndex = self.pageIndex - 1;
        self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#self.data/MaxLength));
        self:RefreshPlayerData(self.data);
    else
        addScrollMessage("已经是第一页");
    end
end

--下一页的按钮
function MyAdDepositNode:DownClick(sender)
    if math.ceil(#self.data/MaxLength)>self.pageIndex and #self.data>0 then
        self.pageIndex = self.pageIndex + 1;
        self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#self.data/MaxLength));
        self:RefreshPlayerData(self.data);
    else
        addScrollMessage("已经是最后一页");
    end
end

--预提按钮
function MyAdDepositNode:TixianClick(sender)
    local DepositLayer = require(GeneralizePath..".DepositLayer");
    local layer = DepositLayer:create(self.parent,2);
    self.parent:addChild(layer);
end

return MyAdDepositNode;