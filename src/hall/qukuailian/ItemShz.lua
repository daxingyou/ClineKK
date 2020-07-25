--超级水果机
local ItemShz = class("ItemShz", ccui.Layout)
SHZ_TYPE = {
    SHUIHUZHUAN = 0,--水浒传
    ZHONGYITANG = 1,--忠义堂
    TITIANXINGDAO = 2,--替天行道
    SONG = 3,--宋江
    LIN = 4,--林冲
    LU = 5,--鲁智深
    DAO = 6,--刀
    QIANG = 7,--枪
    FU = 8,--斧
};
local FRUIT_PNG_NAME = {
    [SHZ_TYPE.SHUIHUZHUAN] = "shz_shuihuzhuan.png",
    [SHZ_TYPE.ZHONGYITANG] = "shz_zhongyitang.png",
    [SHZ_TYPE.TITIANXINGDAO] = "shz_titianxingdao.png",
    [SHZ_TYPE.SONG] = "shz_song.png",
    [SHZ_TYPE.LIN] = "shz_lin.png",
    [SHZ_TYPE.LU] = "shz_lu.png",
    [SHZ_TYPE.DAO] = "shz_dao.png",
    [SHZ_TYPE.QIANG] = "shz_qiang.png",
    [SHZ_TYPE.FU] = "shz_fu.png",
};

function ItemShz:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
end

function ItemShz:create(gameData)
	local layer = ItemShz.new(gameData);

	return layer;
end

function ItemShz:initUI()

	--153*4 + 5*3
	local panelSize = cc.size(910,400);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	--底牌背景
	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao9.png",ccui.TextureResType.localType);
	imageBack:setScaleX(1.2);
    panel:addChild(imageBack);
	local size = imageBack:getContentSize();
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size.height*0.5));
	self.Panel_Common = imageBack;
	local nSinglewidth = 180   
    for i = 1, 5 do
        local singleData = {};
         --水果显示序号
        local fruitIndex = 0;
        if i>1 then
            nSinglewidth = nSinglewidth + 120;
        end
        for j = 1, 3 do
            --判断是否是配置存在的水果
            if FRUIT_PNG_NAME[self.m_ResultTable[j][i]] then
                local sFruitName = FRUIT_PNG_NAME[self.m_ResultTable[j][i]];
                local fruitSprite = cc.Sprite:createWithSpriteFrameName(sFruitName);
                local nSingleHeight = fruitSprite:getContentSize().height;
                fruitSprite:setScaleX(0.6);
                fruitSprite:setScaleY(0.7);
                fruitSprite:setTag(fruitIndex+1);
                fruitSprite:setAnchorPoint(cc.p(1,0));
                fruitSprite:setPosition(cc.p(nSinglewidth*0.95,217-fruitIndex*nSingleHeight*0.7));
                imageBack:addChild(fruitSprite);
                fruitIndex = fruitIndex + 1;
            end
        end
    end  

	self:addChild(panel);

end

function ItemShz:initData(gameData)
	self.m_gameData = gameData;
	self.m_panelList = {} --底牌面板
	self.Panel_Common = nil; --公共牌面板
    luaDump(self.m_gameData,"self.m_gameData");
	self.m_ResultTable = self.m_gameData["m_cbResultData"] --底牌
end



return ItemShz