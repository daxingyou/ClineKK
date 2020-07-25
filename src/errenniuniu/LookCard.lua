--搓牌界面
local LookCard = class("LookCard", BaseWindow)
local Poker = require("errenniuniu.Poker")

function LookCard:create(cardArray,tableLayer)
	return LookCard.new(cardArray,tableLayer);
end

function LookCard:ctor(cardArray,tableLayer)
	self.super.ctor(self, 0, true,false);
	self:setName("LookCard");
	self.tableLayer = tableLayer
	self.data = cardArray;--牌数据
	self.cardNode = {};--牌节点数组
	self.posNode = nil; --选择的牌
	self.posPoint = cc.p(0,0); -- 记录选中牌的坐标
	self.chooseEnd = false; -- 选择结束
	self.Scale = 1.0; -- 扑克牌的放大比例

	self.beganPos = nil; --初始点
	self.movePos = nil; --移动点
	self.isEnd = false; --动画是否已经播放过

	
	self:initUI();
end

function LookCard:onEnter()
	self.super.onEnter(self);
	--self:setLayerTouchEnabled(true, false)
end

function LookCard:getCardTextureFileName(pokerValue)

	local value = string.format("errenniuniu/cards/ernncp_0x%02X", pokerValue);

	return value..".png";
end

function LookCard:initUI()
	local size = cc.Director:getInstance():getWinSize();
	--display.loadSpriteFrames("errenniuniu/cardAni.plist", "errenniuniu/cardAni.png");
	for k,v in pairs(self.data) do
		local card = Poker.new(self:getCardTextureFileName(v),v,1);
		self:addChild(card);
		card:setScale(self.Scale);
		card:setAnchorPoint(cc.p(0.5,0.5));
		card:setLocalZOrder(k);
		card:setRotation(k-5);
		card:setPosition(cc.p(size.width*0.5-card:getContentSize().width*0*self.Scale,size.height*0.5-card:getContentSize().height*0*self.Scale));
		table.insert(self.cardNode,card);
	end
		
end

--触摸系列事件处理
function LookCard:onTouchBegan(touch, event)
	--luaPrint("LookCard BaseLayer:touch began")
	if self.chooseEnd == true then
		return true;
	end
	local pos = cc.p(touch.x,touch.y);
	self.beganPos = pos; --初始点
	--luaDump(pos,"pos");
	for k = 5,2,-1 do
		local carsPos = cc.p(self.cardNode[k]:getPositionX(),self.cardNode[k]:getPositionY());
		--luaDump(carsPos,"carsPos");
		local size = self.cardNode[k]:getContentSize();
		--luaPrint("为啥",pos.x,pos.y,carsPos.x,carsPos.y,size.width,size.height);
		--luaPrint("结果",pos.x >= (carsPos.x-size.width*0.5),pos.x<=(carsPos.x+size.width*0.5),pos.y >= (carsPos.y),pos.y<=(carsPos.y+size.height));
		if pos.x >= (carsPos.x-size.width*0.5*self.Scale) and pos.x<=(carsPos.x+size.width*0.5*self.Scale) and pos.y >= (carsPos.y-size.height*self.Scale*0.5) and pos.y<=(carsPos.y+size.height*self.Scale*0.5) then
			self.posNode = self.cardNode[k];
			self.posPoint = cc.p(self.cardNode[k]:getPositionX(),self.cardNode[k]:getPositionY());
			break;
		end
	end

	return true;
end

function LookCard:onTouchMoved(touch, event)
	--luaPrint("LookCard BaseLayer:touch move",touch.x,touch.y)
	if self.chooseEnd == true then
		return ;
	end
	local pos = cc.p(touch.x,touch.y);
	self.movePos = pos;
	if self.posNode then 
		local disX = self.movePos.x - self.beganPos.x;
		local disY = self.movePos.y - self.beganPos.y;
		self.posNode:setPosition(cc.p(self.posPoint.x + disX,self.posPoint.y + disY));
	end
end

function LookCard:onTouchEnded(touch, event)
	--luaPrint("LookCard BaseLayer:touch end")
	if self.chooseEnd == true then
		return ;
	end
	if self.posNode == self.cardNode[2] then
		self.chooseEnd = true;
		self:showAnimation();
	end
	self.posNode = nil;

end

function LookCard:onTouchCancelled(touch, event)
	-- luaPrint("BaseLayer:touch cancel")
end

function LookCard:showAnimation()
	self.chooseEnd = true;
	if self.isEnd == false then
		self.isEnd = true;
		local size = cc.Director:getInstance():getWinSize();
		local time = 0.5;
		for k,v in pairs(self.cardNode) do
			v:setAnchorPoint(cc.p(0.5,0));
			--v:setPosition(cc.p(size.width*0.5,size.height*0.5-v:getContentSize().height*0.5*self.Scale));
			v:setPositionY(v:getPositionY()-v:getContentSize().height*0.5*self.Scale);
			local moveto = cc.MoveTo:create(time,cc.p(size.width*0.5 + 5*(k-3),size.height*0.5-v:getContentSize().height*0.5*self.Scale));
			local action = cc.RotateTo:create(time,10*(k-3));
			v:runAction(cc.Spawn:create(moveto,action));
			if k == #self.cardNode then
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
					self.tableLayer:showMyCard(self.data);
				end)));
			end
		end
		self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ()
			self.tableLayer:removeLookCardLayer();
		end)));
	end
end



return LookCard;