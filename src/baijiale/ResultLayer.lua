local ResultLayer = class("ResultLayer", PopLayer)

function ResultLayer:create(data,userInfo)
	luaPrint("ResultLayer---------------------");
	return ResultLayer.new(data,userInfo);
end

function ResultLayer:ctor(data,userInfo)
	--self.super.ctor(self, nil, true);
	--self.super.ctor(self)
	self.super.ctor(self,PopType.none)
	self:setName("ResultLayer");
	--luaDump(data,"ResultLayer")
	--luaDump();
	self:removeAllChildren();
	self.data = data;--结算信息
	self.userInfo = userInfo;--庄家信息
	local uiTable = {
		AtlasLabel_endAllScore = "AtlasLabel_endAllScore",
		Text_xian_score = "Text_xian_score",
		Text_zhuang_score = "Text_zhuang_score",
		Text_bankName = "Text_bankName",
		Image_texiao = "Image_texiao",
	}
	loadNewCsb(self,"baijiale/ResultLayer",uiTable)
	self.xBg = self.csbNode
	self:initData();
	self:initUI();
	self:addEffect();
	--self.colorLayer:setOpacity(100);

end

function ResultLayer:addEffect()
	-- body
	local skeleton_animation = sp.SkeletonAnimation:create("animate/jiesuan/jiesuan.json", "animate/jiesuan/jiesuan.atlas");
	    skeleton_animation:setPosition(23,-40)
	    skeleton_animation:setAnimation(0,"jiesuan", false);
	    self.Image_texiao:addChild(skeleton_animation,100);
end

function ResultLayer:initData()
	--cbCardCount
	--cbTableCardArray
	local value1 = self:GetCardListPip(self.data.cbTableCardArray[1],self.data.cbCardCount[1]);--闲
	local value2 = self:GetCardListPip(self.data.cbTableCardArray[2],self.data.cbCardCount[2]);--庄
	luaPrint("ResultLayer",value1,value2);
	self.value1 = value2
	self.value2 = value1

end

function ResultLayer:initUI()

	self.AtlasLabel_endAllScore:setString(numberToString2(self.data.lPlayAllScore));
	--self.Text_xian_score:setString();
	--self.Text_zhuang_score:setString();
	if self.value1>=self.value2 then--庄赢
		self.Text_xian_score:setString("输（"..self.value2..")");
		self.Text_zhuang_score:setString("赢（"..self.value1..")");
	else--闲赢
		self.Text_xian_score:setString("赢（"..self.value2..")");
		self.Text_zhuang_score:setString("输（"..self.value1..")");
	end

	--庄家信息
	if self.userInfo then
		self.Text_bankName:setString(FormotGameNickName(self.userInfo.nickName,nickNameLen));
	else
		self.Text_bankName:setString("无人坐庄");
	end
	
end


--//获取牌点
function ResultLayer:GetCardPip(cbCardData)

	--//计算牌点
	local cbCardValue=self:GetCardValue(cbCardData);
	local cbPipCount=0
	if cbCardValue>= 10 then
		cbPipCount = 0
	else
		cbPipCount = cbCardValue
	end

	return cbPipCount;
end

function ResultLayer:GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end

--//获取牌点
function ResultLayer:GetCardListPip(cbCardData,cbCardCount)
	--//变量定义
	local cbPipCount=0;
	--//获取牌点
	for i=1,cbCardCount do
		cbPipCount=(self:GetCardPip(cbCardData[i])+cbPipCount)%10;
	end
	return cbPipCount;
end

return ResultLayer;