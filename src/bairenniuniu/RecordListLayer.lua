local RecordListLayer =  class("RecordListLayer", BaseWindow)

function RecordListLayer:create(viewParent)
	return RecordListLayer.new(viewParent);
end

function RecordListLayer:ctor(viewParent)
	self.super.ctor(self, 0, false);

	local uiTable = {
		Panel_root = "Panel_root",
		Panel_list = "Panel_list",
		
		Panel_cell = "Panel_cell",	--游戏单元
		Text_round = "Text_round", --游戏总回合
		ListView_content = "ListView_content",

	}

	loadNewCsb(self,"bairenniuniu/recordlistlayer",uiTable)

	self.m_parent = viewParent;
	self:initData();

	self:initUI();
end

function RecordListLayer:initData()
	self.m_winAllList = {};
	self.m_winLastList = {};
end

function RecordListLayer:initUI()
	self.Panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_root:setName("Panel_root");

	-- local sharedDirector = cc.Director:getInstance();
	-- local winSize = sharedDirector:getWinSize();
	-- self.Panel_list:setPositionX(winSize.width - 180);
	-- self.Button_Apply:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.Button_Apply:setName("Button_Apply");

	self.Panel_cell:setVisible(false);
	
	--用户列表
	-- local content = self.Panel_content;
	-- local m_tableView = cc.TableView:create(content:getContentSize())
	-- m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	-- m_tableView:setPosition(content:getPosition())
	-- m_tableView:setDelegate()
	-- m_tableView:registerScriptHandler( handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);  
	-- m_tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	-- m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	-- m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	-- m_tableView:reloadData();
	-- self.Panel_list:addChild(m_tableView)
	-- self.m_tableView = m_tableView;
	-- content:removeFromParent()



	--输赢列表
	self.ListView_content:removeAllChildren();
	self.ListView_content:setScrollBarEnabled(false);

	--初始化总记录
	self.Text_round:setString("0");
	self.Text_greenTb = {};
	self.Text_redTb = {};
	for i=1,4 do
		local text_green = self.Panel_list:getChildByName("Text_green"..i);
		local text_red = self.Panel_list:getChildByName("Text_red"..i);
		text_green:setString("0");
		text_red:setString("0");
		table.insert(self.Text_greenTb,text_green);
		table.insert(self.Text_redTb,text_red);
	end



end

--按钮响应
function RecordListLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        --playsound
    elseif event == ccui.TouchEventType.ended then
    	if btnName == "Panel_root" then
    		self:setVisible(false);
    	end
    end

 end

function RecordListLayer:resetAllInfo()
	self.ListView_content:removeAllChildren();

	self.Text_round:setString(tostring(0));
	for i=1,4 do
		self.Text_greenTb[i]:setString(tostring(0));
		self.Text_redTb[i]:setString(tostring(0));
	end

end


function RecordListLayer:refreshDayList(allRound,winList)


	self.Text_round:setString(tostring(allRound));
	self.m_winAllList = winList;
	for k,v in pairs(self.m_winAllList) do
		self.Text_greenTb[k]:setString(tostring(winList[k]));
		local lost = allRound - winList[k];
		self.Text_redTb[k]:setString(tostring(lost));
	end

end


function RecordListLayer:refreshList(lastList)
	-- do
	-- 	return;
	-- end
	-- self.m_winLastList = {};
	self.m_winLastList = lastList;
	
	self.ListView_content:removeAllChildren();
	for i,v in ipairs(self.m_winLastList) do
		local winItem = v;
		local item = self.Panel_cell:clone();
		item:setVisible(true);
		item:setPosition(0,0)
		item:setName("user_item_view")
		local img_winTb = {};
		for j=1,4 do
			local img_mark = item:getChildByName("Image_mark"..j);
			if winItem[j] then
				img_mark:loadTexture("brnn_gou.png",UI_TEX_TYPE_PLIST);
			else
				img_mark:loadTexture("brnn_X.png",UI_TEX_TYPE_PLIST);
			end
		end

		local img_markNew = item:getChildByName("Image_markNew");
		local num = table.nums(self.m_winLastList);
		
		img_markNew:setVisible(num == i);

		self.ListView_content:pushBackCustomItem(item);
	end

	-- self.ListView_content:jumpToBottom();
	self.ListView_content:scrollToBottom(0.3,false);
	--scrollToBottom
	-- self.m_tableView:reloadData();

	self:setVisible(true);
end



function RecordListLayer:scrollViewDidScroll(view)
	-- body
end

 --tableview
function RecordListLayer:cellSizeForTable( view, idx )
	-- return UserItem.getSize()
	local size = self.Panel_cell:getContentSize();
	
	return size.width,size.height;
end

function RecordListLayer:numberOfCellsInTableView( view )
	-- if nil == self.m_userlist then
	-- 	return 0
	-- else
	-- 	return #self.m_userlist
	-- end
	local num = table.nums(self.m_winLastList);
	
	return num;
end

function RecordListLayer:tableCellAtIndex( view, idx )
	local cell = view:dequeueCell()
	local winItem = self.m_winLastList[idx+1];
	-- local userItem = self.m_parent.tableLogic:getUserBySeatNo(seatNo);
	
	local item = nil;
	if nil == cell then
		cell = cc.TableViewCell:new()
		item = self.Panel_cell:clone();
		item:setVisible(true);
		item:setPosition(0,0)
		item:setName("user_item_view")
		local img_winTb = {};
		for i=1,4 do
			local img_mark = item:getChildByName("Image_mark"..i);
			if winItem[i] then
				img_mark:loadTexture("brnn_gou.png",UI_TEX_TYPE_PLIST);
			else
				img_mark:loadTexture("brnn_X.png",UI_TEX_TYPE_PLIST);
			end
		end

		local img_markNew = item:getChildByName("Image_markNew");
		local num = table.nums(self.m_winLastList);
		
		img_markNew:setVisible(num == idx + 1);
		cell:addChild(item);
	else

		item = cell:getChildByName("user_item_view")

		local img_winTb = {};
		for i=1,4 do
			local img_mark = item:getChildByName("Image_mark"..i);
			if winItem[i] then
				img_mark:loadTexture("brnn_gou.png",UI_TEX_TYPE_PLIST);
			else
				img_mark:loadTexture("brnn_X.png",UI_TEX_TYPE_PLIST);
			end
		end

		local img_markNew = item:getChildByName("Image_markNew");
		local num = table.nums(self.m_winLastList);
		
		img_markNew:setVisible(num == idx + 1);
	end

	return cell
end

return RecordListLayer;