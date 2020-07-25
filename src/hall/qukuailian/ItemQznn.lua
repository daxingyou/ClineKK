--抢庄牛牛
local ItemQznn = class("ItemQznn", ccui.Layout)


function ItemQznn:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemQznn:create(gameData)
	local layer = ItemQznn.new(gameData);

	return layer;
end

function ItemQznn:initUI()

	local panelSize = cc.size(910,469);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	
	display.loadSpriteFrames("qiangzhuangniuniu/card.plist","qiangzhuangniuniu/card.png");

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
			for ii=1,5 do
				local card = ccui.ImageView:create(string.format("qznn_0x%02X.png",self.m_playerTb[i]["cbHandCardData"][ii]),ccui.TextureResType.plistType);
				image:addChild(card);
				local width = card:getContentSize().width*0.65;
				local startPos = 250 - didth*1 - width*0.5;
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

function ItemQznn:initData(gameData)
	self.m_gameData = gameData;
	--self.m_panelList = {} --玩家牌面板
	--self.Panel_Common = nil; --公共牌面板


	--self.m_cardPlayerTb = {} --玩家手牌

	self.m_playerTb = self:adjustData(self.m_gameData["itemlist"]);

	luaDump(self.m_playerTb,"self.m_playerTb");
end

--处理数据
function ItemQznn:adjustData(itemlist)
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
	-- 			table.remove(v.cbHandCardData,i);
	-- 		end
	-- 	end
	-- end

	return data;
end



return ItemQznn