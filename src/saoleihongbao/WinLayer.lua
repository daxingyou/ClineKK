--埋雷
local WinLayer =  class("WinLayer", BaseWindow)
local Common   = require("saoleihongbao.Common");

local Spine_Win ={
		name = "huodehongbao",
		json = "saoleihongbao/anim/huodehongbao.json",
		atlas = "saoleihongbao/anim/huodehongbao.atlas",		
}

local Spine_Lost ={
		name = "henyihan",
		json = "saoleihongbao/anim/henyihan.json",
		atlas = "saoleihongbao/anim/henyihan.atlas",		
}

local ROOM_TEN = 1;
local ROOM_SEVEN = 2;


function WinLayer:create(tableLayer,winValue,isBoom)
	return WinLayer.new(tableLayer,winValue,isBoom);
end

function WinLayer:ctor(tableLayer,winValue,isBoom)
	self.super.ctor(self, 0, false);

	local uiTable = {
		Image_bg = "Image_bg",		--背景图
		Panel_root = "Panel_root",
		Panel_lost = "1",
		Panel_win = "1",	--tableview 面板
		Text_lost = "1",
		Text_win = "1",
		Text_score = "1",
	}

	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end


	loadNewCsb(self,"res/saoleihongbao/winlayer",uiTable)

	
	self:initData(tableLayer,winValue,isBoom);
	self:initUI();
end

function WinLayer:initData(tableLayer,winValue,isBoom)
	self.m_tableLayer = tableLayer;
	self.m_winValue = winValue;
	self.m_isBoom = isBoom;
	luaPrint("self.m_tableLayer:",self.m_tableLayer);
	luaPrint("self.m_winValue:"..self.m_winValue);


end

function WinLayer:initUI()
	self.Panel_lost:setVisible(false);
	self.Panel_win:setVisible(false);

	local skeleton_animation = nil
	 
	local text = nil
	local loseText = nil;
	if  self.m_isBoom~=1 then
		-- self.Panel_lost:setVisible(false);
		-- self.Panel_win:setVisible(true);
		self.Text_win:setString("+"..Common.gameRealMoney(self.m_winValue));
		text = self.Text_win:clone();
		text:setString("+"..Common.gameRealMoney(self.m_winValue));
		skeleton_animation = createSkeletonAnimation("slhb_"..Spine_Win.name,Spine_Win.json,Spine_Win.atlas);
		if skeleton_animation then
			self.Panel_root:addChild(skeleton_animation);
	    	skeleton_animation:setAnimation(0,Spine_Win.name, false);
	    	skeleton_animation:setPosition(cc.p(self.Panel_root:getContentSize().width/2,self.Panel_root:getContentSize().height/2));
	    	skeleton_animation:setTag(301);
	    else
	    	luaPrint("skeleton_animation-----------------------:",skeleton_animation)
		end
		audio.playSound("saoleihongbao/sound/bigwin.mp3");

	else
		-- self.Panel_lost:setVisible(true);
		-- self.Panel_win:setVisible(false);
		self.Text_lost:setString(Common.gameRealMoney(self.m_winValue));

		local bit = 1;
		if self.m_tableLayer.m_roomKind == ROOM_SEVEN then
			bit = 1.5;
		end
		
	
		text = self.Text_lost:clone();
		text:setString(Common.gameRealMoney(self.m_winValue));

		loseText = self.Text_score:clone();
		loseText:setString(Common.gameRealMoney(-1*(bit*self.m_tableLayer.m_curRedBagValue)));

		skeleton_animation = createSkeletonAnimation("slhb_"..Spine_Lost.name,Spine_Lost.json,Spine_Lost.atlas);
		if skeleton_animation then
			self.Panel_root:addChild(skeleton_animation);
	    	skeleton_animation:setAnimation(0,Spine_Lost.name, false);
	    	skeleton_animation:setPosition(cc.p(self.Panel_root:getContentSize().width/2,self.Panel_root:getContentSize().height/2));
	    	skeleton_animation:setTag(301);
	    else
	    	luaPrint("skeleton_animation-----------------------:",skeleton_animation)
		end

		audio.playSound("saoleihongbao/sound/bomb.mp3");
		
	end

	self.Panel_root:addChild(text,1000);
	text:setPosition(cc.p(self.Panel_root:getContentSize().width/2,self.Panel_root:getContentSize().height/2));
	text:setVisible(false);
	text:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.Show:create()));

	if loseText then
		self.Panel_root:addChild(loseText,1000);
		loseText:setPosition(cc.p(self.Panel_root:getContentSize().width/2,self.Panel_root:getContentSize().height/2-80));
		loseText:setVisible(false);
		loseText:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.Show:create()));
	end


	self.Panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_root:setName("Panel_root");
	
	self.Panel_root:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.RemoveSelf:create()));

end




function WinLayer:test()
	

end



--按钮响应
function WinLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        --playsound
    elseif event == ccui.TouchEventType.ended then
    	if btnName == "Panel_root" then
    		-- self:removeFromParent();
    	end
    end

end






return WinLayer;

