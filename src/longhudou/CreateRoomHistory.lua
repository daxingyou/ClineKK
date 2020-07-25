local CreateRoomHistory = class("CreateRoomHistory", BaseWindow)
local LZLogic = require("longhudou.LZLogic");

function CreateRoomHistory:create(size)
	return CreateRoomHistory.new(size)
end

function CreateRoomHistory:ctor(size)
	self.super.ctor(self, 0);
	self:setContentSize(size);
	self:InitUI();
end

function CreateRoomHistory:onEnter()
	self.super.onEnter(self);
end

function CreateRoomHistory:InitUI()
	local size = self:getContentSize();

	local bg = ccui.ImageView:create("roomHistory/historykuang.png");
	bg:setAnchorPoint(0.5,1);
	bg:setPosition(size.width/2,size.height);
	self:addChild(bg);

	--摆放庄问路 闲问路
	local zWen = ccui.ImageView:create("roomHistory/zhuangwenlu.png");
	zWen:setAnchorPoint(0.5,0);
	zWen:setPosition(478,25);
	bg:addChild(zWen);

	local xWen = ccui.ImageView:create("roomHistory/xianwenlu.png");
	xWen:setAnchorPoint(0.5,0);
	xWen:setPosition(566,25);
	bg:addChild(xWen);

	local sumBg = ccui.ImageView:create("roomHistory/historytishi.png");
	sumBg:setAnchorPoint(0,0.5);
	sumBg:setPosition(6,28);
	self:addChild(sumBg);

	local color = cc.c3b(255,224,81)
	color = FontConfig.colorWhite
	--上方横条显示
	local textTitle = FontConfig.createWithSystemFont("",24,color);
    textTitle:setPosition(8,size.height+5);
    textTitle:setAnchorPoint(cc.p(0, 0));
    self:addChild(textTitle);
    self.textTitle = textTitle;

    local textOnLine = FontConfig.createWithSystemFont("",24,color);
    textOnLine:setPosition(158,size.height+5);
    textOnLine:setAnchorPoint(cc.p(0, 0));
    self:addChild(textOnLine);
    self.textOnLine = textOnLine;

    local textLimit = FontConfig.createWithSystemFont("",24,color);
    textLimit:setPosition(260,size.height+5);
    textLimit:setAnchorPoint(cc.p(0, 0));
    self:addChild(textLimit);
    self.textLimit = textLimit;

    local textTimeStr = FontConfig.createWithSystemFont("",24,color);
    textTimeStr:setPosition(498,size.height+5);
    textTimeStr:setAnchorPoint(cc.p(0, 0));
    self:addChild(textTimeStr);
    self.textTimeStr = textTimeStr;

    local textTime = FontConfig.createWithSystemFont("",24,color);
    textTime:setPosition(textTimeStr:getPositionX()+75,size.height+5);
    textTime:setAnchorPoint(cc.p(0, 0));
    textTime:setTag(0);
    self:addChild(textTime);
    self.textTime = textTime;

    self.textTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
    	local tag = textTime:getTag();

    	if tag > 0 then
    		tag = tag - 1;
    		textTime:setTag(tag);
    		textTime:setString(tag);
    	end
    end))));

---------------------------------------------

	--数字统计
	local zhuangZi = FontConfig.createWithCharMap("","roomHistory/historyzitiao.png",16,23,"0");
	zhuangZi:setAnchorPoint(0,0.5);
	zhuangZi:setPosition(36,sumBg:getContentSize().height/2);
	sumBg:addChild(zhuangZi);
	self.zhuangZi = zhuangZi;

	local xianZi = FontConfig.createWithCharMap("","roomHistory/historyzitiao.png",16,23,"0");
	xianZi:setAnchorPoint(0,0.5);
	xianZi:setPosition(115,sumBg:getContentSize().height/2);
	sumBg:addChild(xianZi);
	self.xianZi = xianZi;

	local pingZi = FontConfig.createWithCharMap("","roomHistory/historyzitiao.png",16,23,"0");
	pingZi:setAnchorPoint(0,0.5);
	pingZi:setPosition(193,sumBg:getContentSize().height/2);
	sumBg:addChild(pingZi);
	self.pingZi = pingZi;


	--大路
	local daPanel = ccui.Layout:create();
	daPanel:setAnchorPoint(0,0);
	daPanel:setContentSize(361,93);
	daPanel:setPosition(250-2,94);
	bg:addChild(daPanel);
	self.Panel_da = daPanel;

	--珠路
	local zhuPanel = ccui.Layout:create();
	zhuPanel:setAnchorPoint(0,0);
	zhuPanel:setContentSize(250,187);
	zhuPanel:setPosition(0,0);
	bg:addChild(zhuPanel);
	self.Panel_zhu = zhuPanel;

	--大眼仔路
	local yanPanel = ccui.Layout:create();
	yanPanel:setAnchorPoint(0,0);
	yanPanel:setContentSize(180.5,47);
	yanPanel:setPosition(250-2,47);
	bg:addChild(yanPanel);
	self.Panel_yan = yanPanel;

	--小路
	local xiaoPanel = ccui.Layout:create();
	xiaoPanel:setAnchorPoint(0,0);
	xiaoPanel:setContentSize(180.5,47);
	xiaoPanel:setPosition(430.5-2,47);
	bg:addChild(xiaoPanel);
	self.Panel_xiao = xiaoPanel;

	--冉由路
	local ryPanel = ccui.Layout:create();
	ryPanel:setAnchorPoint(0,0);
	ryPanel:setContentSize(180.5,47);
	ryPanel:setPosition(250-2,0);
	bg:addChild(ryPanel);
	self.Panel_ry = ryPanel;

	--庄问路
	local zwlPanel = ccui.Layout:create();
	zwlPanel:setAnchorPoint(0,0);
	zwlPanel:setContentSize(90.25,0);
	zwlPanel:setPosition(430.5,0);
	bg:addChild(zwlPanel);
	self.Panel_zwl = zwlPanel;

	--闲问路
	local xwlPanel = ccui.Layout:create();
	xwlPanel:setAnchorPoint(0,0);
	xwlPanel:setContentSize(90.25,0);
	xwlPanel:setPosition(520.75,0);
	bg:addChild(xwlPanel);
	self.Panel_xwl = xwlPanel;
end


function CreateRoomHistory:UpdateLayer(data)
	local dealPData = {};

	local data = clone(data);

	for i = 1,data.RecordCount do
		local temp = {};
		temp.iWinner = data.pData[i];
		table.insert(dealPData,temp);
	end

	data.pData = dealPData;
	
	--有游戏界面不刷新路子
	if display.getRunningScene():getChildByName("gameLayer") == nil then
		self:RefreshAllLZ(data.pData);
	end

	--刷新界面上面的信息
	local BasicRoomInfo = data.BasicRoomInfo;
	self.textTitle:setString("T"..(data.BasicRoomInfo.DeskID+1));
	self.textOnLine:setString("在线"..BasicRoomInfo.OnlineUser);

	if BasicRoomInfo.RoomMinScore >= 0 then
		local str = "免费体验"
		if BasicRoomInfo.RoomMinScore > 0 then
			str = goldConvert(BasicRoomInfo.RoomMinScore);
		end

		self.textLimit:setString("入场限制："..str);
		self.textLimit:setVisible(true);
	else
		self.textLimit:setVisible(false);
	end

	local gameStation = BasicRoomInfo.GameStation;
	if gameStation > 0 then
		local leftTime = BasicRoomInfo.LeftTime - (BasicRoomInfo.NowTime - BasicRoomInfo.ChangeTime);

		local gameStatus = "";
		if gameStation == 23 then
			gameStatus = "等待中";
		elseif gameStation == 21 then
			gameStatus = "下注中";
		elseif gameStation == 22 then
			gameStatus = "开奖中";
		end

		if leftTime<0 then
			gameStatus = "等待中";
			leftTime = 0;
		end

		self.textTimeStr:setString(gameStatus);
		self.textTime:setString(leftTime);
		self.textTime:setTag(leftTime);
	else
		self.textTimeStr:setString("等待中");
	end
end

--刷新所有界面
function CreateRoomHistory:RefreshAllLZ(msg)

	self:RefreshZhuLZ(msg);

	self:RefreshDaLZ(msg);

	self:RefreshYanLZ(msg);

	self:RefreshXiaoLZ(msg);

	self:RefreshRyLZ(msg);

	self:Refreshzwl(msg);

	self:Refreshxwl(msg);

	--显示数量
	local zCount = 0;
	local xCount = 0;
	local pCount = 0;

	for k,v in pairs(msg) do
		local msgType = LZLogic:GetType(v);
		if msgType == 0 then
			pCount = pCount+1;
		elseif msgType == 1 then
			xCount = xCount+1;
		elseif msgType == 2 then
			zCount = zCount+1;
		end

	end

	self.zhuangZi:setString(zCount);
	self.xianZi:setString(xCount);
	self.pingZi:setString(pCount);

end

--刷新珠路
function CreateRoomHistory:RefreshZhuLZ(msg)
	local lzWidth = 8;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetZLWayList(msg,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_zhu:removeAllChildren();
	local size = self.Panel_zhu:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			local str = "lz2_"..v2.type..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+2,(lzHeight - k2)*height);
			self.Panel_zhu:addChild(sp);

			if v2.lastFlag then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新大路
function CreateRoomHistory:RefreshDaLZ(msg)
	local lzWidth = 24;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetNewBigWayList(msg,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_da:removeAllChildren();
	local size = self.Panel_da:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			local str = "lz"..v2.color..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+2,(lzHeight - k2)*height);
			self.Panel_da:addChild(sp);

			local spSize = sp:getContentSize();

			--创建和局的数
			if v2.flatCount > 0 then
				local heshu = FontConfig.createWithCharMap(v2.flatCount,"roomHistory/heshu.png",8,10,"0")--庄
				heshu:setPosition(spSize.width/2,spSize.height/2);
				sp:addChild(heshu);
			end

			if v2.lastFlag then
				self:LastPointAction(sp);
			end
		end
	end
end

--刷新大眼仔路
function CreateRoomHistory:RefreshYanLZ(msg)
	local lzWidth = 24;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,2,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_yan:removeAllChildren();
	local size = self.Panel_yan:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lz3_"..v2.color..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+3,(lzHeight - k2)*height);
			self.Panel_yan:addChild(sp);

			if v2.lastFlag then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新小路
function CreateRoomHistory:RefreshXiaoLZ(msg)
	local lzWidth = 24;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,3,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_xiao:removeAllChildren();
	local size = self.Panel_xiao:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lz4_"..v2.color..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+3,(lzHeight - k2)*height);
			self.Panel_xiao:addChild(sp);

			if v2.lastFlag then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新冉由路
function CreateRoomHistory:RefreshRyLZ(msg)
	local lzWidth = 24;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,4,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_ry:removeAllChildren();
	local size = self.Panel_ry:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lz5_"..v2.color..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+3,(lzHeight - k2)*height);
			self.Panel_ry:addChild(sp);

			if v2.lastFlag then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新庄问路
function CreateRoomHistory:RefreshRyLZ(msg)
	local lzWidth = 24;
	local lzHeight = 6;

	local dataDeal = LZLogic:GetThreeWayList(msg,4,lzHeight);
	dataDeal = LZLogic:GetMaxLength(dataDeal,lzWidth);

	--先删除珠路上的所有图片
	self.Panel_ry:removeAllChildren();
	local size = self.Panel_ry:getContentSize();

	local width = size.width/lzWidth;
	local height = size.height/lzHeight;

	--绘制
	for k1,v1 in pairs(dataDeal) do
		for k2, v2 in pairs(v1) do
			--2龙 1虎 0平
			local str = "lz5_"..v2.color..".png";

			local sp = ccui.ImageView:create("roomHistory/"..str);
			sp:setAnchorPoint(0,0);
			sp:setPosition((k1-1)*width+3,(lzHeight - k2)*height);
			self.Panel_ry:addChild(sp);

			if v2.lastFlag then
				self:LastPointAction(sp);
			end

		end
	end
end

--刷新庄问路
function CreateRoomHistory:Refreshzwl(msg)
	self.Panel_zwl:removeAllChildren();
	local size = self.Panel_zwl:getContentSize();

	local width = size.width/3;
	local height = 5;


	local lType = LZLogic:GetFutureWay(msg,1,2);

	if lType then
		local str = "roomHistory/wenlu-1-"..lType..".png";
		local sp = ccui.ImageView:create(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10,height);
		self.Panel_zwl:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,1,3);

	if lType then
		local str = "roomHistory/wenlu-2-"..lType..".png";
		local sp = ccui.ImageView:create(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width,height);
		self.Panel_zwl:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,1,4);

	if lType then
		local str = "roomHistory/wenlu-3-"..lType..".png";
		local sp = ccui.ImageView:create(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width*2,height);
		self.Panel_zwl:addChild(sp);

	end

end

--刷新闲问路
function CreateRoomHistory:Refreshxwl(msg)
	self.Panel_xwl:removeAllChildren();
	local size = self.Panel_xwl:getContentSize();

	local width = size.width/3;
	local height = 5;


	local lType = LZLogic:GetFutureWay(msg,2,2);

	if lType then
		local str = "roomHistory/wenlu-1-"..lType..".png";
		local sp = ccui.ImageView:create(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10,height);
		self.Panel_xwl:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,2,3);
	if lType then
		local str = "roomHistory/wenlu-2-"..lType..".png";
		local sp = ccui.ImageView:create(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width,height);
		self.Panel_xwl:addChild(sp);

	end

	local lType = LZLogic:GetFutureWay(msg,2,4);

	if lType then
		local str = "roomHistory/wenlu-3-"..lType..".png";
		local sp = ccui.ImageView:create(str);
		sp:setAnchorPoint(0,0);
		sp:setPosition(10+width*2,height);
		self.Panel_xwl:addChild(sp);

	end

end

--路子最后个进行闪烁
function CreateRoomHistory:LastPointAction(pNode)
	if true then
		return;
	end

	pNode:setVisible(true);
	pNode:setOpacity(0);
	local fadeInAction = cc.FadeIn:create(0.4);
	local fadeOutAction = cc.FadeOut:create(0.4);
	pNode:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(fadeInAction,fadeOutAction),3),fadeInAction));
end



return CreateRoomHistory
