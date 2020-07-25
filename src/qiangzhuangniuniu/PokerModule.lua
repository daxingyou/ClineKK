local PokerModule = class("PokerModule")

local _pokerModule = nil;

function PokerModule:getInstance()
	if _pokerModule == nil then
		_pokerModule = PokerModule.new();
	end

	return _pokerModule;
end

function PokerModule:ctor()
	self:initData();
end

--初始化相关数据
function PokerModule:initData()
	self.m_byGameStation = GameMsg.GS_FREE;--游戏状态

	self.m_curUser = 0;--开始游戏出牌者

	self.m_byHandCard = {};--手牌

	self.m_recurGameData = {};--恢复场景数据
	self.m_Game_StatisticsMessage= {};--总结算数据
	self.m_cbHandCardData = {} --回放手牌数据
end

function PokerModule:clearData()
	self:initData();
end

function PokerModule:getHandCard(vSeatNo)
	luaPrint("vSeatNo ------------ "..vSeatNo);
	-- luaDump(self.m_byHandCard, "PokerModule:getHandCard")
	local temp = {};

	if not isEmptyTable(self.m_byHandCard) then
		local flag = false;

		for k,v in pairs(self.m_byHandCard) do
			if k == vSeatNo then
				flag = true;
				break;
			end
		end

		if flag == true then
			for k,v in pairs(self.m_byHandCard[vSeatNo]) do
				if v > 0 then
					table.insert(temp, v);
				end				
			end
		end
	end

	return temp;
end

function PokerModule:getLogicCard(value,zhuPai)
	local MASK_VALUE =	0x0F	
	--luaPrint("pppppppppppp",value,zhuPai)							--//数值掩码
	local cbCardValue= bit:_and(value, MASK_VALUE)

	-- //转换数值
	local value = 0;

	-- //王牌扑克
	if cbCardValue>=0x0E then
		value = cbCardValue+3;
	else
		if cbCardValue == zhuPai then
			value = 15;
		elseif cbCardValue == 1  then
			value = 14;
		else
			value = cbCardValue;
		end
	end

	return value;
end

--sortType 0 升序 1 降序
function PokerModule:sortByLogicValue(a, b,zhuPai,sortType)
	
	sortType = 1;--默认就是降序

	local va = self:getLogicCard(a,zhuPai);
	local vb = self:getLogicCard(b,zhuPai);

	if sortType == 0 then
		if va ~= vb then
			return va < vb;
		else
			return a < b;
		end
	else
		if va ~= vb then
			return va > vb;
		else
			return a > b;
		end
	end
	
end

--牌值排序
function PokerModule:sortByHandCard(pokers,zhuPai)
	table.sort(pokers, function(a,b) return self:sortByLogicValue(a,b,zhuPai); end);

end

--牌节点排序
function PokerModule:sortByCardNode(pokerNodes, sortType)
	sortType = sortType or 0;
	table.sort(pokerNodes,
	function(a,b) 
		if sortType == 0 then 
			return a:getIndex() < b:getIndex(); 
		else
			return a:getIndex() > b:getIndex(); 
		end
	end
	)
end

function PokerModule:GetCardValue(value)
	local MASK_VALUE =	0x0F --//数值掩码
	
	if value == nil then
		return 0;
	end

	local cbCardValue= value%16--bit:_and(value, MASK_VALUE)


	
	return cbCardValue;
end

-- //获取花色
function PokerModule:GetCardColor(value)
	local MASK_COLOR  = 0xF0						 --//花色掩码

	local cbCardValue= math.floor(value/16)*16--bit:_and(value, MASK_COLOR);

	return cbCardValue;
end

return PokerModule;
