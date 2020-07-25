
--开牌界面
local KaiPaiLayer = class("KaiPaiLayer", BaseWindow)
local Poker = require("baijiale.Poker")
local ResultLayer = require("baijiale.ResultLayer");
local baijialeLogic = require("baijiale.baijialeLogic");

function KaiPaiLayer:create(msg,tableLayer)
	return KaiPaiLayer.new(msg,tableLayer);
end

function KaiPaiLayer:ctor(msg,tableLayer)
	self.super.ctor(self, 0, false);
	--luaDump(msg.cbCardCount,"msg.cbCardCount")
	--luaDump(msg.cbTableCardArray,"msg.cbTableCardArray")
	self:setName("KaiPaiLayer");
	self.tableLayer = tableLayer;
	self.data = msg;--全部数据
	self.cbCardCount = msg.cbCardCount--牌数量数组
	self.cbTableCardArray = msg.cbTableCardArray--牌值数组
	self.onceMusic = true;
	self.showResult = false;
	self:initUI();

	self:addCard();

end

function KaiPaiLayer:addCard()
	local num1 = self.cbCardCount[1]
	local num2 = self.cbCardCount[2]
	local last_two = num1+num2-2
	if last_two>2 then
		last_two = 2
	end
	local scaleStart = 0.2
	local scaleEnd = 0.8
	local cardArray1 = {};--node
	local cardValueArray = {}; --value
	local lastCardValue1 = self.cbTableCardArray[1][num1];--最后一张牌1
	local lastCardValue2 = self.cbTableCardArray[2][num2];--最后一张牌2
	
	local cardNode = {{},{}};
	for i=1,num1 do--num1
		local poker = Poker.new(self:getCardTextureFileName(0),0);
		poker:setAnchorPoint(0.5,0.5);
		self.Node_card:addChild(poker);
		poker:setScale(scaleEnd);
		poker:setVisible(false)
		table.insert(cardNode[1],poker);
		if i == 1 then
			poker:setPosition(self.Image_xian:getPositionX()-self.Image_xian:getContentSize().width/4,
			self.Image_xian:getPositionY()+self.Image_xian:getContentSize().height/4-10);
		elseif i == 2 then
			poker:setPosition(self.Image_xian:getPositionX()+self.Image_xian:getContentSize().width/4,
			self.Image_xian:getPositionY()+self.Image_xian:getContentSize().height/4-10);
		elseif i == 3 then
			poker:setPosition(self.Image_xian:getPositionX(),
				self.Image_xian:getPositionY()-self.Image_xian:getContentSize().height/4-5);
			poker:setRotation(-90);
		end
	end

	for i=1,num2 do--num2
		local poker = Poker.new(self:getCardTextureFileName(0),0);
		poker:setAnchorPoint(0.5,0.5);
		self.Node_card:addChild(poker);
		poker:setScale(scaleEnd);
		poker:setVisible(false)
		table.insert(cardNode[2],poker);
		if i == 1 then
			poker:setPosition(self.Image_zhuang:getPositionX()-self.Image_zhuang:getContentSize().width/4,
			self.Image_zhuang:getPositionY()+self.Image_zhuang:getContentSize().height/4-10);
		elseif i == 2 then
			poker:setPosition(self.Image_zhuang:getPositionX()+self.Image_zhuang:getContentSize().width/4,
			self.Image_zhuang:getPositionY()+self.Image_zhuang:getContentSize().height/4-10);
		elseif i == 3 then
			poker:setPosition(self.Image_zhuang:getPositionX(),
				self.Image_zhuang:getPositionY()-self.Image_zhuang:getContentSize().height/4-5);
			poker:setRotation(-90);
		end
	end

	--依次插入数组
	for i=1,3 do
		if cardNode[1][i] then
			table.insert(cardArray1,cardNode[1][i])
			if i<= num1 then--num1
				table.insert(cardValueArray,self.cbTableCardArray[1][i])
			end
		end
		if cardNode[2][i] then
			table.insert(cardArray1,cardNode[2][i])
			if i<= num2 then--num2
				table.insert(cardValueArray,self.cbTableCardArray[2][i])
			end
		end
	end

	--执行动画
	local m_time = 0.6;
	local buTime = 0.4;
	for k,node in pairs(cardArray1) do
		local delayTime = k*m_time;
		if k == 6 then
			delayTime = delayTime+buTime;
		end
		local delay1 = cc.DelayTime:create(delayTime);
		local seq1 = cc.Sequence:create(cc.DelayTime:create(0.1),cc.OrbitCamera:create(0.1,1,0,0,-90,0,0),cc.Hide:create());
		local call = cc.CallFunc:create(function ()
			node:updataCard(self:getCardTextureFileName(cardValueArray[k]), cardValueArray[k]);
			-- audio.playSound("baijiale/sound/sound-baccarat_card.wav");
			if k<5 and k%2 == 1 then
				audio.playSound("baijiale/sound/xian.mp3");
			elseif k<5 and k%2 == 0 then
				audio.playSound("baijiale/sound/zhuang.mp3");
			elseif #cardArray1 == 5 and k == 5 then
				if self.cbCardCount[1] == 3 then
					audio.playSound("baijiale/sound/xian1.mp3");
				else
					audio.playSound("baijiale/sound/zhuang1.mp3");
				end
			else
				if k%2 == 1 then--闲补拍
					audio.playSound("baijiale/sound/xian1.mp3");
				else
					audio.playSound("baijiale/sound/zhuang1.mp3");
				end
			end
		end);
		local seq2 = cc.Sequence:create(cc.Show:create(),cc.OrbitCamera:create(0.1,1,0,90,-90,0,0)) 
		node:runAction(cc.Sequence:create(delay1,cc.Show:create(),seq1,call,seq2));
	end

	local delayTime = #cardArray1*m_time;
	if #cardArray1 > 4 then
		delayTime = delayTime+(#cardArray1-4)*buTime;
	end
	
	self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime+1),cc.CallFunc:create(function ()
		-- body
		self:huoshengAni();
	end)));
	
end

--最后搓牌的动画
function KaiPaiLayer:lastAni(node,pos)
	luaPrint("lastAni");
	if node:getPokerValue() <=0 then
		luaPrint("lastAni000");
		--return;
	end
	local scaleEnd = 0.8

	local value = node:getPokerValue();--牌值

	local temp = Poker.new(self:getCardTextureFileName(0), 0);
	temp:setScale(0.8);
	local scaleTo = cc.ScaleTo:create(0,scaleEnd,scaleEnd);
	temp:runAction(scaleTo);
	local pos1 = cc.p(790,540);--发牌位置
	local width = temp:getContentSize().width;
	local pos2 = cc.p(pos.x + temp:getContentSize().width/2-width/2,pos.y+ temp:getContentSize().height/2-4) --最终位置
	luaPrint("lastAni位置",pos2.x,pos2.y);
	local poker = Poker.new(self:getCardTextureFileName(0), 0);
	poker:setAnchorPoint(0.5,0);
	poker:setScale(0.2);
	poker:setPosition(pos1);
	self.Node_card:addChild(poker,10);

	local moveTo = cc.MoveTo:create(0.4,pos2);
	local scaleTo = cc.ScaleTo:create(0.4,scaleEnd,scaleEnd);
	local actionTo = cc.RotateTo:create(0.4, 90);  
	local spawn = cc.Spawn:create(moveTo, scaleTo,actionTo);

	poker:runAction(cc.Sequence:create(spawn,
		cc.CallFunc:create(function ()
			--搓牌动画
			local pos = pos2;
			poker:setVisible(false);
			self:cuopaiAni(pos);
		end),
		cc.DelayTime:create(0.66),
		cc.CallFunc:create(function ()
			-- 看牌
			local poker1 = Poker.new(self:getCardTextureFileName(value), value); 
			self.Node_card:addChild(poker1);
			poker1:setAnchorPoint(0.5,0.5);
			poker1:setScale(scaleEnd);
			poker1:setRotation(-90);
			poker1:setPosition(pos2.x-2,pos2.y-12);

			local rotate = cc.RotateTo:create(0.1,0);

			local spawn = cc.Spawn:create(scaleTo,actionTo);
			poker1:runAction(cc.Sequence:create(rotate,
				cc.DelayTime:create(0.4+2),
				cc.CallFunc:create(function ()
					-- body
					--poker1:setVisible(false);
					--node:setVisible(true);
					--展示获胜动画
					self:huoshengAni();

				end),
				cc.DelayTime:create(1.0),
				cc.CallFunc:create(function ()
					-- body
					--self:showScore();
				end)))
		end),
		cc.DelayTime:create(2+4),
		cc.CallFunc:create(function ()
			-- body
			self:setVisible(false);
			self:removeFromParent();
		end)
	));

end

function KaiPaiLayer:showScore()
	if self.showResult == true then
		return;
	end
	-- body
	self.showResult = true;
	self:setVisible(false);
	--self.Image_Result:setVisible(true);
	--self.Image_Result:setLocalZOrder(10000);
	--if self.data 
	--获取出庄家信息
	local userInfo = self.tableLayer.tableLogic:getUserBySeatNo(self.tableLayer.bankSeatNo);
	luaPrint("self.tableLayer.bankSeatNo",self.tableLayer.bankSeatNo);
	luaDump(userInfo,"showScore");
	local layer = ResultLayer:create(self.data,userInfo);
	self:getParent():addChild(layer,10000);
	layer:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function ()
		-- body
		layer:removeFromParent()
	end)));
end

--搓牌
function KaiPaiLayer:cuopaiAni(pos)
	luaPrint("cuopaiAni",pos.x,pos.y);
	local skeleton_animation = sp.SkeletonAnimation:create("baijiale/animate/cuopai/cuopai_fumin.json", "baijiale/animate/cuopai/cuopai_fumin.atlas");
    skeleton_animation:setPosition(pos.x+40,pos.y)
    skeleton_animation:setAnimation(0,"cuopai_fumin", false);
    self.Node_card:addChild(skeleton_animation);
    skeleton_animation:runAction(cc.Sequence:create(cc.DelayTime:create(0.66),cc.CallFunc:create(function ()
    	-- body
    	skeleton_animation:setVisible(false);
    	skeleton_animation:removeFromParent();
    end)));
end

--背光
function KaiPaiLayer:huoshengAni()
	self.Image_xianscore:setVisible(true);
	self.Image_zhuangscore:setVisible(true);
	luaPrint("huoshengAni",self.data.lPlayAllScore);
	if self.onceMusic then
		local skeleton_animation = sp.SkeletonAnimation:create("baijiale/animate/gongxihuosheng/gongxihuosheng.json", "baijiale/animate/gongxihuosheng/gongxihuosheng.atlas");
	    skeleton_animation:setPosition(72,0)
	    skeleton_animation:setAnimation(0,"gongxihuosheng", false);
	    
	    local value1 = GetCardListPip(self.data.cbTableCardArray[1],self.data.cbCardCount[1]);--闲
		local value2 = GetCardListPip(self.data.cbTableCardArray[2],self.data.cbCardCount[2]);--庄
		luaPrint("value1---",value1,value2);
		self.Image_xianscore:loadTexture("BJL_"..value1.."dian.png",UI_TEX_TYPE_PLIST);
		self.Image_zhuangscore:loadTexture("BJL_"..value2.."dian.png",UI_TEX_TYPE_PLIST);
		--依次播放音效
	
		self:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
			-- body
			audio.playSound("baijiale/sound/sound-baccarat-xpoint-"..value1..".mp3");
		end),cc.DelayTime:create(1.0),cc.CallFunc:create(function ()
			-- body
			audio.playSound("baijiale/sound/sound-baccarat-zpoint-"..value2..".mp3");
		end),cc.DelayTime:create(1.0),cc.CallFunc:create(function ( ... )
			-- body
			if value1 > value2 then
				audio.playSound("baijiale/sound/sound-baccarat-xianwin.mp3");
			elseif value1 < value2 then
				audio.playSound("baijiale/sound/sound-baccarat-zhuangwin.mp3");
			else
				audio.playSound("baijiale/sound/sound-baccarat-ping.mp3");
			end
		end)));
	
		self.onceMusic = false;
	    if value1 > value2 then--闲胜
			--self.Image_xiansheng:setVisible(true);
			self.Node_card:addChild(skeleton_animation);
			skeleton_animation:setPosition(640,591+70)
			-- if value1 == 8 or value1 == 9 then--天王
			-- 	self:addAni(2,cc.p(235+50,300))
			-- end
		elseif value1 < value2 then --闲失败
			--self.Image_zhuangsheng:setVisible(true);
			self.Node_card:addChild(skeleton_animation);
			skeleton_animation:setPosition(640,591+70)
			-- if value2 == 8 or value2 == 9 then--天王
			-- 	self:addAni(2,cc.p(1040-50,300))
			-- end
		elseif value1 == value2 then --ping
			self:addAni(1,cc.p(640,591))
			--self:addAni(1,cc.p(640,591))
		end

		if value1 ~= value2 then
			local str = "BJL_xianying.png"
			if value2>value1 then
				str = "BJL_zhuangying.png"
			end
			luaPrint("str999",str);
			local sprite = ccui.ImageView:create(str,UI_TEX_TYPE_PLIST)
			sprite:setPosition(640,581);
			self.Node_card:addChild(sprite);
		end

		--判断是否是对子,天王
		local cbWinner,cbKingWinner,bAllPointSame,bPlayerTwoPair,bBankerTwoPair 
		= baijialeLogic:DeduceWinner(self.data.cbTableCardArray,self.data.cbCardCount);
		if bPlayerTwoPair then
			self.Image_xiandui:setVisible(true);
		end
		if bBankerTwoPair then
			self.Image_zhuangdui:setVisible(true);
		end


		self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ()
			self:showEnd(value1,value2);
		end)));
		
	end

	
end

function KaiPaiLayer:showEnd(value1,value2)
	self.Node_end:setVisible(true);
	self.AtlasLabel_end_allmoney:setString(gameRealMoney(self.data.lPlayAllScore));
	self.AtlasLabel_end_xian:setString(gameRealMoney(self.data.lPlayScore[1]));
	self.AtlasLabel_end_xiandui:setString(gameRealMoney(self.data.lPlayScore[7]));
	self.AtlasLabel_end_zhuang:setString(gameRealMoney(self.data.lPlayScore[3]));
	self.AtlasLabel_end_zhuangdui:setString(gameRealMoney(self.data.lPlayScore[8]));
	self.AtlasLabel_end_he:setString(gameRealMoney(self.data.lPlayScore[2]));

	if value1>value2 then
		self.Image_end_xian:loadTexture("BJL_xianying.png",UI_TEX_TYPE_PLIST);
		self.Image_end_xian:ignoreContentAdaptWithSize(true);
	elseif value2>value1 then
		self.Image_end_zhuang:loadTexture("BJL_zhuangying.png",UI_TEX_TYPE_PLIST);
		self.Image_end_zhuang:ignoreContentAdaptWithSize(true);
	end
	self.Image_end_xianscore:loadTexture("BJL_"..value1.."dian.png",UI_TEX_TYPE_PLIST);
	self.Image_end_zhuangscore:loadTexture("BJL_"..value2.."dian.png",UI_TEX_TYPE_PLIST);

	self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ()
		self:removeFromParent()
	end)));
	
end



function KaiPaiLayer:getCardTextureFileName(pokerValue)

	local value = string.format("sdb_0x%02X", pokerValue);

	return value..".png";
end

function KaiPaiLayer:initUI()
	local uiTable = {
		Image_bg = "Image_bg",
		Image_zhuang = "Image_zhuang",
		Image_xian = "Image_xian",
		Image_xiansheng = "Image_xiansheng",
		Image_zhuangsheng = "Image_zhuangsheng",
		------------------------------------------
		Node_pos = "Node_pos",
		Text_bankName = "Text_bankName",--本轮庄家
		Text_xian_score = "Text_xian_score",--闲
		Text_zhuang_score = "Text_zhuang_score",--庄
		AtlasLabel_endAllScore = "AtlasLabel_endAllScore",--自己得分
		Text_name1 = "Text_name1",
		Text_name1 = "Text_name1",
		Text_name1 = "Text_name1",
		Text_name1 = "Text_name1",
		Text_name1 = "Text_name1",
		Text_money1 = "Text_money1",
		Text_money2 = "Text_money2",
		Text_money3 = "Text_money3",
		Text_money4 = "Text_money4",
		Text_money5 = "Text_money5",
		Image_1 = "Image_1",
		--AtlasLabel_xianScore = "AtlasLabel_xianScore",
		--AtlasLabel_zhuangScore = "AtlasLabel_zhuangScore",
		Image_xiandui = "Image_xiandui",
		Image_zhuangdui = "Image_zhuangdui",
		--Image_score_xian = "Image_score_xian",
		--Image_score_zhuang = "Image_score_zhuang",
		Node_card = "Node_card",
		Image_xianscore = "Image_xianscore",
		Image_zhuangscore = "Image_zhuangscore",

		Node_end = "Node_end",
		Image_end_xian = "Image_end_xian",
		Image_end_zhuang = "Image_end_zhuang",
		Image_end_xianscore = "Image_end_xianscore",
		Image_end_zhuangscore = "Image_end_zhuangscore",
		AtlasLabel_end_xian = "AtlasLabel_end_xian",
		AtlasLabel_end_xiandui = "AtlasLabel_end_xiandui",
		AtlasLabel_end_zhuang = "AtlasLabel_end_zhuang",
		AtlasLabel_end_zhuangdui = "AtlasLabel_end_zhuangdui",
		AtlasLabel_end_allmoney = "AtlasLabel_end_allmoney",
		AtlasLabel_end_he = "AtlasLabel_end_he",
		Button_close = "Button_close",

	}
	loadNewCsb(self,"baijiale/KaiPaiLayer",uiTable)

	self.Image_xiansheng:setVisible(true);
	self.Image_zhuangsheng:setVisible(true);
	self.Image_xiandui:setVisible(false); 
	self.Image_zhuangdui:setVisible(false);
	self.Image_xianscore:setVisible(false);
	self.Image_zhuangscore:setVisible(false);
	self.Node_end:setVisible(false);
	--self:addAni(2,cc.p(830,260))
	--self:addAni(1)
	self.Button_close:onClick(function ()
		self.Node_end:setVisible(false);
	end);
end

function KaiPaiLayer:start()
	self:setVisible(true);
	self:setTouchEnabled(true);
end

function KaiPaiLayer:stop()
	self:setVisible(false)
	self:setTouchEnabled(false);
end

function KaiPaiLayer:addAni(_type,pos)
	if pos == nil then
		pos = cc.p(630,360)
	end
	if _type == 1 then
		luaPrint("ping ");
		local skeleton_animation = sp.SkeletonAnimation:create("animate/tianwangping/tianwangping.json", "animate/tianwangping/tianwangping.atlas");
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"ping", false);
	    self.Node_card:addChild(skeleton_animation,10000);
    elseif _type ==2 then
    	luaPrint("tianwang");
		local skeleton_animation = sp.SkeletonAnimation:create("animate/tianwangping/tianwangping.json", "animate/tianwangping/tianwangping.atlas");
	    skeleton_animation:setPosition(pos)
	    skeleton_animation:setAnimation(0,"tianwang", false);
	    self.Node_card:addChild(skeleton_animation,10000);
    end
end



return KaiPaiLayer
