--连环夺宝
local ItemShz = class("ItemShz", ccui.Layout)
DIAMOND_TYPE = {
    INVALID = 0, --无效
    ORANGE = 1, --橙色糖果
    RED = 2, --红色糖果
    YELLOW = 3,  --黄色糖果
    GREEN = 4,  --绿色糖果
    PURPLE = 5,  --紫色糖果
    PASSSWEET = 6,  --过关糖果
};
local DIAMOND_PNG_NAME = {
    [DIAMOND_TYPE.ORANGE] = "zuanshiSprite_1",
    [DIAMOND_TYPE.RED] = "zuanshiSprite_2",
    [DIAMOND_TYPE.YELLOW] = "zuanshiSprite_3",
    [DIAMOND_TYPE.GREEN] = "zuanshiSprite_4",
    [DIAMOND_TYPE.PURPLE] = "zuanshiSprite_5",
    [DIAMOND_TYPE.PASSSWEET] = "zuanshiSprite_pass",
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
    local DiamondTypeTable = {}
    local DiamondNumTable = {}
    local level = 1;
    for k,v in pairs(self.m_ResultTable) do
        if k == 2 then
            level = v;
        end
        if k>2 then
            if k%2 == 1 and v ~= 0 then
                table.insert(DiamondTypeTable,v)
            elseif k%2 == 0 and v ~= 0 then
                table.insert(DiamondNumTable,v)
            end
        end
    end
	local nSinglewidth = 180   
    for i = 1, #DiamondTypeTable do
        local singleData = {};
         --宝物显示序号
        if i>1 then
            nSinglewidth = nSinglewidth + 120;
        end
        --判断是否是配置存在的宝物
        if DIAMOND_PNG_NAME[DiamondTypeTable[i]] then
            if DiamondTypeTable[i] == 1 or DiamondTypeTable[i] == 2
                or DiamondTypeTable[i] == 3 or DiamondTypeTable[i] == 4 or DiamondTypeTable[i] == 5 then
                strName = DIAMOND_PNG_NAME[DiamondTypeTable[i]] .. "_" .. tostring(level)  .. "_0.png";
            elseif DiamondTypeTable[i] == 0 then
                return;
            else
                strName = DIAMOND_PNG_NAME[DiamondTypeTable[i]] .. "_0.png";
            end
            local fruitSprite = cc.Sprite:createWithSpriteFrameName(strName);
            local nSingleHeight = fruitSprite:getContentSize().height;
            fruitSprite:setScaleX(0.6);
            fruitSprite:setScaleY(0.7);
            fruitSprite:setAnchorPoint(cc.p(1,0));
            fruitSprite:setPosition(cc.p(((i-1)%2)*250+130,330-math.ceil(i/2)*nSingleHeight));
            imageBack:addChild(fruitSprite);

            local SweetNum = FontConfig.createWithCharMap(":"..DiamondNumTable[i],"lianhuanduobao/number/duobao_zitiaoda.png",30,43,"+")
		    SweetNum:setScale(0.8);
            SweetNum:setPosition(cc.p(((i-1)%2)*260+160,355-math.ceil(i/2)*nSingleHeight))
		    imageBack:addChild(SweetNum)
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