local BankGetLayer = class("BankGetLayer",PopLayer)

function BankGetLayer:create(money)
	return BankGetLayer.new(money)
end

function BankGetLayer:ctor(money)
	self.super.ctor(self,PopType.none)
	self:setName("BankGetLayer");
	self:initUI(money)
end

function BankGetLayer:initUI(money)
	local winSize = cc.Director:getInstance():getWinSize();

	local spine = createSkeletonAnimation("zhuangjiajiesuan","game/gameEffect/zhuangjiajiesuan.json","game/gameEffect/zhuangjiajiesuan.atlas");
	if spine then
		spine:setPosition(cc.p(winSize.width/2,winSize.height/2));
		spine:setAnimation(1,"zhuangjiajiesuan", false);
		spine:setName("spine");
		self:addChild(spine);
	end

	self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
		local str = ccui.ImageView:create("hall/game/bankgetStr.png");
	    str:setPosition(cc.p(winSize.width/2,winSize.height/2-160));
	    self:addChild(str);

	    local path = "bankgetwin";
	    if money < 0 then
	    	path = "bankgetlose"; 
	    end

	    local str = goldConvert(money);
	    if money >= 0 then
	    	str = "+"..str;
	    end

	    local jinbinum = FontConfig.createWithCharMap(str,"game/"..path..".png", 94, 116, '+');
	    jinbinum:setPosition(winSize.width/2-20,winSize.height/2-80);
	    self:addChild(jinbinum);

	end)));

	local closeBtn = ccui.Button:create("common/cha.png","common/cha-on.png")
	closeBtn:setPosition(winSize.width/2+450,winSize.height/2+200)
	self:addChild(closeBtn)
	closeBtn:onTouchClick(function(sender) self:delayCloseLayer() end,1)
end

return BankGetLayer
