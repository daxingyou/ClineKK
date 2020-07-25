--奔驰宝马
local ItemBcbm = class("ItemBcbm", ccui.Layout)


function ItemBcbm:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemBcbm:create(gameData)
	local layer = ItemBcbm.new(gameData);

	return layer;
end

function ItemBcbm:initUI()
	local panelSize = cc.size(910,153);
	
	display.loadSpriteFrames("yaoyiyao/yaoyiyao.plist");

	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);


	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao6.png",ccui.TextureResType.localType);
	panel:addChild(imageBack);
	local size = imageBack:getContentSize();
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(panelSize.width*0.5,size.height*0.5));

	local diceNum = self.m_gameData.DiceData;
	for k1,v1 in pairs(diceNum) do
		local dataSp = cc.Sprite:createWithSpriteFrameName("yyy_Dice"..v1..".png");
		imageBack:addChild(dataSp);
		dataSp:setScale(0.5);


		if k1 == 1 then
			dataSp:setPosition(size.width/2,size.height-40);
		elseif k1 == 2 then
			dataSp:setPosition(size.width/2-25,size.height-85);
		else
			dataSp:setPosition(size.width/2+25,size.height-85);
		end

	end

	local diceNumTotal = diceNum[1]+diceNum[2]+diceNum[3]; 
	local diceNumStr = FontConfig.createWithSystemFont(diceNumTotal.."点",20,FontConfig.colorYellow);
    diceNumStr:setPosition(size.width/2-5,20);
    diceNumStr:setAnchorPoint(cc.p(1, 0));
    imageBack:addChild(diceNumStr);

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

    local daStr = FontConfig.createWithSystemFont(str,20,FontConfig.colorYellow);
    daStr:setPosition(size.width/2+11,20);
    daStr:setAnchorPoint(cc.p(0, 0));
    imageBack:addChild(daStr);
	
	self:addChild(panel);

end

function ItemBcbm:initData(gameData)
	self.m_gameData = gameData;
	self.m_keyCar = self.m_gameData["m_cbResultIndex"]; --开奖结果 动物
end



return ItemBcbm