local GiftEggsLayer = class("GiftEggsLayer",BaseWindow)

function GiftEggsLayer:create()
	return GiftEggsLayer.new();
end

function GiftEggsLayer:ctor()
	self.super.ctor(self, true, true);

	self:bindEvent();

	self:initUI();
end

function GiftEggsLayer:bindEvent()
	self.bindIds = {}
	self.bindIds[#self.bindIds + 1] = BindTool.bind(GiftEggsInfo, "hitGiftEggsInfo", handler(self, self.receiveHitGiftEggsInfo))--砸金蛋结果
end

function GiftEggsLayer:unBindEvent()	
	for _, bindid in ipairs(self.bindIds) do
		BindTool.unbind(bindid)
	end
end

function GiftEggsLayer:onExit()
	self.super.onExit(self);

	for _, bindid in ipairs(self.bindIds) do
		BindTool.unbind(bindid)
	end
end

function GiftEggsLayer:initUI()
	local size = cc.Director:getInstance():getWinSize();
	local bg = ccui.ImageView:create("game/eggsBg.png");
	bg:setPosition(cc.p(size.width/2,size.height/2));
	self:addChild(bg);

	local size = bg:getContentSize();

	local title = ccui.ImageView:create("game/eggsTitle.png");
	title:setPosition(cc.p(size.width/2-25,size.height*0.85-8));
	bg:addChild(title);

	--创建金蛋
	local count = 6;
	local line = 3;
	local x = 0;
	local y = 0;
	local dis = 75;
	self.eggsSp = {};

	for i=1,count do
		local item = ccui.Widget:create();
		item:setTouchEnabled(true);
		item:setContentSize(cc.size(160,200));
		item:setTag(i);

		if x == 0 then
			x = size.width/2 - item:getContentSize().width - dis;
			y = size.height/2 + item:getContentSize().height/4;
		end

		item:setPosition(cc.p(x,y));
		bg:addChild(item);
		item:onClick(function(sender)
			self:onClickGiftEggs(sender);
		end);

		local skeleton_animation = createSkeletonAnimation("zadan","game/effect/zadan.json", "game/effect/zadan.atlas");
		if skeleton_animation then
			skeleton_animation:setPosition(item:getContentSize().width/2,item:getContentSize().height/2);
			skeleton_animation:setAnimation(1,"zadan-budong", true);
			item:addChild(skeleton_animation);
			table.insert(self.eggsSp,skeleton_animation);
		end

		x = x + item:getContentSize().width + dis;

		if i == line  then
			y = size.height/2 - item:getContentSize().height+10;
			x = size.width/2 - item:getContentSize().width - dis;
		end
	end

	local closeBtn = ccui.Button:create("common/guanbi.png","common/guanbi-on.png")
	closeBtn:setPosition(size.width*0.9,size.height*0.9);
	bg:addChild(closeBtn);
	closeBtn:onClick(function()self:delayCloseLayer();end);

	local skeleton_animation = createSkeletonAnimation("zadanjiemian","game/effect/zadanjiemian.json", "game/effect/zadanjiemian.atlas");
	if skeleton_animation then
		skeleton_animation:setPosition(size.width/2,size.height/2);
		skeleton_animation:setAnimation(1,"zadanjiemian", true);
		bg:addChild(skeleton_animation);
	end
	iphoneXFit(bg,4)
end

function GiftEggsLayer:onClickGiftEggs(sender)
	if self.isEndClick == true then
		return;
	end

	self.isEndClick = true;

	self:playHitGiftEggsEffect(sender);

	GiftEggsInfo:sendHitGiftEggsRequest();
end

--播放金蛋碎了动画
function GiftEggsLayer:playHitGiftEggsEffect(sender)
	self.eggsSp[sender:getTag()]:setAnimation(1,"zadan", false);
end

function GiftEggsLayer:receiveHitGiftEggsInfo(data)
	local data = data._usedata;
	luaDump(data,"砸金蛋结果");

	self:delayCloseLayer(0.5);--0.5s后关闭页面
end

return GiftEggsLayer;
