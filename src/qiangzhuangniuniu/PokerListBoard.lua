
--扑克牌牌墙
local PokerListBoard = class("PokerListBoard", BaseWindow)
local Poker = require("qiangzhuangniuniu.Poker")

pokerOffsetY = 15;--扑克牌上下位置偏移量
pokerY = 75;
function PokerListBoard:ctor(seatNo, tableLayer)
	luaPrint("seatNo ------------- "..seatNo)
	self.seatNo = seatNo or -1;
	self.vSeatNo = -1;--逻辑位置
	

	self.tableLayer = tableLayer;
	self:setAnchorPoint(0,0);
	
	self:initData();

	self:initUI();
end

function PokerListBoard:initData()
	self.pokerModule = nil;

	if self.seatNo == 1 then
		self.bIsMyself = true;
	else
		self.bIsMyself = false;
	end

	self.handCard = {};--手牌
	self.handCardNode = {};--手牌节点对象
	self.selectedCards = {};
	
end

function PokerListBoard:setRunMode(mode)
	self.scaleValue = 0.7;
	pokerDis = 30
end

function PokerListBoard:clearData()
	self:removeAllChildren();	
	self:initData();
end

function PokerListBoard:initUI()

	local size = cc.Director:getInstance():getWinSize();
end

function PokerListBoard:setPokerModule(pokerModule)
	self.pokerModule = pokerModule;
end

function PokerListBoard:setLogicSeatNo(vSeatNo)
	self.vSeatNo = vSeatNo;
end


function PokerListBoard:createHandPoker(data)
	self.handCard = data;
	if self.bIsMyself == true then
		for k,v in pairs(data) do
			if  v >= 0 then
				local poker = Poker.new(0);
				poker:setPosition(self.tableLayer.Image_pai[self.seatNo]:getPositionX()+(110*k-330),self.tableLayer.Image_pai[self.seatNo]:getPositionY())
				poker.pokerNode:setTouchEnabled(false)
				poker.pokerNode:addClickEventListener(function(sender)  self:touchPokerDeal(sender); end)
				self:addChild(poker)
				table.insert(self.handCardNode, poker);
			end
		end
	else
		for k,v in pairs(data) do
			if  v >= 0 then
				-- luaPrint("v==  "..v)
				local poker = Poker.new(0);
				poker:setPosition(self.tableLayer.Image_pai[self.seatNo]:getPositionX()+(30*k-90),self.tableLayer.Image_pai[self.seatNo]:getPositionY())
				self:addChild(poker)
				table.insert(self.handCardNode, poker);
			end
		end
	end
end

function PokerListBoard:createnewCard(data)
	-- luaDump(data,"shoupai")
	self.handCard = data;
	self:removeAllChildren();
	local numtype = qqnnGetCardType(self.handCard,5)
	luaPrint("numtype = "..numtype.." endt1= "..tostring(endt1).." endt2= "..tostring(endt2))
	local t1,t2 = 0;
	if endt1 and endt1 > 0 and numtype > 0 then
		t1 = self.handCard[endt1];
		t2 = self.handCard[endt2]
		table.remove(self.handCard,endt2)
		table.remove(self.handCard,endt1)
		table.insert(self.handCard,t1)
		table.insert(self.handCard,t2)
		-- luaDump(data,"self.handCard")
	end

	local x,y = self.tableLayer.Image_pai[self.seatNo]:getPosition();
	for k,v in pairs(self.handCard) do
			if  v > 0 then
				-- luaPrint("v==  "..v)
				local poker = Poker.new(v);
				local posy = y;
				if endt1 and endt1 > 0 then
					if k < 4 then
						posy = y + 15
					else
						posy = y - 15
					end
				end
				poker:setPosition(x+(30*k-90),posy)
				poker:setScale(0.8);
				self:addChild(poker)
				table.insert(self.handCardNode, poker);
			else
				luaPrint("手牌 为0")
				return;
			end
	end
	local niuType = {"meiniu","niu1","niu2","niu3","niu4","niu5","niu6","niu7","niu8","niu9","niuniu","sihuaniu","wuhuaniu"}
	local niuSpine = createSkeletonAnimation("niutype","texiao/niu/qiangzhuangniuniupaixing.json","texiao/niu/qiangzhuangniuniupaixing.atlas");
	if niuSpine then
		niuSpine:setPosition(x,y-40);
		niuSpine:setScale(0.9)
		niuSpine:setAnimation(1,niuType[numtype+1], false);
		self:addChild(niuSpine,10);
	end
	local bSeatNo = self.tableLayer.tableLogic:viewToLogicSeatNo(self.seatNo-1)
	local userinfo = self.tableLayer.tableLogic:getUserBySeatNo(bSeatNo);
	local str = "";
	if userinfo then
		if userinfo.bBoy == true then
			str = "sound/NiuSpeak_M/cow_"..numtype..".mp3"
		else
			str = "sound/NiuSpeak_W/cow_"..numtype..".mp3"
		end
	end
	audio.playSound(str,false);
end

function PokerListBoard:getPokerByTouchPos(pos)
	
	for k,v in pairs(self.handCardNode) do
		local rect = v:getBoundingBox();

		if cc.rectContainsPoint(rect, pos) then
			--luaPrint("触摸的牌值 : "..v:getPokerValue().." k = "..k.." v:getIndex() = "..v:getIndex());
			return v;
		else
			-- luaPrint("不是 触摸的牌 k = "..k)
		end
	end

	return nil;
end

--排序
function PokerListBoard:SortHandCardNode()
for i = 1,#self.handCardNode do
		for j = 1,#self.handCardNode do
			if self:getLogicCard(self.handCardNode[i]:getPokerValue()) > self:getLogicCard(self.handCardNode[j]:getPokerValue()) then
				--luaPrint("排序找到了")
				self.handCardNode[i],self.handCardNode[j] = self.handCardNode[j],self.handCardNode[i]
			end
		end
	end
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
	local value = string.format("0x%02X", pokerValue);

	return value..".png";
end

--适配调整扑克牌位置
function PokerListBoard:adjustmentPokerPos()
	
end

function PokerListBoard:touchPokerDeal(sender)
	local node = sender:getParent();
	-- luaPrint("node:getIsSelected() ------------ "..tostring(node:getIsSelected()));
	if node:getIsSelected() == false then
		--luaPrint("touchPokerDeal*************************")
		self:upSelectedPoker(node);
	else
		self:downSelectedPoker(node);
	end
end

--上升扑克牌
function PokerListBoard:upSelectedPoker(node, isInsert)
	if #self.selectedCards>= 3 then
		return;
	end

	if isInsert ~= true then
		table.insert(self.selectedCards, node);
	end	
	for k,v in pairs(self.tableLayer.AtlasLabel_num) do
		self.tableLayer.AtlasLabel_num[k]:setString("");
	end
	local sum = 0;
	for i=1,#self.selectedCards do
		local num = self.selectedCards[i]:getPokerValue()
		if num > 10 then
			num = 10;
		end
		sum =sum + num;
		self.tableLayer.AtlasLabel_num[i]:setString(num);
	end
	
	if #self.selectedCards == 3 then
		self.tableLayer.AtlasLabel_num[4]:setString(sum);
	end
	
	node:setPositionY(pokerY+pokerOffsetY)
	node:setPokerHighlighted(true);
	node:setIsUp(true);
	node:setIsSelected(true);
	audio.playSound("sound/select_card.mp3",false);
end

--降扑克牌
function PokerListBoard:downSelectedPoker(node, isDelete)
	if isDelete ~= true then
		table.removebyvalue(self.selectedCards, node)
	end	

	if getTableLength(self.selectedCards) <= 0 then
		self.selectedCards = {};
	end
	for k,v in pairs(self.tableLayer.AtlasLabel_num) do
		self.tableLayer.AtlasLabel_num[k]:setString("");
	end
	for i=1,#self.selectedCards do
		local num = self.selectedCards[i]:getPokerValue()
		if num > 10 then
			num = 10;
		end
		self.tableLayer.AtlasLabel_num[i]:setString(num);
	end
	if node then
		node:setPositionY(pokerY)
		node:setPokerHighlighted(true);
		node:setIsUp(false);
		node:setIsSelected(false);
	end
	audio.playSound("sound/select_card.mp3",false);
end

function PokerListBoard:getSelectedPokers()
	local pokers = {};

	for k,v in pairs(self.selectedCards) do
		table.insert(pokers, v:getPokerValue());
	end
	return pokers;
end

function qqnnGetCardType(cards,cardcount)
	endt1 ,endt2 = 0;
	local bKingCount = 0;
	local bTenCount = 0;
	for i=1,cardcount do
		if cards[i]%16 > 10 then
			bKingCount = bKingCount + 1;
		elseif cards[i]%16 == 10 then
			bTenCount = bTenCount + 1
		end
	end
	if bKingCount == 5 then
		return 12;       	--五花牛
	elseif bKingCount == 4 and bTenCount == 1 then
		return 11;			--四花牛
	end
	
	local btemp = {0,0,0,0,0};
	local sum = 0;
	for k,v in pairs(cards) do
		btemp[k] = getRealNum(v);
		sum = sum + btemp[k];
	end
	
	for i=1,4 do
		for j=i+1,5 do
			if (sum - btemp[i] - btemp[j] )%10 == 0 then
				endt1 = i;
				endt2 = j;
				if (btemp[i] + btemp[j])%10 == 0 then
					return 10;
				else
					return (btemp[i] + btemp[j] )%10;
				end

			end
		end
	end

	return 0;
end

function getRealNum(num)
	if num%16 > 10 then
		return 10;
	else
		return num%16;
	end

end

return PokerListBoard;
