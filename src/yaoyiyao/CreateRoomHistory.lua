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

	--上方横条显示
	local textTitle = FontConfig.createWithSystemFont("",24,cc.c3b(255,224,81));
    textTitle:setPosition(8,size.height+5);
    textTitle:setAnchorPoint(cc.p(0, 0));
    self:addChild(textTitle);
    self.textTitle = textTitle;

    local textOnLine = FontConfig.createWithSystemFont("",24,cc.c3b(255,224,81));
    textOnLine:setPosition(158,size.height+5);
    textOnLine:setAnchorPoint(cc.p(0, 0));
    self:addChild(textOnLine);
    self.textOnLine = textOnLine;

    local textLimit = FontConfig.createWithSystemFont("",24,cc.c3b(255,224,81));
    textLimit:setPosition(260,size.height+5);
    textLimit:setAnchorPoint(cc.p(0, 0));
    self:addChild(textLimit);
    self.textLimit = textLimit;

    local textTimeStr = FontConfig.createWithSystemFont("",24,cc.c3b(255,224,81));
    textTimeStr:setPosition(498,size.height+5);
    textTimeStr:setAnchorPoint(cc.p(0, 0));
    self:addChild(textTimeStr);
    self.textTimeStr = textTimeStr;

    local textTime = FontConfig.createWithSystemFont("",24,cc.c3b(255,224,81));
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

	local dealPData1 = {};
	for i = 1,#dealPData do
		if dealPData[i][1] ~= -1 and dealPData[i][2] ~= -1 and dealPData[i][3] ~= -1 and dealPData[i][4] ~= -1 then
			table.insert(dealPData1,dealPData[i]);
		end
	end

	data.pData = {};
	--过滤只剩18局
	if #dealPData1>24 then
		for i = #dealPData1 - 24+1,#dealPData1 do
			table.insert(data.pData,dealPData1[i]);
		end
	else
		data.pData = dealPData1;
	end

	display.loadSpriteFrames("yaoyiyao/yaoyiyao.plist");

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


			local diceTotalNum = v[2];
            local diceNum = {};
            for j = 1,3 do
            	table.insert(diceNum,diceTotalNum%10);
                diceTotalNum = math.floor(diceTotalNum/10);
            end

            for k1,v1 in pairs(diceNum) do
				local dataSp = cc.Sprite:createWithSpriteFrameName("yyy_Dice"..v1..".png");
				diSp:addChild(dataSp);
				dataSp:setScale(0.24);


				if k1 == 1 then
					dataSp:setPosition(size.width/2,size.height-15);
				elseif k1 == 2 then
					dataSp:setPosition(size.width/2-15,size.height-38);
				else
					dataSp:setPosition(size.width/2+15,size.height-38);
				end

			end

			local diceNumTotal = diceNum[1]+diceNum[2]+diceNum[3]; 
			local diceNumStr = FontConfig.createWithSystemFont(diceNumTotal.."点",12,FontConfig.colorYellow);
		    diceNumStr:setPosition(size.width/2-5,0);
		    diceNumStr:setAnchorPoint(cc.p(1, 0));
		    diSp:addChild(diceNumStr);

		    local str = "";

		    if diceNum[1] == diceNum[2] and diceNum[1] == diceNum[3] and diceNum[3] == diceNum[2] then
                str = "豹";
            else
                if diceNumTotal < 11  then
                    str = "小";
                else
                    str = "大";
                end
            end

            local daStr = FontConfig.createWithSystemFont(str,11,FontConfig.colorYellow);
		    daStr:setPosition(size.width/2+11,0);
		    daStr:setAnchorPoint(cc.p(0, 0));
		    diSp:addChild(daStr);

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
	if data.BasicRoomInfo.DeskID < 2 then
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
		if gameStation == 23 then
			gameStatus = "等待中";
		elseif gameStation == 21 then
			gameStatus = "下注中";
		elseif gameStation == 22 then
			gameStatus = "开奖中";
			leftTime = leftTime-1;
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