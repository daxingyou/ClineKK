local getDropGoods = class( "getDropGoods", function() return display.newSprite(); end )

--获取掉落物品
function getDropGoods:ctor(goodsInfo)
	self.goodsInfo = goodsInfo
	self.moveTime = 1

	self:initGui()
end

function getDropGoods:addLinePathTo(endPos)
	self.endPos = endPos; 

	self:playAction()
end

function getDropGoods:initGui()
	local goodsInfo = GameGoodsInfo:getGoodsInfoByID(self.goodsInfo.goodsID)

	if goodsInfo == nil or goodsInfo.goodsIcon == nil then
		self:setVisible(false)
	else
		if goodsInfo.goodsID == GOODS_HUAFEI then
			-- local count = 31;
			-- local frames = display.newFrames("huafei_%d.png", 1, count);
			-- local activeFrameAnimation = display.newAnimation(frames, 0.1);

			-- local goodsIcon = display.newSprite()
			-- goodsIcon:setSpriteFrame(frames[1]);

			-- -- 自身动画
			-- local animate= cc.Animate:create(activeFrameAnimation);
			-- local aimateAction=cc.Repeat:create(animate,999999);
			-- local aimateSpeed = cc.Speed:create(aimateAction, 1);
			-- goodsIcon:runAction(aimateSpeed);
			-- self:addChild(goodsIcon);
			-- local goodsIcon = ccui.ImageView:create("game/quan.png");
			-- goodsIcon:setPositionY(goodsIcon:getPositionY()+100)
			-- self:addChild(goodsIcon,2);

			-- local str = {{"元",":;"}};

			-- local label = FontConfig.createWithCharMap("+"..self.goodsInfo.goodsCount.."元","game/huafeiNum.png",14,19,"+",str);
			-- label:setPosition(goodsIcon:getContentSize().width/2-15,goodsIcon:getContentSize().height/2+15);
			-- label:setAnchorPoint(0,0.5);
			-- goodsIcon:addChild(label);

			-- self.goodsEffect = goodsIcon;
		else
			local goodsIcon = createSkeletonAnimation("kapai","goods/kapai.json", "goods/kapai.atlas");
			if goodsIcon then
				goodsIcon:setAnimation(goodsInfo.goodsID,goodsInfo.goodsEffect, false);
				self:addChild(goodsIcon,2);

				self.goodsEffect = goodsIcon;
			end
		end
		

		-- local goodsIcon = ccui.ImageView:create(goodsInfo.goodsIcon);
		-- goodsIcon:setVisible(false)
		-- self:addChild(goodsIcon,2);
		-- self.goodsIcon = goodsIcon;
	end
end

function getDropGoods:playAction()
	if self.goodsInfo.goodsID == GOODS_HUAFEI then
		self.moveTime = 1.5
	end

	local speed = 800;
	local dt = cc.pGetLength(self.endPos,cc.p(self:getPosition()))/speed;

	self.paths = {}
	table.insert(self.paths, cc.DelayTime:create(self.moveTime));

	local seq = cc.Sequence:create(cc.MoveTo:create(dt, self.endPos))
	local easeAction = cc.EaseSineIn:create(seq);
	
	table.insert(self.paths, easeAction);

	local sequence = nil--transition.sequence(
	-- 	{
	-- 		cc.Sequence:create(self.paths),
	-- 		cc.DelayTime:create(1),
	-- 		cc.CallFunc:create(function() self:deleteNode();end)
	-- 	}
	-- )

	if self.goodsInfo.goodsID == GOODS_HUAFEI then
		self:setPosition(self.endPos);
		local call = cc.CallFunc:create(function() 
			-- self.goodsEffect:stopAllActions();
			-- self.goodsEffect:setVisible(false);
    		local goodsIcon = ccui.ImageView:create("game/huafei.png");
    		goodsIcon:setPositionY(goodsIcon:getPositionY()+150);
    		goodsIcon:setPositionX(goodsIcon:getPositionX()-100);
			self:addChild(goodsIcon,2);

			local str = {{"元",":;"}};

		    local label = FontConfig.createWithCharMap("+"..self.goodsInfo.goodsCount.."元","game/huafeiNum.png",14,19,"+",str);
		    label:setPosition(goodsIcon:getContentSize().width/2-15,goodsIcon:getContentSize().height/2+15);
		    label:setAnchorPoint(0,0.5);
		    label:setScale(0.8);
		    goodsIcon:addChild(label);

		    self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function() self:deleteNode(); end)));
    	end);
		-- sequence = transition.sequence(
		-- 	{
		-- 		cc.Sequence:create(self.paths),
		-- 		call
		-- 	}
		-- )

		-- local call = cc.CallFunc:create(function() 
		-- 		-- self.goodsEffect:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.8,360)));
		-- 	end)
		-- self.goodsEffect:runAction(cc.Sequence:create(
		-- 	cc.DelayTime:create(self.moveTime),
		-- 	call
		-- 	)) ;

		sequence = cc.Sequence:create(call);
	else
		sequence = transition.sequence(
			{
				cc.Sequence:create(self.paths),
				cc.DelayTime:create(1),
				cc.CallFunc:create(function() self:deleteNode();end)
			}
		)
		self.goodsEffect:runAction(cc.Sequence:create(cc.DelayTime:create(self.moveTime),cc.ScaleTo:create(dt,0)));
	end

	self:runAction(sequence);
end

function getDropGoods:addEffect()
	local particle = cc.ParticleSystemQuad:create("goods/dropGoods/lizi_get_zuanshi.plist")
	if particle then
		particle:setPosition(self:getPosition())
		display.getRunningScene():addChild(particle,1000);

		particle:runAction( cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() particle:removeFromParent(); self:removeFromParent() end)));
	else
		luaPrint("getDropGoods:addEffect()  创建失败  ---------------------")
	end
end

function getDropGoods:deleteNode()
	self:removeFromParent()
	-- self:addEffect()

	-- self:setVisible(false)
end

return getDropGoods;
