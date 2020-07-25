local HelpLayer = class("HelpLayer",PopLayer)
local nameId = 40010005;

function HelpLayer:ctor()
    self.super.ctor(self, PopType.middle)
    self:pushGlobalEventInfo("ASS_GP_GET_RAT",handler(self, self.refreshGameRat))
    self:initUI()
end

function HelpLayer:initUI()
    self.sureBtn:removeSelf()
    
    if globalUnit:getIsEnterRoomMode() then
        nameId = 40010001
    else
        nameId = 40010005
    end

    SettlementInfo:sendGameRat(nameId);

   local title = ccui.ImageView:create("common/guizeTitle.png")
    title:setPosition(self.size.width/2,self.size.height-50)
    self.bg:addChild(title)

    local listView = ccui.ListView:create()
    listView:setAnchorPoint(cc.p(0.5,0.5))
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(self.size.width*0.9, self.size.height*0.65-20))
    listView:setPosition(self.size.width*0.5,self.size.height*0.5)
    self.bg:addChild(listView)
    self.listView = listView

    local line = ccui.ImageView:create("helpLayer/guize.png")
    line:setScaleX(0.95)

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self.listView:getContentSize().width, line:getContentSize().height))

    local size = layout:getContentSize()
    line:setPosition(size.width/2,size.height/2)    
    layout:addChild(line)

    self.listView:pushBackCustomItem(layout)
end

function HelpLayer:refreshGameRat(data)
    local data = data._usedata;
    if data.NameID ~= nameId or data.Rat == 0 then
        return;
    end

    local text_tips = self.bg:getChildByName("text_tips");
    if text_tips then
        text_tips:removeFromParent();
    end

    local text_tips = ccui.Text:create("捕获鱼后将收取盈利部分的"..(data.Rat/10).."%作为服务费。",FONT_PTY_TEXT,20);
    text_tips:setName("text_tips");
    text_tips:setPosition(cc.p(90,80))
    text_tips:setAnchorPoint(0,0.5);
    self.bg:addChild(text_tips);
    if globalUnit.nowTingId > 0 then
        text_tips:setVisible(false)
    end

end

return HelpLayer
