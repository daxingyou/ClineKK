local CreateRoomHistory = class("CreateRoomHistory", BaseWindow)

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
	local bgPanel = ccui.Layout:create();
	bgPanel:setAnchorPoint(0,0);
	bgPanel:setContentSize(87*6,63*4);
	bgPanel:setPosition(9,-5);
	self:addChild(bgPanel);
	self.bgPanel = bgPanel;

	for i = 1,6 do
		for j = 1,4 do
			local diSp = ccui.ImageView:create("roomHistory/historydi.png");
			diSp:setAnchorPoint(0,0);
			diSp:setPosition(87*(i-1),62*3 - 62*(j-1));
			diSp:setName("di"..(6*(j-1)+i));
			bgPanel:addChild(diSp);
		end
	end
	
end


function CreateRoomHistory:UpdateLayer(data)
	local dealPData = {};

	for i = 1,data.RecordCount do
		table.insert(dealPData,data.pData[i]);
	end

	data.pData = {};
	--过滤只剩18局
	if #dealPData>24 then
		for i = #dealPData - 24+1,#dealPData do
			table.insert(data.pData,dealPData[i]);
		end
	else
		data.pData = dealPData;
	end

	display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");

	--先清除界面上的图片
	for i = 1,6 do
		for j = 1,4 do
			local diSp = self.bgPanel:getChildByName("di"..(6*(j-1)+i));
			if diSp then
				diSp:removeAllChildren();
			end
		end
	end


	--绘制界面
	for k,v in pairs(data.pData) do
		local diSp = self.bgPanel:getChildByName("di"..k);
		if diSp then
			local size = diSp:getContentSize();
			local dataSp = cc.Sprite:createWithSpriteFrameName("bcbm_cm_"..v..".png");
			dataSp:setPosition(size.width/2,size.height/2);
			diSp:addChild(dataSp);

			dataSp:setScale(0.8);

			if v%2 == 0 then
				dataSp:setScale(0.6);
			end

			if k == #data.pData then
				local xin = ccui.ImageView:create("roomHistory/historyxin.png");
				xin:setPosition(size.width,size.height);
				diSp:addChild(xin);
			end
		end
	end

	--刷新界面上面的信息
	local BasicRoomInfo = data.BasicRoomInfo;

	local str = "T"..(data.BasicRoomInfo.DeskID+1);
	if data.BasicRoomInfo.DeskState ~= 0 then
		str = str.."可上庄";
	else
		str = str.."系统坐庄";
	end

	self.textTitle:setString(str);
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
		if gameStation == GameMsg.GS_FREE then
			gameStatus = "等待中";
		elseif gameStation == GameMsg.GS_Play then
			gameStatus = "下注中";
		elseif gameStation == GameMsg.GS_PLAYING then
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


return CreateRoomHistory