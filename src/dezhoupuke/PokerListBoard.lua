
--扑克牌牌墙
local PokerListBoard = class("PokerListBoard", BaseWindow)
local Poker = require("dezhoupuke.Poker")

pokerOffsetY = 15;--扑克牌上下位置偏移量
pokerY = 75;
local CARD_ICON_TB = {
	"dzpk_w_gaopai.png",	--高牌
	"dzpk_w_duizi.png",	--对子
	"dzpk_w_liangdui.png", --两对
	"dzpk_w_santiao.png", --三条
	"dzpk_w_shunzi.png", --最小顺子
	"dzpk_w_shunzi.png", --顺子
	"dzpk_w_tonghua.png", --同花
	"dzpk_w_hulu.png", --葫芦
	"dzpk_w_sitiao.png", --4条
	"dzpk_w_tonghuashun.png", --最小同花顺
	"dzpk_w_tonghuashun.png", --同花顺
	"dzpk_w_huangjiatonghuashun.png", --皇家同花顺 --12
}

CARD_ICON_TB[0] = "dzpk_daojishiguangquan.png";--错误

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
	-- luaDump(data,"createHandPoker data")
	self.handCard = data;
	if self.bIsMyself == true then
		for k,v in pairs(data) do
			if  v >= 0 and k<3 then
				local poker = Poker.new(v);
				poker:setPosition(self.tableLayer.Image_card[self.seatNo]:getPositionX()+(90*k-135),self.tableLayer.Image_card[self.seatNo]:getPositionY())
				-- poker.pokerNode:setTouchEnabled(true)
				-- poker.pokerNode:addClickEventListener(function(sender)  self:touchPokerDeal(sender); end)
				poker:setScale(0.8)
				poker.cardValue = v;
				self:addChild(poker)
				table.insert(self.handCardNode, poker);
			end
		end
	else
		for k,v in pairs(data) do
			if  v >= 0 and k<3 then
				-- luaPrint("v==  "..v)
				local poker = Poker.new(0);
				poker:setPosition(self.tableLayer.Image_card[self.seatNo]:getPositionX()+(40*k-60),self.tableLayer.Image_card[self.seatNo]:getPositionY())
				poker:setScale(0.6)
				self:addChild(poker)
				table.insert(self.handCardNode, poker);
			end
		end
	end
end

function PokerListBoard:updataHandPoker(data,nCardKind)
	for k,v in pairs(data) do
		if  v > 0 and self.handCardNode[k] then
			self.handCardNode[k]:updataCard(v)
			self.handCardNode[k].cardValue = v;
		end
	end
	local soundName = {"gaopai","duizi","liangdui","santiao","shunzi","shunzi","tonghua","hulu","sitiao","tonghuashun","tonghuashun","huangjiatonghuashun",}
	if nCardKind > 0 then
		-- paixing:loadTexture(CARD_ICON_TB[cardType],UI_TEX_TYPE_PLIST);
		local paixing = cc.Sprite:createWithSpriteFrameName(CARD_ICON_TB[nCardKind])
		paixing:setPosition(cc.p(self.tableLayer.Image_card[self.seatNo]:getPositionX(),self.tableLayer.Image_card[self.seatNo]:getPositionY()-20));
		self:addChild(paixing,10)
		local bSeatNo = self.tableLayer.tableLogic:viewToLogicSeatNo(self.seatNo-1)
		local userinfo = self.tableLayer.tableLogic:getUserBySeatNo(bSeatNo);
		local str = "";
		str = soundName[nCardKind];
		if userinfo then
			if userinfo.bBoy == true then
				str = "sound/M/"..str..".mp3"
			else
				str = "sound/W/"..str..".mp3"
			end
		end
		audio.playSound(str,false);
	end
end

function PokerListBoard:giveupHandPoker()
	for k,v in pairs(self.handCardNode) do
		v:updataCard(0)
		if self.bIsMyself == true then
			v.pokerNode:setTouchEnabled(true)
			v.pokerNode:addClickEventListener(function(sender)  self:touchPokerDeal(sender); end)
			v.isMing = false;
			v.liangpai = cc.Sprite:createWithSpriteFrameName("dzpk_liangpai.png")
			v.liangpai:setPosition(cc.p(0,0));
			v.liangpai:setScale(3.0)
			v.liangpai:setVisible(false)
			v:addChild(v.liangpai,10)
		end
	end
	if self.bIsMyself == false then
		local paixing = cc.Sprite:createWithSpriteFrameName("dzpk_w_qipaitishi.png")
		paixing:setPosition(cc.p(self.tableLayer.Image_card[self.seatNo]:getPositionX(),self.tableLayer.Image_card[self.seatNo]:getPositionY()-20));
		self:addChild(paixing,10)
	end
end

function PokerListBoard:createCommonCard(data,num)
	-- luaDump(data,"shoupai")
	self:clearData();
	for k,v in pairs(data) do
			if  v >= 0 and k<=num then
				-- luaPrint("v==  "..v)
				local poker = Poker.new(v);
				poker:setPosition(self.tableLayer.Image_boardCard:getPositionX()+(130*(k-1)),self.tableLayer.Image_boardCard:getPositionY()-25)
				self:addChild(poker)
				table.insert(self.handCardNode, poker);
			end
	end
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
	DzpkInfo:sendMingCard(not node.isMing)
end


function PokerListBoard:setPokerDeal(bMing)
	
	for k,v in pairs(self.handCardNode) do
		if bMing == false then
			v:updataCard(0)
			v.isMing = false;
			v.liangpai:setVisible(false)
		else
			v:updataCard(v.cardValue)
			v.isMing = true;
			v.liangpai:setVisible(true)
		end
	end
	
end

function PokerListBoard:setPokerTouchEnAbled(enable)
	for k,v in pairs(self.handCardNode) do
		v.pokerNode:setTouchEnabled(enable)
	end
end

--上升扑克牌
function PokerListBoard:upSelectedPoker(node, isInsert)
	
end

--降扑克牌
function PokerListBoard:downSelectedPoker(node, isDelete)
	
end

function PokerListBoard:getSelectedPokers()
	local pokers = {};

	for k,v in pairs(self.selectedCards) do
		table.insert(pokers, v:getPokerValue());
	end
	return pokers;
end



return PokerListBoard;
