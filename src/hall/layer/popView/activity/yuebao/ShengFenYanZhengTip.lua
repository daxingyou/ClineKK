

local ShengFenYanZhengTip = class("ShengFenYanZhengTip",PopLayer)

function ShengFenYanZhengTip:create(_type)
    return ShengFenYanZhengTip.new(_type);
end

function ShengFenYanZhengTip:ctor(_type)
    self.super.ctor(self, PopType.middle)

    self._type = _type or 1;--1表示进转出 2表示转账

    self:initUI();

    self:bindEvent()
end

function ShengFenYanZhengTip:bindEvent()
    self:pushEventInfo(YuEBaoInfo,"bankPassword",handler(self,self.receiveSetPassword))
    self:pushGlobalEventInfo("updatePwd",handler(self, self.receiveUpdatePwd))
end

--绘制输入密码界面
function ShengFenYanZhengTip:initUI()
    luaPrint("输入密码界面");
    --self.sureBtn:removeSelf()

    local title = ccui.ImageView:create("activity/yuebao/yeb_shenfenyanzheng.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title) 

    local text = ccui.ImageView:create("activity/yuebao/yeb_zi2.png");
    text:setPosition(self.size.width/2,self.size.height/2+150)
    self.bg:addChild(text) 

    --二级密码
    local key = ccui.ImageView:create("activity/yuebao/yeb_erjimima.png")
    key:setAnchorPoint(1,0.5)
    key:setPosition(self.size.width/2-250,self.size.height/2)
    self.bg:addChild(key)

    self.keyTextEdit = createEditBox(key,"请输入二级密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

    local forgetPwdBtn = ccui.Button:create("activity/yuebao/yeb_wangjimima.png","activity/yuebao/yeb_wangjimima-on.png");
    forgetPwdBtn:setPosition(self.size.width*0.85-50,self.size.height*0.5);
    self.bg:addChild(forgetPwdBtn);
    forgetPwdBtn:onClick(function(sender) self:onClickForgetPwd() end)
end

function ShengFenYanZhengTip:onClickSure(sender)
    local pwd = self.keyTextEdit:getText()

    if isEmptyString(pwd) then
        luaPrint("密码为空")
        addScrollMessage("密码为空")
        return
    end

    local newPwd = MD5_CTX:MD5String(pwd)

    self.newPwd = newPwd

    BankInfo:sendCheckBankPasswordRequest(newPwd)
end

function ShengFenYanZhengTip:receiveSetPassword(data)
    local data = data._usedata

    if data.ret == 0 then
        luaPrint("设置余额宝成功")
        addScrollMessage("余额宝密码校验成功")
        globalUnit:setBankPwd(self.newPwd)
        local layer;
        if self._type == 1 then
            layer = require("layer.popView.activity.yuebao.ZhuanRuChuLayer"):create()
        else
            layer = require("layer.popView.activity.yuebao.TransferLayer"):create()
        end
        if layer then
            display.getRunningScene():addChild(layer)
        end
        self:delayCloseLayer()
    else
        luaPrint("设置余额宝密码失败")
        addScrollMessage("余额宝密码校验失败")
    end
end

function ShengFenYanZhengTip:receiveUpdatePwd(data)
    local data = data._usedata

    if data == 0 then
        local layer = require("layer.popView.activity.yuebao.YuEBaoLayer"):create()
        if layer then
            display.getRunningScene():addChild(layer)
        end
        self:delayCloseLayer()
    end
end

function ShengFenYanZhengTip:onClickForgetPwd(sender)
    if globalUnit:getLoginType() ~= accountLogin then
        addScrollMessage("请升级到正式账号")
        return
    end

    local layer = require("layer.popView.ForgetPwdLayer"):create(1)

    display.getRunningScene():addChild(layer)

    -- addScrollMessage("请联系游戏客服");
end


return ShengFenYanZhengTip
