

local YuEBaoHelp = class("YuEBaoHelp",PopLayer)

function YuEBaoHelp:create()
    return YuEBaoHelp.new();
end

function YuEBaoHelp:ctor()
    self.super.ctor(self, PopType.moreBig)

    self:initUI()
end

function YuEBaoHelp:initUI()
    self.sureBtn:removeSelf()

    self:updateBg("activity/yuebao/commonBg1.png");
    
    self:updateCloseBtnPos(0,-40)

    local title = ccui.ImageView:create("activity/yuebao/title_guize.png")
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

    local line = ccui.ImageView:create("activity/yuebao/yeb_neirong.png")

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self.listView:getContentSize().width, line:getContentSize().height))

    local size = layout:getContentSize()
    line:setPosition(size.width/2,size.height/2)    
    layout:addChild(line)

    self.listView:pushBackCustomItem(layout)

end

return YuEBaoHelp
