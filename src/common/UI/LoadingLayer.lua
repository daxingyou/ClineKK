local LoadingLayer = class("LoadingLayer", BaseWindow)
local Tag_LoadingLayer = 9999;

function LoadingLayer:createLoading(ttfConfig, text, image)
	local scene = display.getRunningScene();

	text = text or ""

	if scene then
		local layer = scene:getChildByTag(Tag_LoadingLayer);

		if layer then
			if text == layer.text then
				return layer
			end

			layer.textLabel:setString(text)
			layer.callback = nil
			layer:stopAllActions()
			return layer
		end

		layer = LoadingLayer.new();

		if layer then
			layer:initUI(ttfConfig, text, image)
			layer:setTag(Tag_LoadingLayer)
			scene:addChild(layer,20000)
		end

		return layer
	end

	return nil;
end

function LoadingLayer:ctor()
	self.super.ctor(self, true, true);
end

function LoadingLayer:initUI(ttfConfig, text, image)
	local image = ccui.ImageView:create("common/loading1.png")
	image:setPosition(winSize.width/2,winSize.height/2)
	self:addChild(image)
	image:setName("loadImage")

	if text then
		local label = FontConfig.createLabel(ttfConfig, text, FontConfig.colorWhite);
		label:setPosition(winSize.width/2,winSize.height/2);
		label:setName("enterText")
		self:addChild(label);
		self.textLabel = label
		self.text = text
	end
	-- if image then
	-- 	local image = ccui.ImageView:create(image);
	-- 	image:setPosition(getScreenCenter());
	-- 	self:addChild(image);

	-- 	local rep = cc.RepeatForever:create(cc.RotateBy:create(0.4,90));
	-- 	image:runAction(rep);
	-- end

	-- local animation= cc.Animation:create()
	-- for i=1,14 do
	-- 	animation:addSpriteFrameWithFile("hall/loading"..i..".png")
	-- end
	-- animation:setDelayPerUnit(2/14)
	-- animation:setRestoreOriginalFrame(true)
	-- local action = cc.Animate:create(animation)

	-- local image = cc.Sprite:create("hall/loading1.png")
	-- image:setName("loadImage")
	-- image:setPosition(getScreenCenter())
	-- self:addChild(image)
	-- image:runAction(cc.RepeatForever:create(action))

	self:updateLayerOpacity(0)
end

function LoadingLayer:removeTimer(tm, callback)
	tm = tm or 5;
	self:stopAllActions()

	if callback then
		self.callback = callback
	end

	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(tm),
		cc.CallFunc:create(
			function()
				if HallLayer and HallLayer:getInstance() and not HallLayer:getInstance():isVisible() then
					HallLayer:getInstance():delayCloseLayer()
				end

				if self.callback then
					self.callback();
				end
				self:removeLoading();
			end)
		)
	);
end

function LoadingLayer:removeLoading()
	local scene = display.getRunningScene();
	if not scene then
		return
	end

	local layer = scene:getChildByTag(Tag_LoadingLayer);

	if layer then
		layer:removeFromParent();
	end
end

return LoadingLayer;
