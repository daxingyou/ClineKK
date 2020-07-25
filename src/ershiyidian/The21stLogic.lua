--local The21stLogic = {};
--/////////////////////////////////////////////////////////////////////////
--//宏定义

local MAX_COUNT	=				11									--//最大数目
local FULL_COUNT	=				52									--//扑克数目

--//数值掩码
local LOGIC_MASK_COLOR	=		0xF0								--//花色掩码
local LOGIC_MASK_VALUE	=		0x0F								--//数值掩码

--//扑克类型
local CT_BAOPAI			=		1									--//爆牌
local CT_BJ				=		22									--//黑杰克
local CT_SAN_QI			=		30									--//777

--//////////////////////////////////////////////////////////////////////////

-- The21stLogic.tagAnalyseResult = 
-- {
-- 	{"cbCardACount","BYTE"}, 											--//A数目
-- 	{"cbCardNormalCount","BYTE"}, 										--//其它牌数目
-- 	{"cbCardNormal","BYTE["..The21stLogic.MAX_COUNT.."]"},				--//其它牌数值
-- }

local tagAnalyseResult = class("tagAnalyseResult")

function tagAnalyseResult:ctor()
	self:initData();
end

function tagAnalyseResult:initData()
	self.cbCardACount = 0;--//扑克数目
	self.cbCardNormalCount = 0;--//扑克数据
	self.cbCardNormal = {};--//其它牌数值
	for i=1,MAX_COUNT do
		self.cbCardNormal[i] = 0;
	end
end


local The21stLogic = class("The21stLogic")
local PokerCommonDefine = require("ershiyidian.PokerCommonDefine");

function The21stLogic:create()
    return The21stLogic.new();
end

function The21stLogic:ctor()
	--self.m_cbMainValue = 2;
end

--//////////////////////////////////////////////////////////////////////////
--//获取类型
function The21stLogic:GetCardType(cbCardData,cbCardCount,bSplitCard)
	local isMaxA = false;--是否把A算做了最大值
	local cbCardValue_bao = 0;--爆牌的时候或者是黑杰克的时候记录牌值
	--//分析牌
	local AnalyseResult = tagAnalyseResult.new();
	--ZeroMemory(&AnalyseResult,sizeof(tagAnalyseResult));
	AnalyseResult = self:AnalysebCardData(cbCardData,cbCardCount,AnalyseResult);
	--luaDump(AnalyseResult,"AnalyseResult");

	local cbCardValue = 0;

	for i = 1, AnalyseResult.cbCardNormalCount do
		cbCardValue = cbCardValue+self:GetCardLogicValue(AnalyseResult.cbCardNormal[i]);
	end

	for i = 1, AnalyseResult.cbCardACount do
		if( cbCardValue + 11 > 21 ) then
			cbCardValue=cbCardValue+1;
		else 
			cbCardValue = cbCardValue+11;
			isMaxA = true;
		end
	end

	if cbCardValue > 21 and isMaxA then
		cbCardValue = cbCardValue-10;
		isMaxA = false;
	end
	
	--//爆牌
	if(cbCardValue > 21) then
		-- luaPrint("爆牌",cbCardValue);
		cbCardValue_bao = cbCardValue;
		return PokerCommonDefine.Poker_Value_Type.CT_BAOPAI,cbCardValue_bao,isMaxA;
	end

	--//BJ
	if( AnalyseResult.cbCardACount + AnalyseResult.cbCardNormalCount == 2 and cbCardValue == 21 and not bSplitCard ) then
		-- luaPrint("黑夹克",cbCardValue);
		cbCardValue_bao = cbCardValue;
		return PokerCommonDefine.Poker_Value_Type.CT_BJ,cbCardValue_bao,isMaxA;
	end

	-- //N小龙
	-- //if( cbCardCount >= 5 )
	-- //	return CT_BJ+cbCardCount-4;

	-- ////777
	-- //if( cbCardValue == 21 && AnalyseResult.cbCardNormalCount == 3 && 
	-- //	(AnalyseResult.cbCardNormal[0]&0x0F)==7 && (AnalyseResult.cbCardNormal[1]&0x0F)==7 &&
	-- //	(AnalyseResult.cbCardNormal[2]&0x0F)==7 )
	-- //	return CT_SAN_QI;
	--luaPrint("不是黑夹克",cbCardValue);
	return cbCardValue,cbCardValue_bao,isMaxA; --返回牌型值，牌值，是否A算11
end

--//混乱扑克


--//逻辑数值
function The21stLogic:GetCardLogicValue(cbCardData)

	--//扑克属性
	local bCardValue=self:GetCardValue(cbCardData);
	--luaPrint("bCardValue",bCardValue);

	--//转换数值
	if( bCardValue == 1 ) then 
		return 11; 
	end
	if bCardValue>=0x0A then
		return 10;
	else
		return bCardValue;
	end
	--return (bCardValue>=0x0A)?10:bCardValue;
end

--//分析扑克
function The21stLogic:AnalysebCardData(cbCardData,cbCardCount,AnalyseResult)

	local AnalyseResult = tagAnalyseResult.new();
	
	--//设置结果
	--ZeroMemory(&AnalyseResult,sizeof(tagAnalyseResult));

	--//扑克分析
	for i = 1, cbCardCount do
		local continue = true;
		if(self:GetCardLogicValue(cbCardData[i]) == 11) then
			AnalyseResult.cbCardACount=AnalyseResult.cbCardACount+1;
			continue = false;
		end
		if continue then
			AnalyseResult.cbCardNormal[AnalyseResult.cbCardNormalCount+1] = cbCardData[i];
			AnalyseResult.cbCardNormalCount = AnalyseResult.cbCardNormalCount+1;
		end
	end
	return AnalyseResult;
end

function The21stLogic:GetCardValue(cbCardData)  
	return bit:_and(cbCardData,0x0F);--cbCardData&LOGIC_MASK_VALUE; 
end


return The21stLogic