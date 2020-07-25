local LZLogic = {};

local LZType = {
	flat = 0,
	player = 1,
	master = 2,
}

local LZColor = {--大路颜色
	player = 1,
	master = 2,
	playerFlat = 3,
	masterFlat = 4,
}

local TLZColor = {--下三路颜色
	blue = 1,
	red = 2,
}

--大路排序
function LZLogic:GetBigWayList(msg,MaxHeight)
	local msg = clone(msg);

	local dataDeal = {};

	--最多几行转弯参数
	if MaxHeight == nil then
		MaxHeight = 5;
	end

	for i = 1,#msg do
		if i == 1 then
			dataDeal[1] = {};
			dataDeal[1][1] = msg[i];
			msg[i].point = cc.p(1,1);--记录点的位置
			msg[i].count = 1;--记录相同的个数
			msg[i].color = self:SetColor(msg[i]);
		else
			if self:JudgeSamePoint(msg[i],msg[i-1]) then--相同的类型
				local point = msg[i-1].point;
				if dataDeal[point.x][point.y+1] == nil and point.y < MaxHeight then--优先先竖着加
					dataDeal[point.x][point.y+1] = msg[i];
					msg[i].point = cc.p(point.x,point.y+1);
				else
					if dataDeal[point.x+1] == nil then
						dataDeal[point.x+1] = {};
					end
					dataDeal[point.x+1][point.y] = msg[i];
					msg[i].point = cc.p(point.x+1,point.y);
				end
				msg[i].count = msg[i-1].count+1;
				msg[i].color = self:SetColor(msg[i],msg[i-1]);
			else
				local point  = msg[i - msg[i-1].count].point;
				if dataDeal[point.x+1] == nil then
					dataDeal[point.x+1] = {};
				end

				dataDeal[point.x+1][point.y] = msg[i];
				msg[i].point = cc.p(point.x+1,point.y);
				msg[i].count = 1;
				msg[i].color = self:SetColor(msg[i]);
			end

		end
		msg[i].lastFlag = false;

		if i == #msg then
			msg[i].lastFlag = true;
		end

	end

	-- luaDump(dataDeal,"排序");
	return dataDeal;
end

function LZLogic:GetType(msg)
	if msg.iWinner == 0 then
		return LZType.master;
	elseif msg.iWinner == 1 then
		return LZType.player;
	end
end

--1闲 2 庄 0 平
function LZLogic:JudgeSamePoint(msg,leftMsg)
	local msgType = self:GetType(msg);
	local leftMsgType = self:GetType(leftMsg);

	if msgType == 0 then--平时返回true
		return true;
	else
		if msgType == leftMsgType then--2个值相同返回true
			return true;
		else
			if leftMsgType == LZType.flat then--如果前个平的颜色跟当前颜色相同返回true
				local msgColor = self:SetColor(msg);
				if (leftMsg.color == LZColor.playerFlat and msgColor == LZColor.player) or (leftMsg.color == LZColor.masterFlat and msgColor == LZColor.master) then--闲
					return true;
				else
					return false;
				end

			else
				return false;
			end
		end
	end
end

--设置颜色
function LZLogic:SetColor(msg,leftMsg)
	local msgType = self:GetType(msg);
	if msgType == LZType.flat then--如果是平则判断跟上个颜色一样
		if leftMsg then
			if leftMsg.color == LZColor.player or leftMsg.color == LZColor.playerFlat then
				return LZColor.playerFlat;
			else
				return LZColor.masterFlat;
			end
		else--第一个默认闲平
			return LZColor.playerFlat;
		end
	else
		if msgType == LZType.player then--闲
			return LZColor.player;
		else
			return LZColor.master;
		end
	end
end

--珠路
function LZLogic:GetZLWayList(msg,MaxHeight)
	local dataDeal = {};

	if MaxHeight == nil then
		MaxHeight = 5;
	end

	for i = 1,#msg do
		if dataDeal[math.floor((i-1)/MaxHeight)+1] == nil then
			dataDeal[math.floor((i-1)/MaxHeight)+1] = {};
		end

		local temp = {};

		temp.type = self:GetType(msg[i]);
		temp.lastFlag = false;

		if i == #msg then
			temp.lastFlag = true;
		end

		dataDeal[math.floor((i-1)/MaxHeight)+1][(i-1)%MaxHeight+1] = temp;
	end

	return dataDeal;
end


--下3路的排序
function LZLogic:SortThreeOtherWay(msg)
	local msg = clone(msg);

	local dataDeal = {};

	--将数据排成一列
	for i = 1,#msg do
		if i == 1 then
			dataDeal[1] = msg[i];
			msg[i].point = cc.p(1,1);--记录点的位置
			msg[i].count = 1;--记录相同的个数
			msg[i].tpoint = cc.p(1,1);
			msg[i].color = self:SetColor(msg[i]);
		else
			if self:JudgeSamePoint(msg[i],msg[i-1]) then--相同的类型
				local point = msg[i-1].point;

				table.insert(dataDeal,msg[i]);
				msg[i].point = cc.p(point.x,point.y+1);

				msg[i].count = msg[i-1].count+1;
				msg[i].tpoint = msg[i].point;
				msg[i].color = self:SetColor(msg[i],msg[i-1]);
			else
				local point  = msg[i - msg[i-1].count].point;

				table.insert(dataDeal,msg[i]);
				msg[i].point = cc.p(point.x+1,point.y);
				msg[i].count = 1;
				msg[i].tpoint = cc.p(msg[i-1].point.x,msg[i-1].point.y+1);
				msg[i].color = self:SetColor(msg[i]);
			end

		end
	end

	-- luaDump(dataDeal,"下3路的排序");


	return dataDeal;
end

--获取大眼仔路 startPoint 2大眼仔路 3小路 4曱甴路
function LZLogic:GetThreeWayList(msg,startPoint,MaxHeight)
	local dataDeal = {};

	--起始点
	if startPoint == nil then
		startPoint = 2;
	end

	--最多几行转弯参数
	if MaxHeight == nil then
		MaxHeight = 3;
	end

	local msg = clone(msg);
	local msg = self:SortThreeOtherWay(msg);

	for i = 1,#msg do
		if msg[i].point.x >= startPoint and (msg[i].point.y>1 or msg[i].point.x > startPoint) then
			local temp = {};
			for k,v in pairs(msg) do--临时保存
				if v.point.x == msg[i].tpoint.x-startPoint+1 then
					table.insert(temp,v);
				end
			end

			local color = self:JudgeThreeWayColor(msg[i],temp);
			if #dataDeal == 0 then
				dataDeal[1] = {};
				dataDeal[1][1] = msg[i];
				msg[i].lastPoint = cc.p(1,1);--记录点的位置
				msg[i].lastCount = 1;--记录相同的个数
				msg[i].color = color;
			else
				if msg[i-1].color == color then
					local point = msg[i-1].lastPoint;
					if dataDeal[point.x][point.y+1] == nil and point.y < MaxHeight then--优先先竖着加
						dataDeal[point.x][point.y+1] = msg[i];
						msg[i].lastPoint = cc.p(point.x,point.y+1);
					else
						if dataDeal[point.x+1] == nil then
							dataDeal[point.x+1] = {};
						end
						dataDeal[point.x+1][point.y] = msg[i];
						msg[i].lastPoint = cc.p(point.x+1,point.y);
					end
					msg[i].lastCount = msg[i-1].lastCount+1;
					msg[i].color = color;
				else
					local point  = msg[i - msg[i-1].lastCount].lastPoint;
					if dataDeal[point.x+1] == nil then
						dataDeal[point.x+1] = {};
					end

					dataDeal[point.x+1][point.y] = msg[i];
					msg[i].lastPoint = cc.p(point.x+1,point.y);
					msg[i].lastCount = 1;
					msg[i].color = color;
				end
			end

			msg[i].lastFlag = false;

			if i == #msg then
				msg[i].lastFlag = true;
			end
		end
	end
	-- luaDump(dataDeal,"下三路路子显示");

	return dataDeal,msg;
end

--判断下三路的颜色条件
function LZLogic:JudgeThreeWayColor(msg,leftMsgTable)
	local point = msg.tpoint;
	local color = 0;

	--拍拍连
	if leftMsgTable[point.y] then
		color = TLZColor.red;
	else
		if leftMsgTable[point.y-1] then--一厅两房
			color = TLZColor.blue;
		else--长闲
			color = TLZColor.red;
		end
	end

	if msg.point.y == 1 then--路头牌
		if color == TLZColor.blue then--交换颜色
			color = TLZColor.red;
		else
			color = TLZColor.blue;
		end

	end

	return color;
end


--获取庄问路 闲问路 typeWay1庄 2闲
function LZLogic:GetFutureWay(msg,typeWay,startPoint)
	local msg = clone(msg);

	--模拟数据
	local newData = {}
	if typeWay == 1 then--庄
		newData.iWinner = 0;
	else
		newData.iWinner = 1;
	end

	table.insert(msg,newData);

	local dataDeal,msgDeal = self:GetThreeWayList(msg,startPoint);

	if #dataDeal == 0 then
		return nil;
	else
		return msgDeal[#msgDeal].color;
	end

end

--过滤多余的列
function LZLogic:GetMaxLength(msg,MaxLength)
	local lastMsg = {};

	if #msg <= MaxLength then
		lastMsg = clone(msg);
		return lastMsg;
	end

	for k,v in pairs(clone(msg)) do
		if k> #msg - MaxLength then
			lastMsg[k-(#msg - MaxLength)] = v;
		end
	end

	return lastMsg;
end



return LZLogic