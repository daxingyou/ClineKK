

local BindPhoneTiShi = class("BindPhoneTiShi",PopLayer)

function BindPhoneTiShi:create()
    return BindPhoneTiShi.new();
end

function BindPhoneTiShi:ctor()
    self.super.ctor(self, PopType.middle)

    self:initUI()
end

function BindPhoneTiShi:initUI()
    self.sureBtn:removeSelf()

    local title = ccui.ImageView:create("activity/yuebao/yeb_tishi.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title) 

    local bindBtn = ccui.Button:create("activity/yuebao/yeb_qubangding.png","activity/yuebao/yeb_qubangding-on.png");
    bindBtn:setPosition(self.size.width/2,310);
    self.bg:addChild(bindBtn);
    bindBtn:onClick(function(sender) self:onClick(sender) end)

    local text = ccui.ImageView:create("activity/yuebao/yeb_zi.png");
    text:setPosition(self.size.width/2,self.size.height/2+50);
    self.bg:addChild(text);

end

function BindPhoneTiShi:onClick(sender)
    local layer = require("layer.popView.BindPhoneLayer"):create()
    if layer then
        display.getRunningScene():addChild(layer)
    end
    self:delayCloseLayer()
end

return BindPhoneTiShi
