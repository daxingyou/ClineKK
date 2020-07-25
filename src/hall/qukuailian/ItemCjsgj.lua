--超级水果机
local ItemCjsgj = class("ItemCjsgj", ccui.Layout)
FRUIT_TYPE = {
    YINGTAO = 0,--樱桃
    PUTAO = 1,--葡萄
    LINGDANG = 2,--铃铛
    PINGGUO = 3,--苹果
    XIGUA = 4,--西瓜
    NINGMENG = 5,--柠檬
    LIZHI = 6,--荔枝
    CHENGZI = 7,--橙子
    SIYECAO = 8,--四叶草
    BAR = 9,--bar
    QIQIQI = 10,--777
};
local FRUIT_PNG_NAME = {
    [FRUIT_TYPE.YINGTAO] = "sf_game_yingtao.png",
    [FRUIT_TYPE.PUTAO] = "sf_game_putao.png",
    [FRUIT_TYPE.LINGDANG] = "sf_game_lingdang.png",
    [FRUIT_TYPE.PINGGUO] = "sf_game_pingguo.png",
    [FRUIT_TYPE.XIGUA] = "sf_game_xigua.png",
    [FRUIT_TYPE.NINGMENG] = "sf_game_ningmeng.png",
    [FRUIT_TYPE.LIZHI] = "sf_game_lizhi.png",
    [FRUIT_TYPE.CHENGZI] = "sf_game_chengzi.png",
    [FRUIT_TYPE.SIYECAO] = "sf_game_xingyuncao.png",
    [FRUIT_TYPE.BAR] = "sf_game_bar.png",
    [FRUIT_TYPE.QIQIQI] = "sf_game_777.png",
};

function ItemCjsgj:ctor(gameData)
	-- self.super.ctor(self,PopType.small)
	-- self.super.ctor();
	self:initData(gameData);
	self:initUI();
	

end

function ItemCjsgj:create(gameData)
	local layer = ItemCjsgj.new(gameData);

	return layer;
end

function ItemCjsgj:initUI()

	--153*4 + 5*3
	local panelSize = cc.size(910,400);
	
	local panel = ccui.Layout:create();
	panel:setContentSize(panelSize);
	panel:setPosition(cc.p(0,0));
	self:setContentSize(panelSize);

	--底牌背景
	local imageBack = ccui.ImageView:create("qukuailian/image2/qklian_tiao9.png",ccui.TextureResType.localType);
	panel:addChild(imageBack);
	local size = imageBack:getContentSize();
	imageBack:setAnchorPoint(0.5,0.5);
	imageBack:setPosition(cc.p(panelSize.width*0.5,panelSize.height-size.height*0.5));
	self.Panel_Common = imageBack;
	local nSinglewidth = 175   
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
                fruitSprite:setTag(fruitIndex+1);
                fruitSprite:setAnchorPoint(cc.p(1,0));
                fruitSprite:setPosition(cc.p(nSinglewidth,200-fruitIndex*nSingleHeight*0.7));
                imageBack:addChild(fruitSprite);
                fruitIndex = fruitIndex + 1;
            end
        end
    end  

	self:addChild(panel);

end

function ItemCjsgj:initData(gameData)
	self.m_gameData = gameData;
	self.m_panelList = {} --底牌面板
	self.Panel_Common = nil; --公共牌面板
    luaDump(self.m_gameData,"self.m_gameData");
	self.m_ResultTable = self.m_gameData["m_cbResultData"] --底牌

end



return ItemCjsgj