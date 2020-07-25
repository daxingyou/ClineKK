--咪牌界面

--扑克牌牌墙
local MiCards = class("MiCards", BaseWindow)

function MiCards:ctor(tableLayer)
	self.seatNo = -1;
	self.vSeatNo = -1;--逻辑位置
	
	self:setName("MiCards");
	self.tableLayer = tableLayer;
	self:setAnchorPoint(0,0);
	
	self:initData();

	self:initUI();
end

function MiCards:initData()

	self.handCard = {};--手牌
	self.handCardNode = {};--手牌节点对象
	self.isMove = false;
	self.mipai = false;
	self.tableLayer.micard = false;
	self.hand = nil;
end

function MiCards:clearData()
	self:removeAllChildren();	
	self:initData();
end

function MiCards:initUI()
	local size = cc.Director:getInstance():getWinSize();
	self.size = size;	 
end

function MiCards:createHandPoker(data)
	if self.mipai then
		return;
	end
	self.mipai = true;

	self.handCard = data;
	self.tableLayer.micard = true;

	for k,v in pairs(data) do
		if  v >= 0 then
			local pathvalue = string.format("errenniuniu/cards/ernncp_0x%02X.png", v);
			local pokerNode = ccui.ImageView:create(pathvalue);
			pokerNode:setTag(k)
			pokerNode:setAnchorPoint(0,0);
    		pokerNode:setRotation((k-3)*10)
    		-- pokerNode:setTouchEnabled(true)
    		pokerNode:setPosition(self.size.width/2,self.size.height/2)
			-- pokerNode:addTouchEventListener(function(sender,eventTouchType)  self:touchPokerDeal(sender,eventTouchType); end)
			self:addChild(pokerNode)
			table.insert(self.handCardNode, pokerNode);
		end
	end	
	local pokerNode = ccui.ImageView:create("errenniuniu/cards/ernncp_0x00.png");
	pokerNode:setAnchorPoint(0,0);
	pokerNode:setRotation(20)
	pokerNode:setTouchEnabled(true)
	pokerNode:setPosition(self.size.width/2,self.size.height/2)
	pokerNode:addTouchEventListener(function(sender,eventTouchType)  self:touchPokerDeal(sender,eventTouchType); end)
	self:addChild(pokerNode)
	table.insert(self.handCardNode, pokerNode);

	self.cardSize = self.handCardNode[1]:getContentSize()
	for k,v in pairs(self.handCardNode) do
		v:setPositionY(self.size.height/2-self.cardSize.height/2)
	end
	for k,v in pairs(self.handCardNode) do
		local moveBy = cc.MoveBy:create(0.5,cc.p(-240,275))
		local rotateby = cc.RotateBy:create(0.5,70);
		local spawn = cc.Spawn:create(moveBy,rotateby)
		local func = cc.CallFunc:create(function()
			if k == #self.handCardNode then
				self.startX = self.handCardNode[#self.handCardNode]:getPositionX();
				self.startY = self.handCardNode[#self.handCardNode]:getPositionY();
				self:showHand(true)
			end
		end)
		v:runAction(cc.Sequence:create(spawn,func))
		
	end
	
end

function MiCards:touchPokerDeal(sender,eventTouchType)
	
	if eventTouchType == ccui.TouchEventType.began then
		-- self:showHand(true)
		self.beganPos = sender:getTouchBeganPosition()
		self.pos = cc.p(sender:getPosition())
	elseif eventTouchType == ccui.TouchEventType.moved then
		self.movePos = sender:getTouchMovePosition()
		local x = self.movePos.x-self.beganPos.x;
		local y = self.movePos.y-self.beganPos.y;
		sender:setPosition(self.pos.x+x,self.pos.y+y)

		local xx = sender:getPositionX() - self.startX;
		local yy = sender:getPositionY() - self.startY;
		if math.abs(xx) >= self.cardSize.height*2/3 or math.abs(yy) >= self.cardSize.width*2/3 then
			self:showHand(false)
			self:showAction()
		end
		-- addScrollMessage(xx)
	elseif eventTouchType == ccui.TouchEventType.ended then
		local posx,posy = self.handCardNode[2]:getPosition()
		-- if math.abs(posx-self.size.width/2) >30 or math.abs(posy-self.size.height/2+self.cardSize.height/2) >30 then
		-- 	self:showAction();
		-- end
	end

end

function MiCards:showHand(visable)
	if self.hand then
		self.hand:setVisible(visable); 
	else
		if visable then
			local pokerNode = ccui.ImageView:create("errenniuniu/bg/shou.png");
			pokerNode:setPosition(self.size.width/2-390,142)
			self:addChild(pokerNode,10)
			self.hand = pokerNode;
		end
	end
	
end

function MiCards:showAction()
	if self.isMove then
		return;
	end
	self.isMove = true;
	local card = self.handCardNode[#self.handCardNode];
	card:setTouchEnabled(false)
	local fadeOut = cc.FadeOut:create(0.2);
	card:runAction(cc.Sequence:create(fadeOut,cc.DelayTime:create(1.5),cc.CallFunc:create(function() 
		-- self:clearData();
		self.tableLayer:removeMiCardLayer();
	end)))
	self.tableLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
		self.tableLayer:showMyCard(self.handCard);
	end)));
end

return MiCards;
