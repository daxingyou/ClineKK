--飞禽走兽
local ItemFqzs = class("ItemFqzs", ccui.Layout)


function ItemFqzs:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemFqzs:create(gameData)
	local layer = ItemFqzs.new(gameData);

	return layer;
end

function ItemFqzs:initUI()
	local panelSize = cc.size(910,153);
	
	display.loadSpriteFrames("fqzs/fqzs.plist");

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
	local strPng = string.format("animal%d.png",self.m_keyCar);
	luaPrint("strPng",strPng);
	local imageCar = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);
	imageBack:addChild(imageCar);--"bcbm_cm_"..v..".png"
	imageCar:setPosition(cc.p(size.width*0.5,size.height*0.5));
	
	self:addChild(panel);

end

function ItemFqzs:initData(gameData)
	self.m_gameData = gameData;
	self.m_keyCar = self.m_gameData["m_gAnimal"]; --开奖结果 动物
end



return ItemFqzs