local PopUpLayer = class("PopUpLayer",function() return display.newLayer() end)

function PopUpLayer:create()
    local layer = PopUpLayer:new();
	layer:initUI()
    return layer;
end

--透明层
function PopUpLayer:initUI()
	-- 蒙板
	local winSize = cc.Director:getInstance():getWinSize()
	local layout = ccui.Layout:create();
    layout:setContentSize(cc.size(1559, 720));
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid) --设置颜色
    layout:setBackGroundColor(cc.c3b(51, 51, 51))
    layout:setBackGroundColorOpacity(180)    --设置透明
    layout:setTouchEnabled(true);
    layout:setAnchorPoint(cc.p(0.5,0.5));
    layout:setPosition(getScreenCenter())
	self:addChild(layout)

    local bg = ccui.ImageView:create("superfruitgame/superfruit_bg/sf_bg_help.png")
	bg:setPosition(getScreenCenter())
	self:addChild(bg)

    self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0.5));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setContentSize(cc.size(960, 430));
    self.ScrollView_list:setColor(cc.c3b(0, 228, 225))
    self.ScrollView_list:setPosition(bg:getContentSize().width/2+10,bg:getContentSize().height*0.5);
    bg:addChild(self.ScrollView_list);

    self.size = bg:getContentSize()

    local Image_content = ccui.ImageView:create("superfruitgame/superfruit_bg/sf_img_rule.png")
	Image_content:setAnchorPoint(cc.p(0.5,1));
	self.ScrollView_list:addChild(Image_content)

    local closeBtn = ccui.Button:create()
    closeBtn:loadTextures("sf_game_guanbi.png","sf_game_guanbi_on.png","sf_game_guanbi_on.png",UI_TEX_TYPE_PLIST);
	closeBtn:setPosition(self.size.width-45,self.size.height-55)
	bg:addChild(closeBtn)
	closeBtn:onTouchClick(function(sender) self:onClickClose(sender) end,1)
end

function PopUpLayer:onClickClose(sender)
    transition.scaleTo(self, {scale=0,time=0.3,easing="BACKIN",onComplete= function() self:removeSelf() end})
end

return PopUpLayer