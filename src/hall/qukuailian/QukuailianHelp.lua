local QukuailianHelp = class("QukuailianHelp",PopLayer)
local QukuailianVideo = require("qukuailian.QukuailianVideo")

function QukuailianHelp:ctor()
	playEffect("hall/sound/qukuailian.mp3")
	self.super.ctor(self,PopType.middle)

	self:initUI()

end

function QukuailianHelp:initUI()

	self.sureBtn:setVisible(false)


	local title = ccui.ImageView:create("qukuailian/image2/qklian_qukuailianjieshao.png");
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	self.ScrollView_list = ccui.ListView:create();
    self.ScrollView_list:setAnchorPoint(cc.p(0.5,0.5));
    self.ScrollView_list:setDirection(ccui.ScrollViewDir.vertical);
    self.ScrollView_list:setBounceEnabled(true);
    self.ScrollView_list:setContentSize(cc.size(1000, 410));
    self.ScrollView_list:setColor(cc.c3b(0, 228, 225))
    self.ScrollView_list:setPosition(self.bg:getContentSize().width/2+10,self.bg:getContentSize().height/2+5);
    if self.bg then
    	self.bg:addChild(self.ScrollView_list);
	end

	local Image_content = ccui.ImageView:create("qukuailian/image2/qklian_jieshaoneirong.png")
	Image_content:setAnchorPoint(cc.p(0.5,1));
	--Image_content:setPosition(self.size.width/2,self.size.height-30)
	self.ScrollView_list:addChild(Image_content)

	local btnVideo = ccui.Button:create("qukuailian/image2/qklian_kanshiping.png","qukuailian/image2/qklian_kanshiping-on.png","qukuailian/image2/qklian_kanshiping-on.png");
	Image_content:addChild(btnVideo);
	btnVideo:setPosition(800,1038);
	btnVideo:setName("Button_video");
	btnVideo:onClick(handler(self,self.onBtnClickEvent))
	
	local Button_open = ccui.Button:create("qukuailian/image2/qklian_open-on.png","qukuailian/image2/open-on.png","qukuailian/image2/open-on.png");
	Image_content:addChild(Button_open);
	Button_open:setPosition(590,348);
	Button_open:setName("Button_open");
	Button_open:onClick(handler(self,self.onBtnClickEvent))
end


function QukuailianHelp:onBtnClickEvent(sender)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if "Button_video" == btnName then --返回
		local winSize = cc.Director:getInstance():getWinSize();
		local layer = QukuailianVideo.new();
		layer:ignoreAnchorPointForPosition(false);
		layer:setAnchorPoint(cc.p(0.5,0.5));
		layer:setPosition(winSize.width/2,winSize.height/2);
		self:addChild(layer);
	elseif "Button_open" == btnName then
		openWeb("http://kovan.etherscan.io");
	end

end

return QukuailianHelp
