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
		Image_bg = "Image_bg",
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
		Panel_list = "1",
		Image_order = "Image_order"

	}

	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end


	loadNewCsb(self,"res/saoleihongbao/layminelayer",uiTable)

	self:initData(tableLayer);
	self:initUI();
end

function LayMineLayer:initData(tableLayer)
	luaPrint("tableLayer:",tableLayer)
	self.m_tableLayer = tableLayer;
	self.m_redbagValue = 0;   --当前红包金额
	self.m_sliderPercent = 2;
	self.m_mineKey = 0;

	luaPrint("LayMineLayer----",globalUnit.isTryPlay,self.m_tableLayer.ucMaxRedScore);
	if globalUnit.isTryPlay then 
		REDVALUE_ARR = {500000,1000000,2000000,4000000};
		REDBAG_MIN = 500000;  --10.00
 		REDBAG_MAX = 5000000;
 		SLIDER_PER = 25;
 	else
 		REDVALUE_ARR = {5000,10000,20000,40000};
		REDBAG_MIN = 1000;  --10.00
 		REDBAG_MAX = 50000;  --(50000-1000)/10
 		SLIDER_PER = 2; --2
	end


	local gap  = REDBAG_MAX - REDBAG_MIN;
	SLIDER_PER  = (1000/gap)*100;

end
--下注分数刷新
function LayMineLayer:updateMoney()
	luaPrint("updateMoney",self.m_tableLayer.ucMaxRedScore);
	if self.m_tableLayer.ucMaxRedScore == 5000 then
		REDVALUE_ARR = {1000,2000,3000,5000};
		REDBAG_MIN = 1000;  --10.00
 		REDBAG_MAX = 5000;
 		SLIDER_PER = 25;
	end

	local gap  = REDBAG_MAX - REDBAG_MIN;
	SLIDER_PER  = (1000/gap)*100;
	


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
	self.Slider_redValue:addEventListener(function(sender, touchEvent) self:onSliderEvent(sender, touchEvent); end);
	self:setPercent(self:getRightPercent(50));

end

function LayMineLayer:initUI()
	self.Image_order:setVisible(false);
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
	--self.Panel_laydone:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
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
	self:setPercent(self:getRightPercent(50));

	-- self.ListView_redbag:setScrollBarEnabled(false);
	-- self.ListView_redbag:setContentSize(self.ListView_redbag:getInnerContainerSize());

	luaDump(self.m_tableLayer.m_redBagList, "m_redBagList", 5)

	--用户列表
	local content = self.Panel_list;
	local m_tableView = cc.TableView:create(content:getContentSize());
	m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	m_tableView:setPosition(self.Panel_list:getPosition());
	m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
	m_tableView:setDelegate();
	m_tableView:registerScriptHandler( handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);  
	m_tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);
	m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);
	m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
	m_tableView:reloadData();
	self.Panel_dialog:addChild(m_tableView);
	self.m_tableView = m_tableView;
	self.Panel_list:setVisible(false);
	
	self.ListView_redbag:setVisible(false);


end

--刷新列表
function LayMineLayer:reloadRedbagList()
	luaDump(self.m_tableLayer.m_redBagList,"m_redBagList");
	self.m_tableView:reloadData();
	if self.m_tableLayer.m_bInRedBagList then
		self.Panel_laymine:setVisible(false);
    	self.Panel_laydone:setVisible(true);
    else
    	self.Panel_laymine:setVisible(true);
    	self.Panel_laydone:setVisible(false);
	end
end


--显示埋雷
function LayMineLayer:showLayMine()
	luaPrint("showLayMine",self.m_tableLayer:getMeSeat());
	luaDump(self.m_tableLayer.m_redBagList,"m_redBagList00");
	local bLayed = false;
	for i,v in ipairs(self.m_tableLayer.m_redBagList) do
		if v.ucChairID == self.m_tableLayer:getMeSeat() then
			bLayed = true;
			break;
		end
	end


	if bLayed then  --已埋雷
		self.Panel_laymine:setVisible(false);
		self.Panel_laydone:setVisible(true);
	else
		self.Panel_laymine:setVisible(true);
		self.Panel_laydone:setVisible(false);

		self.Panel_mine:setVisible(true);
		self.Button_laymine:setVisible(false);

		self.m_mineKey = 0;
		self.Text_mineValue:setString("0");
	end

	self:reloadRedbagList();
	self:setVisible(true);
end


function LayMineLayer:addRedbagValue()
	self.m_sliderPercent = self:getRightPercent(self.m_sliderPercent + SLIDER_PER);
	self:setPercent(self.m_sliderPercent);
end

function LayMineLayer:reduceRedbagValue()
	self.m_sliderPercent = self:getRightPercent(self.m_sliderPercent - SLIDER_PER);
	self:setPercent(self.m_sliderPercent);
end



function LayMineLayer:setRedbagValue(_value)
	self.m_redbagValue = _value;
	self.Text_redbagValue:setString(math.floor(self.m_redbagValue/100));
end


function LayMineLayer:setPercent(percent)
	if percent < 0 then
		percent = 0;
		
	elseif percent > 100 then
		percent = 100;
		
	else
		
	end

	if percent <= 0 then
		self.Button_reduce:setEnabled(false);
    elseif percent >= 100 then
    	self.Button_add:setEnabled(false);
    else
    	self.Button_reduce:setEnabled(true);
		self.Button_add:setEnabled(true);
	end


	self.m_sliderPercent = percent;
	self.Slider_redValue:setPercent(percent);
	local value = REDBAG_MIN + (REDBAG_MAX - REDBAG_MIN)*percent/100;
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
	-- self.ListView_redbag:removeAllChildren();
	-- for i=1,50 do
	-- 	local item = self.Panel_item:clone();
	-- 	local text_name = item:getChildByName("Text_name");
	-- 	local text_redbag = item:getChildByName("Text_redbag");
	-- 	text_name:setString("奔跑的浣熊_"..i);
	-- 	local money = random(1000,100000);
	-- 	text_redbag:setString(math.floor(money/100));
	-- 	item:setVisible(true);
	-- 	self.ListView_redbag:pushBackCustomItem(item);
	-- end


end

--按钮响应
function LayMineLayer:onSliderEvent(sender,event)
	local btnName = sender:getName();
    local btnTag = sender:getTag();
    local percent = sender:getPercent();
    luaPrint("percent:"..percent..",event:"..event);
    if event == 1 then --touch begin
        
    elseif event == 0 then --touch moved
    	if percent <= 0 then
    		percent = 0;
    		self:setPercent(percent);
    		return;
    	end

    	self:setPercent(percent);

    elseif event == 2 then --touch ended
    	if percent <= 0 then
    		percent = 0;
    		self:setPercent(percent);
    		return;
    	end

    	-- local gap  = REDBAG_MAX - REDBAG_MIN;
    	-- luaPrint("gap:",gap)
    	-- local per  = (1000/gap)*100;
    	-- luaPrint("per:",per)
    	-- local didth = percent%per
    	-- luaPrint("didth:",didth)
    	-- if didth > per/2 then
    	-- 	percent = math.floor(percent/per)*per + per;
    	-- else
    	-- 	percent = math.floor(percent/per)*per;
    	-- end

    	local percent2 = self:getRightPercent(percent)
    	self:setPercent(percent2);

    end
end


function LayMineLayer:getRightPercent(percent)
	local percent2 = 0;
	local gap  = REDBAG_MAX - REDBAG_MIN;
	local per  = (1000/gap)*100;
	local didth = percent%per
	if didth > per/2 then
		percent2 = math.floor(percent/per)*per + per;
	else
		percent2 = math.floor(percent/per)*per;
	end

	return percent2 ;
end


function LayMineLayer:scrollViewDidScroll(view)
	-- local vec1 = view:getContentOffset();
	
	-- local pos1 = cc.p(view:getContentSize().width - view:getViewSize().width,view:getContentSize().height - view:getViewSize().height);
	-- local percent = -(vec1.y/pos1.y);
	-- luaPrint("percent:"..percent);
	-- local height = self.Panel_list:getContentSize().height;
	-- self.Panel_bar:setPosition(cc.p(848,height*percent));


end

 
function LayMineLayer:cellSizeForTable( view, idx )
	local size = self.Panel_item:getContentSize();
	return size.width,size.height;
end

function LayMineLayer:numberOfCellsInTableView( view )
	local num = table.nums(self.m_tableLayer.m_redBagList);
	return num;
end
function LayMineLayer:tableCellAtIndex( view, idx )
	local cell = view:dequeueCell();
	luaPrint("idx:",idx);
	idx = idx+1;
	
	local item = nil;
	if nil == cell then
		cell = cc.TableViewCell:new();
		item = self.Panel_item:clone();
		item:setVisible(true);		
		item:setName("item");
		item:setPosition(cc.p(0,0));
		cell:addChild(item);
	else
		item = cell:getChildByName("item");
	end

	local text_name = item:getChildByName("Text_name");
	local text_redbag = item:getChildByName("Text_redbag");
	local data = self.m_tableLayer.m_redBagList[idx];
	luaDump(data, "tableCellAtIndex", 5);

	local userInfo = self.m_tableLayer.tableLogic:getUserBySeatNo(data.ucChairID);
	if userInfo then
		text_name:setString(FormotGameNickName(userInfo.nickName,nickNameLen));
	else
		text_name:setString("");
	end
	
	text_redbag:setString(GameMsg.formatCoin(data.llRedBagScore));
	item:setVisible(true);

	return cell;
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
    		luaPrint("Button_laymine---");
    		self:sendLayMine();
    		-- self.Panel_laymine:setVisible(false);
    		-- self.Panel_laydone:setVisible(true);

    	elseif "Panel_laydone" == btnName then --
    		self.Panel_laymine:setVisible(false);
    		self.Button_laymine:setVisible(true);



    	elseif "Button_close" == btnName then --
    		self:setVisible(false);
    	elseif "Image_minebg" == btnName then --
    		self.Button_laymine:setVisible(false);
    		self.Panel_mine:setVisible(true);
    	else
    		local ret = false;
    		for i,v in ipairs(self.m_btnPerList) do
    			if v == sender then
    				ret = true;
    				local index = btnTag%100;
    				local value = REDVALUE_ARR[index] - REDBAG_MIN;
    				luaPrint("btn_value:"..value);
    				local per = value*100/(REDBAG_MAX-REDBAG_MIN);
    				self:setPercent(self:getRightPercent(per));
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

function LayMineLayer:sendLayMine()
	local msg = {};
	msg.key = self.m_mineKey; --雷号
	msg.value = self.m_redbagValue; --红包额度

	if globalUnit.isTryPlay  and msg.value < REDBAG_MIN then 
		addScrollMessage("埋雷金额不得低于"..goldConvert(REDBAG_MIN,1));
		return;
	end

	if self.m_tableLayer.m_lSelfScore<200000 then
		addScrollMessage("抱歉，您的金币低于埋雷限制2000，不能埋雷！");
		return;
	end

	self.m_tableLayer.tableLogic:sendApplyMine(msg);
end






return LayMineLayer;

