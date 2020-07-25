
-- 明细 第一层

local ZiJinDetail = class("ZiJinDetail", PopLayer)

function ZiJinDetail:create(data)
	return ZiJinDetail.new(data)
end

function ZiJinDetail:ctor(data)
	
	self.super.ctor(self,PopType.middle)
	
    self.data = data; --收到的数据

    --luaDump(data,"余额宝明细记录");

	self:initData()

	self:initUI()

	self:bindEvent()
end

function ZiJinDetail:initData()
	self.detailBtns = {};
	--self.data = {};
	self.ButtonIndex = 1;

    self.logData = {};--分好类的数据

    self.pastDay = 0;

    self.dateBtn = nil;

    --self.logData = self:adjustData(self.data);
    --luaDump(self.logData,"转化好的数据");

end

function ZiJinDetail:split(msg)
    --luaDump(msg,"split");
    local str = "";
    temp = string.split(msg.bType,"(")
    --str = temp[1];
    if temp[2] ~= nil then
        temp[2] = "("..temp[2];
    end
    return temp;
end

function ZiJinDetail:bindEvent()
	self:pushEventInfo(PartnerInfo,"PartnerUserInfo",handler(self, self.receivePartnerUserInfo))--明细
end

--明细
function ZiJinDetail:receivePartnerUserInfo(data)
    local data = data._usedata
    luaDump(data,"明细ZiJinDetail");
    self.logData = data;
    if self.rankTableView then
        self.rankTableView:reloadData();
    else
        self:createTableView();
    end

end

function ZiJinDetail:initUI()

    PartnerInfo:sendGetPartnerUserInfoRequest(0);

	self.sureBtn:removeSelf()
	
	local title = ccui.ImageView:create("newExtend/hehuoren/hehuorenmingxi.png")
	title:setPosition(self.size.width/2,self.size.height-45)
	self.bg:addChild(title)

	local size = self.bg:getContentSize()

	local x = self.size.width*0.1

	local info = ccui.ImageView:create("newExtend/hehuoren/biaotilan.png")
	info:setAnchorPoint(0.5,0.5)
	info:setPosition(self.size.width*0.5,size.height*0.8-10)
	self.bg:addChild(info)

	local time = ccui.ImageView:create("newExtend/hehuoren/nichen.png");
	time:setAnchorPoint(0,0.5)
	time:setPosition(info:getContentSize().width*0.1-20,time:getContentSize().height*0.5+10)
	info:addChild(time)

	local stype = ccui.ImageView:create("newExtend/hehuoren/id.png");
	stype:setAnchorPoint(0,0.5)
	stype:setPosition(info:getContentSize().width*0.35-40,stype:getContentSize().height*0.5+10)
	info:addChild(stype)

	local money = ccui.ImageView:create("newExtend/hehuoren/shuyingzancheng.png");
	money:setAnchorPoint(0,0.5)
	money:setPosition(info:getContentSize().width*0.6-90,money:getContentSize().height*0.5+10)
	info:addChild(money)

	local balance = ccui.ImageView:create("newExtend/hehuoren/caozuo.png");
	balance:setAnchorPoint(0,0.5)
	balance:setPosition(info:getContentSize().width*0.8,balance:getContentSize().height*0.5+10)
	info:addChild(balance)

    local tishiyu = ccui.ImageView:create("newExtend/hehuoren/tishuyu.png");
    tishiyu:setAnchorPoint(0.5,0.5)
    tishiyu:setPosition(self.bg:getContentSize().width*0.80,self.bg:getContentSize().height*0.1)
    self.bg:addChild(tishiyu)

    local shijiankuang = ccui.ImageView:create("newExtend/hehuoren/shijiankuang.png");
    shijiankuang:setAnchorPoint(0.5,0.5)
    shijiankuang:setPosition(self.bg:getContentSize().width*0.5,self.bg:getContentSize().height*0.1+10)
    self.bg:addChild(shijiankuang)

    local timeText = FontConfig.createWithSystemFont("2019-02-27", 30,cc.c3b(174, 176, 217));
    shijiankuang:addChild(timeText);
    timeText:setPosition(shijiankuang:getContentSize().width/2,shijiankuang:getContentSize().height/2);
    self.timeText = timeText;
    self.timeText:setString(timeConvert(os.time(),1));
    -- timeText:setColor(cc.c3b(193, 210, 246));

    local btn = ccui.Button:create("newExtend/hehuoren/zhankaianniu.png","newExtend/hehuoren/zhankaianniu-on.png")
    btn:setAnchorPoint(1,0.5)
    btn:setPosition(shijiankuang:getContentSize().width-10,shijiankuang:getContentSize().height/2)
    btn:setTag(5)
    shijiankuang:addChild(btn)
    self.xialaButton = btn;
    btn:onClick(function(sender) self:onClickBtn(sender) end)

	self:createTableView();
	
end


function ZiJinDetail:onClickBtn(sender)
    if self.dateBtn == nil then
        local btn = ccui.Widget:create()
        btn:setAnchorPoint(cc.p(0.5,0))
        btn:setPosition(cc.Director:getInstance():getWinSize().width*0.50,self.size.height*0.20)
        btn:setCascadeOpacityEnabled(true)
        btn:setTouchEnabled(true)
        btn:setSwallowTouches(true)
        self:addChild(btn,100)
        self.dateBtn = btn
       
        local width = 0
        local height = 0
        local x = 0
        local y = 0

        for i=1,7 do
            local btn = ccui.Button:create("newExtend/hehuoren/xiala.png","newExtend/hehuoren/xiala.png")
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

            local text = FontConfig.createWithSystemFont(date,26,cc.c3b(174, 176, 217))
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

function ZiJinDetail:onClickDateBtn(sender)
    if self.dateBtn then
        self.dateBtn:setVisible(not self.dateBtn:isVisible())
    end

    local tag = sender:getTag()
    local name = sender:getName()

    self.timeText:setString(name)

    self.pastDay = tag;

    PartnerInfo:sendGetPartnerUserInfoRequest(tag);
end

--创建tableview
function ZiJinDetail:createTableView()
	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end
	self.rankTableView = cc.TableView:create(cc.size(914,370));
	if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(100,350*0.3+30));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.bg:addChild(self.rankTableView);
    end
end

function ZiJinDetail:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function ZiJinDetail:Rank_cellSizeForTable(view, idx)  

    -- local width = self.Panel_otherMsg:getContentSize().width;
    -- local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return 914, 80;  

end  
  
function ZiJinDetail:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
    return #self.logData--#self.logData[self.ButtonIndex]--table.nums(self.tableLayer.otherMsgTable);
end  
  
function ZiJinDetail:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(); 
        rankItem:setContentSize(cc.size(914, 80));
        rankItem:setPosition(20,0);
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

function ZiJinDetail:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local useName = rankItem:getChildByName("useName");
    local useId = rankItem:getChildByName("useId");
    local useScore = rankItem:getChildByName("useScore");
    local btnXiangqing = rankItem:getChildByName("btnXiangqing");
    btnXiangqing:addClickEventListener(function ()
        audio.playSound(GAME_SOUND_BUTTON)
        luaPrint("setRankInfo-ZiJinDetail",self.logData[index].NickName,self.logData[index].UserID, self.pastDay);
        local layer = require("layer.popView.newExtend.hehuoren.DeDetailLayer"):create(self.logData[index],self.pastDay);
        display.getRunningScene():addChild(layer); 
    end);

    useName:setString(FormotGameNickName(self.logData[index].NickName,6));
    useId:setString(self.logData[index].UserID);
    useScore:setString(goldConvert(self.logData[index].SumScore,1));
    if self.logData[index].SumScore < 0 then
        useScore:setColor(cc.c3b(49, 200, 45));--绿色
    else
         useScore:setColor(cc.c3b(230, 173, 44));
    end
    
end

function ZiJinDetail:createItem()

	--大背景
	local layout = ccui.Layout:create();
	layout:setContentSize(cc.size(914,80));
    --layout:setAnchorPoint(0.5,0.5);

	--背景图片
	local itemBg = ccui.ImageView:create("newExtend/hehuoren/fengexian.png");
    layout:addChild(itemBg);
    itemBg:setPosition(914/2-50,6);

    --名字
    local useName = FontConfig.createWithSystemFont("詹姆斯哈登mvp", 24,FontConfig.colorBlack);
    layout:addChild(useName);
    useName:setAnchorPoint(0.5,0.5);
    useName:setPosition(100-10,40);
    useName:setName("useName");
    useName:setColor(cc.c3b(174, 176, 217));

    --ID
    local useId= FontConfig.createWithSystemFont("215632", 24,FontConfig.colorBlack);
    layout:addChild(useId);
    useId:setAnchorPoint(0.5,0.5);
    useId:setPosition(320-50,40);
    useId:setName("useId");
    useId:setColor(cc.c3b(174, 176, 217));

    --score
    local useScore= FontConfig.createWithSystemFont("+180", 24,FontConfig.colorBlack);
    layout:addChild(useScore);
    useScore:setAnchorPoint(0.5,0.5);
    useScore:setPosition(550-50,40);
    useScore:setName("useScore");
    useScore:setColor(cc.c3b(49, 200, 45));--绿色

    --按钮 详情
    local btnXiangqing = ccui.Button:create("newExtend/hehuoren/xiangqing.png","newExtend/hehuoren/xiangqing-on.png");
    layout:addChild(btnXiangqing);
    btnXiangqing:setPosition(780,40);
    btnXiangqing:setName("btnXiangqing");

	return layout;
end

--刷新tableview
function ZiJinDetail:updateTableView()

	self:createTableView();

end

return ZiJinDetail
