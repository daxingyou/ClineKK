local FrozenLayer = class("FrozenLayer", function () return cc.Node:create(); end)
local DataCacheManager = require("jinchanbuyu.game.core.DataCacheManager"):getInstance();

function FrozenLayer:ctor(frozenTime)
	self.frozenTime = frozenTime
	self.frozens = {};

	self:initGui();
	self:palyAciton()
end

function FrozenLayer:resetData(effectType,frozenTime)
	self.frozenTime = frozenTime;

	for k,v in pairs(self.frozens) do
		v:setOpacity(0);
	end
end

function FrozenLayer:initGui()
	local size = cc.Director:getInstance():getWinSize();
	self:setContentSize(size)

	local frozenSp = ccui.ImageView:create("game/frozen.png");
	frozenSp:setPosition(0,0);
	frozenSp:setAnchorPoint(cc.p(0,0));
	self:addChild(frozenSp);
	frozenSp:setOpacity(0)

	table.insert(self.frozens,frozenSp)

	local fs = frozenSp:getContentSize();
	local frozenSp = ccui.ImageView:create("game/frozen.png");
	frozenSp:setPosition(size.width-frozenSp:getContentSize().width,0);
	frozenSp:setAnchorPoint(cc.p(1,0));
	frozenSp:setScaleX(-1)
	self:addChild(frozenSp);
	frozenSp:setOpacity(0)

	table.insert(self.frozens,frozenSp)
	local frozenSp = ccui.ImageView:create("game/frozen.png");
	frozenSp:setPosition(size.width-fs.width,size.height-fs.height);
	frozenSp:setAnchorPoint(cc.p(1,1));
	frozenSp:setScaleX(-1)
	frozenSp:setScaleY(-1)
	self:addChild(frozenSp);
	frozenSp:setOpacity(0)

	table.insert(self.frozens,frozenSp)
	local frozenSp = ccui.ImageView:create("game/frozen.png");
	frozenSp:setPosition(0,size.height-fs.height);
	frozenSp:setAnchorPoint(cc.p(0,1));
	frozenSp:setScaleY(-1);
	self:addChild(frozenSp);
	frozenSp:setOpacity(0)
	table.insert(self.frozens,frozenSp)
end

function FrozenLayer:showFrozenTips(isCard)
	if not self.timeLabel then
		local path = "game/frozenFish.png";
		if isCard ~= nil then
			path = "game/frozenCard.png";
		end
		
		local size = cc.Director:getInstance():getWinSize();
		local image = ccui.ImageView:create(path);
		image:setPosition(size.width/2-50,size.height/2);
		self:addChild(image);

		local label = FontConfig.createWithCharMap(self.frozenTime.."s","game/frozenNum.png",36,52,"0",{{"s",":"}});
		label:setPosition(image:getContentSize().width+50,image:getContentSize().height/2);
		label:setAnchorPoint(cc.p(0.5,0.5));
		label:setTag(self.frozenTime);
		image:addChild(label);
		self.timeLabel = label;
	else
		self.timeLabel:setString(self.frozenTime..":");
		self.timeLabel:stopAllActions();
	end

	local func = function() 
		local tag = self.timeLabel:getTag();
		tag = tag - 1;

		self.timeLabel:setTag(tag);
		self.timeLabel:setString(tag..":");
		if tag == 0 then
			self.timeLabel:stopAllActions();
		end
	end

	schedule(self.timeLabel,func,1);
end

function FrozenLayer:palyAciton()
	for k,v in pairs(self.frozens) do
		v:runAction(cc.Sequence:create(cc.FadeIn:create(1.5)));
	end

	self:runAction(cc.Sequence:create(cc.DelayTime:create(self.frozenTime),cc.CallFunc:create(function() self:closeSelf(); end)))
end	

function FrozenLayer:closeSelf()
	for k,v in pairs(self.frozens) do
		v:runAction(cc.Sequence:create(cc.FadeOut:create(1.5)));
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function() self:nodeDead(); end)))
end

function FrozenLayer:nodeDead()
	DataCacheManager:removeEffect(self);
end

return FrozenLayer;
