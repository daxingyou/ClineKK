--百家乐
local ItemBjl = class("ItemBjl", ccui.Layout)


function ItemBjl:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemBjl:create(gameData)
	local layer = ItemBjl.new(gameData);

	return layer;
end

function ItemBjl:initUI()

	display.loadSpriteFrames("baijiale/card.plist", "baijiale/card.png");

	local panelSize = cc.size(910,206);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);


	--闲家
	local imageXian = ccui.ImageView:create("qukuailian/image2/qklian_lankuang.png",ccui.TextureResType.localType);
	panel:addChild(imageXian);
	local size = imageXian:getContentSize();
	imageXian:setPosition(cc.p(panelSize.width*0.5-20 - size.width*0.5,panelSize.height*0.5));
	--闲img	
	local imageXianWord = ccui.ImageView:create("qukuailian/image2/qklian_xian.png",ccui.TextureResType.localType);
	imageXian:addChild(imageXianWord);
	imageXianWord:setPosition(cc.p(92,96));

	local midPos = cc.p(278,105.5);
	local didth = 5;
	luaDump(self.m_cardZhuangTb, "self.m_cardZhuangTb", 5)
	luaDump(self.m_cardXianTb, "self.m_cardXianTb", 5)
	for i=1,3 do
		local value = self.m_cardXianTb[i];

		if value > 0 then
			local strPng = string.format("sdb_0x%02X.png", value);
			luaPrint("strPng:",strPng);
			local card = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);
			imageXian:addChild(card);
			local width = card:getContentSize().width*0.68;
			local startPos = 278 - didth*1 - width*0.5;
			card:setScale(0.68);
			
			card:setPosition(cc.p(startPos+width*0.5*(i-1)+didth*(i-1),105.5));
			
		end
		
	end


	--庄家
	local imageZhuang = ccui.ImageView:create("qukuailian/image2/qklian_lankuang.png",ccui.TextureResType.localType);
	panel:addChild(imageZhuang);
	local size = imageZhuang:getContentSize();
	imageZhuang:setPosition(cc.p(panelSize.width*0.5+20 + size.width*0.5,panelSize.height*0.5));
	--庄img	
	local imageZhuangWord = ccui.ImageView:create("qukuailian/image2/qklian_zhuang.png",ccui.TextureResType.localType);
	imageZhuang:addChild(imageZhuangWord);
	imageZhuangWord:setPosition(cc.p(92,96));

	for i=1,3 do
		local value = self.m_cardZhuangTb[i];
		if value > 0 then
			local strPng = string.format("sdb_0x%02X.png", value);
			local card = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);
			imageZhuang:addChild(card);
			local width = card:getContentSize().width*0.68;
			local startPos = 278 - didth*1 - width*0.5;
			card:setScale(0.68);
			card:setPosition(cc.p(startPos+width*0.5*(i-1)+didth*(i-1),105.5));
		end
	end


	self:addChild(panel);

end

function ItemBjl:initData(gameData)
	self.m_gameData = gameData;

	self.m_cardZhuangTb = self.m_gameData["m_cbTableCardArray"][1]; --庄牌
	self.m_cardXianTb = self.m_gameData["m_cbTableCardArray"][2]; --闲牌
end



return ItemBjl