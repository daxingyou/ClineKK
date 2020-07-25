
--推广周榜
local GeneralizeRankNode =  class("GeneralizeRankNode", BaseWindow)

--创建类
function GeneralizeRankNode:create()
	local layer = GeneralizeRankNode.new();

	return layer;
end

--构造函数
function GeneralizeRankNode:ctor()
	self.super.ctor(self, false, false);

    self:InitData();

    self:InitUI();

end

--进入
function GeneralizeRankNode:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function GeneralizeRankNode:bindEvent()
    self:pushEventInfo(GeneralizeInfo,"NewGeneralizeRewardRank",handler(self, self.receiveNewGeneralizeRewardRank))
end

function GeneralizeRankNode:receiveNewGeneralizeRewardRank(data)
    local data = data._usedata
    luaDump(data,"receiveNewGeneralizeRewardRank");
    self.logData = data;
    if self.rankTableView then
        self.rankTableView:reloadData();
    end
end

function GeneralizeRankNode:InitData()
    self.logData = {};
end

function GeneralizeRankNode:InitUI()
    local bg = ccui.ImageView:create("newExtend/newGeneralize/dikuang2.png");
    self:addChild(bg);
    bg:setPosition(0,0);
    self.background = bg;

    self.size = self.background:getContentSize();

    local ding = ccui.ImageView:create("newExtend/newGeneralize/kuang.png");
    ding:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.9+10);
    bg:addChild(ding);

    local info1 = ccui.ImageView:create("newExtend/newGeneralize/paiming.png");
    info1:setPosition(ding:getContentSize().width*0.15,ding:getContentSize().height*0.5);
    ding:addChild(info1);

    local info2 = ccui.ImageView:create("newExtend/newGeneralize/wanjiaxinxi.png");
    info2:setPosition(ding:getContentSize().width*0.5,ding:getContentSize().height*0.5);
    ding:addChild(info2);

    local info3 = ccui.ImageView:create("newExtend/newGeneralize/benzhoufanli.png");
    info3:setPosition(ding:getContentSize().width*0.8,ding:getContentSize().height*0.5);
    ding:addChild(info3);

    local tishi = ccui.ImageView:create("newExtend/newGeneralize/zhoubangwenzi.png");
    self.background:addChild(tishi);
    tishi:setPosition(self.size.width*0.5,self.size.height*0.1-10);

    self:createTableView(); 

    GeneralizeInfo:sendGetNewGeneralizeRewardBankRequest();


end

--创建tableview
function GeneralizeRankNode:createTableView()
    if(self.rankTableView) then
        self.rankTableView:removeFromParent();
        self.rankTableView = nil;
    end
    -- if #self.logData==0 then
    --     return;
    -- end
    self.rankTableView = cc.TableView:create(cc.size(921,450));
    if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(self.size.width*0.1-20,self.size.height*0.15));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.background:addChild(self.rankTableView);
    end
end

function GeneralizeRankNode:Rank_scrollViewDidScroll(view)  
    
end  
  
function GeneralizeRankNode:Rank_cellSizeForTable(view, idx)  

    return 921, 80;  
end  
  
function GeneralizeRankNode:Rank_numberOfCellsInTableView(view)  

    return #self.logData
end  
  
function GeneralizeRankNode:Rank_tableCellAtIndex(view, idx)  
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

function GeneralizeRankNode:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local rankNum = rankItem:getChildByName("rankNum");
    local rankNumBg = rankItem:getChildByName("rankNumBg");
    local userName = rankItem:getChildByName("userName");
    local score = rankItem:getChildByName("scoreBg"):getChildByName("score");

    if rankNum then
        rankNum:setString(tostring(index));
    end

    if rankNumBg then
        if index>3 then
            rankNumBg:setVisible(false);
        else
            rankNumBg:setVisible(true);
            rankNumBg:loadTexture("newExtend/newGeneralize/rankbg"..index..".png");
        end
    end

    userName:setString(self.logData[index].NickName);
    score:setString(goldConvert(self.logData[index].Revenue,1));
end

function GeneralizeRankNode:createItem()

    local size = cc.size(921,80);
    --大背景
    local layout = ccui.Layout:create();
    layout:setContentSize(size);
    --layout:setAnchorPoint(0.5,0.5);

    --线
    local itemBg = ccui.ImageView:create("newExtend/newGeneralize/xuxian.png");
    layout:addChild(itemBg);
    itemBg:setPosition(size.width/2-50,0);

    --排名背景
    local rankNumBg = ccui.ImageView:create("newExtend/newGeneralize/rankbg1.png");
    layout:addChild(rankNumBg);
    rankNumBg:setPosition(size.width*0.15-40,size.height*0.5);
    rankNumBg:setName("rankNumBg");

    --排名
    local rankNum = FontConfig.createWithCharMap("1","newExtend/newGeneralize/zitiao2.png",26,38,"0")
    layout:addChild(rankNum);
    rankNum:setAnchorPoint(0.5,0.5);
    rankNum:setPosition(size.width*0.15-40,size.height*0.5);
    rankNum:setName("rankNum");

    --玩家名字
    local userName = FontConfig.createWithSystemFont("害人害己", 24,cc.c3b(150, 91, 25));
    layout:addChild(userName);
    userName:setAnchorPoint(0.5,0.5);
    userName:setPosition(size.width*0.5-30,size.height*0.5);
    userName:setName("userName");

    --金币背景
    local scoreBg = ccui.ImageView:create("newExtend/newGeneralize/jinbi.png");
    layout:addChild(scoreBg);
    scoreBg:setAnchorPoint(0.5,0.5);
    scoreBg:setPosition(size.width*0.70+5,size.height*0.5);
    scoreBg:setName("scoreBg");

    --金币
    local score = FontConfig.createWithSystemFont("0", 24,cc.c3b(212, 63, 12));
    score:setAnchorPoint(0,0.5);
    score:setPosition(50,scoreBg:getContentSize().height*0.5);
    scoreBg:addChild(score);
    score:setName("score");


    return layout;
end

return GeneralizeRankNode;