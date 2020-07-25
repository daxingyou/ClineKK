local MyPerformanceNode = class("MyPerformanceNode", BaseWindow)
--我的业绩

local MaxLength = 8;
--创建类
function MyPerformanceNode:create(parent)
    local layer = MyPerformanceNode.new(parent);
    layer:setName("MyPerformanceNode");
    return layer;
end

--构造函数
function MyPerformanceNode:ctor(parent)

	self.parent = parent;
	self.super.ctor(self, 0, false);
    local uiTable = {
    	Text_sum = "Text_sum",
    	Text_team = "Text_team",
    	Text_player = "Text_player",
    	Text_earn = "Text_earn",
    	Panel_template = "Panel_template",
    	Image_dataBg = "Image_dataBg",
    }

    loadNewCsb(self,"Node_MyPerformance",uiTable);

    self:InitData();

    self:InitUI();

    self:pushEventInfo(ExtendInfo,"ExtendAchieve",handler(self, self.onExtendAchieve));
    self:pushEventInfo(ExtendInfo,"ExtendTotalCount",handler(self, self.onExtendTotalCount));
end

--进入
function MyPerformanceNode:onEnter()
    self.super.onEnter(self); 
    ExtendInfo:sendExtendAchieveRequest();
end

function MyPerformanceNode:InitData()

end

function MyPerformanceNode:InitUI()
	--将模板数据隐藏
	self.Panel_template:setVisible(false);


	self:RefreshPlayerInfo();

	---模拟数据
	self.data = {};
	-- for i = 1,40 do
	-- 	table.insert(self.data,{time=1553075784+i,totalSum=4544,teamTotalSum = 478,playSum = 45});
	-- end

	-- self:RefreshScene();
end

function MyPerformanceNode:onExtendTotalCount(data)
    local msg = data._usedata;

    self:RefreshPlayerInfo();

end

function MyPerformanceNode:RefreshPlayerInfo()
    --设置玩家的信息
	if self.parent.totalCount then
		self.Text_sum:setString(goldConvert(self.parent.totalCount.WeekDirectAchieve+self.parent.totalCount.WeekTeamAchieve));
		self.Text_team:setString(goldConvert(self.parent.totalCount.WeekTeamAchieve));
		self.Text_player:setString(goldConvert(self.parent.totalCount.WeekDirectAchieve));
		self.Text_earn:setString(goldConvert(self.parent.totalCount.PredictReward));
	end
end

function MyPerformanceNode:onExtendAchieve(data)
    local msg = data._usedata;

    self:RefreshScene(msg);

end

--重置页面信息
function MyPerformanceNode:RefreshScene(data)
	if data then
		self.data = data;
	end


	self:RefreshPlayerData(self.data);

	-- local msg = {sum = 275,team = 454,player = 457,earn = 998};

end

--刷新信息
function MyPerformanceNode:RefreshPlayerData(data)
	--清除界面的显示的数据
	for i =1,MaxLength do
		local node = self.Image_dataBg:getChildByName("data"..i);
		if node then
			node:removeFromParent();
		end
	end

	local bgSize = self.Image_dataBg:getContentSize();

	for k,v in pairs(data) do
		local node = self.Panel_template:clone();
		node:setVisible(true);
		node:setName("data"..k);
		node:setPosition(0,bgSize.height-(k-1)*node:getContentSize().height);
		self.Image_dataBg:addChild(node);

		--设置数据
		local Text_time = node:getChildByName("Text_time");
		if Text_time then
			local time = v.Id;

			-- for i = 1,k-1 do
			-- 	time = time - 24*60*60;
			-- end

			Text_time:setString(""..os.date("%Y",time).."-"..os.date("%m",time).."-"..os.date("%d",time));
		end

		local Text_sum = node:getChildByName("Text_sum");
		if Text_sum then
			Text_sum:setString(goldConvert(v.TeamAchieve+v.DirectAchieve));
		end

		local Text_teamSum = node:getChildByName("Text_teamSum");
		if Text_teamSum then
			Text_teamSum:setString(goldConvert(v.TeamAchieve));
		end

		local Text_playSum = node:getChildByName("Text_playSum");
		if Text_playSum then
			Text_playSum:setString(goldConvert(v.DirectAchieve));
		end
	end
end


return MyPerformanceNode;