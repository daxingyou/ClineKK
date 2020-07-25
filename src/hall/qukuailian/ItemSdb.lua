--十点半
local ItemSdb = class("ItemSdb", ccui.Layout)


function ItemSdb:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemSdb:create(gameData)
	local layer = ItemSdb.new(gameData);

	return layer;
end

function ItemSdb:initUI()

	--153*3 + 5*2
	local panelSize = cc.size(910,469);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	display.loadSpriteFrames("shidianban/card.plist","shidianban/card.png")

	local didth = 5;

	local dataCopy = {};

	for i = 1,5 do
		dataCopy[i] = {};
		dataCopy[i].nickName = "";
		dataCopy[i].m_cbHandCardData = {};
		for j = 1,5 do
			dataCopy[i].m_cbHandCardData[j] = 0;
		end
	end

	local count = 1;
	for k,v in pairs(self.m_gameData.itemlist) do
		if v.m_cbHandCardData[1] ~= 0 then
			dataCopy[count].nickName = v.nickName;
			dataCopy[count].m_cbHandCardData = v.m_cbHandCardData;
			count = count+1;
		end
	end

	--玩家牌面板
	for i=1,5 do
		local image = ccui.ImageView:create("qukuailian/image2/qklian_tiao3.png",ccui.TextureResType.localType);
		panel:addChild(image);
		local size = image:getContentSize();
		image:setAnchorPoint(0.5,0.5);
		local index = i%2
		local col = math.ceil(i/2)
		image:setPosition(cc.p(panelSize.width*(0.75-index*0.5),panelSize.height-size.height*0.5-5*col - size.height*(col-1)));

		--昵称
		local imgNick = ccui.ImageView:create("qukuailian/image2/qklian_nichen.png",ccui.TextureResType.localType);
		image:addChild(imgNick);
		imgNick:setPosition(cc.p(63,105));

		if dataCopy[i].m_cbHandCardData[1]~= 0 then
			local labelNick = FontConfig.createWithSystemFont(FormotGameNickName(dataCopy[i].nickName,nickNameLen),20 ,FontConfig.colorWhite,cc.size(180,20),cc.TEXT_ALIGNMENT_LEFT);
			labelNick:setAnchorPoint(cc.p(0,0.5));
		    labelNick:setPosition(0,55);
		    image:addChild(labelNick);
		end

		local cardTb = {}

		local pos = 220;
		for j=1,5 do
			if dataCopy[i].m_cbHandCardData[j] ~= 0 then
				local card = ccui.ImageView:create(string.format("sdb_0x%02X.png", dataCopy[i].m_cbHandCardData[j]),ccui.TextureResType.plistType);
				image:addChild(card);
				local width = card:getContentSize().width*0.68;
				local startPos = 298 - didth*1 - width*0.5;
				card:setScale(0.68);
				-- card:setVisible(i ~= 2);
				pos = pos+30;
				card:setPosition(cc.p(pos,80));
				table.insert(cardTb,card);
			end
		end
		table.insert(self.m_cardPlayerTb,cardTb);
	end


	self:addChild(panel);

end

function ItemSdb:initData(gameData)
	self.m_gameData = gameData;
	self.m_panelList = {} --玩家牌面板
	self.Panel_Common = nil; --公共牌面板


	self.m_cardPlayerTb = {} --玩家手牌
end



return ItemSdb
