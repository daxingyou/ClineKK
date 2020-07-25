--领取记录
local GeneralizeLogLayer =  class("GeneralizeLogLayer", PopLayer)

--创建类
function GeneralizeLogLayer:create()
	local layer = GeneralizeLogLayer.new();

	return layer;
end

--构造函数
function GeneralizeLogLayer:ctor()
	self.super.ctor(self,PopType.none)

    self:InitData();

    self:InitUI();

end

--进入
function GeneralizeLogLayer:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function GeneralizeLogLayer:bindEvent()
    self:pushEventInfo(GeneralizeInfo,"NewGeneralizeRewardLog",handler(self, self.receiveNewGeneralizeRewardLog))
end

function GeneralizeLogLayer:receiveNewGeneralizeRewardLog(data)
    local data = data._usedata
    luaDump(data,"NewGeneralizeRewardLog");
    self.logData = data;
    if self.rankTableView then
        self.rankTableView:reloadData()
    end

end

function GeneralizeLogLayer:InitData()
    self.logData = {};
end

function GeneralizeLogLayer:InitUI()
    --背景
    self.bg = ccui.ImageView:create("newExtend/newGeneralize/jilubg.png");
    self:addChild(self.bg);
    local winSize = cc.Director:getInstance():getWinSize();
    self.bg:setPosition(cc.p(winSize.width/2,winSize.height/2));

    self.size = self.bg:getContentSize()

    local title =  ccui.ImageView:create("newExtend/newGeneralize/tiqujilubiaoti.png");
    self.bg:addChild(title);
    title:setPosition(self.size.width*0.5,self.size.height-50);

    local closeBtn = ccui.Button:create("common/close.png","common/close-on.png");
    closeBtn:setPosition(self.size.width-6,self.size.height-59);
    self.bg:addChild(closeBtn);
    closeBtn:onTouchClick(function (sender)
        self:removeFromParent();
    end);

    local tiao = ccui.ImageView:create("newExtend/newGeneralize/jilutiao.png");
    self.bg:addChild(tiao);
    tiao:setPosition(self.size.width*0.5,self.size.height*0.8-10);

    -- local lastBtn = ccui.Button:create("newExtend/newGeneralize/shangyiye.png","newExtend/newGeneralize/shangyiye.png");
    -- lastBtn:setPosition(self.size.width*0.5-150,self.size.height*0.1-10);
    -- self.bg:addChild(lastBtn);

    -- local nextBtn = ccui.Button:create("newExtend/newGeneralize/xiayiye.png","newExtend/newGeneralize/xiayiye.png");
    -- nextBtn:setPosition(self.size.width*0.5+150,self.size.height*0.1-10);
    -- self.bg:addChild(nextBtn);

    self:createTableView();

    GeneralizeInfo:sendGetNewGeneralizeRewardLogRequest()
end

--创建tableview
function GeneralizeLogLayer:createTableView()
    if(self.rankTableView) then
        self.rankTableView:removeFromParent();
        self.rankTableView = nil;
    end
    
    self.rankTableView = cc.TableView:create(cc.size(921,350));
    if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(self.size.width*0.1-20,self.size.height*0.15+25));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.bg:addChild(self.rankTableView);
    end
end

function GeneralizeLogLayer:Rank_scrollViewDidScroll(view)  
    
end  
  
function GeneralizeLogLayer:Rank_cellSizeForTable(view, idx)  

    return 921, 80;  
end  
  
function GeneralizeLogLayer:Rank_numberOfCellsInTableView(view)  

    return #self.logData
end  
  
function GeneralizeLogLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(); 
        rankItem:setContentSize(cc.size(921, 80));
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

function GeneralizeLogLayer:setRankInfo(rankItem,index)
    local time = rankItem:getChildByName("time");
    local score = rankItem:getChildByName("score");
    local station = rankItem:getChildByName("station");

    score:setString(goldConvertFour(self.logData[index].TradeScore,2))
    time:setString(timeConvert(self.logData[index].CreateDate,3))
    

end

function GeneralizeLogLayer:createItem()

    local size = cc.size(921,80);
    --大背景
    local layout = ccui.Layout:create();
    layout:setContentSize(size);
    --layout:setAnchorPoint(0.5,0.5);

    --线
    local itemBg = ccui.ImageView:create("newExtend/newGeneralize/xuxian.png");
    layout:addChild(itemBg);
    itemBg:setPosition(size.width/2-50,0);

    --时间
    local time = FontConfig.createWithSystemFont("2019-08-30", 24,cc.c3b(150, 91, 25));
    layout:addChild(time)
    time:setPosition(size.width*0.15-30,size.height*0.5);
    time:setName("time");

    --金额
    local score = FontConfig.createWithSystemFont("0元", 24,cc.c3b(212, 63, 12));
    score:setAnchorPoint(0,0.5);
    score:setPosition(size.width*0.5-35,size.height*0.5);
    layout:addChild(score);
    score:setName("score");

    --当前状态
    local station = FontConfig.createWithSystemFont("成功", 24,cc.c3b(29, 148, 65));
    station:setAnchorPoint(0,0.5);
    station:setPosition(size.width*0.8+20,size.height*0.5);
    layout:addChild(station);
    station:setName("station");


    return layout;
end

return GeneralizeLogLayer;