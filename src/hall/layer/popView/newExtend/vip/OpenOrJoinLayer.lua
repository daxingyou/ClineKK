local OpenOrJoinLayer = class("OpenOrJoinLayer",PopLayer)

function OpenOrJoinLayer:create(data,isOnlyOne)
    return OpenOrJoinLayer.new(data,isOnlyOne)
end

function OpenOrJoinLayer:ctor(data,isOnlyOne)
    self.super.ctor(self, PopType.middle)
    self.data = data;
    self.isOnlyOne = isOnlyOne;
    self:bindEvent()
    self:initUI() 
end

function OpenOrJoinLayer:bindEvent()
    self:pushEventInfo(SettlementInfo, "configInfo", handler(self, self.receiveConfigInfo))
end

function OpenOrJoinLayer:initUI()
    --self.sureBtn:removeSelf()
    -- self:setLocalZOrder(999)
    local title = ccui.ImageView:create("newExtend/vip/openvip/vipting.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title)
    
    -- iphoneXFit(self.bg,1)

    -- local layout = ccui.Layout:create()
    -- layout:setContentSize(cc.size(self.size.width-70,self.size.height-280))
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
    -- -- layout:setBackGroundColor(cc.c3b(150, 200, 255))
    -- layout:setBackGroundColorOpacity(60)    --设置透明
    -- layout:setPosition(cc.p(35,180))
    -- self.bg:addChild(layout)
   
    -- local contents = cc.Label:createWithSystemFont("","Arial", 30);
    -- contents:setString("发送二维码邀请10个玩家,即可开启一个属于你自己的VIP厅。\n"..
    --     "供其他玩家娱乐,享受开场子的感觉。你还可以通过输入VIP\n"..
    --     "厅ID申请加入其他VIP厅!")
    -- contents:setColor(cc.c3b(65, 97, 120));
    -- contents:setPosition(cc.p(490,200))
    -- layout:addChild(contents)

    local contents = ccui.ImageView:create("newExtend/vip/openvip/contents.png")
    contents:setPosition(cc.p(self.size.width*0.5,self.size.height*0.70))
    self.bg:addChild(contents)

    local renshu = FontConfig.createWithCharMap(self.data.iCountNeed, "newExtend/vip/openvip/zitiao.png", 18, 24, "+");
    renshu:setPosition(235,110)
    contents:addChild(renshu)

    -- local text1 = cc.Label:createWithSystemFont("下级推广人数:","Arial", 30);    
    -- text1:setPosition(cc.p(400,self.size.height*0.45))
    -- text1:setColor(cc.c3b(65, 97, 120));
    -- self.bg:addChild(text1)
    local text1 = ccui.ImageView:create("newExtend/vip/openvip/xiajituiguang.png")
    text1:setPosition(self.size.width*0.32,self.size.height*0.45)
    self.bg:addChild(text1)

    local text2 = cc.Label:createWithSystemFont(self.data.iCountNow,"Arial", 30);    
    text2:setPosition(cc.p(self.size.width*0.46,self.size.height*0.45))
    text2:setColor(cc.c3b(255, 114, 0));
    self.bg:addChild(text2)

    local text3 = cc.Label:createWithSystemFont("/ "..self.data.iCountNeed,"Arial", 30);    
    text3:setPosition(cc.p(self.size.width*0.5,self.size.height*0.45))
    text3:setColor(cc.c3b(0, 162, 255));
    self.bg:addChild(text3)

    --消息
    local btn = ccui.Button:create("newExtend/vip/openvip/shuoming.png","newExtend/vip/openvip/shuoming-on.png")
    btn:setPosition(cc.p(self.size.width*0.60,self.size.height*0.45))
    self.bg:addChild(btn)
    btn:onClick(function(sender) self:onClickBtn(sender) end)

    local img_help = ccui.ImageView:create("newExtend/vip/openvip/bangzhuwenzi.png")
    img_help:setPosition(cc.p(self.size.width*0.7-10,self.size.height*0.54))
    self.bg:addChild(img_help)
    self.img_help = img_help;

    local size = img_help:getContentSize();

    local text1 = cc.Label:createWithSystemFont("直线下级推广人数满"..self.data.iCountNeed.."人即可开通VIP厅","Arial", 20);    
    text1:setPosition(cc.p(size.width/2,size.height/2+5))
    text1:setColor(cc.c3b(200, 0, 210));
    img_help:addChild(text1)

     --开通vip
    local openvipBtn = ccui.Button:create("newExtend/vip/openvip/kaitong.png","newExtend/vip/openvip/kaitong-on.png")
    openvipBtn:setPosition(cc.p(self.size.width*0.7,self.size.height*0.11))
    self.bg:addChild(openvipBtn)
    openvipBtn:onClick(function(sender) self:onClickOpenVip(sender) end)

    if self.data.iCountNow < self.data.iCountNeed then
        openvipBtn:setEnabled(false)
    end
   
    self:updateSureBtnImage("newExtend/vip/openvip/shenqingjiaru.png","newExtend/vip/openvip/shenqingjiaru-on.png")
    self.sureBtn:setPosition(cc.p(self.size.width*0.3,self.size.height*0.11))
    
    if self.isOnlyOne then
        self.sureBtn:setVisible(false)
        openvipBtn:setPosition(cc.p(self.size.width*0.5,self.size.height*0.11))
    end

    local xianzhi = FontConfig.createWithSystemFont(FormotGameNickName("推广链接"..getQrUrl(),60),28)
    xianzhi:setPosition(self.size.width*0.5,self.size.height*0.35)
    self.bg:addChild(xianzhi)
    xianzhi:setColor(cc.c3b(150, 191, 125));
    self.xianzhi = xianzhi

    local btn = ccui.Button:create("newExtend/generalize/Image/fuzhilianjie.png","newExtend/generalize/Image/fuzhilianjie-on.png")
    btn:setPosition(cc.p(self.size.width*0.5,self.size.height*0.25))
    self.bg:addChild(btn)
    btn:onClick(function(sender) self:CopyUrlClick(sender) end)
end

--拷贝链接
function OpenOrJoinLayer:CopyUrlClick()
    if copyToClipBoard(globalUnit.tuiguanUrlQr) then
        addScrollMessage("推广地址复制成功")
    end
end

function OpenOrJoinLayer:onClickBtn()
    self.img_help:setVisible(not self.img_help:isVisible())
end

--申请加入
function OpenOrJoinLayer:onClickSure(sender)
    
    display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.JoinVipLayer"):create())
   --display.getRunningScene():addChild()
   -- self:removeSelf()
end

--开通vip
function OpenOrJoinLayer:onClickOpenVip(sender)
    
    --display.getRunningScene():addChild(require("hall.layer.popView.activity.SignIn.SignInLayer"):create())
    display.getRunningScene():addChild(require("hall.layer.popView.newExtend.vip.OpenVipLayer"):create(self.data))
    -- self:removeSelf()
end

function OpenOrJoinLayer:receiveConfigInfo(data)
    local data = data._usedata

    if data.id == 9 and self.xianzhi then
       self.xianzhi:setString(getQrUrl())
    end
end

function OpenOrJoinLayer:onClickClose(sender)
    dispatchEvent("registerLayerUpCallBack");
    self:delayCloseLayer()
end

return OpenOrJoinLayer
