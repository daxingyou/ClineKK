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
	
	display.loadSpriteFrames("benchibaoma/game/benchibaoma.plist");

	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);


	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao6.png",ccui.TextureResType.localType);
	panel:addChild(imageBack);
	local size = imageBack:getContentSize();
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(panelSize.width*0.5,size.height*0.5));

	--开奖动物 图标
	local strPng = string.format("bcbm_cm_%d.png",self.m_keyCar);
	local imageCar = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);

	if self.m_keyCar%2 == 0 then
		imageCar:setScale(0.8);
	end
	
	imageBack:addChild(imageCar);--"bcbm_cm_"..v..".png"
	imageCar:setPosition(cc.p(size.width*0.5,size.height*0.5));
	
	self:addChild(panel);

end

function ItemBcbm:initData(gameData)
	self.m_gameData = gameData;
	self.m_keyCar = self.m_gameData["m_cbResultIndex"]; --开奖结果 动物
end



return ItemBcbm