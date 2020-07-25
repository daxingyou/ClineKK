--扫雷红包
local ItemSlhb = class("ItemSlhb", ccui.Layout)


function ItemSlhb:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemSlhb:create(gameData)
	local layer = ItemSlhb.new(gameData);

	return layer;
end

function ItemSlhb:initUI()

	-- display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	--910,95*5+5*4
	local panelSize = cc.size(910,495+95);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);



	--庄家
	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao8.png",ccui.TextureResType.localType);
	panel:addChild(imageBack);
	local size8 = imageBack:getContentSize();
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size8.height*0.5));
	
	--
	local imgBanker = ccui.ImageView:create("qukuailian/image2/qklian_zhuangjia.png",ccui.TextureResType.localType);
	imgBanker:setPosition(cc.p(54,68));
	imageBack:addChild(imgBanker);

	--雷号
	-- local labelBomb = FontConfig.createWithSystemFont("雷号:"..tostring(self.m_gameData["ucMinesIndex"]),24 ,FontConfig.colorWhite,cc.size(180,24),cc.TEXT_ALIGNMENT_LEFT);
	-- labelBomb:setAnchorPoint(cc.p(0,0.5));
 --    labelBomb:setPosition(238,52);
 --    imageBack:addChild(labelBomb);

    local labelBomb = ccui.Text:create("雷号:"..tostring(self.m_gameData["ucMinesIndex"]),"Arial",24);
	labelBomb:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	labelBomb:setAnchorPoint(cc.p(0,0.5));
    labelBomb:setPosition(238,52);
    imageBack:addChild(labelBomb);

    --红包金额
	-- local labelRedbag = FontConfig.createWithSystemFont("红包金额:"..GameMsg.formatCoin(self.m_gameData["llRedBagScore"]),24 ,FontConfig.colorWhite,cc.size(480,24),cc.TEXT_ALIGNMENT_LEFT);
	local textRegbag = ccui.Text:create("红包金额:"..GameMsg.formatCoin(self.m_gameData["llRedBagScore"]),"Arial",24);
	textRegbag:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
	textRegbag:setAnchorPoint(cc.p(0,0.5));
    textRegbag:setPosition(500,52);
    imageBack:addChild(textRegbag);



	for i=1,10 do
		--扫雷红包底图
		local imgBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao5.png",ccui.TextureResType.localType);
		panel:addChild(imgBack);
		local size = imgBack:getContentSize();
		imgBack:setPosition(cc.p(panelSize.width*0.5-20 - size.width*0.5,panelSize.height*0.5));
		
		-- local index = i%2
		-- local col = math.ceil(i/2)
		-- imgBack:setPosition(cc.p(panelSize.width*(0.75-index*0.5),panelSize.height -size.height*0.5 - size.height*(col-1) -95));

		local index= 2 - math.ceil(i/5)
		local col = math.ceil(i%5)
		if col == 0 then
		 	col = 5;
		end 

		imgBack:setPosition(cc.p(panelSize.width*(0.75-index*0.5),panelSize.height -size.height*0.5 - size.height*(col-1) -95));



		--昵称
		local imgNick = ccui.ImageView:create("qukuailian/image2/qklian_nichen.png",ccui.TextureResType.localType);
		imgBack:addChild(imgNick);
		imgNick:setPosition(cc.p(54,68));

		local nameStr = FormotGameNickName(self.m_gameData.itemlist[i].nickName,6)
		local labelNick = FontConfig.createWithSystemFont(nameStr,20 ,FontConfig.colorWhite,cc.size(180,20),cc.TEXT_ALIGNMENT_LEFT);
		labelNick:setAnchorPoint(cc.p(0,0.5));
	    labelNick:setPosition(0,36);
	    imgBack:addChild(labelNick);

	    --输赢
	    if self.m_gameData.itemlist[i].llRedBagScore ~= 0 or true then
	    	local str = tostring(GameMsg.formatCoin(self.m_gameData.itemlist[i].llRedBagScore));
	    	local color = FontConfig.colorRed;
	    	if self.m_gameData.itemlist[i].llRedBagScore > 0 then
	    		-- str = "+"..str;
	    		color = FontConfig.colorGold;
	    	end
	    	
	    	local labelWin = FontConfig.createWithSystemFont(str,28 ,color,cc.size(240,28),cc.TEXT_ALIGNMENT_CENTER);
			labelWin:setAnchorPoint(cc.p(0.5,0.5));
		    labelWin:setPosition(320,53);
		    if self.m_gameData.itemlist[i].llRedBagScore <= 0 then
		    	labelWin:setVisible(false);
		    end
		    imgBack:addChild(labelWin);
	    end
	    


	end

	self:addChild(panel);

end

function ItemSlhb:initData(gameData)
	self.m_gameData = gameData;
	luaDump(self.m_gameData, "self.m_gameData---123", 5)
end



return ItemSlhb