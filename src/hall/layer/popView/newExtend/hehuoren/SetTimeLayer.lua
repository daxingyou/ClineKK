

local SetTimeLayer = class("SetTimeLayer", PopLayer)


--创建类
function SetTimeLayer:create(data)

	local layer = SetTimeLayer.new(data);

	return layer;
end

--构造函数
function SetTimeLayer:ctor(data)
	self.super.ctor(self,PopType.small)

	self.data = data;

	self.timeData = {};

	self:initData();

	self:initUI()

	self:bindEvent()
end

function SetTimeLayer:bindEvent()
	self:pushEventInfo(PartnerInfo,"UpdatePartnerTime",handler(self, self.receiveUpdatePartnerTime))--明细
	self:pushEventInfo(PartnerInfo,"UpdatePartnerTime_temp",handler(self, self.receiveUpdatePartnerTime_temp))--半小时到
	self:pushEventInfo(PartnerInfo,"PartnerInfor",handler(self, self.receivePartnerInfo))
end

function SetTimeLayer:receiveUpdatePartnerTime(data)
	local data = data._usedata
    luaDump(data,"设置时间");
    if data.ret == 0 then
    	addScrollMessage("时间设置成功！");
    else
    	addScrollMessage("时间设置失败！");
    end
    PartnerInfo:sendGetPartnerInfoRequest();--重新请求
end

function SetTimeLayer:receiveUpdatePartnerTime_temp(data)
	--local data = data._usedata
    luaDump(data,"半个小时到");
    PartnerInfo:sendGetPartnerInfoRequest();--重新请求
    
end


function SetTimeLayer:receivePartnerInfo(data)
	local data = data._usedata

	self.data = data;

	self:adjustTime();

	self:setTimeString();

	self:initChangeData();

	self.sureBtn:setEnabled(false);

end

function SetTimeLayer:adjustTime()
	self.timeData[1] = self.data.StartTime1;
	self.timeData[2] = self.data.EndTime1;
	self.timeData[3] = self.data.StartTime2;
	self.timeData[4] = self.data.EndTime2;
	self.timeData[5] = self.data.StartTime3;
	self.timeData[6] = self.data.EndTime3;

	self.saveTime[1] = self.data.StartTime1;
	self.saveTime[2] = self.data.EndTime1;
	self.saveTime[3] = self.data.StartTime2;
	self.saveTime[4] = self.data.EndTime2;
	self.saveTime[5] = self.data.StartTime3;
	self.saveTime[6] = self.data.EndTime3;

	self.newTimeData[1] = self.data.TempStartTime1;
	self.newTimeData[2] = self.data.TempEndTime1;
	self.newTimeData[3] = self.data.TempStartTime2;
	self.newTimeData[4] = self.data.TempEndTime2;
	self.newTimeData[5] = self.data.TempStartTime3;
	self.newTimeData[6] = self.data.TempEndTime3;
end

--显示时间
function SetTimeLayer:setTimeString()
	-- body
	for k,v in pairs(self.AllTimeEdit_h) do
		local str = self:timeChange(math.floor(self.timeData[k]/60))
		v:setText(str);

	end

	for k,v in pairs(self.AllTimeEdit_s) do
		local str = self:timeChange(self.timeData[k]%60)
		v:setText(str);
	end

	for k,v in pairs(self.newTimeLabel) do
		v:setVisible(false);
		v:setString("("..self:timeChange(math.floor(self.newTimeData[k]/60))..":"..self:timeChange(self.newTimeData[k]%60)..")");
		
		if k%2 == 1 then
			luaPrint("111",self.timeData[k],self.newTimeData[k],self.timeData[k+1],self.newTimeData[k+1])
			if self.timeData[k] ~= self.newTimeData[k] and self.timeData[k+1] ~= self.newTimeData[k+1] then
				v:setVisible(true);
			end

			if self.newTimeData[k] ~= -1 then
				v:setVisible(true);
			end

			if self.timeData[k] == self.newTimeData[k] and self.timeData[k+1] == self.newTimeData[k+1] then
				v:setVisible(false);
			end

			if self.newTimeData[k] == self.newTimeData[k+1] and self.newTimeData[k] == -1 then
				v:setVisible(false);
			end

		else
			luaPrint("222",self.timeData[k],self.newTimeData[k],self.timeData[k-1],self.newTimeData[k-1])
			if self.timeData[k] ~= self.newTimeData[k] and self.timeData[k-1] ~= self.newTimeData[k-1] then
				v:setVisible(true);
			end

			if self.newTimeData[k] ~= -1 then
				v:setVisible(true);
			end

			if self.timeData[k] == self.newTimeData[k] and self.timeData[k-1] == self.newTimeData[k-1] then
				v:setVisible(false);
			end

			if self.newTimeData[k] == self.newTimeData[k-1] and self.newTimeData[k] == -1 then
				v:setVisible(false);
			end
			
		end
		
	end
end

--进入
function SetTimeLayer:onEnter()
	--self:initUI()

	--self:bindEvent();--绑定消息
	self.super.onEnter(self);
end

function SetTimeLayer:initData()
	self.timeData = {};--生效时间
	self.newTimeData = {};--修改的时间
	self.saveTime = {};--生效时间

	self:initChangeData();

	self:adjustTime();

end

function SetTimeLayer:initChangeData()
	----记录玩家是否更改过时间
	self.isChange  = {
		{false,false}, -- h,m
		{false,false},
		{false,false},
		{false,false},
		{false,false},
		{false,false},
	}
end

function SetTimeLayer:initUI()
	self.sureBtn:removeSelf()
	
	local title = ccui.ImageView:create("newExtend/hehuoren/shijianshezhibiaoti.png")
	title:setPosition(self.size.width/2,self.size.height-50)
	self.bg:addChild(title)

	self.AllTimeEdit_h = {};
	self.AllTimeEdit_s = {};
	self.newTimeLabel = {};
	self.saveTime = {};--保存生效时间

	for k=1,6 do
		local biao = ccui.ImageView:create("newExtend/hehuoren/lianjiehao.png");
		biao:setAnchorPoint(0.5,0.5)
		biao:setPosition(self.size.width/2,self.size.height*(0.7-0.15*math.floor((k-1)/2)))
		self.bg:addChild(biao)
		local edit = ccui.ImageView:create("newExtend/hehuoren/shijiankuang.png")
	    edit:setAnchorPoint(0.5,0.5)
	    if k%2 == 1 then
	    	edit:setPosition(self.size.width/2-150,self.size.height*(0.7-0.15*math.floor((k-1)/2)))
	    else
	    	edit:setPosition(self.size.width/2+150,self.size.height*(0.7-0.15*math.floor((k-1)/2)))
	    end

	    self.bg:addChild(edit)

	    local xiaoBg = ccui.ImageView:create("newExtend/hehuoren/xiaokuang.png");
	    edit:addChild(xiaoBg);
	    xiaoBg:setPosition(cc.p(edit:getContentSize().width/2-90, edit:getContentSize().height/2));

	    --小时
	    local timeEdit = ccui.EditBox:create(cc.size(50,edit:getContentSize().height),ccui.Scale9Sprite:create())
	    timeEdit:setAnchorPoint(cc.p(0.5,0.5))
	    timeEdit:setPosition(cc.p(edit:getContentSize().width/2-85, edit:getContentSize().height/2))
	    timeEdit:setFontSize(28)
	    timeEdit:setText("00");

	    timeEdit:setPlaceholderFontColor(cc.c3b(216,226,233))
	    timeEdit:setPlaceholderFontSize(2)
	    timeEdit:setMaxLength(2)
	    edit:addChild(timeEdit)
	    timeEdit:setTag(k);
	    timeEdit:setInputFlag(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	    timeEdit:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle_h(eventname,sender) end);
	    table.insert(self.AllTimeEdit_h,timeEdit);

	    
	    local xiaoBg = ccui.ImageView:create("newExtend/hehuoren/xiaokuang.png");
	    edit:addChild(xiaoBg);
	    xiaoBg:setPosition(cc.p(edit:getContentSize().width/2-10, edit:getContentSize().height/2));

	    -- 冒号
	    local label = ccui.ImageView:create("newExtend/hehuoren/maohao.png");
	    label:setPosition(cc.p(edit:getContentSize().width/2-50, edit:getContentSize().height/2))
	    edit:addChild(label)

	    --分钟
	    local timeEdit_s = ccui.EditBox:create(cc.size(50,edit:getContentSize().height),ccui.Scale9Sprite:create())
	    timeEdit_s:setAnchorPoint(cc.p(0.5,0.5))
	    timeEdit_s:setPosition(cc.p(edit:getContentSize().width/2-5, edit:getContentSize().height/2))
	    timeEdit_s:setFontSize(28)
	    timeEdit_s:setText("00");

	    timeEdit_s:setPlaceholderFontColor(cc.c3b(216,226,233))
	    timeEdit_s:setPlaceholderFontSize(2)
	    timeEdit_s:setMaxLength(2)
	    edit:addChild(timeEdit_s)
	    timeEdit_s:setTag(k);
	    timeEdit_s:setInputFlag(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	    timeEdit_s:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle_m(eventname,sender) end);
	    table.insert(self.AllTimeEdit_s,timeEdit_s);

	    --新时间label
	    local label = FontConfig.createWithSystemFont("(00:00)", 28,FontConfig.colorWhite);
	    label:setAnchorPoint(cc.p(0.5,0.5))
	    label:setPosition(cc.p(edit:getContentSize().width*3/3-60, edit:getContentSize().height/2))
	    edit:addChild(label)
	    label:setTag(k);
	    table.insert(self.newTimeLabel ,label);
	end

	local sureBtn = ccui.Button:create("newExtend/hehuoren/baocun.png","newExtend/hehuoren/baocun-on.png");
	sureBtn:setPosition(self.size.width/2+150,self.size.height*0.2);
	self.bg:addChild(sureBtn);
	self.sureBtn = sureBtn;
	sureBtn:setEnabled(false);
	sureBtn:onClick(function ()
		luaPrint("保存时间");
		self:sendTime();
	end);

	local reSetBtn = ccui.Button:create("newExtend/hehuoren/qingchu.png","newExtend/hehuoren/qingchu-on.png");
	reSetBtn:setPosition(self.size.width/2-150,self.size.height*0.2);
	self.bg:addChild(reSetBtn);
	self.reSetBtn = reSetBtn;
	reSetBtn:onClick(function ()
		for i=1,6 do
			if self.AllTimeEdit_h[i] then
				self.AllTimeEdit_h[i]:setText("00");
			end
			if self.AllTimeEdit_s[i] then
				self.AllTimeEdit_s[i]:setText("00");
			end
			self.isChange[i][1] = true;
			self.isChange[i][2] = true;
		end
		self.sureBtn:setEnabled(true);
	end);

	local sprite = ccui.ImageView:create("newExtend/hehuoren/set_tishi.png");
	self.bg:addChild(sprite);
	sprite:setPosition(cc.p(self.bg:getContentSize().width/2,45));

	PartnerInfo:sendGetPartnerInfoRequest();--重新请求


end

--时间转化
function SetTimeLayer:timeChange(time)
	local str = "";
	if type(time) == "string" then
		time = tonumber(time);
	end
	if time == nil then
		return;
	end
	if time == 0 then
		str = "00"
	elseif time<10 and time>0 then
		str = "0"..tostring(time);
	else
		str = tostring(time);
	end
	return str;
end

--保存时间
function SetTimeLayer:sendTime()

	local setTime = {0,0,0,0,0,0};

	for i=1,6 do
		local str_h = self.AllTimeEdit_h[i]:getText();
		local number_h = tonumber(str_h);
		if number_h == nil then
			addScrollMessage("时间设置错误");
			return;
		end

		local str_s = self.AllTimeEdit_s[i]:getText();
		local number_s = tonumber(str_s);
		if number_s == nil then
			addScrollMessage("时间设置错误");
			return;
		end

		local minutes = number_h * 60 + number_s;

		local time = minutes;
		luaPrint("sendTime",self.timeData[i],self.newTimeData[i],minutes);--630 0 630
		if self.newTimeData[i]>0 and self.newTimeData[i] ~= self.timeData[i] then
			time = self.newTimeData[i];
		end

		if minutes ~= self.newTimeData[i] and minutes ~= self.timeData[i] then
			time = minutes;
		end

		luaPrint("isChange",self.isChange[i][1],self.isChange[i][2]);
		if self.isChange[i][1] or self.isChange[i][2] then --玩家操作过
			time = minutes;
		end

		if not self.isChange[i][1] and not self.isChange[i][2] and self.newTimeData[i] ~= -1 then 
			time = self.newTimeData[i]
		end

		setTime[i] = time;
	end

	luaDump(setTime,"setTime0");
	for i=1,6 do
		if i%2 == 1 then
			if setTime[i] == setTime[i+1] and setTime[i+1] == 0 and self.timeData[i]==0 and self.timeData[i+1]==0 then
				setTime[i] = -1;
				setTime[i+1] = -1;
			end
		end
	end

	luaDump(setTime,"setTime");

	if (setTime[2]~= -1 and setTime[2]~=0 and  setTime[2]-setTime[1]<30) or  setTime[2]<setTime[1] then
		addScrollMessage("时间1间隔不得少于30分钟");
		return
	end

	if setTime[4]~=-1 and setTime[4]~=0 and setTime[4]-setTime[3]<30 or setTime[4]<setTime[3] then
		addScrollMessage("时间2间隔不得少于30分钟");
		return
	end

	if (setTime[6]~=-1 and setTime[6]~=0 and setTime[6]-setTime[5]<30 or setTime[6]<setTime[5]) then
		addScrollMessage("时间3间隔不得少于30分钟");
		return
	end

	if setTime[2]> setTime[3] and setTime[3] ~= -1 and setTime[4] ~= 0 and setTime[4] ~= -1
	or setTime[2]> setTime[5] and setTime[5] ~= -1 and setTime[6] ~= 0 and setTime[6] ~= -1
	or setTime[4]> setTime[5] and setTime[5] ~= -1 and setTime[6] ~= 0 and setTime[6] ~= -1 then
		addScrollMessage("下一阶段开始时间要小于上一阶段结束时间！");
		return;
	end 

	self.setTime = setTime;--记录时间

	PartnerInfo:sendGetUpdatePartnerTimeRequest(setTime[1],setTime[2],setTime[3],setTime[4],setTime[5],setTime[6]);
end

function SetTimeLayer:editboxHandle_h(strEventName,sender)
	local tag = sender:getTag();
	luaPrint("editboxHandle",tag,strEventName);
	if strEventName == "began" then
		luaPrint("began");
	elseif strEventName == "ended" then
		luaPrint("began");
	elseif strEventName == "return" then
		
		local str = sender:getText();
		luaPrint("return",str);
		if str == "" or tonumber(str) == nil or tonumber(str)>24 then
			PartnerInfo:sendGetPartnerInfoRequest();--重新请求
			addScrollMessage("非法输入，请重新输入！");
		else
			self.sureBtn:setEnabled(true);
			self.isChange[tag][1] = true;
		end
	elseif strEventName == "changed" then
		luaPrint("changed");
		-- self.sureBtn:setEnabled(true);
	end
end

function SetTimeLayer:editboxHandle_m(strEventName,sender)
	local tag = sender:getTag();
	luaPrint("editboxHandle",tag,strEventName);
	if strEventName == "began" then
		luaPrint("began");
	elseif strEventName == "ended" then
		luaPrint("began");
	elseif strEventName == "return" then
		
		local str = sender:getText();
		luaPrint("return",str);
		if str == "" or tonumber(str) == nil or tonumber(str)>=60 then
			PartnerInfo:sendGetPartnerInfoRequest();--重新请求
			addScrollMessage("非法输入，请重新输入！");
		else
			self.sureBtn:setEnabled(true);
			self.isChange[tag][2] = true;
		end
	elseif strEventName == "changed" then
		luaPrint("changed");
		-- self.sureBtn:setEnabled(true);
	end
end


--按钮回调
function SetTimeLayer:btnClick(sender)

	local tag = sender:getTag();
	
	self:updata(tag);
	
end

function SetTimeLayer:updata(tag)
	self.bgkuang_tuiguang:setVisible(tag == 1); 
	self.bgkuang_moshi:setVisible(tag == 2);
	self.bgkuang_zijin:setVisible(tag == 3);
	self.Button_tgjc:setEnabled(tag ~= 1);
	self.Button_msxq:setEnabled(tag ~= 2);
	self.Button_zjc:setEnabled(tag ~= 3);
end

return SetTimeLayer;