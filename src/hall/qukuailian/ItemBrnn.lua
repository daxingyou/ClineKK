--百人牛牛
local ItemBrnn = class("ItemBrnn", ccui.Layout)


function ItemBrnn:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemBrnn:create(gameData)
	local layer = ItemBrnn.new(gameData);

	return layer;
end

function ItemBrnn:initUI()
	--面板大小
	--153*3 + 5*3
	local panel = ccui.Layout:create();
	local panelSize = cc.size(910,474);
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	display.loadSpriteFrames("bairenniuniu/image/card.plist","bairenniuniu/image/card.png");

	--庄家面板
	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao2.png",ccui.TextureResType.localType);
	panel:addChild(imageBack);
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(453.5,panelSize.height - imageBack:getContentSize().height*0.5));

	local midPoint = cc.p(524,80);
	local startPos = cc.p(524-80*2-10*2,80);
	local cbCardData = self.m_cbTableCardArray[1];
	for i,v in ipairs(cbCardData) do
		local png = string.format("brnn_0x%02X.png",v);
		local card = ccui.ImageView:create(string.format("brnn_0x%02X.png",v),UI_TEX_TYPE_PLIST);
		card:setScale(0.6);
		local cardSize = cc.size(card:getContentSize().width*0.6,card:getContentSize().height*0.6);
		card:setPosition(cc.p(startPos.x+(i-1)*80+(i-1)*10,80));
		imageBack:addChild(card);
	end


	--天地玄黄
	local imgMarkList = {"qklian_tian.png","qklian_di.png","qklian_xuan.png","qklian_huang.png"}
	for i=1,4 do
		local image = ccui.ImageView:create("qukuailian/image2/qklian_tiao7.png",ccui.TextureResType.localType);
		panel:addChild(image);
		local size = image:getContentSize();
		image:setAnchorPoint(0.5,0.5);
		local index = i%2
		local col = math.ceil(i/2)
		image:setPosition(cc.p(panelSize.width*(0.75-index*0.5),panelSize.height - size.height*0.5-5*col - size.height*col));
		
		local cardTb = self.m_cbTableCardArray[i+1];
		if cardTb[1] > 0 then
			--天地玄黄
			local imgNick = ccui.ImageView:create("qukuailian/image2/"..imgMarkList[i],ccui.TextureResType.localType);
			image:addChild(imgNick);
			imgNick:setPosition(cc.p(46,84));
			local startPos = cc.p(254-80.5*2*0.5,80);
			for ii=1,5 do
				local value = cardTb[ii];
				local strPng = string.format("brnn_0x%02X.png",value);
				local card = ccui.ImageView:create(strPng,ccui.TextureResType.plistType);
				image:addChild(card);
				card:setScale(0.6);
				card:setPosition(startPos.x + 80.5*(ii-1)*0.5,startPos.y);
			end
		end
	end

	--牛几得分
	-- local GameLogic = require("bairenniuniu.GameLogic");
	-- local niuScoreTb = {}
	-- local winTb = {}
	-- for i=1,5 do
	-- 	local idx = i;
	-- 	local tb = clone(self.m_cbTableCardArray[idx]);
 --   		local niuScore = GameLogic:GetCardType(self.m_cbTableCardArray[idx], 5);
 --   		table.insert(niuScoreTb,niuScore)
 --   	end
 --   	luaDump(niuScoreTb, "niuScoreTb---abc", 5)
 --   	--和庄家比牌输赢
 --   	for i=2,5 do
	-- 	local result,mult = GameLogic:CompareCard(self.m_cbTableCardArray[1], niuScoreTb[1], self.m_cbTableCardArray[i], niuScoreTb[i])
	-- 	table.insert(winTb,result == 1)
 --    end

 --    luaDump(winTb, "winTb---abc", 5)

	-- --庄家标签
	-- local imageBanker = ccui.ImageView:create("qukuailian/image2/qklian_zhuangjia.png",ccui.TextureResType.localType);
	-- imageBack:addChild(imageBanker);
	-- imageBanker:setAnchorPoint(0.5,0.5);
	-- imageBanker:setPosition(cc.p(78,111));

	-- --天地玄黄 图标
	-- local imgMarkList = {"qklian_tian.png","qklian_di.png","qklian_xuan.png","qklian_huang.png"}
	-- for i=1,4 do
	-- 	local img = ccui.ImageView:create("qukuailian/image2/qklian_tiao4.png",ccui.TextureResType.localType);
	-- 	local imgMark = ccui.ImageView:create("qukuailian/image2/"..imgMarkList[i],ccui.TextureResType.localType);
	-- 	img:addChild(imgMark);
	-- 	imgMark:setPosition(cc.p(48,52));
	-- 	local path = "qukuailian/image2/qklian_cha.png"; --叉图标
	-- 	if winTb[i] then
	-- 		path = "qukuailian/image2/qklian_gou.png"; --勾图标
	-- 	end
	-- 	--结果
	-- 	local imgWin =  ccui.ImageView:create(path,ccui.TextureResType.localType);
	-- 	img:addChild(imgWin);
	-- 	imgWin:setPosition(cc.p(127,50));
	-- 	panel:addChild(img);
	-- 	img:setAnchorPoint(cc.p(0,0.5));
	-- 	img:setPosition(cc.p((i-1)*241,55))
	-- end

	self:addChild(panel);

end

function ItemBrnn:initData(gameData)
	self.m_gameData = gameData;
	-- luaDump(self.m_gameData, "brnn_gamedata", 5)
	self.m_cbTableCardArray = gameData["cbTableCardArray"];



end



return ItemBrnn