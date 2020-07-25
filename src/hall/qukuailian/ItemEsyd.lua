--百家乐
local ItemEsyd = class("ItemEsyd", ccui.Layout)


function ItemEsyd:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	luaDump(gameData,"ItemEsyd");
	self:initData(gameData);
	self:initUI();


	

end

function ItemEsyd:create(gameData)
	local layer = ItemEsyd.new(gameData);

	return layer;
end

function ItemEsyd:initUI()

	display.loadSpriteFrames("ershiyidian/card.plist", "ershiyidian/card.png");

	local panelSize = cc.size(910,160*3);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

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
		luaDump(self.m_playerTb[i],"第几个");
		if self.m_playerTb[i]["cbHandCardData"][1] ~= nil and self.m_playerTb[i]["cbHandCardData"][1] > 0 then
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
			for ii=1,2 do
				local card = ccui.ImageView:create(string.format("sdb_0x%02X.png",self.m_playerTb[i]["cbHandCardData"][ii]),ccui.TextureResType.plistType);
				image:addChild(card);
				local width = card:getContentSize().width*0.68;
				local startPos = 160 
				card:setScale(0.68);
				card:setPosition(cc.p(startPos +20+ width *ii,80));
			end
			
		end
		
	end


	self:addChild(panel);

end

function ItemEsyd:initData(gameData)
	self.m_gameData = gameData;

	self.m_playerTb = self:adjustData(self.m_gameData["itemlist"]);

	luaDump(self.m_playerTb,"self.m_playerTb");

	-- self.m_cardZhuangTb = self.m_gameData["m_cbTableCardArray"][1]; --庄牌
	-- self.m_cardXianTb = self.m_gameData["m_cbTableCardArray"][2]; --闲牌
end

--处理数据
function ItemEsyd:adjustData(itemlist)
	local data = {};
	--先把有人的插入
	for k,v in pairs(itemlist) do
		if v.cbHandCardData[1] and v.cbHandCardData[1] >0 then
			table.insert(data,v);
		end
	end
	--再把没人的插入
	for k,v in pairs(itemlist) do
		if v.cbHandCardData[1] == 0 then
			table.insert(data,v);
		end

		if data[#data].cbHandCardData[1] == 0 then
			data[#data].nickName = "";
		end
	end

	-- for k,v in pairs(data) do
	-- 	for i=#v.cbHandCardData,1,-1 do
	-- 		if v.cbHandCardData[i] == 0 then
	-- 			table.remove(v.cbHandCardData[1],i);
	-- 		end
	-- 	end
	-- end

	return data;
end



return ItemEsyd