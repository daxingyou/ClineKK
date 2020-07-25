--搓牌界面

--扑克牌牌墙
local RubbingCards = class("RubbingCards", BaseWindow)

function RubbingCards:ctor(tableLayer)
	self.seatNo = -1;
	self.vSeatNo = -1;--逻辑位置
	

	self.tableLayer = tableLayer;
	self:setAnchorPoint(0,0);
	
	self:initData();

	self:initUI();
end

function RubbingCards:initData()

	self.handCard = {};--手牌
	self.handCardNode = {};--手牌节点对象
	self.isMove = false;
	self.iscuopai = false;
	self.tableLayer.cuocard = false;
end

function RubbingCards:clearData()
	self:removeAllChildren();	
	self:initData();
end

function RubbingCards:initUI()

	local size = cc.Director:getInstance():getWinSize();
	self.size = size;
end

function RubbingCards:createHandPoker(data)
	if self.iscuopai then
		return;
	end
	self.iscuopai = true;

	self.handCard = data;
	self.tableLayer.cuocard = true;
	
	for k,v in pairs(data) do
		if  v >= 0 then
			-- display.loadSpriteFrames("qiangzhuangniuniu/qznn_cuopai.plist", "qiangzhuangniuniu/qznn_cuopai.png");

			local pathvalue = string.format("qiangzhuangniuniu/cards/qznncp_0x%02X.png", v);
			local pokerNode = ccui.ImageView:create(pathvalue);
			pokerNode:setTag(k)
			pokerNode:setAnchorPoint(0.5,0);
    		-- pokerNode:loadTexture(pathvalue,UI_TEX_TYPE_PLIST);
    		pokerNode:setRotation(k-3)
    		pokerNode:setTouchEnabled(true)
    		pokerNode:setPosition(self.size.width/2,self.size.height/2)
			pokerNode:addTouchEventListener(function(sender,eventTouchType)  self:touchPokerDeal(sender,eventTouchType); end)
			self:addChild(pokerNode)
			table.insert(self.handCardNode, pokerNode);
		end
	end	
	self.cardSize = self.handCardNode[1]:getContentSize()
	for k,v in pairs(self.handCardNode) do
		v:setPositionY(self.size.height/2-self.cardSize.height/2)
	end
end

function RubbingCards:touchPokerDeal(sender,eventTouchType)
	
	if eventTouchType == ccui.TouchEventType.began then
		self.beganPos = sender:getTouchBeganPosition()
		self.pos = cc.p(sender:getPosition())
	elseif eventTouchType == ccui.TouchEventType.moved then
		self.movePos = sender:getTouchMovePosition()
		local x = self.movePos.x-self.beganPos.x;
		local y = self.movePos.y-self.beganPos.y;
		sender:setPosition(self.pos.x+x,self.pos.y+y)
	elseif eventTouchType == ccui.TouchEventType.ended then
		local posx,posy = self.handCardNode[2]:getPosition()
		if math.abs(posx-self.size.width/2) >30 or math.abs(posy-self.size.height/2+self.cardSize.height/2) >30 then
			self:showAction();
		end
	end

end

function RubbingCards:showAction()
	if self.isMove then
		return;
	end
	self.isMove = true;
	for k,v in pairs(self.handCardNode) do
		v:setTouchEnabled(false)
		-- v:setPosition(self.size.width/2+20*(k-3),self.size.height/2)
		-- v:setRotation(20*(k-3))
		local moveto = cc.MoveTo:create(0.2,cc.p(self.size.width/2+5*(k-3),self.size.height/2-self.cardSize.height/2))
		local rotateto = cc.RotateTo:create(0.2,10*(k-3));
		local spawn = cc.Spawn:create(moveto,rotateto)
		v:runAction(cc.Sequence:create(spawn,cc.DelayTime:create(0.5),cc.CallFunc:create(function() 
			self:clearData();
			self.tableLayer:onClickBtnCallBack(self.tableLayer.Button_tanpai)
		end)))

	end
end

return RubbingCards;
