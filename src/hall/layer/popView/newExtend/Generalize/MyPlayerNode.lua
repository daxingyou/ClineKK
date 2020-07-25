local MyPlayerNode = class("MyPlayerNode",BaseWindow)
--我的玩家

local MaxLength = 7;

--创建类
function MyPlayerNode:create()
    local layer = MyPlayerNode.new();
    layer:setName("MyPlayerNode");
    return layer;
end

--构造函数
function MyPlayerNode:ctor()
	self.super.ctor(self, 0, false);
    local uiTable = {
    	Panel_template = "Panel_template",
    	Text_page = "Text_page",
    	Button_up = "Button_up",
    	Button_down = "Button_down",
    	Button_searchSp = "Button_searchSp",
    	TextField_search = "TextField_search",
    	Image_searchBg = "Image_searchBg",
    	Image_dataBg = "Image_dataBg",
    }

    loadNewCsb(self,"Node_MyPlayer",uiTable);

    self:InitData();

    self:InitUI();

    self:pushEventInfo(ExtendInfo,"ExtendDetail",handler(self, self.onExtendDetail));
end

--进入
function MyPlayerNode:onEnter()
    self.super.onEnter(self);

    --获取当前时间戳
    local CurrentTime = os.time();
    -- luaPrint("当前时间戳---------------",ExtendInfo.mSaveDetailTime,CurrentTime);
    --当保存时间戳为0 或 小于当前时间10分钟 刷新
    if ExtendInfo.mSaveDetailTime == 0 or ExtendInfo.mSaveDetailTime + 600 < CurrentTime or ExtendInfo.mSaveDetailData == nil then
    	ExtendInfo.mSaveDetailTime = CurrentTime;
    	ExtendInfo:sendExtendDetailRequest();
    else
    	self:RefreshScene(ExtendInfo.mSaveDetailData);
    end
end


function MyPlayerNode:InitData()
	--设置默认的页数为第一页
	self.pageIndex = 1;
	self.searchId = nil;

end

function MyPlayerNode:InitUI()

	--将模板数据隐藏
	self.Panel_template:setVisible(false);

	self.Text_page:setString("1/1");

	--设置上一页和下一页的按钮
	if self.Button_up then
		self.Button_up:onClick(handler(self,self.UpClick));
	end

	if self.Button_down then
		self.Button_down:onClick(handler(self,self.DownClick));
	end

	if self.Button_searchSp then
		self.Button_searchSp:onClick(handler(self,self.SearchUser));
	end


	self.souTextEdit = ccui.EditBox:create(self.TextField_search:getContentSize(),ccui.Scale9Sprite:create())
    self.souTextEdit:setPosition(self.TextField_search:getPosition());
    self.souTextEdit:setFontSize(26)
    self.souTextEdit:setPlaceHolder("输入玩家ID");
    self.souTextEdit:setPlaceholderFontColor(cc.c3b(255,255,255));
    self.Image_searchBg:addChild(self.souTextEdit)
    self.souTextEdit:onEditHandler(handler(self, self.onEditBoxHandler))
    self.souTextEdit:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL);

	---模拟数据
	-- self.data = {};
	-- for i = 1,40 do
	-- 	table.insert(self.data,{userId=i,nickName="dfdaf",team=654,player=7845,teamNumber=45,directlyPlayer=61,playerType="玩家"});
	-- end

	self.data = {};

	self:RefreshScene();

	--获取控件
	local Panel_bg = self.csbNode:getChildByName("Panel_bg");
	local bgSize = Panel_bg:getContentSize();
	local textTitle = FontConfig.createWithSystemFont("此页面数据，每10分钟刷新一次",24);
    textTitle:setPosition(bgSize.width/2,22);
    Panel_bg:addChild(textTitle);

end

function MyPlayerNode:onExtendDetail(data)
    local msg = data._usedata;
    ExtendInfo.mSaveDetailData = msg;
    self:RefreshScene(msg);

end

--重置页面信息
function MyPlayerNode:RefreshScene(data)
	if data then
		self.data = data;
	end

	self.pageIndex = 1;

	if #self.data > 0 then
		self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#self.data/MaxLength));
	else
		self.Text_page:setString("1/1");
	end

	self:RefreshPlayerData(self.data);
end

--刷新信息
function MyPlayerNode:RefreshPlayerData(data)
	--清除界面的显示的数据
	for i =1,MaxLength do
		local node = self.Image_dataBg:getChildByName("data"..i);
		if node then
			node:removeFromParent();
		end
	end

	local dataCopy = {};

	if self.searchId then
		for k,v in pairs(data) do
			if v.UserID == self.searchId then
				table.insert(dataCopy,v);
			end
		end
	else
		dataCopy = data;
	end


	local bgSize = self.Image_dataBg:getContentSize();

	for k,v in pairs(dataCopy) do
		if (self.pageIndex-1)*MaxLength < k and self.pageIndex*MaxLength >= k then
			local node = self.Panel_template:clone();
			node:setVisible(true);
			node:setName("data"..(k-(self.pageIndex-1)*MaxLength));
			node:setPosition(0,bgSize.height-(k-(self.pageIndex-1)*MaxLength-1)*node:getContentSize().height);
			self.Image_dataBg:addChild(node);

			--设置数据
			local Text_id = node:getChildByName("Text_id");
			if Text_id then
				Text_id:setString(v.UserID);
			end

			local Text_name = node:getChildByName("Text_name");
			if Text_name then
				Text_name:setString(FormotGameNickName(v.NickName,nickNameLen));
			end

			local Text_teamContribution = node:getChildByName("Text_teamContribution");
			if Text_teamContribution then
				Text_teamContribution:setString(goldConvert(v.TeamRevenue));
			end

			local Text_playerContribution = node:getChildByName("Text_playerContribution");
			if Text_playerContribution then
				Text_playerContribution:setString(goldConvert(v.DirectRevenue));
			end

			local Text_teamNum = node:getChildByName("Text_teamNum");
			if Text_teamNum then
				Text_teamNum:setString(v.TeamCount);
			end

			local Text_playerNum = node:getChildByName("Text_playerNum");
			if Text_playerNum then
				Text_playerNum:setString(v.DirectCount);
			end

			local Text_type = node:getChildByName("Text_type");
			if Text_type then
				Text_type:setString("玩家");
			end
		end
	end
end

--上一页的按钮
function MyPlayerNode:UpClick(sender)
	local dataCopy = {};

	if self.searchId then
		for k,v in pairs(self.data) do
			if v.UserID == self.searchId then
				table.insert(dataCopy,v);
			end
		end
	else
		dataCopy = self.data;
	end

	if self.pageIndex>1 and #dataCopy>0 then
		self.pageIndex = self.pageIndex - 1;
		self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#dataCopy/MaxLength));
		self:RefreshPlayerData(self.data);
	else
        addScrollMessage("已经是第一页");
	end
end

--下一页的按钮
function MyPlayerNode:DownClick(sender)
	local dataCopy = {};

	if self.searchId then
		for k,v in pairs(self.data) do
			if v.UserID == self.searchId then
				table.insert(dataCopy,v);
			end
		end
	else
		dataCopy = self.data;
	end

	if math.ceil(#dataCopy/MaxLength)>self.pageIndex and #self.data>0 then
		self.pageIndex = self.pageIndex + 1;
		self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#dataCopy/MaxLength));
		self:RefreshPlayerData(self.data);
	else
        addScrollMessage("已经是最后一页");
	end
end

--查找用户按钮
function MyPlayerNode:SearchUser(sender)
	self.pageIndex = 1;
	self.searchId = tonumber(self.souTextEdit:getText());

	if self.searchId or #self.data == 0 then
		self.Text_page:setString("1/1");
	else
		self.Text_page:setString(""..self.pageIndex.."/"..math.ceil(#self.data/MaxLength));
	end

	self:RefreshPlayerData(self.data);
end


function MyPlayerNode:onEditBoxHandler(event)
    local name = event.name;

    if name == "began" then
    elseif name == "ended" then
        
    elseif name == "return" then
    	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            event.target:setText(tonumber(self.souTextEdit:getText()));
        end)));
    elseif name == "changed" then
    end
end

return MyPlayerNode;