-- local QklConfig = require("qukuailian.Config")

local UserLogLayer = class("UserLogLayer", PopLayer)

function UserLogLayer:ctor(_recordList,target)
	-- self.super.ctor(self,PopType.small)
	self.super.ctor(self, PopType.moreBig)
	self:setName("UserLogLayer");

	self:initData(_recordList,target);
	self:initUI();

end

function UserLogLayer:create(_recordList,target)
	local layer = UserLogLayer.new(_recordList,target);

	return layer;
end


function UserLogLayer:initUI()
	self.sureBtn:removeSelf()
	self:updateBg("hall/UserLog/UserLog_commonBg1.png");
	self:updateCloseBtnPos(10,-30);
	local size = self.bg:getContentSize();

	local title = ccui.ImageView:create("hall/UserLog/UserLog_zhanji.png");
	title:setPosition(size.width/2,size.height-50);
	self.bg:addChild(title);

	local ding = ccui.ImageView:create("hall/UserLog/UserLog_dinglan.png");
	ding:setAnchorPoint(0.5,1);
	ding:setPosition(size.width/2,size.height-120);
	self.bg:addChild(ding);

	local dingSize = ding:getContentSize();

	--创建结束时间的图片
	local shijian = ccui.ImageView:create("hall/UserLog/UserLog_jieshushijian.png");
	shijian:setPosition(230,dingSize.height/2);
	ding:addChild(shijian);

	local shuying = ccui.ImageView:create("hall/UserLog/UserLog_shuyingqingkuang.png");
	shuying:setPosition(620,dingSize.height/2);
	ding:addChild(shuying);

	local xiangqing = ccui.ImageView:create("hall/UserLog/UserLog_touzhuxiangqing.png");
	xiangqing:setPosition(960,dingSize.height/2);
	ding:addChild(xiangqing);

	-- 创建按钮的tableview
    self.gameBtnTableView = cc.TableView:create(cc.size(1068,465));
    if self.gameBtnTableView then  
        self.gameBtnTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.gameBtnTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
        self.gameBtnTableView:setAnchorPoint(cc.p(0,0)); 
        self.gameBtnTableView:setPosition(cc.p(55, 21));
        self.gameBtnTableView:setDelegate();

        self.gameBtnTableView:registerScriptHandler( handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED);  
        self.gameBtnTableView:registerScriptHandler( handler(self, self.tabel_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.gameBtnTableView:registerScriptHandler( handler(self, self.tabel_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.gameBtnTableView:registerScriptHandler( handler(self, self.tabel_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  

        self.bg:addChild(self.gameBtnTableView);
        self.gameBtnTableView:reloadData();
    end
end

function UserLogLayer:onClick(sender)
	local senderName = sender:getName();
	local senderTag = sender:getTag();

	if senderName == "Button_xiangqing" then
		local layer = self.target:getChildByName("ItemLog");
		if layer then
			return;
		end

		local LogLayer = require("UserLog.ItemLog");

    	local logPop = LogLayer:create(self.m_recordDataList[senderTag]);
    	logPop:ignoreAnchorPointForPosition(false);
		logPop:setAnchorPoint(cc.p(0.5,0.5));
    	
    	local size = self.target:getContentSize();
    	logPop:setPosition(size.width/2,size.height/2);
    	self.target:addChild(logPop,9999);

	end
end


function UserLogLayer:initData(_recordList,target)
	self.m_recordDataList = _recordList; --
	self.target = target;
end

function UserLogLayer:refreshLog(data)
	self.m_recordDataList = data;

	if self.gameBtnTableView then
		self.gameBtnTableView:reloadData();
	end
end

--用户列表
--cell点击事件
function UserLogLayer:tableCellTouched(table,cell)
    --CommomFunc_TableViewReloadData_Vertical(self.gameBtnTableView, cc.size( 200, self.Panel_userInfo:getContentSize().height+10), false);
end
--列表项的尺寸
function UserLogLayer:tabel_cellSizeForTable(sender, index)
    return 1068,80;
end

--列表项的数量 
function UserLogLayer:tabel_numberOfCellsInTableView(sender)
    return #self.m_recordDataList;
end

--创建列表项
function UserLogLayer:tabel_tableCellAtIndex(sender, index)   
    local cell = sender:dequeueCell();
    if nil == cell then
    	local cellSize = cc.size(1068,80)
        cell = cc.TableViewCell:new();
        local gamePanel = ccui.ImageView:create("hall/UserLog/UserLog_dikuang.png"); 
        gamePanel:setAnchorPoint(0.5,0);
        gamePanel:setPosition(cc.p(cellSize.width/2,0));
        gamePanel:setName("gamePanel");  
        cell:addChild(gamePanel);

        --创建结束时间
        local finishTime = FontConfig.createWithSystemFont("",26,cc.c3b(255,249,217));
        finishTime:setName("finishTime");
	    finishTime:setPosition(240,cellSize.height/2);
	    gamePanel:addChild(finishTime);

        --创建输赢
        local scoreText = FontConfig.createWithSystemFont("",26,cc.c3b(68,157,41));--156 18 18
        scoreText:setName("scoreText");
	    scoreText:setPosition(620,cellSize.height/2);
	    gamePanel:addChild(scoreText);

        --创建详情按钮
        local Button_xiangqing = ccui.Button:create("UserLog/UserLog_xiangqing.png","UserLog/xiangqing-UserLog_on.png","UserLog/xiangqing-UserLog_on.png");
        Button_xiangqing:setName("Button_xiangqing");
		Button_xiangqing:setPosition(970,cellSize.height/2);
		gamePanel:addChild(Button_xiangqing);
		Button_xiangqing:setTag(index+1);
		Button_xiangqing:onClick(handler(self,self.onClick));

        self:SetGameBtnInfo(gamePanel, index);     
    else
        local gamePanel = cell:getChildByName("gamePanel");
        self:SetGameBtnInfo(gamePanel, index);
	end
	
    
    return cell;
end

function UserLogLayer:SetGameBtnInfo(gamePanel,idx)

	local m_recordData = self.m_recordDataList[idx+1];

	local finishTime = gamePanel:getChildByName("finishTime");
	if finishTime then
		finishTime:setString(os.date("%Y-%m-%d %H:%M:%S",m_recordData.CreateDate));
	end

	local scoreText = gamePanel:getChildByName("scoreText");
	if scoreText then
		local score = goldConvert(m_recordData.lScore);
		if score >= 0 then
			scoreText:setColor(cc.c3b(68,157,41));
			scoreText:setString("+"..score);
		else
			scoreText:setColor(cc.c3b(156,18,18));
			scoreText:setString(score);
		end

	end

	local Button_xiangqing = gamePanel:getChildByName("Button_xiangqing");
	if Button_xiangqing then
		Button_xiangqing:setTag(idx+1);
	end
end


return UserLogLayer
