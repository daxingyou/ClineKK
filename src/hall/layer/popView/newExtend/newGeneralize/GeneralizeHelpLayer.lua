--帮助
local GeneralizeHelpLayer =  class("GeneralizeHelpLayer", PopLayer)

--创建类
function GeneralizeHelpLayer:create()
	local layer = GeneralizeHelpLayer.new();

	return layer;
end

--构造函数
function GeneralizeHelpLayer:ctor()
	self.super.ctor(self,PopType.small)

    self:InitData();

    self:InitUI();

end

--进入
function GeneralizeHelpLayer:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function GeneralizeHelpLayer:bindEvent()

end

function GeneralizeHelpLayer:InitData()
    
end

function GeneralizeHelpLayer:InitUI()
    self.sureBtn:removeSelf()

    local title = ccui.ImageView:create("newExtend/newGeneralize/bangzhuxinxi.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title)

    local helpImage = ccui.ImageView:create("newExtend/newGeneralize/shuomingneirong.png")
    helpImage:setPosition(self.size.width/2,self.size.height/2)
    self.bg:addChild(helpImage)
    
end

return GeneralizeHelpLayer;