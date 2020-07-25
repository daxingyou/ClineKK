
-- 详情 --第二层

local DeDetailLayer = class("DeDetailLayer", PopLayer)

function DeDetailLayer:create(user,pastDay)
	return DeDetailLayer.new(user,pastDay)
end

function DeDetailLayer:ctor(user,pastDay)
	
	self.super.ctor(self,PopType.middle)
    luaPrint("DeDetailLayer",user,pastDay);
    self.user = user;
    self.pastDay = pastDay; 
    self.TextColor = cc.c3b(174, 176, 217);
    
    --luaPrint("DeDetailLayer",self.NickName,self.UserID,self.pastDay,self.money );
    --luaDump(data,"余额宝明细记录");
    self.currentPage = 1;--当前页数

    self.allPage = 1;--最大页数

	self:initData()

	self:initUI()

	self:bindEvent()
end

function DeDetailLayer:initData()
	self.detailBtns = {};
	--self.data = {};
	self.ButtonIndex = 1;

    self.logData = {};--分好类的数据

end

function DeDetailLayer:adjustData(logData)
    local x = 10;--多少个数据一页
    local data = {};

    for k,v in pairs(logData) do
        if data[math.floor((k-1)/x)+1] == nil then
            data[math.floor((k-1)/x)+1] ={};
        end
        table.insert(data[math.floor((k-1)/x)+1],v);
    end

    return data;
end

function DeDetailLayer:split(msg)
    --luaDump(msg,"split");
    local str = "";
    temp = string.split(msg.bType,"(")
    --str = temp[1];
    if temp[2] ~= nil then
        temp[2] = "("..temp[2];
    end
    return temp;
end

function DeDetailLayer:bindEvent()
	self:pushEventInfo(PartnerInfo,"PartnerUserInfoDetail",handler(self, self.receivePartnerUserInfoDetail))--明细
    self:pushEventInfo(PartnerInfo,"PartnerUserInfo",handler(self, self.receivePartnerUserInfo))--明细刷新用
end

--接受玩家信息
function DeDetailLayer:receivePartnerUserInfo(data)
    local data = data._usedata
    luaDump(data,"更新分数");
    for k,v in pairs(data) do
        if v.UserID == self.user.UserID then
            luaPrint("找到",v.SumScore);
            if self.score then
                self.score:setString(goldConvert(v.SumScore));
            end
            break;
        end
    end
end

--明细
function DeDetailLayer:receivePartnerUserInfoDetail(data)
    local data = data._usedata
    luaDump(data,"明细Detail");
    self.logData = data;

    self.logData = self:adjustData(self.logData);
    luaDump(self.logData,"转化好的数据");
    self.currentPage = 1;
    self.allPage = #self.logData;
    if self.allPage <= 1 then
        self.allPage = 1;
    end

    self.pageInfo:setString(self.currentPage.."/"..self.allPage);

    if self.rankTableView then
        self.rankTableView:reloadData();
    else
        self:createTableView();
    end
end

function DeDetailLayer:initUI()

    PartnerInfo:sendGetPartnerUserInfoRequest(self.pastDay);
    PartnerInfo:sendGetPartnerUserInfoDetailRequest(self.user.UserID,self.pastDay);

	self.sureBtn:removeSelf()
	
	local title = ccui.ImageView:create("newExtend/hehuoren/hehuorenmingxi.png")
	title:setPosition(self.size.width/2,self.size.height-45)
	self.bg:addChild(title)

	local size = self.bg:getContentSize()

	local x = self.size.width*0.1

    local name = FontConfig.createWithSystemFont(FormotGameNickName(self.user.NickName,6), 30,self.TextColor);
    name:setPosition(self.size.width*0.2,size.height*0.8-5);
    self.bg:addChild(name);
    self.name = name;

    local id = FontConfig.createWithSystemFont("ID:"..self.user.UserID, 30,self.TextColor);
    id:setPosition(self.size.width*0.5,size.height*0.8-5);
    self.bg:addChild(id);
    self.id = id;

    local scoreTitle = FontConfig.createWithSystemFont("输赢占成:", 30,self.TextColor);
    scoreTitle:setPosition(self.size.width*0.8-60,size.height*0.8-5);
    self.bg:addChild(scoreTitle);

    local score = FontConfig.createWithSystemFont(goldConvert(self.user.SumScore,1), 30,self.TextColor);
    score:setPosition(self.size.width*0.8+20,size.height*0.8-5);
    self.bg:addChild(score);
    score:setAnchorPoint(0,0.5);
    self.score = score;
    score:setColor(cc.c3b(49, 200, 45));--绿色

	local info = ccui.ImageView:create("newExtend/hehuoren/biaotilan.png")
	info:setAnchorPoint(0.5,0.5)
	info:setPosition(self.size.width*0.5,size.height*0.8-60)
	self.bg:addChild(info)
    --结束时间 tab标题
	local time = ccui.ImageView:create("newExtend/hehuoren/jiesuyouxishijian.png");
	time:setAnchorPoint(0.5,0.5)
	time:setPosition(info:getContentSize().width*0.2-40,time:getContentSize().height*0.5+10)
	info:addChild(time)

    self.gap = 60;

    --游戏类型 tab 标题
	local stype = ccui.ImageView:create("newExtend/hehuoren/youxileixing.png");
	stype:setAnchorPoint(0.5,0.5)
	stype:setPosition(info:getContentSize().width*0.4+10 + self.gap,stype:getContentSize().height*0.5+10)
	info:addChild(stype)

    
    --输赢情况 tab 标题
	local money = ccui.ImageView:create("newExtend/hehuoren/shuyingqingkuang.png");
	money:setAnchorPoint(0.5,0.5)
	money:setPosition(info:getContentSize().width*0.6+20 + self.gap,money:getContentSize().height*0.5+10)
	info:addChild(money)
    --输赢占成 tab 标题
    local moneyRat = ccui.ImageView:create("newExtend/hehuoren/shuyingzancheng.png");
    moneyRat:setAnchorPoint(0.5,0.5)
    moneyRat:setPosition(info:getContentSize().width*0.8+30 + self.gap,moneyRat:getContentSize().height*0.5+10)
    info:addChild(moneyRat)
    --下一页 按钮
    local lastButton = ccui.Button:create("newExtend/hehuoren/shangyiye.png","newExtend/hehuoren/shangyiye-on.png");
    lastButton:setPosition(size.width*0.5-150,size.height*0.1+10);
    self.bg:addChild(lastButton);
    lastButton:setTag(0);
    lastButton:onClick(function (sender)
        self:pageButton(sender)
    end);
    --上一页 按钮
    local nextButton = ccui.Button:create("newExtend/hehuoren/xiayiye.png","newExtend/hehuoren/xiayiye-on.png");
    nextButton:setPosition(size.width*0.5+150,size.height*0.1+10);
    self.bg:addChild(nextButton);
    nextButton:setTag(1);

    nextButton:onClick(function (sender)
        self:pageButton(sender)
    end);


    local pageInfo = FontConfig.createWithSystemFont("1/1", 30,cc.c3b(243,218,125));
    pageInfo:setPosition(size.width*0.5,size.height*0.1+10);
    self.bg:addChild(pageInfo);
    self.pageInfo = pageInfo


    
	self:createTableView();
    
	
end


function DeDetailLayer:pageButton(sender)
    local tag = sender:getTag();
    if tag == 0 then
        luaPrint("上一页");
        self.currentPage = self.currentPage-1
        if self.currentPage<1 then
            self.currentPage=1
            addScrollMessage("已经是第一页");
        end
    elseif tag == 1 then
        luaPrint("下一页");
        self.currentPage = self.currentPage+1
        if self.currentPage>self.allPage then
            self.currentPage = self.allPage
            addScrollMessage("已经是最后一页");
        end
    end

    self.pageInfo:setString(self.currentPage.."/"..self.allPage);

    if self.rankTableView then
        self.rankTableView:reloadData();
    else
        self:createTableView();
    end
end

--设置名字
function DeDetailLayer:setName(str)
    self.name:setString("昵称:"..str);
end

--设置ID
function DeDetailLayer:setName(number)
    self.name:setString("ID:"..tostring(number));
end

--设置输赢占成
function DeDetailLayer:setScore(score)
    self.score:setString(tostring(score));
end

--创建tableview
function DeDetailLayer:createTableView()
	if(self.rankTableView) then
		self.rankTableView:removeFromParent();
		self.rankTableView = nil;
	end
    if #self.logData==0 then
        return;
    end
	self.rankTableView = cc.TableView:create(cc.size(914,300));
	if self.rankTableView then
        self.rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);    
        self.rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); 
        self.rankTableView:setPosition(cc.p(100,300*0.35 + 40));
        self.rankTableView:setDelegate();

        self.rankTableView:registerScriptHandler( handler(self, self.Rank_scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL);           --滚动时的回掉函数  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);             --列表项的尺寸  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);              --创建列表项  
        self.rankTableView:registerScriptHandler( handler(self, self.Rank_numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW); --列表项的数量  
        self.rankTableView:reloadData();
        self.bg:addChild(self.rankTableView);
    end
end

function DeDetailLayer:Rank_scrollViewDidScroll(view)  
    --luaPrint("Rank_scrollViewDidScroll",self.rankTableView:getContentOffset().y);
end  
  
function DeDetailLayer:Rank_cellSizeForTable(view, idx)  

    -- local width = self.Panel_otherMsg:getContentSize().width;
    -- local height = self.Panel_otherMsg:getContentSize().height;
    --luaPrint("Rank_cellSizeForTable",width, height)
    return 914, 50;  

end  
  
function DeDetailLayer:Rank_numberOfCellsInTableView(view)  
   -- luaPrint("Rank_numberOfCellsInTableView------",table.nums(self.tableLayer.otherMsgTable))
    return #self.logData[self.currentPage] --#self.logData[self.ButtonIndex]--table.nums(self.tableLayer.otherMsgTable);
end  
  
function DeDetailLayer:Rank_tableCellAtIndex(view, idx)  
    --luaPrint("Rank_tableCellAtIndex",idx);
    local index = idx + 1;  
    local cell = view:dequeueCell();
    if nil == cell then
        local rankItem = self:createItem(); 
        rankItem:setContentSize(cc.size(914, 50));
        rankItem:setPosition(40,0);
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

function DeDetailLayer:setRankInfo(rankItem,index)
    --luaPrint("TableLayer:setRankInfo--------",index)
    local timeText = rankItem:getChildByName("timeText");
    local useId = rankItem:getChildByName("useId");
    local useScore = rankItem:getChildByName("useScore");
    local userScoreRat = rankItem:getChildByName("userScoreRat");
    
    timeText:setString(timeConvert(self.logData[self.currentPage][index].CreateDate,3));
    useId:setString(self:getRoomStringByRoomID(self.logData[self.currentPage][index].RoomID));
    useScore:setString(goldConvert(self.logData[self.currentPage][index].Score,1));
    if self.logData[self.currentPage][index].Score > 0 then
        useScore:setColor(cc.c3b(230, 173, 44));
    else
        useScore:setColor(cc.c3b(49, 200, 45));
    end
    userScoreRat:setString(string.format("%.1f",self.logData[self.currentPage][index].PartnerRat/10).."%");
end

function DeDetailLayer:createItem()

    local size = cc.size(914,80);
	--大背景
	local layout = ccui.Layout:create();
	layout:setContentSize(size);
    --layout:setAnchorPoint(0.5,0.5);

	--背景图片
	local itemBg = ccui.ImageView:create("newExtend/hehuoren/fengexian.png");
    layout:addChild(itemBg);
    itemBg:setPosition(size.width/2-50,6);

    --时间
    local timeText = FontConfig.createWithSystemFont("12:15:56", 24,self.TextColor);
    layout:addChild(timeText);
    timeText:setAnchorPoint(0.5,0.5);
    timeText:setPosition(size.width*0.2-40,25);
    timeText:setName("timeText");

    --游戏类型
    local useId= FontConfig.createWithSystemFont("百人牛牛", 24,self.TextColor);
    layout:addChild(useId);
    useId:setAnchorPoint(0.5,0.5);
    useId:setPosition(size.width*0.4 + self.gap,25);
    useId:setName("useId");
    useId:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);

    --score 输赢
    local useScore= FontConfig.createWithSystemFont("+180", 24,FontConfig.colorBlack);
    layout:addChild(useScore);
    useScore:setAnchorPoint(0.5,0.5);
    useScore:setPosition(size.width*0.6 + self.gap,25);
    useScore:setName("useScore");
    useScore:setColor(cc.c3b(49, 200, 45));--绿色
    useScore:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);

    --占成
    local userScoreRat = FontConfig.createWithSystemFont("0",24,FontConfig.colorBlack);
    layout:addChild(userScoreRat);
    userScoreRat:setAnchorPoint(0.5,0.5);
    userScoreRat:setPosition(size.width*0.8 + self.gap,25);
    userScoreRat:setName("userScoreRat");
    userScoreRat:setColor(cc.c3b(49, 200, 45));--绿色
    userScoreRat:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER);

	return layout;
end

--刷新tableview
function DeDetailLayer:updateTableView()

	self:createTableView();

end

function DeDetailLayer:getRoomStringByRoomID(roomID)
    local nameStr = {}
    nameStr[1] = "百家乐"
    nameStr[2] = "奔驰宝马"
    nameStr[12] = "骰宝"
    nameStr[13] = "飞禽走兽"
    nameStr[3] = "百人牛牛"
    nameStr[14] = "百人牛牛"
    nameStr[46] = "红黑大战"
    nameStr[47] = "龙虎斗"
    local str = "";
    if nameStr[roomID] then
        str = nameStr[roomID];
        return str;
    end

    if roomID == 15 or roomID>=19 and roomID<=24 then
        str = "斗地主";
    elseif roomID>=4 and roomID<=11 then
            str = "捕鱼";
    elseif roomID == 17 or roomID>=28 and roomID<=30 then
        str = "抢庄牛牛";
    elseif roomID == 16 or roomID>=25 and roomID<=27 then
        str = "二人牛牛";
    elseif roomID == 18 or roomID>=31 and roomID<=33 then
        str = "三张牌";
    elseif roomID>=42 and roomID<=45 then
        str = "德州扑克";
    elseif roomID>=38 and roomID<=41 then
        str = "十点半";
    elseif roomID>=34 and roomID<=37 then
        str = "二十一点";
    elseif roomID>=109 and roomID<=112 then
        str = "十三张";
    elseif roomID == 114 or roomID == 115 or roomID == 144 or roomID == 145 then --114 10包1倍 115 7包1.5倍  144 10包1倍低倍 145 7包1.5倍低倍
        str = "扫雷红包"
        if roomID == 114 then
            str = str .. "10包1倍场"
        elseif roomID == 115 then
            str = str .. "7包1.5倍场"
        elseif roomID == 144 then
            str = str .. "10包1倍场低倍"
        elseif roomID == 145 then
            str = str .. "7包1.5倍场低倍"
        end

    elseif roomID == 118 or roomID == 119 or roomID == 120 then
        str = "超级水果机"
    elseif roomID == 121 then
        str = "水浒传"
    end

    return str;
end


return DeDetailLayer
