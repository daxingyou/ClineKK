local GetCashRecordLayer = class("GetCashRecordLayer",PopLayer)

ExtendInfo = require("dataModel.platform.ExtendInfo")

function GetCashRecordLayer:ctor(type)
	self.super.ctor(self,PopType.middle)

	self:bindEvent()

	self:initUI(type)
	
end

function GetCashRecordLayer:bindEvent()
	self:pushEventInfo(ExtendInfo,"ReceiveGetCashLog",handler(self, self.onReceiveGetCashLog))--明细列表
end

function GetCashRecordLayer:initUI(type)
	self.type=type;
	self.sureBtn:hide()
	self:updateBg("hall/common/commonBg0.png");
	self:updateCloseBtnPos(-10,-60);
	if self.type ==1 then
		local title = ccui.ImageView:create("hall/GetCashRecordLayer/deposite_title.png")
		title:setPosition(self.size.width/2,self.size.height-90)
		self.bg:addChild(title)

		local ordernum = ccui.ImageView:create("hall/GetCashRecordLayer/invest_ordernum.png")
		ordernum:setPosition(self.size.width/2-280,self.size.height-160)
		self.bg:addChild(ordernum)

		local deposite_time = ccui.ImageView:create("hall/GetCashRecordLayer/deposite_time.png")
		deposite_time:setPosition(self.size.width/2,self.size.height-160)
		self.bg:addChild(deposite_time)

		local goldnum = ccui.ImageView:create("hall/GetCashRecordLayer/deposite_goldnum.png")
		goldnum:setPosition(self.size.width/2+160,self.size.height-160)
		self.bg:addChild(goldnum)

		local orderstate = ccui.ImageView:create("hall/GetCashRecordLayer/deposite_orderstate.png")
		orderstate:setPosition(self.size.width/2+320,self.size.height-160)
		self.bg:addChild(orderstate)

		ExtendInfo:sendGetCashLog(1);

		--创建按钮的tableview
	    self.RecordTableView = cc.TableView:create(cc.size(870,415));
	    if self.RecordTableView then  
	        -- local layout = ccui.Layout:create()
	        -- layout:setContentSize(cc.size(870,410))   
	        -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	        -- layout:setBackGroundColor(cc.c3b(150, 200, 255))
	        -- layout:setAnchorPoint(cc.p(0,0)); 
	        -- layout:setPosition(cc.p(80, 80));
	        -- self.bg:addChild(layout);
	        self.RecordTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
	        self.RecordTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	        -- layout:setBackGroundColorOpacity(60)    --设置透明
	        self.RecordTableView:setAnchorPoint(cc.p(0,0)); 
	        self.RecordTableView:setPosition(cc.p(80, 90));
	        self.RecordTableView:setDelegate();

	        self.RecordTableView:registerScriptHandler( handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED);  
	        self.RecordTableView:registerScriptHandler( handler(self, self.tabel_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
	        self.RecordTableView:registerScriptHandler( handler(self, self.tabel_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
	        self.RecordTableView:registerScriptHandler( handler(self, self.tabel_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  

	        self.bg:addChild(self.RecordTableView);
	        -- self.RecordTableView:reloadData();
	    end
	else
		local title = ccui.ImageView:create("hall/GetCashRecordLayer/invest_title.png")
		title:setPosition(self.size.width/2,self.size.height-90)
		self.bg:addChild(title)

		local ordernum = ccui.ImageView:create("hall/GetCashRecordLayer/invest_ordernum.png")
		ordernum:setPosition(self.size.width/2-300,self.size.height-160)
		self.bg:addChild(ordernum)

		local deposite_time = ccui.ImageView:create("hall/GetCashRecordLayer/invest_time.png")
		deposite_time:setPosition(self.size.width/2-80,self.size.height-160)
		self.bg:addChild(deposite_time)

		local goldnum = ccui.ImageView:create("hall/GetCashRecordLayer/invest_goldnum.png")
		goldnum:setPosition(self.size.width/2+80,self.size.height-160)
		self.bg:addChild(goldnum)

		local ordermethod = ccui.ImageView:create("hall/GetCashRecordLayer/invest_method.png")
		ordermethod:setPosition(self.size.width/2+220,self.size.height-160)
		self.bg:addChild(ordermethod)

		local orderstate = ccui.ImageView:create("hall/GetCashRecordLayer/invest_state.png")
		orderstate:setPosition(self.size.width/2+360,self.size.height-160)
		self.bg:addChild(orderstate)

		ExtendInfo:sendGetCashLog(5);

		--创建按钮的tableview
	    self.RecordTableView = cc.TableView:create(cc.size(870,415));
	    if self.RecordTableView then  
	        self.RecordTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
	        self.RecordTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	        -- layout:setBackGroundColorOpacity(60)    --设置透明
	        self.RecordTableView:setAnchorPoint(cc.p(0,0)); 
	        self.RecordTableView:setPosition(cc.p(80, 90));
	        self.RecordTableView:setDelegate();

	        self.RecordTableView:registerScriptHandler( handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED);  
	        self.RecordTableView:registerScriptHandler( handler(self, self.tabel_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
	        self.RecordTableView:registerScriptHandler( handler(self, self.tabel_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
	        self.RecordTableView:registerScriptHandler( handler(self, self.tabel_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  

	        self.bg:addChild(self.RecordTableView);
	        -- self.RecordTableView:reloadData();
	    end
	end
end

function GetCashRecordLayer:onReceiveGetCashLog(data)
    local msg = data._usedata;
    table.sort(msg,function(a,b) return a.CollectTime > b.CollectTime end)
    dump(msg,"提现记录");
    self.m_recordDataList = msg;
    self.RecordTableView:reloadData();
    -- self:RefreshScene(msg);

end

--用户列表
--cell点击事件
function GetCashRecordLayer:tableCellTouched(table,cell)
    --CommomFunc_TableViewReloadData_Vertical(self.RecordTableView, cc.size( 200, self.Panel_userInfo:getContentSize().height+10), false);
end
--列表项的尺寸
function GetCashRecordLayer:tabel_cellSizeForTable(sender, index)
    return 1068,80;
end

--列表项的数量 
function GetCashRecordLayer:tabel_numberOfCellsInTableView(sender)
	if #self.m_recordDataList>0 then
    	return #self.m_recordDataList;
    else
    	return 0
    end
end

--创建列表项
function GetCashRecordLayer:tabel_tableCellAtIndex(sender, index)   
    local cell = sender:dequeueCell();
    if self.type ==1 then
	    if nil == cell then
	    	local cellSize = cc.size(950,80)
	        cell = cc.TableViewCell:new();
	        local recordPanel = ccui.ImageView:create("hall/GetCashRecordLayer/cash_hengang.png"); 
	        recordPanel:setAnchorPoint(0.5,0);
	        recordPanel:setPosition(cc.p(cellSize.width/2,0));
	        recordPanel:setName("recordPanel");  
	        cell:addChild(recordPanel);

	        --订单编号
	        local OrderNum = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        OrderNum:setName("OrderNum");
		    OrderNum:setPosition(self.size.width/2-350,cellSize.height/2);
		    OrderNum:setScaleX(0.9);
		    recordPanel:addChild(OrderNum);

	        --创建时间
	        local CreateTime = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        CreateTime:setName("CreateTime");
		    CreateTime:setPosition(self.size.width/2-90,cellSize.height/2);
		    recordPanel:addChild(CreateTime);

	        --提现金币
	        local depositeGold = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        depositeGold:setName("depositeGold");
		    depositeGold:setPosition(self.size.width/2+70,cellSize.height/2);
		    recordPanel:addChild(depositeGold);

	        --创建订单状态
	        local OrderState = FontConfig.createWithSystemFont("",26,cc.c3b(68,157,41));--156 18 18
	        OrderState:setName("OrderState");
		    OrderState:setPosition(self.size.width/2+230,cellSize.height/2);
		    recordPanel:addChild(OrderState);

	        self:SetRecordInfo(recordPanel, index);     
	    else
	        local recordPanel = cell:getChildByName("recordPanel");
	        self:SetRecordInfo(recordPanel, index);
		end  
	else
		if nil == cell then
	    	local cellSize = cc.size(950,80)
	        cell = cc.TableViewCell:new();
	        local recordPanel = ccui.ImageView:create("hall/GetCashRecordLayer/cash_hengang.png"); 
	        recordPanel:setAnchorPoint(0.5,0);
	        recordPanel:setPosition(cc.p(cellSize.width/2,0));
	        recordPanel:setName("recordPanel");  
	        cell:addChild(recordPanel);

	        --订单编号
	        local OrderNum = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        OrderNum:setName("OrderNum");
		    OrderNum:setPosition(self.size.width/2-400,cellSize.height/2);
		    OrderNum:setScale(0.7);
		    recordPanel:addChild(OrderNum);

	        --创建时间
	        local CreateTime = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        CreateTime:setName("CreateTime");
		    CreateTime:setPosition(self.size.width/2-180,cellSize.height/2);
		    recordPanel:addChild(CreateTime);

	        --充值金币
	        local investGold = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        investGold:setName("investGold");
		    investGold:setPosition(self.size.width/2-10,cellSize.height/2);
		    recordPanel:addChild(investGold);

		    --充值方式
	        local investMethod = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
	        investMethod:setName("investMethod");
		    investMethod:setPosition(self.size.width/2+130,cellSize.height/2);
		    recordPanel:addChild(investMethod);

	        --创建订单状态
	        local OrderState = FontConfig.createWithSystemFont("",26,cc.c3b(68,157,41));--156 18 18
	        OrderState:setName("OrderState");
		    OrderState:setPosition(self.size.width/2+270,cellSize.height/2);
		    recordPanel:addChild(OrderState);

	        self:SetRecordInfo(recordPanel, index);     
	    else
	        local recordPanel = cell:getChildByName("recordPanel");
	        self:SetRecordInfo(recordPanel, index);
		end  
	end
    return cell;
end

function GetCashRecordLayer:SetRecordInfo(recordPanel,idx)

	local m_recordData = self.m_recordDataList[idx+1];
	if self.type ==1 then
		local OrderNum = recordPanel:getChildByName("OrderNum");
		if OrderNum then
			OrderNum:setString(m_recordData.OrderNum);
		end

		local CreateTime = recordPanel:getChildByName("CreateTime");
		if CreateTime then
			CreateTime:setString(os.date("%m-%d %H:%M",m_recordData.CollectTime));
		end

		local depositeGold = recordPanel:getChildByName("depositeGold");
		if depositeGold then
			depositeGold:setString(goldConvert(m_recordData.lScore));
		end

		local OrderState = recordPanel:getChildByName("OrderState");
		if OrderState then
			local str = "处理中";
	        OrderState:setTextColor(cc.c3b(255,255,255));
	        if m_recordData.Operate == 0 then
	            str = "审核中";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.Operate == 1 then
	            str = "已发放";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.Operate == 2 then
	            str = "已退回";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.Operate == 4 then
	            str = "罚没";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        end
			OrderState:setString(str);
		end
	else
		local OrderNum = recordPanel:getChildByName("OrderNum");
		if OrderNum then
			OrderNum:setString(m_recordData.OrderNum);
		end

		local CreateTime = recordPanel:getChildByName("CreateTime");
		if CreateTime then
			CreateTime:setString(os.date("%m-%d %H:%M",m_recordData.CollectTime));
		end

		local depositeGold = recordPanel:getChildByName("investGold");
		if depositeGold then
			depositeGold:setString(m_recordData.lScore);
		end

		local investMethod = recordPanel:getChildByName("investMethod");
		if investMethod then
			local str = "";
	        investMethod:setTextColor(cc.c3b(255,255,255));
	        if m_recordData.bType == 0 then
	            str = "VIP充值";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.bType == 1 then
	            str = "支付宝";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.bType == 2 then
	            str = "微信";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.bType == 3 then
	            str = "银联";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.bType == 4 then
	            str = "京东";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.bType == 5 then
	            str = "云闪付";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.bType == 6 then
	            str = "QQ";
	            investMethod:setTextColor(cc.c3b(255,255,255));
	        end
			investMethod:setString(str);
		end

		local OrderState = recordPanel:getChildByName("OrderState");
		if OrderState then
			local str = "待支付";
	        OrderState:setTextColor(cc.c3b(255,255,255));
	        if m_recordData.Operate == 0 then
	            str = "待支付";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.Operate == 1 then
	            str = "已支付";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        elseif m_recordData.Operate == 2 then
	            str = "其他";
	            OrderState:setTextColor(cc.c3b(255,255,255));
	        end
			OrderState:setString(str);
		end
	end
end

return GetCashRecordLayer
