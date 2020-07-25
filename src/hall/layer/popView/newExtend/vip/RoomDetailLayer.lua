--我的战绩
local RoomDetailLayer = class("RoomDetailLayer", PopLayer)
local VipRoomInfoModule = require("hall.layer.popView.newExtend.vip.VipRoomInfoModule"):getInstance()

function RoomDetailLayer:create(name,id)--厅名字，厅ID,数据
	return RoomDetailLayer.new(name,id,data)
end

function RoomDetailLayer:ctor(name,id)
	
	self.super.ctor(self,PopType.none)

	self.name = name or "";
	self.id = id or 0;
	self.time = os.time();
	
	--收到的数据
    -- self.data = data;
    
	self:initData()

	self:initUI()

	self:bindEvent()

	-- self:receiveData();
end

function RoomDetailLayer:initData()
	
	self.currentPage = 1;--当前页数

	self.pageNums = 1; -- 表示总页数
	
	self.logData = {}; --一天整理过的数据

	self.dateT = 1;--成员战绩 第几天

	self.data = {}
	self.recodeReqList = {}

	
end

function RoomDetailLayer:bindEvent()
    self:pushEventInfo(VipInfo,"guildRecordReq",handler(self, self.receiveGuildRecordReq))
end

function RoomDetailLayer:receiveGuildRecordReq(data)
    local data = data._usedata;
    local code = data[2]

    if code== 0 or code== 1 then--
        for k,v in pairs(data[1]) do
            table.insert(self.recodeReqList,v)
        end
    end
           
    if code== 1 then--
    	self.data = self.recodeReqList;
    	self:receiveData()
        self.recodeReqList = {}
    elseif code== 2 then
        addScrollMessage("ID不存在")
        self.data = self.recodeReqList;
        self:receiveData()
    elseif code== 3 then
        addScrollMessage("没有记录")
        self.data = self.recodeReqList;
        self:receiveData()
    end
end

--接受数据刷新
function RoomDetailLayer:receiveData()
	
    -- self:initData();
    self:adjustData();
    self:updateData();

end

--整理数据
function RoomDetailLayer:adjustData()
	local num = 5; -- 表示一页显示的个数
	self.logData = {}
	for k,v in pairs(self.data) do
		if self.logData[math.floor((k-1)/num)+1]  == nil then
			self.logData[math.floor((k-1)/num)+1] = {};
		end
		table.insert(self.logData[math.floor((k-1)/num)+1],v);
	end

	self.pageNums = #self.logData ;
	if self.pageNums == 0 then
		self.pageNums = 1
	end
	-- luaDump(self.data,"self.data");
	-- luaDump(self.logData,"self.logData");
end

function RoomDetailLayer:initUI()

	VipInfo:sendGuildRecordReq(PlatformLogic.loginResult.dwUserID,self.id,1)

	local winSize = cc.Director:getInstance():getWinSize();

	local bg = ccui.ImageView:create("newExtend/vip/common/bgtype.png");
	bg:setPosition(winSize.width/2,winSize.height/2);
	self:addChild(bg);
	self.bg = bg;

	iphoneXFit(self.bg,1);

	local size = bg:getContentSize();
	self.size = size;

	local ding = ccui.ImageView:create("newExtend/vip/common/ding.png");
	ding:setAnchorPoint(0,1);
	ding:setPosition(0,size.height);
	bg:addChild(ding);

	-- local Image_ziBg = ccui.ImageView:create("newExtend/vip/common/dingzibg.png");
 --    Image_ziBg:setAnchorPoint(0,1);
 --    Image_ziBg:setPosition(-180,size.height);
 --    bg:addChild(Image_ziBg);
    
	-- local bttitle = ccui.ImageView:create("newExtend/vip/detail/tigxiangqing.png");
	-- bttitle:setAnchorPoint(0.5,0.5)
	-- bg:addChild(bttitle);
	-- bttitle:setPosition(cc.p(400,winSize.height-35));

	local closeBtn = ccui.Button:create("newExtend/vip/common/fanhui.png","newExtend/vip/common/fanhui-on.png");
	closeBtn:setPosition(0,size.height-38);
	closeBtn:setAnchorPoint(cc.p(0,0.5))
	bg:addChild(closeBtn);
	closeBtn:onClick(function(sender) self:removeSelf() end)

	
	local di = ccui.ImageView:create("newExtend/vip/detail/di.png");
	di:setPosition(size.width*0.5+75,size.height*0.45-35);
	bg:addChild(di);

	local title = ccui.ImageView:create("newExtend/vip/detail/biaotilan.png");
	title:setPosition(di:getContentSize().width*0.5-80,di:getContentSize().height*0.92+5);
	di:addChild(title)

	local sp = ccui.ImageView:create("newExtend/vip/detail/jiesushijian.png");
	title:addChild(sp)
	sp:setPosition(title:getContentSize().width*0.15,title:getContentSize().height*0.5);

	local sp = ccui.ImageView:create("newExtend/vip/detail/youxifangjian.png");
	title:addChild(sp)
	sp:setPosition(title:getContentSize().width*0.5,title:getContentSize().height*0.5);

	local sp = ccui.ImageView:create("newExtend/vip/detail/shuyingqingkuang.png");
	title:addChild(sp)
	sp:setPosition(title:getContentSize().width*0.85,title:getContentSize().height*0.5);

	local tiao = ccui.ImageView:create("newExtend/vip/detail/tiao.png");
	tiao:setPosition(size.width*0.5-380,610);
	bg:addChild(tiao);

	local tingName = FontConfig.createWithSystemFont("厅名称:"..self.name, 24,cc.c3b(188, 200, 235));
	tingName:setPosition(tiao:getContentSize().width*0.25,tiao:getContentSize().height*0.5)
	tiao:addChild(tingName);

	local tingId = FontConfig.createWithSystemFont("厅ID:"..self.id, 24,cc.c3b(188, 200, 235));
	tingId:setPosition(tiao:getContentSize().width*0.75,tiao:getContentSize().height*0.5)
	tiao:addChild(tingId);

	local riqiBg = ccui.ImageView:create("newExtend/vip/detail/riqixuanze.png");
	riqiBg:setPosition(bg:getContentSize().width*0.5,105);
	bg:addChild(riqiBg);

	local zuoButton = ccui.Button:create("newExtend/vip/detail/zuo.png","newExtend/vip/detail/zuo-on.png");
	riqiBg:addChild(zuoButton);
	zuoButton:setPosition(riqiBg:getContentSize().width*0.1,riqiBg:getContentSize().height*0.5);
	zuoButton:setTag(1);
	zuoButton:onClick(function (sender)
		self:onClickTime(sender);
	end)

	local youButton = ccui.Button:create("newExtend/vip/detail/you.png","newExtend/vip/detail/you-on.png");
	riqiBg:addChild(youButton);
	youButton:setPosition(riqiBg:getContentSize().width*0.9,riqiBg:getContentSize().height*0.5);
	youButton:setTag(2);
	youButton:onClick(function (sender)
		self:onClickTime(sender);
	end)

	self.riqiText = FontConfig.createWithSystemFont(timeConvert(self.time,2), 24,cc.c3b(188, 200, 235));
	self.riqiText:setPosition(riqiBg:getContentSize().width*0.5,riqiBg:getContentSize().height*0.5);
	riqiBg:addChild(self.riqiText);

	local lastButton = ccui.Button:create("newExtend/vip/detail/shangyiye.png","newExtend/vip/detail/shangyiye.png");
	lastButton:setPosition(size.width*0.5-500,105);
	bg:addChild(lastButton);
	lastButton:setTag(3);
	lastButton:onClick(function (sender)
		self:onClickTime(sender);
	end)

	local nextButton = ccui.Button:create("newExtend/vip/detail/xiayiye.png","newExtend/vip/detail/xiayiye.png");
	nextButton:setPosition(size.width*0.5-270,105);
	bg:addChild(nextButton);
	nextButton:setTag(4);
	nextButton:onClick(function (sender)
		self:onClickTime(sender);
	end)

	self.pageText = FontConfig.createWithSystemFont(self.currentPage.."/"..self.pageNums, 24,cc.c3b(255, 255, 255));
	self.pageText:setPosition(size.width*0.5-385,105);
	bg:addChild(self.pageText);

	local tishi = ccui.ImageView:create("newExtend/vip/detail/zuiduochakan.png");
	tishi:setPosition(size.width*0.85,40);
	bg:addChild(tishi);

	local winsize =  cc.Director:getInstance():getWinSize();
    if checkIphoneX() then
        -- closeBtn:setPositionX(closeBtn:getPositionX()-(winsize.width-1280)/2);
        -- bttitle:setPositionX(bttitle:getPositionX()-(winsize.width-1280)/2);
    end

	-- self:receiveData();


end

--左右按钮回调(上一页和下一页)
function RoomDetailLayer:onClickTime(sender)
	local tag = sender:getTag();
	luaPrint("onClickTime",tag);
	if tag == 1 then --左
		self.dateT = self.dateT +1
        if self.dateT >7 then
            self.dateT = 7;
            addScrollMessage("最多查看近7天记录")
            return;
        else
            VipInfo:sendGuildRecordReq(PlatformLogic.loginResult.dwUserID,self.id,self.dateT)
            
            self.time = self.time - 24*60*60;
        end
		self.currentPage = 1
		-- self:receiveData()
	elseif tag == 2 then -- 右
		self.dateT = self.dateT -1
        if self.dateT <1 then
            self.dateT = 1;
            addScrollMessage("最多查看近7天记录")
            return;
        else
            VipInfo:sendGuildRecordReq(PlatformLogic.loginResult.dwUserID,self.id,self.dateT)
            
            self.time = self.time + 24*60*60;
        end
        self.currentPage = 1
		-- self:receiveData()
	elseif tag == 3 then -- 上一页
		self.currentPage = self.currentPage-1
		if self.currentPage <=1 then
			self.currentPage = 1;
		end
		self:updateData()
	elseif tag == 4 then -- 下一页
		self.currentPage = self.currentPage+1
		if self.currentPage > self.pageNums then
			self.currentPage = self.pageNums;
		end
		self:updateData()
	end

end

function RoomDetailLayer:updateData()
	if self.rankTableView then
		self.rankTableView:reloadData();
	else
		self:createTableView();
	end
	if self.pageNums == 0 then
        self.pageNums = 1;
    end
	self.pageText:setString(self.currentPage.."/"..self.pageNums);
	self.riqiText:setString(timeConvert(self.time,2));

end

--创建tableview
function RoomDetailLayer:createTableView()
	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end
	self.rankTableView = cc.TableView:create(cc.size(1210,380));
	if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(self.size.width*0.5-600,300*0.30+50));
        self.rankTableView:setDelegate();
        self.rankTableView:setTouchEnabled(false);

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.bg:addChild(self.rankTableView);
    end
end

function RoomDetailLayer:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function RoomDetailLayer:Rank_cellSizeForTable(view, idx)  

    -- local width = self.Panel_otherMsg:getContentSize().width;
    -- local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return 1210, 75;  

end  
  
function RoomDetailLayer:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
   local len = 1
   if self.logData[self.currentPage] == nil then
   		len = 1
   		self.logData[self.currentPage] ={}
   else
   		len = #self.logData[self.currentPage]
   end
   return len;
end  
  
function RoomDetailLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(); 
        rankItem:setContentSize(cc.size(1180, 55));
        rankItem:setPosition(0,0);
        rankItem:setName("item");
        if rankItem then
            self:setRankInfo(rankItem,index);
        end
        cell = cc.TableViewCell:new();  
        cell:addChild(rankItem);
    else
        local rankItem = cell:getChildByName("item");
        self:setRankInfo(rankItem,index);
    end
    
    return cell;
end 

function RoomDetailLayer:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local timeText = rankItem:getChildByName("timeText");--时间
    local useId = rankItem:getChildByName("useId");--游戏类型
    local useScore = rankItem:getChildByName("useScore");--score
    
    timeText:setString(timeConvert(self.logData[self.currentPage][index].iCreateDate,3));
    useId:setString(VipRoomInfoModule:getRoomNameByRoomID(self.logData[self.currentPage][index].iRoomId));
    if self.logData[self.currentPage][index].iChangeScore >0 then
    	useScore:setString("+"..goldConvert(self.logData[self.currentPage][index].iChangeScore));
    else
    	useScore:setString(goldConvert(self.logData[self.currentPage][index].iChangeScore));
    end
    
end

function RoomDetailLayer:createItem()

	--大背景
	local layout = ccui.Layout:create();
	layout:setContentSize(cc.size(1210,75));
    --layout:setAnchorPoint(0.5,0.5);
    local size = cc.size(1210,75);

	--背景图片
	local itemBg = ccui.ImageView:create("newExtend/vip/detail/xinxitiao.png");
    layout:addChild(itemBg);
    itemBg:setPosition(1210/2,30);

    --时间
    local timeText = FontConfig.createWithSystemFont("12:15:56", 24,cc.c3b(250, 200, 3));
    layout:addChild(timeText);
    timeText:setAnchorPoint(0.5,0.5);
    timeText:setPosition(size.width*0.15-10,25);
    timeText:setName("timeText");

    --游戏类型
    local useId= FontConfig.createWithSystemFont("百人牛牛", 24,cc.c3b(250, 200, 3));
    layout:addChild(useId);
    useId:setAnchorPoint(0.5,0.5);
    useId:setPosition(size.width*0.5-20,25);
    useId:setName("useId");

    --score
    local useScore= FontConfig.createWithSystemFont("+180", 24,FontConfig.colorBlack);
    layout:addChild(useScore);
    useScore:setAnchorPoint(0.5,0.5);
    useScore:setPosition(size.width*0.85-30,25);
    useScore:setName("useScore");
    useScore:setColor(cc.c3b(250, 200, 3));--黄色

	return layout;
end

--刷新tableview
function RoomDetailLayer:updateTableView()

	self:createTableView();

end

return RoomDetailLayer