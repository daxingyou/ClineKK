
--扑克牌牌墙
local PokerListBoard = class("PokerListBoard", function() return cc.Layer:create() end)
local Poker = require("ershiyidian.Poker")
local PokerCommonDefine = require("ershiyidian.PokerCommonDefine");

function PokerListBoard:ctor(vSeatNo, tableLayer)
	luaPrint("PokerListBoard seatNo ------------- "..vSeatNo)
	PokerCommonDefine.adjustmentGame()
	self.seatNo = -1;--逻辑位置
	self.vSeatNo = vSeatNo;--视图位置
	self.tableLayer = tableLayer;
	self:setAnchorPoint(0,0);
	
	self:initData();

	self:initUI();
end

function PokerListBoard:initData()
	self.pokerModule = nil;

	if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then
		self.bIsMyself = true;
	else
		self.bIsMyself = false;
	end

	self.handCard = {};--手牌
	self.handCard1 = {}; -- 分牌手牌1
	self.handCard2 = {}; -- 分牌手牌2
	self.handCardNode = {};--手牌节点对象
	self.handCardNode1 = {};--分牌手牌节点1
	self.handCardNode2 = {};--分牌手牌节点2

	self.selectedCards = {};
	self.separate = false;--是否已经分牌标志
	self.scale = 0.7;--没有分牌的扑克牌大小
	self.scale1 = 0.6;--分牌之后的扑克牌的大小
	self.numX = 11;--一排最大牌张数
	self.stop = false; --未分牌是否停牌
	self.stop1 = false;--分牌后第一滩是否停牌
	self.stop2 = false;--分牌后第二滩是否停牌
	self.kuang = nil;	-- 框
	self.isBank = false; --记录是否是庄家

	self.pos_seat = cc.p(0,0);--玩家扑克牌起始位置(未分牌)
	self.pos_seat_break = cc.p(0,0);--玩家扑克牌起始位置(分牌)
	self.sendCardPos = cc.p(640,500);--发牌位置

	self:adjustGame();

end

--根据人数适配游戏坐标
function PokerListBoard:adjustGame()
	if PLAY_COUNT == 4 then
		if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East then
			self.pos_seat = cc.p(1035,320);
			self.pos_seat_break = cc.p(1050,360);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then
			self.pos_seat = cc.p(640,120);
			self.pos_seat_break = cc.p(440,120);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then
			self.pos_seat = cc.p(150,320);
			self.pos_seat_break = cc.p(200,360);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North then
			self.pos_seat = cc.p(640,550);
			self.pos_seat_break = cc.p(440,550);
		end
	elseif PLAY_COUNT == 5 then
		if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East then
			self.pos_seat = cc.p(1035,320);
			self.pos_seat_break = cc.p(1050,360);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then
			self.pos_seat = cc.p(640,120);
			self.pos_seat_break = cc.p(440,120);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then
			self.pos_seat = cc.p(150,320);
			self.pos_seat_break = cc.p(160,360);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 then
			self.pos_seat = cc.p(180,550);
			self.pos_seat_break = cc.p(200,550);
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
			self.pos_seat = cc.p(960,550);
			self.pos_seat_break = cc.p(960,550);
		end
	end
end

function PokerListBoard:setBanker( isTrue )
	self.isBank = isTrue
end

function PokerListBoard:getBanker( )
	return self.isBank;
end

--庄家的牌 恢复手牌
function PokerListBoard:updateHandCardForBanker(cards)
	if self.isBank == false or #cards ~= 2 or #self.handCardNode ~= 2 then
		luaPrint("属性错误--庄家");
		luaDump(cards);
		luaPrint("updateHandCardForBanker",self.isBank,self.vSeatNo,#self.handCardNode);
		return
	end
	luaPrint("updateHandCardForBanker",self.vSeatNo,#self.handCardNode);
	luaDump(cards,"updateHandCardForBanker");
	--设置手牌值
	self:setHandCard(cards);
	--刷新手牌节点
	for k,v in pairs(cards) do
		if self.handCardNode[k] then
			self.handCardNode[k]:updataCard(self:getCardTextureFileName(cards[k]), cards[k]);
		end
	end
end

--获取牌张数
function PokerListBoard:getCardNum()
	luaPrint("getCardNum",#self.handCardNode);
	local num;
	num = #self.handCardNode;
	return num
end

--获取牌张数
function PokerListBoard:getCardNum1()
	luaPrint("getCardNum1");
	local num;
	num = #self.handCardNode1;
	return num
end
--获取牌张数
function PokerListBoard:getCardNum2()
	luaPrint("getCardNum2");
	local num;
	num = #self.handCardNode2;
	return num
end
function PokerListBoard:setStop(isTrue)
	self.stop = isTrue;
end

function PokerListBoard:getStop()
	return self.stop;
end
function PokerListBoard:setStop1(isTrue)
	self.stop1 = isTrue;
end

function PokerListBoard:getStop1()
	return self.stop1;
end
function PokerListBoard:setStop2(isTrue)
	self.stop2 = isTrue;
end

function PokerListBoard:getStop2()
	return self.stop2;
end

function PokerListBoard:setStop_num(isTrue)
	if isTrue then
		if self.stop1 == false then
			self.stop1 = isTrue;
		else
			if self.stop2 == false then
				self.stop2 = isTrue
			else
				luaPrint("设置手牌属性出错",self.stop1,self.stop2,isTrue);
			end
		end
	end
end

--设置手牌数据
function PokerListBoard:setHandCard(cards)
	self.handCard = {};
	for k,v in pairs(cards) do
		if v > 0 then
			table.insert(self.handCard,v);
		end
	end
end

--设置手牌数据1
function PokerListBoard:setHandCard1(cards)
	self.handCard1 = {};
	for k,v in pairs(cards) do
		if v > 0 then
			table.insert(self.handCard1,v);
		end
	end
end

--设置手牌数据2
function PokerListBoard:setHandCard2(cards)
	self.handCard2 = {};
	for k,v in pairs(cards) do
		if v > 0 then
			table.insert(self.handCard2,v);
		end
	end
end

--获取手牌数据
function PokerListBoard:getHandCard()
	return self.handCard;
end

--获取手牌数据
function PokerListBoard:getHandCard1()
	return self.handCard1;
end

--获取手牌数据
function PokerListBoard:getHandCard2()
	return self.handCard2;
end

--获取手牌数据
function PokerListBoard:getHandCardForEnd()
	if self.separate == false then
		return self.handCard;
	else
		if self.stop1 and self.stop2 == false then
			return self.handCard1;
		elseif self.stop2 and self.stop1 then
			return self.handCard2;
		else
			luaPrint("算分获取手牌错误");
		end
	end
end

function PokerListBoard:setSeparate(isTrue)
	self.separate = isTrue;
end

function PokerListBoard:getSeparate()
	return self.separate;
end

function PokerListBoard:setRunMode(mode)
	self.scaleValue = 0.7;
	pokerDis = 30
end

function PokerListBoard:clearData()
	self:removeAllChildren();	
	self:initData();
end

--去除手牌节点和手牌数据
function PokerListBoard:removePokerNode()
	for k,v in pairs(self.handCardNode) do
		v:removeFromParent();
	end
	self.handCardNode = {};
	self.handCard = {};
end

function PokerListBoard:initUI()

	local size = cc.Director:getInstance():getWinSize();
end

function PokerListBoard:setPokerModule(pokerModule)
	self.pokerModule = pokerModule;
end

function PokerListBoard:setLogicSeatNo(lSeatNo)
	self.seatNo = lSeatNo;
end

function PokerListBoard:getLogicCard(value)
	local MASK_VALUE =	0x0F								--//数值掩码
	local cbCardValue= bit:_and(value, MASK_VALUE)

	-- //转换数值
	local value = 0;

	-- //王牌扑克
	if cbCardValue>=0x0E then
		value = cbCardValue+2;
	else
		if cbCardValue<=2 then
			value = cbCardValue+13;
		else
			value = cbCardValue;
		end
	end
	
	return value;
end

function PokerListBoard:getCardTextureFileName(pokerValue)
	if pokerValue == 255 then
		pokerValue = 0;
	end
	local value = string.format("sdb_0x%02X", pokerValue);

	return value..".png";
end

function PokerListBoard:GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end

--适配调整扑克牌位置
function PokerListBoard:adjustmentPokerPos()
	
end

--添加玩家操作框框
function PokerListBoard:updateCaoZuoKuang(isTrue)
	luaPrint("updateCaoZuoKuang");
	local tipBg = "ershiyidian/bg/xuanzhongkuang.png"
	if isTrue then
		if self.separate then -- 分牌才显示框
			    local tipSp = cc.Sprite:create(tipBg);
			    local fullRect = cc.rect(0,0,tipSp:getContentSize().width,tipSp:getContentSize().height);
			    local insetRect = cc.rect(89/2,117/2,1,1);

			    if self.separate == false and #self.handCardNode>0 then
			    	luaDump(self.handCardNode);
			    	local width = (#self.handCardNode-1)* 60*self.scale1 + self.handCardNode[1]:getBoundingBox().width +20 ;
			    	local height = self.handCardNode[1]:getBoundingBox().height +20;
			    	if self.kuang == nil then
				    	self.kuang = cc.Scale9Sprite:create(tipBg,fullRect,insetRect);
				    	self:addChild(self.kuang,100);
				    end
				    self.kuang:setContentSize(cc.size(width,height ));
				    self.kuang:setAnchorPoint(0,0);
				    	
				    self.kuang:setPosition(self.handCardNode[1]:getPositionX()-9,self.handCardNode[1]:getPositionY()-9);

				else-- 分过牌
					luaPrint("updateCaoZuoKuang___________",self.stop1,self.stop2,#self.handCardNode1);
					if self.stop1 == false and self.stop2 == false and #self.handCardNode1>0 then
						luaPrint("updateCaoZuoKuang111111111111111");
						local width = (#self.handCardNode1-1)* 50*self.scale1 + self.handCardNode1[1]:getBoundingBox().width+20 ;
				    	local height = self.handCardNode1[1]:getBoundingBox().height+20;
				    	if self.kuang == nil then
					    	self.kuang = cc.Scale9Sprite:create(tipBg,fullRect,insetRect);
					    	self:addChild(self.kuang,100);	
					    end
					    self.kuang:setContentSize(cc.size(width,height ));
					    self.kuang:setAnchorPoint(0,0);
					    
					    self.kuang:setPosition(self.handCardNode1[1]:getPositionX()-9,self.handCardNode1[1]:getPositionY()-9);
					elseif self.stop1 == true and self.stop2 == false and #self.handCardNode2>0 then
						luaPrint("updateCaoZuoKuang22222222222222");
						local width = (#self.handCardNode2-1)* 50*self.scale1 + self.handCardNode2[1]:getBoundingBox().width+20 ;
				    	local height = self.handCardNode2[1]:getBoundingBox().height+20;
				    	if self.kuang == nil then
					    	self.kuang = cc.Scale9Sprite:create(tipBg,fullRect,insetRect);
					    	self:addChild(self.kuang,100);
					    end
					    self.kuang:setContentSize(cc.size(width,height ));
					    self.kuang:setAnchorPoint(0,0);
					    	
					    self.kuang:setPosition(self.handCardNode2[1]:getPositionX()-9,self.handCardNode2[1]:getPositionY()-9);
					end

				end
		end
	else
		if self.kuang then
			self.kuang:setVisible(false);
		end
	end
end

--创建手牌
function PokerListBoard:createHandNode(cbDate)
	luaDump(cbDate);
	self:setHandCard(cbDate);--初始手牌数据
	for k,v in pairs(cbDate) do
		if v>0 then
			local poker = Poker.new(self:getCardTextureFileName(v), v);
			poker:setScale(self.scale);
			poker:setVisible(false);
			poker:setPosition(950,665);
			self:addChild(poker);
			table.insert(self.handCardNode,poker);
			self:adjustPos();
		end
	end
	
	self:hideAllCard(false);
	self:sendCardAni(cbDate);

	self:updateCaoZuoKuang();
	
end

--发牌动画
function PokerListBoard:sendCardAni(cbDate)
	for k,v in pairs(cbDate) do
		if v>0 then
			local poker = Poker.new(self:getCardTextureFileName(v), v);
			poker:setScale(0.2);
			poker:setPosition(self.sendCardPos);
			self:addChild(poker);
			poker:setVisible(true);
			poker:setLocalZOrder(k);

			local pos = cc.p(0,0);
			pos = self:getMovePos(k);
			local n_time = 0.2;
			local scale = self.scale;
			if self.separate then
				scale = self.scale1
			end
			--动作
			local move = cc.MoveTo:create(n_time,pos);
			local scaleTo = cc.ScaleTo:create(n_time,scale,scale);
			local spawn = cc.Spawn:create(move, scaleTo);  
			poker:runAction(cc.Sequence:create(cc.DelayTime:create(n_time*(k-1)),spawn,cc.DelayTime:create(n_time),cc.CallFunc:create(function ( ... )
				poker:setVisible(false);
				audio.playSound("ershiyidian/sound/send_card.wav",false);
				poker:removeFromParent();
				self:showCardIndex(k);
				--显示得分
				--self.tableLayer:showGameScore(self.tableLayer.tableLogic:viewToLogicSeatNo(self.vSeatNo));
			end)));
		end
	end
end


--获取当前牌所需要移动到的位置
function PokerListBoard:getMovePos(index)
	local pos = cc.p(0,0)
	if index <= 0 or self.handCardNode[index] == nil then
		luaPrint("获取牌位置出错");
		return pos;
	end
	if self.separate == false then--没有分牌
		pos = cc.p(self.handCardNode[index]:getPositionX(),self.handCardNode[index]:getPositionY());
	else--分过牌
		if self.stop1 == false then
			pos = cc.p(self.handCardNode1[index]:getPositionX(),self.handCardNode1[index]:getPositionY());	
		elseif self.stop2 == false then
			pos = cc.p(self.handCardNode2[index]:getPositionX(),self.handCardNode2[index]:getPositionY());	
		end
	end
	luaPrint("getMovePos",pos.x,pos.y);
	return pos;
end
--影藏所有牌
function PokerListBoard:hideAllCard(isTrue)
	if self.separate == false then
		for k,v in pairs(self.handCardNode) do
			v:setVisible(isTrue);
		end
	else
		for k,v in pairs(self.handCardNode1) do
			v:setVisible(isTrue);
		end

		for k,v in pairs(self.handCardNode2) do
			v:setVisible(isTrue);
		end 
	end
end

--显示某一张牌
function PokerListBoard:showCardIndex(index)
	if index <= 0 or self.handCardNode[index] == nil then
		luaPrint("显示牌出错");
		return;
	end
	if self.separate == false then--未分牌
		self.handCardNode[index]:setVisible(true);
	else--分牌
		if self.stop1 == false then
			self.handCardNode1[index]:setVisible(true);
		elseif self.stop2 == false then
			self.handCardNode2[index]:setVisible(true);
		end
	end
end

--恢复手牌(未分牌)
function PokerListBoard:updateHandCard(cbDate)
	luaPrint("updateHandCard",self.vSeatNo);
	luaDump(cbDate,"updateHandCard");
	self:removeAllChildren();
	self:setHandCard(cbDate);--初始手牌数据
	for k,v in pairs(cbDate) do
		if v>0 then
			local poker = Poker.new(self:getCardTextureFileName(v), v);
			poker:setScale(self.scale);
			self:addChild(poker);
			table.insert(self.handCardNode,poker);
			self:adjustPos();
		end
	end
end

--恢复手牌(分牌)
function PokerListBoard:updateHandBreakCard(cards1,cards2)
	luaPrint("updateHandBreakCard");
	self:removeAllChildren();
	self:setHandCard1(cards1);--初始手牌数据1
	self:setHandCard2(cards2);--初始手牌数据2
	self:setSeparate(true);

	for k,v in pairs(self.handCard1) do
		local poker = Poker.new(self:getCardTextureFileName(v), v);
		poker:setScale(self.scale1);
		self:addChild(poker);
		table.insert(self.handCardNode1,poker);
	end

	for k,v in pairs(self.handCard2) do
		local poker = Poker.new(self:getCardTextureFileName(v), v);
		poker:setScale(self.scale1);
		self:addChild(poker);
		table.insert(self.handCardNode2,poker);
	end

	--调整位置
	self:adjustPosSeparate();

end

--增加扑克
function PokerListBoard:addCardNode(card)
	if card>0 then
		table.insert(self.handCard,card);--增加牌数据
		local poker = Poker.new(self:getCardTextureFileName(card), card);
		poker:setScale(self.scale);
		self:addChild(poker);
		table.insert(self.handCardNode,poker);
		self:adjustPos();
	end
	--影藏最后一张牌
	self:hideEndCard(false);
	--要牌动画
	self:getCardAni(card);

end

--要牌动画
function PokerListBoard:getCardAni(card)
	luaPrint("getCardAni",card);
	--影藏最后一张牌
	--self:hideEndCard(false);

	local poker = Poker.new(self:getCardTextureFileName(card), card);
	poker:setScale(0.2);
	poker:setPosition(self.sendCardPos);
	self:addChild(poker);
	poker:setVisible(true);
	poker:setLocalZOrder(100);

	local pos = cc.p(0,0);
	pos = self:getEndCardPos();--获取最后一张牌的位置
	local n_time = 0.2;
	local scale = self.scale;
	if self.separate then
		scale = self.scale1;
	end
	--动作
	local move = cc.MoveTo:create(n_time,pos);
	local scaleTo = cc.ScaleTo:create(n_time,scale,scale);
	local spawn = cc.Spawn:create(move, scaleTo);  
	poker:runAction(cc.Sequence:create(spawn,cc.DelayTime:create(n_time),cc.CallFunc:create(function ( ... )
		poker:setVisible(false);
		poker:removeFromParent();
		audio.playSound("ershiyidian/sound/send_card.wav",false);
		self:hideAllCard(true);
		--显示得分
		self.tableLayer:showGameScore(self.tableLayer.tableLogic:viewToLogicSeatNo(self.vSeatNo),true);
	end)));
end

--获取最后一张牌的位置
function PokerListBoard:getEndCardPos()
	local pos = cc.p(0,0);
	if self.separate == false then--未分牌
		local index = #self.handCardNode;
		pos = cc.p(self.handCardNode[index]:getPositionX(),self.handCardNode[index]:getPositionY());
	else--分牌了
		if self.stop1 == false then
			local index = #self.handCardNode1;
			pos = cc.p(self.handCardNode1[index]:getPositionX(),self.handCardNode1[index]:getPositionY());
		elseif self.stop2 == false then
			local index = #self.handCardNode2;
			pos = cc.p(self.handCardNode2[index]:getPositionX(),self.handCardNode2[index]:getPositionY());
		else
			luaPrint("手牌获取位置出错！");
		end
	end
	return pos;
end

--影藏最后一张牌
function PokerListBoard:hideEndCard(isTrue)

	if self.separate == false then--未分牌
		self.handCardNode[#self.handCardNode]:setVisible(isTrue);
	else--分牌
		if self.stop1 == false then
			luaPrint("hideEndCard1",#self.handCardNode1);
			self.handCardNode1[#self.handCardNode1]:setVisible(isTrue);
		elseif self.stop2 == false then
			luaPrint("hideEndCard2",#self.handCardNode2);
			self.handCardNode2[#self.handCardNode2]:setVisible(isTrue);
		else
			luaPrint("手牌节点属性出现错误！");
		end
	end
end

--增加手牌(分过牌的方法)
function PokerListBoard:addCardNode_num(card)
	luaPrint("addCardNode_num",self.stop1,self.stop2,card);
	if self.stop1 == false then
		self:addCardNode1(card);
	else
		if self.stop2 == false then
			self:addCardNode2(card);
		else
			luaPrint("添加手牌出错",self.stop1,self.stop2,card);
		end
	end

	--影藏最后一张牌
	self:hideEndCard(false);
	--要牌动画
	self:getCardAni(card);
end
--增加扑克1,2
function PokerListBoard:addCardNode1(card)
	if card>0 then
		table.insert(self.handCard1,card);--增加牌数据
		local poker = Poker.new(self:getCardTextureFileName(card), card);
		poker:setScale(self.scale1);
		self:addChild(poker);
		table.insert(self.handCardNode1,poker);
		self:adjustPosSeparate();
	end
end
--增加扑克1,2
function PokerListBoard:addCardNode2(card)
	if card>0 then
		table.insert(self.handCard2,card);--增加牌数据
		local poker = Poker.new(self:getCardTextureFileName(card), card);
		poker:setScale(self.scale1);
		self:addChild(poker);
		table.insert(self.handCardNode2,poker);
		self:adjustPosSeparate();
	end
end

--调整位置
function PokerListBoard:adjustPos()
	luaPrint("adjustPos",self.vSeatNo,#self.handCardNode);
	luaPrint("位置***",PokerCommonDefine.Poker_Seat_Mark.Poker_South,PokerCommonDefine.Poker_Seat_Mark.Poker_West,PokerCommonDefine.Poker_Seat_Mark.Poker_East);
	local dis = 60*self.scale1 ; --牌间距
	local numX = self.numX; --分牌数量
	local pos_seat1 = cc.p(1035,320)--东边位置起点
	local pos_seat2 = cc.p(640,120)--南边位置起点
	local pos_seat3 = cc.p(150,320)--西边位置起点
	local pos_seat4 = cc.p(640,550)-- 北边位置起点
	if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East then --东边
		luaPrint("adjustPos",#self.handCardNode,numX);
		if #self.handCardNode <= numX then
			for i=#self.handCardNode,1,-1 do
				self.handCardNode[i]:setPosition(cc.p(self.pos_seat.x-(#self.handCardNode-i)*dis,self.pos_seat.y));
				self.handCardNode[i]:setLocalZOrder(i);
			end
		end
	elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South or self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then --南边和西边
		if #self.handCardNode <= numX then
			for k,v in pairs(self.handCardNode) do
				if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then--南
					v:setPosition(cc.p(self.pos_seat.x+(k-1)*dis -(#self.handCardNode/2)*dis,self.pos_seat.y));
				elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then--左边
					v:setPosition(cc.p(self.pos_seat.x+(k-1)*dis,self.pos_seat.y));
				end
				v:setLocalZOrder(k);
			end
		end
	elseif  self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North then --北边
		if #self.handCardNode <= numX then
			for k,v in pairs(self.handCardNode) do
				self.handCardNode[k]:setPosition(cc.p(self.pos_seat.x-(#self.handCardNode-k)*dis,self.pos_seat.y));
				v:setLocalZOrder(k);
			end
		end
	elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 or self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then --北1边
		if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 then
			if #self.handCardNode <= numX then
				for k,v in pairs(self.handCardNode) do
					self.handCardNode[k]:setPosition(cc.p(self.pos_seat.x + k*dis,self.pos_seat.y));
					v:setLocalZOrder(k);
				end
			end
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
			for i=#self.handCardNode,1,-1 do
				self.handCardNode[i]:setPosition(cc.p(self.pos_seat.x-(#self.handCardNode-i)*dis,self.pos_seat.y));
				self.handCardNode[i]:setLocalZOrder(i);
			end
		end
	end
end

--判断是否可以分牌
function  PokerListBoard:isBreakCard()
	if #self.handCard ~= 2 then
		return false;
	end

	if self:GetCardValue(self.handCard[1]) == self:GetCardValue(self.handCard[2]) then
		return true;
	else
		return false;
	end
end

--分牌
function PokerListBoard:separateCardNode(isTrue)
	if self:isBreakCard() then
		self:setSeparate(isTrue);
	else
		luaPrint("分牌出现错误");
		luaDump(self.handCard);
		return;
	end

	local scale = self.scale1; --分完牌的大小

	--self.handCard1 = {};
	--self.handCard2 = {};
	local value1 = clone(self.handCard[1]);
	table.insert(self.handCard1,value1);
	local value2 = clone(self.handCard[2]);
	table.insert(self.handCard2,value2);

	luaPrint("分牌成功",self.vSeatNo);
	self:removePokerNode();--去除数据和节点
	luaDump(self.handCard1);
	luaDump(self.handCard2);

	for k,v in pairs(self.handCard1) do
		local poker = Poker.new(self:getCardTextureFileName(v), v);
		poker:setScale(scale);
		self:addChild(poker);
		table.insert(self.handCardNode1,poker);
	end

	for k,v in pairs(self.handCard2) do
		local poker = Poker.new(self:getCardTextureFileName(v), v);
		poker:setScale(scale);
		self:addChild(poker);
		table.insert(self.handCardNode2,poker);
	end

	--调整位置
	self:adjustPosSeparate();
	
end

--分牌之后的位置调整
function PokerListBoard:adjustPosSeparate()
	luaPrint("adjustPosSeparate",self.vSeatNo,PokerCommonDefine.Poker_Seat_Mark.Poker_North,PokerCommonDefine.Poker_Seat_Mark.Poker_North1);
	if self.separate == false then
		luaPrint("分牌错误");
		return;
	end

	local numX = self.numX;--分行数量
	local dis = 50*self.scale1;--牌间距
	local zongDis = 100;--二个滩之间的间距
	local zhongX = 400; --第二个玩家第一排和第二排的中间间距
	local pos_seat1 = cc.p(1050,360);
	local pos_seat2 = cc.p(440,120);
	local pos_seat3 = cc.p(200,360);
	local pos_seat4 = cc.p(440,550);


	--第一滩
	for k,v in pairs(self.handCardNode1) do
		if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East then --东边
			--luaPrint("handCardNode1",#self.handCardNode1,numX);
			if #self.handCardNode1 <= numX then --分行
				for i=#self.handCardNode1,1,-1 do
					self.handCardNode1[i]:setPosition(cc.p(self.pos_seat_break.x-(#self.handCardNode1-i)*dis,self.pos_seat_break.y));
					self.handCardNode1[i]:setLocalZOrder(i);
				end 
			end
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South or self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then --中间和左边
			if #self.handCardNode1 <= numX then
				for k,v in pairs(self.handCardNode1) do
					if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then--南边
						v:setPosition(cc.p(self.pos_seat_break.x+(k-1)*dis,self.pos_seat_break.y));
					elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then--西边
						v:setPosition(cc.p(self.pos_seat_break.x+(k-1)*dis,self.pos_seat_break.y));
					end
					v:setLocalZOrder(k);
				end
			end
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North then -- 北边
			for k,v in pairs(self.handCardNode1) do
				v:setPosition(cc.p(self.pos_seat_break.x+(k-1)*dis,self.pos_seat_break.y));
				v:setLocalZOrder(k);
			end
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 or self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then -- 北边
			--luaPrint("0000000000000");
			if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 then
				--luaPrint("11111111111111111111");
				for k,v in pairs(self.handCardNode1) do
					--luaPrint("Poker_North1",self.pos_seat_break.x+(k)*dis,self.pos_seat_break.y+zongDis/2);
					v:setPosition(cc.p(self.pos_seat_break.x+(k)*dis,self.pos_seat_break.y+zongDis/2));
					v:setLocalZOrder(k);
				end
			elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
				--luaPrint("2222222222222222222");
				for i=#self.handCardNode1,1,-1 do
					self.handCardNode1[i]:setPosition(cc.p(self.pos_seat_break.x-(#self.handCardNode1-i)*dis,self.pos_seat_break.y+zongDis/2));
					self.handCardNode1[i]:setLocalZOrder(i);
				end
			end
		end

	end


	--第二滩
	for k,v in pairs(self.handCardNode2) do
		if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_East then --东边
			if #self.handCardNode2 <= numX then --分行
				for i=#self.handCardNode2,1,-1 do
					self.handCardNode2[i]:setPosition(cc.p(self.pos_seat_break.x-(#self.handCardNode2-i)*dis,self.pos_seat_break.y-zongDis));
					self.handCardNode2[i]:setLocalZOrder(i);
				end 
			end
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South or self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then --中间和左边
			if #self.handCardNode2 <= numX then
				--luaPrint("2222");
				for k,v in pairs(self.handCardNode2) do
					if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_South then--南边
						v:setPosition(cc.p(self.pos_seat_break.x+(k-1)*dis+zhongX,self.pos_seat_break.y));
					elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_West then--西边
						v:setPosition(cc.p(self.pos_seat_break.x+(k-1)*dis,self.pos_seat_break.y-zongDis));
					end
					v:setLocalZOrder(k);
				end
			end
		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North then
			for k,v in pairs(self.handCardNode2) do
				v:setPosition(cc.p(self.pos_seat_break.x+(k-1)*dis+zhongX,self.pos_seat_break.y));
				v:setLocalZOrder(k);
			end

		elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 or self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
			if self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North1 then
				for k,v in pairs(self.handCardNode2) do
					v:setPosition(cc.p(self.pos_seat_break.x+(k)*dis,self.pos_seat_break.y-zongDis/2));
					v:setLocalZOrder(k);
				end
			elseif self.vSeatNo == PokerCommonDefine.Poker_Seat_Mark.Poker_North2 then
				--luaPrint("44444444444");
				for i=#self.handCardNode2,1,-1 do
					self.handCardNode2[i]:setPosition(cc.p(self.pos_seat_break.x-(#self.handCardNode2-i)*dis,self.pos_seat_break.y-zongDis/2));
					self.handCardNode2[i]:setLocalZOrder(i);
				end
			end
		end
	end

end

-- --停牌
-- function PokerListBoard:setStopCard()
-- 	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance();
--     local pFrame = sharedSpriteFrameCache:getSpriteFrame("21D_shuzhixianshi.png");
-- 	if self.separate == false then--没有分牌
-- 		local sp_score = cc.Sprite:createWithSpriteFrame(pFrame);
-- 		self:addChild(sp_score);
-- 		sp_score:setPosition(cc.p(640,360));
-- 	else--分过牌

-- 	end
-- end

return PokerListBoard;
