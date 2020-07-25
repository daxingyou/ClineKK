--下注界面

local XiazhuLayer = class("XiazhuLayer", BaseWindow)

function XiazhuLayer:create(data,num,itype)-- itype 第几局   num 第几个区
	return XiazhuLayer.new(data,num,itype);
end

function XiazhuLayer:ctor(data,num,itype)
    self.super.ctor(self, true, true);

    self.data = data;
    self.num = num;
    self.itype = itype;

    self:initData();

    self:initUI()
end

function XiazhuLayer:initData()  
    self:pushEventInfo(CompetInfo, "UserMoneyUpdate", handler(self, self.onReceiveUserPoint))--
    self:pushGlobalEventInfo("ASS_GP_USERINFO_GET",handler(self, self.receiveRefreshScoreBank))
end


function XiazhuLayer:initUI()
    local winSize = cc.Director:getInstance():getWinSize();
    local bg = ccui.ImageView:create("jingcai/xiazhu/kuang.png");
    bg:setPosition(winSize.width/2,winSize.height/2);
    self:addChild(bg);
    local bgsize = bg:getContentSize();

    local touzhuData = self.data.guess[self.num];


    --显示标题
    local title = FontConfig.createWithSystemFont(touzhuData.bet_title,40,FontConfig.colorWhite);
    title:setPosition(bgsize.width/2,bgsize.height*0.85);
    bg:addChild(title);

   --赔率
    local rate = tonumber(touzhuData.items[self.itype].items_odds)/100;
    local str = "("..touzhuData.items[self.itype].items_odds_name..")";

    self.rate = rate;
    local peilv = FontConfig.createWithCharMap(rate,"jingcai/xiazhu/zitiao1.png", 30, 40, '+');
    peilv:setPosition(bgsize.width*0.33,bgsize.height*0.72);
    peilv:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(peilv);

   
    local name = FontConfig.createWithSystemFont(str,30,FontConfig.colorWhite);
    name:setPosition(bgsize.width*0.48,bgsize.height*0.72);
    name:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(name);

    --可赢
    local ying = FontConfig.createWithCharMap("","jingcai/xiazhu/zitiao2.png", 30, 40, '+');
    ying:setPosition(bgsize.width*0.30,bgsize.height*0.55);
    ying:setAnchorPoint(cc.p(0, 0.5));
    bg:addChild(ying);
    self.ying = ying;

    --关闭
    local guanbi = ccui.Button:create("jingcai/xiazhudan/guanbi.png","jingcai/xiazhudan/guanbi-on.png")
    guanbi:setPosition(bgsize.width*0.96,bgsize.height*0.87);
    bg:addChild(guanbi,100);
    guanbi:setName("guanbi")
    guanbi:onClick(handler(self,self.onClickBtnCallBack));


    local sou = ccui.ImageView:create("jingcai/xiazhu/shurukuang.png")
    sou:setAnchorPoint(1,0.5)
    sou:setPosition(bgsize.width*0.72,bgsize.height*0.36)
    bg:addChild(sou)

    -- self.souTextEdit = createEditBox(sou,"输入游戏名称",cc.EDITBOX_INPUT_MODE_ANY)
    self.souTextEdit = ccui.EditBox:create(sou:getContentSize(),ccui.Scale9Sprite:create())
    self.souTextEdit:setPosition(cc.p(sou:getContentSize().width/2, sou:getContentSize().height/2))
    self.souTextEdit:setFontSize(30)
    self.souTextEdit:setPlaceHolder("输入投注金额")
    sou:addChild(self.souTextEdit)
    self.souTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
    self.souTextEdit:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL);


    local baoxiangui = ccui.ImageView:create("zhuye/baoxianxiang.png");
    baoxiangui:setAnchorPoint(0,0);
    baoxiangui:setPosition(10,80);
    bg:addChild(baoxiangui);

    self.baoxianguinum = FontConfig.createWithCharMap(goldConvertFour(PlatformLogic.loginResult.i64Bank),"zhuye/zitiao.png", 15, 21, '+');
    self.baoxianguinum:setPosition(cc.p(60,22));
    self.baoxianguinum:setAnchorPoint(cc.p(0, 0.5));
    baoxiangui:addChild(self.baoxianguinum);

    
    local jinbi = ccui.ImageView:create("zhuye/jinbi.png");
    jinbi:setAnchorPoint(0,0);
    jinbi:setPosition(10,20);
    bg:addChild(jinbi);

    self.jinbinum = FontConfig.createWithCharMap(goldConvert(PlatformLogic.loginResult.i64Money),"zhuye/zitiao.png", 15, 21, '+');
    self.jinbinum:setPosition(cc.p(60,22));
    self.jinbinum:setAnchorPoint(cc.p(0, 0.5));
    jinbi:addChild(self.jinbinum);

    --全部
    local allBtn = ccui.Button:create("jingcai/xiazhu/quanbu.png","jingcai/xiazhu/quanbu-on.png")
    allBtn:setPosition(bgsize.width*0.85,bgsize.height*0.36);
    bg:addChild(allBtn);
    allBtn:onClick(handler(self,self.onClickBtnCallBack));
    allBtn:setName("allBtn")

    --立即投注
    local touzhu = ccui.Button:create("jingcai/xiazhu/lijitouzhu.png","jingcai/xiazhu/lijitouzhu-on.png")
    touzhu:setPosition(bgsize.width*0.5,bgsize.height*0.15);
    bg:addChild(touzhu);
    touzhu:onClick(handler(self,self.onClickBtnCallBack));
    touzhu:setName("touzhu")


    -- schedule(self, function() self.souTextEdit:setText(self.souTextEdit:getText()); end, 0.5);

end

function XiazhuLayer:onReceiveUserPoint()
    self.jinbinum:setText(goldConvert(PlatformLogic.loginResult.i64Money));
    self.souTextEdit:setText("");
    self:SetMoney();
end

function XiazhuLayer:onClickBtnCallBack(sender)
    local name = sender:getName();
  
    if name == "touzhu" then
        local lScore = tonumber(self.souTextEdit:getText());
        if lScore == nil then
            addScrollMessage("请输入金额");
            return;
        end

        local msg = {};

        msg.EventID = self.data.event_id;
        msg.MatchID = self.data.game_id;
        msg.BetID = self.data.guess[self.num].bet_id;
        msg.BetNumID = self.data.guess[self.num].items[self.itype].items_bet_num;
        msg.UserID = PlatformLogic.loginResult.dwUserID;
        msg.lScore = lScore*100;

        RoomLogic:send(RoomMsg.MDM_GP_EC_INFO, GameMsg.ASS_GP_EC_BET,msg,GameMsg.MSG_GP_EC_BET);

    elseif name == "allBtn" then
        self.souTextEdit:setText(goldConvert(PlatformLogic.loginResult.i64Money));
        self:SetMoney();
    elseif name == "guanbi" then
        self:delayCloseLayer();
    end

end

function XiazhuLayer:onEditBoxHandler(event)
    local name = event.name;

    if name == "began" then
        --todo
    elseif name == "ended" then
        -- local text = event.target:getText();
        -- local num = tonumber(text);
        -- if num then
        --     self.ying:setString(string.format("%.2f", num*self.rate-num))
        -- end
        self:SetMoney();

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            event.target:setText(self.souTextEdit:getText());
        end)));
    elseif name == "return" then
        -- self:SetMoney();
        -- event.target:setText(self.souTextEdit:getText());
    elseif name == "changed" then
        -- self:SetMoney();
        -- event.target:setText(self.souTextEdit:getText());
    end
end

--显示输赢
function XiazhuLayer:SetMoney()
    local text = self.souTextEdit:getText();
    local num = tonumber(text);

    if num == nil then
        self.ying:setString("");
        if text ~= "" then
            addScrollMessage("输入有误，请重新输入");
        end
        return;
    end

    if num*100>=PlatformLogic.loginResult.i64Money then
        num = PlatformLogic.loginResult.i64Money/100;
    end

    self.souTextEdit:setText(num);

    self.ying:setString(string.format("%.2f", math.floor(num*100*self.rate-num*100)/100));

end

function XiazhuLayer:receiveRefreshScoreBank(data)
    local data = data._usedata
    if data then
        self.jinbinum:setText(goldConvert(data.i64WalletMoney))
        self.baoxianguinum:setText(goldConvertFour(data.i64BankMoney))
    end
end

return XiazhuLayer
