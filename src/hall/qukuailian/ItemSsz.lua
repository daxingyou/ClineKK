--十三张
local ItemSsz = class("ItemSsz", ccui.Layout)
local CardLogic = require("shisanzhang.CardLogic")

function ItemSsz:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemSsz:create(gameData)
	local layer = ItemSsz.new(gameData);

	return layer;
end

function ItemSsz:initUI()
	display.loadSpriteFrames("shisanzhang/cards/cards.plist", "shisanzhang/cards/cards.png");
	--153*3 + 5*2
	local panelSize = cc.size(910,153*QukuailianMsg.PLAY_COUNT+(QukuailianMsg.PLAY_COUNT-1)*5);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	local dataCopy = {};

	for i = 1,QukuailianMsg.PLAY_COUNT do
		dataCopy[i] = {};
		dataCopy[i].nickName = "";
		dataCopy[i].m_cbHandCardData = {};
		for j = 1,13 do
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

	local didth = 5;
	--玩家牌面板
	for i=1,QukuailianMsg.PLAY_COUNT do
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

		if dataCopy[i].m_cbHandCardData[1]~= 0 then
			local labelNick = FontConfig.createWithSystemFont(FormotGameNickName(dataCopy[i].nickName,nickNameLen),20 ,FontConfig.colorWhite,cc.size(180,20),cc.TEXT_ALIGNMENT_LEFT);
			labelNick:setAnchorPoint(cc.p(0,0.5));
		    labelNick:setPosition(0,55);
		    image:addChild(labelNick);
		end

		local cardTb = {}
		
		-- luaDump(dataCopy[i].m_cbHandCardData);

		dataCopy[i].m_cbHandCardData = CardLogic.DataToBBWList(dataCopy[i].m_cbHandCardData);

		-- luaDump(dataCopy[i].m_cbHandCardData);

		for j=1,13 do
			if dataCopy[i].m_cbHandCardData[j] > 0 then
				local card = ccui.ImageView:create(string.format("0x%02X.png", dataCopy[i].m_cbHandCardData[j]),ccui.TextureResType.plistType);
				image:addChild(card);
				card:setScale(0.68);
				card:setPosition(cc.p(256+(j-1)*40,80));
				table.insert(cardTb,card);
			end
		end
		table.insert(self.m_cardPlayerTb,cardTb);
	end


	self:addChild(panel);

end

function ItemSsz:initData(gameData)
	self.m_gameData = gameData;
	self.m_panelList = {} --底牌面板
	self.Panel_Common = nil; --公共牌面板

	self.m_cardPlayerTb = {} --玩家手牌
end



return ItemSsz