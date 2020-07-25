local JoinVipLayer = class("JoinVipLayer",PopLayer)

function JoinVipLayer:ctor()
    self.super.ctor(self, PopType.none)

    self:initData();
    self:initUI();
    self:bindEvent()
end

function JoinVipLayer:bindEvent()
    self:pushEventInfo(VipInfo,"applyjoinGuildReq",handler(self, self.receiveApplyjoinGuildReq))
    self:pushEventInfo(VipInfo,"applyjoinGuildInfo",handler(self, self.receiveApplyjoinGuildInfo))
end

function JoinVipLayer:initData()
    self.RoomID = ""; 
end

function JoinVipLayer:initUI()
    -- self:setLocalZOrder(999)
    self:setName("JoinVipLayer");
    VipInfo:sendGuildSendMoneyReq();
    self.colorLayer:setOpacity(150)
    local bg = ccui.ImageView:create("newExtend/vip/join/join_bg.png")
    bg:setPosition(getScreenCenter())
    self:addChild(bg)
    self.bg = bg;
    
    -- iphoneXFit(self.bg,1)

    self.size = bg:getContentSize()

    local title = ccui.ImageView:create("newExtend/vip/join/join_shurutinghaoma.png")
    title:setPosition(self.size.width/2,self.size.height-60)
    self.bg:addChild(title)

    local closeBtn = ccui.Button:create("hall/common/close.png","hall/common/close-on.png")
    closeBtn:setPosition(self.size.width-40,self.size.height-50)
    closeBtn:setTag(1)
    bg:addChild(closeBtn)
    closeBtn:onTouchClick(function(sender) self:onClickBtn(sender) end,1)

    local shuruk = ccui.ImageView:create("newExtend/vip/join/join_shuzikuang.png")
    shuruk:setPosition(self.size.width*0.5,self.size.height*0.72)
    self.bg:addChild(shuruk)

    local posX = 60;
    for i=1,5 do
        -- local di = ccui.ImageView:create("newExtend/vip/join/join_shuzikuang.png")
        -- di:setPosition(80+90*i,self.size.height*0.75)
        -- self.bg:addChild(di)

        local zitiao = FontConfig.createWithCharMap("", "newExtend/vip/join/zhitiaolan.png", 30, 41, "0");
        -- zitiao:setPosition(di:getContentSize().width/2,di:getContentSize().height/2)
        zitiao:setPosition(self.size.width*0.5+100*(i-3),self.size.height*0.72)
        self.bg:addChild(zitiao)
        self["AtlasLabel_id"..i] = zitiao
    end

    local tempIndex = 0;
    local y = 330;
    for i=1,12 do
        local btn = nil;
        local index = i;
        index = i;
        if i == 4 or i == 7 or i == 10 then
            tempIndex = 0;
            y = y - 80
        end
        if i <= 9 then --1-9
            btn = ccui.Button:create("newExtend/vip/join/join_"..index..".png","newExtend/vip/join/join_"..index.."-on.png")
            btn:setTag(i)
            btn:addClickEventListener(function(sender) self:onClickShuzi(sender) end)
        end

        if i == 10 then
            btn = ccui.Button:create("newExtend/vip/join/join_qingchu.png","newExtend/vip/join/join_qingchu-on.png")
            btn:setTag(3)
            btn:addClickEventListener(function(sender) self:onClickBtn(sender) end)
        end

        if i == 11 then
            btn = ccui.Button:create("newExtend/vip/join/join_0.png","newExtend/vip/join/join_0-on.png")
            btn:setTag(0)
            btn:addClickEventListener(function(sender) self:onClickShuzi(sender) end)
        end

        if i == 12 then
            btn = ccui.Button:create("newExtend/vip/join/join_shanchu.png","newExtend/vip/join/join_shanchu-on.png")
            btn:setTag(2)
            btn:addClickEventListener(function(sender) self:onClickBtn(sender) end)
        end

        btn:setPosition(160+tempIndex*210,y)
        self.bg:addChild(btn)
        tempIndex = tempIndex + 1;
    end

    local vipTip = cc.Label:createWithSystemFont("VIP厅内可用金币为除去绑定送金奖励后的金币", "Arial" ,20 ,FontConfig.colorWhite);
    vipTip:setPosition(self.size.width*0.5,self.size.height*0.08)
    vipTip:setAnchorPoint(cc.p(0.5,0.5))
    vipTip:setVisible(false)
    bg:addChild(vipTip)
    self.vipTip = vipTip;

end

function JoinVipLayer:onClickShuzi(sender)
    local tag = sender:getTag();
    if string.len(self.RoomID) < 5 then
        self.RoomID = self.RoomID..tag;
    else
        return;
    end
    if string.len(self.RoomID) >= 5 then
        self.AtlasLabel_id5:setString(tag)
        -- LoadingLayer:createLoading(FontConfig.gFontConfig_22, GBKToUtf8("正在加入VIP厅..."), LOADING):removeTimer()
        VipInfo:sendGetGuildInfo(self.RoomID)
    else
        local index = string.len(self.RoomID);
        self["AtlasLabel_id"..index]:setString(tag)
    end 
end

function JoinVipLayer:onClickBtn(sender)
    local tag = sender:getTag();
    if tag == 1 then
        self:removeSelf();
    elseif tag == 2 then
        local index = string.len(self.RoomID);
        if index > 0 then
            self["AtlasLabel_id"..index]:setString("")
            self.RoomID = string.sub(self.RoomID,1,string.len(self.RoomID)-1)
        end
    elseif tag == 3 then
        self.RoomID = ""
        for i=1,5 do
            self["AtlasLabel_id"..i]:setString("")
        end
    end
end

function JoinVipLayer:receiveApplyjoinGuildReq(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 then--查询成功，存在
        -- VipInfo:sendApplyjoinGuild(data[1].GuildID);
       self:IsSureApply(data[1])
        self.RoomID = ""
        for i=1,5 do
            self["AtlasLabel_id"..i]:setString("")
        end
    elseif code== 1 then--不存在
        addScrollMessage("厅不存在")
    elseif code== 2 then--
        addScrollMessage("玩家信息错误")
    elseif code== 3 then--
        addScrollMessage("重复申请")
    end

end

function JoinVipLayer:receiveApplyjoinGuildInfo(data)
    local data = data._usedata;
    local code = data[2]
    if self.prompt then
        -- self.prompt:delayCloseLayer(0)
    end
    if code == 0 then--申请成功
        addScrollMessage("申请成功")
        self:removeSelf()
    elseif code == 1 then
        addScrollMessage("厅不存在")
    elseif code == 2 then
        addScrollMessage("玩家信息错误")
    elseif code == 3 then
        addScrollMessage("重复申请")
    elseif code == 4 then
        addScrollMessage("您已经是厅成员")
    else
        addScrollMessage("申请失败")
    end

    
end

function JoinVipLayer:IsSureApply(data)
    local text = "是否加入"..data.GuildName.."(厅ID:"..data.GuildID..")\n\n".."厅主昵称:"..data.OwnerName.."\n\n".."厅主ID:"..data.OwnerID
    local prompt = GamePromptLayer:create();
    prompt:showPrompt(GBKToUtf8(text),true,true);
    prompt.btnCancel:loadTextures("newExtend/vip/common/chongxinshuru.png","newExtend/vip/common/chongxinshuru-on.png")
    prompt.btnOk:loadTextures("newExtend/vip/common/querenjiaru.png","newExtend/vip/common/querenjiaru-on.png")
    prompt.btnOk:setPositionY(prompt.btnOk:getPositionY()+20)
    prompt.btnCancel:setPositionY(prompt.btnCancel:getPositionY()+20)
    prompt.textPrompt:setFontSize(30);
    prompt.textPrompt:setColor(cc.c3b(250, 200, 3))
    prompt:setBtnClickCallBack(function() 
        -- addScrollMessage("---------------")
        VipInfo:sendApplyjoinGuild(data.GuildID);
    end,nil);
    self.prompt = prompt;
end

return JoinVipLayer
