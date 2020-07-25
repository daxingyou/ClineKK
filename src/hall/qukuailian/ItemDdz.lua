--斗地主
local ItemDdz = class("ItemDdz", ccui.Layout)


function ItemDdz:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemDdz:create(gameData)
	local layer = ItemDdz.new(gameData);

	return layer;
end

function ItemDdz:initUI()

	--153*4 + 5*3
	local panelSize = cc.size(910,627);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	--底牌背景
	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao2.png",ccui.TextureResType.localType);
	panel:addChild(imageBack);
	local size = imageBack:getContentSize();
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size.height*0.5));
	self.Panel_Common = imageBack;
	--底牌提示
	local imgCommon = ccui.ImageView:create("qukuailian/image2/qklian_dipai.png",ccui.TextureResType.localType);
	imgCommon:setPosition(cc.p(80,100));
	imageBack:addChild(imgCommon);

	display.loadSpriteFrames("doudizhu/card.plist", "doudizhu/card.png");
	local didth = 5;
	--底牌三张牌
	local cardTb = {}
	for i=1,3 do
		
		local value = self.m_cardCommonTb[i];
		local strPng = string.format("sdb_0x%02X.png", value);
		luaPrint("strPng:",strPng);
		local card = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);
		imageBack:addChild(card);
		
		local width = card:getContentSize().width*0.68;
		local startPos = 524 - didth*1 - width*1
		card:setScale(0.68);
		card:setPosition(cc.p(startPos+width*0+width*(i-1)+didth*(i-1),79.5));
	
	end

	
	--玩家牌面板 self.m_playerTb
	for i=1,3 do
		local image = ccui.ImageView:create("qukuailian/image2/qklian_tiao2.png",ccui.TextureResType.localType);
		panel:addChild(image);
		local size = image:getContentSize();
		image:setAnchorPoint(0.5,0.5);
		local index = i%2
		local col = math.ceil(i/2)
		image:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size.height*0.5-didth*(i-1) - size.height*i));

		--昵称
		
		local imgNick = ccui.ImageView:create("qukuailian/image2/qklian_nichen.png",ccui.TextureResType.localType);
		image:addChild(imgNick);
		imgNick:setPosition(cc.p(63,105));

		local nameStr = FormotGameNickName(self.m_playerTb[i]["nickName"],6)
		local labelNick = FontConfig.createWithSystemFont(nameStr,20 ,FontConfig.colorWhite,cc.size(180,20),cc.TEXT_ALIGNMENT_LEFT);
		labelNick:setAnchorPoint(cc.p(0,0.5));
	    labelNick:setPosition(0,55);
	    image:addChild(labelNick);

		local cardTb = self.m_playerTb[i]["cbHandCardData"];
		
		for i,v in ipairs(cardTb) do
			local card = ccui.ImageView:create(string.format("sdb_0x%02X.png", v),ccui.TextureResType.plistType);
			image:addChild(card);
			card:setScale(0.68);
			card:setPosition(cc.p(256+(i-1)*35,80));
		end
		
	end


	self:addChild(panel);

end

function ItemDdz:initData(gameData)
	self.m_gameData = gameData;
	self.m_panelList = {} --底牌面板
	self.Panel_Common = nil; --公共牌面板

	self.m_cardCommonTb = self.m_gameData["m_cbBankerCard"] --底牌
	self.m_playerTb = self.m_gameData["itemlist"] --玩家数据

end



return ItemDdz