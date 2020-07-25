local DiceArea = require("yaoyiyao.DiceConfig");
local MultipleArea =  class("MultipleArea", PopLayer)

function MultipleArea:createLayer(areaType,chipTable,chipType,tableLayer)
    local layer = MultipleArea.new(areaType,chipTable,chipType,tableLayer);

    layer:setName("MultipleArea");

	return layer;
end

function MultipleArea:ctor(areaType,chipTable,chipType,tableLayer)
    self.super.ctor(self,PopType.none)

    self:InitLayer(areaType,chipTable,chipType,tableLayer);
end

--初始化界面
function MultipleArea:InitLayer(areaType,chipTable,chipMonyType,tableLayer)
    self:removeAllChildren();
	local rootNode = cc.CSLoader:createNode("yaoyiyao/MultipleArea.csb");
    if rootNode == nil then
        return nil;
    end
    self.xBg = rootNode
    self:addChild(rootNode);

    self.tableLayer = tableLayer;

    local areaNode = nil;
    if areaType == 1 then--组合区
    	areaNode = rootNode:getChildByName("Node_groupDice");
	elseif areaType == 2 then--豹子区
		areaNode = rootNode:getChildByName("Node_leopard");
	elseif areaType == 3 then--单骰子
		areaNode = rootNode:getChildByName("Node_singleDice");
	elseif areaType == 6 then--双骰子
		areaNode = rootNode:getChildByName("Node_doubleDice");
	end
	--显示区域
	areaNode:setVisible(true);

	areaNode:getChildByName("Button_close"):addClickEventListener(function(sender)
    	self:removeFromParent();
    end);

    for k,areaId in pairs(DiceArea[areaType]) do
    	local buttonArea = areaNode:getChildByName("Image_Bg"):getChildByName("Button_area"..areaId);
    	buttonArea:setTag(areaId);
        buttonArea.chipMonyType = chipMonyType
        buttonArea:addTouchEventListener(handler(self, self.BtnTouchCallBack))

    	for k,chipType in pairs(chipTable[areaId+1]) do--小区域创建筹码显示
    		local chipPos = cc.p(0,0);
            local shrinkLength = 10;
    		chipPos.x = buttonArea:getPositionX()+math.random(shrinkLength,buttonArea:getContentSize().width-shrinkLength)-buttonArea:getContentSize().width/2;
    		chipPos.y = buttonArea:getPositionY()+math.random(shrinkLength,buttonArea:getContentSize().height-shrinkLength)-buttonArea:getContentSize().height/2;

    		self:ChipCreate(areaNode:getChildByName("Image_Bg"),chipType,chipPos);
		end
	end
end

--触摸按钮
function MultipleArea:BtnTouchCallBack(sender,eventType)
    local areaId = sender:getTag();
    local chipMonyType = sender.chipMonyType;
    if eventType == ccui.TouchEventType.began then
        sender:getChildByName("Image_click"):setVisible(true);
    elseif eventType == ccui.TouchEventType.moved then
        -- sender:getChildByName("Image_click"):setVisible(false);
    elseif eventType == ccui.TouchEventType.ended then
        sender:getChildByName("Image_click"):setVisible(false);
        local throwState = self.tableLayer:JudgeSelfThrow(self.tableLayer:ChipTypeToChipMoney(chipMonyType),areaId,chipMonyType);
        -- if throwState then
        --     self:getParent():RememberChipThrow(chipMonyType,areaId);
        -- end
		self:removeFromParent();
	elseif eventType == ccui.TouchEventType.canceled then
		sender:getChildByName("Image_click"):setVisible(false);
    end
end

--创建筹码
function MultipleArea:ChipCreate(rootNode,chipType,beginPos)
	--创建
	cc.SpriteFrameCache:getInstance():addSpriteFrames("yaoyiyao/chip/chip.plist");
	local chipSp = cc.Sprite:createWithSpriteFrameName("yyy_"..chipType..".png");
	chipSp:setTag(chipType);
	chipSp:setPosition(beginPos);
	chipSp:setScale(0.25);
	rootNode:addChild(chipSp);

	return chipSp;
end


return MultipleArea