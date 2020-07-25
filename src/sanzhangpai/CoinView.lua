local CoinView = class("CoinView", function() return display.newLayer() end) 
local Common   = require("sanzhangpai.Common");

CoinView.MAX_COIN = 100
CoinView.MID_COIN = 50
CoinView.SMALL_COIN = 20
CoinView.LITTLE_COIN = 10

CoinView.ante = 0
CoinView.rect = cc.rect(0,0,100,100)

-- local IMG_BASE_BET =  "Games/Flower/Image/img_chouma1@3x.png" --黑色
-- local IMG_CALL_BET =  "Games/Flower/Image/img_chouma2@3x.png" --黑色 
-- local IMG_COIN_LITTLE = "Games/Flower/Image/img_chouma3@3x.png" --黑色 
-- local IMG_COIN_SMALL = "Games/Flower/Image/img_chouma4@3x.png" --黑色 
-- local IMG_COIN_MID = "Games/Flower/Image/img_chouma5@3x.png" --黑色 
-- local IMG_COIN_MAX = "Games/Flower/Image/img_chouma6@3x.png" --黑色 

-- local IMG_COIN_LITTLE = "Games/Flower/Image/img_chouma1@3x.png" --黑色
-- local IMG_COIN_SMALL = "Games/Flower/Image/img_chouma1@3x.png" --蓝色
-- local IMG_COIN_MID = "Games/Flower/Image/img_chouma1@3x.png" --紫色
-- local IMG_COIN_MAX = "Games/Flower/Image/img_chouma1@3x.png" --红色

CoinView.bets = {}

function CoinView:ctor()
	-- self.img_coins = {}
	-- for i=1,10 do
	-- 	local index = i
	-- 	-- if i < 10 then
	-- 	-- 	index = "0"..i
	-- 	-- end


	-- 	-- self.img_coins[i] = "Games/Flower/Image/chouma"..index..".png"

	-- 	self.img_coins[i] = "Games/Flower/Image/chip_img_"..index..".png"
	-- end
	self.rases = {}
	self.level_rases = {}
end


function CoinView:setChipImage(img)
	self.Image_chip = img;
	-- self:addChild(self.Image_chip);
	-- self.Image_chip:setVisible(false);
end
function CoinView:setLevelRase(_rases)
	self.level_rases = _rases
	luaDump(self.level_rases, "self.level_rases ", 3)
end


function CoinView:setRect(_rect)
	self.rect = _rect
	-- luaDump(self.rect, "self.rect", 6)
end



function CoinView:betMoveCoin(_num,_sourcePos)

	local dt = 0.45
	
	local effectState = getEffectIsPlay();
	if effectState then
		playEffect("sanzhangpai/sound/jetton-single.mp3", false);
	end


	local img_path = Common.CHIP_IMG[10]

	if self.level_rases[_num] then
		local index = self.level_rases[_num]
		img_path = Common.CHIP_IMG[index]
	
	end


	local img_coin = self.Image_chip:clone();
	img_coin:loadTexture(img_path,UI_TEX_TYPE_PLIST);
	local children = img_coin:getChildren();
	for i,v in ipairs(children) do
		luaPrint("v_childName:",v:getName());
	end

	local text_num = img_coin:getChildByName("Text_chip");
    text_num:setString(Common.getCoinStr(_num));
    img_coin:setVisible(true);

	-- img_coin:setScale(0.6)
	local rotation = self:getRandom(-20, 80)
	img_coin:setRotation(rotation)

	img_coin:setScale(0.2)

	local scaleTo = cc.ScaleTo:create(dt,0.5)
	local moveTo = cc.MoveTo:create(dt, self:getRandomPos())
	local spawnOut = cc.Spawn:create(scaleTo,moveTo)
	local easeOut = cc.EaseSineOut:create(spawnOut)

	img_coin:setPosition(_sourcePos)
	self:addChild(img_coin)
	img_coin:runAction(easeOut)
	return dt
end

function CoinView:betCoin(_num)
	
	local img_path = Common.CHIP_IMG[10]

	if self.level_rases[_num] then
		local index = self.level_rases[_num]
		img_path = Common.CHIP_IMG[index]
	end

	local img_coin = self.Image_chip:clone();
	img_coin:loadTexture(img_path,UI_TEX_TYPE_PLIST);
	local text_num = img_coin:getChildByName("Text_chip");
    text_num:setString(Common.getCoinStr(_num));
    img_coin:setVisible(true);

	img_coin:setScale(0.5)
	local rotation = self:getRandom(-20, 40)
	img_coin:setRotation(rotation)
	local pos = self:getRandomPos()
	img_coin:setPosition(pos)
	self:addChild(img_coin)

end



function CoinView:coinMoveToWinner(_pos)
	local _children = self:getChildren()
	local dt = 0
	for k,v in pairs(_children) do
		local second = math.random(0,1)
		local second = k%5;
		local move = cc.MoveTo:create(0.3+second*0.05, _pos)
	
		-- local actionCallback = cc.CallFunc:create(function ()
		-- 	 v:removeFromParent()
		-- end)

		-- if dt < second then
		-- 	dt = second + 0.01
		-- end

		v:runAction(cc.Sequence:create(move,cc.DelayTime:create(0.05),cc.RemoveSelf:create()))
	end

	return dt
end

function CoinView:getRandomPos()
	-- luaDump(self.rect, "self.rect", 3)
	local xx = self:getRandom(self.rect.x, self.rect.width)
	local yy = self:getRandom(self.rect.y, self.rect.height)
	return cc.p(xx,yy)
end

function CoinView:getRandom(_start,_length)
	local ranNum = math.random(1,9999)
	-- luaPrint("_start,_length",_start,_length)
	return _start + ranNum%_length
end


function CoinView:removeAllCoin()
	self:removeAllChildren()
end



return CoinView