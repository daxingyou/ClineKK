local LogBar = class("LogBar", BaseWindow)
FontConfig = loadScript("common.UI.FontConfig")
function LogBar:ctor(target,isDelay)
	-- self.super.ctor(self,PopType.small)
	self.super.ctor(self, 0, false);
	self:bindEvent();

	self.isDelay = false;
	if isDelay then
		self.isDelay = isDelay;
	end

	self:initData(target);

	self:initUI();
	
end

--align 验证按钮显示位置  0:靠下，1：靠左边 2:靠右边 默认靠下
function LogBar:create(target,isDelay)
	local layer = LogBar.new(target,isDelay);
	-- layer:setVisible(false);
	return layer;
end

function LogBar:onEnter()
	self.super.onEnter(self);
	if self.target == nil then
		self.target = self:getParent();
	end
end

function LogBar:bindEvent()
	self:pushGlobalEventInfo("ASS_GR_USERSCORELOG",handler(self, self.onUserLog));
	self:pushGlobalEventInfo("ASS_GR_NEWUSERSCORELOG",handler(self, self.onAddUserLog));
	self:pushGlobalEventInfo("H_R_M_GameStation",handler(self, self.sendUserLog));
end

function LogBar:initUI()

	self:setContentSize(cc.size(0,0));

	self:ignoreAnchorPointForPosition(false);
	self:setAnchorPoint(cc.p(0.5,0.5));


	--
	-- self.Button_verify = ccui.Button:create("UserLog/UserLog_enter.png","UserLog/UserLog_enter-on.png","UserLog/UserLog_enter-on.png");
	-- self.Button_verify:setPosition(self:getContentSize().width/2,self:getContentSize().height/2);
	-- self:addChild(self.Button_verify);


	-- self.Button_verify:onClick(handler(self,self.onBtnClickEvent))
	-- self.Button_verify:setName("Button_verify");


end

function LogBar:sendUserLog()
	self.m_recordDataList = {}

	--判断全局表里面是否有值
	if globalUnit.mSaveUserLog[globalUnit.selectedRoomID] and globalUnit.selectedRoomID ~= 31 then
		self.m_recordDataList = globalUnit.mSaveUserLog[globalUnit.selectedRoomID];
	else
		local msg = {};
		msg.UserID = PlatformLogic.loginResult.dwUserID;
		luaDump(msg,"发送用户历史")
		RoomLogic:send(RoomMsg.MDM_GR_ROOM, RoomMsg.ASS_GR_USERSCORELOG, msg, RoomMsg.MSG_GR_C_USERSCORELOG);
	end
end



function LogBar:initData(target)
	self.m_recordDataList = {}  --

	self.target = target;

	self.mDelayData = nil;
end


function LogBar:getRecordDataList()
	return self.m_recordDataList;
end

--按钮响应
function LogBar:onBtnClickEvent(sender)

    --获取按钮名
    local btnName = sender:getName();

    local btnTag = sender:getTag();
    

	if "Button_verify" == btnName then --打开详细验证码
    	local FineLayer = require("UserLog.UserLogLayer");
    	local finePop = FineLayer:create(self.m_recordDataList,self.target);
    	finePop:ignoreAnchorPointForPosition(false);
		finePop:setAnchorPoint(cc.p(0.5,0.5));
    	
    	local size = self.target:getContentSize();
    	finePop:setPosition(size.width/2,size.height/2);
    	self.target:addChild(finePop,9999);
    end
        	
end

function LogBar:CreateLog()
	local FineLayer = require("UserLog.UserLogLayer");
	local finePop = FineLayer:create(self.m_recordDataList,self.target);
	finePop:ignoreAnchorPointForPosition(false);
	finePop:setAnchorPoint(cc.p(0.5,0.5));
	
	local size = self.target:getContentSize();
	finePop:setPosition(size.width/2,size.height/2);
	self.target:addChild(finePop,9999);
end

function LogBar:onUserLog(data)
	local data = data._usedata;
	local handCode = data:getHead(4);

	self.mDelayData = nil;
	
	-- luaPrint("接收用户历史");
	if handCode == 0 then
		local msg = convertToLua(data,RoomMsg.MSG_GP_USERSCORE_LOG);
		-- luaDump(msg,"onUserLog")

		--相同的进行返回
		for k,v in pairs(self.m_recordDataList) do
			if v.CreateDate == msg.CreateDate then
				return;
			end
		end

		msg.Detail = msg.Detail1..msg.Detail2..msg.Detail3;

		msg.Detail = self:splitLog(msg.Detail);

		if msg.Detail == nil then
			return;
		end

		table.insert(self.m_recordDataList,msg);

		luaDump(msg,"onUserLog")
	elseif handCode == 1 then
		-- luaDump(self.m_recordDataList,"m_recordDataList")
		local layer = self.target:getChildByName("UserLogLayer");
		if layer then
			layer:refreshLog(self.m_recordDataList);
		end
		globalUnit.mSaveUserLog[globalUnit.selectedRoomID] = self.m_recordDataList;
	end
end

--添加新的一局
function LogBar:onAddUserLog(data)
	local data = data._usedata;
	local handCode = data:getHead(4);
	
	local msg = convertToLua(data,RoomMsg.MSG_GP_USERSCORE_LOG);

	--相同的进行返回
	for k,v in pairs(self.m_recordDataList) do
		if v.CreateDate == msg.CreateDate then
			return;
		end
	end

	msg.Detail = msg.Detail1..msg.Detail2..msg.Detail3;

	msg.Detail = self:splitLog(msg.Detail);

	-- luaDump(msg,"onUserLog")

	if msg.Detail == nil then
		return;
	end

	if self.isDelay then
		self.mDelayData = msg;
		return;
	end

	table.insert(self.m_recordDataList,1,msg);

	if #self.m_recordDataList>10 then--超出10局去掉多余
		table.remove(self.m_recordDataList,#self.m_recordDataList);
	end

	-- luaDump(self.m_recordDataList,"m_recordDataList")
	local layer = self.target:getChildByName("UserLogLayer");
	if layer then
		layer:refreshLog(self.m_recordDataList);
	end
	globalUnit.mSaveUserLog[globalUnit.selectedRoomID] = self.m_recordDataList;
end

--手动调用刷新
function LogBar:refreshLog()
	if self.mDelayData ~= nil then

		table.insert(self.m_recordDataList,1,self.mDelayData);

		if #self.m_recordDataList>10 then--超出10局去掉多余
			table.remove(self.m_recordDataList,#self.m_recordDataList);
		end

		-- luaDump(self.m_recordDataList,"m_recordDataList")
		local layer = self.target:getChildByName("UserLogLayer");
		if layer then
			layer:refreshLog(self.m_recordDataList);
		end
		globalUnit.mSaveUserLog[globalUnit.selectedRoomID] = self.m_recordDataList;
		self.mDelayData = nil;
	end
end

--分割字符串
function LogBar:splitLog(msg)
	local detailTable = {};
	--先分割下注中
	local tempStr = string.split(msg,"下注：");

	--如果只有一个则返回空
	if #tempStr <= 1 then
		return nil;
	end

	detailTable.title = tempStr[1];

	--先分割
	tempStr[2] = "下注："..tempStr[2];
	local tempStr = string.split(tempStr[2],"开奖结果：");

	if #tempStr <= 1 then
		return nil;
	end

	detailTable.xiazhu = tempStr[1];

	--分割输赢分数
	tempStr[2] = "开奖结果：\n"..tempStr[2];
	local tempStr = string.split(tempStr[2],"输赢分数：");
	if #tempStr > 1 then
		tempStr[2] = "输赢分数："..tempStr[2];
		detailTable.result = tempStr[1];
		detailTable.score = tempStr[2];
	else
		detailTable.result = tempStr[1];
	end

	--将所有的；替换成换行
	detailTable.title = string.gsub(detailTable.title,"；","\n");
	detailTable.xiazhu = string.gsub(detailTable.xiazhu,"；","\n");
	detailTable.xiazhu = string.gsub(detailTable.xiazhu," ","\n");
	if detailTable.result then
		detailTable.result = string.gsub(detailTable.result,"；","\n");
	end

	return detailTable;
end

return LogBar;
