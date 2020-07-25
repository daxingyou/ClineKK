local baijialeLogic = {}


--//玩家索引
baijialeLogic.AREA_XIAN					 = 0							--//闲家索引
baijialeLogic.AREA_PING					 = 1							--//平家索引
baijialeLogic.AREA_ZHUANG				 = 2							--//庄家索引
baijialeLogic.AREA_XIAN_TIAN			 = 3							--//闲天王
baijialeLogic.AREA_ZHUANG_TIAN			 = 4							--//庄天王
baijialeLogic.AREA_TONG_DUI				 = 5							--//同点平
baijialeLogic.AREA_XIAN_DUI				 = 6							--//闲对子
baijialeLogic.AREA_ZHUANG_DUI			 = 7							--//庄对子
baijialeLogic.AREA_MAX					 = 8							--//最大区域

--//推断赢家
function baijialeLogic:DeduceWinner(cbCardData,cbCardCount)
	luaDump(cbCardData,"cbCardData")
	luaDump(cbCardCount,"cbCardCount");
	local cbWinner = 0;
	local cbKingWinner = 0;
	local bAllPointSame = false;

	--//计算牌点
	local cbPlayerCount= self:GetCardListPip(cbCardData[1],cbCardCount[1]);
	local cbBankerCount= self:GetCardListPip(cbCardData[2],cbCardCount[2]);

	--/玩家
	if cbPlayerCount == cbBankerCount then

		cbWinner=baijialeLogic.AREA_PING	

		--//同点平判断
		bAllPointSame = false;
		if cbCardData[1] == cbCardData[2] then
		
			local CardIndex = 0; 
			for wCardIndex = 1,cbCardCount[2] do
				CardIndex = wCardIndex
				local cbBankerValue = self:GetCardValue(cbCardData[2][wCardIndex]);
				local cbPlayerValue = self:GetCardValue(cbCardData[1][wCardIndex]);
				if ( cbBankerValue ~= cbPlayerValue ) then
					break;
				end
			end
			if CardIndex == cbCardData[1]  then
				bAllPointSame = true;
			end
		end
		if bAllPointSame then
			cbKingWinner = baijialeLogic.AREA_TONG_DUI;
		end
	
	elseif cbPlayerCount<cbBankerCount then
	
		cbWinner=baijialeLogic.AREA_ZHUANG;

		--//天王判断
		if cbBankerCount == 8 or cbBankerCount == 9  then
			cbKingWinner = baijialeLogic.AREA_ZHUANG_TIAN;
		end
	else 
		cbWinner=baijialeLogic.AREA_XIAN;
		--//天王判断
		if cbPlayerCount == 8 or cbPlayerCount == 9 then
			cbKingWinner = baijialeLogic.AREA_XIAN_TIAN 
		end
	end

	--//对子判断
	local bPlayerTwoPair=false;
	local bBankerTwoPair=false;

	if self:GetCardValue(cbCardData[1][1]) == self:GetCardValue(cbCardData[1][2]) then
		bPlayerTwoPair=true;
	end	
	--luaPrint();
	-- if self:GetCardValue(cbCardData[2][1]) == self:GetCardValue(cbCardData[2][2]) then
	-- 	bBankerTwoPair=true;
	-- end
	
	if self:GetCardValue(cbCardData[2][1]) == self:GetCardValue(cbCardData[2][2]) then
		bBankerTwoPair=true;
	end
			
	return cbWinner,cbKingWinner,bAllPointSame,bPlayerTwoPair,bBankerTwoPair;
	--庄闲(平)赢，天王，同点和，闲对子，庄对子
end

--//获取牌点
function baijialeLogic:GetCardPip(cbCardData)

	--//计算牌点
	local cbCardValue=GetCardValue(cbCardData);
	local cbPipCount=0
	if cbCardValue>= 10 then
		cbPipCount = 0
	else
		cbPipCount = cbCardValue
	end

	return cbPipCount;
end

function baijialeLogic:GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end

--//获取牌点
function baijialeLogic:GetCardListPip(cbCardData,cbCardCount)
	--//变量定义
	local cbPipCount=0;
	--//获取牌点
	for i=1,cbCardCount do
		cbPipCount=(GetCardPip(cbCardData[i])+cbPipCount)%10;
	end
	return cbPipCount;
end

return baijialeLogic
