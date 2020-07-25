local HelpLayer = class("HelpLayer",PopLayer)

function HelpLayer:ctor()
    self.super.ctor(self, PopType.small)

    self:initUI()
end

function HelpLayer:initUI()
    self.sureBtn:removeSelf()

    local title = ccui.ImageView:create("activity/duobao/zhuanpan/helpTitle.png")
    title:setPosition(self.size.width/2,self.size.height-90)
    self.bg:addChild(title)

    local listView = ccui.ListView:create()
    listView:setAnchorPoint(cc.p(0.5,0))
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(755,410))
    listView:setPosition(self.size.width*0.5,81)
    listView:setScrollBarEnabled(false);
    self.bg:addChild(listView)
    self.listView = listView

    local line = ccui.ImageView:create("activity/duobao/zhuanpan/info.png")

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self.listView:getContentSize().width, line:getContentSize().height))

    local size = layout:getContentSize()
    line:setPosition(size.width/2,size.height/2)
    layout:addChild(line)

    self.listView:pushBackCustomItem(layout)
end

return HelpLayer
