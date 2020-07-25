local errenniuniuLogic = {}


--//玩家索引
errenniuniuLogic.niu_0					 = 0							--没牛
errenniuniuLogic.niu_1					 = 1							--牛1
errenniuniuLogic.niu_2				 	 = 2							--牛2
errenniuniuLogic.niu_3			 		 = 3							--牛3
errenniuniuLogic.niu_4			 		 = 4							--牛4
errenniuniuLogic.niu_5				 	 = 5							--牛5
errenniuniuLogic.niu_6				 	 = 6							--牛6
errenniuniuLogic.niu_7			 		 = 7							--牛7
errenniuniuLogic.niu_8					 = 8							--牛8
errenniuniuLogic.niu_9					 = 9							--牛9
errenniuniuLogic.niu_9					 = 10							--牛牛
errenniuniuLogic.niu_9					 = 11							--银牛
errenniuniuLogic.niu_9					 = 12							--金牛

--寻找牛
function errenniuniuLogic:foundNiu(cbCardData,cbCardCount)
	if cbCardData == nil or cbCardCount == nil then
		return false;
	end
	-- body
	local haveNiu = false;
	local temp = {};
	local stop = false;
	for i=1,cbCardCount do
		for j=1,cbCardCount do
			for m = 1,cbCardCount do
				if i ~= j and i ~= m and j ~= m then
					local value = (self:GetCardPip(cbCardData[i])+self:GetCardPip(cbCardData[j])+self:GetCardPip(cbCardData[m]))%10
					--luaPrint("GetCardPip",self:GetCardPip(cbCardData[i]),self:GetCardPip(cbCardData[j]),self:GetCardPip(cbCardData[m]));
					if (self:GetCardPip(cbCardData[i])+self:GetCardPip(cbCardData[j])+self:GetCardPip(cbCardData[m]))%10 == 0 then
						luaPrint("找到牛");
						haveNiu = true;
						local valua = clone(cbCardData[i]);
						table.insert(temp,valua);
						local valua = clone(cbCardData[j]);
						table.insert(temp,valua);
						local valua = clone(cbCardData[m]);
						table.insert(temp,valua);
						stop = true;
						return haveNiu,temp;
					end
				end
			end
			if stop then break end
		end
		if stop then break end
	end
	return haveNiu,temp;
end

--计算牌型
function errenniuniuLogic:getNiuType(cbCardData,cbCardCount)
	--luaPrint("getNiuType",cbCardCount);
	--luaDump(cbCardData,"getNiuType");
	local haveNiu = false;
	local isYinNiu = false;
	local isJinNiu = false;
	local isNiuNiu = false;
	local value = 0; -- 累计牌值

	local temp = {};

	haveNiu,temp = self:foundNiu(cbCardData,cbCardCount);

	--有牛的话判断金牛银牛
	if haveNiu then
		local num = 0;
		for k,v in pairs(cbCardData) do
			if self:GetCardValue(v) >10 then
				num = num + 1;
			end
			value = (value + self:GetCardPip(v))%10;
		end
		if num == 5 and value%10 == 0 then
			isJinNiu = true; --金牛
		elseif num == 4 and value%10 == 0 then
			isYinNiu = true; --银牛
		elseif value == 10 or value == 0 then
			isNiuNiu = true --牛牛
		end
	end
	luaPrint("结果-",haveNiu,value,isNiuNiu,isYinNiu,isJinNiu);
	return haveNiu,value,isNiuNiu,isYinNiu,isJinNiu;
end


--//获取牌点
function errenniuniuLogic:GetCardPip(cbCardData)

	--//计算牌点
	local cbCardValue=self:GetCardValue(cbCardData);
	local cbPipCount=0
	if cbCardValue>= 10 then
		cbPipCount = 10
	else
		cbPipCount = cbCardValue
	end

	return cbPipCount;
end

function errenniuniuLogic:GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end

--//获取牌点
function errenniuniuLogic:GetCardListPip(cbCardData,cbCardCount)
	--//变量定义
	local cbPipCount=0;
	--//获取牌点
	for i=1,cbCardCount do
		cbPipCount=(GetCardPip(cbCardData[i])+cbPipCount)%10;
	end
	return cbPipCount;
end

function errenniuniuLogic:sortCardArr(cbCardData,cbCardCount)
	if cbCardCount == nil then
		cbCardCount = {5,5};
	end
	local dataArray = {};
	for k=1,#cbCardData do
		local msg = self:sortCard(cbCardData[k],cbCardCount[k]);
		table.insert(dataArray,msg);
	end
	return dataArray;
end
--有牛的排序，没牛的随意
function errenniuniuLogic:sortCard(cbCardData,cbCardCount)
	local haveNiu = false;
	local temp = {};
	haveNiu,temp = self:foundNiu(cbCardData,cbCardCount);

	local cardData = {};

	if haveNiu and #temp ~= 3 then
		luaPrint("找牛错误");
		luaDump(temp,"temp");
		return;
	end

	if haveNiu then
		for k,v in pairs(cbCardData) do
			if v ~= temp[1] and v ~= temp[2] and v ~= temp[3] then
				table.insert(cardData,v);
			end
		end
	else
		cardData = clone(cbCardData);
		return cardData;
	end

	if haveNiu then
		for k,v in pairs(temp) do
			table.insert(cardData,v);
		end
	end
	if #cardData == 5 then
		return cardData;
	else
		return cbCardData;
	end
	
end

return errenniuniuLogic
