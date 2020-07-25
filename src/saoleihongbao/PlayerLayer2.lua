--埋雷
local PlayerLayer =  class("PlayerLayer", BaseWindow)
local Common   = require("saoleihongbao.Common");

local REDVALUE_ARR = {5000,10000,20000,40000};
local REDBAG_MIN = 1000;  --10.00
local REDBAG_MAX = 50000;
local REDBAG_PER = 1000;
local SLIDER_PER = 2; --500 10  10/500;


function PlayerLayer:create(tableLayer)
	return PlayerLayer.new(tableLayer);
end

function PlayerLayer:ctor(tableLayer)
	self.super.ctor(self, 0, false);

	local uiTable = {
		Panel_root = "Panel_root",
		Panel_dialog = "1",
		ListView_player = "1",	--tableview 面板
		Panel_twins = "1",	--游戏单元
		Button_close = "1",	--游戏单元
		
		


	}

	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end


	loadNewCsb(self,"res/saoleihongbao/playerlayer",uiTable)

	
	self:initData(tableLayer);
	self:initUI();
end

function PlayerLayer:initData(tableLayer)
	self.m_tableLayer = tableLayer;
	


end

function PlayerLayer:initUI()
	self.Panel_twins:setVisible(false);
	for i=1,2 do
		local index = i-1;
		local item = self.Panel_twins:getChildByName("Panel_item"..index);
		item:setVisible(false);
	end

	self.Panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_root:setName("Panel_root");
	self.Panel_dialog:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_dialog:setName("Panel_dialog");
	self.Button_close:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_close:setName("Button_close");
	

end

function PlayerLayer:addRedbagValue()
	self.m_sliderPercent = self.m_sliderPercent + 2;
	self:setPercent(self.m_sliderPercent);
end

function PlayerLayer:reduceRedbagValue()
	self.m_sliderPercent = self.m_sliderPercent - 2;
	self:setPercent(self.m_sliderPercent);
end



function PlayerLayer:test()
	local playerData = {};
	for i=1,30 do
		local data = {};
		data.name = "小霸王挖掘机_"..i;
		data.money = random(1000,999929);
		data.seatId = i;
		table.insert(playerData,data);
	end
	self:refreshPlayer(playerData);

end

function PlayerLayer:refreshPlayer(playerData)
	self.ListView_player:removeAllChildren();

	local num = table.nums(playerData);
	local count = math.ceil(num/2);
	for i=1,num do
		local data = playerData[i];
		local index = math.ceil(i/2);

		local odd = (i-1)%2;
		local cell = self.ListView_player:getChildByTag(index);
		if cell == nil then
			cell = self.Panel_twins:clone();
			cell:setTag(index);
			cell:setVisible(true);
			self.ListView_player:pushBackCustomItem(cell);
		end

		local item = cell:getChildByName("Panel_item"..odd);
		if item then
			local text_name = item:getChildByName("Text_name");
			local img_head = item:getChildByName("Image_head");
			local text_coin = item:getChildByName("Text_coin");
			text_name:setString(data.name);
			text_coin:setString(Common.gameRealMoney(data.money));
			item:setVisible(true);
		end

	end

	local function actionEnd()
		self.ListView_player:jumpToTop();
	end

	self.ListView_player:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(actionEnd)));
	-- self.ListView_player:jumpToTop();

end


--按钮响应
function PlayerLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        --playsound
    elseif event == ccui.TouchEventType.ended then
    	if btnName == "Panel_root" then
    		-- self:removeFromParent();
    		self:test();
    	elseif "Panel_dialog" == btnName then --

    	elseif "Button_close" == btnName then --
    		self:removeFromParent();
    	
    	end
    end

end






return PlayerLayer;

