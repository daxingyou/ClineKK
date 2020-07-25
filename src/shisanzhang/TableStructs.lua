---------- 枚举定义 ----------

-- 游戏提示
GTipEnum = {
	GTip_NoTips               	= 0,    --无
	GTip_Pls_Outcard          	= 1,    --请出牌
	GTip_Start_VScard         	= 2,    --比牌
	GTip_Start_VScard_Spec	  	= 3,  	--有特殊牌的比牌
	GTip_Start_VScard_End     	= 4,	--断线重连的比牌
	GTip_Start_VScard_Spec_End 	= 5,	--有特殊牌断线重连的比牌
	GTip_Wait_Next 				= 6,	--等待下局开始
}

-- 牌型
PaiXinEnum = {
	SINGLE        = 0,		--单张
	PAIRS         = 1,		--一对
	TWOPAIRS      = 2,		--两对
	TRIPLES       = 3,		--三条
	STRAIGHT      = 4,		--顺子
	FLUSH         = 5,		--同花
	FULLHOUSE     = 6,		--葫芦
	FOUR   				= 7,		--四条
	GRANDSTRAIGHT = 8,		--同花顺
	FIVE    			= 9			--五同
}

--蹲位
DunPosition = {
	FIRST = 0,
	MID 	= 1,
	LAST  = 2
}

--场景类型
SceneEnum = {
	XIPAI 				= 0,				--洗牌
	DINGNT 				= 1, 				--定庄
	FAPAI 				= 2,				--发牌
	BAIPAI 				= 3,				--摆牌
	BAIPAIFINISH 	= 4,				--摆牌结束
	BIPAI 				= 5,				--比牌
	RESULT 				= 6,				--把结果
	TESHURESULT		=	7					--特殊把结果
}

SpecialCardTypeEnum = {
	QingLong				= 1,						--清龙
	YiTiaoLong			= 2,							--一条龙
	SanTongHuaShun	= 3,					--三同花顺
	SanFenTianXia		= 4,					--三分天下
	SiTaoSanTiao		= 5,						--四套三条
	LiuDuiBan				= 6,							--六对半
	SanShunZi				= 7,							--三顺子
	SanTongHua			= 8,							--三同花
}

---------- 结构体定义 ----------

CardData = class("CardData")

function CardData:ctor()
	self.bColor = EXCEPTIONCARD --花色
	self.bValue = EXCEPTIONCARD --实际数值
	self.bIndex = EXCEPTIONCARD --索引值

	setmetatable(self, {__lt = CardData.__lt, __eq = CardData.__eq})
	
end

function CardData.__lt(e1, e2)
	
	local v1 = (e1.bValue==1 and 14 or e1.bValue)
	local v2 = (e2.bValue==1 and 14 or e2.bValue)
	
	return (v1 < v2)
	
	-- local bResult = true
	-- if e1.bValue > e2.bValue then
	-- 	if e2.bValue ~= 1 then
	-- 		bResult = false
	-- 	end
	-- elseif e1.bValue==e2.bValue then
	-- 	if e1.bIndex >= e2.bIndex then
	-- 		bResult = false
	-- 	end
	-- elseif e1.bValue == 1 then
	-- 	bResult = false
	-- end

	-- return bResult
end

function CardData.__eq(e1, e2)
	local bResult = false

	if e1.bValue==e2.bValue then
		bResult = true
	end

	return bResult
end


-- 对子
PairsData = class("PairsData")
function PairsData:ctor()
	self.cd = {}
	for i=1, 2 do
		self.cd[i]=CardData.new()
	end
end
-- 单牌
DanData = class("DanData")
function DanData:ctor()
	self.cd = {}
	for i=1, 1 do
		self.cd[i]=CardData.new()
	end
end
-- 两对
TPairsData = class("TPairsData")
function TPairsData:ctor()
	self.pd = {}
	for i=1, 2 do
		self.pd[i]=PairsData.new()
	end
end
-- 三条
TriplesData = class("TriplesData")
function TriplesData:ctor()
	self.cd = {}
	for i=1, 3 do
		self.cd[i]=CardData.new()
	end
end
-- 四条
FourData = class("FourData")
function FourData:ctor()
	self.cd = {}
	for i=1, 4 do
		self.cd[i]=CardData.new()
	end
end
-- 五条
FiveData = class("FiveData")
function FiveData:ctor()
	self.cd = {}
	for i=1, 5 do
		self.cd[i]=CardData.new()
	end
end
-- 顺子
StaightData = class("StaightData")
function StaightData:ctor()
	self.cd = {}
	for i=1, 5 do
		self.cd[i]=CardData.new()
	end
end

-- 牌型
PaiXinData = class("PaiXinData")
function PaiXinData:ctor()
	self.ePXE = PaiXinEnum.SINGLE  --牌型
	self.bMax = 0 --最大点数
end

-- 牌型组合
PaiXinZuHe = class("PaiXinZuHe")
function PaiXinZuHe:ctor()
	self.pxe = PaiXinEnum.SINGLE --牌型
	self.dp = DunPosition.new() --位置
	self.baIndex = {}
	for i=1, OTHERDUNCOUNT do
		baIndex[i] = 0
	end
	self.bMax = 0xff --最大点数

	setmetatable(self, {__lt = PaiXinZuHe.__lt, __eq = PaiXinZuHe.__eq})
	
end

function PaiXinZuHe:__lt(e1, e2)
	local bResult = false

	local cbaComp1 = {}
	local cbaComp2 = {}

	for i=1, OTHERDUNCOUNT do
		if e1.baIndex[i]>0 then
			table.insert(cbaComp1, e1.baIndex[i])
		end

		if e2.baIndex[i]>0 then
			table.insert(cbaComp2, e2.baIndex[i])
		end

		local iRet = CardLogic.DunCompare(cbaComp1, cbaComp2)

		if iRet==0xff then
			bResult = true
		end

		return bResult
	end
end

function PaiXinZuHe:__eq(e1, e2)
	local bResult = false

	if e1.pxe == e2.pxe then
		bResult = true
	end
	return bResult
end



-- 一个完整的牌型结构
-- PaXinZuHeList = class("PaXinZuHeList")
-- function PaXinZuHeList:ctor()
-- 	self.last = PaiXinZuHe.new()
-- 	self.mid = PaiXinZuHe.new()
-- 	self.first = PaiXinZuHe.new()
-- end

-- function PaXinZuHeList:__lt(e1, e2)
-- 	local bResult = false

-- 	if e1.last > e2.last then
-- 		bResult = true
-- 	elseif e1.last == e2.last then
-- 		if e1.mid > e2.mid then
-- 			bResult = true
-- 		elseif e1.mid == e2.mid then
-- 			if e1.first > e2.first then
-- 				bResult = true
-- 			end
-- 		end
-- 	end

-- 	return bResult
-- end

-- function PaXinZuHeList:__eq(e1, e2)
-- 	local bResult = false

-- 	if e1.last.pxe == e2.last.pxe and e1.mid.pxe == e2.mid.pxe and e1.first.pxe == e2.first.pxe then
-- 		bResult = true
-- 	end

-- 	return bResult
-- end

-- 比牌数据
-- BiPaiCardData = class("BiPaiCardData")
-- function BiPaiCardData:ctor()
-- 	self.bFirst = {}
-- 	self.bMid = {}
-- 	self.bLast = {}
-- end

-- 手中牌
HandCard = class("HandCard")
HandCard.Pos = {
	FIRST = 0,		--前蹲
	MID 	= 1,		--中蹲
	LAST 	= 2,		--后蹲
	HAND  = 3			--手中
}
function HandCard:ctor()
	self.bValue = EXCEPTIONCARD --实际数值
	self.bIndex = EXCEPTIONCARD	--索引值
	self.bUp    = false  			  --是否点击
	self.ePt    = HandCard.Pos.HAND --位置

	setmetatable(self, {__lt = HandCard.__lt, __eq = HandCard.__eq})
end
function HandCard.__lt(e1, e2)
	local v1 = (e1.bValue==1 and 14 or e1.bValue)
	local v2 = (e2.bValue==1 and 14 or e2.bValue)

	return (v1 < v2)
end

function HandCard.__eq(e1, e2)
	local bResult = false

	if e1.bValue==e2.bValue then
		bResult = true
	end

	return bResult
end

