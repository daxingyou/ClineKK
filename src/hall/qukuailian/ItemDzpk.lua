--德州扑克
local ItemDzpk = class("ItemDzpk", ccui.Layout)


function ItemDzpk:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemDzpk:create(gameData)
	local layer = ItemDzpk.new(gameData);

	return layer;
end

function ItemDzpk:initUI()

	--153*4 + 5*3
	local panelSize = cc.size(910,469+10);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");

	--公共牌背景
	-- local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao2.png",ccui.TextureResType.localType);
	-- panel:addChild(imageBack);
	-- local size = imageBack:getContentSize();
	-- imageBack:setAnchorPoint(0.5,0.5);
	-- imageBack:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size.height*0.5));
	-- self.Panel_Common = imageBack;
	-- --公共牌提示
	-- local imgCommon = ccui.ImageView:create("qukuailian/image2/qklian_gonggongpai.png",ccui.TextureResType.localType);
	-- imgCommon:setPosition(cc.p(80,100));
	-- imageBack:addChild(imgCommon);

	-- display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	-- --公共五张牌
	-- local cardTb = {}
	-- for i=1,5 do
	-- 	local card = ccui.ImageView:create(string.format("dzpk_0x%02X.png", self.m_commonCards[i]),ccui.TextureResType.plistType);
	-- 	imageBack:addChild(card);
	-- 	local didth = 20;
	-- 	local width = card:getContentSize().width*0.68;
	-- 	local startPos = 524 - didth*2 - width*2
	-- 	card:setScale(0.68);
	-- 	card:setPosition(cc.p(startPos+width*0+width*(i-1)+didth*(i-1),79.5));
	
	-- end

	
	--玩家牌面板
	for i=1,5 do
		local image = ccui.ImageView:create("qukuailian/image2/qklian_tiao3.png",ccui.TextureResType.localType);
		panel:addChild(image);
		local size = image:getContentSize();
		image:setAnchorPoint(0.5,0.5);
		local index = i%2
		local col = math.ceil(i/2)
		-- image:setPosition(cc.p(panelSize.width*(0.75-index*0.5),panelSize.height-size.height*0.5-5*col - size.height*col));
		image:setPosition(cc.p(panelSize.width*(0.75-index*0.5),panelSize.height-size.height*0.5-5*col - size.height*(col-1)));
		if self.m_playerTb[i]["cbHandCardData"][1] > 0 then
			--昵称
			local imgNick = ccui.ImageView:create("qukuailian/image2/qklian_nichen.png",ccui.TextureResType.localType);
			image:addChild(imgNick);
			imgNick:setPosition(cc.p(63,105));

			local nameStr = FormotGameNickName(self.m_playerTb[i]["nickName"],6)
			local labelNick = FontConfig.createWithSystemFont(nameStr,20 ,FontConfig.colorWhite,cc.size(180,20),cc.TEXT_ALIGNMENT_LEFT);
			labelNick:setAnchorPoint(cc.p(0,0.5));
		    labelNick:setPosition(0,55);
		    image:addChild(labelNick);

			local cardTb = {}
			local posTb = {cc.p(246,80),cc.p(346,80)}
			for ii=1,2 do
				local value = self.m_playerTb[i]["cbHandCardData"][ii];
				luaPrint("card_value:",value);
				local strPng = string.format("dzpk_0x%02X.png",value);
				luaPrint("strPng:",strPng);
				local card = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);
				image:addChild(card);
				card:setScale(0.68);
				card:setPosition(posTb[ii]);
			end
		end
	end


	self:addChild(panel);

end

function ItemDzpk:initData(gameData)
	self.m_gameData = gameData;
	self.m_commonCards = self.m_gameData["iPublicCard"]; --公共牌
	self.m_playerTb = self.m_gameData["itemlist"]; --玩家 数据
	luaDump(self.m_playerTb,"self.m_playerTb-aaac", 5)
	local tb = {};
	for i,v in ipairs(self.m_playerTb) do
		if v["cbHandCardData"][1] > 0 then
			table.insert(tb,v);
		end
	end

	local len = table.nums(tb);
	for i=1,5-len do		
		local tb2 = {
					cbHandCardData = {0,0},
					nickName = "",
					}
		table.insert(tb,tb2);
	end

	self.m_playerTb = tb;
	luaDump(self.m_playerTb,"self.m_playerTb-abc", 5)

end



return ItemDzpk