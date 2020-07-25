local HelpLayer =  class("HelpLayer", BaseWindow)

function HelpLayer:create(viewParent)
	return HelpLayer.new(viewParent);
end

function HelpLayer:ctor(viewParent)
	self.super.ctor(self, 0, false);

	local uiTable = {
		Panel_root = "Panel_root",
		Panel_Help = "Panel_Help",
		Image_dialog = "Image_dialog",
		ScrollView_help = "ScrollView_help",
		Image_help = "Image_help",	
	

	}

	loadNewCsb(self,"sanzhangpai/szp_help",uiTable)

	self.m_parent = viewParent;
	self:initData();

	self:initUI();
end

function HelpLayer:initData()
	
end

function HelpLayer:initUI()
	-- self.Image_dialog:loadTexture("hall/common/commonBg1.png");
	self.Image_dialog:setVisible(false);
	local winSize = cc.Director:getInstance():getWinSize();
	local bg = ccui.ImageView:create("hall/common/commonBg1.png");
	self:addChild(bg,-10);
	bg:setPosition(winSize.width/2,winSize.height/2);

	local text_tips = ccui.Text:create("每局游戏结算将收取盈利部分的"..(SettlementInfo:getConfigInfoByID(32)/10).."%作为服务费，且最大输赢分不超过所携带的金币。",FONT_PTY_TEXT,20);
	-- text_tips:setPosition(cc.p(400,50))
	text_tips:setAnchorPoint(0,0.5);
    text_tips:setPosition(cc.p(50,50))
	bg:addChild(text_tips);
	
	if globalUnit.nowTingId > 0 then
        text_tips:setString("最大输赢分不超过所携带的金币。")
    end
    
	self.Panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_root:setName("Panel_root");


end

--按钮响应
function HelpLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        --playsound
    elseif event == ccui.TouchEventType.ended then
    	if btnName == "Panel_root" then
    		self:removeFromParent();
    	end
    end

 end


return HelpLayer;