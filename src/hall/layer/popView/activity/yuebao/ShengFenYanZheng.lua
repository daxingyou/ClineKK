

local ShengFenYanZheng = class("ShengFenYanZheng",PopLayer)

function ShengFenYanZheng:create()
    return ShengFenYanZheng.new();
end

function ShengFenYanZheng:ctor()
    self.super.ctor(self, PopType.middle)

    self:initUI();
    self:bindEvent();
end

function ShengFenYanZheng:initUI()

    self:drawUiSet();
    
end

function ShengFenYanZheng:bindEvent()
    self:pushEventInfo(BankInfo,"bankPassword",handler(self,self.receiveSetPassword))
end

--设置二级密码界面
function ShengFenYanZheng:drawUiSet()
    luaPrint("设置二级密码界面");
    self.sureBtn:removeSelf()

    local title = ccui.ImageView:create("activity/yuebao/yeb_shenfenyanzheng.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title) 

    local text = ccui.ImageView:create("activity/yuebao/yeb_zi1.png");
    text:setPosition(self.size.width/2,self.size.height/2+150)
    self.bg:addChild(text) 

    --二级密码
    local key = ccui.ImageView:create("activity/yuebao/yeb_erjimima.png")
    key:setAnchorPoint(1,0.5)
    key:setPosition(self.size.width/2-200,self.size.height/2)
    self.bg:addChild(key)

    self.pwdTextEdit = createEditBox(key,"请输入6-20位数字和英文组合",cc.EDITBOX_INPUT_FLAG_PASSWORD)

    --二级密码
    local keySure = ccui.ImageView:create("activity/yuebao/yeb_erciqueren.png")
    keySure:setAnchorPoint(1,0.5)
    keySure:setPosition(self.size.width/2-200,self.size.height/2-100)
    self.bg:addChild(keySure)

    self.againPwdTextEdit = createEditBox(keySure,"确认密码",cc.EDITBOX_INPUT_FLAG_PASSWORD)

    local bindBtn_set = ccui.Button:create("activity/yuebao/ok.png","activity/yuebao/ok-on.png");
    bindBtn_set:setPosition(self.size.width/2,120);
    self.bg:addChild(bindBtn_set);
    bindBtn_set:onClick(function(sender) self:onClickSure(sender) end)


end


function ShengFenYanZheng:onClick(sender)
    local layer = require("layer.popView.BindPhoneLayer"):create()
    display.getRunningScene():addChild(layer)
end

function ShengFenYanZheng:onClick_xiugai(sender)
    
end

function ShengFenYanZheng:onClickSure(sender)
    local pwd = self.pwdTextEdit:getText()

    if isEmptyString(pwd) then
        luaPrint("密码为空")
        addScrollMessage("密码为空")
        return
    end

    local ret,msg = verifyNumberAndEnglish(pwd)
    if not ret then
        luaPrint("您输入的密码包含非法字符")
        addScrollMessage(msg)
        return
    end

    if #pwd < 6 then
        luaPrint("您输入的密码小于6位，请重输")
        addScrollMessage("您输入的密码小于6位，请重输")
        return
    end

    if #pwd > 20 then
        luaPrint("您输入的密码大于20位，请重输")
        addScrollMessage("您输入的密码大于20位，请重输")
        return
    end

    local againPwd = self.againPwdTextEdit:getText()

    if isEmptyString(againPwd) then
        luaPrint("确认密码为空")
        addScrollMessage("确认密码为空")
        return
    end

    if pwd ~= againPwd then
        luaPrint("两次密码不一致")
        addScrollMessage("两次密码不一致")
        return
    end

    local newPwd = MD5_CTX:MD5String(pwd)

    if newPwd == PlatformLogic.loginResult.szMD5Pass then
        addScrollMessage("保险箱密码不能与登录密码一致")
        return
    end

    self.newPwd = newPwd

    YuEBaoInfo:sendSetBankPasswordRequest(newPwd)
end

function ShengFenYanZheng:receiveSetPassword(data)
    local data = data._usedata

    if data.ret == 0 then
        luaPrint("设置余额宝密码成功")
        globalUnit:setBankPwd(self.newPwd)
        PlatformLogic.loginResult.bSetBankPass = 1
        addScrollMessage("设置余额宝密码成功")
        local layer = require("layer.popView.activity.yuebao.YuEBaoLayer"):create()
        --layer.popView.activity.yuebao.YuEBaoLayer
        if layer then
            display.getRunningScene():addChild(layer)
        end
        dispatchEvent("registerLayerUpCallBack");
        self:delayCloseLayer()
    else
        luaPrint("设置余额宝密码失败")
        addScrollMessage("设置余额宝密码失败")
    end
end

function ShengFenYanZheng:onClickClose(sender)
    dispatchEvent("registerLayerUpCallBack");
    self:delayCloseLayer()
end

return ShengFenYanZheng
