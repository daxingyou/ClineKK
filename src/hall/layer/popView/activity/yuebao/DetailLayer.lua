
-- 明细

local DetailLayer = class("DetailLayer", PopLayer)

function DetailLayer:create(data)
	return DetailLayer.new(data)
end

function DetailLayer:ctor(data)
	
	self.super.ctor(self,PopType.moreBig)
	
    self.data = {}; --收到的数据

    self.TextColor = cc.c3b(255, 255, 255);
    --luaDump(data,"余额宝明细记录");

	self:initData()

	self:initUI()

	self:bindEvent()
end

function DetailLayer:initData()
	self.detailBtns = {};
	--self.data = {};
	self.ButtonIndex = 1;

    self.logData = {{},{},{},{},{},{}};--分好类的数据

    --self.logData = self:adjustData(self.data);
    --luaDump(self.logData,"转化好的数据");

end

--分析数据
function DetailLayer:adjustData(data)
    local logData = {{},{},{},{},{},{}};

    if #data == 0 then
        return logData;
    end

    for k,v in pairs(data) do
        local keyStr = "";
        keyStr = self:split(v)[1];
        --luaPrint("keyStr",keyStr,keyStr == "转账");
        if keyStr == "转入" or keyStr == "收益" or keyStr == "转出" or keyStr == "转账" then
            table.insert(logData[1],clone(v)); --记录全部的数据
            if keyStr == "转入" then
                table.insert(logData[2],clone(v)); --记录转入的数据
            elseif keyStr == "收益" then
                table.insert(logData[3],clone(v)); --记录收益的数据
            elseif keyStr == "转出" then
                table.insert(logData[4],clone(v)); --记录转出的数据
            elseif keyStr == "转账" then
                table.insert(logData[5],clone(v)); --记录转账的数据
            else
                luaPrint("出现未知数据！！！！！");
            end
        else
            table.insert(logData[6],clone(v)); --记录其他的数据
        end

    end

    return logData;
end


function DetailLayer:split(msg)
    --luaDump(msg,"split");
    local str = "";
    temp = string.split(msg.bType,"(")
    --str = temp[1];
    if temp[2] ~= nil then
        temp[2] = "("..temp[2];
    end
    return temp;
end

function DetailLayer:bindEvent()
	self:pushEventInfo(YuEBaoInfo,"bankLog",handler(self, self.receiveBankLog))
end

function DetailLayer:receiveBankLog(data)
    local data = data._usedata
    self.data = data;
    self.logData = self:adjustData(self.data);
    luaDump(self.logData,"转化好的数据");
    self:createTableView();
    
end

function DetailLayer:initUI()
	self.sureBtn:removeSelf()
	
	local title = ccui.ImageView:create("activity/yuebao/yeb_title_mingxi.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	local size = self.bg:getContentSize()

	local x = self.size.width*0.1+50

	--全部
	local btn = ccui.Button:create("activity/yuebao/yeb_quanbu.png","activity/yuebao/yeb_quanbu.png","activity/yuebao/yeb_quanbu-on.png")
	btn:setPosition(x,size.height*0.80)
	btn:setTag(1)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	btn:setEnabled(false)
	table.insert(self.detailBtns,btn)

	--转入
	local btn = ccui.Button:create("activity/yuebao/yeb_zhuanru1.png","activity/yuebao/yeb_zhuanru1.png","activity/yuebao/yeb_zhuanru1-on.png")
	btn:setPosition(x,size.height*0.70-20)
	btn:setTag(2)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	--btn:setEnabled(false)
	table.insert(self.detailBtns,btn)

	--收益
	local btn = ccui.Button:create("activity/yuebao/yeb_shouyi.png","activity/yuebao/yeb_shouyi.png","activity/yuebao/yeb_shouyi-on.png")
	btn:setPosition(x,size.height*0.60-40)
	btn:setTag(3)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	--btn:setEnabled(false)
	table.insert(self.detailBtns,btn)

	--转出
	local btn = ccui.Button:create("activity/yuebao/yeb_zhuanchu1.png","activity/yuebao/yeb_zhuanchu1.png","activity/yuebao/yeb_zhuanchu1-on.png")
	btn:setPosition(x,size.height*0.50-60)
	btn:setTag(4)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	--btn:setEnabled(false)
	table.insert(self.detailBtns,btn)

    --转账
    local btn = ccui.Button:create("activity/yuebao/yeb_zhuanzhang.png","activity/yuebao/yeb_zhuanzhang.png","activity/yuebao/yeb_zhuanzhang-on.png")
    btn:setPosition(x,size.height*0.40-80)
    btn:setTag(5)
    self.bg:addChild(btn)
    btn:onClick(function(sender) self:onClickBtn(sender) end)
    btn:setVisible(false)
    if YuEBaoInfo:isOpenTransfer() then
        btn:setVisible(true)
        table.insert(self.detailBtns,btn)
    end

	--其他
	local btn = ccui.Button:create("activity/yuebao/yeb_qita.png","activity/yuebao/yeb_qita.png","activity/yuebao/yeb_qita-on.png")
	btn:setPosition(x,size.height*0.30-100)
	btn:setTag(6)
	self.bg:addChild(btn)
	btn:onClick(function(sender) self:onClickBtn(sender) end)
	--btn:setVisible(false)
	table.insert(self.detailBtns,btn)

    local dis = 0;
    local num = #self.detailBtns;
    dis = 0.8/num - 0.01;
    for k,v in pairs(self.detailBtns) do
        v:setScale(1.0);
        v:setPositionY(size.height*0.80-(k-1)*98*0.9-12);
    end

    YuEBaoInfo:sendBankLogRequest();
	
end

--创建tableview
function DetailLayer:createTableView()
	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end
	self.rankTableView = cc.TableView:create(cc.size(839,550));
	if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(300,15));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.bg:addChild(self.rankTableView);
    end
end

function DetailLayer:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function DetailLayer:Rank_cellSizeForTable(view, idx)  

    -- local width = self.Panel_otherMsg:getContentSize().width;
    -- local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return 839, 109;  

end  
  
function DetailLayer:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
    return #self.logData[self.ButtonIndex]--table.nums(self.tableLayer.otherMsgTable);
end  
  
function DetailLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(); 
        rankItem:setContentSize(cc.size(839, 95));
        rankItem:setName("item");
        rankItem:setPosition(cc.p(0,0));

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

function DetailLayer:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local title = rankItem:getChildByName("title");
    local titleText_big = rankItem:getChildByName("titleText_big");
    local titleText_small = rankItem:getChildByName("titleText_small");
    local time = rankItem:getChildByName("time");
    local changesMoney = rankItem:getChildByName("changesMoney");
    local allMoney = rankItem:getChildByName("allMoney");

    local keyStr = ""; --大字
    keyStr = self:split(self.logData[self.ButtonIndex][index])[1];

    local smallStr = ""; --小字
    if self:split(self.logData[self.ButtonIndex][index])[2] ~= nil then
        smallStr = self:split(self.logData[self.ButtonIndex][index])[2];
    end

    --图标 title
    if keyStr == "转入" then
       title:loadTexture("activity/yuebao/yeb_zhuanrutubiao.png"); 
    elseif keyStr == "收益" then
        title:loadTexture("activity/yuebao/yeb_shouyitubiao.png"); 
    elseif keyStr == "转出" or keyStr == "转账" then
        title:loadTexture("activity/yuebao/yeb_zhuanchutubiao.png"); 
    else
        title:loadTexture("activity/yuebao/yeb_zhuanrutubiao.png");
    end

    titleText_big:setString(keyStr);
    titleText_small:setString(smallStr);
    titleText_small:setPositionX(titleText_big:getContentSize().width+110);

    time:setString(timeConvert(self.logData[self.ButtonIndex][index].ColletTime,3))

    --分数
    local changeScore = goldConvertFour(self.logData[self.ButtonIndex][index].OperatScore,1)
    if(self.logData[self.ButtonIndex][index].OperatScore>=0) then
        changeScore = "+"..changeScore
    end
    
    changesMoney:setString(changeScore);
    if self.logData[self.ButtonIndex][index].OperatScore>=0 then
        changesMoney:setColor(cc.c3b(239, 210, 162));--黄色
    else
        changesMoney:setColor(cc.c3b(169, 232, 116));--绿色
    end
    allMoney:setString(goldConvertFour(self.logData[self.ButtonIndex][index].NowScore,1));

    
    --Image_otherHead:loadTexture(getHeadPath(userInfo.bLogoID,userInfo.bBoy));
   
    
end

function DetailLayer:createItem()

	--大背景
	local layout = ccui.Layout:create();
	layout:setContentSize(cc.size(839,500));
	--背景图片
	local itemBg = ccui.ImageView:create("activity/yuebao/yeb_di-1.png");
    layout:addChild(itemBg);
    itemBg:setPosition(839/2,95/2);

    --标题
    local title = ccui.ImageView:create("activity/yuebao/yeb_zhuanrutubiao.png");
    layout:addChild(title);
    title:setPosition(50,60);
    title:setName("title");

    --文字 大
    local titleText_big = FontConfig.createWithSystemFont("收益", 35,self.TextColor);
    layout:addChild(titleText_big);
    titleText_big:setAnchorPoint(0,0.5);
    titleText_big:setPosition(100,60);
    titleText_big:setName("titleText_big");
    titleText_big:setColor(cc.c3b(221,200,151));

    --文字 小
    local titleText_small = FontConfig.createWithSystemFont("(日化利率利息)", 25,self.TextColor);
    layout:addChild(titleText_small);
    titleText_small:setAnchorPoint(0,0.5);
    titleText_small:setPosition(180,60);
    titleText_small:setName("titleText_small");
    titleText_small:setColor(self.TextColor);

    --时间背景
    local timeBg = ccui.ImageView:create("activity/yuebao/yeb_di-2.png");
    layout:addChild(timeBg);
    timeBg:setPosition(200,20);

    --时间
    local time = FontConfig.createWithSystemFont("2019-02-27 15:15:24", 20,self.TextColor);
    layout:addChild(time);
    time:setPosition(200,20);
    time:setName("time");
    time:setColor(cc.c3b(255,171,110));

    --变动
    local changesMoney = FontConfig.createWithSystemFont("+22.00", 40);
    layout:addChild(changesMoney);
    changesMoney:setPosition(layout:getContentSize().width*0.95,60);
    changesMoney:setName("changesMoney");
    changesMoney:setColor(cc.c3b(255, 72, 0));
    changesMoney:setAnchorPoint(1,0.5);

    --剩余的钱
    local allMoney = FontConfig.createWithSystemFont("125.00", 25);
    layout:addChild(allMoney);
    allMoney:setPosition(layout:getContentSize().width*0.95,20);
    allMoney:setName("allMoney");
    allMoney:setColor(cc.c3b(253,231,224));
    allMoney:setAnchorPoint(1,0.5);



	return layout;
end

--刷新tableview
function DetailLayer:updateTableView()

	self:createTableView();

end

function DetailLayer:onClickBtn(sender)
	local tag = sender:getTag()

	self:selectBankOperation(tag)

	self.ButtonIndex = tag

	self:updateTableView();
end

function DetailLayer:selectBankOperation(tag)
	for k,v in pairs(self.detailBtns) do
		v:setEnabled(v:getTag()~=tag)
	end
end



return DetailLayer
