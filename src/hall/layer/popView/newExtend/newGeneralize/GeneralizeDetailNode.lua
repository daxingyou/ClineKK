
--推广周榜
local GeneralizeDetailNode =  class("GeneralizeDetailNode", BaseWindow)

--创建类
function GeneralizeDetailNode:create()
	local layer = GeneralizeDetailNode.new();

	return layer;
end

--构造函数
function GeneralizeDetailNode:ctor()
	self.super.ctor(self, false, false);

    self:InitData();

    self:InitUI();

end

--进入
function GeneralizeDetailNode:onEnter()
    self:bindEvent();--绑定消息
    self.super.onEnter(self);
end

function GeneralizeDetailNode:bindEvent()
    self:pushEventInfo(GeneralizeInfo,"NewGeneralizeDetail",handler(self, self.receiveNewGeneralizeDetail))
end

function GeneralizeDetailNode:receiveNewGeneralizeDetail(data)
    local data = data._usedata
    luaDump(data,"NewGeneralizeDetail");
    self.logData = data;
    if self.rankTableView then
        self.rankTableView:reloadData()
    end

    --计算总奖励
    local score = 0;
    for k,v in pairs(self.logData) do
        score = score + v.DirectRevenue+v.TeamRevenue;
    end
    self.allScoreText:setString(goldConvert(score,1));

end

function GeneralizeDetailNode:InitData()
    
    self.logData = {};
    self.dateBtn = nil;
    self.pastDay = 0;
    
end

function GeneralizeDetailNode:InitUI()
    local bg = ccui.ImageView:create("newExtend/newGeneralize/detailBg.png");
    self:addChild(bg);
    bg:setPosition(0,0);
    self.background = bg;

    self.size = self.background:getContentSize();

    local tiao = ccui.ImageView:create("newExtend/newGeneralize/kuang.png");
    tiao:setPosition(self.size.width*0.5,self.size.height*0.9);
    self.background:addChild(tiao);

    local image = ccui.ImageView:create("newExtend/newGeneralize/zhishuwanjia2.png");
    tiao:addChild(image);
    image:setPosition(tiao:getContentSize().width*0.2-20,tiao:getContentSize().height*0.5);

    local image = ccui.ImageView:create("newExtend/newGeneralize/zonggongxianjiangli.png");
    tiao:addChild(image);
    image:setPosition(tiao:getContentSize().width*0.5,tiao:getContentSize().height*0.5);

    local image = ccui.ImageView:create("newExtend/newGeneralize/xiajichanshengjiangli.png");
    tiao:addChild(image);
    image:setPosition(tiao:getContentSize().width*0.8,tiao:getContentSize().height*0.5);


    self:createTableView();

    local shijiankuang = ccui.ImageView:create("newExtend/newGeneralize/shijiankuang.png");
    shijiankuang:setAnchorPoint(0.5,0.5)
    shijiankuang:setPosition(self.background:getContentSize().width*0.5,self.background:getContentSize().height*0.1+10)
    self.background:addChild(shijiankuang)

    local timeText = FontConfig.createWithSystemFont("2019-02-27", 30,cc.c3b(150, 91, 25));
    shijiankuang:addChild(timeText);
    timeText:setPosition(shijiankuang:getContentSize().width/2,shijiankuang:getContentSize().height/2);
    self.timeText = timeText;
    self.timeText:setString(timeConvert(os.time(),1)); 

    local btn = ccui.Button:create("newExtend/newGeneralize/zhankaianniu.png","newExtend/newGeneralize/zhankaianniu-on.png")
    btn:setAnchorPoint(1,0.5)
    btn:setPosition(shijiankuang:getContentSize().width-10,shijiankuang:getContentSize().height/2)
    btn:setTag(5)
    shijiankuang:addChild(btn)
    self.xialaButton = btn;
    btn:onClick(function(sender) self:onClickBtn(sender) end)

    local image = ccui.ImageView:create("newExtend/newGeneralize/zongjiangli.png");
    self.background:addChild(image);
    image:setPosition(self.size.width*0.1,self.size.height*0.1);

    --总奖励
    local allScoreText = FontConfig.createWithSystemFont("0", 30,cc.c3b(255, 246, 0));
    allScoreText:setPosition(self.size.width*0.1+80,self.size.height*0.1-5);
    allScoreText:setAnchorPoint(0,0.5);
    self.background:addChild(allScoreText);
    self.allScoreText = allScoreText

    --提示语
    local image = ccui.ImageView:create("newExtend/newGeneralize/tishuyu.png");
    self.background:addChild(image);
    image:setPosition(self.size.width*0.8,self.size.height*0.1-5);

    GeneralizeInfo:sendGetNewGeneralizeDetailRequest(0)


end

function GeneralizeDetailNode:onClickBtn(sender)
    if self.dateBtn == nil then
        luaPrint("onClickBtn");
        local btn = ccui.Widget:create()
        btn:setAnchorPoint(cc.p(0.5,0))
        btn:setPosition(self.size.width*0.50,self.size.height*0.10+20)
        btn:setCascadeOpacityEnabled(true)
        btn:setTouchEnabled(true)
        btn:setSwallowTouches(true)
        self.background:addChild(btn,100)
        self.dateBtn = btn
       
        local width = 0
        local height = 0
        local x = 0
        local y = 0

        for i=1,7 do
            local btn = ccui.Button:create("newExtend/newGeneralize/xiala.png","newExtend/newGeneralize/xiala.png")
            local date = timeConvert(os.time()-24*60*60*(i-1),1)
            if x == 0 then
                height = btn:getContentSize().height
                width = btn:getContentSize().width

                self.dateBtn:setContentSize(cc.size(width,height*7))
                self.dateBtn:setPositionY(self.dateBtn:getPositionY()-height/2)

                x = width/2
                y = height*7
            end

            btn:setPosition(x,y);
            btn:setAnchorPoint(0.5,0);
            btn:setTag(i-1)
            btn:setName(date)
            self.dateBtn:addChild(btn);
            btn:addClickEventListener(function(sender) self:onClickDateBtn(sender) end)

            local text = FontConfig.createWithSystemFont(date,26,cc.c3b(255,255,255))
            text:setPosition(width/2,height/2)
            btn:addChild(text)

            y = y - height
        end

        self.dateBtn:setVisible(false);
        self.dateBtn:setScaleY(0)
        self.dateBtn:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
                self.dateBtn:setVisible(not self.dateBtn:isVisible())
            end),cc.ScaleTo:create(0.2, 1, 1, 1))) 
    else
        
        if self.dateBtn:isVisible() == false then
            self.dateBtn:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
                self.dateBtn:setVisible(not self.dateBtn:isVisible())
                self.dateBtn:setScaleY(1)
            end),cc.ScaleTo:create(0.2, 1, 1, 1))) 
        else
            self.dateBtn:stopAllActions();
            self.dateBtn:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1, 0, 1),cc.DelayTime:create(0.1),
                cc.CallFunc:create(function ()
                   self.dateBtn:setVisible(not self.dateBtn:isVisible()) 
                   self.dateBtn:setScaleY(0)
            end)))
        end
    end

end

function GeneralizeDetailNode:onClickDateBtn(sender)
    if self.dateBtn then
        self.dateBtn:setVisible(not self.dateBtn:isVisible())
    end

    local tag = sender:getTag()
    local name = sender:getName()

    self.timeText:setString(name)

    self.pastDay = tag;

    GeneralizeInfo:sendGetNewGeneralizeDetailRequest(self.pastDay)
end

--创建tableview
function GeneralizeDetailNode:createTableView()
    if(self.rankTableView) then
        self.rankTableView:removeFromParent();
        self.rankTableView = nil;
    end
    
    self.rankTableView = cc.TableView:create(cc.size(921,400));
    if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(self.size.width*0.1,self.size.height*0.20));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.background:addChild(self.rankTableView);
    end
end

function GeneralizeDetailNode:Rank_scrollViewDidScroll(view)  
    
end  
  
function GeneralizeDetailNode:Rank_cellSizeForTable(view, idx)  

    return 921, 80;  
end  
  
function GeneralizeDetailNode:Rank_numberOfCellsInTableView(view)  

    return #self.logData
end  
  
function GeneralizeDetailNode:Rank_tableCellAtIndex(view, idx)  
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

function GeneralizeDetailNode:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local userName = rankItem:getChildByName("userName");
    local allScore = rankItem:getChildByName("allScore");
    local score = rankItem:getChildByName("score");

    userName:setString(self.logData[index].NickName);
    allScore:setString(goldConvert(self.logData[index].DirectRevenue,1));
    score:setString(goldConvert(self.logData[index].TeamRevenue,1));

end

function GeneralizeDetailNode:createItem()

    local size = cc.size(900,80);
    --大背景
    local layout = ccui.Layout:create();
    layout:setContentSize(size);
    --layout:setAnchorPoint(0.5,0.5);

    --线
    local itemBg = ccui.ImageView:create("newExtend/newGeneralize/xuxian.png");
    layout:addChild(itemBg);
    itemBg:setPosition(size.width/2-50,0);

    --玩家名字
    local userName = FontConfig.createWithSystemFont("翠花", 24,cc.c3b(150, 91, 25));
    layout:addChild(userName);
    userName:setAnchorPoint(0.5,0.5);
    userName:setPosition(size.width*0.15-20,size.height*0.5);
    userName:setName("userName");

    --金币
    local allScore = FontConfig.createWithSystemFont("0", 24,cc.c3b(212, 63, 12));
    layout:addChild(allScore);
    allScore:setAnchorPoint(0,0.5);
    allScore:setPosition(size.width*0.40+15,size.height*0.5);
    allScore:setName("allScore");

    local scorebg = ccui.ImageView:create("newExtend/newGeneralize/jinbi.png");
    scorebg:setPosition(-30,allScore:getContentSize().height*0.5+5);
    allScore:addChild(scorebg);

    --金币
    local score = FontConfig.createWithSystemFont("0", 24,cc.c3b(212, 63, 12));
    score:setAnchorPoint(0,0.5);
    score:setPosition(size.width*0.75-20,size.height*0.5);
    layout:addChild(score);
    score:setName("score");

    local scorebg = ccui.ImageView:create("newExtend/newGeneralize/jinbi.png");
    scorebg:setPosition(-30,score:getContentSize().height*0.5+5);
    score:addChild(scorebg);

    
    return layout;
end

return GeneralizeDetailNode;