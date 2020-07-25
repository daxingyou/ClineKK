--卡牌
local SCALE_SMALL = 0.32;
local SCALE_NORMAL = 0.8;
local SCALE_NORMAL_OTHER = 0.7;
local SCALE_SHOE = 0.2;

local SCALE_FOLD_MARK = 0.6;

local CARD_WIDTH = 115;	--扑克宽度
local CARD_HEIGHT = 158;--扑克高度

local BOARD_CARD_TAG = 10;
local CARD_KIND_TAG = 6;
local CARD_FOLD_TAG = 7;
local CARD_MAX_TAG = 7;

local Common   = require("dezhoupuke.Common");

local CardLayer = class("CardLayer",function()
    return ccui.Layout:create()
end)

local CARD_ICON_TB = {
	"dzpk_w_gaopai.png",	--高牌 1
	"dzpk_w_duizi.png",	--对子 2
	"dzpk_w_liangdui.png", --两对 3
	"dzpk_w_santiao.png", --三条 4
	"dzpk_w_shunzi.png", --最小顺子 5
	"dzpk_w_shunzi.png", --顺子 6
	"dzpk_w_tonghua.png", --同花 7
	"dzpk_w_hulu.png", --葫芦 8
	"dzpk_w_sitiao.png", --4条 9
	"dzpk_w_tonghuashun.png", --最小同花顺 10
	"dzpk_w_tonghuashun.png", --同花顺 11
	"dzpk_w_huangjiatonghuashun.png", --皇家同花顺 --12
}


function CardLayer:create(panel)
    local view = CardLayer.new()
    view:onCreate(panel)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end


function CardLayer:onCreate(panel)
    --牌靴位置
    self.m_posCardShoe = cc.p(548,520);
    self.m_posCardTb = {};
   
    self.mPanel = panel;
    self.mPanelTb = {};

    -- for i=1,5 do
    -- 	local vSeat = i-1;



    -- end





    local posTb = {};
    posTb[0] = cc.p(640,190);
    posTb[1] = cc.p(180,370);
    posTb[2] = cc.p(440,590);
    posTb[3] = cc.p(840,590);
    posTb[4] = cc.p(1100,370);
    for vSeat,pos in pairs(posTb) do
    	local tb = {};
    	local gap = 18;
    	if vSeat == 0 then
    		gap = 92+2;
    	end
    	table.insert(tb,pos);
    	table.insert(tb,cc.p(pos.x+gap,pos.y));
    	self.m_posCardTb[vSeat] = tb;
    end


    --桌面公共牌 位置
    self.boardPosTb = {};
    local gap = 25;
    for i=1,5 do
		local y = 380;
		local x = 360 + 115*(i-1)+gap*(i-1);
		self.boardPosTb[i] = cc.p(x,y);
	end

	--比牌显示 位置
	self.compPosTb = {};
	--牌型显示 位置
	self.kindPosTb = {};
	local posTb = {
		cc.p(550,111);
		cc.p(140,325);
		cc.p(400,550);
		cc.p(755,550);
		cc.p(1024,325);
	};
	--弃牌标志位置
	self.foldPosTb = {};
	for k,v in pairs(self.m_posCardTb) do
		local posMid = cc.pMidpoint(v[1],v[2]);
		local scale = SCALE_SMALL;
		local scaleFold = 0.5;
		if k == 0 then
			scale = SCALE_NORMAL;
			scaleFold = 1.0;
		end
		local posY = posMid.y - CARD_HEIGHT*scale*0.5 + scaleFold*30; --30 弃牌高度
		posMid.y = posY;
		self.foldPosTb[k] = posMid;
	end

	-- local posTb = {
	-- 	cc.p(426,111);
	-- 	cc.p(18,325);
	-- 	cc.p(278,550);
	-- 	cc.p(887,550);
	-- 	cc.p(1147,325);
	-- };
	local size = cc.size(115,154);
	for i,pos in ipairs(posTb) do
		local vSeat = i-1;
		local posList = {};
		local gap = 5;
		local tb = {};
		if vSeat == 0 then
			tb = self.m_posCardTb[vSeat];
		else
			local pos1 = cc.p(pos.x + CARD_WIDTH*SCALE_NORMAL_OTHER*0.5,pos.y + size.height*0.5-gap);
			local pos2 = cc.p(pos.x + size.width - CARD_WIDTH*SCALE_NORMAL_OTHER*0.5,pos.y + size.height*0.5-gap);
			
			table.insert(tb,pos1);
			table.insert(tb,pos2);
		end

		
		self.compPosTb[vSeat] = tb;
	end

	
	for i,pos in ipairs(posTb) do
		local vSeat = i-1;
		if vSeat == 0 then
			local tb = self.m_posCardTb[vSeat];
			local mid = cc.pMidpoint(tb[1],tb[2]);
			local pos1 = cc.p(mid.x,pos.y+41);
			self.kindPosTb[vSeat] = pos1;
		else
			local pos1 = cc.p(pos.x+size.width*0.5,pos.y+41);
			self.kindPosTb[vSeat] = pos1;
		end
		
	end

    -- self.m_posCardTb[0] = cc.p(640,190);
    -- self.m_posCardTb[1] = cc.p(180,370);
    -- self.m_posCardTb[2] = cc.p(440,590);
    -- self.m_posCardTb[3] = cc.p(840,590);
    -- self.m_posCardTb[4] = cc.p(1100,370);

end

function CardLayer:setTableLayer(tableLayer)
	self.tableLayer = tableLayer;
end


function CardLayer:getSmallBackCard()
	local card = ccui.ImageView:create();
	card:loadTexture("dzpk_0x00.png",UI_TEX_TYPE_PLIST);
	card:setScale(SCALE_SMALL);
	return card;
end

function CardLayer:getNormalBackCard()
	local card = ccui.ImageView:create();
	card:loadTexture("dzpk_0x00.png",UI_TEX_TYPE_PLIST);
	card:setScale(SCALE_NORMAL);
	return card;
end

function CardLayer:getNormalCard(cardValue)
	local card = ccui.ImageView:create();
	card:loadTexture(string.format("dzpk_0x%02X.png",cardValue),UI_TEX_TYPE_PLIST);
	card:setScale(SCALE_NORMAL);
	return card;
end



function CardLayer:onEnter()

end

function CardLayer:onExit()

end

--获取牌的tag
function CardLayer:getCardTag(vSeat,index)
	return vSeat*100+index;
end

--清除玩家座位的牌
function CardLayer:removeSeatCard(vSeat)
	for i=1,CARD_MAX_TAG do
		local tag = self:getCardTag(vSeat, i);
		-- luaPrint("vSeat,i,tag,self:getChildByTag(tag):",vSeat,i,tag,self:getChildByTag(tag))
		if self:getChildByTag(tag) ~= nil then
			self:removeChildByTag(tag,true);
		end
	end
end

--清除所有玩家的手牌
function CardLayer:removeAllSeatCard()
	for i=1,6 do
		local vSeat = i-1;
		self:removeSeatCard(vSeat);
	end
end

--清除公共牌
function CardLayer:removeBoardCards()
	for i=1,5 do
		local tag = self:getCardTag(BOARD_CARD_TAG,i)
		self:removeChildByTag(tag,true);
	end
end

--清除桌面的所有牌
function CardLayer:removeDeskCard()
	self:stopAllActions();
	self:removeAllChildren();
end


--判断桌面公共牌
function CardLayer:getBoardCardsCount()
	local count = 0;
	for i=1,5 do
		local tag = self:getCardTag(BOARD_CARD_TAG,i)
		local card = self:getChildByTag(tag);
		if card then
			count = count + 1;
		end
	end

	return count;
end

--

--发牌动画	vSeatedTb-参与玩家，cardData-卡牌数据
function CardLayer:licensingCards(msg)--(vSeatedTb,cardData)
	luaPrint("self.licensingCards")
	luaDump(vSeatedTb, "vSeatedTb1111", 3)
	-- luaDump(cardData, "cardData", 3)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	self:removeAllChildren();

	local cardTb = msg.handCards;
	local iKind = msg.iKind;
	-- for k,v in pairs(cardData) do
	-- 	cardTb[k-1] = v;
	-- end

	--发牌顺序玩家
	local licensingOrder = {0,1,2,3,4};
	-- local seatedTbCC = {2,1,0,4,3};
	luaDump(licensingOrder, "licensingOrder------------1", 4)
	local m_iBigBlindVseat = msg.m_iBigBlindVseat; --大盲注玩家位置
	local seatedTb = {};
	local bGot = false;
	local gotIndex = 1;
	for i,v in ipairs(licensingOrder) do
		if v == m_iBigBlindVseat then
			bGot = true;
			gotIndex = i;
		end
		if bGot then
			table.insert(seatedTb,v);
		end
	end

	for i,v in ipairs(licensingOrder) do
		if i <  gotIndex then
			table.insert(seatedTb,v);
		end
	end



	local playerStatusTb =  msg.playingSeatTb;
	-- local playerStatusTb =  {1,1,1,0,1};
	
	for k,vv in pairs(playerStatusTb) do
		local seat1 = k;
		if vv ~= 1 then
			for i,seat2 in ipairs(seatedTb) do
				if seat1 == seat2 then
					table.remove(seatedTb,i);
					break;
				end
			end
		end
	end
	luaDump(seatedTb, "seatedTb---after", 5)

	local count = table.nums(seatedTb);
	-- luaDump(seatedTb, "seatedTb---", 3)
	local expandTimes = count*2*1+2;

	
	local function turnCardBegin(card)   --耗时 0.4
   		local function turnFrontCard(card)
   			-- luaPrint("card.id:::::",card.id);
			card:loadTexture(string.format("dzpk_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
			if card.bGray then
				Common.setImageGray(card,true);
			end



			local big = cc.ScaleTo:create(0.15, SCALE_NORMAL * 1.2, SCALE_NORMAL);
			local normal = cc.ScaleTo:create(0.05, SCALE_NORMAL, SCALE_NORMAL);
			
			local seq = cc.Sequence:create(big,normal);
			card:runAction(seq);
		end

		local actionCallback = cc.CallFunc:create(function (sender)
				turnFrontCard(sender);
				if self.tableLayer.m_bEffectOn then
		        	-- playEffect("dezhoupuke/sound/light_card_forwardly.mp3", false);
		        end
		end)

		local disappear = cc.ScaleTo:create(0.15, 0.01, SCALE_NORMAL);
		local delayIt = cc.DelayTime:create(card.index*0.1);
		local action = cc.Sequence:create(delayIt,disappear,actionCallback)
		card:runAction(action);
   	end

	local function expandCards()
		-- local seatedTb = {2,1,0,4,3};
		-- luaDump(cardTb, "cardTb----1", 4)
		-- luaDump(seatedTb, "seatedTb----1", 4)
		for k,vSeat in pairs(seatedTb) do
			local cardValueTb = cardTb[vSeat];
			if vSeat == 0  then
				for i=1,2 do
					local tag = self:getCardTag(vSeat, i);
					local card = self:getChildByTag(tag);
					if card then
						card.id = cardValueTb[i];
						card.index = i-1;
						turnCardBegin(card);
					end
				end

				--牌型
				self:hideCardKind(vSeat);
				local imgKind = ccui.ImageView:create();
				imgKind:loadTexture(CARD_ICON_TB[iKind],UI_TEX_TYPE_PLIST);
				imgKind:setVisible(false);
				self:addChild(imgKind);
				local tag = self:getCardTag(vSeat, CARD_KIND_TAG);
				imgKind:setTag(tag);
				imgKind:setPosition(self.kindPosTb[vSeat]);
				imgKind:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.Show:create()));
			else
				--为了测试  发牌显示牌型
				for i,v in ipairs(cardValueTb) do
					if v > 0 then
						local tag = self:getCardTag(vSeat, i);
						local card = self:getChildByTag(tag);
						if card then
							card:loadTexture(string.format("dzpk_0x%02X.png", v),UI_TEX_TYPE_PLIST);
						end
					end
				end


				local tag = self:getCardTag(vSeat, 2);
				local card = self:getChildByTag(tag);
				if card then
					local rotate = cc.RotateBy:create(0.2, 20);
					card:runAction(rotate);
					if self.tableLayer.m_bEffectOn then
			        	-- playEffect("dezhoupuke/sound/light_card_forwardly.mp3", false);
			        end
				end
			end
		end
	end
	
	local function sendCards()
		local spead = 2000;
		local maxIndex = table.nums(seatedTb);
		for i,vSeat in ipairs(seatedTb) do
			local posTb = self.m_posCardTb[vSeat];
			for j=1,2 do
				-- luaDump(posTb, "posTb", 3)
				-- luaPrint("vSeat:",vSeat);
				local pos = posTb[j];
				local card = self:getSmallBackCard();
				self:addChild(card);
				card:setTag(self:getCardTag(vSeat,j));
				card:setPosition(self.m_posCardShoe);
				card:setVisible(false);
				card:setScale(SCALE_SHOE);

				-- local delayIt = cc.DelayTime:create(0.25*(i-1));
				-- local delayIt2 = cc.DelayTime:create(0.25*(j-1));
				local delayIt =  cc.DelayTime:create(0.4*(i-1)+ 0.2*(j-1));
				-- local delayIt =  cc.DelayTime:create(0.2*(i+j-1));
				local showIt = cc.Show:create();

				local length = cc.pGetDistance(self.m_posCardShoe,posTb[1]);
				local dt = length/spead;

				local moveIt = cc.MoveTo:create(dt,posTb[1]);
				
				local scale = SCALE_SMALL;
				if vSeat == 0 then
					scale = SCALE_NORMAL;
				end

				local scaleIt = cc.ScaleTo:create(dt,scale);
				local spawn = cc.Spawn:create(moveIt,scaleIt);
				local delayIt3 = cc.DelayTime:create(1*0.02);
				local moveTo = cc.MoveTo:create(0.03*j*1,posTb[j]);

				local animCallback = cc.CallFunc:create(function (sender)
						if self.tableLayer.m_bEffectOn then
				        	playEffect("dezhoupuke/sound/send_cards.mp3", false);
				        end
				end)

				local expandCallback = cc.CallFunc:create(function (sender)
						expandCards();
				end)

				local seq = nil;
				if i == maxIndex and j == 2 then
					seq = cc.Sequence:create(delayIt,showIt,spawn,delayIt3,animCallback,moveTo,expandCallback);
				else
					seq = cc.Sequence:create(delayIt,showIt,spawn,delayIt3,animCallback,moveTo);
				end

				
				card:runAction(seq);
			end
		end

	end


	sendCards();
  --  	local bEnd = false;
  --  	local times = 0;
  --  	local function doPercent()   			
		-- -- luaPrint("doPercent:",times);
		-- if times == 1  then  --
		-- 	sendCards();
		-- elseif times == expandTimes then --
		-- 	bEnd = true;
		-- 	expandCards();
		-- end
  --  		times = times + 1;
  --  	end

  --  	local function runProgressTime()
  --  		if not bEnd then
  --  			doPercent();
		-- 	self:stopAllActions();
		-- 	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.09),cc.CallFunc:create(runProgressTime)))
  --  		else
  --  			self:stopAllActions();
  --  		end
   		
  --  	end

  --  	runProgressTime();
end


--派发公共桌面牌
function CardLayer:licensingBoardCards(cardData,count)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	-- cardData = {1,2,3,4,5};
	local cardTb = cardData;

	--移除桌面牌
	local function removeBoardCards()
		for i=1,5 do
			local tag = self:getCardTag(BOARD_CARD_TAG,i)
			self:removeChildByTag(tag,true);
		end
	end


	--展开桌面牌
	local function expandBoardCards()
		local spead = 500;
		
		local dt = 0.25;
		local length = cc.pGetDistance(self.boardPosTb[1],self.boardPosTb[2]);
		for i=1,count do
			local card = self:getChildByTag(self:getCardTag(BOARD_CARD_TAG,i));
			if card then
				card:setVisible(true);
				local moveBy = cc.MoveBy:create(dt,cc.p(length,0));
				local actionCallback = cc.CallFunc:create(function (sender)
					if self.tableLayer.m_bEffectOn then
			        	playEffect("dezhoupuke/sound/see_card.mp3", false);
			        end
				end)

				local seq = cc.Sequence:create(moveBy,actionCallback)
				local rep = cc.Repeat:create(seq,i-1);
				card:runAction(rep);
			end
		end
	end



	local function turnCardBegin()   --耗时 0.4
		local scale = 1.0;
   		local function turnFrontCard(card)
   			
			card:loadTexture(string.format("dzpk_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
			card:setScale(1.0);
			local big = cc.ScaleTo:create(0.15, scale * 1.2, scale);
			local normal = cc.ScaleTo:create(0.05, scale, scale);
			
			
			local seq = cc.Sequence:create(big,normal);
			card:runAction(seq);
		end

		for i=1,count do
			local tag = self:getCardTag(BOARD_CARD_TAG, i);
			local card = self:getChildByTag(tag);
			if i == count then
				local actionCallback = cc.CallFunc:create(function (sender)
					turnFrontCard(sender);
				end)

				local nextCallback = cc.CallFunc:create(function (sender)
						expandBoardCards();
				end)

				local disappear = cc.ScaleTo:create(0.15, 0.01, 1.0);	
				local delayIt2 = cc.DelayTime:create(0.3);	
				local action = cc.Sequence:create(disappear,actionCallback,delayIt2,nextCallback)
				card:runAction(action);

				if self.tableLayer.m_bEffectOn then
		        	playEffect("dezhoupuke/sound/fold.mp3", false);
		        end

		        

			else
				card:loadTexture(string.format("dzpk_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
				card:setVisible(false);
				card:setScale(1.0);
			end
		end
   	end

	--派发桌面牌
	local function sendBoardCards()
		local spead = 1600;
		local maxIndex = table.nums(cardTb);
		for i,v in ipairs(cardTb) do
			local card = self:getNormalBackCard();
			card.id = v;
			card:setTag(self:getCardTag(BOARD_CARD_TAG,i));
			card:setPosition(self.m_posCardShoe);
			card:setVisible(false);
			card:setScale(SCALE_SHOE);
			self:addChild(card);

			local delayIt =  cc.DelayTime:create(0.04*(i-1));
			local showIt = cc.Show:create();

			local length = cc.pGetDistance(self.m_posCardShoe,self.boardPosTb[1]);
			local dt = length/spead;
			local moveIt = cc.MoveTo:create(dt,self.boardPosTb[1]);

			local scaleIt = cc.ScaleTo:create(dt,1.0);
			local spawn = cc.Spawn:create(moveIt,scaleIt);
			
			
			local animCallback = cc.CallFunc:create(function (sender)
			        if self.tableLayer.m_bEffectOn then
			        	playEffect("dezhoupuke/sound/send_hole_cards.mp3", false);
			        end
			end)

			local nextCallback = cc.CallFunc:create(function (sender)
					turnCardBegin();
			end)

			local seq = nil;
			if i == maxIndex  then
				local delayIt2 = cc.DelayTime:create(0.2);
				seq = cc.Sequence:create(delayIt,showIt,spawn,animCallback,delayIt2,nextCallback);
			else
				seq = cc.Sequence:create(delayIt,showIt,spawn,animCallback);
			end

			-- local seq = cc.Sequence:create(delayIt,showIt,spawn,animCallback);
			card:runAction(seq);
		end
	end

	

	

   	self:stopAllActions();
   	removeBoardCards();
   	sendBoardCards();

	-- local proIndex = 1;
 --   	local bEnd = false;
 --   	local times = 0;

 --   	local function doPercent()   			
	-- 	-- luaPrint("doPercent:",times);
	-- 	if times == 1  then  --
	-- 		sendBoardCards();
	-- 	elseif times == 2 then --4
	-- 		turnCardBegin();
	-- 	elseif times == 8 then --
	-- 		bEnd = true;
	-- 		expandBoardCards();
	-- 	end
 --   		times = times + 1;
 --   	end

 --   	local function runProgressTime()
 --   		if not bEnd then
 --   			doPercent();
	-- 		self:stopAllActions();
	-- 		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.09),cc.CallFunc:create(runProgressTime)))
 --   		else
 --   			self:stopAllActions();
 --   		end
   		
 --   	end

 --   	self:stopAllActions();
 --   	removeBoardCards();
 --   	runProgressTime();
end


--派发公共桌面牌 Turn 转牌 - 第四张公共牌
function CardLayer:licensingTurnRiverCard(index,cardData)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	-- cardData = {1,2,3,4,5};
	local cardValue = cardData;
	local pos_t = self.boardPosTb[index]
	--移除桌面牌
	local function removeExistCards()
		local tag = self:getCardTag(BOARD_CARD_TAG,index)
		self:removeChildByTag(tag,true);
	end

	--派发桌面牌
	local function sendBoardCards()
		local spead = 1800;
		local card = self:getNormalCard(cardValue);
		card.id = cardValue;
		card:setTag(self:getCardTag(BOARD_CARD_TAG,index));
		card:setPosition(self.m_posCardShoe);
		card:setVisible(false);
		card:setScale(SCALE_SHOE);
		self:addChild(card);

		local showIt = cc.Show:create();
		local length = cc.pGetDistance(self.m_posCardShoe,pos_t);
		local dt = length/spead;
		local moveIt = cc.MoveTo:create(dt,pos_t);

		local scaleIt = cc.ScaleTo:create(dt,1.0);
		local spawn = cc.Spawn:create(moveIt,scaleIt);
		
		
		local animCallback = cc.CallFunc:create(function (sender)
				if self.tableLayer.m_bEffectOn then
		        	playEffect("dezhoupuke/sound/send_cards.mp3", false);
		        end
		end)

		local seq = cc.Sequence:create(showIt,spawn,animCallback);
		card:runAction(seq);
	end

	removeExistCards();
	sendBoardCards();
end


--比牌 展现玩家手牌
function CardLayer:revealCards(handCardTb,cardKindTb)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	-- self:removeAllSeatCard();
	-- luaDump(handCardTb, "handCardTb-------------1", 3)
	-- luaDump(cardKindTb, "cardKindTb-------------1", 3)

	local function turnCardBegin(card)   --耗时 0.4
   		local function turnFrontCard(card)
			card:loadTexture(string.format("dzpk_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
			local big = cc.ScaleTo:create(0.15, card.iScale * 1.2, card.iScale);
			local normal = cc.ScaleTo:create(0.05, card.iScale, card.iScale);
		
			local seq = cc.Sequence:create(big,normal);
			card:runAction(seq);
		end

		local actionCallback = cc.CallFunc:create(function (sender)
				turnFrontCard(sender);
		end)

		local disappear = cc.ScaleTo:create(0.15, 0.01, card.iScale);
		local action = cc.Sequence:create(disappear,actionCallback)
		card:runAction(action);
   	end

   	local function playSound(vSeat,nKind)
   		if not self.tableLayer.m_bEffectOn then
   			return;
   		end

   		local soundName = {"gaopai","duizi","liangdui","santiao","shunzi","shunzi","tonghua","hulu","sitiao","tonghuashun","tonghuashun","huangjiatonghuashun",}
		if nKind > 0 then
			local userinfo = self.tableLayer.tableLogic:getUserBySeatNo(vSeat);
			local str = "";
			str = soundName[nKind];
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

   	local maxKind = 0;
   	for k,v in pairs(cardKindTb) do
   		if v >= maxKind then
   			maxKind = v;
   		end
   	end

  
	for vSeat,v in pairs(cardKindTb) do
		if v > 0 then
			
			self:removeSeatCard(vSeat);

			self:hideCardKind(vSeat);
			local posTb = self.compPosTb[vSeat];
			local cardTb = handCardTb[vSeat];
			for j,vv in ipairs(cardTb) do
				local card = ccui.ImageView:create();
				local tag = self:getCardTag(vSeat, j);
				-- luaPrint("tag_______:",tag,j)
				card:loadTexture("dzpk_0x00.png",UI_TEX_TYPE_PLIST);
				card:setPosition(posTb[j]);
				card:setTag(tag);
				card.id = vv;

				if vSeat == 0 then
					card:setScale(SCALE_NORMAL);
					card.iScale = SCALE_NORMAL;
				else
					card.iScale = SCALE_NORMAL_OTHER;
					card:setScale(SCALE_NORMAL_OTHER)
				end
				
				self:addChild(card);
				turnCardBegin(card);

			end

			--牌型
			local cardType = cardKindTb[vSeat];
			local imgKind = ccui.ImageView:create();
			imgKind:loadTexture(CARD_ICON_TB[cardType],UI_TEX_TYPE_PLIST);
			imgKind:setVisible(false);
			self:addChild(imgKind);
			local tag = self:getCardTag(vSeat, CARD_KIND_TAG);
			imgKind:setTag(tag);
			imgKind:setPosition(self.kindPosTb[vSeat]);
			imgKind:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.Show:create()))
			if cardType == maxKind then
				maxKind  = maxKind + 10000; --播一次
				-- playSound(vSeat,cardType);
			end
			-- playSound(vSeat,cardType);
		end
	end
end

--展示牌型
function  CardLayer:showCardKind(vSeat,iKind)
	self:hideCardKind(vSeat);
	if iKind <= 0 then
		return;
	end

	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	
	--牌型
	local imgKind = ccui.ImageView:create();
	imgKind:loadTexture(CARD_ICON_TB[iKind],UI_TEX_TYPE_PLIST);
	
	self:addChild(imgKind);
	local tag = self:getCardTag(vSeat, CARD_KIND_TAG);
	imgKind:setTag(tag);
	imgKind:setPosition(self.kindPosTb[vSeat]);
end

--隐藏牌型
function  CardLayer:hideCardKind(vSeat)
	--牌型
	local tag = self:getCardTag(vSeat, CARD_KIND_TAG);
	self:removeChildByTag(tag, true);
	
end



--全场ALLIN 时亮牌
function CardLayer:showAllInCards(allCardTb)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	local function turnCardBegin(card)   --耗时 0.4
   		local function turnFrontCard(card)
			card:loadTexture(string.format("dzpk_0x%02X.png", card.id),UI_TEX_TYPE_PLIST);
			local big = cc.ScaleTo:create(0.15, card.iScale * 1.2, card.iScale);
			local normal = cc.ScaleTo:create(0.05, card.iScale, card.iScale);
		
			local seq = cc.Sequence:create(big,normal);
			card:runAction(seq);
		end

		local actionCallback = cc.CallFunc:create(function (sender)
				turnFrontCard(sender);
		end)

		local disappear = cc.ScaleTo:create(0.15, 0.01, card.iScale);
		local action = cc.Sequence:create(disappear,actionCallback)
		card:runAction(action);
   	end

	for vSeat,cardTb in pairs(allCardTb) do
		if vSeat ~= 0 then

			if cardTb[1] > 0 then
				self:removeSeatCard(vSeat);
			end
			-- self:removeSeatCard(vSeat);
			local posTb = self.compPosTb[vSeat];
			for j,vv in ipairs(cardTb) do
				if vv ~= 0 then
					local card = ccui.ImageView:create();
					local tag = self:getCardTag(vSeat, j);
					
					card:loadTexture("dzpk_0x00.png",UI_TEX_TYPE_PLIST);
					card:setPosition(posTb[j]);
					if vSeat == 0 then
						card:setScale(SCALE_NORMAL);
						card.iScale = SCALE_NORMAL;
					else
						card.iScale = SCALE_NORMAL_OTHER;
						card:setScale(SCALE_NORMAL_OTHER)
					end

					card:setTag(tag);
					card.id = vv;
					self:addChild(card);
					turnCardBegin(card);
				end
				
			end
		end
	end
end


--弃牌玩家亮牌
function CardLayer:showCards(allCardTb)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	for vSeat,cardTb in pairs(allCardTb) do
		local posTb = self.compPosTb[vSeat];
		for j,vv in ipairs(cardTb) do
			if vv > 0 then
				self:removeSeatCard(vSeat);
			end
		end

		for j,vv in ipairs(cardTb) do
			if vv > 0 then
				local card = ccui.ImageView:create();
				local tag = self:getCardTag(vSeat, j);
				card:loadTexture(string.format("dzpk_0x%02X.png", vv),UI_TEX_TYPE_PLIST);
				card:setPosition(posTb[j]);
				card:setTag(tag);
				card.id = vv;
				if vSeat == 0 then
					card:setScale(SCALE_NORMAL);
				else
					card:setScale(SCALE_NORMAL_OTHER);
				end
				
				self:addChild(card);
			end
		end
	end

	-- for vSeat,cardTb in pairs(allCardTb) do
	-- 	local posTb = self.compPosTb[vSeat];
	-- 	for j,vv in ipairs(cardTb) do
	-- 		if vv > 0 then
	-- 			self:removeSeatCard(vSeat);
	-- 		end
	-- 	end

	-- 	for j,vv in ipairs(cardTb) do
	-- 		if vv > 0 then
	-- 			local card = ccui.ImageView:create();
	-- 			local tag = self:getCardTag(vSeat, j);
	-- 			card:loadTexture(string.format("dzpk_0x%02X.png", vv),UI_TEX_TYPE_PLIST);
	-- 			card:setPosition(posTb[j]);
	-- 			card:setTag(tag);
	-- 			card.id = vv;
	-- 			card:setScale(SCALE_NORMAL)
	-- 			self:addChild(card);
	-- 		end
	-- 	end
		
	-- end
end


--玩家弃牌
function CardLayer:foldCards(vSeat)
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	local count = 2;
	local cards = {}
	

	local function sendReveal()
		local tag = self:getCardTag(0, 1);
		local card = self:getChildByTag(tag);
		local bMing = false;
		if card then
			bMing = card.bMing;
		end
		
		DzpkInfo:sendMingCard(not bMing);
	end


	local function turnCardBegin()   --耗时 0.4
   		local function turnFrontCard(card)
			card:loadTexture(string.format("dzpk_0x%02X.png", 0),UI_TEX_TYPE_PLIST);
			local big = cc.ScaleTo:create(0.15, SCALE_NORMAL * 1.2, SCALE_NORMAL);
			local normal = cc.ScaleTo:create(0.05, SCALE_NORMAL, SCALE_NORMAL);
		
			local seq = cc.Sequence:create(big,normal);
			card:runAction(seq);
			if self.tableLayer.m_bEffectOn then
	        	playEffect("dezhoupuke/sound/fold.mp3", false);
	        end
		end

		local actionCallback = cc.CallFunc:create(function (sender)
				turnFrontCard(sender);
		end)

		for i=1,2 do
			local tag = self:getCardTag(vSeat, i);
			local card = self:getChildByTag(tag);
			local posTb = self.m_posCardTb[vSeat];
			if card then
				card:stopAllActions();
				card:setPosition(posTb[i]);
				local disappear = cc.ScaleTo:create(0.15, 0.01, SCALE_NORMAL);
				local action = cc.Sequence:create(disappear,actionCallback)
				card:runAction(action);
				card:setTouchEnabled(true);
				card.bMing = false;
				card:addClickEventListener(function(sender)  sendReveal(); end)
			end
		end

		--添加弃牌标志
		local imgFold = ccui.ImageView:create();
		imgFold:loadTexture("dzpk_w_qipaitishi.png",UI_TEX_TYPE_PLIST);
		imgFold:setVisible(false);
		imgFold:setPosition(self.foldPosTb[vSeat]);

		-- imgFold:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.Show:create()));
		local tag = self:getCardTag(vSeat, CARD_FOLD_TAG);
		imgFold:setTag(tag);
		self:addChild(imgFold);
   	end

   	local function showFoldTag()
   		--添加弃牌标志
		local imgFold = ccui.ImageView:create();
		imgFold:loadTexture("dzpk_w_qipaitishi.png",UI_TEX_TYPE_PLIST);
		-- imgFold:setVisible(false);
		imgFold:setOpacity(0)
		imgFold:setPosition(self.foldPosTb[vSeat]);
		imgFold:runAction(cc.FadeIn:create(0.7));
		local tag = self:getCardTag(vSeat, CARD_FOLD_TAG);
		imgFold:setTag(tag);
		imgFold:setScale(SCALE_FOLD_MARK)
		self:addChild(imgFold);
   	end

   	local function grayCards()
   		for i=1,2 do
			local tag = self:getCardTag(vSeat, i);
			local card = self:getChildByTag(tag);
			local posTb = self.m_posCardTb[vSeat];

			if card then
				card:stopAllActions();
				card:setScale(SCALE_NORMAL);
				card:setPosition(posTb[i]);

				Common.setImageGray(card,true);
				card:setOpacity(200);
				card.bGray = true;
				card:setTouchEnabled(true);
				card.bMing = false;
				card:addClickEventListener(function(sender)  sendReveal(); end)
			end
		end

   		
   	end

   	if vSeat == 0 then
   		self:hideCardKind(vSeat);
   		grayCards();
   	else
   		showFoldTag();
   	end


   	
end

--玩家弃牌后亮牌标志
function CardLayer:markRevealTag(vSeat,bReveal)
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	--添加亮牌标志
	if bReveal then
		for i=1,2 do
			local tag = self:getCardTag(vSeat, i);
			local card = self:getChildByTag(tag);
			if card then
				card.bMing = true;
				local sizeCard = card:getContentSize();
				card:removeAllChildren();
				local imgReveal = ccui.ImageView:create();
				imgReveal:loadTexture("dzpk_liangpai.png",UI_TEX_TYPE_PLIST);
				sizeImg = imgReveal:getContentSize();
				imgReveal:setScale(1.0);
				-- imgReveal:setPosition(cc.p(sizeCard.width - sizeImg.width*1.0,sizeCard.height - sizeImg.height*1.0));
				imgReveal:setPosition(cc.p(sizeCard.width - sizeImg.width*0.5-10,sizeCard.height - sizeImg.height*1.0));
				card:addChild(imgReveal);
				imgReveal:setTag(1);
			end
		end
	else
		for i=1,2 do
			local tag = self:getCardTag(vSeat, i);
			local card = self:getChildByTag(tag);
			if card then
				card.bMing = false;
				local sizeCard = card:getContentSize();
				card:removeAllChildren();
			end
		end
	end
	


end



--恢复玩家手牌
function CardLayer:resumePlayerCards(seatedTb,cardAllTb,bMingCard)
	--发牌顺序玩家
	-- self:removeDeskCard();
	-- for i,vSeat in ipairs(seatedTb) do
	-- 	local posTb = self.m_posCardTb[vSeat];
	-- 	for j=1,2 do
	-- 		local card = nil;
	-- 		local scale = nil;
	-- 		if vSeat == 0 then
	-- 			scale = SCALE_NORMAL;
	-- 			card = self:getNormalCard(cardTb[j])
	-- 		else
	-- 			scale = SCALE_SMALL;
	-- 			card = self:getSmallBackCard();
	-- 		end
	-- 		local pos = posTb[j];
			
	-- 		self:addChild(card);
	-- 		card:setTag(self:getCardTag(vSeat,j));
	-- 		card:setPosition(posTb[j]);
	-- 		card:setVisible(true);
	-- 		card:setScale(scale);

	-- 		if vSeat ~= 0 and j == 2 then
	-- 			card:setRotation(20);
	-- 		end

	-- 	end
	-- end
	display.loadSpriteFrames("dezhoupuke/image/card.plist", "dezhoupuke/image/card.png");
	for i,vSeat in ipairs(seatedTb) do
		local posTb = self.m_posCardTb[vSeat];
		local cardTb = cardAllTb[vSeat];
		for j,v in ipairs(cardTb) do
			local card = nil;
			local scale = nil;
			if vSeat == 0 then
				scale = SCALE_NORMAL;
				card = self:getNormalCard(cardTb[j]);
				local pos = posTb[j];
				card.id = cardTb[j];
				self:addChild(card);
				card:setTag(self:getCardTag(vSeat,j));
				card:setPosition(posTb[j]);
				card:setVisible(true);
				card:setScale(scale);
			else
				local card = nil;
				local tag = self:getCardTag(vSeat, j);
				local pos = posTb[j];
				if v > 0 then
					card = ccui.ImageView:create();
					card:loadTexture(string.format("dzpk_0x%02X.png",v),UI_TEX_TYPE_PLIST);
					card.id = v;
					scale = SCALE_NORMAL_OTHER;
					local posTb2 = self.compPosTb[vSeat];
					pos = posTb2[j];
				else
					scale = SCALE_SMALL;
					card = self:getSmallBackCard();
					card.id = 0;
					if j == 2 then
						card:setRotation(20);
					end
				end

				self:addChild(card);
				card:setTag(self:getCardTag(vSeat,j));
				card:setPosition(pos);
				card:setVisible(true);
				card:setScale(scale);
			end
		end

	end

	for i,vSeat in ipairs(seatedTb) do
		if vSeat == 0 then
			self:markRevealTag(vSeat, bMingCard);
		end	
	end
	

end

--恢复弃牌标志
function CardLayer:resumeFoldTag(seatedFoldTb)
	display.loadSpriteFrames("dezhoupuke/image/img_dzpk.plist", "dezhoupuke/image/img_dzpk.png");
	--添加弃牌标志
	local function sendReveal()
		local tag = self:getCardTag(0, 1);
		local card = self:getChildByTag(tag);
		local bMing = false;
		if card then
			bMing = card.bMing;
		end
		-- luaPrint("bMing:",bMing);
		DzpkInfo:sendMingCard(not bMing);
	end


	for i,vSeat in ipairs(seatedFoldTb) do
		local imgFold = ccui.ImageView:create();

		imgFold:loadTexture("dzpk_w_qipaitishi.png",UI_TEX_TYPE_PLIST);
		imgFold:setPosition(self.foldPosTb[vSeat]);
		
		local tag = self:getCardTag(vSeat, CARD_FOLD_TAG);
		imgFold:setTag(tag);
		if vSeat ~= 0 then
			imgFold:setScale(SCALE_FOLD_MARK)
		else
			imgFold:setVisible(false);
		end
		self:addChild(imgFold);

		if vSeat == 0 then
			for i=1,2 do
				local tag = self:getCardTag(vSeat, i);
				local card = self:getChildByTag(tag);
				if card then
					-- card:loadTexture("dzpk_0x00.png",UI_TEX_TYPE_PLIST);
					Common.setImageGray(card,true);
					card:setScale(SCALE_NORMAL);
					card:setTouchEnabled(true);
					card.bMing = false;
					card:addClickEventListener(function(sender)  sendReveal(); end)
				end
			end
		else
			for i=1,2 do
				local tag = self:getCardTag(vSeat, i);
				local card = self:getChildByTag(tag);
				if card and card.id ~= nil and card.id > 0 then
					imgFold:setVisible(false);
				end
			end
		end	
	end
	

	
	
end

--恢复桌面公共牌
function CardLayer:resumeBoardCards(cardTb)
	self:removeBoardCards();
	for i,v in ipairs(cardTb) do
		if v > 0 then
			local card = self:getNormalCard(v);
			card.id = v;
			card:setTag(self:getCardTag(BOARD_CARD_TAG,i));
			card:setVisible(true);
			card:setScale(1.0);
			card:setPosition(self.boardPosTb[i]);
			self:addChild(card);
		end
	end
end


return CardLayer