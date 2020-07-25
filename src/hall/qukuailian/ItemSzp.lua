--三张牌
local ItemSzp = class("ItemSzp", ccui.Layout)


function ItemSzp:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemSzp:create(gameData)
	local layer = ItemSzp.new(gameData);

	return layer;
end

function ItemSzp:initUI()

	--153*3 + 5*2
	local panelSize = cc.size(910,469);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	
	display.loadSpriteFrames("sanzhangpai/image/szp_card.plist","sanzhangpai/image/szp_card.png");

	local didth = 5;

	--玩家牌面板
	for i=1,5 do
		local image = ccui.ImageView:create("qukuailian/image2/qklian_tiao3.png",ccui.TextureResType.localType);
		panel:addChild(image);
		local size = image:getContentSize();
		image:setAnchorPoint(0.5,0.5);
		local index = i%2
		local col = math.ceil(i/2)
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
			for ii=1,3 do
				local card = ccui.ImageView:create(string.format("szp_0x%02X.png",self.m_playerTb[i]["cbHandCardData"][ii]),ccui.TextureResType.plistType);
				image:addChild(card);
				local width = card:getContentSize().width*0.68;
				local startPos = 298 - didth*1 - width*0.5;
				card:setScale(0.68);
				-- card:setVisible(i ~= 2);
				card:setPosition(cc.p(startPos+width*0.5*(ii-1)+didth*(ii-1),80));
				-- table.insert(cardTb,card);
			end
			-- table.insert(self.m_cardPlayerTb,cardTb);
		end
		
	end


	self:addChild(panel);

end

function ItemSzp:initData(gameData)
	self.m_gameData = gameData;
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
					cbHandCardData = {0,0,0},
					nickName = "",
					}
		table.insert(tb,tb2);
	end

	self.m_playerTb = tb;
	luaDump(self.m_playerTb,"self.m_playerTb-abc", 5)
end



return ItemSzp