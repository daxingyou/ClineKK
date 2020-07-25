--日历

local CalendarLayer = class("CalendarLayer", BaseWindow)

function CalendarLayer:create(target,dateTable)
	return CalendarLayer.new(target,dateTable);
end

function CalendarLayer:ctor(target,dateTable)
	self.super.ctor(self, 0, false);
	self.target = target

	--判断参数为空则用当前时间
	local year = os.date("%Y");
	local month = os.date("%m");
	local day = os.date("%d");
	if dateTable then
		year = dateTable[1];
		month = dateTable[2];
		day = dateTable[3];
	end

	self:initUI(year,month,day);
end



function CalendarLayer:initUI(year,month,day)
	local panel_root = ccui.Layout:create();
	self:addChild(panel_root);
	panel_root:setContentSize(cc.size(1280,720));
	panel_root:setTouchEnabled(true);
	panel_root:setName("panel_root");
	panel_root:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);

	local panel_dialog = ccui.Layout:create();
	panel_root:addChild(panel_dialog);
	local size = cc.size(691,653)
	panel_dialog:setContentSize(cc.size(691,653));
	panel_dialog:setAnchorPoint(0.5,0.5);
	local image_bg = ccui.ImageView:create("calendar/calendar_kuang.png");
	panel_dialog:addChild(image_bg);
	panel_dialog:setPosition(640,360);
	panel_dialog:setTouchEnabled(true);
	panel_dialog:setName("panel_dialog");
	panel_dialog:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	image_bg:setPosition(cc.p(size.width/2,size.height/2));

	--获取当前年月份
    self.m_nowYear = tonumber(year);
    self.m_nowMonth = tonumber(month);
    self.m_nowDay = tonumber(day);
    self.m_nowDayCount = os.date("%d",os.time({year=os.date("%Y"),month=os.date("%m")+1,day=0}));
    
    --当前选择的时间
    self.m_selectYear = tonumber(year);
    self.m_selectMonth = tonumber(month);
    self.m_selectDay = tonumber(day);
    self.m_selectDayCount = os.date("%d",os.time({year=os.date("%Y"),month=os.date("%m")+1,day=0}));
	
	
	--年月
	self.Text_yearMonth = ccui.Text:create("",FONT_PTY_TEXT,28);
	panel_dialog:addChild(self.Text_yearMonth);
	self.Text_yearMonth:setPosition(cc.p(size.width/2,600));

	--左右箭头按钮
	self.Button_leftArrow = ccui.Button:create("calendar/arrow_left.png","calendar/arrow_left_on.png");
	self.Button_leftArrow:setName("Button_leftArrow");
	self.Button_leftArrow:setPosition(58,600);
	self.Button_leftArrow:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_rightArrow = ccui.Button:create("calendar/arrow_right.png","calendar/arrow_right_on.png");
	self.Button_rightArrow:setName("Button_rightArrow");
	self.Button_rightArrow:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);
	self.Button_rightArrow:setPosition(628,600);
	panel_dialog:addChild(self.Button_leftArrow);
	panel_dialog:addChild(self.Button_rightArrow);
	--创建日历
	--起始点
	local beginPos = cc.p(100,480);
	local cellSize = cc.size(80,80);
	local gap = 2;

	self.image_dayTb = {};
	local index = 0;
	for j=1,6 do   --列
		for i=1,7 do   --行
			local cell = ccui.ImageView:create("calendar/off.png");
			cell:addTouchEventListener(function(sender, touchEvent) self:onBtnClickEvent(sender, touchEvent); end);

			cell:setPosition(beginPos.x + (i-1)*cellSize.width + gap*(i-1),beginPos.y - (j-1)*cellSize.height-gap*(j-1));
			panel_dialog:addChild(cell);
			index = index + 1;
			cell:setTag(index);
			cell:setName("image_day");
			table.insert(self.image_dayTb,cell);
		end
	end

	self:selectMonth();

end

function CalendarLayer:selectMonth(_year,_month)

	--获取当前年月份
    local year = self.m_nowYear;
    local month = self.m_nowMonth;

	if _month ~= nil then
		year = tonumber(_year);
		month = tonumber(_month);
	end

	local bNowMonth = false;
	
	if year == self.m_nowYear and month == self.m_nowMonth then
		bNowMonth = true;
	end
	self:updateMonthTile(year, month);

	local data = {};
    --获取当前年月份

    local dayCount = os.date("%d",os.time({year=year,month=month+1,day=0}));
    if month >= 12 then
    	dayCount = os.date("%d",os.time({year=year,month=2,day=0}));
    end
    dayCount = tonumber(dayCount);

    local nowDay = self.m_selectDay;
    
	
    --获取当前月份的星期格式
    data.year = year;
    data.month = month;
    data.count = dayCount;
    data.list = {};


    for i=1,dayCount do
        local stamp = os.time({day=i;month=month,year=year,hour=0,minute=0,second=1}) -- 指定时间的时间戳
        local week = tonumber(os.date("%w",stamp));
        table.insert(data.list,week);
    end


    local allCount = table.nums(self.image_dayTb);
    
    local firstWeek = data.list[1];
    
    for k,v in pairs(self.image_dayTb) do
    	v:removeAllChildren();
    	v:loadTexture("calendar/off.png");
    	v:setTouchEnabled(false);
    end

    local index = firstWeek+1;
    if index <= 1 then
    	index = 8;
    end
    nowDay = tonumber(nowDay);
    for i=1,data.count do
    	local image = self.image_dayTb[i+index-1];
    	image:setTouchEnabled(true);
    	local dayStr = tostring(i);
		if i == nowDay and bNowMonth then
			image:loadTexture("calendar/now.png");
			local text_day = ccui.TextAtlas:create(dayStr, "calendar/day_wihte.png", 15, 20, "0");
			image:addChild(text_day);

			local size = image:getContentSize();
			text_day:setPosition(cc.p(size.width/2,size.height/2));
		else
			image:loadTexture("calendar/normal.png");
			local text_day = ccui.TextAtlas:create(dayStr, "calendar/day_dark.png", 15, 20, "0");
			image:addChild(text_day);
			local size = image:getContentSize();
			text_day:setPosition(cc.p(size.width/2,size.height/2));	
		end

		self:updateDayTag(image, year, month, i);

    end

 --    do
 --   		return;
	-- end

    
    --显示上个月的时间
    local lastMonth = month - 1;
    if lastMonth <= 0 then
    	lastMonth = 12;
    end

    local lastYear = year;
    if month == 1 then
    	lastYear = year - 1;
    end

    local lastDayCount = os.date("%d",os.time({year=lastYear,month=lastMonth+1,day=0}));
    if lastMonth >= 12 then
    	lastDayCount = os.date("%d",os.time({year=lastYear,month=1,day=0}));
    end


    local lastCount = tonumber(firstWeek);
    if tonumber(firstWeek) <= 0 then
    	lastCount = 7;
    end
    local lastDayArr = {};
    local lastIndex = lastDayCount - lastCount+1;
    for i=lastIndex,lastDayCount do
		table.insert(lastDayArr,i);
	end	

	-- luaPrint("lastYear:",lastYear,"lastMonth:",lastMonth,"lastDayCount:",lastDayCount,"lastCount:",lastCount);
	-- luaDump(lastDayArr, "lastDayArr", 5);
	for i=1,lastCount do

    	local dayStr = ""..lastDayArr[i];
    	local image = self.image_dayTb[i];
    	image:removeAllChildren();
    	image:loadTexture("calendar/off.png");
		local text_day = ccui.TextAtlas:create(dayStr, "calendar/day_wihte.png", 15, 20, "0");
		image:addChild(text_day);
		local size = image:getContentSize();
		text_day:setPosition(cc.p(size.width/2,size.height/2));
		self:updateDayTag(image, lastYear, lastMonth, lastDayArr[i]);
    end

    -- do
    -- 	return;
    -- end

    --显示下个月
    local nextMonth = month+1;
    if nextMonth > 12 then
    	nextMonth = 1;
    end

    local nextYear = year;
    if month == 12 then
    	nextYear = year + 1;
    end

    local nextDayCount = os.date("%d",os.time({year=nextYear,month=lastMonth+1,day=0}));
    local nextCount = 42 - firstWeek-dayCount;
    if firstWeek <= 0 then
    	nextCount = 42 - 7 - dayCount;
    end
    local nextDayArr = {};
    local nextIndex = firstWeek + dayCount;
    if firstWeek <= 0 then
    	nextIndex = 7 + dayCount;
    end

    for i=1,nextCount do
		table.insert(nextDayArr,i);
	end	

	-- luaPrint("nextYear:",nextYear,"nextMonth:",nextMonth,"nextDayCount:",nextDayCount,"nextCount:",nextCount);
	-- luaDump(nextDayArr, "nextDayArr", 5);
	for i=1,nextCount do

    	local dayStr = ""..nextDayArr[i];
    	local image = self.image_dayTb[i+nextIndex];
    	image:removeAllChildren();
    	image:loadTexture("calendar/off.png");
		local text_day = ccui.TextAtlas:create(dayStr, "calendar/day_wihte.png", 15, 20, "0");
		image:addChild(text_day);
		local size = image:getContentSize();
		text_day:setPosition(cc.p(size.width/2,size.height/2));

		self:updateDayTag(image, nextYear, nextMonth, nextDayArr[i]);
    end

end


function CalendarLayer:updateMonthTile(_year,_month)
	local monthStr = "蛋月";
	if _month == 1 then
		monthStr = "一月";
	elseif _month == 2 then
		monthStr = "二月";
	elseif _month == 3 then
		monthStr = "三月";
	elseif _month == 4 then
		monthStr = "四月";
	elseif _month == 5 then
		monthStr = "五月";
	elseif _month == 6 then
		monthStr = "六月";
	elseif _month == 7 then
		monthStr = "七月";
	elseif _month == 8 then
		monthStr = "八月";
	elseif _month == 9 then
		monthStr = "九月";
	elseif _month == 10 then
		monthStr = "十月";
	elseif _month == 11 then
		monthStr = "十一月";
	elseif _month == 12 then
		monthStr = "十二月";
	end

	local str = monthStr.." ".._year;
	self.Text_yearMonth:setString(str);

end


function CalendarLayer:updateDayTag(image,_year,_month,_day)
	local monthStr = _month;
	if _month < 10 then
		monthStr = "0".._month;
	end

	local dayStr = _day;
	if _day < 10 then
		dayStr = "0".._day;
	end
	image.year = _year;
	image.month = monthStr;
	image.day = dayStr;
end


function CalendarLayer:onBtnClickEvent(sender,event)
	local btnName = sender:getName();

    local btnTag = sender:getTag();
    
    
    if event == ccui.TouchEventType.began then
        
    elseif event == ccui.TouchEventType.ended then
    	if "Button_leftArrow" == btnName then --左箭头
    		self:selectToLastMonth();
    	elseif "Button_rightArrow" == btnName then --右箭头
    		self:selectToNextMonth();
    	elseif "image_day" == btnName then    --当前点击的日期
    		luaPrint("日期",(sender.year),(sender.month),(sender.day))
    		self.target:UpdateGameList(sender.year,sender.month,sender.day)
    		self:removeFromParent();

    	elseif "panel_root" == btnName then
    		luaPrint("panel_root:",btnName);
    		self:removeFromParent();
    	elseif "panel_dialog" == btnName then
    		luaPrint("panel_dialog:",btnName);
    	end
    end
end

function CalendarLayer:selectToLastMonth()
	--当前选择的时间
    self.m_selectMonth = self.m_selectMonth - 1;
    if self.m_selectMonth <= 0 then
    	self.m_selectMonth = 12;
    	self.m_selectYear = self.m_selectYear - 1;
    end

    self.m_selectDay = os.date("%d");
    
    local yearMonth = ""..self.m_selectYear..self.m_selectMonth;
    self:selectMonth(self.m_selectYear,self.m_selectMonth);

end


function CalendarLayer:selectToNextMonth()
	--当前选择的时间
    self.m_selectMonth = self.m_selectMonth + 1;
    if self.m_selectMonth > 12 then
    	self.m_selectMonth = 1;
    	self.m_selectYear = self.m_selectYear + 1;
    end

    self.m_selectDay = os.date("%d");
    
    local yearMonth = ""..self.m_selectYear..self.m_selectMonth;
    self:selectMonth(self.m_selectYear,self.m_selectMonth);





end




return CalendarLayer;