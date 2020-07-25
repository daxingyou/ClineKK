local OpenVipLayer = class("OpenVipLayer",PopLayer)

function OpenVipLayer:create(data,tingData)
    return OpenVipLayer.new(data,tingData)
end

function OpenVipLayer:ctor(data,tingData)
    self.super.ctor(self, PopType.small)
    self.data = data;
    self.tingData = tingData;

    self:initData();

    self:initUI()
    self:bindEvent()

end

function OpenVipLayer:initData()
    self.isChooseEnd = false;--是否已经选择游戏
    self.chooseGame = ""
    self.chooseRoom = ""
end

function OpenVipLayer:bindEvent()
    self:pushEventInfo(VipInfo,"createGuildInfo",handler(self, self.receiveCreateGuildInfo))
end

function OpenVipLayer:initUI()
    --self.sureBtn:removeSelf()
    self:setLocalZOrder(9999)
    local title = ccui.ImageView:create("newExtend/vip/openvip/kaitongvip.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title)

    -- iphoneXFit(self.bg,1)
    
    local tingmingchen = ccui.ImageView:create("newExtend/vip/openvip/tingmingchen.png")
    tingmingchen:setPosition(self.size.width*0.2,self.size.height*0.7)
    self.bg:addChild(tingmingchen)

    self.nameTextEdit = createEditBox(tingmingchen,"请输入厅名称",cc.EDITBOX_INPUT_MODE_SINGLELINE,1)
    self.nameTextEdit:onEditHandler(handler(self, self.onEditBoxNameHandler))
    self.nameTextEdit:setMaxLength(4)

    local ting = ccui.ImageView:create("newExtend/vip/openvip/ting.png")
    ting:setPosition(self.size.width*0.82,self.size.height*0.7)
    self.bg:addChild(ting)

    local wanfa = ccui.ImageView:create("newExtend/vip/openvip/wanfa.png")
    wanfa:setPosition(self.size.width*0.34+5,self.size.height*0.57)
    self.bg:addChild(wanfa)

    -- local xuanze = ccui.ImageView:create("newExtend/vip/openvip/xuanze.png")
    -- xuanze:setPosition(self.size.width*0.42,self.size.height*0.57)
    -- self.bg:addChild(xuanze)

     --消息
    local btn = ccui.Button:create("newExtend/vip/openvip/shezhi.png","newExtend/vip/openvip/shezhi-on.png")
    btn:setPosition(self.size.width*0.6,self.size.height*0.57)
    self.bg:addChild(btn)
    btn:onClick(function(sender) self:onClickBtn(sender) end)

    local yixuanze = ccui.ImageView:create("newExtend/vip/openvip/yixuanze.png")
    yixuanze:setPosition(self.size.width*0.73,self.size.height*0.57)
    yixuanze:setVisible(false)
    self.bg:addChild(yixuanze)
    self.yixuanze = yixuanze

    local shuishoubili = ccui.ImageView:create("newExtend/vip/openvip/shuishoubili.png")
    shuishoubili:setPosition(self.size.width*0.18,self.size.height*0.45)
    self.bg:addChild(shuishoubili)

    -- local  str = "请输入税收比例"..(self.data.iRateMin/10).."~"..(self.data.iRateMax/10);
    local  str = ""
    self.shuiShouTextEdit = createEditBox(shuishoubili,str,cc.EDITBOX_INPUT_MODE_PHONENUMBER,1)
    self.shuiShouTextEdit:onEditHandler(handler(self, self.onEditShuiShouBoxHandler))
    self.shuiShouTextEdit:setMaxLength(6)
    self.shuiShouTextEdit:setTouchEnabled(false)
    self.shuiShouTextEdit:setText(self.data.iRateMin/10)

    -- local baifen = cc.Label:createWithSystemFont("%","Arial", 30);    
    -- baifen:setPosition(cc.p(self.size.width*0.82,self.size.height*0.45))
    -- baifen:setColor(cc.c3b(65, 97, 120));
    -- self.bg:addChild(baifen)

    local baifen = ccui.ImageView:create("newExtend/vip/openvip/%.png")
    baifen:setPosition(self.size.width*0.82,self.size.height*0.45)
    self.bg:addChild(baifen)

    local text3 = cc.Label:createWithSystemFont("其中"..(self.data.iRateBase/10).."%固定为平台收取","Arial", 26);    
    text3:setPosition(cc.p(self.size.width*0.5,self.size.height*0.34))
    text3:setColor(cc.c3b(206, 74, 77));
    self.bg:addChild(text3)
   
    self:updateSureBtnImage("newExtend/vip/openvip/chuangjian.png","newExtend/vip/openvip/chuangjian-on.png")
    self.sureBtn:setPosition(cc.p(self.size.width*0.5,self.size.height*0.22))

    if self.tingData then
        title:loadTexture("newExtend/vip/openvip/vipshezhi.png");
        self.sureBtn:loadTextures("newExtend/vip/openvip/baocun.png","newExtend/vip/openvip/baocun-on.png");
        self.yixuanze:setVisible(true);
        self.nameTextEdit:setText(self.tingData.GuildName)
        self.shuiShouTextEdit:setText(self.tingData.iTaxRate/10)
        self.chooseGame = self.tingData.GameStates;
        self.chooseRoom = self.tingData.RoomStates;
        self.isChooseEnd = true;
    end
end

function OpenVipLayer:setChooseRule(chooseGame,chooseRoom)
    self.isChooseEnd = true;
    -- addScrollMessage("chooseRoom"..chooseRoom)
    
    self.chooseGame = chooseGame;
    self.chooseRoom = chooseRoom;
    self.yixuanze:setVisible(true);
end

--设置按钮
function OpenVipLayer:onClickBtn( ... )
    local layer = require("hall.layer.popView.newExtend.vip.TypeSetLayer"):create(self.isChooseEnd,self.chooseGame,self.chooseRoom)
    layer:setChooseEndCallback(function (chooseGame,chooseRoom)
        self:setChooseRule(chooseGame,chooseRoom)
    end)
    display.getRunningScene():addChild(layer)
end

--创建按钮
function OpenVipLayer:onClickSure(sender)
    local name = self.nameTextEdit:getText()
    if  name =="" or isEmoji(name) then
         addScrollMessage("请输入正确厅名称")
         return;
    end
    local len = string.len(name)
    if len>4*3 then
        addScrollMessage("厅名称最多4个字")
        return;
    end

    local sui = self.shuiShouTextEdit:getText()
    if sui =="" then
         addScrollMessage("请输入税收比例")
         return;
    end
    local num = tonumber(sui)
    local len = string.len(sui)
    if num == nil or num<self.data.iRateMin/10 or num>self.data.iRateMax/10 or len>3 then
        if num ~= nil then
            if num <self.data.iRateMin/10 then
                self.shuiShouTextEdit:setText(self.data.iRateMin/10)
            elseif num>self.data.iRateMax/10 then
                self.shuiShouTextEdit:setText(self.data.iRateMax/10)
            end
        end
        addScrollMessage("税收比例填写错误,应填写"..string.format("%.1f", self.data.iRateMin/10).."~"..string.format("%.1f", self.data.iRateMax/10))
        return;
    end

    if self.chooseGame == "" then
        addScrollMessage("请选择厅规则")
        return;
    end

    if self.tingData then
        if self.callback then
            self.callback(name,self.chooseGame,self.chooseRoom,num*10)
        end
    else
        VipInfo:sendBuildGuild(name,self.chooseGame,self.chooseRoom,num*10)
    end
    -- local layer = require("vip.VipHallLayer"):create(self.chooseGame,self.chooseRoom)
    -- display.getRunningScene():addChild(layer)
end

function OpenVipLayer:receiveCreateGuildInfo(data)
    local data = data._usedata;
    local code = data[2]
    if code== 0 then--创建成功
        -- local layer = require("vip.VipHallLayer"):create(data[1])
        -- display.getRunningScene():addChild(layer)
        VipInfo:sendGetVipInfo();
        self:removeSelf()
    elseif code== 1 then--只能创建一个
        addScrollMessage("每人只能创建一个厅")
    elseif code== 2 then--名字已被占用
        addScrollMessage("名字已被占用")
     elseif code== 3 then--推广员人数不满足
        addScrollMessage("推广员人数不满足")
    end

end

function OpenVipLayer:setChooseEndCallback(callback)
    self.callback = callback;
end

--游戏名字
function OpenVipLayer:onEditBoxNameHandler(event)
    
end

--手续费
function OpenVipLayer:onEditShuiShouBoxHandler(event)
    
end

return OpenVipLayer
