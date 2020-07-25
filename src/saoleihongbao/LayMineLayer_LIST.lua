--埋雷
local LayMineLayer =  class("LayMineLayer", BaseWindow)
local REDVALUE_ARR = {5000,10000,20000,40000};
local REDBAG_MIN = 1000;  --10.00
local REDBAG_MAX = 50000;
local REDBAG_PER = 1000;
local SLIDER_PER = 2; --500 10  10/500;


function LayMineLayer:create(tableLayer)
	return LayMineLayer.new(tableLayer);
end

function LayMineLayer:ctor(tableLayer)
	self.super.ctor(self, 0, false);

	local uiTable = {
		Panel_root = "Panel_root",
		Panel_dialog = "1",
		ListView_redbag = "1",	--tableview 面板
		Panel_laymine = "1",	--游戏单元
		Button_add = "1",	--tableview 面板
		Button_reduce = "1",	--游戏单元
		Text_redbagValue = "1",	--tableview 面板
		Text_mineValue = "1",	--游戏单元
		Slider_redValue = "1",	--tableview 面板
		Button_per1 = "1",	--游戏单元
		Panel_mine = "1",	--tableview 面板
		Button_laymine = "1",	--游戏单元
		Panel_laydone = "1",	--tableview 面板
		Button_close = "1",	--游戏单元
		Panel_item = "1",	--游戏单元
		Image_minebg = "1",
		


	}

	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end


	loadNewCsb(self,"res/saoleihongbao/layminelayer",uiTable)

	
	self:initData(tableLayer);
	self:initUI();
end

function LayMineLayer:initData(tableLayer)
	self.m_tableLayer = tableLayer;
	self.m_redbagValue = 0;   --当前红包金额
	self.m_sliderPercent = 2;
	self.m_mineKey = 0;


end

function LayMineLayer:initUI()
	self.Panel_item:setVisible(false);
	self.Panel_laydone:setVisible(false);
	self.Panel_laymine:setVisible(true);
	self.Panel_laydone:setVisible(false);

	self.Button_reduce:setEnabled(false);
	self.Text_redbagValue:setString(0);
	self.Text_mineValue:setString(0);
	self.Button_laymine:setVisible(false);

	--点击显示地雷选择界面
	self.Image_minebg:setTouchEnabled(true);
	self.Image_minebg:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Image_minebg:setName("Image_minebg");


	self.Panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_root:setName("Panel_root");
	self.Panel_dialog:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_dialog:setName("Panel_dialog");
	self.Panel_laymine:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_laymine:setName("Panel_laymine");
	self.Button_add:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_add:setName("Button_add");
	self.Button_reduce:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_reduce:setName("Button_reduce");
	self.Panel_mine:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_mine:setName("Panel_mine");
	self.Button_laymine:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_laymine:setName("Button_laymine");
	self.Panel_laydone:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_laydone:setName("Panel_laydone");
	self.Button_close:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_close:setName("Button_close");
	
	--四等分 固定红包
	self.m_btnPerList = {};
	for i=1,4 do
		local button = self.Panel_laymine:getChildByName("Button_per"..i);
		local text = button:getChildByName("Text_word");
		text:setString(REDVALUE_ARR[i]/100);
		text:setTag(REDVALUE_ARR[i]/100);
		button:setTag(100+i);
		table.insert(self.m_btnPerList,button);
		button:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		
	end

	--雷号按钮
	self.m_btnMineList = {};
	for i=1,10 do
		local index = i-1;
		local button = self.Panel_mine:getChildByName("Button_"..index);
		button:setTag(200+index);
		table.insert(self.m_btnMineList,button);
		button:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
		
	end

	self.Slider_redValue:addEventListener(function(sender, touchEvent) self:onSliderEvent(sender, touchEvent); end);
	self:setPercent(2);

	self.ListView_redbag:setScrollBarEnabled(false);
	self.ListView_redbag:setContentSize(self.ListView_redbag:getInnerContainerSize());
end

function LayMineLayer:addRedbagValue()
	self.m_sliderPercent = self.m_sliderPercent + 2;
	self:setPercent(self.m_sliderPercent);
end

function LayMineLayer:reduceRedbagValue()
	self.m_sliderPercent = self.m_sliderPercent - 2;
	self:setPercent(self.m_sliderPercent);
end



function LayMineLayer:setRedbagValue(_value)
	self.m_redbagValue = _value;
	self.Text_redbagValue:setString(self.m_redbagValue/100);
end


function LayMineLayer:setPercent(percent)
	if percent < SLIDER_PER then
		percent = 2;
		
	elseif percent > 100 then
		percent = 100;
		
	else
		
	end

	if percent <= 2 then
		self.Button_reduce:setEnabled(false);
    elseif percent >= 100 then
    	self.Button_add:setEnabled(false);
    else
    	self.Button_reduce:setEnabled(true);
		self.Button_add:setEnabled(true);
	end


	self.m_sliderPercent = percent;
	self.Slider_redValue:setPercent(percent);
	local value = REDBAG_MAX*percent/100;
	self:setRedbagValue(value);
end


function LayMineLayer:setMineKey(key)
	if key < 0 then
		key = 0;
	elseif key > 9 then
		key = 9;
	end

	self.m_mineKey = key;
	self.Text_mineValue:setString(key);
	-- self.Panel_laydone:setVisible(true);
	self.Panel_mine:setVisible(false);
	self.Button_laymine:setVisible(true);
end




function LayMineLayer:test()
	self.ListView_redbag:removeAllChildren();
	for i=1,50 do
		local item = self.Panel_item:clone();
		local text_name = item:getChildByName("Text_name");
		local text_redbag = item:getChildByName("Text_redbag");
		text_name:setString("奔跑的浣熊_"..i);
		local money = random(1000,100000);
		text_redbag:setString(math.floor(money/100));
		item:setVisible(true);
		self.ListView_redbag:pushBackCustomItem(item);
	end


end

--按钮响应
function LayMineLayer:onSliderEvent(sender,event)
	local btnName = sender:getName();
    local btnTag = sender:getTag();
    local percent = sender:getPercent();
    luaPrint("percent:"..percent..",event:"..event);
    if event == 1 then --touch begin
        
    elseif event == 0 then --touch moved
    	if percent <= SLIDER_PER then
    		percent = SLIDER_PER;
    		self:setPercent(percent);
    		return;
    	end

    	local p1 = percent%SLIDER_PER;
    	if p1 > 0 then
    		percent = percent + 1;
    	end
    	self:setPercent(percent);

    elseif event == 2 then --touch ended
    	if percent <= SLIDER_PER then
    		percent = SLIDER_PER;
    		self:setPercent(percent);
    		return;
    	end

    	local p1 = percent%SLIDER_PER;
    	if p1 > 0 then
    		percent = percent + 1;
    	end
    	self:setPercent(percent);

    end
end

--按钮响应
function LayMineLayer:onBtnClickEvent(sender,event)
    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
    	if "Button_close" == btnName then
    		audio.playSound(GAME_SOUND_CLOSE)
    	else
        	audio.playSound(GAME_SOUND_BUTTON)
        end
    elseif event == ccui.TouchEventType.ended then
    	if btnName == "Panel_root" then
    		-- self:removeFromParent();

    		self:test();
    	elseif "Panel_dialog" == btnName then --

    	elseif "Panel_laymine" == btnName then --
    	
    	elseif "Button_add" == btnName then --
    		
    		self:addRedbagValue();

    	elseif "Button_reduce" == btnName then --
			
			self:reduceRedbagValue();

    	elseif "Panel_mine" == btnName then --
    	
    	elseif "Button_laymine" == btnName then --
    		self.Panel_laymine:setVisible(false);
    		self.Panel_laydone:setVisible(true);

    	elseif "Panel_laydone" == btnName then --
    		self.Panel_laymine:setVisible(false);
    		self.Button_laymine:setVisible(true);



    	elseif "Button_close" == btnName then --
    		self:removeFromParent();
    	elseif "Image_minebg" == btnName then --
    		self.Button_laymine:setVisible(false);
    		self.Panel_mine:setVisible(true);
    	else
    		local ret = false;
    		for i,v in ipairs(self.m_btnPerList) do
    			if v == sender then
    				ret = true;
    				local index = btnTag%100;
    				local value = REDVALUE_ARR[index];
    				luaPrint("btn_value:"..value);
    				local per = value*100/REDBAG_MAX;
    				self:setPercent(per);
    			end
    		end

    		if ret then
    			return;
    		end

    		for i,v in ipairs(self.m_btnMineList) do
    			if v == sender then
    				ret = true;
    				local value = btnTag%200;
    				luaPrint("btn_key:"..value);
    				self:setMineKey(value);
    			end
    		end
    	end
    end

end






return LayMineLayer;

