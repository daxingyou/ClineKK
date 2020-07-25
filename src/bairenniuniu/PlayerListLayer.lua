local PlayerListLayer =  class("PlayerListLayer", BaseWindow)

function PlayerListLayer:create(viewParent)
	return PlayerListLayer.new(viewParent);
end

function PlayerListLayer:ctor(viewParent)
	self.super.ctor(self, 0, false);

	local uiTable = {
		Panel_root = "Panel_root",
		Panel_list = "Panel_list",
		Panel_content = "Panel_content",	--tableview 面板
		Panel_cell = "Panel_cell",	--游戏单元
		

	}

	loadNewCsb(self,"bairenniuniu/playerlistlayer",uiTable)

	self.m_parent = viewParent;
	self:initData();

	self:initUI();
end

function PlayerListLayer:initData()
	self.m_userlist = {};
end

function PlayerListLayer:initUI()
	self.Panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Panel_root:setName("Panel_root");

	-- self.Button_Apply:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	-- self.Button_Apply:setName("Button_Apply");

	self.Panel_cell:setVisible(false);
	
	--用户列表
	local content = self.Panel_content;
	local m_tableView = cc.TableView:create(content:getContentSize())
	m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	m_tableView:setPosition(content:getPosition())
	m_tableView:setDelegate()
	m_tableView:registerScriptHandler( handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);  
	m_tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	m_tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	m_tableView:reloadData();
	self.Panel_list:addChild(m_tableView)
	self.m_tableView = m_tableView;
	content:removeFromParent()





end

--按钮响应
function PlayerListLayer:onBtnClickEvent(sender,event)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    if event == ccui.TouchEventType.began then
        --playsound
    elseif event == ccui.TouchEventType.ended then
    	if btnName == "Panel_root" then

    		local effectState = getEffectIsPlay();
    		if effectState then
    			playEffect("bairenniuniu/sound/sound-close.mp3", false);
    		end
    		
    		self:setVisible(false);
    	end
    end

 end


function PlayerListLayer:refreshList( userlist,isShow)
	
	-- luaDump(userlist, "====userlist---------", 3)
	self.m_userlist = {};
	for k,v in pairs(userlist) do

		if not self.m_parent:isMeChair(v.bDeskStation) then
			table.insert(self.m_userlist,v);
		end
		
	end
	-- luaDump(self.m_userlist, "====self.m_userlist---------", 3)
	
	self.m_tableView:reloadData();
	if isShow then
		self:setVisible(true);	
	end
	
end



function PlayerListLayer:scrollViewDidScroll(view)
	-- body
end

 
function PlayerListLayer:cellSizeForTable( view, idx )
	-- return UserItem.getSize()
	local size = self.Panel_cell:getContentSize();
	
	return size.width,size.height;
end

function PlayerListLayer:numberOfCellsInTableView( view )
	-- if nil == self.m_userlist then
	-- 	return 0
	-- else
	-- 	return #self.m_userlist
	-- end
	local num = table.nums(self.m_userlist);
	
	return num;
end

function PlayerListLayer:tableCellAtIndex( view, idx )
	local cell = view:dequeueCell()
	local userItem = self.m_userlist[idx+1];
	-- local userItem = self.m_parent.tableLogic:getUserBySeatNo(seatNo);
	
	local item = nil;
	if nil == cell then
		cell = cc.TableViewCell:new()
		item = self.Panel_cell:clone();
		item:setVisible(true);
		item:setPosition(0,0)
		item:setName("user_item_view")

		local headFrame = item:getChildByName("Image_headFrame"); 
		local text_name = item:getChildByName("Text_name");
		local img_bg = item:getChildByName("Image_coinBg");
		local text_coin = img_bg:getChildByName("Text_coin");
		img_bg:setCascadeOpacityEnabled(false);
		img_bg:setOpacity(0);
		local image_head = headFrame:getChildByName("img_head");
		if not image_head then
			image_head = ccui.ImageView:create(getHeadPath(userItem.bLogoID,userItem.bBoy));
			headFrame:addChild(image_head);
			local size = headFrame:getContentSize();
			local sizeHead = image_head:getContentSize();
			image_head:setName("ima_head");
			image_head:setScale(size.width/sizeHead.width);
			image_head:setPosition(cc.p(size.width*0.5,size.height*0.5))

		end

		
		if text_name then
			text_name:setString(FormotGameNickName(userItem.nickName,nickNameLen));
		end

		if text_coin then
			text_coin:setString(GameMsg.formatCoin(userItem.i64Money));
		end

		cell:addChild(item);
	else

		item = cell:getChildByName("user_item_view")

		local headFrame = item:getChildByName("Image_headFrame"); 
		local text_name = item:getChildByName("Text_name");
		local img_bg = item:getChildByName("Image_coinBg");
		local text_coin = img_bg:getChildByName("Text_coin");

		local image_head = headFrame:getChildByName("img_head");
		if not image_head then
			image_head = ccui.ImageView:create(getHeadPath(userItem.bLogoID));
			headFrame:addChild(image_head);
			local size = headFrame:getContentSize();
			local sizeHead = image_head:getContentSize();
			image_head:setName("ima_head");
			image_head:setScale(size.width/sizeHead.width);
			image_head:setPosition(cc.p(size.width*0.5,size.height*0.5))

		end

		
		if text_name then
			text_name:setString(FormotGameNickName(userItem.nickName,nickNameLen));
		end

		if text_coin then
			text_coin:setString(GameMsg.formatCoin(userItem.i64Money));
		end

		
	end

	return cell
end

return PlayerListLayer;