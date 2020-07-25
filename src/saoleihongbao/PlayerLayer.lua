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
		Image_bg = "Image_bg",
		Panel_root = "Panel_root",
		Panel_dialog = "1",
		ListView_player = "1",	--tableview 面板
		Panel_twins = "1",	--游戏单元
		Button_close = "1",	--游戏单元
		
		Panel_list = "1",
		Panel_bar  = "1",


	}

	for k,v in pairs(uiTable) do
		uiTable[k] = k;
	end


	loadNewCsb(self,"res/saoleihongbao/playerlayer",uiTable)

	self:onTouch(function () luaPrint("摸我了---------"); end,0, true)
	
	self:initData(tableLayer);
	self:initUI();
end

function PlayerLayer:initData(tableLayer)
	self.m_tableLayer = tableLayer;
	luaPrint("player_tablelayer:",tableLayer);
	self.m_playerData = {};


	-- local players = self.m_tableLayer.tableLogic._deskUserList._users;
	-- local playerCount = table.nums(players);


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

	self.Panel_bar:setVisible(false);
	self.ListView_player:setVisible(false);
end

function PlayerLayer:showIt()
	self.m_playerData = self.m_tableLayer.tableLogic._deskUserList._users;
	--luaDump(self.m_playerData, "self.m_playerData", 6);
	self.m_tableView:reloadData();
	self:setVisible(true);
end

function PlayerLayer:test()
	self.m_playerData = {};
	for i=1,2 do
		local data = {};
		data.name = "小霸王挖掘机_"..i;
		data.money = random(1000,999929);
		data.seatId = i;
		table.insert(self.m_playerData,data);
	end
	-- self:refreshPlayer(playerData);
	-- luaDump(self.m_playerData, "self.m_playerData", 6);
	self.m_tableView:reloadData();
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


function PlayerLayer:scrollViewDidScroll(view)
	-- local vec1 = view:getContentOffset();
	
	-- local pos1 = cc.p(view:getContentSize().width - view:getViewSize().width,view:getContentSize().height - view:getViewSize().height);
	-- local percent = -(vec1.y/pos1.y);
	-- luaPrint("percent:"..percent);
	-- local height = self.Panel_list:getContentSize().height;
	-- self.Panel_bar:setPosition(cc.p(848,height*percent));


end

 
function PlayerLayer:cellSizeForTable( view, idx )
	local size = self.Panel_twins:getContentSize();
	return size.width,size.height;
end

function PlayerLayer:numberOfCellsInTableView( view )
	local num = table.nums(self.m_playerData);
	local count = math.ceil(num/2);
	return count;
end
function PlayerLayer:tableCellAtIndex( view, idx )
	local cell = view:dequeueCell();
	idx = idx+1;
	
	local item = nil;
	if nil == cell then
		cell = cc.TableViewCell:new();
		item = self.Panel_twins:clone();
		item:setVisible(true);		
		item:setName("item");
		item:setPosition(cc.p(0,0));
		cell:addChild(item);
	else
		item = cell:getChildByName("item");
	end

	local num = table.nums(self.m_playerData);
	for i=2,1,-1 do
		local ii = i -1;
		local index = idx*2-ii;
		local iii = math.abs(i-2);
		if  index <= num then
			local data = self.m_playerData[index];
			local item2 = item:getChildByName("Panel_item"..iii);
			if item2 then
				local text_name = item2:getChildByName("Text_name");
				local img_head = item2:getChildByName("Image_head");
				local text_coin = item2:getChildByName("Text_coin");
				--luaDump(data,"tableCellAtIndex000");
				text_name:setString(FormotGameNickName(data.nickName,nickNameLen));
				text_coin:setString(Common.gameRealMoney(data.i64Money));
				img_head:loadTexture(getHeadPath(data.bLogoID,data.bBoy))
				item2:setVisible(true);
			end
		else
			local item2 = item:getChildByName("Panel_item"..iii);
			item2:setVisible(false);
		end
	end

	return cell;
end


-- function PlayerLayer:tableCellAtIndex( view, idx )
-- 	local cell = view:dequeueCell();
-- 	idx = idx+1;
-- 	luaPrint("idx:"..idx);
-- 	local item = nil;
-- 	if nil == cell then
-- 		cell = cc.TableViewCell:new();
-- 		item = self.Panel_twins:clone();
-- 		item:setVisible(true);
-- 		-- item:setPosition(0,0);
-- 		item:setName("item");
-- 		local num = table.nums(self.m_playerData);
-- 		for i=1,2 do
-- 			local ii = i -1;
-- 			local index = idx*2-ii;
-- 			luaPrint("index:"..index..",num:"..num);
-- 			if  index <= num then
-- 				local data = self.m_playerData[index];
-- 				local item2 = item:getChildByName("Panel_item"..ii);
-- 				if item2 then
-- 					luaPrint("item2--------------------");
-- 					local text_name = item2:getChildByName("Text_name");
-- 					local img_head = item2:getChildByName("Image_head");
-- 					local text_coin = item2:getChildByName("Text_coin");
-- 					text_name:setString(data.name);
-- 					text_coin:setString(Common.gameRealMoney(data.money));
-- 					item2:setVisible(true);
-- 				end
-- 			else
-- 				local item2 = item:getChildByName("Panel_item"..ii);
-- 				item2:setVisible(false);
-- 			end
-- 		end

-- 		item:setPosition(cc.p(0,0));
-- 		cell:addChild(item);
-- 	else

-- 		item = cell:getChildByName("item");
-- 		local num = table.nums(self.m_playerData);
-- 		for i=1,2 do
-- 			local ii = i -1;
-- 			local index = idx*2-ii;
-- 			luaPrint("index:"..index..",num:"..num);
-- 			if  index <= num then
-- 				local data = self.m_playerData[index];
-- 				local item2 = item:getChildByName("Panel_item"..ii);
-- 				if item2 then
-- 					local text_name = item2:getChildByName("Text_name");
-- 					local img_head = item2:getChildByName("Image_head");
-- 					local text_coin = item2:getChildByName("Text_coin");
-- 					text_name:setString(data.name);
-- 					text_coin:setString(Common.gameRealMoney(data.money));
-- 					item2:setVisible(true);
-- 				end
-- 			else
-- 				local item2 = item:getChildByName("Panel_item"..ii);
-- 				item2:setVisible(false);
-- 			end
-- 		end
-- 	end

-- 	return cell
-- end




--按钮响应
function PlayerLayer:onBtnClickEvent(sender,event)
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
    		--self:test();
    	elseif "Panel_dialog" == btnName then --

    	elseif "Button_close" == btnName then --
    		self:setVisible(false);
    	
    	end
    end

end






return PlayerLayer;

