local cbIndexCount					= 5;--索引变量

local ST_ORDER			 			= 1;--大小排序
local ST_COUNT			 			= 2;--数目排序
local ST_CUSTOM			 			= 3;--自定排序


--//数值掩码
local MASK_COLOR					= 0xF0;								--//花色掩码
local MASK_VALUE					= 0x0F;								--//数值掩码
local MAX_COUNT						=20								    --//最大数目
--//逻辑类型
local CT_ERROR						= 0;									--//错误类型
local CT_SINGLE						= 1;									--//单牌类型
local CT_DOUBLE						= 2;									--//对牌类型
local CT_THREE						= 3;									--//三条类型
local CT_SINGLE_LINE				= 4;									--//单连类型
local CT_DOUBLE_LINE				= 5;									--//对连类型
local CT_THREE_LINE					= 6;									--//三连类型
local CT_THREE_TAKE_ONE				= 7;									--//三带一单
local CT_THREE_TAKE_TWO				= 8;									--//三带一对
local CT_FOUR_TAKE_ONE				= 9;									--//四带两单
local CT_FOUR_TAKE_TWO				= 10;									--//四带两对
local CT_BOMB_CARD					= 11;									--//炸弹类型
local CT_MISSILE_CARD				= 12;									--//火箭类型

local m_cbCardData =
{
	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	--//方块 A - K
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	--//梅花 A - K
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	--//红桃 A - K
	0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,	--//黑桃 A - K
	0x4E,0x4F,
};
--//分析结构
local tagAnalyseResult = class("tagAnalyseResult")

function tagAnalyseResult:ctor()
	self:initData();
end

function tagAnalyseResult:initData()
	self.cbBlockCount = {};--//扑克数目
	self.cbCardData =  {};--//扑克数据

	for i=1,4 do
		self.cbCardData[i-1] = {};
		for j=1,MAX_COUNT do
			self.cbCardData[i-1][j-1] = 0;
		end
	end

	for i =1 ,4 do
		self.cbBlockCount[i-1] = 0;
	end
end
--//出牌结果
local tagOutCardResult = class("tagOutCardResult")

function tagOutCardResult:ctor()
	self:initData();
end

function tagOutCardResult:initData()
	self.cbCardCount = 0;--//扑克数目
	self.cbResultCard =  {};--//扑克数据
	for i=1,MAX_COUNT do
		self.cbResultCard[i-1] = 0;
	end
end
--//分布信息
local tagDistributing = class("tagDistributing")

function tagDistributing:ctor()
	self:initData();
end

function tagDistributing:initData()
	self.cbCardCount = 0;--//扑克数目
	self.cbDistributing =  {};--//扑克数据

	for i=1,15 do
		self.cbDistributing[i-1] = {};
		for j=1,6 do
			self.cbDistributing[i-1][j-1] = 0;
		end
	end
end
--//搜索结果
local tagSearchCardResult = class("tagSearchCardResult")

function tagSearchCardResult:ctor()
	self:initData();
end

function tagSearchCardResult:initData()
	self.cbSearchCount = 0;--//结果数目
	self.cbCardCount =  {};--//扑克数目
	self.cbResultCard =  {};--//结果扑克

	for i=1,MAX_COUNT do
		self.cbCardCount[i-1] = 0;
	end

	for i=1,MAX_COUNT do
		self.cbResultCard[i-1] = {};
		for j=1,MAX_COUNT do
			self.cbResultCard[i-1][j-1] = 0;	
		end
	end
end

local CGameLogic = class("CGameLogic")
--创建逻辑代码对象
function CGameLogic:create()
    return CGameLogic.new();
end

function CGameLogic:ctor()
	
end

function CGameLogic:ZeroMemory(des, count, value)
	if value == nil then
		value = 0;
	end

	for i=1,count do
		des[i - 1] = value;
	end
end

function CGameLogic:CopyMemory(des,desStart, source,sourceStart, count)
	local j = 1;
	local i = 0;

	if desStart == nil then
		desStart = 0;
	end

	local index=0;
	if source[0] == nil then 
		index=1;
	end
	for i = 0,count-1   do
		if j <= count then
			des[i+desStart] = source[i+sourceStart+index];
			i = i +1;
		end

		j = j + 1;
	end
end

function CGameLogic:sizeof(des)
	if type(des) == "table" then
		return table.nums(des);
	end

	return 0;
end
--获取类型
function CGameLogic:GetCardType(cbCardData,cbCardCount)
	--简单牌型
	if cbCardCount == 0 then--空牌
		return CT_ERROR;
	elseif cbCardCount == 1 then--单牌
		return CT_SINGLE;
	elseif cbCardCount == 2 then--对牌火箭
		--//牌型判断
		if (cbCardData[0]==0x4F) and (cbCardData[1]==0x4E) then
			return CT_MISSILE_CARD;
		end
		if self:GetCardLogicValue(cbCardData[0]) == self:GetCardLogicValue(cbCardData[1]) then
			return CT_DOUBLE;
		end
		return CT_ERROR;
	end

	--//分析扑克
	local AnalyseResult = tagAnalyseResult.new();
	AnalyseResult = self:AnalysebCardData(cbCardData,cbCardCount,AnalyseResult);

	--判断四牌变成三带一
	if AnalyseResult.cbBlockCount[3]>0 then
		if AnalyseResult.cbBlockCount[3]*4 == cbCardCount and AnalyseResult.cbBlockCount[3]>1 then--都是4张的3带1
			local cbCardData=AnalyseResult.cbCardData[3][0];
			local cbFirstLogicValue=self:GetCardLogicValue(cbCardData);

			--//错误过虑
			if (cbFirstLogicValue>=15) then 
				return CT_ERROR;
			end

			--判断连牌
			for i=1,AnalyseResult.cbBlockCount[3]-1 do
				local cbCardData=AnalyseResult.cbCardData[3][i*4];
				if (cbFirstLogicValue~=(self:GetCardLogicValue(cbCardData)+i)) then
					return CT_ERROR;
				end
			end

			return CT_THREE_TAKE_ONE;
		end

		--其中有4张一样的 和 3张一样的 3带1
		if AnalyseResult.cbBlockCount[3]*4 + AnalyseResult.cbBlockCount[2]*4 == cbCardCount and AnalyseResult.cbBlockCount[2]>0 and AnalyseResult.cbBlockCount[3]>0 then
			local cbFirstLogicValue1=self:GetCardLogicValue(AnalyseResult.cbCardData[3][0]);
			local cbFirstLogicValue2=self:GetCardLogicValue(AnalyseResult.cbCardData[2][0]);
			--第一个为最大的值
			local cbFirstLogicValue = math.max(cbFirstLogicValue1,cbFirstLogicValue2);

			local cbBlockCount3 = 0;
			local cbBlockCount4 = 0;

			if cbFirstLogicValue == cbFirstLogicValue1 then
				cbBlockCount4 = cbBlockCount4+1;
			else
				cbBlockCount3 = cbBlockCount3+1;
			end

			while cbBlockCount3<AnalyseResult.cbBlockCount[2] or cbBlockCount4<AnalyseResult.cbBlockCount[3] do
				local cbCardData1=AnalyseResult.cbCardData[3][cbBlockCount4*4];
				local cbCardData2=AnalyseResult.cbCardData[2][cbBlockCount3*3];

				local cbCardData = math.max(cbCardData1,cbCardData2);

				local cbBlockCount = cbBlockCount3+cbBlockCount4;

				if cbCardData == cbCardData1 then
					cbBlockCount4 = cbBlockCount4+1;
				else
					cbBlockCount3 = cbBlockCount3+1;
				end
				if cbFirstLogicValue ~= self:GetCardLogicValue(cbCardData)+cbBlockCount then
					return CT_ERROR;
				end
			end

			return CT_THREE_TAKE_ONE;
		end
	end

	--//四牌判断
	if (AnalyseResult.cbBlockCount[3]>0) then
		--//牌型判断
		if ((AnalyseResult.cbBlockCount[3]==1) and (cbCardCount==4)) then 
			return CT_BOMB_CARD;
		end
		if ((AnalyseResult.cbBlockCount[3]==1) and (cbCardCount==6)) then 
			return CT_FOUR_TAKE_ONE;
		end
		if ((AnalyseResult.cbBlockCount[3]==1)and(cbCardCount==8)and(AnalyseResult.cbBlockCount[1]==2)) then 
			return CT_FOUR_TAKE_TWO;
		end
		return CT_ERROR;
	end

	--//三牌判断
	if (AnalyseResult.cbBlockCount[2]>0) then
		--//连牌判断
		if (AnalyseResult.cbBlockCount[2]>1) then
			--//变量定义
			local cbCardData=AnalyseResult.cbCardData[2][0];
			local cbFirstLogicValue=self:GetCardLogicValue(cbCardData);

			--//错误过虑
			if (cbFirstLogicValue>=15) then 
				return CT_ERROR;
			end

			--//连牌判断
			for i=1,AnalyseResult.cbBlockCount[2]-1 do
				local cbCardData=AnalyseResult.cbCardData[2][i*3];
				if (cbFirstLogicValue~=(self:GetCardLogicValue(cbCardData)+i)) then
					return CT_ERROR;
				end
			end
		elseif( cbCardCount == 3 ) then
			return CT_THREE;
		end

		--//牌形判断
		if (AnalyseResult.cbBlockCount[2]*3==cbCardCount) then
			return CT_THREE_LINE;
		end
		if (AnalyseResult.cbBlockCount[2]*4==cbCardCount) then
			return CT_THREE_TAKE_ONE;
		end
		if ((AnalyseResult.cbBlockCount[2]*5==cbCardCount)and(AnalyseResult.cbBlockCount[1]==AnalyseResult.cbBlockCount[2])) then
			return CT_THREE_TAKE_TWO;
		end
		return CT_ERROR;
	end

	--//两张类型
	if (AnalyseResult.cbBlockCount[1]>=3) then
		--//变量定义
		local cbCardData=AnalyseResult.cbCardData[1][0];
		local cbFirstLogicValue=self:GetCardLogicValue(cbCardData);

		--//错误过虑
		if (cbFirstLogicValue>=15) then
			return CT_ERROR;
		end
		--//连牌判断
		for i=1,AnalyseResult.cbBlockCount[1]-1 do
			local cbCardData=AnalyseResult.cbCardData[1][i*2];
			if (cbFirstLogicValue~=(self:GetCardLogicValue(cbCardData)+i)) then
				return CT_ERROR;
			end
		end

		--//二连判断
		if ((AnalyseResult.cbBlockCount[1]*2)==cbCardCount) then
			return CT_DOUBLE_LINE;
		end

		return CT_ERROR;
	end

	--//单张判断
	if ((AnalyseResult.cbBlockCount[0]>=5)and(AnalyseResult.cbBlockCount[0]==cbCardCount)) then
		--//变量定义
		local cbCardData=AnalyseResult.cbCardData[0][0];
		local cbFirstLogicValue=self:GetCardLogicValue(cbCardData);

		--//错误过虑
		if (cbFirstLogicValue>=15) then
			return CT_ERROR;
		end
		--//连牌判断
		for i=1,AnalyseResult.cbBlockCount[0]-1 do
			local cbCardData=AnalyseResult.cbCardData[0][i];
			if (cbFirstLogicValue~=(self:GetCardLogicValue(cbCardData)+i)) then
				return CT_ERROR;
			end
		end

		return CT_SINGLE_LINE;
	end

	return CT_ERROR;
end

--//排列扑克
function CGameLogic:SortCardList(cbCardData,cbCardCount,cbSortType)
	--//数目过虑
	if (cbCardCount==0) then
		return;
	end
	if (cbSortType==ST_CUSTOM) then
		return;
	end

	--//转换数值
	local cbSortValue = {};
	for i = 0,MAX_COUNT-1 do
		cbSortValue[i] = 0;
	end

	for i=0,cbCardCount-1 do
		cbSortValue[i]=self:GetCardLogicValue(cbCardData[i]);
	end

	--//排序操作
	local bSorted=true;
	local cbSwitchData=0;
	local cbLast=cbCardCount-1;
	
	repeat
		bSorted=true;
		for i=0,cbLast-1 do
			if ((cbSortValue[i]<cbSortValue[i+1]) or ((cbSortValue[i]==cbSortValue[i+1])and(cbCardData[i]<cbCardData[i+1]))) then
				--//设置标志
				bSorted=false;

				--//扑克数据
				cbSwitchData=cbCardData[i];
				cbCardData[i]=cbCardData[i+1];
				cbCardData[i+1]=cbSwitchData;

				--//排序权位
				cbSwitchData=cbSortValue[i];
				cbSortValue[i]=cbSortValue[i+1];
				cbSortValue[i+1]=cbSwitchData;
			end	
		end
		cbLast = cbLast - 1;
	until(bSorted==true);

	--//数目排序
	if (cbSortType==ST_COUNT) then
		--//变量定义
		local cbCardIndex=0;

		--//分析扑克
		local AnalyseResult = tagAnalyseResult.new();
		AnalyseResult = self:AnalysebCardData(cbCardData[cbCardIndex],cbCardCount-cbCardIndex,AnalyseResult);

		--//提取扑克
		for i=0,self:sizeof(AnalyseResult.cbBlockCount)-1 do
			--//拷贝扑克
			local cbIndex=self:sizeof(AnalyseResult.cbBlockCount)-i-1;
			self:CopyMemory(cbCardData,cbCardIndex,AnalyseResult.cbCardData[cbIndex],0,AnalyseResult.cbBlockCount[cbIndex]*(cbIndex+1));

			--//设置索引
			cbCardIndex=cbCardIndex+AnalyseResult.cbBlockCount[cbIndex]*(cbIndex+1);
		end
	end

	return;
end

--//删除扑克
function CGameLogic:RemoveCard(cbRemoveCard,cbRemoveCount,cbCardData,cbCardCount)
	--//定义变量
	local cbDeleteCount=0;
	local cbTempCardData = {};
	for i = 0,MAX_COUNT-1 do
		cbTempCardData[i] = 0
	end

	if (cbCardCount>self:sizeof(cbTempCardData)) then 
		return false;
	end
	self:CopyMemory(cbTempCardData,0,cbCardData,0,cbCardCount);

	--//置零扑克
	for i=0,cbRemoveCount-1 do
		for j=0,cbCardCount-1 do
			if (cbRemoveCard[i]==cbTempCardData[j]) then
				cbDeleteCount = cbDeleteCount+1;
				cbTempCardData[j]=0;
				break;
			end
		end
	end
	if (cbDeleteCount~=cbRemoveCount) then
		return false;
	end

	--//清理扑克
	local cbCardPos=0;
	for i=0,cbCardCount-1 do
		if (cbTempCardData[i]~=0) then 
			cbCardData[cbCardPos]=cbTempCardData[i];
			cbCardPos = cbCardPos+1;
		end
	end

	return true;
end

--//排列扑克
function CGameLogic:SortOutCardList(cbCardData,cbCardCount)
	--//获取牌型
	local cbCardType = self:GetCardType(cbCardData,cbCardCount);

	if( cbCardType == CT_THREE_TAKE_ONE or cbCardType == CT_THREE_TAKE_TWO ) then
		--//分析牌
		local AnalyseResult = tagAnalyseResult.new();
		AnalyseResult = self:AnalysebCardData( cbCardData,cbCardCount,AnalyseResult );

		cbCardCount = AnalyseResult.cbBlockCount[2]*3;
		self:CopyMemory( cbCardData,0,AnalyseResult.cbCardData[2],0,cbCardCount );
		for i = self:sizeof(AnalyseResult.cbBlockCount)-1, 0, -1 do
			if( i ~= 2 ) then
				if( AnalyseResult.cbBlockCount[i] > 0 )then
					self:CopyMemory(cbCardData,cbCardCount,AnalyseResult.cbCardData[i],0,(i+1)*AnalyseResult.cbBlockCount[i]);
					cbCardCount = cbCardCount + (i+1)*AnalyseResult.cbBlockCount[i];
				end
			end
		end
	elseif( cbCardType == CT_FOUR_TAKE_ONE or cbCardType == CT_FOUR_TAKE_TWO ) then
		--//分析牌
		local AnalyseResult = tagAnalyseResult.new();
		AnalyseResult = self:AnalysebCardData( cbCardData,cbCardCount,AnalyseResult );

		cbCardCount = AnalyseResult.cbBlockCount[3]*4;
		self:CopyMemory( cbCardData,0,AnalyseResult.cbCardData[3],0,cbCardCount );
		for i = self:sizeof(AnalyseResult.cbBlockCount)-1, 0, -1 do
			if( i ~= 3 ) then
				if( AnalyseResult.cbBlockCount[i] > 0 ) then
					self:CopyMemory(cbCardData,cbCardCount,AnalyseResult.cbCardData[i],0,(i+1)*AnalyseResult.cbBlockCount[i] );
					cbCardCount = cbCardCount + (i+1)*AnalyseResult.cbBlockCount[i];
				end
			end
		end
	end

	return;
end
--//逻辑数值
function CGameLogic:GetCardLogicValue(cbCardData)
	--//扑克属性
	local cbCardColor=self:GetCardColor(cbCardData);
	local cbCardValue=self:GetCardValue(cbCardData);

	--//转换数值
	if (cbCardColor==0x40) then
		return cbCardValue+2;
	end

	if cbCardValue<=2 then
		return cbCardValue+13;
	else
		return cbCardValue;
	end
end

function CGameLogic:GetCardValue(value)
	local MASK_VALUE =	0x0F --//数值掩码
	
	if value == nil then
		return 0;
	end

	local cbCardValue= value%16--bit:_and(value, MASK_VALUE)


	
	return cbCardValue;
end

-- //获取花色
function CGameLogic:GetCardColor(value)
	local MASK_COLOR  = 0xF0						 --//花色掩码
	local cbCardValue= math.floor(value/16)*16--bit:_and(value, MASK_COLOR);

	return cbCardValue;
end

--//对比扑克
function CGameLogic:CompareCard(cbFirstCard,cbNextCard,cbFirstCount,cbNextCount)
	--//获取类型
	local cbNextType=self:GetCardType(cbNextCard,cbNextCount);
	local cbFirstType=self:GetCardType(cbFirstCard,cbFirstCount);

	--//类型判断
	if (cbNextType==CT_ERROR) then
		return false;
	end
	if (cbNextType==CT_MISSILE_CARD) then
		return true;
	end

	if cbFirstType == CT_MISSILE_CARD then
		return false;
	end

	--//炸弹判断
	if ((cbFirstType~=CT_BOMB_CARD)and(cbNextType==CT_BOMB_CARD)) then
		return true;
	end
	if ((cbFirstType==CT_BOMB_CARD)and(cbNextType~=CT_BOMB_CARD)) then
		return false;
	end

	--//规则判断
	if ((cbFirstType~=cbNextType)or(cbFirstCount~=cbNextCount)) then
		return false;
	end

	--//开始对比
	if cbNextType == CT_SINGLE or 
		cbNextType == CT_DOUBLE or 
		cbNextType == CT_THREE or 
		cbNextType == CT_SINGLE_LINE or 
		cbNextType == CT_DOUBLE_LINE or 
		cbNextType == CT_THREE_LINE or 
		cbNextType == CT_BOMB_CARD then

		--//获取数值
		local cbNextLogicValue=self:GetCardLogicValue(cbNextCard[0]);
		local cbFirstLogicValue=self:GetCardLogicValue(cbFirstCard[0]);

		--//对比扑克
		return cbNextLogicValue>cbFirstLogicValue;
	elseif cbNextType == CT_THREE_TAKE_ONE or cbNextType == CT_THREE_TAKE_TWO then
		--//分析扑克
		local NextResult = tagAnalyseResult.new();
		local FirstResult = tagAnalyseResult.new();
		NextResult = self:AnalysebCardData(cbNextCard,cbNextCount,NextResult);
		FirstResult = self:AnalysebCardData(cbFirstCard,cbFirstCount,FirstResult);

		--//获取数值
		local cbNextLogicValue=self:GetCardLogicValue(NextResult.cbCardData[2][0]);
		if NextResult.cbBlockCount[3] > 0 then
			local cbNextLogicValue4 = self:GetCardLogicValue(NextResult.cbCardData[3][0])
			if cbNextLogicValue4>cbNextLogicValue then
				cbNextLogicValue = cbNextLogicValue4;
			end
		end

		local cbFirstLogicValue=self:GetCardLogicValue(FirstResult.cbCardData[2][0]);
		if FirstResult.cbBlockCount[3] > 0 then
			local cbFirstLogicValue4 = self:GetCardLogicValue(FirstResult.cbCardData[3][0])
			if cbFirstLogicValue4>cbFirstLogicValue then
				cbFirstLogicValue = cbFirstLogicValue4;
			end
		end

		--//对比扑克
		return cbNextLogicValue>cbFirstLogicValue;
	elseif cbNextType == CT_FOUR_TAKE_ONE or cbNextType == CT_FOUR_TAKE_TWO then
		--//分析扑克
		local NextResult = tagAnalyseResult.new();
		local FirstResult = tagAnalyseResult.new();
		NextResult = self:AnalysebCardData(cbNextCard,cbNextCount,NextResult);
		FirstResult = self:AnalysebCardData(cbFirstCard,cbFirstCount,FirstResult);

		--//获取数值
		local cbNextLogicValue=self:GetCardLogicValue(NextResult.cbCardData[3][0]);
		local cbFirstLogicValue=self:GetCardLogicValue(FirstResult.cbCardData[3][0]);

		--//对比扑克
		return cbNextLogicValue>cbFirstLogicValue;
	end
	
	return false;
end

--//构造扑克
function CGameLogic:MakeCardData(cbValueIndex, cbColorIndex)
	return bit:_or((bit:_lshift(cbColorIndex,4)),(cbValueIndex+1))
end

--//分析扑克
function CGameLogic:AnalysebCardData(cbCardData, cbCardCount, AnalyseResult)
	--//设置结果
	AnalyseResult = tagAnalyseResult.new();
	--//扑克分析
    local i = 0;
	while i < cbCardCount do
		--//变量定义
		local cbSameCount=1;
		local cbCardValueTemp=0;
		local cbLogicValue=self:GetCardLogicValue(cbCardData[i]);

		--//搜索同牌
		for j=i+1,cbCardCount-1 do
			--//获取扑克
			if (self:GetCardLogicValue(cbCardData[j])~=cbLogicValue) then
				break;
			end
			--//设置变量
			cbSameCount = cbSameCount + 1;
		end

		if(cbSameCount > 4) then
			--//设置结果
			AnalyseResult = tagAnalyseResult.new();
			return AnalyseResult;
		end

		--//设置结果
		local cbIndex=AnalyseResult.cbBlockCount[cbSameCount-1];
		AnalyseResult.cbBlockCount[cbSameCount-1] = AnalyseResult.cbBlockCount[cbSameCount-1]+1
		for j=0,cbSameCount-1 do 
			AnalyseResult.cbCardData[cbSameCount-1][cbIndex*cbSameCount+j]=cbCardData[i+j];
		end

		--//设置索引
		i = i+cbSameCount-1+1;
	end

	return AnalyseResult;
end

--//分析分布
function CGameLogic:AnalysebDistributing(cbCardData,cbCardCount,Distributing)
	--//设置变量
	Distributing = tagDistributing.new();

	--//设置变量
	for i=0,cbCardCount-1 do
		if (cbCardData[i]~=0) then
			--//获取属性
			local cbCardColor=self:GetCardColor(cbCardData[i]);
			local cbCardValue=self:GetCardValue(cbCardData[i]);
			--//分布信息
			Distributing.cbCardCount = Distributing.cbCardCount+1;
			Distributing.cbDistributing[cbCardValue-1][cbIndexCount] = Distributing.cbDistributing[cbCardValue-1][cbIndexCount]+1;
			Distributing.cbDistributing[cbCardValue-1][math.floor(cbCardData[i]/16)] = Distributing.cbDistributing[cbCardValue-1][math.floor(cbCardData[i]/16)]+1;
		end
	end

	return Distributing;
end

--//出牌搜索
function CGameLogic:SearchOutCard(cbHandCardData,cbHandCardCount,cbTurnCardData,cbTurnCardCount)
	--//设置结果
	local pSearchCardResult = tagSearchCardResult.new();

	--//变量定义
	local cbResultCount = 0;
	local tmpSearchCardResult = tagSearchCardResult.new();

	--//构造扑克
	local cbCardData = {};
	for i=0,MAX_COUNT-1 do
		cbCardData[i] = 0
	end

	local cbCardCount=cbHandCardCount;
	self:CopyMemory(cbCardData,0,cbHandCardData,0,cbHandCardCount);

	local otherCard = {};
	self:CopyMemory(otherCard,0,cbTurnCardData,0,cbTurnCardCount);
	cbTurnCardData = otherCard;
	--//排列扑克
	self:SortCardList(cbCardData,cbCardCount,ST_ORDER);
    self:SortCardList(cbTurnCardData,cbTurnCardCount,ST_ORDER);

	--//获取类型
	local cbTurnOutType=self:GetCardType(cbTurnCardData,cbTurnCardCount);
	luaPrint("获取类型",cbTurnOutType);
	--//出牌分析
	if cbTurnOutType == CT_ERROR then--//错误类型
		--//提取各种牌型一组
		if( not pSearchCardResult ) then
			return 0;
		end
		--//是否一手出完
		if self:GetCardType(cbCardData,cbCardCount) ~= CT_ERROR then
			pSearchCardResult.cbCardCount[cbResultCount] = cbCardCount;
			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,cbCardData,0,cbCardCount );
			cbResultCount = cbResultCount+1;
		end

		--//如果最小牌不是单牌，则提取
		local cbSameCount = 0;
		if( cbCardCount > 1 and self:GetCardValue(cbCardData[cbCardCount-1]) == self:GetCardValue(cbCardData[cbCardCount-2]) )then
			cbSameCount = 1;
			pSearchCardResult.cbResultCard[cbResultCount][0] = cbCardData[cbCardCount-1];
			local cbCardValue = self:GetCardValue(cbCardData[cbCardCount-1]);
			for i = cbCardCount-2, 0,-1 do
				if self:GetCardValue(cbCardData[i]) == cbCardValue then
					pSearchCardResult.cbResultCard[cbResultCount][cbSameCount] = cbCardData[i];
					cbSameCount = cbSameCount+1;
				else 
					break;
				end
			end

			pSearchCardResult.cbCardCount[cbResultCount] = cbSameCount;
			cbResultCount=cbResultCount+1;
		end

		--//单牌
		local cbTmpCount = 0;
		if( cbSameCount ~= 1 )then
			cbTmpCount,tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,0,1 );
			if( cbTmpCount > 0 )then
				pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
				self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0]);
				cbResultCount = cbResultCount+1;
			end
		end

		--//对牌
		if( cbSameCount ~= 2 )then
			cbTmpCount,tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,0,2 );
			if( cbTmpCount > 0 )then
				pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
				self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
				cbResultCount=cbResultCount+1;
			end
		end

		--//三条
		if( cbSameCount ~= 3 )then
			cbTmpCount,tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,0,3 );
			if( cbTmpCount > 0 )then
				pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
				self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
				cbResultCount = cbResultCount+1;
			end
		end

		--//三带一单
		cbTmpCount,tmpSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,0,CT_THREE_TAKE_ONE,1 );
		if( cbTmpCount > 0 )then
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
			cbResultCount=cbResultCount+1;
		end

		--//三带一对
		cbTmpCount,tmpSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,0,CT_THREE_TAKE_TWO,2 );
		if( cbTmpCount > 0 )then
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
			cbResultCount=cbResultCount+1;
		end

		--//单连
		cbTmpCount,tmpSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,0,1,0 );
		if( cbTmpCount > 0 )then
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
			cbResultCount=cbResultCount+1;
		end

		--//连对
		cbTmpCount,tmpSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,0,2,0 );
		if( cbTmpCount > 0 )then
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
			cbResultCount=cbResultCount+1;
		end

		--//三连
		cbTmpCount,tmpSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,0,3,0 );
		if( cbTmpCount > 0 )then
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
			self:CopyMemory( pSearchCardResult.cbResultCard,cbResultCount,tmpSearchCardResult.cbResultCard,0,tmpSearchCardResult.cbCardCount[0] );
			cbResultCount=cbResultCount+1;
		end

		--//炸弹
		if( cbSameCount ~= 4 )then
			cbTmpCount,tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,0,4 );
			if( cbTmpCount > 0 )then
				pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[0];
				self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[0],0,tmpSearchCardResult.cbCardCount[0] );
				cbResultCount=cbResultCount+1;
			end
		end

		--//搜索火箭
		if ((cbCardCount>=2)and(cbCardData[0]==0x4F)and(cbCardData[1]==0x4E))then
			--//设置结果
			pSearchCardResult.cbCardCount[cbResultCount] = 2;
			pSearchCardResult.cbResultCard[cbResultCount][0] = cbCardData[0];
			pSearchCardResult.cbResultCard[cbResultCount][1] = cbCardData[1];

			cbResultCount=cbResultCount+1;
		end

		pSearchCardResult.cbSearchCount = cbResultCount;
		return cbResultCount,pSearchCardResult;
	elseif cbTurnOutType == CT_SINGLE or cbTurnOutType == CT_DOUBLE or cbTurnOutType == CT_THREE then--单牌类型 对牌类型 三条类型
		--//变量定义
		local cbReferCard=cbTurnCardData[0];
		local cbSameCount = 1;
		if( cbTurnOutType == CT_DOUBLE )then 
			cbSameCount = 2;
		elseif( cbTurnOutType == CT_THREE ) then
			cbSameCount = 3;
		end
		--//搜索相同牌
		cbResultCount,pSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,cbReferCard,cbSameCount);

	elseif cbTurnOutType == CT_SINGLE_LINE or cbTurnOutType == CT_DOUBLE_LINE or cbTurnOutType == CT_THREE_LINE then--单连类型 对连类型 三连类型
		--//变量定义
		local cbBlockCount = 1;
		if( cbTurnOutType == CT_DOUBLE_LINE ) then
			cbBlockCount = 2;
		elseif( cbTurnOutType == CT_THREE_LINE ) then
			cbBlockCount = 3;
		end
		local cbLineCount = math.floor(cbTurnCardCount/cbBlockCount);

		--//搜索边牌
		cbResultCount,pSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,cbTurnCardData[0],cbBlockCount,cbLineCount );

	elseif cbTurnOutType == CT_THREE_TAKE_ONE or cbTurnOutType == CT_THREE_TAKE_TWO then--三带一单 三带一对
		--//效验牌数
		if( cbCardCount >= cbTurnCardCount ) then
			--//如果是三带一或三带二
			if( cbTurnCardCount == 4 or cbTurnCardCount == 5 )then
				local cbTakeCardCount = 1;
				if cbTurnOutType==CT_THREE_TAKE_ONE then
					cbTakeCardCount = 1;
				else
					cbTakeCardCount = 2;
				end

				--//搜索三带牌型
				cbResultCount,pSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,cbTurnCardData[2],cbTurnOutType,cbTakeCardCount );
			else
				--//变量定义
				local cbBlockCount = 3;

				local tempData = 4;
				if cbTurnOutType==CT_THREE_TAKE_ONE then
					tempData = 4;
				else
					tempData = 5;
				end

				local cbLineCount = math.floor(cbTurnCardCount/tempData);
				local cbTakeCardCount = 1;
				if cbTurnOutType==CT_THREE_TAKE_ONE then
					cbTakeCardCount = 1;
				else
					cbTakeCardCount = 2;
				end

				--//搜索连牌
				local cbTmpTurnCard = {};
				for i=0,MAX_COUNT-1  do
					cbTmpTurnCard[i] = 0;
				end

				self:CopyMemory( cbTmpTurnCard,0,cbTurnCardData,0,cbTurnCardCount );
				self:SortOutCardList( cbTmpTurnCard,cbTurnCardCount );
				cbResultCount,pSearchCardResult = self:SearchLineCardType( cbCardData,cbCardCount,cbTmpTurnCard[0],cbBlockCount,cbLineCount );

				--//提取带牌
				local bAllDistill = true;
				for i = 0, cbResultCount-1 do
					local cbResultIndex = cbResultCount-i-1;

					--//变量定义
					local cbTmpCardData = {};
					for i = 0,MAX_COUNT-1 do
						cbTmpCardData[i] = 0;
					end

					local cbTmpCardCount = cbCardCount;

					--//删除连牌
					self:CopyMemory( cbTmpCardData,0,cbCardData,0,cbCardCount );
					self:RemoveCard( pSearchCardResult.cbResultCard[cbResultIndex],pSearchCardResult.cbCardCount[cbResultIndex],cbTmpCardData,cbTmpCardCount );
					cbTmpCardCount = cbTmpCardCount-pSearchCardResult.cbCardCount[cbResultIndex];

					--//分析牌
					local TmpResult = tagAnalyseResult.new();
					TmpResult = self:AnalysebCardData( cbTmpCardData,cbTmpCardCount,TmpResult );

					--//提取牌
					local cbDistillCard = {};
					for i=0,MAX_COUNT-1 do
						cbDistillCard[i] = 0;
					end

					local cbDistillCount = 0;

					if cbTakeCardCount-1 >=0 then
						for j = cbTakeCardCount-1, self:sizeof(TmpResult.cbBlockCount)-1 do
							if( TmpResult.cbBlockCount[j] > 0 )then
								if( j+1 == cbTakeCardCount and TmpResult.cbBlockCount[j] >= cbLineCount )then
									local cbTmpBlockCount = TmpResult.cbBlockCount[j];
									self:CopyMemory( cbDistillCard,0,TmpResult.cbCardData[j],(cbTmpBlockCount-cbLineCount)*(j+1),(j+1)*cbLineCount );
									cbDistillCount = (j+1)*cbLineCount;
									break;
								else
									for k = 0,  TmpResult.cbBlockCount[j]-1 do
										local cbTmpBlockCount = TmpResult.cbBlockCount[j];
										self:CopyMemory(cbDistillCard,cbDistillCount,TmpResult.cbCardData[j],(cbTmpBlockCount-k-1)*(j+1),cbTakeCardCount );
										cbDistillCount =cbDistillCount + cbTakeCardCount;

										--//提取完成
										if( cbDistillCount == cbTakeCardCount*cbLineCount ) then
											break;
										end
									end
								end
							end

							--//提取完成
							if( cbDistillCount == cbTakeCardCount*cbLineCount ) then
								break;
							end
						end
					end
					--//提取完成
					if( cbDistillCount == cbTakeCardCount*cbLineCount )then
						--//复制带牌
						local cbCount = pSearchCardResult.cbCardCount[cbResultIndex];
						self:CopyMemory( pSearchCardResult.cbResultCard[cbResultIndex],cbCount,cbDistillCard,0,cbDistillCount );
						pSearchCardResult.cbCardCount[cbResultIndex] =pSearchCardResult.cbCardCount[cbResultIndex] + cbDistillCount;
					--//否则删除连牌
					else
						bAllDistill = false;
						pSearchCardResult.cbCardCount[cbResultIndex] = 0;
					end
				end

				--//整理组合
				if( not bAllDistill )then
					pSearchCardResult.cbSearchCount = cbResultCount;
					cbResultCount = 0;
					for i = 0,  pSearchCardResult.cbSearchCount-1 do

						if( pSearchCardResult.cbCardCount[i] ~= 0 )then
							tmpSearchCardResult.cbCardCount[cbResultCount] = pSearchCardResult.cbCardCount[i];
							self:CopyMemory( tmpSearchCardResult.cbResultCard[cbResultCount],0,pSearchCardResult.cbResultCard[i],0,pSearchCardResult.cbCardCount[i] );
							cbResultCount = cbResultCount+1;
						end
					end
					tmpSearchCardResult.cbSearchCount = cbResultCount;
					pSearchCardResult = tmpSearchCardResult;
				end
			end
		end
	elseif cbTurnOutType == CT_FOUR_TAKE_ONE or cbTurnOutType == CT_FOUR_TAKE_TWO then--四带两单 四带两双
		local cbTakeCount = 1;
		if cbTurnOutType==CT_FOUR_TAKE_ONE then
			cbTakeCount = 1;
		else
			cbTakeCount = 2;
		end

		local cbTmpTurnCard = {};
		for i = 0,MAX_COUNT-1 do
			cbTmpTurnCard[i] = 0;
		end

		self:CopyMemory( cbTmpTurnCard,0,cbTurnCardData,0,cbTurnCardCount );
		self:SortOutCardList( cbTmpTurnCard,cbTurnCardCount );

		--//分析扑克
		local AnalyseResult = tagAnalyseResult.new();
		AnalyseResult = self:AnalysebCardData(cbTurnCardData,cbTurnCardCount,AnalyseResult);

		if AnalyseResult.cbBlockCount[1] == 1 then
			cbTakeCount = 2;
		end

		--//搜索带牌
		cbResultCount,pSearchCardResult = self:SearchTakeCardType( cbCardData,cbCardCount,cbTmpTurnCard[0],cbTurnOutType,cbTakeCount );
	end

	--//搜索炸弹
	if ((cbCardCount>=4)and(cbTurnOutType~=CT_MISSILE_CARD)) then
		--//变量定义
		local cbReferCard = 0;
		if (cbTurnOutType==CT_BOMB_CARD) then
			cbReferCard=cbTurnCardData[0];
		end
		--//搜索炸弹
		local cbTmpResultCount,tmpSearchCardResult = self:SearchSameCard( cbCardData,cbCardCount,cbReferCard,4 );
		for i = 0,  cbTmpResultCount-1 do
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSearchCardResult.cbCardCount[i];
			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSearchCardResult.cbResultCard[i],0,tmpSearchCardResult.cbCardCount[i] );
			cbResultCount = cbResultCount+1;
		end
	end

	--//搜索火箭
	if (cbTurnOutType~=CT_MISSILE_CARD and (cbCardCount>=2)and(cbCardData[0]==0x4F)and(cbCardData[1]==0x4E)) then
		--//设置结果
		pSearchCardResult.cbCardCount[cbResultCount] = 2;
		pSearchCardResult.cbResultCard[cbResultCount][0] = cbCardData[0];
		pSearchCardResult.cbResultCard[cbResultCount][1] = cbCardData[1];

		cbResultCount = cbResultCount+1;
	end

	pSearchCardResult.cbSearchCount = cbResultCount;
	return cbResultCount,pSearchCardResult;
end

--//同牌搜索
function CGameLogic:SearchSameCard(cbHandCardData,cbHandCardCount,cbReferCard,cbSameCardCount )
	--//设置结果
	local pSearchCardResult = tagSearchCardResult.new();
	local cbResultCount = 0;

	--//构造扑克
	local cbCardData = {};
	for i=0,MAX_COUNT-1 do
		cbCardData[i] = 0;
	end

	local cbCardCount=cbHandCardCount;
	self:CopyMemory(cbCardData,0,cbHandCardData,0,cbHandCardCount);

	--//排列扑克
	self:SortCardList(cbCardData,cbCardCount,ST_ORDER);

	--//分析扑克
	AnalyseResult = tagAnalyseResult.new();
	AnalyseResult = self:AnalysebCardData( cbCardData,cbCardCount,AnalyseResult );

	local cbReferLogicValue = 0;
	if cbReferCard==0 then
		cbReferLogicValue = 0;
	else
		cbReferLogicValue = self:GetCardLogicValue(cbReferCard);
	end

	local cbBlockIndex = cbSameCardCount-1;
	repeat
		for i = 0,  AnalyseResult.cbBlockCount[cbBlockIndex]-1 do
			local cbIndex = (AnalyseResult.cbBlockCount[cbBlockIndex]-i-1)*(cbBlockIndex+1);
			if( self:GetCardLogicValue(AnalyseResult.cbCardData[cbBlockIndex][cbIndex]) > cbReferLogicValue ) then

				--//复制扑克
				self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,AnalyseResult.cbCardData[cbBlockIndex],cbIndex,cbSameCardCount );
				pSearchCardResult.cbCardCount[cbResultCount] = cbSameCardCount;

				cbResultCount = cbResultCount+1;
			end
		end

		cbBlockIndex = cbBlockIndex+1;
	until( cbBlockIndex >= self:sizeof(AnalyseResult.cbBlockCount) );

	pSearchCardResult.cbSearchCount = cbResultCount;
	return cbResultCount,pSearchCardResult;
end

--//带牌类型搜索(三带一，四带一等)
function CGameLogic:SearchTakeCardType( cbHandCardData, cbHandCardCount, cbReferCard, cbTurnOutType, cbTakeCardCount )
	--//设置结果
	local pSearchCardResult = tagSearchCardResult.new();
	local cbResultCount = 0;

	local cbSameCount = 3;
	if cbTurnOutType == CT_FOUR_TAKE_ONE or cbTurnOutType == CT_FOUR_TAKE_TWO then
		cbSameCount = 4;
	end

	if( cbSameCount ~= 3 and cbSameCount ~= 4 ) then
		return cbResultCount,pSearchCardResult;
	end
	if( cbTakeCardCount ~= 1 and cbTakeCardCount ~= 2 )then
		return cbResultCount,pSearchCardResult;
	end
	--//长度判断
	if cbSameCount == 4 and ((cbTurnOutType == CT_FOUR_TAKE_ONE and cbHandCardCount<cbSameCount+2) or 
		((cbTurnOutType == CT_FOUR_TAKE_TWO and cbHandCardCount<cbSameCount+cbTakeCardCount*2))) then
		return cbResultCount,pSearchCardResult;
	end

	--//构造扑克
	local cbCardData={};
	for i=0,MAX_COUNT-1 do
		cbCardData[i] = 0;
	end

	local cbCardCount=cbHandCardCount;
	self:CopyMemory(cbCardData,0,cbHandCardData,0,cbHandCardCount);

	--//排列扑克
	self:SortCardList(cbCardData,cbCardCount,ST_ORDER);

	--//搜索同张
	local cbSameCardResultCount,SameCardResult = self:SearchSameCard( cbCardData,cbCardCount,cbReferCard,cbSameCount );

	if( cbSameCardResultCount > 0 )then
		--//分析扑克
		AnalyseResult = tagAnalyseResult.new();
		AnalyseResult = self:AnalysebCardData(cbCardData,cbCardCount,AnalyseResult);

		--//需要牌数
		local cbNeedCount = cbSameCount+cbTakeCardCount;
		if( cbSameCount == 4 )then
			if cbTurnOutType == CT_FOUR_TAKE_ONE then 
				cbNeedCount = 6;
			elseif cbTurnOutType == CT_FOUR_TAKE_TWO then
				cbNeedCount = 8;
			end
		end
		--//提取带牌
		for i = 0,  cbSameCardResultCount-1 do
			local bMerge = false;
			if cbTakeCardCount-1>=0 then
				for j = cbTakeCardCount-1,  self:sizeof(AnalyseResult.cbBlockCount)-1 do
					for k = 0,  AnalyseResult.cbBlockCount[j]-1 do
						--//从小到大
						local cbIndex = (AnalyseResult.cbBlockCount[j]-k-1)*(j+1);

						--//过滤相同牌
						if( self:GetCardValue(SameCardResult.cbResultCard[i][0]) ~= self:GetCardValue(AnalyseResult.cbCardData[j][cbIndex]) )then

							--//复制带牌
							local cbCount = SameCardResult.cbCardCount[i];
							self:CopyMemory( SameCardResult.cbResultCard[i],cbCount,AnalyseResult.cbCardData[j],cbIndex,cbTakeCardCount );
							SameCardResult.cbCardCount[i] =SameCardResult.cbCardCount[i] + cbTakeCardCount;

							if( SameCardResult.cbCardCount[i] >= cbNeedCount ) then

								--//复制结果
								self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,SameCardResult.cbResultCard[i],0,SameCardResult.cbCardCount[i] );
								pSearchCardResult.cbCardCount[cbResultCount] = SameCardResult.cbCardCount[i];
								cbResultCount=cbResultCount+1;

								bMerge = true;

								--//下一组合
								break;
							end
						end
					end

					if( bMerge ) then
						break;
					end
				end
			end
		end
	end

	pSearchCardResult.cbSearchCount = cbResultCount;
	return cbResultCount,pSearchCardResult;
end

--//连牌搜索
function CGameLogic:SearchLineCardType(cbHandCardData, cbHandCardCount, cbReferCard, cbBlockCount, cbLineCount)
	--//设置结果
	local pSearchCardResult = tagSearchCardResult.new();
	local cbResultCount = 0;

	--//定义变量
	local cbLessLineCount = 0;
	if cbLineCount == 0 then
		if( cbBlockCount == 1 ) then
			cbLessLineCount = 5;
		elseif( cbBlockCount == 2 ) then
			cbLessLineCount = 3;
		else 
			cbLessLineCount = 2;
		end
	else 
		cbLessLineCount = cbLineCount;
	end

	local cbReferIndex = 2;
	if( cbReferCard ~= 0 ) then
		cbReferIndex = self:GetCardLogicValue(cbReferCard)-cbLessLineCount+1;
	end
	--//超过A
	if( cbReferIndex+cbLessLineCount > 14 )then 
		return cbResultCount,pSearchCardResult;
	end
	--//长度判断
	if( cbHandCardCount < cbLessLineCount*cbBlockCount ) then
		return cbResultCount,pSearchCardResult;
	end
	--//构造扑克
	local cbCardData={};
	for i=0,MAX_COUNT-1 do
		cbCardData[i] = 0
	end

	local cbCardCount=cbHandCardCount;
	self:CopyMemory(cbCardData,0,cbHandCardData,0,cbHandCardCount);

	--//排列扑克
	self:SortCardList(cbCardData,cbCardCount,ST_ORDER);

	--//分析扑克
	local Distributing = tagDistributing.new();
	Distributing = self:AnalysebDistributing(cbCardData,cbCardCount,Distributing);

	--//搜索顺子
	local cbTmpLinkCount = 0;
    cbValueIndex=cbReferIndex;
	while cbValueIndex<13 do
		--//继续判断
		local continue = false;
		if ( Distributing.cbDistributing[cbValueIndex][cbIndexCount]<cbBlockCount )then
			if( cbTmpLinkCount < cbLessLineCount )then
				cbTmpLinkCount=0;
				continue = true;
			else 
				cbValueIndex = cbValueIndex - 1;
                if cbValueIndex < 0 then
                    break;
                end
			end
		else 
			cbTmpLinkCount= cbTmpLinkCount+1;
			--//寻找最长连
			if( cbLineCount == 0 ) then
				continue=true;
			end
		end

		if continue == false then
			if( cbTmpLinkCount >= cbLessLineCount )then
				--//复制扑克
				local cbCount = 0;
				if cbValueIndex+1-cbTmpLinkCount>=0 then
					for cbIndex = cbValueIndex+1-cbTmpLinkCount, cbValueIndex do
						local cbTmpCount = 0;
						for cbColorIndex=0,3 do
							for cbColorCount = 0,  Distributing.cbDistributing[cbIndex][3-cbColorIndex]-1 do
								pSearchCardResult.cbResultCard[cbResultCount][cbCount]=self:MakeCardData(cbIndex,3-cbColorIndex);
								cbCount = cbCount+1;
								cbTmpCount = cbTmpCount+1;
								if( cbTmpCount == cbBlockCount ) then
									break;
								end
							end
							if( cbTmpCount == cbBlockCount ) then
								break;
							end
						end
					end
				end
				--//设置变量
				pSearchCardResult.cbCardCount[cbResultCount] = cbCount;
				cbResultCount=cbResultCount+1;

				if( cbLineCount ~= 0 )then
					cbTmpLinkCount=cbTmpLinkCount-1;
				else 
					cbTmpLinkCount = 0;
				end
			end
		end
		cbValueIndex = cbValueIndex+1;
	end

	--//特殊顺子
	if( cbTmpLinkCount >= cbLessLineCount-1 and cbValueIndex == 13 )then
		if( Distributing.cbDistributing[0][cbIndexCount] >= cbBlockCount or cbTmpLinkCount >= cbLessLineCount )then
			--//复制扑克
			local cbCount = 0;
			local cbTmpCount = 0;

			if cbValueIndex-cbTmpLinkCount >= 0 then
				for cbIndex = cbValueIndex-cbTmpLinkCount, 12 do
					cbTmpCount = 0;
					for cbColorIndex=0,3 do
						for cbColorCount = 0, Distributing.cbDistributing[cbIndex][3-cbColorIndex]-1 do
							pSearchCardResult.cbResultCard[cbResultCount][cbCount]=self:MakeCardData(cbIndex,3-cbColorIndex);
							cbCount = cbCount+1;
							cbTmpCount = cbTmpCount+1;
							if( cbTmpCount == cbBlockCount )then 
								break;
							end
						end
						if( cbTmpCount == cbBlockCount ) then
							break;
						end
					end
				end
			end
			--//复制A
			if( Distributing.cbDistributing[0][cbIndexCount] >= cbBlockCount )then
				cbTmpCount = 0;
				for cbColorIndex=0,3 do
					for cbColorCount = 0, Distributing.cbDistributing[0][3-cbColorIndex]-1 do
						pSearchCardResult.cbResultCard[cbResultCount][cbCount]=self:MakeCardData(0,3-cbColorIndex);
						cbCount = cbCount+1;
						cbTmpCount = cbTmpCount+1;
						if( cbTmpCount == cbBlockCount ) then
							break;
						end
					end
					if( cbTmpCount == cbBlockCount ) then
						break;
					end
				end
			end

			--//设置变量
			pSearchCardResult.cbCardCount[cbResultCount] = cbCount;
			cbResultCount=cbResultCount+1;
		end
	end

	pSearchCardResult.cbSearchCount = cbResultCount;
	return cbResultCount,pSearchCardResult;
end

--//搜索飞机
function CGameLogic:SearchThreeTwoLine(cbHandCardData,cbHandCardCount )
	--//设置结果
	local pSearchCardResult = tagSearchCardResult.new();
	--//变量定义
	local tmpSearchResult = tagSearchCardResult.new();
	local tmpSingleWing = tagSearchCardResult.new();
	local tmpDoubleWing = tagSearchCardResult.new();
	local cbTmpResultCount = 0;

	--//搜索连牌
	cbTmpResultCount,tmpSearchResult = self:SearchLineCardType( cbHandCardData,cbHandCardCount,0,3,0 );

	if( cbTmpResultCount > 0 )then
		--//提取带牌
		for i = 0, cbTmpResultCount-1 do
			--//变量定义
			local cbTmpCardData={};
			for i =0,MAX_COUNT-1 do
				cbTmpCardData[i] = 0
			end

			local cbTmpCardCount = cbHandCardCount;
			local continue = false;

			--//不够牌
			if( cbHandCardCount-tmpSearchResult.cbCardCount[i] < math.floor(tmpSearchResult.cbCardCount[i]/3) )then
				local cbNeedDelCount = 3;
				while( cbHandCardCount+cbNeedDelCount-tmpSearchResult.cbCardCount[i] < math.floor((tmpSearchResult.cbCardCount[i]-cbNeedDelCount)/3) )do
					cbNeedDelCount=cbNeedDelCount + 3;
				end
				--//不够连牌
				if( math.floor((tmpSearchResult.cbCardCount[i]-cbNeedDelCount)/3) < 2 )then
					--//废除连牌
					continue = true;
				end

				if continue == false then
					--//拆分连牌
					self:RemoveCard( tmpSearchResult.cbResultCard[i],cbNeedDelCount,tmpSearchResult.cbResultCard[i],tmpSearchResult.cbCardCount[i] );
					tmpSearchResult.cbCardCount[i] =tmpSearchResult.cbCardCount[i]- cbNeedDelCount;
				end
			end

			if continue == false then
				--//删除连牌
				self:CopyMemory( cbTmpCardData,0,cbHandCardData,0,cbHandCardCount );
				self:RemoveCard( tmpSearchResult.cbResultCard[i],tmpSearchResult.cbCardCount[i],cbTmpCardData,cbTmpCardCount ) ;
				cbTmpCardCount =cbTmpCardCount- tmpSearchResult.cbCardCount[i];

				--//组合飞机
				local cbNeedCount = math.floor(tmpSearchResult.cbCardCount[i]/3);

				local cbResultCount = tmpSingleWing.cbSearchCount;
				tmpSingleWing.cbSearchCount = tmpSingleWing.cbSearchCount+1;
				self:CopyMemory( tmpSingleWing.cbResultCard[cbResultCount],0,tmpSearchResult.cbResultCard[i],0,tmpSearchResult.cbCardCount[i] );
				self:CopyMemory(tmpSingleWing.cbResultCard[cbResultCount],tmpSearchResult.cbCardCount[i],cbTmpCardData,cbTmpCardCount-cbNeedCount,cbNeedCount );
				tmpSingleWing.cbCardCount[i] = tmpSearchResult.cbCardCount[i]+cbNeedCount;

				local continue1 = false;
				--//不够带翅膀
				if( cbTmpCardCount < math.floor(tmpSearchResult.cbCardCount[i]/3)*2 )then
					local cbNeedDelCount = 3;
					while( cbTmpCardCount+cbNeedDelCount-tmpSearchResult.cbCardCount[i] < math.floor((tmpSearchResult.cbCardCount[i]-cbNeedDelCount)/3)*2 )do
						cbNeedDelCount =cbNeedDelCount+ 3;
					end
					--//不够连牌
					if( math.floor((tmpSearchResult.cbCardCount[i]-cbNeedDelCount)/3) < 2 )then
						--//废除连牌
						continue1 = true;
					end

					if continue1 == false then
						--//拆分连牌
						self:RemoveCard( tmpSearchResult.cbResultCard[i],cbNeedDelCount,tmpSearchResult.cbResultCard[i],tmpSearchResult.cbCardCount[i] );
						tmpSearchResult.cbCardCount[i] =tmpSearchResult.cbCardCount[i]- cbNeedDelCount;

						--//重新删除连牌
						self:CopyMemory( cbTmpCardData,0,cbHandCardData,0,cbHandCardCount );
						self:RemoveCard( tmpSearchResult.cbResultCard[i],tmpSearchResult.cbCardCount[i],cbTmpCardData,cbTmpCardCount );
						cbTmpCardCount = cbHandCardCount-tmpSearchResult.cbCardCount[i];
					end
				end
				if continue1 == false then
					--//分析牌
					TmpResult = tagAnalyseResult.new();
					TmpResult = self:AnalysebCardData( cbTmpCardData,cbTmpCardCount,TmpResult );

					--//提取翅膀
					local cbDistillCard = {};
					for i=0,MAX_COUNT-1 do
						cbDistillCard[i] = 0;
					end

					local cbDistillCount = 0;
					local cbLineCount = math.floor(tmpSearchResult.cbCardCount[i]/3);
					for j = 1, self:sizeof(TmpResult.cbBlockCount)-1 do
						if( TmpResult.cbBlockCount[j] > 0 )then
							if( j+1 == 2 and TmpResult.cbBlockCount[j] >= cbLineCount )then
								local cbTmpBlockCount = TmpResult.cbBlockCount[j];
								self:CopyMemory( cbDistillCard,0,TmpResult.cbCardData[j],(cbTmpBlockCount-cbLineCount)*(j+1),(j+1)*cbLineCount );
								cbDistillCount = (j+1)*cbLineCount;
								break;
							else
								for k = 0, TmpResult.cbBlockCount[j]-1 do
									local cbTmpBlockCount = TmpResult.cbBlockCount[j];
									self:CopyMemory( cbDistillCard,cbDistillCount,TmpResult.cbCardData[j],(cbTmpBlockCount-k-1)*(j+1),2 );
									cbDistillCount =cbDistillCount+ 2;

									--//提取完成
									if( cbDistillCount == 2*cbLineCount )then 
										break;
									end
								end
							end
						end

						--//提取完成
						if( cbDistillCount == 2*cbLineCount ) then
							break;
						end
					end

					--//提取完成
					if( cbDistillCount == 2*cbLineCount )then
						--//复制翅膀
						cbResultCount = tmpDoubleWing.cbSearchCount;
						tmpDoubleWing.cbSearchCount = tmpDoubleWing.cbSearchCount+1
						self:CopyMemory( tmpDoubleWing.cbResultCard[cbResultCount],0,tmpSearchResult.cbResultCard[i],0,tmpSearchResult.cbCardCount[i] );
						self:CopyMemory( tmpDoubleWing.cbResultCard[cbResultCount],tmpSearchResult.cbCardCount[i],cbDistillCard,0,cbDistillCount );
						tmpDoubleWing.cbCardCount[i] = tmpSearchResult.cbCardCount[i]+cbDistillCount;
					end
				end
			end
		end

		--//复制结果
		for i = 0, tmpDoubleWing.cbSearchCount-1 do
			local cbResultCount = pSearchCardResult.cbSearchCount;
			pSearchCardResult.cbSearchCount= pSearchCardResult.cbSearchCount+1;

			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpDoubleWing.cbResultCard[i],0,tmpDoubleWing.cbCardCount[i] );
			pSearchCardResult.cbCardCount[cbResultCount] = tmpDoubleWing.cbCardCount[i];
		end
		for i = 0, tmpSingleWing.cbSearchCount-1 do
			local cbResultCount = pSearchCardResult.cbSearchCount;
			pSearchCardResult.cbSearchCount = pSearchCardResult.cbSearchCount+1;

			self:CopyMemory( pSearchCardResult.cbResultCard[cbResultCount],0,tmpSingleWing.cbResultCard[i],0,tmpSingleWing.cbCardCount[i] );
			pSearchCardResult.cbCardCount[cbResultCount] = tmpSingleWing.cbCardCount[i];
		end
	end

	return pSearchCardResult.cbSearchCount,pSearchCardResult;
end

return CGameLogic;