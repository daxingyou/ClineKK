local PopUpLayer = class("PopUpLayer",PopLayer)

function PopUpLayer:ctor()
	self.super.ctor(self,PopType.middle)

	self:initUI()

end

function PopUpLayer:initUI()

	self.sureBtn:removeSelf()

    local title = ccui.ImageView:create("common/guizeTitle.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title)

    local listView = ccui.ListView:create()
    listView:setAnchorPoint(cc.p(0.5,0.5))
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(self.size.width*0.95, self.size.height*0.65))
    listView:setPosition(self.size.width*0.5,self.size.height*0.5)
    self.bg:addChild(listView)
    self.listView = listView

    local line = ccui.ImageView:create("Image/help.png")

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self.listView:getContentSize().width, line:getContentSize().height))

    local size = layout:getContentSize()
    line:setPosition(size.width/2,size.height/2)    
    layout:addChild(line)

    self.listView:pushBackCustomItem(layout)

    --隐藏listview的滑动条
    self.listView:setScrollBarEnabled(false);
end

return PopUpLayer
