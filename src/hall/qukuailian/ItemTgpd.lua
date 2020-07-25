--糖果派对
local ItemShz = class("ItemShz", ccui.Layout)
SWEET_TYPE = {
    INVALID = 0, --无效
    ORANGE = 1, --橙色糖果   
    GREEN = 2,  --绿色糖果
    RED = 3, --红色糖果    
    PURPLE = 4,  --紫色糖果
    YELLOW = 5,  --黄色糖果
    PASSSWEET = 6,  --过关糖果
    FREESWEET = 7,  --免费次数糖果
    WINNINGSSWEET = 8,  --彩金糖果
};
local SWEET_PNG_NAME = {
    [SWEET_TYPE.ORANGE] = "SweetSprite_orange",
    [SWEET_TYPE.RED] = "SweetSprite_red",
    [SWEET_TYPE.YELLOW] = "SweetSprite_yellow",
    [SWEET_TYPE.GREEN] = "SweetSprite_green",
    [SWEET_TYPE.PURPLE] = "SweetSprite_purple",
    [SWEET_TYPE.PASSSWEET] = "SweetSprite_passsweet",
    [SWEET_TYPE.FREESWEET] = "SweetSprite_freesweet",
    [SWEET_TYPE.WINNINGSSWEET] = "SweetSprite_winningssweet",
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
    local SweetTypeTable = {}
    local SweetNumTable = {}
    local level = 1;
    for k,v in pairs(self.m_ResultTable) do
        if k == 2 then
            level = v;
        end
        if k>2 then
            if k%2 == 1 and v ~= 0 then
                table.insert(SweetTypeTable,v)
            elseif k%2 == 0 and v ~= 0 then
                table.insert(SweetNumTable,v)
            end
        end
    end
    luaDump(SweetTypeTable,"SweetTypeTable");
    luaDump(SweetNumTable,"SweetNumTable");
	local nSinglewidth = 180   
    for i = 1, #SweetTypeTable do
        local singleData = {};
         --糖果显示序号
        if i>1 then
            nSinglewidth = nSinglewidth + 120;
        end
        --判断是否是配置存在的糖果
        if SWEET_PNG_NAME[SweetTypeTable[i]] then
            if SweetTypeTable[i] == 6 or SweetTypeTable[i] == 1 or SweetTypeTable[i] == 2
                or SweetTypeTable[i] == 3 or SweetTypeTable[i] == 4 or SweetTypeTable[i] == 5 then
                strName = SWEET_PNG_NAME[SweetTypeTable[i]] .. "_" .. tostring(level) .. ".png";
            elseif SweetTypeTable[i] == 0 then
                return;
            else
                strName = SWEET_PNG_NAME[SweetTypeTable[i]] .. ".png";
            end
            local fruitSprite = cc.Sprite:createWithSpriteFrameName(strName);
            local nSingleHeight = fruitSprite:getContentSize().height;
            fruitSprite:setScaleX(0.6);
            fruitSprite:setScaleY(0.7);
            fruitSprite:setAnchorPoint(cc.p(1,0));
            fruitSprite:setPosition(cc.p(((i-1)%2)*250+130,330-math.ceil(i/2)*nSingleHeight));
            imageBack:addChild(fruitSprite);
            local SweetNum = FontConfig.createWithCharMap(":"..SweetNumTable[i],"sweetparty/number_res/sweetparty_zitiaoda.png",30,43,"+")
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