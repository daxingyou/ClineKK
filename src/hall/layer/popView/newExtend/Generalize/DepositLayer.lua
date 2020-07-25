local DepositLayer =  class("DepositLayer", PopLayer)

--代理预提现界面
function DepositLayer:create(parent,iType)
    local layer = DepositLayer.new(parent,iType);
    layer:setName("DepositLayer");
    return layer;
end

local FishModel = false;
--构造函数 iType 1 提现 2 预提
function DepositLayer:ctor(parent,iType)
    self.super.ctor(self,PopType.middle)

    self.parent = parent;
    self.iType = iType;

    self:InitData();

    self:InitUI();

    self:pushEventInfo(ExtendInfo,"ExtendTotalCount",handler(self, self.onExtendTotalCount));
 
end

function DepositLayer:onExtendTotalCount(data)
    local msg = data._usedata;

    self:RefreshMaxMoney();
end

function DepositLayer:InitData()
    --最大的预提
    self.MaxMoney = 0;
    self.SelectTag = 1;
end

function DepositLayer:InitUI()
    self.sureBtn:removeSelf();

    local title;
    if self.iType == 1 then
        title = ccui.ImageView:create("Deposit/dailitixian.png");
    else
        title = ccui.ImageView:create("Deposit/dailiyutixian.png");
    end
    title:setPosition(self.size.width/2,self.size.height-50);
    self.bg:addChild(title);

    local infoBg = ccui.ImageView:create("Deposit/dise.png");
    infoBg:setPosition(self.size.width/2,self.size.height/2+50);
    self.bg:addChild(infoBg);

    --预提按钮
    local tixianBtn;
    if self.iType == 1 then
        tixianBtn = ccui.Button:create("Deposit/shenqingbtn.png","Deposit/shenqingbtn-on.png")
    else
        tixianBtn = ccui.Button:create("Deposit/sheniqngyutibtn.png","Deposit/sheniqngyutibtn-on.png")
    end
    tixianBtn:setPosition(self.size.width/2,130);
    self.bg:addChild(tixianBtn);
    tixianBtn:onClick(handler(self,self.onClickBtnCallBack));

    --显示标签图片
    if self.iType == 1 and FishModel == false then
        local image = ccui.ImageView:create("Deposit/tubiao.png");
        image:setPosition(infoBg:getContentSize().width/2,300);
        infoBg:addChild(image);

        --创建checkbox
        local checkbox1 = ccui.CheckBox:create("Deposit/gouxuanqian.png","Deposit/gouxuanhou.png",ccui.TextureResType.localType);
        checkbox1:setAnchorPoint(cc.p(0,0.5));
        checkbox1:setPosition(cc.p(100, 230));
        checkbox1:setSelected(false);
        checkbox1:setEnabled(true);
        infoBg:addChild(checkbox1);

        --提现到游戏的字
        local checkPos = cc.p(checkbox1:getPosition());
        local tixianText = ccui.ImageView:create("Deposit/tixian.png");
        tixianText:setAnchorPoint(0,0.5);
        tixianText:setPosition(checkPos.x+60,checkPos.y);
        infoBg:addChild(tixianText);

        local textPos = cc.p(tixianText:getPosition());
        local textSize = tixianText:getContentSize();
        local checkbox2 = ccui.CheckBox:create("Deposit/gouxuanqian.png","Deposit/gouxuanhou.png",ccui.TextureResType.localType);
        checkbox2:setAnchorPoint(cc.p(0,0.5));
        checkbox2:setPosition(cc.p(textPos.x+20+textSize.width,textPos.y));
        checkbox2:setSelected(false);
        checkbox2:setEnabled(true);
        infoBg:addChild(checkbox2);

        local checkPos = cc.p(checkbox2:getPosition());
        local zhifubaoText = ccui.ImageView:create("Deposit/zhifubao.png");
        zhifubaoText:setAnchorPoint(0,0.5);
        zhifubaoText:setPosition(checkPos.x+60,checkPos.y);
        infoBg:addChild(zhifubaoText);

        local textPos = cc.p(zhifubaoText:getPosition());
        local textSize = zhifubaoText:getContentSize();
        local checkbox3 = ccui.CheckBox:create("Deposit/gouxuanqian.png","Deposit/gouxuanhou.png",ccui.TextureResType.localType);
        checkbox3:setAnchorPoint(cc.p(0,0.5));
        checkbox3:setPosition(cc.p(textPos.x+20+textSize.width,textPos.y));
        checkbox3:setSelected(false);
        checkbox3:setEnabled(true);
        infoBg:addChild(checkbox3);

        local checkPos = cc.p(checkbox3:getPosition());
        local yinhangText = ccui.ImageView:create("Deposit/yinhangka.png");
        yinhangText:setAnchorPoint(0,0.5);
        yinhangText:setPosition(checkPos.x+60,checkPos.y);
        infoBg:addChild(yinhangText);

        local SetAllCheckSelect = function(tag)
            if tag == 1 then
                checkbox1:setSelected(true);
                checkbox2:setSelected(false);
                checkbox3:setSelected(false);
            elseif tag == 2 then
                checkbox1:setSelected(false);
                checkbox2:setSelected(true);
                checkbox3:setSelected(false);
            elseif tag == 3 then
                checkbox1:setSelected(false);
                checkbox2:setSelected(false);
                checkbox3:setSelected(true);
            end
        end

         --默认提现到游戏
        if PlatformLogic.loginResult.BankNo ~= "" then
            self.SelectTag = 3;
            SetAllCheckSelect(self.SelectTag);
        else   
            checkbox1:setSelected(true);
        end
        checkbox1:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                self.SelectTag = 1;
                SetAllCheckSelect(self.SelectTag);
            elseif eventType == ccui.TouchEventType.canceled then
                SetAllCheckSelect(self.SelectTag);
            end
        end)


        checkbox2:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if PlatformLogic.loginResult.Alipay == "" then
                    addScrollMessage("未绑定支付宝");
                    SetAllCheckSelect(self.SelectTag);
                    return;
                end

                self.SelectTag = 2;
                SetAllCheckSelect(self.SelectTag);
            elseif eventType == ccui.TouchEventType.canceled then
                SetAllCheckSelect(self.SelectTag);
            end
        end)


        checkbox3:addTouchEventListener(function(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if PlatformLogic.loginResult.BankNo == "" then
                    addScrollMessage("未绑定银行卡");
                    SetAllCheckSelect(self.SelectTag);
                    return;
                end
                self.SelectTag = 3;
                SetAllCheckSelect(self.SelectTag);
            elseif eventType == ccui.TouchEventType.canceled then
                SetAllCheckSelect(self.SelectTag);
            end
        end)

        -- local str = ccui.Text:create();
        -- str:setFontSize(24);
        -- str:setAnchorPoint(cc.p(0.5,0));
        -- str:setString("提现到支付宝或者银行卡需收取"..(SettlementInfo:getConfigInfoByID(37)/10).."%手续费");
        -- str:setPosition(self.bg:getContentSize().width/2,40);
        -- self.bg:addChild(str); 

        local addWidth = 100;--向后移动100
        --支付宝关闭
        local zhifubao = 0
        local bank = 1
        if zhifubao == 0 and bank ~= 0 then
            checkbox2:setVisible(false);
            zhifubaoText:setVisible(false);

            --调整位置
            checkbox1:setPositionX(checkbox1:getPositionX()+addWidth);
            tixianText:setPositionX(tixianText:getPositionX()+addWidth);
            checkbox3:setPositionX(tixianText:getPositionX()+20+tixianText:getContentSize().width);
            yinhangText:setPositionX(checkbox3:getPositionX()+60);

        --银行卡关闭
        elseif bank == 0 and zhifubao ~= 0 then
            checkbox3:setVisible(false);
            yinhangText:setVisible(false);

            --调整位置
            checkbox1:setPositionX(checkbox1:getPositionX()+addWidth);
            tixianText:setPositionX(tixianText:getPositionX()+addWidth);
            checkbox2:setPositionX(tixianText:getPositionX()+20+tixianText:getContentSize().width);
            zhifubaoText:setPositionX(checkbox2:getPositionX()+60);
            --全部关闭
        elseif bank == 0 and zhifubao == 0 then
            checkbox2:setVisible(false);
            zhifubaoText:setVisible(false);

            checkbox3:setVisible(false);
            yinhangText:setVisible(false);

            checkbox1:setPositionX(checkbox1:getPositionX()+addWidth+150);
            tixianText:setPositionX(tixianText:getPositionX()+addWidth+150);
        end
    end

    local image = nil;
    local shengyuPosY = 155;
    if self.iType == 1 then
        image = ccui.ImageView:create("Deposit/shengyu.png");
    else
        image = ccui.ImageView:create("Deposit/shengyutixian.png");
        shengyuPosY = 220;
    end

    if FishModel then
        shengyuPosY = 220;
    end

    image:setAnchorPoint(1,0.5);
    image:setPosition(380,shengyuPosY);
    infoBg:addChild(image);


    local image = nil;
    if self.iType == 1 then
        image = ccui.ImageView:create("Deposit/shenqing.png");
    else
        image = ccui.ImageView:create("Deposit/shenqingtixian.png");
    end
    image:setAnchorPoint(1,0.5);
    image:setPosition(380,80);
    infoBg:addChild(image);


    --显示剩余提现金币的底
    local ziBg = ccui.ImageView:create("Deposit/shurukuang.png");
    ziBg:setAnchorPoint(0,0.5);
    ziBg:setPosition(420,shengyuPosY);
    infoBg:addChild(ziBg);

    --获取最大提现金额
    if self.parent.totalCount then
        if self.iType == 1 then
            self.MaxMoney = self.parent.totalCount.AgencyReward;
        else
            self.MaxMoney = self.parent.totalCount.LeftProvisionsReward;
        end
    end

    local remainMoney = FontConfig.createWithSystemFont(goldConvert(self.MaxMoney),30,FontConfig.colorWhite);
    remainMoney:setAnchorPoint(cc.p(0,0.5));
    remainMoney:setPosition(20,ziBg:getContentSize().height/2);
    ziBg:addChild(remainMoney);
    self.remainMoney = remainMoney;
    --添加元字
    local zi = ccui.ImageView:create("Deposit/yuan.png");
    zi:setAnchorPoint(0,0.5);
    zi:setPosition(ziBg:getPositionX()+ziBg:getContentSize().width+10,shengyuPosY);
    infoBg:addChild(zi);

    --申请预提
    local ziBg = ccui.ImageView:create("Deposit/shurukuang.png");
    ziBg:setAnchorPoint(0,0.5);
    ziBg:setPosition(420,80);
    infoBg:addChild(ziBg);

    local bgSize = ziBg:getContentSize();
    bgSize.width = bgSize.width - 20;
    self.souTextEdit = ccui.EditBox:create(bgSize,ccui.Scale9Sprite:create())
    self.souTextEdit:setAnchorPoint(0,0.5);
    self.souTextEdit:setPosition(cc.p(20, ziBg:getContentSize().height/2))
    self.souTextEdit:setFontSize(30)
    self.souTextEdit:setPlaceHolder("输入金额");
    self.souTextEdit:setPlaceholderFontColor(cc.c3b(255,255,255));
    ziBg:addChild(self.souTextEdit)
    self.souTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
    self.souTextEdit:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL);

    --添加元字
    local zi = ccui.ImageView:create("Deposit/yuan.png");
    zi:setAnchorPoint(0,0.5);
    zi:setPosition(ziBg:getPositionX()+ziBg:getContentSize().width+10,80);
    infoBg:addChild(zi);

    --创建最大按钮
    local maxBtn = ccui.Button:create("Deposit/zuida.png","Deposit/zuida-on.png")
    maxBtn:setAnchorPoint(0,0.5);
    maxBtn:setPosition(zi:getPositionX()+zi:getContentSize().width+10,80);
    infoBg:addChild(maxBtn);
    maxBtn:onClick(handler(self,self.SetMaxMoney));

end

function DepositLayer:SetMaxMoney(sender)
    self.souTextEdit:setText(goldConvert(self.MaxMoney));
end

--预提按钮
function DepositLayer:onClickBtnCallBack(sender)
    if tonumber(self.souTextEdit:getText()) == nil then
        addScrollMessage("输入有误，请重新输入");
        return;
    end

    local lScore = tonumber(self.souTextEdit:getText());

    if lScore then
        lScore = lScore*100;
    end

    luaPrint("申请提现",lScore);

    if lScore == 0 then
        addScrollMessage("提现金币不足");
        return;
    end

    if self.iType == 1 then--提现
        if self.SelectTag == 1 then--提现到游戏
            if lScore < SettlementInfo:getConfigInfoByID(serverConfig.dailiYouxi) then
                addScrollMessage("提现到游戏不得少于"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiYouxi)/100));
                return;
            end

            ExtendInfo:sendGetCash(4,lScore);
        elseif self.SelectTag == 2 then
            if lScore < SettlementInfo:getConfigInfoByID(serverConfig.dailiZifubao) then
                addScrollMessage("提现到支付宝不得少于"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiZifubao)/100));
                return;
            end
            ExtendInfo:sendGetCash(7,lScore);
        elseif self.SelectTag == 3 then
            if lScore < SettlementInfo:getConfigInfoByID(serverConfig.dailiYinhangka) then
                addScrollMessage("提现到银行卡不得少于"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiYinhangka)/100));
                return;
            end
            ExtendInfo:sendGetCash(5,lScore);
        end
    elseif self.iType == 2 then
       if lScore < SettlementInfo:getConfigInfoByID(serverConfig.dailiYouxi) then
            addScrollMessage("提现到游戏不得少于"..(SettlementInfo:getConfigInfoByID(serverConfig.dailiYouxi)/100));
            return;
        end
        ExtendInfo:sendGetProvisions(lScore);
    end

    self.souTextEdit:setText("");

end

function DepositLayer:onEditBoxHandler(event)
    local name = event.name;

    if name == "began" then
    elseif name == "ended" then
        self:SetMoney();

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            event.target:setText(self.souTextEdit:getText());
        end)));
    elseif name == "return" then

    elseif name == "changed" then
    end
end

function DepositLayer:SetMoney()
    local text = self.souTextEdit:getText();
    local num = tonumber(text);

    if num == nil then
        if text ~= "" then
            addScrollMessage("输入有误，请重新输入");
        end
        return;
    end

    if num*100>=self.MaxMoney then
        num = self.MaxMoney/100;
    end

    if num == 0 then
        num = "";
    end

    self.souTextEdit:setText(num);

end

function DepositLayer:RefreshMaxMoney()
    if self.parent.totalCount then
        if self.iType == 1 then
            self.MaxMoney = self.parent.totalCount.AgencyReward;
        else
            self.MaxMoney = self.parent.totalCount.LeftProvisionsReward;
        end
    end

    self.remainMoney:setString(goldConvert(self.MaxMoney));
    self.souTextEdit:setText("");
end

return DepositLayer;