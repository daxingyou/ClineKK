--百家乐
local ItemErnn = class("ItemErnn", ccui.Layout)


function ItemErnn:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	luaDump(gameData,"ItemErnn");
	self:initData(gameData);
	self:initUI();


	

end

function ItemErnn:create(gameData)
	local layer = ItemErnn.new(gameData);

	return layer;
end

function ItemErnn:initUI()

	display.loadSpriteFrames("errenniuniu/card.plist", "errenniuniu/card.png");

	local panelSize = cc.size(910,160*#self.m_playerTb);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	local didth = 5;
	--玩家牌面板 self.m_playerTb
	for i=1,#self.m_playerTb do
		local image = ccui.ImageView:create("qukuailian/image2/qklian_tiao2.png",ccui.TextureResType.localType);
		panel:addChild(image);
		local size = image:getContentSize();
		image:setAnchorPoint(0.5,0.5);
		local index = i%2
		local col = math.ceil(i/2)
		image:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size.height*0.5-didth*(i-1) - size.height*(i-1)));

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
			card:setPosition(cc.p(image:getContentSize().width/2-(math.floor(5/2)*80)+i*80,80));
		end

	end


	self:addChild(panel);

end

function ItemErnn:initData(gameData)
	self.m_gameData = gameData;

	self.m_playerTb = self.m_gameData["itemlist"];

	luaDump(self.m_playerTb,"self.m_playerTb");

	-- self.m_cardZhuangTb = self.m_gameData["m_cbTableCardArray"][1]; --庄牌
	-- self.m_cardXianTb = self.m_gameData["m_cbTableCardArray"][2]; --闲牌
end

return ItemErnn