local MyAwardNode = class("MyAwardNode", BaseWindow)
--我的奖励
local MaxLength = 7;

--创建类
function MyAwardNode:create()
    local layer = MyAwardNode.new();
    layer:setName("MyAwardNode");
    return layer;
end

--构造函数
function MyAwardNode:ctor()
	self.super.ctor(self, 0, false);
    local uiTable = {
    	Image_content = "Image_content",
    	Panel_template = "Panel_template",
    }

    loadNewCsb(self,"Node_MyAward",uiTable);

    self:InitData();

    self:InitUI();
    
    self:pushEventInfo(ExtendInfo,"ExtendReward",handler(self, self.onExtendReward));
end

--进入
function MyAwardNode:onEnter()
    self.super.onEnter(self); 
    ExtendInfo:sendExtendRewardRequest();
end

function MyAwardNode:InitData()

end

function MyAwardNode:InitUI()
	--将模板数据隐藏
	self.Panel_template:setVisible(false);


	---模拟数据
	self.data = {};
	-- for i = 1,40 do
	-- 	table.insert(self.data,{time="2/10-2/11",totalSum=4544+i,teamTotalSum = 478,playSum = 45,award = 1454,type = "已发送"});
	-- end

	self:RefreshScene();
end

function MyAwardNode:onExtendReward(data)
    local msg = data._usedata;

    self:RefreshScene(msg);

end

--重置页面信息
function MyAwardNode:RefreshScene(data)
	if data then
		self.data = data;
	end

	self:RefreshPlayerData(self.data);
end

--刷新信息
function MyAwardNode:RefreshPlayerData(data)
	--清除界面的显示的数据
	for i =1,MaxLength do
		local node = self.Image_content:getChildByName("data"..i);
		if node then
			node:removeFromParent();
		end
	end

	local bgSize = self.Image_content:getContentSize();

	luaDump(data,"刷新信息")

	for k,v in pairs(data) do
		local node = self.Panel_template:clone();
		node:setVisible(true);
		node:setName("data"..k);
		node:setPosition(0,bgSize.height-(k-1)*node:getContentSize().height);
		self.Image_content:addChild(node);

		--设置数据
		local Text_time = node:getChildByName("Text_time");
		if Text_time then
			Text_time:setString(v.RewardDate);
		end

		local Text_totalSum = node:getChildByName("Text_totalSum");
		if Text_totalSum then
			Text_totalSum:setString(goldConvert(v.WeekTeamAchieve+v.WeekDirectAchieve));
		end

		local Text_teamSum = node:getChildByName("Text_teamSum");
		if Text_teamSum then
			Text_teamSum:setString(goldConvert(v.WeekTeamAchieve));
		end

		local Text_playerSum = node:getChildByName("Text_playerSum");
		if Text_playerSum then
			Text_playerSum:setString(goldConvert(v.WeekDirectAchieve));
		end

		local Text_award = node:getChildByName("Text_award");
		if Text_award then
			Text_award:setString(goldConvert(v.WeekRewrd));
		end

		local Text_status = node:getChildByName("Text_status");
		if Text_status then
			local str = "异常";
			Text_status:setTextColor(cc.c3b(211,194,46));
			if v.Flag == 0 then
				-- str = "计算中";
				-- Text_status:setTextColor(cc.c3b(105,152,238));
			-- elseif v.Flag == 1 then
				str = "已发放";
				Text_status:setTextColor(cc.c3b(241,73,56));
			end


			Text_status:setString(str);
		end

	end
end


return MyAwardNode;